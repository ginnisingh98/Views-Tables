--------------------------------------------------------
--  DDL for Package PER_PEOPLE11_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEOPLE11_PKG" AUTHID CURRENT_USER AS
/* $Header: peper11t.pkh 120.0 2005/05/31 13:38:22 appldev noship $ */

--
--
procedure insert_row1(p_rowid in out nocopy VARCHAR2
	,p_person_id in out nocopy NUMBER
	,p_effective_start_date DATE
	,p_effective_end_date DATE
	,p_business_group_id NUMBER
	,p_person_type_id NUMBER
	,p_last_name VARCHAR2
	,p_start_date DATE
	,p_applicant_number IN OUT NOCOPY VARCHAR2
	,p_comment_id NUMBER
	,p_current_applicant_flag VARCHAR2
	,p_current_emp_or_apl_flag VARCHAR2
	,p_current_employee_flag VARCHAR2
	,p_date_employee_data_verified DATE
	,p_date_of_birth DATE
	,p_email_address VARCHAR2
	,p_employee_number IN OUT NOCOPY VARCHAR2
	,p_expense_check_send_to_addr VARCHAR2
	,p_first_name VARCHAR2
	,p_full_name VARCHAR2
	,p_known_as  VARCHAR2
	,p_marital_status VARCHAR2
	,p_middle_names  VARCHAR2
	,p_nationality VARCHAR2
	,p_national_identifier VARCHAR2
	,p_previous_last_name VARCHAR2
	,p_registered_disabled_flag VARCHAR2
	,p_sex VARCHAR2
	,p_title VARCHAR2
	,p_suffix VARCHAR2
	,p_vendor_id NUMBER
	,p_work_telephone VARCHAR2
	,p_request_id NUMBER
	,p_program_application_id NUMBER
	,p_program_id NUMBER
	,p_program_update_date DATE
	,p_a_cat VARCHAR2
	,p_a1 VARCHAR2
	,p_a2 VARCHAR2
	,p_a3 VARCHAR2
	,p_a4 VARCHAR2
	,p_a5 VARCHAR2
	,p_a6 VARCHAR2
	,p_a7 VARCHAR2
	,p_a8 VARCHAR2
	,p_a9 VARCHAR2
	,p_a10 VARCHAR2
	,p_a11 VARCHAR2
	,p_a12 VARCHAR2
	,p_a13 VARCHAR2
	,p_a14 VARCHAR2
	,p_a15 VARCHAR2
	,p_a16 VARCHAR2
	,p_a17 VARCHAR2
	,p_a18 VARCHAR2
	,p_a19 VARCHAR2
	,p_a20 VARCHAR2
	,p_a21 VARCHAR2
	,p_a22 VARCHAR2
	,p_a23 VARCHAR2
	,p_a24 VARCHAR2
	,p_a25 VARCHAR2
	,p_a26 VARCHAR2
	,p_a27 VARCHAR2
	,p_a28 VARCHAR2
	,p_a29 VARCHAR2
	,p_a30 VARCHAR2
	,p_last_update_date DATE
	,p_last_updated_by NUMBER
	,p_last_update_login NUMBER
	,p_created_by NUMBER
	,p_creation_date DATE
	,p_i_cat VARCHAR2
	,p_i1 VARCHAR2
	,p_i2 VARCHAR2
	,p_i3 VARCHAR2
	,p_i4 VARCHAR2
	,p_i5 VARCHAR2
	,p_i6 VARCHAR2
	,p_i7 VARCHAR2
	,p_i8 VARCHAR2
	,p_i9 VARCHAR2
	,p_i10 VARCHAR2
	,p_i11 VARCHAR2
	,p_i12 VARCHAR2
	,p_i13 VARCHAR2
	,p_i14 VARCHAR2
	,p_i15 VARCHAR2
	,p_i16 VARCHAR2
	,p_i17 VARCHAR2
	,p_i18 VARCHAR2
	,p_i19 VARCHAR2
	,p_i20 VARCHAR2
	,p_i21 VARCHAR2
	,p_i22 VARCHAR2
	,p_i23 VARCHAR2
	,p_i24 VARCHAR2
	,p_i25 VARCHAR2
	,p_i26 VARCHAR2
	,p_i27 VARCHAR2
	,p_i28 VARCHAR2
	,p_i29 VARCHAR2
	,p_i30 VARCHAR2
	,p_app_ass_status_type_id NUMBER
	,p_emp_ass_status_type_id NUMBER
	,p_create_defaults_for VARCHAR2
   ,p_work_schedule VARCHAR2
   ,p_correspondence_language VARCHAR2
   ,p_student_status VARCHAR2
   ,p_fte_capacity NUMBER
   ,p_on_military_service VARCHAR2
   ,p_second_passport_exists VARCHAR2
   ,p_background_check_status VARCHAR2
   ,p_background_date_check DATE
   ,p_blood_type VARCHAR2
   ,p_last_medical_test_date DATE
   ,p_last_medical_test_by VARCHAR2
   ,p_rehire_recommendation VARCHAR2
   ,p_rehire_reason VARCHAR2
   ,p_resume_exists VARCHAR2
   ,p_resume_last_updated DATE
   ,p_office_number VARCHAR2
   ,p_internal_location VARCHAR2
   ,p_mailstop VARCHAR2
   ,p_honors VARCHAR2
   ,p_pre_name_adjunct VARCHAR2
   ,p_hold_applicant_date_until DATE
   ,p_benefit_group_id NUMBER
   ,p_receipt_of_death_cert_date DATE
   ,p_coord_ben_med_pln_no VARCHAR2
   ,p_coord_ben_no_cvg_flag VARCHAR2
   ,p_uses_tobacco_flag VARCHAR2
   ,p_dpdnt_adoption_date DATE
   ,p_dpdnt_vlntry_svce_flag VARCHAR2
   ,p_date_of_death DATE
   ,p_original_date_of_hire DATE
   ,p_adjusted_svc_date DATE
   ,p_town_of_birth VARCHAR2
   ,p_region_of_birth VARCHAR2
   ,p_country_of_birth VARCHAR2
   ,p_global_person_id VARCHAR2
   ,p_fast_path_employee VARCHAR2 default null
   ,p_rehire_authorizor VARCHAR2 default null
   ,p_party_id         number default null
   ,p_npw_number   IN OUT NOCOPY VARCHAR2
   ,p_current_npw_flag VARCHAR2 default null
   ,p_order_name       IN VARCHAR2
   ,p_global_name      IN VARCHAR2
   ,p_local_name       IN VARCHAR2
    );
--
procedure delete_row1(p_rowid VARCHAR2);
--
END PER_PEOPLE11_PKG;

 

/
