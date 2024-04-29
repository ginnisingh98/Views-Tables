--------------------------------------------------------
--  DDL for Package BEN_EXT_ELMT_IN_RCD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ELMT_IN_RCD_API" AUTHID CURRENT_USER as
/* $Header: bexerapi.pkh 120.0 2005/05/28 12:32:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_ELMT_IN_RCD >------------------------|
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
--   p_seq_num                      No   number
--   p_strt_pos                     No   number
--   p_dlmtr_val                    No   varchar2
--   p_rqd_flag                     Yes  varchar2
--   p_sprs_cd                      No   varchar2
--   p_any_or_all_cd                No   varchar2
--   p_ext_data_elmt_id             Yes  number
--   p_ext_rcd_id                   Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2
--   p_hide_flag                    Yes  varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_data_elmt_in_rcd_id      Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_ELMT_IN_RCD
(
   p_validate                       in boolean    default false
  ,p_ext_data_elmt_in_rcd_id        out nocopy number
  ,p_seq_num                        in  number    default null
  ,p_strt_pos                       in  number    default null
  ,p_dlmtr_val                      in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_sprs_cd                        in  varchar2  default null
  ,p_any_or_all_cd                  in  varchar2  default null
  ,p_ext_data_elmt_id               in  number    default null
  ,p_ext_rcd_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_hide_flag                      in  varchar2  default 'N'
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_ELMT_IN_RCD >------------------------|
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
--   p_ext_data_elmt_in_rcd_id      Yes  number    PK of record
--   p_seq_num                      No   number
--   p_strt_pos                     No   number
--   p_dlmtr_val                    No   varchar2
--   p_rqd_flag                     Yes  varchar2
--   p_sprs_cd                      No   varchar2
--   p_any_or_all_cd                No   varchar2
--   p_ext_data_elmt_id             Yes  number
--   p_ext_rcd_id                   Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2
--   p_hide_flag                    Yes  varchar2
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
procedure update_EXT_ELMT_IN_RCD
  (
   p_validate                       in  boolean    default false
  ,p_ext_data_elmt_in_rcd_id        in  number
  ,p_seq_num                        in  number    default hr_api.g_number
  ,p_strt_pos                       in  number    default hr_api.g_number
  ,p_dlmtr_val                      in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_sprs_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_any_or_all_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_ext_data_elmt_id               in  number    default hr_api.g_number
  ,p_ext_rcd_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2   default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_hide_flag                      in  varchar2   default hr_api.g_varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_ELMT_IN_RCD >------------------------|
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
--   p_legislation_code             No   varchar2
--   p_ext_data_elmt_in_rcd_id      Yes  number    PK of record
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
procedure delete_EXT_ELMT_IN_RCD
  (
   p_validate                       in boolean        default false
  ,p_ext_data_elmt_in_rcd_id        in  number
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
--   p_ext_data_elmt_in_rcd_id                 Yes  number   PK of record
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
    p_ext_data_elmt_in_rcd_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_ELMT_IN_RCD_api;

 

/
