//
//  QiscusHelper.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 7/22/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

open class QiscusIndexPathData: NSObject{
    open var row = 0
    open var section = 0
    open var newGroup:Bool = false
}
open class QiscusSearchIndexPathData{
    open var row = 0
    open var section = 0
    open var found:Bool = false
}
open class QCommentIndexPath{
    open var row = 0
    open var section = 0
}
open class QiscusHelper: NSObject {
    open class func properIndexPathOf(comment: QiscusComment, inGroupedComment:[[QiscusComment]])-> QiscusIndexPathData{
        
        let dataIndexPath = QiscusIndexPathData()
        var stopSearch = false
        if inGroupedComment.count == 0{
            stopSearch = true
            dataIndexPath.section = 0
            dataIndexPath.row = 0
            dataIndexPath.newGroup = true
        }else{
            groupDataLoop: for i in (0..<inGroupedComment.count).reversed(){
                let comments = inGroupedComment[i]
                dataLoop: for j in (0..<comments.count).reversed() {
                    let target = comments[j]
                    if target.commentId < comment.commentId {
                        if comment.commentDate == target.commentDate && comment.commentSenderEmail == target.commentSenderEmail{
                            stopSearch = true
                            dataIndexPath.section = i
                            dataIndexPath.row = j + 1
                            dataIndexPath.newGroup = false
                        }else{
                            var after: QiscusComment? = nil
                            if j == comments.count - 1 {
                                if i < (inGroupedComment.count - 1){
                                    after = inGroupedComment[i+1][0]
                                }
                            }else{
                                after = comments[j + 1]
                            }
                            stopSearch = true
                            dataIndexPath.row = 0
                            dataIndexPath.section = i + 1
                            if after == nil {
                                dataIndexPath.newGroup = true
                            }else{
                                if after!.commentSenderEmail == comment.commentSenderEmail{
                                    dataIndexPath.newGroup = false
                                }else{
                                    dataIndexPath.newGroup = true
                                }
                            }
                        }
                        break dataLoop
                    }
                }
                if stopSearch{
                    break groupDataLoop
                }
            }
        }
        return dataIndexPath
    }
    
    open class func getIndexPathOfComment(comment: QiscusComment, inGroupedComment:[[QiscusComment]])-> QiscusSearchIndexPathData{
        
        let dataIndexPath = QiscusSearchIndexPathData()
        var stopSearch = false
        groupDataLoop: for i in (0..<inGroupedComment.count).reversed(){
            let comments = inGroupedComment[i]
            dataLoop: for j in (0..<comments.count).reversed(){
                let commentTarget = comments[j]
                if((comment.commentUniqueId != "") && (comment.commentUniqueId == commentTarget.commentUniqueId) ) || comment.commentId == commentTarget.commentId {
                    dataIndexPath.section = i
                    dataIndexPath.row = j
                    dataIndexPath.found = true
                    stopSearch = true
                    break dataLoop
                }
            }
            if stopSearch{
                break groupDataLoop
            }
        }
        return dataIndexPath
    }
    
    open class func getLastCommentInGroup(groupComment:[[QiscusComment]])->QiscusComment{
        var lastGroup = groupComment[groupComment.count - 1]
        let lastComment = lastGroup[lastGroup.count - 1]
        
        return lastComment
    }
    open class func getLastCommentindexPathInGroup(groupComment:[[QiscusComment]])->QCommentIndexPath{
        let indexPath = QCommentIndexPath()
        indexPath.section = groupComment.count - 1
        indexPath.row = groupComment[indexPath.section].count - 1
        
        return indexPath
    }
    open class func getNextIndexPathIn(groupComment:[[QiscusComment]])->QCommentIndexPath{
        var indexPath = QCommentIndexPath()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        
        let today = dateFormatter.string(from: date)
        
        if groupComment.count != 0 {
            let lastComment = getLastCommentInGroup(groupComment: groupComment)
            if lastComment.commentDate == today {
                indexPath = getLastCommentindexPathInGroup(groupComment: groupComment)
            }else{
                indexPath.section = groupComment.count
            }
        }
        return indexPath
    }
    class func screenWidth()->CGFloat{
        return UIScreen.main.bounds.size.width
    }
    class func screenHeight()->CGFloat{
        return UIScreen.main.bounds.size.height
    }
    class func statusBarSize()->CGRect{
        return UIApplication.shared.statusBarFrame
    }
    class var thisDateString:String{
        get{
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM yyyy"
            
            return dateFormatter.string(from: date)
        }
    }
    
    open class func isFileExist(inLocalPath path:String)->Bool{
        var check:Bool = false
        
        let checkValidation = FileManager.default
        
        if (path != "" && checkValidation.fileExists(atPath:path))
        {
            check = true
        }
        return check
    }
    open class func getFirstLinkInString(text:String)->String?{
        let pattern = "((?:http|https)://)?(?:www\\.)?([a-zA-Z0-9./]+[.][a-zA-Z0-9/]{2,3})+([a-zA-Z0-9./-]+)?((\\?)+[a-zA-Z0-9./-_&]*)*"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
            let nsstr = text as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            var matches = [String]()
            regex.enumerateMatches(in: text, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: all, using: { (result, flags, _) in
                matches.append(nsstr.substring(with: result!.range))
            })
            if matches.count > 0 {
                return matches[0]
            }else{
                return nil
            }
        } catch {
            return nil
        }
    }
}
