--------------------------------------------------------
--  DDL for Package BEN_PBR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PBR_RKD" AUTHID CURRENT_USER as
/* $Header: bepbrrhi.pkh 120.0 2005/05/28 10:08:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_py_bss_rt_id                   in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_pay_basis_id_o                 in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_business_group_id_o            in number
 ,p_pbr_attribute_category_o       in varchar2
 ,p_pbr_attribute1_o               in varchar2
 ,p_pbr_attribute2_o               in varchar2
 ,p_pbr_attribute3_o               in varchar2
 ,p_pbr_attribute4_o               in varchar2
 ,p_pbr_attribute5_o               in varchar2
 ,p_pbr_attribute6_o               in varchar2
 ,p_pbr_attribute7_o               in varchar2
 ,p_pbr_attribute8_o               in varchar2
 ,p_pbr_attribute9_o               in varchar2
 ,p_pbr_attribute10_o              in varchar2
 ,p_pbr_attribute11_o              in varchar2
 ,p_pbr_attribute12_o              in varchar2
 ,p_pbr_attribute13_o              in varchar2
 ,p_pbr_attribute14_o              in varchar2
 ,p_pbr_attribute15_o              in varchar2
 ,p_pbr_attribute16_o              in varchar2
 ,p_pbr_attribute17_o              in varchar2
 ,p_pbr_attribute18_o              in varchar2
 ,p_pbr_attribute19_o              in varchar2
 ,p_pbr_attribute20_o              in varchar2
 ,p_pbr_attribute21_o              in varchar2
 ,p_pbr_attribute22_o              in varchar2
 ,p_pbr_attribute23_o              in varchar2
 ,p_pbr_attribute24_o              in varchar2
 ,p_pbr_attribute25_o              in varchar2
 ,p_pbr_attribute26_o              in varchar2
 ,p_pbr_attribute27_o              in varchar2
 ,p_pbr_attribute28_o              in varchar2
 ,p_pbr_attribute29_o              in varchar2
 ,p_pbr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pbr_rkd;

 

/
