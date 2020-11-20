//.ViewController.Swift

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManagar = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self //should be set before or it ends up crashing the app
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
        weatherManagar.delegate = self
        // Do any additional setup after loading the view.
        searchTextField.delegate = self // defines the return button
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    // to process the pressing of the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    // its usually used to validate
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != " " {
            return true
        } else {
            textField.placeholder = "Type Something"
            return false
        }
    }
    
    // to clear the text in the search field
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchTextField.text {
            weatherManagar.fetchWeather(cityName: city)
        }
        // use the searchTextField.text to get the weather
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelagate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather (_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
 
//MARK: - CLLocatinManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManagar.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
