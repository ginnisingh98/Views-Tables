--------------------------------------------------------
--  DDL for Package PER_SOLUTIONS_SELECTED_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTIONS_SELECTED_SWI" AUTHID CURRENT_USER As
/* $Header: pesosswi.pkh 115.0 2003/03/14 02:11:04 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_solutions_selected >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_solutions_selected_api.create_solutions_selected
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_solutions_selected
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_solution_id                  in     number
  ,p_solution_set_name            in     varchar2
  ,p_user_id                      in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_solutions_selected >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_solutions_selected_api.delete_solutions_selected
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_solutions_selected
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_solution_id                  in     number
  ,p_solution_set_name            in     varchar2
  ,p_user_id                      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_solutions_selected >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_solutions_selected_api.update_solutions_selected
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_solutions_selected
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_solution_id                  in     number
  ,p_solution_set_name            in     varchar2
  ,p_user_id                      in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end per_solutions_selected_swi;

 

/
