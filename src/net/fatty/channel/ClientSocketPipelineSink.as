package net.fatty.channel {
    import net.SocketAddress;
    import net.fatty.channel.events.IChannelEvent;
    import net.fatty.channel.events.IChannelStateEvent;
    import net.fatty.channel.events.IMessageEvent;

    public class ClientSocketPipelineSink extends AbstractChannelSick {
        override public function eventSunk(pipeline : IChannelPipeline, e : IChannelEvent) : void{
            const channel : ClientSocketChannel = ClientSocketChannel(e.channel);
            if (e is IChannelStateEvent) {
                const stateEvent : IChannelStateEvent = IChannelStateEvent(e);
                const state : ChannelState = stateEvent.state;
                const value : * = stateEvent.value;
                if (state == ChannelState.OPEN) {
                    if (false === value)
                        AbstractWorker.close(channel);
                } else if (state == ChannelState.CONNECTED) {
                    if (value != null)
                        connect(channel, SocketAddress(value));
                    else
                        AbstractWorker.close(channel);
                }
            } else if (e is IMessageEvent) {
                Worker.write(channel, (IMessageEvent(e)).message);
            }
        }
    
        private function connect(channel : ClientSocketChannel, remoteAddress : SocketAddress) : void {
            var connected : Boolean = false;
            var workerStarted : Boolean = false;
    
            try {
                channel.socket.connect(remoteAddress.host, remoteAddress.port);
                connected = true;
    
                const worker : IWorker = new Worker(channel);
                worker.start();
                workerStarted = true;
            } catch (t : Error) {
                Channels.fireExceptionCaught(channel, t);
            } finally {
                if (connected && !workerStarted)
                    AbstractWorker.close(channel);
            }
        }
    }
}
