package net.channel {
    public interface ILifeCycleAwareChannelHandler {
        function beforeAdd(ctx : IChannelHandlerContext) : void;
        function afterAdd(ctx : IChannelHandlerContext) : void;
        function beforeRemove(ctx : IChannelHandlerContext) : void;
        function afterRemove(ctx : IChannelHandlerContext) : void;
    }
}
