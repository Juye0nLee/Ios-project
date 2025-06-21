//
//  MainViewController.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/19/25.
//

import UIKit
import FirebaseFirestore

class MainViewController: UIViewController {
    var userDocumentId: String?
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var childImage: UIImageView!
    @IBOutlet weak var applyButton: UIView!
    @IBOutlet weak var applyStatusBox: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserData()
        fetchChildrenData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(applyButtonTapped))
        applyButton.addGestureRecognizer(tapGesture)
        applyButton.isUserInteractionEnabled = true
    }
    
    private func setupUI() {
        applyButton.layer.cornerRadius = 16
        applyStatusBox.layer.cornerRadius = 12
        applyStatusBox.layer.borderColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1).cgColor
        applyStatusBox.layer.borderWidth = 1
        childImage.layer.cornerRadius = 12
        scrollView.layer.cornerRadius = 16
    }
    private func fetchUserData() {
        guard let userId = userDocumentId else {
            print("userDocumentId 없음")
            return
        }

        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("유저 정보 조회 실패: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else { return }
            let name = data["name"] as? String ?? ""
            let incomeType = data["incomeType"] as? String ?? ""

            print("유저 이름: \(name), 소득 유형: \(incomeType)")
            // 여기에 UI 반영 코드 작성 가능
            DispatchQueue.main.async {
                self.userNameLabel.text = "\(name)님"
            }
        }
    }

    private func fetchChildrenData() {
        guard let userId = userDocumentId else {
            print("userDocumentId 없음")
            return
        }

        let childrenRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("children")

        childrenRef.getDocuments { snapshot, error in
            if let error = error {
                print("자녀 정보 조회 실패: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else { return }

            var serviceApplied = false
            let dispatchGroup = DispatchGroup()

            for doc in documents {
                let childId = doc.documentID
                dispatchGroup.enter()

                childrenRef.document(childId).collection("schedules").getDocuments { scheduleSnapshot, error in
                    if let error = error {
                        print("스케줄 조회 실패: \(error.localizedDescription)")
                    } else if let schedules = scheduleSnapshot?.documents, !schedules.isEmpty {
                        serviceApplied = true
                    }

                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                if serviceApplied {
                    self.statusLabel.text = "서비스 신청 완료"
                }
            }
        }
    }

    
    @objc func applyButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let applyVC = storyboard.instantiateViewController(withIdentifier: "ApplyViewController") as? ApplyViewController {
            applyVC.userDocumentId = self.userDocumentId
            self.present(applyVC, animated: false, completion: nil)
        }
    }

}

