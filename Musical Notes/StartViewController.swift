//
//  StartViewController.swift
//  Musical Notes
//
//  Created by Hayato Nakamura on 2019/11/25.
//  Copyright © 2019 Hayatopia. All rights reserved.
//

import UIKit
import Foundation

class StartViewController: UIViewController {
    
    // MARK: - BookInfo
    struct BookInfo: Codable {
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
    
    // MARK: - Current
    struct Current: Codable {
        let count: Int
        let data: [Datumn]
    }

    // MARK: - Datumn
    struct Datumn: Codable {
        let id, author, date, isbn: String
        let thumbnail: String
        let title: String

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case author, date, isbn, thumbnail, title
        }
    }

    
    var book_list: [String] = []

    
    @IBOutlet weak var other_book_1: UIButton!
    @IBOutlet weak var other_book_2: UIButton!
    @IBOutlet weak var other_book_3: UIButton!
    
    @IBOutlet weak var temp_button: UIButton!
    @IBOutlet weak var status_label: UILabel!
    @IBOutlet weak var author_label: UILabel!
    @IBOutlet weak var isbn_label: UILabel!
    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var item_bar: UITabBarItem!
    @IBOutlet weak var make_current_button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Whenever the book button is pressed --> switch with the current one
            // Call the udpate_current_label function
        
        // Book Name:
        // Author:
        // ISPN #:
        // Status:
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: "i")
        
        initialize()
        
        make_current_button.layer.cornerRadius = 3
        make_current_button.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    
    func initialize(){
        self.make_current_button.isHidden = true
        initialize_current()
        update_other_book(action: "start")
    }
    
    func get_book_info() {
        // *** server connection ***
        guard let url = URL(string: "http://3.231.6.81:5000/books") else {return}
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            //print(String(data: data, encoding: .utf8)!)
            let bookjson = try? JSONDecoder().decode(BookInfo.self, from: data)
            let book_data = bookjson!.data
            let defaults = UserDefaults.standard
            DispatchQueue.main.async {
               for book_info in book_data {
                   self.book_list.append(book_info.title)
               }
                defaults.set(self.book_list, forKey: "book_list")
                
            }
        }
        task.resume()
    }
    
    // MARK: GET CURRENT BOOK
    func initialize_current() {
        // *** server connection ***
        guard let url = URL(string: "http://3.231.6.81:5000/currently_reading") else {return}
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            //print(String(data: data, encoding: .utf8)!)
            let bookjson = try? JSONDecoder().decode(Current.self, from: data)
            let book_data = bookjson!.data
            
            DispatchQueue.main.async {
                for book_info in book_data {
                    let url = book_info.thumbnail
                    let id = book_info.id
                    let book_title = book_info.title
                    let isbn = book_info.isbn
                    let author = book_info.author
                    let u = URL(string: url)
                    let data = try? Data(contentsOf: u!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    self.temp_button.setBackgroundImage(UIImage(data: data!), for: .normal)
                    let defaults = UserDefaults.standard
                    defaults.set(author, forKey: "current_author")
                    defaults.set(isbn, forKey: "current_isbn")
                    defaults.set(book_title, forKey: "current_title")
                    defaults.set(id, forKey: "current_id")
                    self.update_current_label()
                    
                }
            }
                    }
        task.resume()
    }
    
    
    func compare_current_book(is_this_current: String){
        guard let url = URL(string: "http://3.231.6.81:5000/currently_reading") else {return}
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let bookjson = try? JSONDecoder().decode(Current.self, from: data)
            let book_data = bookjson!.data
            DispatchQueue.main.async {
                for book_info in book_data {
                    let book_title = book_info.title
                    if book_title == is_this_current {
                        self.status_label.text = "Current Book"
                        self.make_current_button.isHidden = true
                        print("Compared: This is the current book")
                    }
                    else {
                        self.status_label.text = "Not Reading"
                        self.make_current_button.isHidden = false
                        print("Compared: This is NOT the current book")
                    }
                }
            }
                    }
        task.resume()
        
    }
    
    
    // MARK: SEARCH BOOK
    func search_book(name: String) {
        guard let url = URL(string: "http://3.231.6.81:5000/books/search") else {return}
        var request = URLRequest(url: url)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "title": name
        ]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let bookjson = try? JSONDecoder().decode(Current.self, from: data)
            let book_data = bookjson!.data
            
            DispatchQueue.main.async {
                
            }
        }
        task.resume()
    }
    
    
    // MARK: UPDATE CURRENT LABEL
    func update_current_label() {
        //var books = UserDefaults.standard.array(forKey: "book_titles")!
        self.author_label.text = UserDefaults.standard.string(forKey: "current_author")!
        self.title_label.text = UserDefaults.standard.string(forKey: "current_title")
        self.isbn_label.text = UserDefaults.standard.string(forKey: "current_isbn")
        self.status_label.text = "Current Book"
    }
    
    
    
    func get_url(title: String) {
        guard let url = URL(string: "http://3.231.6.81:5000/books/search") else {return }
        var request = URLRequest(url: url)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "title": title
        ]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let bookjson = try? JSONDecoder().decode(Current.self, from: data)
            let book_data = bookjson!.data
            let defaults = UserDefaults.standard
            
            DispatchQueue.main.async {
                for book_info in book_data {
                    defaults.set(book_info.thumbnail, forKey: "get_url_result")
                }
                }
        }
        task.resume()
    }
    
    
    func update_other_book(action: String) {
        // action: "start", "next", "prev"
        
        var temp:[String] = []
        guard let url = URL(string: "http://3.231.6.81:5000/books") else {return}
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            //print(String(data: data, encoding: .utf8)!)
            let bookjson = try? JSONDecoder().decode(BookInfo.self, from: data)
            let book_data = bookjson!.data
            DispatchQueue.main.async {
               for book_info in book_data {
                   temp.append(book_info.title)
               }
                
                print("book list")
                print(temp)
                let curr_title = UserDefaults.standard.string(forKey: "current_title")!
                if let i = temp.firstIndex(of: curr_title) {
                    temp.remove(at: i)
                }
                
                if action == "start" {
                    let defaults = UserDefaults.standard
                    defaults.set(0, forKey: "i")
                    let i = 0
                    self.change_three_books(temp: temp, i: i)
                    
                }
                else if action == "next" {
                    let defaults = UserDefaults.standard
                    var i = UserDefaults.standard.integer(forKey: "i")
                    i += 3
                    defaults.set(i, forKey: "i")
                    self.change_three_books(temp: temp, i: i)
                    
                }
                else if action == "prev" {
                    let defaults = UserDefaults.standard
                    var i = UserDefaults.standard.integer(forKey: "i")
                    i -= 3
                    defaults.set(i, forKey: "i")
                    self.change_three_books(temp: temp, i: i)
                }
                else if action == "switch" {
                    let defaults = UserDefaults.standard
                    let i = UserDefaults.standard.integer(forKey: "i")
                    defaults.set(i, forKey: "i")
                    self.change_three_books(temp: temp, i: i)
                }
            }
        }
        task.resume()
    }
    
    
    func change_three_books(temp: [String], i: Int){
            guard let url = URL(string: "http://3.231.6.81:5000/books/search") else {return }
            var request = URLRequest(url: url)
            let parameters: [String: Any] = [
                "title": temp[abs(i)%temp.count]
            ]
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let bookjson = try? JSONDecoder().decode(Current.self, from: data)
                let book_data = bookjson!.data
                
                DispatchQueue.main.async {
                    for book_info in book_data {
                        let defaults = UserDefaults.standard
                        defaults.set(book_info.title, forKey: "book1")
                        let u1 = URL(string: book_info.thumbnail)
                        let data1 = try? Data(contentsOf: u1!)
                        self.other_book_1.setBackgroundImage(UIImage(data: data1!), for: .normal)
                    }
                    }
            }
            task.resume()
        
            
            guard let url2 = URL(string: "http://3.231.6.81:5000/books/search") else {return }
            var request2 = URLRequest(url: url2)
            let parameters2: [String: Any] = [
                "title": temp[(abs(i)+1)%temp.count]
            ]
            request2.httpMethod = "POST"
            request2.httpBody = try? JSONSerialization.data(withJSONObject: parameters2, options: [])
            request2.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request2.addValue("application/json", forHTTPHeaderField: "Accept")

            let task2 = URLSession.shared.dataTask(with: request2) { (data, response, error) in
                guard let data = data else { return }
                let bookjson = try? JSONDecoder().decode(Current.self, from: data)
                let book_data = bookjson!.data
                
                DispatchQueue.main.async {
                    for book_info in book_data {
                        let defaults = UserDefaults.standard
                        defaults.set(book_info.title, forKey: "book2")
                        let u2 = URL(string: book_info.thumbnail)
                        let data2 = try? Data(contentsOf: u2!)
                        self.other_book_2.setBackgroundImage(UIImage(data: data2!), for: .normal)
                    }
                    }
            }
            task2.resume()
                                    
        
            guard let url3 = URL(string: "http://3.231.6.81:5000/books/search") else {return }
            var request3 = URLRequest(url: url3)
            let parameters3: [String: Any] = [
                "title": temp[(abs(i)+2)%temp.count]
            ]
            request3.httpMethod = "POST"
            request3.httpBody = try? JSONSerialization.data(withJSONObject: parameters3, options: [])
            request3.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request3.addValue("application/json", forHTTPHeaderField: "Accept")

            let task3 = URLSession.shared.dataTask(with: request3) { (data, response, error) in
                guard let data = data else { return }
                let bookjson = try? JSONDecoder().decode(Current.self, from: data)
                let book_data = bookjson!.data
                
                DispatchQueue.main.async {
                    for book_info in book_data {
                        let defaults = UserDefaults.standard
                        defaults.set(book_info.title, forKey: "book3")
                        let u3 = URL(string: book_info.thumbnail)
                        let data3 = try? Data(contentsOf: u3!)
                        self.other_book_3.setBackgroundImage(UIImage(data: data3!), for: .normal)
                    }
                    }
                
            }
            task3.resume()
    }

    @IBAction func next_book_pressed(_ sender: Any) {
        update_other_book(action: "next")
    }
    
    @IBAction func prev_book_pressed(_ sender: Any) {
        update_other_book(action: "prev")
    }
    
    @IBAction func first_book_pressed(_ sender: Any) {
        let book1 = UserDefaults.standard.string(forKey: "book1")!
        guard let url = URL(string: "http://3.231.6.81:5000/books/search") else {return}
        var request = URLRequest(url: url)
        let parameters: [String: Any] = [
            "title": book1
        ]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let bookjson = try? JSONDecoder().decode(Current.self, from: data)
            let book_data = bookjson!.data
            
            DispatchQueue.main.async {
                for book_info in book_data {
                    let defaults = UserDefaults.standard
                    defaults.set(book_info.author, forKey: "current_author")
                    defaults.set(book_info.isbn, forKey: "current_isbn")
                    defaults.set(book_info.title, forKey: "current_title")
                    defaults.set(book_info.id, forKey: "current_id")
                    let u = URL(string: book_info.thumbnail)
                    let data = try? Data(contentsOf: u!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    self.temp_button.setBackgroundImage(UIImage(data: data!), for: .normal)
                    
                    self.author_label.text = book_info.author
                    self.title_label.text = book_info.title
                    self.isbn_label.text = book_info.isbn
                    self.compare_current_book(is_this_current: book_info.title)


                }
                
                self.update_other_book(action: "switch")
            }
        }
        task.resume()
    }
    
    
    @IBAction func second_book_pressed(_ sender: Any) {
        let book2 = UserDefaults.standard.string(forKey: "book2")!
        guard let url = URL(string: "http://3.231.6.81:5000/books/search") else {return}
        var request = URLRequest(url: url)
        let parameters: [String: Any] = [
            "title": book2
        ]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let bookjson = try? JSONDecoder().decode(Current.self, from: data)
            let book_data = bookjson!.data
            
            DispatchQueue.main.async {
                for book_info in book_data {
                    let defaults = UserDefaults.standard
                    defaults.set(book_info.author, forKey: "current_author")
                    defaults.set(book_info.isbn, forKey: "current_isbn")
                    defaults.set(book_info.title, forKey: "current_title")
                    defaults.set(book_info.id, forKey: "current_id")
                    let u = URL(string: book_info.thumbnail)
                    let data = try? Data(contentsOf: u!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    self.temp_button.setBackgroundImage(UIImage(data: data!), for: .normal)
                    self.compare_current_book(is_this_current: book_info.title)
                    self.author_label.text = book_info.author
                    self.title_label.text = book_info.title
                    self.isbn_label.text = book_info.isbn
                }
                
                self.update_other_book(action: "switch")
            }
        }
        task.resume()
    }
    
    
    @IBAction func third_book_pressed(_ sender: Any) {
        let book3 = UserDefaults.standard.string(forKey: "book3")!
        guard let url = URL(string: "http://3.231.6.81:5000/books/search") else {return}
        var request = URLRequest(url: url)
        let parameters: [String: Any] = [
            "title": book3
        ]
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let bookjson = try? JSONDecoder().decode(Current.self, from: data)
            let book_data = bookjson!.data
            
            DispatchQueue.main.async {
                for book_info in book_data {
                    let defaults = UserDefaults.standard
                    defaults.set(book_info.author, forKey: "current_author")
                    defaults.set(book_info.isbn, forKey: "current_isbn")
                    defaults.set(book_info.title, forKey: "current_title")
                    defaults.set(book_info.id, forKey: "current_id")
                    let u = URL(string: book_info.thumbnail)
                    let data = try? Data(contentsOf: u!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    self.temp_button.setBackgroundImage(UIImage(data: data!), for: .normal)
                    self.compare_current_book(is_this_current: book_info.title)
                    self.author_label.text = book_info.author
                    self.title_label.text = book_info.title
                    self.isbn_label.text = book_info.isbn
                }
                
                self.update_other_book(action: "switch")
            }
        }
        task.resume()
    }
    
    // MARK: MAKE POST REQUEST TO UPDATE CURRENT BOOK
    @IBAction func make_current_button_pressed(_ sender: Any) {
                
        var new_book = UserDefaults.standard.string(forKey: "current_id")!
        new_book = "http://3.231.6.81:5000/currently_reading/" + new_book
        guard let url = URL(string: new_book) else {return }
        var request = URLRequest(url: url)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let bookjson = try? JSONDecoder().decode(Current.self, from: data)
            let book_data = bookjson!.data
            
            DispatchQueue.main.async {
                for book_info in book_data {
                    print(book_info.title)
                    print("successfully updated new book")
                    self.status_label.text = "Current Book"
                    self.make_current_button.isHidden = true
                }
                }
        }
        task.resume()

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
