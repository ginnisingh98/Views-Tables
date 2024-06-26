--------------------------------------------------------
--  DDL for Package IRC_PENDING_DATA_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PENDING_DATA_BK2" AUTHID CURRENT_USER as
/* $Header: iripdapi.pkh 120.7 2008/02/21 14:22:51 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_PENDING_DATA_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_PENDING_DATA_b
  (p_email_address                in     varchar2
  ,p_last_name                    in     varchar2
  ,p_vacancy_id                   in     number
  ,p_first_name                   in     varchar2
  ,p_user_password                in     varchar2
  ,p_resume_file_name             in     varchar2
  ,p_resume_description           in     varchar2
  ,p_resume_mime_type             in     varchar2
  ,p_source_type                  in     varchar2
  ,p_job_post_source_name         in     varchar2
  ,p_posting_content_id           in     number
  ,p_person_id                    in     number
  ,p_processed                    in     varchar2
  ,p_sex                          in     varchar2
  ,p_date_of_birth                in     date
  ,p_per_information_category     in     varchar2
  ,p_per_information1             in     varchar2
  ,p_per_information2             in     varchar2
  ,p_per_information3             in     varchar2
  ,p_per_information4             in     varchar2
  ,p_per_information5             in     varchar2
  ,p_per_information6             in     varchar2
  ,p_per_information7             in     varchar2
  ,p_per_information8             in     varchar2
  ,p_per_information9             in     varchar2
  ,p_per_information10            in     varchar2
  ,p_per_information11            in     varchar2
  ,p_per_information12            in     varchar2
  ,p_per_information13            in     varchar2
  ,p_per_information14            in     varchar2
  ,p_per_information15            in     varchar2
  ,p_per_information16            in     varchar2
  ,p_per_information17            in     varchar2
  ,p_per_information18            in     varchar2
  ,p_per_information19            in     varchar2
  ,p_per_information20            in     varchar2
  ,p_per_information21            in     varchar2
  ,p_per_information22            in     varchar2
  ,p_per_information23            in     varchar2
  ,p_per_information24            in     varchar2
  ,p_per_information25            in     varchar2
  ,p_per_information26            in     varchar2
  ,p_per_information27            in     varchar2
  ,p_per_information28            in     varchar2
  ,p_per_information29            in     varchar2
  ,p_per_information30            in     varchar2
  ,p_error_message                in     varchar2
  ,p_creation_date                in     date
  ,p_last_update_date             in     date
  ,p_allow_access                 in     varchar2
  ,p_visitor_resp_key             in     varchar2
  ,p_visitor_resp_appl_id         in     number
  ,p_security_group_key           in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_PENDING_DATA_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_PENDING_DATA_a
  (p_email_address                in     varchar2
  ,p_last_name                    in     varchar2
  ,p_vacancy_id                   in     number
  ,p_first_name                   in     varchar2
  ,p_user_password                in     varchar2
  ,p_resume_file_name             in     varchar2
  ,p_resume_description           in     varchar2
  ,p_resume_mime_type             in     varchar2
  ,p_source_type                  in     varchar2
  ,p_job_post_source_name         in     varchar2
  ,p_posting_content_id           in     number
  ,p_person_id                    in     number
  ,p_processed                    in     varchar2
  ,p_sex                          in     varchar2
  ,p_date_of_birth                in     date
  ,p_per_information_category     in     varchar2
  ,p_per_information1             in     varchar2
  ,p_per_information2             in     varchar2
  ,p_per_information3             in     varchar2
  ,p_per_information4             in     varchar2
  ,p_per_information5             in     varchar2
  ,p_per_information6             in     varchar2
  ,p_per_information7             in     varchar2
  ,p_per_information8             in     varchar2
  ,p_per_information9             in     varchar2
  ,p_per_information10            in     varchar2
  ,p_per_information11            in     varchar2
  ,p_per_information12            in     varchar2
  ,p_per_information13            in     varchar2
  ,p_per_information14            in     varchar2
  ,p_per_information15            in     varchar2
  ,p_per_information16            in     varchar2
  ,p_per_information17            in     varchar2
  ,p_per_information18            in     varchar2
  ,p_per_information19            in     varchar2
  ,p_per_information20            in     varchar2
  ,p_per_information21            in     varchar2
  ,p_per_information22            in     varchar2
  ,p_per_information23            in     varchar2
  ,p_per_information24            in     varchar2
  ,p_per_information25            in     varchar2
  ,p_per_information26            in     varchar2
  ,p_per_information27            in     varchar2
  ,p_per_information28            in     varchar2
  ,p_per_information29            in     varchar2
  ,p_per_information30            in     varchar2
  ,p_error_message                in     varchar2
  ,p_creation_date                in     date
  ,p_last_update_date             in     date
  ,p_allow_access                 in     varchar2
  ,p_visitor_resp_key             in     varchar2
  ,p_visitor_resp_appl_id         in     number
  ,p_security_group_key           in     varchar2
  );
--
end IRC_PENDING_DATA_BK2;

/
