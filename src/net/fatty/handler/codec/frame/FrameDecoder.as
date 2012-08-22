package net.fatty.handler.codec.frame {
    import net.SocketAddress;
    import net.fatty.channel.Channels;
    import net.fatty.channel.IChannel;
    import net.fatty.channel.IChannelHandler;
    import net.fatty.channel.IChannelHandlerContext;
    import net.fatty.channel.IChannelPipeline;
    import net.fatty.channel.ILifeCycleAwareChannelHandler;
    import net.fatty.channel.SimpleChannelUpstreamHandler;
    import net.fatty.channel.events.IChannelStateEvent;
    import net.fatty.channel.events.IExceptionEvent;
    import net.fatty.channel.events.IMessageEvent;

    import util.errors.IllegalStateException;
    import util.errors.UnimplementedException;

    import flash.utils.ByteArray;

    public class FrameDecoder extends SimpleChannelUpstreamHandler
                              implements ILifeCycleAwareChannelHandler {
        public static const DEFAULT_MAX_COMPOSITEBUFFER_COMPONENTS : uint = 1024;

        private var _unfold : Boolean;
        private var _cumulation : ByteArray;
        private var _ctx : IChannelHandlerContext;
        private var _copyThreshold : uint;
        private var _maxCumulationBufferComponents : uint = DEFAULT_MAX_COMPOSITEBUFFER_COMPONENTS;
        
        public function FrameDecoder(unfold : Boolean = false) {
            _unfold = unfold;
        }

        public final function get unfold() : Boolean {
            return _unfold;
        }
    
        public final function set unfold(value : Boolean) : void {
            if (_ctx == null)
                _unfold = value;
            else
                throw new IllegalStateException("decoder properties cannot be changed" +
                                                " once the decoder is added to a pipeline.");
        }

        public final function get maxCumulationBufferCapacity() : uint {
            return _copyThreshold;
        }

        public final function set maxCumulationBufferCapacity(value : uint) : void {
            if (value < 0)
                throw new ArgumentError("maxCumulationBufferCapacity must be >= 0");

            if (_ctx == null)
                _copyThreshold = value;
            else
                throw new IllegalStateException("decoder properties cannot be changed" +
                                                " once the decoder is added to a pipeline.");
        }

        public final function get maxCumulationBufferComponents() : uint {
            return _maxCumulationBufferComponents;
        }

        public final function set maxCumulationBufferComponents(value : uint) : void {
            if (value < 2)
                throw new ArgumentError("maxCumulationBufferComponents: " + value +
                                        " (expected: >= 2)");
    
            if (_ctx == null)
                _maxCumulationBufferComponents = value;
            else
                throw new IllegalStateException("decoder properties cannot be changed" +
                                                " once the decoder is added to a pipeline.");
        }

        override public function messageReceived(ctx : IChannelHandlerContext,
                                                 e : IMessageEvent) : void {
            const m : * = e.message;
            if (!(m is ByteArray)) {
                ctx.sendUpstream(e);
                return;
            }
    
            var input : ByteArray = ByteArray(m);
            if (input.bytesAvailable == 0)
                return;
    
            if (_cumulation == null) {
                try {
                    // the cumulation buffer is not created yet so just pass the input to callDecode(...) method
                    callDecode(ctx, e.channel, input, e.remoteAddress);
                } finally {
                    updateCumulation(ctx, input);
                }
            } else {
                input = appendToCumulation(input);
                try {
                    callDecode(ctx, e.channel, input, e.remoteAddress);
                } finally {
                    updateCumulation(ctx, input);
                }
            }
        }
    
        protected function appendToCumulation(input : ByteArray) : ByteArray {
            //TODO : implement channel buffers
            if (_cumulation != null)
                for (var i : uint = 0; i < input.length; ++i)
                    _cumulation.writeByte(input.readByte());
            else
                _cumulation = input;
            return _cumulation;
        }
    
        protected function updateCumulation(ctx : IChannelHandlerContext, input : ByteArray) : ByteArray {
            if (input.bytesAvailable > 0)
                _cumulation = input;
            else
                _cumulation = null;
            return _cumulation;
        }
    
        override public function channelDisconnected(ctx : IChannelHandlerContext,
                                                     event : IChannelStateEvent) : void {
            cleanup(ctx, event);
        }
    
        override public function channelClosed(ctx : IChannelHandlerContext,
                                               event : IChannelStateEvent) : void {
            cleanup(ctx, event);
        }
    
        override public function exceptionCaught(ctx : IChannelHandlerContext,
                                                 event : IExceptionEvent) : void {
            ctx.sendUpstream(event);
        }

        // abstract function
        protected function decode(ctx : IChannelHandlerContext,
                                  channel : IChannel,
                                  buffer : ByteArray) : * {
            throw new UnimplementedException();
        }
    
        protected function decodeLast(ctx : IChannelHandlerContext,
                                      channel : IChannel,
                                      buffer : ByteArray) : * {
            return decode(ctx, channel, buffer);
        }
    
        private function callDecode(context : IChannelHandlerContext,
                                    channel : IChannel,
                                    cumulation : ByteArray,
                                    remoteAddress : SocketAddress) : void {
            while (cumulation.bytesAvailable > 0) {
                const oldReaderIndex : uint = cumulation.bytesAvailable;
                const frame : * = decode(context, channel, cumulation);
                if (frame == null) {
                    if (oldReaderIndex == cumulation.bytesAvailable) {
                        // Seems like more data is required.
                        // Let us wait for the next notification.
                        break;
                    } else {
                        // Previous data has been discarded.
                        // Probably it is reading on.
                        continue;
                    }
                } else if (oldReaderIndex == cumulation.bytesAvailable) {
                    throw new IllegalStateException("decode() method must read at least one byte " +
                                                    "if it returned a frame");
                }
    
                unfoldAndFireMessageReceived(context, remoteAddress, frame);
            }
        }
    
        protected final function unfoldAndFireMessageReceived(context : IChannelHandlerContext,
                                                              remoteAddress : SocketAddress,
                                                              result : *) : void {
            if (_unfold) {
                if (result is Array) {
                    for each (var r : * in result)
                        Channels.fireMessageReceivedForContext(context, r, remoteAddress);
                } else if (result is Vector.<*>) {
                    for each (var rt : * in result)
                        Channels.fireMessageReceivedForContext(context, rt, remoteAddress);
                } else {
                    Channels.fireMessageReceivedForContext(context, result, remoteAddress);
                }
            } else {
                Channels.fireMessageReceivedForContext(context, result, remoteAddress);
            }
        }
    
        protected function cleanup(ctx : IChannelHandlerContext,
                                   event : IChannelStateEvent) : void {
            try {
                const cumulation : ByteArray = _cumulation;
                if (_cumulation == null)
                    return;
    
                _cumulation = null;
    
                // Make sure all frames are read before notifying a closed channel.
                if (cumulation.bytesAvailable > 0)
                    callDecode(ctx, ctx.channel, cumulation, null);
    
                // Call decodeLast() finally.  Please note that decodeLast() is
                // called even if there's nothing more to read from the buffer to
                // notify a user that the connection was closed explicitly.
                const partialFrame : * = decodeLast(ctx, ctx.channel, cumulation);
                if (partialFrame != null)
                    unfoldAndFireMessageReceived(ctx, null, partialFrame);
            } finally {
                ctx.sendUpstream(event);
            }
        }
    
        protected function newCumulationBuffer(ctx : IChannelHandlerContext,
                                               minimumCapacity : uint) : ByteArray {
            return new ByteArray();
        }
    
        public function replace(handlerName : String, handler : IChannelHandler) : void {
            if (_ctx == null)
                throw new IllegalStateException("Replace cann only be called once the " +
                                                "FrameDecoder is added to the ChannelPipeline");
            const pipeline : IChannelPipeline = _ctx.pipeline;
            pipeline.addAfterName(_ctx.name, handlerName, handler);
    
            try {
                if (_cumulation != null)
                    Channels.fireMessageReceivedForContext(_ctx, _cumulation);
            } finally {
                pipeline.remove(this);
            }
        }
    
        public function beforeAdd(ctx : IChannelHandlerContext) : void {
            _ctx = ctx;
        }

        public function afterAdd(ctx : IChannelHandlerContext) : void {
            // do nothing
        }

        public function beforeRemove(ctx : IChannelHandlerContext) : void {
            // do nothing
        }

        public function afterRemove(ctx : IChannelHandlerContext) : void {
            // do nothing
        }
    }
}
