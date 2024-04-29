--------------------------------------------------------
--  DDL for Package BEN_ACTY_RT_PTD_LMT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_RT_PTD_LMT_BK1" AUTHID CURRENT_USER as
/* $Header: beaplapi.pkh 120.0 2005/05/28 00:25:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ACTY_RT_PTD_LMT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ACTY_RT_PTD_LMT_b
  (
   p_acty_base_rt_id                in  number
  ,p_ptd_lmt_id                     in  number
  ,p_business_group_id              in  number
  ,p_apl_attribute_category         in  varchar2
  ,p_apl_attribute1                 in  varchar2
  ,p_apl_attribute2                 in  varchar2
  ,p_apl_attribute3                 in  varchar2
  ,p_apl_attribute4                 in  varchar2
  ,p_apl_attribute5                 in  varchar2
  ,p_apl_attribute6                 in  varchar2
  ,p_apl_attribute7                 in  varchar2
  ,p_apl_attribute8                 in  varchar2
  ,p_apl_attribute9                 in  varchar2
  ,p_apl_attribute10                in  varchar2
  ,p_apl_attribute11                in  varchar2
  ,p_apl_attribute12                in  varchar2
  ,p_apl_attribute13                in  varchar2
  ,p_apl_attribute14                in  varchar2
  ,p_apl_attribute15                in  varchar2
  ,p_apl_attribute16                in  varchar2
  ,p_apl_attribute17                in  varchar2
  ,p_apl_attribute18                in  varchar2
  ,p_apl_attribute19                in  varchar2
  ,p_apl_attribute20                in  varchar2
  ,p_apl_attribute21                in  varchar2
  ,p_apl_attribute22                in  varchar2
  ,p_apl_attribute23                in  varchar2
  ,p_apl_attribute24                in  varchar2
  ,p_apl_attribute25                in  varchar2
  ,p_apl_attribute26                in  varchar2
  ,p_apl_attribute27                in  varchar2
  ,p_apl_attribute28                in  varchar2
  ,p_apl_attribute29                in  varchar2
  ,p_apl_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ACTY_RT_PTD_LMT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ACTY_RT_PTD_LMT_a
  (
   p_acty_rt_ptd_lmt_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_acty_base_rt_id                in  number
  ,p_ptd_lmt_id                     in  number
  ,p_business_group_id              in  number
  ,p_apl_attribute_category         in  varchar2
  ,p_apl_attribute1                 in  varchar2
  ,p_apl_attribute2                 in  varchar2
  ,p_apl_attribute3                 in  varchar2
  ,p_apl_attribute4                 in  varchar2
  ,p_apl_attribute5                 in  varchar2
  ,p_apl_attribute6                 in  varchar2
  ,p_apl_attribute7                 in  varchar2
  ,p_apl_attribute8                 in  varchar2
  ,p_apl_attribute9                 in  varchar2
  ,p_apl_attribute10                in  varchar2
  ,p_apl_attribute11                in  varchar2
  ,p_apl_attribute12                in  varchar2
  ,p_apl_attribute13                in  varchar2
  ,p_apl_attribute14                in  varchar2
  ,p_apl_attribute15                in  varchar2
  ,p_apl_attribute16                in  varchar2
  ,p_apl_attribute17                in  varchar2
  ,p_apl_attribute18                in  varchar2
  ,p_apl_attribute19                in  varchar2
  ,p_apl_attribute20                in  varchar2
  ,p_apl_attribute21                in  varchar2
  ,p_apl_attribute22                in  varchar2
  ,p_apl_attribute23                in  varchar2
  ,p_apl_attribute24                in  varchar2
  ,p_apl_attribute25                in  varchar2
  ,p_apl_attribute26                in  varchar2
  ,p_apl_attribute27                in  varchar2
  ,p_apl_attribute28                in  varchar2
  ,p_apl_attribute29                in  varchar2
  ,p_apl_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ACTY_RT_PTD_LMT_bk1;

 

/
