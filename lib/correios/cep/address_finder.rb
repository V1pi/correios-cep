# frozen_string_literal: true
module Correios
  module CEP
    class AddressFinder
      @@errors = {}
      def initialize(args = {})
        @web_service = args.fetch(:web_service, Correios::CEP::WebService.new)
        @parser = args.fetch(:parser, Correios::CEP::Parser.new)
      end

      def get(zipcode)
        zipcode = zipcode.to_s.strip
        validate(zipcode)

        response = web_service.request(zipcode)

        @@errors = parser.errors(response)

        parser.address(response)
      end

      def self.get(zipcode, args = {})
        self.new(args).get(zipcode)
      end

      def get_with_errors(zipcode)
        zipcode = zipcode.to_s.strip
        validate(zipcode)

        response = web_service.request(zipcode)

        @@errors = parser.errors(response)

        address = parser.address(response)
        address[:errors] = @@errors
        address
      end

      def self.get_with_errors(zipcode, args = {})
        self.new(args).get_with_errors(zipcode)
      end

      def get_errors
        @@errors
      end

      def self.get_errors (args = {})
        self.new(args).get_errors
      end

      private

      attr_reader :web_service, :parser

      def validate(zipcode)
        raise ArgumentError.new('zipcode is required') if zipcode.empty?
        raise ArgumentError.new('zipcode in invalid format (valid format: 00000-000)') unless zipcode.match(/\A\d{5}-?\d{3}\z/)
      end
    end
  end
end
