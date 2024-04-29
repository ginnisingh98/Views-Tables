--------------------------------------------------------
--  DDL for Package BEN_PIL_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_ASSIGNMENT_API" AUTHID CURRENT_USER as
/*  $Header: bepsgapi.pkh 120.0 2005/09/29 06:20:11 ssarkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pil_assignment >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--
-- Out Parameters:
--   Name                          Reqd      Type     Description
--   p_pil_assignment_id            Yes     number    PK of record
--   p_object_version_number        No      number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_pil_assignment
(
   p_validate                       in boolean    default false
  ,p_pil_assignment_id              out nocopy number
  ,p_per_in_ler_id                  in  number    default null
  ,p_applicant_assignment_id        in  number    default null
  ,p_offer_assignment_id            in  number    default null
  ,p_object_version_number          out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_pil_assignment >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
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
procedure update_pil_assignment
  (
   p_validate                       in boolean    default false
  ,p_pil_assignment_id              in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_applicant_assignment_id        in  number    default hr_api.g_number
  ,p_offer_assignment_id            in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
   );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pil_assignment >------------------------|
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
--   p_pil_assignment_id            Yes  number    PK of record
--
-- Post Success:
--
--   Name                           Type           Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_pil_assignment
  (
   p_validate                       in boolean        default false
  ,p_pil_assignment_id              in  number
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
--   p_pil_assignment_id            Yes  number   PK of record
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
    p_pil_assignment_id            in number
   ,p_object_version_number        in number
  );
--
end ben_pil_assignment_api;

 

/
