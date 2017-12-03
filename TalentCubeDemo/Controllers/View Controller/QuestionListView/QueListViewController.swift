//
//  QueListViewController.swift
//  TalentCubeDemo
//
//  Created by Abrar Niyazi on 02/12/17.
//  Copyright © 2017 Abrar Niyazi. All rights reserved.
//

import UIKit

class QueListViewController: UIViewController {

    //Question 1 Section
    @IBOutlet var que1View: UIView!
    @IBOutlet var que1Label: UILabel!
    @IBOutlet var que1Button: UIButton!
    
    
    //Question 2 Section
    @IBOutlet var que2View: UIView!
    @IBOutlet var que2Label: UILabel!
    @IBOutlet var que2Button: UIButton!
    
    
    //Question 3 Section
    @IBOutlet var que3View: UIView!
    @IBOutlet var que3Label: UILabel!
    @IBOutlet var que3Button: UIButton!
    
    
    var videoURLs:VideoURLs?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initNavigationBarUI()
        self.initUIComponents()
        message2Text.normal("Super! Continue the interview or press the ").bold("2 Try ").normal("button ").bold("BEFORE TIME IS UP.")
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        //UpdateUI
        if videoURLs?.recordedURLs![optional: 0] != nil {
           updateUIForQue2()
        }
        if videoURLs?.recordedURLs![optional: 1] != nil {
            updateUIForQue3()
        }
        if videoURLs?.recordedURLs![optional: 2] != nil {
            updateUIAfterQue3()
        }
        
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////
    // UI functions start here
    
    func initUIComponents(){
        que1Button.isHidden = false
        que2Button.isHidden = true
        que3Button.isHidden = true
        
        que1Button.setTitle("START", for: .normal)
        
        que2View.backgroundColor = UIColor.white
        que3View.backgroundColor = UIColor.white
        
        que1Label.textColor = UIColor.white
        que2Label.textColor = UIColor.black
        que3Label.textColor = UIColor.black
        
        que1Button.layer.cornerRadius = que1Button.frame.size.height / 2
        que1Button.layer.borderWidth = 2
        que1Button.layer.borderColor = UIColor.white.cgColor
        
        que2Button.layer.cornerRadius = que2Button.frame.size.height / 2
        que2Button.layer.borderWidth = 2
        que2Button.layer.borderColor = UIColor.white.cgColor
        
        que3Button.layer.cornerRadius = que3Button.frame.size.height / 2
        que3Button.layer.borderWidth = 2
        que3Button.layer.borderColor = UIColor.white.cgColor
        
    }
    
    func updateUIForQue2(){
        que1Button.setTitle("REPLAY", for: .normal)
        que2View.backgroundColor = UIColor.init(hexString: "#0373C3")
        que2Button.isHidden = false
        que2Label.textColor =  UIColor.white
    }
    
    
    func updateUIForQue3(){
        que2Button.setTitle("REPLAY", for: .normal)
        que3View.backgroundColor = UIColor.init(hexString: "#005A99")
        que3Button.isHidden = false
        que3Label.textColor =  UIColor.white
        let lineView = self.view.viewWithTag(999) as! UIView
        lineView.backgroundColor = UIColor.clear
    }
    
    func updateUIAfterQue3(){
        que3Button.setTitle("REPLAY", for: .normal)
    }
    
    func initNavigationBarUI() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]//UIColor.white
    }
    
    // UI Functions end here
    ////////////////////////////////////////////////////////////////////////////////////////
    func pushRecordVideoViewController(questionIndex:Int!) {
        // Pushing record Video page
        let userStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let recordVideoViewController = userStoryBoard.instantiateViewController(withIdentifier: "RecordAndPlayViewController") as! RecordAndPlayViewController
        recordVideoViewController.delegate = self
        recordVideoViewController.questionIndex = questionIndex
        if videoURLs != nil {
             recordVideoViewController.videoURLs = videoURLs!
        }
        self.navigationController!.pushViewController(recordVideoViewController, animated: true)
    }
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////
    // All IBActions Below this
    @IBAction func que1ButtonTapped(_ sender: UIButton) {
        pushRecordVideoViewController(questionIndex: 0)
    }
    
    @IBAction func que2ButtonTapped(_ sender: UIButton) {
        pushRecordVideoViewController(questionIndex: 1)
    }
    
    @IBAction func que3ButtonTapped(_ sender: UIButton) {
        pushRecordVideoViewController(questionIndex: 2)
    }
    
}


