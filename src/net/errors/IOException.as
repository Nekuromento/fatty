package net.errors {
    import util.errors.Exception;

    public class IOException extends Exception {
        public function IOException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
            name = "IOException";
        }
    }
}
