package net.fatty.channel {
    import net.fatty.channel.events.IChannelEvent;
    import net.fatty.channel.events.IChannelStateEvent;
    import net.fatty.channel.events.IExceptionEvent;
    import net.fatty.channel.events.IMessageEvent;
    import net.fatty.channel.events.IWriteCompletionEvent;

    import util.debug.warning;

    public class SimpleChannelHandler implements IChannelUpstreamHandler,
                                                 IChannelDownstreamHandler {
        public function handleUpstream(ctx : IChannelHandlerContext,
                                       event : IChannelEvent) : void {
            if (event is IMessageEvent) {
                messageReceived(ctx, IMessageEvent(event));
            } else if (event is IWriteCompletionEvent) {
                writeComplete(ctx, IWriteCompletionEvent(event));
            } else if (event is IChannelStateEvent) {
                const evt : IChannelStateEvent = IChannelStateEvent(event);
                if (evt.state == ChannelState.OPEN) {
                    if (true === evt.value)
                        channelOpen(ctx, evt);
                    else
                        channelClosed(ctx, evt);
                } else if (evt.state == ChannelState.CONNECTED) {
                    if (evt.value != null)
                        channelConnected(ctx, evt);
                    else
                        channelDisconnected(ctx, evt);
                } else {
                    ctx.sendUpstream(event);
                }
            } else if (event is IExceptionEvent) {
                exceptionCaught(ctx, IExceptionEvent(event));
            } else {
                ctx.sendUpstream(event);
            }
        }

        public function exceptionCaught(ctx : IChannelHandlerContext,
                                        event : IExceptionEvent) : void {
            if (this == ctx.pipeline.getLast()) {
                //TODO: implement proper logging
                warning("EXCEPTION, please implement exceptionCaught()" +
                        "for proper handling.", event.cause);
//                logger.warn("EXCEPTION, please implement exceptionCaught()" +
//                            "for proper handling.", event.cause);
            }
            ctx.sendUpstream(event);
        }

        public function channelDisconnected(ctx : IChannelHandlerContext,
                                            event : IChannelStateEvent) : void {
            ctx.sendUpstream(event);
        }

        public function channelConnected(ctx : IChannelHandlerContext,
                                         event : IChannelStateEvent) : void {
            ctx.sendUpstream(event);
        }

        public function channelClosed(ctx : IChannelHandlerContext,
                                      event : IChannelStateEvent) : void {
            ctx.sendUpstream(event);
        }

        public function channelOpen(ctx : IChannelHandlerContext,
                                    event : IChannelStateEvent) : void {
            ctx.sendUpstream(event);
        }

        public function writeComplete(ctx : IChannelHandlerContext,
                                      event : IWriteCompletionEvent) : void {
            ctx.sendUpstream(event);
        }

        public function messageReceived(ctx : IChannelHandlerContext,
                                        event : IMessageEvent) : void {
            ctx.sendUpstream(event);
        }

        public function handleDownstream(ctx : IChannelHandlerContext,
                                         event : IChannelEvent) : void {
            if (event is IMessageEvent) {
                writeRequested(ctx, IMessageEvent(event));
            } else if (event is IChannelStateEvent) {
                const evt : IChannelStateEvent = IChannelStateEvent(event);
                if (evt.state == ChannelState.OPEN) {
                    if (true !== evt.value)
                        closeRequested(ctx, evt);
                } else if (evt.state == ChannelState.CONNECTED) {
                    if (evt.value != null)
                        connectRequested(ctx, evt);
                    else
                        disconnectRequested(ctx, evt);
                } else {
                    ctx.sendDownstream(event);
                }
            } else {
                ctx.sendDownstream(event);
            }
        }

        public function disconnectRequested(ctx : IChannelHandlerContext,
                                            event : IChannelStateEvent) : void {
            ctx.sendDownstream(event);
        }

        public function connectRequested(ctx : IChannelHandlerContext,
                                         event : IChannelStateEvent) : void {
            ctx.sendDownstream(event);
        }

        public function closeRequested(ctx : IChannelHandlerContext,
                                       event : IChannelStateEvent) : void {
            ctx.sendDownstream(event);
        }

        public function writeRequested(ctx : IChannelHandlerContext,
                                       event : IMessageEvent) : void {
            ctx.sendDownstream(event);
        }
    }
}
