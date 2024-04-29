--------------------------------------------------------
--  DDL for Package BEN_APV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_APV_RKU" AUTHID CURRENT_USER as
/* $Header: beapvrhi.pkh 120.0.12010000.1 2008/07/29 10:51:01 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_actl_prem_vrbl_rt_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_actl_prem_id                   in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_ordr_num                       in number
 ,p_business_group_id              in number
 ,p_apv_attribute_category         in varchar2
 ,p_apv_attribute1                 in varchar2
 ,p_apv_attribute2                 in varchar2
 ,p_apv_attribute3                 in varchar2
 ,p_apv_attribute4                 in varchar2
 ,p_apv_attribute5                 in varchar2
 ,p_apv_attribute6                 in varchar2
 ,p_apv_attribute7                 in varchar2
 ,p_apv_attribute8                 in varchar2
 ,p_apv_attribute9                 in varchar2
 ,p_apv_attribute10                in varchar2
 ,p_apv_attribute11                in varchar2
 ,p_apv_attribute12                in varchar2
 ,p_apv_attribute13                in varchar2
 ,p_apv_attribute14                in varchar2
 ,p_apv_attribute15                in varchar2
 ,p_apv_attribute16                in varchar2
 ,p_apv_attribute17                in varchar2
 ,p_apv_attribute18                in varchar2
 ,p_apv_attribute19                in varchar2
 ,p_apv_attribute20                in varchar2
 ,p_apv_attribute21                in varchar2
 ,p_apv_attribute22                in varchar2
 ,p_apv_attribute23                in varchar2
 ,p_apv_attribute24                in varchar2
 ,p_apv_attribute25                in varchar2
 ,p_apv_attribute26                in varchar2
 ,p_apv_attribute27                in varchar2
 ,p_apv_attribute28                in varchar2
 ,p_apv_attribute29                in varchar2
 ,p_apv_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_actl_prem_id_o                 in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_ordr_num_o                     in number
 ,p_business_group_id_o            in number
 ,p_apv_attribute_category_o       in varchar2
 ,p_apv_attribute1_o               in varchar2
 ,p_apv_attribute2_o               in varchar2
 ,p_apv_attribute3_o               in varchar2
 ,p_apv_attribute4_o               in varchar2
 ,p_apv_attribute5_o               in varchar2
 ,p_apv_attribute6_o               in varchar2
 ,p_apv_attribute7_o               in varchar2
 ,p_apv_attribute8_o               in varchar2
 ,p_apv_attribute9_o               in varchar2
 ,p_apv_attribute10_o              in varchar2
 ,p_apv_attribute11_o              in varchar2
 ,p_apv_attribute12_o              in varchar2
 ,p_apv_attribute13_o              in varchar2
 ,p_apv_attribute14_o              in varchar2
 ,p_apv_attribute15_o              in varchar2
 ,p_apv_attribute16_o              in varchar2
 ,p_apv_attribute17_o              in varchar2
 ,p_apv_attribute18_o              in varchar2
 ,p_apv_attribute19_o              in varchar2
 ,p_apv_attribute20_o              in varchar2
 ,p_apv_attribute21_o              in varchar2
 ,p_apv_attribute22_o              in varchar2
 ,p_apv_attribute23_o              in varchar2
 ,p_apv_attribute24_o              in varchar2
 ,p_apv_attribute25_o              in varchar2
 ,p_apv_attribute26_o              in varchar2
 ,p_apv_attribute27_o              in varchar2
 ,p_apv_attribute28_o              in varchar2
 ,p_apv_attribute29_o              in varchar2
 ,p_apv_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_apv_rku;

/