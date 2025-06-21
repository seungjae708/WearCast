//
//  PreferencePopupViewController.swift
//  WearCast
//
//  Created by 최승재 on 6/21/25.
//

import UIKit

class PreferencePopupViewController: UIViewController {

    var preferenceSelectedHandler: (([String: Any]) -> Void)?

    private var selectedGender: String?
    private var selectedStyles: Set<String> = []
    private var selectedSituations: Set<String> = []
    private var selectedColors: Set<String> = []

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "옷 추천을 위한 정보를 선택하세요"
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var genderSegment: UISegmentedControl = {
        let control = UISegmentedControl(items: ["남성", "여성"])
        control.selectedSegmentIndex = UISegmentedControl.noSegment
        control.addTarget(self, action: #selector(genderChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // 구분용 레이블
    private let styleLabel = PreferencePopupViewController.createSectionLabel("스타일")
    private let situationLabel = PreferencePopupViewController.createSectionLabel("상황")
    private let colorLabel = PreferencePopupViewController.createSectionLabel("색상")

    private lazy var styleStack = PreferencePopupViewController.createButtonStack(
        titles: ["캐주얼", "스트릿", "포멀", "미니멀"],
        action: #selector(styleTapped(_:)),
        target: self
    )

    private lazy var situationStack = PreferencePopupViewController.createButtonStack(
        titles: ["일상", "데이트", "출근", "행사", "운동"],
        action: #selector(situationTapped(_:)),
        target: self
    )

    private lazy var colorStack = PreferencePopupViewController.createButtonStack(
        titles: ["밝은 톤", "중간 톤", "어두운 톤"],
        action: #selector(colorTapped(_:)),
        target: self
    )

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("선택 완료", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.tintColor = .systemRed
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(containerView)
        [titleLabel, genderSegment,
         styleLabel, styleStack,
         situationLabel, situationStack,
         colorLabel, colorStack,
         confirmButton, cancelButton].forEach { containerView.addSubview($0) }

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            genderSegment.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            genderSegment.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            genderSegment.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9),

            styleLabel.topAnchor.constraint(equalTo: genderSegment.bottomAnchor, constant: 20),
            styleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            styleStack.topAnchor.constraint(equalTo: styleLabel.bottomAnchor, constant: 8),
            styleStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            styleStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            styleStack.heightAnchor.constraint(equalToConstant: 36),

            situationLabel.topAnchor.constraint(equalTo: styleStack.bottomAnchor, constant: 16),
            situationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            situationStack.topAnchor.constraint(equalTo: situationLabel.bottomAnchor, constant: 8),
            situationStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            situationStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            situationStack.heightAnchor.constraint(equalToConstant: 36),

            colorLabel.topAnchor.constraint(equalTo: situationStack.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            colorStack.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            colorStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            colorStack.heightAnchor.constraint(equalToConstant: 36),

            confirmButton.topAnchor.constraint(equalTo: colorStack.bottomAnchor, constant: 20),
            confirmButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 120),
            confirmButton.heightAnchor.constraint(equalToConstant: 40),

            cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 8),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Actions
    @objc private func genderChanged() {
        selectedGender = genderSegment.titleForSegment(at: genderSegment.selectedSegmentIndex)
    }

    @objc private func styleTapped(_ sender: UIButton) {
        toggleSelection(for: sender, in: &selectedStyles)
    }

    @objc private func situationTapped(_ sender: UIButton) {
        toggleSelection(for: sender, in: &selectedSituations)
    }

    @objc private func colorTapped(_ sender: UIButton) {
        toggleSelection(for: sender, in: &selectedColors)
    }

    private func toggleSelection(for button: UIButton, in set: inout Set<String>) {
        guard let title = button.title(for: .normal) else { return }
        if set.contains(title) {
            set.remove(title)
            button.backgroundColor = .systemGray5
            button.setTitleColor(.label, for: .normal)
        } else {
            set.insert(title)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
        }
    }

    @objc private func didTapConfirm() {
        let result: [String: Any] = [
            "gender": selectedGender ?? "",
            "style": Array(selectedStyles),
            "situation": Array(selectedSituations),
            "colors": Array(selectedColors)
        ]
        preferenceSelectedHandler?(result)
        dismiss(animated: true)
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    // MARK: - Helpers
    static func createToggleButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemGray5
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    static func createButtonStack(titles: [String], action: Selector, target: Any?) -> UIStackView {
        let buttons = titles.map { title -> UIButton in
            let btn = createToggleButton(title: title)
            btn.addTarget(target, action: action, for: .touchUpInside)
            return btn
        }
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    static func createSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
