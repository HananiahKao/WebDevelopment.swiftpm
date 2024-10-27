import SwiftUI

struct NavigationLinkView: View {
    @ObservedObject var datasets: DataSets
    @Binding var dataSet: DataSet
    @State private var renaming = false
    @FocusState var focused: Bool
    var body: some View {
        if renaming {
            TextField("title", text: $dataSet.title)
                .focused($focused)
                .onSubmit() {
                    renaming = false
                }
        }else{
            NavigationLink(dataSet.title) {
                ContentView(datasets: datasets, dataSet: datasets.getBindingToDataSet(dataSet))
            }
            .swipeActions {
                Button(role: .destructive) {
                    datasets.dataSets.removeAll {$0.id==dataSet.id}
                }label: {
                    Image(systemName: "trash")
                }
            }
            .contextMenu {
                RenameButton()
                /*@START_MENU_TOKEN@*/Text("Menu Item 2")/*@END_MENU_TOKEN@*/
                /*@START_MENU_TOKEN@*/Text("Menu Item 3")/*@END_MENU_TOKEN@*/
            }
            .renameAction {
                focused = true
                renaming = true
            }
            .onChange(of: dataSet.title) {
                datasets.save()
            }
        }
    }
}
