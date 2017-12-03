
struct Position {
    let x: Int
    let z: Int
    let y: Int
}

struct Size {
    let width: Int
    let depth: Int
    let height: Int
}

enum Color: Int {
    case black = 30
    case red = 31
    case green = 32
    case yellow = 33
    case blue = 34
    case magenta = 35
    case cyan = 36
    case white = 37
}

struct Block {
    let color: Color
    let character: Character
}

typealias BlockRow = [Block?]

typealias BlockLayer = [BlockRow]

typealias BlockWorld = [BlockLayer]
