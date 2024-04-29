--------------------------------------------------------
--  DDL for Package BEN_CMR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMR_RKU" AUTHID CURRENT_USER as
/* $Header: becmrrhi.pkh 120.0 2005/05/28 01:07:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_cmbn_age_los_rt_id             in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_vrbl_rt_prfl_id                in number
 ,p_cmbn_age_los_fctr_id           in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_business_group_id              in number
 ,p_cmr_attribute_category         in varchar2
 ,p_cmr_attribute1                 in varchar2
 ,p_cmr_attribute2                 in varchar2
 ,p_cmr_attribute3                 in varchar2
 ,p_cmr_attribute4                 in varchar2
 ,p_cmr_attribute5                 in varchar2
 ,p_cmr_attribute6                 in varchar2
 ,p_cmr_attribute7                 in varchar2
 ,p_cmr_attribute8                 in varchar2
 ,p_cmr_attribute9                 in varchar2
 ,p_cmr_attribute10                in varchar2
 ,p_cmr_attribute11                in varchar2
 ,p_cmr_attribute12                in varchar2
 ,p_cmr_attribute13                in varchar2
 ,p_cmr_attribute14                in varchar2
 ,p_cmr_attribute15                in varchar2
 ,p_cmr_attribute16                in varchar2
 ,p_cmr_attribute17                in varchar2
 ,p_cmr_attribute18                in varchar2
 ,p_cmr_attribute19                in varchar2
 ,p_cmr_attribute20                in varchar2
 ,p_cmr_attribute21                in varchar2
 ,p_cmr_attribute22                in varchar2
 ,p_cmr_attribute23                in varchar2
 ,p_cmr_attribute24                in varchar2
 ,p_cmr_attribute25                in varchar2
 ,p_cmr_attribute26                in varchar2
 ,p_cmr_attribute27                in varchar2
 ,p_cmr_attribute28                in varchar2
 ,p_cmr_attribute29                in varchar2
 ,p_cmr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_cmbn_age_los_fctr_id_o         in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_business_group_id_o            in number
 ,p_cmr_attribute_category_o       in varchar2
 ,p_cmr_attribute1_o               in varchar2
 ,p_cmr_attribute2_o               in varchar2
 ,p_cmr_attribute3_o               in varchar2
 ,p_cmr_attribute4_o               in varchar2
 ,p_cmr_attribute5_o               in varchar2
 ,p_cmr_attribute6_o               in varchar2
 ,p_cmr_attribute7_o               in varchar2
 ,p_cmr_attribute8_o               in varchar2
 ,p_cmr_attribute9_o               in varchar2
 ,p_cmr_attribute10_o              in varchar2
 ,p_cmr_attribute11_o              in varchar2
 ,p_cmr_attribute12_o              in varchar2
 ,p_cmr_attribute13_o              in varchar2
 ,p_cmr_attribute14_o              in varchar2
 ,p_cmr_attribute15_o              in varchar2
 ,p_cmr_attribute16_o              in varchar2
 ,p_cmr_attribute17_o              in varchar2
 ,p_cmr_attribute18_o              in varchar2
 ,p_cmr_attribute19_o              in varchar2
 ,p_cmr_attribute20_o              in varchar2
 ,p_cmr_attribute21_o              in varchar2
 ,p_cmr_attribute22_o              in varchar2
 ,p_cmr_attribute23_o              in varchar2
 ,p_cmr_attribute24_o              in varchar2
 ,p_cmr_attribute25_o              in varchar2
 ,p_cmr_attribute26_o              in varchar2
 ,p_cmr_attribute27_o              in varchar2
 ,p_cmr_attribute28_o              in varchar2
 ,p_cmr_attribute29_o              in varchar2
 ,p_cmr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cmr_rku;

 

/
