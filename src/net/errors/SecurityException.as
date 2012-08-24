package net.errors {
    import util.errors.Exception;

    public class SecurityException extends Exception {
        public function SecurityException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
            name = "SecutityException";
        }
    }
}
