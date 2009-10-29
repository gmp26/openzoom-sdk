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
package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.openzoom.flash.components.IsotypeDrawingBase;
	
	public class Lottery extends IsotypeDrawingBase
	{
		[Embed(source="../assets/Cates.swf", symbol="GoodOutcome")]
        public static var goodFace:Class;
        
        [Embed(source="../assets/Cates.swf", symbol="BadOutcome")]
		public static var badFace:Class;
		
        [Embed(source="../assets/Cates.swf", symbol="BetterWithTreatment")]
		public static var betterFace:Class;
		
       	[Embed(source="../assets/Cates.swf", symbol="BetterWithControl")]
		public static var worseFace:Class;

		public const textureThreshold:int = 6; // Use plain textures if more than 6 levels up

		public static var trap:Object = {}; 

		override public function sketch(result:DisplayObject, level:uint, col:uint, row:uint, context:*):void {
			
			var sprite:Sprite = new Sprite();
	
			var bmd:BitmapData;

			var hash:String = "("+level+":"+col+":"+row+")";
			var myTrap:Object = trap;
			if(myTrap[hash]) {
				trace("Already created this tile: "+hash);
				trace("old context="+ myTrap[hash]);
				trace("new context="+context);
			} 
			else {
				myTrap[hash] = context;
			}
			//trace("tile=",level, col, row);
			//trace("numLevels="+descriptor.numLevels);
			
			var useSprites:int = descriptor.numLevels - textureThreshold;			
			
			if(level > useSprites) {
				var count:int = Math.pow(2, descriptor.numLevels - level - 1);
				drawIconArrayOnSprite(sprite, count, level);
				bmd = new BitmapData(descriptor.tileWidth, descriptor.tileHeight, false, 0x000000);
				bmd.draw(sprite);
			}
			else {
				if(levelCache == null) {
					chooseWinner();
					createLevelCache();
				}
				bmd = (levelCache[level] as BitmapData).clone();
			}


			var label:TextField = new TextField();
			label.autoSize = TextFieldAutoSize.LEFT;
			label.htmlText = '<FONT COLOR="#FFFFFF">('+level+":"+col.toString(16)+":"+row.toString(16)+')</FONT>';
			
			if(tileContainsWinner(level, col, row)) {
				var s:Sprite = new Sprite();
				s.graphics.lineStyle(1, 0xffffff, 1.0);
				s.graphics.moveTo(0.5, 0.5);
				s.graphics.lineTo(0.5, descriptor.tileHeight-0.5);
				s.graphics.lineTo(descriptor.tileWidth-0.5, descriptor.tileHeight-0.5);
				s.graphics.lineTo(descriptor.tileWidth-0.5, 0.5);
				s.graphics.lineTo(0.5, 0.5);
				//bmd.draw(s);
				
				var winner:Sprite = new betterFace();
				var numlevs:uint = descriptor.numLevels - level - 1;
				var scaler:Number = 0.75*descriptor.tileWidth/winner.width;;
				while(numlevs--) scaler *= 0.5;
				
				var mask:uint = winMask(level);
				var rowOffset:uint = winRow & mask;
				var colOffset:uint = winCol & mask;
				trace("colOffset=",colOffset.toString(16),"rowOffset",rowOffset.toString(16));
				s.addChild(winner);
				winner.scaleX = winner.scaleY = scaler;
				winner.x = (colOffset+0.125)*descriptor.tileWidth/(mask+1);
				winner.y = (rowOffset+0.125)*descriptor.tileWidth/(mask+1);
				bmd.draw(s);
//				bmd.draw(winner, new Matrix(scaler, 0, 0, scaler, (colOffset+0.125)*descriptor.tileWidth/mask, (rowOffset+0.125)*descriptor.tileHeight/mask));
			}
			
			var scale:Number = 0.7 * descriptor.tileWidth / label.width;
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			m.translate(0.15*descriptor.tileWidth, (-label.height*scale + descriptor.tileHeight)/2);
			bmd.draw(label, m);

			var bmap:Bitmap = new Bitmap(bmd);
			(result as Bitmap).bitmapData = bmd;			
			
			//super.sketch(result, level, col, row, context);
		}
		
		private function drawIconArrayOnSprite(sprite:Sprite, count:int, lev:int):void {
			for(var i:int = 0; i < count; i++) {
				for(var j:int = 0; j < count; j++) {
					var smiley:Sprite = new badFace() as Sprite;
					smiley.width = descriptor.tileWidth * 0.75 / count;
					smiley.height = descriptor.tileHeight * 0.75 / count;
					smiley.x = (i * descriptor.tileWidth + (descriptor.tileWidth>>3))/count;
					smiley.y = (j * descriptor.tileHeight + (descriptor.tileHeight>>3))/count;
					sprite.addChild(smiley);
				}
			}				
		}
		
		/*
		 * Predraw and save tiles which are simply repeated in the coarser levels
		 */
		static private var levelCache:Array; /*of BitMapData */		
		
		private function createLevelCache():void {
			
			levelCache = [];
			var sprite:Sprite = new Sprite();
			
			var lev:int = descriptor.numLevels - textureThreshold + 1;
			var count:int = Math.pow(2, textureThreshold - 2);
			drawIconArrayOnSprite(sprite, count, lev);
			var levelMap:BitmapData = new BitmapData(descriptor.tileWidth, descriptor.tileHeight, false, 0x000000);
			levelMap.draw(sprite);
						
			while(--lev >= 0) {
				var level2Map:BitmapData;
				level2Map = new BitmapData(descriptor.tileWidth, descriptor.tileHeight, true, 0x000000);
				var midWidth:int = descriptor.tileWidth/2;
				var midHeight:int = descriptor.tileHeight/2;
				
				// Stamp the previous level 4 times at half size in the new level map
				var m:Matrix = new Matrix(0.5, 0, 0, 0.5, 0, 0);
				level2Map.draw(levelMap, m, null, BlendMode.NORMAL, null, true);
				m.translate(midWidth, 0);
				level2Map.draw(levelMap, m, null, BlendMode.NORMAL, null, true);
				m.translate(0,midHeight);
				level2Map.draw(levelMap, m, null, BlendMode.NORMAL, null, true);
				m.translate(-midWidth,0);
				level2Map.draw(levelMap, m, null, BlendMode.NORMAL, null, true);
				levelCache[lev] = level2Map;
				
				//trace("level ="+lev);
				levelMap = level2Map;
			}
		}
		
		/*
		 * Choose a lottery winner;
		 */
		private static var winRow:int = -1;
		private static var winCol:int = -1;  
		
		// Number of bits needed to store rows and columns
	    private static var rowBits:int = -1;
	    private static var colBits:int = -1;			
	    private static var rowMask:int = -1;
	    private static var colMask:int = -1;			

		private function chooseWinner():void {
			
			var rowTiles:uint = descriptor.height / descriptor.tileHeight;
			var colTiles:uint = descriptor.width / descriptor.tileWidth;
			
			// assume power of 2 dimensions for now
			if(rowBits < 0)
				rowBits = bitSize(rowTiles);			
			if(colBits < 0)
				colBits = bitSize(colTiles);
				
			rowMask = 0;
			for(var i:int = 0; i < rowBits; i++) {
				rowMask <<= 1;
				rowMask |= 1;
			}
				
			colMask = 0;
			for(i = 0; i < colBits; i++) {
				colMask <<= 1;
				colMask |= 1;
			}
				
			if(winCol < 0)
				winCol = Math.floor(Math.random() * colTiles);
			if(winRow < 0)
				winRow = Math.floor(Math.random() * rowTiles);

			//trace("height="+descriptor.height+" rowBits="+rowBits + " rowMask="+rowMask.toString(16));
			trace("winner= (1:"+winCol.toString(16)+":"+winRow.toString(16)+")");
		}

		private function tileContainsWinner(level:uint, col:uint, row:uint):Boolean {
			var wrow:int = winRow;
			var wcol:int = winCol;
			var lev:int = descriptor.numLevels - level - 1;
			while(lev-- > 0) {
				wrow >>= 1;
				wcol >>= 1;
			}
			return col==wcol && row==wrow;
		}

		private function winMask(level:uint):uint {
			var lev:int = descriptor.numLevels - level - 1;
			var mask:uint = 0;
			while(lev-- > 0) {
				mask <<= 1;
				mask |= 1;
			}
			trace("mask=",mask.toString(16));
			return mask;
		}

		private function bitSize(v:uint):int {
			var bits:int = 0;
			while(v != 0) {
				v >>= 1;
				bits++;
			}
			return bits;
		}

		private function bitMask(v:uint):int {
			var mask:int = 0;
			while(v != 0) {
				v >>= 1;
				mask <<= 1;
				mask |= 1;
			}
			return mask;
		}


	}
}