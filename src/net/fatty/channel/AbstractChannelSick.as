package net.fatty.channel {
    import net.fatty.channel.errors.ChannelPipelineException;
    import net.fatty.channel.events.IChannelEvent;

    import util.errors.UnimplementedException;

    public class AbstractChannelSick implements IChannelSink {
        // abstract function
        public function eventSunk(pipeline : IChannelPipeline,
                                  event : IChannelEvent) : void {
            throw new UnimplementedException();
        }

        public function exceptionCaught(pipeline : IChannelPipeline,
                                        event : IChannelEvent,
                                        pe : ChannelPipelineException) : void {
            var actualCause : Error = pe.cause;
            if (actualCause == null)
                actualCause = pe;

            Channels.fireExceptionCaught(event.channel, actualCause);
        }
    }
}
