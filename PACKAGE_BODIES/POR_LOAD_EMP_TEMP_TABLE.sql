--------------------------------------------------------
--  DDL for Package Body POR_LOAD_EMP_TEMP_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_LOAD_EMP_TEMP_TABLE" as
/* $Header: PORLEMTB.pls 115.4 2001/06/28 18:57:03 pkm ship        $ */

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
        x_work_telephone IN VARCHAR2)
IS
BEGIN


        IF (get_employee_exists(x_employee_number)) THEN

        UPDATE POR_EMPLOYEE_LOADER_VALUES
        SET
        first_name =  x_first_name,
        last_name = x_last_name,
        sex = x_sex,
        start_date = x_effective_start_date,
        end_date = x_effective_end_date,
        business_group_name = x_business_group_name,
        location_code = x_location_name,
        set_of_books = x_set_of_books_name,
        default_expense_account = x_default_employee_account,
        job_name = x_job_name,
        supervisor_emp_num = x_supervisor_emp_number,
        user_name = x_user_name,
        password  = x_password,
        email_address = x_email_address,
        work_telephone = x_work_telephone,
        loader_status = 'unloaded',
        last_update_date = sysdate

        WHERE
          employee_number = x_employee_number;


        ELSE

         INSERT INTO POR_EMPLOYEE_LOADER_VALUES (
         employee_number,
         first_name,
         last_name,
         sex,
         start_date,
         end_date,
         business_group_name,
         location_code,
         set_of_books,
         default_expense_account,
         job_name,
         supervisor_emp_num,
         user_name,
         password,
         email_address,
         work_telephone,
         loader_status,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
         VALUES (
         x_employee_number,
         x_first_name,
         x_last_name,
         x_sex,
         x_effective_start_date,
         x_effective_end_date,
         x_business_group_name,
         x_location_name,
         x_set_of_books_name,
         x_default_employee_account,
         x_job_name,
         x_supervisor_emp_number,
         x_user_name,
         x_password,
         x_email_address,
         x_work_telephone,
         'unloaded',
         sysdate,
         0,
         sysdate,
         0
         );

       END IF;

       EXCEPTION
       WHEN OTHERS THEN
         RAISE;

       commit;

END insert_update_emp_temp_table;

FUNCTION get_employee_exists (p_employee_number IN VARCHAR2) RETURN BOOLEAN IS
  l_exists NUMBER;

BEGIN

  SELECT 1 INTO l_exists FROM por_employee_loader_values
  WHERE employee_number = p_employee_number;

  RETURN true;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN false;

END get_employee_exists;

END POR_LOAD_EMP_TEMP_TABLE;


/
