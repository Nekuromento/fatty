package net.fatty.channel {
    import net.fatty.channel.errors.ChannelPipelineException;
    import net.fatty.channel.events.IChannelEvent;

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
