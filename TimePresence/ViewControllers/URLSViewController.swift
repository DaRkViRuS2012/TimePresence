//
//  URLSViewController.swift
//  TimePresence
//
//  Created by Nour  on 5/6/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import UIKit

class URLSViewController: AbstractController {

    @IBOutlet weak var tableView:UITableView!
    var services:[Service] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        services = DatabaseManagement.shared.queryAllServices()
        tableView.reloadData()
    }
    
    
    func getCompanies(){
        guard let url = DataStore.shared.currentURL else {return}
        self.showActivityLoader(true)
        ApiManager.shared.getCompanies { (success, error, result) in
            self.showActivityLoader(false)
            if success{
                if let company = result.first{
                    company.urlId = url.ID
                    company.save()
                    DataStore.shared.currentCompany = company
                    let vc = UIStoryboard.startStoryboard.instantiateViewController(withIdentifier: "LoginViewController" ) as! LoginViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            if error != nil{
                if let msg = error?.errorName{
                    self.showMessage(message: msg, type: .error)
                }
            }
        }
      
    }

    
}



extension URLSViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = services[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataStore.shared.currentURL = self.services[indexPath.row]
        getCompanies()
    }
}
