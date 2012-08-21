package net.fatty.channel.events {
    import net.fatty.channel.IChannel;

    public class DefaultWriteCompletionEvent implements IWriteCompletionEvent {
        private var _channel : IChannel;
        private var _writtenAmount : uint;
    
        public function DefaultWriteCompletionEvent(channel : IChannel,
                                                    writtenAmount : uint) {
            if (channel == null)
                throw new ArgumentError("channel");
    
            _channel = channel;
            _writtenAmount = writtenAmount;
        }

        public function get channel() : IChannel {
            return _channel;
        }

        public function get writtenAmount() : uint {
            return _writtenAmount;
        }
    }
}
