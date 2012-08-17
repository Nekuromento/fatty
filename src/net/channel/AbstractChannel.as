package net.channel {
    import net.SocketAddress;

    import util.Random;
    import util.errors.UnimplementedException;

    import flash.utils.Dictionary;

    public class AbstractChannel implements IChannel {
        private static const _allChannels : Dictionary = new Dictionary();
        private static const _random : Random = new Random();
    
        private static function allocateId(channel : IChannel) : uint {
            var id : uint = _random.nextUInt();
            for (;;) {
                // Loop until a unique ID is acquired.
                // It should be found in one loop practically.
                if (_allChannels[id] == null) {
                    _allChannels[id] == channel;
                    // Successfully acquired.
                    return id;
                } else {
                    // Taken by other channel
                    ++id;
                }
            }
        }
    
        private var _id : uint;
        private var _closed : Boolean;
        private var _factory : IChannelFactory;
        private var _pipeline : IChannelPipeline;
        private var _attachment : *;
    
        public function AbstractChannel(factory : IChannelFactory,
                                        pipeline : IChannelPipeline,
                                        sink : IChannelSink) {
            _factory = factory;
            _pipeline = pipeline;
    
            _id = allocateId(this);
    
            pipeline.attach(this, sink);
        }
    
        public final function get id() : uint {
            return _id;
        }
    
        public function get factory() : IChannelFactory {
            return _factory;
        }
    
        public function get pipeline() : IChannelPipeline {
            return _pipeline;
        }
    
        public function get isOpen() : Boolean {
            return !_closed;
        }
    
        protected function setClosed() : Boolean {
            // Deallocate the current channel's ID from allChannels so that other
            // new channels can use it.
            delete _allChannels[id];
    
            return _closed = true;
        }
    
        public function close() : void {
            Channels.close(this);
        }
    
        public function connect(remoteAddress : SocketAddress) : void {
            Channels.connect(this, remoteAddress);
        }
    
        public function disconnect() : void{
            Channels.disconnect(this);
        }
    
        public function write(message : *) : void {
            Channels.write(this, message);
        }
    
        public function get attachment() : * {
            return _attachment;
        }
    
        public function set attachment(value : *) : void {
            _attachment = attachment;
        }

        // abstract property
        public function get isBound() : Boolean {
            throw new UnimplementedException();
            return false;
        }

        // abstract property
        public function get isConnected() : Boolean {
            throw new UnimplementedException();
            return false;
        }

        // abstract property
        public function get remoteAddress() : SocketAddress {
            throw new UnimplementedException();
            return null;
        }
    }
}
