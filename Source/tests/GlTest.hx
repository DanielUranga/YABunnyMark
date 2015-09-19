package tests;

import com.daniel.glhaxor.Float32VertexAttribute;
import com.daniel.glhaxor.GLUniformMatrix3D;
import com.daniel.glhaxor.Program;
import com.daniel.glhaxor.Shader;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import openfl.display.BitmapData;
import openfl.display.OpenGLView;
import openfl.display.Sprite;
import openfl.geom.Matrix3D;
import openfl.geom.Rectangle;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
import openfl.gl.GLTexture;
import openfl.gl.GLUniformLocation;
import openfl.utils.Float32Array;
import openfl.utils.UInt8Array;
import openfl.utils.Int16Array;
import openfl.Assets;

class GlTest extends Sprite {

	var bitmapData : BitmapData;
	var imageUniform : GLUniformLocation;
	var indexesBuffer : GLBuffer;
	var modelViewMatrix : GLUniformMatrix3D;
	var projectionMatrix : GLUniformMatrix3D;
	var shaderProgram : Program;
	var texCoordBuffer : Float32VertexAttribute;
	var texture : GLTexture;
	var vertexBuffer : Float32VertexAttribute;

	var bunnies : Array<Bunny>;
	var bunnyH : Float;
	var bunnyW : Float;
	var gravity : Float;
	var numBunnies : Int;
	var tf : TextField;
	var view : OpenGLView;

	public function new () {
		super ();
		bitmapData = Assets.getBitmapData("assets/wabbit_alpha.png");
		if (OpenGLView.isSupported) {
			view = new OpenGLView();
			indexesBuffer = GL.createBuffer();
			initializeShaders();
			createTexture();
			view.render = renderView;
			addChild(view);
		}
		gravity = 0.5;
		bunnies = [];
		numBunnies = 0;
		bunnyW = bitmapData.width;
		bunnyH = bitmapData.height;
		createCounter();
		addBunnies();
		onResize(null);
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
	}

	function onResize(_) {
		tf.x = Lib.current.stage.stageWidth - tf.width - 10;
		projectionMatrix = GLUniformMatrix3D.createOrtho (shaderProgram, "uProjectionMatrix", 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, 0, 1000, -1000);
		modelViewMatrix = GLUniformMatrix3D.create2D (shaderProgram, "uModelViewMatrix", 0, 0, 1, 0);
	}

	function createCounter () {
		var format = new TextFormat("_sans", 20, 0, true);
		format.align = TextFormatAlign.RIGHT;

		tf = new TextField ();
		tf.selectable = false;
		tf.defaultTextFormat = format;
		tf.width = 200;
		tf.height = 60;
		tf.x = Lib.current.stage.stageWidth - tf.width - 10;
		tf.y = 10;

		addChild(tf);

		tf.addEventListener(MouseEvent.CLICK, function(_) addBunnies ());
	}

	function addBunnies () {

		var more = numBunnies + 1000;
		for (i in numBunnies...more) {
			var bunny = new Bunny ();
			bunny.position = new Point();
			bunny.speedX = Math.random() * 5;
			bunny.speedY = (Math.random() * 5) - 2.5;
			//bunny.scale = 0.3 + Math.random();
			//bunny.rotation = 15 - Math.random() * 30;
			bunnies.push(bunny);
		}
		numBunnies = more;
		var indexes = new Int16Array (bunnies.length*6);
		//texCoords = new Float32Array (bunnies.length*8);

		var idI = 0;
		var idJ = 0;
		for (i in 0...bunnies.length) {
			
			if (i==0) {
				indexes[idI++] = 0;
				indexes[idI++] = 1;
				indexes[idI++] = 2;
				indexes[idI++] = 3;
				indexes[idI++] = 3;		// Degenerate
			} else {
				var j = i*4;
				indexes[idI++] = j+0;	// Degenerate
				indexes[idI++] = j+0;
				indexes[idI++] = j+1;
				indexes[idI++] = j+2;
				indexes[idI++] = j+3;
				indexes[idI++] = j+3;	// Degenerate
			}

		}

		texCoordBuffer.beginPush();
		for (i in 0...bunnies.length) {

			texCoordBuffer.push2 (0, 1);
			texCoordBuffer.push2 (0, 0);
			texCoordBuffer.push2 (1, 1);
			texCoordBuffer.push2 (1, 0);

		}

		GL.bindBuffer (GL.ELEMENT_ARRAY_BUFFER, indexesBuffer);
		GL.bufferData (GL.ELEMENT_ARRAY_BUFFER, indexes, GL.STATIC_DRAW);
		
		texCoordBuffer.bind ();
		texCoordBuffer.commit ();

		GL.bindBuffer (GL.ARRAY_BUFFER, null);

		tf.text = "Bunnies:\n" + numBunnies;

	}

	function updateBunnies () : Void {

		vertexBuffer.beginPush();
		var j = 0;
		for (i in 0...bunnies.length) {

			var bunny = bunnies[i];

			bunny.position.x += bunny.speedX;
			bunny.position.y += bunny.speedY;
			bunny.speedY += gravity;

			if (bunny.position.x > Lib.current.stage.stageWidth)
			{
				bunny.speedX *= -1;
				bunny.position.x = Lib.current.stage.stageWidth;
			}
			else if (bunny.position.x < 0)
			{
				bunny.speedX *= -1;
				bunny.position.x = 0;
			}
			if (bunny.position.y > Lib.current.stage.stageHeight)
			{
				bunny.speedY *= -0.8;
				bunny.position.y = Lib.current.stage.stageHeight;
				if (Math.random() > 0.5) bunny.speedY -= 3 + Math.random() * 4;
			}
			else if (bunny.position.y < 0)
			{
				bunny.speedY = 0;
				bunny.position.y = 0;
			}

			vertexBuffer.push2 (bunny.position.x, bunny.position.y + bunnyH);
			vertexBuffer.push2 (bunny.position.x, bunny.position.y);
			vertexBuffer.push2 (bunny.position.x + bunnyW, bunny.position.y + bunnyH);
			vertexBuffer.push2 (bunny.position.x + bunnyW, bunny.position.y);

		}

		vertexBuffer.bind();
		vertexBuffer.commit();
		GL.bindBuffer (GL.ARRAY_BUFFER, null);

	}


	private function initializeShaders () {

		var vertexShaderSource =

			"attribute vec2 aVertexPosition;
			attribute vec2 aTexCoord;
			varying vec2 vTexCoord;

			uniform mat4 uModelViewMatrix;
			uniform mat4 uProjectionMatrix;

			void main(void) {
				vTexCoord = aTexCoord;
				gl_Position = uProjectionMatrix * uModelViewMatrix * vec4 (aVertexPosition, 1.0, 1.0);
			}";


		var fragmentShaderSource =

			#if !desktop
			"precision mediump float;" +
			#end
			"varying vec2 vTexCoord;
			uniform sampler2D uImage0;

			void main(void)
			{"
				#if html5
				+ "gl_FragColor = texture2D(uImage0, vTexCoord).rgba;" +
				#elseif lime_legacy
				+ "gl_FragColor = texture2D(uImage0, vTexCoord).gbar;" +
				#else
				+ "gl_FragColor = texture2D(uImage0, vTexCoord).bgra;" +
				#end
			"}";

		shaderProgram = new Program(
			new Shader (ShaderKind.Vertex, vertexShaderSource),
			new Shader (ShaderKind.Fragment, fragmentShaderSource));

		if (GL.getProgramParameter (shaderProgram.program, GL.LINK_STATUS) == 0) {

			throw "Unable to initialize the shader program.";

		}

		vertexBuffer = new Float32VertexAttribute (shaderProgram, "aVertexPosition", 2);
		texCoordBuffer = new Float32VertexAttribute (shaderProgram, "aTexCoord", 2);
		projectionMatrix = new GLUniformMatrix3D (shaderProgram, "uProjectionMatrix");
		modelViewMatrix = new GLUniformMatrix3D (shaderProgram, "uModelViewMatrix");
		imageUniform = GL.getUniformLocation (shaderProgram.program, "uImage0");

	}

	private function createTexture () : Void {

		#if lime
		var pixelData = bitmapData.image.data;
		#else
		var pixelData = new UInt8Array(bitmapData.getPixels(bitmapData.rect));
		#end

		texture = GL.createTexture ();
		GL.bindTexture (GL.TEXTURE_2D, texture);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, bitmapData.width, bitmapData.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, pixelData);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		GL.bindTexture (GL.TEXTURE_2D, null);

	}

	function renderView (rect:Rectangle) {

		updateBunnies();

		GL.viewport (Std.int (rect.x), Std.int (rect.y), Std.int (rect.width), Std.int (rect.height));

		GL.clearColor (1.0, 1.0, 1.0, 1.0);
		GL.clear (GL.COLOR_BUFFER_BIT);

		GL.useProgram (shaderProgram.program);

		vertexBuffer.enableVertexAttribArray ();
		texCoordBuffer.enableVertexAttribArray ();

		GL.activeTexture (GL.TEXTURE0);
		GL.bindTexture (GL.TEXTURE_2D, texture);

		#if desktop
		GL.enable (GL.TEXTURE_2D);
		#end

		GL.bindBuffer (GL.ELEMENT_ARRAY_BUFFER, indexesBuffer);
		vertexBuffer.bind ();
		texCoordBuffer.bind ();

		projectionMatrix.commit();
		modelViewMatrix.commit();
		GL.uniform1i (imageUniform, 0);

		GL.drawElements(GL.TRIANGLE_STRIP, bunnies.length*6, GL.UNSIGNED_SHORT, 0);

		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		GL.bindBuffer (GL.ELEMENT_ARRAY_BUFFER, null);
		GL.bindTexture (GL.TEXTURE_2D, null);

		#if desktop
		GL.disable (GL.TEXTURE_2D);
		#end

		vertexBuffer.disableVertexAttribArray ();
		texCoordBuffer.disableVertexAttribArray ();

		GL.useProgram (null);

	}

}
