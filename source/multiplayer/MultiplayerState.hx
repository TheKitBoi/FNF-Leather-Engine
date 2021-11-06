package multiplayer;

import states.LoadingState;
import game.Song;
import game.Highscore;
import states.PlayState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import networking.utils.NetworkEvent;
import states.MainMenuState;
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

    var chatBox:FlxUIInputText;
    var nameBox:FlxUIInputText;

    var coolChat:FlxText;
    var UI_box:FlxUITabMenu;

    public static var instance:MultiplayerState;

    var ipBox:FlxUIInputText;
    var portBox:FlxUIInputText;

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

        var tabs = [
			{name: "Room", label: 'Room'},
			{name: "Client", label: 'Client'},
			{name: "Server", label: 'Server'}
		];

        UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = 5;
		UI_box.y = 40;
        UI_box.cameras = [camHUD];

        UI_box.scrollFactor.set();

		add(UI_box);

        coolUI();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if(FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        if(FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(new MainMenuState());
        
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
    }

    public function onMessageRecieved(e: NetworkEvent)
    {
        switch(e.verb)
        {
            case "chatMessage":
                coolChat.text += e.data.messanger + ": " + e.data.message + "\n";

                var text = coolChat.text;

                if(text.split("\n").length >= 25)
                {
                    var lines = text.split("\n");

                    coolChat.text = "";

                    for(line in 0...lines.length) {
                        if(line > 0 && lines[line] != "\n" && lines[line] != "")
                            coolChat.text += lines[line] + "\n";
                    }
                }
            case "startGame":
<<<<<<< HEAD
            /*    var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDiffString);
=======
                /*
                var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDiffString);
>>>>>>> b03ae410652d69a91405d5e1139c7ebb854c63a3
	
				trace(poop);
                
                PlayState.SONG = Song.loadFromJson(poop,songs[curSelected].songName.toLowerCase());
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = curDifficulty;
                PlayState.songMultiplier = curSpeed;
				PlayState.storyDifficultyStr = curDiffString.toUpperCase();
                PlayState.isMultiplayer = true;

				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);

<<<<<<< HEAD
				LoadingState.loadAndSwitchState(new PlayState()); */
=======
				LoadingState.loadAndSwitchState(new PlayState());*/
>>>>>>> b03ae410652d69a91405d5e1139c7ebb854c63a3
        }
    }

    function coolUI()
    {
        var tab_room = new FlxUI(null, UI_box);
		tab_room.name = "Room";

        var tab_client = new FlxUI(null, UI_box);
		tab_client.name = "Client";

        var tab_server = new FlxUI(null, UI_box);
		tab_server.name = "Server";

        UI_box.addGroup(tab_room);
        UI_box.addGroup(tab_client);
        UI_box.addGroup(tab_server);

        /* ROOM STUFF */
        var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));

		var stageDropDown = new FlxUIDropDownMenuCustom(10, 10, FlxUIDropDownMenuCustom.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			loadStage(stages[Std.parseInt(stage)]);
		});

		stageDropDown.selectedLabel = "stage";
        stageDropDown.cameras = [camHUD];

        chatBox = new FlxUIInputText(stageDropDown.x + stageDropDown.width, 10, 70, "", 8);
        chatBox.cameras = [camHUD];

        var chat = new FlxButton(chatBox.x + chatBox.width + 2, chatBox.y, "Chat", function()
        {
            @:privateAccess
            var _session = Multiplayer.getInstance()._session;
            
            _session.send({verb: 'chatMessage', message: chatBox.text, messanger: nameBox.text});

            @:privateAccess
            if(MultiplayerState.instance != null)
            {
                MultiplayerState.instance.coolChat.text += nameBox.text + ": " + chatBox.text + "\n";

                var text = MultiplayerState.instance.coolChat.text;

                if(text.split("\n").length >= 25)
                {
                    var lines = text.split("\n");

                    MultiplayerState.instance.coolChat.text = "";

                    for(line in 0...lines.length) {
                        if(line > 0 && lines[line] != "\n" && lines[line] != "")
                            MultiplayerState.instance.coolChat.text += lines[line] + "\n";
                    }
                }
            }

            chatBox.text = "";
        });

        chat.visible = false;
        chat.cameras = [camHUD];

        tab_room.add(chatBox);
        tab_room.add(chat);
        tab_room.add(stageDropDown);

        /* CLIENT STUFF */
        var connectClient = new FlxButton(10, 10,"Connect Client", function()
        {
            if(nameBox.text != "")
            {
                @:privateAccess
                if(Multiplayer.getInstance()._session != null)
                    Multiplayer.getInstance().finish();

                Multiplayer.getInstance().start(CLIENT, { ip: ipBox.text, port: Std.parseInt(portBox.text) });

                chat.visible = true;
            }
        });

        connectClient.cameras = [camHUD];

        ipBox = new FlxUIInputText(connectClient.x + connectClient.width + 2, connectClient.y, 70, "127.0.0.1", 8);
        ipBox.cameras = [camHUD];

        portBox = new FlxUIInputText(ipBox.x, ipBox.y + ipBox.height + 2, 70, "9999", 8);
        portBox.cameras = [camHUD];

        nameBox = new FlxUIInputText(10, portBox.y + portBox.height + 2, 70, "", 8);
        nameBox.cameras = [camHUD];

        var ipLabel = new FlxText(ipBox.x + ipBox.width, ipBox.y, 0, "IP", 9);
        var portLabel = new FlxText(portBox.x + portBox.width, portBox.y, 0, "Port", 9);
        var nameLabel = new FlxText(nameBox.x + nameBox.width, nameBox.y, 0, "Username", 9);

        tab_client.add(ipBox);
        tab_client.add(portBox);
        tab_client.add(nameBox);

        tab_client.add(ipLabel);
        tab_client.add(portLabel);
        tab_client.add(nameLabel);
        
        tab_client.add(connectClient);

        /* SERVER STUFF */
        var startServer = new FlxButton(10, 10,"Start Server", function()
        {
            Multiplayer.getInstance().start(SERVER, { ip: '0.0.0.0', port: 9999, max_connections: 100 });
        });

        startServer.cameras = [camHUD];

        tab_server.add(startServer);

        /* OUTSIDE IDK */
        coolChat = new FlxText(UI_box.x + UI_box.width, UI_box.y, 0, "", 16);
        coolChat.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(coolChat);
    }
}