//  LocationPickerViewController.swift
//  WearCast
import UIKit
import MapKit

class LocationPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!

    var cities: [City] = []

    var selectedHandler: ((City, CLLocationCoordinate2D) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
        locationTextField.delegate = self

        loadCityData()
        updateMapWithCity(at: 0)  // 첫 번째 도시를 기본 표시
    }

    // MARK: - Load JSON Data
    func loadCityData() {
        if let url = Bundle.main.url(forResource: "cityData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([City].self, from: data) {
            self.cities = decoded
        } else {
            print("도시 데이터 로딩 실패")
        }
    }

    // MARK: - PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cities[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateMapWithCity(at: row)
    }

    // MARK: - TextField Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchAndDisplayLocation(named: textField.text)
        return true
    }

    // MARK: - Map Handling
    func updateMapWithCity(at index: Int) {
        let city = cities[index]
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city.name) { placemarks, error in
            if let location = placemarks?.first?.location {
                self.centerMap(on: location.coordinate)
            }
        }
    }

    func searchAndDisplayLocation(named name: String?) {
        guard let query = name, !query.isEmpty else { return }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { placemarks, error in
            if let location = placemarks?.first?.location {
                self.centerMap(on: location.coordinate)
            } else {
                print("검색 실패")
            }
        }
    }

    func centerMap(on coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
    }

    @IBAction func didTap(_ sender: Any) {
        print("✅ 버튼 눌림")
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let city = cities[selectedRow]
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city.name) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                self.selectedHandler?(city, coordinate)
                DispatchQueue.main.async {
                    self.dismiss(animated: true)  // ✅ 이거로 고쳐야 화면 닫힘
                }
            } else {
                print("위치 좌표 찾기 실패")
            }
        }
    }
}
