module Support
  def numeric?(string)
    true if Float(string) rescue false
  end
end