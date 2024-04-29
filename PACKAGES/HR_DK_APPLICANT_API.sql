--------------------------------------------------------
--  DDL for Package HR_DK_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DK_APPLICANT_API" AUTHID CURRENT_USER AS
/* $Header: peappdki.pkh 120.4 2006/10/11 07:18:57 saurai noship $ */
/*#
 * This package contains applicant APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Applicant for Denmark
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_dk_applicant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Danish applicant.
 *
 * This API is effectively an alternative to the API create_applicant. If
 * p_validate is set to false, an applicant is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Denmark legislation must already exist. Also a valid
 * person_type_id, with a corresponding system type of APL, must be active and
 * in the same business group as that of the applicant being created.
 *
 * <p><b>Post Success</b><br>
 * The person, application, default applicant assignment, and, if required,
 * associated assignment budget values, and a letter request are successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person, application, default applicant
 * assignment, associated assignment budget values, and a letter request, and
 * raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The date an application was received, and thus the
 * effective start date of the person, application and assignment.
 * @param p_business_group_id The applicant's business group.
 * @param p_last_name The applicant's last name.
 * @param p_person_type_id Person type id. If a person_type_id is not specified
 * the API will use the default APL type for the business group.
 * @param p_applicant_number Applicant number, if the number generation method
 * is Manual then this parameter is mandatory. If the number generation method
 * is Automatic then the value of this parameter must be NULL. If p_validate is
 * false and the applicant number generation method is Automatic this will be
 * set to to the generated applicant number of the person created. If
 * p_validate is false and the applicant number generation method is manual
 * this will be set to the same value passed in. If p_validate is true this
 * will be set to the same value as passed in.
 * @param p_comments Applicant comment text.
 * @param p_date_employee_data_verified The date on which the applicant data
 * was last verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Applicant's first name.
 * @param p_middle_names Person's middle name.
 * @param p_known_as Applicant's alternative name.
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_nationality Applicant's nationality. Valid values are defined by
 * the NATIONALITY lookup type.
 * @param p_national_identifier National identifier.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Registered disabled flag.Valid values are
 * defined by the REGISTERED_DISABLED lookup type.
 * @param p_sex Applicant's sex. Valid values are defined by the SEX lookup
 * type.
 * @param p_title Applicant's title. Valid values are defined by the TITLE
 * lookup type.
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
 * @param p_initials Initials.
 * @param p_jubilee_date Jubilee date.
 * @param p_trainee Trainee.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fte_capacity Currently unsupported.
 * @param p_hold_applicant_date_until Date up to which the applicant's file is
 * to be maintained.
 * @param p_honors Honors or degrees awarded.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Number of office.
 * @param p_on_military_service Type of military service.
 * @param p_projected_start_date Currently unsupported.
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date resume last updated.
 * @param p_student_status Type of student status.
 * @param p_work_schedule Type of work schedule indicating which days the
 * person works.
 * @param p_date_of_death Date of death.
 * @param p_benefit_group_id ID for benefit group.
 * @param p_receipt_of_death_cert_date Date death certificate was received.
 * @param p_coord_ben_med_pln_no Number of an externally provided medical plan.
 * @param p_coord_ben_no_cvg_flag No other coverage flag.
 * @param p_uses_tobacco_flag Uses tobacco list of values.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Dependent on voluntary service flag.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_town_of_birth Town or city of birth.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_country_of_birth Country of birth.
 * @param p_global_person_id Global ID for the person.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_application_id If p_validate is false, this uniquely identifies the
 * application created. If p_validate is true this parameter will be null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_apl_object_version_number If p_validate is false, this will be set
 * to the version number of the application created. If p_validate is true this
 * parameter will be set to null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false this will be set to the id of
 * the corresponding person comment row, if any comment text exists. If
 * p_validate is true this will be null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the default assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Thi is set to true if the original date of hire
 * is not null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Applicant for Denmark
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE create_dk_applicant
  (p_validate                      in     boolean  default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                   in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2
  -- Added for bug fix 4666216
  ,p_middle_names                  in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_nationality                   in     varchar2
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_sex                           in     varchar2 default null
  ,p_title                         in     varchar2
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
  ,p_initials			   in     varchar2 default null
  ,p_jubilee_date		   in		date default null
  ,p_trainee			   IN     VARCHAR2 DEFAULT null
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

end hr_dk_applicant_api;

 

/
