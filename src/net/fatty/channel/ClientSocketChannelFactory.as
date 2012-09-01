package net.fatty.channel {
    public class ClientSocketChannelFactory implements IChannelFactory {
        private const _sink : ClientSocketPipelineSink = new ClientSocketPipelineSink();

        public function newChannel(pipeline : IChannelPipeline) : IChannel {
            return new ClientSocketChannel(this, pipeline, _sink);
        }
    }
}
