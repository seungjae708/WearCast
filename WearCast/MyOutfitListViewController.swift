//
//  MyOutfitListViewController.swift
//  WearCast
//
//  Created by 최승재 on 6/22/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MyOutfitListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var mytableView: UITableView!
    
    var outfits: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mytableView.delegate = self
        mytableView.dataSource = self
        
        // 네트워크 문제를 우회하기 위한 임시 데이터
        outfits = [
            [
                "location": "서울시 강남구",
                "top": "흰색 셔츠",
                "bottom": "검은색 슬랙스",
                "timestamp": Timestamp(),
                "docId": "test1"
            ],
            [
                "location": "부산시 해운대구",
                "top": "파란색 티셔츠",
                "bottom": "청바지",
                "timestamp": Timestamp(),
                "docId": "test2"
            ]
        ]
        
        mytableView.reloadData()
    
        fetchMyOutfits()
    }

//    func fetchMyOutfits() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        // 모든 데이터를 timestamp 순으로 정렬하여 가져오기
//        Firestore.firestore()
//            .collection("recommendations")
//            .order(by: "timestamp", descending: true)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ Error: \(error.localizedDescription)")
//                    return
//                }
//
//                let documents = snapshot?.documents ?? []
//                print("📊 조회된 전체 문서 개수: \(documents.count)")
//                
//                self.outfits = documents.map {
//                    $0.data().merging(["docId": $0.documentID]) { $1 }
//                }
//                
//                print("📦 outfits 배열 개수: \(self.outfits.count)")
//                
//                // 각 문서의 기본 정보 출력
//                for (index, outfit) in self.outfits.enumerated() {
//                    let location = outfit["location"] as? String ?? "위치없음"
//                    let top = outfit["top"] as? String ?? "상의없음"
//                    let uid = outfit["uid"] as? String ?? "UID없음"
//                    print("의상 \(index): \(location) - \(top) (UID: \(uid))")
//                }
//
//                DispatchQueue.main.async {
//                    print("🔄 메인 스레드에서 테이블뷰 리로드")
//                    self.mytableView.reloadData()
//                }
//            }
//    }
    func fetchMyOutfits() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ 현재 사용자 UID가 없습니다")
            return
        }
        
        print("🔍 현재 사용자 UID: \(uid)")
        
        Firestore.firestore()
            .collection("recommendations")
            .whereField("uid", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }
                
                let documents = snapshot?.documents ?? []
                print("📊 내 UID로 조회된 문서 개수: \(documents.count)")
                
                // 각 문서의 UID 확인
                for (index, doc) in documents.enumerated() {
                    let docUID = doc.data()["uid"] as? String ?? "UID없음"
                    print("문서 \(index) UID: \(docUID)")
                }
                
                self.outfits = documents.map {
                    $0.data().merging(["docId": $0.documentID]) { $1 }
                }
                
                DispatchQueue.main.async {
                    self.mytableView.reloadData()
                }
            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outfits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyOutfitCell", for: indexPath) as? MyOutfitCell else {
            return UITableViewCell()
        }

        let data = outfits[indexPath.row]

        cell.locationLabel.text = data["location"] as? String ?? "-"
        cell.topLabel.text = "상의: \(data["top"] as? String ?? "-")"
        cell.bottomLabel.text = "하의: \(data["bottom"] as? String ?? "-")"

        if let timestamp = data["timestamp"] as? Timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "yy.MM.dd HH:mm"
            cell.timeLabel.text = formatter.string(from: timestamp.dateValue())
        } else {
            cell.timeLabel.text = ""
        }

        return cell
    }

    // ✅ 상세보기로 이동
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = outfits[indexPath.row]
        let detail = selected["weatherDetail"] as? String ?? ""
        
        let temp = detail.slice(from: "🌡️ 현재 기온: ", to: "°C") ?? ""
        let humidity = detail.slice(from: "💧 습도: ", to: "%") ?? ""
        let wind = detail.slice(from: "💨 풍속: ", to: " m/s") ?? ""

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let recoVC = storyboard.instantiateViewController(withIdentifier: "RecommendationViewController") as? RecommendationViewController {
            recoVC.recommendation = (
                top: selected["top"] as? String ?? "",
                bottom: selected["bottom"] as? String ?? "",
                outer: selected["outer"] as? String ?? "",
                shoes: selected["shoes"] as? String ?? "",
                accessories: selected["accessories"] as? String ?? "",
                tips: selected["tips"] as? [String] ?? []
            )
            recoVC.weatherDetailText = detail
            recoVC.locationName = selected["location"] as? String ?? ""
            
            recoVC.temperature = "\(temp)°C"
            recoVC.humidity = "💧 습도: \(humidity)%"
            recoVC.windSpeed = "💨 풍속: \(wind) m/s"
            
            recoVC.modalPresentationStyle = .fullScreen
            self.present(recoVC, animated: true)
        }
    }

    // ✅ 삭제 기능
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedItem = outfits[indexPath.row]
            guard let docId = deletedItem["docId"] as? String else { return }

            Firestore.firestore().collection("recommendations").document(docId).delete { error in
                if let error = error {
                    print("❌ 삭제 실패: \(error.localizedDescription)")
                } else {
                    print("✅ 삭제 성공")
                    self.outfits.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
