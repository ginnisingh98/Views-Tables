--------------------------------------------------------
--  DDL for Package BEN_EBN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EBN_RKU" AUTHID CURRENT_USER as
/* $Header: beebnrhi.pkh 120.0 2005/05/28 01:47:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_benfts_grp_prte_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_benfts_grp_id                  in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_ebn_attribute_category         in varchar2
 ,p_ebn_attribute1                 in varchar2
 ,p_ebn_attribute2                 in varchar2
 ,p_ebn_attribute3                 in varchar2
 ,p_ebn_attribute4                 in varchar2
 ,p_ebn_attribute5                 in varchar2
 ,p_ebn_attribute6                 in varchar2
 ,p_ebn_attribute7                 in varchar2
 ,p_ebn_attribute8                 in varchar2
 ,p_ebn_attribute9                 in varchar2
 ,p_ebn_attribute10                in varchar2
 ,p_ebn_attribute11                in varchar2
 ,p_ebn_attribute12                in varchar2
 ,p_ebn_attribute13                in varchar2
 ,p_ebn_attribute14                in varchar2
 ,p_ebn_attribute15                in varchar2
 ,p_ebn_attribute16                in varchar2
 ,p_ebn_attribute17                in varchar2
 ,p_ebn_attribute18                in varchar2
 ,p_ebn_attribute19                in varchar2
 ,p_ebn_attribute20                in varchar2
 ,p_ebn_attribute21                in varchar2
 ,p_ebn_attribute22                in varchar2
 ,p_ebn_attribute23                in varchar2
 ,p_ebn_attribute24                in varchar2
 ,p_ebn_attribute25                in varchar2
 ,p_ebn_attribute26                in varchar2
 ,p_ebn_attribute27                in varchar2
 ,p_ebn_attribute28                in varchar2
 ,p_ebn_attribute29                in varchar2
 ,p_ebn_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_benfts_grp_id_o                in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_ebn_attribute_category_o       in varchar2
 ,p_ebn_attribute1_o               in varchar2
 ,p_ebn_attribute2_o               in varchar2
 ,p_ebn_attribute3_o               in varchar2
 ,p_ebn_attribute4_o               in varchar2
 ,p_ebn_attribute5_o               in varchar2
 ,p_ebn_attribute6_o               in varchar2
 ,p_ebn_attribute7_o               in varchar2
 ,p_ebn_attribute8_o               in varchar2
 ,p_ebn_attribute9_o               in varchar2
 ,p_ebn_attribute10_o              in varchar2
 ,p_ebn_attribute11_o              in varchar2
 ,p_ebn_attribute12_o              in varchar2
 ,p_ebn_attribute13_o              in varchar2
 ,p_ebn_attribute14_o              in varchar2
 ,p_ebn_attribute15_o              in varchar2
 ,p_ebn_attribute16_o              in varchar2
 ,p_ebn_attribute17_o              in varchar2
 ,p_ebn_attribute18_o              in varchar2
 ,p_ebn_attribute19_o              in varchar2
 ,p_ebn_attribute20_o              in varchar2
 ,p_ebn_attribute21_o              in varchar2
 ,p_ebn_attribute22_o              in varchar2
 ,p_ebn_attribute23_o              in varchar2
 ,p_ebn_attribute24_o              in varchar2
 ,p_ebn_attribute25_o              in varchar2
 ,p_ebn_attribute26_o              in varchar2
 ,p_ebn_attribute27_o              in varchar2
 ,p_ebn_attribute28_o              in varchar2
 ,p_ebn_attribute29_o              in varchar2
 ,p_ebn_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_ebn_rku;

 

/
