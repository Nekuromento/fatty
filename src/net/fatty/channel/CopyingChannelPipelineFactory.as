package net.fatty.channel {
    public class CopyingChannelPipelineFactory implements IChannelPipelineFactory {
        private var _pipeline : IChannelPipeline;

        public function CopyingChannelPipelineFactory(pipeline : IChannelPipeline) {
            _pipeline = pipeline;
        }

        public function get newPipeline() : IChannelPipeline {
            return Channels.copyPipeline(_pipeline);
        }
    }
}
