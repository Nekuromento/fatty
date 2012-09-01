package net.fatty.channel {
    import net.fatty.channel.errors.ChannelHandlerLifeCycleException;
    import net.fatty.channel.errors.ChannelPipelineException;
    import net.fatty.channel.events.IChannelEvent;
    import net.fatty.channel.events.IExceptionEvent;
    import net.fatty.channel.events.UpstreamMessageEvent;

    import util.debug.warning;

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
            return _contextCount == 0;
        }

        public function sendDownstream(event : IChannelEvent) : void {
            const tail : DefaultChannelHandlerContext =
                getActualDownstreamContext(_tail);
            if (tail == null) {
                try {
                    sink.eventSunk(this, event);
                    return;
                } catch (t : Error) {
                    notifyHandlerException(event, t);
                    return;
                }
            }
    
            sendDownstreamForContext(tail, event);
        }

        public function sendUpstream(event : IChannelEvent) : void {
            const head : DefaultChannelHandlerContext =
                getActualUpstreamContext(_head);
            if (head == null) {
                //TODO : implement proper logging
                warning("The pipeline contains no upstream handlers; discarding: " + event);
//                if (logger.isWarnEnabled()) {
//                    logger.warn(
//                            "The pipeline contains no upstream handlers; discarding: " + e);
//                }
                return;
            }
    
            sendUpstreamForContext(head, event);
        }

        public function getByName(name : String) : IChannelHandler {
            const ctx : DefaultChannelHandlerContext = _contextRegistry[name];
            return ctx != null ? ctx.handler : null;
        }

        public function getByType(type : Class) : IChannelHandler {
            const ctx : IChannelHandlerContext = getContextByType(type);
            return ctx != null ? ctx.handler : null;
        }

        public function getFirst() : IChannelHandler {
            return _head != null ? _head.handler : null;
        }

        public function getLast() : IChannelHandler {
            return _tail != null ? _tail.handler : null;
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

        private function callAfterAdd(ctx : IChannelHandlerContext) : void {
            if (!(ctx.handler is ILifeCycleAwareChannelHandler))
                return;
    
            const h : ILifeCycleAwareChannelHandler =
                ILifeCycleAwareChannelHandler(ctx.handler);
    
            try {
                h.afterAdd(ctx);
            } catch (t : Error) {
                var removed : Boolean = false;
                try {
                    removeContext(DefaultChannelHandlerContext(ctx));
                    removed = true;
                } catch (t2 : Error) {
                    //TODO: implement proper logging
                    warning("Failed to remove a handler: " + ctx.name, t2);
//                    if (logger.isWarnEnabled()) {
//                        logger.warn("Failed to remove a handler: " + ctx.name, t2);
//                    }
                }
    
                if (removed) {
                    throw new ChannelHandlerLifeCycleException(String(h) +
                                                               ".afterAdd() has thrown an exception; removed.", t);
                } else {
                    throw new ChannelHandlerLifeCycleException(String(h) +
                                                               ".afterAdd() has thrown an exception; also failed to remove.", t);
                }
            }
        }

        private function callBeforeAdd(ctx : DefaultChannelHandlerContext) : void {
            if (!(ctx.handler is ILifeCycleAwareChannelHandler))
                return;
    
            const h : ILifeCycleAwareChannelHandler =
                ILifeCycleAwareChannelHandler(ctx.handler);
    
            try {
                h.beforeAdd(ctx);
            } catch (t : Error) {
                throw new ChannelHandlerLifeCycleException(String(h) +
                                                           ".beforeAdd() has thrown an exception; not adding.", t);
            }
        }

        private function checkDuplicateName(name : String) : void {
            if (_contextRegistry[name] != null)
                throw new ArgumentError("Duplicate handler name: " + name);
        }

        private function init(name : String, handler : IChannelHandler) : void {
            const ctx : DefaultChannelHandlerContext =
                new DefaultChannelHandlerContext(this, null, null, name, handler);
            callBeforeAdd(ctx);
            _head = ctx;
            _tail = ctx;
            for each (var key : * in DictionaryUtil.getKeys(_contextRegistry))
                delete _contextRegistry[key];
            _contextRegistry[name] = ctx;
            _contextCount = 1;
            callAfterAdd(ctx);
        }

        public function removeFirst() : IChannelHandler {
            if (registryEmpty)
                throw new IllegalOperationError("nothing to remove");
    
            const oldHead : DefaultChannelHandlerContext = _head;
            if (oldHead == null)
                throw new IllegalOperationError("nothing to remove");
    
            callBeforeRemove(oldHead);
    
            if (oldHead.next == null) {
                _head = null;
                _tail = null;
                for each (var key : * in DictionaryUtil.getKeys(_contextRegistry))
                    delete _contextRegistry[key];
                _contextCount = 0;
            } else {
                oldHead.next.previous = null;
                _head = oldHead.next;
                delete _contextRegistry[oldHead.name];
                --_contextCount;
            }
    
            callAfterRemove(oldHead);
    
            return oldHead.handler;
        }

        public function removeLast() : IChannelHandler {
            if (registryEmpty)
                throw new IllegalOperationError("nothing to remove");
    
            const oldTail : DefaultChannelHandlerContext = _tail;
            if (oldTail == null)
                throw new IllegalOperationError("nothing to remove");
    
            callBeforeRemove(oldTail);
    
            if (oldTail.previous == null) {
                _head = null;
                _tail = null;
                for each (var key : * in DictionaryUtil.getKeys(_contextRegistry))
                    delete _contextRegistry[key];
                _contextCount = 0;
            } else {
                oldTail.previous.next = null;
                _tail = oldTail.previous;
                delete _contextRegistry[oldTail.name];
                --_contextCount;
            }
    
            callBeforeRemove(oldTail);
    
            return oldTail.handler;
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
            if (!(ctx.handler is ILifeCycleAwareChannelHandler))
                return;
    
            const h : ILifeCycleAwareChannelHandler =
                ILifeCycleAwareChannelHandler(ctx.handler);
    
            try {
                h.afterRemove(ctx);
            } catch (t : Error) {
                throw new ChannelHandlerLifeCycleException(String(h) +
                                                           ".afterRemove() has thrown an exception.", t);
            }
        }

        private function callBeforeRemove(ctx : DefaultChannelHandlerContext) : void {
            if (!(ctx.handler is ILifeCycleAwareChannelHandler))
                return;
    
            const h : ILifeCycleAwareChannelHandler =
                ILifeCycleAwareChannelHandler(ctx.handler);
    
            try {
                h.beforeRemove(ctx);
            } catch (t : Error) {
                throw new ChannelHandlerLifeCycleException(String(h) +
                                                           ".beforeRemove() has thrown an exception; not removing.", t);
            }
        }

        private function getContextOrDie(handler : IChannelHandler) : DefaultChannelHandlerContext {
            const ctx : DefaultChannelHandlerContext =
                DefaultChannelHandlerContext(getContext(handler));
            if (ctx == null)
                throw new ArgumentError("no such element");
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
            replaceContext(getContextOrDie(oldHandler), newName, newHandler);
        }

        private function replaceContext(ctx : DefaultChannelHandlerContext,
                                        newName : String,
                                        newHandler : IChannelHandler) : void {
            if (ctx == _head) {
                removeFirst();
                addFirst(newName, newHandler);
            } else if (ctx == _tail) {
                removeLast();
                addLast(newName, newHandler);
            } else {
                const sameName : Boolean = ctx.name == newName;
                if (!sameName)
                    checkDuplicateName(newName);
    
                const previous : DefaultChannelHandlerContext = ctx.previous;
                const next : DefaultChannelHandlerContext = ctx.next;
                const newCtx : DefaultChannelHandlerContext =
                    new DefaultChannelHandlerContext(this, previous, next, newName, newHandler);
    
                callBeforeRemove(ctx);
                callBeforeAdd(newCtx);
    
                previous.next = newCtx;
                next.previous = newCtx;
    
                if (!sameName) {
                    delete _contextRegistry[ctx.name];
                    --_contextCount;
                }
                _contextRegistry[newName] = newCtx;
                ++_contextCount;
    
                var removeException : ChannelHandlerLifeCycleException = null;
                var addException : ChannelHandlerLifeCycleException = null;
                var removed : Boolean = false;
                try {
                    callAfterRemove(ctx);
                    removed = true;
                } catch (e : ChannelHandlerLifeCycleException) {
                    removeException = e;
                }
    
                var added : Boolean = false;
                try {
                    callAfterAdd(newCtx);
                    added = true;
                } catch (e : ChannelHandlerLifeCycleException) {
                    addException = e;
                }
    
                if (!removed && !added) {
                    //TODO: implement proper logging
                    warning(removeException.message);
                    warning(addException.message);
//                    logger.warn(removeException.getMessage(), removeException);
//                    logger.warn(addException.getMessage(), addException);
                    throw new ChannelHandlerLifeCycleException("Both " + String(ctx.handler) +
                                                               ".afterRemove() and " + String(newCtx.handler) +
                                                               ".afterAdd() failed; see logs.");
                } else if (!removed) {
                    throw removeException;
                } else if (!added) {
                    throw addException;
                }
            }
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
            if (handler == null)
                throw new ArgumentError("handler");
            if (registryEmpty)
                return null;

            var ctx : DefaultChannelHandlerContext = _head;
            for (; ctx != null; ctx = ctx.next) {
                if (ctx.handler == handler)
                    return ctx;
            }
            return null;
        }

        public function getContextByName(name : String) : IChannelHandlerContext {
            return getContext(getByName(name));
        }

        public function getContextByType(type : Class) : IChannelHandlerContext {
            if (type == null)
                throw new ArgumentError("handlerType");
    
            if (registryEmpty)
                return null;

            var ctx : DefaultChannelHandlerContext = _head;
            for (; ctx != null; ctx = ctx.next) {
                if (ctx.handler is type)
                    return ctx;
            }
            return null;
        }

        public function getActualUpstreamContext(ctx : DefaultChannelHandlerContext) : DefaultChannelHandlerContext {
            if (ctx == null)
                return null;
    
            var realCtx : DefaultChannelHandlerContext = ctx;
            while (!realCtx.canHandleUpstreamEvents) {
                realCtx = realCtx.next;
                if (realCtx == null)
                    return null;
            }
    
            return realCtx;
        }

        public function getActualDownstreamContext(ctx : DefaultChannelHandlerContext) : DefaultChannelHandlerContext {
            if (ctx == null)
                return null;
    
            var realCtx : DefaultChannelHandlerContext = ctx;
            while (!realCtx.canHandleDownstreamEvents) {
                realCtx = realCtx.previous;
                if (realCtx == null)
                    return null;
            }
    
            return realCtx;
        }

        public function sendUpstreamForContext(ctx : DefaultChannelHandlerContext,
                                               event : IChannelEvent) : void {
            try {
                IChannelUpstreamHandler(ctx.handler).handleUpstream(ctx, event);
            } catch (t : Error) {
                notifyHandlerException(event, t);
            }
        }

        public function sendDownstreamForContext(ctx : DefaultChannelHandlerContext,
                                                 event : IChannelEvent) : void {
            if (event is UpstreamMessageEvent)
                throw new ArgumentError("cannot send an upstream event to downstream");

            try {
                IChannelDownstreamHandler(ctx.handler).handleDownstream(ctx, event);
            } catch (t : Error) {
                notifyHandlerException(event, t);
            }
        }

        public function notifyHandlerException(event : IChannelEvent,
                                               e : Error) : void {
            if (event is IExceptionEvent) {
                //TODO: implement proper logging
                warning("An exception was thrown by a user handler " +
                        "while handling an exception event (" + event + ")", e);
//                if (logger.isWarnEnabled()) {
//                    logger.warn(
//                            "An exception was thrown by a user handler " +
//                            "while handling an exception event (" + event + ")", e);
//                }
    
                return;
            }
    
            const pe : ChannelPipelineException =
                e is ChannelPipelineException
                    ? e as ChannelPipelineException
                    : new ChannelPipelineException("", e);
    
            try {
                sink.exceptionCaught(this, event, pe);
            } catch (error : Error) {
                //TODO: implement proper logging
                warning("An exception was thrown by an exception handler.", error);
//                if (logger.isWarnEnabled()) {
//                    logger.warn("An exception was thrown by an exception handler.", error);
//                }
            }
        }

        public function asArray() : Array {
            const array : Array = new Array();
            var ctx : DefaultChannelHandlerContext = _head;
            for (; ctx != null; ctx = ctx.next) {
                array.push(ctx.name);
                array.push(ctx.handler);
            }
            return array;
        }
    }
}
