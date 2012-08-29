package net.fatty.channel.events {
    import net.SocketAddress;
    import net.fatty.channel.IChannel;

    import flash.utils.ByteArray;

    public class UpstreamMessageEvent implements IMessageEvent {
        private var _channel : IChannel;
        private var _message : *;
        private var _remoteAddress : SocketAddress;
    
        public function UpstreamMessageEvent(channel : IChannel,
                                             message : *,
                                             remoteAddress : SocketAddress) {
            if (channel == null)
                throw new ArgumentError("channel");
            if (message == null)
                throw new ArgumentError("message");

            _channel = channel;
            _message = message;
            _remoteAddress =
                remoteAddress != null ? remoteAddress : channel.remoteAddress;
        }

        public function get channel() : IChannel {
            return _channel;
        }

        public function get message() : * {
            return _message;
        }

        public function get remoteAddress() : SocketAddress {
            return _remoteAddress;
        }

        public function toString() : String {
            if (remoteAddress == channel.remoteAddress)
                return String(channel) + " RECEIVED: " +
                    (message is ByteArray ? "ByteArray" : String(message));
            else
                return String(channel) + " RECEIVED: " +
                    (message is ByteArray ? "ByteArray" : String(message)) + " from " + String(remoteAddress);
        }
    }
}
