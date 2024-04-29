--------------------------------------------------------
--  DDL for Package BEN_BENEFIT_GRP_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFIT_GRP_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: bebrgapi.pkh 120.0 2005/05/28 00:50:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_BENEFIT_GRP_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_BENEFIT_GRP_RATE_b
  (
   p_benfts_grp_rt_id               in  number
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_benfts_grp_id                  in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_brg_attribute_category         in  varchar2
  ,p_brg_attribute1                 in  varchar2
  ,p_brg_attribute2                 in  varchar2
  ,p_brg_attribute3                 in  varchar2
  ,p_brg_attribute4                 in  varchar2
  ,p_brg_attribute5                 in  varchar2
  ,p_brg_attribute6                 in  varchar2
  ,p_brg_attribute7                 in  varchar2
  ,p_brg_attribute8                 in  varchar2
  ,p_brg_attribute9                 in  varchar2
  ,p_brg_attribute10                in  varchar2
  ,p_brg_attribute11                in  varchar2
  ,p_brg_attribute12                in  varchar2
  ,p_brg_attribute13                in  varchar2
  ,p_brg_attribute14                in  varchar2
  ,p_brg_attribute15                in  varchar2
  ,p_brg_attribute16                in  varchar2
  ,p_brg_attribute17                in  varchar2
  ,p_brg_attribute18                in  varchar2
  ,p_brg_attribute19                in  varchar2
  ,p_brg_attribute20                in  varchar2
  ,p_brg_attribute21                in  varchar2
  ,p_brg_attribute22                in  varchar2
  ,p_brg_attribute23                in  varchar2
  ,p_brg_attribute24                in  varchar2
  ,p_brg_attribute25                in  varchar2
  ,p_brg_attribute26                in  varchar2
  ,p_brg_attribute27                in  varchar2
  ,p_brg_attribute28                in  varchar2
  ,p_brg_attribute29                in  varchar2
  ,p_brg_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_BENEFIT_GRP_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_BENEFIT_GRP_RATE_a
  (
   p_benfts_grp_rt_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_benfts_grp_id                  in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_brg_attribute_category         in  varchar2
  ,p_brg_attribute1                 in  varchar2
  ,p_brg_attribute2                 in  varchar2
  ,p_brg_attribute3                 in  varchar2
  ,p_brg_attribute4                 in  varchar2
  ,p_brg_attribute5                 in  varchar2
  ,p_brg_attribute6                 in  varchar2
  ,p_brg_attribute7                 in  varchar2
  ,p_brg_attribute8                 in  varchar2
  ,p_brg_attribute9                 in  varchar2
  ,p_brg_attribute10                in  varchar2
  ,p_brg_attribute11                in  varchar2
  ,p_brg_attribute12                in  varchar2
  ,p_brg_attribute13                in  varchar2
  ,p_brg_attribute14                in  varchar2
  ,p_brg_attribute15                in  varchar2
  ,p_brg_attribute16                in  varchar2
  ,p_brg_attribute17                in  varchar2
  ,p_brg_attribute18                in  varchar2
  ,p_brg_attribute19                in  varchar2
  ,p_brg_attribute20                in  varchar2
  ,p_brg_attribute21                in  varchar2
  ,p_brg_attribute22                in  varchar2
  ,p_brg_attribute23                in  varchar2
  ,p_brg_attribute24                in  varchar2
  ,p_brg_attribute25                in  varchar2
  ,p_brg_attribute26                in  varchar2
  ,p_brg_attribute27                in  varchar2
  ,p_brg_attribute28                in  varchar2
  ,p_brg_attribute29                in  varchar2
  ,p_brg_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_BENEFIT_GRP_RATE_bk2;

 

/
