package net.channel {
    import net.channel.errors.ChannelPipelineException;
    import net.channel.events.IChannelEvent;

    public class DiscardingChannelSink implements IChannelSink {
        public function eventSunk(pipeline : IChannelPipeline,
                                  event : IChannelEvent) : void {
//            if (logger.isWarnEnabled()) {
//                logger.warn("Not attached yet; discarding: " + e);
//            }
        }

        public function exceptionCaught(pipeline : IChannelPipeline,
                                        event : IChannelEvent,
                                        pe : ChannelPipelineException) : void {
            throw pe;
        }
    }
}
