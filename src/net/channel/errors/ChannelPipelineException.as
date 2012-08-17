package net.channel.errors {
    public class ChannelPipelineException extends ChannelException {
        public function ChannelPipelineException(message : * = "", cause : Error = null, id : * = 0) {
            super(message, cause, id);
        }
    }
}
