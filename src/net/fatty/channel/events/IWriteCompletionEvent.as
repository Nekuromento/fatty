package net.fatty.channel.events {
    import net.fatty.channel.events.IChannelEvent;

    public interface IWriteCompletionEvent extends IChannelEvent {
        function get writtenAmount() : uint;
    }
}
