//
//  FAQViewController.swift
//  WearCast
//
//  Created by 최승재 on 6/22/25.
//

import UIKit

class FAQViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "앱 정보"
        
        // 네비게이션 바 설정
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = UIColor.systemBlue
        
        // 닫기 버튼 추가
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.rightBarButtonItem = closeButton
        
        // 스크롤뷰 설정
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupContent()
    }
    
    private func setupContent() {
        // 앱 아이콘
        let appIconImageView = UIImageView()
        appIconImageView.image = UIImage(named: "appstore")
        appIconImageView.contentMode = .scaleAspectFill  // 꽉 차게
        appIconImageView.clipsToBounds = true            // 바깥으로 안 나가게
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 앱 제목
        let titleLabel = UILabel()
        titleLabel.text = "WearCast"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 부제목
        let subtitleLabel = UILabel()
        subtitleLabel.text = "날씨 기반 개인화 코디 추천 앱"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 앱 개요 카드
        let overviewCard = createInfoCard(
            title: "📱 앱 개요",
            content: """
            이 앱은 사용자의 현재 위치를 기반으로 날씨 정보를 자동으로 확인한 뒤, 그날의 기온, 강수량, 습도, 풍속 등을 종합해 적절한 옷차림을 추천해주는 개인화 코디 앱입니다.
            
            사용자는 AI(OpenAI)에게 현재 기상 상태에 최적화된 스타일 조언을 제공받으며, 매일 달라지는 날씨에 따라 새로운 추천을 받을 수 있습니다.
            """
        )
        
        // 주요 기능 카드
        let featuresCard = createInfoCard(
            title: "✨ 주요 기능",
            content: """
            • 실시간 위치 기반 날씨 정보 자동 수집
            • AI 기반 개인화 옷차림 추천
            • 기온, 습도, 풍속, 강수량 종합 분석
            • 추천 기록 저장 및 히스토리 확인
            • 직관적이고 사용하기 쉬운 인터페이스
            • 커뮤니티 기능으로 다른 사용자 추천 확인
            """
        )
        
        // 사용법 카드
        let usageCard = createInfoCard(
            title: "🔍 사용법",
            content: """
            1. 앱을 실행하면 현재 위치의 날씨를 자동으로 확인합니다
            2. '추천받기' 버튼을 눌러 AI 코디 추천을 받아보세요
            3. 상의, 하의, 아우터, 신발, 악세서리별 상세 추천을 확인하세요
            4. 마음에 드는 추천은 자동으로 저장됩니다
            5. 'My Page'에서 과거 추천 기록을 다시 확인할 수 있습니다
            """
        )
        
        // 대상 사용자 카드
        let targetCard = createInfoCard(
            title: "👥 이런 분들께 추천",
            content: """
            • 아침마다 "오늘 뭐 입지?"를 고민하는 분
            • 날씨에 맞는 옷차림을 선택하기 어려운 분
            • 패션에 관심은 있지만 코디가 어려운 분
            • 간편하고 빠른 스타일 조언이 필요한 분
            • 날씨 변화에 민감하여 옷차림 실수를 줄이고 싶은 분
            """
        )
        
        // 스택뷰에 모든 요소 추가
        let stackView = UIStackView(arrangedSubviews: [
            appIconImageView,
            titleLabel,
            subtitleLabel,
            overviewCard,
            featuresCard,
            usageCard,
            targetCard
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            appIconImageView.heightAnchor.constraint(equalToConstant: 350),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func createInfoCard(title: String, content: String) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.1
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.textColor = UIColor.label
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(titleLabel)
        cardView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            contentLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
        
        return cardView
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
