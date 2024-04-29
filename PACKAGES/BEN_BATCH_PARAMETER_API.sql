--------------------------------------------------------
--  DDL for Package BEN_BATCH_PARAMETER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_PARAMETER_API" AUTHID CURRENT_USER as
/* $Header: bebbpapi.pkh 120.0 2005/05/28 00:33:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_parameter >------------------------|
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
--   p_batch_exe_cd                 No   varchar2
--   p_thread_cnt_num               No   number
--   p_max_err_num                  No   number
--   p_chunk_size                   No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_batch_parameter_id           Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_batch_parameter
  (p_validate                       in boolean    default false
  ,p_batch_parameter_id             out nocopy number
  ,p_batch_exe_cd                   in  varchar2  default null
  ,p_thread_cnt_num                 in  number    default null
  ,p_max_err_num                    in  number    default null
  ,p_chunk_size                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_parameter >------------------------|
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
--   p_batch_parameter_id           Yes  number    PK of record
--   p_batch_exe_cd                 No   varchar2
--   p_thread_cnt_num               No   number
--   p_max_err_num                  No   number
--   p_chunk_size                   No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date          Yes  date       Session Date.
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
procedure update_batch_parameter
  (p_validate                       in boolean    default false
  ,p_batch_parameter_id             in  number
  ,p_batch_exe_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_thread_cnt_num                 in  number    default hr_api.g_number
  ,p_max_err_num                    in  number    default hr_api.g_number
  ,p_chunk_size                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_parameter >------------------------|
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
--   p_batch_parameter_id           Yes  number    PK of record
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
procedure delete_batch_parameter
  (p_validate                       in boolean        default false
  ,p_batch_parameter_id             in number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date);
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
--   p_batch_parameter_id                 Yes  number   PK of record
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
  (p_batch_parameter_id           in number
  ,p_object_version_number        in number);
--
end ben_batch_parameter_api;

 

/
