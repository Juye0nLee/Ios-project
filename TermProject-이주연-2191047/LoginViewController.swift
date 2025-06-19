//
//  LoginViewController.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/18/25.
import UIKit
class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFieldStyle(idTextField, placeholder: "아이디를 입력해주세요")
        configureTextFieldStyle(passwordTextField, placeholder: "비밀번호를 입력해주세요")
        loginButton.layer.cornerRadius = 12

        idTextField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        idTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        passwordTextField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        passwordTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
    }

    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1).cgColor
        loginButton.layer.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1).cgColor
    }

    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
    }
    private func configureTextFieldStyle(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.backgroundColor = UIColor(red: 0.954, green: 0.954, blue: 0.954, alpha: 1)
        textField.layer.cornerRadius = 12
        textField.clipsToBounds = true
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.setPadding(top: 14, left: 16, bottom: 14, right: 16)
        //비밀번호 필드일 경우에는 마스킹
        if textField == passwordTextField {
            textField.isSecureTextEntry = true
        }
    }
}
extension UITextField {
    func setPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.height))
        self.rightView = rightPaddingView
        self.rightViewMode = .always
        self.contentVerticalAlignment = .center
    }
}


