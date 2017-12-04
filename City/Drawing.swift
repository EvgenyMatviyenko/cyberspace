
import Foundation

private enum ScreenCell {
    case some(color: Color, character: Character)
    case none
}

private typealias Grid = [[ScreenCell]]

private func draw(grid: Grid) -> String {
    let formattedRows = grid.enumerated().map { (rowIndex, row) -> String in
        let formattedRow = row.map { cell -> String in
            switch cell {
            case .some(let color, let character):
                return "\u{001B}[0;\(color.rawValue)m\(character)"
            case .none:
                return " "
            }
            }.map { " \($0)" }

        return formattedRow.joined()
    }

    return formattedRows.joined(separator: "\n")
}

func draw(world: World, width: Int = 60, height: Int = 40, offsetX: Int = 0, offsetY: Int = 0) {
    var grid = Grid(repeating: [ScreenCell](repeating: .none, count: width), count: height)

    // Place world
    (0..<world.height).forEach { y in
        let zWorldOffset = offsetY
        (zWorldOffset..<zWorldOffset + height + world.height).forEach { z in
            let xWorldOffset = offsetX + z
            (xWorldOffset..<xWorldOffset + width).forEach { x in
                let i = z - y - offsetY
                let j = x - z - offsetX
                let position = Position(x: x, z: z, y: y)
                if let block = world.block(at: position), (0..<height).contains(i), (0..<width).contains(j) {
                    grid[i][j] = ScreenCell.some(color: block.color, character: block.character)
                }
            }
        }
    }

    // Place frame
    (0..<width).forEach { x in
        (0..<height).forEach { y in
            if x == 0 || x == width - 1 || y == 0 || y == height - 1 {
                grid[y][x] = .some(color: .red, character: "@")
            }
        }
    }

    print(draw(grid: grid))
}
