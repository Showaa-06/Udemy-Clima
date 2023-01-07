//
//  WeatherManager.swift
//  Clima
//
//  Created by 鈴木彰悟 on 2022/12/24.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
   func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
   func didFailWithError(error: Error)
}


struct WeatherManager {
    let weaatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=646b7fa43aef8c10d86c067c73f0177f&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityname: String) {
        let urlString = "\(weaatherURL)&q=\(cityname)"
        //print(urlString)
        performRequest(with: urlString)
    }
    
    //CLLocationDegrees: latとlonそれぞれのデータの割り当て
    func fetchWeather(latitude: CLLocationDegrees, longitute: CLLocationDegrees) {
        let urlString = "\(weaatherURL)&lat=\(latitude)&lon=\(longitute)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        //1. Create a URL
        if let url = URL(string: urlString) {
            //2. Creat a URLSession
            //事実上ブラウザのようなもので、URLセッションオブジェクトを作成
            let session = URLSession(configuration: .default)
            //3. GIve the session task
            //指定されたURLの内容を取得し、完了後にハンドラまたはメソッドを呼び出すタスクを作成
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        //WeatherViewControllerへ戻す
                        //let weatherVC = WeatherViewController()
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    //データタスクから戻ってくるフォーマット
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            //コーディングした場所にこれを返す必要がある
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}




