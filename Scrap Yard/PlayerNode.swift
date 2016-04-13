import SpriteKit

class PlayerNode: SKSpriteNode, CustomNodeEvents
{
    var targetAngle = CGFloat(0.0)
    var currentAngle = CGFloat(0.0)
    var rotSpeed = π / 2
    
    init()
    {
        super.init(
            texture: SKTexture(imageNamed: "square"),
            color: UIColor(),
            size: CGSize(width: 40, height: 20))
        
        self.position = center + CGPoint(x: 350, y: 0)
        self.zRotation = (self.position - center).angle
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didMoveToScene()
    {

    }
    
    func update(dt: CGFloat)
    {
        if(currentAngle != targetAngle)
        {
            let shortest = shortestAngleBetween(
                targetAngle,
                angle2: currentAngle)
            let amtToRotate = self.rotSpeed * dt
            if(abs(shortest) < amtToRotate)
            {
                currentAngle -= shortest;
            }
            else
            {
                currentAngle -= amtToRotate * CGFloat(sign(Float(shortest)))
            }
            
            self.position = center + CGPoint(angle: currentAngle, mag: 350)
            self.zRotation = currentAngle
        }
    }
    
    func setPosAndRot(position: CGPoint)
    {
        targetAngle = (position - center).angle
    }
}
