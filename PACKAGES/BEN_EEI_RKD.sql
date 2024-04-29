--------------------------------------------------------
--  DDL for Package BEN_EEI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EEI_RKD" AUTHID CURRENT_USER as
/* $Header: beeeirhi.pkh 120.0 2005/05/28 02:04:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_enrld_anthr_oipl_id       in number
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
 ,p_oipl_id_o                      in number
 ,p_eligy_prfl_id_o                in number
 ,p_eei_attribute_category_o       in varchar2
 ,p_eei_attribute1_o               in varchar2
 ,p_eei_attribute2_o               in varchar2
 ,p_eei_attribute3_o               in varchar2
 ,p_eei_attribute4_o               in varchar2
 ,p_eei_attribute5_o               in varchar2
 ,p_eei_attribute6_o               in varchar2
 ,p_eei_attribute7_o               in varchar2
 ,p_eei_attribute8_o               in varchar2
 ,p_eei_attribute9_o               in varchar2
 ,p_eei_attribute10_o              in varchar2
 ,p_eei_attribute11_o              in varchar2
 ,p_eei_attribute12_o              in varchar2
 ,p_eei_attribute13_o              in varchar2
 ,p_eei_attribute14_o              in varchar2
 ,p_eei_attribute15_o              in varchar2
 ,p_eei_attribute16_o              in varchar2
 ,p_eei_attribute17_o              in varchar2
 ,p_eei_attribute18_o              in varchar2
 ,p_eei_attribute19_o              in varchar2
 ,p_eei_attribute20_o              in varchar2
 ,p_eei_attribute21_o              in varchar2
 ,p_eei_attribute22_o              in varchar2
 ,p_eei_attribute23_o              in varchar2
 ,p_eei_attribute24_o              in varchar2
 ,p_eei_attribute25_o              in varchar2
 ,p_eei_attribute26_o              in varchar2
 ,p_eei_attribute27_o              in varchar2
 ,p_eei_attribute28_o              in varchar2
 ,p_eei_attribute29_o              in varchar2
 ,p_eei_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_eei_rkd;

 

/