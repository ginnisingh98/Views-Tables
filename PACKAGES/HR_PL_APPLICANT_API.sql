--------------------------------------------------------
--  DDL for Package HR_PL_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PL_APPLICANT_API" AUTHID CURRENT_USER as
/* $Header: peapppli.pkh 120.3 2006/05/08 05:17:20 mseshadr noship $ */
/*#
 * This package contains applicant APIs for Poland.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Applicant for Poland
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pl_applicant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The following procedure(older version) creates a Polish applicant.
 *
 * This API is an alternative to the API create_applicant. If p_validate is set
 * to false, an applicant is created.
 *
 * <P> This version of the API is now out-of-date however it has been provided
 * to you for backward compatibility support and will be removed in the future.
 * Oracle recommends you to modify existing calling programs in advance of the
 * support being withdrawn thus avoiding any potential disruption.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Poland legislation must already exist. Also a valid
 * person_type_id, with a corresponding system type of 'APL', must be active
 * and in the same business group as that of the applicant being created.
 *
 * <p><b>Post Success</b><br>
 * The person, application, default applicant assignment and if required
 * associated assignment budget values and a letter request are successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The applicant will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The date an application was received and thus the
 * effective start date of the applicant record, application and applicant
 * assignment.
 * @param p_business_group_id The applicant's business group.
 * @param p_last_name Applicant's last name.
 * @param p_person_type_id This is the identifier corrresponding to the type of
 * person. If an identification number is not specified, then the API will use
 * the default 'APL' type for the business group.
 * @param p_applicant_number Applicant number, if the number generation method
 * is Manual then this parameter is mandatory. If the number generation method
 * is Automatic then the value of this parameter must be NULL. If p_validate is
 * false and the applicant number generation method is Automatic this will be
 * set to the generated applicant number of the person created. If p_validate
 * is false and the applicant number generation method is manual this will be
 * set to the same value passed in. If p_validate is true this will be set to
 * the same value as passed in.
 * @param p_per_comments Comments for person record.
 * @param p_date_employee_data_verified Date when the applicant last verified
 * the data.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address of the applicant.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Applicant's first name.
 * @param p_preferred_name Alternative name of the applicant.
 * @param p_marital_status Marital status of the applicant. Valid values are
 * defined by 'MAR_STATUS' lookup type.
 * @param p_middle_names Applicant's middle name(s).
 * @param p_nationality Applicant's nationality. Valid values are defined by
 * 'NATIONALITY' lookup type.
 * @param p_pesel_value National identifier of the applicant.
 * @param p_maiden_name Previous last name of the applicant.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by 'REGISTERED_DISABLED' lookup type.
 * @param p_sex Applicant's sex.
 * @param p_title Applicant's title. Valid values are defined by 'TITLE' lookup
 * type.
 * @param p_work_telephone Work telephone of the applicant.
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
 * @param p_nip_value The National Polish Tax identifier of the applicant.
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
 * @param p_background_check_status Yes/No flag indicates whether
 * background check has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_correspondence_language Preferred language for correspondance.
 * @param p_fte_capacity This parameter is currently not supported.
 * @param p_hold_applicant_date_until Date up to which applicant's file is to
 * be maintained.
 * @param p_honors Honors or degrees awarded.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Office Number of the applicant.
 * @param p_on_military_service Yes/No flag indicating whether the applicant is
 * employed in military service.
 * @param p_prefix Obsolete parameter, do not use.
 * @param p_projected_start_date This parameter is currently not supported.
 * @param p_resume_exists Yes/No flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_student_status Full time/part time status of student. Valid values
 * are defined by 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Type of work schedule indicating which days the
 * person works. Valid values are defined by 'WORK_SCHEDULE' lookup type.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_date_of_death Date of death of the applicant.
 * @param p_benefit_group_id Identification for benefit group.
 * @param p_receipt_of_death_cert_date Date when the death certificate was
 * received.
 * @param p_coord_ben_med_pln_no Coordination of benefits medical group plan
 * number.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag.
 * @param p_uses_tobacco_flag Tobacoo type used by the applicant. Valid values
 * are defined by 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire of the applicant.
 * @param p_town_of_birth Town or city of birth of the applicant.
 * @param p_region_of_birth Geographical region of birth of the applicant.
 * @param p_country_of_birth Country of birth of the applicant.
 * @param p_global_person_id Global Identification number for the person.
 * @param p_party_id Identifier for the party.
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
 * to the effective start date of the applicant. If p_validate is true this
 * will be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the applicant. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the applicant. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created applicant
 * record. If p_validate is true or no comment text was provided, then this
 * will be null.
 * @param p_assignment_sequence If p_validate is false, then this will be set
 * to the assignment sequence of the assignment created. If p_validate is true,
 * this parameter is set to null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Applicant for Poland
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:scope public
 * @rep:lifecycle deprecated
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pl_applicant
  (p_validate                     in     boolean  default false
  ,p_date_received                in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_person_type_id               in     number   default null
  ,p_applicant_number             in out nocopy varchar2
  ,p_per_comments                 in     varchar2 default null
  ,p_date_employee_data_verified  in     date     default null
  ,p_date_of_birth                in     date     default null
  ,p_email_address                in     varchar2 default null
  ,p_expense_check_send_to_addres in     varchar2 default null
  ,p_first_name                   in     varchar2
  ,p_preferred_name               in     varchar2 default null
  ,p_marital_status               in     varchar2 default null
  ,p_middle_names                 in     varchar2 default null
  ,p_nationality                  in     varchar2 default null
  ,p_pesel_value                  in     varchar2 default null
  ,p_maiden_name                  in     varchar2 default null
  ,p_registered_disabled_flag     in     varchar2 default null
  ,p_sex                          in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_work_telephone               in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_attribute21                  in     varchar2 default null
  ,p_attribute22                  in     varchar2 default null
  ,p_attribute23                  in     varchar2 default null
  ,p_attribute24                  in     varchar2 default null
  ,p_attribute25                  in     varchar2 default null
  ,p_attribute26                  in     varchar2 default null
  ,p_attribute27                  in     varchar2 default null
  ,p_attribute28                  in     varchar2 default null
  ,p_attribute29                  in     varchar2 default null
  ,p_attribute30                  in     varchar2 default null
  ,p_per_information_category     in     varchar2 default null
  ,p_nip_value                    in     varchar2 default null
  ,p_per_information2             in     varchar2 default null
  ,p_per_information3             in     varchar2 default null
  ,p_per_information4             in     varchar2 default null
  ,p_per_information5             in     varchar2 default null
  ,p_per_information6             in     varchar2 default null
  ,p_per_information7             in     varchar2 default null
  ,p_per_information8             in     varchar2 default null
  ,p_per_information9             in     varchar2 default null
  ,p_per_information10            in     varchar2 default null
  ,p_per_information11            in     varchar2 default null
  ,p_per_information12            in     varchar2 default null
  ,p_per_information13            in     varchar2 default null
  ,p_per_information14            in     varchar2 default null
  ,p_per_information15            in     varchar2 default null
  ,p_per_information16            in     varchar2 default null
  ,p_per_information17            in     varchar2 default null
  ,p_per_information18            in     varchar2 default null
  ,p_per_information19            in     varchar2 default null
  ,p_per_information20            in     varchar2 default null
  ,p_per_information21            in     varchar2 default null
  ,p_per_information22            in     varchar2 default null
  ,p_per_information23            in     varchar2 default null
  ,p_per_information24            in     varchar2 default null
  ,p_per_information25            in     varchar2 default null
  ,p_per_information26            in     varchar2 default null
  ,p_per_information27            in     varchar2 default null
  ,p_per_information28            in     varchar2 default null
  ,p_per_information29            in     varchar2 default null
  ,p_per_information30            in     varchar2 default null
  ,p_background_check_status      in     varchar2 default null
  ,p_background_date_check        in     date     default null
  ,p_correspondence_language      in     varchar2 default null
  ,p_fte_capacity                 in     number   default null
  ,p_hold_applicant_date_until    in     date     default null
  ,p_honors                       in     varchar2 default null
  ,p_mailstop                     in     varchar2 default null
  ,p_office_number                in     varchar2 default null
  ,p_on_military_service          in     varchar2 default null
  ,p_prefix                       in     varchar2 default null
  ,p_projected_start_date         in     date     default null
  ,p_resume_exists                in     varchar2 default null
  ,p_resume_last_updated          in     date     default null
  ,p_student_status               in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_suffix                       in     varchar2 default null
  ,p_date_of_death                in     date     default null
  ,p_benefit_group_id             in     number   default null
  ,p_receipt_of_death_cert_date   in     date     default null
  ,p_coord_ben_med_pln_no         in     varchar2 default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 default 'N'
  ,p_uses_tobacco_flag            in     varchar2 default null
  ,p_dpdnt_adoption_date          in     date     default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 default 'N'
  ,p_original_date_of_hire        in     date     default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_global_person_id             in      varchar2 default null
  ,p_party_id                     in      number default null
  ,p_person_id                       out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_application_id                  out nocopy number
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_apl_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_per_comment_id                  out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_name_combination_warning        out nocopy boolean
  ,p_orig_hire_warning               out nocopy boolean
  );
--
-- ---------------------------------------------------------------------------
--|----------------------< create_pl_applicant >---------------------------|
-- ---------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The following procedure creates a Polish applicant.
 *
 * This API is an alternative to the API create_applicant. If p_validate is set
 * to false, an applicant is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Poland legislation must already exist. Also a valid
 * person_type_id, with a corresponding system type of 'APL', must be active
 * and in the same business group as that of the applicant being created.
 *
 * <p><b>Post Success</b><br>
 * The person, application, default applicant assignment and if required
 * associated assignment budget values and a letter request are successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The applicant will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The date an application was received and thus the
 * effective start date of the applicant record, application and applicant
 * assignment.
 * @param p_business_group_id The applicant's business group.
 * @param p_last_name Applicant's last name.
 * @param p_person_type_id This is the identifier corrresponding to the type of
 * person. If an identification number is not specified, then the API will use
 * the default 'APL' type for the business group.
 * @param p_applicant_number Applicant number, if the number generation method
 * is Manual then this parameter is mandatory. If the number generation method
 * is Automatic then the value of this parameter must be NULL. If p_validate is
 * false and the applicant number generation method is Automatic this will be
 * set to the generated applicant number of the person created. If p_validate
 * is false and the applicant number generation method is manual this will be
 * set to the same value passed in. If p_validate is true this will be set to
 * the same value as passed in.
 * @param p_per_comments Comments for person record.
 * @param p_date_employee_data_verified Date when the applicant last verified
 * the data.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address of the applicant.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Applicant's first name.
 * @param p_preferred_name Alternative name of the applicant.
 * @param p_marital_status Marital status of the applicant. Valid values are
 * defined by 'MAR_STATUS' lookup type.
 * @param p_middle_names Applicant's middle name(s).
 * @param p_nationality Applicant's nationality. Valid values are defined by
 * 'NATIONALITY' lookup type.
 * @param p_pesel National identifier of the applicant.
 * @param p_maiden_name Previous last name of the applicant.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by 'REGISTERED_DISABLED' lookup type.
 * @param p_sex Applicant's sex.
 * @param p_title Applicant's title. Valid values are defined by 'TITLE' lookup
 * type.
 * @param p_work_telephone Work telephone of the applicant.
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
 * @param p_nip The National Polish Tax identifier of the applicant.
 * @param p_insured_by_employee Indicates if the person is insured by the
 * employee (health insurance).Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_inheritor Indicates if the person is an inheritor.Valid values are
 * are defined by 'YES_NO' lookup type.
 * @param p_oldage_pension_rights This indicates whether the applicant
 * has old age or pension rights.Valid values are defined by
 * 'PL_OLDAGE_PENSION_RIGHTS' lookup type.
 * @param p_national_fund_of_health This indicates the national fund of health
 * to which the applicant belongs.Valid values are defined by
 * 'PL_NATIONAL_FUND_OF_HEALTH' lookup type.
 * @param p_tax_office Specifies the tax office of the applicant.
 * @param p_legal_employer Specifies the legal employer of the applicant.
 * @param p_citizenship This indicates the citizenship of the applicant.
 * Valid values are defined by 'PL_CITIZENSHIP' lookup type.
 * @param p_background_check_status Yes/No flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_correspondence_language Preferred language for correspondance.
 * @param p_fte_capacity This parameter is currently not supported.
 * @param p_hold_applicant_date_until Date up to which applicant's file is to
 * be maintained.
 * @param p_honors Honors or degrees awarded.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Office Number of the applicant.
 * @param p_on_military_service Yes/No flag indicating whether the applicant is
 * employed in military service.
 * @param p_prefix Obsolete parameter, do not use.
 * @param p_projected_start_date This parameter is currently not supported.
 * @param p_resume_exists Yes/No flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_student_status Full time/part time status of student. Valid values
 * are defined by 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Type of work schedule indicating which days the
 * person works. Valid values are defined by 'WORK_SCHEDULE' lookup type.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_date_of_death Date of death of the applicant.
 * @param p_benefit_group_id Identification for benefit group.
 * @param p_receipt_of_death_cert_date Date when the death certificate was
 * received.
 * @param p_coord_ben_med_pln_no Coordination of benefits medical group plan
 * number.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag.
 * @param p_uses_tobacco_flag Tobacoo type used by the applicant. Valid values
 * are defined by 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire of the applicant.
 * @param p_town_of_birth Town or city of birth of the applicant.
 * @param p_region_of_birth Geographical region of birth of the applicant.
 * @param p_country_of_birth Country of birth of the applicant.
 * @param p_global_person_id Global Identification number for the person.
 * @param p_party_id Identifier for the party.
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
 * to the effective start date of the applicant. If p_validate is true this
 * will be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the applicant. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the applicant. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created applicant
 * record. If p_validate is true or no comment text was provided, then this
 * will be null.
 * @param p_assignment_sequence If p_validate is false, then this will be set
 * to the assignment sequence of the assignment created. If p_validate is true,
 * this parameter is set to null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Applicant for Poland
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--


procedure create_pl_applicant
  (p_validate                     in     boolean  default false
  ,p_date_received                in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_person_type_id               in     number   default null
  ,p_applicant_number             in out nocopy varchar2
  ,p_per_comments                 in     varchar2 default null
  ,p_date_employee_data_verified  in     date     default null
  ,p_date_of_birth                in     date     default null
  ,p_email_address                in     varchar2 default null
  ,p_expense_check_send_to_addres in     varchar2 default null
  ,p_first_name                   in     varchar2
  ,p_preferred_name               in     varchar2 default null
  ,p_marital_status               in     varchar2 default null
  ,p_middle_names                 in     varchar2 default null
  ,p_nationality                  in     varchar2 default null
  ,p_pesel                        in     varchar2 default null
  ,p_maiden_name                  in     varchar2 default null
  ,p_registered_disabled_flag     in     varchar2 default null
  ,p_sex                          in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_work_telephone               in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_attribute21                  in     varchar2 default null
  ,p_attribute22                  in     varchar2 default null
  ,p_attribute23                  in     varchar2 default null
  ,p_attribute24                  in     varchar2 default null
  ,p_attribute25                  in     varchar2 default null
  ,p_attribute26                  in     varchar2 default null
  ,p_attribute27                  in     varchar2 default null
  ,p_attribute28                  in     varchar2 default null
  ,p_attribute29                  in     varchar2 default null
  ,p_attribute30                  in     varchar2 default null
  ,p_per_information_category     in     varchar2 default null
  ,p_nip                          in     varchar2 default null
  ,p_insured_by_employee          in     varchar2 default null
  ,p_inheritor                    in     varchar2 default null
  ,p_oldage_pension_rights        in     varchar2 default null
  ,p_national_fund_of_health      in     varchar2 default null
  ,p_tax_office                   in     varchar2 default null
  ,p_legal_employer               in     varchar2 default null
  ,p_citizenship                  in     varchar2 default null
  ,p_background_check_status      in     varchar2 default null
  ,p_background_date_check        in     date     default null
  ,p_correspondence_language      in     varchar2 default null
  ,p_fte_capacity                 in     number   default null
  ,p_hold_applicant_date_until    in     date     default null
  ,p_honors                       in     varchar2 default null
  ,p_mailstop                     in     varchar2 default null
  ,p_office_number                in     varchar2 default null
  ,p_on_military_service          in     varchar2 default null
  ,p_prefix                       in     varchar2 default null
  ,p_projected_start_date         in     date     default null
  ,p_resume_exists                in     varchar2 default null
  ,p_resume_last_updated          in     date     default null
  ,p_student_status               in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_suffix                       in     varchar2 default null
  ,p_date_of_death                in     date     default null
  ,p_benefit_group_id             in     number   default null
  ,p_receipt_of_death_cert_date   in     date     default null
  ,p_coord_ben_med_pln_no         in     varchar2 default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 default 'N'
  ,p_uses_tobacco_flag            in     varchar2 default null
  ,p_dpdnt_adoption_date          in     date     default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 default 'N'
  ,p_original_date_of_hire        in     date     default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_global_person_id             in      varchar2 default null
  ,p_party_id                     in      number default null
  ,p_person_id                       out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_application_id                  out nocopy number
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_apl_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_per_comment_id                  out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_name_combination_warning        out nocopy boolean
  ,p_orig_hire_warning               out nocopy boolean
  );

END hr_pl_applicant_api;

 

/
