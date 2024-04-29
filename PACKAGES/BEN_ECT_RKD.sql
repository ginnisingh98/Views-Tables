--------------------------------------------------------
--  DDL for Package BEN_ECT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECT_RKD" AUTHID CURRENT_USER as
/* $Header: beectrhi.pkh 120.0 2005/05/28 01:54:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_dsblty_ctg_prte_id        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_category_o                     in varchar2
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_ect_attribute_category_o       in varchar2
 ,p_ect_attribute1_o               in varchar2
 ,p_ect_attribute2_o               in varchar2
 ,p_ect_attribute3_o               in varchar2
 ,p_ect_attribute4_o               in varchar2
 ,p_ect_attribute5_o               in varchar2
 ,p_ect_attribute6_o               in varchar2
 ,p_ect_attribute7_o               in varchar2
 ,p_ect_attribute8_o               in varchar2
 ,p_ect_attribute9_o               in varchar2
 ,p_ect_attribute10_o              in varchar2
 ,p_ect_attribute11_o              in varchar2
 ,p_ect_attribute12_o              in varchar2
 ,p_ect_attribute13_o              in varchar2
 ,p_ect_attribute14_o              in varchar2
 ,p_ect_attribute15_o              in varchar2
 ,p_ect_attribute16_o              in varchar2
 ,p_ect_attribute17_o              in varchar2
 ,p_ect_attribute18_o              in varchar2
 ,p_ect_attribute19_o              in varchar2
 ,p_ect_attribute20_o              in varchar2
 ,p_ect_attribute21_o              in varchar2
 ,p_ect_attribute22_o              in varchar2
 ,p_ect_attribute23_o              in varchar2
 ,p_ect_attribute24_o              in varchar2
 ,p_ect_attribute25_o              in varchar2
 ,p_ect_attribute26_o              in varchar2
 ,p_ect_attribute27_o              in varchar2
 ,p_ect_attribute28_o              in varchar2
 ,p_ect_attribute29_o              in varchar2
 ,p_ect_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_ect_rkd;

 

/
