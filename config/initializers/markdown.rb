class ActionView::Template
  markdown_handler = lambda do |template|
    Markdpwn.markdpwn(template.source).inspect
  end
  register_template_handler :md, markdown_handler
end
