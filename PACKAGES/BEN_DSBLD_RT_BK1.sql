--------------------------------------------------------
--  DDL for Package BEN_DSBLD_RT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DSBLD_RT_BK1" AUTHID CURRENT_USER as
/* $Header: bedbrapi.pkh 120.0 2005/05/28 01:30:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_DSBLD_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_DSBLD_RT_b
  (
   p_dsbld_cd                       in  varchar2
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_dbr_attribute_category         in  varchar2
  ,p_dbr_attribute1                 in  varchar2
  ,p_dbr_attribute2                 in  varchar2
  ,p_dbr_attribute3                 in  varchar2
  ,p_dbr_attribute4                 in  varchar2
  ,p_dbr_attribute5                 in  varchar2
  ,p_dbr_attribute6                 in  varchar2
  ,p_dbr_attribute7                 in  varchar2
  ,p_dbr_attribute8                 in  varchar2
  ,p_dbr_attribute9                 in  varchar2
  ,p_dbr_attribute10                in  varchar2
  ,p_dbr_attribute11                in  varchar2
  ,p_dbr_attribute12                in  varchar2
  ,p_dbr_attribute13                in  varchar2
  ,p_dbr_attribute14                in  varchar2
  ,p_dbr_attribute15                in  varchar2
  ,p_dbr_attribute16                in  varchar2
  ,p_dbr_attribute17                in  varchar2
  ,p_dbr_attribute18                in  varchar2
  ,p_dbr_attribute19                in  varchar2
  ,p_dbr_attribute20                in  varchar2
  ,p_dbr_attribute21                in  varchar2
  ,p_dbr_attribute22                in  varchar2
  ,p_dbr_attribute23                in  varchar2
  ,p_dbr_attribute24                in  varchar2
  ,p_dbr_attribute25                in  varchar2
  ,p_dbr_attribute26                in  varchar2
  ,p_dbr_attribute27                in  varchar2
  ,p_dbr_attribute28                in  varchar2
  ,p_dbr_attribute29                in  varchar2
  ,p_dbr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_DSBLD_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_DSBLD_RT_a
  (
   p_dsbld_rt_id                    in  number
  ,p_dsbld_cd                       in  varchar2
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_dbr_attribute_category         in  varchar2
  ,p_dbr_attribute1                 in  varchar2
  ,p_dbr_attribute2                 in  varchar2
  ,p_dbr_attribute3                 in  varchar2
  ,p_dbr_attribute4                 in  varchar2
  ,p_dbr_attribute5                 in  varchar2
  ,p_dbr_attribute6                 in  varchar2
  ,p_dbr_attribute7                 in  varchar2
  ,p_dbr_attribute8                 in  varchar2
  ,p_dbr_attribute9                 in  varchar2
  ,p_dbr_attribute10                in  varchar2
  ,p_dbr_attribute11                in  varchar2
  ,p_dbr_attribute12                in  varchar2
  ,p_dbr_attribute13                in  varchar2
  ,p_dbr_attribute14                in  varchar2
  ,p_dbr_attribute15                in  varchar2
  ,p_dbr_attribute16                in  varchar2
  ,p_dbr_attribute17                in  varchar2
  ,p_dbr_attribute18                in  varchar2
  ,p_dbr_attribute19                in  varchar2
  ,p_dbr_attribute20                in  varchar2
  ,p_dbr_attribute21                in  varchar2
  ,p_dbr_attribute22                in  varchar2
  ,p_dbr_attribute23                in  varchar2
  ,p_dbr_attribute24                in  varchar2
  ,p_dbr_attribute25                in  varchar2
  ,p_dbr_attribute26                in  varchar2
  ,p_dbr_attribute27                in  varchar2
  ,p_dbr_attribute28                in  varchar2
  ,p_dbr_attribute29                in  varchar2
  ,p_dbr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_DSBLD_RT_bk1;

 

/
