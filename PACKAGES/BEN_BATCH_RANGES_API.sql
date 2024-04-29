--------------------------------------------------------
--  DDL for Package BEN_BATCH_RANGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_RANGES_API" AUTHID CURRENT_USER as
/* $Header: beranapi.pkh 115.4 2002/12/11 11:35:36 lakrish ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_ranges >---------------------------|
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
--   p_benefit_action_id            Yes  number
--   p_range_status_cd              Yes  varchar2
--   p_starting_person_action_id    Yes  number
--   p_ending_person_action_id      Yes  number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_range_id                     Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_batch_ranges
 (p_validate                  in  boolean  default false
 ,p_range_id                  out nocopy number
 ,p_benefit_action_id         in  number   default null
 ,p_range_status_cd           in  varchar2 default null
 ,p_starting_person_action_id in  number   default null
 ,p_ending_person_action_id   in  number   default null
 ,p_object_version_number     out nocopy number
 ,p_effective_date            in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_ranges >---------------------------|
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
--   p_range_id                     Yes  number    PK of record
--   p_benefit_action_id            Yes  number
--   p_range_status_cd              Yes  varchar2
--   p_starting_person_action_id    Yes  number
--   p_ending_person_action_id      Yes  number
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
procedure update_batch_ranges
  (p_validate                  in boolean   default false
  ,p_range_id                  in number
  ,p_benefit_action_id         in number    default hr_api.g_number
  ,p_range_status_cd           in varchar2  default hr_api.g_varchar2
  ,p_starting_person_action_id in number    default hr_api.g_number
  ,p_ending_person_action_id   in number    default hr_api.g_number
  ,p_object_version_number     in out nocopy number
  ,p_effective_date            in date);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_ranges >---------------------------|
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
--   p_range_id                     Yes  number    PK of record
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
procedure delete_batch_ranges
  (p_validate                  in boolean        default false
  ,p_range_id                  in number
  ,p_object_version_number     in out nocopy number
  ,p_effective_date            in date);
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
--   p_range_id                 Yes  number   PK of record
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
  (p_range_id                 in number
  ,p_object_version_number    in number);
--
end ben_batch_ranges_api;

 

/
