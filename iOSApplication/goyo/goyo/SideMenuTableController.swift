//
//  SideMenuTableController.swift
//  goyo
//
//  Created by Danny Gosain on 2018-01-29.
//  Copyright © 2018 Danny Gosain. All rights reserved.
//

import UIKit

struct cellData {
    let cell : Int!
    let text : String!
}

class SideMenuTableController: UITableViewController {

    var arrayOfCellData = [cellData]()
    
    override func viewDidLoad() {
        arrayOfCellData = [cellData(cell : 1, text : "Today's Data"),
                           cellData(cell : 1, text : "Weekly Data"),
                           cellData(cell : 1, text : "Monthly Data"),
                           cellData(cell : 1, text : "Settings"),
                           cellData(cell : 1, text : "Profile")]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCellData.count // returns number of rows
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("SideMenuTableViewCell", owner: self, options: nil)?.first as! SideMenuTableViewCell
        cell.title.text = arrayOfCellData[indexPath.row].text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 44
    }
}
