package net.channel {
    import net.channel.errors.ChannelPipelineException;
    import net.channel.events.IChannelEvent;

    public interface IChannelSink {
        function eventSunk(pipeline : IChannelPipeline, event : IChannelEvent) : void;
        function exceptionCaught(pipeline : IChannelPipeline,
                                 event : IChannelEvent,
                                 pe : ChannelPipelineException) : void;
    }
}
