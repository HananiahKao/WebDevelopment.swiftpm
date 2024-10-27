import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject var datasets: DataSets
    @Binding var dataSet: DataSet
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    enum screen {
        case code
        case view
        case both
    }
    let Scales: [DynamicTypeSize : CGFloat] = [
        .xSmall : 0.8,
        .small : 0.85,
        .medium : 0.9,
        .large : 1.0,
        .xLarge : 1.1,
        .xxLarge : 1.2,
        .xxxLarge : 1.35,
        .accessibility1 : 1.6,
        .accessibility2 : 1.9,
        .accessibility3 : 2.35,
        .accessibility4 : 2.75,
        .accessibility5 : 3.1
    ]
    @State var scr: screen = .code
    @State var show = false
    var body: some View {
        HStack {
            if scr == .code || scr == .both{
                VStack {
                    ZStack {
                        Rectangle()
                            .clipShape(RoundedRectangle(cornerRadius: 20*Scales[dynamicTypeSize]!))
                            .foregroundStyle(.tertiary)
                            .frame(height: 30*Scales[dynamicTypeSize]!)
                        TextField("type or paste URL", text: $dataSet.link)
                            .font(.custom("menlo", size: 15))
                            .frame(height: 30)
                            .padding(.leading,15*Scales[dynamicTypeSize]!)
                    }
                    TextEditor(text: $dataSet.html)
                    .font(.custom("menlo", size: 15))
                    .onChange(of: dataSet.html) {
                        datasets.save()
                    }
                    .onChange(of: dataSet.link) {
                        dataSet.html = "loading HTML..."
                        Task {
                            let text = await makeHTML(dataSet.link)
                            dataSet.html = beautify(text)
                        }
                        
                    }
                }
            }
            if scr == .both {
                Rectangle()
                    .frame(width: 1)
            }
            if scr == .view || scr == .both{
                webView(html: dataSet.html, url: dataSet.link)
            }
        }
        .padding()
        .toolbar{
            ToolbarItem(placement: .bottomBar) {
                Button{
                    scr = scr == .both ? .code : scr == .code ? .view : .both
                }label: {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .imageScale(.large)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button{
                    show = true
                }label: {
                    Image(systemName: "info.circle.fill")
                        .imageScale(.large)
                }
                .popover(isPresented: $show) {
                    VStack {
                        webView(url: "https://www.w3schools.com/tags/default.asp")
                            .frame(width: 500 ,height: 500)
                    }
                    .frame(width: 500 ,height: 500)
                }
            }
        }
    }
}
struct webView: UIViewRepresentable {
    var html: String?
    var url: String
    typealias UIViewType = WKWebView
    func makeUIView(context: Context) -> WKWebView {
        let uiview = WKWebView()
        if let htmlin = html {
            uiview.loadHTMLString(htmlin, baseURL: URL(string: url))
        }else{
            uiview.load(URLRequest(url: URL(string: url)!))
        }
        return uiview
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let htmlin = html {
            uiView.loadHTMLString(htmlin, baseURL: URL(string: url))
        }else{
            uiView.load(URLRequest(url: URL(string: url)!))
        }
    }
}
func makeHTML(_ text: String) async -> String{
    print(#function)
    guard let myURL = URL(string: text) else {
        print("Error: \(text) doesn't seem to be a valid URL")
        return ""
    }
    
    do {
        let data = try await URLSession.shared.data(from: myURL).0
        let myHTMLString = String(data: data, encoding: .ascii)!
        return myHTMLString
    } catch let error {
        print("Error: \(error)")
    }
    return ""
}
func beautify(_ text: String) -> String {
    print(#function)
    var modifiedText = ""
    var tabs = 0
    let regex = try! NSRegularExpression(pattern: "(</?[\\d\\w\",_ /:;!-={}']+>)")
    var textAfterTag = ""
    for match in regex.matches(in: text, range: NSRange(location: 0, length: text.count)) {
        var rangeOfTag = Range(match.range,in: text)!
        var tag: Substring
        rangeOfTag = Range(match.range,in:text)!
        tag = text[rangeOfTag]
        for range in text.ranges(of: "<") {
            if range.lowerBound >= rangeOfTag.upperBound{
                textAfterTag = String(text[rangeOfTag.upperBound..<range.lowerBound])
                break
            }
        }
        if !tag.hasPrefix("</") && textAfterTag.isEmpty{
            if text.contains("</"+tag[tag.index(tag.startIndex, offsetBy: 1)..<tag.endIndex]) {
                modifiedText += String(repeating: "\t",count: tabs >= 0 ? tabs : 0) + tag + "\n"
                tabs += 1
            }else{
                modifiedText += String(repeating: "\t",count: tabs >= 0 ? tabs : 0) + tag + "\n"
            }
        }else if tag.hasPrefix("</"){
            tabs -= 1
            modifiedText += String(repeating: "\t",count: tabs >= 0 ? tabs : 0) + tag + "\n"
        }else{
            modifiedText += String(repeating: "\t",count: tabs >= 0 ? tabs : 0) + tag + "\n"
        }
        if !textAfterTag.isEmpty {
            tabs += 1
            modifiedText += String(repeating: "\t",count: tabs >= 0 ? tabs : 0) + textAfterTag + "\n"
        }
    }
    return modifiedText
}