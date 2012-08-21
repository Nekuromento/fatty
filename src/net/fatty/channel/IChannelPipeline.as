package net.fatty.channel {
    import net.fatty.channel.events.IChannelEvent;

    public interface IChannelPipeline {
        function get channel() : IChannel;
        function get sink() : IChannelSink;

        function attach(channel : IChannel, sink : IChannelSink) : void;
        function get isAttached() : Boolean;

        function sendDownstream(event : IChannelEvent) : void;
        function sendUpstream(event : IChannelEvent) : void;

        function getByName(name : String) : IChannelHandler;
        function getByType(type : Class) : IChannelHandler;

        function getContext(handler : IChannelHandler) : IChannelHandlerContext;
        function getContextByName(name : String) : IChannelHandlerContext;
        function getContextByType(type : Class) : IChannelHandlerContext;

        function getFirst() : IChannelHandler;
        function getLast() : IChannelHandler;

        function addFirst(name : String, handler : IChannelHandler) : void;
        function addLast(name : String, handler : IChannelHandler) : void;

        function removeFirst() : IChannelHandler;
        function removeLast() : IChannelHandler;

        function remove(handler : IChannelHandler) : void;
        function removeByName(name : String) : IChannelHandler;
        function removeByType(type : Class) : IChannelHandler;

        function replace(oldHandler : IChannelHandler,
                         newName : String,
                         newHandler : IChannelHandler) : void;
        function replaceByName(oldName : String,
                               newName : String,
                               handler : IChannelHandler) : IChannelHandler;
        function replaceByType(type : Class,
                               name : String,
                               handler : IChannelHandler) : IChannelHandler;

        function addBefore(handler : IChannelHandler,
                           name : String,
                           newHandler : IChannelHandler) : void;
        function addBeforeName(name : String,
                               newName : String,
                               handler : IChannelHandler) : void;
        function addBeforeType(type : Class,
                               name : String,
                               handler : IChannelHandler) : void;

        function addAfter(handler : IChannelHandler,
                          name : String,
                          newHandler : IChannelHandler) : void;
        function addAfterName(name : String,
                              newName : String,
                              handler : IChannelHandler) : void;
        function addAfterType(type : Class,
                              name : String,
                              handler : IChannelHandler) : void;
    }
}
