--------------------------------------------------------
--  DDL for Package HR_APPLICATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICATION_SWI" AUTHID CURRENT_USER As
/* $Header: hraplswi.pkh 115.1 2002/12/03 06:07:36 hjonnala ship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< update_apl_details >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_application_api.update_apl_details
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
PROCEDURE update_apl_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_current_employer             in     varchar2  default hr_api.g_varchar2
  ,p_projected_hire_date          in     date      default hr_api.g_date
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end hr_application_swi;

 

/
