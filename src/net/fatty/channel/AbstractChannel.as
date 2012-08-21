package net.fatty.channel {
    import net.SocketAddress;

    import util.Random;
    import util.errors.UnimplementedException;

    import flash.utils.Dictionary;

    public class AbstractChannel implements IChannel {
        private static const _allChannels : Dictionary = new Dictionary();
        private static const _random : Random = new Random();

        private var _remoteAddress : SocketAddress;
        private var _worker : IWorker;
    
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

            return 0;
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

        public final function get worker() : IWorker {
            return _worker;
        }

        public final function set worker(value : IWorker) : void {
            _worker = value;
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
    
        public function setClosed() : void {
            // Deallocate the current channel's ID from allChannels so that other
            // new channels can use it.
            delete _allChannels[id];
            _closed = true;
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
    
        public function write(message : *, remoteAddress : SocketAddress = null) : void {
            if (remoteAddress == null || remoteAddress == _remoteAddress)
                Channels.write(this, message, null);
            else
                Channels.write(this, message, remoteAddress);
        }
    
        public function get attachment() : * {
            return _attachment;
        }
    
        public function set attachment(value : *) : void {
            _attachment = attachment;
        }

        public function get isConnected() : Boolean {
            return isOpen && isSocketConnected;
        }

        // abstract property
        public function get isSocketConnected() : Boolean {
            throw new UnimplementedException();
            return false;
        }

        // abstract property
        public function get isSocketClosed() : Boolean {
            throw new UnimplementedException();
            return false;
        }

        // abstract function
        public function closeSocket() : void {
            throw new UnimplementedException();
        }

        // abstract function
        public function getRemoteSocketAddress() : SocketAddress {
            throw new UnimplementedException();
            return null;
        }

        public function get remoteAddress() : SocketAddress {
            if (_remoteAddress == null)
                _remoteAddress = getRemoteSocketAddress();
            return _remoteAddress;
        }
    }
}
