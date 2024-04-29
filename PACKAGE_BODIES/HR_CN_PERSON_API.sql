--------------------------------------------------------
--  DDL for Package Body HR_CN_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CN_PERSON_API" AS
/* $Header: hrcnwrpe.pkb 115.5 2003/01/31 11:36:32 statkar noship $ */

   -- Package Variables
   g_package   VARCHAR2(33) := 'hr_cn_person_api.';


-- ----------------------------------------------------------------------------
-- |---------------------------< update_cn_person >------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API updates the person record as identified by p_person_id
--   and p_object_version_number.
--
--   Note: The business group must have the CN legislation code.
--
-- Prerequisites
--   The person record, identified by p_person_id and
--   p_object_version_number, must already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the person will be
--                                                updated.
--   p_effective_date               Yes  date     The effective date for this
--                                                change
--   p_datetrack_update_mode        Yes  varchar2 Update mode
--   p_person_id                    Yes  number   ID of person
--   p_object_version_number        Yes  number   Version number of the person
--                                                record
--   p_person_type_id               No   number   Person type ID
--   p_family_or_last_name          No   varchar2 Family or Last name
--   p_applicant_number             No   varchar2 Applicant number
--   p_comments                     No   varchar2 Comment text
--   p_date_employee_data_verified  No   date     Date when the employee
--                                                data was last verified
--   p_date_of_birth                No   date     Date of birth
--   p_email_address                No   varchar2 Email address
--   p_employee_number              No   varchar2 Employee number
--   p_expense_check_send_to_addres No   varchar2 Mailing address
--   p_given_or_first_name          No   varchar2 Given or First name
--   p_known_as                     No   varchar2 Known as
--   p_marital_status               No   varchar2 Marital status
--   p_middle_names                 No   varchar2 Middle names
--   p_nationality                  No   varchar2 Nationality
--   p_citizen_identification_num   No   varchar2 Citizen Identification Number
--   p_previous_last_name           No   varchar2 Previous last name
--   p_registered_disabled_flag     No   varchar2 Registered disabled flag
--   p_sex                          No   varchar2 Gender
--   p_title                        No   varchar2 Title
--   p_vendor_id                    No   number   Foreign key to PO_VENDORS
--   p_work_telephone               No   varchar2 Work telephone
--   p_attribute_category           No   varchar2 Determines the context of
--                                                the descriptive flexfield
--   p_attribute1                   No   varchar2 Descriptive flexfield
--   p_attribute2                   No   varchar2 Descriptive flexfield
--   p_attribute3                   No   varchar2 Descriptive flexfield
--   p_attribute4                   No   varchar2 Descriptive flexfield
--   p_attribute5                   No   varchar2 Descriptive flexfield
--   p_attribute6                   No   varchar2 Descriptive flexfield
--   p_attribute7                   No   varchar2 Descriptive flexfield
--   p_attribute8                   No   varchar2 Descriptive flexfield
--   p_attribute9                   No   varchar2 Descriptive flexfield
--   p_attribute10                  No   varchar2 Descriptive flexfield
--   p_attribute11                  No   varchar2 Descriptive flexfield
--   p_attribute12                  No   varchar2 Descriptive flexfield
--   p_attribute13                  No   varchar2 Descriptive flexfield
--   p_attribute14                  No   varchar2 Descriptive flexfield
--   p_attribute15                  No   varchar2 Descriptive flexfield
--   p_attribute16                  No   varchar2 Descriptive flexfield
--   p_attribute17                  No   varchar2 Descriptive flexfield
--   p_attribute18                  No   varchar2 Descriptive flexfield
--   p_attribute19                  No   varchar2 Descriptive flexfield
--   p_attribute20                  No   varchar2 Descriptive flexfield
--   p_attribute21                  No   varchar2 Descriptive flexfield
--   p_attribute22                  No   varchar2 Descriptive flexfield
--   p_attribute23                  No   varchar2 Descriptive flexfield
--   p_attribute24                  No   varchar2 Descriptive flexfield
--   p_attribute25                  No   varchar2 Descriptive flexfield
--   p_attribute26                  No   varchar2 Descriptive flexfield
--   p_attribute27                  No   varchar2 Descriptive flexfield
--   p_attribute28                  No   varchar2 Descriptive flexfield
--   p_attribute29                  No   varchar2 Descriptive flexfield
--   p_attribute30                  No   varchar2 Descriptive flexfield
--   p_hukou_type                   Yes  varchar2 Hukou Type
--   p_hukou_location               Yes  varchar2 Hukou Location
--   p_highest_education_level      No   varchar2 Highest Education Level
--   p_number_of_children           No   varchar2 Number Of Children
--   p_expatriate_indicator         Yes  varchar2 Expatriate Indicator
--   p_health_status                No   varchar2 Health Status
--   p_tax_exemption_indicator      No   varchar2 Tax Exemption Indicator
--   p_perentage                    No   varchar2 Percentage
--   p_family_han_yu_pin_yin_name   No   varchar2 Family Han Yu Pin Yin Name
--   p_given_han_yu_pin_yin_name    No   varchar2 Given Han Yu Pin Yin Name
--   p_previous_name                No   varchar2 Previous Name
--   p_race_ethnic_origin           No   varchar2 Race or Etnic Origin
--   p_social_security_ic_number    No   varchar2 Social Security IC Number
--   p_suffix                       No   varchar2 Person's suffix
--   p_date_of_death                No   date     Currently unsupported
--   p_background_check_status      No   varchar2 Background check status
--   p_background_date_check        No   date     Background date check
--   p_blood_type                   No   varchar2 Blood group
--   p_correspondence_language      No   varchar2 Language for correspondence
--   p_fast_path_employee           No   varchar2 Currently unsupported
--   p_fte_capacity                 No   number   Full-time employment capacity
--   p_hold_applicant_date_until    No   date     Hold applicant until
--   p_honors                       No   varchar2 Honors
--   p_internal_location            No   varchar2 Internal location
--   p_last_medical_test_by         No   varchar2 Last medical test by
--   p_last_medical_test_date       No   date     Last medical test date
--   p_mailstop                     No   varchar2 Internal mail location
--   p_office_number                No   varchar2 Office number
--   p_on_military_service          No   varchar2 On military service
--   p_pre_name_adjunct             No   varchar2 Name prefix
--   p_projected_start_date         No   date     Currently unsupported
--   p_rehire_authorizor            No   varchar2 Currently unsupported
--   p_rehire_recommendation        No   varchar2 Re-hire recommendation
--   p_resume_exists                No   varchar2 Resume exists
--   p_resume_last_updated          No   date     Date resume last updated
--   p_second_passport_exists       No   varchar2 Second passport available
--                                                flag
--   p_student_status               No   varchar2 Student status
--   p_work_schedule                No   varchar2 Work schedule
--   p_rehire_reason                No   varchar2 Reason for re-hiring
--   p_benefit_group_id             No   number   Id for benefit group
--   p_receipt_of_death_cert_date   No   date     Date death certificate
--                                                was received
--   p_coord_ben_med_pln_no         No   varchar2 Number of an externally
--                                                provided medical plan
--   p_coord_ben_no_cvg_flag        No   varchar2 No other coverage flag
--   p_uses_tobacco_flag            No   varchar2 Uses tobacco flag
--   p_dpdnt_adoption_date          No   date     Date dependent was adopted
--   p_dpdnt_vlntry_svce_flag       No   varchar2 Dependent on voluntary
--                                                service flag
--   p_original_date_of_hire        No   date     Original date of hire
--   p_adjusted_svc_date            No   date     Adjusted service date
--   p_place_of_birth               No   varchar2 Place of birth
--   p_original_hometown            No   varchar2 Original hometown
--   p_country_of_birth             No   varchar2 Country of birth
--   p_global_person_id             No   varchar2 Global ID for the person
--   p_party_id                     No   number   Party ID for the person
--   p_npw_number                   No   varchar2 Non-payrolled worker number
--
-- Post Success:
--   The API will set the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of the
--                                           updated person record. If
--                                           p_validate is true set to the
--                                           same value you passed in.
--   p_employee_number              varchar2 If p_validate is false, set to
--                                           the value of the employee number
--                                           after the person record has
--                                           been updated.
--                                           If p_validate is true, set to
--                                           the same value you passed in.
--                                           This parameter depends on the
--                                           employee number generation method
--                                           of the business group.
--   p_effective_start_date         date     If p_validate is false, set to
--                                           the effective start date of the
--                                           person. If p_validate is true, set
--                                           to null.
--   p_effective_end_date           date     If p_validate is false, set to
--                                           the effective end date of the
--                                           person.
--                                           If p_validate is true, set to
--                                           null.
--   p_full_name                    varchar2 If p_validate is false, set to
--                                           the complete full name of the
--                                           person.
--                                           If p_validate is true, set to
--                                           null.
--   p_comment_id                   number   If p_validate is false and any
--                                           comment text exists, set to the id
--                                           of the corresponding person
--                                           comment row.
--                                           If p_validate is true, or no
--                                           comment text exists this will be
--                                           null.
--   p_name_combination_warning     boolean  Set to true if the new
--                                           combination (if changed) of last
--                                           name, first name and date of
--                                           birth already existed prior to
--                                           the update. Else, set to false.
--   p_assign_payroll_warning       boolean  Set to true if the date of birth
--                                           has been updated to a null value,
--                                           and this person is an employee,
--                                           otherwise set to false.
--   p_orig_hire_warning            boolean  Set to true if the original date
--                                           of hire is not null and the
--                                           person type is not EMP,EMP_APL,
--                                           EX_EMP or EX_EMP_APL.
--
--
-- Post Failure:
--   The API will not update the person and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
   PROCEDURE update_cn_person
    ( p_validate                      IN     BOOLEAN  DEFAULT false
     ,p_effective_date                IN     DATE
     ,p_datetrack_update_mode         IN     VARCHAR2
     ,p_person_id                     IN     NUMBER
     ,p_object_version_number         IN OUT NOCOPY   NUMBER
     ,p_person_type_id                IN     NUMBER   DEFAULT hr_api.g_number
     ,p_family_or_last_name           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_applicant_number              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_comments                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_date_employee_data_verified   IN     DATE     DEFAULT hr_api.g_date
     ,p_date_of_birth                 IN     DATE     DEFAULT hr_api.g_date
     ,p_email_address                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_employee_number               IN OUT NOCOPY   VARCHAR2
     ,p_expense_check_send_to_addres  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_given_or_first_name           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_known_as                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_marital_status                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_middle_names                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_nationality                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_citizen_identification_num    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_previous_last_name            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_registered_disabled_flag      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_sex                           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_title                         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_vendor_id                     IN     NUMBER   DEFAULT hr_api.g_number
     ,p_work_telephone                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute_category            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute1                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute2                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute3                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute4                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute5                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute6                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute7                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute8                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute9                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute10                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute11                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute12                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute13                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute14                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute15                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute16                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute17                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute18                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute19                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute21                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute22                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute23                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute24                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute25                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute26                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute27                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute28                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute29                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_attribute30                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_hukou_type	   	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_hukou_location		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_highest_education_level	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_number_of_children	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_expatriate_indicator	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_health_status		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_tax_exemption_indicator	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_percentage		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_family_han_yu_pin_yin_name    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_given_han_yu_pin_yin_name     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_previous_name		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_race_ethnic_orgin	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_social_security_ic_number     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_date_of_death		      IN     DATE     DEFAULT hr_api.g_date
     ,p_background_check_status	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_background_date_check	      IN     DATE     DEFAULT hr_api.g_date
     ,p_blood_type		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_correspondence_language	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_fast_path_employee	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_fte_capacity		      IN     NUMBER   DEFAULT hr_api.g_number
     ,p_hold_applicant_date_until     IN     DATE     DEFAULT hr_api.g_date
     ,p_honors			      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_internal_location	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_last_medical_test_by	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_last_medical_test_date	      IN     DATE     DEFAULT hr_api.g_date
     ,p_mailstop		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_office_number		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_on_military_service	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_pre_name_adjunct	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_projected_start_date	      IN     DATE     DEFAULT hr_api.g_date
     ,p_rehire_authorizor	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_rehire_recommendation	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_resume_exists		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_resume_last_updated	      IN     DATE     DEFAULT hr_api.g_date
     ,p_second_passport_exists	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_student_status		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_work_schedule		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_rehire_reason		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_suffix			      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_benefit_group_id	      IN     NUMBER   DEFAULT hr_api.g_number
     ,p_receipt_of_death_cert_date    IN     DATE     DEFAULT hr_api.g_date
     ,p_coord_ben_med_pln_no	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_coord_ben_no_cvg_flag	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_coord_ben_med_ext_er	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_coord_ben_med_pl_name	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_coord_ben_med_insr_crr_name   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_coord_ben_med_insr_crr_ident  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_coord_ben_med_cvg_strt_dt     IN     DATE     DEFAULT hr_api.g_date
     ,p_coord_ben_med_cvg_end_dt      IN     DATE     DEFAULT hr_api.g_date
     ,p_uses_tobacco_flag	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_dpdnt_adoption_date	      IN     DATE     DEFAULT hr_api.g_date
     ,p_dpdnt_vlntry_svce_flag 	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_original_date_of_hire	      IN     DATE     DEFAULT hr_api.g_date
     ,p_adjusted_svc_date	      IN     DATE     DEFAULT hr_api.g_date
     ,p_town_of_birth		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_region_of_birth		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_country_of_birth	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_global_person_id	      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
     ,p_party_id		      IN     NUMBER   DEFAULT hr_api.g_number
     ,p_npw_number		      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
--
     ,p_effective_start_date	      OUT    NOCOPY   DATE
     ,p_effective_end_date	      OUT    NOCOPY   DATE
     ,p_full_name		      OUT    NOCOPY   VARCHAR2
     ,p_comment_id		      OUT    NOCOPY   NUMBER
     ,p_name_combination_warning      OUT    NOCOPY   BOOLEAN
     ,p_assign_payroll_warning	      OUT    NOCOPY   BOOLEAN
     ,p_orig_hire_warning	      OUT    NOCOPY   BOOLEAN ) IS
   --
   -- Declare cursors and local variables
   --
   l_proc                VARCHAR2(72) := g_package||'update_cn_person';
   l_effective_date      DATE;
   --
BEGIN

    hr_cn_api.set_location(g_trace, 'Entering:'|| l_proc, 10);
   --
   -- Initialise local variables
   --
   l_effective_date := trunc(p_effective_date);

   --
   -- Check that the person exists.
   --

   hr_cn_api.check_person (p_person_id,'CN',l_effective_date);

   hr_cn_api.set_location(g_trace, l_proc, 20);

   --
   -- Update the person record using the update_person BP
   --
   hr_person_api.update_person
   ( p_validate                    	=>	     p_validate
     ,p_effective_date               	=>	     l_effective_date
     ,p_datetrack_update_mode         	=>	     p_datetrack_update_mode
     ,p_person_id                     	=>	     p_person_id
     ,p_object_version_number        	=>	     p_object_version_number
     ,p_person_type_id               	=>	     p_person_type_id
     ,p_last_name          	        =>	     p_family_or_last_name
     ,p_applicant_number              	=>	     p_applicant_number
     ,p_comments                    	=>	     p_comments
     ,p_date_employee_data_verified   	=>	     p_date_employee_data_verified
     ,p_date_of_birth                 	=>	     p_date_of_birth
     ,p_email_address                 	=>	     p_email_address
     ,p_employee_number               	=>	     p_employee_number
     ,p_expense_check_send_to_addres  	=>	     p_expense_check_send_to_addres
     ,p_first_name          	        =>	     p_given_or_first_name
     ,p_known_as                      	=>	     p_known_as
     ,p_marital_status                	=>	     p_marital_status
     ,p_middle_names                  	=>	     p_middle_names
     ,p_nationality                   	=>	     p_nationality
     ,p_national_identifier	        =>	     p_citizen_identification_num
     ,p_previous_last_name            	=>	     p_previous_last_name
     ,p_registered_disabled_flag      	=>	     p_registered_disabled_flag
     ,p_sex                           	=>	     p_sex
     ,p_title                         	=>	     p_title
     ,p_vendor_id                     	=>	     p_vendor_id
     ,p_work_telephone                	=>	     p_work_telephone
     ,p_attribute_category            	=>	     p_attribute_category
     ,p_attribute1                   	=>	     p_attribute1
     ,p_attribute2                    	=>	     p_attribute2
     ,p_attribute3                   	=>	     p_attribute3
     ,p_attribute4                   	=>	     p_attribute4
     ,p_attribute5                    	=>	     p_attribute5
     ,p_attribute6                   	=>	     p_attribute6
     ,p_attribute7                    	=>	     p_attribute7
     ,p_attribute8                    	=>	     p_attribute8
     ,p_attribute9                    	=>	     p_attribute9
     ,p_attribute10                  	=>	     p_attribute10
     ,p_attribute11                   	=>	     p_attribute11
     ,p_attribute12                   	=>	     p_attribute12
     ,p_attribute13                   	=>	     p_attribute13
     ,p_attribute14                   	=>	     p_attribute14
     ,p_attribute15                   	=>	     p_attribute15
     ,p_attribute16                  	=>	     p_attribute16
     ,p_attribute17                   	=>	     p_attribute17
     ,p_attribute18                   	=>	     p_attribute18
     ,p_attribute19                   	=>	     p_attribute19
     ,p_attribute20                  	=>	     p_attribute20
     ,p_attribute21                   	=>	     p_attribute21
     ,p_attribute22                   	=>	     p_attribute22
     ,p_attribute23                 	=>	     p_attribute23
     ,p_attribute24                  	=>	     p_attribute24
     ,p_attribute25                  	=>	     p_attribute25
     ,p_attribute26                  	=>	     p_attribute26
     ,p_attribute27                  	=>	     p_attribute27
     ,p_attribute28                  	=>	     p_attribute28
     ,p_attribute29                   	=>	     p_attribute29
     ,p_attribute30                   	=>	     p_attribute30
     ,p_per_information4		=>	     p_hukou_type
     ,p_per_information5		=>	     p_hukou_location
     ,p_per_information6		=>	     p_highest_education_level
     ,p_per_information7		=>	     p_number_of_children
     ,p_per_information8		=>	     p_expatriate_indicator
     ,p_per_information10		=>	     p_health_status
     ,p_per_information11		=>	     p_tax_exemption_indicator
     ,p_per_information12		=>	     p_percentage
     ,p_per_information14		=>	     p_family_han_yu_pin_yin_name
     ,p_per_information15		=>	     p_given_han_yu_pin_yin_name
     ,p_per_information16		=>	     p_previous_name
     ,p_per_information17		=>	     p_race_ethnic_orgin
     ,p_per_information18		=>	     p_social_security_ic_number
     ,p_date_of_death			=>	     p_date_of_death
     ,p_background_check_status		=>	     p_background_check_status
     ,p_background_date_check		=>	     p_background_date_check
     ,p_blood_type			=>	     p_blood_type
     ,p_correspondence_language		=>	     p_correspondence_language
     ,p_fast_path_employee		=>	     p_fast_path_employee
     ,p_fte_capacity			=>	     p_fte_capacity
     ,p_hold_applicant_date_until    	=>	     p_hold_applicant_date_until
     ,p_honors				=>	     p_honors
     ,p_internal_location		=>	     p_internal_location
     ,p_last_medical_test_by		=>	     p_last_medical_test_by
     ,p_last_medical_test_date		=>	     p_last_medical_test_date
     ,p_mailstop			=>	     p_mailstop
     ,p_office_number			=>	     p_office_number
     ,p_on_military_service		=>	     p_on_military_service
     ,p_pre_name_adjunct		=>	     p_pre_name_adjunct
     ,p_projected_start_date		=>	     p_projected_start_date
     ,p_rehire_authorizor		=>	     p_rehire_authorizor
     ,p_rehire_recommendation		=>	     p_rehire_recommendation
     ,p_resume_exists			=>	     p_resume_exists
     ,p_resume_last_updated		=>	     p_resume_last_updated
     ,p_second_passport_exists		=>	     p_second_passport_exists
     ,p_student_status			=>	     p_student_status
     ,p_work_schedule			=>	     p_work_schedule
     ,p_rehire_reason			=>	     p_rehire_reason
     ,p_suffix				=>	     p_suffix
     ,p_benefit_group_id		=>	     p_benefit_group_id
     ,p_receipt_of_death_cert_date   	=>	     p_receipt_of_death_cert_date
     ,p_coord_ben_med_pln_no		=>	     p_coord_ben_med_pln_no
     ,p_coord_ben_no_cvg_flag		=>	     p_coord_ben_no_cvg_flag
     ,p_coord_ben_med_ext_er		=>	     p_coord_ben_med_ext_er
     ,p_coord_ben_med_pl_name		=>	     p_coord_ben_med_pl_name
     ,p_coord_ben_med_insr_crr_name   	=>	     p_coord_ben_med_insr_crr_name
     ,p_coord_ben_med_insr_crr_ident  	=>	     p_coord_ben_med_insr_crr_ident
     ,p_coord_ben_med_cvg_strt_dt    	=>	     p_coord_ben_med_cvg_strt_dt
     ,p_coord_ben_med_cvg_end_dt      	=>	     p_coord_ben_med_cvg_end_dt
     ,p_uses_tobacco_flag		=>	     p_uses_tobacco_flag
     ,p_dpdnt_adoption_date		=>	     p_dpdnt_adoption_date
     ,p_dpdnt_vlntry_svce_flag 		=>	     p_dpdnt_vlntry_svce_flag
     ,p_original_date_of_hire		=>	     p_original_date_of_hire
     ,p_adjusted_svc_date		=>	     p_adjusted_svc_date
     ,p_town_of_birth			=>	     p_town_of_birth
     ,p_region_of_birth			=>	     p_region_of_birth
     ,p_country_of_birth		=>	     p_country_of_birth
     ,p_global_person_id		=>	     p_global_person_id
     ,p_party_id			=>	     p_party_id
     ,p_npw_number			=>	     p_npw_number
     ,p_effective_start_date		=>	     p_effective_start_date
     ,p_effective_end_date		=>	     p_effective_end_date
     ,p_full_name			=>	     p_full_name
     ,p_comment_id			=>	     p_comment_id
     ,p_name_combination_warning     	=>	     p_name_combination_warning
     ,p_assign_payroll_warning		=>	     p_assign_payroll_warning
     ,p_orig_hire_warning		=>	     p_orig_hire_warning    );

   --

    hr_cn_api.set_location(g_trace, 'Leaving:'|| l_proc, 30);
--
END update_cn_person;


END hr_cn_person_api;

/
