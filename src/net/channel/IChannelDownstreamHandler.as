package net.channel {
    import net.channel.events.IChannelEvent;

    public interface IChannelDownstreamHandler extends IChannelHandler {
        function handleDownstream(ctx : IChannelHandlerContext,
                                  event : IChannelEvent) : void;
    }
}
