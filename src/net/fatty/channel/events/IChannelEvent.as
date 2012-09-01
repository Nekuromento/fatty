package net.fatty.channel.events {
    import net.fatty.channel.IChannel;

    public interface IChannelEvent {
        function get channel() : IChannel;
    }
}
