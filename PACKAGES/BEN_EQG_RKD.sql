--------------------------------------------------------
--  DDL for Package BEN_EQG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EQG_RKD" AUTHID CURRENT_USER as
/* $Header: beeqgrhi.pkh 120.0 2005/05/28 02:49:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ELIG_QUA_IN_GR_PRTE_id             in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_quar_in_grade_cd_o                     in varchar2
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_eqg_attribute_category_o       in varchar2
 ,p_eqg_attribute1_o               in varchar2
 ,p_eqg_attribute2_o               in varchar2
 ,p_eqg_attribute3_o               in varchar2
 ,p_eqg_attribute4_o               in varchar2
 ,p_eqg_attribute5_o               in varchar2
 ,p_eqg_attribute6_o               in varchar2
 ,p_eqg_attribute7_o               in varchar2
 ,p_eqg_attribute8_o               in varchar2
 ,p_eqg_attribute9_o               in varchar2
 ,p_eqg_attribute10_o              in varchar2
 ,p_eqg_attribute11_o              in varchar2
 ,p_eqg_attribute12_o              in varchar2
 ,p_eqg_attribute13_o              in varchar2
 ,p_eqg_attribute14_o              in varchar2
 ,p_eqg_attribute15_o              in varchar2
 ,p_eqg_attribute16_o              in varchar2
 ,p_eqg_attribute17_o              in varchar2
 ,p_eqg_attribute18_o              in varchar2
 ,p_eqg_attribute19_o              in varchar2
 ,p_eqg_attribute20_o              in varchar2
 ,p_eqg_attribute21_o              in varchar2
 ,p_eqg_attribute22_o              in varchar2
 ,p_eqg_attribute23_o              in varchar2
 ,p_eqg_attribute24_o              in varchar2
 ,p_eqg_attribute25_o              in varchar2
 ,p_eqg_attribute26_o              in varchar2
 ,p_eqg_attribute27_o              in varchar2
 ,p_eqg_attribute28_o              in varchar2
 ,p_eqg_attribute29_o              in varchar2
 ,p_eqg_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_eqg_rkd;

 

/
