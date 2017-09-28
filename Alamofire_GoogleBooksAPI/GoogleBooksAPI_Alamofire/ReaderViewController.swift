//
//  ReaderViewController.swift
//  GoogleBooksAPI_Alamofire
//
//  Created by Jonathon Fishman on 12/23/16.
//  Copyright © 2016 fatsjohonimahnn. All rights reserved.
//

import UIKit

class ReaderViewController: UIViewController {

    @IBOutlet weak var bookReadView: UIWebView!
    
    var webReaderLink: String?
    var bookTitle: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Don't forget, we had to add this to the project's Info.plist to
        // load anything at all!
        //  <key>NSAppTransportSecurity</key>
        //    <dict>
        //        <key>NSAllowsArbitraryLoads</key>
        //    <true/>
        //  </dict>
        
        let url = URL (string: webReaderLink!)
        let requestObj = URLRequest(url: url!)
        bookReadView.loadRequest(requestObj)
        
        navigationItem.title = bookTitle!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
