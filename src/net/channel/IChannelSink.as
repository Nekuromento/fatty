package net.channel {
    public interface IChannelSink {
        function eventSunk(pipeline : IChannelPipeline, event : IChannelEvent) : void;
    }
}
