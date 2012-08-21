package net.fatty.channel {
    import net.fatty.channel.errors.ChannelPipelineException;
    import net.fatty.channel.events.IChannelEvent;

    public interface IChannelSink {
        function eventSunk(pipeline : IChannelPipeline, event : IChannelEvent) : void;
        function exceptionCaught(pipeline : IChannelPipeline,
                                 event : IChannelEvent,
                                 pe : ChannelPipelineException) : void;
    }
}
