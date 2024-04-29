--------------------------------------------------------
--  DDL for Package BEN_EAP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EAP_RKU" AUTHID CURRENT_USER as
/* $Header: beeaprhi.pkh 120.0 2005/05/28 01:45:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_age_prte_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_age_fctr_id                    in number
 ,p_eligy_prfl_id                  in number
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_eap_attribute_category         in varchar2
 ,p_eap_attribute1                 in varchar2
 ,p_eap_attribute2                 in varchar2
 ,p_eap_attribute3                 in varchar2
 ,p_eap_attribute4                 in varchar2
 ,p_eap_attribute5                 in varchar2
 ,p_eap_attribute6                 in varchar2
 ,p_eap_attribute7                 in varchar2
 ,p_eap_attribute8                 in varchar2
 ,p_eap_attribute9                 in varchar2
 ,p_eap_attribute10                in varchar2
 ,p_eap_attribute11                in varchar2
 ,p_eap_attribute12                in varchar2
 ,p_eap_attribute13                in varchar2
 ,p_eap_attribute14                in varchar2
 ,p_eap_attribute15                in varchar2
 ,p_eap_attribute16                in varchar2
 ,p_eap_attribute17                in varchar2
 ,p_eap_attribute18                in varchar2
 ,p_eap_attribute19                in varchar2
 ,p_eap_attribute20                in varchar2
 ,p_eap_attribute21                in varchar2
 ,p_eap_attribute22                in varchar2
 ,p_eap_attribute23                in varchar2
 ,p_eap_attribute24                in varchar2
 ,p_eap_attribute25                in varchar2
 ,p_eap_attribute26                in varchar2
 ,p_eap_attribute27                in varchar2
 ,p_eap_attribute28                in varchar2
 ,p_eap_attribute29                in varchar2
 ,p_eap_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_age_fctr_id_o                  in number
 ,p_eligy_prfl_id_o                in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_eap_attribute_category_o       in varchar2
 ,p_eap_attribute1_o               in varchar2
 ,p_eap_attribute2_o               in varchar2
 ,p_eap_attribute3_o               in varchar2
 ,p_eap_attribute4_o               in varchar2
 ,p_eap_attribute5_o               in varchar2
 ,p_eap_attribute6_o               in varchar2
 ,p_eap_attribute7_o               in varchar2
 ,p_eap_attribute8_o               in varchar2
 ,p_eap_attribute9_o               in varchar2
 ,p_eap_attribute10_o              in varchar2
 ,p_eap_attribute11_o              in varchar2
 ,p_eap_attribute12_o              in varchar2
 ,p_eap_attribute13_o              in varchar2
 ,p_eap_attribute14_o              in varchar2
 ,p_eap_attribute15_o              in varchar2
 ,p_eap_attribute16_o              in varchar2
 ,p_eap_attribute17_o              in varchar2
 ,p_eap_attribute18_o              in varchar2
 ,p_eap_attribute19_o              in varchar2
 ,p_eap_attribute20_o              in varchar2
 ,p_eap_attribute21_o              in varchar2
 ,p_eap_attribute22_o              in varchar2
 ,p_eap_attribute23_o              in varchar2
 ,p_eap_attribute24_o              in varchar2
 ,p_eap_attribute25_o              in varchar2
 ,p_eap_attribute26_o              in varchar2
 ,p_eap_attribute27_o              in varchar2
 ,p_eap_attribute28_o              in varchar2
 ,p_eap_attribute29_o              in varchar2
 ,p_eap_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_eap_rku;

 

/
