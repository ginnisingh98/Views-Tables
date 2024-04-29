--------------------------------------------------------
--  DDL for Package BEN_ELIG_RSLT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_RSLT_API" AUTHID CURRENT_USER as
/* $Header: beberapi.pkh 120.0 2005/05/28 00:39:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_RSLT >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_RSLT
(
   p_validate                       in boolean    default false
  ,p_elig_rslt_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_elig_obj_id                    in  number    default null
  ,p_person_id                      in  number    default null
  ,p_assignment_id                  in  number    default null
  ,p_elig_flag                      in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_RSLT >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_RSLT
  (
   p_validate                       in boolean    default false
  ,p_elig_rslt_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_elig_obj_id                    in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_elig_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_RSLT >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_RSLT
  (
   p_validate                       in boolean        default false
  ,p_elig_rslt_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
    p_elig_rslt_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_ELIG_RSLT_api;

 

/
