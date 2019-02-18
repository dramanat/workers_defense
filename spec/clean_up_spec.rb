require './clean_up'

describe "#format_name" do

  context "capitalize first letter" do
    it "should capitalize first letter and leave rest in lower case" do
      name = CleanUp.new.format_name('dharini')
      expect(name).to eq 'Dharini'
    end
  end

end

describe "only_allowed_chars?" do
  let(:clean_up) { CleanUp.new }

  it "should return false when blank name" do
    result = clean_up.only_allowed_chars?("")
    expect(result).to eq false
  end

  it "should return false when numerics in name" do
    result = clean_up.only_allowed_chars?("a3b")
    expect(result).to eq false
  end

  it "should return true when space with alpha in name" do
    result = clean_up.only_allowed_chars?("a b")
    expect(result).to eq true
  end

  it "should return false when * in name" do
    result = clean_up.only_allowed_chars?("a*b")
    expect(result).to eq false
  end

  it "should return true when - in name" do
    result = clean_up.only_allowed_chars?("a-b")
    expect(result).to eq true
  end
  
  it "should return true when name is camel case" do
    result = clean_up.only_allowed_chars?("DeLeon")
    expect(result).to eq true
  end

  it "should return true when name is all lower case" do
    result = clean_up.only_allowed_chars?("deleon")
    expect(result).to eq true
  end

  it "should return true when name is all upper case" do
    result = clean_up.only_allowed_chars?("DELEON")
    expect(result).to eq true
  end
end

describe "all_caps?" do
  let(:clean_up) { CleanUp.new }

  it "should return true if all upper case" do
    result = clean_up.all_caps?("DELEON")
    expect(result).to eq true
  end

  it "should return false if all lower case" do
    result = clean_up.all_caps?("deleon")
    expect(result).to eq false
  end

  it "should return false if camel case" do
    result = clean_up.all_caps?("DeLeon")
    expect(result).to eq false
  end

  it "should return false if hyphen exists" do
    result = clean_up.all_caps?("DE-LEON")
    expect(result).to eq false
  end

  it "should return false if space exists" do
    result = clean_up.all_caps?("DE LEON")
    expect(result).to eq false
  end
end

describe "all_lower?" do
  let(:clean_up) { CleanUp.new }

  it "should return false if all upper case" do
    result = clean_up.all_lower?("DELEON")
    expect(result).to eq false
  end

  it "should return true if all lower case" do
    result = clean_up.all_lower?("deleon")
    expect(result).to eq true
  end

  it "should return false if camel case" do
    result = clean_up.all_lower?("DeLeon")
    expect(result).to eq false
  end

  it "should return false if hyphen exists" do
    result = clean_up.all_lower?("de-leon")
    expect(result).to eq false
  end

  it "should return false if space exists" do
    result = clean_up.all_lower?("de leon")
    expect(result).to eq false
  end
end

describe "capital_lower_capital_rest_lower?" do
  let(:clean_up) { CleanUp.new }

  it "should return false if all upper case" do
    result = clean_up.capital_lower_capital_rest_lower?("DELEON")
    expect(result).to eq false
  end

  it "should return false if all lower case" do
    result = clean_up.capital_lower_capital_rest_lower?("deleon")
    expect(result).to eq false
  end

  it "should return true if camel case" do
    result = clean_up.capital_lower_capital_rest_lower?("DeLeon")
    expect(result).to eq true
  end

  it "should return false if hyphen exists" do
    result = clean_up.capital_lower_capital_rest_lower?("De-Leon")
    expect(result).to eq false
  end

  it "should return false if space exists" do
    result = clean_up.capital_lower_capital_rest_lower?("De Leon")
    expect(result).to eq false
  end

end

describe "start_with_capital_rest_lower?" do
  let(:clean_up) { CleanUp.new }

  it "should return false if all upper case" do
    result = clean_up.start_with_capital_rest_lower?("LISA")
    expect(result).to eq false
  end

  it "should return false if all lower case" do
    result = clean_up.start_with_capital_rest_lower?("lisa")
    expect(result).to eq false
  end

  it "should return false if camel case" do
    result = clean_up.start_with_capital_rest_lower?("DeLeon")
    expect(result).to eq false
  end

  it "should return true if starts with upper and rest are lower" do
    result = clean_up.start_with_capital_rest_lower?("Lisa")
    expect(result).to eq true
  end

  it "should return false if hyphen exists" do
    result = clean_up.start_with_capital_rest_lower?("De-Leon")
    expect(result).to eq false
  end

  it "should return false if space exists" do
    result = clean_up.start_with_capital_rest_lower?("De Leon")
    expect(result).to eq false
  end

end


describe "valid_zip?" do
  let(:clean_up) { CleanUp.new }

  it "should return false if alpha in zip" do
    result = clean_up.valid_zip?("7a704")
    expect(result).to eq false
  end

  it "should return false if - in zip" do
    result = clean_up.valid_zip?("7-704")
    expect(result).to eq false
  end

  it "should return false if * in zip" do
    result = clean_up.valid_zip?("7*704")
    expect(result).to eq false
  end

  it "should return false if more than 5 digits in zip" do
    result = clean_up.valid_zip?("787044")
    expect(result).to eq false
  end

  it "should return false if less than 5 digits in zip" do
    result = clean_up.valid_zip?("7870")
    expect(result).to eq false
  end

  it "should return true if exactly 5 digits in zip" do
    result = clean_up.valid_zip?("78704")
    expect(result).to eq true
  end

end

describe "append_to_groups" do
  let(:clean_up) { CleanUp.new }

  it "should add to array" do
    result = clean_up.append_to_groups(%w(a), "b|c")
    expect(result).to eq %w(a b c)
  end

  it "should not add to array" do
    result = clean_up.append_to_groups(%w(a c), "a|c")
    expect(result).to eq %w(a c)
  end
end

