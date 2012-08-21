package util.errors {
    public class IllegalStateException extends Exception {
        public function IllegalStateException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
        }
    }
}
