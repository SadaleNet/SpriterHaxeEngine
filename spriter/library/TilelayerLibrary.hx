package spriter.library;
import aze.display.SparrowTilesheet;
import aze.display.TileGroup;
import aze.display.TileLayer;
import aze.display.TileSprite;
import flash.display.Sprite;
import flash.geom.Point;
import openfl.Assets;
import spriter.definitions.PivotInfo;
import spriter.definitions.SpatialInfo;
import spriter.util.SpriterUtil;

/**
 * Advanced OpenFL renderer using Texture Atlas thanks to Tilelayer (https://github.com/elsassph/openfl-tilelayer)
 * @author Loudo
 */
class TilelayerLibrary extends AbstractLibrary
{
	/**
	 * Tilelayer used for rendering
	 */
	var _layer:TileLayer;
	
	/**
	 * Sprite where we render
	 */
	var _canvas:Sprite;
	
	var _currentSpatialResult:SpatialInfo;
	
	/**
	 * Advanced OpenFL renderer using Texture Atlas thanks to Tilelayer (https://github.com/elsassph/openfl-tilelayer)
	 * 
	 * @param	dataPath .xml of the atlas
	 * @param	atlasPath .png of the atlas
	 * @param	canvas rendering Sprite
	 */
	public function new(dataPath:String = "", atlasPath:String = "", canvas:Sprite) 
	{
		super(dataPath);
		_canvas = canvas;
		
		var sheetData = Assets.getText(dataPath);
		var tilesheet = new SparrowTilesheet(Assets.getBitmapData(atlasPath), sheetData);
		_layer = new TileLayer(tilesheet, true);
		_canvas.addChild(_layer.view); // layer is NOT a DisplayObject
	}
	
	override public function getFile(name:String):Dynamic
	{
		return new TileSprite(_layer, name);
	}
	
	override public function clear():Void
	{
		_layer.removeAllChildren();//TODO destroy ? pool ?
	}
	
	override public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		
		var sprite:TileSprite = getFile(name);
		_layer.addChild(sprite);
		
		_currentSpatialResult = compute(info, pivots, sprite.width, sprite.height);
		
		
		//sprite.offset = getPivotsRelativeToCenter(info, pivots, sprite.width, sprite.height);//TOFIX tilelayer seems buggy
		sprite.x =  _currentSpatialResult.x;
		sprite.y =  _currentSpatialResult.y;
		sprite.rotation = SpriterUtil.toRadians(SpriterUtil.fixRotation(_currentSpatialResult.angle));
		sprite.scaleX = _currentSpatialResult.scaleX;
		sprite.scaleY = _currentSpatialResult.scaleY;
		sprite.alpha = _currentSpatialResult.a;
		
		_currentSpatialResult.put();//back to pool
	}
	
	private function getPivotsRelativeToCenter(info:SpatialInfo, pivots:PivotInfo, width:Float, height:Float):Point
	{
		var x:Float = (pivots.pivotX - 0.5) * width * info.scaleX;
		var y:Float = (0.5 - pivots.pivotY) * height * info.scaleY;
		return new Point(x, y);
	}
	
	//overrided because tilelayer use the center of the sprite for the coordinates
	override public function compute(info:SpatialInfo, pivots:PivotInfo, width:Float, height:Float):SpatialInfo
	{
		var degreesUnder360 = SpriterUtil.under360(info.angle);
		var rad = SpriterUtil.toRadians(degreesUnder360);
		var s = Math.sin(rad);
		var c = Math.cos(rad);
		
		var pivotX =  info.x;
		var pivotY =  info.y;
		
		var preX = info.x - pivots.pivotX * width * info.scaleX + 0.5 * width * info.scaleX;
		var preY = info.y + (1 - pivots.pivotY) * height * info.scaleY - 0.5 * height * info.scaleY;
		
		var x2 = (preX - pivotX) * c - (preY - pivotY) * s + pivotX;
        var y2 = (preX - pivotX) * s + (preY - pivotY) * c + pivotY;
		
		return SpatialInfo.get(x2, -y2, degreesUnder360, info.scaleX, info.scaleY, info.a, info.spin);
	}
	
	override public function render():Void
	{
		_layer.render();
	}
	
	override public function destroy():Void
	{
		clear();
		if (_layer.view != null && _layer.view.parent != null)
			_layer.view.parent.removeChild(_layer.view);
		_layer = null;
		_canvas = null;
	}
	
	
	
}