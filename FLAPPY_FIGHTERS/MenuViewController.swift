//
//  MenuViewController.swift
//  FLAPPY_FIGHTERS
//
//  Created by Kamran Kara-Pabani on 7/2/15.
//  Copyright (c) 2015 Kamran Kara-Pabani. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {


    @IBOutlet weak var scoreNotDisplay: UILabel!
    
    @IBOutlet weak var scoreDisplayMenu: UILabel!
    
    @IBOutlet weak var howToPlay: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func unwoundToMenu(segue: UIStoryboardSegue) {
        
    }
}
