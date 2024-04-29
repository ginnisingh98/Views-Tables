--------------------------------------------------------
--  DDL for Package HR_KW_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KW_APPLICANT_API" AUTHID CURRENT_USER as
/* $Header: peappkwi.pkh 120.2 2005/10/02 02:37:53 aroussel $ */
/*#
 * This package contains applicant APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Applicant for Kuwait
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_kw_applicant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Kuwaiti applicant.
 *
 * The API creates the person details, a default primary assignment, and an
 * application for the applicant. The API calls the generic API
 * create_applicant, with the parameters set as appropriate for a Kuwaiti
 * applicant. Secure user functionality is not included in this version of the
 * API. As this API is effectively an alternative to the API create_applicant,
 * see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Kuwait legislation must exist on the effective date.
 * The APL type must be active in the same business group as the applicant you
 * are creating. If you do not specify a person_type_id, the API uses the
 * default APL type for the business group.
 *
 * <p><b>Post Success</b><br>
 * The API creates a person, application, and default applicant assignment. If
 * required, then the API also creates the associated assignment budget values
 * and a letter request.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create an applicant and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The date an application is received and therefore the
 * effective start date of the person, application, and assignment.
 * @param p_business_group_id Identifies the applicant's business group.
 * @param p_family_name Applicant's family name.
 * @param p_person_type_id Identifies the person type id. If a person_type_id
 * is not specified, then the API will use the default 'APL' type for the
 * business group.
 * @param p_applicant_number Identifies the applicant's unique number. If the
 * number generation method is Manual, then this parameter is mandatory. If the
 * number generation method is Automatic, then the value of this parameter must
 * be NULL. If p_validate is false and the applicant number generation method
 * is Automatic, then the parameter value will be set to the generated
 * applicant number of the person created. If p_validate is false and the
 * applicant number generation method is Manual, then the parameter value will
 * be set to the same value passed in. If p_validate is true, then the
 * parameter value will be set to the same value as passed in.
 * @param p_comments Applicant comment text.
 * @param p_date_employee_data_verified The date on which the applicant data
 * was last verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address E-mail address.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Applicant's first name.
 * @param p_known_as Alternative name.
 * @param p_marital_status Marital status. The lookup type 'MAR_STATUS' defines
 * the valid values.
 * @param p_nationality Applicant's nationality. The lookup type 'NATIONALITY'
 * defines the valid values.
 * @param p_national_identifier National identifier.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Indicates whether the person is classified
 * as disabled. The lookup type 'REGISTERED_DISABLED' defines the valid values.
 * @param p_sex Applicant's sex. The lookup type 'SEX' defines the valid
 * values.
 * @param p_title Applicant's title. The lookup type 'TITLE' defines the valid
 * values.
 * @param p_work_telephone Work telephone.
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
 * @param p_father_name Father's name.
 * @param p_grandfather_name Grandfather's name.
 * @param p_alt_first_name Alternate first name.
 * @param p_alt_father_name Father's alternate name.
 * @param p_alt_grandfather_name Grandfather's alternate name.
 * @param p_alt_family_name Alternate family name.
 * @param p_previous_nationality Previous nationality.
 * @param p_religion Religion.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fte_capacity Currently unsupported.
 * @param p_hold_applicant_date_until Date up to which applicant's file to be
 * maintained.
 * @param p_honors Honors or degrees awarded.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Number of office.
 * @param p_on_military_service Type of military service.
 * @param p_projected_start_date Currently unsupported.
 * @param p_resume_exists Y/N flag indicating whether resume is available.
 * @param p_resume_last_updated Date resume was last updated.
 * @param p_student_status Type of student status. The lookup type
 * 'STUDENT_STATUS' defines the valid values.
 * @param p_work_schedule Type of work schedule indicating which days the
 * person works. The lookup type 'WORK_SCHEDULE' defines the valid values.
 * @param p_date_of_death Date of death of the applicant.
 * @param p_benefit_group_id Identifies the applicant's benefit group.
 * @param p_receipt_of_death_cert_date Date when the death certificate was
 * received.
 * @param p_coord_ben_med_pln_no Number of the medical plan provided by an
 * external organization.
 * @param p_coord_ben_no_cvg_flag Indicates that the person is not covered by
 * any other benefit plan.
 * @param p_uses_tobacco_flag Tobacco type used by the applicant. The lookup
 * type 'TOBACCO_USER' defines the valid values.
 * @param p_dpdnt_adoption_date Date the dependent is adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original hire date of the applicant.
 * @param p_town_of_birth Town or city of birth of the applicant.
 * @param p_region_of_birth Geographical region of birth of the applicant.
 * @param p_country_of_birth Country of birth of the applicant.
 * @param p_global_person_id Global identification number for the applicant.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_application_id If p_validate is false, then this uniquely
 * identifies the created application. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_apl_object_version_number If p_validate is false, then this will be
 * set to the version number of the created application. If p_validate is true,
 * then set to null.
 * @param p_per_effective_start_date If p_validate is false, then this will be
 * set to the effective start date of the person. If p_validate is true, then
 * set to null.
 * @param p_per_effective_end_date If p_validate is false, then this will be
 * set to the effective end date of the person. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, then this will be set to the
 * complete full name of the person. If p_validate is true, then set to null.
 * @param p_per_comment_id If p_validate is false, then this will be set to the
 * ID of the corresponding person comment row, if any comment text exists. If
 * p_validate is true, then set to null.
 * @param p_assignment_sequence If p_validate is false, then this will be set
 * to the sequence number of the default assignment. If p_validate is true,
 * then set to null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true, if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP, or EX_EMP_APL.
 * @rep:displayname Create Applicant for Kuwait
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE create_kw_applicant
  (p_validate                      in     boolean  default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_family_name                   in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_sex                           in     varchar2 default null
  ,p_title                         in     varchar2 default null
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
  ,p_father_name             	   in     varchar2 default null
  ,p_grandfather_name              in     varchar2 default null
  ,p_alt_first_name                in     varchar2 default null
  ,p_alt_father_name               in     varchar2 default null
  ,p_alt_grandfather_name          in     varchar2 default null
  ,p_alt_family_name           	   in     varchar2 default null
  ,p_previous_nationality          in     varchar2 default null
  ,p_religion			   in     varchar2 default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_application_id                   out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean);

end hr_kw_applicant_api;

 

/
