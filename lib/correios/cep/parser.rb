# frozen_string_literal: true
require 'ox'

module Correios
  module CEP
    class Parser
      ADDRESS_MAP = {
        'end'          => :address,
        'bairro'       => :neighborhood,
        'cidade'       => :city,
        'uf'           => :state,
        'cep'          => :zipcode,
        'complemento'  => :complement,
        'complemento2' => :complement2,
      }.freeze

      ERROR_MAP = {
        'faultstring'  => :error_name
      }.freeze

      def address(xml)
        doc = Ox.parse(xml)

        return_node = find_node(doc.nodes, 'return')
        return {} if return_node.nil?

        address = {}
        return_node.nodes.each do |element|
          address[ADDRESS_MAP[element.name]] = text_for(element) if ADDRESS_MAP[element.name]
        end

        join_complements(address)
        address
      end

      def errors(xml)
        doc = Ox.parse(xml)
        errors_node = find_node(doc.nodes, 'soap:Fault')

        return {} if errors_node.nil?

        errors = {}

        errors_node.nodes.each do |element|
          errors[ERROR_MAP[element.name]] = text_for(element) if ERROR_MAP[element.name]
        end

        errors
      end

      private

      def find_node(nodes, name)
        node = nodes.last
        return nil unless node.is_a?(Ox::Element)
        return node if node.nil? || node.name == name

        find_node(node.nodes, name)
      end

      def text_for(element)
        element.text.to_s.force_encoding(Encoding::UTF_8)
      end

      def join_complements(address)
        address[:complement] += " #{address.delete(:complement2)}"
        address[:complement].strip!
      end
    end
  end
end
