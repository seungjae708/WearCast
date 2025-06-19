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
        print("선택된 위치 위도: \(coordinate.latitude), 경도: \(coordinate.longitude)")
        // → 여기에 날씨 API 요청 추가하면 됨
    }
}
