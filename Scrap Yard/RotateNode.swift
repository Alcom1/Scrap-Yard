import SpriteKit

class RotateNode: SKSpriteNode, CustomNodeEvents
{
    var rotSpeed: CGFloat?
    
    init(texture: SKTexture, size: CGSize, rotSpeed: CGFloat)
    {
        super.init(
            texture: texture,
            color: UIColor(),
            size: size)
        self.rotSpeed = rotSpeed
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
        zRotation += rotSpeed! * dt
    }
}
