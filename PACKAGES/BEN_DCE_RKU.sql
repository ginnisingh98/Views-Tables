--------------------------------------------------------
--  DDL for Package BEN_DCE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DCE_RKU" AUTHID CURRENT_USER as
/* $Header: bedcerhi.pkh 120.0.12010000.2 2010/04/07 06:34:31 pvelvano ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_dpnt_cvg_eligy_prfl_id         in number
 ,p_effective_end_date             in date
 ,p_effective_start_date           in date
 ,p_business_group_id              in number
 ,p_regn_id                        in number
 ,p_name                           in varchar2
 ,p_dpnt_cvg_eligy_prfl_stat_cd    in varchar2
 ,p_dce_desc                       in varchar2
-- ,p_military_status_rqmt_ind       in varchar2
 ,p_dpnt_cvg_elig_det_rl           in number
 ,p_dce_attribute_category         in varchar2
 ,p_dce_attribute1                 in varchar2
 ,p_dce_attribute2                 in varchar2
 ,p_dce_attribute3                 in varchar2
 ,p_dce_attribute4                 in varchar2
 ,p_dce_attribute5                 in varchar2
 ,p_dce_attribute6                 in varchar2
 ,p_dce_attribute7                 in varchar2
 ,p_dce_attribute8                 in varchar2
 ,p_dce_attribute9                 in varchar2
 ,p_dce_attribute10                in varchar2
 ,p_dce_attribute11                in varchar2
 ,p_dce_attribute12                in varchar2
 ,p_dce_attribute13                in varchar2
 ,p_dce_attribute14                in varchar2
 ,p_dce_attribute15                in varchar2
 ,p_dce_attribute16                in varchar2
 ,p_dce_attribute17                in varchar2
 ,p_dce_attribute18                in varchar2
 ,p_dce_attribute19                in varchar2
 ,p_dce_attribute20                in varchar2
 ,p_dce_attribute21                in varchar2
 ,p_dce_attribute22                in varchar2
 ,p_dce_attribute23                in varchar2
 ,p_dce_attribute24                in varchar2
 ,p_dce_attribute25                in varchar2
 ,p_dce_attribute26                in varchar2
 ,p_dce_attribute27                in varchar2
 ,p_dce_attribute28                in varchar2
 ,p_dce_attribute29                in varchar2
 ,p_dce_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_dpnt_rlshp_flag                in  varchar2
 ,p_dpnt_age_flag                  in  varchar2
 ,p_dpnt_stud_flag                 in  varchar2
 ,p_dpnt_dsbld_flag                in  varchar2
 ,p_dpnt_mrtl_flag                 in  varchar2
 ,p_dpnt_mltry_flag                in  varchar2
 ,p_dpnt_pstl_flag                 in  varchar2
 ,p_dpnt_cvrd_in_anthr_pl_flag     in  varchar2
 ,p_dpnt_dsgnt_crntly_enrld_flag   in  varchar2
 ,p_dpnt_crit_flag                 in  varchar2
 ,p_effective_end_date_o           in date
 ,p_effective_start_date_o         in date
 ,p_business_group_id_o            in number
 ,p_regn_id_o                      in number
 ,p_name_o                         in varchar2
 ,p_dpnt_cvg_eligy_prfl_stat_c_o  in varchar2
 ,p_dce_desc_o                     in varchar2
-- ,p_military_status_rqmt_ind_o     in varchar2
 ,p_dpnt_cvg_elig_det_rl_o         in number
 ,p_dce_attribute_category_o       in varchar2
 ,p_dce_attribute1_o               in varchar2
 ,p_dce_attribute2_o               in varchar2
 ,p_dce_attribute3_o               in varchar2
 ,p_dce_attribute4_o               in varchar2
 ,p_dce_attribute5_o               in varchar2
 ,p_dce_attribute6_o               in varchar2
 ,p_dce_attribute7_o               in varchar2
 ,p_dce_attribute8_o               in varchar2
 ,p_dce_attribute9_o               in varchar2
 ,p_dce_attribute10_o              in varchar2
 ,p_dce_attribute11_o              in varchar2
 ,p_dce_attribute12_o              in varchar2
 ,p_dce_attribute13_o              in varchar2
 ,p_dce_attribute14_o              in varchar2
 ,p_dce_attribute15_o              in varchar2
 ,p_dce_attribute16_o              in varchar2
 ,p_dce_attribute17_o              in varchar2
 ,p_dce_attribute18_o              in varchar2
 ,p_dce_attribute19_o              in varchar2
 ,p_dce_attribute20_o              in varchar2
 ,p_dce_attribute21_o              in varchar2
 ,p_dce_attribute22_o              in varchar2
 ,p_dce_attribute23_o              in varchar2
 ,p_dce_attribute24_o              in varchar2
 ,p_dce_attribute25_o              in varchar2
 ,p_dce_attribute26_o              in varchar2
 ,p_dce_attribute27_o              in varchar2
 ,p_dce_attribute28_o              in varchar2
 ,p_dce_attribute29_o              in varchar2
 ,p_dce_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_dpnt_rlshp_flag_o              in  varchar2
 ,p_dpnt_age_flag_o                  in  varchar2
 ,p_dpnt_stud_flag_o                 in  varchar2
 ,p_dpnt_dsbld_flag_o                in  varchar2
 ,p_dpnt_mrtl_flag_o                 in  varchar2
 ,p_dpnt_mltry_flag_o                in  varchar2
 ,p_dpnt_pstl_flag_o                 in  varchar2
 ,p_dpnt_cvrd_in_anthr_pl_flag_o     in  varchar2
 ,p_dpnt_dsgnt_crntly_enrld_fl_o   in  varchar2
 ,p_dpnt_crit_flag_o                 in  varchar2
  );
--
end ben_dce_rku;

/
