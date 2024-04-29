--------------------------------------------------------
--  DDL for Package BEN_EOY_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EOY_RKD" AUTHID CURRENT_USER as
/* $Header: beeoyrhi.pkh 120.0 2005/05/28 02:34:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_othr_ptip_prte_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_only_pls_subj_cobra_flag_o     in varchar2
 ,p_eligy_prfl_id_o                in number
 ,p_ptip_id_o                      in number
 ,p_business_group_id_o            in number
 ,p_eoy_attribute_category_o       in varchar2
 ,p_eoy_attribute1_o               in varchar2
 ,p_eoy_attribute2_o               in varchar2
 ,p_eoy_attribute3_o               in varchar2
 ,p_eoy_attribute4_o               in varchar2
 ,p_eoy_attribute5_o               in varchar2
 ,p_eoy_attribute6_o               in varchar2
 ,p_eoy_attribute7_o               in varchar2
 ,p_eoy_attribute8_o               in varchar2
 ,p_eoy_attribute9_o               in varchar2
 ,p_eoy_attribute10_o              in varchar2
 ,p_eoy_attribute11_o              in varchar2
 ,p_eoy_attribute12_o              in varchar2
 ,p_eoy_attribute13_o              in varchar2
 ,p_eoy_attribute14_o              in varchar2
 ,p_eoy_attribute15_o              in varchar2
 ,p_eoy_attribute16_o              in varchar2
 ,p_eoy_attribute17_o              in varchar2
 ,p_eoy_attribute18_o              in varchar2
 ,p_eoy_attribute19_o              in varchar2
 ,p_eoy_attribute20_o              in varchar2
 ,p_eoy_attribute21_o              in varchar2
 ,p_eoy_attribute22_o              in varchar2
 ,p_eoy_attribute23_o              in varchar2
 ,p_eoy_attribute24_o              in varchar2
 ,p_eoy_attribute25_o              in varchar2
 ,p_eoy_attribute26_o              in varchar2
 ,p_eoy_attribute27_o              in varchar2
 ,p_eoy_attribute28_o              in varchar2
 ,p_eoy_attribute29_o              in varchar2
 ,p_eoy_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_eoy_rkd;

 

/
