--------------------------------------------------------
--  DDL for Package BEN_EMC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EMC_RKU" AUTHID CURRENT_USER as
/* $Header: beemcrhi.pkh 120.0 2005/05/28 02:24:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_mltry_stat_cvg_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_dpnt_cvg_eligy_prfl_id         in number
 ,p_mltry_stat_cd                  in varchar2
 ,p_cvg_strt_cd                    in varchar2
 ,p_cvg_strt_rl                    in number
 ,p_cvg_thru_cd                    in varchar2
 ,p_cvg_thru_rl                    in number
 ,p_emc_attribute_category         in varchar2
 ,p_emc_attribute1                 in varchar2
 ,p_emc_attribute2                 in varchar2
 ,p_emc_attribute3                 in varchar2
 ,p_emc_attribute4                 in varchar2
 ,p_emc_attribute5                 in varchar2
 ,p_emc_attribute6                 in varchar2
 ,p_emc_attribute7                 in varchar2
 ,p_emc_attribute8                 in varchar2
 ,p_emc_attribute9                 in varchar2
 ,p_emc_attribute10                in varchar2
 ,p_emc_attribute11                in varchar2
 ,p_emc_attribute12                in varchar2
 ,p_emc_attribute13                in varchar2
 ,p_emc_attribute14                in varchar2
 ,p_emc_attribute15                in varchar2
 ,p_emc_attribute16                in varchar2
 ,p_emc_attribute17                in varchar2
 ,p_emc_attribute18                in varchar2
 ,p_emc_attribute19                in varchar2
 ,p_emc_attribute20                in varchar2
 ,p_emc_attribute21                in varchar2
 ,p_emc_attribute22                in varchar2
 ,p_emc_attribute23                in varchar2
 ,p_emc_attribute24                in varchar2
 ,p_emc_attribute25                in varchar2
 ,p_emc_attribute26                in varchar2
 ,p_emc_attribute27                in varchar2
 ,p_emc_attribute28                in varchar2
 ,p_emc_attribute29                in varchar2
 ,p_emc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
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
end ben_emc_rku;

 

/
