//
//  Side_menu_VC.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//


import UIKit
import SWRevealViewController
var iPhone = true
var sidemenuselect = false
class Side_menu_VC: UIViewController {

    @IBOutlet var tblsidemenu: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tblsidemenu.tableFooterView = UIView()
       tblsidemenu.delegate = self
        tblsidemenu.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    

}

extension Side_menu_VC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditableCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        let title = EditableCategory[indexPath.row]
        cell.textLabel?.text = title
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (iPhone ? 16 : 26))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        globalvalue = indexPath.row
        globalstr = EditableCategory[indexPath.row]
        sidemenuselect = true
        self.revealViewController().rightRevealToggle(animated: true)
        NotificationCenter.default.post(name:Notification.Name(rawValue: "close"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
