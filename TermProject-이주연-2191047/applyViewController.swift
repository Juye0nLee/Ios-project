//
//  applyViewController.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/19/25.
//

import Foundation
import UIKit

class ApplyViewController : UIViewController {
    @IBOutlet weak var imagePickerView: UIView!
    @IBOutlet weak var childBox: UIView!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var box4: UIView!
    @IBOutlet weak var box3: UIView!
    @IBOutlet weak var box2: UIView!
    @IBOutlet weak var box1: UIView!
    @IBOutlet weak var circle1: UIView!
    @IBOutlet weak var circle2: UIView!
    @IBOutlet weak var circle3: UIView!
    @IBOutlet weak var circle4: UIView!
    @IBOutlet weak var circle5: UIView!
    @IBOutlet weak var circle6: UIView!
    var count = 1;
    override func viewDidLoad() {
        super.viewDidLoad()
        circle1.layer.cornerRadius = 20
        circle2.layer.cornerRadius = 20
        circle3.layer.cornerRadius = 20
        circle4.layer.cornerRadius = 20
        circle5.layer.cornerRadius = 20
        circle6.layer.cornerRadius = 20
        box1.layer.cornerRadius = 16
        box2.layer.cornerRadius = 16
        box3.layer.cornerRadius = 16
        box4.layer.cornerRadius = 16
        childBox.layer.cornerRadius = 12
        checkButton.layer.cornerRadius = 8
        childBox.isHidden = true
        imagePickerView.isHidden = true
        
        //탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(childBoxTapped))
        childBox.addGestureRecognizer(tapGesture)
        childBox.isUserInteractionEnabled = true
    }
    @objc func childBoxTapped() {
        childBox.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 0.15)
        childBox.layer.cornerRadius = 12
        childBox.layer.borderWidth = 1
        childBox.layer.borderColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1).cgColor
        checkButton.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        let shouldHide = true
        box1.isHidden = shouldHide
        box2.isHidden = shouldHide
        box3.isHidden = shouldHide
        box4.isHidden = shouldHide
        circle1.isHidden = shouldHide
        circle2.isHidden = shouldHide
        circle3.isHidden = shouldHide
        circle4.isHidden = shouldHide
        if count == 1 {
            text1.text = "서비스 신청할 아이를 선택해 주세요"
            text2.text = "한 명만 선택이 가능합니다"
            checkButton.setTitle("선택 완료", for: .normal)
            checkButton.tintColor = .white
            checkButton.backgroundColor = UIColor(red: 0.875, green: 0.886, blue: 0.898, alpha: 1)
            childBox.isHidden = false
            count += 1
        } else if count == 2 {
            text1.text = "1. 서류제출"
            text2.text = "진단서 제출"
            checkButton.setTitle("서류 검증하기", for: .normal)
            checkButton.tintColor = .white
            checkButton.backgroundColor =  UIColor(red: 0.875, green: 0.886, blue: 0.898, alpha: 1)
            imagePickerView.isHidden = false
            imagePickerView.layer.cornerRadius = 8
            childBox.isHidden = true
            count += 1
        }
    }

}
