--------------------------------------------------------
--  DDL for Package BEN_EGR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EGR_RKD" AUTHID CURRENT_USER as
/* $Header: beegrrhi.pkh 120.1 2006/02/21 03:57:04 sturlapa noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_grd_prte_id               in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_grade_id_o                     in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_egr_attribute_category_o       in varchar2
 ,p_egr_attribute1_o               in varchar2
 ,p_egr_attribute2_o               in varchar2
 ,p_egr_attribute3_o               in varchar2
 ,p_egr_attribute4_o               in varchar2
 ,p_egr_attribute5_o               in varchar2
 ,p_egr_attribute6_o               in varchar2
 ,p_egr_attribute7_o               in varchar2
 ,p_egr_attribute8_o               in varchar2
 ,p_egr_attribute9_o               in varchar2
 ,p_egr_attribute10_o              in varchar2
 ,p_egr_attribute11_o              in varchar2
 ,p_egr_attribute12_o              in varchar2
 ,p_egr_attribute13_o              in varchar2
 ,p_egr_attribute14_o              in varchar2
 ,p_egr_attribute15_o              in varchar2
 ,p_egr_attribute16_o              in varchar2
 ,p_egr_attribute17_o              in varchar2
 ,p_egr_attribute18_o              in varchar2
 ,p_egr_attribute19_o              in varchar2
 ,p_egr_attribute20_o              in varchar2
 ,p_egr_attribute21_o              in varchar2
 ,p_egr_attribute22_o              in varchar2
 ,p_egr_attribute23_o              in varchar2
 ,p_egr_attribute24_o              in varchar2
 ,p_egr_attribute25_o              in varchar2
 ,p_egr_attribute26_o              in varchar2
 ,p_egr_attribute27_o              in varchar2
 ,p_egr_attribute28_o              in varchar2
 ,p_egr_attribute29_o              in varchar2
 ,p_egr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_egr_rkd;

 

/
