//
//  FeedViewController.swift
//  Prototype
//
//  Created by Kamran on 29.03.25.
//

import UIKit

final class FeedViewController: UITableViewController{
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!
    }
}
