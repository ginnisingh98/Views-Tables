--------------------------------------------------------
--  DDL for Package BEN_ELIG_OBJ_ELIG_PROFL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_OBJ_ELIG_PROFL_SWI" AUTHID CURRENT_USER as
/* $Header: bebepswi.pkh 120.0 2005/05/28 00:39:45 appldev noship $ */
 procedure create_ELIG_OBJ_ELIG_PROFL
(
   p_validate                       in number    default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id          in number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_elig_obj_id                    in  number    default null
  ,p_elig_prfl_id                   in  number    default null
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_bep_attribute_category         in  varchar2  default null
  ,p_bep_attribute1                 in  varchar2  default null
  ,p_bep_attribute2                 in  varchar2  default null
  ,p_bep_attribute3                 in  varchar2  default null
  ,p_bep_attribute4                 in  varchar2  default null
  ,p_bep_attribute5                 in  varchar2  default null
  ,p_bep_attribute6                 in  varchar2  default null
  ,p_bep_attribute7                 in  varchar2  default null
  ,p_bep_attribute8                 in  varchar2  default null
  ,p_bep_attribute9                 in  varchar2  default null
  ,p_bep_attribute10                in  varchar2  default null
  ,p_bep_attribute11                in  varchar2  default null
  ,p_bep_attribute12                in  varchar2  default null
  ,p_bep_attribute13                in  varchar2  default null
  ,p_bep_attribute14                in  varchar2  default null
  ,p_bep_attribute15                in  varchar2  default null
  ,p_bep_attribute16                in  varchar2  default null
  ,p_bep_attribute17                in  varchar2  default null
  ,p_bep_attribute18                in  varchar2  default null
  ,p_bep_attribute19                in  varchar2  default null
  ,p_bep_attribute20                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_return_status                  out nocopy varchar2
 );
-- ----------------------------------------------------------------------------
-- |----------------------< update_ELIG_OBJ_ELIG_PROFL >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_OBJ_ELIG_PROFL
  (
   p_validate                       in number     default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_elig_obj_id                    in  number    default hr_api.g_number
  ,p_elig_prfl_id                   in  number    default hr_api.g_number
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_bep_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_return_status                  out nocopy varchar2
  );
  -- ----------------------------------------------------------------------------
-- |-----------------------< delete_ELIG_OBJ_ELIG_PROFL >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_OBJ_ELIG_PROFL
  (
   p_validate                       in number   default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_return_status                  out nocopy varchar2
  );
--
--
END; -- Package spec


 

/
