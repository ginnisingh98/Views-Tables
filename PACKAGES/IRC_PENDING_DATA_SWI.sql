--------------------------------------------------------
--  DDL for Package IRC_PENDING_DATA_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PENDING_DATA_SWI" AUTHID CURRENT_USER As
/* $Header: iripdswi.pkh 120.0 2005/07/26 15:10:04 mbocutt noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pending_data >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_pending_data_api.create_pending_data
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
PROCEDURE create_pending_data
  (p_validate                       in     number   default hr_api.g_false_num
  ,p_email_address                  in     varchar2
  ,p_last_name                      in     varchar2
  ,p_vacancy_id                     in     number   default null
  ,p_first_name                     in     varchar2 default null
  ,p_user_password                  in     varchar2 default null
  ,p_resume_file_name               in     varchar2 default null
  ,p_resume_description             in     varchar2 default null
  ,p_resume_mime_type               in     varchar2 default null
  ,p_source_type                    in     varchar2 default null
  ,p_job_post_source_name           in     varchar2 default null
  ,p_posting_content_id             in     number   default null
  ,p_person_id                      in     number   default null
  ,p_processed                      in     varchar2 default null
  ,p_sex                            in     varchar2 default null
  ,p_date_of_birth                  in     date     default null
  ,p_per_information_category       in     varchar2 default null
  ,p_per_information1               in     varchar2 default null
  ,p_per_information2               in     varchar2 default null
  ,p_per_information3               in     varchar2 default null
  ,p_per_information4               in     varchar2 default null
  ,p_per_information5               in     varchar2 default null
  ,p_per_information6               in     varchar2 default null
  ,p_per_information7               in     varchar2 default null
  ,p_per_information8               in     varchar2 default null
  ,p_per_information9               in     varchar2 default null
  ,p_per_information10              in     varchar2 default null
  ,p_per_information11              in     varchar2 default null
  ,p_per_information12              in     varchar2 default null
  ,p_per_information13              in     varchar2 default null
  ,p_per_information14              in     varchar2 default null
  ,p_per_information15              in     varchar2 default null
  ,p_per_information16              in     varchar2 default null
  ,p_per_information17              in     varchar2 default null
  ,p_per_information18              in     varchar2 default null
  ,p_per_information19              in     varchar2 default null
  ,p_per_information20              in     varchar2 default null
  ,p_per_information21              in     varchar2 default null
  ,p_per_information22              in     varchar2 default null
  ,p_per_information23              in     varchar2 default null
  ,p_per_information24              in     varchar2 default null
  ,p_per_information25              in     varchar2 default null
  ,p_per_information26              in     varchar2 default null
  ,p_per_information27              in     varchar2 default null
  ,p_per_information28              in     varchar2 default null
  ,p_per_information29              in     varchar2 default null
  ,p_per_information30              in     varchar2 default null
  ,p_error_message                  in     varchar2 default null
  ,p_creation_date                  in     date
  ,p_last_update_date               in     date
  ,p_pending_data_id                in     number
  ,p_allow_access                   in     varchar2 default null
  ,p_user_guid                      in     raw      default null
  ,p_visitor_resp_key               in     varchar2 default null
  ,p_visitor_resp_appl_id           in     number   default null
  ,p_security_group_key             in     varchar2 default null
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_pending_data >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_pending_data_api.update_pending_data
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
PROCEDURE update_pending_data
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pending_data_id              in     number
  ,p_email_address                in     varchar2  default hr_api.g_varchar2
  ,p_last_name                    in     varchar2  default hr_api.g_varchar2
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_first_name                   in     varchar2  default hr_api.g_varchar2
  ,p_user_password                in     varchar2  default hr_api.g_varchar2
  ,p_resume_file_name             in     varchar2  default hr_api.g_varchar2
  ,p_resume_description           in     varchar2  default hr_api.g_varchar2
  ,p_resume_mime_type             in     varchar2  default hr_api.g_varchar2
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_processed                    in     varchar2  default hr_api.g_varchar2
  ,p_sex                          in     varchar2  default hr_api.g_varchar2
  ,p_date_of_birth                in     date      default hr_api.g_date
  ,p_per_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ,p_error_message                in     varchar2  default hr_api.g_varchar2
  ,p_creation_date                in     date      default hr_api.g_date
  ,p_last_update_date             in     date      default hr_api.g_date
  ,p_allow_access                 in     varchar2  default hr_api.g_varchar2
  ,p_user_guid                    in     raw      default null
  ,p_visitor_resp_key             in     varchar2 default hr_api.g_varchar2
  ,p_visitor_resp_appl_id         in     number   default hr_api.g_number
  ,p_security_group_key           in     varchar2 default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_pending_data >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_pending_data_api.delete_pending_data
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
PROCEDURE delete_pending_data
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pending_data_id              in     number
  ,p_return_status                out nocopy varchar2
  );
 end irc_pending_data_swi;

 

/
