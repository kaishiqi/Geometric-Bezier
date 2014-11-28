package kaishiqi.geometric.intersection
{
	public class Vector2D
	{
		private var _x:Number;
		private var _y:Number;
		
		static public function fromPoints(p1:Vector2D,p2:Vector2D):Vector2D
		{
			return new Vector2D(p2.x - p1.x, p2.y - p1.y);
		}
		
		public function Vector2D(x:Number = 0, y:Number = 0)
		{
			_x = x;
			_y = y;
		}
		
		public function get y():Number { return _y; }
		public function set y(value:Number):void { _y = value; }
		
		public function get x():Number { return _x; }
		public function set x(value:Number):void { _x = value; }
		
		public function gte(that:Vector2D):Boolean
		{
			return (this.x >= that.x && this.y >= that.y);
		}
		
		public function lte(that:Vector2D):Boolean
		{
			return (this.x <= that.x && this.y <= that.y);
		}
		
		public function dot(that:Vector2D):Number
		{
			return (this.x * that.x + this.y * that.y);
		}
		
		public function min(that:Vector2D):Vector2D
		{
			return new Vector2D(Math.min(this.x, that.x), Math.min(this.y, that.y));
		}
		
		public function max(that:Vector2D):Vector2D
		{
			return new Vector2D(Math.max(this.x, that.x), Math.max(this.y, that.y));
		}
		
		public function add(that:Vector2D):Vector2D
		{
			return new Vector2D(this.x + that.x, this.y + that.y);
		}
		
		public function multiply(scalar:Number):Vector2D
		{
			return new Vector2D(this.x * scalar, this.y * scalar);
		}
		
		public function lerp(that:Vector2D, t:Number):Vector2D
		{
			return new Vector2D(this.x + (that.x - this.x) * t, this.y + (that.y - this.y) * t);
		}
		
		public function subtract(that):Vector2D
		{
			return new Vector2D(this.x - that.x, this.y - that.y);
		}
		
		public function toString():String
		{
			return "(x=" + this.x +", y=" + this.y + ")";
		}
		
	}
}