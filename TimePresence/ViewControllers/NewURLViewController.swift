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
    @IBOutlet weak var addButton:XUIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func customizeView() {
        super.customizeView()
        addButton.backgroundColor = AppColors.orange
        
        
    }
    
}
