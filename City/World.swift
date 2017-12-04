
import Foundation

protocol World {
    var height: Int { get }
    func block(at position: Position) -> Block?
}

struct InfiniteWorld: World {
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
        return blockWorld[mod(position.y, height)][mod(position.z, depth)][mod(position.x, width)]
    }

    private func mod(_ a: Int, _ n: Int) -> Int {
        let r = a % n
        return r >= 0 ? r : r + n
    }
}
