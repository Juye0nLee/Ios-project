//
//  ViewController.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/18/25.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.layer.cornerRadius = 12
        startButton.clipsToBounds = true
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSignup", sender: self)
    }

}

