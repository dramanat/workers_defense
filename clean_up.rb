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
      next unless only_allowed_chars?(first_name, line_num, row)

      last_name  = row[last_name_idx]
      next unless only_allowed_chars?(last_name , line_num, row)

      if need_to_format_name?(first_name)
        first_name = format_name(first_name.downcase)
      end

      if need_to_format_name?(last_name)
        last_name = format_name(last_name.downcase)
      end

      email = row[email_idx]
      if persons.has_key?(email)
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

  def only_allowed_chars?(name, line_num=0, row="")
    if !!(/^[a-zA-Z\-\ ]+$/ =~ name)
      true
    else
      puts "ROW #{line_num} invalid first or last name: #{row}"
      false
    end
  end

  def all_caps?(name)
    !!(/^[A-Z]+$/ =~ name)
  end

  def all_lower?(name)
    !!(/^[a-z]+$/ =~ name)
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

