package net.fatty.channel {
    import net.fatty.channel.events.IChannelEvent;

    public interface IChannelDownstreamHandler extends IChannelHandler {
        function handleDownstream(ctx : IChannelHandlerContext,
                                  event : IChannelEvent) : void;
    }
}
