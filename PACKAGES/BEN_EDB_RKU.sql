--------------------------------------------------------
--  DDL for Package BEN_EDB_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDB_RKU" AUTHID CURRENT_USER as
/* $Header: beedbrhi.pkh 120.0 2005/05/28 01:56:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_dsbld_prte_id             in number
 ,p_dsbld_cd                       in varchar2
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_edb_attribute_category         in varchar2
 ,p_edb_attribute1                 in varchar2
 ,p_edb_attribute2                 in varchar2
 ,p_edb_attribute3                 in varchar2
 ,p_edb_attribute4                 in varchar2
 ,p_edb_attribute5                 in varchar2
 ,p_edb_attribute6                 in varchar2
 ,p_edb_attribute7                 in varchar2
 ,p_edb_attribute8                 in varchar2
 ,p_edb_attribute9                 in varchar2
 ,p_edb_attribute10                in varchar2
 ,p_edb_attribute11                in varchar2
 ,p_edb_attribute12                in varchar2
 ,p_edb_attribute13                in varchar2
 ,p_edb_attribute14                in varchar2
 ,p_edb_attribute15                in varchar2
 ,p_edb_attribute16                in varchar2
 ,p_edb_attribute17                in varchar2
 ,p_edb_attribute18                in varchar2
 ,p_edb_attribute19                in varchar2
 ,p_edb_attribute20                in varchar2
 ,p_edb_attribute21                in varchar2
 ,p_edb_attribute22                in varchar2
 ,p_edb_attribute23                in varchar2
 ,p_edb_attribute24                in varchar2
 ,p_edb_attribute25                in varchar2
 ,p_edb_attribute26                in varchar2
 ,p_edb_attribute27                in varchar2
 ,p_edb_attribute28                in varchar2
 ,p_edb_attribute29                in varchar2
 ,p_edb_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_dsbld_cd_o                     in varchar2
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_edb_attribute_category_o       in varchar2
 ,p_edb_attribute1_o               in varchar2
 ,p_edb_attribute2_o               in varchar2
 ,p_edb_attribute3_o               in varchar2
 ,p_edb_attribute4_o               in varchar2
 ,p_edb_attribute5_o               in varchar2
 ,p_edb_attribute6_o               in varchar2
 ,p_edb_attribute7_o               in varchar2
 ,p_edb_attribute8_o               in varchar2
 ,p_edb_attribute9_o               in varchar2
 ,p_edb_attribute10_o              in varchar2
 ,p_edb_attribute11_o              in varchar2
 ,p_edb_attribute12_o              in varchar2
 ,p_edb_attribute13_o              in varchar2
 ,p_edb_attribute14_o              in varchar2
 ,p_edb_attribute15_o              in varchar2
 ,p_edb_attribute16_o              in varchar2
 ,p_edb_attribute17_o              in varchar2
 ,p_edb_attribute18_o              in varchar2
 ,p_edb_attribute19_o              in varchar2
 ,p_edb_attribute20_o              in varchar2
 ,p_edb_attribute21_o              in varchar2
 ,p_edb_attribute22_o              in varchar2
 ,p_edb_attribute23_o              in varchar2
 ,p_edb_attribute24_o              in varchar2
 ,p_edb_attribute25_o              in varchar2
 ,p_edb_attribute26_o              in varchar2
 ,p_edb_attribute27_o              in varchar2
 ,p_edb_attribute28_o              in varchar2
 ,p_edb_attribute29_o              in varchar2
 ,p_edb_attribute30_o              in varchar2
 ,p_object_version_number_o  in number
 ,p_criteria_score			      in  number
 ,p_criteria_weight                     in number
 ,p_criteria_score_o                   in  number
 ,p_criteria_weight_o               in number
  );
--
end ben_edb_rku;

 

/
