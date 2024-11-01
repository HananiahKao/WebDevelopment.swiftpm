import SwiftUI

@main
struct MyApp: App {
    @StateObject var datasets = DataSets()
    var body: some Scene {
        WindowGroup {
            MyNavigationView(datasets: datasets)
                .statusBar(hidden: true)
                .task {
                    datasets.load()
                }
                .onChange(of: datasets.dataSets, {
                    datasets.save()
                })
        }
    }
}
