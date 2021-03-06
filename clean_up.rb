require 'csv'
require 'pry'

class Person

  attr_reader :first_name, :last_name, :zip
  attr_accessor :groups

  def initialize(first_name, last_name, groups, zip)
    @first_name = first_name 
    @last_name  = last_name
    @groups     = groups
    @zip        = zip
  end

end

class CleanUp

  def initialize
    @num_invalid_zip        = 0
    @num_invalid_first_name = 0
    @num_invalid_last_name  = 0
    @diff_data              = Hash.new
  end

  def do_it
    first_name_idx = 0
    last_name_idx  = 1
    email_idx      = 2
    groups_idx     = 3
    zip_idx        = 4
    persons        = Hash.new

    CSV.foreach('Halloween_Upload.csv').with_index(1) do |row, line_num|

      #puts "processing #{line_num}"
      zip = row[zip_idx]
      next unless valid_zip?(zip, line_num, row)
      
      first_name = row[first_name_idx]
      next unless only_allowed_chars?(first_name, line_num, row, true, false)

      last_name  = row[last_name_idx]
      next unless only_allowed_chars?(last_name , line_num, row, false, true)

      if need_to_format_name?(first_name)
        first_name = format_name(first_name.downcase)
      end

      if need_to_format_name?(last_name)
        last_name = format_name(last_name.downcase)
      end

      email = row[email_idx]
      if persons.has_key?(email)
        if (persons[email].first_name != row[first_name_idx] ||
            persons[email].last_name  != row[last_name_idx] ||
            persons[email].zip        != row[zip_idx])
          @diff_data[email] = "has diff data"
        end

        persons[email].groups = append_to_groups(persons[email].groups, 
                                                 row[groups_idx])
      else
        #create new person obj & add to persons hash
        if row[groups_idx].nil?
          groups       = []
        else
          groups       = row[groups_idx].split('|').uniq
        end
        a_person       = Person.new(first_name, last_name, groups, zip)
        persons[email] = a_person
      end
      
    end

    puts "Number of invalid zips       = #{@num_invalid_zip}"
    puts "Number of invalid first name = #{@num_invalid_first_name}"
    puts "Number of invalid last name  = #{@num_invalid_last_name}"
    puts "Number with diff data        = #{@diff_data.length} ; #{@diff_data.keys}"

    create_new_csv(persons)
  end

  def create_new_csv(persons)
    new_csv = File.open("new_csv.csv", "w+")
    persons.each do |key, value| 
      new_str = ""
      new_str << value.first_name
      new_str << ','
      new_str << value.last_name
      new_str << ','
      new_str << key
      new_str << ','
      new_str << value.groups.join('|')
      new_str << ','
      new_str << value.zip
      new_str << ','
      new_str << "\n"
      new_csv.write(new_str)
    end 
  end

  def format_name(name)
    name[0] = name[0].capitalize
    name
  end

  def need_to_format_name?(name)
    return false if start_with_capital_rest_lower?(name)
    return false if capital_lower_capital_rest_lower?(name)
    return true if all_caps?(name) || all_lower?(name)
  end

  def only_allowed_chars?(name, line_num=0, row="", first, last)
    if !!(/^[\p{Alpha}\-\ ]+$/ =~ name)
      true
    else
      if first
        puts "ROW #{line_num} invalid first name: #{row}"
        @num_invalid_first_name += 1 if first
      elsif last
        puts "ROW #{line_num} invalid last name: #{row}"
        @num_invalid_last_name  += 1 if last
      end
      false
    end
  end

  def all_caps?(name)
    !!(/^[\p{Upper}]+$/ =~ name)
  end

  def all_lower?(name)
    !!(/^[\p{Lower}]+$/ =~ name)
  end

  def start_with_capital_rest_lower?(name)
    !!(/^[A-Z][a-z]+$/ =~ name)
  end
  
  def capital_lower_capital_rest_lower?(name)
    !!(/^[A-Z][a-z][A-Z][a-z]+$/ =~ name)
  end

  def valid_zip?(zip, line_num=0, row="")
    if !!(/^[0-9]{5}$/ =~ zip)
      true
    else
      @num_invalid_zip += 1
      puts "ROW #{line_num} invalid zip: #{row}"
      false
    end
  end

  def append_to_groups(existing_groups, new_groups)
    if new_groups.nil?
      existing_groups
    else
      existing_groups =  existing_groups + new_groups.split('|')
      existing_groups =  existing_groups.uniq
    end
  end

end

