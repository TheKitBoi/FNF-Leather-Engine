package multiplayer;

import states.PlayState;
import flixel.FlxG;
import networking.Network;
import networking.sessions.Session;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;

class Multiplayer
{
    /** Current networking session. **/
    private var _session: Session;

    /** Singleton instance of this class. **/
    private static var s_instance:Multiplayer;

    /** Singleton getter. **/
    public static function getInstance():Multiplayer
    {
        if (s_instance == null)
            s_instance = new Multiplayer();

        return s_instance;
    }

    /**
        * Empty constructor.
    */
    private function new() {}

    /**
    * Start a new game either as a server or as a client.
    * This method will initialize the networking session, and add the required event listeners.
    *
    * If the current session is a server, a random initial turn ("X" or "O") will be selected.
    *
    * @param mode Networking mode.
    * @param params Networking parameters.
    */
    public function start(mode: NetworkMode, params: Dynamic) {
        _session = Network.registerSession(mode, params);

        _session.addEventListener(NetworkEvent.INIT_SUCCESS, onInit);
        _session.addEventListener(NetworkEvent.INIT_FAILURE, onFailure);
        _session.addEventListener(NetworkEvent.CONNECTED, onConnected);
        _session.addEventListener(NetworkEvent.DISCONNECTED, onDisconnect);
        _session.addEventListener(NetworkEvent.MESSAGE_RECEIVED, onMessageRecieved);

        _session.start();
    }

    /**
    * Finish the current game session. This method will close the networking session,
    * and bring back the main menu.
    *
    * @param msg Message to show on the screen after the game is finished.
    */
    public function finish(msg: String = null) {
        Network.destroySession(_session);
    }

    /**
    * Networking - initialize event handler.
    *
    * @param e Networking event.
    */
    private function onInit(e: NetworkEvent) {
        // do nothing lmao
    }

    /**
    * Networking - failure event handler.
    *
    * @param e Networking event.
    */
    private function onFailure(e: NetworkEvent) {
        switch(_session.mode) {
            case SERVER:
                // If we're a server, and we can't initialize the server, close the game session, and show an error.
                finish("Unable to create server");

            case CLIENT:
                // If we're a client, and we can't connect to the server, close the game session, and show an error.
                finish("Unable to connect to host");
        }
    }

    /**
    * Networking - connected event handler.
    *
    * @param e Networking event.
    */
    private function onConnected(e: NetworkEvent) {
        // do nothing lmao
    }

    /**
    * Networking - disconnected event handler.
    *
    * @param e Networking event.
    */
    private function onDisconnect(e: NetworkEvent) {
        // Client: disconnected from the server.
        // Server: client disconnected.
        // In both cases. finish the game session, and show a "Disconnected" message.
        finish("Disconnected");
    }

    /**
    * Networking - messages event handler.
    *
    * @param e Networking event.
    */
    private function onMessageRecieved(e: NetworkEvent) {
        if(FlxG.state == MultiplayerState.instance)
            MultiplayerState.instance.onMessageRecieved(e);

        if(FlxG.state == PlayState.instance)
            PlayState.instance.onMessageRecieved(e);
    }
}