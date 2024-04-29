--------------------------------------------------------
--  DDL for Package HR_IN_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_CONTINGENT_WORKER_API" AUTHID CURRENT_USER as
/* $Header: pecwkini.pkh 120.1 2005/10/02 02:40 aroussel $ */
/*#
 * This package contains contingent worker APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contingent Worker for India
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_in_cwk >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a contingent worker.
 *
 * The API creates a person record and a default contingent worker assignment
 * for a new non-payrolled worker.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * If person_type_id is supplied, it must have a corresponding system person
 * type of 'CWK', must be active and be in the same business group as that of
 * the employee being created.
 *
 * <p><b>Post Success</b><br>
 * Creates a contingent worker.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a contingent worker and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date Start date for person, default assignment and placement
 * record.
 * @param p_business_group_id The contingent worker's business group.
 * @param p_last_name Last name of the contingent worker.
 * @param p_person_type_id This is the identifier corrresponding to the type of
 * person. If an identification number is not specified, then the API will use
 * the default 'CWK' type for the business group.
 * @param p_npw_number If p_validate is false then the parameter value passed
 * is used as the number of non-payrolled worker. If no value is passed the
 * number of non-payrolled worker is generated. If p_validate is true null is
 * returned.
 * @param p_background_check_status Indicates whether background check has been
 * performed. Valid values are defined by 'Yes_No' lookup type.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Blood type of the contingent worker. Valid values are
 * defined by 'BLOOD_TYPE' lookup type.
 * @param p_comments Contingent worker comment text.
 * @param p_correspondence_language Preferred language for correspondance.
 * @param p_country_of_birth Country of birth of the contingent worker. Valid
 * values are defined in FND_TERRITORIES
 * @param p_date_of_birth Date of birth of the contingent worker.
 * @param p_date_of_death Date of death of the contingent worker.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_email_address Email address of the contingent worker.
 * @param p_first_name First name of the contingent worker.
 * @param p_fte_capacity Full-time employment capacity of the contingent
 * worker.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office of the contingent
 * worker.
 * @param p_alias_name Alias name of the contingent worker.
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location for the contingent worker.
 * @param p_marital_status Marital status of the contingent worker. Valid
 * values are defined by 'MAR_STATUS' lookup type.
 * @param p_middle_name Contingent worker's middle name(s).
 * @param p_national_identifier National identifier of the contingent worker.
 * @param p_nationality Contingent worker's nationality. Valid values are
 * defined by 'NATIONALITY' lookup type.
 * @param p_office_number Office Number of the contingent worker.
 * @param p_on_military_service Y/N flag indicating whether the contingent
 * worker is employed in military service.
 * @param p_party_id Identifier for the party.
 * @param p_pre_name_adjunct Name prefix of the contingent worker.
 * @param p_previous_last_name Previous last name of the contingent worker.
 * @param p_projected_placement_end Obsolete parameter, do not use.
 * @param p_receipt_of_death_cert_date Date when the death certificate is
 * received.
 * @param p_region_of_birth Geographical region of birth of the contingent
 * worker.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by 'REGISTERED_DISABLED' lookup type.
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Y/N flag indicaing whether the person has
 * multiple passports.
 * @param p_sex Contingent worker's sex.
 * @param p_student_status Full time/part time status of the contingent worker.
 * @param p_suffix Name Suffix of the contingent worker.
 * @param p_title Title of the contingent worker. Valid values are defined by
 * 'TITLE' lookup type.
 * @param p_place_of_birth Town or city of birth of the contingent worker.
 * @param p_uses_tobacco_flag Tobacco type used by the contingent worker. Valid
 * values are defined by 'TOBACCO_USER' lookup type.
 * @param p_vendor_id Identifier of workers supplying organization.
 * @param p_work_schedule Type of work schedule indicating which days the
 * contingent worker works. Valid values are defined by 'WORK_SCHEDULE' lookup
 * type.
 * @param p_work_telephone Work telephone of the contingent worker.
 * @param p_exp_check_send_to_address Mailing address of the contingent worker.
 * @param p_hold_applicant_date_until Date until which the applicant should be
 * put on hold.
 * @param p_date_employee_data_verified Date when the employee last verified
 * the data.
 * @param p_benefit_group_id Identification for benefit group.
 * @param p_coord_ben_med_pln_no Coordination of benefits medical group plan
 * number.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag.
 * @param p_original_date_of_hire Original date of hire of the contingent
 * worker.
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
 * @param p_pan PAN of the person. Should be in correct format (XXXXX9999X).
 * @param p_pan_af PAN Applied for Flag. Valid values are defined by 'YES_NO'
 * lookup type. Has to be null if p_pan is populated.
 * @param p_ex_serviceman Military Status. Valid values are defined by 'YES_NO'
 * lookup type.
 * @param p_resident_status Residential Status of the person. Valid values are
 * defined by 'IN_RESIDENTIAL_STATUS' lookup type.
 * @param p_pf_number PF Number of the contingent worker.
 * @param p_esi_number ESI Nnumber of the contingent worker.
 * @param p_superannuation_number Superannuation Number of the contingent
 * worker.
 * @param p_gi_number Group Insurance Number of the contingent worker.
 * @param p_gratuity_number Gratuity Number of the contingent worker.
 * @param p_pension_number Pension Number of the contingent worker.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_pdp_object_version_number If p_validate is false, this will be set
 * to the version number of the person created. If p_validate is true this
 * parameter will be set to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created contingent worker comment
 * record. If p_validate is true or no comment text was provided, then will be
 * null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_assignment_sequence If p_validate is false, this will be set to the
 * sequence number of the default assignment created. If p_validate is true
 * this parameter will be set to null.
 * @param p_assignment_number If p_validate is false this will be set to the
 * assignment number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @rep:displayname Create Contingent Worker for India
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_in_cwk
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_start_date                    IN     DATE
  ,p_business_group_id             IN     NUMBER
  ,p_last_name                     IN     VARCHAR2
  ,p_person_type_id                IN     NUMBER   DEFAULT NULL
  ,p_npw_number                    IN OUT NOCOPY VARCHAR2
  ,p_background_check_status       IN     VARCHAR2 DEFAULT NULL
  ,p_background_date_check         IN     DATE     DEFAULT NULL
  ,p_blood_type                    IN     VARCHAR2 DEFAULT NULL
  ,p_comments                      IN     VARCHAR2 DEFAULT NULL
  ,p_correspondence_language       IN     VARCHAR2 DEFAULT NULL
  ,p_country_of_birth              IN     VARCHAR2 DEFAULT NULL
  ,p_date_of_birth                 IN     DATE     DEFAULT NULL
  ,p_date_of_death                 IN     DATE     DEFAULT NULL
  ,p_dpdnt_adoption_date           IN     DATE     DEFAULT NULL
  ,p_dpdnt_vlntry_svce_flag        IN     VARCHAR2 DEFAULT NULL
  ,p_email_address                 IN     VARCHAR2 DEFAULT NULL
  ,p_first_name                    IN     VARCHAR2 DEFAULT NULL
  ,p_fte_capacity                  IN     NUMBER   DEFAULT NULL
  ,p_honors                        IN     VARCHAR2 DEFAULT NULL
  ,p_internal_location             IN     VARCHAR2 DEFAULT NULL
  ,p_alias_name                    IN     VARCHAR2 DEFAULT NULL
  ,p_last_medical_test_by          IN     VARCHAR2 DEFAULT NULL
  ,p_last_medical_test_date        IN     DATE     DEFAULT NULL
  ,p_mailstop                      IN     VARCHAR2 DEFAULT NULL
  ,p_marital_status                IN     VARCHAR2 DEFAULT NULL
  ,p_middle_name                   IN     VARCHAR2 DEFAULT NULL
  ,p_national_identifier           IN     VARCHAR2 DEFAULT NULL
  ,p_nationality                   IN     VARCHAR2 DEFAULT NULL
  ,p_office_number                 IN     VARCHAR2 DEFAULT NULL
  ,p_on_military_service           IN     VARCHAR2 DEFAULT NULL
  ,p_party_id                      IN     NUMBER   DEFAULT NULL
  ,p_pre_name_adjunct              IN     VARCHAR2 DEFAULT NULL
  ,p_previous_last_name            IN     VARCHAR2 DEFAULT NULL
  ,p_projected_placement_end       IN     DATE     DEFAULT NULL
  ,p_receipt_of_death_cert_date    IN     DATE     DEFAULT NULL
  ,p_region_of_birth               IN     VARCHAR2 DEFAULT NULL
  ,p_registered_disabled_flag      IN     VARCHAR2 DEFAULT NULL
  ,p_resume_exists                 IN     VARCHAR2 DEFAULT NULL
  ,p_resume_last_updated           IN     DATE     DEFAULT NULL
  ,p_second_passport_exists        IN     VARCHAR2 DEFAULT NULL
  ,p_sex                           IN     VARCHAR2 DEFAULT NULL
  ,p_student_status                IN     VARCHAR2 DEFAULT NULL
  ,p_suffix                        IN     VARCHAR2 DEFAULT NULL
  ,p_title                         IN     VARCHAR2 DEFAULT NULL
  ,p_place_of_birth                IN     VARCHAR2 DEFAULT NULL
  ,p_uses_tobacco_flag             IN     VARCHAR2 DEFAULT NULL
  ,p_vendor_id                     IN     NUMBER   DEFAULT NULL
  ,p_work_schedule                 IN     VARCHAR2 DEFAULT NULL
  ,p_work_telephone                IN     VARCHAR2 DEFAULT NULL
  ,p_exp_check_send_to_address     IN     VARCHAR2 DEFAULT NULL
  ,p_hold_applicant_date_until     IN     DATE     DEFAULT NULL
  ,p_date_employee_data_verified   IN     DATE     DEFAULT NULL
  ,p_benefit_group_id              IN     NUMBER   DEFAULT NULL
  ,p_coord_ben_med_pln_no          IN     VARCHAR2 DEFAULT NULL
  ,p_coord_ben_no_cvg_flag         IN     VARCHAR2 DEFAULT NULL
  ,p_original_date_of_hire         IN     DATE     DEFAULT NULL
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
  ,p_pan                           IN     VARCHAR2 DEFAULT NULL
  ,p_pan_af                        IN     VARCHAR2 DEFAULT NULL
  ,p_ex_serviceman                 IN     VARCHAR2 DEFAULT NULL
  ,p_resident_status               IN     VARCHAR2 DEFAULT NULL
  ,p_pf_number                     IN     VARCHAR2 DEFAULT NULL
  ,p_esi_number                    IN     VARCHAR2 DEFAULT NULL
  ,p_superannuation_number         IN     VARCHAR2 DEFAULT NULL
  ,p_gi_number                     IN     VARCHAR2 DEFAULT NULL
  ,p_gratuity_number               IN     VARCHAR2 DEFAULT NULL
  ,p_pension_number                IN     VARCHAR2 DEFAULT NULL
  ,p_person_id                        OUT NOCOPY   NUMBER
  ,p_per_object_version_number        OUT NOCOPY   NUMBER
  ,p_per_effective_start_date         OUT NOCOPY   DATE
  ,p_per_effective_end_date           OUT NOCOPY   DATE
  ,p_pdp_object_version_number        OUT NOCOPY   NUMBER
  ,p_full_name                        OUT NOCOPY   VARCHAR2
  ,p_comment_id                       OUT NOCOPY   NUMBER
  ,p_assignment_id                    OUT NOCOPY   NUMBER
  ,p_asg_object_version_number        OUT NOCOPY   NUMBER
  ,p_assignment_sequence              OUT NOCOPY   NUMBER
  ,p_assignment_number                OUT NOCOPY   VARCHAR2
  ,p_name_combination_warning         OUT NOCOPY   BOOLEAN
  )  ;
END hr_in_contingent_worker_api;

 

/
