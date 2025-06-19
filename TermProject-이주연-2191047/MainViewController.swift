//
//  MainViewController.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/19/25.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var childImage: UIImageView!
    @IBOutlet weak var applyButton: UIView!
    @IBOutlet weak var applyStatusBox: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        applyButton.layer.cornerRadius = 16
        applyStatusBox.layer.cornerRadius = 12
        applyStatusBox.layer.borderColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1).cgColor
        applyStatusBox.layer.borderWidth = 1
        childImage.layer.cornerRadius = 12
        scrollView.layer.cornerRadius = 16

    }

}
