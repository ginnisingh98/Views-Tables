--------------------------------------------------------
--  DDL for Package BEN_EPN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPN_RKD" AUTHID CURRENT_USER as
/* $Header: beepnrhi.pkh 120.0 2005/05/28 02:41:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_prbtn_perd_prte_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_probation_period_o             in number
 ,p_probation_unit_o               in varchar2
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_epn_attribute_category_o       in varchar2
 ,p_epn_attribute1_o               in varchar2
 ,p_epn_attribute2_o               in varchar2
 ,p_epn_attribute3_o               in varchar2
 ,p_epn_attribute4_o               in varchar2
 ,p_epn_attribute5_o               in varchar2
 ,p_epn_attribute6_o               in varchar2
 ,p_epn_attribute7_o               in varchar2
 ,p_epn_attribute8_o               in varchar2
 ,p_epn_attribute9_o               in varchar2
 ,p_epn_attribute10_o              in varchar2
 ,p_epn_attribute11_o              in varchar2
 ,p_epn_attribute12_o              in varchar2
 ,p_epn_attribute13_o              in varchar2
 ,p_epn_attribute14_o              in varchar2
 ,p_epn_attribute15_o              in varchar2
 ,p_epn_attribute16_o              in varchar2
 ,p_epn_attribute17_o              in varchar2
 ,p_epn_attribute18_o              in varchar2
 ,p_epn_attribute19_o              in varchar2
 ,p_epn_attribute20_o              in varchar2
 ,p_epn_attribute21_o              in varchar2
 ,p_epn_attribute22_o              in varchar2
 ,p_epn_attribute23_o              in varchar2
 ,p_epn_attribute24_o              in varchar2
 ,p_epn_attribute25_o              in varchar2
 ,p_epn_attribute26_o              in varchar2
 ,p_epn_attribute27_o              in varchar2
 ,p_epn_attribute28_o              in varchar2
 ,p_epn_attribute29_o              in varchar2
 ,p_epn_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_epn_rkd;

 

/