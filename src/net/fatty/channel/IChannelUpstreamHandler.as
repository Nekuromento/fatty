package net.fatty.channel {
    import net.fatty.channel.events.IChannelEvent;

    public interface IChannelUpstreamHandler extends IChannelHandler {
        function handleUpstream(ctx : IChannelHandlerContext,
                                event : IChannelEvent) : void;
    }
}
