package util.errors {

    public class UnimplementedException extends Exception {
        public function UnimplementedException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
        }
    }
}
