--------------------------------------------------------
--  DDL for Package BEN_EXT_INCL_CHG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_INCL_CHG_API" AUTHID CURRENT_USER as
/* $Header: bexicapi.pkh 120.1 2005/06/08 13:23:38 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_INCL_CHG >------------------------|
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
--   p_chg_evt_cd                   No   varchar2
--   p_ext_rcd_in_file_id           No   number
--   p_ext_data_elmt_in_rcd_id      No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_incl_chg_id              Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_INCL_CHG
(
   p_validate                       in boolean    default false
  ,p_ext_incl_chg_id                out nocopy number
  ,p_chg_evt_cd                     in  varchar2  default null
  ,p_chg_evt_source                 in  varchar2  default null
  ,p_ext_rcd_in_file_id             in  number    default null
  ,p_ext_data_elmt_in_rcd_id        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_INCL_CHG >------------------------|
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
--   p_ext_incl_chg_id              Yes  number    PK of record
--   p_chg_evt_cd                   No   varchar2
--   p_ext_rcd_in_file_id           No   number
--   p_ext_data_elmt_in_rcd_id      No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2
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
procedure update_EXT_INCL_CHG
  (
   p_validate                       in boolean    default false
  ,p_ext_incl_chg_id                in  number
  ,p_chg_evt_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_chg_evt_source              in  varchar2  default hr_api.g_varchar2
  ,p_ext_rcd_in_file_id             in  number    default hr_api.g_number
  ,p_ext_data_elmt_in_rcd_id        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_INCL_CHG >------------------------|
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
--   p_ext_incl_chg_id              Yes  number    PK of record
--   p_legislation_code             No   varchar2
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
procedure delete_EXT_INCL_CHG
  (
   p_validate                       in boolean        default false
  ,p_ext_incl_chg_id                in  number
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
--   p_ext_incl_chg_id                 Yes  number   PK of record
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
    p_ext_incl_chg_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_INCL_CHG_api;

 

/
