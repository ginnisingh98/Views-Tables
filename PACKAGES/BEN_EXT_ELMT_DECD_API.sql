--------------------------------------------------------
--  DDL for Package BEN_EXT_ELMT_DECD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ELMT_DECD_API" AUTHID CURRENT_USER as
/* $Header: bexddapi.pkh 120.1 2005/06/08 13:09:11 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_ELMT_DECD >------------------------|
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
--   p_val                          No   varchar2
--   p_dcd_val                      No   varchar2
--   p_ext_data_elmt_id             Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_data_elmt_decd_id        Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_ELMT_DECD
(
   p_validate                       in boolean    default false
  ,p_ext_data_elmt_decd_id          out nocopy number
  ,p_val                            in  varchar2  default null
  ,p_dcd_val                        in  varchar2  default null
  ,p_chg_evt_source                 in  varchar2  default null
  ,p_ext_data_elmt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_ELMT_DECD >------------------------|
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
--   p_ext_data_elmt_decd_id        Yes  number    PK of record
--   p_val                          No   varchar2
--   p_dcd_val                      No   varchar2
--   p_ext_data_elmt_id             Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2
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
procedure update_EXT_ELMT_DECD
  (
   p_validate                       in boolean    default false
  ,p_ext_data_elmt_decd_id          in  number
  ,p_val                            in  varchar2  default hr_api.g_varchar2
  ,p_dcd_val                        in  varchar2  default hr_api.g_varchar2
  ,p_chg_evt_source                 in  varchar2  default hr_api.g_varchar2
  ,p_ext_data_elmt_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_ELMT_DECD >------------------------|
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
--   p_ext_data_elmt_decd_id        Yes  number    PK of record
--   p_legislation_code             No   varchar2
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
procedure delete_EXT_ELMT_DECD
  (
   p_validate                       in boolean        default false
  ,p_ext_data_elmt_decd_id          in number
  ,p_legislation_code               in varchar2 default null
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
--   p_ext_data_elmt_decd_id                 Yes  number   PK of record
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
    p_ext_data_elmt_decd_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_ELMT_DECD_api;

 

/
