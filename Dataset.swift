import SwiftUI

struct DataSet: Codable,Identifiable,Equatable {
    var title: String = ""
    var link: String = ""
    var html: String = "hello, world"
    var id = UUID()
}
class DataSets: ObservableObject {
    @Published var dataSets: [DataSet] = [DataSet(title: "hello", link: "", html: "hello, world")]
    private func getFileURL() throws -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("HTMLs")
    }
    func save() {
        let encoder = JSONEncoder()
        do {
           let encodedData = try encoder.encode(self.dataSets)
            try encodedData.write(to: getFileURL())
            print("saved")
        }catch{
            print("error when encoding: \(error)")
        }
    }
    func load() {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: getFileURL())
            let decodedData = try decoder.decode([DataSet].self, from: data)
            self.dataSets = decodedData
            print("loaded")
        }catch{
            print("error when decoding: \(error)")
        }
    }
    func getBindingToDataSet(_ dataset: DataSet) -> Binding<DataSet>{
        Binding<DataSet>(
            get: { 
                guard let index = self.dataSets.firstIndex(where: {$0.id==dataset.id}) else {
                    return dataset
                } 
                return self.dataSets[index]
            },
            set: { ds in
                guard let index = self.dataSets.firstIndex(where: {$0.id==dataset.id}) else {
                    return
                } 
                self.dataSets[index] = ds
            })
    }
}
