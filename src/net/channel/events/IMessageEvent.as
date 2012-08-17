package net.channel.events {
    import net.SocketAddress;

    public interface IMessageEvent extends IChannelEvent {
        function get message() : *;
        function get remoteAddress() : SocketAddress;
    }
}
