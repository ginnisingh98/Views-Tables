--------------------------------------------------------
--  DDL for Package BEN_EAN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EAN_RKD" AUTHID CURRENT_USER as
/* $Header: beeanrhi.pkh 120.0 2005/05/28 01:43:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_asnt_set_prte_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_assignment_set_id_o            in number
 ,p_ordr_num_o                     in number
 ,p_eligy_prfl_id_o                in number
 ,p_excld_flag_o                   in varchar2
 ,p_ean_attribute_category_o       in varchar2
 ,p_ean_attribute1_o               in varchar2
 ,p_ean_attribute2_o               in varchar2
 ,p_ean_attribute3_o               in varchar2
 ,p_ean_attribute4_o               in varchar2
 ,p_ean_attribute5_o               in varchar2
 ,p_ean_attribute6_o               in varchar2
 ,p_ean_attribute7_o               in varchar2
 ,p_ean_attribute8_o               in varchar2
 ,p_ean_attribute9_o               in varchar2
 ,p_ean_attribute10_o              in varchar2
 ,p_ean_attribute11_o              in varchar2
 ,p_ean_attribute12_o              in varchar2
 ,p_ean_attribute13_o              in varchar2
 ,p_ean_attribute14_o              in varchar2
 ,p_ean_attribute15_o              in varchar2
 ,p_ean_attribute16_o              in varchar2
 ,p_ean_attribute17_o              in varchar2
 ,p_ean_attribute18_o              in varchar2
 ,p_ean_attribute19_o              in varchar2
 ,p_ean_attribute20_o              in varchar2
 ,p_ean_attribute21_o              in varchar2
 ,p_ean_attribute22_o              in varchar2
 ,p_ean_attribute23_o              in varchar2
 ,p_ean_attribute24_o              in varchar2
 ,p_ean_attribute25_o              in varchar2
 ,p_ean_attribute26_o              in varchar2
 ,p_ean_attribute27_o              in varchar2
 ,p_ean_attribute28_o              in varchar2
 ,p_ean_attribute29_o              in varchar2
 ,p_ean_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_ean_rkd;

 

/
