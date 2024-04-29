--------------------------------------------------------
--  DDL for Package IRC_PROF_AREA_CRITERIA_VAL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PROF_AREA_CRITERIA_VAL_SWI" AUTHID CURRENT_USER As
/* $Header: irpcvswi.pkh 120.0 2005/10/03 14:59 rbanda noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_prof_area_criteria >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_prof_area_criteria_val_api.create_prof_area_criteria
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
PROCEDURE create_prof_area_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_search_criteria_id           in     number
  ,p_professional_area            in     varchar2
  ,p_prof_area_criteria_value_id  in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_prof_area_criteria >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_prof_area_criteria_val_api.delete_prof_area_criteria
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
PROCEDURE delete_prof_area_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_prof_area_criteria_value_id  in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end irc_prof_area_criteria_val_swi;

 

/
