package net.channel {
    public interface IChannelPipelineFactory {
        function get pipeline() : IChannelPipeline;
    }
}
