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
package org.openzoom.flash.components
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	import org.openzoom.flash.descriptors.isotype.IsotypeDescriptor;

	/**
	 * IsotypeDrawing is a base class for all drawings which create large arrays of isotypes.
	 * Isotypes are icons used to represent types of object in a statistical chart
	 * 
	 * See the Lottery.as example 
	 */
	public class IsotypeDrawingBase extends EventDispatcher
	{
		public var baseURL:String; // initialised to reference the drawing class in the descriptor
		public var descriptor:IsotypeDescriptor;
		public var tileResult:DisplayObject; // the result of drawing on a tile
		
		private var context:*;
		
		public function IsotypeDrawingBase()
		{
			super();
		}
		
		public function sketch(result:DisplayObject, level:uint, col:uint, row:uint, context:*):void {
			// override me
			tileResult = result;
		}
		
		public function get bytesDrawn():uint {
			return 0;
		}
		
		public function get bytesTotal():uint {
			return descriptor.tileWidth * descriptor.tileWidth / 8;
		}
		
	}
}