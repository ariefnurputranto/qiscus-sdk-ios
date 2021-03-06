//
//  QVCPickerAndMedia.swift
//  Example
//
//  Created by Ahmad Athaullah on 5/16/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit
import ImageViewer
import AVFoundation

// MARK: - GaleryItemDataSource
extension QiscusChatVC:GalleryItemsDatasource{
    // MARK: - Galery Function
    public func galleryConfiguration()-> GalleryConfiguration{
        let closeButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)))
        closeButton.setImage(Qiscus.image(named: "close")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        closeButton.tintColor = UIColor.white
        closeButton.imageView?.contentMode = .scaleAspectFit
        
        let seeAllButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)))
        seeAllButton.setTitle("", for: UIControlState())
        seeAllButton.setImage(Qiscus.image(named: "viewmode")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        seeAllButton.tintColor = UIColor.white
        seeAllButton.imageView?.contentMode = .scaleAspectFit
        
        return [
            GalleryConfigurationItem.closeButtonMode(.custom(closeButton)),
            GalleryConfigurationItem.thumbnailsButtonMode(.custom(seeAllButton))
        ]
    }
    
    public func itemCount() -> Int{
        return self.galleryItems.count
    }
    public func provideGalleryItem(_ index: Int) -> GalleryItem{
        let item = self.galleryItems[index]
        if item.isVideo{
            return GalleryItem.video(fetchPreviewImageBlock: { $0(item.image)}, videoURL: URL(string: item.url)! )
        }else{
            return GalleryItem.image { $0(item.image) }
        }
    }
}
// MARK: - UIImagePickerDelegate
extension QiscusChatVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let time = Double(Date().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        let fileType:String = info[UIImagePickerControllerMediaType] as! String
        picker.dismiss(animated: true, completion: nil)
        
        if fileType == "public.image"{
            var imageName:String = ""
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            var imagePath:URL?
            if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL{
                imageName = imageURL.lastPathComponent
                
                let imageNameArr = imageName.characters.split(separator: ".")
                let imageExt:String = String(imageNameArr.last!).lowercased()
                
                if imageExt.isEqual("gif") || imageExt.isEqual("gif_"){
                    imagePath = imageURL
                }
            }else{
                imageName = "\(timeToken).jpg"
            }
            let text = QiscusTextConfiguration.sharedInstance.confirmationImageUploadText
            let okText = QiscusTextConfiguration.sharedInstance.alertOkText
            let cancelText = QiscusTextConfiguration.sharedInstance.alertCancelText
            
            QPopUpView.showAlert(withTarget: self, image: image, message: text, firstActionTitle: okText, secondActionTitle: cancelText,doneAction: {
                self.continueImageUpload(image, imageName: imageName, imagePath: imagePath)
            },
                                 cancelAction: {}
            )
        }else if fileType == "public.movie" {
            let mediaURL = info[UIImagePickerControllerMediaURL] as! URL
            let fileName = mediaURL.lastPathComponent
            let fileNameArr = fileName.characters.split(separator: ".")
            let fileExt:NSString = String(fileNameArr.last!).lowercased() as NSString
            
            let mediaData = try? Data(contentsOf: mediaURL)
            
            Qiscus.printLog(text: "mediaURL: \(mediaURL)\nfileName: \(fileName)\nfileExt: \(fileExt)")
            
            //create thumb image
            let assetMedia = AVURLAsset(url: mediaURL)
            let thumbGenerator = AVAssetImageGenerator(asset: assetMedia)
            thumbGenerator.appliesPreferredTrackTransform = true
            
            let thumbTime = CMTimeMakeWithSeconds(0, 30)
            let maxSize = CGSize(width: QiscusHelper.screenWidth(), height: QiscusHelper.screenWidth())
            thumbGenerator.maximumSize = maxSize
            
            do{
                let thumbRef = try thumbGenerator.copyCGImage(at: thumbTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: thumbRef)
                
                QPopUpView.showAlert(withTarget: self, image: thumbImage, message:"Are you sure to send this video?", isVideoImage: true,
                                     doneAction: {
                                        Qiscus.printLog(text: "continue video upload")
                                        self.continueImageUpload(thumbImage, imageName: fileName, imageNSData: mediaData, videoFile: true)
                },
                                     cancelAction: {
                                        Qiscus.printLog(text: "cancel upload")
                }
                )
            }catch{
                Qiscus.printLog(text: "error creating thumb image")
            }
        }
    }
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIDocumentPickerDelegate
extension QiscusChatVC: UIDocumentPickerDelegate{
    open func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.showLoading("Processing File")
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(readingItemAt: url, options: NSFileCoordinator.ReadingOptions.forUploading, error: nil) { (dataURL) in
            do{
                let data:Data = try Data(contentsOf: dataURL, options: NSData.ReadingOptions.mappedIfSafe)
                var fileName = dataURL.lastPathComponent.replacingOccurrences(of: "%20", with: "_")
                fileName = fileName.replacingOccurrences(of: " ", with: "_")
                
                let fileNameArr = (fileName as String).characters.split(separator: ".")
                let ext = String(fileNameArr.last!).lowercased()
                
                // get file extension
                let isGifImage:Bool = (ext == "gif" || ext == "gif_")
                let isJPEGImage:Bool = (ext == "jpg" || ext == "jpg_")
                let isPNGImage:Bool = (ext == "png" || ext == "png_")
                
                if isGifImage || isPNGImage || isJPEGImage{
                    var imagePath:URL?
                    let image = UIImage(data: data)
                    if isGifImage{
                        imagePath = dataURL
                    }
                    self.dismissLoading()
                    let text = QiscusTextConfiguration.sharedInstance.confirmationImageUploadText
                    let okText = QiscusTextConfiguration.sharedInstance.alertOkText
                    let cancelText = QiscusTextConfiguration.sharedInstance.alertCancelText
                    QPopUpView.showAlert(withTarget: self, image: image, message: text, firstActionTitle: okText, secondActionTitle: cancelText,
                                         doneAction: {
                                            self.continueImageUpload(image, imageName: fileName, imagePath: imagePath, imageNSData: data)
                                            
                    },
                                         cancelAction: {}
                    )
                }else{
                    self.dismissLoading()
                    let textFirst = QiscusTextConfiguration.sharedInstance.confirmationFileUploadText
                    let textMiddle = "\(fileName as String)"
                    let textLast = QiscusTextConfiguration.sharedInstance.questionMark
                    let text = "\(textFirst) \(textMiddle) \(textLast)"
                    let okText = QiscusTextConfiguration.sharedInstance.alertOkText
                    let cancelText = QiscusTextConfiguration.sharedInstance.alertCancelText
                    QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: okText, secondActionTitle: cancelText,
                                         doneAction: {
                                            self.continueImageUpload(imageName: fileName, imagePath: dataURL, imageNSData: data)
                    },
                                         cancelAction: {
                    }
                    )
                }
            }catch _{
                self.dismissLoading()
            }
        }
    }
}
// MARK: - AudioPlayer
extension QiscusChatVC:AVAudioPlayerDelegate{
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            if let activeCell = activeAudioCell {
                activeCell.data.audioIsPlaying = false
                self.didChangeData(onCell: activeCell, withData: activeCell.data)
            }
            stopTimer()
            updateAudioDisplay()
        } catch _ as NSError {}
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let activeCell = activeAudioCell as? QCellAudioLeft{
            activeCell.data.audioIsPlaying = false
            self.didChangeData(onCell: activeCell, withData: activeCell.data)
        }
        stopTimer()
        updateAudioDisplay()
    }
    
    // MARK: - Audio Methods
    func audioTimerFired(_ timer: Timer) {
        self.updateAudioDisplay()
    }
    
    func stopTimer() {
        audioTimer?.invalidate()
        audioTimer = nil
    }
    
    func updateAudioDisplay() {
        if let cell = activeAudioCell{
            if let currentTime = audioPlayer?.currentTime {
                cell.updateAudioDisplay(withTimeInterval: currentTime)
            }
        }
    }
}
