--------------------------------------------------------
--  DDL for Package PER_PEOPLE9_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEOPLE9_PKG" AUTHID CURRENT_USER AS
/* $Header: peper09t.pkh 115.2 2003/01/31 11:45:25 pkakar ship $ */
--
procedure insert_applicant_rows(p_person_id NUMBER
	,p_effective_start_date DATE
	,p_effective_end_date DATE
	,p_business_group_id NUMBER
	,p_app_ass_status_type_id NUMBER
	,p_request_id NUMBER
	,p_program_application_id NUMBER
	,p_program_id NUMBER
	,p_program_update_date DATE
	,p_last_update_date DATE
	,p_last_updated_by NUMBER
	,p_last_update_login NUMBER
	,p_created_by NUMBER
	,p_creation_date DATE);
--
procedure insert_employee_rows(p_person_id NUMBER
	,p_effective_start_date DATE
	,p_effective_end_date DATE
	,p_business_group_id NUMBER
	,p_emp_ass_status_type_id NUMBER
	,p_employee_number VARCHAR2
	,p_request_id NUMBER
	,p_program_application_id NUMBER
	,p_program_id NUMBER
	,p_program_update_date DATE
	,p_last_update_date DATE
	,p_last_updated_by NUMBER
	,p_last_update_login NUMBER
	,p_created_by NUMBER
	,p_creation_date DATE
        ,p_adjusted_svc_date DATE);
--
procedure update_old_person_row(p_person_id NUMBER
                               ,p_session_date DATE
                               ,p_effective_start_date DATE);
--
END PER_PEOPLE9_PKG;

 

/
