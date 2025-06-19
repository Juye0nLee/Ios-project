//
//  SignupViewController.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/18/25.
//

import UIKit

class SignupViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSignup", sender: self)
    }
}
