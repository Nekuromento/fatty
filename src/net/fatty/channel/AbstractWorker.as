package net.fatty.channel {
    import util.errors.UnimplementedException;

    public class AbstractWorker implements IWorker {
        private var _channel : AbstractChannel;
    
        public function AbstractWorker(channel : AbstractChannel) {
            _channel = channel;
            channel.worker = this;
        }

        protected function get channel() : AbstractChannel {
            return _channel;
        }

        // abstract function
        public function start() : void {
            throw new UnimplementedException();
        }

        public static function close(channel : AbstractChannel) : void {
            const connected : Boolean = channel.isConnected;
    
            try {
                channel.closeSocket();
                channel.setClosed();
                if (connected)
                    Channels.fireChannelDisconnected(channel);
                Channels.fireChannelClosed(channel);
            } catch (t : Error) {
                Channels.fireExceptionCaught(channel, t);
            }
        }
    }
}
