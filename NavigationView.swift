import SwiftUI
struct MyNavigationView: View {
    @ObservedObject var datasets: DataSets
    @State var show = false
    @State var newDataSet = DataSet()
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(datasets.dataSets.map{datasets.getBindingToDataSet($0)}) { dataSet in
                    NavigationLinkView(datasets: datasets, dataSet: dataSet)
                }
                .disabled(datasets.dataSets.isEmpty)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        show = true
                    }label: {
                        Image(systemName: "plus")
                    }
                    .popover(isPresented: $show) {
                        VStack(alignment: .leading) {
                            HStack {
                                Button("cancel") {
                                    show = false
                                }
                                Spacer(minLength: 50)
                                Button {
                                    datasets.dataSets.append(newDataSet)
                                    show = false
                                }label: {
                                    Text("add")
                                }
                                .disabled(newDataSet.title.isEmpty)
                            }
                            Text("File Name")
                            TextField("my file", text: $newDataSet.title)
                            Spacer()
                        }
                        .padding(.horizontal,20)
                        .padding(.vertical,10)
                    }
                }
            }
        } detail: {
            Text("Detail")
        }
    }
}

#Preview {
    MyNavigationView(datasets: DataSets())
}

