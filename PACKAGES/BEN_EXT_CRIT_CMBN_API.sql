--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_CMBN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_CMBN_API" AUTHID CURRENT_USER as
/* $Header: bexccapi.pkh 120.0 2005/05/28 12:22:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_CRIT_CMBN >------------------------|
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
--   p_crit_typ_cd                  Yes  varchar2
--   p_oper_cd                      Yes  varchar2
--   p_val_1                        No   varchar2
--   p_val_2                        No   varchar2
--   p_ext_crit_val_id              Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2  Legislation Code
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_crit_cmbn_id             Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_CRIT_CMBN
(
   p_validate                       in boolean    default false
  ,p_ext_crit_cmbn_id               out nocopy number
  ,p_crit_typ_cd                    in  varchar2  default null
  ,p_oper_cd                        in  varchar2  default null
  ,p_val_1                          in  varchar2  default null
  ,p_val_2                          in  varchar2  default null
  ,p_ext_crit_val_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_CRIT_CMBN >------------------------|
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
--   p_ext_crit_cmbn_id             Yes  number    PK of record
--   p_crit_typ_cd                  Yes  varchar2
--   p_oper_cd                      Yes  varchar2
--   p_val_1                        No   varchar2
--   p_val_2                        No   varchar2
--   p_ext_crit_val_id              Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2  Legislation Code
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
procedure update_EXT_CRIT_CMBN
  (
   p_validate                       in boolean    default false
  ,p_ext_crit_cmbn_id               in  number
  ,p_crit_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_oper_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_val_1                          in  varchar2  default hr_api.g_varchar2
  ,p_val_2                          in  varchar2  default hr_api.g_varchar2
  ,p_ext_crit_val_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_CRIT_CMBN >------------------------|
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
--   p_ext_crit_cmbn_id             Yes  number    PK of record
--   p_legislation_code             No   varchar2  Legislation Code
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
procedure delete_EXT_CRIT_CMBN
  (
   p_validate                       in boolean        default false
  ,p_ext_crit_cmbn_id               in  number
  ,p_legislation_code               in  varchar2  default null
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
--   p_ext_crit_cmbn_id                 Yes  number   PK of record
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
    p_ext_crit_cmbn_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_CRIT_CMBN_api;

 

/
