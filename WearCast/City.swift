/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A representation of a single landmark.
*/

import Foundation
import SwiftUI
import CoreLocation

struct City: Hashable, Codable, Identifiable {
    static var imagePool: [String: UIImage] = [:]
    var id: Int
    var name: String
    var country: String
    var description: String
    var imageName: String
    
    init(id: Int, name: String, country: String, description: String, imageName: String) {
        self.id = id
        self.name = name
        self.country = country
        self.description = description
        self.imageName = imageName
    }

//    func uiImage(size: CGSize? = nil) -> UIImage?{
//
//        var image = City.imagePool[imageName]
//        if image == nil{
//            image = UIImage(named: imageName)!
//        }
////        if image == nil{
////            DbFirebase.downloadImage(imageName: imageName){ image in
////                
////                let resizedImage = image!.resized(to: size!)
////                City.imagePool[name] = resizedImage
////                //return resizedImage
////                
////            }
////        }
//        guard let size = size else{ return image}
//        let resizedImage = image!.resized(to: size)
//        City.imagePool[name] = resizedImage
//        return resizedImage
//    }
    
    func uiImage(size: CGSize? = nil, completion: @escaping (UIImage) -> Void) -> Void{

        var image = City.imagePool[imageName]
        if image == nil{
            image = UIImage(named: imageName)!
        }
        if image != nil{
            guard let size = size else{
                completion(image!)
                return
            }
            let resizedImage = image!.resized(to: size)
            City.imagePool[name] = resizedImage
            completion(resizedImage)
            return
        }

//        DbFirebase.downloadImage(imageName: imageName){ image in
//            
//            let resizedImage = image!.resized(to: size!)
//            City.imagePool[name] = resizedImage
//            completion(resizedImage)
//            
//        }


    }

    var image: Image {
        Image(imageName)
    }
}

extension City{
    static func toDict(city: City) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["id"] = city.id
        dict["name"] = city.name
        dict["country"] = city.country
        dict["description"] = city.description
        dict["imageName"] = city.imageName

        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> City{
        
        let id = dict["id"] as! Int
        let name = dict["name"] as! String
        let country = dict["country"] as! String
        let description = dict["description"] as! String
        let imageName = dict["imageName"] as! String

        return City(id: id, name: name, country: country, description: description, imageName: imageName)
    }
}

