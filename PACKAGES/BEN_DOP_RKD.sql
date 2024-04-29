--------------------------------------------------------
--  DDL for Package BEN_DOP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DOP_RKD" AUTHID CURRENT_USER as
/* $Header: bedoprhi.pkh 120.0 2005/05/28 01:37:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_dpnt_cvrd_othr_pgm_rt_id     in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_only_pls_subj_cobra_flag_o     in varchar2
 ,p_enrl_det_dt_cd_o               in varchar2
 ,p_ordr_num_o                     in number
 ,p_pgm_id_o                       in number
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_dop_attribute_category_o       in varchar2
 ,p_dop_attribute1_o               in varchar2
 ,p_dop_attribute2_o               in varchar2
 ,p_dop_attribute3_o               in varchar2
 ,p_dop_attribute4_o               in varchar2
 ,p_dop_attribute5_o               in varchar2
 ,p_dop_attribute6_o               in varchar2
 ,p_dop_attribute7_o               in varchar2
 ,p_dop_attribute8_o               in varchar2
 ,p_dop_attribute9_o               in varchar2
 ,p_dop_attribute10_o              in varchar2
 ,p_dop_attribute11_o              in varchar2
 ,p_dop_attribute12_o              in varchar2
 ,p_dop_attribute13_o              in varchar2
 ,p_dop_attribute14_o              in varchar2
 ,p_dop_attribute15_o              in varchar2
 ,p_dop_attribute16_o              in varchar2
 ,p_dop_attribute17_o              in varchar2
 ,p_dop_attribute18_o              in varchar2
 ,p_dop_attribute19_o              in varchar2
 ,p_dop_attribute20_o              in varchar2
 ,p_dop_attribute21_o              in varchar2
 ,p_dop_attribute22_o              in varchar2
 ,p_dop_attribute23_o              in varchar2
 ,p_dop_attribute24_o              in varchar2
 ,p_dop_attribute25_o              in varchar2
 ,p_dop_attribute26_o              in varchar2
 ,p_dop_attribute27_o              in varchar2
 ,p_dop_attribute28_o              in varchar2
 ,p_dop_attribute29_o              in varchar2
 ,p_dop_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_dop_rkd;

 

/
