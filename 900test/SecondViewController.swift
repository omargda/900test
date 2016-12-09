//
//  SecondViewController.swift
//  900test
//
//  Created by Omar Garcia De Alba on 10/26/16.
//  Copyright © 2016 Omar Garcia De Alba. All rights reserved.
//

import UIKit

class SecondViewController: UITableViewController, DVGStreamsDataControllerDelegate {

    var dataController: DVGStreamsDataController!
    var playerController: NHSStreamPlayerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "List"
        
        if (self.dataController == nil) {
            self.dataController = DVGStreamsDataController()
            self.dataController.delegate = self
        }
        
        let acitivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.tableView.backgroundView = acitivityIndicatorView
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        self.dataController.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureView()
    }
    
    @IBAction func didTapDone(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshControlTriggered(_ sender: AnyObject) {
        self.dataController.refresh()
    }
    
    func configureView() {
        if self.tableView.backgroundView != nil {
            self.refreshControl?.endRefreshing()
            self.tableView.backgroundView = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var c = self.dataController.streams.count
        
        if c < 20 {
            c = 20
        }
        return c
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func streamsDataControllerDidUpdateStreams(_ controller: DVGStreamsDataController!) {
        return
    }
}

