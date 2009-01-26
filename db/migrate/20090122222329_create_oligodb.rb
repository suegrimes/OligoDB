class CreateOligodb < ActiveRecord::Migration
  def self.up
# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

  create_table "aliquots", :force => true do |t|
    t.integer  "oligo_well_id",                                                 :default => 0
    t.integer  "pool_well_id",                                                  :default => 0
    t.string   "plate_from",       :limit => 25
    t.string   "well_from",        :limit => 4
    t.string   "to_plate_or_pool", :limit => 1
    t.string   "plate_to",         :limit => 25
    t.string   "well_to",          :limit => 4
    t.decimal  "volume_pipetted",                :precision => 11, :scale => 3
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "aliquots", ["oligo_well_id"], :name => "al_oligo_plate_fk"
  add_index "aliquots", ["pool_well_id"], :name => "al_pool_plate_fk"

  create_table "oligo_designs", :force => true do |t|
    t.string   "oligo_name",              :limit => 50, :default => "", :null => false
    t.string   "valid_oligo",             :limit => 1,  :default => "", :null => false
    t.string   "gene_code",               :limit => 8
    t.string   "enzyme_code",             :limit => 20
    t.integer  "selector_nr",             :limit => 3
    t.integer  "region_id",                             :default => 0,  :null => false
    t.integer  "roi_nr",                  :limit => 2
    t.integer  "enzyme_id",                             :default => 0
    t.integer  "vector_id",                             :default => 0,  :null => false
    t.integer  "sel_n_sites_start",       :limit => 1
    t.integer  "sel_left_start_rel_pos",  :limit => 2
    t.integer  "sel_left_end_rel_pos",    :limit => 2
    t.integer  "sel_left_site_used",      :limit => 1
    t.integer  "sel_right_start_rel_pos", :limit => 2
    t.integer  "sel_right_end_rel_pos",   :limit => 2
    t.integer  "sel_right_site_used",     :limit => 1
    t.string   "sel_polarity",            :limit => 1
    t.string   "sel_5prime",              :limit => 30
    t.string   "sel_3prime",              :limit => 30
    t.string   "usel_5prime",             :limit => 30
    t.string   "usel_3prime",             :limit => 30
    t.string   "selector_useq"
    t.integer  "amplicon_chr_start_pos"
    t.integer  "amplicon_chr_end_pos"
    t.integer  "amplicon_length"
    t.text     "amplicon_seq"
    t.float    "genome_build",            :limit => 9
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oligo_orders", :force => true do |t|
    t.string   "order_hdr",       :limit => 25
    t.string   "researcher",      :limit => 20
    t.date     "order_submit_dt"
    t.string   "order_hdr_recv",  :limit => 25
    t.date     "order_recv_dt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oligo_plates", :force => true do |t|
    t.integer  "oligo_order_id"
    t.string   "oligo_plate_nr",  :limit => 50
    t.string   "synth_plate_nr",  :limit => 25
    t.string   "plate_copy_code", :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oligo_plates", ["oligo_order_id"], :name => "op_oligo_order_fk"

  create_table "oligo_wells", :force => true do |t|
    t.string   "oligo_plate_nr",        :limit => 50,                                :default => "", :null => false
    t.string   "oligo_well_nr",         :limit => 4,                                 :default => "", :null => false
    t.integer  "oligo_plate_id",                                                     :default => 0,  :null => false
    t.integer  "oligo_design_id",                                                                    :null => false
    t.string   "oligo_name",            :limit => 50
    t.string   "enzyme_code",           :limit => 20
    t.decimal  "well_initial_volume",                 :precision => 11, :scale => 3
    t.decimal  "well_rem_volume",                     :precision => 11, :scale => 3
    t.string   "well_suspend_lysophil", :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oligo_wells", ["oligo_plate_id"], :name => "ow_oligo_plate_fk"
  add_index "oligo_wells", ["oligo_design_id"], :name => "ow_oligo_design_fk"

  create_table "pool_plates", :force => true do |t|
    t.string   "pool_plate_nr",   :limit => 50
    t.string   "pool_plate_desc", :limit => 150
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pool_wells", :force => true do |t|
    t.integer  "pool_plate_id",               :default => 0,  :null => false
    t.string   "pool_well_nr",  :limit => 4,  :default => "", :null => false
    t.string   "pool_code",     :limit => 8,  :default => "", :null => false
    t.string   "enzyme_code",   :limit => 20
    t.string   "pool_status",   :limit => 1
    t.float    "pool_volume",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pool_wells", ["pool_plate_id"], :name => "pw_pool_plate_fk"

  create_table "regions", :force => true do |t|
    t.string   "gene_code",            :limit => 8, :default => "", :null => false
    t.integer  "roi_nr",               :limit => 2,                 :null => false
    t.integer  "roi_flank_size",       :limit => 1
    t.integer  "roi_start_rel_pos",    :limit => 2
    t.integer  "roi_end_rel_pos",      :limit => 2
    t.integer  "target_flank_size",    :limit => 2
    t.integer  "target_start_chr_pos"
    t.integer  "roi_start_chr_pos"
    t.integer  "roi_end_chr_pos"
    t.integer  "roi_strand",           :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "researchers", :force => true do |t|
    t.string "researcher_name", :limit => 50
    t.string "company",         :limit => 50
    t.string "phone_number",    :limit => 20
  end

  create_table "syntheses", :force => true do |t|
    t.string    "researcher",    :limit => 50
    t.string    "gene_code",     :limit => 8
    t.integer   "order_line_nr", :limit => 2
    t.string    "oligo_name",    :limit => 50
    t.string    "selector_useq"
    t.timestamp "created_at"
  end

  create_table "uploads", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "filename"
    t.string   "original_filename"
    t.string   "content_type"
    t.integer  "size"
    t.string   "upload_file"
    t.string   "sender"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end
  end

  end

  def self.down
    raise.IrreversibleMigration
  end
end
