////////////////////////////////////////////////////////////////////////////////
//
//  OpenZoom
//
//  Copyright (c) 2007-2009, Daniel Gasienica <daniel@gasienica.ch>
//
//  OpenZoom is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  OpenZoom is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with OpenZoom. If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
package org.openzoom.flash.descriptors.deepzoom
{

import flash.geom.Point;
import flash.geom.Rectangle;

import org.openzoom.flash.descriptors.IImagePyramidDescriptor;
import org.openzoom.flash.descriptors.IImagePyramidLevel;
import org.openzoom.flash.descriptors.ImagePyramidDescriptorBase;
import org.openzoom.flash.descriptors.ImagePyramidLevel;
import org.openzoom.flash.utils.MIMEUtil;
import org.openzoom.flash.utils.math.clamp;

/**
 * Descriptor for the
 * <a href="http://msdn.microsoft.com/en-us/library/cc645077(VS.95).aspx">
 * Microsoft Deep Zoom Image (DZI) format</a>.
 */
public final class DeepZoomImageDescriptor extends ImagePyramidDescriptorBase
                                           implements IImagePyramidDescriptor
{
    //--------------------------------------------------------------------------
    //
    //  Namespaces
    //
    //--------------------------------------------------------------------------

    namespace deepzoom2008 = "http://schemas.microsoft.com/deepzoom/2008"
    namespace deepzoom2009 = "http://schemas.microsoft.com/deepzoom/2009"

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     */
    public function DeepZoomImageDescriptor(source:String,
                                            width:uint,
                                            height:uint,
                                            tileSize:uint,
                                            tileOverlap:uint,
                                            format:String,
                                            displayRects:Array=null,
                                            mortonNumber:uint=0,
                                            collection:DeepZoomCollectionDescriptor=null)
    {
        this.source = source
        _width = width
        _height = height
        _format = format
        _tileOverlap = tileOverlap
        _type = MIMEUtil.getContentType(format)
        _tileWidth = _tileHeight = tileSize
        _numLevels = getNumLevels(width, height)
        createLevels(width, height, tileWidth, tileHeight, numLevels)

        // Collection
        _mortonNumber = mortonNumber
        _collection = collection

        // Display Rects
        if (!displayRects)
            return

        for (var i:int = displayRects.length - 1; i >= 0; i--)
        {
            var rect:DisplayRect = displayRects[i] as DisplayRect

            for (var level:int = rect.minLevel; level <= rect.maxLevel; level++)
            {
                if (!levelRects[level])
                    levelRects[level] = []

                levelRects[level].push(rect)
            }
        }
    }

    /**
     * Create descriptor from XML.
     */
    public static function fromXML(source:String, xml:XML):DeepZoomImageDescriptor
    {
    	var ns:Namespace = deepzoom2008
    	
    	if (xml.namespace() == deepzoom2009)
            ns = deepzoom2009

        var width:uint = xml.ns::Size.@Width
        var height:uint = xml.ns::Size.@Height
        var tileSize:uint = xml.@TileSize
        var tileOverlap:uint = xml.@Overlap
        var format:String = xml.@Format

        var numDisplayRects:int = xml.ns::DisplayRects.ns::DisplayRect.length()
        var displayRects:Array = []

        for (var i:int = 0; i < numDisplayRects; i++)
        {
            var displayRect:XML = xml.ns::DisplayRects.ns::DisplayRect[i]
            displayRects.push(new DisplayRect(displayRect.ns::Rect.@X,
                                              displayRect.ns::Rect.@Y,
                                              displayRect.ns::Rect.@Width,
                                              displayRect.ns::Rect.@Height,
                                              displayRect.@MinLevel,
                                              displayRect.@MaxLevel))	
        }

        var descriptor:DeepZoomImageDescriptor =
                new DeepZoomImageDescriptor(source,
                                            width,
                                            height,
                                            tileSize,
                                            tileOverlap,
                                            format,
                                            displayRects)

        return descriptor
    }

    //--------------------------------------------------------------------------
    //
    //  Properties: Deep Zoom Image format specification
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  displayRects
    //----------------------------------

    private var levelRects:Object = {}

    //----------------------------------
    //  mortonNumber
    //----------------------------------

    private var _mortonNumber:uint = 0

    /**
     * Returns the Morton number of this image within the collection.
     * The Morton number is only valid if <code>collection</code> is not <code>null</code>.
     */
    public function get mortonNumber():uint
    {
    	return _mortonNumber
    }

    //----------------------------------
    //  collection
    //----------------------------------

    private var _collection:DeepZoomCollectionDescriptor

    /**
     * Returns the collection this image belongs to or null
     * if it does not belong to a collection.
     */
    public function get collection():DeepZoomCollectionDescriptor
    {
    	return _collection
    }

    //----------------------------------
    //  tileSize
    //----------------------------------

    /**
     * Returns the size of a single tile of the image pyramid in pixels.
     */
    public function get tileSize():uint
    {
        return _tileWidth
    }

    //----------------------------------
    //  format
    //----------------------------------

    private var _format:String

    /**
     * Returns the format of the image pyramid.
     */
    public function get format():String
    {
        return _format
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: IMultiScaleImageDescriptor
    //
    //--------------------------------------------------------------------------

    /**
     * @inheritDoc
     */
    public function getTileURL(level:int, column:int, row:int):String
    {
        if (collection && level <= collection.maxLevel)
            return collection.getTileURL(mortonNumber, level)

    	var basePath:String = source.substring(0, source.lastIndexOf("."))
        var path:String = basePath + "_files"
        return [path, "/", level, "/", column, "_", row, ".", format].join("")
    }

    /**
     * @inheritDoc
     */
    override public function existsTile(level:int, column:int, row:int):Boolean
    {
        var displayRects:Array = levelRects[level] as Array

        if (!displayRects)
            return true

        for (var i:int = displayRects.length - 1; i >= 0; i--)
        {
            var displayRect:DisplayRect = displayRects[i] as DisplayRect

            if (!(displayRect.minLevel <= level && level <= displayRect.maxLevel))
                continue

            var scale:Number = getScale(level)
            var minColunm:int = displayRect.x * scale
            var minRow:int = displayRect.y * scale
            var maxColumn:int = minColunm + displayRect.width * scale
            var maxRow:int = minRow + displayRect.height * scale
            minColunm = Math.floor(minColunm / tileSize)
            minRow = Math.floor(minRow / tileSize)
            maxColumn = Math.ceil(maxColumn / tileSize)
            maxRow = Math.ceil(maxRow / tileSize)

            var validHorizontal:Boolean = minColunm <= column && column < maxColumn
            var validVertical:Boolean = minRow <= row && row < maxRow

            if (validHorizontal && validVertical)
                return true
        }

        return false
    }

    /**
     * @inheritDoc
     */
    public function getLevelForSize(width:Number, height:Number):IImagePyramidLevel
    {
        var longestSide:Number = Math.max(width, height)
        var log2:Number = Math.log(longestSide) / Math.LN2
        var maxLevel:uint = numLevels - 1
        var index:int = clamp(Math.ceil(log2) + 1, 0, maxLevel)
        var level:IImagePyramidLevel = getLevelAt(index)

        var pixelRatio:Number = width / level.width
        if (pixelRatio < 0.5)
            level = getLevelAt(Math.max(0, index - 1))

        return level
    }

    /**
     * @inheritDoc
     */
    public function clone():IImagePyramidDescriptor
    {
        return new DeepZoomImageDescriptor(source,
                                           width,
                                           height,
                                           tileSize,
                                           tileOverlap,
                                           format)
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Debug
    //
    //--------------------------------------------------------------------------

    /**
     * @inheritDoc
     */
    override public function toString():String
    {
        return "[DeepZoomImageDescriptor]" + "\n" + super.toString()
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Internal
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function getNumLevels(width:Number, height:Number):int
    {
        return Math.ceil(Math.log(Math.max(width, height)) / Math.LN2) + 1
    }

    /**
     * @private
     */
    private function createLevels(originalWidth:uint,
                                  originalHeight:uint,
                                  tileWidth:uint,
                                  tileHeight:uint,
                                  numLevels:int):void
    {
        var maxLevel:int = numLevels - 1

        for (var index:int = 0; index <= maxLevel; index++)
        {
        	var size:Point = getSize(index)
        	var width:uint = size.x
        	var height:uint = size.y
        	var numColumns:int = Math.ceil(width / tileWidth)
        	var numRows:int = Math.ceil(height / tileHeight)
            var level:IImagePyramidLevel = new ImagePyramidLevel(this,
                                                                 index,
                                                                 width,
                                                                 height,
                                                                 numColumns,
                                                                 numRows)
            addLevel(level)
        }
    }

    /**
     * @private
     */
    private function getScale(level:int):Number
    {
    	var maxLevel:int = numLevels - 1
    	// 1 / (1 << maxLevel - level)
    	return Math.pow(0.5, maxLevel - level)
    }

    /**
     * @private
     */
    private function getSize(level:int):Point
    {
        var size:Point = new Point()
        var scale:Number = getScale(level)
        size.x = Math.ceil(width * scale)
        size.y = Math.ceil(height * scale)

        return size
    }
}

}

//------------------------------------------------------------------------------
//
//  Internal classes
//
//------------------------------------------------------------------------------

import flash.geom.Rectangle

/**
 * @private
 */
class DisplayRect extends Rectangle
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     */
    public function DisplayRect(x:Number,
                                y:Number,
                                width:Number,
                                height:Number,
                                minLevel:int,
                                maxLevel:int)
    {
        super(x, y, width, height)
        this.minLevel = minLevel
        this.maxLevel = maxLevel
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  minLevel
    //----------------------------------

    /**
     * @private
     */
    public var minLevel:int

    //----------------------------------
    //  maxLevel
    //----------------------------------

    /**
     * @private
     */
    public var maxLevel:int
}