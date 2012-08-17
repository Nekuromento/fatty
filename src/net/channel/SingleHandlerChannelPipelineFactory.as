package net.channel {
    public class SingleHandlerChannelPipelineFactory implements IChannelPipelineFactory {
        private var _pipeline : IChannelPipeline;

        public function SingleHandlerChannelPipelineFactory(pipeline : IChannelPipeline) {
            _pipeline = pipeline;
        }

        public function get pipeline() : IChannelPipeline {
            return Channels.copyPipeline(_pipeline);
        }
    }
}
