--------------------------------------------------------
--  DDL for Package BEN_VEP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VEP_RKD" AUTHID CURRENT_USER as
/* $Header: beveprhi.pkh 120.0.12010000.1 2008/07/29 13:06:44 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_vrbl_rt_elig_prfl_id                     in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_vrbl_rt_prfl_id_o            in number
  ,p_eligy_prfl_id_o              in number
  ,p_mndtry_flag_o                in varchar2
  ,p_vep_attribute_category_o     in varchar2
  ,p_vep_attribute1_o             in varchar2
  ,p_vep_attribute2_o             in varchar2
  ,p_vep_attribute3_o             in varchar2
  ,p_vep_attribute4_o             in varchar2
  ,p_vep_attribute5_o             in varchar2
  ,p_vep_attribute6_o             in varchar2
  ,p_vep_attribute7_o             in varchar2
  ,p_vep_attribute8_o             in varchar2
  ,p_vep_attribute9_o             in varchar2
  ,p_vep_attribute10_o            in varchar2
  ,p_vep_attribute11_o            in varchar2
  ,p_vep_attribute12_o            in varchar2
  ,p_vep_attribute13_o            in varchar2
  ,p_vep_attribute14_o            in varchar2
  ,p_vep_attribute15_o            in varchar2
  ,p_vep_attribute16_o            in varchar2
  ,p_vep_attribute17_o            in varchar2
  ,p_vep_attribute18_o            in varchar2
  ,p_vep_attribute19_o            in varchar2
  ,p_vep_attribute20_o            in varchar2
  ,p_vep_attribute21_o            in varchar2
  ,p_vep_attribute22_o            in varchar2
  ,p_vep_attribute23_o            in varchar2
  ,p_vep_attribute24_o            in varchar2
  ,p_vep_attribute25_o            in varchar2
  ,p_vep_attribute26_o            in varchar2
  ,p_vep_attribute27_o            in varchar2
  ,p_vep_attribute28_o            in varchar2
  ,p_vep_attribute29_o            in varchar2
  ,p_vep_attribute30_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_vep_rkd;

/
