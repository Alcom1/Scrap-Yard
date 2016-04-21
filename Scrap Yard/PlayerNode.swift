import SpriteKit

class PlayerNode: SKSpriteNode, CustomNodeEvents
{
    var targetAngle = CGFloat(π / 2)    //Angle to rotate to
    var currentAngle = CGFloat(π / 2)   //Current angle
    var rotSpeed = π / 2                //Speed that the player rotates at
    
    //Init
    init()
    {
        super.init(
            texture: SKTexture(imageNamed: "square"),
            color: UIColor(),
            size: CGSize(width: 50, height: 25))
        
        self.position = center + CGPoint(x: 0, y: 350)
        self.zRotation = (self.position - center).angle
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //DMTS
    func didMoveToScene()
    {

    }
    
    //Update
    func update(dt: CGFloat)
    {
        //Rotate player to target
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
    
    //Set the angle that the player rotates to
    func setPosAndRot(position: CGPoint)
    {
        targetAngle = (position - center).angle
    }
}
