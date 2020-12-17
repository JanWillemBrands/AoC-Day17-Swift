import Foundation

let home = FileManager.default.homeDirectoryForCurrentUser

let fileURL = home
    .appendingPathComponent("Documents")
    .appendingPathComponent("cubes")
    .appendingPathExtension("txt")

var lines = [Substring]()
do {
    let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
    lines = fileContents.split(omittingEmptySubsequences: true, whereSeparator: \.isNewline)
}
catch {
    print("Could not read from \(fileURL.absoluteString)")
}

let offset = 7
let startSize = 8
let spaceSize = 22
var newSpace: [[[[Bool]]]] = Array(repeating: Array(repeating: Array(repeating: Array(repeating: false, count: spaceSize), count: spaceSize), count: spaceSize), count: spaceSize)

struct Frame {  // a hyper-rectangle that spans all active cubes
    var x_min = offset
    var x_max = offset+startSize
    var y_min = offset
    var y_max = offset+startSize
    var z_min = offset
    var z_max = offset
    var w_min = offset
    var w_max = offset
}

var y = 0
for line in lines {
    let chars = Array(line)
    var x = 0
    for c in chars {
        if c == "#" { newSpace[0+offset][0+offset][y+offset][x+offset] = true }
        x += 1
    }
    y += 1
}

func neighbors(_ x: Int, _ y: Int, _ z: Int, _ w: Int) -> Int {
    var activeNeighbors = 0
    for dx in -1...1 {
        for dy in -1...1 {
            for dz in -1...1 {
                for dw in -1...1 {
                    if space[w+dw][z+dz][y+dy][x+dx] { activeNeighbors += 1 }
                }
            }
        }
    }
    if space[w][z][y][x] { activeNeighbors -= 1 }
    return activeNeighbors
}

func actives() -> Int {
    var n = 0
    for x in 0..<spaceSize {
        for y in 0..<spaceSize {
            for z in 0..<spaceSize {
                for w in 0..<spaceSize {
                    if newSpace[w][z][y][x] { n += 1 }
                }
            }
        }
    }
    return n
}

func updateNewFrame(_ x: Int, _ y: Int, _ z: Int, _ w: Int) {
    newFrame.x_min = min(newFrame.x_min, x)
    newFrame.x_max = max(newFrame.x_max, x)
    newFrame.y_min = min(newFrame.y_min, y)
    newFrame.y_max = max(newFrame.y_max, y)
    newFrame.z_min = min(newFrame.z_min, z)
    newFrame.z_max = max(newFrame.z_max, z)
    newFrame.w_min = min(newFrame.w_min, w)
    newFrame.w_max = max(newFrame.w_max, w)
}

var start = Date()

var space = newSpace
var newFrame = Frame()
var frame = newFrame
for _ in 0..<6 {
    for x in frame.x_min-1...frame.x_max+1 {
        for y in frame.y_min-1...frame.y_max+1 {
            for z in frame.z_min-1...frame.z_max+1 {
                for w in frame.w_min-1...frame.w_max+1 {
                    let n = neighbors(x, y, z, w)
                    if space[w][z][y][x] {
                        if n != 2 && n != 3 { newSpace[w][z][y][x] = false }
                    } else {
                        if n == 3 {
                            newSpace[w][z][y][x] = true
                            updateNewFrame(x,y,z,w)
                       }
                    }
                }
            }
        }
    }
    frame = newFrame
    space = newSpace
}

print(actives())
print(Date().timeIntervalSince(start))
