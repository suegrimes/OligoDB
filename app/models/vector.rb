# == Schema Information
#
# Table name: vectors
#
#  id         :integer(11)     not null, primary key
#  vector     :string(50)      default(""), not null
#  u_vector   :string(50)
#  created_at :datetime
#  updated_at :timestamp
#

class Vector < ActiveRecord::Base
#VECTOR(1) = 'ACGATAACGGTACAAGGCTAAAGCTTTGCTAACGGTCGAG'
#VECTOR(2) = 'AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAACTCGGCATTCCTGCTGAACCGCTCTTCCGATCT'
end
