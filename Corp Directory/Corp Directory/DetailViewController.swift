//
//  DetailViewController.swift
//  Proto1
//
//  Created by Rich Randall on 9/30/14.
//  Copyright (c) 2014 Rich Randall. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var user : AADUser!
    var userAttributes = Dictionary<String, String>()
    var attributeKeys = Array<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userAttributes = user.getDisplayAttributes()
        self.attributeKeys = Array<String>(self.userAttributes.keys)
        self
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (userAttributes.count > 0) {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (0 == section) {
            return 1
        } else {
            return userAttributes.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if (indexPath.section == 0) {
            cell = tableView.dequeueReusableCellWithIdentifier("UserName", forIndexPath: indexPath) as? UITableViewCell
            cell?.textLabel?.text = self.user.displayName
            user.setImage(cell!.imageView!)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("UserDetail", forIndexPath: indexPath) as? UITableViewCell
            var index = indexPath.row
            cell?.textLabel?.text = self.attributeKeys[index]
            cell?.detailTextLabel?.text = self.userAttributes[self.attributeKeys[index]]
        }
        return cell!
    }
}