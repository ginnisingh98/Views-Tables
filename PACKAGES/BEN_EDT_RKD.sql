--------------------------------------------------------
--  DDL for Package BEN_EDT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDT_RKD" AUTHID CURRENT_USER as
/* $Header: beedtrhi.pkh 120.0 2005/05/28 02:02:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_dpnt_cvrd_othr_ptip_id    in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_enrl_det_dt_cd_o               in varchar2
 ,p_only_pls_subj_cobra_flag_o     in varchar2
 ,p_ptip_id_o                      in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_edt_attribute_category_o       in varchar2
 ,p_edt_attribute1_o               in varchar2
 ,p_edt_attribute2_o               in varchar2
 ,p_edt_attribute3_o               in varchar2
 ,p_edt_attribute4_o               in varchar2
 ,p_edt_attribute5_o               in varchar2
 ,p_edt_attribute6_o               in varchar2
 ,p_edt_attribute7_o               in varchar2
 ,p_edt_attribute8_o               in varchar2
 ,p_edt_attribute9_o               in varchar2
 ,p_edt_attribute10_o              in varchar2
 ,p_edt_attribute11_o              in varchar2
 ,p_edt_attribute12_o              in varchar2
 ,p_edt_attribute13_o              in varchar2
 ,p_edt_attribute14_o              in varchar2
 ,p_edt_attribute15_o              in varchar2
 ,p_edt_attribute16_o              in varchar2
 ,p_edt_attribute17_o              in varchar2
 ,p_edt_attribute18_o              in varchar2
 ,p_edt_attribute19_o              in varchar2
 ,p_edt_attribute20_o              in varchar2
 ,p_edt_attribute21_o              in varchar2
 ,p_edt_attribute22_o              in varchar2
 ,p_edt_attribute23_o              in varchar2
 ,p_edt_attribute24_o              in varchar2
 ,p_edt_attribute25_o              in varchar2
 ,p_edt_attribute26_o              in varchar2
 ,p_edt_attribute27_o              in varchar2
 ,p_edt_attribute28_o              in varchar2
 ,p_edt_attribute29_o              in varchar2
 ,p_edt_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_edt_rkd;

 

/
