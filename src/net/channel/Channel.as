package net.channel {
    import util.debug.warning;
    import org.osflash.signals.natives.base.SignalSocket;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;

    public class Channel {
        private var _socket : SignalSocket;

        public function Channel(socket : SignalSocket) {
            _socket = socket;

            _socket.signals.connect.addOnce(onConnect);
            _socket.signals.close.addOnce(onClose);
            _socket.signals.ioError.addOnce(onIOError);
            _socket.signals.socketData.add(onResponce);
            _socket.signals.securityError.addOnce(onSecurityError);
        }

        private function onSecurityError(event : SecurityErrorEvent) : void {
            warning(event.text);
        }

        private function onResponce(event : ProgressEvent) : void {
        }

        private function onIOError(event : IOErrorEvent) : void {
        }

        private function onClose(event : Event) : void {
            // preventing security error
            _socket.close();
        }

        private function onConnect(event : Event) : void {
        }
    }
}
