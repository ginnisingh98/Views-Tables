--------------------------------------------------------
--  DDL for Package BEN_RCL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RCL_RKD" AUTHID CURRENT_USER as
/* $Header: berclrhi.pkh 120.0 2005/05/28 11:35:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_rltd_per_chg_cs_ler_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_old_val_o                      in varchar2
 ,p_new_val_o                      in varchar2
 ,p_whatif_lbl_txt_o               in varchar2
 ,p_rule_overrides_flag_o               in varchar2
 ,p_source_column_o                in varchar2
 ,p_source_table_o                 in varchar2
 ,p_rltd_per_chg_cs_ler_rl_o       in number
 ,p_business_group_id_o            in number
 ,p_rcl_attribute_category_o       in varchar2
 ,p_rcl_attribute1_o               in varchar2
 ,p_rcl_attribute2_o               in varchar2
 ,p_rcl_attribute3_o               in varchar2
 ,p_rcl_attribute4_o               in varchar2
 ,p_rcl_attribute5_o               in varchar2
 ,p_rcl_attribute6_o               in varchar2
 ,p_rcl_attribute7_o               in varchar2
 ,p_rcl_attribute8_o               in varchar2
 ,p_rcl_attribute9_o               in varchar2
 ,p_rcl_attribute10_o              in varchar2
 ,p_rcl_attribute11_o              in varchar2
 ,p_rcl_attribute12_o              in varchar2
 ,p_rcl_attribute13_o              in varchar2
 ,p_rcl_attribute14_o              in varchar2
 ,p_rcl_attribute15_o              in varchar2
 ,p_rcl_attribute16_o              in varchar2
 ,p_rcl_attribute17_o              in varchar2
 ,p_rcl_attribute18_o              in varchar2
 ,p_rcl_attribute19_o              in varchar2
 ,p_rcl_attribute20_o              in varchar2
 ,p_rcl_attribute21_o              in varchar2
 ,p_rcl_attribute22_o              in varchar2
 ,p_rcl_attribute23_o              in varchar2
 ,p_rcl_attribute24_o              in varchar2
 ,p_rcl_attribute25_o              in varchar2
 ,p_rcl_attribute26_o              in varchar2
 ,p_rcl_attribute27_o              in varchar2
 ,p_rcl_attribute28_o              in varchar2
 ,p_rcl_attribute29_o              in varchar2
 ,p_rcl_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_rcl_rkd;

 

/
