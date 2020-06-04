//
//  PasscodeView.swift
//  passcode
//
//  Created by mfv-computer-0019 on 6/3/20.
//  Copyright © 2020 mfv. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class PinCodeTextField: UIView {
    public weak var delegate: PinCodeTextFieldDelegate?
    
    //MARK: Customizable from Interface Builder
    @IBInspectable public var underlineWidth: CGFloat = 40
    @IBInspectable public var underlineHSpacing: CGFloat = 8
    @IBInspectable public var underlineVMargin: CGFloat = 0
    @IBInspectable public var characterLimit: Int = 6 {
        willSet {
            if characterLimit != newValue {
                updateView()
            }
        }
    }
    @IBInspectable public var underlineHeight: CGFloat = 3
    @IBInspectable public var placeholderText: String?
    @IBInspectable public var text: String? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable public var fontSize: CGFloat = 14 {
        didSet {
            font = font.withSize(fontSize)
        }
    }
    
    @IBInspectable public var textColor: UIColor = .clear
    @IBInspectable public var placeholderColor: UIColor = .lightGray
    @IBInspectable public var underlineColor: UIColor = .darkGray
    @IBInspectable public var updatedUnderlineColor: UIColor = .clear
    @IBInspectable public var errorColor: UIColor = .red
    @IBInspectable public var secureText: Bool = false
    @IBInspectable public var needToUpdateUnderlines: Bool = true
    @IBInspectable public var characterBackgroundColor: UIColor = .white
    @IBInspectable public var characterBackgroundCornerRadius: CGFloat = 0
    @IBInspectable public var highlightInputUnderline: Bool = false
    @IBInspectable public var errorViewHeight: CGFloat = 20
    @IBInspectable public var cellHeight: CGFloat = 54
    @IBInspectable public var marginErrorText: CGFloat = 20



    @IBInspectable public var isError: Bool = false {
        
        didSet {
            if isError {
                for label in labels {
                    let index = labels.firstIndex(of: label) ?? 0
                    underlines[index].backgroundColor = errorColor
                }
            } else {
                
                for label in labels {
                    let index = labels.firstIndex(of: label) ?? 0
                    if (!highlightInputUnderline || !isInput(index)) && isPlaceholder(index) {
                           underlines[index].backgroundColor = underlineColor
                    }
                    else{
                        underlines[index].backgroundColor = updatedUnderlineColor
                    }
                }
            
            }
        }
    }

    
    //MARK: Customizable from code
    public var keyboardType: UIKeyboardType = UIKeyboardType.numberPad
    public var keyboardAppearance: UIKeyboardAppearance = UIKeyboardAppearance.default
    public var autocorrectionType: UITextAutocorrectionType = UITextAutocorrectionType.no
    public var font: UIFont = UIFont.systemFont(ofSize: 14)
    public var allowedCharacterSet: CharacterSet = CharacterSet.alphanumerics
    public var textContentType: UITextContentType! = nil
    public var errorMessage: String? {
        didSet {
            if let message = errorMessage {
                setupErrorLabel(message: message)
                isError = true
            } else {
                errorLabel.removeFromSuperview()
                isError = false
            }
        }
    }
    
    private var _inputView: UIView?
    open override var inputView: UIView? {
        get {
            return _inputView
        }
        set {
            _inputView = newValue
        }
    }
    
    // UIResponder
    private var _inputAccessoryView: UIView?
    @IBOutlet open override var inputAccessoryView: UIView? {
        get {
            return _inputAccessoryView
        }
        set {
            _inputAccessoryView = newValue
        }
    }
    
    public var isSecureTextEntry: Bool {
        get {
            return secureText
        }
        @objc(setSecureTextEntry:) set {
            secureText = newValue
        }
    }
    
    //MARK: Private
    private var labels: [UILabel] = []
    private var underlines: [UIView] = []
    private var backgrounds: [UIView] = []
    private var errorLabel: UILabel!
    
    
    //MARK: Init and awake
    override public init(frame: CGRect) {
        super.init(frame: frame)
        postInitialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        postInitialize()
    }
    
    override open func prepareForInterfaceBuilder() {
        postInitialize()
    }
    
    private func postInitialize() {
        updateView()
    }
    
    //MARK: Overrides
    override open func layoutSubviews() {
        layoutCharactersAndPlaceholders()
        super.layoutSubviews()
    }
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    @discardableResult override open func becomeFirstResponder() -> Bool {
        delegate?.textFieldDidBeginEditing(self)
        return super.becomeFirstResponder()
    }
    
    @discardableResult override open func resignFirstResponder() -> Bool {
        delegate?.textFieldDidEndEditing(self)
        return super.resignFirstResponder()
    }
    
    //MARK: Private
    private func updateView() {
        if needToRecreateBackgrounds() {
            recreateBackgrounds()
        }
        if needToRecreateUnderlines() {
            recreateUnderlines()
        }
        if needToRecreateLabels() {
            recreateLabels()
        }
        updateLabels()

        if needToUpdateUnderlines {
            updateUnderlines()
        }
        updateBackgrounds()
        
        if needToRecreateErrorLabel() {
            errorLabel.removeFromSuperview()
        }
                
        setNeedsLayout()
    }
    
    private func needToRecreateUnderlines() -> Bool {
        return characterLimit != underlines.count
    }
    
    private func needToRecreateLabels() -> Bool {
        return characterLimit != labels.count
    }
    
    private func needToRecreateBackgrounds() -> Bool {
        return characterLimit != backgrounds.count
    }
    
    private func needToRecreateErrorLabel() -> Bool {
        return errorLabel != nil
    }
    
    private func recreateUnderlines() {
        underlines.forEach{ $0.removeFromSuperview() }
        underlines.removeAll()
        characterLimit.times {
            let underline = createUnderline()
            underlines.append(underline)
            addSubview(underline)
        }
    }
    
    private func recreateLabels() {
        labels.forEach{ $0.removeFromSuperview() }
        labels.removeAll()
        characterLimit.times {
            let label = createLabel()
            labels.append(label)
            addSubview(label)
        }
    }
    
    private func recreateBackgrounds() {
        backgrounds.forEach{ $0.removeFromSuperview() }
        backgrounds.removeAll()
        characterLimit.times {
            let background = createBackground()
            backgrounds.append(background)
            addSubview(background)
        }
    }
    
    private func updateLabels() {
        let textHelper = TextHelper(text: text, placeholder: placeholderText, isSecure: isSecureTextEntry)
        for label in labels {
            let index = labels.firstIndex(of: label) ?? 0
            let currentCharacter = textHelper.character(atIndex: index)
            label.text = currentCharacter.map { String($0) }
            label.font = font
            let isplaceholder = isPlaceholder(index)
            label.textColor = labelColor(isPlaceholder: isplaceholder)
        }
    
    }
    
    private func setupErrorLabel(message: String) {
        errorLabel = UILabel(frame: CGRect())
        errorLabel.text = message
        errorLabel.textColor = errorColor
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.bottomAnchor.constraint(equalTo:bottomAnchor).isActive = true
        errorLabel.heightAnchor.constraint(equalToConstant: errorViewHeight).isActive = true
        errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: marginErrorText).isActive = true
        errorLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
    }

    private func updateUnderlines() {
        for label in labels {
            let index = labels.firstIndex(of: label) ?? 0
            if (!highlightInputUnderline || !isInput(index)) && isPlaceholder(index) {
                   underlines[index].backgroundColor = underlineColor
            }
            else{
                underlines[index].backgroundColor = updatedUnderlineColor
            }
        }
    }
    
    private func updateBackgrounds() {
        for background in backgrounds {
            background.backgroundColor = characterBackgroundColor
            background.layer.cornerRadius = characterBackgroundCornerRadius
        }
    }
    
    private func labelColor(isPlaceholder placeholder: Bool) -> UIColor {
        return placeholder ? placeholderColor : textColor
    }
    
    private func isPlaceholder(_ i: Int) -> Bool {
        let inputTextCount = text?.count ?? 0
        return i >= inputTextCount
    }
    
    private func isInput(_ i: Int) -> Bool {
        let inputTextCount = text?.count ?? 0
        return i == inputTextCount
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel(frame: CGRect())
        label.font = font
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        return label
    }
    
    private func createUnderline() -> UIView {
        let underline = UIView()
        underline.backgroundColor = underlineColor
        return underline
    }
    
    private func createBackground() -> UIView {
        let background = UIView()
        background.backgroundColor = characterBackgroundColor
        background.layer.cornerRadius = characterBackgroundCornerRadius
        background.clipsToBounds = true
        return background
    }
    
    private func layoutCharactersAndPlaceholders() {
        let marginsCount = characterLimit - 1
        let totalMarginsWidth = underlineHSpacing * CGFloat(marginsCount)
        let totalUnderlinesWidth = underlineWidth * CGFloat(characterLimit)
        
        var currentUnderlineX: CGFloat = bounds.width / 2 - (totalUnderlinesWidth + totalMarginsWidth) / 2
        var currentLabelCenterX = currentUnderlineX + underlineWidth / 2
        
        let totalLabelHeight = font.ascender + font.descender
        let underlineY = bounds.height / 2 + totalLabelHeight / 2 + underlineVMargin
        
        for i in 0..<underlines.count {
            let underline = underlines[i]
            let background = backgrounds[i]
            underline.frame = CGRect(x: currentUnderlineX, y: underlineY, width: underlineWidth, height: underlineHeight)
            background.frame = CGRect(x: currentUnderlineX, y: 0, width: underlineWidth, height: cellHeight)
            currentUnderlineX += underlineWidth + underlineHSpacing
        }
        
        labels.forEach {
            $0.sizeToFit()
            let labelWidth = $0.bounds.width
            let labelX = (currentLabelCenterX - labelWidth / 2).rounded(.down)
            $0.frame = CGRect(x: labelX, y: 0, width: labelWidth, height: cellHeight)
            currentLabelCenterX += underlineWidth + underlineHSpacing
        }
        
    }
    
    //MARK: Touches
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        if (bounds.contains(location)) {
            if (delegate?.textFieldShouldBeginEditing(self) ?? true) {
                let _ = becomeFirstResponder()
            }
        }
    }
    
    
    //MARK: Text processing
    func canInsertCharacter(_ character: String) -> Bool {
        let newText = text.map { $0 + character } ?? character
        let isNewline = character.hasOnlyNewlineSymbols
        let isCharacterMatchingCharacterSet = character.trimmingCharacters(in: allowedCharacterSet).isEmpty
        let isLengthWithinLimit = newText.count <= characterLimit
        return !isNewline && isCharacterMatchingCharacterSet && isLengthWithinLimit
    }
}


//MARK: UIKeyInput
extension PinCodeTextField: UIKeyInput {
    public var hasText: Bool {
        if let text = text {
            return !text.isEmpty
        }
        else {
            return false
        }
    }
    
    public func insertText(_ charToInsert: String) {
        if charToInsert.hasOnlyNewlineSymbols {
            if (delegate?.textFieldShouldReturn(self) ?? true) {
                let _ = resignFirstResponder()
            }
        }
        else if canInsertCharacter(charToInsert) {
            let newText = text.map { $0 + charToInsert } ?? charToInsert
            text = newText
            delegate?.textFieldValueChanged(self)
            if (newText.count == characterLimit) {
                if (delegate?.textFieldShouldEndEditing(self) ?? true) {
                    let _ = resignFirstResponder()
                }
            }
        }
    }
    
    public func deleteBackward() {
        guard hasText else { return }
        text?.removeLast()
        delegate?.textFieldValueChanged(self)
    }
}


internal extension String {
    var hasOnlyNewlineSymbols: Bool {
        return trimmingCharacters(in: CharacterSet.newlines).isEmpty
    }
}

internal extension Int {
    func times(f: () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
    
    func times( f: @autoclosure () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
}


public protocol PinCodeTextFieldDelegate: class {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool // return false to disallow editing.
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) // became first responder
    
    func textFieldValueChanged(_ textField: PinCodeTextField) // text value changed
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool // return true to allow editing to stop and to resign first responder status at the last character entered event. NO to disallow the editing session to end
    
    func textFieldDidEndEditing(_ textField: PinCodeTextField) // called when pinCodeTextField did end editing
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool // called when 'return' key pressed. return false to ignore.
}

/// default
public extension PinCodeTextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
}


class TextHelper {
    let text: String?
    let placeholderText: String?
    let isSecureTextEntry: Bool
    
    init(text: String?, placeholder: String?, isSecure: Bool = false) {
        self.text = text
        self.placeholderText = placeholder
        self.isSecureTextEntry = isSecure
    }
    
    func character(atIndex i: Int) -> Character? {
        let inputTextCount = text?.count ?? 0
        let placeholderTextLength = placeholderText?.count ?? 0
        let character: Character?
        if i < inputTextCount {
            let string = text ?? ""
            character = isSecureTextEntry ? "•" : string[string.index(string.startIndex, offsetBy: i)]
        }
        else if i < placeholderTextLength {
            let string = placeholderText ?? ""
            character = string[string.index(string.startIndex, offsetBy: i)]
        }
        else {
            character = nil
        }
        return character
    }
}
