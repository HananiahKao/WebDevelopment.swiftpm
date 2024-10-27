import SwiftUI

struct SolarSystemWebView: View {
    var body: some View {
        webView(url: "https://eyes.nasa.gov/apps/solar-system/#/home")
    }
}

#Preview {
    SolarSystemWebView()
}
