////////////////////////////////////////////////////////////////////////////////
//
//  OpenZoom
//
//  Copyright (c) 2007–2008, Daniel Gasienica <daniel@gasienica.ch>
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
package org.openzoom.flash.viewport.constraints
{

import flash.geom.Point;

import org.openzoom.flash.viewport.IReadonlyViewport;
import org.openzoom.flash.viewport.IViewportConstraint;

public class DefaultViewportConstraint implements IViewportConstraint
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    private static const DEFAULT_MIN_ZOOM : Number = 0.25
    private static const DEFAULT_MAX_ZOOM : Number = 10000
	private static const BOUNDS_TOLERANCE : Number = 0.5
	
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
    public function DefaultViewportConstraint()
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties: IViewportConstraint
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  minZoom
    //----------------------------------

    protected var _minZoom : Number = DEFAULT_MIN_ZOOM

    public function get minZoom() : Number
    {
        return _minZoom
    }

    public function set minZoom( value : Number ) : void
    {
        _minZoom = value
    }

    //----------------------------------
    //  maxZoom
    //----------------------------------
    
    protected var _maxZoom : Number = DEFAULT_MAX_ZOOM
    
    public function get maxZoom() : Number
    {
        return _maxZoom
    }
    
    public function set maxZoom( value : Number ) : void
    {
       _maxZoom = value
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: IViewportConstraint
    //
    //--------------------------------------------------------------------------
    
    public function computePosition( viewport : IReadonlyViewport ) : Point
    {
    	var x : Number = viewport.x
    	var y : Number = viewport.y
    	
    	// content is wider than viewport
        if( viewport.width < 1 )
        {
            // horizontal bounds checking:
            // the viewport sticks out on the left:
            // align it with the left margin
            if( viewport.x + viewport.width * BOUNDS_TOLERANCE < 0 )
                x = -viewport.width * BOUNDS_TOLERANCE
    
           // the viewport sticks out on the right:
           // align it with the right margin
           if(( viewport.x + viewport.width * ( 1 - BOUNDS_TOLERANCE )) > 1 )
               x = 1 - viewport.width * ( 1 - BOUNDS_TOLERANCE )      
        }
        else
        {
            // viewport is wider than content:
            // center scene horizontally
            x = ( 1 - viewport.width ) * 0.5
        }
    
        // scene is taller than viewport
        if( viewport.height < 1 )
        {
            // vertical bounds checking:
            // the viewport sticks out at the top:
            // align it with the top margin
            if( viewport.y + viewport.height * BOUNDS_TOLERANCE < 0 )
                y = -viewport.height * BOUNDS_TOLERANCE
        
            // the viewport sticks out at the bottom:
            // align it with the bottom margin
            if( viewport.y + viewport.height * (1 - BOUNDS_TOLERANCE) > 1 )
                y = 1 - viewport.height * ( 1 - BOUNDS_TOLERANCE )
        }
        else
        {
            // viewport is taller than scene
            // center scene vertically
            y = ( 1 - viewport.height ) * 0.5
        }
        
        return new Point( x, y )
    }
}

}