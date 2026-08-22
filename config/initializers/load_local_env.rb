if Rails.env.development?
  path = Rails.root.join(".env")
  if path.exist?
    path.readlines(chomp: true).each do |line|
      next if line.blank? || line.start_with?("#")
      key, separator, value = line.partition("=")
      next if key.blank? || separator.blank?
      ENV[key] ||= value.delete_prefix('"').delete_suffix('"').delete_prefix("'").delete_suffix("'")
    end
  end
end
