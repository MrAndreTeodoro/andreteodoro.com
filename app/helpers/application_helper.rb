module ApplicationHelper
  # Sanitize URL to prevent XSS attacks
  # Only allows http and https protocols
  def sanitize_url(url)
    return nil if url.blank?

    begin
      uri = URI.parse(url)
      # Only allow http and https schemes
      if uri.scheme.in?(%w[http https])
        url
      else
        nil
      end
    rescue URI::InvalidURIError
      nil
    end
  end
end
