# This can be removed whenever the Pull Request below is merged and released.
#     https://github.com/dazuma/activerecord-postgis-adapter/pull/60

module ActiveRecord  # :nodoc:
  module ConnectionAdapters  # :nodoc
    module PostGISAdapter  # :nodoc:
      class MainAdapter < PostgreSQLAdapter  # :nodoc:
        def add_index(table_name_, column_name_, options_=nil)
          # FULL REPLACEMENT. RE-CHECK ON NEW VERSIONS.
          # We have to fully-replace because of the gist_clause.
          options_ ||= {}
          gist_clause_ = options_.delete(:spatial) ? ' USING GIST' : ''
          index_name_, index_type_, index_columns_, index_options_ = add_index_options(table_name_, column_name_, options_)
          execute "CREATE #{index_type_} INDEX #{quote_column_name(index_name_)} ON #{quote_table_name(table_name_)}#{gist_clause_} (#{index_columns_})#{index_options_}"
        end
      end
    end
  end
end
