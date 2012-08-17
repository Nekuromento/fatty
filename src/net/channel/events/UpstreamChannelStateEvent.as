package net.channel.events {
    import net.channel.ChannelState;
    import net.channel.IChannel;

    public class UpstreamChannelStateEvent implements IChannelStateEvent {
        private var _channel : IChannel;
        private var _state : ChannelState;
        private var _value : *;

        public function UpstreamChannelStateEvent(channel : IChannel,
                                                  state : ChannelState,
                                                  value : *) {
            if (channel == null)
                throw new ArgumentError("channel");

            if (state == null)
                throw new ArgumentError("state");
    
            _channel = channel;
            _state = state;
            _value = value;
        }

        public function get channel() : IChannel {
            return _channel;
        }

        public function get state() : ChannelState {
            return _state;
        }

        public function get value() : * {
            return _value;
        }
    }
}
