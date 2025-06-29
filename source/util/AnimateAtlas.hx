package util;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import haxe.Json;

class AnimateAtlas
{
    public static function buildFrames(
        image:FlxGraphic,
        spritemapData:Dynamic,
        animationData:Dynamic
    ):FlxAtlasFrames
    {
        var frames = new FlxAtlasFrames(image);
        var spriteMap:Array<Dynamic> = cast spritemapData.ATLAS.SPRITES;
        var spriteIndex = new Map<String, FlxFrame>();

        // Add all frames from the spritemap
        for (entry in spriteMap)
        {
            var spr = entry.SPRITE;
            var rect = new FlxRect(spr.x, spr.y, spr.w, spr.h);
            var name = spr.name + ".png";
            var frame = frames.addAtlasFrame(rect, new FlxPoint(0, 0), new FlxPoint(spr.w, spr.h));
            frame.name = name;
            spriteIndex.set(spr.name, frame);
        }

        // Also include Symbol Definitions if present
        var symbols:Array<Dynamic> = cast animationData.SD.S;
        for (symbol in symbols)
        {
            var name:String = symbol.SN.split("/").pop();
            var symbolFrames:Array<String> = [];

            if (symbol.TL != null && symbol.TL.L != null)
            {
                var layers:Array<Dynamic> = cast symbol.TL.L;
                for (layer in layers)
                {
                    var layerFrames:Array<Dynamic> = cast layer.FR;
                    for (frame in layerFrames)
                    {
                        var elements:Array<Dynamic> = cast frame.E;
                        for (element in elements)
                        {
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
            for (frameName in symbolFrames)
            {
                if (spriteIndex.exists(frameName))
                    flxFrames.push(spriteIndex.get(frameName));
            }

            // Add each frame individually into the FlxAtlasFrames collection
            for (i in 0...flxFrames.length)
            {
                frames.pushFrame(flxFrames[i]);
            }
        }

        return frames;
    }
}
