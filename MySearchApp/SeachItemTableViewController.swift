//
//  SeachItemTableViewController.swift
//  MySearchApp
//
//  Created by inoue on 2016/06/22.
//  Copyright © 2016年 inoue. All rights reserved.
//

import UIKit

class SearchItemTableViewController: UITableViewController, UISearchBarDelegate {
    var itemDataArray = [ItemData]()
    var imageCache = NSCache()
    
    let appid = "dj0zaiZpPWRGMldVYktITFFtQiZzPWNvbnN1bWVyc2VjcmV0Jng9ZjI-"
    let entryUrl = "https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch"
    
    let priceFormat = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceFormat.numberStyle = .CurrencyStyle
        priceFormat.currencyCode = "JPY"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let inputText = searchBar.text
        
        if inputText?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            itemDataArray.removeAll()
            let parameter = ["appid": appid, "query": inputText]
            
            let requestUrl = createRequestUrl(parameter)
            request(requestUrl)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func createRequestUrl(parameter: [String:String?]) -> String {
        var parameterString = ""
        for key in parameter.keys {
            if let value = parameter[key] {
                
                if parameterString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                    parameterString += "&"
                }
                
                if let escapedValue = value!.stringByAddingPercentEncodingWithAllowedCharacters(
                    NSCharacterSet.URLQueryAllowedCharacterSet()) {
                    parameterString += "\(key)=\(escapedValue)"
                }
            }
        }
        
        let requestUrl = entryUrl + "?" + parameterString
        return requestUrl
    }
    
    func request(requestUrl: String) {
        let session = NSURLSession.sharedSession()
        if let url = NSURL(string: requestUrl) {
            let request = NSURLRequest(URL: url)
            
            let task = session.dataTaskWithRequest(request, completionHandler: {
                (data:NSData?, response:NSURLResponse?, error: NSError?) -> Void in
                if error != nil {
                    let alert = UIAlertController(title: "エラー", message: error?.description, preferredStyle: UIAlertControllerStyle.Alert)
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    
                    return
                }
                
                if let data = data {
                    let jsonData = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                    
                    
                    if let resultSet = jsonData["ResultSet"] as? [String: AnyObject] {
                        self.parseData(resultSet)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        self.tableView.reloadData()
                    })
                }
            })
            
            task.resume()
        }
    }
    
    func parseData(resultSet: [String: AnyObject]) {
        if let firstObject = resultSet["0"] as? [String: AnyObject] {
            if let results = firstObject["Result"] as? [String: AnyObject] {
                for key in results.keys.sort() {
                    if (key == "Request") {
                        continue
                    }
                    
                    if let result = results[key] as? [String: AnyObject] {
                        let itemData = ItemData()
                        
                        if let itemImageDic = result["image"] as? [String: AnyObject] {
                            let itemImageUrl = itemImageDic["Medium"] as? String
                            itemData.itemImageUrl = itemImageUrl
                        }
                        
                        let itemTitle = result["Name"] as? String
                        itemData.itemTitle = itemTitle
                        
                        
                        if let itemPriceDic = result["Price"] as? [String: AnyObject] {
                            let itemPrice = itemPriceDic["_value"] as? String
                            itemData.itemPrice = itemPrice
                        }
                        
                        let itemUrl = result["Url"] as? String
                        itemData.itemUrl = itemUrl
                        
                        self.itemDataArray.append(itemData)
                    }
                }
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as! ItemTableViewCell
        
        let itemData = itemDataArray[indexPath.row]
        
        cell.itemTitleLabel.text = itemData.itemTitle
        
        let number = NSNumber(integer: Int(itemData.itemPrice!)!)
        cell.itemPriceLable.text = priceFormat.stringFromNumber(number)
        cell.itemUrl = itemData.itemUrl
        
        if let itemImageUrl = itemData.itemImageUrl {
            if let cacheImage = imageCache.objectForKey(itemImageUrl) as? UIImage{
                cell.itemImageView.image = cacheImage
            }else {
                let session = NSURLSession.sharedSession()
                if let url = NSURL(string: itemImageUrl) {
                    let request = NSURLRequest(URL: url)
                    let task = session.dataTaskWithRequest(request, completionHandler: {
                        (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                        if let data = data {
                            if let image = UIImage(data: data) {
                                self.imageCache.setObject(image, forKey: itemImageUrl)
                                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                                    cell.itemImageView.image = image
                                })
                            }
                        }
                    })
                    task.resume()
                }
            }
        }
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDataArray.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? ItemTableViewCell {
            if let webViewController = segue.destinationViewController as? WebViewController {
                webViewController.itemUrl = cell.itemUrl
            }
        }
    }
    
}
