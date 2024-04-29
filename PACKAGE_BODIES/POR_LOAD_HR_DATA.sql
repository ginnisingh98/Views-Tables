--------------------------------------------------------
--  DDL for Package Body POR_LOAD_HR_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_LOAD_HR_DATA" as
/* $Header: PORLHRLB.pls 115.14 2004/02/05 23:20:36 skaushik ship $ */
validation_error EXCEPTION;
PROCEDURE insert_update_emp_data
IS

l_employee_number VARCHAR2(30);
l_first_name  VARCHAR2(30);
l_last_name VARCHAR2(40);
l_middle_name VARCHAR2(40); /* 2610687 Set the variable size as mentioned in Employee Loader Readme */
l_sex VARCHAR2(30);
l_start_date VARCHAR2(30);
l_end_date VARCHAR2(30);
l_business_group_name VARCHAR2(240);
l_location_code VARCHAR2(30);
l_set_of_books VARCHAR2(30);
l_default_expense_account VARCHAR2(50);	/*2610687*/
l_job_name VARCHAR2(30);
l_supervisor_emp_num VARCHAR2(30);
l_user_name VARCHAR2(30);
l_password VARCHAR2(30);
l_email_address VARCHAR2(30);
l_work_telephone VARCHAR2(30);
l_loader_status VARCHAR2(30);

CURSOR c_employees IS
   SELECT employee_number,first_name,last_name, sex, start_date, end_date,
   business_group_name, location_code,set_of_books,default_expense_account,
   job_name, supervisor_emp_num, user_name,password, email_address,
   work_telephone
   FROM por_employee_loader_values ORDER BY last_update_date ASC;

BEGIN

   OPEN c_employees;
   LOOP
   BEGIN
   FETCH c_employees INTO l_employee_number,l_first_name,l_last_name,
   l_sex,l_start_date,l_end_date,l_business_group_name,l_location_code,
   l_set_of_books,l_default_expense_account,l_job_name,l_supervisor_emp_num,
   l_user_name,l_password,l_email_address,l_work_telephone;

   EXIT WHEN c_employees%NOTFOUND;

   POR_LOAD_EMPLOYEE.insert_update_employee_info (
        x_employee_number => l_employee_number,
	x_first_name => l_first_name,
        x_last_name => l_last_name,
        x_sex => l_sex,
        x_effective_start_date => l_start_date,
        x_effective_end_date => l_end_date,
        x_business_group_name => l_business_group_name,
        x_location_name => l_location_code,
        x_default_employee_account => l_default_expense_account,
        x_set_of_books_name => l_set_of_books ,
	x_supervisor_emp_number => l_supervisor_emp_num,
        x_job_name => l_job_name,
        x_email_address => l_email_address,
        x_work_telephone => l_work_telephone);

   POR_LOAD_FND_USER.insert_update_user_info (
        x_employee_number => l_employee_number,
	x_user_name => l_user_name,
        x_password => l_password,
        x_email_address => l_email_address);


    UPDATE por_employee_loader_values
    SET loader_status = 'complete'
    WHERE employee_number =  l_employee_number;

   EXCEPTION
      WHEN OTHERS THEN
           ERROR_STACK.PUSHMESSAGE('*****************','ICX');
           ERROR_STACK.PUSHMESSAGE('The employee or assignment information for '||l_last_name||' '||l_first_name||' could not be loaded','ICX');

           IF (hr_utility.get_message() IS NULL OR
                    hr_utility.get_message() = '') THEN
             ERROR_STACK.PUSHMESSAGE(SQLCODE || ' ' ||SQLERRM,'ICX');
           ELSE
             ERROR_STACK.PUSHMESSAGE(hr_utility.get_message(),'ICX');
           END IF;

           UPDATE por_employee_loader_values
           SET loader_status = 'failure'
           WHERE employee_number =  l_employee_number;

   END;

  END LOOP;

  CLOSE c_employees;

  COMMIT;

  BEGIN
    IF (ERROR_STACK.GETMSGCOUNT > 0) THEN
       RAISE validation_error;
    END IF;
  END;

  EXCEPTION
     WHEN validation_error THEN
        RAISE;
     WHEN OTHERS THEN
         RAISE;

END insert_update_emp_data;


PROCEDURE insert_update_loc_data
IS

l_location_code VARCHAR2(30);
l_business_group VARCHAR2(240);
l_effective_date	DATE;
l_description VARCHAR2(240);
l_address_style VARCHAR2(30);
l_address_line_1 VARCHAR2(60);
l_address_line_2	VARCHAR2(60);
l_address_line_3	VARCHAR2(60);
l_city	VARCHAR2(30);
l_state VARCHAR2(30);
l_county VARCHAR2(30);
l_postal_code VARCHAR2(30);
l_country	 VARCHAR2(30);
l_telephone VARCHAR2(30);
l_fax VARCHAR2(30);
l_ship_to_location VARCHAR2(30);
l_ship_to_flag	VARCHAR2(30);
l_bill_to_flag	VARCHAR2(30);
l_receiving_to_flag VARCHAR2(30);
l_office_site VARCHAR2(30);
l_internal_site VARCHAR2(30);
l_inventory_Org VARCHAR2(30);
l_tax_name VARCHAR2(30);

CURSOR c_locations IS
   SELECT location_code,business_group, effective_date,description,
          address_style,address_line_1,	address_line_2,address_line_3,
          city,state,county,postal_code,country,telephone,fax,ship_to_location,
          ship_to_flag,bill_to_flag,receiving_to_flag,office_site,
	  internal_site,inventory_Org,tax_name
   FROM por_location_loader_values ORDER BY last_update_date ASC;

BEGIN

   OPEN c_locations;
   LOOP
   BEGIN
   FETCH c_locations INTO l_location_code,l_business_group,l_effective_date,
       l_description,l_address_style,l_address_line_1,l_address_line_2,
       l_address_line_3,l_city,l_state,l_county,l_postal_code,l_country,
       l_telephone,l_fax,l_ship_to_location,l_ship_to_flag,l_bill_to_flag,
       l_receiving_to_flag,l_office_site,l_internal_site,l_inventory_Org,
       l_tax_name;

   EXIT WHEN c_locations%NOTFOUND;


   POR_LOAD_LOCATION.insert_update_location_info (
        x_location_code => l_location_code,
	x_business_grp_name => l_business_group,
        x_effective_date => l_effective_date,
	x_description => l_description,
        x_address_style => l_address_style,
        x_address_line_1 => l_address_line_1,
        x_address_line_2 => l_address_line_2,
        x_address_line_3 => l_address_line_3,
        x_city => l_city,
        x_state => l_state,
        x_county => l_county,
        x_country => l_country,
        x_postal_code => l_postal_code,
        x_telephone_number_1 => l_telephone,
        x_telephone_number_2 => l_fax,
        x_shipToLocation => l_ship_to_location,
        x_ship_to_flag => l_ship_to_flag,
        x_bill_to_flag => l_bill_to_flag,
        x_receiving_site => l_receiving_to_flag,
        x_office_site_flag => l_office_site,
        x_inv_org => l_inventory_Org,
        x_tax_name => l_tax_name);


    UPDATE por_location_loader_values
    SET loader_status = 'complete'
    WHERE location_code =  l_location_code;


   EXCEPTION
      WHEN OTHERS THEN
           ERROR_STACK.PUSHMESSAGE('*****************','ICX');
           ERROR_STACK.PUSHMESSAGE('Location '||l_location_code || ' could not be loaded','ICX');

           IF (hr_utility.get_message() IS NULL OR
                    hr_utility.get_message() = '') THEN
             ERROR_STACK.PUSHMESSAGE(SQLCODE || ' ' ||SQLERRM,'ICX');
           ELSE
             ERROR_STACK.PUSHMESSAGE(hr_utility.get_message(),'ICX');
           END IF;

           UPDATE por_location_loader_values
           SET loader_status = 'failure'
           WHERE location_code =  l_location_code;

   END;

  END LOOP;
  CLOSE c_locations;

  COMMIT;

  BEGIN
    IF (ERROR_STACK.GETMSGCOUNT > 0) THEN
       RAISE validation_error;
    END IF;
  END;

  EXCEPTION
     WHEN OTHERS THEN
         RAISE;


END insert_update_loc_data;


END POR_LOAD_HR_DATA;



/
