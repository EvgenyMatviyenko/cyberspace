
import Foundation

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

enum BlockColor: Int {
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
    let color: BlockColor
    let character: Character
}

typealias BlockRow = [Block?]

typealias BlockLayer = [BlockRow]

typealias BlockWorld = [BlockLayer]

func buildRectangle(world: inout BlockWorld, size: Size, position: Position, color: BlockColor) {
    (position.y..<size.height + position.y).forEach { y in
        guard y < world.count else { return }
        (position.z..<size.depth + position.z).forEach { z in
            guard z < world[y].count else { return }
            (position.x..<size.width + position.x).forEach { x in
                guard x < world[y][z].count else { return }

                let isVerticalEdge =
                    (x == position.x || x == position.x + size.width - 1) &&
                        (z == position.z || z == position.z + size.depth - 1)

                let isDepthEdge =
                    (x == position.x || x == position.x + size.width - 1) &&
                        (y == position.y || y == position.y + size.height - 1)

                let isHorizontalEdge =
                    (z == position.z || z == position.z + size.depth - 1) &&
                        (y == position.y || y == position.y + size.height - 1)

                let isCorner =
                    (isVerticalEdge && isDepthEdge) ||
                        (isVerticalEdge && isHorizontalEdge) ||
                        (isDepthEdge && isHorizontalEdge)

                let char: Character =
                    isCorner ? "@" :
                        isVerticalEdge ? "|" :
                        isDepthEdge ? "/" :
                        isHorizontalEdge ? "-" : " "

                world[y][z][x] = Block(color: color, character: char)
            }
        }
    }
}

func fill(world: inout BlockWorld, size: Size, position: Position, block: Block) {
    (position.y..<size.height + position.y).forEach { y in
        guard y < world.count else { return }
        (position.z..<size.depth + position.z).forEach { z in
            guard z < world[y].count else { return }
            (position.x..<size.width + position.x).forEach { x in
                guard x < world[y][z].count else { return }
                world[y][z][x] = block
            }
        }
    }
}

func buildHouse(world: inout BlockWorld, isBig: Bool, position: Position, floorsCount: Int, color: BlockColor) {
    if isBig {
        let height = floorsCount * 5
        buildRectangle(world: &world, size: Size(width: 8, depth: 8, height: height), position: Position(x: position.x + 1, z: position.z + 1, y: position.y), color: .white)
        stride(from: 2, to: height, by: 5).forEach { y in
            buildRectangle(world: &world, size: Size(width: 10, depth: 10, height: 2), position: Position(x: position.x, z: position.z, y: y), color: color)
        }
    } else {
        let height = floorsCount * 4
        buildRectangle(world: &world, size: Size(width: 5, depth: 5, height: height), position: position, color: BlockColor.white)
        stride(from: 2, to: height, by: 4).forEach { y in
            buildRectangle(world: &world, size: Size(width: 1, depth: 1, height: 2), position: Position(x: position.x + 3, z: position.z + 5, y: y), color: color)
            buildRectangle(world: &world, size: Size(width: 1, depth: 1, height: 2), position: Position(x: position.x + 5, z: position.z + 3, y: y), color: color)
        }
    }
}

enum Tile {
    case house(isBig: Bool, floorsCount: Int, color: BlockColor)
    case road(horizontal: Bool)
    case crossroad

    func build(world: inout BlockWorld, position: Position) {
        switch self {
        case let .house(isBig, floorsCount, color):
            let housePosition = Position(x: position.x + 2, z: position.z + 2, y: position.y)
            buildHouse(world: &world, isBig: isBig, position: housePosition, floorsCount: floorsCount, color: color)
        case .road(let horizontal):
            let roadPosition = Position(x: position.x + (horizontal ? 0 : 2), z: position.z + (horizontal ? 2 : 0), y: position.y)
            let roadSize = Size(width: horizontal ? 10 : 6, depth: horizontal ? 6 : 10, height: 1)
            fill(world: &world, size: roadSize, position: roadPosition, block: Block(color: .white, character: " "))

            let sidewalkSize = Size(width: horizontal ? 10 : 1, depth: horizontal ? 1 : 10, height: 1)
            let leftSidewalkPosition = Position(x: position.x + (horizontal ? 0 : 2), z: position.z + (horizontal ? 2 : 0), y: 0)
            let rightSidewalkPosition = Position(x: position.x + (horizontal ? 0 : 8), z: position.z + (horizontal ? 8 : 0), y: 0)
            fill(world: &world, size: sidewalkSize, position: leftSidewalkPosition, block: Block(color: BlockColor.white, character: horizontal ? "-" : "/"))
            fill(world: &world, size: sidewalkSize, position: rightSidewalkPosition, block: Block(color: BlockColor.white, character: horizontal ? "-" : "/"))

            let lineSize = Size(width: horizontal ? 3 : 1, depth: horizontal ? 1 : 3, height: 1)
            let firstLinePosition = Position(x: position.x + (horizontal ? 1 : 5), z: position.z + (horizontal ? 5 : 1), y: position.y)
            let secondLinePosition = Position(x: position.x + (horizontal ? 6 : 5), z: position.z + (horizontal ? 5 : 6), y: position.y)
            fill(world: &world, size: lineSize, position: firstLinePosition, block: Block(color: BlockColor.white, character: "*"))
            fill(world: &world, size: lineSize, position: secondLinePosition, block: Block(color: BlockColor.white, character: "*"))

        case .crossroad:
            Tile.road(horizontal: false).build(world: &world, position: position)
            Tile.road(horizontal: true).build(world: &world, position: position)
            fill(world: &world, size: Size(width: 10, depth: 5, height: 1), position: Position.init(x: position.x, z: position.z + 3, y: position.y), block: Block(color: .white, character: " "))
            fill(world: &world, size: Size(width: 5, depth: 10, height: 1), position: Position(x: position.x + 3, z: position.z, y: position.y), block: Block(color: .white, character: " "))
        }
    }
}

func makeWorld(tilesWidth: Int, tilesHeight: Int) -> BlockWorld {
    let size = Size(width: tilesWidth * 10, depth: tilesHeight * 10, height: 60)
    var world = BlockWorld(repeating: BlockLayer(repeating: BlockRow(repeating: nil, count: size.width), count: size.depth), count: size.height)

    // tiles
    (0..<tilesWidth).forEach { tileX in
        (0..<tilesHeight).forEach { tileY in
            let position = Position(x: tileX * 10, z: tileY * 10, y: 0)

            let isVerticalRoad = Float(tileX).remainder(dividingBy: 4) == 0
            let isHorizontalRoad = Float(tileY).remainder(dividingBy: 4) == 0
            let isCrossroad = isVerticalRoad && isHorizontalRoad

            func randomHouse() -> Tile {
                let randomIsBig = arc4random_uniform(10) == 1
                let randomColor: BlockColor = BlockColor(rawValue: Int(arc4random_uniform(7)) + 30) ?? .blue
                let randomFloorsCount = Int(arc4random_uniform(6)) + 1
                return .house(isBig: randomIsBig, floorsCount: randomFloorsCount, color: randomColor)
            }

            let tile: Tile = isCrossroad ? .crossroad :
                isVerticalRoad ? .road(horizontal: false) :
                isHorizontalRoad ? .road(horizontal: true) :
                randomHouse()

            tile.build(world: &world, position: position)
        }
    }

    // Trees
    world[0].enumerated().forEach { (rowIndex, row) in
        row.enumerated().forEach { (blockIndex, block) in
            if block == nil && arc4random_uniform(20) == 1 {
                fill(world: &world, size: Size.init(width: 1, depth: 1, height: Int(arc4random_uniform(5)) + 2), position: Position(x: blockIndex, z: rowIndex, y: 1), block: Block(color: arc4random_uniform(2) == 1 ? BlockColor.green : BlockColor.yellow, character: "^"))
            }
        }
    }

    return world
}

// MARK: - Drawing

enum Cell {
    case tile(color: BlockColor, character: Character)
    case none
}

typealias Grid = [[Cell]]

func draw(grid: Grid) -> String {
    let formattedRows = grid.enumerated().map { (rowIndex, row) -> String in
        let formattedRow = row.map { cell -> String in
            switch cell {
            case .tile(let color, let character):
                return "\u{001B}[0;\(color.rawValue)m\(character)"
            case .none:
                return " "
            }
        }.map { " \($0)" }

        return formattedRow.joined()
    }

    return formattedRows.joined(separator: "\n")
}

func draw(world: BlockWorld, width: Int = 80, height: Int = 40, offsetX: Int, offsetY: Int) {
    var grid = Grid(repeating: [Cell](repeating: .none, count: width), count: height)

    // Place world
    world.enumerated().forEach { (layerIndex, layer) in
        let rowsOffset = max(offsetY, 0)
        let rows: ArraySlice<BlockRow> = layer
            .dropFirst(rowsOffset)
            .prefix(height + 40)

        rows.enumerated().forEach { (rowIndex, row) in
            let reverseRowIndex = layer.count - rowIndex - rowsOffset
            let i = rowIndex - layerIndex - offsetY + rowsOffset

            let blocksOffset = max(offsetX - reverseRowIndex, 0)
            let blocks: ArraySlice<Block?> = row
                .dropFirst(blocksOffset)
                .prefix(width)

            blocks.enumerated().forEach { (columnIndex, block) in
                let j = columnIndex + reverseRowIndex - offsetX + blocksOffset

                if let block = block, i < height && i > 0, j < width && j > 0 {
                    grid[i][j] = .tile(color: block.color, character: block.character)
                }
            }
        }
    }

    // Place frame
    (0..<width).forEach { x in
        (0..<height).forEach { y in
            if x == 0 || x == width - 1 || y == 0 || y == height - 1 {
                grid[y][x] = .tile(color: .red, character: "@")
            }
        }
    }

    print(draw(grid: grid))
}

let world = makeWorld(tilesWidth: 50, tilesHeight: 50)
var offsetX = 600
var offsetY = 0
while true {
    draw(world: world, offsetX: offsetX, offsetY: offsetY)
    Thread.sleep(forTimeInterval: 0.3)
    offsetX -= 1
    offsetY += 2
}
