module MCollective
  module RPC
    # A RPC::Audit plugin that sends all audit messages to a non SimpleRPC agent called
    # centralrpclog where it can then process them however it feels like
    #
    # https://github.com/puppetlabs/mcollective-plugins
    class Centralrpclog<Audit
      def audit_request(request, connection)
        begin
          config = Config.instance
          log_collective = Config.instance.pluginconf["centralrpclog.collective"] || config.main_collective
          filter = {"agent" => "centralrpclog"}
          req = Message.new(request, nil, {:agent => "centralrpclog", :type => :request, :collective => log_collective, :filter => filter})
          req.encode!
          # First try the new sub collectives method of obtaining the required collective, if that fails
          # because make_target doesnt take a collective fall back to old behavior
          ##begin
          ##  log_collective = Config.instance.pluginconf["centralrpclog.collective"] || config.main_collective
          ##  target = Util.make_target("centralrpclog", :command, log_collective)
          ##rescue
          ##  target = Util.make_target("centralrpclog", :command)
          ##end

          ##reqid = Digest::MD5.hexdigest("#{config.identity}-#{Time.now.to_f.to_s}-#{target}")
          ##filter = {"agent" => "centralrpclog"}

          ##req = PluginManager["security_plugin"].encoderequest(config.identity, target, request, reqid, filter)

          ##if connection.respond_to?(:publish)
          ##  connection.publish(target, req)
          ##else
          ##  connection.send(target, req)
          ##end
          req.publish
          Log.debug("Sending request #{req.requestid} to the #{req.agent} agent in collective #{req.collective}")
        rescue Exception => e
          Log.instance.error("Failed to send audit request: #{e}")
        end
      end
    end
  end
end
