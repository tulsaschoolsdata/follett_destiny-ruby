# frozen_string_literal: true

module FollettDestiny
  class API # :nodoc:
    def resource_item(id: nil, barcode: nil)
      raise ArgumentError, 'id or barcode is required' unless id || barcode
      raise ArgumentError, 'id or barcode not both' if id && barcode

      return resource_items('itemBarcode' => barcode, '$top' => 1).first if barcode
      return get("/materials/resources/items/#{id}").parse if id
    end

    def resource_types(params = {})
      get('/materials/resourcetypes', params).parse
    end

    def resource_items(params = {})
      get('/materials/resources/items', params).parse['value']
    end

    def resource_type(resource_type, *args)
      get("/materials/resourcetypes/#{resource_type}", *args).parse
    end

    def resource_type_items(resource_type, *args, &block)
      get_all("/materials/resourcetypes/#{resource_type}/items", *args, &block)
    end

    def resource_types_list
      list = lambda do |item, parent = nil|
        guid, name, children = item.values_at('guid', 'name', 'children')

        path = URI.encode_www_form_component(name)
        path = "#{parent}/#{path}" if parent

        item = { guid: guid, name: name, path: path }
        [item, (children || []).map { |child| list.call(child, path) }]
      end

      list.call(resource_types).flatten
    end
  end
end
