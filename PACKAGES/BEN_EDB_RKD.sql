--------------------------------------------------------
--  DDL for Package BEN_EDB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDB_RKD" AUTHID CURRENT_USER as
/* $Header: beedbrhi.pkh 120.0 2005/05/28 01:56:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_dsbld_prte_id             in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                   in  number
 ,p_criteria_weight_o                in number
  );
--
end ben_edb_rkd;

 

/