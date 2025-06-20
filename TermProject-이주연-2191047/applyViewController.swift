//
//  applyViewController.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/19/25.
//

import Foundation
import UIKit
import FirebaseFirestore

class ApplyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var childInfoLabel: UILabel!
    @IBOutlet weak var childNameLabel: UILabel!
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
    @IBOutlet weak var ImagePreview: UIImageView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var calendar: UIDatePicker!
    
    @IBOutlet weak var periodField: UILabel!
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var reasonField: UILabel!
    @IBOutlet weak var reason: UILabel!
    @IBOutlet weak var noteField: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var memoView: UIStackView!
    @IBOutlet weak var memofield: UITextField!
    var userDocumentId: String?
    var selectedDate = ""
    let overlayView = UIView()
    let loadingLabel = UILabel()
    let loadingIcon = UIImageView(image: UIImage(systemName: "list.bullet.rectangle"))

    var count = 1;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CornerRadius 설정
        [circle1, circle2, circle3, circle4, circle5, circle6].forEach {
            $0?.layer.cornerRadius = 20
        }
        [box1, box2, box3, box4].forEach {
            $0?.layer.cornerRadius = 16
        }
        childBox.layer.cornerRadius = 12
        checkButton.layer.cornerRadius = 8

        //초기 hidden 상태
        childBox.isHidden = true
        imagePickerView.isHidden = true
        resultView.isHidden = true
        calendar.isHidden = true
        memoView.isHidden = true
        
        
        memofield.addTarget(self, action: #selector(memoFieldDidBeginEditing), for: .editingDidBegin)
        memofield.layer.cornerRadius = 12
        
        calendar.preferredDatePickerStyle = .inline // 달력 스타일
        calendar.datePickerMode = .dateAndTime
        calendar.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        


        //탭 제스처 설정
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(childBoxTapped))
        childBox.addGestureRecognizer(tapGesture1)
        childBox.isUserInteractionEnabled = true

        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(imagePickerViewTapped))
        circle5.addGestureRecognizer(tapGesture2)
        circle5.isUserInteractionEnabled = true
        
        ImagePreview.isHidden = true
        ImagePreview.layer.cornerRadius = 12
        ImagePreview.clipsToBounds = true
        
        //Overlay View 설정
        overlayView.frame = view.bounds
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        overlayView.isHidden = true
        overlayView.layer.zPosition = 999  // 가장 위에 표시되도록

        //아이콘
        loadingIcon.tintColor = .white
        loadingIcon.contentMode = .scaleAspectFit
        loadingIcon.translatesAutoresizingMaskIntoConstraints = false

        //라벨
        loadingLabel.text = "서류 검증하는 중..."
        loadingLabel.textColor = .white
        loadingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.textAlignment = .center

        //스택뷰로 묶기
        let stack = UIStackView(arrangedSubviews: [loadingIcon, loadingLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        overlayView.addSubview(stack)
        view.addSubview(overlayView)

        // 제약조건
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            loadingIcon.widthAnchor.constraint(equalToConstant: 40),
            loadingIcon.heightAnchor.constraint(equalToConstant: 40)
        ])


    }
    
    //아이 선택 시 스타일 변경
    @objc func childBoxTapped() {
        childBox.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 0.15)
        childBox.layer.borderWidth = 1
        childBox.layer.borderColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1).cgColor
        checkButton.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
    }

    //이미지 선택 뷰 클릭 시
    @objc func imagePickerViewTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }

    //파일 선택 완료 처리
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            ImagePreview.image = selectedImage  // 이미지를 뷰에 표시
            ImagePreview.isHidden = false       // 안 보였다면 보이게
            print("선택된 이미지: \(selectedImage)")
            checkButton.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        //날짜 선택되면 버튼 활성화
        checkButton.isEnabled = true
        checkButton.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        selectedDate = formatter.string(from: sender.date)
        print("선택된 날짜 및 시간: \(selectedDate)")
        count += 1
    }
    
    private func calculateAge(from birth: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // 저장한 형식과 일치해야 함
        guard let birthDate = formatter.date(from: birth) else { return 0 }

        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year ?? 0
    }
    
    @objc func memoFieldDidBeginEditing() {
        memofield.backgroundColor = UIColor(red: 0.954, green: 0.954, blue: 0.954, alpha: 1)
        memofield.layer.cornerRadius = 12
        memofield.layer.borderWidth = 1
        memofield.layer.borderColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1).cgColor
        checkButton.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
    }
    
    private func saveScheduleForChild(date: String, memo: String) {
        guard let userId = userDocumentId else {
            print("userDocumentId 없음")
            return
        }

        // 자녀 문서 1개만 있다고 가정 (첫 번째 자녀)
        let childrenRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("children")

        childrenRef.getDocuments { snapshot, error in
            if let error = error {
                print("자녀 문서 조회 실패: \(error.localizedDescription)")
                return
            }

            guard let firstChildDoc = snapshot?.documents.first else {
                print("자녀 없음")
                return
            }

            let childId = firstChildDoc.documentID
            let scheduleData: [String: Any] = [
                "date": date,
                "memo": memo,
                "createdAt": Timestamp(date: Date())
            ]

            Firestore.firestore()
                .collection("users")
                .document(userId)
                .collection("children")
                .document(childId)
                .collection("schedules")
                .addDocument(data: scheduleData) { error in
                    if let error = error {
                        print("스케줄 저장 실패: \(error.localizedDescription)")
                    } else {
                        print("스케줄 저장 성공!")
                    }
                }
        }
    }


    //버튼 클릭 이벤트
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        let shouldHide = true
        [box1, box2, box3, box4, circle1, circle2, circle3, circle4].forEach {
            $0?.isHidden = shouldHide
        }

        if count == 1 {
            text1.text = "서비스 신청할 아이를 선택해 주세요"
            text2.text = "한 명만 선택이 가능합니다"
            checkButton.setTitle("선택 완료", for: .normal)
            checkButton.tintColor = .white
            checkButton.backgroundColor = UIColor(red: 0.875, green: 0.886, blue: 0.898, alpha: 1)
            childBox.isHidden = false
            count += 1
            //자녀 정보 가져오기
            if let userId = userDocumentId {
                Firestore.firestore()
                    .collection("users")
                    .document(userId)
                    .collection("children")
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("자녀 정보 조회 실패: \(error.localizedDescription)")
                            return
                        }
                        guard let documents = snapshot?.documents else { return }
                        if let first = documents.first {
                            let data = first.data()
                            let name = data["name"] as? String ?? ""
                            let birth = data["birth"] as? String ?? ""
                            let gender = data["gender"] as? String ?? ""
                            
                            let age = self.calculateAge(from: birth)

                            DispatchQueue.main.async {
                                self.childNameLabel.text = "\(name)"
                                self.childInfoLabel.text = "만 \(age)세 | \(gender)"
                                self.childBox.isHidden = false
                            }
                        }
                    }
            }
        } else if count == 2 {
            text1.text = "1. 서류제출"
            text2.text = "진단서 제출"
            checkButton.setTitle("서류 검증하기", for: .normal)
            checkButton.tintColor = .white
            checkButton.backgroundColor = UIColor(red: 0.875, green: 0.886, blue: 0.898, alpha: 1)
            imagePickerView.isHidden = false
            imagePickerView.layer.cornerRadius = 8
            childBox.isHidden = true
            count += 1
        } else if count == 3 {
            overlayView.isHidden = false
            // 예: 2초 뒤에 숨기기 (서버 응답 시 대체 가능)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.overlayView.isHidden = true
                self.imagePickerView.isHidden = true
                //이후
                self.checkButton.setTitle("다음", for: .normal)
                self.checkButton.tintColor = .white
                self.checkButton.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
                self.resultView.isHidden = false
                self.count += 1
            }
        } else if count == 4 {
            self.resultView.isHidden = true
            text1.text = "1. 서류제출"
            text2.text = "미등원 확인서 제출"
            checkButton.setTitle("서류 검증하기", for: .normal)
            checkButton.tintColor = .white
            checkButton.backgroundColor = UIColor(red: 0.875, green: 0.886, blue: 0.898, alpha: 1)
            imagePickerView.isHidden = false
            imagePickerView.layer.cornerRadius = 8
            //이미지 초기화
            self.ImagePreview.image = nil
            self.ImagePreview.isHidden = true
            count += 1
        } else if count == 5 {
            overlayView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.overlayView.isHidden = true
                self.imagePickerView.isHidden = true
                //이후
                self.checkButton.setTitle("다음", for: .normal)
                self.checkButton.tintColor = .white
                self.checkButton.backgroundColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
                self.resultView.isHidden = false
                self.periodField.text = "결석 기간"
                self.period.text = "2025-06-20 ~ 2025-06-24 (5일)"
                self.reasonField.text = "결석 사유"
                self.reason.text = "질병(눈병)으로 인한 결석"
                self.noteField.text = "비고"
                self.note.text = ""
                self.count += 1
            }
        } else if count == 6 {
            self.resultView.isHidden = true
            text1.text = "2. 일정 선택"
            text2.text = "돌봄 일정 선택"
            checkButton.setTitle("다음", for: .normal)
            checkButton.tintColor = .white
            checkButton.backgroundColor = UIColor(red: 0.875, green: 0.886, blue: 0.898, alpha: 1)
            //캘린더
            self.calendar.isHidden = false
            self.calendar.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
            self.calendar.layer.cornerRadius = 12
            self.calendar.locale = Locale(identifier: "ko_KR")
            self.calendar.tintColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
        } else if count == 7 {
            self.calendar.isHidden = true
            self.memoView.isHidden = false
            text1.text = "2. 일정 선택"
            text2.text = "돌봄 메모 작성 (선택)"
            checkButton.backgroundColor = UIColor(red: 0.875, green: 0.886, blue: 0.898, alpha: 1)
            
            // 저장 호출
            let memo = self.memofield.text ?? ""
            self.saveScheduleForChild(date: self.selectedDate, memo: memo)
            count += 1
        } else if count == 8 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let payVC = storyboard.instantiateViewController(withIdentifier: "PayViewController") as? PayViewController {
                payVC.userDocumentId = self.userDocumentId // 유저 정보 전달
                self.present(payVC, animated: true, completion: nil) // modal 방식
                // 또는 navigationController?.pushViewController(payVC, animated: true)
            }
        }
    }
}
