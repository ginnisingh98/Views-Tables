--------------------------------------------------------
--  DDL for Package BEN_EDC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDC_RKD" AUTHID CURRENT_USER as
/* $Header: beedcrhi.pkh 120.0 2005/05/28 01:57:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_dsbld_stat_cvg_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
end ben_edc_rkd;

 

/
