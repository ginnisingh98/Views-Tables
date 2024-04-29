--------------------------------------------------------
--  DDL for Package BEN_LABOR_MEMBER_RATE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LABOR_MEMBER_RATE_BK1" AUTHID CURRENT_USER as
/* $Header: belmmapi.pkh 120.0 2005/05/28 03:24:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_LABOR_MEMBER_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_LABOR_MEMBER_RATE_b
  (
   p_vrbl_rt_prfl_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_lbr_mmbr_flag                  in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_lmm_attribute_category         in  varchar2
  ,p_lmm_attribute1                 in  varchar2
  ,p_lmm_attribute2                 in  varchar2
  ,p_lmm_attribute3                 in  varchar2
  ,p_lmm_attribute4                 in  varchar2
  ,p_lmm_attribute5                 in  varchar2
  ,p_lmm_attribute6                 in  varchar2
  ,p_lmm_attribute7                 in  varchar2
  ,p_lmm_attribute8                 in  varchar2
  ,p_lmm_attribute9                 in  varchar2
  ,p_lmm_attribute10                in  varchar2
  ,p_lmm_attribute11                in  varchar2
  ,p_lmm_attribute12                in  varchar2
  ,p_lmm_attribute13                in  varchar2
  ,p_lmm_attribute14                in  varchar2
  ,p_lmm_attribute15                in  varchar2
  ,p_lmm_attribute16                in  varchar2
  ,p_lmm_attribute17                in  varchar2
  ,p_lmm_attribute18                in  varchar2
  ,p_lmm_attribute19                in  varchar2
  ,p_lmm_attribute20                in  varchar2
  ,p_lmm_attribute21                in  varchar2
  ,p_lmm_attribute22                in  varchar2
  ,p_lmm_attribute23                in  varchar2
  ,p_lmm_attribute24                in  varchar2
  ,p_lmm_attribute25                in  varchar2
  ,p_lmm_attribute26                in  varchar2
  ,p_lmm_attribute27                in  varchar2
  ,p_lmm_attribute28                in  varchar2
  ,p_lmm_attribute29                in  varchar2
  ,p_lmm_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_LABOR_MEMBER_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_LABOR_MEMBER_RATE_a
  (
   p_lbr_mmbr_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_lbr_mmbr_flag                  in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_lmm_attribute_category         in  varchar2
  ,p_lmm_attribute1                 in  varchar2
  ,p_lmm_attribute2                 in  varchar2
  ,p_lmm_attribute3                 in  varchar2
  ,p_lmm_attribute4                 in  varchar2
  ,p_lmm_attribute5                 in  varchar2
  ,p_lmm_attribute6                 in  varchar2
  ,p_lmm_attribute7                 in  varchar2
  ,p_lmm_attribute8                 in  varchar2
  ,p_lmm_attribute9                 in  varchar2
  ,p_lmm_attribute10                in  varchar2
  ,p_lmm_attribute11                in  varchar2
  ,p_lmm_attribute12                in  varchar2
  ,p_lmm_attribute13                in  varchar2
  ,p_lmm_attribute14                in  varchar2
  ,p_lmm_attribute15                in  varchar2
  ,p_lmm_attribute16                in  varchar2
  ,p_lmm_attribute17                in  varchar2
  ,p_lmm_attribute18                in  varchar2
  ,p_lmm_attribute19                in  varchar2
  ,p_lmm_attribute20                in  varchar2
  ,p_lmm_attribute21                in  varchar2
  ,p_lmm_attribute22                in  varchar2
  ,p_lmm_attribute23                in  varchar2
  ,p_lmm_attribute24                in  varchar2
  ,p_lmm_attribute25                in  varchar2
  ,p_lmm_attribute26                in  varchar2
  ,p_lmm_attribute27                in  varchar2
  ,p_lmm_attribute28                in  varchar2
  ,p_lmm_attribute29                in  varchar2
  ,p_lmm_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_LABOR_MEMBER_RATE_bk1;

 

/
