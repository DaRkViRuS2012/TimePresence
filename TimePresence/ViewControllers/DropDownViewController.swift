//
//  DropDownViewController.swift
//  Sheffa
//
//  Created by Nour  on 11/19/18.
//  Copyright © 2018 Nour . All rights reserved.
//

import UIKit

protocol DropDownDelegete {
    func didSelectetItem<T:BaseModel>(dropDown: DropDownViewController<T>,model:T?,index:Int)
    func didClearData()
}


class DropDownViewController<T:BaseModel>: AbstractController,UITableViewDataSource,UITableViewDelegate {
    var tag:String?
    var overLayView:UIView = UIView()
    var bgView:UIView = UIView()
    var searchTextField: XUITextField = XUITextField()
    var tableView: UITableView = UITableView()
    var closeButton : UIButton =  {
        let button  = UIButton()
        button.setImage(UIImage(named:"navClose"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    var selectedObject:T?
    
    var allowAnyText:Bool = false
    var loadData: ()->() = {}
    
    var textField:UITextField?{
        didSet{
            guard let textField = textField else {return}
       //     textField.delegate = self
            textField.addTarget(self, action: #selector(DropDownViewController.showDropDown), for: .editingDidBegin)
        }
    }
    
    var buttonAnchor:UIButton?{
        didSet{
            guard let buttonAnchor = buttonAnchor else {return}
            buttonAnchor.addTarget(self, action: #selector(DropDownViewController.showDropDown), for: .touchUpInside)
        }
    }
    
    var delegate:DropDownDelegete?
    var list:[String] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    var searchList:[String] {
        if let keyword =  searchTextField.text , !keyword.isEmpty{
            let temp = list.filter({($0.lowercased().contains(keyword.lowercased()))})
            return temp
        }
        return list
    }
    
    
    var modelList:[T] = [] {
        didSet{
            self.list = modelList.map{$0.modelTitle ?? ""}
            tableView.reloadData()
        }
    }
    
    var searchModelList:[T] {
        if let keyword =  searchTextField.text , !keyword.isEmpty{
            let temp = modelList.filter({($0.modelTitle?.lowercased().contains(keyword.lowercased()))!})
            return temp
        }
        return modelList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        prepareView()
        bgView.backgroundColor = .white
        overLayView.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        searchTextField.placeholder = "Search".localized
        
        
        if allowAnyText{
            self.searchTextField.addIconButton(image:"chevron")
            let button = searchTextField.rightView as! UIButton
            button.addTarget(self, action: #selector(setText), for: .touchUpInside)
        }
        
        self.searchTextField.addTarget(self, action: #selector(search(_:)), for: .editingChanged)
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        tapGesture.cancelsTouchesInView = false
        overLayView.addGestureRecognizer(tapGesture)
        loadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func setText(){
        textField?.text = searchTextField.text
        dismissView()
    }
    
    
    @objc func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func prepareView(){
        
        self.view.addSubview(overLayView)
        self.view.addSubview(bgView)
        self.bgView.addSubview(searchTextField)
        self.bgView.addSubview(tableView)
        self.bgView.addSubview(closeButton)
        
        
        self.overLayView.frame = view.frame
        
        _ = self.bgView.anchor8(self.view, topattribute: .top, topConstant: 32, leftview: self.view, leftattribute: .leading, leftConstant: 16, bottomview: self.view, bottomattribute: .bottom, bottomConstant: 32, rightview: self.view, rightattribute: .trailing, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        
        _ = self.closeButton.anchor8(self.bgView, topattribute: .top, topConstant: 8, leftview: self.bgView, leftattribute: .leading, leftConstant: 8, bottomview: nil, bottomattribute: nil, bottomConstant: 0, rightview: nil, rightattribute: nil, rightConstant: 0, widthConstant: 24, heightConstant: 24)
        
        _ = self.searchTextField.anchor8(bgView, topattribute: .top, topConstant: 32, leftview: bgView, leftattribute: .leading, leftConstant: 8, bottomview: nil, bottomattribute: nil, bottomConstant: 0, rightview: bgView, rightattribute: .trailing, rightConstant: 8, widthConstant: 0, heightConstant: 40)
        _ = self.tableView.anchor8(searchTextField, topattribute: .bottom, topConstant: 0, leftview: bgView, leftattribute: .leading, leftConstant: 0, bottomview: bgView, bottomattribute: .bottom, bottomConstant: 16, rightview: bgView, rightattribute: .trailing, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        self.bgView.Center(view)
        self.view.layoutSubviews()
    }
    
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func search(_ sender: UITextField) {
        tableView.reloadData()
    }
    
    @objc func showDropDown(){
        self.textField?.resignFirstResponder()
        self.searchTextField.becomeFirstResponder()
        //        if let vc = self.presentingViewController as? AbstractController{
        //            vc.dismissKeyboard()
        //        }
        
        self.modalPresentationStyle = .overCurrentContext
        UIApplication.visibleViewController()?.present(self, animated: true, completion: nil)
    }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("clicked")
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.selectedObject = nil
        delegate?.didClearData()
        print("clicked")
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = searchList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if let textField = textField  {
            textField.text = searchList[indexPath.row]
        }
//        if let button = buttonAnchor{
//            button.setTitle(searchList[indexPath.row], for: .normal)
//        }
        if searchModelList.count > 0 {
            selectedObject = searchModelList[indexPath.row]
        }
        delegate?.didSelectetItem(dropDown:self,model:selectedObject,index: indexPath.row)
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}



