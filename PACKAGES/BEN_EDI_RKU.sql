--------------------------------------------------------
--  DDL for Package BEN_EDI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDI_RKU" AUTHID CURRENT_USER as
/* $Header: beedirhi.pkh 120.0 2005/05/28 01:59:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_dpnt_cvrd_plip_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_enrl_det_dt_cd                 in varchar2
 ,p_plip_id                        in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_edi_attribute_category         in varchar2
 ,p_edi_attribute1                 in varchar2
 ,p_edi_attribute2                 in varchar2
 ,p_edi_attribute3                 in varchar2
 ,p_edi_attribute4                 in varchar2
 ,p_edi_attribute5                 in varchar2
 ,p_edi_attribute6                 in varchar2
 ,p_edi_attribute7                 in varchar2
 ,p_edi_attribute8                 in varchar2
 ,p_edi_attribute9                 in varchar2
 ,p_edi_attribute10                in varchar2
 ,p_edi_attribute11                in varchar2
 ,p_edi_attribute12                in varchar2
 ,p_edi_attribute13                in varchar2
 ,p_edi_attribute14                in varchar2
 ,p_edi_attribute15                in varchar2
 ,p_edi_attribute16                in varchar2
 ,p_edi_attribute17                in varchar2
 ,p_edi_attribute18                in varchar2
 ,p_edi_attribute19                in varchar2
 ,p_edi_attribute20                in varchar2
 ,p_edi_attribute21                in varchar2
 ,p_edi_attribute22                in varchar2
 ,p_edi_attribute23                in varchar2
 ,p_edi_attribute24                in varchar2
 ,p_edi_attribute25                in varchar2
 ,p_edi_attribute26                in varchar2
 ,p_edi_attribute27                in varchar2
 ,p_edi_attribute28                in varchar2
 ,p_edi_attribute29                in varchar2
 ,p_edi_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_enrl_det_dt_cd_o               in varchar2
 ,p_plip_id_o                      in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_edi_attribute_category_o       in varchar2
 ,p_edi_attribute1_o               in varchar2
 ,p_edi_attribute2_o               in varchar2
 ,p_edi_attribute3_o               in varchar2
 ,p_edi_attribute4_o               in varchar2
 ,p_edi_attribute5_o               in varchar2
 ,p_edi_attribute6_o               in varchar2
 ,p_edi_attribute7_o               in varchar2
 ,p_edi_attribute8_o               in varchar2
 ,p_edi_attribute9_o               in varchar2
 ,p_edi_attribute10_o              in varchar2
 ,p_edi_attribute11_o              in varchar2
 ,p_edi_attribute12_o              in varchar2
 ,p_edi_attribute13_o              in varchar2
 ,p_edi_attribute14_o              in varchar2
 ,p_edi_attribute15_o              in varchar2
 ,p_edi_attribute16_o              in varchar2
 ,p_edi_attribute17_o              in varchar2
 ,p_edi_attribute18_o              in varchar2
 ,p_edi_attribute19_o              in varchar2
 ,p_edi_attribute20_o              in varchar2
 ,p_edi_attribute21_o              in varchar2
 ,p_edi_attribute22_o              in varchar2
 ,p_edi_attribute23_o              in varchar2
 ,p_edi_attribute24_o              in varchar2
 ,p_edi_attribute25_o              in varchar2
 ,p_edi_attribute26_o              in varchar2
 ,p_edi_attribute27_o              in varchar2
 ,p_edi_attribute28_o              in varchar2
 ,p_edi_attribute29_o              in varchar2
 ,p_edi_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_edi_rku;

 

/
