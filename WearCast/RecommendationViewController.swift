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

    var recommendation: (top: String, bottom: String, outer: String, shoes: String, accessories: String, tips: [String])?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        summaryLabel.text = "현재 날씨 요약\n\(temperature), \(humidity), \(windSpeed)"

        if let reco = recommendation {
            topCardLabel.text = "👕 상의: \(reco.top)"
            bottomCardLabel.text = "👖 하의: \(reco.bottom)"
            outerCardLabel.text = "🧥 겉옷: \(reco.outer)"
            shoesCardLabel.text = "👟 신발: \(reco.shoes)"
            accessoriesCardLabel.text = "🧢 액세서리: \(reco.accessories)"
            
            tipLabel.text = "💡 오늘의 포인트\n- " + reco.tips.joined(separator: "\n- ")
        }
    }

    // MARK: - Button Actions
    
    @IBAction func didTapStyleAgain(_ sender: UIButton) {
        print("스타일 다시 추천받기")
        // → 옵션 선택 뷰로 이동 or 다시 요청
    }

    @IBAction func didTapRefresh(_ sender: UIButton) {
        print("날씨 다시 확인")
        // → 현재 날씨 새로 요청
    }

    @IBAction func didTapSave(_ sender: UIButton) {
        print("추천 저장")
        // → UserDefaults or 서버에 저장
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

