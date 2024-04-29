--------------------------------------------------------
--  DDL for Package BEN_EPF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPF_RKU" AUTHID CURRENT_USER as
/* $Header: beepfrhi.pkh 120.0 2005/05/28 02:38:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_pct_fl_tm_prte_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_eligy_prfl_id                  in number
 ,p_pct_fl_tm_fctr_id              in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_epf_attribute_category         in varchar2
 ,p_epf_attribute1                 in varchar2
 ,p_epf_attribute2                 in varchar2
 ,p_epf_attribute3                 in varchar2
 ,p_epf_attribute4                 in varchar2
 ,p_epf_attribute5                 in varchar2
 ,p_epf_attribute6                 in varchar2
 ,p_epf_attribute7                 in varchar2
 ,p_epf_attribute8                 in varchar2
 ,p_epf_attribute9                 in varchar2
 ,p_epf_attribute10                in varchar2
 ,p_epf_attribute11                in varchar2
 ,p_epf_attribute12                in varchar2
 ,p_epf_attribute13                in varchar2
 ,p_epf_attribute14                in varchar2
 ,p_epf_attribute15                in varchar2
 ,p_epf_attribute16                in varchar2
 ,p_epf_attribute17                in varchar2
 ,p_epf_attribute18                in varchar2
 ,p_epf_attribute19                in varchar2
 ,p_epf_attribute20                in varchar2
 ,p_epf_attribute21                in varchar2
 ,p_epf_attribute22                in varchar2
 ,p_epf_attribute23                in varchar2
 ,p_epf_attribute24                in varchar2
 ,p_epf_attribute25                in varchar2
 ,p_epf_attribute26                in varchar2
 ,p_epf_attribute27                in varchar2
 ,p_epf_attribute28                in varchar2
 ,p_epf_attribute29                in varchar2
 ,p_epf_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_pct_fl_tm_fctr_id_o            in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_epf_attribute_category_o       in varchar2
 ,p_epf_attribute1_o               in varchar2
 ,p_epf_attribute2_o               in varchar2
 ,p_epf_attribute3_o               in varchar2
 ,p_epf_attribute4_o               in varchar2
 ,p_epf_attribute5_o               in varchar2
 ,p_epf_attribute6_o               in varchar2
 ,p_epf_attribute7_o               in varchar2
 ,p_epf_attribute8_o               in varchar2
 ,p_epf_attribute9_o               in varchar2
 ,p_epf_attribute10_o              in varchar2
 ,p_epf_attribute11_o              in varchar2
 ,p_epf_attribute12_o              in varchar2
 ,p_epf_attribute13_o              in varchar2
 ,p_epf_attribute14_o              in varchar2
 ,p_epf_attribute15_o              in varchar2
 ,p_epf_attribute16_o              in varchar2
 ,p_epf_attribute17_o              in varchar2
 ,p_epf_attribute18_o              in varchar2
 ,p_epf_attribute19_o              in varchar2
 ,p_epf_attribute20_o              in varchar2
 ,p_epf_attribute21_o              in varchar2
 ,p_epf_attribute22_o              in varchar2
 ,p_epf_attribute23_o              in varchar2
 ,p_epf_attribute24_o              in varchar2
 ,p_epf_attribute25_o              in varchar2
 ,p_epf_attribute26_o              in varchar2
 ,p_epf_attribute27_o              in varchar2
 ,p_epf_attribute28_o              in varchar2
 ,p_epf_attribute29_o              in varchar2
 ,p_epf_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_epf_rku;

 

/
