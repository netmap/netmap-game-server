module MetricsServerHelper
  def metrics_server_setup_tag
    url = MetricsServer.url
    if url.index 'localhost'
      url = url.sub 'localhost', request.host
    end
    url = File.join url, 'readings'

    if current_user
      uid = MetricsServer.user_token current_user.exuid
    else
      uid = MetricsServer.user_token '0'
    end

    content_tag 'script', type: 'text/javascript' do
      %Q|NetMap.Pil.setReadingsUploadBackend("#{url}", "#{uid}");|.html_safe
    end
  end
end
