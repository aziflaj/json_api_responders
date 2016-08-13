require 'spec_helper'

describe JsonApiResponders do
  let(:controller) { FakeController.new }
  let(:resource)   { FakeModel.new }
  let(:responder)  { double(:responder) }

  describe '#respond_with' do
    it 'calls responder' do
      expect(JsonApiResponders::Responder).to(
        receive(:new).with(controller, resource, params: {}).and_return(responder)
      )
      expect(responder).to receive(:respond!)
      controller.respond_with(resource)
    end

    context 'when resource invalid and on_error is passed' do
      it 'calls responder' do
        allow(resource).to receive(:valid?).and_return(false)
        expect(controller).to receive(:render).with(
          status: :unauthorized,
          content_type: 'application/vnd.api+json',
          json: { errors: [
            { detail: 'Unauthorized' },
            { title: 'json_api.errors.conflict.title',
              detail: 'Name cant be blank',
              source: { parameter: :name, pointer: 'data/attributes/name' } }
          ] }
        )
        controller.respond_with(
          resource, on_error: { status: 401, detail: 'Unauthorized' }, params: { action: 'create' }
        )
      end
    end
  end

  describe '#respond_with_error' do
    it 'calls responder with on_error' do
      expect(JsonApiResponders::Responder).to(
        receive(:new).with(
          controller, on_error: { status: :forbidden, error: 'help me' }
        ).and_return(responder)
      )
      expect(responder).to receive(:respond_error)
      controller.respond_with_error(:forbidden, 'help me')
    end
  end
end
