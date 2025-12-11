import SwiftUI

enum AnimDirection {
    case leftToRight
    case rightToLeft
}

struct AnimatedImageLoader: View {

    // MARK: - Properties
    let imageNames: [String]
    let size: CGFloat
    let animationDuration: Double
    let pauseDuration: Double
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let imagePadding: CGFloat
    @Binding var animationDirection: AnimDirection

    // ⭐ New Flag — Controls Start/Stop
    @Binding var isAnimating: Bool

    @State private var currentIndex: Int = 0
    @State private var animateOffset: CGFloat = 0
    @State private var isLoopActive: Bool = false   // internal flag to stop loops

    // MARK: - Init
    init(
        imageNames: [String] = [
            "Variant10", "Variant11", "Variant12", "Variant13",
            "Variant14", "Variant15", "Variant16", "Variant17", "Variant18"
        ],
        size: CGFloat = 100,
        animationDuration: Double = 0.4,
        pauseDuration: Double = 0.3,
        cornerRadius: CGFloat = 10,
        backgroundColor: Color = Color.gray.opacity(0.2),
        imagePadding: CGFloat = 0,
        direction: Binding<AnimDirection> = .constant(.rightToLeft),
        isAnimating: Binding<Bool> = .constant(true)
    ) {
        self.imageNames = imageNames
        self.size = size
        self.animationDuration = animationDuration
        self.pauseDuration = pauseDuration
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.imagePadding = imagePadding
        self._animationDirection = direction
        self._isAnimating = isAnimating
    }

    // MARK: - UI
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .overlay(
                    GeometryReader { geo in
                        let width = geo.size.width
                        HStack(spacing: 0) {
                            ForEach(imageNames.indices, id: \.self) { i in
                                Image(imageNames[i])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: width - imagePadding * 2,
                                        height: width - imagePadding * 2
                                    )
                                    .padding(imagePadding)
                            }
                        }
                        .offset(x: animateOffset)
                        .onChange(of: isAnimating) { _, newValue in
                            if newValue {
                                startAnimation(width: width)
                            } else {
                                stopAnimation()
                            }
                        }
                        .onAppear{
                            if isAnimating{ startAnimation(width: width) }
                        }
                    }
                    .clipped()
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    // MARK: - Animation Control
    private func startAnimation(width: CGFloat) {
        guard !isLoopActive else { return }
        isLoopActive = true
        animateNext(width: width)
    }

    private func stopAnimation() {
        isLoopActive = false
    }

    private func animateNext(width: CGFloat) {
        guard isLoopActive else { return }

        withAnimation(.easeInOut(duration: animationDuration)) {
            switch animationDirection {
            case .leftToRight:
                currentIndex -= 1
                animateOffset = -width * CGFloat(currentIndex)
            case .rightToLeft:
                currentIndex += 1
                animateOffset = -width * CGFloat(currentIndex)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + pauseDuration) {

            guard isLoopActive else { return }

            switch animationDirection {
            case .leftToRight:
                if currentIndex <= 0 {
                    currentIndex = imageNames.count - 1
                    animateOffset = -width * CGFloat(currentIndex)
                }
            case .rightToLeft:
                if currentIndex >= imageNames.count {
                    currentIndex = 0
                    animateOffset = 0
                }
            }

            animateNext(width: width)
        }
    }
}

struct TestLoaderView: View {
    
    @State private var loading = true
    @State private var direction :AnimDirection = .rightToLeft
    var body: some View {
        VStack(spacing: 30) {

            AnimatedImageLoader(direction: $direction, isAnimating: $loading)

            Button(loading ? "Stop" : "Start") {
                loading.toggle()
            }
            .padding()
            Button(direction == .rightToLeft ? "Left To Right" : "Right To Left") {
                if direction == .leftToRight {
                    direction = .rightToLeft
                }else{
                    direction = .leftToRight
                }
            }
        }
    }
}



// MARK: - Preview
#Preview {
    TestLoaderView()
//    VStack(spacing: 30) {
//        AnimatedImageLoader()
//        AnimatedImageLoader(size: 80)
//        VariantImageLoader(directino: .leftToRight)
//    }
//    .padding()
}
