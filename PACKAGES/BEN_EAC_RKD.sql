--------------------------------------------------------
--  DDL for Package BEN_EAC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EAC_RKD" AUTHID CURRENT_USER as
/* $Header: beeacrhi.pkh 120.0 2005/05/28 01:42:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_age_cvg_id                in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_dpnt_cvg_eligy_prfl_id_o       in number
 ,p_age_fctr_id_o                  in number
 ,p_cvg_strt_cd_o                  in varchar2
 ,p_cvg_strt_rl_o                  in number
 ,p_cvg_thru_cd_o                  in varchar2
 ,p_cvg_thru_rl_o                  in number
 ,p_excld_flag_o                   in varchar2
 ,p_eac_attribute_category_o       in varchar2
 ,p_eac_attribute1_o               in varchar2
 ,p_eac_attribute2_o               in varchar2
 ,p_eac_attribute3_o               in varchar2
 ,p_eac_attribute4_o               in varchar2
 ,p_eac_attribute5_o               in varchar2
 ,p_eac_attribute6_o               in varchar2
 ,p_eac_attribute7_o               in varchar2
 ,p_eac_attribute8_o               in varchar2
 ,p_eac_attribute9_o               in varchar2
 ,p_eac_attribute10_o              in varchar2
 ,p_eac_attribute11_o              in varchar2
 ,p_eac_attribute12_o              in varchar2
 ,p_eac_attribute13_o              in varchar2
 ,p_eac_attribute14_o              in varchar2
 ,p_eac_attribute15_o              in varchar2
 ,p_eac_attribute16_o              in varchar2
 ,p_eac_attribute17_o              in varchar2
 ,p_eac_attribute18_o              in varchar2
 ,p_eac_attribute19_o              in varchar2
 ,p_eac_attribute20_o              in varchar2
 ,p_eac_attribute21_o              in varchar2
 ,p_eac_attribute22_o              in varchar2
 ,p_eac_attribute23_o              in varchar2
 ,p_eac_attribute24_o              in varchar2
 ,p_eac_attribute25_o              in varchar2
 ,p_eac_attribute26_o              in varchar2
 ,p_eac_attribute27_o              in varchar2
 ,p_eac_attribute28_o              in varchar2
 ,p_eac_attribute29_o              in varchar2
 ,p_eac_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_eac_rkd;

 

/
