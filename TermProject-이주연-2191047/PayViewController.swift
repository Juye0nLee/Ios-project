import UIKit
import FirebaseFirestore

class PayViewController: UIViewController {
    var userDocumentId: String?

    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var incomeTypeLabel: UILabel!

    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var charge3: UILabel! //기본요금
    @IBOutlet weak var charge2: UILabel! //정부지원 판정금
    @IBOutlet weak var charge1: UILabel! //본인 부담금
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserAndChildInfo()
        payButton.layer.cornerRadius = 12
    }

    private func fetchUserAndChildInfo() {
        guard let userId = userDocumentId else {
            print("userDocumentId 없음")
            return
        }

        let userRef = Firestore.firestore().collection("users").document(userId)

        userRef.getDocument { snapshot, error in
            if let error = error {
                print("유저 정보 조회 실패: \(error.localizedDescription)")
                return
            }

            guard let userData = snapshot?.data() else { return }

            let incomeType = userData["incomeType"] as? String ?? ""

            DispatchQueue.main.async {
                self.incomeTypeLabel.text = incomeType
            }

            userRef.collection("children").getDocuments { childSnapshot, error in
                if let error = error {
                    print("자녀 정보 조회 실패: \(error.localizedDescription)")
                    return
                }

                guard let childDoc = childSnapshot?.documents.first else {
                    print("자녀 없음")
                    return
                }

                let childData = childDoc.data()
                let childName = childData["name"] as? String ?? ""
                let birthStr = childData["birth"] as? String ?? ""

                DispatchQueue.main.async {
                    self.nameLabel.text = childName
                    self.birthLabel.text = birthStr
                }

                userRef.collection("children")
                    .document(childDoc.documentID)
                    .collection("schedules")
                    .order(by: "createdAt", descending: true)
                    .limit(to: 1)
                    .getDocuments { scheduleSnapshot, error in

                        if let error = error {
                            print("스케줄 정보 조회 실패: \(error.localizedDescription)")
                            return
                        }

                        guard let scheduleDoc = scheduleSnapshot?.documents.first else {
                            print("스케줄 없음")
                            return
                        }

                        let scheduleData = scheduleDoc.data()
                        let memo = scheduleData["memo"] as? String ?? ""
                        let createdAt = scheduleData["createdAt"] as? Timestamp

                        guard let startDate = createdAt?.dateValue() else {
                            print("createdAt 없음")
                            return
                        }

                        //5시간 고정
                        let endDate = Calendar.current.date(byAdding: .hour, value: 5, to: startDate) ?? startDate

                        let formatterDate = DateFormatter()
                        formatterDate.dateFormat = "yyyy-MM-dd"

                        let formatterTime = DateFormatter()
                        formatterTime.dateFormat = "HH:mm"

                        let scheduleText = "\(formatterDate.string(from: startDate)) | \(formatterTime.string(from: startDate)) ~ \(formatterDate.string(from: endDate)) | \(formatterTime.string(from: endDate))"

                        //요금 계산
                        let hoursPerDay = 5
                        let hourlyRate = 13900
                        let days = 5
                        let totalHours = hoursPerDay * days
                        let totalAmount = totalHours * hourlyRate

                        //자녀 나이 계산
                        let birthFormatter = DateFormatter()
                        birthFormatter.dateFormat = "yyyy-MM-dd"
                        let birthDate = birthFormatter.date(from: birthStr) ?? Date()
                        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0

                        //정부 지원금 계산
                        var subsidy: Int = 0
                        if incomeType.contains("가형") {
                            subsidy = age < 8 ? Int(Double(totalAmount) * 0.85) : Int(Double(totalAmount) * 0.75)
                        } else if incomeType.contains("나형") {
                            subsidy = age < 8 ? Int(Double(totalAmount) * 0.60) : Int(Double(totalAmount) * 0.50)
                        } else if incomeType.contains("다형") || incomeType.contains("라형") {
                            subsidy = Int(Double(totalAmount) * 0.50)
                        } else {
                            subsidy = 0 // 소득 유형이 없으면 지원 없음
                        }

                        let userPay = totalAmount - subsidy

                        
                        DispatchQueue.main.async {
                            self.scheduleLabel.text = scheduleText
                            self.memoLabel.text = memo

                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal

                            self.charge3.text = "\(formatter.string(from: NSNumber(value: totalAmount)) ?? "0")원"
                            self.charge2.text = "\(formatter.string(from: NSNumber(value: subsidy)) ?? "0")원"
                            self.charge1.text = "\(formatter.string(from: NSNumber(value: userPay)) ?? "0")원"
                        }
                    }
            }
        }
    }

}
