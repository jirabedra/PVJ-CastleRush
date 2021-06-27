package gameObjects;

import kha.math.FastVector2;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Phoenix extends Entity {
	public var display: Sprite;
	public var collision: CollisionBox;

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
		display = new Sprite("phoenix");
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
		collision.dragX = 0.9;
	}

	override function update(dt: Float) {
		super.update(dt);
		collision.update(dt);
	}

	override function render() {
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);
		display.timeline.playAnimation("idle");

		display.x = collision.x;
		display.y = collision.y;
	}

	public function follow(player: Princess) {
		var dx = player.x - x;
		var dir = new FastVector2(dx / Math.abs(dx), 0);
		collision.accelerationX = dir.x * 100;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
	}
}
