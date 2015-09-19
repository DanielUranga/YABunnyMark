package com.daniel.glhaxor;

import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;

class Float32VertexAttribute {

	public var length(default, null) : Int;						// Number of vertexs
	public var occupiedLength(get, null) : Int;
	public var perVertexElementsNumber(default, null) : Int;	// Number of elements per vertex
	var data : Float32Array;
	var pushPos : Int;
	var vertexAttribute : Int;
	var vertexBufferOnGpu : GLBuffer;

	public function new (program : Program, attribName : String, perVertexElementsNumber : Int) {
		this.length = 4;
		this.perVertexElementsNumber = perVertexElementsNumber;
		this.vertexAttribute = program.getAttribLocation(attribName);
		this.pushPos = 0;
		data = new Float32Array(length*perVertexElementsNumber);
		this.vertexBufferOnGpu = GL.createBuffer();
		commit();
	}

	@:arrayAccess
	public inline function get (key : Int) : Float {
		return data[key];
	}

	@:arrayAccess
	public inline function set (key : Int, value : Float) : Float {
		return this.data[key] = value;
	}

	function get_occupiedLength () : Int {
		return Std.int(pushPos/perVertexElementsNumber);
	}

	function resize (newSize : Int) : Void {
		var tmp = new Array<Float>();
		for (i in 0...(length*perVertexElementsNumber)) {
			tmp.push(data[i]);
		}
		for (i in (length*perVertexElementsNumber)...(newSize*perVertexElementsNumber)) {
			tmp.push(0.0);
		}
		length = newSize;
		data = new Float32Array(tmp, 0, length*perVertexElementsNumber);
	}

	public function enableVertexAttribArray () {
		GL.enableVertexAttribArray(vertexAttribute);
	}

	public function disableVertexAttribArray () {
		GL.disableVertexAttribArray(vertexAttribute);
	}

	public function beginPush () {
		pushPos = 0;
	}

	inline public function push1 (x : Float) {
		if (perVertexElementsNumber==1) {
			if (pushPos+1>data.length) {
				resize(length*2);
			}
			data[pushPos++] = x;
		}
	}

	inline public function push2 (x : Float, y : Float) {
		if (perVertexElementsNumber==2) {
			if (pushPos+2>data.length) {
				resize(length*2);
			}
			data[pushPos++] = x;
			data[pushPos++] = y;
		}
	}

	
	inline public function push3 (x : Float, y : Float, z : Float) {
		if (perVertexElementsNumber==3) {
			if (pushPos+3>data.length) {
				resize(length*2);
			}
			data[pushPos++] = x;
			data[pushPos++] = y;
			data[pushPos++] = z;
		}
	}

	
	inline public function push4 (x : Float, y : Float, z : Float, w : Float) {
		if (perVertexElementsNumber==4) {		
			if (pushPos+4>data.length) {
				resize(length*2);
			}
			data[pushPos++] = x;
			data[pushPos++] = y;
			data[pushPos++] = z;
			data[pushPos++] = w;
		}
	}
	
	inline public function set2 (index : Int, x : Float, y : Float) {
		if (perVertexElementsNumber==2) {
			var i = index*2;
			if (i+2>data.length) {
				resize(length*2);
			}
			data[i] = x;
			data[i+1] = y;
		}
	}

	inline public function set4 (index : Int, x : Float, y : Float, z : Float, w : Float) {
		if (perVertexElementsNumber==4) {
			var i = index*4;
			if (i+4>data.length) {
				resize(length*4);
			}
			data[i] = x;
			data[i+1] = y;
			data[i+2] = z;
			data[i+3] = w;
		}
	}

	public function bind () {
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBufferOnGpu);
		GL.vertexAttribPointer(vertexAttribute, perVertexElementsNumber, GL.FLOAT, false, 0, 0);
	}

	public function commit () : Void {
		GL.bufferData(GL.ARRAY_BUFFER, data, GL.DYNAMIC_DRAW);
	}

	public function toString () {
		var str = "[";
		for (i in 0...data.length) {
			str += Std.int(data[i]) + ", ";
		}
		str += "]";
		return str;
	}

}
