--------------------------------------------------------
--  DDL for Package BEN_ORG_UNIT_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ORG_UNIT_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: beourapi.pkh 120.0 2005/05/28 09:59:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ORG_UNIT_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ORG_UNIT_RATE_b
  (
   p_org_unit_rt_id                 in  number
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_organization_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_our_attribute_category         in  varchar2
  ,p_our_attribute1                 in  varchar2
  ,p_our_attribute2                 in  varchar2
  ,p_our_attribute3                 in  varchar2
  ,p_our_attribute4                 in  varchar2
  ,p_our_attribute5                 in  varchar2
  ,p_our_attribute6                 in  varchar2
  ,p_our_attribute7                 in  varchar2
  ,p_our_attribute8                 in  varchar2
  ,p_our_attribute9                 in  varchar2
  ,p_our_attribute10                in  varchar2
  ,p_our_attribute11                in  varchar2
  ,p_our_attribute12                in  varchar2
  ,p_our_attribute13                in  varchar2
  ,p_our_attribute14                in  varchar2
  ,p_our_attribute15                in  varchar2
  ,p_our_attribute16                in  varchar2
  ,p_our_attribute17                in  varchar2
  ,p_our_attribute18                in  varchar2
  ,p_our_attribute19                in  varchar2
  ,p_our_attribute20                in  varchar2
  ,p_our_attribute21                in  varchar2
  ,p_our_attribute22                in  varchar2
  ,p_our_attribute23                in  varchar2
  ,p_our_attribute24                in  varchar2
  ,p_our_attribute25                in  varchar2
  ,p_our_attribute26                in  varchar2
  ,p_our_attribute27                in  varchar2
  ,p_our_attribute28                in  varchar2
  ,p_our_attribute29                in  varchar2
  ,p_our_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ORG_UNIT_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ORG_UNIT_RATE_a
  (
   p_org_unit_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_organization_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_our_attribute_category         in  varchar2
  ,p_our_attribute1                 in  varchar2
  ,p_our_attribute2                 in  varchar2
  ,p_our_attribute3                 in  varchar2
  ,p_our_attribute4                 in  varchar2
  ,p_our_attribute5                 in  varchar2
  ,p_our_attribute6                 in  varchar2
  ,p_our_attribute7                 in  varchar2
  ,p_our_attribute8                 in  varchar2
  ,p_our_attribute9                 in  varchar2
  ,p_our_attribute10                in  varchar2
  ,p_our_attribute11                in  varchar2
  ,p_our_attribute12                in  varchar2
  ,p_our_attribute13                in  varchar2
  ,p_our_attribute14                in  varchar2
  ,p_our_attribute15                in  varchar2
  ,p_our_attribute16                in  varchar2
  ,p_our_attribute17                in  varchar2
  ,p_our_attribute18                in  varchar2
  ,p_our_attribute19                in  varchar2
  ,p_our_attribute20                in  varchar2
  ,p_our_attribute21                in  varchar2
  ,p_our_attribute22                in  varchar2
  ,p_our_attribute23                in  varchar2
  ,p_our_attribute24                in  varchar2
  ,p_our_attribute25                in  varchar2
  ,p_our_attribute26                in  varchar2
  ,p_our_attribute27                in  varchar2
  ,p_our_attribute28                in  varchar2
  ,p_our_attribute29                in  varchar2
  ,p_our_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ORG_UNIT_RATE_bk2;

 

/
