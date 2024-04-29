--------------------------------------------------------
--  DDL for Package BEN_TTP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TTP_RKU" AUTHID CURRENT_USER as
/* $Header: bettprhi.pkh 120.0.12010000.1 2008/07/29 13:05:48 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ttl_prtt_rt_id                 in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_excld_flag                     in varchar2
 ,p_no_mn_prtt_num_apls_flag       in varchar2
 ,p_no_mx_prtt_num_apls_flag       in varchar2
 ,p_ordr_num                       in number
 ,p_mn_prtt_num                    in number
 ,p_mx_prtt_num                    in number
 ,p_prtt_det_cd                    in varchar2
 ,p_prtt_det_rl                    in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_ttp_attribute_category         in varchar2
 ,p_ttp_attribute1                 in varchar2
 ,p_ttp_attribute2                 in varchar2
 ,p_ttp_attribute3                 in varchar2
 ,p_ttp_attribute4                 in varchar2
 ,p_ttp_attribute5                 in varchar2
 ,p_ttp_attribute6                 in varchar2
 ,p_ttp_attribute7                 in varchar2
 ,p_ttp_attribute8                 in varchar2
 ,p_ttp_attribute9                 in varchar2
 ,p_ttp_attribute10                in varchar2
 ,p_ttp_attribute11                in varchar2
 ,p_ttp_attribute12                in varchar2
 ,p_ttp_attribute13                in varchar2
 ,p_ttp_attribute14                in varchar2
 ,p_ttp_attribute15                in varchar2
 ,p_ttp_attribute16                in varchar2
 ,p_ttp_attribute17                in varchar2
 ,p_ttp_attribute18                in varchar2
 ,p_ttp_attribute19                in varchar2
 ,p_ttp_attribute20                in varchar2
 ,p_ttp_attribute21                in varchar2
 ,p_ttp_attribute22                in varchar2
 ,p_ttp_attribute23                in varchar2
 ,p_ttp_attribute24                in varchar2
 ,p_ttp_attribute25                in varchar2
 ,p_ttp_attribute26                in varchar2
 ,p_ttp_attribute27                in varchar2
 ,p_ttp_attribute28                in varchar2
 ,p_ttp_attribute29                in varchar2
 ,p_ttp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_excld_flag_o                   in varchar2
 ,p_no_mn_prtt_num_apls_flag_o     in varchar2
 ,p_no_mx_prtt_num_apls_flag_o     in varchar2
 ,p_ordr_num_o                     in number
 ,p_mn_prtt_num_o                  in number
 ,p_mx_prtt_num_o                  in number
 ,p_prtt_det_cd_o                  in varchar2
 ,p_prtt_det_rl_o                  in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_ttp_attribute_category_o       in varchar2
 ,p_ttp_attribute1_o               in varchar2
 ,p_ttp_attribute2_o               in varchar2
 ,p_ttp_attribute3_o               in varchar2
 ,p_ttp_attribute4_o               in varchar2
 ,p_ttp_attribute5_o               in varchar2
 ,p_ttp_attribute6_o               in varchar2
 ,p_ttp_attribute7_o               in varchar2
 ,p_ttp_attribute8_o               in varchar2
 ,p_ttp_attribute9_o               in varchar2
 ,p_ttp_attribute10_o              in varchar2
 ,p_ttp_attribute11_o              in varchar2
 ,p_ttp_attribute12_o              in varchar2
 ,p_ttp_attribute13_o              in varchar2
 ,p_ttp_attribute14_o              in varchar2
 ,p_ttp_attribute15_o              in varchar2
 ,p_ttp_attribute16_o              in varchar2
 ,p_ttp_attribute17_o              in varchar2
 ,p_ttp_attribute18_o              in varchar2
 ,p_ttp_attribute19_o              in varchar2
 ,p_ttp_attribute20_o              in varchar2
 ,p_ttp_attribute21_o              in varchar2
 ,p_ttp_attribute22_o              in varchar2
 ,p_ttp_attribute23_o              in varchar2
 ,p_ttp_attribute24_o              in varchar2
 ,p_ttp_attribute25_o              in varchar2
 ,p_ttp_attribute26_o              in varchar2
 ,p_ttp_attribute27_o              in varchar2
 ,p_ttp_attribute28_o              in varchar2
 ,p_ttp_attribute29_o              in varchar2
 ,p_ttp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ttp_rku;

/
