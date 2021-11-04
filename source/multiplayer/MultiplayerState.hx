package multiplayer;

import networking.utils.NetworkMode;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.FlxCamera;
import utilities.CoolUtil;
import ui.FlxUIDropDownMenuCustom;
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

    var camFollow:FlxObject;

    var selectedPlayer:Int = 0;

    var camGame:FlxCamera;
    var camHUD:FlxCamera;

    var testBox:FlxUIInputText;
    var nameBox:FlxUIInputText;

    var coolChat:FlxText;

    public static var instance:MultiplayerState;

    override public function create()
    {
        instance = this;

        camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset();
		FlxG.cameras.add(camGame, true);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.camera = camGame;
        
        FlxG.mouse.visible = true;

        loadStage("stage");

        var prevVal:Bool = FlxG.save.data.nightMusic;

        FlxG.save.data.nightMusic = true;
        FlxG.save.flush();

        TitleState.playTitleMusic();
        Conductor.changeBPM(117);

        FlxG.save.data.nightMusic = prevVal;
        FlxG.save.flush();

        FlxG.sound.music.fadeIn(4, 0, 0.7);

        var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));

		var stageDropDown = new FlxUIDropDownMenuCustom(10, 50, FlxUIDropDownMenuCustom.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			loadStage(stages[Std.parseInt(stage)]);
		});

		stageDropDown.selectedLabel = "stage";
        stageDropDown.cameras = [camHUD];

        add(stageDropDown);

        testBox = new FlxUIInputText(10, 180, 70, "", 8);
        testBox.cameras = [camHUD];

        add(testBox);

        nameBox = new FlxUIInputText(10, 220, 70, "", 8);
        nameBox.cameras = [camHUD];

        add(nameBox);

        var ipBox = new FlxUIInputText(10, 270, 70, "127.0.0.1", 8);
        ipBox.cameras = [camHUD];

        add(ipBox);

        var connectClient = new FlxButton(10, 80,"Connect Client", function()
        {
            if(nameBox.text != "")
                Multiplayer.getInstance().start(CLIENT, { ip: ipBox.text, port: 9999 });
        });

        connectClient.cameras = [camHUD];

        var startServer = new FlxButton(connectClient.x + connectClient.width + 2, connectClient.y,"Start Server", function()
        {
            Multiplayer.getInstance().start(SERVER, { ip: '0.0.0.0', port: 9999, max_connections: 100 });
        });

        startServer.cameras = [camHUD];

        var chat = new FlxButton(testBox.x + testBox.width + 2, testBox.y, "Chat", function()
        {
            @:privateAccess
            var _session = Multiplayer.getInstance()._session;
            
            _session.send({verb: 'chatMessage', message: testBox.text, messanger: nameBox.text});
        });

        chat.cameras = [camHUD];

        coolChat = new FlxText(chat.x + chat.width, chat.y, 0, "", 16);
        coolChat.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(coolChat);

        add(chat);
        add(connectClient);
        add(startServer);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
        
        super.update(elapsed);
    }

    override public function beatHit()
    {
        if(stage != null)
            stage.beatHit();

        super.beatHit();
    }

    function loadStage(?stageName:String = "stage")
    {
        if(stage != null)
        {
            remove(stage);

            stage.kill();
            stage.destroy();
        }

        if(!FlxG.save.data.chrsAndBGs)
			stage = new StageGroup("");
		else
			stage = new StageGroup(stageName);

        add(stage);

        //FlxG.camera.zoom = stage.camZoom;
    }
}