--------------------------------------------------------
--  DDL for Package IRC_VARIABLE_COMP_ELEMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VARIABLE_COMP_ELEMENT_SWI" AUTHID CURRENT_USER As
/* $Header: irvceswi.pkh 120.1 2006/03/13 02:36:36 cnholmes noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------< create_variable_compensation >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_variable_comp_element_api.create_variable_compensation
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
PROCEDURE create_variable_compensation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_vacancy_id                   in     number
  ,p_variable_comp_lookup         in     varchar2
  ,p_effective_date               in     date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< delete_variable_compensation >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_variable_comp_element_api.delete_variable_compensation
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
PROCEDURE delete_variable_compensation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_vacancy_id                   in     number
  ,p_variable_comp_lookup         in     varchar2
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
--
procedure process_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
);
--
end irc_variable_comp_element_swi;

 

/
