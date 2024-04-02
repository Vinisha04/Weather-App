//
//  ViewController.swift
//  Asiignment 8
//
//  Created by user240738 on 3/31/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{
   
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var windLabel: UILabel!
    
    
    let apiKey = "e7cd87ec7049c2fd8ca82ab7aed1868b"
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        fetchWeatherData(for: location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //handleError(error)
    }

    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        print("Printing inside the fetchWeatherData")
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&exclude=hourly,daily&appid=\(apiKey)") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("oops !!! Its an Error")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//
                return
            }

            guard let data = data else {
//
                return
            }

            self.parseWeatherData(data)
        }

        task.resume()
    }

    func parseWeatherData(_ data: Data) {
        do {
            let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            updateUI(with: weatherData)
        } catch {
        
        }
    }

    func updateUI(with weatherData: WeatherData) {
        print("logging weather Data", weatherData);
        DispatchQueue.main.async {
            self.locationLabel.text = weatherData.name
            self.descriptionLabel.text = weatherData.weather.first?.description
            self.weatherImageView.image = UIImage(named: weatherData.weather.first?.icon ?? "")
            let temperatureInCelsius = weatherData.main.temp - 273.15
            self.temperature.text = "\(Int(temperatureInCelsius))°C"
            self.humidityLabel.text = "\(weatherData.main.humidity)%"
            self.windLabel.text = "\(Int(weatherData.wind.speed)) m/s"
            
            if let weatherIconCode = weatherData.weather.first?.icon {
                self.fetchWeatherIcon(with: weatherIconCode) { image in
                    DispatchQueue.main.async {
                        self.weatherImageView.image = image
                    }
                }
            }
        }
        
    }
    func fetchWeatherIcon(with iconCode: String, completion: @escaping (UIImage?) -> Void) {
        let imageUrlString = "https://api.openweathermap.org/img/w/\(iconCode).png"
        guard let url = URL(string: imageUrlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                completion(nil)
                return
            }

            completion(image)
        }

        task.resume()
    }


}

