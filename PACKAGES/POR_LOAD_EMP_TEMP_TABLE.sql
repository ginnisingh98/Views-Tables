--------------------------------------------------------
--  DDL for Package POR_LOAD_EMP_TEMP_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_LOAD_EMP_TEMP_TABLE" AUTHID CURRENT_USER as
/* $Header: PORLEMTS.pls 115.1 2001/06/28 18:57:04 pkm ship        $ */

PROCEDURE insert_update_emp_temp_table (
        x_employee_number IN VARCHAR2,
	x_first_name  IN VARCHAR2,
        x_last_name IN VARCHAR2,
        x_sex IN VARCHAR2,
        x_effective_start_date IN DATE,
        x_effective_end_date IN DATE,
        x_business_group_name IN VARCHAR2,
        x_location_name IN VARCHAR2,
        x_default_employee_account IN VARCHAR2,
        x_set_of_books_name IN VARCHAR2,
	x_supervisor_emp_number IN VARCHAR2,
        x_job_name IN VARCHAR2,
        x_user_name IN VARCHAR2,
        x_password IN VARCHAR2,
        x_email_address IN VARCHAR2,
        x_work_telephone IN VARCHAR2);

FUNCTION get_employee_exists (p_employee_number IN VARCHAR2) RETURN BOOLEAN;

END POR_LOAD_EMP_TEMP_TABLE;


 

/
