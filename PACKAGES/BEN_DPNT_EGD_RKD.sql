--------------------------------------------------------
--  DDL for Package BEN_DPNT_EGD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_EGD_RKD" AUTHID CURRENT_USER as

--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_eligy_criteria_dpnt_id              in number
 ,p_name_o                         in  varchar2
 ,p_short_code_o                   in  varchar2
 ,p_description_o                  in  varchar2
 ,p_criteria_type_o		   in  varchar2
 ,p_crit_col1_val_type_cd_o	   in  varchar2
 ,p_crit_col1_datatype_o	   in  varchar2
 ,p_col1_lookup_type_o		   in  varchar2
 ,p_col1_value_set_id_o            in  number
 ,p_access_table_name1_o           in  varchar2
 ,p_access_column_name1_o	   in  varchar2
 ,p_time_entry_access_tab_nam1_o   in  varchar2
 ,p_time_entry_access_col_nam1_o   in  varchar2
 ,p_crit_col2_val_type_cd_o	   in  varchar2
 ,p_crit_col2_datatype_o	   in  varchar2
 ,p_col2_lookup_type_o		   in  varchar2
 ,p_col2_value_set_id_o            in  number
 ,p_access_table_name2_o	   in  varchar2
 ,p_access_column_name2_o	   in  varchar2
 ,p_time_entry_access_tab_nam2_o   in  varchar2
 ,p_time_entry_access_col_nam2_o   in  varchar2
 ,p_allow_range_validation_flg_o   in  varchar2
 ,p_user_defined_flag_o            in  varchar2
 ,p_business_group_id_o 	   in  number
 ,p_egd_attribute_category_o       in varchar2
 ,p_egd_attribute1_o               in varchar2
 ,p_egd_attribute2_o               in varchar2
 ,p_egd_attribute3_o               in varchar2
 ,p_egd_attribute4_o               in varchar2
 ,p_egd_attribute5_o               in varchar2
 ,p_egd_attribute6_o               in varchar2
 ,p_egd_attribute7_o               in varchar2
 ,p_egd_attribute8_o               in varchar2
 ,p_egd_attribute9_o               in varchar2
 ,p_egd_attribute10_o              in varchar2
 ,p_egd_attribute11_o              in varchar2
 ,p_egd_attribute12_o              in varchar2
 ,p_egd_attribute13_o              in varchar2
 ,p_egd_attribute14_o              in varchar2
 ,p_egd_attribute15_o              in varchar2
 ,p_egd_attribute16_o              in varchar2
 ,p_egd_attribute17_o              in varchar2
 ,p_egd_attribute18_o              in varchar2
 ,p_egd_attribute19_o              in varchar2
 ,p_egd_attribute20_o              in varchar2
 ,p_egd_attribute21_o              in varchar2
 ,p_egd_attribute22_o              in varchar2
 ,p_egd_attribute23_o              in varchar2
 ,p_egd_attribute24_o              in varchar2
 ,p_egd_attribute25_o              in varchar2
 ,p_egd_attribute26_o              in varchar2
 ,p_egd_attribute27_o              in varchar2
 ,p_egd_attribute28_o              in varchar2
 ,p_egd_attribute29_o              in varchar2
 ,p_egd_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_allw_range_validation_flg2_o   in varchar2
 ,p_time_access_calc_rule1_o       in number
 ,p_time_access_calc_rule2_o       in number
  );
--
end ben_dpnt_egd_rkd;

/
