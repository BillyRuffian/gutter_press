module MfaHelper
  def safe_qr_code_svg(uri)
    return content_tag(:div, 'Error generating QR code', class: 'alert alert-danger') unless uri.present?

    begin
      qr = RQRCode::QRCode.new(uri)
      svg_content = qr.as_svg(
        offset: 0,
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 6,
        standalone: true
      )

      # Validate that the SVG content is safe before marking as html_safe
      if svg_content.is_a?(String) && svg_content.start_with?('<?xml') && svg_content.include?('<svg')
        svg_content.html_safe
      else
        content_tag(:div, 'Invalid QR code format', class: 'alert alert-danger')
      end
    rescue StandardError => e
      Rails.logger.error "QR Code generation failed: #{e.message}"
      content_tag(:div, 'QR code generation failed', class: 'alert alert-danger')
    end
  end
end
