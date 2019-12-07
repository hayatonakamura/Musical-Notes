//
//  timeReadViewController.swift
//  Musical Notes
//
//  Created by Hayato Nakamura on 2019/12/06.
//  Copyright © 2019 Hayatopia. All rights reserved.
//

import UIKit
import Charts
import Foundation
import AudioToolbox


class timeReadViewController: UIViewController {
    
    // MARK: - Readingtimes
    struct Readingtimes: Codable {
        let intervalEnd, intervalStart: String
        let readingTimes: ReadingTimes
        let totalTimeInHours: Double
        let totalTimeInSeconds: Int

        enum CodingKeys: String, CodingKey {
            case intervalEnd = "interval_end"
            case intervalStart = "interval_start"
            case readingTimes = "reading_times"
            case totalTimeInHours = "total_time_in_hours"
            case totalTimeInSeconds = "total_time_in_seconds"
        }
    }

    // MARK: - ReadingTimes
    struct ReadingTimes: Codable {
        let day1: Double
        let day2, day3: Int
        let day4: Double
        let day5, day6: Int
        let day7: Double

        enum CodingKeys: String, CodingKey {
            case day1 = "day_1"
            case day2 = "day_2"
            case day3 = "day_3"
            case day4 = "day_4"
            case day5 = "day_5"
            case day6 = "day_6"
            case day7 = "day_7"
        }
    }


    @IBOutlet weak var lineChart: LineChartView!
    
    var lineChartEntry: [ChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update_weekly_time()
        
        // Do any additional setup after loading the view.
    }
    
    func update_weekly_time(){
        let u = "http://3.231.6.81:5000/time_by_days"
        guard let url = URL(string: u) else {return}
               let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                   guard let data = data else { return }
                   //print(String(data: data, encoding: .utf8)!)
                   let book = try? JSONDecoder().decode(Readingtimes.self, from: data)
                
                let day1:Double = book!.readingTimes.day1
                let day2:Double = Double(book!.readingTimes.day2)
                let day3:Double = Double(book!.readingTimes.day3)
                let day4:Double = book!.readingTimes.day4
                let day5:Double = Double(book!.readingTimes.day5)
                let day6:Double = Double(book!.readingTimes.day6)
                let day7:Double = Double(book!.readingTimes.day7)
                
                
                    print(day1)
                
                   DispatchQueue.main.async {
                    let x = [day1, day2, day3, day4, day5, day6, day7] as! [Double]
                    let d = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
                    print(x)
                    self.lineChart.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    self.lineChart.translatesAutoresizingMaskIntoConstraints = false
                    var dataEntries: [ChartDataEntry] = []
                    self.lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"])
                    self.lineChart.xAxis.granularity = 1
                    for i in 0..<x.count {
                        let dataEntry = ChartDataEntry(x: Double(i), y: Double(x[i]))
                      dataEntries.append(dataEntry)
                    }
                    let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "Reading Hours")
                    let lineChartData = LineChartData(dataSet: lineChartDataSet)
                    self.lineChart.leftAxis.enabled = false
                    self.lineChart.xAxis.granularityEnabled = true
                    self.lineChart.xAxis.labelPosition = .bottom
                    self.lineChart.data = lineChartData
                    self.lineChart.leftAxis.drawGridLinesEnabled = false
                    self.lineChart.xAxis.drawGridLinesEnabled = false
                    self.lineChart.animate(xAxisDuration: 1, yAxisDuration: 1)
                    let gradientColors = [UIColor.gray.cgColor, UIColor.clear.cgColor] as CFArray
                    let colorLocations: [CGFloat] = [1.0, 0.0]
                    guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) else {print ("gradient error"); return }
                    lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
                    lineChartDataSet.drawFilledEnabled = true
                   }
                }
               task.resume()
    }
    
    @IBAction func refresh_pressed(_ sender: Any) {
        print("refresh pressed")
        update_weekly_time()
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
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
