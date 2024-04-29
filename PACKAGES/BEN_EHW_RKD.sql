--------------------------------------------------------
--  DDL for Package BEN_EHW_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EHW_RKD" AUTHID CURRENT_USER as
/* $Header: beehwrhi.pkh 120.0 2005/05/28 02:15:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_hrs_wkd_prte_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_hrs_wkd_in_perd_fctr_id_o      in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_ehw_attribute_category_o       in varchar2
 ,p_ehw_attribute1_o               in varchar2
 ,p_ehw_attribute2_o               in varchar2
 ,p_ehw_attribute3_o               in varchar2
 ,p_ehw_attribute4_o               in varchar2
 ,p_ehw_attribute5_o               in varchar2
 ,p_ehw_attribute6_o               in varchar2
 ,p_ehw_attribute7_o               in varchar2
 ,p_ehw_attribute8_o               in varchar2
 ,p_ehw_attribute9_o               in varchar2
 ,p_ehw_attribute10_o              in varchar2
 ,p_ehw_attribute11_o              in varchar2
 ,p_ehw_attribute12_o              in varchar2
 ,p_ehw_attribute13_o              in varchar2
 ,p_ehw_attribute14_o              in varchar2
 ,p_ehw_attribute15_o              in varchar2
 ,p_ehw_attribute16_o              in varchar2
 ,p_ehw_attribute17_o              in varchar2
 ,p_ehw_attribute18_o              in varchar2
 ,p_ehw_attribute19_o              in varchar2
 ,p_ehw_attribute20_o              in varchar2
 ,p_ehw_attribute21_o              in varchar2
 ,p_ehw_attribute22_o              in varchar2
 ,p_ehw_attribute23_o              in varchar2
 ,p_ehw_attribute24_o              in varchar2
 ,p_ehw_attribute25_o              in varchar2
 ,p_ehw_attribute26_o              in varchar2
 ,p_ehw_attribute27_o              in varchar2
 ,p_ehw_attribute28_o              in varchar2
 ,p_ehw_attribute29_o              in varchar2
 ,p_ehw_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_ehw_rkd;

 

/
