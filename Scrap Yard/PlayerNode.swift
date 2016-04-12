import SpriteKit

class PlayerNode: SKSpriteNode, CustomNodeEvents
{
    var targetAngle = CGFloat(0.0)
    var currentAngle = CGFloat(0.0)
    
    init()
    {
        super.init(
            texture: SKTexture(imageNamed: "square"),
            color: UIColor(),
            size: CGSize(width: 40, height: 20))
        
        self.position = center + CGPoint(x: 0, y: 350)
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
            currentAngle = targetAngle
            self.position = center + CGPoint(angle: currentAngle, mag: 350)
            self.zRotation = currentAngle
        }
    }
    
    func setPosAndRot(position: CGPoint)
    {
        print((position - center).angle)
        targetAngle = (position - center).angle
    }
}
