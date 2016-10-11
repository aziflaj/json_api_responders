module JsonApiResponders
  class Responder
    module Actions
      ACTIONS = %w(index show create update destroy).freeze

      def respond_to_index_action
        self.status ||= :ok
        render_resource
      end

      def respond_to_show_action
        self.status ||= :ok
        render_resource
      end

      def respond_to_create_action
        if resource.valid?
          self.status ||= :created
          render_resource
        else
          self.status ||= :unprocessable_entity
          render_error
        end
      end

      def respond_to_update_action
        if resource.valid?
          self.status ||= :ok
          render_resource
        else
          self.status ||= :unprocessable_entity
          render_error
        end
      end

      def respond_to_destroy_action
        self.status ||= :no_content
        controller.head(status, render_options)
      end

      def render_resource
        controller.render(resource_render_options)
      end

      def resource_render_options
        render_options.merge(json: resource, **options)
      end
    end
  end
end
