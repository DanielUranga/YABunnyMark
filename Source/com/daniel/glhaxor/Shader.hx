package com.daniel.glhaxor;

import openfl.gl.GL;
import openfl.gl.GLShader;

enum ShaderKind {
	Vertex;
	Fragment;
}

class Shader {

	public var shader(get, null) : GLShader;
	var kind : ShaderKind;
	var compiled : Bool;
	var source : String;

	public function new (kind : ShaderKind, source : String)
	{
		this.source = source;
		this.kind = kind;
		shader = GL.createShader(kind == Vertex ? GL.VERTEX_SHADER : GL.FRAGMENT_SHADER);
		compiled = false;
	}

	function get_shader () : GLShader {
		if (!compiled) {
			GL.shaderSource(shader, source);
			GL.compileShader(shader);
			if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0) {
				var log = GL.getShaderInfoLog(shader);
				throw "Error compiling shader, kind: " + kind + ". Log: " + log;
			}
			compiled = true;
		}
		return shader;
	}

}
