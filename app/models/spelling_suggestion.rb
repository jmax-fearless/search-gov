class SpellingSuggestion
  def initialize(query, did_you_mean_suggestion)
    @query = query
    @did_you_mean_suggestion = did_you_mean_suggestion
  end

  def cleaned
    cleaned_suggestion = normalize(@did_you_mean_suggestion)
    cleaned_query = normalize(@query)
    same_or_overridden?(cleaned_suggestion, cleaned_query) ? nil : cleaned_suggestion
  end

  private

  def same_or_overridden?(cleaned_suggestion, cleaned_query)
    cleaned_suggestion == cleaned_query || (cleaned_suggestion.present? && cleaned_suggestion.starts_with?('+'))
  end

  def normalize(str)
    stripped_str = str.gsub(/(\uE000|\uE001|[()])/, '')
    remaining_tokens = stripped_str.split.reject do |token|
      token.starts_with?('language:', 'site:', '-site:', 'scopeid:') || %w(OR AND NOT).include?(token)
    end
    remaining_tokens.join(' ').downcase
  end
end