package net.fatty.channel {
    import net.InetSocket;
    import net.errors.IOException;
    import net.errors.SecurityException;
    import net.fatty.channel.errors.ClosedChannelException;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.utils.ByteArray;

    public class Worker extends AbstractWorker {
        private var _socket : InetSocket;

        public function Worker(channel : SocketChannel) {
            super(channel);
        }

        override public function start() : void {
            _socket = SocketChannel(this.channel).socket;
            _socket.addEventListener(Event.CONNECT, onConnect);
            _socket.addEventListener(Event.CLOSE, onClose);
            _socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            _socket.addEventListener(ProgressEvent.SOCKET_DATA, onResponce);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
        }

        private function onConnect(event : Event) : void {
            Channels.fireChannelConnected(channel, channel.remoteAddress);
        }

        private function onClose(event : Event) : void {
            close(channel);
        }

        private function onIOError(event : IOErrorEvent) : void {
            Channels.fireExceptionCaught(channel, new IOException(event.text));
        }

        private function onResponce(event : ProgressEvent) : void {
            if (_socket.bytesAvailable > 0) {
                const a : ByteArray = new ByteArray();
                _socket.readBytes(a, 0, _socket.bytesAvailable);
                Channels.fireMessageReceived(channel, a);
            }
        }

        private function onSecurityError(event : SecurityErrorEvent) : void {
            Channels.fireExceptionCaught(channel, new SecurityException(event.text));
        }
        
        public static function write(channel : SocketChannel, message : *) : void {
            if (!channel.isOpen) {
                Channels.fireExceptionCaught(channel, new ClosedChannelException());
                return;
            }
    
            try {
                const a : ByteArray = ByteArray(message);
                channel.socket.writeBytes(a, 0, a.bytesAvailable);
                Channels.fireWriteComplete(channel, length);
            } catch (t : Error) {
                Channels.fireExceptionCaught(channel, t);
            }
        }
    }
}
