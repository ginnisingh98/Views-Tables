--------------------------------------------------------
--  DDL for Package BEN_ECV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECV_RKD" AUTHID CURRENT_USER AS
/* $Header: beecvrhi.pkh 120.1 2005/07/29 10:02:03 rbingi noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_eligy_crit_values_id                      In  Number
 ,p_datetrack_mode                            In  Varchar2
 ,p_validation_start_date                     In  Date
 ,p_validation_end_date                       In  Date
 ,p_effective_start_date                      In  Date
 ,p_effective_end_date                        In  Date
 ,p_eligy_prfl_id_o                           In  Number
 ,p_eligy_criteria_id_o                       In  Number
 ,p_effective_start_date_o                    In  Date
 ,p_effective_end_date_o                      In  Date
 ,p_ordr_num_o                                In  Number
 ,p_number_value1_o                           In  Number
 ,p_number_value2_o                           In  Number
 ,p_char_value1_o                             In  Varchar2
 ,p_char_value2_o                             In  Varchar2
 ,p_date_value1_o                             In  Date
 ,p_date_value2_o                             In  Date
 ,p_excld_flag_o                              In  Varchar2
 ,p_business_group_id_o                       In  Number
 ,p_legislation_code_o                        In  Varchar2
 ,p_ecv_attribute_category_o                  In  Varchar2
 ,p_ecv_attribute1_o                          In  Varchar2
 ,p_ecv_attribute2_o                          In  Varchar2
 ,p_ecv_attribute3_o                          In  Varchar2
 ,p_ecv_attribute4_o                          In  Varchar2
 ,p_ecv_attribute5_o                          In  Varchar2
 ,p_ecv_attribute6_o                          In  Varchar2
 ,p_ecv_attribute7_o                          In  Varchar2
 ,p_ecv_attribute8_o                          In  Varchar2
 ,p_ecv_attribute9_o                          In  Varchar2
 ,p_ecv_attribute10_o                         In  Varchar2
 ,p_ecv_attribute11_o                         In  Varchar2
 ,p_ecv_attribute12_o                         In  Varchar2
 ,p_ecv_attribute13_o                         In  Varchar2
 ,p_ecv_attribute14_o                         In  Varchar2
 ,p_ecv_attribute15_o                         In  Varchar2
 ,p_ecv_attribute16_o                         In  Varchar2
 ,p_ecv_attribute17_o                         In  Varchar2
 ,p_ecv_attribute18_o                         In  Varchar2
 ,p_ecv_attribute19_o                         In  Varchar2
 ,p_ecv_attribute20_o                         In  Varchar2
 ,p_ecv_attribute21_o                         In  Varchar2
 ,p_ecv_attribute22_o                         In  Varchar2
 ,p_ecv_attribute23_o                         In  Varchar2
 ,p_ecv_attribute24_o                         In  Varchar2
 ,p_ecv_attribute25_o                         In  Varchar2
 ,p_ecv_attribute26_o                         In  Varchar2
 ,p_ecv_attribute27_o                         In  Varchar2
 ,p_ecv_attribute28_o                         In  Varchar2
 ,p_ecv_attribute29_o                         In  Varchar2
 ,p_ecv_attribute30_o                         In  Varchar2
 ,p_object_version_number_o                   In  Number
 ,p_criteria_score_o                          In  Number
 ,p_criteria_weight_o                         In  Number
 ,p_Char_value3_o                             In  Varchar2
 ,p_Char_value4_o                             In  Varchar2
 ,p_Number_value3_o                           In  Number
 ,p_Number_value4_o                           In  Number
 ,p_Date_value3_o                             In  Date
 ,p_Date_value4_o                             In  Date
 );
 --
end ben_ecv_rkd;

 

/
