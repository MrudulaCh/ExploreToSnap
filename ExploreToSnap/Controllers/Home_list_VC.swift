//
//  Home_list_VC.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//


import UIKit
import SWRevealViewController

class Home_list_VC: UIViewController {
    @IBOutlet var tbleview: UITableView!
    @IBOutlet var menubutton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSidemenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name:Notification.Name(rawValue: "close"), object: nil)
    }
    
    @objc func refresh() {
        if sidemenuselect {
            sidemenuselect = false
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "StoreViewController") as! StoreViewController
            globalstr = EditableCategory[globalvalue]
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func Click_menu(_ sender: UIBarButtonItem) {
        
        
    }
    
    // Add Store Buttons
    @IBAction func newPostButton(_ sender: Any) {
        
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController =
            storyB.instantiateViewController(withIdentifier:
                "postPicture") as! NewPostViewController
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    func configSidemenu() {
        if self.revealViewController() != nil {
            menubutton.target = self.revealViewController()
            menubutton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
}

extension Home_list_VC : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditableCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Home_list_cell
        cell.selectionStyle = .none
        cell.cate_name.text = EditableCategory[indexPath.row]
        cell.Cateimage.image = CategoryImage[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 214.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StoreViewController") as! StoreViewController
        globalvalue = indexPath.row
        globalstr = EditableCategory[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

var globalvalue = Int()
var globalstr = String()
