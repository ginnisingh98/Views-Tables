--------------------------------------------------------
--  DDL for Package PER_VACANCY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VACANCY_SWI" AUTHID CURRENT_USER As
/* $Header: pevacswi.pkh 120.4 2008/02/19 11:59:49 amikukum noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_vacancy >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_vacancy_api.create_vacancy
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
PROCEDURE create_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_requisition_id               in     number
  ,p_date_from                    in     date
  ,p_name                         in     varchar2
  ,p_security_method              in     varchar2  default null
  ,p_business_group_id            in     number
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_organization_id              in     number    default null
  ,p_people_group_id              in     number    default null
  ,p_location_id                  in     number    default null
  ,p_recruiter_id                 in     number    default null
  ,p_date_to                      in     date      default null
  ,p_description                  in     varchar2  default null
  ,p_number_of_openings           in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_budget_measurement_type      in     varchar2  default null
  ,p_budget_measurement_value     in     number    default null
  ,p_vacancy_category             in     varchar2  default null
  ,p_manager_id                   in     number    default null
  ,p_primary_posting_id           in     number    default null
  ,p_assessment_id                in     number    default null
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
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_object_version_number        out nocopy number
  ,p_vacancy_id                   in     number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_vacancy >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_vacancy_api.delete_vacancy
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
PROCEDURE delete_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_object_version_number        in     number
  ,p_vacancy_id                   in     number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_vacancy >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_vacancy_api.update_vacancy
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
PROCEDURE update_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_vacancy_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_recruiter_id                 in     number    default hr_api.g_number
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_security_method              in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_number_of_openings           in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_budget_measurement_type      in     varchar2  default hr_api.g_varchar2
  ,p_budget_measurement_value     in     number    default hr_api.g_number
  ,p_vacancy_category             in     varchar2  default hr_api.g_varchar2
  ,p_manager_id                   in     number    default hr_api.g_number
  ,p_primary_posting_id           in     number    default hr_api.g_number
  ,p_assessment_id                in     number    default hr_api.g_number
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
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_assignment_changed              out nocopy number
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
Function getNumberValueP2(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in number default hr_api.g_number)
  return NUMBER;
--
--
procedure finalize_transaction
(
 p_transaction_id       in         number
,p_event                in         varchar2
,p_return_status        out nocopy varchar2
);
-- ----------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenCommit >---------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenCommit(p_vacancy_id in number);
 --
-- ----------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenRejected >-------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenRejected(p_vacancy_id in number) ;

 -- ----------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenEditing >---------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenEdit(p_vacancy_id in number);

 -- ---------------------------------------------------------------------------
-- |-----------------------------< copyAttachments >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure copyAttachments(p_from_vacancy_id in number,p_to_vacancy_id in number);


end per_vacancy_swi;

/
