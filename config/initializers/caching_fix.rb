module ActionController
  module Caching
    module Pages
      module ClassMethods
        def caches_formatted_page(format, *actions)
          return unless perform_caching
          actions.each do |action|
            class_eval %(
              after_filter do |c|
                if c.action_name == '#{action}' && c.request.format.#{format}?
                  c.cache_page
                end 
              end
            )
          end
        end
      end
    end
  end
end