import SpriteKit

//Node for any passive rotating objects
class RotateNode: SKSpriteNode, CustomNodeEvents
{
    var rotSpeed: CGFloat?  //Rotational speed of the object
    
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
    
    //DMTS
    func didMoveToScene()
    {
        
    }
    
    //Update
    func update(dt: CGFloat)
    {
        zRotation += rotSpeed! * dt
    }
}
