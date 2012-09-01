package net.fatty.channel {
    public interface IChannelPipelineFactory {
        function get newPipeline() : IChannelPipeline;
    }
}
