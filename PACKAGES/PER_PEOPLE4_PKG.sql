--------------------------------------------------------
--  DDL for Package PER_PEOPLE4_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEOPLE4_PKG" AUTHID CURRENT_USER AS
/* $Header: peper04t.pkh 115.11 2002/12/09 11:00:31 pkakar ship $ */

--
procedure update_row(p_rowid VARCHAR2
	,p_person_id NUMBER
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
	,p_system_person_type VARCHAR2
	,p_s_system_person_type VARCHAR2
	,p_hire_date DATE
	,p_s_hire_date DATE
	,p_s_date_of_birth DATE
	,p_status in out nocopy VARCHAR2
	,p_new_primary_id in out nocopy NUMBER
	,p_update_primary in out nocopy VARCHAR2
	,p_legislation_code VARCHAR2
        ,p_vacancy_id IN OUT NOCOPY NUMBER
	,p_session_date date
	,p_end_of_time date);
--
procedure check_future_changes(p_person_id NUMBER
                              ,p_effective_start_date DATE);
--
procedure check_not_supervisor(p_person_id NUMBER
 			      ,p_new_hire_date DATE
			      ,p_old_hire_date DATE);
--
procedure check_rehire(p_person_id NUMBER
                      ,p_start_date DATE);
--
procedure check_birth_date(p_person_id NUMBER);
--
procedure original_date_of_hire (p_person_id             IN NUMBER
                                ,p_original_date_of_hire IN DATE
                                ,p_hire_date             IN DATE
                                ,p_business_group_id     IN NUMBER
                                ,p_person_type_id        IN NUMBER
                                ,p_period_of_service_id  IN NUMBER
                                ,p_system_person_type    IN VARCHAR2
                                ,p_orig_hire_warning     IN OUT NOCOPY BOOLEAN
);
--
END PER_PEOPLE4_PKG;

 

/
