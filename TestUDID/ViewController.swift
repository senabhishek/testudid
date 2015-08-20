//
//  ViewController.swift
//  TestUDID
//
//  Created by Abhishek Sen on 8/20/15.
//  Copyright (c) 2015 Abhi. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastnameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!

  var getUniqueDeviceIdentifier : String {
    get {
      let identifier = UIDevice.currentDevice().identifierForVendor.description
      let identifierArray = split(identifier) {$0 == ">"}
      let identifierString = identifierArray[1] as String
      return identifierString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func doneButtonPressed(sender: AnyObject) {
    let testerObject = PFObject(className: "Testers")
    testerObject["Firstname"] = firstNameTextField.text
    testerObject["Lastname"] = lastnameTextField.text
    testerObject["Email"] = emailTextField.text
    testerObject["UDID"] = getUniqueDeviceIdentifier
//    testerObject["DeviceType"] 
    testerObject.saveInBackgroundWithBlock { (success, error) -> Void in
      println("Saved tester information successfully")
    }
//    let testObject = PFObject(className: "TestObject")
//    testObject["foo"] = "bar"
//    testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//      println("Object has been saved.")
//    }
  }

}

