package net.fatty.channel.events {
    import net.fatty.channel.IChannel;

    public class DefaultExceptionEvent implements IExceptionEvent {
        private var _channel : IChannel;
        private var _cause : Error;

        public function DefaultExceptionEvent(channel : IChannel, cause : Error) {
            if (channel == null)
                throw new ArgumentError("channel");

            if (cause == null)
                throw new ArgumentError("cause");

            _channel = channel;
            _cause = cause;
        }

        public function get channel() : IChannel {
            return _channel;
        }

        public function get cause() : Error {
            return _cause;
        }

        public function toString() : String {
            return String(channel) + " EXCEPTION: " + String(cause);
        }
    }
}

