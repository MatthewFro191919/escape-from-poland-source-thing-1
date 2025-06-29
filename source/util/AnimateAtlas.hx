package util;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.Json;
import openfl.geom.Rectangle;
import openfl.geom.Point;

class AnimateAtlas
{
    public static function buildFrames(
        image:FlxGraphic,
        spritemapData:Dynamic,
        animationData:Dynamic
    ):FlxAtlasFrames
    {
        var frames = new FlxAtlasFrames(image);
        var spriteMap = spritemapData.ATLAS.SPRITES;
        var spriteIndex = new Map<String, FlxFrame>();

        // Add all frames from the spritemap
        for (entry in spriteMap)
        {
            var spr = entry.SPRITE;
            var rect = new Rectangle(spr.x, spr.y, spr.w, spr.h);
            var name = spr.name + ".png";
            var frame = frames.addAtlasFrame(rect, new Point(0, 0), name);
            spriteIndex.set(spr.name, frame);
        }

        // Parse timeline animation data
        var topLayer = animationData.AN.TL.L[0];
        var frameAnims = new Map<String, Array<String>>();

        for (frame in topLayer.FR)
        {
            for (element in frame.E)
            {
                var symbol = element.SI.SN;
                var tag = symbol.split("/").pop();
                if (!frameAnims.exists(tag)) frameAnims.set(tag, []);
                var spriteName = symbol;
                var matched = ~/Parts\/(.+)/;
                if (matched.match(spriteName))
                {
                    spriteName = matched.matched(1);
                }
                frameAnims.get(tag).push(spriteName);
            }
        }

        // Add animations to FlxAtlasFrames
        for (animName in frameAnims.keys())
        {
            var frameNames = frameAnims.get(animName);
            var flxFrames:Array<FlxFrame> = [];
            for (frameName in frameNames)
            {
                if (spriteIndex.exists(frameName))
                    flxFrames.push(spriteIndex.get(frameName));
            }

            if (flxFrames.length > 0)
                frames.addSpriteSheetAnimation(animName, flxFrames, 24);
        }

        return frames;
    }
}
