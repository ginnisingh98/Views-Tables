--------------------------------------------------------
--  DDL for Package BEN_PL_EXTRACT_ID_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_EXTRACT_ID_API" AUTHID CURRENT_USER as
/* $Header: bepeiapi.pkh 120.0 2005/05/28 10:33:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pl_extract_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                            Reqd  Type       Description
--   p_validate                      Yes   boolean    Commit or Rollback.
--   p_pl_id                         No    number
--   p_plip_id                       No    number
--   p_oipl_id                       No    number
--   p_third_party_identifier        No    varchar
--   p_organization_id               No    number
--   p_job_id                        No    number
--   p_position_id                   No    number
--   p_people_group_id               No    number
--   p_grade_id                      No    number
--   p_payroll_id                    No    number
--   p_home_state                    No    varchar
--   p_home_zip                      No    varchar
--   p_business_group_id             No    number
--   p_effective_date                Yes   date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                  Type     Description
--   p_pl_extract_identifier_id      Yes   number
--   p_effective_start_date          Yes   date      Effective Start Date of Record
--   p_effective_end_date            Yes   date      Effective End Date of Record
--   p_object_version_number         No    number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_pl_extract_id
(
   p_validate                       in  boolean       default false
  ,p_pl_extract_identifier_id       out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_id                          in  number        default null
  ,p_plip_id                        in  number        default null
  ,p_oipl_id                        in  number        default null
  ,p_third_party_identifier         in  varchar2      default null
  ,p_organization_id                in  number        default null
  ,p_job_id                         in  number        default null
  ,p_position_id                    in  number        default null
  ,p_people_group_id                in  number        default null
  ,p_grade_id                       in  number        default null
  ,p_payroll_id                     in  number        default null
  ,p_home_state                     in  varchar2      default null
  ,p_home_zip                       in  varchar2      default null
  ,p_object_version_number          out nocopy number
  ,p_business_group_id              in  number        default null
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pl_extract_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                            Reqd  Type       Description
--   p_validate                      Yes   boolean    Commit or Rollback.
--   p_pl_extract_identifier_id      Yes   number
--   p_pl_id                         No    number
--   p_plip_id                       No    number
--   p_oipl_id                       No    number
--   p_third_party_identifier        No    varchar
--   p_organization_id               No    number
--   p_job_id                        No    number
--   p_position_id                   No    number
--   p_people_group_id               No    number
--   p_grade_id                      No    number
--   p_payroll_id                    No    number
--   p_home_state                    No    varchar
--   p_home_zip                      No    varchar
--   p_object_version_number         No    number
--   p_business_group_id             No    number
--   p_effective_date                Yes   date      Session Date.
--   p_datetrack_mode                Yes   varchar2  Datetrack mode.
--
-- Post Success:
--
--   Name                                Type      Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_pl_extract_id
  (
   p_validate                       in  boolean       default false
  ,p_pl_extract_identifier_id       in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_id                          in  number        default hr_api.g_number
  ,p_plip_id                        in  number        default hr_api.g_number
  ,p_oipl_id                        in  number        default hr_api.g_number
  ,p_third_party_identifier         in  varchar2      default hr_api.g_varchar2
  ,p_organization_id                in  number        default hr_api.g_number
  ,p_job_id                         in  number        default hr_api.g_number
  ,p_position_id                    in  number        default hr_api.g_number
  ,p_people_group_id                in  number        default hr_api.g_number
  ,p_grade_id                       in  number        default hr_api.g_number
  ,p_payroll_id                     in  number        default hr_api.g_number
  ,p_home_state                     in  varchar2      default hr_api.g_varchar2
  ,p_home_zip                       in  varchar2      default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in  number        default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pl_extract_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_pl_extract_identifier_id     Yes  number
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_pl_extract_id
  (
   p_validate                       in boolean        default false
  ,p_pl_extract_identifier_id       in  number
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
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_pl_extract_identifier_id     Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_pl_extract_identifier_id       in number
   ,p_object_version_number          in number
   ,p_effective_date                 in date
   ,p_datetrack_mode                 in varchar2
   ,p_validation_start_date          out nocopy date
   ,p_validation_end_date            out nocopy date
  );
--
end ben_pl_extract_id_api;

 

/
