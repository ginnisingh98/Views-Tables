--------------------------------------------------------
--  DDL for Package BEN_ECY_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECY_RKD" AUTHID CURRENT_USER as
/* $Header: beecyrhi.pkh 120.0 2005/05/28 01:55:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ELIG_COMPTNCY_PRTE_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_competence_id_o                in number
 ,p_rating_level_id_o              in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_ecy_attribute_category_o       in varchar2
 ,p_ecy_attribute1_o               in varchar2
 ,p_ecy_attribute2_o               in varchar2
 ,p_ecy_attribute3_o               in varchar2
 ,p_ecy_attribute4_o               in varchar2
 ,p_ecy_attribute5_o               in varchar2
 ,p_ecy_attribute6_o               in varchar2
 ,p_ecy_attribute7_o               in varchar2
 ,p_ecy_attribute8_o               in varchar2
 ,p_ecy_attribute9_o               in varchar2
 ,p_ecy_attribute10_o              in varchar2
 ,p_ecy_attribute11_o              in varchar2
 ,p_ecy_attribute12_o              in varchar2
 ,p_ecy_attribute13_o              in varchar2
 ,p_ecy_attribute14_o              in varchar2
 ,p_ecy_attribute15_o              in varchar2
 ,p_ecy_attribute16_o              in varchar2
 ,p_ecy_attribute17_o              in varchar2
 ,p_ecy_attribute18_o              in varchar2
 ,p_ecy_attribute19_o              in varchar2
 ,p_ecy_attribute20_o              in varchar2
 ,p_ecy_attribute21_o              in varchar2
 ,p_ecy_attribute22_o              in varchar2
 ,p_ecy_attribute23_o              in varchar2
 ,p_ecy_attribute24_o              in varchar2
 ,p_ecy_attribute25_o              in varchar2
 ,p_ecy_attribute26_o              in varchar2
 ,p_ecy_attribute27_o              in varchar2
 ,p_ecy_attribute28_o              in varchar2
 ,p_ecy_attribute29_o              in varchar2
 ,p_ecy_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o               in number
 ,p_criteria_weight_o              in number
  );
--
end ben_ecy_rkd;

 

/
