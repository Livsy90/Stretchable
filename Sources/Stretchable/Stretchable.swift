import SwiftUI

public extension View {
    /// Stretch when the scroll view is pulled past its start edge (top/leading).
    /// - Parameters:
    ///   - axis: .vertical for vertical ScrollView, .horizontal for horizontal ScrollView
    ///   - uniform: if true, scales both axes. If false, scales only along `axis`.
    @ViewBuilder
    func stretchable(
        axis: Axis = .vertical,
        uniform: Bool = true
    ) -> some View {
        if #available(iOS 17.0, *) {
            stretchableView(axis: axis, uniform: uniform)
        } else {
            stretchableViewBackported(axis: axis, uniform: uniform)
        }
    }
}

extension View {
    @available(iOS 17.0, *)
    func stretchableView(
        axis: Axis,
        uniform: Bool
    ) -> some View {
        visualEffect { effect, geometry in
            let frame = geometry.frame(in: .scrollView)
            
            let offset: CGFloat
            let currentLength: CGFloat
            
            switch axis {
            case .vertical:
                offset = frame.minY
                currentLength = geometry.size.height
            case .horizontal:
                offset = frame.minX
                currentLength = geometry.size.width
            }
            
            let positiveOffset = max(0, offset)
            let scale = (currentLength + positiveOffset) / max(currentLength, 0.0001)
            
            let resolvedAnchor: UnitPoint = axis == .vertical ? .bottom : .trailing
            
            if uniform {
                return effect.scaleEffect(
                    x: scale,
                    y: scale,
                    anchor: resolvedAnchor
                )
            } else {
                return effect.scaleEffect(
                    x: axis == .horizontal ? scale : 1,
                    y: axis == .vertical ? scale : 1,
                    anchor: resolvedAnchor
                )
            }
        }
    }
    
    func stretchableViewBackported(
        axis: Axis = .vertical,
        uniform: Bool = false,
    ) -> some View {
        modifier(StretchyModifier(axis: axis, uniform: uniform))
    }
}

private struct StretchyMetrics: Equatable {
    var minX: CGFloat
    var minY: CGFloat
    var width: CGFloat
    var height: CGFloat
    
    static let zero = Self(minX: 0, minY: 0, width: 0, height: 0)
}

private struct StretchyMetricsKey: @MainActor PreferenceKey {
    @MainActor static var defaultValue: StretchyMetrics = .zero
    static func reduce(value: inout StretchyMetrics, nextValue: () -> StretchyMetrics) {
        value = nextValue()
    }
}

private struct StretchyModifier: ViewModifier {
    let axis: Axis
    let uniform: Bool

    @State private var metrics: StretchyMetrics = .zero
    @State private var baseline: CGFloat? = nil

    func body(content: Content) -> some View {
        let rawOffset: CGFloat = (axis == .vertical) ? metrics.minY : metrics.minX
        let currentLength: CGFloat = (axis == .vertical) ? metrics.height : metrics.width

        let base = baseline ?? rawOffset
        let normalizedOffset = rawOffset - base

        let positiveOffset = max(0, normalizedOffset)

        let safeLength = max(currentLength, 0.0001)
        let scale = (currentLength + positiveOffset) / safeLength

        let anchor: UnitPoint = (axis == .vertical) ? .bottom : .trailing

        return content
            .scaleEffect(
                x: uniform ? scale : (axis == .horizontal ? scale : 1),
                y: uniform ? scale : (axis == .vertical ? scale : 1),
                anchor: anchor
            )
            .background(
                GeometryReader { geo in
                    let frame = geo.frame(in: .global)
                    Color.clear.preference(
                        key: StretchyMetricsKey.self,
                        value: .init(
                            minX: frame.minX,
                            minY: frame.minY,
                            width: geo.size.width,
                            height: geo.size.height
                        )
                    )
                }
            )
            .onPreferenceChange(StretchyMetricsKey.self) { newValue in
                metrics = newValue
                if baseline == nil {
                    baseline = (axis == .vertical) ? newValue.minY : newValue.minX
                }
            }
    }
}

#Preview {
    struct HorizontalView: View {
        @State private var size: CGSize = .init(width: 150, height: 150)
        
        var body: some View {
            ScrollView(.horizontal) {
                HStack {
                    ZStack {
                        Rectangle()
                            .fill(.purple.opacity(0.5))
                        
                        Rectangle()
                            .fill(Color.purple.opacity(0.4))
                            .blur(radius: 3)
                            .padding(4)
                        
                        Text("Header")
                            .foregroundColor(.white)
                            .padding(50)
                    }
                    .frame(height: size.height)
                    .stretchable(axis: .horizontal, uniform: true)
                    
                    ForEach(0...30, id: \.self) { _ in
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: size.width, height: size.height)
                    }
                }
            }
        }
    }
    
    return HorizontalView()
}

#Preview {
    struct VerticalView: View {

        var body: some View {
            ScrollView(.vertical) {
                VStack {
                    ZStack {
                        Rectangle()
                            .fill(.purple.opacity(0.5))
                        
                        Rectangle()
                            .fill(Color.purple.opacity(0.4))
                            .blur(radius: 3)
                            .padding(4)
                        
                        Text("Header")
                            .foregroundColor(.white)
                            .padding(50)
                    }
                    .frame(height: 150)
                    .stretchable(axis: .vertical, uniform: true)
                    
                    ForEach(0...30, id: \.self) { _ in
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(height: 150)
                    }
                }
            }
        }
    }
    
    return VerticalView()
}
