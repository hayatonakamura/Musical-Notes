//
//  addBookViewController.swift
//  Musical Notes
//
//  Created by Hayato Nakamura on 2019/12/06.
//  Copyright © 2019 Hayatopia. All rights reserved.
//

import UIKit
import Foundation

class addBookViewController: UIViewController {
    
    // MARK: - Addbook
    struct Addbook: Codable {
        let count: Int
        let data: [Datum]
    }

    // MARK: - Datum
    struct Datum: Codable {
        let id, author, date, isbn: String
        let thumbnail: String
        let title: String

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case author, date, isbn, thumbnail, title
        }
    }

    @IBOutlet weak var addBook: UIButton!
    @IBOutlet weak var title_field: UITextField!
    @IBOutlet weak var author_field: UITextField!
    @IBOutlet weak var isbn_field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBook.layer.cornerRadius = 3
        addBook.clipsToBounds = true
    }
    
    @IBAction func add_book_pressed(_ sender: Any) {
        
        if (title_field.text == "" || author_field.text == "" || isbn_field.text == "" ) {
            let alert = UIAlertController(title: "", message: "Please fill in all the fields.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                // Handle your ok action
            }
            alert.addAction(okAction)

            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            guard let url = URL(string: "http://3.231.6.81:5000/currently_reading") else {return}
            var request = URLRequest(url: url)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let myString = formatter.string(from: Date())
            print(myString)
            
//            let yourDate = formatter.date(from: myString)
//            formatter.dateFormat = "dd-MMM-yyyy"
//            let myStringafd = formatter.string(from: yourDate!)
            
            let parameters: [String: Any] = [
                "title": title_field.text!,
                "author": author_field.text!,
                "date": myString,
                "isbn": isbn_field.text!
            ]
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let bookjson = try? JSONDecoder().decode(Addbook.self, from: data)
                let book_data = bookjson!.data
                
                DispatchQueue.main.async {
                    for book_info in book_data {
                        self.added_book_succ(title: book_info.title)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func added_book_succ(title: String) {
        let book_name = "Successfully added " + title + "!"
        let alert = UIAlertController(title: "", message: book_name, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            // Handle your ok action
        }
        alert.addAction(okAction)

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
            self.title_field.text = ""
            self.author_field.text = ""
            self.isbn_field.text = ""
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
