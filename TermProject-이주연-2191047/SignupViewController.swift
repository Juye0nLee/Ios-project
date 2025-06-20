import UIKit
import FirebaseFirestore

class SignupViewController: UIViewController,
                            UIPickerViewDelegate, UIPickerViewDataSource,
                            UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var passwordTextField: CustomPaddingTextField!
    @IBOutlet weak var idTextField: CustomPaddingTextField!
    @IBOutlet weak var nameTextField: CustomPaddingTextField!
    @IBOutlet weak var incomeTypeTextField: UITextField!

    @IBOutlet weak var incomeTypeView: UIStackView!
    @IBOutlet weak var nameView: UIStackView!
    @IBOutlet weak var idView: UIStackView!
    @IBOutlet weak var passwordView: UIStackView!
    @IBOutlet weak var addChildView: UIView!
    @IBOutlet weak var imagePickerView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!

    @IBOutlet weak var childNameTextField: UITextField!
    @IBOutlet weak var childBirthDatePicker: UIDatePicker!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!

    // MARK: - Properties
    var count = 1
    var userDocumentId: String?

    let incomeTypes = [
        "가형 (중위 소득 기준 75% 이하)",
        "나형 (중위 소득 기준 120% 이하)",
        "다형 (중위 소득 기준 150% 이하)",
        "라형 (중위 소득 기준 150% 초과)"
    ]
    let pickerView = UIPickerView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupPicker()
        setupImagePickerGesture()
    }

    // MARK: - Setup
    private func setupViews() {
        configureTextFieldStyle(nameTextField, placeholder: "이름을 입력해주세요")
        configureTextFieldStyle(idTextField, placeholder: "아이디를 입력해주세요")
        configureTextFieldStyle(passwordTextField, placeholder: "비밀번호를 입력해주세요")
        configureTextFieldStyle(incomeTypeTextField, placeholder: "소득 유형 선택")

        [nameTextField, idTextField, passwordTextField].forEach {
            $0?.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
            $0?.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        }
    
        childBirthDatePicker.locale = Locale(identifier: "ko_KR") // 한국 날짜 형식

        genderSegmentedControl.removeAllSegments()
        genderSegmentedControl.insertSegment(withTitle: "남성", at: 0, animated: false)
        genderSegmentedControl.insertSegment(withTitle: "여성", at: 1, animated: false)
        genderSegmentedControl.selectedSegmentIndex = 0

        button.layer.cornerRadius = 12
        addChildView.layer.cornerRadius = 12
        imagePickerView.layer.cornerRadius = 8
        imagePreview.layer.cornerRadius = 8
        imagePreview.clipsToBounds = true

        incomeTypeView.isHidden = true
        addChildView.isHidden = true
        imagePreview.isHidden = true
    }

    private func setupPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        incomeTypeTextField.inputView = pickerView
        incomeTypeTextField.tintColor = .clear

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([doneButton], animated: false)
        incomeTypeTextField.inputAccessoryView = toolbar
    }

    private func setupImagePickerGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePickerViewTapped))
        imagePickerView.addGestureRecognizer(tapGesture)
        imagePickerView.isUserInteractionEnabled = true
    }

    // MARK: - Actions
    @objc private func doneTapped() {
        incomeTypeTextField.resignFirstResponder()
    }

    @objc private func imagePickerViewTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func checkButtonTapped(_ sender: UIButton) {
        print("버튼 클릭됨, 현재 count: \(count)")

        if count == 1 {
            nameView.isHidden = true
            idView.isHidden = true
            passwordView.isHidden = true
            incomeTypeView.isHidden = false
            count += 1

        } else if count == 2 {
            guard let name = nameTextField.text, !name.isEmpty,
                  let userId = idTextField.text, !userId.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty,
                  let incomeType = incomeTypeTextField.text, !incomeType.isEmpty else {
                showAlert(message: "모든 정보를 입력해주세요.")
                return
            }

            registerUser(name: name, id: userId, password: password, incomeType: incomeType)
            incomeTypeView.isHidden = true
            addChildView.isHidden = false
            count += 1

        } else if count == 3 {
            guard let childName = childNameTextField.text, !childName.isEmpty else {
                showAlert(message: "자녀 이름을 입력해주세요.")
                return
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let birth = dateFormatter.string(from: childBirthDatePicker.date)

            let genderIndex = genderSegmentedControl.selectedSegmentIndex
            let gender = genderIndex == 0 ? "남성" : "여성"

            saveChildInfo(name: childName, birth: birth, gender: gender)

            let alert = UIAlertController(title: "알림", message: "회원가입이 완료되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                let storyboard = UIStoryboard(name: "Main", bundle: nil) // 스토리보드 이름
                if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true, completion: nil)
                }
            })
            present(alert, animated: true, completion: nil)
        }

    }

    // MARK: - Firestore 저장
    private func registerUser(name: String, id: String, password: String, incomeType: String) {
        let userData: [String: Any] = [
            "name": name,
            "id": id,
            "password": password,
            "incomeType": incomeType
        ]

        let docRef = Firestore.firestore().collection("users").document() // 문서 ID 미리 생성
        docRef.setData(userData) { error in
            if let error = error {
                print("회원가입 실패: \(error.localizedDescription)")
                self.showAlert(message: "회원가입 실패! 다시 시도해주세요.")
                return
            }

            self.userDocumentId = docRef.documentID
            print("회원 정보 저장 완료")
        }
    }


    private func saveChildInfo(name: String, birth: String, gender: String) {
        guard let userId = userDocumentId else {
            print("userDocumentId 없음 - 자녀 정보 저장 실패")
            return
        }

        let childData: [String: Any] = [
            "name": name,
            "birth": birth,
            "gender": gender
        ]

        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("children")
            .addDocument(data: childData) { error in
                if let error = error {
                    print("자녀 정보 저장 실패: \(error.localizedDescription)")
                } else {
                    print("자녀 정보 저장 성공")
                }
            }
    }

    // MARK: - Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return incomeTypes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return incomeTypes[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        incomeTypeTextField.text = incomeTypes[row]
        button.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
    }

    // MARK: - 이미지 선택
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imagePreview.image = selectedImage
            imagePreview.isHidden = false
        }
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    // MARK: - UI 보조
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }

    private func configureTextFieldStyle(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.backgroundColor = UIColor(red: 0.954, green: 0.954, blue: 0.954, alpha: 1)
        textField.layer.cornerRadius = 12
        textField.clipsToBounds = true
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.setPadding(top: 14, left: 16, bottom: 14, right: 16)

        if textField == passwordTextField {
            textField.isSecureTextEntry = true
        }
    }

    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1).cgColor
    }

    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        button.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
    }
}
