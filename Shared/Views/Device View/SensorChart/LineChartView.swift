import Foundation
import Algorithms
import SwiftUI

private struct ColumnLines: Shape {
    let columns: [CGFloat]

    init(columns: [CGFloat]) {
        self.columns = columns
    }

    func path(in rect: CGRect) -> Path {

        let xGrid = columns.map {  $0 * rect.width }

        var path = Path()

        for column in xGrid {
            path.move(to: .init(x: column, y: 0))
            path.addLine(to: .init(x: column, y: rect.height))
        }
        return path
    }
}

private struct BorderView: Shape {
    func path(in rect: CGRect) -> Path {

        var path = Path()

        path.move(to: .init(x: 0, y: 0))
        path.addLine(to: .init(x: 0, y: rect.height))
        path.addLine(to: .init(x: rect.width, y: rect.height))

        return path
    }
}

private struct RowLines: Shape {
    let rows: [CGFloat]

    init(rows: [CGFloat]) {
        self.rows = rows
    }

    func path(in rect: CGRect) -> Path {
        let yGrid = rows.map { rect.height * (1 - $0) }

        var path = Path()

        for row in yGrid {
            path.move(to: .init(x: 0, y: row))
            path.addLine(to: .init(x: rect.width, y: row))
        }

        return path
    }
}

private struct YAxisUnitLabel: View {
    let unit: String

    init(unit: String) {
        self.unit = unit
    }

    var body: some View {
        Text(unit)
            .offset(x: 0 + 2, y: 0)
    }
}

struct WidthKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}


struct XAxisValueView: View {
    // Workaround for a SwiftUI Bug.
    // When nesting mutlbile Lists, view are initalized two times, while the second time fire off the GeometryReader
    @EnvironmentObject
    var xLabelCache: SensorGraphXLabelCache

    @State var textWidth: CGFloat?

    let label: String

    let value: CGFloat
    let totalWidth: CGFloat

    var xOffset: CGFloat {
        let textWidth = self.textWidth
            ?? xLabelCache.cache[label]
            ?? 0

        var xPosition = value * totalWidth
        let maxXPosition = totalWidth - textWidth

        // Center text
        xPosition = xPosition - textWidth / 2.0

        let xOffset = max(
            0,
            min(maxXPosition, xPosition)
        )

        return xOffset
    }

    init(label: String, value: CGFloat, totalWidth: CGFloat) {
        self.label = label
        self.value = value
        self.totalWidth = totalWidth
    }

    var body: some View {
        Text(label)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: WidthKey.self, value: proxy.size.width)
                }
            )
            .onPreferenceChange(WidthKey.self) { width in
                guard let width = width else { return }
                self.textWidth = width
                self.xLabelCache.cache[self.label] = width
            }
            .offset(x: xOffset, y: 0)
    }
}

 struct XAxisView: View {

    let normalizedSteps: [AxisLabel]

    init(normalizedSteps: [AxisLabel], presentAsRanges: Bool = true) {
        if presentAsRanges {

            guard normalizedSteps.count > 2 else {
                self.normalizedSteps = [AxisLabel]()
                return
            }

            let xShift = (normalizedSteps[2].value - normalizedSteps[1].value) / 2.0
            let maxXPosition = 1 + xShift

            self.normalizedSteps = normalizedSteps.compactMap { axisLabel -> AxisLabel? in
                let value = axisLabel.value + xShift

                if value >= maxXPosition {
                    return nil
                }

                return AxisLabel(text: axisLabel.text, value: value)
            }
        } else {
            self.normalizedSteps = normalizedSteps
        }
    }

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ForEach(normalizedSteps) { step in
                    XAxisValueView(label: step.text, value: step.value, totalWidth: proxy.size.width)
                }
            }
        }
    }
 }

private struct YAxisView: View {
    @State
    var textHeight: CGFloat = 0

    let normalizedSteps: [AxisLabel]

    init(normalizedSteps: [AxisLabel]) {
        // Remove lowest y value which sits on the x Axis
        self.normalizedSteps = Array<AxisLabel>(normalizedSteps.dropFirst())
    }

    var body: some View {
        GeometryReader { proxy in
            ForEach(normalizedSteps, id: \.self) { value in
                let yOffset: CGFloat = (proxy.size.height * (1 - value.value) + 5)
                    .clamped(to: 0...(proxy.size.height - textHeight))

                Text(value.text)
                    .background(
                        Color(.clear)
                            .geometryReader{ proxy in
                                self.textHeight = proxy.size.height
                            }
                    )
                    .offset(x: 0 + 2, y: yOffset)
            }
        }
    }
}

private struct QuadCurve: Shape {
    private let data: [(x: CGFloat, y: CGFloat)]

    public init(data: [(x: Double, y: Double)]) {
        self.data = data
            .map{ (x: CGFloat($0.x), y: CGFloat($0.y)) }
    }

    public func path(in rect: CGRect) -> Path {

        let points = data.map { data in
            CGPoint(x: data.x * rect.width,
                    y: data.y * rect.height)
        }

        return Path { path in
            path.addQuadCurves(points)
        }
    }
}

public struct LineChart<Background: View>: View {
    @Environment(\.colorScheme)
    var colorScheme

    private var lineColor: Color {
        colorScheme == .light ? .black : .gray
    }
    private let lineWidth: CGFloat

    let data: [(x: Double, y: Double)]
    let backgroundData: [(x: Double, y: Double)]

    let trimFrom: CGFloat = 0
    let trimTo: CGFloat = 1

    let areaUnderCurve: Background

    init(data: [(x: Double, y: Double)], underCurve: Background) {
        self.data = data.map {(x: $0.x, y: 1 - $0.y) }

        var backgroundData = self.data
        if let first = backgroundData.first,
           let last = backgroundData.last {
            backgroundData.insert((x: first.x, y: 1.0), at: 0)
            backgroundData.append((x: last.x, y: 1.0))
        }

        self.backgroundData = backgroundData

        lineWidth = 2
        areaUnderCurve = underCurve
    }

    public var body: some View {
        ZStack {
            areaUnderCurve
                .clipShape(QuadCurve(data: backgroundData))

            QuadCurve(data: data)
                .trim(from: trimFrom, to: trimTo)
                .stroke(lineColor, style: .init(lineWidth: lineWidth, lineCap: .round))
        }
    }
}

struct LineChartView: View {
    @Environment(\.colorScheme)
    var colorScheme

    var data: LineChartData

    init(data: LineChartData) {
        self.data = data
    }

    var defaultGradient: [Color] {
        colorScheme == .light
            ? [Color.blue, Color.white]
            : [Color.blue, Color.gray]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(data.unit)
            ZStack {
                switch data.type {
                case .particlePM1, .particlePM2_5, .particlePM10:
                    LineChart(data: data.unitPoints,
                              underCurve: LinearGradient(gradient: Gradient.airQualtiy(data.valueRange),
                                                         startPoint: .top,
                                                         endPoint: .bottom)
                                .opacity(colorScheme == .light ? 0.7 : 0.4)
                    )
                default:
                    LineChart(data: data.unitPoints,
                              underCurve: LinearGradient(gradient:Gradient(colors: defaultGradient),
                                                         startPoint: .top,
                                                         endPoint: .bottom)
                                .opacity(colorScheme == .light ? 0.7 : 0.4)
                    )
                }

                YAxisView(normalizedSteps: data.yLabels)

                ColumnLines(columns: data.xPositions)
                    .stroke(Color.gray, lineWidth: 0.5)

                RowLines(rows: data.yPositions)
                    .stroke(Color.gray, lineWidth: 0.5)

                BorderView()
                    .stroke(style: StrokeStyle(lineWidth: 1))
            }

            XAxisView(normalizedSteps: data.xLabels, presentAsRanges: data.xScaleIsRanged)
                .frame(height: 20)
        }
    }
}

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        SensorChartViewModel.now = { PreviewData.loadReadingsFullDay().readings.first!.date }
        let readings = PreviewData.loadReadingsFullDay()

        let firstDate = readings.readings.last!.date
        let lastDate = readings.readings.first!.date
        let interval = SensorChartViewModel.dateInterval(with: .day,
                                                         date: lastDate,
                                                         in: TimeZone(abbreviation: "JST")!)
        let chartData = LineChartData(readings: readings,
                                      in: TimeZone(abbreviation: "JST")!,
                                      dateInterval: interval,
                                      selectedDateRange: .day,
                                      type: .particlePM2_5,
                                      unit: "pm2")

        return VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("\(firstDate)")
                Text("\(lastDate)")
                Spacer()
            }
            .padding()

            Picker(selection: .constant(1), label: Text("Date Range"), content: {
                ForEach(DateRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            })
            .pickerStyle(SegmentedPickerStyle())

            LineChartView(data: chartData)
                .padding()
                .frame(height: 300)
        }
        .preferredColorScheme(.dark)
        .environmentObject(SensorGraphXLabelCache())
    }
}
