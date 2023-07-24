# frozen_string_literal: true

module FollettDestiny
  class API # :nodoc:
    # Gets entire listing
    #
    # Examples:
    #
    #   [1] pry(main)> api.get_all('/materials/resources/items').length
    #   => 667
    #
    #   [2] pry(main)> api.get_all('/materials/resources/items') do |row, index, total, rows|
    #                    puts "#{index+1} #{total}"
    #                    row
    #                  end.length
    #   1 667
    #   2 667
    #   …
    #   667 667
    #   => 667

    def get_all(endpoint, params = {}) # rubocop:disable Metrics/MethodLength
      count = get_count(endpoint, params)
      index = -1
      return_rows = []
      next_link = endpoint

      loop do
        result = get(next_link, params).parse
        rows = result['value']

        rows.each do |row|
          return_rows.push block_given? ? yield(row, index += 1, count, rows) : row
        end

        next_link = get_next_link(result, endpoint)
        break unless next_link
      end

      return_rows
    end

    def get_count(endpoint, params = {})
      response = get(endpoint, params.merge('$count': true))

      unless response.content_type.mime_type == 'text/plain'
        raise StandardError, "#{endpoint} is not compatible with get_all"
      end

      response.body.to_s.to_i
    end

    private

    def get_next_link(result, endpoint)
      next_link = result['@nextLink']
      return unless next_link

      # NOTE: The API does not include `/materials` in the next link but it actually requires it
      if endpoint.start_with?('/materials/') && !next_link.start_with?('/materials/')
        next_link = "/materials#{next_link}"
      end

      # NOTE: The API does not include a value for orderby sometimes.
      #       /materials/resourcetypes/<id>/resources
      next_link.sub!(%r{\$orderby=($|&)}, '$orderby=id')

      next_link
    end
  end
end
