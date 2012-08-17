package net.channel.events {
    import net.channel.ChannelState;

    public interface IChannelStateEvent extends IChannelEvent {
        function get state() : ChannelState;
        function get value() : *;
    }
}
