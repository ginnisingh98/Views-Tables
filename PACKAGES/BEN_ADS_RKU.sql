--------------------------------------------------------
--  DDL for Package BEN_ADS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ADS_RKU" AUTHID CURRENT_USER as
/* $Header: beadsrhi.pkh 120.0.12010000.1 2008/07/29 10:48:42 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_acty_rt_ded_sched_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_ded_sched_py_freq_id           in number
 ,p_acty_base_rt_id                in number
 ,p_ded_sched_rl                   in number
 ,p_ded_sched_cd                   in varchar2
 ,p_ads_attribute_category         in varchar2
 ,p_ads_attribute1                 in varchar2
 ,p_ads_attribute2                 in varchar2
 ,p_ads_attribute3                 in varchar2
 ,p_ads_attribute4                 in varchar2
 ,p_ads_attribute5                 in varchar2
 ,p_ads_attribute6                 in varchar2
 ,p_ads_attribute7                 in varchar2
 ,p_ads_attribute8                 in varchar2
 ,p_ads_attribute9                 in varchar2
 ,p_ads_attribute10                in varchar2
 ,p_ads_attribute11                in varchar2
 ,p_ads_attribute12                in varchar2
 ,p_ads_attribute13                in varchar2
 ,p_ads_attribute14                in varchar2
 ,p_ads_attribute15                in varchar2
 ,p_ads_attribute16                in varchar2
 ,p_ads_attribute17                in varchar2
 ,p_ads_attribute18                in varchar2
 ,p_ads_attribute19                in varchar2
 ,p_ads_attribute20                in varchar2
 ,p_ads_attribute21                in varchar2
 ,p_ads_attribute22                in varchar2
 ,p_ads_attribute23                in varchar2
 ,p_ads_attribute24                in varchar2
 ,p_ads_attribute25                in varchar2
 ,p_ads_attribute26                in varchar2
 ,p_ads_attribute27                in varchar2
 ,p_ads_attribute28                in varchar2
 ,p_ads_attribute29                in varchar2
 ,p_ads_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_ded_sched_py_freq_id_o         in number
 ,p_acty_base_rt_id_o              in number
 ,p_ded_sched_rl_o                 in number
 ,p_ded_sched_cd_o                 in varchar2
 ,p_ads_attribute_category_o       in varchar2
 ,p_ads_attribute1_o               in varchar2
 ,p_ads_attribute2_o               in varchar2
 ,p_ads_attribute3_o               in varchar2
 ,p_ads_attribute4_o               in varchar2
 ,p_ads_attribute5_o               in varchar2
 ,p_ads_attribute6_o               in varchar2
 ,p_ads_attribute7_o               in varchar2
 ,p_ads_attribute8_o               in varchar2
 ,p_ads_attribute9_o               in varchar2
 ,p_ads_attribute10_o              in varchar2
 ,p_ads_attribute11_o              in varchar2
 ,p_ads_attribute12_o              in varchar2
 ,p_ads_attribute13_o              in varchar2
 ,p_ads_attribute14_o              in varchar2
 ,p_ads_attribute15_o              in varchar2
 ,p_ads_attribute16_o              in varchar2
 ,p_ads_attribute17_o              in varchar2
 ,p_ads_attribute18_o              in varchar2
 ,p_ads_attribute19_o              in varchar2
 ,p_ads_attribute20_o              in varchar2
 ,p_ads_attribute21_o              in varchar2
 ,p_ads_attribute22_o              in varchar2
 ,p_ads_attribute23_o              in varchar2
 ,p_ads_attribute24_o              in varchar2
 ,p_ads_attribute25_o              in varchar2
 ,p_ads_attribute26_o              in varchar2
 ,p_ads_attribute27_o              in varchar2
 ,p_ads_attribute28_o              in varchar2
 ,p_ads_attribute29_o              in varchar2
 ,p_ads_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ads_rku;

/
