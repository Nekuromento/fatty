package net.channel {
    import net.SocketAddress;

    public interface IChannel {
        function get pipeline() : IChannelPipeline;
        function get isBound() : Boolean;
        function get isConnected() : Boolean;
        function get id() : uint;
        function get remoteAddress() : SocketAddress;

        function write(message : *) : void;
        function connect(address : SocketAddress) : void;
        function disconnect() : void;
        function close() : void;

        function get attachment() : *;
        function set attachment(value : *) : void;
    }
}
