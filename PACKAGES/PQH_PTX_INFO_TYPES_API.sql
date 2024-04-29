--------------------------------------------------------
--  DDL for Package PQH_PTX_INFO_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTX_INFO_TYPES_API" AUTHID CURRENT_USER as
/* $Header: pqptiapi.pkh 120.0 2005/05/29 02:21:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ptx_info_type >------------------------|
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
--   p_active_inactive_flag         Yes  varchar2
--   p_description                  No   varchar2
--   p_multiple_occurences_flag     Yes  varchar2
--   p_legislation_code             No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_information_type             Yes  varchar2  PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ptx_info_type
(
   p_validate                       in boolean    default false
  ,p_information_type               out nocopy varchar2
  ,p_active_inactive_flag           in  varchar2  default null
  ,p_description                    in  varchar2  default null
  ,p_multiple_occurences_flag       in  varchar2  default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ptx_info_type >------------------------|
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
--   p_information_type             Yes  varchar2  PK of record
--   p_active_inactive_flag         Yes  varchar2
--   p_description                  No   varchar2
--   p_multiple_occurences_flag     Yes  varchar2
--   p_legislation_code             No   varchar2
--   p_effective_date          Yes  date       Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_ptx_info_type
  (
   p_validate                       in boolean    default false
  ,p_information_type               in  varchar2
  ,p_active_inactive_flag           in  varchar2  default hr_api.g_varchar2
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_multiple_occurences_flag       in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ptx_info_type >------------------------|
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
--   p_information_type             Yes  varchar2  PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_ptx_info_type
  (
   p_validate                       in boolean        default false
  ,p_information_type               in  varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
  );
--
--
end pqh_ptx_info_types_api;

 

/
