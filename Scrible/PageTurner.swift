//
//  PageTurner.swift
//  Scrible
//
//  Created by Jadon Gearhart on 10/2/24.
//

import SwiftUI

struct PageTurner: View {
    @Binding var page: Int
    @State private var dragOffset: CGFloat = 0
    @State private var previousPage: Int? = nil

    var body: some View {
      /*  VStack {
            HStack {
                HStack {
                    Button("\(page - 1)") {
                        withAnimation(.easeInOut) {
                            page -= 1
                        }
                    }
                    .font(.title2)
                    .bold()
                    .transition(.opacity)
                    .foregroundStyle(.secondary)


                    ZStack {
                        if let previousPage = previousPage {
                            Text("\(previousPage)")
                                .padding(10)
                                .frame(width: 30) // Fixed width for consistency
                                .background(.tertiary)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .bold()
                                .offset(x: dragOffset)
                                .opacity(dragOffset != 0 ? 1 : 0) // Show previous page on swipe
                        }
                        
                        Text("Page \(page)")
                            .padding(6)
                            .frame(width: 100) // Fixed width for consistency
                            .background(.tertiary)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .bold()
                            .offset(x: dragOffset)
                            .id(page)
                    }

                    Button("\(page + 1)") {
                        withAnimation(.easeInOut) {
                            page += 1
                        }
                    }
                    .bold()
                    .foregroundStyle(.secondary)

                }
                .frame(width: 250, height: 30)
                .padding(5)
                .background(.thinMaterial)
                .clipShape(Capsule())
                .padding()
                .transition(.opacity)

                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            dragOffset = gesture.translation.width
                        }
                        .onEnded { gesture in
                            if gesture.translation.width < -50 {
                                // Swipe left (forward)
                                withAnimation(.easeInOut) {
                                    page += 1
                                }
                            } else if gesture.translation.width > 50 {
                                // Swipe right (backward)
                                withAnimation(.easeInOut) {
                                    if page > 2  {
                                        page -= 1
                                    }
                                }
                            }
                            previousPage = page
                            dragOffset = 0
                        }
                )

                Spacer()
            }
            Spacer()
        }.offset(CGSize(width: 0, height: 2))*/
        Text("Page ") + Text(String(page)).bold()
    }
}


