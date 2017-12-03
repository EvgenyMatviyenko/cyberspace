
import Foundation

private enum Tile {
    case house(isBig: Bool, floorsCount: Int, color: Color)
    case road(horizontal: Bool)
    case crossroad
    case pyramid(color: Color, floorHeight: Int)

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
            fill(world: &world, size: sidewalkSize, position: leftSidewalkPosition, block: Block(color: Color.white, character: horizontal ? "-" : "/"))
            fill(world: &world, size: sidewalkSize, position: rightSidewalkPosition, block: Block(color: Color.white, character: horizontal ? "-" : "/"))

            let lineSize = Size(width: horizontal ? 3 : 1, depth: horizontal ? 1 : 3, height: 1)
            let firstLinePosition = Position(x: position.x + (horizontal ? 1 : 5), z: position.z + (horizontal ? 5 : 1), y: position.y)
            let secondLinePosition = Position(x: position.x + (horizontal ? 6 : 5), z: position.z + (horizontal ? 5 : 6), y: position.y)
            fill(world: &world, size: lineSize, position: firstLinePosition, block: Block(color: Color.white, character: "*"))
            fill(world: &world, size: lineSize, position: secondLinePosition, block: Block(color: Color.white, character: "*"))

        case .crossroad:
            Tile.road(horizontal: false).build(world: &world, position: position)
            Tile.road(horizontal: true).build(world: &world, position: position)
            fill(world: &world, size: Size(width: 10, depth: 5, height: 1), position: Position.init(x: position.x, z: position.z + 3, y: position.y), block: Block(color: .white, character: " "))
            fill(world: &world, size: Size(width: 5, depth: 10, height: 1), position: Position(x: position.x + 3, z: position.z, y: position.y), block: Block(color: .white, character: " "))
        case let .pyramid(color, floorHeight):
            (0..<5).forEach { i in
                let size = Size(width: 10 - i * 2, depth: 10 - i * 2, height: floorHeight)
                let position = Position(x: position.x + i, z: position.z + i, y: position.y + i * floorHeight)
                buildRectangle(world: &world, size: size, position: position, color: color)
            }
        }
    }
}

private func fill(world: inout BlockWorld, size: Size, position: Position, blockFactory: (Position) -> Block) {
    (position.y..<size.height + position.y).forEach { y in
        guard y < world.count else { return }
        (position.z..<size.depth + position.z).forEach { z in
            guard z < world[y].count else { return }
            (position.x..<size.width + position.x).forEach { x in
                guard x < world[y][z].count else { return }
                world[y][z][x] = blockFactory(Position(x: x, z: z, y: y))
            }
        }
    }
}

private func fill(world: inout BlockWorld, size: Size, position: Position, block: Block) {
    fill(world: &world, size: size, position: position, blockFactory: { _ in block })
}

private func buildRectangle(world: inout BlockWorld, size: Size, position: Position, color: Color) {
    fill(world: &world, size: size, position: position) { (blockPosition) -> Block in
        let isVerticalEdge =
            (blockPosition.x == position.x || blockPosition.x == position.x + size.width - 1) &&
                (blockPosition.z == position.z || blockPosition.z == position.z + size.depth - 1)

        let isDepthEdge =
            (blockPosition.x == position.x || blockPosition.x == position.x + size.width - 1) &&
                (blockPosition.y == position.y || blockPosition.y == position.y + size.height - 1)

        let isHorizontalEdge =
            (blockPosition.z == position.z || blockPosition.z == position.z + size.depth - 1) &&
                (blockPosition.y == position.y || blockPosition.y == position.y + size.height - 1)

        let isCorner =
            (isVerticalEdge && isDepthEdge) ||
                (isVerticalEdge && isHorizontalEdge) ||
                (isDepthEdge && isHorizontalEdge)

        let char: Character =
            isCorner ? "@" :
                isVerticalEdge ? "|" :
                isDepthEdge ? "/" :
                isHorizontalEdge ? "-" : " "

        return Block(color: color, character: char)
    }
}

private func buildHouse(world: inout BlockWorld, isBig: Bool, position: Position, floorsCount: Int, color: Color) {
    if isBig {
        let height = floorsCount * 5
        buildRectangle(world: &world, size: Size(width: 8, depth: 8, height: height), position: Position(x: position.x + 1, z: position.z + 1, y: position.y), color: .white)
        stride(from: 2, to: height, by: 5).forEach { y in
            buildRectangle(world: &world, size: Size(width: 10, depth: 10, height: 2), position: Position(x: position.x, z: position.z, y: y), color: color)
        }
    } else {
        let height = floorsCount * 4
        buildRectangle(world: &world, size: Size(width: 5, depth: 5, height: height), position: position, color: Color.white)
        stride(from: 2, to: height, by: 4).forEach { y in
            buildRectangle(world: &world, size: Size(width: 1, depth: 1, height: 2), position: Position(x: position.x + 3, z: position.z + 5, y: y), color: color)
            buildRectangle(world: &world, size: Size(width: 1, depth: 1, height: 2), position: Position(x: position.x + 5, z: position.z + 3, y: y), color: color)
        }
    }
}

func makeWorld(tilesWidth: Int, tilesHeight: Int) -> BlockWorld {
    let size = Size(width: tilesWidth * 10, depth: tilesHeight * 10, height: 100)
    var world = BlockWorld(repeating: BlockLayer(repeating: BlockRow(repeating: nil, count: size.width), count: size.depth), count: size.height)

    // Floor
    fill(world: &world, size: Size(width: size.width, depth: size.depth, height: 1), position: Position(x: 0, z: 0, y: 0), block: Block(color: .green, character: "."))

    // tiles
    (0..<tilesWidth).forEach { tileX in
        (0..<tilesHeight).forEach { tileY in
            let position = Position(x: tileX * 10, z: tileY * 10, y: 0)

            let isVerticalRoad = Float(tileX).remainder(dividingBy: 4) == 0
            let isHorizontalRoad = Float(tileY).remainder(dividingBy: 4) == 0
            let isCrossroad = isVerticalRoad && isHorizontalRoad

            func random(max: Int) -> Int {
                return Int(arc4random_uniform(UInt32(max))) + 1
            }

            func randomColor() -> Color {
                return Color(rawValue: Int(arc4random_uniform(7)) + 30) ?? .blue
            }

            func randomHouse() -> Tile {
                let randomIsBig = arc4random_uniform(7) == 1
                return .house(isBig: randomIsBig, floorsCount: random(max: 4), color: randomColor())
            }

            func randomPyramid() -> Tile {
                return .pyramid(color: randomColor(), floorHeight: random(max: 3))
            }

            func randomStructure() -> Tile {
                return arc4random_uniform(5) == 1 ? randomPyramid() : randomHouse()
            }

            let tile: Tile = isCrossroad ? .crossroad :
                isVerticalRoad ? .road(horizontal: false) :
                isHorizontalRoad ? .road(horizontal: true) :
                randomStructure()

            tile.build(world: &world, position: position)
        }
    }

    // Trees
    world[0].enumerated().forEach { (rowIndex, row) in
        row.enumerated().forEach { (blockIndex, block) in
            if block?.character == "." && arc4random_uniform(20) == 1 {
                fill(world: &world, size: Size(width: 1, depth: 1, height: Int(arc4random_uniform(5)) + 2), position: Position(x: blockIndex, z: rowIndex, y: 1), block: Block(color: arc4random_uniform(2) == 1 ? Color.green : Color.yellow, character: "^"))
            }
        }
    }

    return world
}
