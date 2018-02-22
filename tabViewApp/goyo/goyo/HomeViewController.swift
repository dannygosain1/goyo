//
//  HomeViewController.swift
//  goyo
//
//  Created by Danny Gosain on 2018-02-22.
//  Copyright © 2018 Danny Gosain. All rights reserved.
//

import UIKit
import Cosmos

class HomeViewController: UIViewController {

    @IBOutlet weak var starCosmos: CosmosView!
    
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home" // setting title of the page
        
        var rating = 1.0
        starCosmos.rating = rating
        if (rating <= 1.5) {
            image.image = UIImage(named: "sad-old-man.jpg")
        } else if (rating > 1.5 && rating < 4) {
            image.image = UIImage(named: "medium-old-man.jpg")
        } else if (rating >= 4){
            image.image = UIImage(named: "happy-old-man.jpg")
        } else {
            image.image = UIImage(named: "medium-old-man.jpg")
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
