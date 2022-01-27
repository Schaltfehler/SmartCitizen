import SwiftUI

public struct DateView: View {
    var date: Date
    
    let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
    
    public var body: some View {
        Text(dateFormatter.string(from: date))
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(date: Date())
    }
}
