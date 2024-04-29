--------------------------------------------------------
--  DDL for Package POR_LOAD_EMPLOYEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_LOAD_EMPLOYEE" AUTHID CURRENT_USER as
/* $Header: PORLEMPS.pls 115.3 2002/11/19 00:34:10 jjessup ship $ */

PROCEDURE insert_update_employee_info (
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
        x_email_address IN VARCHAR2,
        x_work_telephone IN VARCHAR2);

FUNCTION get_business_group_id (p_business_group_name IN VARCHAR2) RETURN NUMBER;

FUNCTION get_employee_exists (p_employee_number IN VARCHAR2) RETURN NUMBER;

FUNCTION get_row_id (p_employee_number IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE get_employee_details(x_employee_number IN VARCHAR2,
                     p_Effective_Start_Date OUT NOCOPY DATE,
                     p_Effective_End_Date OUT NOCOPY DATE,
                     p_Business_Group_Id OUT NOCOPY NUMBER,
                     p_Person_Type_Id OUT NOCOPY NUMBER,
                     p_Last_Name OUT NOCOPY VARCHAR2,
                     p_Start_Date OUT NOCOPY DATE,
                     p_Hire_date OUT NOCOPY DATE,
                     p_Applicant_Number OUT NOCOPY VARCHAR2,
                     p_Comment_Id OUT NOCOPY NUMBER,
                     p_Current_Applicant_Flag OUT NOCOPY VARCHAR2,
                     p_Current_Emp_Or_Apl_Flag OUT NOCOPY VARCHAR2,
                     p_Current_Employee_Flag OUT NOCOPY VARCHAR2,
                     p_Date_Employee_Data_Verified OUT NOCOPY DATE,
                     p_Date_Of_Birth OUT NOCOPY DATE,
                     p_Email_Address OUT NOCOPY VARCHAR2,
                     p_Expense_Check_To_Address OUT NOCOPY VARCHAR2,
                     p_First_Name OUT NOCOPY VARCHAR2,
                     p_Full_Name OUT NOCOPY VARCHAR2,
                     p_Known_As OUT NOCOPY VARCHAR2,
                     p_Marital_Status OUT NOCOPY VARCHAR2,
                     p_Middle_Names OUT NOCOPY VARCHAR2,
                     p_Nationality OUT NOCOPY VARCHAR2,
                     p_National_Identifier OUT NOCOPY VARCHAR2,
                     p_Previous_Last_Name OUT NOCOPY VARCHAR2,
                     p_Registered_Disabled_Flag OUT NOCOPY VARCHAR2,
                     p_Sex  OUT NOCOPY VARCHAR2,
                     p_Title OUT NOCOPY VARCHAR2,
                     p_Vendor_Id OUT NOCOPY NUMBER,
                     p_Work_Telephone OUT NOCOPY VARCHAR2,
                     p_Attribute_Category OUT NOCOPY VARCHAR2,
                     p_Attribute1 OUT NOCOPY VARCHAR2,
                     p_Attribute2 OUT NOCOPY VARCHAR2,
                     p_Attribute3 OUT NOCOPY VARCHAR2,
                     p_Attribute4 OUT NOCOPY VARCHAR2,
                     p_Attribute5 OUT NOCOPY VARCHAR2,
                     p_Attribute6 OUT NOCOPY VARCHAR2,
                     p_Attribute7 OUT NOCOPY VARCHAR2,
                     p_Attribute8 OUT NOCOPY VARCHAR2,
                     p_Attribute9 OUT NOCOPY VARCHAR2,
                     p_Attribute10 OUT NOCOPY VARCHAR2,
                     p_Attribute11 OUT NOCOPY VARCHAR2,
                     p_Attribute12 OUT NOCOPY VARCHAR2,
                     p_Attribute13 OUT NOCOPY VARCHAR2,
                     p_Attribute14 OUT NOCOPY VARCHAR2,
                     p_Attribute15 OUT NOCOPY VARCHAR2,
                     p_Attribute16 OUT NOCOPY VARCHAR2,
                     p_Attribute17 OUT NOCOPY VARCHAR2,
                     p_Attribute18 OUT NOCOPY VARCHAR2,
                     p_Attribute19 OUT NOCOPY VARCHAR2,
                     p_Attribute20 OUT NOCOPY VARCHAR2,
                     p_Attribute21 OUT NOCOPY VARCHAR2,
                     p_Attribute22 OUT NOCOPY VARCHAR2,
                     p_Attribute23 OUT NOCOPY VARCHAR2,
                     p_Attribute24 OUT NOCOPY VARCHAR2,
                     p_Attribute25 OUT NOCOPY VARCHAR2,
                     p_Attribute26 OUT NOCOPY VARCHAR2,
                     p_Attribute27 OUT NOCOPY VARCHAR2,
                     p_Attribute28 OUT NOCOPY VARCHAR2,
                     p_Attribute29 OUT NOCOPY VARCHAR2,
                     p_Attribute30 OUT NOCOPY VARCHAR2,
                     p_Last_Update_Date OUT NOCOPY DATE,
                     p_Last_Updated_By OUT NOCOPY NUMBER,
                     p_Last_Update_Login OUT NOCOPY NUMBER);

END POR_LOAD_EMPLOYEE;

 

/
