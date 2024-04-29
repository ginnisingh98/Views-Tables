--------------------------------------------------------
--  DDL for Package BEN_EES_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EES_RKD" AUTHID CURRENT_USER as
/* $Header: beeesrhi.pkh 120.0 2005/05/28 02:06:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_ee_stat_prte_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_assignment_status_type_id_o    in number
 ,p_ees_attribute_category_o       in varchar2
 ,p_ees_attribute1_o               in varchar2
 ,p_ees_attribute2_o               in varchar2
 ,p_ees_attribute3_o               in varchar2
 ,p_ees_attribute4_o               in varchar2
 ,p_ees_attribute5_o               in varchar2
 ,p_ees_attribute6_o               in varchar2
 ,p_ees_attribute7_o               in varchar2
 ,p_ees_attribute8_o               in varchar2
 ,p_ees_attribute9_o               in varchar2
 ,p_ees_attribute10_o              in varchar2
 ,p_ees_attribute11_o              in varchar2
 ,p_ees_attribute12_o              in varchar2
 ,p_ees_attribute13_o              in varchar2
 ,p_ees_attribute14_o              in varchar2
 ,p_ees_attribute15_o              in varchar2
 ,p_ees_attribute16_o              in varchar2
 ,p_ees_attribute17_o              in varchar2
 ,p_ees_attribute18_o              in varchar2
 ,p_ees_attribute19_o              in varchar2
 ,p_ees_attribute20_o              in varchar2
 ,p_ees_attribute21_o              in varchar2
 ,p_ees_attribute22_o              in varchar2
 ,p_ees_attribute23_o              in varchar2
 ,p_ees_attribute24_o              in varchar2
 ,p_ees_attribute25_o              in varchar2
 ,p_ees_attribute26_o              in varchar2
 ,p_ees_attribute27_o              in varchar2
 ,p_ees_attribute28_o              in varchar2
 ,p_ees_attribute29_o              in varchar2
 ,p_ees_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_ees_rkd;

 

/
