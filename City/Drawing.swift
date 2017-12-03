
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

func draw(world: BlockWorld, width: Int = 60, height: Int = 40, offsetX: Int = 0, offsetY: Int = 0) {
    var grid = Grid(repeating: [ScreenCell](repeating: .none, count: width), count: height)

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
                    grid[i][j] = .some(color: block.color, character: block.character)
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
