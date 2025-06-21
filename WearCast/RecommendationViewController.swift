//  RecommendationViewController.swift
//  WearCast

import UIKit

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
    
    var apiKey = ""
    
    var recommendation: (top: String, bottom: String, outer: String, shoes: String, accessories: String, tips: [String])?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        fetchRecommendationFromOpenAI()
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
        let prompt = """
        다음은 날씨 정보입니다: \(weatherDetailText)

        위 날씨에 어울리는 옷차림을 패션 스타일리스트의 관점에서 구체적으로 추천해줘.
        - 각 항목(상의, 하의, 겉옷, 신발, 액세서리)은 구체적인 의류 종류, 소재, 색감, 조합을 포함할 것
        - 실용성과 스타일을 모두 고려할 것
        - 추천 사유는 3개, 명확하고 간결하게

        다음 JSON 형식으로 응답해줘:

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
                if let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = responseDict["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String,
                   let jsonData = content.data(using: .utf8),
                   let result = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

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
                } else {
                    print("OpenAI 응답 파싱 실패")
                }
            } catch {
                print("JSON 파싱 에러:", error)
            }
        }
        task.resume()
    }

    // MARK: - Button Actions
    
    @IBAction func didTapStyleAgain(_ sender: UIButton) {
        print("스타일 다시 추천받기")
        // → 옵션 선택 뷰로 이동 or 다시 요청
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

        // 2. 프롬프트 생성
        let prompt = """
        A realistic outfit photo featuring:
        - Top: \(reco.top)
        - Bottom: \(reco.bottom)
        - Outer: \(reco.outer)
        - Shoes: \(reco.shoes)
        - Accessories: \(reco.accessories)

        Show the full outfit on a standing model, modern clean background, 4K quality, fashion catalog style.
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
        // → UserDefaults or 서버에 저장
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

