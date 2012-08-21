package net.fatty.channel {
    public interface IChannelFactory {
        function newChannel(pipeline : IChannelPipeline) : IChannel;
        function releaseExternalResources() : void;
    }
}
