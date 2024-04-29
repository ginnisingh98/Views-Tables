--------------------------------------------------------
--  DDL for Package BEN_ONLINE_ACTIVITY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ONLINE_ACTIVITY_API" AUTHID CURRENT_USER as
/* $Header: beolaapi.pkh 120.0 2005/05/28 09:50:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_online_activity >------------------------|
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
--   p_ordr_num                     No   number
--   p_function_name                No   varchar2
--   p_user_function_name           No   varchar2
--   p_function_type                No   varchar2
--   p_business_group_id            No   number    Business Group of Record
--   p_start_date                   No   date
--   p_end_date                     No   date
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_csr_activities_id            Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_online_activity
(
   p_validate                       in boolean    default false
  ,p_csr_activities_id              out nocopy number
  ,p_ordr_num                       in  number    default null
  ,p_function_name                  in  varchar2  default null
  ,p_user_function_name             in  varchar2  default null
  ,p_function_type                  in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_start_date                     in  date      default null
  ,p_end_date                       in  date      default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_online_activity >------------------------|
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
--   p_csr_activities_id            Yes  number    PK of record
--   p_ordr_num                     No   number
--   p_function_name                No   varchar2
--   p_user_function_name           No   varchar2
--   p_function_type                No   varchar2
--   p_business_group_id            No   number    Business Group of Record
--   p_start_date                   No   date
--   p_end_date                     No   date
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
procedure update_online_activity
  (
   p_validate                       in boolean    default false
  ,p_csr_activities_id              in  number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_function_name                  in  varchar2  default hr_api.g_varchar2
  ,p_user_function_name             in  varchar2  default hr_api.g_varchar2
  ,p_function_type                  in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     in  date      default hr_api.g_date
  ,p_end_date                       in  date      default hr_api.g_date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_online_activity >------------------------|
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
--   p_csr_activities_id            Yes  number    PK of record
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
procedure delete_online_activity
  (
   p_validate                       in boolean        default false
  ,p_csr_activities_id              in  number
  ,p_object_version_number          in out nocopy number
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
--   p_csr_activities_id                 Yes  number   PK of record
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
    p_csr_activities_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_online_activity_api;

 

/
