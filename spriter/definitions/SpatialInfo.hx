package spriter.definitions;
import spriter.interfaces.ISpriterPooled;
import spriter.util.SpriterPool;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author Loudo
 */
class SpatialInfo implements ISpriterPooled 
{
	public var x:Float=0; 
    public var y:Float=0; 
    public var angle:Float=0;
    public var scaleX:Float=1; 
    public var scaleY:Float=1; 
	/**
	 * Alpha
	 */
    public var a:Float=1;
    public var spin:Int = 1;
	
	private static var _pool = new SpriterPool<SpatialInfo>(SpatialInfo);
	private var _inPool:Bool = false;
	
	/**
	 * Recycle or create a new SpatialInfo. 
	 * Be sure to put() them back into the pool after you're done with them!
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @return	This point.
	 */
	public static inline function get(x:Float = 0, y:Float = 0, angle:Float = 0, scaleX:Float = 1, scaleY:Float = 1, a:Float = 1, spin:Int = 1):SpatialInfo
	{
		var pooledInfo = _pool.get().init(x, y, angle, scaleX, scaleY, a, spin);
		pooledInfo._inPool = false;
		return pooledInfo;
	}
	
	public function new(x:Float = 0, y:Float = 0, angle:Float = 0, scaleX:Float = 1, scaleY:Float = 1, a:Float = 1, spin:Int = 1) 
	{
		this.x = x; 
		this.y = y; 
		this.angle = angle;
		this.scaleX = scaleX; 
		this.scaleY = scaleY; 
		this.a = a;
		this.spin = spin;
	}
	
	public function init(x:Float = 0, y:Float = 0, angle:Float = 0, scaleX:Float = 1, scaleY:Float = 1, a:Float = 1, spin:Int = 1):SpatialInfo
	{
		this.x = x; 
		this.y = y; 
		this.angle = angle;
		this.scaleX = scaleX; 
		this.scaleY = scaleY; 
		this.a = a;
		this.spin = spin;
		return this;
	}
	
	public function setPos(x:Float = 0, y:Float = 0):SpatialInfo
	{
		this.x = x; 
		this.y = y; 
		return this;
	}
	
	public function setScale(scale:Float):SpatialInfo
	{
		this.scaleX = scale; 
		this.scaleY = scale;
		return this;
	}
	
	public function unmapFromParent(parentInfo:SpatialInfo):SpatialInfo
    {
        var unmapped_x : Float;
		var unmapped_y : Float;
		var unmapped_angle = angle + parentInfo.angle;
		var unmapped_scaleX = scaleX * parentInfo.scaleX;
		var unmapped_scaleY = scaleY * parentInfo.scaleY;
		var unmapped_alpha = a * parentInfo.a;
		
		if (x != 0 || y != 0)
		{
			var preMultX = x * parentInfo.scaleX;
			var preMultY = y * parentInfo.scaleY;
			var parentRad = SpriterUtil.toRadians(SpriterUtil.under360(parentInfo.angle));
			var s = Math.sin(parentRad);
			var c = Math.cos(parentRad);
			
			unmapped_x = (preMultX * c) - (preMultY * s) + parentInfo.x;
			unmapped_y = (preMultX * s) + (preMultY * c) + parentInfo.y;
		}
		else
		{
			unmapped_x = parentInfo.x;
			unmapped_y = parentInfo.y;
		}
		
		return SpatialInfo.get(unmapped_x, unmapped_y, unmapped_angle, unmapped_scaleX, unmapped_scaleY, unmapped_alpha, spin);
    }
	
	public function copy():SpatialInfo
	{
		return SpatialInfo.get(x, y, angle, scaleX, scaleY, a, spin);
	}
	
	/*public function linear(infoA:SpatialInfo, infoB:SpatialInfo, spin:Int, t:Float):SpatialInfo
	{
		var resultInfo:SpatialInfo;
		resultInfo.x = linear(infoA.x,infoB.x,t); 
		resultInfo.y = linear(infoA.y,infoB.y,t);  
		resultInfo.angle = angleLinear(infoA.angle,infoB.angle,spin,t); 
		resultInfo.scaleX = linear(infoA.scaleX,infoB.scaleX,t); 
		resultInfo.scaleY = linear(infoA.scaleY,infoB.scaleY,t); 
		resultInfo.a = linear(infoA.a,infoB.a,t); 
	}*/
	/**
	 * Add this SpatialInfo to the recycling pool.
	 */
	public function put():Void
	{
		if (!_inPool)
		{
			_inPool = true;
			_pool.putUnsafe(this);
		}
	}
	public function destroy():Void
	{
		
	}
	
}