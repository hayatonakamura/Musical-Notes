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
import UICircularProgressRing


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
        let day2, day3: Double
        let day4: Double
        let day5, day6: Double
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
    @IBOutlet weak var goalChart: HorizontalBarChartView!
    @IBOutlet weak var progressRing: UICircularProgressRing!
    @IBOutlet weak var welcome_text: UILabel!
    @IBOutlet weak var current_goal_label: UILabel!
    @IBOutlet weak var change_goal_button: UIButton!
    
    // Change any of the properties you'd like
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update_text()
        update_weekly_time()
        update_goal()
        
        // Button customization
        change_goal_button.layer.cornerRadius = 3
        change_goal_button.clipsToBounds = true
             
        // Checking if user set goals already
        if (isKeyPresentInUserDefaults(key: "goal") == false) {
            let defaults = UserDefaults.standard
            defaults.set(3, forKey: "goal")
        }
        
        let goal: Double = UserDefaults.standard.double(forKey: "goal")
        current_goal_label.text = "Current Goal: " + String(goal) + " hours"
        
        // Progress Ring bar
        self.progressRing.minValue = 0
        self.progressRing.maxValue = 100
        
        // Timer
        let timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { timer in
            self.refresh()
            print("Timer Activated")
        })
        
        //UserDefaults.standard.double(forKey: "goal")
        let update_timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            if (self.isKeyPresentInUserDefaults(key: "should_reload") == true) {
            let should_update = UserDefaults.standard.bool(forKey: "should_reload")
                if (should_update == true) {
                    self.refresh()
                    let defaults = UserDefaults.standard
                    defaults.set(false, forKey: "should_reload")
                }
            }
            
        })
        
        // Do any additional setup after loading the view.
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func update_text(){
        let u = "http://3.231.6.81:5000/time_by_days"
        guard let url = URL(string: u) else {return}
               let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                   guard let data = data else { return }
                   //print(String(data: data, encoding: .utf8)!)
                   let book = try? JSONDecoder().decode(Readingtimes.self, from: data)
                
                let total_hours = (book!.totalTimeInHours)
                let defaults = UserDefaults.standard
                defaults.set(total_hours, forKey: "hours")
                let new_total_hours = String(format: "%.2f", total_hours)
                                
                   DispatchQueue.main.async {
                    self.welcome_text.text = "You have read " + new_total_hours + " hours this week."
                   }
                }
               task.resume()
    }
    
    func test_ring(){
        let goal: Double = UserDefaults.standard.double(forKey: "goal")
        let hours: Double = UserDefaults.standard.double(forKey: "hours")
        
        let progress = Int((hours/goal)*100)
        self.progressRing.innerRingColor = #colorLiteral(red: 1, green: 0, blue: 0.3303074837, alpha: 1)
        self.progressRing.startProgress(to: CGFloat(progress), duration: 2.0) {
          print("Done animating!")
          // Do anything your heart desires...
        }
    }
    
    func update_goal() {
        
        let goal: Double = UserDefaults.standard.double(forKey: "goal")
        
        self.goalChart.drawBarShadowEnabled = true
        self.goalChart.drawValueAboveBarEnabled = true
        self.goalChart.maxVisibleCount = Int(goal)
        self.goalChart.rightAxis.axisMaximum = goal
        self.goalChart.leftAxis.axisMaximum = goal
                
        let xAxis  = self.goalChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 10.0
        
        let leftAxis = self.goalChart.leftAxis;
        leftAxis.drawAxisLineEnabled = false;
        leftAxis.drawGridLinesEnabled = true;
        leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        leftAxis.enabled = false
        
        let rightAxis = self.goalChart.rightAxis
        rightAxis.enabled = true;
        rightAxis.drawAxisLineEnabled = false;
        rightAxis.drawGridLinesEnabled = true;
        rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        
        let l = self.goalChart.legend
        l.enabled =  false
        goalChart.fitBars = true;
        self.goalChart.animate(xAxisDuration: 2, yAxisDuration: 2)
        setDataCount()
    }
    
    
    func setDataCount(){
        
        let hours: Double = UserDefaults.standard.double(forKey: "hours")
        
        let barWidth = 0.6
        var yVals = [BarChartDataEntry]()
        yVals.append(BarChartDataEntry(x: Double(1.0), y: hours))
        var set1 : BarChartDataSet!
        set1 = BarChartDataSet(entries: yVals, label: "DataSet")
        var dataSets = [BarChartDataSet]()
        dataSets.append(set1)
        let data = BarChartData(dataSets: dataSets)
        data.barWidth =  barWidth;
        goalChart.data = data
    
    }
    
    func update_weekly_time() {
        let u = "http://3.231.6.81:5000/time_by_days"
        guard let url = URL(string: u) else {return}
               let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                   guard let data = data else { return }
                   //print(String(data: data, encoding: .utf8)!)
                   let book = try? JSONDecoder().decode(Readingtimes.self, from: data)
                
                let day1 = Double(book!.readingTimes.day1)
                let day2 = Double(book!.readingTimes.day2)
                let day3 = Double(book!.readingTimes.day3)
                let day4 = Double(book!.readingTimes.day4)
                let day5 = Double(book!.readingTimes.day5)
                let day6 = Double(book!.readingTimes.day6)
                let day7 = Double(book!.readingTimes.day7)
                
                                
                   DispatchQueue.main.async {
                    let x = [day1, day2, day3, day4, day5, day6, day7]
                    print(x)
                    self.lineChart.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    self.lineChart.translatesAutoresizingMaskIntoConstraints = false
                    var dataEntries: [ChartDataEntry] = []
                    // Get the last 7 days as Strings
                    let cal = Calendar.current
                    var date = cal.startOfDay(for: Date())
                    var days = [String]()
                    for i in 1 ... 7 {
                        let day = cal.component(.day, from: date)
                        let month = cal.component(.month, from: date)
                        let comb = String(month) + "/" + String(day)
                        days.insert(comb, at: 0)
                        date = cal.date(byAdding: .day, value: -1, to: date)!
                    }
                    
                    self.lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
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
                    self.lineChart.rightAxis.drawGridLinesEnabled = false
                    self.lineChart.animate(xAxisDuration: 2, yAxisDuration: 2)
                    let gradientColors = [UIColor.gray.cgColor, UIColor.clear.cgColor] as CFArray
                    let colorLocations: [CGFloat] = [1.0, 0.0]
                    guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) else {print ("gradient error"); return }
                    lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
                    lineChartDataSet.drawFilledEnabled = true
                    
                    self.test_ring()
                   }
                }
               task.resume()
    }
    
    @IBAction func refresh_pressed(_ sender: Any) {
        print("refresh pressed")
        update_weekly_time()
        DispatchQueue.main.async {
            self.progressRing.resetProgress()
        }
        test_ring()
        update_goal()
        let goal: Double = UserDefaults.standard.double(forKey: "goal")
        self.current_goal_label.text = "Current Goal: " + String(goal) + " hours"
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func refresh(){
        update_weekly_time()
        DispatchQueue.main.async {
            self.progressRing.resetProgress()
        }
        test_ring()
        update_goal()
        let goal: Double = UserDefaults.standard.double(forKey: "goal")
        self.current_goal_label.text = "Current Goal: " + String(goal) + " hours"
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
