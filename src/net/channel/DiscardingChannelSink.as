package net.channel {
    public class DiscardingChannelSink implements IChannelSink {
        public function eventSunk(pipeline : IChannelPipeline,
                                  event : IChannelEvent) : void {
        }
    }
}
