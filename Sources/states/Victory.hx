package states;

import kha.input.KeyCode;
import com.soundLib.SoundManager;
import com.loading.basicResources.SoundLoader;
import com.framework.utils.Input;
import com.gEngine.display.Text;
import com.loading.basicResources.FontLoader;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;

class Victory extends State {
  public function new(){
    super();
  }

  override function load(resources: Resources) {
    var atlas = new JoinAtlas(512,512);
    atlas.add(new FontLoader("Kenney_Thick", 20));
    resources.add(atlas);
    resources.add(new SoundLoader("victory"));
  }

  override function init() {
    SoundManager.stopMusic();
    stageColor(0.5,0.5,0.5);

    var gameOverText = new Text("Kenney_Thick");
    gameOverText.x = 1280 * 0.5 - 150;
    gameOverText.y = 720 * 0.5;
    gameOverText.text = "You won";

    var continueText = new Text("Kenney_Thick");
    continueText.x = 1280 * 0.5 - 150;
    continueText.y = 720 * 0.5 + 50;
    continueText.text = "Press space to play again" ; 

    stage.addChild(gameOverText);
    stage.addChild(continueText);

    SoundManager.playFx("victory");
  }

  override function update(dt: Float) {
    super.update(dt);

    if(Input.i.isKeyCodePressed(KeyCode.Space)){
      changeState(new LevelOne());
    }
  }
}
