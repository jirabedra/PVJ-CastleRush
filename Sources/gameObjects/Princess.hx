package gameObjects;

import com.soundLib.SoundManager;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Princess extends Entity {
	public var display: Sprite;
	public var collision: CollisionBox;
	public var livesRemaining = 3;

	var maxSpeed = 200;

	var lastDamageTaken: Float = 0;
	var allowDoubleJump = false;
	var lastWallGrabing: Float = 0;
	var sideTouching: Int;
	var gravityScale: Int = 1;

	public var x(get, null): Float;
	private inline function get_x(): Float{
		return display.x;
	}

	public var y(get, null): Float;
	private inline function get_y(): Float{
		return display.y;
	}

	public function new(x: Float, y: Float, layer: Layer) {
		super();
		display = new Sprite("hero");
		display.smooth = false;
		layer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		display.pivotX = display.width() * 0.5;
		
		display.scaleX = display.scaleY = 1;
		collision.x = x;
		collision.y = y;

		collision.userData = this;

		collision.accelerationY = 2000;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.9;
	}

	override function update(dt:Float) {
		if (isWallGrabing()) {
			lastWallGrabing = 0;
			if (collision.isTouching(Sides.LEFT)) {
				sideTouching = Sides.LEFT;
			} else {
				sideTouching = Sides.RIGHT;
			}
		} else {
			lastWallGrabing += dt;
		}

		super.update(dt);
		collision.update(dt);
	}

	override function render() {
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);

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

		display.x = collision.x;
		display.y = collision.y;
	}

	public function onButtonChange(id: Int, value: Float) {
		switch (id) {
			case XboxJoystick.LEFT_DPAD:
				if (value == 1) {
					collision.accelerationX = -maxSpeed * 4;
					display.scaleX = Math.abs(display.scaleX);
				} else {
					if (collision.accelerationX < 0) {
						collision.accelerationX = 0;
					}
				}
			
			case XboxJoystick.RIGHT_DPAD:
				if (value == 1) {
					collision.accelerationX = maxSpeed * 4;
					display.scaleX = -Math.abs(display.scaleX);
				} else {
					if (collision.accelerationX > 0) {
						collision.accelerationX = 0;
					}
				}

			case XboxJoystick.A:
				if (value == 1) {
					if (collision.isTouching(Sides.BOTTOM)) {
						collision.velocityY = -1000;
						SoundManager.playFx("jump_fx");
						allowDoubleJump = true;
					} else if (isWallGrabing() || lastWallGrabing < 0.2) {
						SoundManager.playFx("jump_fx");
						if (sideTouching== Sides.LEFT) {
							collision.velocityX = 500;
						} else {
							collision.velocityX = -500;
						}
						collision.velocityY = -1000;
					} else if (allowDoubleJump) {
						collision.velocityY -= 800;
						SoundManager.playFx("jump_fx");
						allowDoubleJump = false;
					}
				}

		}
	}

	inline function isWallGrabing(): Bool {
		return !collision.isTouching(Sides.BOTTOM) && (collision.isTouching(Sides.LEFT) || collision.isTouching(Sides.RIGHT));
	}
	
	public inline function takeDamage(dt = 0.31) {
		lastDamageTaken += dt;
		
		if (livesRemaining == 3 || lastDamageTaken > 0.3) {
			lastDamageTaken = 0;
			if (--livesRemaining == 0) {
				die();
			}
		}

	}

	public function onAxisChange(id: Int, value: Float) {}
}
