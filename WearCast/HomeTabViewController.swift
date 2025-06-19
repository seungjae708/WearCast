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
        print("✅ 지역 선택 눌림")
        performSegue(withIdentifier: "showLocationPicker", sender: nil)
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
    }

    func fetchWeatherInfo(for coordinate: CLLocationCoordinate2D) {
        let apiKey = "6f82acd7cbb472db29049a230b39d8b2" // 실제 API 키로 교체
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)"

        guard let url = URL(string: urlStr) else {
            print("❌ 잘못된 URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ 네트워크 에러:", error?.localizedDescription ?? "Unknown")
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

                    DispatchQueue.main.async {
                        self.weatherImageView?.image = image
                        self.temperatureLabel?.text = String(format: "%.1f°C", temp)
                        self.humidityLabel?.text = String(format: "습도: %.0f%%", humidity)
                        self.windSpeedLabel?.text = String(format: "풍속: %.1f m/s", windSpeed)
                    }
                }
            } catch {
                print("❌ JSON 파싱 에러:", error)
            }
        }

        task.resume()
    }

}
