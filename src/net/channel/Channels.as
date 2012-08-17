package net.channel {
    import net.SocketAddress;
    import net.channel.events.DefaultExceptionEvent;
    import net.channel.events.DownstreamChannelStateEvent;
    import net.channel.events.DownstreamMessageEvent;
    import net.channel.events.UpstreamChannelStateEvent;
    import net.channel.events.UpstreamMessageEvent;

    public class Channels {
        public static function newPipeline() : IChannelPipeline {
            return new DefaultChannelPipeline();
        }
    
        public static function pipeline(... handlers) : IChannelPipeline {
            const p : IChannelPipeline = newPipeline();
            const handlerCount : uint = handlers.length;
            for (var i : uint = 0; i < handlerCount; i ++) {
                const h : IChannelHandler = handlers[i];
                if (h == null)
                    break;

                p.addLast(i.toString(), h);
            }
            return p;
        }

        public static function copyPipeline(pipeline : IChannelPipeline) : IChannelPipeline {
            //TODO: implement
            return null;
        }

        public static function pipelineFactory(pipeline : IChannelPipeline) : IChannelPipelineFactory {
            return new SingleHandlerChannelPipelineFactory(pipeline);
        }
    
        public static function fireChannelOpen(channel : IChannel) : void {
            channel.pipeline.sendUpstream(new UpstreamChannelStateEvent(channel,
                                                                        ChannelState.OPEN,
                                                                        true));
        }
    
        public static function fireChannelOpenForContext(ctx : IChannelHandlerContext) : void {
            ctx.sendUpstream(new UpstreamChannelStateEvent(ctx.channel,
                                                           ChannelState.OPEN,
                                                           true));
        }
    
        public static function fireChannelConnected(channel : IChannel,
                                                    remoteAddress : SocketAddress) : void {
            channel.pipeline.sendUpstream(new UpstreamChannelStateEvent(channel,
                                                                        ChannelState.CONNECTED,
                                                                        remoteAddress));
        }
    
        public static function fireChannelConnectedForContext(ctx : IChannelHandlerContext,
                                                              remoteAddress : SocketAddress) : void {
            ctx.sendUpstream(new UpstreamChannelStateEvent(ctx.channel,
                                                           ChannelState.CONNECTED,
                                                           remoteAddress));
        }
    
        public static function fireMessageReceived(channel : IChannel,
                                                   message : *,
                                                   remoteAddress : SocketAddress = null) : void {
            channel.pipeline.sendUpstream(new UpstreamMessageEvent(channel,
                                                                   message,
                                                                   remoteAddress));
        }
    
        public static function fireMessageReceivedForContext(ctx : IChannelHandlerContext,
                                                             message : *,
                                                             remoteAddress : SocketAddress = null) : void {
            ctx.sendUpstream(new UpstreamMessageEvent(ctx.channel,
                                                      message,
                                                      remoteAddress));
        }
    
        public static function fireChannelDisconnected(channel : IChannel) : void {
            channel.pipeline.sendUpstream(new UpstreamChannelStateEvent(channel,
                                                                        ChannelState.CONNECTED,
                                                                        null));
        }
    
        public static function fireChannelDisconnectedForContext(ctx : IChannelHandlerContext) : void {
            ctx.sendUpstream(new UpstreamChannelStateEvent(ctx.channel,
                                                           ChannelState.CONNECTED,
                                                           null));
        }
    
        public static function fireChannelClosed(channel : IChannel) : void {
            channel.pipeline.sendUpstream(new UpstreamChannelStateEvent(channel,
                                                                        ChannelState.OPEN,
                                                                        false));
        }
    
        public static function fireChannelClosedForContext(ctx : IChannelHandlerContext) : void {
            ctx.sendUpstream(new UpstreamChannelStateEvent(ctx.channel,
                                                           ChannelState.OPEN,
                                                           false));
        }
    
        public static function fireExceptionCaught(channel : IChannel,
                                                   cause : Error) : void {
            channel.pipeline.sendUpstream(new DefaultExceptionEvent(channel,
                                                                    cause));
        }
    
        public static function fireExceptionCaughtForContext(ctx : IChannelHandlerContext,
                                                             cause : Error) : void {
            ctx.sendUpstream(new DefaultExceptionEvent(ctx.channel,
                                                       cause));
        }
    
        public static function connect(channel : IChannel, remoteAddress : SocketAddress) : void {
            if (remoteAddress == null)
                throw new ArgumentError("remoteAddress");

            channel.pipeline.sendDownstream(new DownstreamChannelStateEvent(channel,
                                                                            ChannelState.CONNECTED,
                                                                            remoteAddress));
        }
    
        public static function write(channel : IChannel,
                                     message : *,
                                     remoteAddress : SocketAddress = null) : void {
            channel.pipeline.sendDownstream(new DownstreamMessageEvent(channel,
                                                                       message,
                                                                       remoteAddress));
        }
    
        public static function disconnect(channel : IChannel) : void {
            channel.pipeline.sendDownstream(new DownstreamChannelStateEvent(channel,
                                                                            ChannelState.CONNECTED,
                                                                            null));
        }
    
        public static function close(channel : IChannel) : void {
            channel.pipeline.sendDownstream(new DownstreamChannelStateEvent(channel,
                                                                            ChannelState.OPEN,
                                                                            false));
        }
    }
}
