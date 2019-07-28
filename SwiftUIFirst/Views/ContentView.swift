//
//  ContentView.swift
//  SwiftUIFirst
//
// Reference: https://github.com/twostraws/HackingWithSwift

import Combine      // For Bindable object
import SwiftUI

/*
 @ObjectBinding
*/

class DataSource : BindableObject{
    let didChange = PassthroughSubject<Void, Never>()
    var pictures = [String]()
    var path = String()
    
    func getResourceContent(prefix: String){
        let fm = FileManager.default
        guard let paths = Bundle.main.resourcePath else { return }
        guard let items : [String] = try? fm.contentsOfDirectory(atPath: paths) else { return }
        print("items: \(items)")
        
        for item in items {
            let fullPath = paths + "/" + item
            if let contents : [String] = try? fm.contentsOfDirectory(atPath: fullPath)
            {
                for content in contents {
                    if content.hasPrefix(prefix) {
                        self.path = fullPath
                        pictures.append(content)
                    }
                }
            }
        }
    }
    
    init() {
        getResourceContent(prefix: "IMG_")
        // Any time there is a change in this folder, it will reload this picture array
        didChange.send(())
    }
    
}

struct ContentView : View {
    // Grab bindable data
    // SwiftUI will take control of object binding
    @ObjectBinding var dataSource = DataSource()
    
    // Add the list of picture to the list control
    var body: some View {
        NavigationView{
            List(dataSource.pictures.identified(by: \.self)){
                picture in
                NavigationLink(destination: DetailImageView(selectedImage: picture, path: self.dataSource.path)) {
                    Text(picture)
                }
            }.navigationBarTitle(Text("Animals"))
        }
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
