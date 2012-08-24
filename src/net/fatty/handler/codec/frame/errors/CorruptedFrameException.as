package net.fatty.handler.codec.frame.errors {
    import util.errors.Exception;

    public class CorruptedFrameException extends Exception {
        public function CorruptedFrameException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
            name = "CorruptedFrameException";
        }
    }
}
