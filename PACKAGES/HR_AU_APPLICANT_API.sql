--------------------------------------------------------
--  DDL for Package HR_AU_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AU_APPLICANT_API" AUTHID CURRENT_USER AS
/* $Header: hrauwraa.pkh 120.1 2005/10/02 01:58:59 aroussel $ */
/*#
 * This package contains applicant API for Australia.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Applicant for Australia
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_au_applicant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new applicant for Australia.
 *
 * A default primary assignment and an application for the applicant are
 * created with this API. The API calls the generic API create_applicant, with
 * the parameters set as appropriate for an applicant in Australia. Secure user
 * functionality is not included in this version of the API. As this API is
 * effectively an alternative to the API create_applicant, see that API for
 * further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A business group for Australian legislation must be specified. See core API
 * create_applicant.
 *
 * <p><b>Post Success</b><br>
 * The person, primary assignment and application will be successfully
 * inserted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the applicant, DEFAULT assignment or application and
 * raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The applicant hire date and effective start date of
 * the person, primary assignment and application.
 * @param p_business_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BUSINESS_GROUP_ID}
 * @param p_last_name {@rep:casecolumn PER_ALL_PEOPLE_F.LAST_NAME}
 * @param p_sex The applicant's legal gender as defined by the lookup type
 * "SEX".
 * @param p_person_type_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_TYPE_ID}
 * @param p_applicant_number If the number generation method is Manual then
 * this parameter is mandatory. If the number generation method is Automatic
 * then the value of this parameter must be NULL. When the API completes, if
 * p_validate is false and the applicant number generation method is Automatic
 * this will be set to the generated applicant number of the person created. If
 * p_validate is false and the applicant number generation method is manual or
 * if p_validate is true this will be set to the same value passed in.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DATE_EMPLOYEE_DATA_VERIFIED}
 * @param p_date_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_BIRTH}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_expense_check_send_to_addres The applicant's address to which the
 * expense should be sent. Valid values are determined by the lookup type
 * 'HOME_OFFICE'.
 * @param p_first_name {@rep:casecolumn PER_ALL_PEOPLE_F.FIRST_NAME}
 * @param p_known_as {@rep:casecolumn PER_ALL_PEOPLE_F.KNOWN_AS}
 * @param p_marital_status The applicant's marital status. Valid values are
 * defined by the lookup type 'MAR_STATUS' .
 * @param p_middle_names {@rep:casecolumn PER_ALL_PEOPLE_F.MIDDLE_NAMES}
 * @param p_nationality The applicant' s nationality. Valid values are defined
 * by the lookup type 'NATIONALITY' .
 * @param p_national_identifier {@rep:casecolumn
 * PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_previous_last_name {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PREVIOUS_LAST_NAME}
 * @param p_registered_disabled_flag This flag indicates whether the applicant
 * is classified as disabled. Valid values are defined by the lookup type
 * 'REGISTERED_DISABLED'.
 * @param p_title Applicant's Title e.g. Mr, Mrs, Dr. Valid values are defined
 * by 'TITLE' lookup type.
 * @param p_work_telephone {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_TELEPHONE}
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
 * @param p_country_of_birth {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COUNTRY_OF_BIRTH}
 * @param p_background_check_status The applicant's background check status.
 * Valid values are defined by the lookup type 'YES_NO'.
 * @param p_background_date_check {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BACKGROUND_DATE_CHECK}
 * @param p_correspondence_language {@rep:casecolumn
 * PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE}
 * @param p_fte_capacity {@rep:casecolumn PER_ALL_PEOPLE_F.FTE_CAPACITY}
 * @param p_hold_applicant_date_until {@rep:casecolumn
 * PER_ALL_PEOPLE_F.HOLD_APPLICANT_DATE_UNTIL}
 * @param p_honors {@rep:casecolumn PER_ALL_PEOPLE_F.HONORS}
 * @param p_mailstop {@rep:casecolumn PER_ALL_PEOPLE_F.MAILSTOP}
 * @param p_office_number {@rep:casecolumn PER_ALL_PEOPLE_F.OFFICE_NUMBER}
 * @param p_on_military_service Indicates if the applicant is on military
 * service. Valid values are defined by the lookup type 'YES_NO'.
 * @param p_pre_name_adjunct {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PRE_NAME_ADJUNCT}
 * @param p_projected_start_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PROJECTED_START_DATE}
 * @param p_resume_exists Indicates if the applicant's resume exists. Valid
 * values are defined by the lookup type 'YES_NO'.
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_student_status {@rep:casecolumn PER_ALL_PEOPLE_F.STUDENT_STATUS}
 * @param p_work_schedule The applicant's work schedule, defined by the lookup
 * type 'WORK_SCHEDULE' .
 * @param p_suffix {@rep:casecolumn PER_ALL_PEOPLE_F.SUFFIX}
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_benefit_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BENEFIT_GROUP_ID}
 * @param p_receipt_of_death_cert_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RECEIPT_OF_DEATH_CERT_DATE}
 * @param p_coord_ben_med_pln_no {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_PLN_NO}
 * @param p_coord_ben_no_cvg_flag The applicant's coordination of benefits no
 * other coverage, valid values as applicable are defined by 'YES_NO' lookup
 * type.
 * @param p_uses_tobacco_flag Indicates whether the applicant uses tabacco.
 * Valid values are defined by the lookup type 'YES_NO'.
 * @param p_dpdnt_adoption_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DPDNT_ADOPTION_DATE}
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the applicant's dependent
 * have undertaken voluntary service. Valid values are defined by the lookup
 * type 'YES_NO'.
 * @param p_original_date_of_hire {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_application_id If p_validate is FALSE, this uniquely identifies the
 * application created. If p_validate is true this parameter will be NULL.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_asg_object_version_number If p_validate is false, then set to the
 * version number of the created assignment. If p_validate is true, then the
 * value will be null.
 * @param p_apl_object_version_number If p_validate is FALSE, this will be set
 * to the version number of the application created. If p_validate is true this
 * parameter will be set to NULL.
 * @param p_per_effective_start_date If p_validate is FALSE, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be NULL.
 * @param p_per_effective_end_date If p_validate is FALSE, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * NULL.
 * @param p_full_name If p_validate is FALSE, this will be set to the complete
 * full name of the person. If p_validate is true this will be NULL.
 * @param p_per_comment_id If p_validate is FALSE this will be set to the id of
 * the corresponding person comment row,if any comment text exists. If
 * p_validate is true this will be NULL.
 * @param p_assignment_sequence If p_validate is FALSE this will be set to the
 * sequence number of the primary assignment. If p_validate is true this will
 * be NULL.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning If p_validate is false,this is set to true if the
 * original date of hire is provided and the person type is not
 * Employee,Employee-Applicant,Ex-Employee or Ex-Employee Applicant.
 * @rep:displayname Create Applicant for Australia
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE create_au_applicant
    (p_validate                      IN     BOOLEAN  DEFAULT FALSE
    ,p_date_received                 IN     DATE
    ,p_business_group_id             IN     NUMBER
    ,p_last_name                     IN     VARCHAR2
    ,p_sex                           IN     VARCHAR2 DEFAULT NULL
    ,p_person_type_id                IN     NUMBER   DEFAULT NULL
    ,p_applicant_number              IN OUT NOCOPY VARCHAR2
    ,p_comments                      IN     VARCHAR2 DEFAULT NULL
    ,p_date_employee_data_verified   IN     DATE     DEFAULT NULL
    ,p_date_of_birth                 IN     DATE     DEFAULT NULL
    ,p_email_address                 IN     VARCHAR2 DEFAULT NULL
    ,p_expense_check_send_to_addres  IN     VARCHAR2 DEFAULT NULL
    ,p_first_name                    IN     VARCHAR2 DEFAULT NULL
    ,p_known_as                      IN     VARCHAR2 DEFAULT NULL
    ,p_marital_status                IN     VARCHAR2 DEFAULT NULL
    ,p_middle_names                  IN     VARCHAR2 DEFAULT NULL
    ,p_nationality                   IN     VARCHAR2 DEFAULT NULL
    ,p_national_identifier           IN     VARCHAR2 DEFAULT NULL
    ,p_previous_last_name            IN     VARCHAR2 DEFAULT NULL
    ,p_registered_disabled_flag      IN     VARCHAR2 DEFAULT NULL
    ,p_title                         IN     VARCHAR2 DEFAULT NULL
    ,p_work_telephone                IN     VARCHAR2 DEFAULT NULL
    ,p_attribute_category            IN     VARCHAR2 DEFAULT NULL
    ,p_attribute1                    IN     VARCHAR2 DEFAULT NULL
    ,p_attribute2                    IN     VARCHAR2 DEFAULT NULL
    ,p_attribute3                    IN     VARCHAR2 DEFAULT NULL
    ,p_attribute4                    IN     VARCHAR2 DEFAULT NULL
    ,p_attribute5                    IN     VARCHAR2 DEFAULT NULL
    ,p_attribute6                    IN     VARCHAR2 DEFAULT NULL
    ,p_attribute7                    IN     VARCHAR2 DEFAULT NULL
    ,p_attribute8                    IN     VARCHAR2 DEFAULT NULL
    ,p_attribute9                    IN     VARCHAR2 DEFAULT NULL
    ,p_attribute10                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute11                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute12                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute13                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute14                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute15                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute16                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute17                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute18                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute19                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute20                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute21                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute22                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute23                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute24                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute25                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute26                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute27                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute28                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute29                   IN     VARCHAR2 DEFAULT NULL
    ,p_attribute30                   IN     VARCHAR2 DEFAULT NULL
    ,p_country_of_birth              IN     VARCHAR2 DEFAULT NULL
    ,p_background_check_status       IN     VARCHAR2 DEFAULT NULL
    ,p_background_date_check         IN     DATE     DEFAULT NULL
    ,p_correspondence_language       IN     VARCHAR2 DEFAULT NULL
    ,p_fte_capacity                  IN     NUMBER   DEFAULT NULL
    ,p_hold_applicant_date_until     IN     DATE     DEFAULT NULL
    ,p_honors                        IN     VARCHAR2 DEFAULT NULL
    ,p_mailstop                      IN     VARCHAR2 DEFAULT NULL
    ,p_office_number                 IN     VARCHAR2 DEFAULT NULL
    ,p_on_military_service           IN     VARCHAR2 DEFAULT NULL
    ,p_pre_name_adjunct              IN     VARCHAR2 DEFAULT NULL
    ,p_projected_start_date          IN     DATE     DEFAULT NULL
    ,p_resume_exists                 IN     VARCHAR2 DEFAULT NULL
    ,p_resume_last_updated           IN     DATE     DEFAULT NULL
    ,p_student_status                IN     VARCHAR2 DEFAULT NULL
    ,p_work_schedule                 IN     VARCHAR2 DEFAULT NULL
    ,p_suffix                        IN     VARCHAR2 DEFAULT NULL
    ,p_date_of_death                 IN     DATE     DEFAULT NULL
    ,p_benefit_group_id              IN     NUMBER   DEFAULT NULL
    ,p_receipt_of_death_cert_date    IN     DATE     DEFAULT NULL
    ,p_coord_ben_med_pln_no          IN     VARCHAR2 DEFAULT NULL
    ,p_coord_ben_no_cvg_flag         IN     VARCHAR2 DEFAULT 'N'
    ,p_uses_tobacco_flag             IN     VARCHAR2 DEFAULT NULL
    ,p_dpdnt_adoption_date           IN     DATE     DEFAULT NULL
    ,p_dpdnt_vlntry_svce_flag        IN     VARCHAR2 DEFAULT 'N'
    ,p_original_date_of_hire         IN     DATE     DEFAULT NULL
    ,p_person_id                        OUT NOCOPY NUMBER
    ,p_assignment_id                    OUT NOCOPY NUMBER
    ,p_application_id                   OUT NOCOPY NUMBER
    ,p_per_object_version_number        OUT NOCOPY NUMBER
    ,p_asg_object_version_number        OUT NOCOPY NUMBER
    ,p_apl_object_version_number        OUT NOCOPY NUMBER
    ,p_per_effective_start_date         OUT NOCOPY DATE
    ,p_per_effective_end_date           OUT NOCOPY DATE
    ,p_full_name                        OUT NOCOPY VARCHAR2
    ,p_per_comment_id                   OUT NOCOPY NUMBER
    ,p_assignment_sequence              OUT NOCOPY NUMBER
    ,p_name_combination_warning         OUT NOCOPY BOOLEAN
    ,p_orig_hire_warning                OUT NOCOPY BOOLEAN
    );

END hr_au_applicant_api;

 

/