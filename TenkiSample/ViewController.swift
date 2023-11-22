//
//  ViewController.swift
//  TenkiSample
//
//  Created by Mina on 2023/11/12.
//

import UIKit

struct WeatherModel: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let hourlyUnits: HourlyUnits

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case generationtimeMs = "generationtime_ms"
        case hourlyUnits = "hourly_units"
    }
}

struct HourlyUnits: Decodable {
    let time: String
    let temperature2m: String

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TimeZoneはAsia/Tokyo しかないので、緯度と経度のパラメータだけ変更する
        let url: URL = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=35.6785&longitude=139.6823&hourly=temperature_2m&timezone=Asia%2FTokyo")!

        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            guard let data = data else { return }

            do {
                let model = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.async {
                    self.latitudeLabel.text = String(model.latitude)
                    self.longitudeLabel.text = String(model.longitude)
                }
            } catch {
                print("error: \(error)")
            }
        })
        // セッションタスクを開始しデータを取得し、UIを更新
        task.resume()
    }

    // 天気データを更新するメソッド
    func updateWeatherData(latitude: String, longitude: String) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m&timezone=Asia%2FTokyo"
        guard let url = URL(string: urlString) else { return }

        // トレイリングクロージャの書き方(引数のクロージャを()の外に記述する方法)
        // 関数の最後の引数がクロージャの場合、引数名を省略できる。→completionHandler を省略した
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.latitudeLabel.text = latitude
                self.longitudeLabel.text = longitude
            }
        }
        task.resume()
    }

    
    @IBAction func next(_ sender: UIStoryboardSegue) {
        print("next")
        self.performSegue(withIdentifier: "next", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next" {
            if let nextVC = segue.destination as? NextViewController {
                nextVC.delegate = self
            }
        }
    }
}

extension ViewController: PrefectureSelectDelegate {
    func didSelectPrefecture(name: String, latitude: Double, longitude: Double) {
        prefectureLabel.text = name
        updateWeatherData(latitude: String(latitude), longitude: String(longitude))
    }
}
