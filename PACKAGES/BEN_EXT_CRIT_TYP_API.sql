--------------------------------------------------------
--  DDL for Package BEN_EXT_CRIT_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CRIT_TYP_API" AUTHID CURRENT_USER as
/* $Header: bexctapi.pkh 120.0 2005/05/28 12:26:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_CRIT_TYP >------------------------|
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
--   p_crit_typ_cd                  No   varchar2
--   p_ext_crit_prfl_id             Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code		    No   varchar2  Legislation Code
--   p_effective_date               Yes  date      Session Date.
--   p_excld_flag                   Yes  varchar2  Exclude/Include
--
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_crit_typ_id              Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_CRIT_TYP
(
   p_validate                       in boolean    default false
  ,p_ext_crit_typ_id                out nocopy number
  ,p_crit_typ_cd                    in  varchar2  default null
  ,p_ext_crit_prfl_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_excld_flag                     in  varchar2
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_CRIT_TYP >------------------------|
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
--   p_ext_crit_typ_id              Yes  number   PK of record
--   p_crit_typ_cd                  No   varchar2
--   p_ext_crit_prfl_id             Yes  number
--   p_business_group_id            Yes  number   Business Group of Record
--   p_legislation_code             No   varchar2  Legislation Code
--   p_effective_date               Yes  date     Session Date.
--   p_excld_flag                   Yes  varchar2 Exclude/Include
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
procedure update_EXT_CRIT_TYP
  (
   p_validate                       in  boolean    default false
  ,p_ext_crit_typ_id                in  number
  ,p_crit_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ext_crit_prfl_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_CRIT_TYP >------------------------|
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
--   p_ext_crit_typ_id              Yes  number    PK of record
--   p_effective_date          	    Yes  date     Session Date.
--   p_legislation_code             No   varchar2  Legislation Code
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
procedure delete_EXT_CRIT_TYP
  (
   p_validate                       in boolean   default false
  ,p_ext_crit_typ_id                in  number
  ,p_legislation_code               in  varchar2 default null
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
--   p_ext_crit_typ_id                 Yes  number   PK of record
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
    p_ext_crit_typ_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_CRIT_TYP_api;

 

/
