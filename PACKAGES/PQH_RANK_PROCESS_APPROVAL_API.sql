--------------------------------------------------------
--  DDL for Package PQH_RANK_PROCESS_APPROVAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RANK_PROCESS_APPROVAL_API" AUTHID CURRENT_USER as
/* $Header: pqrapapi.pkh 120.1 2005/06/03 11:58:56 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_rank_process_approval >---------------------|
-- ----------------------------------------------------------------------------
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
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_rank_process_approval
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rank_process_approval_id      out nocopy     number
  ,p_rank_process_id               in     number
  ,p_approval_date                 in     date
  ,p_supervisor_id                 in     number  default null
  ,p_system_rank                   in     number
  ,p_population_count              in     number  default null
  ,p_proposed_rank                 in     number  default null
  ,p_object_version_number         out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_rank_process_approval >---------------------|
-- ----------------------------------------------------------------------------
procedure update_rank_process_approval
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rank_process_approval_id      in     number
  ,p_rank_process_id               in     number
  ,p_approval_date                 in     date
  ,p_supervisor_id                 in     number  default hr_api.g_number
  ,p_system_rank                   in     number  default hr_api.g_number
  ,p_population_count              in     number  default hr_api.g_number
  ,p_proposed_rank                 in     number  default hr_api.g_number
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_rank_process_approval >---------------------|
-- ----------------------------------------------------------------------------
procedure delete_rank_process_approval
  (p_validate                      in     boolean           default false
  ,p_effective_date                in     date
  ,p_rank_process_approval_id      in     number
  ,p_object_version_number         in     number
  );
--
end pqh_rank_process_approval_api;

 

/
