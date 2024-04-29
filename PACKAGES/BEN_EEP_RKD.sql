--------------------------------------------------------
--  DDL for Package BEN_EEP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EEP_RKD" AUTHID CURRENT_USER as
/* $Header: beeeprhi.pkh 120.0 2005/05/28 02:05:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_enrld_anthr_pl_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_enrl_det_dt_cd_o               in varchar2
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_pl_id_o                        in number
 ,p_eep_attribute_category_o       in varchar2
 ,p_eep_attribute1_o               in varchar2
 ,p_eep_attribute2_o               in varchar2
 ,p_eep_attribute3_o               in varchar2
 ,p_eep_attribute4_o               in varchar2
 ,p_eep_attribute5_o               in varchar2
 ,p_eep_attribute6_o               in varchar2
 ,p_eep_attribute7_o               in varchar2
 ,p_eep_attribute8_o               in varchar2
 ,p_eep_attribute9_o               in varchar2
 ,p_eep_attribute10_o              in varchar2
 ,p_eep_attribute11_o              in varchar2
 ,p_eep_attribute12_o              in varchar2
 ,p_eep_attribute13_o              in varchar2
 ,p_eep_attribute14_o              in varchar2
 ,p_eep_attribute15_o              in varchar2
 ,p_eep_attribute16_o              in varchar2
 ,p_eep_attribute17_o              in varchar2
 ,p_eep_attribute18_o              in varchar2
 ,p_eep_attribute19_o              in varchar2
 ,p_eep_attribute20_o              in varchar2
 ,p_eep_attribute21_o              in varchar2
 ,p_eep_attribute22_o              in varchar2
 ,p_eep_attribute23_o              in varchar2
 ,p_eep_attribute24_o              in varchar2
 ,p_eep_attribute25_o              in varchar2
 ,p_eep_attribute26_o              in varchar2
 ,p_eep_attribute27_o              in varchar2
 ,p_eep_attribute28_o              in varchar2
 ,p_eep_attribute29_o              in varchar2
 ,p_eep_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_eep_rkd;

 

/
