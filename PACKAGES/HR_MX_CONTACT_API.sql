--------------------------------------------------------
--  DDL for Package HR_MX_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_CONTACT_API" AUTHID CURRENT_USER AS
/* $Header: hrmxwrca.pkh 120.1 2005/10/02 02:36:14 aroussel $ */
/*#
 * This API creates a new contact for Mexico.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Personal Contact for Mexico
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_mx_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new contact for Mexico.
 *
 * This API creates person details and adds the person to the security lists so
 * that secure users can see the contact.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group must exist on the effective date. A valid
 * business_group_id, a valid person_type_id (if specified), and a
 * corresponding system type of OTHER are required. The OTHER type must be
 * active in the same business group as the contact you are creating. If you do
 * not specify a person_type_id, the API uses the default OTHER type for the
 * business group.
 *
 * <p><b>Post Success</b><br>
 * The contact details are created.
 *
 * <p><b>Post Failure</b><br>
 * The contact is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date Start date.
 * @param p_business_group_id Business group of the person.
 * @param p_paternal_last_name Paternal last name of the person.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_person_type_id Type of person being created.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified Date on which the person data was last
 * verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_expense_check_send_to_addres Mailing address.
 * @param p_first_name First name.
 * @param p_known_as Preferred name.
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_second_name Second name of the person.
 * @param p_nationality Nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_curp_id Mexican national identifier.
 * @param p_previous_last_name Obsolete parameter, do not use.
 * @param p_registered_disabled_flag Flag indicating whether the person is
 * classified as disabled.
 * @param p_title Title. Valid values are defined by the TITLE lookup type.
 * @param p_vendor_id Obsolete parameter, do not use.
 * @param p_work_telephone Obsolete parameter, do not use.
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
 * @param p_maternal_last_name Maternal last name of the person.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_honors Honors awarded.
 * @param p_benefit_group_id Benefit group to which this person will belong.
 * @param p_on_military_service Flag indicating whether the person is on
 * military service.
 * @param p_student_status If this person is a student, this field is used to
 * capture their status. Valid values are defined by the STUDENT_STATUS lookup
 * type.
 * @param p_uses_tobacco_flag Flag indicating whether the person uses tobacco.
 * @param p_coord_ben_no_cvg_flag No secondary medical plan coverage. Column
 * used for external processing.
 * @param p_pre_name_adjunct Prefix before the person's name.
 * @param p_suffix Suffix after the person's last name.
 * @param p_town_of_birth Town or city of birth.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_country_of_birth Country of birth.
 * @param p_global_person_id Obsolete parameter, do not use.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created contact. If p_validate is true, then the value
 * will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created contact. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created contact. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, then set to the complete full
 * name of the person. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created contact comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning If set to true, an orginal date of hire exists
 * for a person who has never been an employee.
 * @rep:displayname Create Contact Person for Mexico
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
*/
--
-- {End Of Comments}
--
PROCEDURE CREATE_MX_PERSON
    (p_validate                      in     boolean  default false
    ,p_start_date                    in     date
    ,p_business_group_id             in     number
    ,p_paternal_last_name            in     varchar2
    ,p_sex                           in     varchar2
    ,p_person_type_id                in     number   default null
    ,p_comments                      in     varchar2 default null
    ,p_date_employee_data_verified   in     date     default null
    ,p_date_of_birth                 in     date     default null
    ,p_email_address                 in     varchar2 default null
    ,p_expense_check_send_to_addres  in     varchar2 default null
    ,p_first_name                    in     varchar2 default null
    ,p_known_as                      in     varchar2 default null
    ,p_marital_status                in     varchar2 default null
    ,p_second_name                   in     varchar2 default null
    ,p_nationality                   in     varchar2 default null
    ,p_curp_id                       in     varchar2 default null
    ,p_previous_last_name            in     varchar2 default null
    ,p_registered_disabled_flag      in     varchar2 default null
    ,p_title                         in     varchar2 default null
    ,p_vendor_id                     in     number   default null
    ,p_work_telephone                in     varchar2 default null
    ,p_attribute_category            in     varchar2 default null
    ,p_attribute1                    in     varchar2 default null
    ,p_attribute2                    in     varchar2 default null
    ,p_attribute3                    in     varchar2 default null
    ,p_attribute4                    in     varchar2 default null
    ,p_attribute5                    in     varchar2 default null
    ,p_attribute6                    in     varchar2 default null
    ,p_attribute7                    in     varchar2 default null
    ,p_attribute8                    in     varchar2 default null
    ,p_attribute9                    in     varchar2 default null
    ,p_attribute10                   in     varchar2 default null
    ,p_attribute11                   in     varchar2 default null
    ,p_attribute12                   in     varchar2 default null
    ,p_attribute13                   in     varchar2 default null
    ,p_attribute14                   in     varchar2 default null
    ,p_attribute15                   in     varchar2 default null
    ,p_attribute16                   in     varchar2 default null
    ,p_attribute17                   in     varchar2 default null
    ,p_attribute18                   in     varchar2 default null
    ,p_attribute19                   in     varchar2 default null
    ,p_attribute20                   in     varchar2 default null
    ,p_attribute21                   in     varchar2 default null
    ,p_attribute22                   in     varchar2 default null
    ,p_attribute23                   in     varchar2 default null
    ,p_attribute24                   in     varchar2 default null
    ,p_attribute25                   in     varchar2 default null
    ,p_attribute26                   in     varchar2 default null
    ,p_attribute27                   in     varchar2 default null
    ,p_attribute28                   in     varchar2 default null
    ,p_attribute29                   in     varchar2 default null
    ,p_attribute30                   in     varchar2 default null
    ,p_maternal_last_name            in     varchar2 default null
    ,p_correspondence_language       in     varchar2 default null
    ,p_honors                        in     varchar2 default null
    ,p_benefit_group_id              in     number   default null
    ,p_on_military_service           in     varchar2 default null
    ,p_student_status                in     varchar2 default null
    ,p_uses_tobacco_flag             in     varchar2 default null
    ,p_coord_ben_no_cvg_flag         in     varchar2 default null
    ,p_pre_name_adjunct              in     varchar2 default null
    ,p_suffix                        in     varchar2 default null
    ,p_town_of_birth                 in     varchar2 default null
    ,p_region_of_birth               in     varchar2 default null
    ,p_country_of_birth              in     varchar2 default null
    ,p_global_person_id              in     varchar2 default null
    ,p_person_id                        out nocopy number
    ,p_object_version_number            out nocopy number
    ,p_effective_start_date             out nocopy date
    ,p_effective_end_date               out nocopy date
    ,p_full_name                        out nocopy varchar2
    ,p_comment_id                       out nocopy number
    ,p_name_combination_warning         out nocopy boolean
    ,p_orig_hire_warning                out nocopy boolean
    );

END HR_MX_CONTACT_API;

 

/
