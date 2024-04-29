--------------------------------------------------------
--  DDL for Package BEN_EMC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EMC_RKD" AUTHID CURRENT_USER as
/* $Header: beemcrhi.pkh 120.0 2005/05/28 02:24:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_mltry_stat_cvg_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_dpnt_cvg_eligy_prfl_id_o       in number
 ,p_mltry_stat_cd_o                in varchar2
 ,p_cvg_strt_cd_o                  in varchar2
 ,p_cvg_strt_rl_o                  in number
 ,p_cvg_thru_cd_o                  in varchar2
 ,p_cvg_thru_rl_o                  in number
 ,p_emc_attribute_category_o       in varchar2
 ,p_emc_attribute1_o               in varchar2
 ,p_emc_attribute2_o               in varchar2
 ,p_emc_attribute3_o               in varchar2
 ,p_emc_attribute4_o               in varchar2
 ,p_emc_attribute5_o               in varchar2
 ,p_emc_attribute6_o               in varchar2
 ,p_emc_attribute7_o               in varchar2
 ,p_emc_attribute8_o               in varchar2
 ,p_emc_attribute9_o               in varchar2
 ,p_emc_attribute10_o              in varchar2
 ,p_emc_attribute11_o              in varchar2
 ,p_emc_attribute12_o              in varchar2
 ,p_emc_attribute13_o              in varchar2
 ,p_emc_attribute14_o              in varchar2
 ,p_emc_attribute15_o              in varchar2
 ,p_emc_attribute16_o              in varchar2
 ,p_emc_attribute17_o              in varchar2
 ,p_emc_attribute18_o              in varchar2
 ,p_emc_attribute19_o              in varchar2
 ,p_emc_attribute20_o              in varchar2
 ,p_emc_attribute21_o              in varchar2
 ,p_emc_attribute22_o              in varchar2
 ,p_emc_attribute23_o              in varchar2
 ,p_emc_attribute24_o              in varchar2
 ,p_emc_attribute25_o              in varchar2
 ,p_emc_attribute26_o              in varchar2
 ,p_emc_attribute27_o              in varchar2
 ,p_emc_attribute28_o              in varchar2
 ,p_emc_attribute29_o              in varchar2
 ,p_emc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_emc_rkd;

 

/
