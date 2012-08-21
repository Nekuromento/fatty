package net.fatty.channel {
    public interface IChannelPipelineFactory {
        function get pipeline() : IChannelPipeline;
    }
}
