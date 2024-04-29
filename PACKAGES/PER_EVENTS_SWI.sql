--------------------------------------------------------
--  DDL for Package PER_EVENTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EVENTS_SWI" AUTHID CURRENT_USER As
/* $Header: peevtswi.pkh 115.2 2002/12/05 15:45:32 pkakar ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_event >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_events_api.create_event
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
PROCEDURE create_event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_date_start                   in     date
  ,p_type                         in     varchar2
  ,p_business_group_id            in     number    default null
  ,p_location_id                  in     number    default null
  ,p_internal_contact_person_id   in     number    default null
  ,p_organization_run_by_id       in     number    default null
  ,p_assignment_id                in     number    default null
  ,p_contact_telephone_number     in     varchar2  default null
  ,p_date_end                     in     date      default null
  ,p_emp_or_apl                   in     varchar2  default null
  ,p_event_or_interview           in     varchar2  default null
  ,p_external_contact             in     varchar2  default null
  ,p_time_end                     in     varchar2  default null
  ,p_time_start                   in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_party_id                     in     number    default null
  ,p_event_id                     in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_event >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_events_api.delete_event
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
PROCEDURE delete_event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_event_id                     in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_event >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_events_api.update_event
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
PROCEDURE update_event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_internal_contact_person_id   in     number    default hr_api.g_number
  ,p_organization_run_by_id       in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_contact_telephone_number     in     varchar2  default hr_api.g_varchar2
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_emp_or_apl                   in     varchar2  default hr_api.g_varchar2
  ,p_event_or_interview           in     varchar2  default hr_api.g_varchar2
  ,p_external_contact             in     varchar2  default hr_api.g_varchar2
  ,p_time_end                     in     varchar2  default hr_api.g_varchar2
  ,p_time_start                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_date_start                   in     date      default hr_api.g_date
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_party_id                     in     number    default hr_api.g_number
  ,p_event_id                     in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end per_events_swi;

 

/
