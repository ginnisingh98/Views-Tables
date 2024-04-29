--------------------------------------------------------
--  DDL for Package BEN_EXT_RCD_IN_FILE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RCD_IN_FILE_API" AUTHID CURRENT_USER as
/* $Header: bexrfapi.pkh 120.1 2005/06/21 16:54:34 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_RCD_IN_FILE >------------------------|
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
--   p_sprs_cd                      No   varchar2
--   p_ext_rcd_id                   Yes  number
--   p_ext_file_id                  Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2  Legislation Code
--   p_any_or_all_cd                No   varchar2
--   p_hide_flag                    Yes  varchar2
--   p_rqd_flag                     Yes  varchar2
--   p_chg_rcd_upd_flag             Yes  varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_rcd_in_file_id           Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_RCD_IN_FILE
(
   p_validate                       in boolean    default false
  ,p_ext_rcd_in_file_id             out nocopy number
  ,p_seq_num                        in  number    default null
  ,p_sprs_cd                        in  varchar2  default null
  ,p_sort1_data_elmt_in_rcd_id      in  number    default null
  ,p_sort2_data_elmt_in_rcd_id      in  number    default null
  ,p_sort3_data_elmt_in_rcd_id      in  number    default null
  ,p_sort4_data_elmt_in_rcd_id      in  number    default null
  ,p_ext_rcd_id                     in  number    default null
  ,p_ext_file_id                    in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_any_or_all_cd                  in  varchar2  default null
  ,p_hide_flag                      in  varchar2  default 'N'
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_chg_rcd_upd_flag               in  varchar2  default 'N'
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_RCD_IN_FILE >------------------------|
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
--   p_ext_rcd_in_file_id           Yes  number    PK of record
--   p_seq_num                      No   number
--   p_sprs_cd                      No   varchar2
--   p_ext_rcd_id                   Yes  number
--   p_ext_file_id                  Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2  Legislation Code
--   p_any_or_all_cd                No   varchar2
--   p_hide_flag                    Yes  varchar2
--   p_rqd_flag                     Yes  varchar2
--   p_chg_rcd_upd_flag             Yes  varchar2
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
procedure update_EXT_RCD_IN_FILE
  (
   p_validate                       in boolean    default false
  ,p_ext_rcd_in_file_id             in  number
  ,p_seq_num                        in  number    default hr_api.g_number
  ,p_sprs_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_sort1_data_elmt_in_rcd_id      in  number    default hr_api.g_number
  ,p_sort2_data_elmt_in_rcd_id      in  number    default hr_api.g_number
  ,p_sort3_data_elmt_in_rcd_id      in  number    default hr_api.g_number
  ,p_sort4_data_elmt_in_rcd_id      in  number    default hr_api.g_number
  ,p_ext_rcd_id                     in  number    default hr_api.g_number
  ,p_ext_file_id                    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_any_or_all_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_hide_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_chg_rcd_upd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_RCD_IN_FILE >------------------------|
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
--   p_ext_rcd_in_file_id           Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
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
procedure delete_EXT_RCD_IN_FILE
  (
   p_validate                       in boolean        default false
  ,p_ext_rcd_in_file_id             in  number
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
--   p_ext_rcd_in_file_id                 Yes  number   PK of record
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
    p_ext_rcd_in_file_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_RCD_IN_FILE_api;

 

/
