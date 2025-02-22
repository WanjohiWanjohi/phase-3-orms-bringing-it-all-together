class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @name = name 
    @breed = breed
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER  PRIMARY KEY, 
      name TEXT, 
      breed TEXT);
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    return dog
  end

  def self.new_from_db(row)
    dog = Dog.new( name:row[1], breed:row[2]) 
    dog.id=(row[0])
    dog
  end

  def self.all
    sql = <<-SQL
    SELECT * from dogs
    SQL
    DB[:conn].execute(sql).map do |dog |
      self.new_from_db(dog)
      end
  end
  
  def self.find_by_name(name)
    
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? Limit 1;
    SQL
    DB[:conn].execute(sql, name) do|dog|
      return self.new_from_db(dog)
    end
  end


  
  def self.find(id)
    sql = <<-SQL
    SELECT * from dogs WHERE id = ? 
    SQL
    DB[:conn].execute(sql, id) do |dog |
      return self.new_from_db(dog)
    end
  end
  
  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?,?) 
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

  end
  
end
