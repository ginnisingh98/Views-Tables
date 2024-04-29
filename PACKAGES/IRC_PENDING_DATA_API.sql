--------------------------------------------------------
--  DDL for Package IRC_PENDING_DATA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PENDING_DATA_API" AUTHID CURRENT_USER as
/* $Header: iripdapi.pkh 120.7 2008/02/21 14:22:51 viviswan noship $ */
/*#
 * This package contains APIs for maintaining pending data
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Pending Data
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pending_data >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates new pending data record.
 *
 * This table stores the details of job applications that have been submitted
 * on the high availability instance.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The API creates a new pending data record.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the pending data record and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_email_address The e-mail address of the registered user.
 * @param p_last_name The last name of the registered user.
 * @param p_vacancy_id Identifies the vacancy for which the person has applied.
 * @param p_first_name The first name of the registered user.
 * @param p_user_password Password of the registered user.
 * @param p_resume_file_name Name of the resume file.
 * @param p_resume_description Description of the resume.
 * @param p_resume_mime_type Resume's mime type.
 * @param p_source_type Job posting source type.
 * @param p_job_post_source_name Job posting source name.
 * @param p_posting_content_id Identifies the record from IRC_POSTING_CONTENTS
 * table.
 * @param p_person_id Uniquely identifies the registered user.
 * @param p_processed Processed flag for pending data.
 * @param p_sex Gender of the registered user.
 * @param p_date_of_birth Date of birth of the registered of user.
 * @param p_per_information_category Obsolete parameter, do not use.
 * @param p_per_information1 Developer descriptive flexfield segment.
 * @param p_per_information2 Developer descriptive flexfield segment.
 * @param p_per_information3 Developer descriptive flexfield segment.
 * @param p_per_information4 Developer descriptive flexfield segment.
 * @param p_per_information5 Developer descriptive flexfield segment.
 * @param p_per_information6 Developer descriptive flexfield segment.
 * @param p_per_information7 Developer descriptive flexfield segment.
 * @param p_per_information8 Developer descriptive flexfield segment.
 * @param p_per_information9 Developer descriptive flexfield segment.
 * @param p_per_information10 Developer descriptive flexfield segment.
 * @param p_per_information11 Developer descriptive flexfield segment.
 * @param p_per_information12 Developer descriptive flexfield segment.
 * @param p_per_information13 Developer descriptive flexfield segment.
 * @param p_per_information14 Developer descriptive flexfield segment.
 * @param p_per_information15 Developer descriptive flexfield segment.
 * @param p_per_information16 Developer descriptive flexfield segment.
 * @param p_per_information17 Developer descriptive flexfield segment.
 * @param p_per_information18 Developer descriptive flexfield segment.
 * @param p_per_information19 Developer descriptive flexfield segment.
 * @param p_per_information20 Developer descriptive flexfield segment.
 * @param p_per_information21 Developer descriptive flexfield segment.
 * @param p_per_information22 Developer descriptive flexfield segment.
 * @param p_per_information23 Developer descriptive flexfield segment.
 * @param p_per_information24 Developer descriptive flexfield segment.
 * @param p_per_information25 Developer descriptive flexfield segment.
 * @param p_per_information26 Developer descriptive flexfield segment.
 * @param p_per_information27 Developer descriptive flexfield segment.
 * @param p_per_information28 Developer descriptive flexfield segment.
 * @param p_per_information29 Developer descriptive flexfield segment.
 * @param p_per_information30 Developer descriptive flexfield segment.
 * @param p_error_message Stores error messages encountered while
 * processing the pending data.
 * @param p_creation_date Creation date of the job application.
 * @param p_last_update_date Last updated date.
 * @param p_allow_access Indicates if the user wants their account to be
 * searchable by recruiters. Indicates whether the user's information is
 * available when recruiters search for candidates.
 * @param p_user_guid Unique identifier of the user.
 * @param p_visitor_resp_key Identifies the responsibilitykey assigned to
 * the site visitor.
 * @param p_visitor_resp_appl_id Identifies the responsibility application
 * assigned to the site visitor.
 * @param p_security_group_key Identifies the security group key that the
 * applicant belong to Security Group Key.
 * @param p_pending_data_id Primary key of the pending data record.
 * @rep:displayname Create Pending Data.
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_PENDING_DATA
  (p_validate                       in     boolean  default false
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
  ,p_allow_access                   in     varchar2 default null
  ,p_user_guid                      in     raw      default null
  ,p_visitor_resp_key               in     varchar2 default null
  ,p_visitor_resp_appl_id           in     number   default null
  ,p_security_group_key             in     varchar2 default null
  ,p_pending_data_id                   out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_pending_data >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the pending data record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The pending data record must exsit.
 *
 * <p><b>Post Success</b><br>
 * The API updates the record.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the record and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pending_data_id Primary Key of the pending data record.
 * @param p_email_address The e-mail address of the registered user.
 * @param p_last_name The last name of the registered user.
 * @param p_vacancy_id The vacancy that the registered user is applying for.
 * @param p_first_name The first name of the registered user.
 * @param p_user_password Password of the registered user.
 * @param p_resume_file_name Name of the resume file.
 * @param p_resume_description Description of the resume.
 * @param p_resume_mime_type Resume's mime type.
 * @param p_source_type Job posting source type.
 * @param p_job_post_source_name Job posting source name.
 * @param p_posting_content_id Identifies the posting content of the vacancy
 * that the user is applying for.
 * @param p_person_id Uniquely identifies the registered user.
 * @param p_processed Processed flag of the pending data.
 * @param p_sex Gender of the registered user.
 * @param p_date_of_birth Date of birth of the registered of user.
 * @param p_per_information_category Obsolete parameter, do not use.
 * @param p_per_information1 Developer descriptive flexfield segment.
 * @param p_per_information2 Developer descriptive flexfield segment.
 * @param p_per_information3 Developer descriptive flexfield segment.
 * @param p_per_information4 Developer descriptive flexfield segment.
 * @param p_per_information5 Developer descriptive flexfield segment.
 * @param p_per_information6 Developer descriptive flexfield segment.
 * @param p_per_information7 Developer descriptive flexfield segment.
 * @param p_per_information8 Developer descriptive flexfield segment.
 * @param p_per_information9 Developer descriptive flexfield segment.
 * @param p_per_information10 Developer descriptive flexfield segment.
 * @param p_per_information11 Developer descriptive flexfield segment.
 * @param p_per_information12 Developer descriptive flexfield segment.
 * @param p_per_information13 Developer descriptive flexfield segment.
 * @param p_per_information14 Developer descriptive flexfield segment.
 * @param p_per_information15 Developer descriptive flexfield segment.
 * @param p_per_information16 Developer descriptive flexfield segment.
 * @param p_per_information17 Developer descriptive flexfield segment.
 * @param p_per_information18 Developer descriptive flexfield segment.
 * @param p_per_information19 Developer descriptive flexfield segment.
 * @param p_per_information20 Developer descriptive flexfield segment.
 * @param p_per_information21 Developer descriptive flexfield segment.
 * @param p_per_information22 Developer descriptive flexfield segment.
 * @param p_per_information23 Developer descriptive flexfield segment.
 * @param p_per_information24 Developer descriptive flexfield segment.
 * @param p_per_information25 Developer descriptive flexfield segment.
 * @param p_per_information26 Developer descriptive flexfield segment.
 * @param p_per_information27 Developer descriptive flexfield segment.
 * @param p_per_information28 Developer descriptive flexfield segment.
 * @param p_per_information29 Developer descriptive flexfield segment.
 * @param p_per_information30 Developer descriptive flexfield segment.
 * @param p_error_message Errors encountered.
 * @param p_creation_date Creation date.
 * @param p_last_update_date Last updated date.
 * @param p_allow_access Indicates whether the user's information is available
 * to recruiters when they search for candidates.
 * @param p_user_guid Unique identifier for user.
 * @param p_visitor_resp_key Identifies the responsibility key assigned to
 * the site visitor.
 * @param p_visitor_resp_appl_id Identifies the responsibility application
 * assigned to the site visitor.
 * @param p_security_group_key Security Group Key.
 * @rep:displayname Update Pending Data
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_PENDING_DATA
  (p_validate                     in     boolean   default false
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
  ,p_allow_access                 in     varchar2 default hr_api.g_varchar2
  ,p_user_guid                    in     raw      default null
  ,p_visitor_resp_key             in     varchar2 default hr_api.g_varchar2
  ,p_visitor_resp_appl_id         in     number   default hr_api.g_number
  ,p_security_group_key           in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pending_data >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a pending data record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The pending data record must exist.
 *
 * <p><b>Post Success</b><br>
 * The pending data record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The pending data record is not deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pending_data_id The primary key of the pending data record.
 * @rep:displayname Delete Pending Data
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_PENDING_DATA
  (p_validate                      in     boolean  default false
  ,p_pending_data_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< process_applications >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API processes pending data applications.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * Successfully processed records are deleted from the pending data table.
 *
 * <p><b>Post Failure</b><br>
 * Records that are not successfully processed are updated with the processed
 * flag set to 'E' and the error_message column is populated appropriately.
 * @param p_server_name Name of the Node.
 * @rep:displayname Process Applications
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure PROCESS_APPLICATIONS
(
  p_server_name         in     fnd_nodes.node_name%type
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< send_notifications >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API sends notifications to the user.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * Notification is sent successfully with the appropriate comments.
 *
 * <p><b>Post Failure</b><br>
 * Notifications are not sent, and an error is raised.
 *
 * @rep:displayname Send Notifications
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure SEND_NOTIFICATIONS;
--
end IRC_PENDING_DATA_API;

/
