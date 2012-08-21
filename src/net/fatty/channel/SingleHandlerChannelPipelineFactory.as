package net.fatty.channel {
    public class SingleHandlerChannelPipelineFactory implements IChannelPipelineFactory {
        private var _pipeline : IChannelPipeline;

        public function SingleHandlerChannelPipelineFactory(pipeline : IChannelPipeline) {
            _pipeline = pipeline;
        }

        public function get newPipeline() : IChannelPipeline {
            return Channels.copyPipeline(_pipeline);
        }
    }
}
