import SwiftUI

public struct ActivityCapsule: View {
    public enum State {
        case none
        case active
        case failed(String)
    }

    @Binding
    var state: State
    var buttonAction: () -> Void

    public var body: some View {
        withAnimation (.easeInOut(duration: 0.3)) {
            HStack{
                switch self.state {
                case .none:
                    Button(action: buttonAction) {
                        Image(systemName: "arrow.2.circlepath")
                    }
                    .frame(width: 20)
                    .foregroundColor(.black)

                case .active:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading...")
                        .padding(.horizontal, 10)

                case let .failed(text):
                    Button(action: buttonAction) {
                        Image(systemName: "arrow.2.circlepath")
                    }
                    .foregroundColor(.black)
                    Text(text)
                        .padding(.trailing, 10)
                }
            }
            .fixedSize()
            .padding(.all, 10)
            .clipped()
            .background( Capsule().fill(Color.white) )
            .overlay( Capsule().stroke(Color.black, lineWidth: 1) )
            .frame(height: 20)
        }
    }
}

#if DEBUG
struct ActivityCapsule_Previews: PreviewProvider {

    @State
    static var state = ActivityCapsule.State.none
    static var previews: some View {
        ActivityCapsule(state: $state, buttonAction: {
            self.state = .active
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.state = .failed("Something went wrong. Try again?")
            }
        })
    }
}
#endif
