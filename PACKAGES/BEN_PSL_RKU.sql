--------------------------------------------------------
--  DDL for Package BEN_PSL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PSL_RKU" AUTHID CURRENT_USER as
/* $Header: bepslrhi.pkh 120.0 2005/05/28 11:18:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_per_info_chg_cs_ler_id         in number
 ,p_name                           in varchar2
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_per_info_chg_cs_ler_rl         in number
 ,p_old_val                        in varchar2
 ,p_new_val                        in varchar2
 ,p_whatif_lbl_txt                 in varchar2
 ,p_rule_overrides_flag                 in varchar2
 ,p_source_column                  in varchar2
 ,p_source_table                   in varchar2
 ,p_business_group_id              in number
 ,p_psl_attribute_category         in varchar2
 ,p_psl_attribute1                 in varchar2
 ,p_psl_attribute2                 in varchar2
 ,p_psl_attribute3                 in varchar2
 ,p_psl_attribute4                 in varchar2
 ,p_psl_attribute5                 in varchar2
 ,p_psl_attribute6                 in varchar2
 ,p_psl_attribute7                 in varchar2
 ,p_psl_attribute8                 in varchar2
 ,p_psl_attribute9                 in varchar2
 ,p_psl_attribute10                in varchar2
 ,p_psl_attribute11                in varchar2
 ,p_psl_attribute12                in varchar2
 ,p_psl_attribute13                in varchar2
 ,p_psl_attribute14                in varchar2
 ,p_psl_attribute15                in varchar2
 ,p_psl_attribute16                in varchar2
 ,p_psl_attribute17                in varchar2
 ,p_psl_attribute18                in varchar2
 ,p_psl_attribute19                in varchar2
 ,p_psl_attribute20                in varchar2
 ,p_psl_attribute21                in varchar2
 ,p_psl_attribute22                in varchar2
 ,p_psl_attribute23                in varchar2
 ,p_psl_attribute24                in varchar2
 ,p_psl_attribute25                in varchar2
 ,p_psl_attribute26                in varchar2
 ,p_psl_attribute27                in varchar2
 ,p_psl_attribute28                in varchar2
 ,p_psl_attribute29                in varchar2
 ,p_psl_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
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
end ben_psl_rku;

 

/
