--------------------------------------------------------
--  DDL for Package HR_CA_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CA_APPLICANT_API" AUTHID CURRENT_USER as
/* $Header: peappcai.pkh 120.1 2005/10/02 02:09:56 aroussel $ */
/*#
 * This package contains APIs used while creating Canadian Applicants.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Applicant for Canada
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ca_applicant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Canadian applicant.
 *
 * This API creates a new Canadian applicant, including a default primary
 * assignment and a application for the applicant. The API calls the generic
 * API create_applicant, with the parameters set as appropriate for a Canadian
 * applicant. Secure user functionality is not included in this version of the
 * API. As this API is effectively an alternative to the API create_applicant,
 * see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_applicant. - A business group with A legislation of Canada
 * must be specified.
 *
 * <p><b>Post Success</b><br>
 * A new person, primary assignment and application have been successfully
 * inserted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the applicant, default assignment or application and
 * raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The applicant hire date and thus the effective start
 * date of the person, primary assignment and application.
 * @param p_business_group_id The applicant's business group.
 * @param p_last_name Applicant's last name.
 * @param p_person_type_id Person type id. If this value is omitted then the
 * person_type_id of the active default `APL' system person type in the
 * applicant's business group is used.
 * @param p_applicant_number If p_validate is false this will be set to the
 * applicant number of the person created. If p_validate is true this will be
 * set to the same value as passed in.
 * @param p_comments Comment text
 * @param p_date_employee_data_verified The date on which the applicant data
 * was last verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Applicant's first name.
 * @param p_known_as Alternative name.
 * @param p_marital_status YES_NO flag indicates if the person is married or
 * not.
 * @param p_middle_names Applicant's middle name(s).
 * @param p_nationality Applicant's nationality.
 * @param p_social_insurance_number Social Insurance Number.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag REGISTERED_DISABLED lookup_type indicates
 * if the applicant is registered as disabled or not.
 * @param p_sex Applicant sex.
 * @param p_title Applicant's title.
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
 * @param p_work_permit_number Work permit number
 * @param p_work_permit_status Work permit status
 * @param p_work_permit_end_date Work permit end date
 * @param p_woman YES_NO flag indicating if applicant is female
 * @param p_aboriginal YES_NO flag indicating if applicant is aboriginal
 * @param p_visible_minority YES_NO flag indicating if applicant is VM
 * @param p_disabled YES_NO flag indicating if applicant is disabled
 * @param p_not_provided YES_NO flag indicating if info is disabled
 * @param p_unknown YES_NO flag indicating info is unknown
 * @param p_background_check_status YES_NO flag indicates whether background
 * check has been performed
 * @param p_background_date_check Date background check was performed
 * @param p_correspondence_language Preferred language for correspondance
 * @param p_fte_capacity Currently unsupported
 * @param p_hold_applicant_date_until Date up to which applicant's file to be
 * maintained
 * @param p_honors Honors or degrees awarded
 * @param p_mailstop Office identifier for internal mail
 * @param p_office_number Number of office
 * @param p_on_military_service Type of military service
 * @param p_pre_name_adjunct First part of surname such as Van or De
 * @param p_projected_start_date Currently unsupported
 * @param p_resume_exists YES_NO flag indicating whether resume is on file
 * @param p_resume_last_updated Date resume last updated
 * @param p_student_status STUDENT_STATUS lookup type indicates if the
 * applicant is a full time or a part time student.
 * @param p_work_schedule Type of work schedule inndicating which days person
 * works
 * @param p_suffix Applicant's suffix
 * @param p_date_of_death Date of death
 * @param p_benefit_group_id Id for benefit group
 * @param p_receipt_of_death_cert_date Date death certificate was received
 * @param p_coord_ben_med_pln_no Number of an externally provided medical plan
 * @param p_coord_ben_no_cvg_flag No other coverage flag
 * @param p_uses_tobacco_flag Uses tobacco list of values
 * @param p_dpdnt_adoption_date Date dependent was adopted
 * @param p_dpdnt_vlntry_svce_flag Dependent on voluntary service flag
 * @param p_original_date_of_hire Original date of hire
 * @param p_city_of_birth City of birth
 * @param p_province_of_birth Province of birth
 * @param p_country_of_birth Country of birth
 * @param p_global_person_id Global ID for the person
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
 * sequence number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Applicant for Canada
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ca_applicant
  (p_validate                      in     boolean  default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
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
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_social_insurance_number       in     varchar2 default null
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
  ,p_work_permit_number            in     varchar2 default null
  ,p_work_permit_status            in     varchar2 default null
  ,p_work_permit_end_date          in     varchar2 default null
  ,p_woman                         in     varchar2 default null
  ,p_aboriginal                    in     varchar2 default null
  ,p_visible_minority              in     varchar2 default null
  ,p_disabled                      in     varchar2 default null
  ,p_not_provided                  in     varchar2 default null
  ,p_unknown                       in     varchar2 default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_city_of_birth                 in      varchar2 default null
  ,p_province_of_birth             in      varchar2 default null
  ,p_country_of_birth              in      varchar2 default null
  ,p_global_person_id              in      varchar2 default null
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
  ,p_orig_hire_warning                out nocopy boolean
  );
--
end hr_ca_applicant_api;

 

/
