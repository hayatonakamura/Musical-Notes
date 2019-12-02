//
//  ViewController.swift
//  Musical Notes
//
//  Created by Hayato Nakamura on 2019/11/23.
//  Copyright © 2019 Hayatopia. All rights reserved.
//

import UIKit
import Charts
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var PieChart: PieChartView!
    
    var anger = PieChartDataEntry(value: 0, label: "Anger")
    var joy = PieChartDataEntry(value: 0, label: "Joy")
    var sorrow = PieChartDataEntry(value: 0, label: "Sorrow")
    var surprise = PieChartDataEntry(value: 0, label: "Surprise")
    var numdownloads = [PieChartDataEntry]()
    
    // MARK: - Cumulative
    struct Cumulative: Codable {
        let count: Int
        let data: [Datum]
    }

    // MARK: - Datum
    struct Datum: Codable {
        let bookID, bookTitle: String
        let emotionCount: Int
        let facialEmotions: FacialEmotions
        let textSentiments: TextSentiments

        enum CodingKeys: String, CodingKey {
            case bookID = "book_id"
            case bookTitle = "book_title"
            case emotionCount = "emotion_count"
            case facialEmotions = "facial_emotions"
            case textSentiments = "text_sentiments"
        }
    }

    // MARK: - FacialEmotions
    struct FacialEmotions: Codable {
        let anger, joy, sorrow, surprise: Double
    }

    // MARK: - TextSentiments
    struct TextSentiments: Codable {
        let anger, disgust, fear, joy: Double
        let sadness: Double
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // *** server connection ***
        guard let url = URL(string: "http://3.231.6.81:5000/cumulative_emotions") else {return}
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            //print(String(data: data, encoding: .utf8)!)
            let cumulative = try? JSONDecoder().decode(Cumulative.self, from: data)
            let cumu = cumulative!.data
            
            // Replace this later
            var ang = 0.0
            var joy = 0.0
            var sor = 0.0
            var sur = 0.0
            
            for book_info in cumu {
                let temp = book_info.facialEmotions
                ang = ang + temp.anger
                joy = joy + temp.joy
                sor = sor + temp.sorrow
                sur = sur + temp.surprise
            }
            DispatchQueue.main.async {
                self.PieChart.chartDescription?.text = ""
                self.anger.value =  ang
                self.joy.value = joy
                self.sorrow.value = sor
                self.surprise.value = sur
                self.numdownloads = [self.anger, self.joy, self.sorrow, self.surprise]
                self.update_chart()
            }
            
            
                    }
        task.resume()
        
        get_books()
    }
    
    func update_chart() {
        let chartDataSet = PieChartDataSet(entries: numdownloads, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let a_color = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        let j_color = #colorLiteral(red: 0.8711249232, green: 0.8718349934, blue: 0.03860105574, alpha: 1)
        let so_color = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        let ss_color = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        let colors = [a_color, j_color, so_color, ss_color]
        chartDataSet.colors = colors
        PieChart.data = chartData
    }
    
    func get_books() {
        guard let url = URL(string: "http://3.231.6.81:5000/cumulative_emotions") else {return}
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            //print(String(data: data, encoding: .utf8)!)
            let book = try? JSONDecoder().decode(Cumulative.self, from: data)
            print(book!.data)
            let a_books = book!.data
            
            DispatchQueue.main.async {
                var books: [String] = []
                var ids: [String] = []
                for book_title in a_books {
                    let temp_title = book_title.bookTitle
                    let temp_id = book_title.bookID
                    books.append(temp_title)
                    ids.append(temp_id)
                }
                let defaults = UserDefaults.standard
                defaults.set(books, forKey: "book_titles")
                defaults.set(ids, forKey: "book_ids")
            }
                                }
        task.resume()
    }


}

