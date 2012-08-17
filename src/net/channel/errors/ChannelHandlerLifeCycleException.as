package net.channel.errors {
    import util.Exception;

    public class ChannelHandlerLifeCycleException extends Exception {
        public function ChannelHandlerLifeCycleException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
        }
    }
}
