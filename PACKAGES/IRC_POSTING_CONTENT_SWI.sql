--------------------------------------------------------
--  DDL for Package IRC_POSTING_CONTENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_POSTING_CONTENT_SWI" AUTHID CURRENT_USER As
/* $Header: iripcswi.pkh 120.2 2006/09/19 10:18:24 cnholmes noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_posting_content >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_posting_content_api.create_posting_content
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
PROCEDURE create_posting_content
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_display_manager_info         in     varchar2
  ,p_display_recruiter_info       in     varchar2
  ,p_language_code                in     varchar2  default null
  ,p_name                         in     varchar2
  ,p_org_name                     in     varchar2  default null
  ,p_org_description              in     varchar2  default null
  ,p_job_title                    in     varchar2  default null
  ,p_brief_description            in     varchar2  default null
  ,p_detailed_description         in     varchar2  default null
  ,p_job_requirements             in     varchar2  default null
  ,p_additional_details           in     varchar2  default null
  ,p_how_to_apply                 in     varchar2  default null
  ,p_benefit_info                 in     varchar2  default null
  ,p_image_url                    in     varchar2  default null
  ,p_alt_image_url                in     varchar2  default null
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
  ,p_ipc_information_category     in     varchar2  default null
  ,p_ipc_information1             in     varchar2  default null
  ,p_ipc_information2             in     varchar2  default null
  ,p_ipc_information3             in     varchar2  default null
  ,p_ipc_information4             in     varchar2  default null
  ,p_ipc_information5             in     varchar2  default null
  ,p_ipc_information6             in     varchar2  default null
  ,p_ipc_information7             in     varchar2  default null
  ,p_ipc_information8             in     varchar2  default null
  ,p_ipc_information9             in     varchar2  default null
  ,p_ipc_information10            in     varchar2  default null
  ,p_ipc_information11            in     varchar2  default null
  ,p_ipc_information12            in     varchar2  default null
  ,p_ipc_information13            in     varchar2  default null
  ,p_ipc_information14            in     varchar2  default null
  ,p_ipc_information15            in     varchar2  default null
  ,p_ipc_information16            in     varchar2  default null
  ,p_ipc_information17            in     varchar2  default null
  ,p_ipc_information18            in     varchar2  default null
  ,p_ipc_information19            in     varchar2  default null
  ,p_ipc_information20            in     varchar2  default null
  ,p_ipc_information21            in     varchar2  default null
  ,p_ipc_information22            in     varchar2  default null
  ,p_ipc_information23            in     varchar2  default null
  ,p_ipc_information24            in     varchar2  default null
  ,p_ipc_information25            in     varchar2  default null
  ,p_ipc_information26            in     varchar2  default null
  ,p_ipc_information27            in     varchar2  default null
  ,p_ipc_information28            in     varchar2  default null
  ,p_ipc_information29            in     varchar2  default null
  ,p_ipc_information30            in     varchar2  default null
  ,p_date_approved                in     date      default null
  ,p_posting_content_id           in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_posting_content >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_posting_content_api.delete_posting_content
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
PROCEDURE delete_posting_content
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_posting_content_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_posting_content >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_posting_content_api.update_posting_content
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
PROCEDURE update_posting_content
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_posting_content_id           in     number
  ,p_display_manager_info         in     varchar2  default hr_api.g_varchar2
  ,p_display_recruiter_info       in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_org_name                     in     varchar2  default hr_api.g_varchar2
  ,p_org_description              in     varchar2  default hr_api.g_varchar2
  ,p_job_title                    in     varchar2  default hr_api.g_varchar2
  ,p_brief_description            in     varchar2  default hr_api.g_varchar2
  ,p_detailed_description         in     varchar2  default hr_api.g_varchar2
  ,p_job_requirements             in     varchar2  default hr_api.g_varchar2
  ,p_additional_details           in     varchar2  default hr_api.g_varchar2
  ,p_how_to_apply                 in     varchar2  default hr_api.g_varchar2
  ,p_benefit_info                 in     varchar2  default hr_api.g_varchar2
  ,p_image_url                    in     varchar2  default hr_api.g_varchar2
  ,p_alt_image_url                in     varchar2  default hr_api.g_varchar2
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
  ,p_ipc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_ipc_information30            in     varchar2  default hr_api.g_varchar2
  ,p_date_approved                in     date      default hr_api.g_date
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
Function getClobValue(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in varchar2 default hr_api.g_varchar2)
return varchar2;
--
end irc_posting_content_swi;

/
