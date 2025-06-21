//
//  CommunityTabViewController.swift
//  WearCast
//
//  Created by 최승재 on 6/22/25.
//


import UIKit
import FirebaseFirestore
import FirebaseAuth

class CommunityTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var allOutfits: [[String: Any]] = []
    var filteredOutfits: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

        fetchAllOutfits()
    }
    
    // 화면이 나타날 때마다 최신 데이터 가져오기
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            fetchAllOutfits()
        }

    func fetchAllOutfits() {
        let db = Firestore.firestore()
        db.collection("recommendations").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("🔥 오류 발생: \(error.localizedDescription)")
                return
            }

            self.allOutfits = snapshot?.documents.compactMap { $0.data() } ?? []
            self.filteredOutfits = self.allOutfits
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOutfits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCell", for: indexPath) as? CommunityCell else {
            return UITableViewCell()
        }

        let data = filteredOutfits[indexPath.row]
        cell.locationLabel.text = data["location"] as? String ?? "Unknown Location"

        func trimmedSummary(from text: String) -> String {
            let words = text.components(separatedBy: " ")
            let firstThree = words.prefix(3).joined(separator: " ")
            return "\(firstThree)…"
        }

        let topFull = data["top"] as? String ?? ""
        let bottomFull = data["bottom"] as? String ?? ""
        let topSummary = trimmedSummary(from: topFull)
        let bottomSummary = trimmedSummary(from: bottomFull)

        cell.summaryLabel.text = "상의: \(topFull)"
        cell.summaryLabel2.text = "하의: \(bottomFull)"


        if let timestamp = data["timestamp"] as? Timestamp {
            let date = timestamp.dateValue()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm"
            cell.timestampLabel.text = formatter.string(from: date)
        } else {
            cell.timestampLabel.text = ""
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = filteredOutfits[indexPath.row]
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

    // MARK: - Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredOutfits = allOutfits
        } else {
            filteredOutfits = allOutfits.filter {
                ($0["location"] as? String ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        tableView.reloadData()
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        guard let fromRange = range(of: from)?.upperBound else { return nil }
        guard let toRange = range(of: to, range: fromRange..<endIndex)?.lowerBound else { return nil }
        return String(self[fromRange..<toRange])
    }
}
