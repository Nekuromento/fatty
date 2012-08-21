package net.fatty.channel {
    import net.fatty.channel.events.IChannelEvent;
 
    public class DefaultChannelHandlerContext implements IChannelHandlerContext {
        private var _pipeline : DefaultChannelPipeline;
        private var _next : DefaultChannelHandlerContext;
        private var _previous : DefaultChannelHandlerContext;

        private var _name : String;
        private var _handler : IChannelHandler;
        private var _canHandleUpstream : Boolean;
        private var _canHandleDownstream : Boolean;

        private var _attachment : *;

        public function DefaultChannelHandlerContext(pipeline : DefaultChannelPipeline,
                                                     previous : DefaultChannelHandlerContext,
                                                     next : DefaultChannelHandlerContext,
                                                     name : String,
                                                     handler : IChannelHandler) {
            if (pipeline == null)
                throw new ArgumentError("pipeline");
            if (name == null)
                throw new ArgumentError("name");
            if (handler == null)
                throw new ArgumentError("handler");

            _canHandleUpstream = handler is IChannelUpstreamHandler;
            _canHandleDownstream = handler is IChannelDownstreamHandler;

            if (!_canHandleUpstream && !_canHandleDownstream) {
                throw new ArgumentError("handler must be either " +
                                        "IChannelUpstreamHandler or " +
                                        "IChannelDownstreamHandler.");
            }

            _pipeline = pipeline;
            _previous = previous;
            _next = next;
            _name = name;
            _handler = handler;
        }

        public function get next() : DefaultChannelHandlerContext {
            return _next;
        }

        public function set next(value : DefaultChannelHandlerContext) : void {
            _next = value;
        }

        public function get previous() : DefaultChannelHandlerContext {
            return _previous;
        }

        public function set previous(value : DefaultChannelHandlerContext) : void {
            _previous = value;
        }

        public function sendUpstream(event : IChannelEvent) : void {
            const next : DefaultChannelHandlerContext =
                _pipeline.getActualUpstreamContext(_next);
            if (next != null)
                _pipeline.sendUpstreamForContext(next, event);
        }

        public function sendDownstream(event : IChannelEvent) : void {
            const previous : DefaultChannelHandlerContext =
                _pipeline.getActualDownstreamContext(_previous);
            if (previous == null) {
                try {
                    _pipeline.sink.eventSunk(_pipeline, event);
                } catch (e : Error) {
                    _pipeline.notifyHandlerException(event, e);
                }
            } else {
                _pipeline.sendDownstreamForContext(previous, event);
            }
        }

        public function get name() : String {
            return _name;
        }

        public function get channel() : IChannel {
            return pipeline.channel;
        }

        public function get pipeline() : IChannelPipeline {
            return _pipeline;
        }

        public function get handler() : IChannelHandler {
            return _handler;
        }

        public function get canHandleUpstreamEvents() : Boolean {
            return _canHandleUpstream;
        }

        public function get canHandleDownstreamEvents() : Boolean {
            return _canHandleDownstream;
        }

        public function get attachment() : * {
            return _attachment;
        }

        public function set attachment(value : *) : void {
            _attachment = value;
        }
    }
}
