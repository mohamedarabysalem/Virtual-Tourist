//
//  Flicker.swift
//  VirtualTourist
//
//  Created by Mohamad El Araby on 4/17/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import Foundation


class FlickerAPI {
    static var shared = FlickerAPI()
    var lat : Double?
    var lon : Double?
    
    
    func getImageFromFlicker (lat : Double , lon : Double,page : Int , completion : @escaping (_ result : [[String:AnyObject]])-> Void){
        self.lat = lat
        self.lon = lon
        let methodParameters = [
            "method": "flickr.photos.search",
            "api_key": "e642c34c6ac8532ef77a7ec1c221babc",
            "bbox": bboxString(),
            "per_page": "30",
            "page": "\(page)",
            "safe_search": "1",
            "extras": "url_m",
            "format": "json",
            "nojsoncallback": "1"
            ] as [String : Any]
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in methodParameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
       // print(components.url)
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            let parsedData : NSDictionary
            do {
                parsedData = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
               // print(parsedData)
            }catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            guard let photosDictionary = parsedData["photos"] as? [String:AnyObject] else {
                print("Cannot find keys photos in \(parsedData)")
                return
            }
            guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                print("Cannot find key photo in \(photosDictionary)")
                return
            }
            completion(photosArray)
        }
        task.resume()
    }
    func bboxString() -> String {
        
        let minimumLon = max(lon! - 1.0, (-180.0, 180.0).0)
        let minimumLat = max(lat! - 1.0, (-90.0, 90.0).0)
        let maximumLon = min(lon! + 1.0, (-180.0, 180.0).1)
        let maximumLat = min(lat! + 1.0, (-90.0, 90.0).1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}
