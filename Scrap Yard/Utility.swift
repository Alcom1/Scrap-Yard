
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import CoreGraphics
import SpriteKit


// www.codingexplorer.com/create-uicolor-swift/
extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

func randomBool() -> Bool
{
    return arc4random_uniform(2) == 0 ? true: false
}


func + (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (inout left: CGPoint, right: CGPoint)
{
    left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (inout left: CGPoint, right: CGPoint)
{
    left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (inout left: CGPoint, right: CGPoint)
{
    left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (inout point: CGPoint, scalar: CGFloat)
{
    point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (inout left: CGPoint, right: CGPoint)
{
    left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (inout point: CGPoint, scalar: CGFloat)
{
    point = point / scalar
}

func * (vector: CGVector, scalar: CGFloat) -> CGVector
{
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

func / (vector: CGVector, scalar: CGFloat) -> CGVector
{
    return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func atan2(y: CGFloat, x: CGFloat) -> CGFloat
    {
        return CGFloat(atan2f(Float(y), Float(x)))
    }
    
    func sqrt(a: CGFloat) -> CGFloat
    {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint
{
    init(angle: CGFloat, mag: CGFloat)
    {
        x = mag * cos(angle)
        y = mag * sin(angle)
    }
    
    func length() -> CGFloat
    {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint
    {
        return self / length()
    }
    
    var angle: CGFloat
    {
        return atan2(y, x)
    }
    
    func toCGVector() -> CGVector
    {
        return CGVector(dx: x, dy: y)
    }
}

extension CGVector
{
    func length() -> CGFloat
    {
        return sqrt(dx*dx + dy*dy)
    }
    
    func normalized() -> CGVector
    {
        return self / length()
    }
    
    var angle: CGFloat
    {
        return atan2(dy, dx)
    }
    
    func toCGPoint() -> CGPoint
    {
        return CGPoint(x: dx, y: dy)
    }
}

let π = CGFloat(M_PI)

let center = CGPoint(x: 384, y: 512)

//Number of levels in game
let levelCount = 6

//Rate at which stars are lost when an escaper escapes for each level
let levelCurve = [3, 2, 2, 2, 1, 1]

func shortestAngleBetween(
    angle1: CGFloat,
    angle2: CGFloat) -> CGFloat
{
        let twoπ = π * 2.0
        var angle = (angle2 - angle1) % twoπ
        if (angle >= π)
        {
            angle = angle - twoπ
        }
        if (angle <= -π)
        {
            angle = angle + twoπ
        }
        return angle
}

extension CGFloat
{
    func sign() -> CGFloat
    {
        return (self >= 0.0) ? 1.0 : -1.0
    }
    
    func toDegrees() -> CGFloat
    {
        return self * 180 / π
    }
}

extension CGFloat
{
    static func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    static func random(min min: CGFloat, max: CGFloat) -> CGFloat
    {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}



//Generate an array of points arranged in a circle
func polygonPointArray(
    sides: Int,
    x: CGFloat,
    y: CGFloat,
    radius: CGFloat) -> [CGPoint]
{
    
    var points = [CGPoint]()
    for(var i = 0; i < sides; i++)
    {
        points.append(
            CGPoint(
                x: x + radius * cos(2.0 * π * CGFloat(i) / CGFloat(sides)),
                y: y + radius * sin(2.0 * π * CGFloat(i) / CGFloat(sides))))
    }
    return points
}

//Generate a path of a regular polygon
func polygonPath(x: CGFloat, y: CGFloat, radius: CGFloat, sides: Int) -> CGPathRef
{
    let path = CGPathCreateMutable()
    let points = polygonPointArray(sides, x: x, y: y, radius: radius)
    let cpg = points[0]
    CGPathMoveToPoint(path, nil, cpg.x, cpg.y)
    for p in points
    {
        CGPathAddLineToPoint(path, nil, p.x, p.y)
    }
    CGPathCloseSubpath(path)
    return path
}

import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String)
{
    let resourceUrl = NSBundle.mainBundle().URLForResource(
        filename,
        withExtension: nil)
    
    guard let url = resourceUrl else
    {
        print("Could not find file: \(filename)")
        return
    }
    do
    {
        try backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }
    catch
    {
        print("Could not create audio player!")
        return
    }
}