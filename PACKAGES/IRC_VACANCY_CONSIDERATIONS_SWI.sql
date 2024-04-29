--------------------------------------------------------
--  DDL for Package IRC_VACANCY_CONSIDERATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VACANCY_CONSIDERATIONS_SWI" AUTHID CURRENT_USER As
/* $Header: irivcswi.pkh 120.0 2005/07/26 15:12:48 mbocutt noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------< create_vacancy_consideration >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_vacancy_considerations_api.create_vacancy_consideration
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
PROCEDURE create_vacancy_consideration
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_vacancy_consideration_id     in     number
  ,p_person_id                    in     number
  ,p_vacancy_id                   in     number
  ,p_consideration_status         in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< delete_vacancy_consideration >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_vacancy_considerations_api.delete_vacancy_consideration
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
PROCEDURE delete_vacancy_consideration
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_vacancy_consideration_id     in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< update_vacancy_consideration >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_vacancy_considerations_api.update_vacancy_consideration
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
PROCEDURE update_vacancy_consideration
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_vacancy_consideration_id     in     number
  ,p_party_id                     in     number    default hr_api.g_number
  ,p_consideration_status         in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
end irc_vacancy_considerations_swi;

 

/
