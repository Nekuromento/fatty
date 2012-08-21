package net.fatty.channel {
    import net.InetSocket;
    import net.SocketAddress;

    public class SocketChannel extends AbstractChannel {
        private var _socket : InetSocket;

        public function SocketChannel(factory : IChannelFactory,
                                      pipeline : IChannelPipeline,
                                      sink : IChannelSink,
                                      socket : InetSocket) {
            super(factory, pipeline, sink);
            _socket = socket;
        }

        public function get socket() : InetSocket {
            return _socket;
        }

        override public function get isSocketConnected() : Boolean {
            return _socket.connected;
        }

        override public function get isSocketClosed() : Boolean {
            return _socket.closed;
        }

        override public function closeSocket() : void {
            _socket.close();
        }

        override public function getRemoteSocketAddress() : SocketAddress {
            return _socket.remoteAddress;
        }
    }
}
