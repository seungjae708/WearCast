//
//  ViewController.swift
//  WearCast
//
//  Created by 최승재 on 6/16/25.
//

import UIKit
import CoreLocation

class HomeTabViewController: UIViewController, CLLocationManagerDelegate {

    // 위치 관련 객체
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    // 날씨 상세 데이터 보관용 변수
    var weatherDetailText: String = ""

    // 자동 위치 감지 on/off
    var isAutoLocationEnabled = true

    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var locationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isAutoLocationEnabled, let location = locations.last else { return }

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self?.locationLabel.text = city
                    self?.fetchWeatherInfo(for: location.coordinate)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 실패: \(error.localizedDescription)")
    }

    @IBAction func didTapLocationSelect(_ sender: Any) {
        print("지역 선택 눌림")
        performSegue(withIdentifier: "showLocationPicker", sender: nil)
    }
    
    @IBAction func didTapShowDetails(_ sender: UIButton) {
        let popupVC = WeatherDetailPopupViewController()
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.weatherSummary = self.weatherDetailText
            present(popupVC, animated: true)
    }
    @IBAction func didTapRecommend(_ sender: UIButton) {
        let preferenceVC = PreferencePopupViewController()
            preferenceVC.modalPresentationStyle = .overCurrentContext
            preferenceVC.modalTransitionStyle = .crossDissolve

            preferenceVC.preferenceSelectedHandler = { [weak self] selected in
                guard let self = self else { return }

                // 팝업 닫히는 걸 기다린 후 화면 전환
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let recoVC = storyboard.instantiateViewController(withIdentifier: "RecommendationViewController") as? RecommendationViewController {
                        
                        recoVC.temperature = self.temperatureLabel.text ?? ""
                        recoVC.humidity = self.humidityLabel.text ?? ""
                        recoVC.windSpeed = self.windSpeedLabel.text ?? ""
                        recoVC.weatherDetailText = self.weatherDetailText

                        // 💡 여기서 preference 데이터를 넘겨줌
                        recoVC.preference = selected

                        recoVC.modalPresentationStyle = .fullScreen
                        self.present(recoVC, animated: true)
                    }
                }
            }

            present(preferenceVC, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLocationPicker",
           let pickerVC = segue.destination as? LocationPickerViewController {

            pickerVC.selectedHandler = { [weak self] city, coordinate in
                self?.isAutoLocationEnabled = false
                self?.locationLabel.text = city.name
                self?.fetchWeatherInfo(for: coordinate)
            }
        }
        
        if segue.identifier == "showRecommendation",
           let destination = segue.destination as? RecommendationViewController {
            
            destination.temperature = temperatureLabel.text ?? ""
            destination.humidity = humidityLabel.text ?? ""
            destination.windSpeed = windSpeedLabel.text ?? ""
            
            // (선택) 더미 추천 데이터 전달
            destination.recommendation = (
                top: "얇은 니트",
                bottom: "청바지",
                outer: "가디건",
                shoes: "운동화",
                accessories: "헤어밴드",
                tips: [
                    "일교차가 있어 얇은 겉옷이 좋아요.",
                    "습도가 낮아 정전기 방지 제품이 필요해요.",
                    "바람이 있으니 모자를 추천해요."
                ]
            )
        }
    }

    func fetchWeatherInfo(for coordinate: CLLocationCoordinate2D) {
        let apiKey = "6f82acd7cbb472db29049a230b39d8b2" // 실제 API 키로 교체
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)"

        guard let url = URL(string: urlStr) else {
            print("잘못된 URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("네트워크 에러:", error?.localizedDescription ?? "Unknown")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let weatherArray = json["weather"] as? [[String: Any]],
                   let weather = weatherArray.first,
                   let icon = weather["icon"] as? String,
                   let main = json["main"] as? [String: Any],
                   let wind = json["wind"] as? [String: Any] {

                    let temp = (main["temp"] as? Double ?? 0.0) - 273.15
                    let humidity = main["humidity"] as? Double ?? 0.0
                    let windSpeed = wind["speed"] as? Double ?? 0.0

                    let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")!
                    let iconData = try Data(contentsOf: iconURL)
                    let image = UIImage(data: iconData)
                    
                    let feelsLike = (main["feels_like"] as? Double ?? 0.0) - 273.15
                    let tempMin = (main["temp_min"] as? Double ?? 0.0) - 273.15
                    let tempMax = (main["temp_max"] as? Double ?? 0.0) - 273.15
                    let pressure = main["pressure"] as? Int ?? 0
                    let cloudPercent = (json["clouds"] as? [String: Any])?["all"] as? Int ?? 0
                    let windDeg = wind["deg"] as? Int ?? 0
                    let rain = (json["rain"] as? [String: Any])?["1h"] as? Double ?? 0.0
                    let snow = (json["snow"] as? [String: Any])?["1h"] as? Double ?? 0.0

                    let sys = json["sys"] as? [String: Any]
                    let sunriseUnix = sys?["sunrise"] as? TimeInterval ?? 0
                    let sunsetUnix = sys?["sunset"] as? TimeInterval ?? 0

                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    dateFormatter.locale = Locale(identifier: "ko_KR")
                    let sunrise = dateFormatter.string(from: Date(timeIntervalSince1970: sunriseUnix))
                    let sunset = dateFormatter.string(from: Date(timeIntervalSince1970: sunsetUnix))

                    DispatchQueue.main.async {
                        self.weatherImageView?.image = image
                        self.temperatureLabel?.text = String(format: "%.1f°C", temp)
                        self.humidityLabel?.text = String(format: "💧 습도: %.0f%%", humidity)
                        self.windSpeedLabel?.text = String(format: "💨 풍속: %.1f m/s", windSpeed)
                        self.weatherDetailText = """
                        🌡️ 현재 기온: \(String(format: "%.1f°C", temp))
                        🥵 체감 온도: \(String(format: "%.1f°C", feelsLike))
                        
                        ⬆️ 최고: \(String(format: "%.1f°C", tempMax))      ⬇️ 최저: \(String(format: "%.1f°C", tempMin))

                        💧 습도: \(String(format: "%.0f%%", humidity))         ☁️ 구름: \(cloudPercent)%
                        🌧️ 강수: \(String(format: "%.1f", rain))mm       ❄️ 적설: \(String(format: "%.1f", snow))mm

                        💨 풍속: \(String(format: "%.1f m/s", windSpeed))     🧭 풍향: \(windDeg)°
                        📈 기압: \(pressure) hPa  

                        ☀️ 일출: \(sunrise)   🌙 일몰: \(sunset)
                        """
                    }
                }
            } catch {
                print("JSON 파싱 에러:", error)
            }
        }

        task.resume()
    }

}
