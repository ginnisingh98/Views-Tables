--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATION_EVENTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATION_EVENTS_SWI" AUTHID CURRENT_USER As
/* $Header: pqvleswi.pkh 115.1 2002/12/05 00:31:25 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< delete_validation_event >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_validation_events_api.delete_validation_event
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
PROCEDURE delete_validation_event
  (p_validation_event_id          in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< insert_validation_event >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_validation_events_api.insert_validation_event
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
PROCEDURE insert_validation_event
  (p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_event_type                   in     varchar2
  ,p_event_code                   in     varchar2
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_comments                     in     varchar2  default null
  ,p_validation_event_id             out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_validation_event >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_validation_events_api.update_validation_event
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
PROCEDURE update_validation_event
  (p_effective_date               in     date
  ,p_validation_event_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_validation_id                in     number    default hr_api.g_number
  ,p_event_type                   in     varchar2  default hr_api.g_varchar2
  ,p_event_code                   in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end pqh_fr_validation_events_swi;

 

/
