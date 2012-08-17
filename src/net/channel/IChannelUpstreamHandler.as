package net.channel {
    import net.channel.events.IChannelEvent;

    public interface IChannelUpstreamHandler extends IChannelHandler {
        function handleUpstream(ctx : IChannelHandlerContext,
                                event : IChannelEvent) : void;
    }
}
