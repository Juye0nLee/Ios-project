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
    @IBOutlet weak var charge3: UILabel! // 기본요금
    @IBOutlet weak var charge2: UILabel! // 정부지원 판정금
    @IBOutlet weak var charge1: UILabel! // 본인 부담금

    // 오버레이 구성 요소
    let overlayView = UIView()
    let loadingIcon = UIImageView(image: UIImage(systemName: "hourglass"))
    let loadingLabel = UILabel()
    let subLabel = UILabel()
    let logo1 = UIImageView(image: UIImage(named:"service_logo"))
    let logo2 = UIImageView(image: UIImage(named:"ivory_text_logo"))
    let xIcon = UIImageView(image: UIImage(systemName: "xmark"))
    let textLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserAndChildInfo()
        setupOverlay()
        payButton.layer.cornerRadius = 12
    }

    private func setupOverlay() {
        overlayView.frame = view.bounds
        overlayView.backgroundColor = .white
        overlayView.isHidden = true
        overlayView.layer.zPosition = 999

        // 중앙 로딩 아이콘 및 라벨
        loadingIcon.tintColor = UIColor(red: 0.988, green: 0.596, blue: 0.424, alpha: 1)
        loadingIcon.contentMode = .scaleAspectFit
        loadingIcon.translatesAutoresizingMaskIntoConstraints = false

        loadingLabel.text = "서비스 결제 중"
        loadingLabel.font = UIFont.boldSystemFont(ofSize: 22)
        loadingLabel.textAlignment = .center
        loadingLabel.textColor = .black
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false

        subLabel.text = "잠시만 기다려주세요 :)"
        subLabel.font = UIFont.systemFont(ofSize: 15)
        subLabel.textAlignment = .center
        subLabel.textColor = .darkGray
        subLabel.translatesAutoresizingMaskIntoConstraints = false

        // 하단 로고 및 텍스트
        logo1.image = UIImage(named: "아이돌봄서비스 로고")
        logo1.contentMode = .scaleAspectFit
        logo1.translatesAutoresizingMaskIntoConstraints = false

        logo2.image = UIImage(named: "아이보리 텍스트 로고")
        logo2.contentMode = .scaleAspectFit
        logo2.translatesAutoresizingMaskIntoConstraints = false

        textLabel.text = "본 서비스는 아이돌봄서비스와 아이보리가 함께합니다"
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        // 스택 구성
        let centerStack = UIStackView(arrangedSubviews: [loadingIcon, loadingLabel, subLabel])
        centerStack.axis = .vertical
        centerStack.alignment = .center
        centerStack.spacing = 12
        centerStack.translatesAutoresizingMaskIntoConstraints = false

        let logoStack = UIStackView(arrangedSubviews: [logo1, logo2])
        logoStack.axis = .horizontal
        logoStack.alignment = .center
        logoStack.distribution = .equalSpacing
        logoStack.spacing = 8
        logoStack.translatesAutoresizingMaskIntoConstraints = false

        overlayView.addSubview(centerStack)
        overlayView.addSubview(logoStack)
        overlayView.addSubview(textLabel)
        view.addSubview(overlayView)

        // 제약조건
        NSLayoutConstraint.activate([
            // 중앙 스택
            centerStack.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            loadingIcon.widthAnchor.constraint(equalToConstant: 30),
            loadingIcon.heightAnchor.constraint(equalToConstant: 30),

            // 로고 스택 하단
            logoStack.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            logoStack.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -60),
            logo1.heightAnchor.constraint(equalToConstant: 20),
            logo2.heightAnchor.constraint(equalToConstant: 20),

            // 안내 텍스트
            textLabel.topAnchor.constraint(equalTo: logoStack.bottomAnchor, constant: 6),
            textLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor)
        ])
    }


    @IBAction func payButtonTapped(_ sender: UIButton) {
        overlayView.isHidden = false

        // 1. 요청할 URL
        guard let url = URL(string: "http://192.168.45.245:8080/payments/start") else {
            print("URL 생성 실패")
            return
        }

        // 2. URLRequest 구성
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("SECRET_KEY DEV44D98DF96DA593BCE34C8B17C62625836F53C", forHTTPHeaderField: "Authorization")

        // 3. 요청 보내기
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.overlayView.isHidden = true
            }

            if let error = error {
                print("요청 실패: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("응답 데이터 없음")
                return
            }

            // 4. JSON 디코딩
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(KakaoPayResponse.self, from: data)
                
                // 5. 결제 페이지로 이동 (Safari 열기)
                if let url = URL(string: response.next_redirect_pc_url) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }
            } catch {
                print("디코딩 실패: \(error.localizedDescription)")
            }
        }

        task.resume()
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

                        // 5시간 고정 스케줄
                        let endDate = Calendar.current.date(byAdding: .hour, value: 5, to: startDate) ?? startDate

                        let formatterDate = DateFormatter()
                        formatterDate.dateFormat = "yyyy-MM-dd"

                        let formatterTime = DateFormatter()
                        formatterTime.dateFormat = "HH:mm"

                        let scheduleText = "\(formatterDate.string(from: startDate)) | \(formatterTime.string(from: startDate)) ~ \(formatterDate.string(from: endDate)) | \(formatterTime.string(from: endDate))"
                        
                        let hoursPerDay = 5
                        let hourlyRate = 13900
                        let days = 5
                        let totalHours = hoursPerDay * days
                        let totalAmount = totalHours * hourlyRate
                        
                        // 자녀 나이 계산
                        let birthFormatter = DateFormatter()
                        birthFormatter.dateFormat = "yyyy-MM-dd"
                        let birthDate = birthFormatter.date(from: birthStr) ?? Date()
                        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0

                        var subsidy: Int = 0
                        if incomeType.contains("가형") {
                            subsidy = age < 8 ? Int(Double(totalAmount) * 0.85) : Int(Double(totalAmount) * 0.75)
                        } else if incomeType.contains("나형") {
                            subsidy = age < 8 ? Int(Double(totalAmount) * 0.60) : Int(Double(totalAmount) * 0.50)
                        } else if incomeType.contains("다형") || incomeType.contains("라형") {
                            subsidy = Int(Double(totalAmount) * 0.50)
                        } else {
                            subsidy = 0
                        }
                        let userPay = totalAmount - subsidy

                        DispatchQueue.main.async {
                            self.scheduleLabel.text = scheduleText
                            self.memoLabel.text = "우리 아이는 포켓몬을 좋아해요"

                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal

                            self.charge1.text = "\(formatter.string(from: NSNumber(value: totalAmount)) ?? "0")원"
                            self.charge2.text = "\(formatter.string(from: NSNumber(value: subsidy)) ?? "0")원"
                            self.charge3.text = "\(formatter.string(from: NSNumber(value: userPay)) ?? "0")원"
                        }
                    }
            }
        }
    }
}
