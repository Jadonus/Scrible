import SwiftUI
import PencilKit

struct ToolChanger: View {
    @Binding var tool: PKTool
    @State private var selectedColor: Color = .primary
    @State private var selectedHighlightColor: Color = .yellow
    @State private var eraserWidth = 30.0

    var body: some View {
            HStack {
                Button(action: {
                    tool = PKInkingTool(.pen, color: UIColor(selectedColor))
                }) {
                    Image(systemName: "pencil.tip")
                }
                .foregroundStyle(isCurrentTool(PKInkingTool(.pen, color: UIColor(selectedColor))) ? .primary : .secondary)
                .background {
                    if isCurrentTool(PKInkingTool(.pen, color: UIColor(selectedColor))) {
                        
                        Circle()
                            .frame(width: 35, height:35)
                            .foregroundStyle(.bar)
                            .zIndex(-1)
                    }
                    else {
                        Circle().foregroundStyle(.clear)
                    }
                }
                .contextMenu {
                    Picker("Color", selection: $selectedColor) {
                        Image(systemName: "circle.fill")
                            .tint(.primary)
                            .tag(Color.primary)
                        Image(systemName: "circle.fill")
                            .tint(.blue)
                            .tag(Color.blue)
                        Image(systemName: "circle.fill")
                            .tint(.red)
                            .tag(Color.red)
                    }.pickerStyle(.palette)
                }
                
                Button(action: {
                    tool = PKInkingTool(.marker, color: UIColor(selectedHighlightColor))
                }) {
                    Image(systemName: "highlighter")
                }
                .foregroundStyle(isCurrentTool(PKInkingTool(.marker, color: UIColor(selectedHighlightColor))) ? .primary : .secondary)
                .background {
                    if isCurrentTool(PKInkingTool(.marker, color: UIColor(selectedHighlightColor))) {
                        
                        Circle()
                            .frame(width: 35, height:35)
                            .foregroundStyle(.bar)
                            .zIndex(-1)
                    }
                    else {
                        Circle().foregroundStyle(.clear)
                    }
                }
                .contextMenu {
                    Picker("Color", selection: $selectedHighlightColor) {
                        Image(systemName: "circle.fill")
                            .tint(.yellow)
                            .tag(Color.yellow)
                        Image(systemName: "circle.fill")
                            .tint(.blue)
                            .tag(Color.blue)
                        Image(systemName: "circle.fill")
                            .tint(.orange)
                            .tag(Color.orange)
                        Image(systemName: "circle.fill")
                            .tint(.green)
                            .tag(Color.green)
                    }.pickerStyle(.palette)
                }
                
                Button(action: {
                    tool = PKEraserTool(.bitmap, width: eraserWidth)
                }) {
                    Image(systemName: "eraser")
                }
                .foregroundStyle(isCurrentTool(PKEraserTool(.bitmap, width: eraserWidth)) ? .primary : .secondary)
                .background {
                    if isCurrentTool(PKEraserTool(.bitmap, width: eraserWidth)) {
                        
                        Circle()
                            .frame(width: 35, height:35)
                            .foregroundStyle(.bar)
                            .zIndex(-1)
                    }
                    else {
                        Circle().foregroundStyle(.clear)
                    }
                }
                .contextMenu {
                    Slider(value: $eraserWidth,
                           minimumValueLabel: Text("Thinner"),
                           maximumValueLabel: Text("Thicker"),
                           label: { Text("") }
                    )
                }
            }
        
    }
    
    private func isCurrentTool(_ candidate: PKTool) -> Bool {
        // Compare the type and properties of the tools
        if let currentInkingTool = tool as? PKInkingTool, let candidateInkingTool = candidate as? PKInkingTool {
            return currentInkingTool.inkType == candidateInkingTool.inkType &&
                   currentInkingTool.color == candidateInkingTool.color
        } else if let currentEraserTool = tool as? PKEraserTool, let candidateEraserTool = candidate as? PKEraserTool {
            return currentEraserTool.eraserType == candidateEraserTool.eraserType &&
                   currentEraserTool.width == candidateEraserTool.width
        }
        return false
    }
}
