module App
  class FailureApp
      def call(env)
        env['x-rack.flash'][:notice] = env['warden'].message unless env['x-rack.flash'].nil?
        [302, {'Location' => env['warden.options'][:attempted_path], 'Content-type' => 'text/html'},'']
      end
    end
end