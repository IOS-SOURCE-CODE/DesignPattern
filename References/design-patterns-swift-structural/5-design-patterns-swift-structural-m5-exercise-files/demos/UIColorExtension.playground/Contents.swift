//: The Decorator pattern
import UIKit

//: UIColor Extension
/*
 We use Swift extensions to add a new UIColor initializer which takes a 32-bit unsigned integer as input argument.
 This argument represents the HTML color code. HTML color codes are provided as hexadecimal triplets representing the colors red, green, and blue (#RRGGBB).
 */
extension UIColor {
    convenience init(hex: UInt32) {
        let divisor = Float(255)
        let red     = Float((hex & 0xFF0000) >> 16) / divisor
        let green   = Float((hex & 0x00FF00) >> 8) / divisor
        let blue    = Float(hex & 0x0000FF) / divisor
        self.init(colorLiteralRed: red, green: green, blue: blue, alpha: 1)
    }
}

let darkBlue = UIColor(hex: 0x191970)
let lightBlue = UIColor(hex: 0x3CB5B5)
let customYellow = UIColor(hex: 0xFCD920)
let customRed = UIColor(hex: 0xE53B51)

//: UILabel Decorator
/*
 The BorderedLabelDecorator is a subclass of UILabel and wraps a UILabel instance. 
 It adds a new initializer which allows creating rounded labels with custom borders.
 */
class BorderedLabelDecorator: UILabel {
    fileprivate let wrappedLabel: UILabel
    
    required init(label: UILabel, cornerRadius: CGFloat = 3.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .black) {
        self.wrappedLabel = label
        super.init(frame: label.frame)
        
        wrappedLabel.layer.cornerRadius = cornerRadius
        wrappedLabel.layer.borderColor = borderColor.cgColor
        wrappedLabel.layer.borderWidth = borderWidth
        wrappedLabel.clipsToBounds = true
    }
    
    override var textAlignment: NSTextAlignment {
        get {
            return wrappedLabel.textAlignment
        }
        set {
            wrappedLabel.textAlignment = newValue
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return wrappedLabel.backgroundColor
        }
        set {
            wrappedLabel.backgroundColor = newValue
        }
    }
    
    override var textColor: UIColor? {
        get {
            return wrappedLabel.textColor
        }
        set {
            wrappedLabel.textColor = newValue
        }
    }
    
    override var text: String? {
        get {
            return wrappedLabel.text
        }
        set {
            var str = "😸"
            if let newVal = newValue {
                str += newVal + str
            }
            wrappedLabel.text = str
        }
    }
    
    override var layer: CALayer {
        return wrappedLabel.layer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Testing
let frame = CGRect(origin: CGPoint.zero, size: CGSize(width:400, height: 44))
let label = UILabel(frame: frame)
var roundedLabel = BorderedLabelDecorator(label: label, cornerRadius: 10, borderWidth: 1, borderColor: .red)
roundedLabel.textAlignment = .center
roundedLabel.backgroundColor = .white
roundedLabel.textColor = lightBlue
roundedLabel.text = "Rounded label with border and custom text"
//: Pitfalls
// With extensions we can even modify the behavior of existing methods.
// While this is a nice feature, we can accidentally replace existing funtionality, as illustrated in the following snippet:
extension String {
    public func lowercased() -> String {
        return self.uppercased()
    }
}

var message = "Hello"
print("\(message) lowercased is \(message.lowercased())?!")
