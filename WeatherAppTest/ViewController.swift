//
//  ViewController.swift
//  WeatherAppTest
//
//  Created by Артём Коротков on 24.08.2022.
//

import UIKit
import CoreLocation


class ViewController: UIViewController {
    
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var weatherDescription: UILabel!
    @IBOutlet var temperature: UILabel!
    @IBOutlet var weatherIconImageView: UIImageView!
    @IBOutlet var humidity: UILabel!
    @IBOutlet var pressure: UILabel!
    
    
    
    //get coordinate where we are
    let locationManager = CLLocationManager()
    var weatherData = WeatherData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLocationManager()
    }
    
    func updateView() {
        cityNameLabel.text = weatherData.name
        weatherDescription.text = DataSource.weatherIDs[weatherData.weather[0].id]
        temperature.text = weatherData.main.temp.description + "ºC"
        weatherIconImageView.image = UIImage(named: weatherData.weather[0].icon)
        humidity.text = "\(weatherData.main.humidity)mm"
        pressure.text = "\(weatherData.main.pressure)%"
    }
    
    func startLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateWeatherInfoWith(latitude: Double, longtitude: Double) {
        let session = URLSession.shared
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longtitude.description)&appid=1841d2c1d4c3ab05578d22ddcfe63ea6&units=metric&lang=ru")
        let task = session.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                print(error!)
                //alert
                return
            }
            do {
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                DispatchQueue.main.async {
                    self.updateView()
                }
            } catch {
                //alert
                print(error)
            }
        }
        task.resume()
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            updateWeatherInfoWith(latitude: lastLocation.coordinate.latitude, longtitude: lastLocation.coordinate.longitude)
        }
        
    }
}
