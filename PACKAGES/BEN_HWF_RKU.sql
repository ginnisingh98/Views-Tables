--------------------------------------------------------
--  DDL for Package BEN_HWF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HWF_RKU" AUTHID CURRENT_USER as
/* $Header: behwfrhi.pkh 120.0 2005/05/28 03:12:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_hrs_wkd_in_perd_fctr_id        in number
 ,p_name                           in varchar2
 ,p_business_group_id              in number
 ,p_hrs_src_cd                     in varchar2
 ,p_rndg_cd                        in varchar2
 ,p_rndg_rl                        in number
 ,p_hrs_wkd_det_cd                 in varchar2
 ,p_hrs_wkd_det_rl                 in number
 ,p_no_mn_hrs_wkd_flag             in varchar2
 ,p_mx_hrs_num                     in number
 ,p_no_mx_hrs_wkd_flag             in varchar2
 ,p_once_r_cntug_cd                in varchar2
 ,p_mn_hrs_num                     in number
 ,p_hrs_alt_val_to_use_cd          in varchar2
 ,p_pyrl_freq_cd                   in varchar2
 ,p_hrs_wkd_calc_rl                in number
 ,p_defined_balance_id             in number
 ,p_bnfts_bal_id                   in number
 ,p_hwf_attribute_category         in varchar2
 ,p_hwf_attribute1                 in varchar2
 ,p_hwf_attribute2                 in varchar2
 ,p_hwf_attribute3                 in varchar2
 ,p_hwf_attribute4                 in varchar2
 ,p_hwf_attribute5                 in varchar2
 ,p_hwf_attribute6                 in varchar2
 ,p_hwf_attribute7                 in varchar2
 ,p_hwf_attribute8                 in varchar2
 ,p_hwf_attribute9                 in varchar2
 ,p_hwf_attribute10                in varchar2
 ,p_hwf_attribute11                in varchar2
 ,p_hwf_attribute12                in varchar2
 ,p_hwf_attribute13                in varchar2
 ,p_hwf_attribute14                in varchar2
 ,p_hwf_attribute15                in varchar2
 ,p_hwf_attribute16                in varchar2
 ,p_hwf_attribute17                in varchar2
 ,p_hwf_attribute18                in varchar2
 ,p_hwf_attribute19                in varchar2
 ,p_hwf_attribute20                in varchar2
 ,p_hwf_attribute21                in varchar2
 ,p_hwf_attribute22                in varchar2
 ,p_hwf_attribute23                in varchar2
 ,p_hwf_attribute24                in varchar2
 ,p_hwf_attribute25                in varchar2
 ,p_hwf_attribute26                in varchar2
 ,p_hwf_attribute27                in varchar2
 ,p_hwf_attribute28                in varchar2
 ,p_hwf_attribute29                in varchar2
 ,p_hwf_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_hrs_src_cd_o                   in varchar2
 ,p_rndg_cd_o                      in varchar2
 ,p_rndg_rl_o                      in number
 ,p_hrs_wkd_det_cd_o               in varchar2
 ,p_hrs_wkd_det_rl_o               in number
 ,p_no_mn_hrs_wkd_flag_o           in varchar2
 ,p_mx_hrs_num_o                   in number
 ,p_no_mx_hrs_wkd_flag_o           in varchar2
 ,p_once_r_cntug_cd_o              in varchar2
 ,p_mn_hrs_num_o                   in number
 ,p_hrs_alt_val_to_use_cd_o        in varchar2
 ,p_pyrl_freq_cd_o                 in varchar2
 ,p_hrs_wkd_calc_rl_o              in number
 ,p_defined_balance_id_o           in number
 ,p_bnfts_bal_id_o                 in number
 ,p_hwf_attribute_category_o       in varchar2
 ,p_hwf_attribute1_o               in varchar2
 ,p_hwf_attribute2_o               in varchar2
 ,p_hwf_attribute3_o               in varchar2
 ,p_hwf_attribute4_o               in varchar2
 ,p_hwf_attribute5_o               in varchar2
 ,p_hwf_attribute6_o               in varchar2
 ,p_hwf_attribute7_o               in varchar2
 ,p_hwf_attribute8_o               in varchar2
 ,p_hwf_attribute9_o               in varchar2
 ,p_hwf_attribute10_o              in varchar2
 ,p_hwf_attribute11_o              in varchar2
 ,p_hwf_attribute12_o              in varchar2
 ,p_hwf_attribute13_o              in varchar2
 ,p_hwf_attribute14_o              in varchar2
 ,p_hwf_attribute15_o              in varchar2
 ,p_hwf_attribute16_o              in varchar2
 ,p_hwf_attribute17_o              in varchar2
 ,p_hwf_attribute18_o              in varchar2
 ,p_hwf_attribute19_o              in varchar2
 ,p_hwf_attribute20_o              in varchar2
 ,p_hwf_attribute21_o              in varchar2
 ,p_hwf_attribute22_o              in varchar2
 ,p_hwf_attribute23_o              in varchar2
 ,p_hwf_attribute24_o              in varchar2
 ,p_hwf_attribute25_o              in varchar2
 ,p_hwf_attribute26_o              in varchar2
 ,p_hwf_attribute27_o              in varchar2
 ,p_hwf_attribute28_o              in varchar2
 ,p_hwf_attribute29_o              in varchar2
 ,p_hwf_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_hwf_rku;

 

/
