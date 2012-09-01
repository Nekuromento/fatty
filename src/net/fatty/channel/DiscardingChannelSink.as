package net.fatty.channel {
    import net.fatty.channel.errors.ChannelPipelineException;
    import net.fatty.channel.events.IChannelEvent;

    import util.debug.warning;

    public class DiscardingChannelSink implements IChannelSink {
        public function eventSunk(pipeline : IChannelPipeline,
                                  event : IChannelEvent) : void {
            //TODO: implement proper logging
            warning("Not attached yet; discarding: " + event);
//            if (logger.isWarnEnabled()) {
//                logger.warn("Not attached yet; discarding: " + event);
//            }
        }

        public function exceptionCaught(pipeline : IChannelPipeline,
                                        event : IChannelEvent,
                                        pe : ChannelPipelineException) : void {
            throw pe;
        }
    }
}
