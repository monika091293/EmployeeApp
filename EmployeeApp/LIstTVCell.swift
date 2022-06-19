//
//  LIstTVCell.swift
//  EmployeeApp
//
//  Created by Monika Mohan on 19/06/22.
//

import UIKit

class LIstTVCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setListTVCellWith(emp: EmployeeDetails) {
        
        DispatchQueue.main.async {
            self.name.text = "Name : " + (emp.name ?? "Name")
          //  self.id.text = emp.id
            self.email .text = "Company :" + (emp.companyName ?? "Company")
            if let url = emp.profileImage {
                self.imgView.loadImageUsingCacheWithURLString(url, placeHolder: UIImage(named: "placeholder"))
            }
        }
    }

}
