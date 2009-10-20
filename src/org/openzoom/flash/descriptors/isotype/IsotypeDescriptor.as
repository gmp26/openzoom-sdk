////////////////////////////////////////////////////////////////////////////////
//
//  OpenZoom SDK
//
//  Version: MPL 1.1/GPL 3/LGPL 3
//
//  The contents of this file are subject to the Mozilla Public License Version
//  1.1 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at
//  http://www.mozilla.org/MPL/
//
//  Software distributed under the License is distributed on an "AS IS" basis,
//  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
//  for the specific language governing rights and limitations under the
//  License.
//
//  The Original Code is the OpenZoom SDK.
//
//  The Initial Developer of the Original Code is Daniel Gasienica.
//  Portions created by the Initial Developer are Copyright (c) 2007-2009
//  the Initial Developer. All Rights Reserved.
//
//  Contributor(s):
//    Daniel Gasienica <daniel@gasienica.ch>
//	  Mike Pearson <gmp26@cam.ac.uk>
//
//  Alternatively, the contents of this file may be used under the terms of
//  either the GNU General Public License Version 3 or later (the "GPL"), or
//  the GNU Lesser General Public License Version 3 or later (the "LGPL"),
//  in which case the provisions of the GPL or the LGPL are applicable instead
//  of those above. If you wish to allow use of your version of this file only
//  under the terms of either the GPL or the LGPL, and not to allow others to
//  use your version of this file under the terms of the MPL, indicate your
//  decision by deleting the provisions above and replace them with the notice
//  and other provisions required by the GPL or the LGPL. If you do not delete
//  the provisions above, a recipient may use your version of this file under
//  the terms of any one of the MPL, the GPL or the LGPL.
//
////////////////////////////////////////////////////////////////////////////////
package org.openzoom.flash.descriptors.isotype
{
	import flash.utils.getDefinitionByName;
	
	import org.openzoom.flash.components.IsotypeDrawingBase;
	import org.openzoom.flash.core.openzoom_internal;
	import org.openzoom.flash.descriptors.IImagePyramidDescriptor;
	import org.openzoom.flash.descriptors.IImagePyramidLevel;
	import org.openzoom.flash.descriptors.ImagePyramidLevel;
	import org.openzoom.flash.descriptors.ImagePyramidDescriptorBase;
	import org.openzoom.flash.descriptors.ImageSourceDescriptor;
	import org.openzoom.flash.utils.math.clamp;

	use namespace openzoom_internal;
	
	public class IsotypeDescriptor extends ImagePyramidDescriptorBase implements IImagePyramidDescriptor
	{
	    //--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------

		// use this instead of http: to locate clases which draw tiles at runtime
		// http: will still pull the tile from a file or web server
		public static const ISOTYPE_PROTOCOL:String = "tile";
			
	    private static const DEFAULT_IMAGE_SIZE:uint = 4096; //2^12
	    private static const DEFAULT_NUM_LEVELS:uint = 5;	 //ceil(log_2(DEFAULT_IMAGE_SIZE/DEFAULT_TILE_SIZE) 	
	    private static const DEFAULT_TILE_SIZE:uint = 256;
	    private static const DEFAULT_TILE_OVERLAP:uint = 0; 
	    private static const DEFAULT_BASE_LEVEL:uint = 8; //LOG_2(DEFAULT_TILE_SIZE);
	    
   	    //--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	
	    private var data:XML;
	    
	    // This variable stores an isotype drawing
	    public var drawing:IsotypeDrawingBase;
	    
	    
	    // And this is where we keep all our drawings
	    public static var drawingStore:Object = {};

		public function IsotypeDescriptor(uri:String, data:XML)
		{
			//super();
			//use namespace openzoom;
        	this.data = data
        	this.source = uri
        	parseXML(data)
  		}
  		
	    private function parseXML(data:XML):void
	    {
			_width = DEFAULT_IMAGE_SIZE;
			_height = DEFAULT_IMAGE_SIZE;
		 	_tileWidth = DEFAULT_TILE_SIZE;
		 	_tileHeight = DEFAULT_TILE_SIZE
			_type = "isotype";
			var _drawing:String;
			var _baseURL:String = "class:"; //indicates a local class file 
				 
			var xml:XML = data.isocanvas ? data.isocanvas[0] : null;
			if(xml != null && xml.length() == 1) {
			 	_width = xml.@width;
			 	_height = xml.@height;
			 	_tileWidth = xml.@tileWidth;
			 	_tileHeight = xml.@tileHeight;
			 	_drawing = xml.@drawing;
			 	
			}
			else 
				throw new Error("No isocanvas configuration");
	
			if(_drawing == null || _drawing=="")
				throw new Error("No isocanvas@drawing"); 
			
			var descriptor:ImageSourceDescriptor;
			descriptor = new ImageSourceDescriptor(source, _width, _height, _type);
			_sources.push(descriptor);
				
			var levelWidth:uint  = _tileWidth;
			var levelHeight:uint = _tileHeight;

	        for (var i:int = 0; levelWidth <= _width && levelHeight <= _height; i++)
	        {
	            var columns:uint = Math.ceil(levelWidth / _tileWidth)
	            var rows:uint = Math.ceil(levelHeight / _tileHeight)
	            var t:ImagePyramidLevel;
	            var level:IImagePyramidLevel =
	                    new ImagePyramidLevel(this, i, levelWidth, levelHeight, columns, rows)
	            addLevel(level);
	            levelWidth <<= 1;
	            levelHeight <<= 1;
	        }
	        _numLevels = i;

			// Create the drawing
			var drawingClass:Class = getDefinitionByName(_drawing) as Class;
			drawing = new drawingClass();
			drawing.descriptor = this;
			
			// The IsotypeDisplayObjectRequest is responsible for returning tiles for drawings created here,
			// so it needs to be able to look them up.
			drawingStore[_drawing] = drawing;
			drawing.baseURL =  ISOTYPE_PROTOCOL + "://" + _drawing;
	        
	    }

		private var _sources:Array = [];
					
	    /**
	     * @inheritDoc
	     */
	    public function getLevelForSize(width:Number, height:Number):IImagePyramidLevel
	    {
	        var longestSide:Number = Math.max(width, height);
	        var log2:Number = Math.log(longestSide) * Math.LOG2E;
	        var maxLevel:uint = numLevels - 1;
	        var index:uint = clamp(Math.floor(log2) - Math.floor(Math.log(Math.max(_tileHeight, _tileWidth))*Math.LOG2E), 0, maxLevel);
	        var level:IImagePyramidLevel = getLevelAt(index);
	
	        return level;
	    }
		
		public function getTileURL(level:int, column:int, row:int):String
		{
			return drawing.baseURL + "-" + level + "-" + column + "-"+row;
		}
		
    	/**
     	* @inheritDoc
     	*/
    	public function clone():IImagePyramidDescriptor
    	{
        	return new IsotypeDescriptor(source, data.copy());
    	}
 	}
}

