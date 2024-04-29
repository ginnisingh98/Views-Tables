--------------------------------------------------------
--  DDL for Package BEN_PERSON_TYPE_RATE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_TYPE_RATE_BK1" AUTHID CURRENT_USER as
/* $Header: beptrapi.pkh 120.0 2005/05/28 11:23:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_PERSON_TYPE_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_PERSON_TYPE_RATE_b
  (
   p_vrbl_rt_prfl_id                in  number
  ,p_per_typ_cd                     in  varchar2
  ,p_person_type_id                 in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_ptr_attribute_category         in  varchar2
  ,p_ptr_attribute1                 in  varchar2
  ,p_ptr_attribute2                 in  varchar2
  ,p_ptr_attribute3                 in  varchar2
  ,p_ptr_attribute4                 in  varchar2
  ,p_ptr_attribute5                 in  varchar2
  ,p_ptr_attribute6                 in  varchar2
  ,p_ptr_attribute7                 in  varchar2
  ,p_ptr_attribute8                 in  varchar2
  ,p_ptr_attribute9                 in  varchar2
  ,p_ptr_attribute10                in  varchar2
  ,p_ptr_attribute11                in  varchar2
  ,p_ptr_attribute12                in  varchar2
  ,p_ptr_attribute13                in  varchar2
  ,p_ptr_attribute14                in  varchar2
  ,p_ptr_attribute15                in  varchar2
  ,p_ptr_attribute16                in  varchar2
  ,p_ptr_attribute17                in  varchar2
  ,p_ptr_attribute18                in  varchar2
  ,p_ptr_attribute19                in  varchar2
  ,p_ptr_attribute20                in  varchar2
  ,p_ptr_attribute21                in  varchar2
  ,p_ptr_attribute22                in  varchar2
  ,p_ptr_attribute23                in  varchar2
  ,p_ptr_attribute24                in  varchar2
  ,p_ptr_attribute25                in  varchar2
  ,p_ptr_attribute26                in  varchar2
  ,p_ptr_attribute27                in  varchar2
  ,p_ptr_attribute28                in  varchar2
  ,p_ptr_attribute29                in  varchar2
  ,p_ptr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_PERSON_TYPE_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_PERSON_TYPE_RATE_a
  (
   p_per_typ_rt_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                in  number
  ,p_per_typ_cd                     in  varchar2
  ,p_person_type_id                 in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_ptr_attribute_category         in  varchar2
  ,p_ptr_attribute1                 in  varchar2
  ,p_ptr_attribute2                 in  varchar2
  ,p_ptr_attribute3                 in  varchar2
  ,p_ptr_attribute4                 in  varchar2
  ,p_ptr_attribute5                 in  varchar2
  ,p_ptr_attribute6                 in  varchar2
  ,p_ptr_attribute7                 in  varchar2
  ,p_ptr_attribute8                 in  varchar2
  ,p_ptr_attribute9                 in  varchar2
  ,p_ptr_attribute10                in  varchar2
  ,p_ptr_attribute11                in  varchar2
  ,p_ptr_attribute12                in  varchar2
  ,p_ptr_attribute13                in  varchar2
  ,p_ptr_attribute14                in  varchar2
  ,p_ptr_attribute15                in  varchar2
  ,p_ptr_attribute16                in  varchar2
  ,p_ptr_attribute17                in  varchar2
  ,p_ptr_attribute18                in  varchar2
  ,p_ptr_attribute19                in  varchar2
  ,p_ptr_attribute20                in  varchar2
  ,p_ptr_attribute21                in  varchar2
  ,p_ptr_attribute22                in  varchar2
  ,p_ptr_attribute23                in  varchar2
  ,p_ptr_attribute24                in  varchar2
  ,p_ptr_attribute25                in  varchar2
  ,p_ptr_attribute26                in  varchar2
  ,p_ptr_attribute27                in  varchar2
  ,p_ptr_attribute28                in  varchar2
  ,p_ptr_attribute29                in  varchar2
  ,p_ptr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_PERSON_TYPE_RATE_bk1;

 

/
