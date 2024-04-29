--------------------------------------------------------
--  DDL for Package BEN_HSR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HSR_RKU" AUTHID CURRENT_USER as
/* $Header: behsrrhi.pkh 120.0 2005/05/28 03:11:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_hrly_slrd_rt_id                in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_vrbl_rt_prfl_id                in number
 ,p_hrly_slrd_cd                      in varchar2
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_business_group_id              in number
 ,p_hsr_attribute_category         in varchar2
 ,p_hsr_attribute1                 in varchar2
 ,p_hsr_attribute2                 in varchar2
 ,p_hsr_attribute3                 in varchar2
 ,p_hsr_attribute4                 in varchar2
 ,p_hsr_attribute5                 in varchar2
 ,p_hsr_attribute6                 in varchar2
 ,p_hsr_attribute7                 in varchar2
 ,p_hsr_attribute8                 in varchar2
 ,p_hsr_attribute9                 in varchar2
 ,p_hsr_attribute10                in varchar2
 ,p_hsr_attribute11                in varchar2
 ,p_hsr_attribute12                in varchar2
 ,p_hsr_attribute13                in varchar2
 ,p_hsr_attribute14                in varchar2
 ,p_hsr_attribute15                in varchar2
 ,p_hsr_attribute16                in varchar2
 ,p_hsr_attribute17                in varchar2
 ,p_hsr_attribute18                in varchar2
 ,p_hsr_attribute19                in varchar2
 ,p_hsr_attribute20                in varchar2
 ,p_hsr_attribute21                in varchar2
 ,p_hsr_attribute22                in varchar2
 ,p_hsr_attribute23                in varchar2
 ,p_hsr_attribute24                in varchar2
 ,p_hsr_attribute25                in varchar2
 ,p_hsr_attribute26                in varchar2
 ,p_hsr_attribute27                in varchar2
 ,p_hsr_attribute28                in varchar2
 ,p_hsr_attribute29                in varchar2
 ,p_hsr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_hrly_slrd_cd_o                  in varchar2
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_business_group_id_o            in number
 ,p_hsr_attribute_category_o       in varchar2
 ,p_hsr_attribute1_o               in varchar2
 ,p_hsr_attribute2_o               in varchar2
 ,p_hsr_attribute3_o               in varchar2
 ,p_hsr_attribute4_o               in varchar2
 ,p_hsr_attribute5_o               in varchar2
 ,p_hsr_attribute6_o               in varchar2
 ,p_hsr_attribute7_o               in varchar2
 ,p_hsr_attribute8_o               in varchar2
 ,p_hsr_attribute9_o               in varchar2
 ,p_hsr_attribute10_o              in varchar2
 ,p_hsr_attribute11_o              in varchar2
 ,p_hsr_attribute12_o              in varchar2
 ,p_hsr_attribute13_o              in varchar2
 ,p_hsr_attribute14_o              in varchar2
 ,p_hsr_attribute15_o              in varchar2
 ,p_hsr_attribute16_o              in varchar2
 ,p_hsr_attribute17_o              in varchar2
 ,p_hsr_attribute18_o              in varchar2
 ,p_hsr_attribute19_o              in varchar2
 ,p_hsr_attribute20_o              in varchar2
 ,p_hsr_attribute21_o              in varchar2
 ,p_hsr_attribute22_o              in varchar2
 ,p_hsr_attribute23_o              in varchar2
 ,p_hsr_attribute24_o              in varchar2
 ,p_hsr_attribute25_o              in varchar2
 ,p_hsr_attribute26_o              in varchar2
 ,p_hsr_attribute27_o              in varchar2
 ,p_hsr_attribute28_o              in varchar2
 ,p_hsr_attribute29_o              in varchar2
 ,p_hsr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_hsr_rku;

 

/
