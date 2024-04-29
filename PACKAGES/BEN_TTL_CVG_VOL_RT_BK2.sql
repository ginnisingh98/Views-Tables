--------------------------------------------------------
--  DDL for Package BEN_TTL_CVG_VOL_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TTL_CVG_VOL_RT_BK2" AUTHID CURRENT_USER as
/* $Header: betcvapi.pkh 120.0 2005/05/28 11:55:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ttl_cvg_vol_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ttl_cvg_vol_rt_b
  (
   p_ttl_cvg_vol_rt_id              in  number
  ,p_business_group_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_no_mn_cvg_vol_amt_apls_flag    in  varchar2
  ,p_no_mx_cvg_vol_amt_apls_flag    in  varchar2
  ,p_ordr_num                       in  number
  ,p_mn_cvg_vol_amt                 in  number
  ,p_mx_cvg_vol_amt                 in  number
  ,p_cvg_vol_det_cd                 in  varchar2
  ,p_cvg_vol_det_rl                 in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_tcv_attribute_category         in  varchar2
  ,p_tcv_attribute1                 in  varchar2
  ,p_tcv_attribute2                 in  varchar2
  ,p_tcv_attribute3                 in  varchar2
  ,p_tcv_attribute4                 in  varchar2
  ,p_tcv_attribute5                 in  varchar2
  ,p_tcv_attribute6                 in  varchar2
  ,p_tcv_attribute7                 in  varchar2
  ,p_tcv_attribute8                 in  varchar2
  ,p_tcv_attribute9                 in  varchar2
  ,p_tcv_attribute10                in  varchar2
  ,p_tcv_attribute11                in  varchar2
  ,p_tcv_attribute12                in  varchar2
  ,p_tcv_attribute13                in  varchar2
  ,p_tcv_attribute14                in  varchar2
  ,p_tcv_attribute15                in  varchar2
  ,p_tcv_attribute16                in  varchar2
  ,p_tcv_attribute17                in  varchar2
  ,p_tcv_attribute18                in  varchar2
  ,p_tcv_attribute19                in  varchar2
  ,p_tcv_attribute20                in  varchar2
  ,p_tcv_attribute21                in  varchar2
  ,p_tcv_attribute22                in  varchar2
  ,p_tcv_attribute23                in  varchar2
  ,p_tcv_attribute24                in  varchar2
  ,p_tcv_attribute25                in  varchar2
  ,p_tcv_attribute26                in  varchar2
  ,p_tcv_attribute27                in  varchar2
  ,p_tcv_attribute28                in  varchar2
  ,p_tcv_attribute29                in  varchar2
  ,p_tcv_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ttl_cvg_vol_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ttl_cvg_vol_rt_a
  (
   p_ttl_cvg_vol_rt_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_no_mn_cvg_vol_amt_apls_flag    in  varchar2
  ,p_no_mx_cvg_vol_amt_apls_flag    in  varchar2
  ,p_ordr_num                       in  number
  ,p_mn_cvg_vol_amt                 in  number
  ,p_mx_cvg_vol_amt                 in  number
  ,p_cvg_vol_det_cd                 in  varchar2
  ,p_cvg_vol_det_rl                 in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_tcv_attribute_category         in  varchar2
  ,p_tcv_attribute1                 in  varchar2
  ,p_tcv_attribute2                 in  varchar2
  ,p_tcv_attribute3                 in  varchar2
  ,p_tcv_attribute4                 in  varchar2
  ,p_tcv_attribute5                 in  varchar2
  ,p_tcv_attribute6                 in  varchar2
  ,p_tcv_attribute7                 in  varchar2
  ,p_tcv_attribute8                 in  varchar2
  ,p_tcv_attribute9                 in  varchar2
  ,p_tcv_attribute10                in  varchar2
  ,p_tcv_attribute11                in  varchar2
  ,p_tcv_attribute12                in  varchar2
  ,p_tcv_attribute13                in  varchar2
  ,p_tcv_attribute14                in  varchar2
  ,p_tcv_attribute15                in  varchar2
  ,p_tcv_attribute16                in  varchar2
  ,p_tcv_attribute17                in  varchar2
  ,p_tcv_attribute18                in  varchar2
  ,p_tcv_attribute19                in  varchar2
  ,p_tcv_attribute20                in  varchar2
  ,p_tcv_attribute21                in  varchar2
  ,p_tcv_attribute22                in  varchar2
  ,p_tcv_attribute23                in  varchar2
  ,p_tcv_attribute24                in  varchar2
  ,p_tcv_attribute25                in  varchar2
  ,p_tcv_attribute26                in  varchar2
  ,p_tcv_attribute27                in  varchar2
  ,p_tcv_attribute28                in  varchar2
  ,p_tcv_attribute29                in  varchar2
  ,p_tcv_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ttl_cvg_vol_rt_bk2;

 

/
