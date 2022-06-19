//
//  DetailViewController.swift
//  EmployeeApp
//
//  Created by Monika Mohan on 19/06/22.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phoneNum: UILabel!
    
    @IBOutlet weak var compnyDetails: UIView!
    var empData : Employees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.text = empData?.name
        self.email.text = empData?.email
        self.address.text = empData?.address?.city
        self.phoneNum.text = empData?.phone?.description
        self.userName.text = empData?.username?.description
        self.companyName.text = empData?.company?.name
        if let url = empData?.profile_image {
            self.imgView.loadImageUsingCacheWithURLString(url, placeHolder: UIImage(named: "placeholder"))
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
