//
//  LoadingIndicator.swift
//  Demo
//
//  Created by Anand Upadhyay on 09/12/25.
//

import SwiftUI

struct SlidingImagesLoader: View {
    let images: [String]          // image asset names
    let imageSize: CGSize
    let speed: Double            // seconds for one full slide

    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width

            HStack(spacing: 16) {
                // First sequence
                ForEach(images.indices, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.width, height: imageSize.height)
                }

                // Second sequence for seamless loop
                ForEach(images.indices, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.width, height: imageSize.height)
                }
            }
            .frame(width: width * 2, alignment: .leading)
            .offset(x: offset)
            .onAppear {
                // Start from the right
                offset = 0
                withAnimation(
                    .easeInOut(duration: speed)
                        .repeatForever(autoreverses: false)
                ) {
                    // Move full width to the left continuously
                    offset = -width
                }
            }
            .clipped()
        }
        .frame(height: imageSize.height)
    }
}


struct HorizontalImagesLoader: View {
    let images: [String]
    let imageSize: CGFloat
    let spacing: CGFloat
    let speed: Double          // seconds for one full travel

    @State private var phase: Double = 0  // 0...1

    var body: some View {
        TimelineView(.animation) { timeline in
            // drive phase based on time
            let t = timeline.date.timeIntervalSinceReferenceDate
            // normalize 0...1
            let localPhase = (t.truncatingRemainder(dividingBy: speed)) / speed

            HStack(spacing: spacing) {
                ForEach(images.indices, id: \.self) { index in
                    let offsetFraction = Double(index) / Double(images.count)
                    // shift each image so they are staggered
                    let progress = (localPhase + offsetFraction)
                        .truncatingRemainder(dividingBy: 1)

                    // 1 -> 0 (right to left)
                    let x = 1.0 - progress

                    Image(images[index])
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                        .opacity(easeInOut(progress))              // ease opacity if you want
                        .offset(x: CGFloat((x - 0.5) * 200))       // 200 = travel width
                }
            }
        }
        .frame(height: imageSize)
    }

    // simple easeInOut curve for opacity or any other parameter
    private func easeInOut(_ t: Double) -> Double {
        // cosine-based smoothstep
        return 0.5 - 0.5 * cos(t * .pi)
    }
}

struct SlidingImageLoader: View {
    let imageName: String
    let height: CGFloat
    let backgroundOpacity: Double
    let duration: Double   // seconds for one leftward pass
    let cornerRadius: CGFloat

    @State private var animate = false

    public init(imageName: String = "paperplane.fill",
                height: CGFloat = 48,
                backgroundOpacity: Double = 0.12,
                duration: Double = 1.6,
                cornerRadius: CGFloat = 12)
    {
        self.imageName = imageName
        self.height = height
        self.backgroundOpacity = backgroundOpacity
        self.duration = duration
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            // We'll move the image from off the right edge to off the left edge
            let travel = totalWidth + height // enough to clear both edges (image ~ height)

            ZStack {
                // rounded rectangle with transparent light gray background
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.gray.opacity(backgroundOpacity))
                    .frame(height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.gray.opacity(backgroundOpacity * 1.5), lineWidth: 0) // subtle border if wanted
                    )

                // moving image
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: height * 0.6) // image size relative to container
                    .offset(x: animate ? -travel/2 : travel/2) // animate from right -> left
                    // center vertically inside the rectangle
                    .animation(
                        .linear(duration: duration)
                            .repeatForever(autoreverses: false),
                        value: animate
                    )
                    .accessibilityHidden(true)
            }
            .frame(height: height)
            // Keep a bit of padding so the image visibly travels inside the rounded rect
            .onAppear {
                // tiny delay so layout finishes before animation starts (avoids jump)
                DispatchQueue.main.async {
                    animate = true
                }
            }
        }
        .frame(height: height)
        // Optional subtle shadow
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}


// MARK: - Reusable Animated Variant View
struct VariantAnimator: View {
    let imageNames: [String]
    let size: CGFloat
    @State private var currentIndex: Int = 0
    @State private var animateOffset: CGFloat = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: size, height: size)
                .overlay(
                    GeometryReader { geo in
                        let width = geo.size.width
                        HStack(spacing: 0) {
                            ForEach(imageNames.indices, id: \.self) { index in
                                Image(imageNames[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: width, height: width)
                            }
                        }
                        .offset(x: animateOffset)
                        .onAppear {
                            startAnimation(width: width)
                        }
                    }
                )
        }
    }

    private func startAnimation(width: CGFloat) {
        let totalWidth = width * CGFloat(imageNames.count)
        animateOffset = 0

        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
            animateOffset = -totalWidth + width
        }
    }
}



// MARK: - Extension for Universal Use
extension View {
    func variantAnimatorSquare(size: CGFloat = 50) -> some View {
        VariantAnimator(imageNames: ["Variant10", "Variant11", "Variant12", "Variant13","Variant14","Variant15","Variant16","Variant17","Variant18"], size: size)
    }
}

// MARK: - Preview
struct VariantAnimator_Previews: PreviewProvider {
    static var previews: some View {
        VariantAnimator(imageNames: ["Variant10", "Variant11", "Variant12", "Variant13","Variant14","Variant15","Variant16","Variant17","Variant18"], size: 50)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}


struct LoadingContentView: View {
    var body: some View {
        
        SlidingImageLoader(imageName: "Variant10",
height: 56,backgroundOpacity: 0.10,duration: 1.2)
.padding(.horizontal)
        
        
//        SlidingImageLoader(
//            images: ["Variant10", "Variant11", "Variant12", "Variant13","Variant14","Variant15","Variant16","Variant17","Variant18"],
//            imageSize: CGSize(width: 40, height: 40),
//            speed: 1.0  // adjust for faster/slower
//        )
    }
}

#Preview {
    LoadingContentView()
}
