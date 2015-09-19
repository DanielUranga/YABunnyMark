package com.daniel.glhaxor;

import openfl.geom.Matrix3D;
import openfl.gl.GL;
import openfl.gl.GLUniformLocation;
import openfl.utils.Float32Array;

class GLUniformMatrix3D {

	var data : Float32Array;
	var location : GLUniformLocation;

	public function new (program : Program, id : String, inData : Array<Float> = null) {
		data = new Float32Array(4*4);
		location = program.getUniformLocation(id);
		if (inData!=null) {
			for (i in 0...4*4) {
				data[i] = inData[i];
			}
		}
	}

	public function commit () {
		GL.uniformMatrix4fv(location, false, data);
	}

	public static function create2D (program : Program, id : String, x : Float, y : Float, scale : Float = 1, rotation : Float = 0) : GLUniformMatrix3D {

		var theta = rotation * Math.PI / 180.0;
		var c = Math.cos (theta);
		var s = Math.sin (theta);

		return new GLUniformMatrix3D (
			program,
			id,
			[
				c * scale, -s * scale, 0, 0,
				s * scale, c * scale, 0, 0,
				0, 0, 1, 0,
				x, y, 0, 1
			]
		);

	}

	public static function createABCD(program : Program, id : String, a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
		return new GLUniformMatrix3D (
			program,
			id,
			[
				a, b, 0, 0,
				c, d, 0, 0,
				0, 0, 1, 0,
				tx, ty, 0, 1
			]
		);
	}

	public static function createOrtho (program : Program, id : String, x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float) : GLUniformMatrix3D {

		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		var sz = 1.0 / (zFar - zNear);

		return new GLUniformMatrix3D (
			program,
			id,
			[
				2.0 * sx, 0, 0, 0,
				0, 2.0 * sy, 0, 0,
				0, 0, -2.0 * sz, 0,
				-(x0 + x1) * sx, -(y0 + y1) * sy, -(zNear + zFar) * sz, 1
			]
		);

	}

}
