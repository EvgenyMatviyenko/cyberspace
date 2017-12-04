
import Foundation

let world = makeWorld(tilesWidth: 50, tilesHeight: 50)
var offsetX = 0
var offsetY = 0
while true {
    draw(world: _World(blockWorld: world), offsetX: offsetX, offsetY: offsetY)
    offsetX -= 1
    offsetY += 2
}
