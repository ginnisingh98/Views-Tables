--------------------------------------------------------
--  DDL for Package BEN_HRS_WKD_IN_PERD_FCTR_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HRS_WKD_IN_PERD_FCTR_BK2" AUTHID CURRENT_USER as
/* $Header: behwfapi.pkh 120.0 2005/05/28 03:11:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_hrs_wkd_in_perd_fctr_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_hrs_wkd_in_perd_fctr_b
  (
   p_hrs_wkd_in_perd_fctr_id        in  number
  ,p_name                           in  varchar2
  ,p_business_group_id              in  number
  ,p_hrs_src_cd                     in  varchar2
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_hrs_wkd_det_cd                 in  varchar2
  ,p_hrs_wkd_det_rl                 in  number
  ,p_no_mn_hrs_wkd_flag             in  varchar2
  ,p_mx_hrs_num                     in  number
  ,p_no_mx_hrs_wkd_flag             in  varchar2
  ,p_once_r_cntug_cd                in  varchar2
  ,p_mn_hrs_num                     in  number
  ,p_hrs_alt_val_to_use_cd          in  varchar2
  ,p_pyrl_freq_cd                   in  varchar2
  ,p_hrs_wkd_calc_rl                in  number
  ,p_defined_balance_id             in  number
  ,p_bnfts_bal_id                   in  number
  ,p_hwf_attribute_category         in  varchar2
  ,p_hwf_attribute1                 in  varchar2
  ,p_hwf_attribute2                 in  varchar2
  ,p_hwf_attribute3                 in  varchar2
  ,p_hwf_attribute4                 in  varchar2
  ,p_hwf_attribute5                 in  varchar2
  ,p_hwf_attribute6                 in  varchar2
  ,p_hwf_attribute7                 in  varchar2
  ,p_hwf_attribute8                 in  varchar2
  ,p_hwf_attribute9                 in  varchar2
  ,p_hwf_attribute10                in  varchar2
  ,p_hwf_attribute11                in  varchar2
  ,p_hwf_attribute12                in  varchar2
  ,p_hwf_attribute13                in  varchar2
  ,p_hwf_attribute14                in  varchar2
  ,p_hwf_attribute15                in  varchar2
  ,p_hwf_attribute16                in  varchar2
  ,p_hwf_attribute17                in  varchar2
  ,p_hwf_attribute18                in  varchar2
  ,p_hwf_attribute19                in  varchar2
  ,p_hwf_attribute20                in  varchar2
  ,p_hwf_attribute21                in  varchar2
  ,p_hwf_attribute22                in  varchar2
  ,p_hwf_attribute23                in  varchar2
  ,p_hwf_attribute24                in  varchar2
  ,p_hwf_attribute25                in  varchar2
  ,p_hwf_attribute26                in  varchar2
  ,p_hwf_attribute27                in  varchar2
  ,p_hwf_attribute28                in  varchar2
  ,p_hwf_attribute29                in  varchar2
  ,p_hwf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_hrs_wkd_in_perd_fctr_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_hrs_wkd_in_perd_fctr_a
  (
   p_hrs_wkd_in_perd_fctr_id        in  number
  ,p_name                           in  varchar2
  ,p_business_group_id              in  number
  ,p_hrs_src_cd                     in  varchar2
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_hrs_wkd_det_cd                 in  varchar2
  ,p_hrs_wkd_det_rl                 in  number
  ,p_no_mn_hrs_wkd_flag             in  varchar2
  ,p_mx_hrs_num                     in  number
  ,p_no_mx_hrs_wkd_flag             in  varchar2
  ,p_once_r_cntug_cd                in  varchar2
  ,p_mn_hrs_num                     in  number
  ,p_hrs_alt_val_to_use_cd          in  varchar2
  ,p_pyrl_freq_cd                   in  varchar2
  ,p_hrs_wkd_calc_rl                in  number
  ,p_defined_balance_id             in  number
  ,p_bnfts_bal_id                   in  number
  ,p_hwf_attribute_category         in  varchar2
  ,p_hwf_attribute1                 in  varchar2
  ,p_hwf_attribute2                 in  varchar2
  ,p_hwf_attribute3                 in  varchar2
  ,p_hwf_attribute4                 in  varchar2
  ,p_hwf_attribute5                 in  varchar2
  ,p_hwf_attribute6                 in  varchar2
  ,p_hwf_attribute7                 in  varchar2
  ,p_hwf_attribute8                 in  varchar2
  ,p_hwf_attribute9                 in  varchar2
  ,p_hwf_attribute10                in  varchar2
  ,p_hwf_attribute11                in  varchar2
  ,p_hwf_attribute12                in  varchar2
  ,p_hwf_attribute13                in  varchar2
  ,p_hwf_attribute14                in  varchar2
  ,p_hwf_attribute15                in  varchar2
  ,p_hwf_attribute16                in  varchar2
  ,p_hwf_attribute17                in  varchar2
  ,p_hwf_attribute18                in  varchar2
  ,p_hwf_attribute19                in  varchar2
  ,p_hwf_attribute20                in  varchar2
  ,p_hwf_attribute21                in  varchar2
  ,p_hwf_attribute22                in  varchar2
  ,p_hwf_attribute23                in  varchar2
  ,p_hwf_attribute24                in  varchar2
  ,p_hwf_attribute25                in  varchar2
  ,p_hwf_attribute26                in  varchar2
  ,p_hwf_attribute27                in  varchar2
  ,p_hwf_attribute28                in  varchar2
  ,p_hwf_attribute29                in  varchar2
  ,p_hwf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_hrs_wkd_in_perd_fctr_bk2;

 

/
