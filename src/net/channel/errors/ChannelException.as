package net.channel.errors {
    import util.errors.Exception;

    public class ChannelException extends Exception {
        public function ChannelException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
        }
    }
}
