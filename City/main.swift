
import Foundation

let world = makeWorld(tilesWidth: 50, tilesHeight: 50)
var offsetX = 500
var offsetY = 0
while true {
    draw(world: world, offsetX: offsetX, offsetY: offsetY)
    offsetX -= 1
    offsetY += 2
}
