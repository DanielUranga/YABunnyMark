package com.daniel.glhaxor;

import openfl.gl.GL;
import openfl.gl.GLProgram;
import openfl.gl.GLUniformLocation;

class Program {

	public var program(get, null) : GLProgram;
	var vertexShader : Shader;
	var fragmentShader : Shader;
	var linked : Bool;

	public function new (vertexShader : Shader, fragmentShader : Shader) {
		this.vertexShader = vertexShader;
		this.fragmentShader = fragmentShader;
		this.linked = false;
	}

	function get_program () : GLProgram {
		if (!linked) {
			program = GL.createProgram();
			GL.attachShader(program, vertexShader.shader);
			GL.attachShader(program, fragmentShader.shader);
			GL.linkProgram(program);
			if (GL.getProgramParameter (program, GL.LINK_STATUS) == 0) {
				throw "Unable to initialize the shader program.";
			}
			linked = true;
		}
		return program;
	}

	public function getUniformLocation (name : String) : GLUniformLocation {
		return GL.getUniformLocation(get_program(), name);
	}

	public function getAttribLocation (name : String) : Int {
		return GL.getAttribLocation(get_program(), name);
	}

}
