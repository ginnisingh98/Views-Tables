--------------------------------------------------------
--  DDL for Package IRC_PARTY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PARTY_SWI" AUTHID CURRENT_USER As
/* $Header: irhzpswi.pkh 120.3.12010000.3 2009/06/04 10:17:08 vmummidi ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_candidate_internal >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_party_api.create_candidate_internal
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
PROCEDURE create_candidate_internal
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_id                    in     number
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_first_name                   in     varchar2  default null
  ,p_date_of_birth                in     date      default null
  ,p_email_address                in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_gender                       in     varchar2  default null
  ,p_marital_status               in     varchar2  default null
  ,p_previous_last_name           in     varchar2  default null
  ,p_middle_name                  in     varchar2  default null
  ,p_name_suffix                  in     varchar2  default null
  ,p_known_as                     in     varchar2  default null
  ,p_first_name_phonetic          in     varchar2  default null
  ,p_last_name_phonetic           in     varchar2  default null
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
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_nationality                  in     varchar2  default null
  ,p_national_identifier          in     varchar2  default null
  ,p_town_of_birth                in     varchar2  default null
  ,p_region_of_birth              in     varchar2  default null
  ,p_country_of_birth             in     varchar2  default null
  ,p_effective_start_date         out NOCOPY date
  ,p_effective_end_date           out NOCOPY date
  ,p_object_version_number        out nocopy number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_registered_user >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_party_api.create_registered_user
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
PROCEDURE create_registered_user
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_last_name                    in     varchar2
  ,p_first_name                   in     varchar2  default null
  ,p_date_of_birth                in     date      default null
  ,p_title                        in     varchar2  default null
  ,p_gender                       in     varchar2  default null
  ,p_marital_status               in     varchar2  default null
  ,p_previous_last_name           in     varchar2  default null
  ,p_middle_name                  in     varchar2  default null
  ,p_name_suffix                  in     varchar2  default null
  ,p_known_as                     in     varchar2  default null
  ,p_first_name_phonetic          in     varchar2  default null
  ,p_last_name_phonetic           in     varchar2  default null
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
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_effective_start_date         out NOCOPY date
  ,p_effective_end_date           out NOCOPY date
  ,p_person_id                    out NOCOPY number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< registered_user_application >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_party_api.registered_user_application
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
PROCEDURE registered_user_application
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_recruitment_person_id        in     number
  ,p_person_id                    in     number
  ,p_assignment_id                in     number
  ,p_application_received_date    in     date      default null
  ,p_vacancy_id                   in     number    default null
  ,p_posting_content_id           in     number    default null
  ,p_per_information4             in     per_all_people_f.per_information4%type   default null
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_recruitment_person_ovn          out nocopy number
  ,p_applicant_number                out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_registered_user >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_party_api.update_registered_user
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
PROCEDURE update_registered_user
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_first_name                   in     varchar2  default hr_api.g_varchar2
  ,p_last_name                    in     varchar2  default hr_api.g_varchar2
  ,p_date_of_birth                in     date      default hr_api.g_date
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_gender                       in     varchar2  default hr_api.g_varchar2
  ,p_marital_status               in     varchar2  default hr_api.g_varchar2
  ,p_previous_last_name           in     varchar2  default hr_api.g_varchar2
  ,p_middle_name                  in     varchar2  default hr_api.g_varchar2
  ,p_name_suffix                  in     varchar2  default hr_api.g_varchar2
  ,p_known_as                     in     varchar2  default hr_api.g_varchar2
  ,p_first_name_phonetic          in     varchar2  default hr_api.g_varchar2
  ,p_last_name_phonetic           in     varchar2  default hr_api.g_varchar2
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
  ,p_person_ovn                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_user >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_party_api.create_user
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
PROCEDURE create_user
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
   ,p_last_name                    in     varchar2  default null
   ,p_first_name                   in     varchar2  default null
   ,p_per_information_category     in     varchar2  default null
   ,p_per_information1             in     varchar2  default null
   ,p_per_information2             in     varchar2  default null
   ,p_per_information3             in     varchar2  default null
   ,p_per_information4             in     varchar2  default null
   ,p_per_information5             in     varchar2  default null
   ,p_per_information6             in     varchar2  default null
   ,p_per_information7             in     varchar2  default null
   ,p_per_information8             in     varchar2  default null
   ,p_per_information9             in     varchar2  default null
   ,p_per_information10            in     varchar2  default null
   ,p_per_information11            in     varchar2  default null
   ,p_per_information12            in     varchar2  default null
   ,p_per_information13            in     varchar2  default null
   ,p_per_information14            in     varchar2  default null
   ,p_per_information15            in     varchar2  default null
   ,p_per_information16            in     varchar2  default null
   ,p_per_information17            in     varchar2  default null
   ,p_per_information18            in     varchar2  default null
   ,p_per_information19            in     varchar2  default null
   ,p_per_information20            in     varchar2  default null
   ,p_per_information21            in     varchar2  default null
   ,p_per_information22            in     varchar2  default null
   ,p_per_information23            in     varchar2  default null
   ,p_per_information24            in     varchar2  default null
   ,p_per_information25            in     varchar2  default null
   ,p_per_information26            in     varchar2  default null
   ,p_per_information27            in     varchar2  default null
   ,p_per_information28            in     varchar2  default null
   ,p_per_information29            in     varchar2  default null
   ,p_per_information30            in     varchar2  default null
   ,p_return_status                OUT nocopy varchar2
   );
-- -------------------------------------------------------------------------
-- |------------------------< self_register_user >-------------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API is used to allow ex-employees, and other non-employee users
--      to self-identify with the system and get an iRecruitment login
--      e-mailed to them.
--
-- In Parameters:
--  Name                         Reqd Type     Description
--  p_current_email_address      Y    varchar2 The current e-mail address of
--                                             the user
--  p_responsibility_id          Y    number   The responsibility that the
--                                             user will be granted
--  p_resp_appl_id               Y    number   The application for the
--                                             responsibility that the user
--                                             will be granted
--  p_security_group_id          Y    number   The security group for the
--                                             responsibility that the user
--                                             will be granted
--  p_first_name                 N    varchar2 The first name that the user
--                                             self identifies with
--  p_last_name                  N    varchar2 The last name that the user
--                                             self identifies with
--  p_middle_names               N    varchar2 The middle name that the user
--                                             self identifies with
--  p_previous_last_name         N    varchar2 The previous last  name that the
--                                             user self identifies with
--  p_employee_number            N    varchar2 The employee number that the user
--                                             self identifies with
--  p_national_identifier        N    varchar2 The national identifier that the
--                                             user self identifies with
--  p_date_of_birth              N    date     The date of birth that the
--                                             user self identifies with
--  p_email_address              N    varchar2 The e-mail address that the
--                                             user self identifies with
--  p_home_phone_number          N    varchar2 The home phone number that the
--                                             user self identifies with
--  p_work_phone_number          N    varchar2 The work phone number that the
--                                             user self identifies with
--  p_address_line_1             N    varchar2 The first line of their home
--                                             address that the user
--                                             self identifies with
--  p_manager_last_name          N    varchar2 The last name of their
--                                             manager that the user
--                                             self identifies with
--  p_allow_access               N    varchar2 Indicates if the user wants their
--                                             account to be searchable by
--                                             recruiters
--  p_language                   N    varchar2 The default language for the
--                                             new account
--  p_user_name                  N    varchar2 Application username
--
-- Post Success:
--   If an user name is not provided, a new user account will be created for the
--   user with their new e-mail address and a notification will be sent to the
--   user with their new password in it.
--   If an user name is provided, it will be associated with the person and a
--   confirmation notification is sent to the user.
--   In either case any old user accounts will be disabled. Their e-mail address
--   will be updated on their person record. Notification preferences and work
--   preferences records will be created if they do not already exist.
--
-- Post Failure:
--   No records will be updated, and an appropriate error message will be raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
procedure self_register_user
   (p_validate                  IN     number   default hr_api.g_false_num
   ,p_current_email_address     IN     varchar2
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_first_name                IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_middle_names              IN     varchar2 default null
   ,p_previous_last_name        IN     varchar2 default null
   ,p_employee_number           IN     varchar2 default null
   ,p_national_identifier       IN     varchar2 default null
   ,p_date_of_birth             IN     date     default null
   ,p_email_address             IN     varchar2 default null
   ,p_home_phone_number         IN     varchar2 default null
   ,p_work_phone_number         IN     varchar2 default null
   ,p_address_line_1            IN     varchar2 default null
   ,p_manager_last_name         IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default 'N'
   ,p_language                  IN     varchar2 default null
   ,p_user_name                 IN     varchar2 default null
   ,p_return_status                OUT nocopy varchar2
   );
-- -------------------------------------------------------------------
-- |------------------------< get_first_page >-----------------------|
-- -------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure gets the menu name of the menu type home page
--  and the function defined at the top of this menu tree for a given
--  responsibility key
--
-- Pre-requisites
--  p_responsibility_key - the responsibility key
--
-- Post Success:
--  p_oasf will return function name at top of home page menu tree
--  p_oahp will return menu name of the menu of type home page
--
-- Post Failure:
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
procedure get_first_page(p_responsibility_key in     varchar2
                        ,p_oasf                  out nocopy varchar2
                        ,p_oahp                  out nocopy varchar2);
-- -------------------------------------------------------------------------
-- |------------------------< create_partial_user >------------------------|
-- -------------------------------------------------------------------------
PROCEDURE create_partial_user
  (p_user_name                  IN      varchar2
  ,p_start_date                 IN      date     default null
  ,p_email                      IN      varchar2 default null
  ,p_language                   IN      varchar2 default null
  ,p_last_name                  IN      varchar2 default null
  ,p_first_name                 IN      varchar2 default null
  ,p_reg_bg_id                  IN      number
  ,p_responsibility_id          IN      number
  ,p_resp_appl_id               IN      number
  ,p_security_group_id          IN      number
  ,p_allow_access               IN      varchar2 default null
  ,p_return_status              OUT     nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_user_byReferral >-----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_user_byReferral
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
  ,p_last_name                    in     varchar2  default null
  ,p_first_name                   in     varchar2  default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_person_id                    in     number    default null
  ,p_return_status                OUT nocopy varchar2
  );
--
end irc_party_swi;

/
