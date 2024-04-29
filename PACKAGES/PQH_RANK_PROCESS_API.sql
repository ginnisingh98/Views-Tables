--------------------------------------------------------
--  DDL for Package PQH_RANK_PROCESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RANK_PROCESS_API" AUTHID CURRENT_USER as
/* $Header: pqrnkapi.pkh 120.1 2005/06/03 11:58:28 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_rank_process >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  Commit or rollback
--   p_effective_date               Yes  date     effective date
--
--
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Type     Description
--   p_rank_process_id              number   primary key
--   p_object_version_number        number   object version number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_rank_process
  (p_validate                      in     boolean default false
  ,p_effective_date                in     date
  ,p_rank_process_id                  out nocopy number
  ,p_pgm_id                        in     number default null
  ,p_pl_id                         in     number default null
  ,p_oipl_id                       in     number default null
  ,p_process_cd                    in     varchar2
  ,p_process_date                  in     date
  ,p_benefit_action_id             in     number default null
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number
  ,p_total_score                   in     number default null
  ,p_request_id                    in     number default null
  ,p_business_group_id             in     number default null
  ,p_object_version_number            out nocopy number
  ,p_per_in_ler_id                 in     number default null
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_rank_process >-----------------------|
-- ----------------------------------------------------------------------------
procedure update_rank_process
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rank_process_id               in     number
  ,p_pgm_id                        in     number default hr_api.g_number
  ,p_pl_id                         in     number default hr_api.g_number
  ,p_oipl_id                       in     number default hr_api.g_number
  ,p_process_cd                    in     varchar2
  ,p_process_date                  in     date
  ,p_benefit_action_id             in     number default hr_api.g_number
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number
  ,p_total_score                   in     number default hr_api.g_number
  ,p_request_id                    in     number default hr_api.g_number
  ,p_business_group_id             in     number default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ,p_per_in_ler_id                 in     number default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_rank_process >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_rank_process
  (p_validate                      in     boolean           default false
  ,p_effective_date                in     date
  ,p_rank_process_id               in     number
  ,p_object_version_number         in     number
  );
--
end pqh_rank_process_api;

 

/
