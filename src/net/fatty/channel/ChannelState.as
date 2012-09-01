package net.fatty.channel {
    public final class ChannelState {
        public static const OPEN : ChannelState = new ChannelState("OPEN");
        public static const CONNECTED : ChannelState = new ChannelState("CONNECTED");

        private var _name : String = name;

        public function ChannelState(name : String) {
            _name = name;
        }

        public function get name() : String {
            return _name;
        }
    }
}
