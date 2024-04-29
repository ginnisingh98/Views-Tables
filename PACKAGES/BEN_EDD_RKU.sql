--------------------------------------------------------
--  DDL for Package BEN_EDD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDD_RKU" AUTHID CURRENT_USER as
/* $Header: beeddrhi.pkh 120.0 2005/05/28 01:58:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_dsblty_dgr_prte_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_eligy_prfl_id                  in number
 ,p_degree                     in number
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_edd_attribute_category         in varchar2
 ,p_edd_attribute1                 in varchar2
 ,p_edd_attribute2                 in varchar2
 ,p_edd_attribute3                 in varchar2
 ,p_edd_attribute4                 in varchar2
 ,p_edd_attribute5                 in varchar2
 ,p_edd_attribute6                 in varchar2
 ,p_edd_attribute7                 in varchar2
 ,p_edd_attribute8                 in varchar2
 ,p_edd_attribute9                 in varchar2
 ,p_edd_attribute10                in varchar2
 ,p_edd_attribute11                in varchar2
 ,p_edd_attribute12                in varchar2
 ,p_edd_attribute13                in varchar2
 ,p_edd_attribute14                in varchar2
 ,p_edd_attribute15                in varchar2
 ,p_edd_attribute16                in varchar2
 ,p_edd_attribute17                in varchar2
 ,p_edd_attribute18                in varchar2
 ,p_edd_attribute19                in varchar2
 ,p_edd_attribute20                in varchar2
 ,p_edd_attribute21                in varchar2
 ,p_edd_attribute22                in varchar2
 ,p_edd_attribute23                in varchar2
 ,p_edd_attribute24                in varchar2
 ,p_edd_attribute25                in varchar2
 ,p_edd_attribute26                in varchar2
 ,p_edd_attribute27                in varchar2
 ,p_edd_attribute28                in varchar2
 ,p_edd_attribute29                in varchar2
 ,p_edd_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_degree_o                   in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_edd_attribute_category_o       in varchar2
 ,p_edd_attribute1_o               in varchar2
 ,p_edd_attribute2_o               in varchar2
 ,p_edd_attribute3_o               in varchar2
 ,p_edd_attribute4_o               in varchar2
 ,p_edd_attribute5_o               in varchar2
 ,p_edd_attribute6_o               in varchar2
 ,p_edd_attribute7_o               in varchar2
 ,p_edd_attribute8_o               in varchar2
 ,p_edd_attribute9_o               in varchar2
 ,p_edd_attribute10_o              in varchar2
 ,p_edd_attribute11_o              in varchar2
 ,p_edd_attribute12_o              in varchar2
 ,p_edd_attribute13_o              in varchar2
 ,p_edd_attribute14_o              in varchar2
 ,p_edd_attribute15_o              in varchar2
 ,p_edd_attribute16_o              in varchar2
 ,p_edd_attribute17_o              in varchar2
 ,p_edd_attribute18_o              in varchar2
 ,p_edd_attribute19_o              in varchar2
 ,p_edd_attribute20_o              in varchar2
 ,p_edd_attribute21_o              in varchar2
 ,p_edd_attribute22_o              in varchar2
 ,p_edd_attribute23_o              in varchar2
 ,p_edd_attribute24_o              in varchar2
 ,p_edd_attribute25_o              in varchar2
 ,p_edd_attribute26_o              in varchar2
 ,p_edd_attribute27_o              in varchar2
 ,p_edd_attribute28_o              in varchar2
 ,p_edd_attribute29_o              in varchar2
 ,p_edd_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_edd_rku;

 

/