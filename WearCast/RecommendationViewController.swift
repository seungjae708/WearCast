//  RecommendationViewController.swift
//  WearCast

import UIKit
import FirebaseFirestore
import FirebaseAuth

class RecommendationViewController: UIViewController {

    // MARK: - UI Elements
    
    @IBOutlet weak var summaryLabel: UILabel!

    @IBOutlet weak var topCardLabel: UILabel!
    @IBOutlet weak var bottomCardLabel: UILabel!
    @IBOutlet weak var outerCardLabel: UILabel!
    @IBOutlet weak var shoesCardLabel: UILabel!
    @IBOutlet weak var accessoriesCardLabel: UILabel!

    @IBOutlet weak var tipLabel: UILabel!

    @IBOutlet weak var styleAgainButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Variables
    var temperature: String = ""
    var humidity: String = ""
    var windSpeed: String = ""
    var weatherDetailText: String = ""
    var userPreferences: [String: Any]? // 성별, 스타일, 상황, 색상 정보
    var preference: [String: Any]?
    var locationName: String = ""
    
    var apiKey = ""
    
    var recommendation: (top: String, bottom: String, outer: String, shoes: String, accessories: String, tips: [String])?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // 이미 외부에서 recommendation이 설정되었는지 확인
        if recommendation == nil {
            fetchRecommendationFromOpenAI()
        }
    }

    func setupView() {
        summaryLabel.text = "현재 날씨 요약\n\(temperature), \(humidity), \(windSpeed)"

        if let reco = recommendation {
            topCardLabel.text = "\(reco.top)"
            bottomCardLabel.text = "\(reco.bottom)"
            outerCardLabel.text = "\(reco.outer)"
            shoesCardLabel.text = "\(reco.shoes)"
            accessoriesCardLabel.text = "\(reco.accessories)"
            tipLabel.text = "💡 오늘의 포인트\n- " + reco.tips.joined(separator: "\n- ")
        } else {
            topCardLabel.text = "로딩 중..."
            bottomCardLabel.text = "로딩 중..."
            outerCardLabel.text = "로딩 중..."
            shoesCardLabel.text = "로딩 중..."
            accessoriesCardLabel.text = "로딩 중..."
            tipLabel.text = "💡 오늘의 포인트\n- 잠시만 기다려 주세요..."
        }
    }
    
    func fetchRecommendationFromOpenAI() {
        var preferenceText = ""
        if let pref = preference {
            if let gender = pref["gender"] as? String { preferenceText += "\n- 성별: \(gender)" }
            if let style = pref["style"] as? [String] { preferenceText += "\n- 스타일: \(style.joined(separator: ", "))" }
            if let situation = pref["situation"] as? [String] { preferenceText += "\n- 상황: \(situation.joined(separator: ", "))" }
            if let colors = pref["colors"] as? [String] { preferenceText += "\n- 색상 선호: \(colors.joined(separator: ", "))" }
        }
        
        let prompt = """
        [날씨 요약]
        \(weatherDetailText)

        [사용자 정보]
        \(preferenceText)

        위의 날씨와 사용자 정보를 참고하여, 아래 조건에 따라 오늘의 패션 스타일을 추천해 주세요.
        구성 항목:
        - 상의, 하의, 겉옷, 신발, 액세서리 각각 1개씩
        - 각 항목은 **옷의 종류뿐 아니라 길이(예: 반팔, 긴팔, 반바지, 긴바지)**, 소재, 색감, 조합을 반드시 명시할 것

        날씨 기준 조건:
        - **기온이 25도 이상이면 겉옷은 절대 추천하지 말 것**
        - 25도 이상이면 반팔 또는 민소매 위주로 구성
        - 15도 이상 22도 이하는 봄/가을용 얇은 겉옷, 긴팔 포함 가능
        - 13도 미만일 경우 보온성이 좋은 겉옷 (코트, 패딩 등) 포함
        
        - 추천 대상은 \(preference?["gender"] as? String ?? "사용자")입니다.
        - 사용자가 선호하는 스타일은 \( (preference?["style"] as? [String])?.joined(separator: ", ") ?? "없음")입니다.
        - 옷차림은 주로 \( (preference?["situation"] as? [String])?.joined(separator: ", ") ?? "일상") 상황에 어울려야 합니다.
        - 전체적인 색상 톤은 \( (preference?["colors"] as? [String])?.joined(separator: ", ") ?? "자유롭게") 분위기를 내도록 구성해 주세요.

        [출력 형식]
        아래 JSON 형식으로 답변해 주세요:

        {
          "top": "예: 연청 린넨 셔츠",
          "bottom": "예: 카키 면 팬츠",
          "outer": "예: 얇은 트렌치코트 (베이지)",
          "shoes": "예: 흰색 로우탑 스니커즈",
          "accessories": "예: 미니멀 가죽 크로스백",
          "tips": [
            "기온이 낮아 얇은 겉옷 필요",
            "바람이 강하므로 단단한 신발 추천",
            "색조합으로 차분한 인상을 줄 수 있음"
          ]
        }
        """

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let messages = [
            ["role": "user", "content": prompt]
        ]
        
        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.7
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("OpenAI 응답 없음:", error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                // 1. 전체 응답 디코드
                guard let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("전체 JSON 디코딩 실패")
                    return
                }

                print("전체 응답 JSON:\n\(responseDict)")

                // 2. 응답 구조 추출
                guard let choices = responseDict["choices"] as? [[String: Any]],
                      let message = choices.first?["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    print("응답 구조 파싱 실패")
                    return
                }

                print("GPT 응답 (content):\n\(content)")

                // 3. 불필요한 ```json 제거
                let cleaned = content
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                print("cleaned JSON 문자열:\n\(cleaned)")

                // 4. JSON 문자열 → 딕셔너리
                guard let jsonData = cleaned.data(using: .utf8),
                      let result = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                    print("JSON 문자열 파싱 실패")
                    return
                }

                print("파싱 성공 - 결과:\n\(result)")

                // 5. 메인 스레드에서 UI 반영
                DispatchQueue.main.async {
                    self.recommendation = (
                        top: result["top"] as? String ?? "",
                        bottom: result["bottom"] as? String ?? "",
                        outer: result["outer"] as? String ?? "",
                        shoes: result["shoes"] as? String ?? "",
                        accessories: result["accessories"] as? String ?? "",
                        tips: result["tips"] as? [String] ?? []
                    )
                    self.setupView()
                }
            } catch {
                print("JSON 파싱 예외 발생:", error)
            }
        }
        task.resume()
    }

    // MARK: - Button Actions
    
    @IBAction func didTapStyleAgain(_ sender: UIButton) {
        print("스타일 다시 추천받기")
        let preferenceVC = PreferencePopupViewController()
        preferenceVC.modalPresentationStyle = .overCurrentContext
        preferenceVC.modalTransitionStyle = .crossDissolve

        preferenceVC.preferenceSelectedHandler = { [weak self] selected in
            guard let self = self else { return }

            self.preference = selected
            self.recommendation = nil // 이전 추천 초기화
            self.setupView() // UI 초기화 (로딩 중... 텍스트 등)
            self.fetchRecommendationFromOpenAI() // 새로 추천 받기

            self.dismiss(animated: true)
        }

        self.present(preferenceVC, animated: true)
    }
    
    @IBAction func didTapPreviewImageButton(_ sender: UIButton) {
        guard let reco = self.recommendation else {
            print("추천이 아직 없음")
            return
        }

        // 1. 로딩 인디케이터 표시
        let loadingAlert = UIAlertController(title: nil, message: "이미지를 생성 중입니다...\n\n", preferredStyle: .alert)
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        loadingAlert.view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            spinner.bottomAnchor.constraint(equalTo: loadingAlert.view.bottomAnchor, constant: -20)
        ])
        self.present(loadingAlert, animated: true)

        let genderText = (preference?["gender"] as? String) ?? "모델"
        let styleText = (preference?["style"] as? [String])?.joined(separator: ", ") ?? "선호 스타일 없음"
        let situationText = (preference?["situation"] as? [String])?.joined(separator: ", ") ?? "일상"
        let colorTone = (preference?["colors"] as? [String])?.joined(separator: ", ") ?? "자연스러운 톤"
        
        // 2. 프롬프트 생성
        let prompt = """
            A realistic outfit photo featuring:
            - Top: \(reco.top)
            - Bottom: \(reco.bottom)
            - Outer: \(reco.outer)
            - Shoes: \(reco.shoes)
            - Accessories: \(reco.accessories)

            Show the full outfit on a single standing \(genderText) model only. No additional people. Use a modern clean background, 4K resolution, and fashion catalog style."
            """

        // 3. 이미지 생성
        generateImageFromPrompt(prompt: prompt) { generatedImage in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    guard let generatedImage = generatedImage else {
                        // 3-1. 실패 시 알림
                        let failAlert = UIAlertController(title: "실패", message: "이미지 생성에 실패했어요. 다시 시도해 주세요.", preferredStyle: .alert)
                        failAlert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(failAlert, animated: true)
                        return
                    }

                    // 3-2. 성공 시 팝업으로 이미지 표시
                    let popupVC = PreviewImageViewController()
                    popupVC.image = generatedImage
                    popupVC.modalPresentationStyle = .overFullScreen
                    popupVC.modalTransitionStyle = .crossDissolve
                    self.present(popupVC, animated: true)
                }
            }
        }
    }
    
    func generateImageFromPrompt(prompt: String, completion: @escaping (UIImage?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/images/generations")!

        let json: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("이미지 응답 실패:", error?.localizedDescription ?? "Unknown")
                completion(nil)
                return
            }

            do {
                if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataArr = dict["data"] as? [[String: Any]],
                   let urlStr = dataArr.first?["url"] as? String,
                   let imageUrl = URL(string: urlStr),
                   let imageData = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: imageData) {
                    completion(image)
                } else {
                    print("이미지 URL 파싱 실패")
                    completion(nil)
                }
            } catch {
                print("JSON 에러: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }

    @IBAction func didTapRefresh(_ sender: UIButton) {
        print("날씨 상세 보기 (팝업)")

        let popupVC = WeatherDetailPopupViewController()
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.weatherSummary = self.weatherDetailText
        present(popupVC, animated: true)
    }

    @IBAction func didTapSave(_ sender: UIButton) {
        print("추천 저장")
        guard let reco = recommendation else {
            print("추천된 옷 정보가 없습니다.")
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            print("사용자 인증 실패: 익명 로그인 필요")
            return
        }

        let uid = user.uid  // 사용자 고유 ID

        // 저장할 키
        let key = UUID().uuidString

        // 전체 저장할 데이터 (추천 + 날씨 요약 + preference 포함)
        let outfitData: [String: Any] = [
            "uid": uid,
            "top": reco.top,
            "bottom": reco.bottom,
            "outer": reco.outer,
            "shoes": reco.shoes,
            "accessories": reco.accessories,
            "tips": reco.tips,
            "weatherDetail": weatherDetailText,
            "preference": preference ?? [:],  // nil 방지
            "location": locationName,
            "timestamp": Timestamp(date: Date())
        ]
        
        // Firestore 저장
        let db = DbFirebase(parentNotification: nil)
        db.saveChange(key: key, object: outfitData, action: .add)

        // 알림
        let alert = UIAlertController(title: "저장 완료", message: "날씨와 함께 착장을 저장했어요!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            // 알림 닫은 후 RecommendationViewController도 닫기
            self.dismiss(animated: true) {
                self.presentingViewController?.dismiss(animated: true)
            }
        }))
        present(alert, animated: true)

    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

