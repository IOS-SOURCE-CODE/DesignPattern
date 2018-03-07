//: 🏆 The Decorator Patttern

import Foundation



class Purchase: CustomStringConvertible {
   private let product:String
   private let price: Float
   
   init(product:String, price:Float) {
      self.price = price
      self.product = product
   }
   
   var description: String {
      return product
   }
   
   var totalPrice:Float {
      return price
   }
}

class CustomerAccount {
   let customerName:String
   var purchases = [Purchase]()
   
   init(name:String) {
      self.customerName = name
   }
   
   func addPurchase(_ purchase:Purchase) {
      self.purchases.append(purchase)
   }
   
   func printAccount() {
      var total:Float = 0;
      for p in purchases {
         total += p.totalPrice
         print("Purchase \(p), Price \(formatCurrencyString(p.totalPrice))")
      }
      print("Total due: \(formatCurrencyString(total))");
   }
   func formatCurrencyString(_ number:Float) -> String {
      let nsnumber = NSNumber(value: number)
      let formatter = NumberFormatter();
      formatter.numberStyle = .currency
      return formatter.string(from: nsnumber) ?? "";
   }
}
//:  🔥 Problem without decorator pattern

class PurchaseWithGiftWrap : Purchase {
   override var description:String { return "\(super.description) + giftwrap"; }
   override var totalPrice:Float { return super.totalPrice + 2;}
}

class PurchaseWithRibbon : Purchase {
   override var description:String { return "\(super.description) + ribbon"; }
   override var totalPrice:Float { return super.totalPrice + 1; }
}
class PurchaseWithDelivery : Purchase {
   override var description:String { return "\(super.description) + delivery"; }
   override var totalPrice:Float { return super.totalPrice + 5.0; }
}

let account = CustomerAccount(name:"Joe")
account.addPurchase(Purchase(product: "Red Hat", price: 10))
account.addPurchase(Purchase(product: "Scarf", price: 20))

account.addPurchase(PurchaseWithGiftWrap(product: "Sunglasses", price: 25.0))

//account.printAccount()
//:🥇 Solution : for adding more functionality by keep origin class

class BasePurchaseDecorator: Purchase {
   private let wrappedPurchase: Purchase
   init(purchase: Purchase) {
      wrappedPurchase = purchase
      print(purchase.description)
      super.init(product: purchase.description, price: purchase.totalPrice)
   }
}

class SPurchaseWithGifWrap: BasePurchaseDecorator {
   override var description: String {
      return "\(super.description) + giftwrap"
   }
   override var totalPrice: Float {
      return super.totalPrice + 2
   }
}

class SPurchaseWithRibbon: BasePurchaseDecorator {
   override var description: String {
      return "\(super.description) + ribbon"
   }
   override var totalPrice: Float {
      return super.totalPrice + 1
   }
}

class SPurchaseWithDelivery: BasePurchaseDecorator {
   override var description: String {
      return "\(super.description) + delivery"
   }
   override var totalPrice: Float {
      return super.totalPrice + 5
   }
}





class DiscountDecorator: Purchase {
   private let wrappedPurchase: Purchase
   init(purchase: Purchase) {
      self.wrappedPurchase = purchase
      super.init(product: purchase.description, price: purchase.totalPrice)
   }
   
   override var description: String {
      return super.description
   }
   
   var discountAmount: Float {
      return 0
   }
   
   func coundDiscounts() -> Int {
      var total = 1
      if let discounter = wrappedPurchase as? DiscountDecorator {
         total += discounter.coundDiscounts()
      }
      return total
   }
}

class BlackFrindayDecorator: DiscountDecorator {
   override var totalPrice: Float {
      return super.totalPrice - discountAmount
   }
   
   override var discountAmount: Float {
      return super.totalPrice * 0.20
   }
}

class EndOfLineDecorator: DiscountDecorator {
   override var totalPrice: Float {
      return super.totalPrice - discountAmount
   }
   
   override var discountAmount: Float {
      return super.totalPrice * 0.70
   }
}


let daccount = CustomerAccount(name: "Joe")
daccount.addPurchase(Purchase(product: "Red Hat", price: 10))
daccount.addPurchase(Purchase(product: "Scarf", price: 20))

daccount.addPurchase(EndOfLineDecorator(purchase: BlackFrindayDecorator(purchase:
   SPurchaseWithDelivery(purchase: SPurchaseWithGifWrap(purchase: Purchase(product: "Sunglassess", price: 25))))))
daccount.printAccount()


for p in daccount.purchases {
   if let d = p as? DiscountDecorator {
      print("\(p) has \(d.coundDiscounts()) discounts)")
   } else {
      print("\(p) has no discounts")
   }
}

let saccount = CustomerAccount(name:"Joe");
//saccount.addPurchase(Purchase(product: "Red Hat", price: 10))
//saccount.addPurchase(Purchase(product: "Scarf", price: 20))

saccount.addPurchase(SPurchaseWithDelivery(purchase: SPurchaseWithGifWrap(purchase: Purchase(product: "Sunglasses", price: 25.0))))
saccount.purchases.count

saccount.printAccount()


protocol Component {
   func doOperation()
}


class Decorator: Component {
   let wrapperObject: Component
   
   init(wrapperObject: Component) {
      self.wrapperObject = wrapperObject
   }
   
   func doOperation() {
      wrapperObject.doOperation()
   }
}

class ConcreteComponent : Component {
   func doOperation() {
      print("Do Operator")
   }
}

class ConcreteComponent2: Component {
   func doOperation() {
      print("Do Operator 2")
   }
}


let decorator = Decorator(wrapperObject: ConcreteComponent())

decorator.doOperation()


//class SuperClass: CustomStringConvertible {
//   let name: String
//
//   init(name:String) {
//      self.name = name
//   }
//
//   var description: String {
//      return name
//   }
//}
//
//class ChildOne: ClassDecorator {
//   override var description: String {
//      return super.description + " ChildOne "
//   }
//}
//
//class ChildTwo : ClassDecorator {
//   override var description: String {
//      return super.description + " ChildTwo "
//   }
//}
//
//class ClassDecorator : SuperClass {
//
//   let wrapperObject: SuperClass
//
//   init(superClass: SuperClass) {
//      wrapperObject = superClass
//      super.init(name: wrapperObject.description)
//   }
//}
//
//
//let childOne = ChildOne(superClass: ChildTwo(superClass: SuperClass(name: "Hello")))
//
//
//print(childOne.description)


class CheckSuper {
   func printSuper() {
      print("Super")
   }
}

class ChildOne: CheckSuper {
   override func printSuper() {
      print("Hello i am child one")
   }
}

class ChildTwo: ChildOne {
   func printChild2() {
      super.printSuper()
   }
}

ChildTwo().printChild2()












