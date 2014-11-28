module CartoDB
  module Stats
    class Platform

      # Total users created
      def users
        return User.count
      end

      # Total datasets
      def datasets
        return Table.count
      end

      # Total seats among orgs
      # Returns a hash with reserved seats and used seats
      def seats_among_orgs
        seats_used = User.where('organization_id IS NOT NULL').count
        seats_reserved = Organization.sum(:seats)
        return {'used' => seats_used, 'reserved' => seats_reserved}
      end

      # Shared objects among orgs
      # Returns a hash with shared visualizations and shared datasets
      def shared_objects_among_orgs
        shared_objects = {}
        visualization_types_sql = "SELECT COUNT(*), visualizations.type FROM shared_entities, visualizations WHERE entity_id=visualizations.id::uuid GROUP BY type"
        db = ::Rails::Sequel.configuration.environment_for(Rails.env)
        conn = Sequel.connect(db)
        conn.fetch(visualization_types_sql).all.each do |vt|
          if vt[:type] == 'table'
            shared_objects['datasets'] = vt[:count]
          elsif vt[:type] == 'derived'
            shared_objects['visualizations'] = vt[:count]
          end
        end
        conn.disconnect
        return shared_objects
      end

    end
  end
end
