package net.fatty.channel {
    import net.InetSocket;

    public class ClientSocketChannel extends SocketChannel {
        public function ClientSocketChannel(factory : IChannelFactory,
                                            pipeline : IChannelPipeline,
                                            sink : IChannelSink) {
            super(factory, pipeline, sink, new InetSocket());

            Channels.fireChannelOpen(this);
        }
    }
}
