class CreateOligoDb < ActiveRecord::Migration
  def self.up
    create_table "OligoFlagged", :id => false, :force => true do |t|
    t.string "gene_code"
    t.string "oligo_params"
  end

  create_table "aliquots", :force => true do |t|
    t.integer  "oligo_well_id",    :limit => 11,                                :default => 0
    t.integer  "pool_well_id",     :limit => 11,                                :default => 0
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

  create_table "ccds", :force => true do |t|
    t.integer  "target_region_id", :limit => 11,                 :null => false
    t.string   "ccds_code",        :limit => 20, :default => "", :null => false
    t.integer  "version_id",       :limit => 11
    t.string   "genome_build",     :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ccds", ["target_region_id"], :name => "cd_region_indx"

  create_table "combined_selectors", :id => false, :force => true do |t|
    t.string "sel_id_per_session"
    t.string "roi_num_per_session"
    t.string "chr_num"
    t.string "chr_target_start"
    t.string "L_sel_start"
    t.string "L_sel_end"
    t.string "R_sel_start"
    t.string "R_sel_end"
    t.string "amplicon_length"
    t.string "n_sites_start"
    t.string "left_site"
    t.string "right_site"
    t.string "polarity"
    t.string "enz"
    t.string "selector"
    t.string "5prime_end_20b_sel"
    t.string "3prime_20b__sel"
    t.string "amplicon_seq"
    t.string "roi_ids_of_selectors"
    t.string "U_selector"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.string   "comment",                        :default => ""
    t.datetime "created_at",                                     :null => false
    t.integer  "commentable_id",   :limit => 11, :default => 0,  :null => false
    t.string   "commentable_type", :limit => 15, :default => "", :null => false
    t.integer  "user_id",          :limit => 11, :default => 0,  :null => false
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user"

  create_table "created_files", :force => true do |t|
    t.string   "content_type",  :limit => 20, :default => "", :null => false
    t.string   "created_file",                :default => "", :null => false
    t.integer  "researcher_id", :limit => 11
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "designs_synthesized", :force => true do |t|
    t.integer  "oligo_design_id",  :limit => 11, :null => false
    t.integer  "synth_oligo_id",   :limit => 11, :null => false
    t.integer  "oligo_version_id", :limit => 11
    t.integer  "synth_version_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genes", :force => true do |t|
    t.string   "accession_nr",     :limit => 25
    t.string   "gene_code",        :limit => 25, :default => "", :null => false
    t.integer  "chromosome_nr",    :limit => 6
    t.text     "gene_description"
    t.integer  "version_id",       :limit => 11
    t.string   "genome_build",     :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "genes", ["gene_code"], :name => "gene_code_ind"
  add_index "genes", ["accession_nr"], :name => "accession_ind"

  create_table "indicators", :force => true do |t|
    t.integer "last_oligo_plate_nr", :limit => 11
    t.integer "last_pool_plate_nr",  :limit => 11
  end

  create_table "oligo_designs", :force => true do |t|
    t.string   "oligo_name",              :limit => 100, :default => "", :null => false
    t.integer  "target_region_id",        :limit => 11,  :default => 0,  :null => false
    t.string   "valid_oligo",             :limit => 1,   :default => "", :null => false
    t.string   "chromosome_nr",           :limit => 3
    t.string   "gene_code",               :limit => 25
    t.string   "enzyme_code",             :limit => 20
    t.integer  "selector_nr",             :limit => 9
    t.integer  "roi_nr",                  :limit => 6
    t.string   "internal_QC",             :limit => 2
    t.string   "annotation_codes",        :limit => 20
    t.integer  "sel_n_sites_start",       :limit => 4
    t.integer  "sel_left_start_rel_pos",  :limit => 6
    t.integer  "sel_left_end_rel_pos",    :limit => 6
    t.integer  "sel_left_site_used",      :limit => 4
    t.integer  "sel_right_start_rel_pos", :limit => 6
    t.integer  "sel_right_end_rel_pos",   :limit => 6
    t.integer  "sel_right_site_used",     :limit => 4
    t.string   "sel_polarity",            :limit => 1
    t.string   "sel_5prime",              :limit => 30
    t.string   "sel_3prime",              :limit => 30
    t.string   "usel_5prime",             :limit => 30
    t.string   "usel_3prime",             :limit => 30
    t.string   "selector_useq"
    t.integer  "amplicon_chr_start_pos",  :limit => 11
    t.integer  "amplicon_chr_end_pos",    :limit => 11
    t.integer  "amplicon_length",         :limit => 11
    t.text     "amplicon_seq"
    t.integer  "version_id",              :limit => 11
    t.string   "genome_build",            :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oligo_designs", ["gene_code"], :name => "od_gene_code"

  create_table "oligo_designs_projects", :id => false, :force => true do |t|
    t.integer "oligo_design_id", :limit => 11, :null => false
    t.integer "project_id",      :limit => 11, :null => false
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
    t.integer  "oligo_order_id",      :limit => 11
    t.string   "oligo_plate_nr",      :limit => 50, :default => "", :null => false
    t.string   "oligo_plate_num",     :limit => 8
    t.string   "synth_plate_nr",      :limit => 25
    t.string   "plate_copy_code",     :limit => 2,  :default => "", :null => false
    t.integer  "storage_location_id", :limit => 11
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oligo_plates", ["oligo_order_id"], :name => "op_oligo_order_fk"

  create_table "oligo_wells", :force => true do |t|
    t.string   "oligo_plate_nr",        :limit => 50,                                 :default => "", :null => false
    t.string   "oligo_well_nr",         :limit => 4,                                  :default => "", :null => false
    t.integer  "oligo_plate_id",        :limit => 11,                                 :default => 0,  :null => false
    t.string   "oligo_plate_num",       :limit => 8
    t.string   "plate_copy_code",       :limit => 2
    t.integer  "oligo_design_id",       :limit => 11
    t.integer  "synth_oligo_id",        :limit => 11,                                                 :null => false
    t.string   "oligo_name",            :limit => 100
    t.string   "enzyme_code",           :limit => 20
    t.decimal  "well_initial_volume",                  :precision => 11, :scale => 3
    t.decimal  "well_rem_volume",                      :precision => 11, :scale => 3
    t.string   "well_suspend_lysophil", :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oligo_wells", ["oligo_plate_id"], :name => "ow_oligo_plate_fk"
  add_index "oligo_wells", ["oligo_design_id"], :name => "ow_oligo_design_fk"

  create_table "output_target", :id => false, :force => true do |t|
    t.string "roi_id"
    t.string "gene_name"
    t.string "roi_num_per_gene"
    t.string "cds_ids"
    t.string "ccds_ids"
    t.string "g_accession"
    t.string "chr_num"
    t.string "chr_roi_start"
    t.string "chr_roi_stop"
    t.string "roi_strand"
    t.string "chr_target_start"
    t.string "target_roi_start"
    t.string "target_roi_stop"
    t.string "target_seq_clean"
    t.string "target_seq_degenerate"
    t.string "roi_num_per_session"
    t.string "Mse_n_sites_start"
    t.string "Mse_left_site"
    t.string "Mse_right_site"
    t.string "Mse_sel"
    t.string "Bfa_n_sites_start"
    t.string "Bfa_left_site"
    t.string "Bfa_right_site"
    t.string "Bfa_sel"
    t.string "Sau_n_sites_start"
    t.string "Sau_left_site"
    t.string "Sau_right_site"
    t.string "Sau_sel"
    t.string "fold_coverage"
    t.string "MseI_report"
    t.string "BfaI_report"
    t.string "Sau3AI_report"
    t.string "f33"
  end

  create_table "pathway_genes", :force => true do |t|
    t.string   "gene_code",               :limit => 25,  :default => "", :null => false
    t.integer  "pathway_id",              :limit => 11
    t.string   "pathway_name",            :limit => 100
    t.string   "affymetrix_code"
    t.string   "chromosome_location",                    :default => "", :null => false
    t.string   "unigene_code"
    t.string   "ensemble_code"
    t.string   "refseq_protein_codes"
    t.string   "refseq_transcript_codes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pathway_genes", ["gene_code"], :name => "pg_gene_code"
  add_index "pathway_genes", ["pathway_id"], :name => "pathway_fk"

  create_table "pathways", :force => true do |t|
    t.string   "pathway_name", :limit => 100, :default => "", :null => false
    t.string   "contributor",  :limit => 50,  :default => "", :null => false
    t.string   "version_nr",   :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pool_plates", :force => true do |t|
    t.string   "pool_plate_nr",   :limit => 50
    t.string   "pool_plate_desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pool_wells", :force => true do |t|
    t.integer  "pool_plate_id",       :limit => 11, :default => 0,   :null => false
    t.string   "pool_plate_nr",       :limit => 50
    t.string   "pool_well_nr",        :limit => 4,  :default => "",  :null => false
    t.string   "pool_tube_label",     :limit => 50
    t.string   "enzyme_code",         :limit => 20
    t.string   "concentration",       :limit => 20
    t.float    "pool_volume",         :limit => 11, :default => 0.0
    t.float    "pool_rem_volume",     :limit => 11
    t.integer  "pool_id",             :limit => 11
    t.integer  "storage_location_id", :limit => 11
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pool_wells", ["pool_plate_id"], :name => "pw_pool_plate_fk"
  add_index "pool_wells", ["pool_id"], :name => "pw_pool_id"

  create_table "pools", :force => true do |t|
    t.string   "pool_name",           :limit => 50,                               :default => "",  :null => false
    t.string   "enzyme_code",         :limit => 20,                               :default => "",  :null => false
    t.string   "pool_description"
    t.decimal  "pool_volume",                       :precision => 9, :scale => 3, :default => 0.0
    t.integer  "storage_location_id", :limit => 11
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_genes", :force => true do |t|
    t.integer "project_id", :limit => 11,                 :null => false
    t.string  "gene_code",  :limit => 25, :default => "", :null => false
  end

  create_table "projects", :force => true do |t|
    t.string "project_name",        :limit => 50, :default => "", :null => false
    t.string "project_description"
  end

  create_table "researchers", :force => true do |t|
    t.string "researcher_name",     :limit => 50, :default => "", :null => false
    t.string "researcher_initials", :limit => 3,  :default => "", :null => false
    t.string "company",             :limit => 50
    t.string "phone_number",        :limit => 20
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id", :limit => 11
    t.integer "user_id", :limit => 11
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "selector_sites", :force => true do |t|
    t.integer  "target_region_id", :limit => 11,                 :null => false
    t.string   "enzyme_code",      :limit => 20, :default => "", :null => false
    t.integer  "n_sites_start",    :limit => 4,                  :null => false
    t.integer  "left_site_used",   :limit => 4
    t.integer  "right_site_used",  :limit => 4
    t.string   "selector"
    t.string   "design_result",                  :default => "", :null => false
    t.integer  "version_id",       :limit => 11
    t.string   "genome_build",     :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "selector_sites", ["target_region_id"], :name => "ss_region_indx"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "storage_locations", :force => true do |t|
    t.string    "room_nr",    :limit => 25, :default => "", :null => false
    t.string    "shelf_nr",   :limit => 25
    t.string    "bin_nr",     :limit => 25
    t.string    "box_nr",     :limit => 25
    t.string    "comments"
    t.datetime  "created_at"
    t.timestamp "updated_at"
  end

  create_table "synth_oligos", :force => true do |t|
    t.string   "oligo_name",              :limit => 100, :default => "", :null => false
    t.integer  "target_region_id",        :limit => 11,  :default => 0,  :null => false
    t.string   "valid_oligo",             :limit => 1,   :default => "", :null => false
    t.string   "chromosome_nr",           :limit => 3
    t.string   "gene_code",               :limit => 25
    t.string   "enzyme_code",             :limit => 20
    t.integer  "selector_nr",             :limit => 9
    t.integer  "roi_nr",                  :limit => 6
    t.string   "internal_QC",             :limit => 2
    t.string   "annotation_codes",        :limit => 20
    t.integer  "sel_n_sites_start",       :limit => 4
    t.integer  "sel_left_start_rel_pos",  :limit => 6
    t.integer  "sel_left_end_rel_pos",    :limit => 6
    t.integer  "sel_left_site_used",      :limit => 4
    t.integer  "sel_right_start_rel_pos", :limit => 6
    t.integer  "sel_right_end_rel_pos",   :limit => 6
    t.integer  "sel_right_site_used",     :limit => 4
    t.string   "sel_polarity",            :limit => 1
    t.string   "sel_5prime",              :limit => 30
    t.string   "sel_3prime",              :limit => 30
    t.string   "usel_5prime",             :limit => 30
    t.string   "usel_3prime",             :limit => 30
    t.string   "selector_useq"
    t.integer  "amplicon_chr_start_pos",  :limit => 11
    t.integer  "amplicon_chr_end_pos",    :limit => 11
    t.integer  "amplicon_length",         :limit => 11
    t.text     "amplicon_seq"
    t.integer  "version_id",              :limit => 11
    t.string   "genome_build",            :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "synth_oligos", ["gene_code"], :name => "so_gene_code"

  create_table "syntheses", :force => true do |t|
    t.string    "researcher",    :limit => 50
    t.string    "gene_code",     :limit => 8
    t.integer   "order_line_nr", :limit => 4
    t.string    "oligo_name",    :limit => 50
    t.string    "selector_useq"
    t.timestamp "created_at"
  end

  create_table "target_regions", :force => true do |t|
    t.integer   "gene_id",               :limit => 11, :null => false
    t.string    "gene_roi",              :limit => 50
    t.integer   "fold_coverage",         :limit => 6
    t.string    "cds_codes"
    t.integer   "chr_roi_start",         :limit => 11
    t.integer   "chr_roi_stop",          :limit => 11
    t.integer   "roi_strand",            :limit => 6
    t.integer   "chr_target_start",      :limit => 11
    t.integer   "target_roi_start",      :limit => 11
    t.integer   "target_roi_stop",       :limit => 11
    t.text      "target_seq_clean"
    t.text      "target_seq_degenerate"
    t.integer   "version_id",            :limit => 11
    t.string    "genome_build",          :limit => 25
    t.datetime  "created_at"
    t.timestamp "updated_at"
  end

  add_index "target_regions", ["gene_roi"], :name => "gene_roi_ind"

  create_table "targets", :force => true do |t|
    t.string    "gene_roi",              :limit => 50
    t.string    "gene_code",             :limit => 25
    t.integer   "roi_nr",                :limit => 6
    t.string    "cds_ids"
    t.string    "ccds_ids"
    t.string    "g_accession"
    t.string    "chr_num",               :limit => 3
    t.integer   "chr_roi_start",         :limit => 11
    t.integer   "chr_roi_stop",          :limit => 10
    t.integer   "roi_strand",            :limit => 6
    t.integer   "chr_target_start",      :limit => 10
    t.integer   "target_roi_start",      :limit => 11
    t.integer   "target_roi_stop",       :limit => 255
    t.string    "target_seq_clean"
    t.string    "target_seq_degenerate"
    t.datetime  "created_at"
    t.timestamp "updated_at"
  end

  create_table "uploads", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "filename"
    t.string   "original_filename"
    t.string   "content_type"
    t.integer  "size",              :limit => 11
    t.string   "upload_file"
    t.string   "sender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "loadtodb_at"
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

  create_table "versions", :force => true do |t|
    t.string    "version_for_synthesis", :limit => 1
    t.string    "genome_build",          :limit => 25, :default => "", :null => false
    t.string    "design_version",        :limit => 25, :default => "", :null => false
    t.string    "genome_build_notes"
    t.string    "design_version_notes"
    t.datetime  "created_at"
    t.timestamp "updated_at",                                          :null => false
  end

end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
