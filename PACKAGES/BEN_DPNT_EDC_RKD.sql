--------------------------------------------------------
--  DDL for Package BEN_DPNT_EDC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_EDC_RKD" AUTHID CURRENT_USER AS
/* $Header: beedvrhi.pkh 120.0.12010000.1 2010/04/09 06:34:15 pvelvano noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_dpnt_eligy_crit_values_id                      In  Number
 ,p_datetrack_mode                            In  Varchar2
 ,p_validation_start_date                     In  Date
 ,p_validation_end_date                       In  Date
 ,p_effective_start_date                      In  Date
 ,p_effective_end_date                        In  Date
 ,p_dpnt_cvg_eligy_prfl_id_o                           In  Number
 ,p_eligy_criteria_dpnt_id_o                       In  Number
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
 ,p_edc_attribute_category_o                  In  Varchar2
 ,p_edc_attribute1_o                          In  Varchar2
 ,p_edc_attribute2_o                          In  Varchar2
 ,p_edc_attribute3_o                          In  Varchar2
 ,p_edc_attribute4_o                          In  Varchar2
 ,p_edc_attribute5_o                          In  Varchar2
 ,p_edc_attribute6_o                          In  Varchar2
 ,p_edc_attribute7_o                          In  Varchar2
 ,p_edc_attribute8_o                          In  Varchar2
 ,p_edc_attribute9_o                          In  Varchar2
 ,p_edc_attribute10_o                         In  Varchar2
 ,p_edc_attribute11_o                         In  Varchar2
 ,p_edc_attribute12_o                         In  Varchar2
 ,p_edc_attribute13_o                         In  Varchar2
 ,p_edc_attribute14_o                         In  Varchar2
 ,p_edc_attribute15_o                         In  Varchar2
 ,p_edc_attribute16_o                         In  Varchar2
 ,p_edc_attribute17_o                         In  Varchar2
 ,p_edc_attribute18_o                         In  Varchar2
 ,p_edc_attribute19_o                         In  Varchar2
 ,p_edc_attribute20_o                         In  Varchar2
 ,p_edc_attribute21_o                         In  Varchar2
 ,p_edc_attribute22_o                         In  Varchar2
 ,p_edc_attribute23_o                         In  Varchar2
 ,p_edc_attribute24_o                         In  Varchar2
 ,p_edc_attribute25_o                         In  Varchar2
 ,p_edc_attribute26_o                         In  Varchar2
 ,p_edc_attribute27_o                         In  Varchar2
 ,p_edc_attribute28_o                         In  Varchar2
 ,p_edc_attribute29_o                         In  Varchar2
 ,p_edc_attribute30_o                         In  Varchar2
 ,p_object_version_number_o                   In  Number
 ,p_Char_value3_o                             In  Varchar2
 ,p_Char_value4_o                             In  Varchar2
 ,p_Number_value3_o                           In  Number
 ,p_Number_value4_o                           In  Number
 ,p_Date_value3_o                             In  Date
 ,p_Date_value4_o                             In  Date
 );
 --
end ben_dpnt_edc_rkd;

/
