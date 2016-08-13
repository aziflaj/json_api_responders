require 'spec_helper'

describe JsonApiResponders::Responder do
  let(:controller) { FakeController.new }
  let(:resource)   { FakeModel.new }
  let(:responder) do
    JsonApiResponders::Responder.new(controller, resource, params: { action: 'index' })
  end

  describe '#respond!' do
    it 'calls respond to action' do
      expect(responder).to receive(:respond_to_index_action)
      responder.respond!
    end

    it 'raises error if unknown action' do
      responder.options = { params: { action: 'fake' } }
      expect { responder.respond! }.to raise_error(JsonApiResponders::Errors::UnknownAction)
    end
  end

  describe '#respond_error' do
    it 'calls render action' do
      expect(responder).to receive(:render_error)
      responder.respond_error
    end
  end
end
