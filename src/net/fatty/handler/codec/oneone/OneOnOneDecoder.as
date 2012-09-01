package net.fatty.handler.codec.oneone {
    import net.fatty.channel.Channels;
    import net.fatty.channel.IChannel;
    import net.fatty.channel.IChannelHandlerContext;
    import net.fatty.channel.IChannelUpstreamHandler;
    import net.fatty.channel.events.IChannelEvent;
    import net.fatty.channel.events.IMessageEvent;

    import util.errors.UnimplementedException;

    public class OneOnOneDecoder implements IChannelUpstreamHandler {
        public function handleUpstream(ctx : IChannelHandlerContext,
                                       event : IChannelEvent) : void {
            if (!(event is IMessageEvent)) {
                ctx.sendUpstream(event);
                return;
            }
    
            const e : IMessageEvent = IMessageEvent(event);
            const originalMessage : * = e.message;
            const decodedMessage : * = decode(ctx, e.channel, originalMessage);
            if (originalMessage == decodedMessage)
                ctx.sendUpstream(event);
            else if (decodedMessage != null)
                Channels.fireMessageReceivedForContext(ctx,
                                                       decodedMessage,
                                                       e.remoteAddress);
        }

        // abstract function
        protected function decode(ctx : IChannelHandlerContext,
                                  channel : IChannel,
                                  originalMessage : *) : * {
            throw new UnimplementedException();
            return null;
        }
    }
}
