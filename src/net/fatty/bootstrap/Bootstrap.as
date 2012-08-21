package net.fatty.bootstrap {
    import net.fatty.channel.Channels;
    import net.fatty.channel.IChannelFactory;
    import net.fatty.channel.IChannelPipeline;
    import net.fatty.channel.IChannelPipelineFactory;

    import util.errors.IllegalStateException;

    public class Bootstrap {
        private var _channelFactory : IChannelFactory;
        private var _pipeline : IChannelPipeline = Channels.pipeline();
        private var _pipelineFactory : IChannelPipelineFactory = Channels.pipelineFactory(_pipeline);

        public function Bootstrap(factory : IChannelFactory = null) {
            _channelFactory = factory;
        }

        public function get channelFactory() : IChannelFactory {
            if (_channelFactory == null)
                throw new IllegalStateException("factory is not set yet.");
            return _channelFactory;
        }

        public function set channelFactory(factory : IChannelFactory) : void {
            if (factory == null)
                throw new ArgumentError("factory");
            if (_channelFactory != null)
                throw new IllegalStateException("factory can't change once set.");
            _channelFactory = factory;
        }

        public function get pipeline() : IChannelPipeline {
            if (_pipeline == null)
                throw new IllegalStateException("get pipeline() cannot be called " +
                                                "if set pipelineFactory() was called.");
            return _pipeline;
        }

        public function set pipeline(pipeline : IChannelPipeline) : void {
            if (pipeline == null)
                throw new ArgumentError("pipeline");
            _pipeline = pipeline;
            _pipelineFactory = Channels.pipelineFactory(pipeline);
        }

        public function get pipelineFactory() : IChannelPipelineFactory {
            return _pipelineFactory;
        }

        public function set pipelineFactory(pipelineFactory : IChannelPipelineFactory) : void {
            if (pipelineFactory == null)
                throw new ArgumentError("pipelineFactory");

            _pipeline = null;
            _pipelineFactory = pipelineFactory;
        }
    }
}
