package states;

import com.collision.platformer.CollisionEngine;
import controllers.PhoenixController;
import com.loading.basicResources.SoundLoader;
import gameObjects.Phoenix;
import com.collision.platformer.CollisionBox;
import format.tmx.Data.TmxObject;
import com.collision.platformer.Tilemap;
import com.loading.Resources;

class LevelTwo extends BaseLevel {
	var phoenix: Phoenix;
	var phoenixController = new PhoenixController();
	var dangerZone: CollisionBox;

	public function new() {
		super();
		tmxName = 'levelTwo_tmx';
	}

	override function load(resources: Resources) {
		super.load(resources);
		phoenixController.load(resources);
		resources.add(new SoundLoader("phoenix_death"));
	}

	override function init() {
		super.init();
		phoenixController.init(simulationLayer, worldMap);
	}

	override function parseMapObjects(layerTilemap: Tilemap, object: TmxObject) {
		super.parseMapObjects(layerTilemap, object);

		switch (object.name.toLowerCase()) {
			case "playerposition":
				if (princess != null) {
					phoenixController.setPrincess(princess);
				}

			case "enemyposition":
				if (phoenix == null) {
					phoenix = new Phoenix(object.x, object.y, simulationLayer);
					phoenixController.setPhoenix(phoenix);
					addChild(phoenix);
				}

			case "dangerzone":
				dangerZone = new CollisionBox();
				dangerZone.x = object.x;
				dangerZone.y = object.y;
				dangerZone.width = object.width;
				dangerZone.height = object.height;
				dangerZone.staticObject = true;
				phoenixController.setDangerZone(dangerZone);
		}
	}

	override function update(dt: Float) {
		super.update(dt);
		phoenixController.update(dt, addChild, changeState);

		if (CollisionEngine.overlap(princess.collision, winZone)) {
			changeState(new LevelThree());
		}
	}
}
