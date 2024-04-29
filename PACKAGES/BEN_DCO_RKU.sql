--------------------------------------------------------
--  DDL for Package BEN_DCO_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DCO_RKU" AUTHID CURRENT_USER as
/* $Header: bedcorhi.pkh 120.0 2005/05/28 01:33:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_dpnt_cvrd_othr_ptip_rt_id    in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_enrl_det_dt_cd                 in varchar2
 ,p_only_pls_subj_cobra_flag       in varchar2
 ,p_ptip_id                        in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_dco_attribute_category         in varchar2
 ,p_dco_attribute1                 in varchar2
 ,p_dco_attribute2                 in varchar2
 ,p_dco_attribute3                 in varchar2
 ,p_dco_attribute4                 in varchar2
 ,p_dco_attribute5                 in varchar2
 ,p_dco_attribute6                 in varchar2
 ,p_dco_attribute7                 in varchar2
 ,p_dco_attribute8                 in varchar2
 ,p_dco_attribute9                 in varchar2
 ,p_dco_attribute10                in varchar2
 ,p_dco_attribute11                in varchar2
 ,p_dco_attribute12                in varchar2
 ,p_dco_attribute13                in varchar2
 ,p_dco_attribute14                in varchar2
 ,p_dco_attribute15                in varchar2
 ,p_dco_attribute16                in varchar2
 ,p_dco_attribute17                in varchar2
 ,p_dco_attribute18                in varchar2
 ,p_dco_attribute19                in varchar2
 ,p_dco_attribute20                in varchar2
 ,p_dco_attribute21                in varchar2
 ,p_dco_attribute22                in varchar2
 ,p_dco_attribute23                in varchar2
 ,p_dco_attribute24                in varchar2
 ,p_dco_attribute25                in varchar2
 ,p_dco_attribute26                in varchar2
 ,p_dco_attribute27                in varchar2
 ,p_dco_attribute28                in varchar2
 ,p_dco_attribute29                in varchar2
 ,p_dco_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_enrl_det_dt_cd_o               in varchar2
 ,p_only_pls_subj_cobra_flag_o     in varchar2
 ,p_ptip_id_o                      in number
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_dco_attribute_category_o       in varchar2
 ,p_dco_attribute1_o               in varchar2
 ,p_dco_attribute2_o               in varchar2
 ,p_dco_attribute3_o               in varchar2
 ,p_dco_attribute4_o               in varchar2
 ,p_dco_attribute5_o               in varchar2
 ,p_dco_attribute6_o               in varchar2
 ,p_dco_attribute7_o               in varchar2
 ,p_dco_attribute8_o               in varchar2
 ,p_dco_attribute9_o               in varchar2
 ,p_dco_attribute10_o              in varchar2
 ,p_dco_attribute11_o              in varchar2
 ,p_dco_attribute12_o              in varchar2
 ,p_dco_attribute13_o              in varchar2
 ,p_dco_attribute14_o              in varchar2
 ,p_dco_attribute15_o              in varchar2
 ,p_dco_attribute16_o              in varchar2
 ,p_dco_attribute17_o              in varchar2
 ,p_dco_attribute18_o              in varchar2
 ,p_dco_attribute19_o              in varchar2
 ,p_dco_attribute20_o              in varchar2
 ,p_dco_attribute21_o              in varchar2
 ,p_dco_attribute22_o              in varchar2
 ,p_dco_attribute23_o              in varchar2
 ,p_dco_attribute24_o              in varchar2
 ,p_dco_attribute25_o              in varchar2
 ,p_dco_attribute26_o              in varchar2
 ,p_dco_attribute27_o              in varchar2
 ,p_dco_attribute28_o              in varchar2
 ,p_dco_attribute29_o              in varchar2
 ,p_dco_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_dco_rku;

 

/
