--------------------------------------------------------
--  DDL for Package HR_AE_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AE_CONTACT_API" AUTHID CURRENT_USER as
/* $Header: peconaei.pkh 120.5 2006/04/25 22:57:18 spendhar noship $ */
/*#
 * This package contains contact APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contact for UAE
*/

--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ae_person  >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates a UAE contact.
 *
 * The API creates a person record in PER_PEOPLE_F for a person of type
 * 'OTHER'. No information is stored in any other tables.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for UAE legislation must exist on the effective date.
 * A valid business_group_id, a valid person_type_id (if specified), and a
 * corresponding system type of 'OTHER' are required. The 'OTHER' type must be
 * active in the same business group as the contact you are creating. If you do
 * not specify a person_type_id, the API uses the default 'OTHER' type for the
 * business group.
 *
 * <p><b>Post Success</b><br>
 * The contact person will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The contact person will not be created and an error will be raised.
 *
 * @param p_validate If true, the database remains unchanged. If false
 * then the person will be created in the database.
 * @param p_start_date The effective start date of the person
 * @param p_business_group_id The person's business group.
 * @param p_family_name Person's last name.
 * @param p_sex Person's sex.
 * @param p_person_type_id Person type id. If this value is omitted then the
 * person_type_id of the default `OTHER' system person type in the person's business
 * group is used.
 * @param p_comments Comments for person record.
 * @param p_date_employee_data_verified Date when the contact last verified the data.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Person's first name.
 * @param p_known_as Alternative name.
 * @param p_marital_status Marital status.
 * @param p_national_identifier National identifier.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Registered disabled flag.
 * @param p_title Person's title.
 * @param p_vendor_id Foreign key to PO_VENDORS.
 * @param p_work_telephone Work telephone.
 * @param p_attribute_category Determines the context of the descriptive flexfield
 * in the parameter list.
 * @param p_attribute1 Descriptive flexfield.
 * @param p_attribute2 Descriptive flexfield.
 * @param p_attribute3 Descriptive flexfield.
 * @param p_attribute4 Descriptive flexfield.
 * @param p_attribute5 Descriptive flexfield.
 * @param p_attribute6 Descriptive flexfield.
 * @param p_attribute7 Descriptive flexfield.
 * @param p_attribute8 Descriptive flexfield.
 * @param p_attribute9 Descriptive flexfield.
 * @param p_attribute10 Descriptive flexfield.
 * @param p_attribute11 Descriptive flexfield.
 * @param p_attribute12 Descriptive flexfield.
 * @param p_attribute13 Descriptive flexfield.
 * @param p_attribute14 Descriptive flexfield.
 * @param p_attribute15 Descriptive flexfield.
 * @param p_attribute16 Descriptive flexfield.
 * @param p_attribute17 Descriptive flexfield.
 * @param p_attribute18 Descriptive flexfield.
 * @param p_attribute19 Descriptive flexfield.
 * @param p_attribute20 Descriptive flexfield.
 * @param p_attribute21 Descriptive flexfield.
 * @param p_attribute22 Descriptive flexfield.
 * @param p_attribute23 Descriptive flexfield.
 * @param p_attribute24 Descriptive flexfield.
 * @param p_attribute25 Descriptive flexfield.
 * @param p_attribute26 Descriptive flexfield.
 * @param p_attribute27 Descriptive flexfield.
 * @param p_attribute28 Descriptive flexfield.
 * @param p_attribute29 Descriptive flexfield.
 * @param p_attribute30 Descriptive flexfield.
 * @param p_father_name Father's Name.
 * @param p_grandfather_name Grandfather's Name.
 * @param p_mother_name Mother's Name.
 * @param p_alt_first_name Alternate first name.
 * @param p_alt_father_name Father's alternate name.
 * @param p_alt_grandfather_name Grandfather's alternate name.
 * @param p_alt_family_name Alternate family name.
 * @param p_alt_mother_name Alternate mother name.
 * @param p_previous_nationality Previous Nationality.
 * @param p_religion Religion.
 * @param p_education_level Education level.
 * @param p_alt_place_of_birth Alternate place of birth.
 * @param p_date_of_change Date of change of nationality.
 * @param p_reason_for_change Reason for change of nationality.
 * @param p_nationality Person's nationality.
 * @param p_correspondence_language Correspondence language
 * @param p_honors Honors
 * @param p_benefit_group_id The identification for the benefit group.
 * @param p_on_military_service The type of military service.
 * @param p_student_status The type of student status.
 * @param p_uses_tobacco_flag The person's tobacco usage details. The valid
 * values are defined by 'TOBACCO_USER' lookup type.
 * @param p_coord_ben_no_cvg_flag The coordination of benefits with no other
 * coverage flag.
 * @param p_place_of_birth Town or city of birth
 * @param p_region_of_birth Geographical region of birth
 * @param p_country_of_birth varchar2 Country of birth
 * @param p_global_person_id varchar2 Global ID for the person
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person. If p_validate is true,
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true, this will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created person comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the person type is not EMP,
 * EMP_APL, EX_EMP, or EX_EMP_APL and the original_date_of_hire is not null.
 * @rep:displayname Create Person for UAE
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}

--
procedure create_ae_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_family_name                   in     varchar2
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
  ,p_national_identifier           in     varchar2 default null
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
  ,p_father_name                   in     varchar2 default null
  ,p_grandfather_name              in     varchar2 default null
  ,p_mother_name                   in     varchar2 default null
  ,p_alt_first_name                in     varchar2 default null
  ,p_alt_father_name               in     varchar2 default null
  ,p_alt_grandfather_name          in     varchar2 default null
  ,p_alt_family_name               in     varchar2 default null
  ,p_alt_mother_name               in     varchar2 default null
  ,p_previous_nationality          in     varchar2 default null
  ,p_religion                      in     varchar2 default null
  ,p_education_level               in     varchar2 default null
  ,p_alt_place_of_birth            in     varchar2 default null
  ,p_date_of_change                in     varchar2 default null
  ,p_reason_for_change             in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_honors                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_on_military_service           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_place_of_birth                in     varchar2 default null
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
--
end hr_ae_contact_api;

/
