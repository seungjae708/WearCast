//  LocationPickerViewController.swift
//  WearCast
import UIKit
import MapKit

class LocationPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!

    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    
    var cities: [City] = []

    var selectedHandler: ((City, CLLocationCoordinate2D) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
        locationTextField.delegate = self

        modeSegmentedControl.selectedSegmentIndex = 0
        updateInputMode()
        loadCityData()
        updateMapWithCity(at: 0)  // 첫 번째 도시를 기본 표시
    }
    
    
    @IBAction func modeSegmentChanged(_ sender: UISegmentedControl) {
        updateInputMode()
    }

    func updateInputMode() {
        let isTextMode = (modeSegmentedControl.selectedSegmentIndex == 1)

        pickerView.isHidden = isTextMode
        pickerView.isUserInteractionEnabled = !isTextMode
        locationTextField.isHidden = !isTextMode
        locationTextField.isUserInteractionEnabled = isTextMode

        if isTextMode {
            locationTextField.becomeFirstResponder()
        } else {
            locationTextField.resignFirstResponder()
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            updateMapWithCity(at: selectedRow)
        }
    }

    // Load JSON Data
    func loadCityData() {
        if let url = Bundle.main.url(forResource: "cityData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([City].self, from: data) {
            self.cities = decoded
        } else {
            print("도시 데이터 로딩 실패")
        }
    }

    // PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cities[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 피커뷰 모드일 때만 지도 업데이트
        if modeSegmentedControl.selectedSegmentIndex == 0 {
            updateMapWithCity(at: row)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let city = cities[row]
        
        // 기존 뷰 재사용 또는 새로 생성
        let containerView: UIView
        if let reusableView = view {
            containerView = reusableView
            // 기존 서브뷰들 제거
            containerView.subviews.forEach { $0.removeFromSuperview() }
        } else {
            containerView = UIView()
        }
        
        // 이미지뷰 설정
        let imageView = UIImageView()
        
        // 이미지 로딩 디버깅
        if let image = UIImage(named: city.imageName) {
            imageView.image = image
            print("이미지 로드 성공: \(city.imageName)")
        } else {
            print("이미지 로드 실패: \(city.imageName)")
            // 기본 이미지 설정 (선택사항)
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 이름 레이블 설정
        let nameLabel = UILabel()
        nameLabel.text = city.name
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 수직 스택뷰로 구성
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        
        // Auto Layout 제약 조건 설정
        NSLayoutConstraint.activate([
            // 스택뷰 제약조건
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -10),
            
            // 이미지뷰 크기 제약조건
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        return containerView
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 120
    }

    // TextField Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchAndDisplayLocation(named: textField.text)
        return true
    }
    
    // 텍스트필드 편집 중에도 실시간으로 검색하고 싶다면 이 메서드 추가
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // 타이핑 중에 실시간 검색 (선택사항)
        // searchAndDisplayLocation(named: textField.text)
    }

    // Map Handling
    func updateMapWithCity(at index: Int) {
        guard index < cities.count else { return }
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
                print("검색 실패: \(query)")
                // 검색 실패 시 사용자에게 알림 (선택사항)
                DispatchQueue.main.async {
                    self.showSearchFailAlert()
                }
            }
        }
    }
    
    // 검색 실패 알림 표시
    func showSearchFailAlert() {
        let alert = UIAlertController(title: "검색 실패",
                                    message: "입력하신 도시를 찾을 수 없습니다. 다시 시도해주세요.",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func centerMap(on coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
    }

    @IBAction func didTap(_ sender: Any) {
        print("버튼 눌림")
        
        let isTextMode = (modeSegmentedControl.selectedSegmentIndex == 1)
//        if modeSwitch.isOn {
        if isTextMode {
            // 텍스트 입력 모드인 경우
            guard let cityName = locationTextField.text, !cityName.isEmpty else {
                showAlert(message: "도시 이름을 입력해주세요.")
                return
            }
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(cityName) { placemarks, error in
                if let coordinate = placemarks?.first?.location?.coordinate {
                    // 임시 City 객체 생성 (텍스트 입력용)
                    let customCity = City(
                        id: -1, // 사용자 입력 도시용 특별한 ID
                        name: cityName,
                        country: "Unknown", // 또는 검색 결과에서 국가 정보 추출
                        description: "사용자 입력 도시",
                        imageName: "default_city"
                    )
                    self.selectedHandler?(customCity, coordinate)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(message: "입력하신 도시의 위치를 찾을 수 없습니다.")
                    }
                }
            }
        } else {
            // 피커뷰 모드인 경우
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            let city = cities[selectedRow]
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(city.name) { placemarks, error in
                if let coordinate = placemarks?.first?.location?.coordinate {
                    self.selectedHandler?(city, coordinate)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                } else {
                    print("위치 좌표 찾기 실패")
                }
            }
        }
    }
    
    // 알림 표시 헬퍼 메서드
    func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
