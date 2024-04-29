--------------------------------------------------------
--  DDL for Package BEN_EGN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EGN_RKU" AUTHID CURRENT_USER as
/* $Header: beegnrhi.pkh 120.0 2005/05/28 02:12:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_gndr_prte_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_sex                            in varchar2
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_egn_attribute_category         in varchar2
 ,p_egn_attribute1                 in varchar2
 ,p_egn_attribute2                 in varchar2
 ,p_egn_attribute3                 in varchar2
 ,p_egn_attribute4                 in varchar2
 ,p_egn_attribute5                 in varchar2
 ,p_egn_attribute6                 in varchar2
 ,p_egn_attribute7                 in varchar2
 ,p_egn_attribute8                 in varchar2
 ,p_egn_attribute9                 in varchar2
 ,p_egn_attribute10                in varchar2
 ,p_egn_attribute11                in varchar2
 ,p_egn_attribute12                in varchar2
 ,p_egn_attribute13                in varchar2
 ,p_egn_attribute14                in varchar2
 ,p_egn_attribute15                in varchar2
 ,p_egn_attribute16                in varchar2
 ,p_egn_attribute17                in varchar2
 ,p_egn_attribute18                in varchar2
 ,p_egn_attribute19                in varchar2
 ,p_egn_attribute20                in varchar2
 ,p_egn_attribute21                in varchar2
 ,p_egn_attribute22                in varchar2
 ,p_egn_attribute23                in varchar2
 ,p_egn_attribute24                in varchar2
 ,p_egn_attribute25                in varchar2
 ,p_egn_attribute26                in varchar2
 ,p_egn_attribute27                in varchar2
 ,p_egn_attribute28                in varchar2
 ,p_egn_attribute29                in varchar2
 ,p_egn_attribute30                in varchar2
 ,p_ordr_num			   in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_sex_o                          in varchar2
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_egn_attribute_category_o       in varchar2
 ,p_egn_attribute1_o               in varchar2
 ,p_egn_attribute2_o               in varchar2
 ,p_egn_attribute3_o               in varchar2
 ,p_egn_attribute4_o               in varchar2
 ,p_egn_attribute5_o               in varchar2
 ,p_egn_attribute6_o               in varchar2
 ,p_egn_attribute7_o               in varchar2
 ,p_egn_attribute8_o               in varchar2
 ,p_egn_attribute9_o               in varchar2
 ,p_egn_attribute10_o              in varchar2
 ,p_egn_attribute11_o              in varchar2
 ,p_egn_attribute12_o              in varchar2
 ,p_egn_attribute13_o              in varchar2
 ,p_egn_attribute14_o              in varchar2
 ,p_egn_attribute15_o              in varchar2
 ,p_egn_attribute16_o              in varchar2
 ,p_egn_attribute17_o              in varchar2
 ,p_egn_attribute18_o              in varchar2
 ,p_egn_attribute19_o              in varchar2
 ,p_egn_attribute20_o              in varchar2
 ,p_egn_attribute21_o              in varchar2
 ,p_egn_attribute22_o              in varchar2
 ,p_egn_attribute23_o              in varchar2
 ,p_egn_attribute24_o              in varchar2
 ,p_egn_attribute25_o              in varchar2
 ,p_egn_attribute26_o              in varchar2
 ,p_egn_attribute27_o              in varchar2
 ,p_egn_attribute28_o              in varchar2
 ,p_egn_attribute29_o              in varchar2
 ,p_egn_attribute30_o              in varchar2
 ,p_ordr_num_o			   in number
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_egn_rku;

 

/
