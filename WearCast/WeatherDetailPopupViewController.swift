//
//  WeatherDetailPopupViewController.swift
//  WearCast
//
//  Created by 최승재 on 6/21/25.
//

import UIKit

class WeatherDetailPopupViewController: UIViewController {

    var weatherSummary: String = ""

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("닫기", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupLayout()
        summaryLabel.text = weatherSummary
    }

    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(summaryLabel)
        containerView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),

            summaryLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            summaryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            closeButton.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])

        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}
