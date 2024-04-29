--------------------------------------------------------
--  DDL for Package BEN_EWL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EWL_RKU" AUTHID CURRENT_USER as
/* $Header: beewlrhi.pkh 120.0 2005/05/28 03:05:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_wk_loc_prte_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_ordr_num                       in number
 ,p_location_id                    in number
 ,p_eligy_prfl_id                  in number
 ,p_excld_flag                     in varchar2
 ,p_ewl_attribute_category         in varchar2
 ,p_ewl_attribute1                 in varchar2
 ,p_ewl_attribute2                 in varchar2
 ,p_ewl_attribute3                 in varchar2
 ,p_ewl_attribute4                 in varchar2
 ,p_ewl_attribute5                 in varchar2
 ,p_ewl_attribute6                 in varchar2
 ,p_ewl_attribute7                 in varchar2
 ,p_ewl_attribute8                 in varchar2
 ,p_ewl_attribute9                 in varchar2
 ,p_ewl_attribute10                in varchar2
 ,p_ewl_attribute11                in varchar2
 ,p_ewl_attribute12                in varchar2
 ,p_ewl_attribute13                in varchar2
 ,p_ewl_attribute14                in varchar2
 ,p_ewl_attribute15                in varchar2
 ,p_ewl_attribute16                in varchar2
 ,p_ewl_attribute17                in varchar2
 ,p_ewl_attribute18                in varchar2
 ,p_ewl_attribute19                in varchar2
 ,p_ewl_attribute20                in varchar2
 ,p_ewl_attribute21                in varchar2
 ,p_ewl_attribute22                in varchar2
 ,p_ewl_attribute23                in varchar2
 ,p_ewl_attribute24                in varchar2
 ,p_ewl_attribute25                in varchar2
 ,p_ewl_attribute26                in varchar2
 ,p_ewl_attribute27                in varchar2
 ,p_ewl_attribute28                in varchar2
 ,p_ewl_attribute29                in varchar2
 ,p_ewl_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_ordr_num_o                     in number
 ,p_location_id_o                  in number
 ,p_eligy_prfl_id_o                in number
 ,p_excld_flag_o                   in varchar2
 ,p_ewl_attribute_category_o       in varchar2
 ,p_ewl_attribute1_o               in varchar2
 ,p_ewl_attribute2_o               in varchar2
 ,p_ewl_attribute3_o               in varchar2
 ,p_ewl_attribute4_o               in varchar2
 ,p_ewl_attribute5_o               in varchar2
 ,p_ewl_attribute6_o               in varchar2
 ,p_ewl_attribute7_o               in varchar2
 ,p_ewl_attribute8_o               in varchar2
 ,p_ewl_attribute9_o               in varchar2
 ,p_ewl_attribute10_o              in varchar2
 ,p_ewl_attribute11_o              in varchar2
 ,p_ewl_attribute12_o              in varchar2
 ,p_ewl_attribute13_o              in varchar2
 ,p_ewl_attribute14_o              in varchar2
 ,p_ewl_attribute15_o              in varchar2
 ,p_ewl_attribute16_o              in varchar2
 ,p_ewl_attribute17_o              in varchar2
 ,p_ewl_attribute18_o              in varchar2
 ,p_ewl_attribute19_o              in varchar2
 ,p_ewl_attribute20_o              in varchar2
 ,p_ewl_attribute21_o              in varchar2
 ,p_ewl_attribute22_o              in varchar2
 ,p_ewl_attribute23_o              in varchar2
 ,p_ewl_attribute24_o              in varchar2
 ,p_ewl_attribute25_o              in varchar2
 ,p_ewl_attribute26_o              in varchar2
 ,p_ewl_attribute27_o              in varchar2
 ,p_ewl_attribute28_o              in varchar2
 ,p_ewl_attribute29_o              in varchar2
 ,p_ewl_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_ewl_rku;

 

/
