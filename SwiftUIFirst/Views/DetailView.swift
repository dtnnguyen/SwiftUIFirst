//
//  DetailView.swift
//  SwiftUIFirst
// 
//

import Combine      // For Bindable object
import SwiftUI

// To fix flip image
//https://gist.github.com/schickling/b5d86cb070130f80bb40
//https://stackoverflow.com/questions/25796545/getting-device-orientation-in-swift
//https://stackoverflow.com/questions/56843499/swiftui-ipad-app-shows-black-screen-on-enabling-multiple-window-support/56864529#56864529
//https://developer.apple.com/documentation/uikit/uiimage/orientation

/*
 @State: Swift UI let us modify state of struct
 @State: for simple properties like strings, integers, and booleans
 SwiftUI manage update when state change
 two-way binding: bind a state to a UI
 hideNavigationBar flag with NavigationTitleBar
 When hideNavigationBar flag changes NavigationTitleBar is updated
*/
struct DetailImageView : View {
    // State for this one view
    @State private var hideNavigationBar = false
    var selectedImage : String = "IMG_242.png"
    var path : String
    
    // dictionary of image direction and its opposite [ current : desired ]
    var ImageDrection = [
                          UIImage.Orientation.left : UIImage.Orientation.rightMirrored,
                          UIImage.Orientation.upMirrored : UIImage.Orientation.downMirrored,
                          UIImage.Orientation.leftMirrored : UIImage.Orientation.right,
                          UIImage.Orientation.right : UIImage.Orientation.leftMirrored,
                          UIImage.Orientation.downMirrored : UIImage.Orientation.upMirrored,
                          UIImage.Orientation.rightMirrored : UIImage.Orientation.left,
                          ]
    
    var body: some View {
        let fullPathName = path + "/" + selectedImage
    
        let img = UIImage(named: fullPathName)!
        let currentOrientation = img.imageOrientation
        print("image orientation: \(currentOrientation)")
        
        // Rotate and scale image to display it correctly
        var newImage : UIImage = img
        if currentOrientation != UIImage.Orientation.up
        {
            newImage = img.scaleAndRotate()
        }
    
        return Image(uiImage: newImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .navigationBarTitle(Text(selectedImage), displayMode: .inline)
            .navigationBarHidden(hideNavigationBar)
            .tapAction {
                self.hideNavigationBar.toggle()
        }
    }
}

// Image extension to rotate or scale image to display it correctly.
// https://developer.apple.com/documentation/uikit/uiimage/orientation
// https://gist.github.com/schickling/b5d86cb070130f80bb40
extension UIImage {
    func scaleAndRotate() -> UIImage {
        let kMaxResolution : Int = 1280
        let imgRef = self.cgImage
        
        let width = imgRef!.width
        let height = imgRef!.height
        
        var transform = CGAffineTransform.identity
        var bounds = CGRect(x:0, y:0, width: width, height: height)
        if (width > kMaxResolution || height > kMaxResolution) {
            let ratio = width/height
            if ratio > 1 {
                bounds.size.width = CGFloat(kMaxResolution);
                bounds.size.height = bounds.size.width / CGFloat(ratio)
            }
            else {
                bounds.size.height = CGFloat(kMaxResolution);
                bounds.size.width = bounds.size.height * CGFloat(ratio)
            }
        }
        
        let scaleRatio = bounds.size.width / CGFloat(width);
        let imageSize = CGSize(width : imgRef!.width, height: imgRef!.height);
        var boundHeight : CGFloat
        let orient = self.imageOrientation;
        
        switch(orient) {
            
        case UIImage.Orientation.up: //EXIF = 1
            print("orientation: up")
            transform = CGAffineTransform.identity;
            break;
            
        case UIImage.Orientation.upMirrored: //EXIF = 2
            print("orientation: up mirrored")
            transform = CGAffineTransform.init(translationX: imageSize.width, y: 0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            break;
            
        case UIImage.Orientation.down: //EXIF = 3
            print("orientation: down")
            transform = CGAffineTransform.init(translationX: imageSize.width, y: imageSize.height)
            transform = transform.rotated(by: .pi)
            break;
            
        case UIImage.Orientation.downMirrored:      //EXIF = 4
            print("orientation: down mirrored")
            transform = CGAffineTransform.init(translationX: 0, y: imageSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
            break;
        
        case UIImage.Orientation.leftMirrored:      //EXIF = 5
            print("orientation: left mirrored")
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            
            transform = CGAffineTransform.init(translationX: imageSize.height, y: imageSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            let angle = CGFloat(3.0 * .pi/2.0)
            transform = transform.rotated(by: angle)
            break;
        
        case UIImage.Orientation.left:      //EXIF = 6
            print("orientation: left")

            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            
            transform = CGAffineTransform.init(translationX: 0.0, y: imageSize.width)
            let angle = CGFloat(3.0 * .pi/2.0)
            transform = transform.rotated(by: angle)
            break;
            
        case UIImage.Orientation.rightMirrored:     //EXIF = 7
            print("orientation: right mirrored")

            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            
            transform = CGAffineTransform.init(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(.pi / 2.0))
            break
        
        case UIImage.Orientation.right:     //EXIF = 8
            print("orientation: right")

            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
           
            transform = CGAffineTransform.init(translationX: imageSize.height, y: 0)
            //transform = CGAffineTransform.init(translationX: imageSize.height, y: 0.0)
            transform = transform.rotated(by: CGFloat(.pi/2.0))
            break

        default:
            print ("Invalid image orientation.")
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context : CGContext?  = UIGraphicsGetCurrentContext()
        if orient == UIImage.Orientation.right || orient == UIImage.Orientation.left {
            context?.scaleBy(x: -scaleRatio, y: scaleRatio)
            context?.translateBy(x: CGFloat(-height), y: 0)
        }
        else {
            context?.scaleBy(x: scaleRatio, y: -scaleRatio)
            context?.translateBy(x: 0, y: CGFloat(-height))
        }
        
        context?.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = context?.makeImage() else { return self }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
