package net {
    public final class SocketAddress {
        private var _host : String;
        private var _port : int;

        public function SocketAddress(host : String, port : int) {
            _host = host;
            _port = port;
        }

        public function get host() : String {
            return _host;
        }

        public function get port() : int {
            return _port;
        }
    }
}
