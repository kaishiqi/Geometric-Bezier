package kaishiqi.geometric.intersection
{
	public class Polynomial
	{
		public static const TOLERANCE:Number = 1e-6;
		public static const ACCURACY:int = 6;
		
		private var coefs:Vector.<Number>;
		
		public function Polynomial(...arg)
		{
			coefs = new Vector.<Number>();
			for (var i:int = arg.length-1; i >=0; i--)
				coefs.push(arg[i]);
		}
		
		private function simplify():void 
		{
			for (var i:int = getDegree(); i >= 0; i--) {
				if (Math.abs(coefs[i]) <= Polynomial.TOLERANCE)
					coefs.pop();
				else 
					break;
			}
		}
		
		private function getDegree():int
		{
			return coefs.length - 1;
		}
		
		public function getRoots():Vector.<Number>
		{
			simplify();
			
			var result:Vector.<Number> = null;
			switch (getDegree()) {
				case 0:
					result = new Vector.<Number>();
					break;
				case 1:
					result = getLinearRoot();
					break;
				case 2:
					result = getQuadraticRoots();
					break;
				case 3:
					result = getCubicRoots();
					break;
				case 4:
					result = getQuarticRoots();
					break;
				default:
					result = new Vector.<Number>();
			}
			return result;
		}
		
		private function getLinearRoot():Vector.<Number>
		{
			var result:Vector.<Number> = new Vector.<Number>();
			var a:Number = coefs[1];
			if (a != 0)
				result.push(-coefs[0] / a);
			return result;
		}
		
		private function getQuadraticRoots():Vector.<Number>
		{
			var results:Vector.<Number> = new Vector.<Number>();
			if (getDegree() == 2) {
				var a:Number = coefs[2];
				var b:Number = coefs[1] / a;
				var c:Number = coefs[0] / a;
				var d:Number = b*b-4*c;
				
				if (d > 0){
					var e:Number = Math.sqrt(d);
					results.push(0.5 * (-b + e));
					results.push(0.5 * (-b - e));
				} else if (d == 0) {
					results.push(0.5 * -b);
				}
			}
			return results;
		}
		
		private function getCubicRoots():Vector.<Number>
		{
			var results:Vector.<Number> = new Vector.<Number>();
			if (getDegree() == 3) {
				var c3:Number = coefs[3];
				var c2:Number = coefs[2]/c3;
				var c1:Number = coefs[1]/c3;
				var c0:Number = coefs[0]/c3;
				var a:Number = (3*c1-c2*c2)/3;
				var b:Number = (2*c2*c2*c2-9*c1*c2+27*c0)/27;
				var offset:Number = c2/3;
				var discrim:Number = b*b/4 + a*a*a/27;
				var halfB:Number = b/2;
				
				if (Math.abs(discrim) <= Polynomial.TOLERANCE)
					discrim = 0;
				if (discrim > 0) {
					var e:Number = Math.sqrt(discrim);
					var tmp:Number = 0;
					var root:Number = 0;
					tmp = -halfB + e;
					if (tmp >= 0)
						root = Math.pow(tmp,1/3);
					else 
						root = -Math.pow(-tmp,1/3);
					tmp = -halfB-e;
					if (tmp >= 0)
						root += Math.pow(tmp,1/3);
					else 
						root-=Math.pow(-tmp,1/3);
					results.push(root-offset);
				} else if (discrim < 0) {
					var distance:Number = Math.sqrt(-a/3);
					var angle:Number = Math.atan2(Math.sqrt(-discrim),-halfB)/3;
					var cos:Number = Math.cos(angle);
					var sin:Number = Math.sin(angle);
					var sqrt3:Number = Math.sqrt(3);
					results.push(2*distance*cos-offset);
					results.push(-distance*(cos+sqrt3*sin)-offset);
					results.push(-distance*(cos-sqrt3*sin)-offset);
				} else {
					var tmp2:Number = 0;
					if (halfB >= 0)
						tmp2 = -Math.pow(halfB,1/3);
					else
						tmp2 = Math.pow(-halfB,1/3);
					results.push(2*tmp2-offset);
					results.push(-tmp2-offset);
				}
			}
			return results;
		}
		
		private function getQuarticRoots():Vector.<Number>
		{
			var results:Vector.<Number> = new Vector.<Number>();
			if (getDegree() == 4) {
				var c4:Number = coefs[4];
				var c3:Number = coefs[3]/c4;
				var c2:Number = coefs[2]/c4;
				var c1:Number = coefs[1]/c4;
				var c0:Number = coefs[0]/c4;
				var resolveRoots:Vector.<Number> = new Polynomial(1,-c2,c3*c1-4*c0,-c3*c3*c0+4*c2*c0-c1*c1).getCubicRoots();
				var y:Number = resolveRoots[0];
				var discrim:Number = c3*c3/4-c2+y;
				
				if (Math.abs(discrim) <= Polynomial.TOLERANCE)
					discrim = 0;
				if (discrim > 0){
					var e:Number = Math.sqrt(discrim);
					var t1:Number = 3*c3*c3/4-e*e-2*c2;
					var t2:Number = (4*c3*c2-8*c1-c3*c3*c3)/(4*e);
					var plus:Number = t1+t2;
					var minus:Number = t1-t2;
					if (Math.abs(plus) <= Polynomial.TOLERANCE)
						plus = 0;
					if (Math.abs(minus) <= Polynomial.TOLERANCE)
						minus = 0;
					if (plus >= 0){
						var f1:Number = Math.sqrt(plus);
						results.push(-c3/4 + (e+f1)/2);
						results.push(-c3/4 + (e-f1)/2);
					}
					if (minus >= 0) {
						var f2:Number = Math.sqrt(minus);
						results.push(-c3/4 + (f2-e)/2);
						results.push(-c3/4 - (f2+e)/2);
					}
				} else if (discrim < 0) {
				} else {
					var t22:Number = y*y-4*c0;
					if (t22 >= -Polynomial.TOLERANCE) {
						if (t22 < 0)
							t22 = 0;
						t22 = 2*Math.sqrt(t22);
						var t11:Number = 3*c3*c3/4-2*c2;
						if (t11+t22 >= Polynomial.TOLERANCE){
							var d1:Number = Math.sqrt(t11+t22);
							results.push(-c3/4 + d1/2);
							results.push(-c3/4 - d1/2);
						} if (t11-t22 >= Polynomial.TOLERANCE){
							var d2:Number = Math.sqrt(t11-t22);
							results.push(-c3/4 + d2/2);
							results.push(-c3/4 - d2/2);
						}
					}
				}
			}
			return results;
		}

		public function getRootsInInterval(min:Number, max:Number):Vector.<Number>
		{
			var roots:Vector.<Number> = new Vector.<Number>();
			var root:Number = NaN;
			if (getDegree() == 1) {
				root = bisection(min, max);
				if (!isNaN(root))
					roots.push(root);
			} else {
				var deriv:Polynomial = getDerivative();
				var droots:Vector.<Number> = deriv.getRootsInInterval(min,max);
				if (droots.length > 0) {
					root = bisection(min, droots[0]);
					if (!isNaN(root))
						roots.push(root);
					for (var i:int = 0; i <= droots.length-2; i++) {
						root = bisection(droots[i], droots[i + 1]);
						if (!isNaN(root))
							roots.push(root);
					}
					root = bisection(droots[droots.length - 1], max);
					if (!isNaN(root))
						roots.push(root);
				} else {
					root = bisection(min, max);
					if (!isNaN(root))
						roots.push(root);
				}
			}
			return roots;
		}
		
		private function bisection(min:Number, max:Number):Number
		{
			var minValue:Number = eval(min);
			var maxValue:Number = eval(max);
			var result:Number = NaN;
			if (Math.abs(minValue) <= Polynomial.TOLERANCE)
				result = min;
			else if (Math.abs(maxValue) <= Polynomial.TOLERANCE)
				result = max;
			else if (minValue * maxValue <= 0){
				var tmp1:Number = Math.log(max - min);
				var tmp2:Number = Math.LN10 * Polynomial.ACCURACY;
				var iters:Number = Math.ceil((tmp1 + tmp2) / Math.LN2);
				for(var i:int = 0; i < iters; i++){
					result = 0.5 * (min + max);
					var value:Number = eval(result);
					if (Math.abs(value) <= Polynomial.TOLERANCE)
						break;
					if (value*minValue < 0) {
						max = result;
						maxValue = value;
					} else {
						min = result;
						minValue = value;
					}
				}
			}
			return result;
		}
		
		private function eval(x:Number):Number
		{
			if (isNaN(x))
				throw new Error("Polynomial.eval: parameter must be a number");
			var result:Number = 0;
			for(var i:int = coefs.length - 1; i >= 0; i--)
				result = result * x + coefs[i];
			return result;
		}
		
		private function getDerivative():Polynomial
		{
			var derivative:Polynomial = new Polynomial();
			for(var i:int = 1; i < coefs.length; i++){
				derivative.coefs.push(i * coefs[i]);
			}
			return derivative;
		}


	}
}