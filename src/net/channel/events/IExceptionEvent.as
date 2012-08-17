package net.channel.events {
    public interface IExceptionEvent extends IChannelEvent {
        function get cause() : Error;
    }
}
