//
//  AnalyticsViewController.swift
//  
//
//  Created by Hayato Nakamura on 2019/11/25.
//

import UIKit
import Charts
import Foundation

// MARK: - BookInfo
struct BookInfo: Codable {
    let count: Int
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let id, bookID, date: String
    let facialEmotions: FacialEmotions
    let text: String
    let textSentiments: TextSentiments

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case bookID = "book_id"
        case date
        case facialEmotions = "facial_emotions"
        case text
        case textSentiments = "text_sentiments"
    }
}

// MARK: - FacialEmotions
struct FacialEmotions: Codable {
    let anger, joy, sorrow, surprise: Int
}

// MARK: - TextSentiments
struct TextSentiments: Codable {
    let anger, disgust, fear, joy: Double
    let sadness: Double
}
var books = UserDefaults.standard.array(forKey: "book_titles")!
var ids = UserDefaults.standard.array(forKey: "book_ids")!


class AnalyticsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var bar_chart: BarChartView!
    @IBOutlet weak var FE_bar_char: BarChartView!
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (books[row] as! String)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return books.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        update_chart(selected_ele: ids[row] as! String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        update_chart(selected_ele: ids[0] as! String)
    }
    
    func update_chart(selected_ele: String) {

        let u = "http://3.231.6.81:5000/emotions/" + selected_ele
        guard let url = URL(string: u) else {return}
               let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                   guard let data = data else { return }
                   //print(String(data: data, encoding: .utf8)!)
                   let book = try? JSONDecoder().decode(BookInfo.self, from: data)
                   print(book!.data)
                   let book_data = book!.data
                    var ang = 0.0
                    var dis = 0.0
                    var fear = 0.0
                    var joy = 0.0
                    var sad = 0.0
                
                    var f_ang = 0
                    var f_sor = 0
                    var f_sur = 0
                    var f_joy = 0
                for emotion_info in book_data {
                     let temp_facial = emotion_info.facialEmotions
                     let temp_text = emotion_info.textSentiments
                        ang += temp_text.anger
                        dis += temp_text.disgust
                        fear += temp_text.fear
                        joy += temp_text.joy
                        sad += temp_text.sadness
                    
                        f_ang += temp_facial.anger
                        f_sor += temp_facial.sorrow
                        f_sur += temp_facial.surprise
                        f_joy += temp_facial.joy
                }
                   
                   DispatchQueue.main.async {
                    let emotions_text = ["anger", "disgust", "fear", "joy", "sadness"]
                    let vals = [ang, dis, fear, joy, sad]
                    self.bar_chart.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    self.bar_chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
                    self.setChart_text(dataPoints: emotions_text, values: vals)
                    
                    let emotions_face = ["anger", "sorrow", "surprise", "joy"]
                    let vals_face = [f_ang, f_sor, f_sur, f_joy]
                    self.FE_bar_char.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    self.FE_bar_char.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
                    self.setChart_face(dataPoints: emotions_face, values: vals_face)
                    
                   }
                                       }
               task.resume()
        
    }
    
    func setChart_text(dataPoints: [String], values: [Double]) {
        
        bar_chart.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
            
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Text Sentiment Level")
        let chartData = BarChartData(dataSet: chartDataSet)
        bar_chart.leftAxis.enabled = false
        bar_chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        bar_chart.xAxis.granularityEnabled = true
        bar_chart.xAxis.labelPosition = .bottom
        
        chartDataSet.colors = [UIColor(red: 10/255, green: 126/255, blue: 200/255, alpha: 1)]
        bar_chart.data = chartData
    }
    
    func setChart_face(dataPoints: [String], values: [Int]) {
        
        FE_bar_char.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
            
        }
        
        FE_bar_char.leftAxis.enabled = false
        //FE_bar_char.rightAxis.enabled = false
        //FE_bar_char.xAxis.enabled = false
        
        FE_bar_char.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        FE_bar_char.xAxis.granularityEnabled = true
        FE_bar_char.xAxis.labelPosition = .bottom
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Facial Emotion Level")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartDataSet.colors = [UIColor(red: 200/255, green: 50/255, blue: 90/255, alpha: 1)]
        FE_bar_char.data = chartData
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
