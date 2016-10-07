require 'spec_helper'

describe JsonApiResponders::Responder do
  let(:controller) { FakeController.new }
  let(:resource)   { FakeModel.new }
  let(:responder) do
    JsonApiResponders::Responder.new(controller, resource, params: { action: action })
  end
  let(:options) do
    { status: status, content_type: 'application/vnd.api+json',
      json: resource, params: { action: action } }
  end
  let(:error_options) do
    {
      status: status, content_type: 'application/vnd.api+json',
      json: {
        errors: [
          {
            title: 'json_api.errors.conflict.title',
            detail: 'Name cant be blank',
            source: { parameter: :name, pointer: 'data/attributes/name' }
          }
        ]
      }
    }
  end

  describe '#respond_to_index_action' do
    let(:action) { 'index' }
    let(:status) { :ok }

    it 'renders ok' do
      expect(controller).to receive(:render).with(options)
      responder.respond!
    end
  end

  describe '#respond_to_show_action' do
    let(:action) { 'show' }
    let(:status) { :ok }

    it 'renders ok' do
      expect(controller).to receive(:render).with(options)
      responder.respond!
    end
  end

  describe '#respond_to_create_action' do
    let(:action) { 'create' }

    context 'when resource valid' do
      let(:status) { :created }

      it 'renders created' do
        allow(resource).to receive(:valid?).and_return(true)
        expect(controller).to receive(:render).with(options)
        responder.respond!
      end
    end

    context 'when resource invalid' do
      let(:status) { :conflict }

      it 'renders conflict' do
        allow(resource).to receive(:valid?).and_return(false)
        expect(controller).to receive(:render).with(error_options)
        responder.respond!
      end
    end
  end

  describe '#respond_to_update_action' do
    let(:action) { 'update' }

    context 'when resource valid' do
      let(:status) { :ok }

      it 'renders ok' do
        allow(resource).to receive(:valid?).and_return(true)
        expect(controller).to receive(:render).with(options)
        responder.respond!
      end
    end

    context 'when resource invalid' do
      let(:status) { :conflict }

      it 'renders conflict' do
        allow(resource).to receive(:valid?).and_return(false)
        expect(controller).to receive(:render).with(error_options)
        responder.respond!
      end
    end
  end

  describe '#respond_to_destroy_action' do
    let(:action) { 'destroy' }
    let(:status) { :no_content }

    it 'renders no_content' do
      expect(controller).to receive(:head).with(status, status: :no_content, content_type: 'application/vnd.api+json')
      responder.respond!
    end
  end
end
