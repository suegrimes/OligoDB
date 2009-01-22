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

ActiveRecord::Schema.define(:version => 20090121183010) do

  create_table "BioMekPools", :id => false, :force => true do |t|
    t.string  "oligo_name",        :limit => 50, :default => "", :null => false
    t.integer "source_plate_id",                 :default => 0,  :null => false
    t.string  "source_plate_nr",   :limit => 50
    t.string  "source_well_nr",    :limit => 4,  :default => "", :null => false
    t.string  "source_plate_code", :limit => 2
    t.string  "to_plate_or_pool",  :limit => 1,  :default => "", :null => false
    t.string  "pool_code",         :limit => 1
    t.integer "dest_plate_id",                   :default => 0,  :null => false
    t.string  "dest_plate_nr",     :limit => 10, :default => "", :null => false
    t.string  "dest_well_nr",      :limit => 2
    t.integer "volume",                          :default => 0,  :null => false
  end

  create_table "Gene", :force => true do |t|
    t.string  "gn_gene_code",        :limit => 8,  :default => "", :null => false
    t.integer "gn_chromosome_nr",    :limit => 2
    t.text    "gn_gene_description"
    t.string  "gn_genome_build",     :limit => 20
  end

  create_table "Gene_Exon", :force => true do |t|
    t.string  "ge_gene_code",          :limit => 8,  :default => "", :null => false
    t.integer "ge_exon_nr",            :limit => 2,                  :null => false
    t.integer "ge_gene_id",                          :default => 0,  :null => false
    t.integer "ge_exon_chr_start_pos"
    t.integer "ge_exon_chr_end_pos"
    t.string  "ge_ccds_code",          :limit => 50
  end

  add_index "Gene_Exon", ["ge_gene_id"], :name => "Gene has Exon"

  create_table "Gene_Regulatory", :force => true do |t|
    t.string  "gr_gene_code",       :limit => 8,  :default => "", :null => false
    t.integer "gr_gene_id",                       :default => 0,  :null => false
    t.string  "gr_regulatory_info", :limit => 50
  end

  add_index "Gene_Regulatory", ["gr_gene_id"], :name => "Gene has Regulatory Region"

  create_table "Gene_SNP", :force => true do |t|
    t.string  "gs_gene_code",      :limit => 8, :default => "", :null => false
    t.integer "gs_snp_nr",                                      :null => false
    t.integer "gs_gene_id",                     :default => 0,  :null => false
    t.integer "gs_upstream_pos"
    t.integer "gs_downstream_pos"
    t.string  "gs_alleles"
  end

  add_index "Gene_SNP", ["gs_gene_id"], :name => "Gene has SNP"

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

  create_table "enzymes", :force => true do |t|
    t.string   "ez_enzyme",          :limit => 20, :default => "", :null => false
    t.string   "ez_enzyme_descr"
    t.string   "ez_recognition_seq", :limit => 30
    t.integer  "ez_cut_pos1",        :limit => 2
    t.integer  "ez_cut_pos2",        :limit => 2
    t.integer  "ez_cut_pos3",        :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "oligo_designs_projects", :id => false, :force => true do |t|
    t.integer "oligo_design_id", :null => false
    t.integer "project_id",      :null => false
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

  add_index "oligo_plates", ["oligo_order_id"], :name => "FKIndex1"

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

  add_index "oligo_wells", ["oligo_plate_id"], :name => "oligo_plate_fk"
  add_index "oligo_wells", ["oligo_design_id"], :name => "oligo_design_fk"

  create_table "order_plate_0003_080124_GN", :id => false, :force => true do |t|
    t.string "Well_Number", :limit => 4
    t.string "Oligo_Name",  :limit => 40
    t.string "Sequence"
  end

  create_table "order_plate_0004_080124_GN", :id => false, :force => true do |t|
    t.string "Well_Number", :limit => 4
    t.string "Oligo_Name",  :limit => 40
    t.string "Sequence"
  end

  create_table "order_plate_0005_080124_GN", :id => false, :force => true do |t|
    t.string "Well_number", :limit => 4
    t.string "Oligo_Name",  :limit => 40
    t.string "Sequence"
  end

  create_table "order_plate_0006_080124_GN", :id => false, :force => true do |t|
    t.string "Well_Number", :limit => 4
    t.string "Oligo_Name",  :limit => 40
    t.string "Sequence"
  end

  create_table "order_plate_0007_080604_GN", :id => false, :force => true do |t|
    t.string "Well_Number", :limit => 4
    t.string "Oligo_Name",  :limit => 40
    t.string "Sequence"
  end

  create_table "pool_plates", :force => true do |t|
    t.string   "pool_plate_nr",   :limit => 50
    t.text     "pool_plate_desc", :limit => 16777215
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

  add_index "pool_wells", ["pool_plate_id"], :name => "FKIndex1"

  create_table "projects", :force => true do |t|
    t.string "project_name",        :limit => 50, :default => "", :null => false
    t.string "project_description"
  end

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

  create_table "selectors_file", :id => false, :force => true do |t|
    t.integer "sel_id_per_session",   :limit => 3
    t.integer "roi_num_per_session",  :limit => 3
    t.integer "chr_num",              :limit => 1
    t.integer "chr_target_start"
    t.integer "L_sel_start",          :limit => 2
    t.integer "L_sel_end",            :limit => 2
    t.integer "R_sel_start",          :limit => 2
    t.integer "R_sel_end",            :limit => 2
    t.integer "amplicon_length",      :limit => 3
    t.integer "n_sites_start",        :limit => 1
    t.integer "left_site",            :limit => 1
    t.integer "right_site",           :limit => 1
    t.string  "polarity",             :limit => 8
    t.string  "enz",                  :limit => 20
    t.string  "selector"
    t.string  "5prime_end_20b_sel",   :limit => 50
    t.string  "3prime_20b__sel",      :limit => 50
    t.text    "amplicon_seq"
    t.string  "roi_ids_of_selectors", :limit => 20
    t.string  "U_selector"
  end

  create_table "selectors_lymphoma", :id => false, :force => true do |t|
    t.integer "sel_id_per_session",   :limit => 3
    t.string  "project",              :limit => 50
    t.integer "chr_num",              :limit => 1
    t.integer "chr_target_start"
    t.integer "L_sel_start",          :limit => 2
    t.integer "L_sel_end",            :limit => 2
    t.integer "R_sel_start",          :limit => 2
    t.integer "R_sel_end",            :limit => 2
    t.integer "amplicon_length",      :limit => 3
    t.integer "n_sites_start",        :limit => 1
    t.integer "left_site",            :limit => 1
    t.integer "right_site",           :limit => 1
    t.string  "polarity",             :limit => 8
    t.string  "enz",                  :limit => 20
    t.string  "selector"
    t.string  "5prime_end_20b_sel",   :limit => 50
    t.string  "3prime_20b__sel",      :limit => 50
    t.text    "amplicon_seq"
    t.string  "roi_ids_of_selectors", :limit => 20
    t.string  "U_selector"
  end

  create_table "synth_orders1", :id => false, :force => true do |t|
    t.string "plate_ID"
    t.string "plate"
    t.string "Well"
    t.string "Sequence"
    t.string "Total_vol"
    t.string "Pipet_out_of_S"
    t.string "Pipet_to_A"
    t.string "Pipet_to_B"
    t.string "Left_in_S"
    t.string "Pipetted_Out_of_A"
    t.string "To_pool_nr"
    t.string "Left_in_A"
    t.string "Resuspend_A"
    t.string "Left_in_PlateA"
  end

  create_table "syntheses", :force => true do |t|
    t.string    "researcher",    :limit => 50
    t.string    "gene_code",     :limit => 8
    t.integer   "order_line_nr", :limit => 2
    t.string    "oligo_name",    :limit => 50
    t.string    "selector_useq"
    t.timestamp "created_at"
  end

  create_table "synthesized_orders", :id => false, :force => true do |t|
    t.string "Order_id_sub",      :limit => 25
    t.string "plate_id_synth",    :limit => 25
    t.string "plate_id",          :limit => 25
    t.string "well_id",           :limit => 4
    t.string "gene_enz_roi_id",   :limit => 40
    t.float  "Total_vol"
    t.float  "Pipet_from_S"
    t.float  "Pipet_to_A"
    t.float  "Pipet_to_B"
    t.float  "Left_in_S"
    t.float  "Pipetted_Out_of_A"
    t.string "To_pool_num",       :limit => 4
    t.string "Left in A"
  end

  create_table "target_file", :id => false, :force => true do |t|
    t.string  "roi_id",                :limit => 20
    t.string  "gene_name",             :limit => 50
    t.integer "roi_num",               :limit => 2
    t.string  "cds_ids",               :limit => 20
    t.string  "ccds_ids",              :limit => 20
    t.string  "g_accession",           :limit => 20
    t.integer "chr_num",               :limit => 2
    t.integer "chr_roi_start"
    t.integer "chr_roi_stop"
    t.integer "roi_strand",            :limit => 1
    t.integer "chr_target_start"
    t.integer "target_roi_start",      :limit => 2
    t.integer "target_roi_stop",       :limit => 2
    t.text    "target_seq_clean"
    t.text    "target_seq_degenerate"
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

  create_table "vectors", :force => true do |t|
    t.string   "vc_vector",             :limit => 20,  :default => "", :null => false
    t.string   "vc_vector_description"
    t.integer  "vc_vector_length",      :limit => 2
    t.string   "vc_vector_seq",         :limit => 100
    t.string   "vc_vector_useq",        :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
