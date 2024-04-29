--------------------------------------------------------
--  DDL for Package BEN_EDR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDR_RKU" AUTHID CURRENT_USER as
/* $Header: beedrrhi.pkh 120.0 2005/05/28 02:01:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_dsblty_rsn_prte_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_eligy_prfl_id                  in number
 ,p_reason                     in varchar2
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_edr_attribute_category         in varchar2
 ,p_edr_attribute1                 in varchar2
 ,p_edr_attribute2                 in varchar2
 ,p_edr_attribute3                 in varchar2
 ,p_edr_attribute4                 in varchar2
 ,p_edr_attribute5                 in varchar2
 ,p_edr_attribute6                 in varchar2
 ,p_edr_attribute7                 in varchar2
 ,p_edr_attribute8                 in varchar2
 ,p_edr_attribute9                 in varchar2
 ,p_edr_attribute10                in varchar2
 ,p_edr_attribute11                in varchar2
 ,p_edr_attribute12                in varchar2
 ,p_edr_attribute13                in varchar2
 ,p_edr_attribute14                in varchar2
 ,p_edr_attribute15                in varchar2
 ,p_edr_attribute16                in varchar2
 ,p_edr_attribute17                in varchar2
 ,p_edr_attribute18                in varchar2
 ,p_edr_attribute19                in varchar2
 ,p_edr_attribute20                in varchar2
 ,p_edr_attribute21                in varchar2
 ,p_edr_attribute22                in varchar2
 ,p_edr_attribute23                in varchar2
 ,p_edr_attribute24                in varchar2
 ,p_edr_attribute25                in varchar2
 ,p_edr_attribute26                in varchar2
 ,p_edr_attribute27                in varchar2
 ,p_edr_attribute28                in varchar2
 ,p_edr_attribute29                in varchar2
 ,p_edr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_reason_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_edr_attribute_category_o       in varchar2
 ,p_edr_attribute1_o               in varchar2
 ,p_edr_attribute2_o               in varchar2
 ,p_edr_attribute3_o               in varchar2
 ,p_edr_attribute4_o               in varchar2
 ,p_edr_attribute5_o               in varchar2
 ,p_edr_attribute6_o               in varchar2
 ,p_edr_attribute7_o               in varchar2
 ,p_edr_attribute8_o               in varchar2
 ,p_edr_attribute9_o               in varchar2
 ,p_edr_attribute10_o              in varchar2
 ,p_edr_attribute11_o              in varchar2
 ,p_edr_attribute12_o              in varchar2
 ,p_edr_attribute13_o              in varchar2
 ,p_edr_attribute14_o              in varchar2
 ,p_edr_attribute15_o              in varchar2
 ,p_edr_attribute16_o              in varchar2
 ,p_edr_attribute17_o              in varchar2
 ,p_edr_attribute18_o              in varchar2
 ,p_edr_attribute19_o              in varchar2
 ,p_edr_attribute20_o              in varchar2
 ,p_edr_attribute21_o              in varchar2
 ,p_edr_attribute22_o              in varchar2
 ,p_edr_attribute23_o              in varchar2
 ,p_edr_attribute24_o              in varchar2
 ,p_edr_attribute25_o              in varchar2
 ,p_edr_attribute26_o              in varchar2
 ,p_edr_attribute27_o              in varchar2
 ,p_edr_attribute28_o              in varchar2
 ,p_edr_attribute29_o              in varchar2
 ,p_edr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_edr_rku;

 

/
