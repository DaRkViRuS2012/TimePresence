//
//  NewURLViewController.swift
//  TimePresence
//
//  Created by Nour  on 5/6/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import UIKit

class NewURLViewController: AbstractController {

    @IBOutlet weak var urlTextField:XUITextField!
    @IBOutlet weak var titleTextField:XUITextField!
    @IBOutlet weak var addButton:XUIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func customizeView() {
        super.customizeView()
        addButton.backgroundColor = AppColors.orange
    }
    
    @IBAction func save(_ sender :UIButton){
        addURL()
    }
    
    func validate()->Bool{
        if let title = titleTextField.text ,!title.isEmpty{
        }else{
            self.showMessage(message: "Please enter the title", type: .error)
            return false
        }
        
        if let url = urlTextField.text ,!url.isEmpty{
        }else{
            self.showMessage(message: "Please enter the URL", type: .error)
            return false
        }
    return true
    }
    
    func addURL(){
        if validate(){
            let title = titleTextField.text
            let url = urlTextField.text
            let service = Service(ID: nil, title: title, url: url, date: Date(), userCode: "1")
            service.save()
            self.showMessage(message: "Done", type: .success)
            self.popOrDismissViewControllerAnimated(animated: true)
        }
    }
}
