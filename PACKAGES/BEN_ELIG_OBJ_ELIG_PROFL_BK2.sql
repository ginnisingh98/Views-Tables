--------------------------------------------------------
--  DDL for Package BEN_ELIG_OBJ_ELIG_PROFL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_OBJ_ELIG_PROFL_BK2" AUTHID CURRENT_USER as
/* $Header: bebepapi.pkh 120.0 2005/05/28 00:39:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_OBJ_ELIG_PROFL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_OBJ_ELIG_PROFL_b
  (
   p_elig_obj_elig_prfl_id               in  number
  ,p_business_group_id              in  number
  ,p_elig_obj_id                    in  number
  ,p_elig_prfl_id                   in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_bep_attribute_category         in  varchar2
  ,p_bep_attribute1                 in  varchar2
  ,p_bep_attribute2                 in  varchar2
  ,p_bep_attribute3                 in  varchar2
  ,p_bep_attribute4                 in  varchar2
  ,p_bep_attribute5                 in  varchar2
  ,p_bep_attribute6                 in  varchar2
  ,p_bep_attribute7                 in  varchar2
  ,p_bep_attribute8                 in  varchar2
  ,p_bep_attribute9                 in  varchar2
  ,p_bep_attribute10                in  varchar2
  ,p_bep_attribute11                in  varchar2
  ,p_bep_attribute12                in  varchar2
  ,p_bep_attribute13                in  varchar2
  ,p_bep_attribute14                in  varchar2
  ,p_bep_attribute15                in  varchar2
  ,p_bep_attribute16                in  varchar2
  ,p_bep_attribute17                in  varchar2
  ,p_bep_attribute18                in  varchar2
  ,p_bep_attribute19                in  varchar2
  ,p_bep_attribute20                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_OBJ_ELIG_PROFL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_OBJ_ELIG_PROFL_a
  (
   p_elig_obj_elig_prfl_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_elig_obj_id                    in  number
  ,p_elig_prfl_id                   in  number
  ,p_mndtry_flag                    in  varchar2
  ,p_bep_attribute_category         in  varchar2
  ,p_bep_attribute1                 in  varchar2
  ,p_bep_attribute2                 in  varchar2
  ,p_bep_attribute3                 in  varchar2
  ,p_bep_attribute4                 in  varchar2
  ,p_bep_attribute5                 in  varchar2
  ,p_bep_attribute6                 in  varchar2
  ,p_bep_attribute7                 in  varchar2
  ,p_bep_attribute8                 in  varchar2
  ,p_bep_attribute9                 in  varchar2
  ,p_bep_attribute10                in  varchar2
  ,p_bep_attribute11                in  varchar2
  ,p_bep_attribute12                in  varchar2
  ,p_bep_attribute13                in  varchar2
  ,p_bep_attribute14                in  varchar2
  ,p_bep_attribute15                in  varchar2
  ,p_bep_attribute16                in  varchar2
  ,p_bep_attribute17                in  varchar2
  ,p_bep_attribute18                in  varchar2
  ,p_bep_attribute19                in  varchar2
  ,p_bep_attribute20                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_OBJ_ELIG_PROFL_bk2;

 

/
