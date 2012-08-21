package net.fatty.handler.codec.oneone {
    import net.fatty.channel.Channels;
    import net.fatty.channel.IChannel;
    import net.fatty.channel.IChannelDownstreamHandler;
    import net.fatty.channel.IChannelHandlerContext;
    import net.fatty.channel.events.IChannelEvent;
    import net.fatty.channel.events.IMessageEvent;

    import util.errors.UnimplementedException;

    public class OneOnOneEncoder implements IChannelDownstreamHandler {
        public function handleDownstream(ctx : IChannelHandlerContext, event : IChannelEvent) : void {
            if (!(event is IMessageEvent)) {
                ctx.sendDownstream(event);
                return;
            }
    
            const e : IMessageEvent = IMessageEvent(event);
            const originalMessage : * = e.message;
            const encodedMessage : * = encode(ctx, e.channel, originalMessage);
            if (originalMessage == encodedMessage)
                ctx.sendDownstream(event);
            else if (encodedMessage != null)
                Channels.writeForContext(ctx, encodedMessage, e.remoteAddress);
        }

        // abstract function
        protected function encode(ctx : IChannelHandlerContext,
                                  channel : IChannel,
                                  message : *) : * {
            throw new UnimplementedException();
        }
    }
}
