--------------------------------------------------------
--  DDL for Package BEN_CEP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CEP_RKD" AUTHID CURRENT_USER as
/* $Header: beceprhi.pkh 120.0 2005/05/28 01:00:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_prtn_elig_prfl_id              in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_mndtry_flag_o                  in varchar2
 ,p_prtn_elig_id_o                 in number
 ,p_eligy_prfl_id_o                in number
 ,p_Elig_prfl_type_cd_o            in  varchar2
 ,p_cep_attribute_category_o       in varchar2
 ,p_cep_attribute1_o               in varchar2
 ,p_cep_attribute2_o               in varchar2
 ,p_cep_attribute3_o               in varchar2
 ,p_cep_attribute4_o               in varchar2
 ,p_cep_attribute5_o               in varchar2
 ,p_cep_attribute6_o               in varchar2
 ,p_cep_attribute7_o               in varchar2
 ,p_cep_attribute8_o               in varchar2
 ,p_cep_attribute9_o               in varchar2
 ,p_cep_attribute10_o              in varchar2
 ,p_cep_attribute11_o              in varchar2
 ,p_cep_attribute12_o              in varchar2
 ,p_cep_attribute13_o              in varchar2
 ,p_cep_attribute14_o              in varchar2
 ,p_cep_attribute15_o              in varchar2
 ,p_cep_attribute16_o              in varchar2
 ,p_cep_attribute17_o              in varchar2
 ,p_cep_attribute18_o              in varchar2
 ,p_cep_attribute19_o              in varchar2
 ,p_cep_attribute20_o              in varchar2
 ,p_cep_attribute21_o              in varchar2
 ,p_cep_attribute22_o              in varchar2
 ,p_cep_attribute23_o              in varchar2
 ,p_cep_attribute24_o              in varchar2
 ,p_cep_attribute25_o              in varchar2
 ,p_cep_attribute26_o              in varchar2
 ,p_cep_attribute27_o              in varchar2
 ,p_cep_attribute28_o              in varchar2
 ,p_cep_attribute29_o              in varchar2
 ,p_cep_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_compute_score_flag_o           in varchar2
  );
--
end ben_CEP_rkd;

 

/
