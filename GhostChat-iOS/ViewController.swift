//
//  ViewController.swift
//  GhostChat-iOS
//
//  Created by GrownYoda on 4/26/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBPeripheralManagerDelegate, CBCentralManagerDelegate,CBPeripheralDelegate, UITextFieldDelegate {

    // MARK: - Globals
    
    // Core Bluetooth Peripheral Stuff
    var myPeripheralManager: CBPeripheralManager?
    var dataToBeAdvertisedGolbal:[String:AnyObject!]?
    // ID of Peripheral
    var identifer = "My ID"
    // A newly generated UUID for Peripheral
    var uuid = NSUUID()
    var refreshControl:UIRefreshControl!
    
    
    // Chat Array
    var fullChatArray = [("","", "", "")]
    var chatDictionary:[String:(String, String, String, String)] = ["UUIDString":("UUIDString","RSSI", "Name","myPeripheralDictionary Services1")]
    var cleanAndSortedChatArray = [("","", "","")]
    
    // BLE Peripheral Arrays
    var fullPeripheralArray = [("UUIDString","RSSI", "Name", "full Services1")]
    var myPeripheralDictionary:[String:(String, String, String, String)] = ["UUIDString":("UUIDString","RSSI", "Name","myPeripheralDictionary Services1")]
    var cleanAndSortedArray = [("UUIDString","RSSI", "Name","clean Services1")]

    
    //  CoreBluetooth Central Stuff
    var myCentralManager = CBCentralManager()
    var peripheralArray = [CBPeripheral]() // create now empty array.
  
    
    
    // MARK: - UI Stuff
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBAction func sendButtonPressed(sender: UIButton) {
                self.view.endEditing(true)
        

        
        advertiseNewName(myTextField.text)
        myTextField.text = ""
    }
    
    func  textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    @IBAction func refreshPressed(sender: UIButton) {
        myCentralManager.stopScan()
        //refreshArrays()
        startScanning()
        
    }
    
    func refreshArrays(sender: AnyObject){
        
        fullPeripheralArray.removeAll(keepCapacity: false)
        cleanAndSortedArray.removeAll(keepCapacity: false)
        myPeripheralDictionary.removeAll(keepCapacity: false)
        
        cleanAndSortedChatArray.removeAll(keepCapacity: false)
        fullChatArray.removeAll(keepCapacity: false)
        chatDictionary.removeAll(keepCapacity: false)
        
        // display a clean table
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }

    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        advertiseNewName(myTextField.text)
        putPeripheralManagerIntoMainQueue()
        
        //dismiss keyboard
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
        
     //   func textFieldShouldReturn(textField: UITextField) -> Bool {
         //   textField.resignFirstResponder()
          //  return false
        //}
        
  
        
        
        //refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refreshArrays:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + 10
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = 10;
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper Functions
    
    func updateStatusText(passedString: String){
      //  statusText.text = passedString + "\r" + statusText.stringValue
    }
    
    
    
    func putPeripheralManagerIntoMainQueue(){
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        
        if let manager = myPeripheralManager{
            manager.delegate = self
            
        }
    }
    
    //dismiss keyboard
    func didTapView(){
        self.view.endEditing(true)

    }
    

    
    
    // MARK:  - CBPeripheral
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        println("did update state!")
        // Stop Advertising
        peripheral.stopAdvertising()
        
        
        switch (peripheral.state) {
        case .PoweredOn:
            println(" Powered ON State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            println("We Are Going to Scan and Advertise at once.")
            
            
            println("We are ON!")
            
            advertiseNewName("uh, hello?")
/*
            // Prep Advertising Packet for Periperhal
            let manufacturerData = identifer.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            let theUUid = CBUUID(NSUUID: uuid)
            
            let nameString = nameField.text
            let messageString = myTextField.text
            let localNameChatString = "Ghost \(messageString)"
            
            let dataToBeAdvertised:[String:AnyObject!] = [
                CBAdvertisementDataLocalNameKey: "\(localNameChatString)",
                CBAdvertisementDataManufacturerDataKey: "Hello Hello Hello Hello",
                CBAdvertisementDataServiceUUIDsKey: [theUUid],]
            
            dataToBeAdvertisedGolbal = dataToBeAdvertised
            // Start Advertising The Packet
            myPeripheralManager?.startAdvertising(dataToBeAdvertised)
  */
            
            break
        case .PoweredOff:
            println(" Powered OFF State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            println("We are off!")
            
            break;
            
        case .Resetting:
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            
            break;
            
        case .Unauthorized:
            //
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            break;
            
        case .Unknown:
            //
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            break;
            
        case .Unsupported:
            //
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            break;
            
        default:
            println(" State: " + "\(myPeripheralManager?.state.rawValue)"  )
            
            break;
        }
        
        
    }
    func advertiseNewName(passedString: String ){
        
        // Stop Advertising
        myPeripheralManager?.stopAdvertising()
        
        // UI Stuff
        
        
        // Prep Advertising Packet for Periperhal
        let manufacturerData = identifer.dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: false)
        
        let theUUid = CBUUID(NSUUID: uuid)
        
        //let nameString = nameField.text
        
        let dataToBeAdvertised:[String:AnyObject!] = [
            CBAdvertisementDataLocalNameKey: "Ghost: \(passedString)",
            CBAdvertisementDataManufacturerDataKey: "Hello anufacturerDataKey",
            CBAdvertisementDataServiceUUIDsKey: [theUUid],]
        
        // Start Advertising The Packet
        myPeripheralManager?.startAdvertising(dataToBeAdvertised)
    }
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        //
        println(" State in DidStartAdvertising: " + "\(myPeripheralManager?.state.rawValue)"  )
        
        if error == nil {
            //            let myString = peripheral.isAdvertising
            println("Succesfully Advertising Data")
            updateStatusText("Succesfully Advertising Data")
            
        } else{
            println("Failed to Advertise Data.  Error = \(error)")
            updateStatusText("Failed to Advertise Data.  Error = \(error)")
        }
        
    }
    
    
    
    //MARK: - CBCenteral
    // Put CentralManager in the main queue
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        
    }


    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        println("centralManagerDidUpdateState")
        
        /*
        typedef enum {
        CBCentralManagerStateUnknown  = 0,
        CBCentralManagerStateResetting ,
        CBCentralManagerStateUnsupported ,
        CBCentralManagerStateUnauthorized ,
        CBCentralManagerStatePoweredOff ,
        CBCentralManagerStatePoweredOn ,
        } CBCentralManagerState;
        */
        switch central.state{
        case .PoweredOn:
            updateStatusText("Central poweredOn")
            //Scan for other Peripherals
            startScanning()
            

            
            
        case .PoweredOff:
            updateStatusText("Central State PoweredOFF")
            
        case .Resetting:
            updateStatusText("Central State Resetting")
            
        case .Unauthorized:
            updateStatusText("Central State Unauthorized")
            
        case .Unknown:
            updateStatusText("Central State Unknown")
            
        case .Unsupported:
            updateStatusText("Central State Unsupported")
            
        default:
            updateStatusText("Central State None Of The Above")
            
        }
    }

    func startScanning(){
        
        
        myCentralManager.stopScan()   // stop scanning to save power
        
        //    refreshArrays()
        
       //   tableView.reloadData()
        
        myCentralManager.scanForPeripheralsWithServices(nil, options: nil )   // call to scan for services
        
    }
    
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        
        
        // Refresh Entry or Make an New Entry into Dictionary
        let myUUIDString = peripheral.identifier.UUIDString
        let myRSSIString = String(RSSI.intValue)
        var myNameString: String!
        var myMessageString: String!
        
        
        //myMessageString = advertisementData[CBAdvertisementDataManufacturerDataKey] as String
        
        
        let prefixString = "Ghost"
        //   let localNameKey = advertisementData[CBAdvertisementDataLocalNameKey]
        
        if let localNameKey: AnyObject = advertisementData[CBAdvertisementDataLocalNameKey]  {
            
            myNameString = localNameKey as! String
            var myTuple = (myUUIDString, myRSSIString, "\(myNameString)", "\(myMessageString)" )
            
            if myNameString!.hasPrefix(prefixString) || myNameString!.hasPrefix("GC") {
                myTuple.2 = myTuple.2
                chatDictionary[myTuple.0] = myTuple
                
                // Clean Array
                fullChatArray.removeAll(keepCapacity: false)
                
                // Tranfer Dictionary to Array
                for eachItem in chatDictionary{
                    fullChatArray.append(eachItem.1)
                }
                
                // Sort Array by RSSI
                //from http://www.andrewcbancroft.com/2014/08/16/sort-yourself-out-sorting-an-array-in-swift/
                cleanAndSortedChatArray = sorted(fullChatArray,{
                    (str1: (String,String,String,String) , str2: (String,String,String,String) ) -> Bool in
                    return str1.1.toInt() > str2.1.toInt()
                })
                
                return
                
            }
        }
        
        
        
        myNameString = peripheral.name
        
        let myTuple = (myUUIDString, myRSSIString, "others: \(myNameString)", "\(myMessageString)" )
        myPeripheralDictionary[myTuple.0] = myTuple
        
        // Clean Array
        fullPeripheralArray.removeAll(keepCapacity: false)
        
        // Tranfer Dictionary to Array
        for eachItem in myPeripheralDictionary{
            fullPeripheralArray.append(eachItem.1)
        }
        
        // Sort Array by RSSI
        //from http://www.andrewcbancroft.com/2014/08/16/sort-yourself-out-sorting-an-array-in-swift/
        cleanAndSortedArray = sorted(fullPeripheralArray,{
            (str1: (String,String,String,String) , str2: (String,String,String,String) ) -> Bool in
            return str1.1.toInt() > str2.1.toInt()
        })
        
        tableView.reloadData()
        
    }
    
    

    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return cleanAndSortedChatArray.count
        }else{
            return cleanAndSortedArray.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if (indexPath.section == 0) {
            // Configure the cell...
            let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = "\(cleanAndSortedChatArray[indexPath.row].2)"
            cell.detailTextLabel?.text = cleanAndSortedChatArray[indexPath.row].1
            
            var myImage = UIImage (named: "CellIcon")
                cell.imageView?.image = myImage
            
                        
            return cell
            
        } else {
            
            // Configure the cell...
            let cell = tableView.dequeueReusableCellWithIdentifier("backgroundCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = "\(cleanAndSortedArray[indexPath.row].1)" + "  \(cleanAndSortedArray[indexPath.row].2)"
            cell.detailTextLabel?.text = cleanAndSortedArray[indexPath.row].3
            
            return cell}
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Chat Activity"
        }else if section == 1{
            tableView.sectionIndexColor = UIColor.darkGrayColor()
            return "BackGround Devices"
        } else {
            return "Misc"
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        //  future build out
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
        println("selected: \(indexPath.row)")
  //      updateStatusLabel("selected: \(cleanAndSortedArray[indexPath.row].3)")
        
        
        
    }

    
    
    

}

