--------------------------------------------------------
--  DDL for Package BEN_ESA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ESA_RKU" AUTHID CURRENT_USER as
/* $Header: beesarhi.pkh 120.0 2005/05/28 02:54:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_svc_area_prte_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_svc_area_id                    in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_esa_attribute_category         in varchar2
 ,p_esa_attribute1                 in varchar2
 ,p_esa_attribute2                 in varchar2
 ,p_esa_attribute3                 in varchar2
 ,p_esa_attribute4                 in varchar2
 ,p_esa_attribute5                 in varchar2
 ,p_esa_attribute6                 in varchar2
 ,p_esa_attribute7                 in varchar2
 ,p_esa_attribute8                 in varchar2
 ,p_esa_attribute9                 in varchar2
 ,p_esa_attribute10                in varchar2
 ,p_esa_attribute11                in varchar2
 ,p_esa_attribute12                in varchar2
 ,p_esa_attribute13                in varchar2
 ,p_esa_attribute14                in varchar2
 ,p_esa_attribute15                in varchar2
 ,p_esa_attribute16                in varchar2
 ,p_esa_attribute17                in varchar2
 ,p_esa_attribute18                in varchar2
 ,p_esa_attribute19                in varchar2
 ,p_esa_attribute20                in varchar2
 ,p_esa_attribute21                in varchar2
 ,p_esa_attribute22                in varchar2
 ,p_esa_attribute23                in varchar2
 ,p_esa_attribute24                in varchar2
 ,p_esa_attribute25                in varchar2
 ,p_esa_attribute26                in varchar2
 ,p_esa_attribute27                in varchar2
 ,p_esa_attribute28                in varchar2
 ,p_esa_attribute29                in varchar2
 ,p_esa_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_svc_area_id_o                  in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_esa_attribute_category_o       in varchar2
 ,p_esa_attribute1_o               in varchar2
 ,p_esa_attribute2_o               in varchar2
 ,p_esa_attribute3_o               in varchar2
 ,p_esa_attribute4_o               in varchar2
 ,p_esa_attribute5_o               in varchar2
 ,p_esa_attribute6_o               in varchar2
 ,p_esa_attribute7_o               in varchar2
 ,p_esa_attribute8_o               in varchar2
 ,p_esa_attribute9_o               in varchar2
 ,p_esa_attribute10_o              in varchar2
 ,p_esa_attribute11_o              in varchar2
 ,p_esa_attribute12_o              in varchar2
 ,p_esa_attribute13_o              in varchar2
 ,p_esa_attribute14_o              in varchar2
 ,p_esa_attribute15_o              in varchar2
 ,p_esa_attribute16_o              in varchar2
 ,p_esa_attribute17_o              in varchar2
 ,p_esa_attribute18_o              in varchar2
 ,p_esa_attribute19_o              in varchar2
 ,p_esa_attribute20_o              in varchar2
 ,p_esa_attribute21_o              in varchar2
 ,p_esa_attribute22_o              in varchar2
 ,p_esa_attribute23_o              in varchar2
 ,p_esa_attribute24_o              in varchar2
 ,p_esa_attribute25_o              in varchar2
 ,p_esa_attribute26_o              in varchar2
 ,p_esa_attribute27_o              in varchar2
 ,p_esa_attribute28_o              in varchar2
 ,p_esa_attribute29_o              in varchar2
 ,p_esa_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_esa_rku;

 

/
