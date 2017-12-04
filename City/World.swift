
import Foundation

protocol World {
    var height: Int { get }
    func block(at position: Position) -> Block?
}

struct _World: World {
    let height: Int
    private let width: Int
    private let depth: Int

    private let blockWorld: BlockWorld

    init(blockWorld: BlockWorld) {
        self.blockWorld = blockWorld
        self.height = blockWorld.count
        self.width = blockWorld[0][0].count
        self.depth = blockWorld[0].count
    }

    func block(at position: Position) -> Block? {
        guard position.x < width && position.z < depth && position.y < height && position.x >= 0 && position.z >= 0 && position.y >= 0 else {
            return nil
        }

        return blockWorld[position.y][position.z][position.x]
    }
}
