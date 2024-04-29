--------------------------------------------------------
--  DDL for Package BEN_EPS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPS_RKD" AUTHID CURRENT_USER as
/* $Header: beepsrhi.pkh 120.1 2006/02/21 04:05:21 sturlapa noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_pstn_prte_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_position_id_o                      in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_eps_attribute_category_o       in varchar2
 ,p_eps_attribute1_o               in varchar2
 ,p_eps_attribute2_o               in varchar2
 ,p_eps_attribute3_o               in varchar2
 ,p_eps_attribute4_o               in varchar2
 ,p_eps_attribute5_o               in varchar2
 ,p_eps_attribute6_o               in varchar2
 ,p_eps_attribute7_o               in varchar2
 ,p_eps_attribute8_o               in varchar2
 ,p_eps_attribute9_o               in varchar2
 ,p_eps_attribute10_o              in varchar2
 ,p_eps_attribute11_o              in varchar2
 ,p_eps_attribute12_o              in varchar2
 ,p_eps_attribute13_o              in varchar2
 ,p_eps_attribute14_o              in varchar2
 ,p_eps_attribute15_o              in varchar2
 ,p_eps_attribute16_o              in varchar2
 ,p_eps_attribute17_o              in varchar2
 ,p_eps_attribute18_o              in varchar2
 ,p_eps_attribute19_o              in varchar2
 ,p_eps_attribute20_o              in varchar2
 ,p_eps_attribute21_o              in varchar2
 ,p_eps_attribute22_o              in varchar2
 ,p_eps_attribute23_o              in varchar2
 ,p_eps_attribute24_o              in varchar2
 ,p_eps_attribute25_o              in varchar2
 ,p_eps_attribute26_o              in varchar2
 ,p_eps_attribute27_o              in varchar2
 ,p_eps_attribute28_o              in varchar2
 ,p_eps_attribute29_o              in varchar2
 ,p_eps_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_eps_rkd;

 

/
