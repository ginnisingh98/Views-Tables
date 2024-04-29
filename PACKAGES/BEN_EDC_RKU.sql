--------------------------------------------------------
--  DDL for Package BEN_EDC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDC_RKU" AUTHID CURRENT_USER as
/* $Header: beedcrhi.pkh 120.0 2005/05/28 01:57:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_dsbld_stat_cvg_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_dpnt_cvg_eligy_prfl_id         in number
 ,p_cvg_strt_cd                    in varchar2
 ,p_cvg_strt_rl                    in number
 ,p_cvg_thru_cd                    in varchar2
 ,p_cvg_thru_rl                    in number
 ,p_dsbld_cd                       in varchar2
 ,p_edc_attribute_category         in varchar2
 ,p_edc_attribute1                 in varchar2
 ,p_edc_attribute2                 in varchar2
 ,p_edc_attribute3                 in varchar2
 ,p_edc_attribute4                 in varchar2
 ,p_edc_attribute5                 in varchar2
 ,p_edc_attribute6                 in varchar2
 ,p_edc_attribute7                 in varchar2
 ,p_edc_attribute8                 in varchar2
 ,p_edc_attribute9                 in varchar2
 ,p_edc_attribute10                in varchar2
 ,p_edc_attribute11                in varchar2
 ,p_edc_attribute12                in varchar2
 ,p_edc_attribute13                in varchar2
 ,p_edc_attribute14                in varchar2
 ,p_edc_attribute15                in varchar2
 ,p_edc_attribute16                in varchar2
 ,p_edc_attribute17                in varchar2
 ,p_edc_attribute18                in varchar2
 ,p_edc_attribute19                in varchar2
 ,p_edc_attribute20                in varchar2
 ,p_edc_attribute21                in varchar2
 ,p_edc_attribute22                in varchar2
 ,p_edc_attribute23                in varchar2
 ,p_edc_attribute24                in varchar2
 ,p_edc_attribute25                in varchar2
 ,p_edc_attribute26                in varchar2
 ,p_edc_attribute27                in varchar2
 ,p_edc_attribute28                in varchar2
 ,p_edc_attribute29                in varchar2
 ,p_edc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_dpnt_cvg_eligy_prfl_id_o       in number
 ,p_cvg_strt_cd_o                  in varchar2
 ,p_cvg_strt_rl_o                  in number
 ,p_cvg_thru_cd_o                  in varchar2
 ,p_cvg_thru_rl_o                  in number
 ,p_dsbld_cd_o                     in varchar2
 ,p_edc_attribute_category_o       in varchar2
 ,p_edc_attribute1_o               in varchar2
 ,p_edc_attribute2_o               in varchar2
 ,p_edc_attribute3_o               in varchar2
 ,p_edc_attribute4_o               in varchar2
 ,p_edc_attribute5_o               in varchar2
 ,p_edc_attribute6_o               in varchar2
 ,p_edc_attribute7_o               in varchar2
 ,p_edc_attribute8_o               in varchar2
 ,p_edc_attribute9_o               in varchar2
 ,p_edc_attribute10_o              in varchar2
 ,p_edc_attribute11_o              in varchar2
 ,p_edc_attribute12_o              in varchar2
 ,p_edc_attribute13_o              in varchar2
 ,p_edc_attribute14_o              in varchar2
 ,p_edc_attribute15_o              in varchar2
 ,p_edc_attribute16_o              in varchar2
 ,p_edc_attribute17_o              in varchar2
 ,p_edc_attribute18_o              in varchar2
 ,p_edc_attribute19_o              in varchar2
 ,p_edc_attribute20_o              in varchar2
 ,p_edc_attribute21_o              in varchar2
 ,p_edc_attribute22_o              in varchar2
 ,p_edc_attribute23_o              in varchar2
 ,p_edc_attribute24_o              in varchar2
 ,p_edc_attribute25_o              in varchar2
 ,p_edc_attribute26_o              in varchar2
 ,p_edc_attribute27_o              in varchar2
 ,p_edc_attribute28_o              in varchar2
 ,p_edc_attribute29_o              in varchar2
 ,p_edc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_edc_rku;

 

/
