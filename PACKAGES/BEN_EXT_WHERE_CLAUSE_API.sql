--------------------------------------------------------
--  DDL for Package BEN_EXT_WHERE_CLAUSE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_WHERE_CLAUSE_API" AUTHID CURRENT_USER as
/* $Header: bexwcapi.pkh 120.1 2005/10/11 06:34:58 rbingi noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ext_where_clause >------------------------|
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
--   p_oper_cd                      No   varchar2
--   p_val                          No   varchar2
--   p_and_or_cd                    No   varchar2
--   p_ext_data_elmt_id             Yes  number
--   p_cond_ext_data_elmt_id        No   number
--   p_ext_rcd_in_file_id           No   number
--   p_ext_data_elmt_in_rcd_id      No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2  Legislation Code
--   p_cond_ext_data_elmt_in_rcd_id No   number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_where_clause_id          Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ext_where_clause
(
   p_validate                       in boolean    default false
  ,p_ext_where_clause_id            out nocopy number
  ,p_seq_num                        in  number    default null
  ,p_oper_cd                        in  varchar2  default null
  ,p_val                            in  varchar2  default null
  ,p_and_or_cd                      in  varchar2  default null
  ,p_ext_data_elmt_id               in  number    default null
  ,p_cond_ext_data_elmt_id          in  number    default null
  ,p_ext_rcd_in_file_id             in  number    default null
  ,p_ext_data_elmt_in_rcd_id        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_cond_ext_data_elmt_in_rcd_id   in  number    default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ext_where_clause >------------------------|
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
--   p_ext_where_clause_id          Yes  number    PK of record
--   p_seq_num                      No   number
--   p_oper_cd                      No   varchar2
--   p_val                          No   varchar2
--   p_and_or_cd                    No   varchar2
--   p_ext_data_elmt_id             Yes  number
--   p_cond_ext_data_elmt_id        No   number
--   p_ext_rcd_in_file_id           No   number
--   p_ext_data_elmt_in_rcd_id      No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             No   varchar2  Legislation Code
--   p_cond_ext_data_elmt_in_rcd_id No   number
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
procedure update_ext_where_clause
  (
   p_validate                       in boolean    default false
  ,p_ext_where_clause_id            in  number
  ,p_seq_num                        in  number    default hr_api.g_number
  ,p_oper_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  varchar2  default hr_api.g_varchar2
  ,p_and_or_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_ext_data_elmt_id               in  number    default hr_api.g_number
  ,p_cond_ext_data_elmt_id          in  number    default hr_api.g_number
  ,p_ext_rcd_in_file_id             in  number    default hr_api.g_number
  ,p_ext_data_elmt_in_rcd_id        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_cond_ext_data_elmt_in_rcd_id   in  number    default hr_api.g_number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ext_where_clause >------------------------|
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
--   p_ext_where_clause_id          Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
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
procedure delete_ext_where_clause
  (
   p_validate                       in boolean        default false
  ,p_ext_where_clause_id            in  number
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
--   p_ext_where_clause_id                 Yes  number   PK of record
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
    p_ext_where_clause_id                 in number
   ,p_object_version_number        in number
  );
--
procedure multi_rows_edit
  (p_business_group_id       in number
  ,p_legislation_code        in varchar2
  ,p_ext_rcd_in_file_id      in number
  ,p_ext_data_elmt_in_rcd_id in number
  ,p_ext_data_elmt_id        in number);
--
end ben_ext_where_clause_api;

 

/
