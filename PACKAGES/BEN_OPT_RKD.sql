--------------------------------------------------------
--  DDL for Package BEN_OPT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPT_RKD" AUTHID CURRENT_USER as
/* $Header: beoptrhi.pkh 120.0 2005/05/28 09:56:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_opt_id                         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_cmbn_ptip_opt_id_o             in number
 ,p_business_group_id_o            in number
 ,p_opt_attribute_category_o       in varchar2
 ,p_opt_attribute1_o               in varchar2
 ,p_opt_attribute2_o               in varchar2
 ,p_opt_attribute3_o               in varchar2
 ,p_opt_attribute4_o               in varchar2
 ,p_opt_attribute5_o               in varchar2
 ,p_opt_attribute6_o               in varchar2
 ,p_opt_attribute7_o               in varchar2
 ,p_opt_attribute8_o               in varchar2
 ,p_opt_attribute9_o               in varchar2
 ,p_opt_attribute10_o              in varchar2
 ,p_opt_attribute11_o              in varchar2
 ,p_opt_attribute12_o              in varchar2
 ,p_opt_attribute13_o              in varchar2
 ,p_opt_attribute14_o              in varchar2
 ,p_opt_attribute15_o              in varchar2
 ,p_opt_attribute16_o              in varchar2
 ,p_opt_attribute17_o              in varchar2
 ,p_opt_attribute18_o              in varchar2
 ,p_opt_attribute19_o              in varchar2
 ,p_opt_attribute20_o              in varchar2
 ,p_opt_attribute21_o              in varchar2
 ,p_opt_attribute22_o              in varchar2
 ,p_opt_attribute23_o              in varchar2
 ,p_opt_attribute24_o              in varchar2
 ,p_opt_attribute25_o              in varchar2
 ,p_opt_attribute26_o              in varchar2
 ,p_opt_attribute27_o              in varchar2
 ,p_opt_attribute28_o              in varchar2
 ,p_opt_attribute29_o              in varchar2
 ,p_opt_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_rqd_perd_enrt_nenrt_uom_o      in varchar2
 ,p_rqd_perd_enrt_nenrt_val_o      in number
 ,p_rqd_perd_enrt_nenrt_rl_o       in number
 ,p_invk_wv_opt_flag_o             in varchar2
 ,p_short_name_o		   in varchar2
 ,p_short_code_o		   in varchar2
 ,p_legislation_code_o		   in varchar2
 ,p_legislation_subgroup_o	   in varchar2
 ,p_group_opt_id_o                 in number
 ,p_component_reason_o             in varchar2
 ,p_mapping_table_name_o           in varchar2
 ,p_mapping_table_pk_id_o          in number
  );
--
end ben_opt_rkd;

 

/
