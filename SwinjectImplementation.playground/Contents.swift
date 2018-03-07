//: Playground - noun: a place where people can play

import UIKit

protocol Animal : class {}
class Dog: Animal {}
class Cat: Animal {}


class PetOwner {
    let pet: Animal
    
    init(pet: Animal) {
        self.pet = pet
    }
}


class Container {
    
    var factories = [String: Any]()
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T ) {
        print(type)
        let key = String(reflecting: type)
        factories[key] = factory as Any
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(reflecting: type)
        guard let factory = factories[key] as? () -> T else { return nil }
        return factory()
    }
}

let container = Container()

do {
    
    let cat = Cat()
    
    container.register(Animal.self) { cat }
    container.register(PetOwner.self) {
        PetOwner(pet: container.resolve(Animal.self)!)
        
    }
}

let pet = container.resolve(Animal.self)

let seyha = container.resolve(PetOwner.self)!

let chanthem = container.resolve(PetOwner.self)!

seyha.pet is Cat

seyha !== chanthem

seyha.pet === chanthem.pet








