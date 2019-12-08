//
//  changeGoalViewController.swift
//  
//
//  Created by Hayato Nakamura on 2019/12/07.
//

import UIKit

class changeGoalViewController: UIViewController {

    @IBOutlet weak var current_goal_label: UILabel!
    @IBOutlet weak var update_button: UIButton!
    @IBOutlet weak var new_goal_field: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Button customization
        update_button.layer.cornerRadius = 3
        update_button.clipsToBounds = true
        
        if (isKeyPresentInUserDefaults(key: "goal") == false) {
            let defaults = UserDefaults.standard
            defaults.set(3, forKey: "goal")
        }
        
        let goal: Double = UserDefaults.standard.double(forKey: "goal")
        current_goal_label.text = "Current Goal:      " + String(goal) + " hours"
        
        
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    @IBAction func update_button_pressed(_ sender: Any) {
        if (new_goal_field.text == "") {
            let alert = UIAlertController(title: "", message: "Please enter a value.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                // Handle your ok action
            }
            alert.addAction(okAction)

            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            let new_goal = Double(new_goal_field.text!)
            let string_new_goal = new_goal_field.text
            let defaults = UserDefaults.standard
            defaults.set(new_goal, forKey: "goal")
            defaults.set(true, forKey: "should_reload")
            added_book_succ(goal: string_new_goal!)
        }
    }
    
    func added_book_succ(goal: String) {
        let book_name = "Goal updated to " + goal + "!"
        let alert = UIAlertController(title: "", message: book_name, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            // Handle your ok action
        }
        alert.addAction(okAction)

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
            self.new_goal_field.text = ""
            let goal: Double = UserDefaults.standard.double(forKey: "goal")
            self.current_goal_label.text = "Current Goal:      " + String(goal) + " hours"
        }
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
