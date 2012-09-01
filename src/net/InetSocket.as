package net {
    import flash.net.Socket;

    public class InetSocket extends Socket {
        private var _remoteAddress : SocketAddress;
        private var _closed : Boolean;

        public function InetSocket(host : String = null, port : int = 0) {
            super(host, port);
            if (host != null)
                _remoteAddress = new SocketAddress(host, port);
        }

        override public function connect(host : String, port : int) : void {
            _remoteAddress = new SocketAddress(host, port);
            super.connect(host, port);
            _closed = false;
        }

        public function get remoteAddress() : SocketAddress {
            return _remoteAddress;
        }

        override public function close() : void {
            if (connected)
                _closed = true;
            super.close();
        }

        public function get closed() : Boolean {
            return _closed;
        }
    }
}
