package net.fatty.channel.events {
    import net.fatty.channel.ChannelState;

    public interface IChannelStateEvent extends IChannelEvent {
        function get state() : ChannelState;
        function get value() : *;
    }
}
