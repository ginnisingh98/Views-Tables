--------------------------------------------------------
--  DDL for Package PER_REC_ACTIVITY_FOR_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REC_ACTIVITY_FOR_SWI" AUTHID CURRENT_USER As
/* $Header: percfswi.pkh 120.1 2006/03/13 02:33:10 cnholmes noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_rec_activity_for >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_rec_activity_for_api.create_rec_activity_for
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
PROCEDURE create_rec_activity_for
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_activity_for_id          in     number
  ,p_business_group_id            in     number
  ,p_vacancy_id                   in     number
  ,p_rec_activity_id              in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_rec_activity_for >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_rec_activity_for_api.delete_rec_activity_for
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
PROCEDURE delete_rec_activity_for
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_activity_for_id          in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_rec_activity_for >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_rec_activity_for_api.update_rec_activity_for
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
PROCEDURE update_rec_activity_for
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_activity_for_id          in     number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_rec_activity_id              in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
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
end per_rec_activity_for_swi;

 

/
