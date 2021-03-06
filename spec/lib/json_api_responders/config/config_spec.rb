require 'spec_helper'
describe JsonApiResponders::Config do
  let(:config) { JsonApiResponders.config }

  context 'when config render method is not set' do
    after { clear_config }
    it 'render_method is set to default render method' do
      expect(config.render_method).to eq JsonApiResponders::Config::DEFAULT_RENDER_METHOD
    end
  end

  context 'when config render method is :jsonapi' do
    before do
      JsonApiResponders.configure do |config|
        config.render_method = :jsonapi
      end
    end
    after { clear_config }

    it 'render_method is set to :jsonapi' do
      expect(config.render_method).to eq :jsonapi
    end

  end

  context 'when config render method is :invalid' do
    after { clear_config }
    subject do
      JsonApiResponders.configure do |config|
        config.render_method = :invalid_render_method
      end
    end

    it 'raises an error' do
      expect{ subject }.to raise_error(JsonApiResponders::Errors::InvalidRenderMethodError)
    end
  end

  private

  def clear_config
    JsonApiResponders.instance_variable_set(:@config, nil)
  end
end
