//
//  ContentView.swift
//  Calculator
//
//
//
import SwiftUI

enum CalcButton: String {
    case one = "1", two = "2", three = "3"
    case four = "4", five = "5", six = "6"
    case seven = "7", eight = "8", nine = "9"
    case zero = "0"
    case add = "+"
    case subtract = "-"
    case divide = "÷"
    case multiply = "x"
    case equal = "="
    case clear = "AC"
    case decimal = "."
    case percent = "%"
    case negative = "-/+"
}

struct FloatingHeart: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: width/2, y: height))
        path.addCurve(to: CGPoint(x: 0, y: height/4),
                      control1: CGPoint(x: width/2, y: height*3/4),
                      control2: CGPoint(x: 0, y: height/2))
        path.addArc(center: CGPoint(x: width/4, y: height/4),
                    radius: width/4,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false)
        path.addArc(center: CGPoint(x: width*3/4, y: height/4),
                    radius: width/4,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false)
        path.addCurve(to: CGPoint(x: width/2, y: height),
                      control1: CGPoint(x: width, y: height/2),
                      control2: CGPoint(x: width/2, y: height*3/4))
        return path
    }
}

struct ContentView: View {
    @State private var displayValue: String = "0"
    @State private var clearButtonText: String = "AC"
    @State private var isDarkMode: Bool = true
    @State private var hearts: [FloatingHeart] = []

    let buttons: [[CalcButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal],
    ]

    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)

            ForEach(hearts) { heart in
                HeartShape()
                    .fill(heart.color)
                    .frame(width: heart.size, height: heart.size)
                    .position(x: heart.x, y: heart.y)
                    .animation(.linear(duration: 2), value: heart.y)
            }

            VStack {
                HStack {
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 28))
                            .foregroundColor(isDarkMode ? .yellow : .blue)
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 10)

                Spacer()

                HStack {
                    Spacer()
                    Text(displayValue)
                        .bold()
                        .font(.system(size: 60))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding()

                ForEach(0..<buttons.count, id: \.self) { i in
                    HStack(spacing: 12) {
                        ForEach(0..<buttons[i].count, id: \.self) { j in
                            let item = buttons[i][j]
                            Button(action: {
                                self.didTap(button: item, buttonIndex: (i,j))
                            }, label: {
                                Text(item == .clear ? clearButtonText : item.rawValue)
                                    .font(.system(size: 32))
                                    .frame(
                                        width: self.buttonWidth(item: item),
                                        height: self.buttonHeight()
                                    )
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: gradientColors(for: item)),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(self.buttonWidth(item: item)/2)
                                    .shadow(color: .white.opacity(0.3), radius: 6, x: 0, y: 3)
                            })
                        }
                    }
                    .padding(.bottom, 3)
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    func gradientColors(for button: CalcButton) -> [Color] {
        switch button {
        case .add, .subtract, .multiply, .divide, .equal:
            return [Color.pink, Color.purple]
        case .clear, .negative, .percent:
            return [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]
        default:
            return [Color.pink.opacity(0.7), Color.purple.opacity(0.4)]
        }
    }

    func didTap(button: CalcButton, buttonIndex: (Int, Int)) {
        switch button {
        case .add, .subtract, .multiply, .divide, .decimal:
            if displayValue == "0" { displayValue = "" }
            displayValue += button.rawValue
            clearButtonText = "⌫"
        case .equal:
            let result = evaluateExpression(displayValue)
            displayValue = result
            clearButtonText = "AC"
            if displayValue == "777" {
                openYouTube()
            }
        case .clear:
            if clearButtonText == "AC" {
                displayValue = "0"
            } else {
                displayValue.removeLast()
                if displayValue.isEmpty { displayValue = "0"; clearButtonText = "AC" }
            }
        case .negative:
            if displayValue.hasPrefix("-") {
                displayValue.removeFirst()
            } else {
                displayValue = "-" + displayValue
            }
            clearButtonText = "⌫"
        case .percent:
            if let val = Double(displayValue) {
                displayValue = formatResult(val / 100)
            }
        default:
            let number = button.rawValue
            if displayValue == "0" {
                displayValue = number
            } else {
                displayValue += number
            }
            clearButtonText = "⌫"
            addHearts(fromButton: buttonIndex)
        }
    }

    func addHearts(fromButton index: (Int, Int)) {
        let buttonWidth = self.buttonWidth(item: buttons[index.0][index.1])
        let buttonHeight = self.buttonHeight()
        let spacing: CGFloat = 12
        let startX = spacing + CGFloat(index.1) * (buttonWidth + spacing) + buttonWidth/2
        let startY = UIScreen.main.bounds.height - CGFloat(buttons.count - index.0) * (buttonHeight + spacing) + buttonHeight/2

        for _ in 0..<15 {
            let heart = FloatingHeart(
                x: startX + CGFloat.random(in: -20...20),
                y: startY + CGFloat.random(in: -10...10),
                size: CGFloat.random(in: 8...14),
                color: [.pink, .red, .purple].randomElement()!
            )
            hearts.append(heart)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if let i = hearts.firstIndex(where: { $0.id == heart.id }) {
                    withAnimation(.linear(duration: 2)) {
                        hearts[i].y = 50 + CGFloat.random(in: -30...30)
                        hearts[i].x += CGFloat.random(in: -20...20)
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                hearts.removeAll { $0.id == heart.id }
            }
        }

    }

    func evaluateExpression(_ expr: String) -> String {
        let replaced = expr
            .replacingOccurrences(of: "x", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
        let expression = NSExpression(format: replaced)
        if let result = expression.expressionValue(with: nil, context: nil) as? Double {
            return formatResult(result)
        }
        return "Error"
    }

    func formatResult(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.2f", value)
        }
    }

    func buttonWidth(item: CalcButton) -> CGFloat {
        if item == .zero {
            return ((UIScreen.main.bounds.width - (4*12)) / 4) * 2
        }
        return (UIScreen.main.bounds.width - (5*12)) / 4
    }

    func buttonHeight() -> CGFloat {
        return (UIScreen.main.bounds.width - (5*12)) / 4
    }

    func openYouTube() {
        if let url = URL(string: "https://m.youtube.com/watch?v=TWo7ktEPxSg&pp=ygUOWmFtYW5zxLF6ZMSxayDSBwkJrQkBhyohjO8%3D") {
            UIApplication.shared.open(url)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
