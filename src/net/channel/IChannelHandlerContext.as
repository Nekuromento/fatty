package net.channel {
    public interface IChannelHandlerContext {
        function get channel() : IChannel;
        function get pipeline() : IChannelPipeline;
        function get handler() : IChannelHandler;
        function get canHandleUpstreamEvents() : Boolean;
        function get canHandleDownstreamEvents() : Boolean;

        function sendUpstream(event : IChannelEvent) : void;
        function sendDownstream(event : IChannelEvent) : void;

        function get attachment() : *;
        function set attachment(value : *) : void;
    }
}
