--------------------------------------------------------
--  DDL for Package BEN_PSL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PSL_RKD" AUTHID CURRENT_USER as
/* $Header: bepslrhi.pkh 120.0 2005/05/28 11:18:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_per_info_chg_cs_ler_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name_o                         in varchar2
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_per_info_chg_cs_ler_rl_o       in number
 ,p_old_val_o                      in varchar2
 ,p_new_val_o                      in varchar2
 ,p_whatif_lbl_txt_o               in varchar2
 ,p_rule_overrides_flag_o               in varchar2
 ,p_source_column_o                in varchar2
 ,p_source_table_o                 in varchar2
 ,p_business_group_id_o            in number
 ,p_psl_attribute_category_o       in varchar2
 ,p_psl_attribute1_o               in varchar2
 ,p_psl_attribute2_o               in varchar2
 ,p_psl_attribute3_o               in varchar2
 ,p_psl_attribute4_o               in varchar2
 ,p_psl_attribute5_o               in varchar2
 ,p_psl_attribute6_o               in varchar2
 ,p_psl_attribute7_o               in varchar2
 ,p_psl_attribute8_o               in varchar2
 ,p_psl_attribute9_o               in varchar2
 ,p_psl_attribute10_o              in varchar2
 ,p_psl_attribute11_o              in varchar2
 ,p_psl_attribute12_o              in varchar2
 ,p_psl_attribute13_o              in varchar2
 ,p_psl_attribute14_o              in varchar2
 ,p_psl_attribute15_o              in varchar2
 ,p_psl_attribute16_o              in varchar2
 ,p_psl_attribute17_o              in varchar2
 ,p_psl_attribute18_o              in varchar2
 ,p_psl_attribute19_o              in varchar2
 ,p_psl_attribute20_o              in varchar2
 ,p_psl_attribute21_o              in varchar2
 ,p_psl_attribute22_o              in varchar2
 ,p_psl_attribute23_o              in varchar2
 ,p_psl_attribute24_o              in varchar2
 ,p_psl_attribute25_o              in varchar2
 ,p_psl_attribute26_o              in varchar2
 ,p_psl_attribute27_o              in varchar2
 ,p_psl_attribute28_o              in varchar2
 ,p_psl_attribute29_o              in varchar2
 ,p_psl_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_psl_rkd;

 

/
