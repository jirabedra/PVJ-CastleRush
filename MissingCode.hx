//create map

//var mayonnaiseMap:TileMapDisplay;

worldMap = new Tilemap("testRoom_tmx", "tiles2", 1);
worldMap.init(function(layerTilemap, tileLayer) {
	if (!tileLayer.properties.exists("noCollision")) {
		layerTilemap.createCollisions(tileLayer);
	}
	simulationLayer.addChild(layerTilemap.createDisplay(tileLayer));
	//mayonnaiseMap = layerTilemap.createDisplay(tileLayer);
	//simulationLayer.addChild(mayonnaiseMap);
}, parseMapObjects);




//constructor chivito 
collision.accelerationY = 2000;
collision.maxVelocityX = 500;
collision.maxVelocityY = 800;
collision.dragX = 0.9;

//create joystick
touchJoystick = new VirtualGamepad();
touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.X);
touchJoystick.notify(chivito.onAxisChange, chivito.onButtonChange);

var gamepad = Input.i.getGamepad(0);
gamepad.notify(chivito.onAxisChange, chivito.onButtonChange);

///onButtonChange
if (id == XboxJoystick.LEFT_DPAD) {
	if (value == 1) {
		collision.accelerationX = -maxSpeed * 4;
		display.scaleX = Math.abs(display.scaleX);
	} else {
		if (collision.accelerationX < 0) {
			collision.accelerationX = 0;
		}
	}
}
if (id == XboxJoystick.RIGHT_DPAD) {
	if (value == 1) {
		collision.accelerationX = maxSpeed * 4;
		display.scaleX = -Math.abs(display.scaleX);
	} else {
		if (collision.accelerationX > 0) {
			collision.accelerationX = 0;
		}
	}
}
if (id == XboxJoystick.A) {
	if (value == 1) {
		if (collision.isTouching(Sides.BOTTOM)) {
			collision.velocityY = -1000;
		} else if (isWallGrabing()) {
			if (collision.isTouching(Sides.LEFT)) {
				collision.velocityX = 500;
			} else {
				collision.velocityX = -500;
			}
			collision.velocityY = -1000;
		}
	}
}


/// render
if (isWallGrabing()) {
	display.timeline.playAnimation("wallGrab");
} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX * collision.accelerationX < 0) {
	display.timeline.playAnimation("slide");
} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
	display.timeline.playAnimation("idle");
} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX != 0) {
	display.timeline.playAnimation("run");
} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY > 0) {
	display.timeline.playAnimation("fall");
} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY < 0) {
	display.timeline.playAnimation("jump");
}

inline function isWallGrabing():Bool {
	return !collision.isTouching(Sides.BOTTOM) && (collision.isTouching(Sides.LEFT) || collision.isTouching(Sides.RIGHT));
}


		
var s = Math.abs(collision.velocityX / collision.maxVelocityX);
display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);



//limit camera
stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 32 * 1, worldMap.heightInTiles * 32 * 1);