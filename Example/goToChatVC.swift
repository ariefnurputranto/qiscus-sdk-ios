//
//  goToChatVC.swift
//  SampleSDK
//
//  Created by Ahmad Athaullah on 1/11/17.
//  Copyright © 2017 Evan Purnama. All rights reserved.
//

import UIKit
import Qiscus

class goToChatVC: UIViewController {

    @IBOutlet weak var targetField: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let dismissRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToChatVC.hideKeyboard))
        self.view.addGestureRecognizer(dismissRecognizer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goToChat(_ sender: UIButton) {
        if targetField.text! != "" {
            if targetField.text!.contains("@") {
                let emailData = targetField.text!.characters.split(separator: ",")
                if emailData.count > 1 {
                    var emails = [String]()
                    for email in emailData{
                        emails.append(String(email).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                    }
                    Qiscus.createChat(withUsers:emails, target:self, title:"New Group Chat", subtitle: "Always new chat")
                }else{
                    let email = targetField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    let view = Qiscus.chatView(withUsers: [email])
                    self.navigationController?.pushViewController(view, animated: true)
                    view.titleAction = {
                        print("title clicked")
                    }
                }
            }else{
                if let roomId = Int(targetField.text!){
                    let view = Qiscus.chatView(withRoomId: roomId)
                    self.navigationController?.pushViewController(view, animated: true)
                    view.titleAction = {
                        print("title clicked")
                    }
                }else{
                    let uniqueId = targetField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    let view = Qiscus.chatView(withRoomUniqueId: uniqueId)
                    self.navigationController?.pushViewController(view, animated: true)
                    view.titleAction = {
                        print("title clicked")
                    }
                }
            }
        }
    }
    @IBAction func ClearData(_ sender: Any) {
        Qiscus.clearData()
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        Qiscus.clear()
        appDelegate.goToLoginView()
    }
    func hideKeyboard(){
        self.view.endEditing(true)
    }
}
