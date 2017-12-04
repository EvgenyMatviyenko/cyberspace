
import Foundation

let world = makeWorld(tilesWidth: 2, tilesHeight: 2)
var offsetX = 0
var offsetY = 0
while true {
    draw(world: InfiniteWorld(blockWorld: world), offsetX: offsetX, offsetY: offsetY)
    offsetX -= 1
    offsetY += 2
}
