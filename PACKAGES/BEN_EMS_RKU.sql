--------------------------------------------------------
--  DDL for Package BEN_EMS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EMS_RKU" AUTHID CURRENT_USER as
/* $Header: beemsrhi.pkh 120.0 2005/05/28 02:26:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_mrtl_stat_cvg_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_dpnt_cvg_eligy_prfl_id         in number
 ,p_mrtl_stat_cd                   in varchar2
 ,p_cvg_strt_cd                    in varchar2
 ,p_cvg_strt_rl                    in number
 ,p_cvg_thru_cd                    in varchar2
 ,p_cvg_thru_rl                    in number
 ,p_ems_attribute_category         in varchar2
 ,p_ems_attribute1                 in varchar2
 ,p_ems_attribute2                 in varchar2
 ,p_ems_attribute3                 in varchar2
 ,p_ems_attribute4                 in varchar2
 ,p_ems_attribute5                 in varchar2
 ,p_ems_attribute6                 in varchar2
 ,p_ems_attribute7                 in varchar2
 ,p_ems_attribute8                 in varchar2
 ,p_ems_attribute9                 in varchar2
 ,p_ems_attribute10                in varchar2
 ,p_ems_attribute11                in varchar2
 ,p_ems_attribute12                in varchar2
 ,p_ems_attribute13                in varchar2
 ,p_ems_attribute14                in varchar2
 ,p_ems_attribute15                in varchar2
 ,p_ems_attribute16                in varchar2
 ,p_ems_attribute17                in varchar2
 ,p_ems_attribute18                in varchar2
 ,p_ems_attribute19                in varchar2
 ,p_ems_attribute20                in varchar2
 ,p_ems_attribute21                in varchar2
 ,p_ems_attribute22                in varchar2
 ,p_ems_attribute23                in varchar2
 ,p_ems_attribute24                in varchar2
 ,p_ems_attribute25                in varchar2
 ,p_ems_attribute26                in varchar2
 ,p_ems_attribute27                in varchar2
 ,p_ems_attribute28                in varchar2
 ,p_ems_attribute29                in varchar2
 ,p_ems_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_dpnt_cvg_eligy_prfl_id_o       in number
 ,p_mrtl_stat_cd_o                 in varchar2
 ,p_cvg_strt_cd_o                  in varchar2
 ,p_cvg_strt_rl_o                  in number
 ,p_cvg_thru_cd_o                  in varchar2
 ,p_cvg_thru_rl_o                  in number
 ,p_ems_attribute_category_o       in varchar2
 ,p_ems_attribute1_o               in varchar2
 ,p_ems_attribute2_o               in varchar2
 ,p_ems_attribute3_o               in varchar2
 ,p_ems_attribute4_o               in varchar2
 ,p_ems_attribute5_o               in varchar2
 ,p_ems_attribute6_o               in varchar2
 ,p_ems_attribute7_o               in varchar2
 ,p_ems_attribute8_o               in varchar2
 ,p_ems_attribute9_o               in varchar2
 ,p_ems_attribute10_o              in varchar2
 ,p_ems_attribute11_o              in varchar2
 ,p_ems_attribute12_o              in varchar2
 ,p_ems_attribute13_o              in varchar2
 ,p_ems_attribute14_o              in varchar2
 ,p_ems_attribute15_o              in varchar2
 ,p_ems_attribute16_o              in varchar2
 ,p_ems_attribute17_o              in varchar2
 ,p_ems_attribute18_o              in varchar2
 ,p_ems_attribute19_o              in varchar2
 ,p_ems_attribute20_o              in varchar2
 ,p_ems_attribute21_o              in varchar2
 ,p_ems_attribute22_o              in varchar2
 ,p_ems_attribute23_o              in varchar2
 ,p_ems_attribute24_o              in varchar2
 ,p_ems_attribute25_o              in varchar2
 ,p_ems_attribute26_o              in varchar2
 ,p_ems_attribute27_o              in varchar2
 ,p_ems_attribute28_o              in varchar2
 ,p_ems_attribute29_o              in varchar2
 ,p_ems_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ems_rku;

 

/
