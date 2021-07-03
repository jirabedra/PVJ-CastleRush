package states;

import com.loading.basicResources.SoundLoader;
import com.gEngine.display.Sprite;
import gameObjects.Phoenix;
import com.loading.basicResources.FontLoader;
import com.gEngine.display.Text;
import com.collision.platformer.Sides;
import format.tmx.Data.TmxTileLayer;
import com.collision.platformer.CollisionBox;
import helpers.Tray;
import com.gEngine.display.extra.TileMapDisplay;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import format.tmx.Data.TmxObject;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionEngine;
import gameObjects.Princess;
import com.loading.basicResources.TilesheetLoader;
import com.loading.basicResources.SpriteSheetLoader;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import com.collision.platformer.Tilemap;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;

class LevelTwo extends State {
	var worldMap: Tilemap;
	var princess: Princess;
	var phoenix: Phoenix;
	var hudText: Text;
	
	var winZone: CollisionBox;
	var deathZone: CollisionBox;
	var dangerZone: CollisionBox;

	var simulationLayer: Layer;
	var touchJoystick: VirtualGamepad;
	var tray: helpers.Tray;
	var castleMap: TileMapDisplay;

	public function new() {
		super();
	}

	override function load(resources: Resources) {
		resources.add(new DataLoader("firstLevel_tmx"));
		var atlas = new JoinAtlas(2048, 2048);

		atlas.add(new TilesheetLoader("castle_tileset_part1", 16, 16, 0));
		atlas.add(new SpriteSheetLoader("hero", 22, 36, 0, [
			new Sequence("fall", [9]),
			new Sequence("slide", [5]),
			new Sequence("jump", [8]),
			new Sequence("run", [0, 1, 2, 3, 4]),
			new Sequence("idle", [6]),
			new Sequence("wallGrab", [5])
		]));
		atlas.add(new SpriteSheetLoader("phoenix", 41, 21, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6])
		]));

		atlas.add(new FontLoader("Kenney_Thick", 20));

		resources.add(atlas);
		resources.add(new SoundLoader("background_music", false));
		resources.add(new SoundLoader("jump_fx"));
		resources.add(new SoundLoader("phoenix_death"));
	}

	override function init() {
		// SoundManager.stopMusic();
		// SoundManager.playMusic("background_music");

		stageColor(0.5, .5, 0.5);
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);

		worldMap = new Tilemap("firstLevel_tmx");
		worldMap.init(parseTileLayers, parseMapObjects);

		tray = new Tray(castleMap);
		stage.defaultCamera().limits(16*2, 0, worldMap.widthIntTiles * 16 - 4*16, worldMap.heightInTiles * 16);
		createTouchJoystick();

		hudText = new Text("Kenney_Thick");
		hudText.x = 64;
		hudText.y = 48;
		stage.addChild(hudText);
	}

	function createTouchJoystick() {
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
		touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.X);
		
		touchJoystick.notify(princess.onAxisChange, princess.onButtonChange);

		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(princess.onAxisChange, princess.onButtonChange);
	}

	function parseTileLayers(layerTilemap: Tilemap, tileLayer: TmxTileLayer) {
		if (!tileLayer.properties.exists("noCollision")) {
			layerTilemap.createCollisions(tileLayer);
		}

		simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("castle_tileset_part1")));
		castleMap = layerTilemap.createDisplay(tileLayer, new Sprite("castle_tileset_part1"));
		simulationLayer.addChild(castleMap);
	}

	function parseMapObjects(layerTilemap: Tilemap, object: TmxObject) {
		switch (object.name.toLowerCase()) {
			case "playerposition":
				if (princess == null) {
					princess = new Princess(object.x, object.y, simulationLayer);
					addChild(princess);
				}

			case "enemyposition":
				if (phoenix == null) {
					phoenix = new Phoenix(object.x, object.y, simulationLayer);
					addChild(phoenix);
				}

			case "deathzone":
				deathZone = new CollisionBox();
				deathZone.x = object.x;
				deathZone.y = object.y;
				deathZone.width = object.width;
				deathZone.height = object.height;

			case "dangerzone":
				dangerZone = new CollisionBox();
				dangerZone.x = object.x;
				dangerZone.y = object.y;
				dangerZone.width = object.width;
				dangerZone.height = object.height;
				dangerZone.staticObject = true;

			case "winzone":
				winZone = new CollisionBox();
				winZone.x = object.x;
				winZone.y = object.y;
				winZone.width = object.width;
				winZone.height = object.height;

		}
	}

	override function update(dt: Float) {
		super.update(dt);

		stage.defaultCamera().setTarget(princess.collision.x, princess.collision.y);

		CollisionEngine.collide(princess.collision, worldMap.collision);

		if (phoenix != null) {
			CollisionEngine.collide(phoenix.collision, worldMap.collision);
	
			if (CollisionEngine.overlap(princess.collision, dangerZone)) {
				phoenix.follow(princess);
			}
	
			if (CollisionEngine.collide(princess.collision, phoenix.collision)) {
				if (phoenix.collision.isTouching(Sides.TOP)) {
					phoenix.die();
					phoenix = null;
				} else if (phoenix.collision.isTouching(Sides.LEFT) || phoenix.collision.isTouching(Sides.RIGHT)) {
					princess.takeDamage(dt);
	
					if (princess.isDead()) {
						changeState(new GameOver());
					}
				}
			}
		}

		if (CollisionEngine.overlap(princess.collision, deathZone)) {
			changeState(new GameOver());
		}

		hudText.x = stage.defaultCamera().eye.x - stage.defaultCamera().screenWidth() / 2 + 48;
		hudText.text = "LIVES REMAINING " + princess.livesRemaining;
	}

	override function destroy() {
		touchJoystick.destroy();
		super.destroy();
	}

	#if DEBUGDRAW
	override function draw(framebuffer: kha.Canvas) {
		super.draw(framebuffer);
		var camera = stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer, camera);
	}
	#end
}
