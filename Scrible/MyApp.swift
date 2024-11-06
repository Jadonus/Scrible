
import SwiftUI

struct Onboardingg: View {
    
    @State private var isAnimationTriggered: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Banner contains slowly moving cards at the top. You can place whatever you want inside this view.
            // Technically, it occupies the entire screen, but only the part at the top is visible due to
            // the LinearGradient used on top of it.
            BannerView()
                .frame(maxHeight: .infinity, alignment: .top)
                .bannerAnimation(isTriggered: isAnimationTriggered)
            
            VStack {
                VStack(spacing: 0) {
                    // LinearGradient fades out the Banner.
                    // I use it inside the VStack so that regardless of the size of the text used in TitleAndDescription() below,
                    // the LinearGradient here occupies the rest of the screen, no matter the screen size of the device or font size used,
                    // such as when users set larger fonts for accessibility, etc.
                    // Clear color is used to fade out the Banner.
                    LinearGradient(gradient: Gradient(stops: [.init(color: Color.clear, location: 0),
                                                              .init(color: Color(UIColor.systemBackground), location: 0.99)]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                    
                    // Contains the welcome title, description, and "Dive In" button. You can have whatever you want here.
                    VStack(spacing: 30) {
                        VStack(spacing: 5) {
                            Text("Welcome to Scrible")
                                .font(.title.bold())
                                .offsetAnimation(isTriggered: isAnimationTriggered, delay: 0.1)
                            Text("A bible app purpose built for study.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .offsetAnimation(isTriggered: isAnimationTriggered, delay: 0.3)
                        }
                        NavigationLink(destination: Text("Next Step")) {
                            Label("Dive In", systemImage: "rectangle.portrait.and.arrow.right.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(15)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                }
                                .offsetAnimation(isTriggered: isAnimationTriggered, delay: 0.5)
                        }
                    }
                    .padding(30)
                    .layoutPriority(1)
                    // You also need to set the background behind the text so the rest of the Banner() is not visible
                    // behind it.
                    .background { Color(UIColor.systemBackground) }
                }
            }
        }
        .onAppear { isAnimationTriggered = true }
    }
    
}

struct Onboarding2: View {
    var body: some View {
     Text("Some awesome Scrible features")
        
        

    }
    
}

// MARK: BANNER
struct BannerView: View {
    
    let colors: [Color] = [.red, .orange, .blue, .green, .pink, .yellow, .gray, .brown]
    @State private var isAnimationTriggered: Bool = false
    
    var body: some View {
        // GeometryReader is used so the cards below can exceed the boundries of the screen without
        // affecting other elements (Texts and the button)
        GeometryReader { _ in
            VStack(spacing: 10) {
                ForEach(Array(colors.enumerated()), id: \.element) { index, color in
                    HStack(spacing: 10) {
                        ForEach(0..<5, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 250, height: 70)
                                .foregroundStyle(color)
                        }
                    }
                    .offset(x: CGFloat(index) * -80.0)
                }
            }
            // subtle "scrolling" animation effect of the cards
            .offset(x: isAnimationTriggered ? -400 : 0)
            .animation(.linear(duration: 50).repeatForever(autoreverses: true), value: isAnimationTriggered)
            .onAppear { isAnimationTriggered = true }
        }
    }
    
}


// MARK: HELPERS
extension View {
    
    func offsetAnimation(isTriggered: Bool, delay: CGFloat) -> some View {
        return self
            .offset(y: isTriggered ? 0 : 30)
            .opacity(isTriggered ? 1 : 0)
            .animation(.smooth(duration: 1.4, extraBounce: 0.2).delay(delay), value: isTriggered)
    }
    
    func bannerAnimation(isTriggered: Bool) -> some View {
        return self
            .scaleEffect(isTriggered ? 1 : 0.95)
            .opacity(isTriggered ? 1 : 0)
            .animation(.easeOut(duration: 1), value: isTriggered)
    }
    
}


// MARK: PREVIEW
