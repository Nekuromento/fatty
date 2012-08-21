package net.fatty.bootstrap {
    import net.SocketAddress;
    import net.fatty.channel.IChannel;
    import net.fatty.channel.IChannelFactory;
    import net.fatty.channel.IChannelPipeline;
    import net.fatty.channel.errors.ChannelPipelineException;

    public class ClientBootstrap extends Bootstrap {
        public function ClientBootstrap(factory : IChannelFactory = null) {
            super(factory);
        }

        public function connect(remoteAddress : SocketAddress) : void {
            if (remoteAddress == null)
                throw new ArgumentError("remoteAddress");
    
            var pipeline : IChannelPipeline;
            try {
                pipeline = pipelineFactory.newPipeline;
            } catch (e : Error) {
                throw new ChannelPipelineException("Failed to initialize a pipeline.", e);
            }
    
            const ch : IChannel = channelFactory.newChannel(pipeline);
    
            ch.connect(remoteAddress);
        }
    }
}
