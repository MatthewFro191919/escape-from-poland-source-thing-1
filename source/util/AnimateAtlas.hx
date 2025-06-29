package util;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxRect;
import haxe.Json;
import openfl.geom.Point;

class AnimateAtlas {
	public static function buildFrames(image:FlxGraphic, spritemapData:Dynamic, animationData:Dynamic):FlxAtlasFrames {
		var frames = new FlxAtlasFrames(image);
		var spriteMap:Array<Dynamic> = cast spritemapData.ATLAS.SPRITES;
		var spriteIndex = new Map<String, FlxFrame>();

		// Add all frames from the spritemap
		for (entry in spriteMap) {
			var spr = entry.SPRITE;
			var rect = new FlxRect(spr.x, spr.y, spr.w, spr.h);
			var name = spr.name + ".png";
			var frame = frames.addAtlasFrame(rect, new Point(0, 0), name);
			spriteIndex.set(spr.name, frame);
		}

		// Auto-detect and map animations from the top-level timeline
		var topLayer:Dynamic = animationData.AN.TL.L[0];
		var anims:Map<String, Array<String>> = new Map();

		var frameList:Array<Dynamic> = cast topLayer.FR;
		for (frame in frameList) {
			var elements:Array<Dynamic> = cast frame.E;
			for (element in elements) {
				var symbolPath:String = element.SI.SN;
				var tag = symbolPath.split("/").pop();
				if (!anims.exists(tag))
					anims.set(tag, []);
				anims.get(tag).push(tag);
			}
		}

		// Also include Symbol Definitions if present
		var symbols:Array<Dynamic> = cast animationData.SD.S;
		for (symbol in symbols) {
			var name:String = symbol.SN.split("/").pop();
			var symbolFrames:Array<String> = [];

			if (symbol.TL != null && symbol.TL.L != null) {
				var layers:Array<Dynamic> = cast symbol.TL.L;
				for (layer in layers) {
					var layerFrames:Array<Dynamic> = cast layer.FR;
					for (frame in layerFrames) {
						var elements:Array<Dynamic> = cast frame.E;
						for (element in elements) {
							var frameName = null;
							if (element.SI != null)
								frameName = element.SI.SN.split("/").pop();
							else if (element.ASI != null)
								frameName = element.ASI.N;

							if (frameName != null)
								symbolFrames.push(frameName);
						}
					}
				}
			}

			var flxFrames:Array<FlxFrame> = [];
			for (frameName in symbolFrames) {
				if (spriteIndex.exists(frameName))
					flxFrames.push(spriteIndex.get(frameName));
			}

			if (flxFrames.length > 0) {
				frames.frames[name] = flxFrames;
			}
		}

		return frames;
	}
}
