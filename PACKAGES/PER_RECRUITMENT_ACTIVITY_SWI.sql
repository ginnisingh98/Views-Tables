--------------------------------------------------------
--  DDL for Package PER_RECRUITMENT_ACTIVITY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RECRUITMENT_ACTIVITY_SWI" AUTHID CURRENT_USER As
/* $Header: peraaswi.pkh 120.1 2006/03/13 02:38:52 cnholmes noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_recruitment_activity >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_recruitment_activity_api.create_recruitment_activity
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
PROCEDURE create_recruitment_activity
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number
  ,p_date_start                   in     date
  ,p_name                         in     varchar2
  ,p_authorising_person_id        in     number    default null
  ,p_run_by_organization_id       in     number    default null
  ,p_internal_contact_person_id   in     number    default null
  ,p_parent_recruitment_activity  in     number    default null
  ,p_currency_code                in     varchar2  default null
  ,p_actual_cost                  in     varchar2  default null
  ,p_comments                     in     long      default null
  ,p_contact_telephone_number     in     varchar2  default null
  ,p_date_closing                 in     date      default null
  ,p_date_end                     in     date      default null
  ,p_external_contact             in     varchar2  default null
  ,p_planned_cost                 in     varchar2  default null
  ,p_recruiting_site_id           in     number    default null
  ,p_recruiting_site_response     in     varchar2  default null
  ,p_last_posted_date             in     date      default null
  ,p_type                         in     varchar2  default null
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
  ,p_posting_content_id           in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_recruitment_activity_id      in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_recruitment_activity >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_recruitment_activity_api.delete_recruitment_activity
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
PROCEDURE delete_recruitment_activity
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_object_version_number        in     number
  ,p_recruitment_activity_id      in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_recruitment_activity >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_recruitment_activity_api.update_recruitment_activity
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
PROCEDURE update_recruitment_activity
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_recruitment_activity_id      in     number
  ,p_authorising_person_id        in     number    default hr_api.g_number
  ,p_run_by_organization_id       in     number    default hr_api.g_number
  ,p_internal_contact_person_id   in     number    default hr_api.g_number
  ,p_parent_recruitment_activity  in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_date_start                   in     date      default hr_api.g_date
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_actual_cost                  in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     long      default hr_api.g_varchar2
  ,p_contact_telephone_number     in     varchar2  default hr_api.g_varchar2
  ,p_date_closing                 in     date      default hr_api.g_date
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_external_contact             in     varchar2  default hr_api.g_varchar2
  ,p_planned_cost                 in     varchar2  default hr_api.g_varchar2
  ,p_recruiting_site_id           in     number    default hr_api.g_number
  ,p_recruiting_site_response     in     varchar2  default hr_api.g_varchar2
  ,p_last_posted_date             in     date      default hr_api.g_date
  ,p_type                         in     varchar2  default hr_api.g_varchar2
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
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
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
function get_posting_date
  (p_type_flag varchar2, p_current_start_date date,
   p_internal_start_date date, p_dates_editable varchar2) return date;
--
FUNCTION get_internal_posting_days return number;
--
end per_recruitment_activity_swi;

 

/
