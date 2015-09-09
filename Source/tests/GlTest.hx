package tests;

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
import openfl.Assets;

class GlTest extends Sprite {

	var tf : TextField;

	var bitmapData : BitmapData;
	var imageUniform : GLUniformLocation;
	var modelViewMatrixData : Float32Array;
	var modelViewMatrixUniform : GLUniformLocation;
	var projectionMatrixData : Float32Array;
	var projectionMatrixUniform : GLUniformLocation;
	var shaderProgram : GLProgram;
	var texCoordAttribute : Int;
	var texCoordBuffer : GLBuffer;
	var texCoords : Float32Array;
	var texture : GLTexture;
	var vertexAttribute : Int;
	var vertexBuffer : GLBuffer;
	var vertices : Float32Array;
	var view : OpenGLView;

	var bunnies : Array<Bunny>;
	var bunnyH : Float;
	var bunnyW : Float;
	var gravity : Float;
	var numBunnies : Int;

	public function new () {
		super ();
		bitmapData = Assets.getBitmapData("assets/wabbit_alpha.png");
		if (OpenGLView.isSupported) {
			view = new OpenGLView();
			vertexBuffer = GL.createBuffer();
			texCoordBuffer = GL.createBuffer();
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
		var projectionMatrix = Matrix3D.createOrtho (0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, 0, 1000, -1000);
		projectionMatrixData = new Float32Array (projectionMatrix.rawData);
		var modelViewMatrix = Matrix3D.create2D (0, 0, 1, 0);
		modelViewMatrixData = new Float32Array(modelViewMatrix.rawData);
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
		vertices = new Float32Array (bunnies.length*12);
		texCoords = new Float32Array (bunnies.length*12);

		for (i in 0...bunnies.length) {
			if (i==0) {

				texCoords[0] = 0;
				texCoords[1] = 1;

				texCoords[2] = 0;
				texCoords[3] = 0;

				texCoords[4] = 1;
				texCoords[5] = 1;

				texCoords[6] = 1;
				texCoords[7] = 0;

				// Degenerate triangle strip
				texCoords[8] = 1;
				texCoords[9] = 0;

			} else {

				var j = i*(8+4) - 2;

				// Degenerate triangle strip

				texCoords[j+0] = 0;
				texCoords[j+1] = 1;

				texCoords[j+2] = 0;
				texCoords[j+3] = 1;

				texCoords[j+4] = 0;

				texCoords[j+5] = 0;

				texCoords[j+6] = 1;
				texCoords[j+7] = 1;

				texCoords[j+8] = 1;
				texCoords[j+9] = 0;

				// Degenerate triangle strip
				texCoords[j+10] = 1;
				texCoords[j+11] = 0;

			}
		}

		tf.text = "Bunnies:\n" + numBunnies;

	}

	function updateBunnies () : Void {

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

			if (i==0) {

				vertices[0] = bunny.position.x;
				vertices[1] = bunny.position.y + bunnyH;

				vertices[2] = bunny.position.x;
				vertices[3] = bunny.position.y;

				vertices[4] = bunny.position.x + bunnyW;
				vertices[5] = bunny.position.y + bunnyH;

				vertices[6] = bunny.position.x + bunnyW;
				vertices[7] = bunny.position.y;

				// Degenerate triangle strip
				vertices[8] = bunny.position.x + bunnyW;
				vertices[9] = bunny.position.y;

			} else {

				var j = i*(8+4) - 2;

				// Degenerate triangle strip
				vertices[j+0] = bunny.position.x;
				vertices[j+1] = bunny.position.y + bunnyH;

				vertices[j+2] = bunny.position.x;
				vertices[j+3] = bunny.position.y + bunnyH;

				vertices[j+4] = bunny.position.x;
				vertices[j+5] = bunny.position.y;

				vertices[j+6] = bunny.position.x + bunnyW;
				vertices[j+7] = bunny.position.y + bunnyH;

				vertices[j+8] = bunny.position.x + bunnyW;
				vertices[j+9] = bunny.position.y;

				// Degenerate triangle strip
				vertices[j+10] = bunny.position.x + bunnyW;
				vertices[j+11] = bunny.position.y;

			}

		}

		GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferData (GL.ARRAY_BUFFER, vertices, GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);

		GL.bindBuffer (GL.ARRAY_BUFFER, texCoordBuffer);
		GL.bufferData (GL.ARRAY_BUFFER, texCoords, GL.STATIC_DRAW);
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

		var vertexShader = GL.createShader (GL.VERTEX_SHADER);
		GL.shaderSource (vertexShader, vertexShaderSource);
		GL.compileShader (vertexShader);

		if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) {
			throw "Error compiling vertex shader";
		}

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

		var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
		GL.shaderSource (fragmentShader, fragmentShaderSource);
		GL.compileShader (fragmentShader);

		if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0) {

			throw "Error compiling fragment shader";

		}

		shaderProgram = GL.createProgram ();
		GL.attachShader (shaderProgram, vertexShader);
		GL.attachShader (shaderProgram, fragmentShader);
		GL.linkProgram (shaderProgram);

		if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0) {

			throw "Unable to initialize the shader program.";

		}

		vertexAttribute = GL.getAttribLocation (shaderProgram, "aVertexPosition");
		texCoordAttribute = GL.getAttribLocation (shaderProgram, "aTexCoord");
		projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "uProjectionMatrix");
		modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "uModelViewMatrix");
		imageUniform = GL.getUniformLocation (shaderProgram, "uImage0");

	}

	private function createTexture () : Void {

		#if lime
		var pixelData = bitmapData.image.data;
		#else
		var pixelData = new UInt8Array(bitmapData.getPixels(bitmapData.rect));
		#end

		texture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, texture);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, bitmapData.width, bitmapData.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, pixelData);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		GL.bindTexture(GL.TEXTURE_2D, null);

	}

	function renderView (rect:Rectangle) {

		updateBunnies();

		GL.viewport (Std.int (rect.x), Std.int (rect.y), Std.int (rect.width), Std.int (rect.height));

		GL.clearColor (1.0, 1.0, 1.0, 1.0);
		GL.clear (GL.COLOR_BUFFER_BIT);

		GL.useProgram (shaderProgram);
		GL.enableVertexAttribArray (vertexAttribute);
		GL.enableVertexAttribArray (texCoordAttribute);

		GL.activeTexture (GL.TEXTURE0);
		GL.bindTexture (GL.TEXTURE_2D, texture);

		#if desktop
		GL.enable (GL.TEXTURE_2D);
		#end

		GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);
		GL.vertexAttribPointer (vertexAttribute, 2, GL.FLOAT, false, 0, 0);
		GL.bindBuffer (GL.ARRAY_BUFFER, texCoordBuffer);
		GL.vertexAttribPointer (texCoordAttribute, 2, GL.FLOAT, false, 0, 0);

		GL.uniformMatrix4fv (projectionMatrixUniform, false, projectionMatrixData);
		GL.uniformMatrix4fv (modelViewMatrixUniform, false, modelViewMatrixData);
		GL.uniform1i (imageUniform, 0);

		GL.drawArrays (GL.TRIANGLE_STRIP, 0, bunnies.length*6);

		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		GL.bindTexture (GL.TEXTURE_2D, null);

		#if desktop
		GL.disable (GL.TEXTURE_2D);
		#end

		GL.disableVertexAttribArray (vertexAttribute);
		GL.disableVertexAttribArray (texCoordAttribute);
		GL.useProgram (null);

	}

}
