# == Schema Information
#
# Table name: vectors
#
#  id          :integer(4)      not null, primary key
#  description :string(50)
#  vector      :string(75)      default(""), not null
#  u_vector    :string(75)
#  created_at  :datetime
#  updated_at  :timestamp
#

class Vector < ActiveRecord::Base
#VECTOR(1) = 'ACGATAACGGTACAAGGCTAAAGCTTTGCTAACGGTCGAG'
#VECTOR(2) = 'AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAACTCGGCATTCCTGCTGAACCGCTCTTCCGATCT'
end
