
import Foundation

let world = makeWorld(tilesWidth: 150, tilesHeight: 150)
var offsetX = 1500
var offsetY = 0
while true {
    draw(world: world, offsetX: offsetX, offsetY: offsetY)
    offsetX -= 1
    offsetY += 2
}
