//
//  QiscusLinkData.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 1/17/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

open class QiscusLinkData: Object {
    open dynamic var localId:Int = 0
    open dynamic var linkURL:String = ""{
        didSet{
            if localId > 0 {
                let id = self.localId
                let value = linkURL
                
                    let realm = try! Realm(configuration: Qiscus.dbConfiguration)
                    let searchQuery = NSPredicate(format: "localId == \(id)")
                    
                    let linkData = realm.objects(QiscusLinkData.self).filter(searchQuery)
                    
                    if linkData.count > 0{
                        let firstLink = linkData.first!
                        if firstLink.linkURL != value{
                            try! realm.write {
                                firstLink.linkURL = value
                            }
                        }
                    }
                
            }
        }
    }
    open dynamic var linkTitle:String = ""{
        didSet{
            if localId > 0 {
                let id = self.localId
                let value = linkTitle
                
                    let realm = try! Realm(configuration: Qiscus.dbConfiguration)
                    let searchQuery = NSPredicate(format: "localId == \(id)")
                    
                    let linkData = realm.objects(QiscusLinkData.self).filter(searchQuery)
                    
                    if linkData.count > 0{
                        let firstLink = linkData.first!
                        if firstLink.linkTitle != value{
                            try! realm.write {
                                firstLink.linkTitle = value
                            }
                        }
                    }
                
            }
        }
    }
    open dynamic var linkDescription: String = ""{
        didSet{
            if localId > 0 {
                let id = self.localId
                let value = linkDescription
                
                    let realm = try! Realm(configuration: Qiscus.dbConfiguration)
                    let searchQuery = NSPredicate(format: "localId == \(id)")
                    
                    let linkData = realm.objects(QiscusLinkData.self).filter(searchQuery)
                    
                    if linkData.count > 0{
                        let firstLink = linkData.first!
                        if firstLink.linkDescription != value{
                            try! realm.write {
                                firstLink.linkDescription = value
                            }
                        }
                    }
                
            }
        }
    }
    open dynamic var linkImageURL: String = ""{
        didSet{
            if localId > 0 {
                let id = self.localId
                let value = linkImageURL
                
                    let realm = try! Realm(configuration: Qiscus.dbConfiguration)
                    let searchQuery = NSPredicate(format: "localId == \(id)")
                    
                    let linkData = realm.objects(QiscusLinkData.self).filter(searchQuery)
                    
                    if linkData.count > 0{
                        let firstLink = linkData.first!
                        if firstLink.linkImageURL != value{
                            try! realm.write {
                                firstLink.linkImageURL = value
                            }
                        }
                    }
                
            }
        }
    }
    open dynamic var linkImageThumbURL: String = ""{
        didSet{
            if localId > 0 {
                let id = self.localId
                let value = linkImageThumbURL
                
                    let realm = try! Realm(configuration: Qiscus.dbConfiguration)
                    let searchQuery = NSPredicate(format: "localId == \(id)")
                    
                    let linkData = realm.objects(QiscusLinkData.self).filter(searchQuery)
                    
                    if linkData.count > 0{
                        let firstLink = linkData.first!
                        if firstLink.linkImageThumbURL != value{
                            try! realm.write {
                                firstLink.linkImageThumbURL = value
                            }
                        }
                    }
                
            }
        }
    }
    
    class func copyLink(link:QiscusLinkData)->QiscusLinkData{
        let newLink = QiscusLinkData()
        newLink.localId = link.localId
        newLink.linkURL = link.linkURL
        newLink.linkTitle = link.linkTitle
        newLink.linkDescription = link.linkDescription
        newLink.linkImageURL = link.linkImageURL
        newLink.linkImageThumbURL = link.linkImageThumbURL
        return newLink
    }
    open var isLocalThumbExist:Bool{
        get{
            var check:Bool = false
            if QiscusHelper.isFileExist(inLocalPath: self.linkImageThumbURL){
                check = true
            }
            return check
        }
    }
    open var thumbImage:UIImage?{
        get{
            if isLocalThumbExist{
                if let image = UIImage.init(contentsOfFile: self.linkImageThumbURL){
                    return image
                }else{
                    return remoteLinkImage
                }
            }else{
                return remoteLinkImage
            }
        }
    }
    open var remoteLinkImage:UIImage?{
        get{
            if linkImageURL != "" {
                if let imageURL = URL(string: linkImageURL){
                    if let imageData = NSData(contentsOf: imageURL){
                        if let image = UIImage(data: imageData as Data){
                            return image
                        }
                    }
                }
            }
            return nil
        }
    }
    // MARK: - Set Primary Key
    override open class func primaryKey() -> String {
        return "localId"
    }
    open class var LastId:Int{
        get{
            let realm = try! Realm(configuration: Qiscus.dbConfiguration)
            let RetNext = realm.objects(QiscusLinkData.self).sorted(byKeyPath: "localId")
            
            if RetNext.count > 0 {
                let last = RetNext.last!
                return last.localId
            } else {
                return 0
            }
        }
    }
    open class func getLinkData(fromURL url: String)->QiscusLinkData?{
        let realm = try! Realm(configuration: Qiscus.dbConfiguration)
        let searchQuery:NSPredicate = NSPredicate(format: "linkURL == '\(url)'")
        let RetNext = realm.objects(QiscusLinkData.self).filter(searchQuery)
        
        if RetNext.count > 0 {
            let data = QiscusLinkData.copyLink(link: RetNext.first!)
            return data
        }else{
            return nil
        }
    }
    open func saveLink(){ //  
        
            let realm = try! Realm(configuration: Qiscus.dbConfiguration)
            let searchQuery = NSPredicate(format: "linkURL == '\(self.linkURL)'")
            
            let linkData = realm.objects(QiscusLinkData.self).filter(searchQuery)
            
            if linkData.count == 0{
                try! realm.write {
                    self.localId = QiscusLinkData.LastId + 1
                    realm.add(self)
                }
                if self.linkImageThumbURL == "" {
                    self.downloadThumbImage()
                }
            }
        
    }
    open func updateThumbURL(url:String){
        let localId = self.localId
        
            let realm = try! Realm(configuration: Qiscus.dbConfiguration)
            let searchQuery = NSPredicate(format: "localId == '\(localId)'")
            
            let linkData = realm.objects(QiscusLinkData.self).filter(searchQuery)

            if linkData.count > 0{
                let firstLink = linkData.first!
                try! realm.write {
                    firstLink.linkImageThumbURL = url
                }
            }
        
    }
    open func updateLinkImageURL(url:String){
        let localId = self.localId
        
            let realm = try! Realm(configuration: Qiscus.dbConfiguration)
            let searchQuery = NSPredicate(format: "localId == '\(localId)'")
            
            let linkData = realm.objects(QiscusLinkData.self).filter(searchQuery)
            
            if linkData.count > 0{
                let firstLink = linkData.first!
                try! realm.write {
                    firstLink.linkImageURL = url
                }
            }
        
    }
    fileprivate func createThumbLink(_ image:UIImage)->UIImage{
        var smallPart:CGFloat = image.size.height
        
        if(image.size.width > image.size.height){
            smallPart = image.size.width
        }
        let ratio:CGFloat = CGFloat(100.0/smallPart)
        let newSize = CGSize(width: (image.size.width * ratio),height: (image.size.height * ratio))
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    open func downloadThumbImage(){
        if self.linkImageURL != ""{
            let linkData = QiscusLinkData.copyLink(link: self)
            let imageURL = self.linkImageURL
            Qiscus.printLog(text: "Downloading image for link \(self.linkURL)")
            Alamofire.request(self.linkImageURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
                .responseData(completionHandler: { response in
                    Qiscus.printLog(text: "download linkImage result: \(response)")
                    if let data = response.data {
                        if let image = UIImage(data: data) {
                            var thumbImage = UIImage()
                            let time = Double(Date().timeIntervalSince1970)
                            let timeToken = UInt64(time * 10000)
                            
                            let fileExt = QiscusFile.getExtension(fromURL: imageURL)
                            let fileName = "ios-link-\(timeToken).\(fileExt)"
                            
                            if fileExt == "jpg" || fileExt == "jpg_" || fileExt == "png" || fileExt == "png_" {
                                thumbImage = linkData.createThumbLink(image)
                                
                                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                                let directoryPath = "\(documentsPath)/Qiscus"
                                if !FileManager.default.fileExists(atPath: directoryPath){
                                    do {
                                        try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false, attributes: nil)
                                    } catch let error as NSError {
                                        Qiscus.printLog(text: error.localizedDescription);
                                    }
                                }
                                let thumbPath = "\(directoryPath)/\(fileName)"
                                
                                if fileExt == "png" || fileExt == "png_" {
                                    try? UIImagePNGRepresentation(thumbImage)!.write(to: URL(fileURLWithPath: thumbPath), options: [.atomic])
                                } else if fileExt == "jpg" || fileExt == "jpg_"{
                                    try? UIImageJPEGRepresentation(thumbImage, 1.0)!.write(to: URL(fileURLWithPath: thumbPath), options: [.atomic])
                                }
                                
                                linkData.linkImageThumbURL = thumbPath
                            }else{
                               linkData.linkImageURL = ""
                            }
                        }
                    }
                }).downloadProgress(closure: { progressData in
                    let progress = CGFloat(progressData.fractionCompleted)
                    DispatchQueue.main.async(execute: {
                        Qiscus.printLog(text: "Download link image progress: \(progress)")
                    })
                })
        }
    }
}
