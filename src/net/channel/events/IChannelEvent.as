package net.channel.events {
    import net.channel.IChannel;

    public interface IChannelEvent {
        function get channel() : IChannel;
    }
}
