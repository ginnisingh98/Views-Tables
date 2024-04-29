--------------------------------------------------------
--  DDL for Package BEN_ENT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENT_RKD" AUTHID CURRENT_USER as
/* $Header: beentrhi.pkh 120.0 2005/05/28 02:31:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_enrld_anthr_ptip_rt_id       in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_enrl_det_dt_cd_o               in varchar2
 ,p_only_pls_subj_cobra_flag_o     in varchar2
 ,p_ptip_id_o                      in number
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_ent_attribute_category_o       in varchar2
 ,p_ent_attribute1_o               in varchar2
 ,p_ent_attribute2_o               in varchar2
 ,p_ent_attribute3_o               in varchar2
 ,p_ent_attribute4_o               in varchar2
 ,p_ent_attribute5_o               in varchar2
 ,p_ent_attribute6_o               in varchar2
 ,p_ent_attribute7_o               in varchar2
 ,p_ent_attribute8_o               in varchar2
 ,p_ent_attribute9_o               in varchar2
 ,p_ent_attribute10_o              in varchar2
 ,p_ent_attribute11_o              in varchar2
 ,p_ent_attribute12_o              in varchar2
 ,p_ent_attribute13_o              in varchar2
 ,p_ent_attribute14_o              in varchar2
 ,p_ent_attribute15_o              in varchar2
 ,p_ent_attribute16_o              in varchar2
 ,p_ent_attribute17_o              in varchar2
 ,p_ent_attribute18_o              in varchar2
 ,p_ent_attribute19_o              in varchar2
 ,p_ent_attribute20_o              in varchar2
 ,p_ent_attribute21_o              in varchar2
 ,p_ent_attribute22_o              in varchar2
 ,p_ent_attribute23_o              in varchar2
 ,p_ent_attribute24_o              in varchar2
 ,p_ent_attribute25_o              in varchar2
 ,p_ent_attribute26_o              in varchar2
 ,p_ent_attribute27_o              in varchar2
 ,p_ent_attribute28_o              in varchar2
 ,p_ent_attribute29_o              in varchar2
 ,p_ent_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ent_rkd;

 

/
