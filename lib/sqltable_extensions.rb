module SqltableExtensions
  require 'rufus/scheduler' 
  
  def sqltbl_exists?(tablename)
    ActiveRecord::Base.connection.tables.include?(tablename)
  end
  
  def next_autoincr(modelname)    
    # get table status results, which includes next auto increment number
    # result will be an array with a single row
    # use 'each_hash' iterator, to put the result row into hash format
    sql_hash_array = ActiveRecord::Base.connection.select_all("show table status like '#{modelname}' ")   
    #sql_result.each_hash {|sql_hash| sql_array << sql_hash}
    
    return sql_hash_array[0]['Auto_increment']
  end
  
  def set_autoincr(modelname, value_or_model, now_or_sched='now')
    # if to_value is numeric, set auto_increment to that value, otherwise assume a model name
    # is passed, and set auto_increment to the value in that model
    
    # this is used for example to make sure autoincrement numbers are unique across pilot_oligo_designs
    # and oligo_designs models
    if value_or_model.is_a?(Numeric)
      auto_incr = value_or_model.to_i
    elsif sqltbl_exists?(value_or_model)
      auto_incr = next_autoincr(value_or_model)
    end
    
    # Note: if auto_incr is lower than the maximum id in the table, MySQL will not perform the update,
    #       since it would result in duplicate primary keys
    # Therefore: formally retrieve the actual autoincrement number after the update, and return that
    if auto_incr && now_or_sched == 'sched'
      scheduler = Rufus::Scheduler.start_new
      scheduler.in '1s' do 
        ActiveRecord::Base.connection.execute("ALTER TABLE #{modelname} AUTO_INCREMENT = #{auto_incr} ") 
        end
      return 0
    elsif auto_incr
      ActiveRecord::Base.connection.execute("ALTER TABLE #{modelname} AUTO_INCREMENT = #{auto_incr} ") 
      return next_autoincr(modelname)
    else
      return -1
    end
  end
  
end