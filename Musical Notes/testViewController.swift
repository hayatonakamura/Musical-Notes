//
//  testViewController.swift
//  Musical Notes
//
//  Created by Hayato Nakamura on 2019/12/07.
//  Copyright © 2019 Hayatopia. All rights reserved.
//

import UIKit
import SwiftUICharts

class testViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen") // legend is optional, use optional .padding()


        // Do any additional setup after loading the view.
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
