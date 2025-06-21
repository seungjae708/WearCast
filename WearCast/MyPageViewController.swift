//
//  MyPageViewController.swift
//  WearCast
//
//  Created by 최승재 on 6/22/25.
//

import UIKit
import FirebaseAuth

class MyPageViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func didTapMyOutfits(_ sender: UIButton) {
        performSegue(withIdentifier: "showMyOutfits", sender: nil)
    }

    @IBAction func didTapFAQ(_ sender: UIButton) {
        let faqVC = FAQViewController()
        let navController = UINavigationController(rootViewController: faqVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }

    @IBAction func didTapLogout(_ sender: UIButton) {
        let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                // 로그인 화면으로 이동하거나 앱 상태 초기화
                self.dismiss(animated: true)
            } catch {
                print("로그아웃 실패: \(error.localizedDescription)")
            }
        }))
        present(alert, animated: true)
    }
}
