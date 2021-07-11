package states;

import com.collision.platformer.CollisionEngine;
import gameObjects.Dragon;
import controllers.DragonController;
import controllers.PhoenixController;
import com.loading.basicResources.SoundLoader;
import gameObjects.Phoenix;
import com.collision.platformer.CollisionBox;
import format.tmx.Data.TmxObject;
import com.collision.platformer.Tilemap;
import com.loading.Resources;

class LevelThree extends BaseLevel {
	var phoenix: Phoenix;
	var dangerZone1: CollisionBox;
  var dragon: Dragon;
	var dangerZone2: CollisionBox;
	var dragonController = new DragonController();
	var phoenixController = new PhoenixController();

	public function new() {
		super();
		tmxName = 'levelThree_tmx';
	}

	override function load(resources: Resources) {
		super.load(resources);
    dragonController.load(resources);
		phoenixController.load(resources);
    resources.add(new SoundLoader("dragon_death_fx"));
		resources.add(new SoundLoader("phoenix_death"));
	}

	override function init() {
		super.init();
    dragonController.init(simulationLayer, worldMap);
		phoenixController.init(simulationLayer, worldMap);
	}

	override function parseMapObjects(layerTilemap: Tilemap, object: TmxObject) {
		super.parseMapObjects(layerTilemap, object);

		switch (object.name.toLowerCase()) {
			case "playerposition":
				if (princess != null) {
          dragonController.setPrincess(princess);
					phoenixController.setPrincess(princess);
				}

      case "dangerzone1":
        dangerZone1 = new CollisionBox();
        dangerZone1.x = object.x;
        dangerZone1.y = object.y;
        dangerZone1.width = object.width;
        dangerZone1.height = object.height;
        dangerZone1.staticObject = true;
        phoenixController.setDangerZone(dangerZone1);

			case "phoenixposition":
				if (phoenix == null) {
					phoenix = new Phoenix(object.x, object.y, simulationLayer);
					phoenixController.setPhoenix(phoenix);
					addChild(phoenix);
				}

      case "dangerzone2":
        dangerZone2 = new CollisionBox();
        dangerZone2.x = object.x;
        dangerZone2.y = object.y;
        dangerZone2.width = object.width;
        dangerZone2.height = object.height;
        dangerZone2.staticObject = true;
        dragonController.setDangerZone(dangerZone2);

      case "dragonposition":
        if (dragon == null) {
					dragon = new Dragon(object.x, object.y, simulationLayer);
					dragonController.setDragon(dragon);
					addChild(dragon);
				}
		}
	}

	override function update(dt: Float) {
		super.update(dt);
    dragonController.update(dt, addChild, changeState);
		phoenixController.update(dt, addChild, changeState);

    if (CollisionEngine.overlap(princess.collision, winZone)) {
			changeState(new Victory());
		}
	}
}
