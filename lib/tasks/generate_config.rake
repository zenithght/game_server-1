desc "Generate configs Sql format file from Excel"
task :generate_config => :environment do
  s = Roo::Excel.new(File.expand_path("./config/game_data/item_config.xls"))
  sql = ""

  File.open("#{Rails.root.to_s}/include/config_names.hrl", 'w') do |io|
    io.puts "%%% Generated by generate_config.rake #{Time.now}\n"
    io.puts "-define(CONFIG_MODELS, ["
    io.puts "        #{s.sheets.join(",\n")}"
    io.puts "        ])."
  end

  s.sheets.each do |sheet|
    File.open("#{Rails.root.to_s}/app/models/#{sheet.singularize}.rb", 'w') do |io|
      model_name = sheet.singularize.camelize
      io.write "# Generated by generate_config.rake #{Time.now}\n"
      io.write "class #{model_name} < ActiveRecord::Base;end"
    end
    fields_define = []
    field_types = []
    field_names = []
    s.first.each do |field|
      name, type = field.split(":")
      field_names << name
      field_types << type
      case type
      when 'string'
        fields_define << "`#{name}` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL"
      when 'text'
        fields_define << "`#{name}` text COLLATE utf8_unicode_ci"
      when 'integer'
        fields_define << "`#{name}` int(11) DEFAULT NULL"
      when 'float'
        fields_define << "`#{name}` float DEFAULT NULL"
      else
        raise "TYPE ERROR: #{type} didn't defined."
      end
    end
    sql << %Q{
      DROP TABLE IF EXISTS `#{sheet}`;
      CREATE TABLE `#{sheet}` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        #{fields_define.join(",\n")},
        PRIMARY KEY (`id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    }
    values = 2.upto(s.last_row).map do |row|
      row_values = []
      s.row(row).each_with_index do |value, index|
        value = ActiveRecord::Base.sanitize(value) if field_types[index] == 'string'
        value = 0 if field_types[index] == 'integer' and value.blank?
        value = 0.0 if field_types[index] == 'float' and value.blank?
        row_values << value
      end
      "(#{row_values.join(',')})"
    end.join(',')

    field_names = field_names.map do |field_name|
      "`#{field_name}`"
    end.join(',')

    sql << "INSERT INTO `#{sheet}` (#{field_names}) VALUES #{values}"
    file_path = "#{Rails.root.to_s}/db/config_data.sql"
    File.open(file_path, "w") do |io|
      io.write sql
    end
    database_name = Rails.configuration.database_configuration[Rails.env]["database"]

    # Make sure mysql path is: '/usr/bin/mysql'
    `mysql -u root #{database_name} < #{file_path}`
  end
end
