--------------------------------------------------------
--  DDL for Package BEN_CER_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CER_RKU" AUTHID CURRENT_USER as
/* $Header: becerrhi.pkh 120.0 2005/05/28 01:00:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_prtn_eligy_rl_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_prtn_elig_id                   in number
 ,p_formula_id                     in number
 ,p_drvbl_fctr_apls_flag           in varchar2
 ,p_mndtry_flag                    in varchar2
 ,p_ordr_to_aply_num               in number
 ,p_cer_attribute_category         in varchar2
 ,p_cer_attribute1                 in varchar2
 ,p_cer_attribute2                 in varchar2
 ,p_cer_attribute3                 in varchar2
 ,p_cer_attribute4                 in varchar2
 ,p_cer_attribute5                 in varchar2
 ,p_cer_attribute6                 in varchar2
 ,p_cer_attribute7                 in varchar2
 ,p_cer_attribute8                 in varchar2
 ,p_cer_attribute9                 in varchar2
 ,p_cer_attribute10                in varchar2
 ,p_cer_attribute11                in varchar2
 ,p_cer_attribute12                in varchar2
 ,p_cer_attribute13                in varchar2
 ,p_cer_attribute14                in varchar2
 ,p_cer_attribute15                in varchar2
 ,p_cer_attribute16                in varchar2
 ,p_cer_attribute17                in varchar2
 ,p_cer_attribute18                in varchar2
 ,p_cer_attribute19                in varchar2
 ,p_cer_attribute20                in varchar2
 ,p_cer_attribute21                in varchar2
 ,p_cer_attribute22                in varchar2
 ,p_cer_attribute23                in varchar2
 ,p_cer_attribute24                in varchar2
 ,p_cer_attribute25                in varchar2
 ,p_cer_attribute26                in varchar2
 ,p_cer_attribute27                in varchar2
 ,p_cer_attribute28                in varchar2
 ,p_cer_attribute29                in varchar2
 ,p_cer_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_prtn_elig_id_o                 in number
 ,p_formula_id_o                   in number
 ,p_drvbl_fctr_apls_flag_o         in varchar2
 ,p_mndtry_flag_o                  in varchar2
 ,p_ordr_to_aply_num_o             in number
 ,p_cer_attribute_category_o       in varchar2
 ,p_cer_attribute1_o               in varchar2
 ,p_cer_attribute2_o               in varchar2
 ,p_cer_attribute3_o               in varchar2
 ,p_cer_attribute4_o               in varchar2
 ,p_cer_attribute5_o               in varchar2
 ,p_cer_attribute6_o               in varchar2
 ,p_cer_attribute7_o               in varchar2
 ,p_cer_attribute8_o               in varchar2
 ,p_cer_attribute9_o               in varchar2
 ,p_cer_attribute10_o              in varchar2
 ,p_cer_attribute11_o              in varchar2
 ,p_cer_attribute12_o              in varchar2
 ,p_cer_attribute13_o              in varchar2
 ,p_cer_attribute14_o              in varchar2
 ,p_cer_attribute15_o              in varchar2
 ,p_cer_attribute16_o              in varchar2
 ,p_cer_attribute17_o              in varchar2
 ,p_cer_attribute18_o              in varchar2
 ,p_cer_attribute19_o              in varchar2
 ,p_cer_attribute20_o              in varchar2
 ,p_cer_attribute21_o              in varchar2
 ,p_cer_attribute22_o              in varchar2
 ,p_cer_attribute23_o              in varchar2
 ,p_cer_attribute24_o              in varchar2
 ,p_cer_attribute25_o              in varchar2
 ,p_cer_attribute26_o              in varchar2
 ,p_cer_attribute27_o              in varchar2
 ,p_cer_attribute28_o              in varchar2
 ,p_cer_attribute29_o              in varchar2
 ,p_cer_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cer_rku;

 

/