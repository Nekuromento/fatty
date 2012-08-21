package net.fatty.channel.errors {
    import util.errors.Exception;

    public class ClosedChannelException extends Exception {
        public function ClosedChannelException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
        }
    }
}
