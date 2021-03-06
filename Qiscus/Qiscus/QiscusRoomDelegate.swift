//
//  QiscusRoomDelegate.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 7/23/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc public protocol QiscusRoomDelegate {
    func gotNewComment(_ comments:QiscusComment)
    func didFinishLoadRoom(onRoom room: QiscusRoom)
    func didFailLoadRoom(withError error:String)
    func didFinishUpdateRoom(onRoom room:QiscusRoom)
    func didFailUpdateRoom(withError error:String)
}
