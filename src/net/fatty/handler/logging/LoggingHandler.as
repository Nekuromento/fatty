package net.fatty.handler.logging {
    import net.fatty.channel.IChannelDownstreamHandler;
    import net.fatty.channel.IChannelHandlerContext;
    import net.fatty.channel.IChannelUpstreamHandler;
    import net.fatty.channel.events.IChannelEvent;
    import net.fatty.channel.events.IExceptionEvent;
    import net.fatty.channel.events.IMessageEvent;

    import util.debug.info;
    import util.debug.warning;

    import com.adobe.utils.IntUtil;

    import flash.utils.ByteArray;

    public class LoggingHandler implements IChannelUpstreamHandler, IChannelDownstreamHandler {
//        private static const DEFAULT_LEVEL : InternalLogLevel = InternalLogLevel.DEBUG;
        private static const NEWLINE : String = "\n";
    
        private static const BYTE2HEX : Vector.<String> = new Vector.<String>(256, true);
        private static const HEXPADDING : Vector.<String> = new Vector.<String>(16, true);
        private static const BYTEPADDING : Vector.<String> = new Vector.<String>(16, true);
        private static const BYTE2CHAR : Vector.<String> = new Vector.<String>(256, true);

        private static var _initialized : Boolean;
    
//        private var _logger : InternalLogger;
//        private var _level : InternalLogLevel;
        private var _hexDump : Boolean;
    
        private static function init() : void {
            const hexChars : String = "0123456789abcdef";
            var i : uint;
            var j : uint;
            var padding : uint;
            var buf : String;
    
            // Generate the lookup table for byte-to-hex-dump conversion
            for (i = 0; i < 10; ++i)
                BYTE2HEX[i] = " 0" + i;
            for (; i < BYTE2HEX.length; ++i)
                BYTE2HEX[i] = " " + hexChars.charAt((i >> 4) & 0xF) + hexChars.charAt(i & 0xF);
    
            // Generate the lookup table for hex dump paddings
            for (i = 0; i < HEXPADDING.length; ++i) {
                padding = HEXPADDING.length - i;
                buf = "";
                for (j = 0; j < padding; ++j)
                    buf += "   ";
                HEXPADDING[i] = buf;
            }
    
            // Generate the lookup table for byte dump paddings
            for (i = 0; i < BYTEPADDING.length; ++i) {
                padding = BYTEPADDING.length - i;
                buf = "";
                for (j = 0; j < padding; ++j)
                    buf += ' ';
                BYTEPADDING[i] = buf;
            }
    
            // Generate the lookup table for byte-to-char conversion
            for (i = 0; i < BYTE2CHAR.length; ++i) {
                if (i <= 0x1f || i >= 0x7f)
                    BYTE2CHAR[i] = '.';
                else
                    BYTE2CHAR[i] = String.fromCharCode(i);
            }

            _initialized = true;
        }
    
        public function LoggingHandler(/*level : InternalLogLevel, */hexDump : Boolean = true) : void {
//            if (level == null) {
//                throw new ArgumentError("level");
    
//            logger = InternalLoggerFactory.getInstance(getClass());
//            _level = level;
            _hexDump = hexDump;

            if (!_initialized)
                init();
        }
    
//        public function get logger() : InternalLogger {
//            return _logger;
//        }
    
//        public function get level() : InternalLogLevel {
//            return _level;
//        }
    
        public function log(e : IChannelEvent) : void {
//            if (getLogger().isEnabled(level)) {
                var msg : String = String(e);
    
                // Append hex dump if necessary.
                if (_hexDump && e is IMessageEvent) {
                    const me : IMessageEvent = IMessageEvent(e);
                    if (me.message is ByteArray)
                        msg += formatBuffer(ByteArray(me.message));
                }
    
                // Log the message (and exception if available.)
                if (e is IExceptionEvent)
                    warning(msg, IExceptionEvent(e).cause);
//                    logger.log(level, msg, IExceptionEvent(e).cause);
                else
                    info(msg);
//                    logger.log(level, msg);
//            }
        }
    
        private static function formatBuffer(buf : ByteArray) : String {
            const position : uint = buf.position;
            const length : uint = buf.bytesAvailable;
            var i : uint;
            var j : uint;
            var dump : String =
                NEWLINE + "         +-------------------------------------------------+" +
                NEWLINE + "         |  0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f |" +
                NEWLINE + "+--------+-------------------------------------------------+----------------+";
    
            for (i = 0; i < length; ++i) {
                const mod16 : uint = i & 15;
                if (mod16 == 0)
                    dump += NEWLINE + "|" + IntUtil.toHex(i, true) + '|';
                dump += BYTE2HEX[buf[position + i]];
                if (mod16 == 15) {
                    dump += " |";
                    for (j = i - 15; j <= i; ++j)
                        dump += BYTE2CHAR[buf[position + j]];
                    dump += '|';
                }
            }
    
            if ((i & 15) != 0) {
                const remainder : uint = length & 15;
                dump += HEXPADDING[remainder] + " |";
                for (j = i - remainder; j < i; ++j)
                    dump += BYTE2CHAR[buf[position + j]];
                dump += BYTEPADDING[remainder] + "|";
            }
    
            dump +=
                NEWLINE + "+--------+-------------------------------------------------+----------------+";

            return dump;
        }
    
        public function handleUpstream(ctx : IChannelHandlerContext, e : IChannelEvent) : void {
            log(e);
            ctx.sendUpstream(e);
        }
    
        public function handleDownstream(ctx : IChannelHandlerContext, e : IChannelEvent) : void {
            log(e);
            ctx.sendDownstream(e);
        }
    }
}
