package net.channel {
    import com.adobe.utils.DictionaryUtil;

    import flash.errors.IllegalOperationError;
    import flash.utils.Dictionary;

    public class DefaultChannelPipeline implements IChannelPipeline {
        private static const _discardingSink : IChannelSink = new DiscardingChannelSink();

        private const _contextRegistry : Dictionary = new Dictionary();
        private var _contextCount : int;
        private var _sink : IChannelSink;
        private var _channel : IChannel;
        private var _head : DefaultChannelHandlerContext;
        private var _tail : DefaultChannelHandlerContext;

        public function attach(channel : IChannel, sink : IChannelSink) : void {
            if (channel == null)
                throw new ArgumentError("channel");
            if (sink == null)
                throw new ArgumentError("sink");

            if (_sink != null && _channel != null)
                throw new IllegalOperationError("already attached");

            _channel = channel;
            _sink = sink;
        }

        private function get registryEmpty() : Boolean {
            return _contextCount > 0;
        }

        public function sendDownstream(event : IChannelEvent) : void {
            //TODO: implement
        }

        public function sendUpstream(event : IChannelEvent) : void {
            //TODO: implement
        }

        public function getByName(name : String) : IChannelHandler {
            //TODO: implement
            return null;
        }

        public function getByType(type : Class) : IChannelHandler {
            //TODO: implement
            return null;
        }

        public function getFirst() : IChannelHandler {
            //TODO: implement
            return null;
        }

        public function getLast() : IChannelHandler {
            //TODO: implement
            return null;
        }

        public function addFirst(name : String, handler : IChannelHandler) : void {
            if (registryEmpty) {
                init(name, handler);
            } else {
                checkDuplicateName(name);
                var oldHead : DefaultChannelHandlerContext = _head;
                var newHead : DefaultChannelHandlerContext =
                    new DefaultChannelHandlerContext(this, null, oldHead, name, handler);
    
                callBeforeAdd(newHead);
    
                oldHead.previous = newHead;
                _head = newHead;
                _contextRegistry[name] = newHead;
                ++_contextCount;
    
                callAfterAdd(newHead);
            }
        }

        public function addLast(name : String, handler : IChannelHandler) : void {
            if (registryEmpty) {
                init(name, handler);
            } else {
                checkDuplicateName(name);
                var oldTail : DefaultChannelHandlerContext = _tail;
                var newTail : DefaultChannelHandlerContext =
                    new DefaultChannelHandlerContext(this, oldTail, null, name, handler);
    
                callBeforeAdd(newTail);
    
                oldTail.next = newTail;
                _tail = newTail;
                _contextRegistry[name] = newTail;
                ++_contextCount;
    
                callAfterAdd(newTail);
            }
        }

        private function callAfterAdd(context : DefaultChannelHandlerContext) : void {
            //TODO: implement
        }

        private function callBeforeAdd(context : DefaultChannelHandlerContext) : void {
            //TODO: implement
        }

        private function checkDuplicateName(name : String) : void {
            //TODO: implement
        }

        private function init(name : String, handler : IChannelHandler) : void {
            //TODO: implement
        }

        public function removeFirst() : IChannelHandler {
            // TODO: Auto-generated method stub
            return null;
        }

        public function removeLast() : IChannelHandler {
            // TODO: Auto-generated method stub
            return null;
        }

        public function remove(handler : IChannelHandler) : void {
            removeContext(getContextOrDie(handler));
        }

        private function removeContext(ctx : DefaultChannelHandlerContext) : void {
            if (_head == _tail) {
                _head = null;
                _tail = null;
                for each (var key : * in DictionaryUtil.getKeys(_contextRegistry))
                    delete _contextRegistry[key];
                _contextCount = 0;
            } else if (ctx == _head) {
                removeFirst();
            } else if (ctx == _tail) {
                removeLast();
            } else {
                callBeforeRemove(ctx);
    
                const previous : DefaultChannelHandlerContext = ctx.previous;
                const next : DefaultChannelHandlerContext = ctx.next;
                previous.next = next;
                next.previous = previous;
                delete _contextRegistry[ctx.name];
                --_contextCount;
    
                callAfterRemove(ctx);
            }
        }

        private function callAfterRemove(ctx : DefaultChannelHandlerContext) : void {
            //TODO: implement
        }

        private function callBeforeRemove(ctx : DefaultChannelHandlerContext) : void {
            //TODO: implement
        }

        private function getContextOrDie(handler : IChannelHandler) : DefaultChannelHandlerContext {
            const ctx : DefaultChannelHandlerContext =
                DefaultChannelHandlerContext(getContext(handler));
            if (ctx == null)
                throw new ArgumentError("no such element");
            else
                return ctx;
        }

        public function removeByName(name : String) : IChannelHandler {
            const oldHandler : IChannelHandler = getByName(name);
            remove(oldHandler);
            return oldHandler;
        }

        public function removeByType(type : Class) : IChannelHandler {
            const oldHandler : IChannelHandler = getByType(type);
            remove(oldHandler);
            return oldHandler;
        }

        public function replace(oldHandler : IChannelHandler,
                                newName : String,
                                newHandler : IChannelHandler) : void {
            //TODO: implement
        }

        public function replaceByName(oldName : String,
                                      newName : String,
                                      handler : IChannelHandler) : IChannelHandler {
            const oldHandler : IChannelHandler = getByName(oldName);
            replace(oldHandler, newName, handler);
            return oldHandler;
        }

        public function replaceByType(type : Class,
                                      name : String,
                                      handler : IChannelHandler) : IChannelHandler {
            const oldHandler : IChannelHandler = getByType(type);
            replace(oldHandler, name, handler);
            return oldHandler;
        }

        public function addBefore(handler : IChannelHandler,
                                  name : String,
                                  newHandler : IChannelHandler) : void {
            const ctx : DefaultChannelHandlerContext = getContextOrDie(handler);
            if (ctx == _head) {
                addFirst(name, handler);
            } else {
                checkDuplicateName(name);
                const newCtx : DefaultChannelHandlerContext =
                    new DefaultChannelHandlerContext(this, ctx.previous, ctx, name, handler);
    
                callBeforeAdd(newCtx);
    
                ctx.previous.next = newCtx;
                ctx.previous = newCtx;
                _contextRegistry[name] = newCtx;
                ++_contextCount;
    
                callAfterAdd(newCtx);
            }
        }

        public function addBeforeName(name : String,
                                      newName : String,
                                      handler : IChannelHandler) : void {
            addBefore(getByName(name), newName, handler);
        }

        public function addBeforeType(type : Class,
                                      name : String,
                                      handler : IChannelHandler) : void {
            addBefore(getByType(type), name, handler);
        }

        public function addAfter(handler : IChannelHandler,
                                 name : String,
                                 newHandler : IChannelHandler) : void {
            const ctx : DefaultChannelHandlerContext = getContextOrDie(handler);
            if (ctx == _tail) {
                addLast(name, handler);
            } else {
                checkDuplicateName(name);
                const newCtx : DefaultChannelHandlerContext =
                    new DefaultChannelHandlerContext(this, ctx, ctx.next, name, handler);
    
                callBeforeAdd(newCtx);
    
                ctx.next.previous = newCtx;
                ctx.next = newCtx;
                _contextRegistry[name] = newCtx;
                ++_contextCount;
    
                callAfterAdd(newCtx);
            }
        }

        public function addAfterName(name : String,
                                     newName : String,
                                     handler : IChannelHandler) : void {
            addAfter(getByName(name), newName, handler);
        }

        public function addAfterType(type : Class,
                                     name : String,
                                     handler : IChannelHandler) : void {
            addAfter(getByType(type), name, handler);
        }

        public function get channel() : IChannel {
            return _channel;
        }

        public function get sink() : IChannelSink {
            return _sink != null ? _sink : _discardingSink;
        }

        public function get isAttached() : Boolean {
            return _sink != null;
        }

        public function getContext(handler : IChannelHandler) : IChannelHandlerContext {
            //TODO: implement
            return null;
        }

        public function getContextByName(name : String) : IChannelHandlerContext {
            return getContext(getByName(name));
        }

        public function getContextByType(type : Class) : IChannelHandlerContext {
            return getContext(getByType(type));
        }

        public function getActualUpstreamContext(next : DefaultChannelHandlerContext) : DefaultChannelHandlerContext {
            //TODO: implement
            return null;
        }

        public function getActualDownstreamContext(previous : DefaultChannelHandlerContext) : DefaultChannelHandlerContext {
            //TODO: implement
            return null;
        }

        public function sendUpstreamForContext(next : DefaultChannelHandlerContext,
                                               event : IChannelEvent) : void {
            //TODO: implement
        }

        public function sendDownstreamForContext(previous : DefaultChannelHandlerContext,
                                                 event : IChannelEvent) : void {
            //TODO: implement
        }

        public function notifyHandlerException(event : IChannelEvent,
                                               e : Error) : void {
            //TODO: implement
        }
    }
}
