module TPhases::Modes
  module Helpers
    module RailsHelper
      extend ActiveSupport::Concern
      module ClassMethods
        def add_rails_methods!
          add_render_alias_method_chain!

          require 'tphases/rails/no_transactions_in_controller'
          ActionController::Base.send :include, TPhases::Rails::NoTransactionsInController
        end

        private
        def add_render_alias_method_chain!
          unless Gem.loaded_specs.values.map { |value| value.full_gem_path }.any? { |n| n.include? "actionpack-3." }
            raise "TPhases currently expects Rails version 3.*.* for patching ActionView template."
          end

          ActionView::Template.class_eval do

            def render_with_tphases_no_transactions(view, locals, &block)
              controller_class = view.controller.class
              if controller_class.class_variable_defined?(:@@no_transaction_actions) &&
                  controller_class.class_variable_get(:@@no_transaction_actions).include?(view.action_name.to_sym)
                TPhases.no_transactions_phase do
                  render_without_tphases_no_transactions(view, locals, &block)
                end
              else
                render_without_tphases_no_transactions(view, locals, &block)
              end
            end

            alias_method_chain :render, :tphases_no_transactions
          end

        end

      end
    end
  end
end