--------------------------------------------------------
--  DDL for Package BEN_ABP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABP_RKU" AUTHID CURRENT_USER as
/* $Header: beabprhi.pkh 120.0.12010000.1 2008/07/29 10:47:12 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_aplcn_to_bnft_pool_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_acty_base_rt_id                in number
 ,p_bnft_prvdr_pool_id             in number
 ,p_business_group_id              in number
 ,p_abp_attribute_category         in varchar2
 ,p_abp_attribute1                 in varchar2
 ,p_abp_attribute2                 in varchar2
 ,p_abp_attribute3                 in varchar2
 ,p_abp_attribute4                 in varchar2
 ,p_abp_attribute5                 in varchar2
 ,p_abp_attribute6                 in varchar2
 ,p_abp_attribute7                 in varchar2
 ,p_abp_attribute8                 in varchar2
 ,p_abp_attribute9                 in varchar2
 ,p_abp_attribute10                in varchar2
 ,p_abp_attribute11                in varchar2
 ,p_abp_attribute12                in varchar2
 ,p_abp_attribute13                in varchar2
 ,p_abp_attribute14                in varchar2
 ,p_abp_attribute15                in varchar2
 ,p_abp_attribute16                in varchar2
 ,p_abp_attribute17                in varchar2
 ,p_abp_attribute18                in varchar2
 ,p_abp_attribute19                in varchar2
 ,p_abp_attribute20                in varchar2
 ,p_abp_attribute21                in varchar2
 ,p_abp_attribute22                in varchar2
 ,p_abp_attribute23                in varchar2
 ,p_abp_attribute24                in varchar2
 ,p_abp_attribute25                in varchar2
 ,p_abp_attribute26                in varchar2
 ,p_abp_attribute27                in varchar2
 ,p_abp_attribute28                in varchar2
 ,p_abp_attribute29                in varchar2
 ,p_abp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_acty_base_rt_id_o              in number
 ,p_bnft_prvdr_pool_id_o           in number
 ,p_business_group_id_o            in number
 ,p_abp_attribute_category_o       in varchar2
 ,p_abp_attribute1_o               in varchar2
 ,p_abp_attribute2_o               in varchar2
 ,p_abp_attribute3_o               in varchar2
 ,p_abp_attribute4_o               in varchar2
 ,p_abp_attribute5_o               in varchar2
 ,p_abp_attribute6_o               in varchar2
 ,p_abp_attribute7_o               in varchar2
 ,p_abp_attribute8_o               in varchar2
 ,p_abp_attribute9_o               in varchar2
 ,p_abp_attribute10_o              in varchar2
 ,p_abp_attribute11_o              in varchar2
 ,p_abp_attribute12_o              in varchar2
 ,p_abp_attribute13_o              in varchar2
 ,p_abp_attribute14_o              in varchar2
 ,p_abp_attribute15_o              in varchar2
 ,p_abp_attribute16_o              in varchar2
 ,p_abp_attribute17_o              in varchar2
 ,p_abp_attribute18_o              in varchar2
 ,p_abp_attribute19_o              in varchar2
 ,p_abp_attribute20_o              in varchar2
 ,p_abp_attribute21_o              in varchar2
 ,p_abp_attribute22_o              in varchar2
 ,p_abp_attribute23_o              in varchar2
 ,p_abp_attribute24_o              in varchar2
 ,p_abp_attribute25_o              in varchar2
 ,p_abp_attribute26_o              in varchar2
 ,p_abp_attribute27_o              in varchar2
 ,p_abp_attribute28_o              in varchar2
 ,p_abp_attribute29_o              in varchar2
 ,p_abp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_abp_rku;

/
