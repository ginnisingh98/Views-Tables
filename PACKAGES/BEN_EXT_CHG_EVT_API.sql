--------------------------------------------------------
--  DDL for Package BEN_EXT_CHG_EVT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CHG_EVT_API" AUTHID CURRENT_USER as
/* $Header: bexclapi.pkh 120.1 2005/06/23 15:04:14 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_CHG_EVT >------------------------|
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
--   p_chg_evt_cd                   Yes  varchar2
--   p_chg_eff_dt                   Yes  date
--   p_chg_user_id                  No   number
--   p_prmtr_01                     No   varchar2
--   p_prmtr_02                     No   varchar2
--   p_prmtr_03                     No   varchar2
--   p_prmtr_04                     No   varchar2
--   p_prmtr_05                     No   varchar2
--   p_prmtr_06                     No   varchar2
--   p_prmtr_07                     No   varchar2
--   p_prmtr_08                     No   varchar2
--   p_prmtr_09                     No   varchar2
--   p_prmtr_10                     No   varchar2
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_chg_evt_log_id           Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_CHG_EVT
(
   p_validate                       in boolean    default false
  ,p_ext_chg_evt_log_id             out nocopy number
  ,p_chg_evt_cd                     in  varchar2  default null
  ,p_chg_eff_dt                     in  date      default null
  ,p_chg_user_id                    in  number    default null
  ,p_prmtr_01                       in  varchar2  default null
  ,p_prmtr_02                       in  varchar2  default null
  ,p_prmtr_03                       in  varchar2  default null
  ,p_prmtr_04                       in  varchar2  default null
  ,p_prmtr_05                       in  varchar2  default null
  ,p_prmtr_06                       in  varchar2  default null
  ,p_prmtr_07                       in  varchar2  default null
  ,p_prmtr_08                       in  varchar2  default null
  ,p_prmtr_09                       in  varchar2  default null
  ,p_prmtr_10                       in  varchar2  default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_new_val1                       in varchar2   default null
  ,p_new_val2                       in varchar2   default null
  ,p_new_val3                       in varchar2   default null
  ,p_new_val4                       in varchar2   default null
  ,p_new_val5                       in varchar2   default null
  ,p_new_val6                       in varchar2   default null
  ,p_old_val1                       in varchar2   default null
  ,p_old_val2                       in varchar2   default null
  ,p_old_val3                       in varchar2   default null
  ,p_old_val4                       in varchar2   default null
  ,p_old_val5                       in varchar2   default null
  ,p_old_val6                       in varchar2   default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_CHG_EVT >------------------------|
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
--   p_ext_chg_evt_log_id           Yes  number    PK of record
--   p_chg_evt_cd                   Yes  varchar2
--   p_chg_eff_dt                   Yes  date
--   p_chg_user_id                  No   number
--   p_prmtr_01                     No   varchar2
--   p_prmtr_02                     No   varchar2
--   p_prmtr_03                     No   varchar2
--   p_prmtr_04                     No   varchar2
--   p_prmtr_05                     No   varchar2
--   p_prmtr_06                     No   varchar2
--   p_prmtr_07                     No   varchar2
--   p_prmtr_08                     No   varchar2
--   p_prmtr_09                     No   varchar2
--   p_prmtr_10                     No   varchar2
--   p_person_id                    Yes  number
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
procedure update_EXT_CHG_EVT
  (
   p_validate                       in boolean    default false
  ,p_ext_chg_evt_log_id             in  number
  ,p_chg_evt_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_chg_eff_dt                     in  date      default hr_api.g_date
  ,p_chg_user_id                    in  number    default hr_api.g_number
  ,p_prmtr_01                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_02                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_03                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_04                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_05                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_06                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_07                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_08                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_09                       in  varchar2  default hr_api.g_varchar2
  ,p_prmtr_10                       in  varchar2  default hr_api.g_varchar2
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_CHG_EVT >------------------------|
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
--   p_ext_chg_evt_log_id           Yes  number    PK of record
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
procedure delete_EXT_CHG_EVT
  (
   p_validate                       in boolean        default false
  ,p_ext_chg_evt_log_id             in  number
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
--   p_ext_chg_evt_log_id                 Yes  number   PK of record
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
    p_ext_chg_evt_log_id                 in number
   ,p_object_version_number        in number
  );
--

Function pay_interpreter_ressult    (p_assignment_id  in number,
                                    p_event_group_id  in number,
                                    p_actl_date       in date ,
                                    p_dated_table_id  in number,
                                    p_column_name     in varchar2,
                                    p_effective_date  in  date ,
                                    p_eff_date        in date ,
                                    p_change_type     in varchar2 ,
                                    p_process_event_id in number)
                                    return varchar2 ;

end ben_EXT_CHG_EVT_api;

 

/
