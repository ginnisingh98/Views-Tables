--------------------------------------------------------
--  DDL for Package BEN_ECT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECT_RKU" AUTHID CURRENT_USER as
/* $Header: beectrhi.pkh 120.0 2005/05/28 01:54:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_dsblty_ctg_prte_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_eligy_prfl_id                  in number
 ,p_category                       in varchar2
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_ect_attribute_category         in varchar2
 ,p_ect_attribute1                 in varchar2
 ,p_ect_attribute2                 in varchar2
 ,p_ect_attribute3                 in varchar2
 ,p_ect_attribute4                 in varchar2
 ,p_ect_attribute5                 in varchar2
 ,p_ect_attribute6                 in varchar2
 ,p_ect_attribute7                 in varchar2
 ,p_ect_attribute8                 in varchar2
 ,p_ect_attribute9                 in varchar2
 ,p_ect_attribute10                in varchar2
 ,p_ect_attribute11                in varchar2
 ,p_ect_attribute12                in varchar2
 ,p_ect_attribute13                in varchar2
 ,p_ect_attribute14                in varchar2
 ,p_ect_attribute15                in varchar2
 ,p_ect_attribute16                in varchar2
 ,p_ect_attribute17                in varchar2
 ,p_ect_attribute18                in varchar2
 ,p_ect_attribute19                in varchar2
 ,p_ect_attribute20                in varchar2
 ,p_ect_attribute21                in varchar2
 ,p_ect_attribute22                in varchar2
 ,p_ect_attribute23                in varchar2
 ,p_ect_attribute24                in varchar2
 ,p_ect_attribute25                in varchar2
 ,p_ect_attribute26                in varchar2
 ,p_ect_attribute27                in varchar2
 ,p_ect_attribute28                in varchar2
 ,p_ect_attribute29                in varchar2
 ,p_ect_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_category_o                     in varchar2
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_ect_attribute_category_o       in varchar2
 ,p_ect_attribute1_o               in varchar2
 ,p_ect_attribute2_o               in varchar2
 ,p_ect_attribute3_o               in varchar2
 ,p_ect_attribute4_o               in varchar2
 ,p_ect_attribute5_o               in varchar2
 ,p_ect_attribute6_o               in varchar2
 ,p_ect_attribute7_o               in varchar2
 ,p_ect_attribute8_o               in varchar2
 ,p_ect_attribute9_o               in varchar2
 ,p_ect_attribute10_o              in varchar2
 ,p_ect_attribute11_o              in varchar2
 ,p_ect_attribute12_o              in varchar2
 ,p_ect_attribute13_o              in varchar2
 ,p_ect_attribute14_o              in varchar2
 ,p_ect_attribute15_o              in varchar2
 ,p_ect_attribute16_o              in varchar2
 ,p_ect_attribute17_o              in varchar2
 ,p_ect_attribute18_o              in varchar2
 ,p_ect_attribute19_o              in varchar2
 ,p_ect_attribute20_o              in varchar2
 ,p_ect_attribute21_o              in varchar2
 ,p_ect_attribute22_o              in varchar2
 ,p_ect_attribute23_o              in varchar2
 ,p_ect_attribute24_o              in varchar2
 ,p_ect_attribute25_o              in varchar2
 ,p_ect_attribute26_o              in varchar2
 ,p_ect_attribute27_o              in varchar2
 ,p_ect_attribute28_o              in varchar2
 ,p_ect_attribute29_o              in varchar2
 ,p_ect_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_ect_rku;

 

/
