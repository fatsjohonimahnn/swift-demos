//
//  ViewController.swift
//  GoogleBooksAPI_Alamofire
//
//  Created by Jonathon Fishman on 12/23/16.
//  Copyright © 2016 fatsjohonimahnn. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewFooter: UIView!
    
    // Instead storing the raw JSON data and re-parsing it every time we
    // need to be build a new table view cell, we will parse it once and
    // store the data for each book as an array of BookData structs.
    struct BookData {
        
        var thumbnailImage: UIImage?
        var title: String
        var author: [String]
        var webReaderLink: String
    }
    
    var bookDataArray = [BookData]()

    var searchBarUsed = false
    var searchURL = String()
    var keywords = String()
    var usableKeywords = String()
    var canFetchMoreResults = true
    
    typealias JSONFormat = [String : AnyObject]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewFooter.isHidden = true
        
        loadJSONData(url: //"https://www.googleapis.com/books/v1/users/NEED_USER_ID/bookshelves/0/volumes?&startIndex=0&key=NEED_KEY")
        
         "https://www.googleapis.com/books/v1/volumes?q=alice+in+wonderland")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        canFetchMoreResults = true
        
        searchBarUsed = true
        
        keywords = searchBar.text!
        usableKeywords = keywords.replacingOccurrences(of: " ", with: "+")
        let startIndex = 0
        
        bookDataArray = []
        
        searchURL = "https://www.googleapis.com/books/v1/volumes?q=\(usableKeywords)&filter=free-ebooks&startIndex=\(startIndex)&maxResults=10&key=NEED_KEY"
            
            //"https://www.googleapis.com/books/v1/volumes?q=\(usableKeywords!)"
        
        //print("-----------------------------------------------searchURL = \(searchURL)")
        
        loadJSONData(url: searchURL)
        
        self.view.endEditing(true)
    }
    
    func loadJSONData(url: String) {
        
        Alamofire.request(url).responseJSON(completionHandler: { response in
            
            self.parseData(JSONData: response.data!)
            
            self.tableView.reloadData()
        })
    }
    
    func parseData(JSONData: Data) {
        
        do {
            // serialize incoming JSON Data
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONFormat
            print(readableJSON)
            
            if let items = readableJSON["items"] as? [JSONFormat] {
                
                for i in 0..<items.count {
                    
                    let item = items[i]
                    //print("item = \(item)")
                    
                    if let volumeInfo = item["volumeInfo"] as? JSONFormat {
                        
                        let title = volumeInfo["title"] as! String
                        let author = volumeInfo["authors"] as? NSArray ?? ["Unavailable"]
                        
                        if let imageLinks = volumeInfo["imageLinks"] as? JSONFormat {
                            
                            let thumbnailJSONData = imageLinks["thumbnail"] as! String
                            let thumbnailURL = URL(string: thumbnailJSONData)
                            let thumbnailData = NSData(contentsOf: thumbnailURL!)
                            let thumbnailImage = UIImage(data: thumbnailData as! Data) ?? #imageLiteral(resourceName: "defaultPhoto")
                            
                            if let accessInfo = item["accessInfo"] as? JSONFormat {
                                
                                let webReaderLink = accessInfo["webReaderLink"] as! String
                                
                                self.bookDataArray.append(BookData(thumbnailImage: thumbnailImage, title: title, author: author as! [String], webReaderLink: webReaderLink))
                                
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        catch{
            print("error = \(error)")
        }
    }
    
    func loadSegment(keywords: String, startIndex: Int) {
        
        //print("-------------------------------------------------------------searchBarUsed = \(searchBarUsed)")
        
        if searchBarUsed {
            
            searchURL = "https://www.googleapis.com/books/v1/volumes?q=\(usableKeywords)&filter=free-ebooks&startIndex=\(startIndex)&maxResults=10&key=NEED_KEY"
            
        } else {
            
            searchURL = "https://www.googleapis.com/books/v1/users/NEED_USER_ID/bookshelves/0/volumes?&startIndex=\(startIndex)&maxResults=10&key=NEED_KEY"
        }
        
        //print("---------------------------------------------------------nextSegmentURL = \(searchURL)")
        
        if canFetchMoreResults {
            
            self.loadJSONData(url: self.searchURL)
            
            self.canFetchMoreResults = !(self.bookDataArray.count > 40)
            //print("canFetchMoreResults = \(self.canFetchMoreResults)")
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        //print("------------------------------------------------------------------deltaOffset = \(maximumOffset - currentOffset)")
        
        if maximumOffset - currentOffset < 0 && canFetchMoreResults {
            
            self.tableViewFooter?.isHidden = false
            
            loadSegment(keywords: keywords, startIndex: bookDataArray.count)
        }
        else {
            
            self.tableViewFooter?.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        self.tableViewFooter?.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bookDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! BookTableViewCell
        
        cell.coverImage.image = bookDataArray[indexPath.row].thumbnailImage
        cell.bookTitle.text = bookDataArray[indexPath.row].title
        cell.bookAuthor.text! = bookDataArray[indexPath.row].author[0]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        
        let destinationViewController = segue.destination as! ReaderViewController
        destinationViewController.webReaderLink = bookDataArray[indexPath!].webReaderLink
        destinationViewController.bookTitle = bookDataArray[indexPath!].title
    }
}
