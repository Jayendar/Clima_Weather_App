

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather (_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=3c175b2d26ea689d0b3e4702b730d6ad&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather (cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
        
    }
    
    func performRequest(urlString: String) {
        //1. create a url
        
        if let url = URL(string: urlString) {
            //2. create a urlsession
            let session = URLSession(configuration: .default) // this essentially performs the url like the browser used to perform the networking
            
            //3. give the url session a task
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return // exit the function
                }
                 
                if let safeData = data {
                    
                    if let weather = self.parseJSON(safeData) {
                        // Optional Binding
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
//                    let dataString = String(data: safeData, encoding: .utf8)
//                    print(dataString)
                }
            }
            
            //4. start the task
            
            task.resume() // resume() - the task is usually in a suspended state
            
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            //            print(decodedData.main.temp)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
