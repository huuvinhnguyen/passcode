//
//  ViewController.swift
//  passcode
//
//  Created by mfv-computer-0019 on 6/2/20.
//  Copyright © 2020 mfv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pinCodeTextField: PinCodeTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func updatePin(_ sender: Any) {
        if let message = pinCodeTextField.errorMessage {
            pinCodeTextField.errorMessage = nil

            
        } else {
            pinCodeTextField.errorMessage = "This is text message"

        }
    }
    
}

@IBDesignable
class PassCodeView: UIView {
    
    override class func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        
    }
    
    private func configure() {
        backgroundColor = .purple

        let child = UIView()
        child.translatesAutoresizingMaskIntoConstraints = false
        child.backgroundColor = .red
        addSubview(child)
        
        child.bottomAnchor.constraint(equalTo:  safeAreaLayoutGuide.bottomAnchor).isActive = true
        child.heightAnchor.constraint(equalToConstant: 10).isActive = true
        child.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        child.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 1.0).isActive = true
        
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 10))
        textField.textAlignment = .center
        textField.backgroundColor = .green
        textField.keyboardType = .numberPad
//
//        textField.topAnchor.constraint(equalTo:  safeAreaLayoutGuide.topAnchor).isActive = true
//        textField.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
//        textField.heightAnchor.constraint(equalToConstant: 90).isActive = true
//        textField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true

        
        addSubview(textField)
        
        

        
        
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 1
    }

}

