package kaishiqi.geometric
{
	import flash.display.Graphics;

	public interface IGeometric
	{
		function draw(g:Graphics, dash:Number = NaN, dashStart:Number = 0.0):void;
	}
}