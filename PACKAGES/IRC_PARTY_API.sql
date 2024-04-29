--------------------------------------------------------
--  DDL for Package IRC_PARTY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PARTY_API" AUTHID CURRENT_USER as
/* $Header: irhzpapi.pkh 120.15.12010000.5 2010/04/16 14:57:54 vmummidi ship $ */
/*#
 * This package contains recruiting candidate APIs.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Party
*/
--
-- globals to store person_id and ovn of person record that
-- has been updated
   g_person_id            number   default  hr_api.g_number;
   g_ovn_for_person       number   default  hr_api.g_number;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_candidate_internal >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a person record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * A person record is created.
 *
 * <p><b>Post Failure</b><br>
 * The API fails to create the person and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id Uniquely identifies the business group in which
 * the previous employer record is created. It must be the same as the person's
 * business group.
 * @param p_last_name The last name of the registered user
 * @param p_first_name The first name of the registered user
 * @param p_date_of_birth The date of birth of the registered user
 * @param p_email_address The e-mail address of the registered user
 * @param p_title The title of the registered user. Valid values are defined by
 * the 'TITLE' lookup type
 * @param p_gender The gender of the registered user. Valid values are defined
 * by the 'SEX' lookup type
 * @param p_marital_status The marital status of the registered user. Valid
 * values are defined by the 'MAR_STATUS' lookup type
 * @param p_previous_last_name The previous last name of the registered user.
 * @param p_middle_name The middle name of the registered user.
 * @param p_name_suffix Suffix after the person's last name.
 * @param p_known_as The name by which the registered user is known.
 * @param p_first_name_phonetic Obsolete parameter. Do not use
 * @param p_last_name_phonetic Obsolete parameter. Do not use
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
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
 * @param p_nationality The nationality of the user
 * @param p_national_identifier The national identifier of the user
 * @param p_town_of_birth The town of birth of the user
 * @param p_region_of_birth  The region of birth of the user
 * @param p_country_of_birth The country of birth of the user
 * @param p_allow_access Indicates whether the user's details are available to
 * recruiters when they search for candidates in iRecruitment.
 * @param p_party_id Party ID for the person.
 * @param p_start_date The start date of the registered user's account.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created registered user. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created registered user. If p_validate is true,
 * then set to null.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * registered user created. If p_validate is true, then set to null.
 * @rep:displayname Create Candidate Internal
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_candidate_internal
   (p_validate                  IN     boolean  default false
   ,p_business_group_id         IN     number
   ,p_last_name                 IN     varchar2
   ,p_first_name                IN     varchar2 default null
   ,p_date_of_birth             IN     date     default null
   ,p_email_address             IN     varchar2 default null
   ,p_title                     IN     varchar2 default null
   ,p_gender                    IN     varchar2 default null
   ,p_marital_status            IN     varchar2 default null
   ,p_previous_last_name        IN     varchar2 default null
   ,p_middle_name               IN     varchar2 default null
   ,p_name_suffix               IN     varchar2 default null
   ,p_known_as                  IN     varchar2 default null
   ,p_first_name_phonetic       IN     varchar2 default null
   ,p_last_name_phonetic        IN     varchar2 default null
   ,p_attribute_category        IN     varchar2 default null
   ,p_attribute1                IN     varchar2 default null
   ,p_attribute2                IN     varchar2 default null
   ,p_attribute3                IN     varchar2 default null
   ,p_attribute4                IN     varchar2 default null
   ,p_attribute5                IN     varchar2 default null
   ,p_attribute6                IN     varchar2 default null
   ,p_attribute7                IN     varchar2 default null
   ,p_attribute8                IN     varchar2 default null
   ,p_attribute9                IN     varchar2 default null
   ,p_attribute10               IN     varchar2 default null
   ,p_attribute11               IN     varchar2 default null
   ,p_attribute12               IN     varchar2 default null
   ,p_attribute13               IN     varchar2 default null
   ,p_attribute14               IN     varchar2 default null
   ,p_attribute15               IN     varchar2 default null
   ,p_attribute16               IN     varchar2 default null
   ,p_attribute17               IN     varchar2 default null
   ,p_attribute18               IN     varchar2 default null
   ,p_attribute19               IN     varchar2 default null
   ,p_attribute20               IN     varchar2 default null
   ,p_attribute21               IN     varchar2 default null
   ,p_attribute22               IN     varchar2 default null
   ,p_attribute23               IN     varchar2 default null
   ,p_attribute24               IN     varchar2 default null
   ,p_attribute25               IN     varchar2 default null
   ,p_attribute26               IN     varchar2 default null
   ,p_attribute27               IN     varchar2 default null
   ,p_attribute28               IN     varchar2 default null
   ,p_attribute29               IN     varchar2 default null
   ,p_attribute30               IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   ,p_nationality               IN     varchar2  default null
   ,p_national_identifier       IN     varchar2  default null
   ,p_town_of_birth             IN     varchar2  default null
   ,p_region_of_birth           IN     varchar2  default null
   ,p_country_of_birth          IN     varchar2  default null
   ,p_allow_access              IN     varchar2 default null
   ,p_party_id                  IN     number default null
   ,p_start_date                IN     date default null
   ,p_effective_start_date      OUT NOCOPY date
   ,p_effective_end_date        OUT NOCOPY date
   ,p_person_id                 OUT NOCOPY number
   );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_registered_user >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a registered user with work preferences and notification
 * preferences.
 *
 * This API does not create a login for the registered user. To create the
 * registered user complete with a login, call the create_user API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates a registered user.
 *
 * <p><b>Post Failure</b><br>
 * The API fails to create a registered user and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_last_name The last name of the registered user.
 * @param p_first_name The first name of the registered user.
 * @param p_date_of_birth The date of birth of the registered user.
 * @param p_email_address The e-mail address of the registered user.
 * @param p_title The title of the registered user. Valid values are defined by
 * the 'TITLE' lookup type.
 * @param p_gender The gender of the registered user. Valid values are defined
 * by the 'SEX' lookup type.
 * @param p_marital_status The marital status of the registered user. Valid
 * values are defined by the 'MAR_STATUS' lookup type.
 * @param p_previous_last_name The previous last name of the registered user.
 * @param p_middle_name The middle name of the registered user.
 * @param p_name_suffix Suffix after the person's last name.
 * @param p_known_as The name by which the registered user is known.
 * @param p_first_name_phonetic Obsolete parameter. Do not use.
 * @param p_last_name_phonetic Obsolete parameter. Do not use.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
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
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created registered user. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created registered user. If p_validate is true,
 * then set to null.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * registered user created. If p_validate is true, then set to null.
 * @param p_allow_access Indicates whether the user's details are available to
 * recruiters when they search for candidates in iRecruitment.
 * @param p_start_date The start date of the registered user's account.
 * @rep:displayname Create Registered User
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_registered_user
   (p_validate                  IN     boolean  default false
   ,p_last_name                 IN     varchar2
   ,p_first_name                IN     varchar2 default null
   ,p_date_of_birth             IN     date     default null
   ,p_email_address             IN     varchar2 default null
   ,p_title                     IN     varchar2 default null
   ,p_gender                    IN     varchar2 default null
   ,p_marital_status            IN     varchar2 default null
   ,p_previous_last_name        IN     varchar2 default null
   ,p_middle_name               IN     varchar2 default null
   ,p_name_suffix               IN     varchar2 default null
   ,p_known_as                  IN     varchar2 default null
   ,p_first_name_phonetic       IN     varchar2 default null
   ,p_last_name_phonetic        IN     varchar2 default null
   ,p_attribute_category        IN     varchar2 default null
   ,p_attribute1                IN     varchar2 default null
   ,p_attribute2                IN     varchar2 default null
   ,p_attribute3                IN     varchar2 default null
   ,p_attribute4                IN     varchar2 default null
   ,p_attribute5                IN     varchar2 default null
   ,p_attribute6                IN     varchar2 default null
   ,p_attribute7                IN     varchar2 default null
   ,p_attribute8                IN     varchar2 default null
   ,p_attribute9                IN     varchar2 default null
   ,p_attribute10               IN     varchar2 default null
   ,p_attribute11               IN     varchar2 default null
   ,p_attribute12               IN     varchar2 default null
   ,p_attribute13               IN     varchar2 default null
   ,p_attribute14               IN     varchar2 default null
   ,p_attribute15               IN     varchar2 default null
   ,p_attribute16               IN     varchar2 default null
   ,p_attribute17               IN     varchar2 default null
   ,p_attribute18               IN     varchar2 default null
   ,p_attribute19               IN     varchar2 default null
   ,p_attribute20               IN     varchar2 default null
   ,p_attribute21               IN     varchar2 default null
   ,p_attribute22               IN     varchar2 default null
   ,p_attribute23               IN     varchar2 default null
   ,p_attribute24               IN     varchar2 default null
   ,p_attribute25               IN     varchar2 default null
   ,p_attribute26               IN     varchar2 default null
   ,p_attribute27               IN     varchar2 default null
   ,p_attribute28               IN     varchar2 default null
   ,p_attribute29               IN     varchar2 default null
   ,p_attribute30               IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default null
   ,p_start_date                IN     date     default null
   ,p_effective_start_date      OUT NOCOPY date
   ,p_effective_end_date        OUT NOCOPY date
   ,p_person_id                 OUT NOCOPY number
   );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_registered_user >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a registered user's details.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The registered user must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The registered user's information will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The registered user's information will not be updated, and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes
 * into force.
 * @param p_person_id Identifies the registered user record to be updated.
 * @param p_first_name The first name of the registered user.
 * @param p_last_name The last name of the registered user.
 * @param p_date_of_birth The date of birth of the registered user.
 * @param p_title The title of the registered user. Valid values are defined by
 * the 'TITLE' lookup type.
 * @param p_gender The gender of the registered user. Valid values are defined
 * by the 'SEX' lookup type.
 * @param p_marital_status The marital status of the registered user. Valid
 * values are defined by the 'MAR_STATUS' lookup type.
 * @param p_previous_last_name The previous last name of the registered user.
 * @param p_middle_name The middle name of the registered user.
 * @param p_name_suffix Suffix after the person's last name.
 * @param p_known_as The name by which the registered user is known.
 * @param p_first_name_phonetic Obsolete parameter. Do not use.
 * @param p_last_name_phonetic Obsolete parameter. Do not use.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
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
 * @rep:displayname Update Registered User
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_registered_user
   (p_validate                  IN     boolean  default false
   ,p_effective_date            IN     date
   ,p_person_id                 IN     number
   ,p_first_name                IN     varchar2 default hr_api.g_varchar2
   ,p_last_name                 IN     varchar2 default hr_api.g_varchar2
   ,p_date_of_birth             IN     date     default hr_api.g_date
   ,p_title                     IN     varchar2 default hr_api.g_varchar2
   ,p_gender                    IN     varchar2 default hr_api.g_varchar2
   ,p_marital_status            IN     varchar2 default hr_api.g_varchar2
   ,p_previous_last_name        IN     varchar2 default hr_api.g_varchar2
   ,p_middle_name               IN     varchar2 default hr_api.g_varchar2
   ,p_name_suffix               IN     varchar2 default hr_api.g_varchar2
   ,p_known_as                  IN     varchar2 default hr_api.g_varchar2
   ,p_first_name_phonetic       IN     varchar2 default hr_api.g_varchar2
   ,p_last_name_phonetic        IN     varchar2 default hr_api.g_varchar2
   ,p_attribute_category        IN     varchar2 default hr_api.g_varchar2
   ,p_attribute1                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute2                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute3                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute4                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute5                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute6                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute7                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute8                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute9                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute10               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute11               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute12               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute13               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute14               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute15               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute16               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute17               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute18               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute19               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute20               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute21               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute22               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute23               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute24               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute25               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute26               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute27               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute28               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute29               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute30               IN     varchar2 default hr_api.g_varchar2
   ,p_per_information_category  IN     varchar2 default hr_api.g_varchar2
   ,p_per_information1          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information2          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information3          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information4          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information5          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information6          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information7          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information8          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information9          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information10         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information11         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information12         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information13         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information14         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information15         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information16         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information17         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information18         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information19         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information20         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information21         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information22         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information23         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information24         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information25         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information26         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information27         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information28         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information29         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information30         IN     varchar2 default hr_api.g_varchar2
   );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< registered_user_application >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a job application for a registered user.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The registered user and the vacancy must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates an application for the registered user.
 *
 * <p><b>Post Failure</b><br>
 * The API fails to create an application and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes
 * into force.
 * @param p_recruitment_person_id Identifies the registered user.
 * @param p_person_id Identifies the new applicant, who may not be the same
 * person as the registered user, if the registered user is applying to a
 * different business group.
 * @param p_assignment_id Identifies the new applicant assignment.
 * @param p_application_received_date The date when the application was
 * received. If not supplied, this value is defaulted to the effective date.
 * @param p_vacancy_id Identifies the vacancy for which the registered user
 * has applied.
 * @param p_posting_content_id Identifies the advert for which the registered
 * user has applied.
 * @param p_per_information4 Developer descriptive flexfield segment.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the new applicant record. If p_validate is true, then the
 * value will be null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_applicant_number The applicant's identification number.
 * @rep:displayname Registered User Application
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure registered_user_application
   (p_validate                  IN     boolean  default false
   ,p_effective_date            IN     date
   ,p_recruitment_person_id     IN     number
   ,p_person_id                 IN     number
   ,p_assignment_id             IN     number
   ,p_application_received_date IN     date     default null
   ,p_vacancy_id                IN     number   default null
   ,p_posting_content_id        IN     number   default null
   ,p_per_information4          IN     per_all_people_f.per_information4%type default null
   ,p_per_object_version_number    OUT NOCOPY number
   ,p_asg_object_version_number    OUT NOCOPY number
   ,p_applicant_number             OUT NOCOPY varchar2);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_user >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a registered user with a login account.
 *
 * The API also uses create_registered_user with the default parameters to
 * create a basic registered user record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The responsibility, application, and security group must exist.
 *
 * <p><b>Post Success</b><br>
 * The API creates a new user account.
 *
 * <p><b>Post Failure</b><br>
 * The API fails to create a new user account and raises an error.
 * @param p_user_name The username for the new account. The user name
 * is same as the e-mail address.
 * @param p_password The encrypted password for the new account.
 * @param p_start_date The start date of the registered user's account.
 * @param p_responsibility_id Identifies the responsibility that will be
 * assigned to the new user.
 * @param p_resp_appl_id Identifies the application that the new responsibility
 * belongs to.
 * @param p_security_group_id Identifies the security group to be associated
 * with the new responsibility.
 * @param p_email The e-mail address for the new user.
 * @param p_language The default language for the new account.
 * @param p_last_name The last name of the registered user.
 * @param p_first_name The first name of the registered user.
 * @param p_allow_access Indicates whether the user's details are available to
 * recruiters when they search for candidates in iRecruitment.
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
 * @rep:displayname Create User
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_user
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_first_name                IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_user >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the login account details for a registered user.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The login account must exist.
 *
 * <p><b>Post Success</b><br>
 * The login information will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The login information will not be updated and an error will be raised
 * @param p_user_name The username for the new account. The user name
 * is same as the e-mail address.
 * @param p_owner Owner name for setting the last_udated_by column. This should
 * be set to 'CUST'.
 * @param p_unencrypted_password Plain text new password.
 * @param p_encrypted_user_password Encrypted password. This must be supplied
 * when updating the e-mail address.
 * @param p_session_number The session number of the application user's last
 * sign-on session.
 * @param p_start_date The date when the password becomes active.
 * @param p_end_date The date when the password expires.
 * @param p_last_logon_date The date when the application user last signed on.
 * @param p_description Optional description.
 * @param p_password_date The date when the current password was set.
 * @param p_password_accesses_left The number of accesses left for the password.
 * @param p_password_lifespan_accesses The number of accesses allowed for the
 * password.
 * @param p_password_lifespan_days Lifespan of the password.
 * @param p_employee_id Identifier of the employee to whom the application
 * username is assigned.
 * @param p_email_address The e-mail address for the user.
 * @param p_fax The fax number for the user (this will not be used in
 * iRecruitment).
 * @param p_customer_id Customer contact identifier.
 * @param p_supplier_id Supplier contact identifier.
 * @param p_old_password Old or Existing password used with
 * p_unencrypted_password to update user password.
 * @rep:displayname Update User
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_user (
  p_user_name                  in varchar2,
  p_owner                      in varchar2,
  p_unencrypted_password       in varchar2 default null,
  p_encrypted_user_password    in varchar2 default null,
  p_session_number             in number default null,
  p_start_date                 in date default null,
  p_end_date                   in date default null,
  p_last_logon_date            in date default null,
  p_description                in varchar2 default null,
  p_password_date              in date default null,
  p_password_accesses_left     in number default null,
  p_password_lifespan_accesses in number default null,
  p_password_lifespan_days     in number default null,
  p_employee_id                in number default null,
  p_email_address              in varchar2 default null,
  p_fax                        in varchar2 default null,
  p_customer_id                in number default null,
  p_supplier_id                in number default null,
  p_old_password               in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< self_register_user >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API enables ex-employees and other non-employee users to identify
 * themselves on iRecruitment and receive iRecruitment login details.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * If the user does not provide a user name, then iRecruitment creates a new
 * account using the new e-mail address and sends a notification about the new
 * password. If the user name is provided, then the application associates the
 * user name with the person record and sends a confirmation notification.
 *
 * In both the scenarios the application disables the old user accounts. The
 * e-mail will be updated on the person record. The API creates notification
 * preferences and work preferences records, if they do not exist.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update any records and will raise an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_current_email_address The current e-mail address of the user.
 * @param p_responsibility_id Identifies the responsibility that will be
 * assigned to the new user.
 * @param p_resp_appl_id The application for the responsibility that the
 * user will be granted.
 * @param p_security_group_id The security group for the responsibility that
 * the user will be granted.
 * @param p_first_name The first name that the user provides to identify
 * against an existing user in the database.
 * @param p_last_name The last name that the user provides to identify against
 * an existing user in the database.
 * @param p_middle_names The middle name that the user provides to identify
 * against an existing user in the database.
 * @param p_previous_last_name The previous last  name of the registered user.
 * @param p_employee_number The employee number that the user provides to
 * identify against an existing user in the database.
 * @param p_national_identifier The national identifier that the user provides
 * to identify against an existing user in the database.
 * @param p_date_of_birth The date of birth that the user provides to identify
 * against an existing user in the database.
 * @param p_email_address The e-mail address that the user provides to identify
 * against an existing user in the database.
 * @param p_home_phone_number The home phone number that the user
 * provides to identify against an existing user in the database.
 * @param p_work_phone_number The work phone number that the user provides to
 * identify against an existing user in the database.
 * @param p_address_line_1 The first line of their home address that
 * the user identifies with.
 * @param p_manager_last_name The last name of their manager that the user
 * provides to identify against an existing user in the database.
 * @param p_allow_access Indicates whether the user's details are available to
 * recruiters when they search for candidates in iRecruitment.
 * @param p_language The default language for the new account.
 * @param p_user_name The username for the new account. The user name
 * is same as the e-mail address.
 * @rep:displayname Self Register User
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure self_register_user
   (p_validate                  IN     boolean  default false
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
   ,p_allow_access              IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
   ,p_user_name                 IN     varchar2 default null
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_partial_user >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an iRecruitment profile for a candidate who is not an
 * Employee.
 *
 * The API checks whether the User is associated with the iRecruitment
 * Employee Candidate responsibility or the iRecruitment External Candidate
 * responsibility. It also checks whether the details such as grant,
 * notification preferences, and person record are available for the user in
 * the registration business group. If any or all of the information is
 * missing, then the API creates the details for the user. You must not use
 * this API to create details for an employee user.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The user must exist.
 *
 * <p><b>Post Success</b><br>
 * The API creates a profile for an iRecruitment external candidate.
 *
 * <p><b>Post Failure</b><br>
 * The API fails to create a profile for the user and raises an error.
 *
 * @param p_user_name The username for the new account. The user name
 * is same as the e-mail address.
 * @param p_start_date The start date of the registered user's account.
 * @param p_email The e-mail address for the new user.
 * @param p_language The default language for the new account.
 * @param p_last_name The last name of the registered user.
 * @param p_first_name The first name of the registered user.
 * @param p_reg_bg_id Identifies the registration business group in which
 * the candidate's record needs to be created.
 * @param p_responsibility_id Identifies the responsibility that will be
 * assigned to the new user.
 * @param p_resp_appl_id Identifies the application that the new responsibility
 * belongs to.
 * @param p_security_group_id Identifies the security group to be associated
 * with the new responsibility.
 * @param p_allow_access Indicates whether the user's details are available to
 * recruiters when they search for candidates in iRecruitment.
 * @rep:displayname Create Partial User
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
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
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< irec_profile_exists >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API checks if the user has an iRecruitment profile.
 *
 * The API checks whether the user is associated with the iRecruitment
 * Employee Candidate responsibility or the iRecruitment External Candidate
 * responsibility. It also checks whether the details such as grant,
 * notification preferences, and person record exist for the user in the
 * registration business group.
 *
 * If any or all of the information is missing, then the API returns the value
 * NO_PROFILE. If the information exists, then the API returns the value
 * PROFILE_EXISTS.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The user must exist.
 *
 * <p><b>Post Success</b><br>
 * The API returns a value indicating whether the user has an iRecruitment
 * profile.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a profile for the user and raises an error.
 *
 * @param p_user_name The username for the account. The user name
 * is same as the e-mail address.
 * @param p_reg_bg_id Identifies the registration business group in which
 * the candidate's record needs to be created.
 * @param p_responsibility_id Identifies the responsibility that will be
 * assigned to the new user.
 * @param p_resp_appl_id Identifies the application that the new responsibility
 * belongs to.
 * @param p_security_group_id Identifies the security group to be associated
 * with the new responsibility.
 * @return VARCHAR2 'PROFILE_EXISTS' is returned if exist else 'NO_PROFILE' is
 * returned.
 * @rep:displayname iRecruitment Profile Exists
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
FUNCTION irec_profile_exists
  (p_user_name                  IN      varchar2
  ,p_reg_bg_id                  IN      number
  ,p_responsibility_id          IN      number
  ,p_resp_appl_id               IN      number
  ,p_security_group_id          IN      number
  ) return VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ha_processed_user >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an iRecruitment profile for a candidate who has registered
 * using the High Availability site.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The API creates a profile for an iRecruitment external candidate who
 * has registered or applied for a job using the High Availability site.
 *
 * <p><b>Post Failure</b><br>
 * iRecruitment profile is not created for the user, and an error is raised.
 *
 * @param p_user_name The username for the new account. The user name
 * is same as the e-mail address.
 * @param p_password Encrypted password for the FND user that was created on
 * the High Availability site.
 * @param p_email The e-mail address for the new user.
 * @param p_start_date The start date of the registered user's account.
 * @param p_language The default language for the new account.
 * @param p_last_name The last name of the registered user.
 * @param p_first_name The first name of the registered user.
 * @param p_user_guid GUID of the User that was created using the High
 * Availability site.
 * @param p_reg_bg_id Identifies the registration business group in which
 * the candidate's record needs to be created.
 * @param p_responsibility_id Identifies the responsibility that will be
 * assigned to the new user.
 * @param p_resp_appl_id Identifies the application that the new responsibility
 * belongs to.
 * @param p_security_group_id Identifies the security group to be associated
 * with the new responsibility.
 * @param p_allow_access Indicates whether the user's details are available to
 * recruiters when they search for candidates in iRecruitment.
 * @param p_server_id Indicates the server from which the user is accessing
 * the application
 * @rep:displayname Create High Availability Processed User
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_ha_processed_user
  (p_user_name                  IN      varchar2
  ,p_password                   IN      varchar2
  ,p_email                      IN      varchar2
  ,p_start_date                 IN      date
  ,p_last_name                  IN      varchar2
  ,p_first_name                 IN      varchar2
  ,p_user_guid                  IN      RAW
  ,p_reg_bg_id                  IN      number
  ,p_responsibility_id          IN      number
  ,p_resp_appl_id               IN      number
  ,p_security_group_id          IN      number
  ,p_language                   IN      varchar2 default null
  ,p_allow_access               IN      varchar2 default null
  ,p_server_id                  IN      varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< grant_access >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an iRecruitment candidate grant.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The user must exist.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates a candidate grant for the user.
 *
 * <p><b>Post Failure</b><br>
 * The API fails to create a candidate grant for the user and raises an error.
 *
 * @param p_user_name The username for new account. The user name
 * is same as the e-mail address.
 * @param p_user_id ID of the user.
 * @param p_menu_id ID of the menu for which this grant is created.
 * @param p_resp_id ID of the responsibility for which the grant is created.
 * @param p_resp_appl_id Application ID of the responsibility for which the
 * grant is created.
 * @param p_sec_group_id Security Group ID for which the grant is created.
 * @param p_grant_name Name of the grant.
 * @param p_description Description of the grant.
 * @rep:displayname Grant Access
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure grant_access
(p_user_name    IN varchar2
,p_user_id      IN number
,p_menu_id      IN number
,p_resp_id      IN number
,p_resp_appl_id IN number
,p_sec_group_id IN number
,p_grant_name   IN varchar2
,p_description  IN varchar2 default null
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< assign_responsibility >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API assigns a responsibility to the user.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The user and responsibility should exist.
 *
 * <p><b>Post Success</b><br>
 * The responsibility is successfully assigned to the user.
 *
 * <p><b>Post Failure</b><br>
 * The API does not assign a responsibility to the user and an error is raised.
 *
 * @param p_user_id ID of the user
 * @param p_resp_id Identifies the responsibility to be assigned to the user.
 * @param p_resp_appl_id Application ID of the responsibility that the API
 * assigns to the user.
 * @param p_sec_group_id Identifies the security group to which the API
 * assigns the responsibility.
 * @rep:displayname Assign Responsibility
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure assign_responsibility
(p_user_id      IN number
,p_resp_id      IN number
,p_resp_appl_id IN number
,p_sec_group_id IN number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< testusername >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API tests the User Name to validate that it is unique and passes
 * validations checks.
 *
 * The checks are performed against SSO server if the application
 * is SSO enabled.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The result of the user name validation is returned.
 *
 * <p><b>Post Failure</b><br>
 * An error is raised.
 *
 * @param p_user_name User name to be validated.
 * @return The API will return a value indicating whether the user name is
 * INVALID, or VALID or if a SSO user exists with that name. The API links
 * the FND user with the SSO user.
 * @rep:displayname Test User Name
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
function TestUserName
(
  p_user_name IN varchar2
) return NUMBER;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< process_ha_resp_check >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API checks if the user has the responsibility and if not, assigns the
 * responsibility. The procedure does a re-initialization of user's session
 * to the new assigned responsibility
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * This API updates the user's session to refer to the input responsibility.
 *
 * <p><b>Post Failure</b><br>
 * An error is raised.
 *
 * @param p_user_id ID of the user
 * @param p_responsibility_id Identifies the responsibility to be assigned
 * to the user.
 * @param p_resp_appl_id Application ID of the responsibility that the API
 * assigns to the user.
 * @param p_security_group_id Identifies the security group to which the API
 * assigns the responsibility.
 * @param p_start_date The start date of the registered user's account.
 * @param p_server_id Identifies the server from which this user is
 * accessing the application
 * @rep:displayname Assign Responsibility
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:category BUSINESS_ENTITY FND_USER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure process_ha_resp_check
(
p_user_id            IN number,
p_responsibility_id  IN number,
p_resp_appl_id       IN number,
p_security_group_id  IN number,
p_start_date         IN date,
p_server_id          IN number default null
);
--
--
-- -------------------------------------------------------------------------
-- |------------------------< create_user_byReferral >--------------------------------|
-- -------------------------------------------------------------------------
--
procedure create_user_byReferral
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_first_name                IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   ,p_person_id                 IN     number   default null
   );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< merge_profile >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- {End Of Comments}
--
procedure merge_profile
   (p_validate                  IN     boolean  default false
   ,p_target_party_id           IN     number
   ,p_source_party_id           IN     number
   ,p_term_or_purge_s           IN     varchar2 default null
   ,p_disable_user_acc          IN     varchar2 default null
   ,p_create_new_application    IN     varchar2 default null
   );
--
end IRC_PARTY_API;

/
