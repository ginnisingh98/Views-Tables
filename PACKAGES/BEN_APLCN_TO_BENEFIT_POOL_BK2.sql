--------------------------------------------------------
--  DDL for Package BEN_APLCN_TO_BENEFIT_POOL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_APLCN_TO_BENEFIT_POOL_BK2" AUTHID CURRENT_USER as
/* $Header: beabpapi.pkh 120.0 2005/05/28 00:17:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Aplcn_To_Benefit_Pool_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Aplcn_To_Benefit_Pool_b
  (
   p_aplcn_to_bnft_pool_id          in  number
  ,p_acty_base_rt_id                in  number
  ,p_bnft_prvdr_pool_id             in  number
  ,p_business_group_id              in  number
  ,p_abp_attribute_category         in  varchar2
  ,p_abp_attribute1                 in  varchar2
  ,p_abp_attribute2                 in  varchar2
  ,p_abp_attribute3                 in  varchar2
  ,p_abp_attribute4                 in  varchar2
  ,p_abp_attribute5                 in  varchar2
  ,p_abp_attribute6                 in  varchar2
  ,p_abp_attribute7                 in  varchar2
  ,p_abp_attribute8                 in  varchar2
  ,p_abp_attribute9                 in  varchar2
  ,p_abp_attribute10                in  varchar2
  ,p_abp_attribute11                in  varchar2
  ,p_abp_attribute12                in  varchar2
  ,p_abp_attribute13                in  varchar2
  ,p_abp_attribute14                in  varchar2
  ,p_abp_attribute15                in  varchar2
  ,p_abp_attribute16                in  varchar2
  ,p_abp_attribute17                in  varchar2
  ,p_abp_attribute18                in  varchar2
  ,p_abp_attribute19                in  varchar2
  ,p_abp_attribute20                in  varchar2
  ,p_abp_attribute21                in  varchar2
  ,p_abp_attribute22                in  varchar2
  ,p_abp_attribute23                in  varchar2
  ,p_abp_attribute24                in  varchar2
  ,p_abp_attribute25                in  varchar2
  ,p_abp_attribute26                in  varchar2
  ,p_abp_attribute27                in  varchar2
  ,p_abp_attribute28                in  varchar2
  ,p_abp_attribute29                in  varchar2
  ,p_abp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Aplcn_To_Benefit_Pool_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Aplcn_To_Benefit_Pool_a
  (
   p_aplcn_to_bnft_pool_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_acty_base_rt_id                in  number
  ,p_bnft_prvdr_pool_id             in  number
  ,p_business_group_id              in  number
  ,p_abp_attribute_category         in  varchar2
  ,p_abp_attribute1                 in  varchar2
  ,p_abp_attribute2                 in  varchar2
  ,p_abp_attribute3                 in  varchar2
  ,p_abp_attribute4                 in  varchar2
  ,p_abp_attribute5                 in  varchar2
  ,p_abp_attribute6                 in  varchar2
  ,p_abp_attribute7                 in  varchar2
  ,p_abp_attribute8                 in  varchar2
  ,p_abp_attribute9                 in  varchar2
  ,p_abp_attribute10                in  varchar2
  ,p_abp_attribute11                in  varchar2
  ,p_abp_attribute12                in  varchar2
  ,p_abp_attribute13                in  varchar2
  ,p_abp_attribute14                in  varchar2
  ,p_abp_attribute15                in  varchar2
  ,p_abp_attribute16                in  varchar2
  ,p_abp_attribute17                in  varchar2
  ,p_abp_attribute18                in  varchar2
  ,p_abp_attribute19                in  varchar2
  ,p_abp_attribute20                in  varchar2
  ,p_abp_attribute21                in  varchar2
  ,p_abp_attribute22                in  varchar2
  ,p_abp_attribute23                in  varchar2
  ,p_abp_attribute24                in  varchar2
  ,p_abp_attribute25                in  varchar2
  ,p_abp_attribute26                in  varchar2
  ,p_abp_attribute27                in  varchar2
  ,p_abp_attribute28                in  varchar2
  ,p_abp_attribute29                in  varchar2
  ,p_abp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Aplcn_To_Benefit_Pool_bk2;

 

/
