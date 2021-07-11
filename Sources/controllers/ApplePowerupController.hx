package controllers;

import com.collision.platformer.CollisionEngine;
import gameObjects.Princess;
import gameObjects.Apple;
import com.loading.basicResources.SpriteSheetLoader;
import com.loading.Resources;
import com.loading.basicResources.JoinAtlas;

class ApplePowerupController {
  var princess: Princess;
  var apple: Apple;

  public function new() { }

  public function load(resources: Resources) {
    var atlas = new JoinAtlas(2048, 2048);
		atlas.add(new SpriteSheetLoader("apple", 32, 32, 0, [
			new Sequence("idle", [0])
		]));
    resources.add(atlas);
  }

  public function setApple(apple: Apple) {
    this.apple = apple;
  }

  public function setPrincess(princess: Princess) {
    this.princess = princess;
  }

  public function update(dt: Float, addChild, changeState) {
    if (apple == null) {
      return;
    }

    if (CollisionEngine.overlap(princess.collision, apple.collision)) {
      apple.destroy();
      apple = null;

      princess.powerup();
    }
  }
}
