package multiplayer;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.FlxCamera.FlxCameraFollowStyle;
import states.TitleState;
import game.Conductor;
import game.Boyfriend;
import flixel.FlxG;
import game.Character;
import game.StageGroup;
import states.MusicBeatState;

class MultiplayerState extends MusicBeatState
{
    var stage:StageGroup;

    var players:Array<Character> = [];
    var names:Array<FlxText> = [];

    var camFollow:FlxObject;

    var selectedPlayer:Int = 0;

    override public function create()
    {
        FlxG.mouse.visible = true;

        if(!FlxG.save.data.chrsAndBGs)
			stage = new StageGroup("");
		else
			stage = new StageGroup("stage");

        add(stage);

        loadCharacter(0, "bf", "Player1");
        loadCharacter(1, "spooky", "Player2");
        loadCharacter(2, "dad", "Player3");

        var prevVal:Bool = FlxG.save.data.nightMusic;

        FlxG.save.data.nightMusic = true;
        FlxG.save.flush();

        TitleState.playTitleMusic();
        Conductor.changeBPM(117);

        FlxG.save.data.nightMusic = prevVal;
        FlxG.save.flush();

        FlxG.sound.music.fadeIn(4, 0, 0.7);

        camFollow = new FlxObject(players[selectedPlayer].getGraphicMidpoint().x, players[selectedPlayer].getGraphicMidpoint().y, 1, 1);
		add(camFollow);

        FlxG.camera.zoom = stage.camZoom;

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        if(controls.LEFT_P || controls.RIGHT_P)
        {
            if(controls.LEFT_P)
                selectedPlayer -= 1;

            if(controls.RIGHT_P)
                selectedPlayer += 1;

            if(selectedPlayer < 0)
                selectedPlayer = players.length - 1;

            if(selectedPlayer > players.length - 1)
                selectedPlayer = 0;

            camFollow.setPosition(players[selectedPlayer].getGraphicMidpoint().x, players[selectedPlayer].getGraphicMidpoint().y);
        }

        FlxG.camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0.12 * (60 / Main.display.currentFPS));
        
        super.update(elapsed);
    }

    override public function beatHit()
    {
        for(character in players) {
            character.dance();
        }

        stage.beatHit();

        super.beatHit();
    }

    function loadCharacter(player:Int, characterName:String, playerName:String)
    {
        players[player] = new Character(0, 0, characterName);

        var playerSprite = players[player];

        var coolBfPos = stage.getCoolCharacterPos(1, playerSprite);

        playerSprite.setPosition(coolBfPos[0], coolBfPos[1]);

        if(player > 0)
        {
            for(character in players) {
                if(character != playerSprite)
                    playerSprite.x += character.width;
            }

            playerSprite.x += 12;
        }

        add(playerSprite);

        var playerMidpoint = playerSprite.getGraphicMidpoint();

        names[player] = new FlxText(playerMidpoint.x, playerMidpoint.y - (playerSprite.height / 2), 0, playerName, 32);

        names[player].setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        names[player].setPosition(playerMidpoint.x - (names[0].width / 2), playerMidpoint.y - (playerSprite.height / 2) - names[0].height - 6);

        add(names[player]);
    }
}