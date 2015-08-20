//
//  ViewController.swift
//  TestUDID
//
//  Created by Abhishek Sen on 8/20/15.
//  Copyright (c) 2015 Abhi. All rights reserved.
//

import UIKit
import Parse
import SDVersion
import JLToast

extension String {
  func isEmail() -> Bool {
    let regex = NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive, error: nil)
    return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
  }
}

class ViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastnameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  var testerObjectClassName = "Testers"
  let testerObjectIDKey = "testerObjectIDKey"
  var testerObjectID = ""
  var allObjectIDs = [NSString]()
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
    self.firstNameTextField.delegate = self
    self.lastnameTextField.delegate = self
    self.emailTextField.delegate = self
    JLToastView.setDefaultValue(UIFont(name: "AvenirNext-Regular", size: 16.0)!, forAttributeName: JLToastViewFontAttributeName, userInterfaceIdiom: UIUserInterfaceIdiom.Phone)
    JLToastView.setDefaultValue(200.0, forAttributeName: JLToastViewPortraitOffsetYAttributeName, userInterfaceIdiom: UIUserInterfaceIdiom.Phone)
    self.getRegisteredTesters()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.firstNameTextField.becomeFirstResponder()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField != self.emailTextField {
      if textField.text.isEmpty {
        textField.text = textField.text.stringByAppendingString(string).uppercaseString
      } else {
        textField.text = textField.text.stringByAppendingString(string)
      }
    } else {
      textField.text = textField.text.stringByAppendingString(string)
    }
    return false
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func getRegisteredTesters() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if let objectIDs : AnyObject = defaults.objectForKey(testerObjectIDKey) {
      self.allObjectIDs = objectIDs as! [NSString]
    }
  }
  
  func isTesterAlreadyRegistered() {
    self.testerObjectID = self.emailTextField.text
    if let testObjectID = self.allObjectIDs.filter({$0 == self.testerObjectID}).first {
      JLToast.makeText("You're already registered. Thanks!", duration: JLToastDelay.ShortDelay).show()
      clearTextFields()
    } else {
      self.createNewUserObject()
    }
  }
  
  func clearTextFields() {
    self.emailTextField.text = ""
    self.firstNameTextField.text = ""
    self.lastnameTextField.text = ""
  }
  
  func createNewUserObject() {
    let testerObject = PFObject(className: self.testerObjectClassName)
    testerObject["Firstname"] = firstNameTextField.text
    testerObject["Lastname"] = lastnameTextField.text
    testerObject["Email"] = emailTextField.text
    testerObject["UDID"] = getUniqueDeviceIdentifier
    testerObject["DeviceType"] = SDiPhoneVersion.deviceName()
    testerObject.saveInBackgroundWithBlock { (success, error) -> Void in
      let toastText : String
      if success {
        toastText = "Thanks \(self.firstNameTextField.text.capitalizedString)! Your response has been saved. You can close the app now."
        self.allObjectIDs.append(self.testerObjectID)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.allObjectIDs, forKey: self.testerObjectIDKey)
        defaults.synchronize()
        self.clearTextFields()
      } else {
        toastText = "Unfortunately there was an error. Please try submitting the form again."
      }
      JLToast.makeText(toastText, duration: JLToastDelay.LongDelay).show()
    }
  }

  @IBAction func doneButtonPressed(sender: AnyObject) {
    self.view.endEditing(true)
    if !self.firstNameTextField.text.isEmpty &&
      !self.lastnameTextField.text.isEmpty &&
      self.emailTextField.text.isEmail() {
        self.isTesterAlreadyRegistered()
    } else {
      let toastText : String
      if self.lastnameTextField.text.isEmpty {
        toastText = "Please enter a valid non-empty firstname and try again."
      } else if self.lastnameTextField.text.isEmpty {
        toastText = "Please enter a valid non-empty lastname and try again."
      } else {
        toastText = "Please enter a valid email address and try again."
      }
      JLToast.makeText(toastText, duration: JLToastDelay.LongDelay).show()
    }
  }

}

