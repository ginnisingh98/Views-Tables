--------------------------------------------------------
--  DDL for Package BEN_EXT_RSLT_ERR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RSLT_ERR_API" AUTHID CURRENT_USER as
/* $Header: bexreapi.pkh 120.0 2005/05/28 12:39:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_RSLT_ERR >------------------------|
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
--   p_err_num                      No   number
--   p_err_txt                      No   varchar2
--   p_typ_cd                       No   varchar2
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_ext_rslt_id                  No   number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_rslt_err_id              Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_RSLT_ERR
(
   p_validate                       in boolean    default false
  ,p_ext_rslt_err_id                out nocopy number
  ,p_err_num                        in  number    default null
  ,p_err_txt                        in  varchar2  default null
  ,p_typ_cd                         in  varchar2  default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_ext_rslt_id                    in  number    default null
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_RSLT_ERR >------------------------|
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
--   p_ext_rslt_err_id              Yes  number    PK of record
--   p_err_num                      No   number
--   p_err_txt                      No   varchar2
--   p_typ_cd                       No   varchar2
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_ext_rslt_id                  No   number
--   p_effective_date               Yes  date       Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_EXT_RSLT_ERR
  (
   p_validate                       in boolean    default false
  ,p_ext_rslt_err_id                in  number
  ,p_err_num                        in  number    default hr_api.g_number
  ,p_err_txt                        in  varchar2  default hr_api.g_varchar2
  ,p_typ_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_ext_rslt_id                    in  number    default hr_api.g_number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_RSLT_ERR >------------------------|
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
--   p_ext_rslt_err_id              Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_EXT_RSLT_ERR
  (
   p_validate                       in boolean        default false
  ,p_ext_rslt_err_id                in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
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
--   p_ext_rslt_err_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
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
    p_ext_rslt_err_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_RSLT_ERR_api;

 

/
