//
//  LoginViewController.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/18/25.
import UIKit
import FirebaseFirestore
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
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }

    private func navigateToMain() {
        // 예: 스토리보드 ID 기반 화면 전환
        if let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") {
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true)
        }
    }
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let id = idTextField.text, !id.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "아이디와 비밀번호를 모두 입력해주세요.")
            return
        }
        let usersRef = Firestore.firestore().collection("users")
        usersRef.whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            if let error = error {
                print("로그인 조회 실패: \(error.localizedDescription)")
                self.showAlert(message: "로그인 중 문제가 발생했습니다.")
                return
            }

            guard let documents = snapshot?.documents, let userDoc = documents.first else {
                self.showAlert(message: "해당 아이디의 계정이 존재하지 않습니다.")
                return
            }

            let data = userDoc.data()
            let savedPassword = data["password"] as? String ?? ""

            if savedPassword == password {
                print("로그인 성공 - 사용자 이름: \(data["name"] ?? "")")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
                    mainVC.userDocumentId = userDoc.documentID
                    mainVC.modalPresentationStyle = .fullScreen
                    self.present(mainVC, animated: true)
                }
                self.navigateToMain()
            } else {
                self.showAlert(message: "비밀번호가 일치하지 않습니다.")
            }
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


