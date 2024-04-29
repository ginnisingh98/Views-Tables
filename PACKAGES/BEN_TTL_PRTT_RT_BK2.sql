--------------------------------------------------------
--  DDL for Package BEN_TTL_PRTT_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TTL_PRTT_RT_BK2" AUTHID CURRENT_USER as
/* $Header: bettpapi.pkh 120.0 2005/05/28 11:57:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ttl_prtt_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ttl_prtt_rt_b
  (
   p_ttl_prtt_rt_id                 in  number
  ,p_business_group_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_no_mn_prtt_num_apls_flag       in  varchar2
  ,p_no_mx_prtt_num_apls_flag       in  varchar2
  ,p_ordr_num                       in  number
  ,p_mn_prtt_num                    in  number
  ,p_mx_prtt_num                    in  number
  ,p_prtt_det_cd                    in  varchar2
  ,p_prtt_det_rl                    in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ttp_attribute_category         in  varchar2
  ,p_ttp_attribute1                 in  varchar2
  ,p_ttp_attribute2                 in  varchar2
  ,p_ttp_attribute3                 in  varchar2
  ,p_ttp_attribute4                 in  varchar2
  ,p_ttp_attribute5                 in  varchar2
  ,p_ttp_attribute6                 in  varchar2
  ,p_ttp_attribute7                 in  varchar2
  ,p_ttp_attribute8                 in  varchar2
  ,p_ttp_attribute9                 in  varchar2
  ,p_ttp_attribute10                in  varchar2
  ,p_ttp_attribute11                in  varchar2
  ,p_ttp_attribute12                in  varchar2
  ,p_ttp_attribute13                in  varchar2
  ,p_ttp_attribute14                in  varchar2
  ,p_ttp_attribute15                in  varchar2
  ,p_ttp_attribute16                in  varchar2
  ,p_ttp_attribute17                in  varchar2
  ,p_ttp_attribute18                in  varchar2
  ,p_ttp_attribute19                in  varchar2
  ,p_ttp_attribute20                in  varchar2
  ,p_ttp_attribute21                in  varchar2
  ,p_ttp_attribute22                in  varchar2
  ,p_ttp_attribute23                in  varchar2
  ,p_ttp_attribute24                in  varchar2
  ,p_ttp_attribute25                in  varchar2
  ,p_ttp_attribute26                in  varchar2
  ,p_ttp_attribute27                in  varchar2
  ,p_ttp_attribute28                in  varchar2
  ,p_ttp_attribute29                in  varchar2
  ,p_ttp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ttl_prtt_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ttl_prtt_rt_a
  (
   p_ttl_prtt_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_no_mn_prtt_num_apls_flag       in  varchar2
  ,p_no_mx_prtt_num_apls_flag       in  varchar2
  ,p_ordr_num                       in  number
  ,p_mn_prtt_num                    in  number
  ,p_mx_prtt_num                    in  number
  ,p_prtt_det_cd                    in  varchar2
  ,p_prtt_det_rl                    in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_ttp_attribute_category         in  varchar2
  ,p_ttp_attribute1                 in  varchar2
  ,p_ttp_attribute2                 in  varchar2
  ,p_ttp_attribute3                 in  varchar2
  ,p_ttp_attribute4                 in  varchar2
  ,p_ttp_attribute5                 in  varchar2
  ,p_ttp_attribute6                 in  varchar2
  ,p_ttp_attribute7                 in  varchar2
  ,p_ttp_attribute8                 in  varchar2
  ,p_ttp_attribute9                 in  varchar2
  ,p_ttp_attribute10                in  varchar2
  ,p_ttp_attribute11                in  varchar2
  ,p_ttp_attribute12                in  varchar2
  ,p_ttp_attribute13                in  varchar2
  ,p_ttp_attribute14                in  varchar2
  ,p_ttp_attribute15                in  varchar2
  ,p_ttp_attribute16                in  varchar2
  ,p_ttp_attribute17                in  varchar2
  ,p_ttp_attribute18                in  varchar2
  ,p_ttp_attribute19                in  varchar2
  ,p_ttp_attribute20                in  varchar2
  ,p_ttp_attribute21                in  varchar2
  ,p_ttp_attribute22                in  varchar2
  ,p_ttp_attribute23                in  varchar2
  ,p_ttp_attribute24                in  varchar2
  ,p_ttp_attribute25                in  varchar2
  ,p_ttp_attribute26                in  varchar2
  ,p_ttp_attribute27                in  varchar2
  ,p_ttp_attribute28                in  varchar2
  ,p_ttp_attribute29                in  varchar2
  ,p_ttp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ttl_prtt_rt_bk2;

 

/
