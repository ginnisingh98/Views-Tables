--------------------------------------------------------
--  DDL for Package Body POR_LOAD_EMPLOYEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_LOAD_EMPLOYEE" as
/* $Header: PORLEMPB.pls 115.9 2004/02/05 22:40:57 skaushik ship $ */

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
        x_work_telephone IN VARCHAR2)
IS

 l_person_id NUMBER;
 l_assignment_id NUMBER;
 l_per_object_version_number NUMBER;
 l_asg_object_version_number NUMBER;
 l_full_name   VARCHAR2(30);
 l_per_comment_id    NUMBER;
 l_assignment_sequence  NUMBER;
 l_effective_start_date DATE;
 effective_end_date DATE;
 l_effective_end_date DATE;
 l_per_effective_end_date DATE;
 l_assignment_number   VARCHAR2(30);
 l_name_combination_warning BOOLEAN;
 l_assign_payroll_warning  BOOLEAN;
 l_business_group_id NUMBER;
 l_employee_number VARCHAR2(30);
 l_set_of_books_id NUMBER;
 l_group_name VARCHAR2(20);
 l_concatenated_segments VARCHAR2(20);
 l_cagr_grade_def_id NUMBER;
 l_cagr_concatenated_segments VARCHAR2(20);
 l_soft_coding_keyflex_id NUMBER;
 l_people_group_id NUMBER;
 l_other_manager_warning BOOLEAN;
 l_chart_of_accounts_id NUMBER;
 l_ccid NUMBER;
 l_row_id VARCHAR2(30);
 p_Effective_Start_Date DATE;
 p_Effective_End_Date DATE;
 p_Business_Group_Id NUMBER;
 p_Person_Type_Id NUMBER;
 p_Last_Name PER_ALL_PEOPLE_F.LAST_NAME%TYPE;
 p_Start_Date DATE;
 p_Hire_date DATE;
 p_S_Hire_Date DATE;
 p_Period_of_service_id NUMBER;
 p_Termination_Date DATE;
 p_S_Termination_Date DATE;
 p_Applicant_Number VARCHAR2(30);
 p_Comment_Id NUMBER;
 p_Current_Applicant_Flag VARCHAR2(30);
 p_Current_Emp_Or_Apl_Flag VARCHAR2(30);
 p_Current_Employee_Flag VARCHAR2(30);
 p_Date_Employee_Data_Verified DATE;
 p_Date_Of_Birth DATE;
 p_Email_Address VARCHAR2(240);
 p_Expense_Check_To_Address VARCHAR2(30);
 p_First_Name PER_ALL_PEOPLE_F.FIRST_NAME%TYPE;
 p_Full_Name VARCHAR2(240);
 p_Known_As VARCHAR2(30);
 p_Marital_Status VARCHAR2(30);
 p_Middle_Names VARCHAR2(30);
 p_Nationality VARCHAR2(30);
 p_National_Identifier VARCHAR2(30);
 p_Previous_Last_Name PER_ALL_PEOPLE_F.PREVIOUS_LAST_NAME%TYPE;
 p_Registered_Disabled_Flag VARCHAR2(30);
 p_Sex VARCHAR2(30);
 p_Title VARCHAR2(30);
 p_Vendor_Id NUMBER(30);
 p_Work_Telephone VARCHAR2(60);
 p_Attribute_Category VARCHAR2(30);
 p_Attribute1 VARCHAR2(150);
 p_Attribute2 VARCHAR2(150);
 p_Attribute3 VARCHAR2(150);
 p_Attribute4 VARCHAR2(150);
 p_Attribute5 VARCHAR2(150);
 p_Attribute6 VARCHAR2(150);
 p_Attribute7 VARCHAR2(150);
 p_Attribute8 VARCHAR2(150);
 p_Attribute9 VARCHAR2(150);
 p_Attribute10 VARCHAR2(150);
 p_Attribute11 VARCHAR2(150);
 p_Attribute12 VARCHAR2(150);
 p_Attribute13 VARCHAR2(150);
 p_Attribute14 VARCHAR2(150);
 p_Attribute15 VARCHAR2(150);
 p_Attribute16 VARCHAR2(150);
 p_Attribute17 VARCHAR2(150);
 p_Attribute18 VARCHAR2(150);
 p_Attribute19 VARCHAR2(150);
 p_Attribute20 VARCHAR2(150);
 p_Attribute21 VARCHAR2(150);
 p_Attribute22 VARCHAR2(150);
 p_Attribute23 VARCHAR2(150);
 p_Attribute24 VARCHAR2(150);
 p_Attribute25 VARCHAR2(150);
 p_Attribute26 VARCHAR2(150);
 p_Attribute27 VARCHAR2(150);
 p_Attribute28 VARCHAR2(150);
 p_Attribute29 VARCHAR2(150);
 p_Attribute30 VARCHAR2(150);
 p_Last_Update_Date DATE;
 p_Last_Updated_By NUMBER;
 p_Last_Update_Login NUMBER;

 BEGIN


  l_business_group_id := get_business_group_id(x_business_group_name);

  l_employee_number := x_employee_number;
  l_effective_start_date := x_effective_start_date;

  l_effective_end_date := x_effective_end_date;

  l_person_id := get_employee_exists (x_employee_number);


  IF (l_person_id IS NULL) THEN

	  hr_employee_api.create_us_employee(
	   p_validate => FALSE
	  ,p_hire_date => x_effective_start_date
	  ,p_business_group_id => l_business_group_id
	  ,p_last_name =>  x_last_name
	  ,p_first_name => x_first_name
          ,p_email_address => x_email_address
	  ,p_middle_names => NULL
	  ,p_sex => x_sex
          ,p_work_telephone => x_work_telephone
	  ,p_employee_number => l_employee_number
	  ,p_person_id     => l_person_id
	  ,p_assignment_id  => l_assignment_id
	  ,p_per_object_version_number => l_per_object_version_number
	  ,p_asg_object_version_number => l_asg_object_version_number
	  ,p_per_effective_start_date  => l_effective_start_date
	  ,p_per_effective_end_date   => l_per_effective_end_date
	  ,p_full_name                => l_full_name
	  ,p_per_comment_id           => l_per_comment_id
	  ,p_assignment_sequence      => l_assignment_sequence
	  ,p_assignment_number        => l_assignment_number
	  ,p_name_combination_warning => l_name_combination_warning
	  ,p_assign_payroll_warning   => l_assign_payroll_warning
	);


   ELSE

         l_row_id := get_row_id(x_employee_number);

         get_employee_details(x_employee_number,
                     p_Effective_Start_Date,
                     p_Effective_End_Date,
                     p_Business_Group_Id,
                     p_Person_Type_Id,
                     p_Last_Name,
                     p_Start_Date,
                     p_Hire_date,
                     p_Applicant_Number,
                     p_Comment_Id,
                     p_Current_Applicant_Flag,
                     p_Current_Emp_Or_Apl_Flag,
                     p_Current_Employee_Flag,
                     p_Date_Employee_Data_Verified,
                     p_Date_Of_Birth,
                     p_Email_Address,
                     p_Expense_Check_To_Address,
                     p_First_Name,
                     p_Full_Name,
                     p_Known_As,
                     p_Marital_Status,
                     p_Middle_Names,
                     p_Nationality,
                     p_National_Identifier,
                     p_Previous_Last_Name,
                     p_Registered_Disabled_Flag,
                     p_Sex,
                     p_Title,
                     p_Vendor_Id,
                     p_Work_Telephone,
                     p_Attribute_Category,
                     p_Attribute1,
                     p_Attribute2,
                     p_Attribute3,
                     p_Attribute4,
                     p_Attribute5,
                     p_Attribute6,
                     p_Attribute7,
                     p_Attribute8,
                     p_Attribute9,
                     p_Attribute10,
                     p_Attribute11,
                     p_Attribute12,
                     p_Attribute13,
                     p_Attribute14,
                     p_Attribute15,
                     p_Attribute16,
                     p_Attribute17,
                     p_Attribute18,
                     p_Attribute19,
                     p_Attribute20,
                     p_Attribute21,
                     p_Attribute22,
                     p_Attribute23,
                     p_Attribute24,
                     p_Attribute25,
                     p_Attribute26,
                     p_Attribute27,
                     p_Attribute28,
                     p_Attribute29,
                     p_Attribute30,
                     p_Last_Update_Date,
                     p_Last_Updated_By,
                     p_Last_Update_Login);


         IF (l_effective_end_date IS NULL) THEN
               effective_end_date := p_Effective_End_Date;
         ELSE
               effective_end_date := l_effective_end_date;
         END IF;

         PER_PEOPLE_V15_PKG.Update_Row(
                     X_Rowid   => l_row_id,
                     X_Person_Id => l_person_id,
                     X_Effective_Start_Date => l_effective_start_date,
                     X_Effective_End_Date  => effective_end_date,
                     X_Business_Group_Id => l_business_group_id,
                     X_Person_Type_Id => p_Person_Type_Id,
                     X_Last_Name => x_last_name,
                     X_Email_Address => x_email_address,
                     X_Start_Date  => p_Start_Date,
                     X_Hire_date  => p_Hire_date,
                     X_S_Hire_Date => NULL,
                     X_Period_of_service_id => NULL,
                     X_Termination_Date => NULL,
                     X_S_Termination_Date => NULL,
                     X_Applicant_Number => p_Applicant_Number,
                     X_Comment_Id => p_Comment_Id,
                     X_Current_Applicant_Flag => p_Current_Applicant_Flag,
                     X_Current_Emp_Or_Apl_Flag => p_Current_Emp_Or_Apl_Flag,
                     X_Current_Employee_Flag  => p_Current_Employee_Flag,
                     X_Date_Employee_Data_Verified => p_Date_Employee_Data_Verified,
                     X_Date_Of_Birth => p_Date_Of_Birth,
                     X_Employee_Number  => x_employee_number,
                     X_Expense_Check_To_Address => p_Expense_Check_To_Address,
                     X_First_Name => x_first_name,
                     X_Full_Name => p_Full_Name,
                     X_Known_As => p_Known_As,
                     X_Marital_Status =>p_Marital_Status ,
                     X_Middle_Names => p_Middle_Names,
                     X_Nationality => p_Nationality,
                     X_National_Identifier => p_National_Identifier,
                     X_Previous_Last_Name  => p_Previous_Last_Name,
                     X_Registered_Disabled_Flag  => p_Registered_Disabled_Flag,
                     X_Sex  => x_sex,
                     X_Title => p_Title,
                     X_Vendor_Id  => p_Vendor_Id,
                     X_Work_Telephone => x_work_telephone,
                     X_Attribute_Category => p_Attribute_Category,
                     X_Attribute1 => p_Attribute1,
                     X_Attribute2 => p_Attribute2,
                     X_Attribute3 => p_Attribute3,
                     X_Attribute4 => p_Attribute4,
                     X_Attribute5 => p_Attribute5,
                     X_Attribute6 => p_Attribute6,
                     X_Attribute7 => p_Attribute7,
                     X_Attribute8 => p_Attribute8,
                     X_Attribute9 => p_Attribute9,
                     X_Attribute10 => p_Attribute10,
                     X_Attribute11 => p_Attribute11,
                     X_Attribute12 => p_Attribute12,
                     X_Attribute13 => p_Attribute13,
                     X_Attribute14 => p_Attribute14,
                     X_Attribute15 => p_Attribute15,
                     X_Attribute16 => p_Attribute16,
                     X_Attribute17 => p_Attribute17,
                     X_Attribute18 => p_Attribute18,
                     X_Attribute19 => p_Attribute19,
                     X_Attribute20 => p_Attribute20,
                     X_Attribute21 => p_Attribute21,
                     X_Attribute22 => p_Attribute22,
                     X_Attribute23 => p_Attribute23,
                     X_Attribute24 => p_Attribute24,
                     X_Attribute25 => p_Attribute25,
                     X_Attribute26 => p_Attribute26,
                     X_Attribute27 => p_Attribute27,
                     X_Attribute28 => p_Attribute28,
                     X_Attribute29 => p_Attribute29,
                     X_Attribute30 => p_Attribute30,
                     X_Last_Update_Date => sysdate,
                     X_Last_Updated_By => p_Last_Updated_By,
                     X_Last_Update_Login => p_Last_Update_Login);

   END IF;

   POR_LOAD_EMPLOYEE_ASSIGNMENT.insert_update_employee_asg(
        l_person_id,
        l_business_group_id,
        x_location_name,
        l_assignment_number,
        x_default_employee_account,
        x_set_of_books_name,
        x_job_name,
        x_supervisor_emp_number,
        x_effective_start_date,
        x_effective_end_date);

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
       RETURN;

   WHEN OTHERS THEN

       RAISE;

END insert_update_employee_info;


FUNCTION get_business_group_id (p_business_group_name IN VARCHAR2) RETURN NUMBER IS
  l_business_group_id NUMBER;
BEGIN

  SELECT business_group_id INTO l_business_group_id
  FROM per_business_groups
  WHERE name = p_business_group_name;

  RETURN l_business_group_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_business_group_id;


FUNCTION get_employee_exists (p_employee_number IN VARCHAR2) RETURN NUMBER IS
  l_person_id NUMBER;

BEGIN

  SELECT person_id INTO l_person_id
  FROM per_all_people_f
  WHERE employee_number = p_employee_number;

  RETURN l_person_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_employee_exists;

FUNCTION get_row_id (p_employee_number IN VARCHAR2) RETURN VARCHAR2 IS
  l_row_id VARCHAR2(30);

BEGIN

  SELECT rowid INTO l_row_id
  FROM per_all_people_f
  WHERE employee_number = p_employee_number;

  RETURN l_row_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_row_id;

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
                     p_Last_Update_Login OUT NOCOPY NUMBER)

IS
BEGIN

     SELECT  EFFECTIVE_START_DATE,
             EFFECTIVE_END_DATE,
             BUSINESS_GROUP_ID,
             PERSON_TYPE_ID,
             LAST_NAME,
             START_DATE,
             ORIGINAL_DATE_OF_HIRE,
             APPLICANT_NUMBER,
             COMMENT_ID,
             CURRENT_APPLICANT_FLAG,
             CURRENT_EMP_OR_APL_FLAG,
             CURRENT_EMPLOYEE_FLAG,
             DATE_EMPLOYEE_DATA_VERIFIED,
             DATE_OF_BIRTH,
             EMAIL_ADDRESS,
             EXPENSE_CHECK_SEND_TO_ADDRESS,
             FIRST_NAME,
             FULL_NAME,
             KNOWN_AS,
             MARITAL_STATUS,
             MIDDLE_NAMES,
             NATIONALITY,
             NATIONAL_IDENTIFIER,
             PREVIOUS_LAST_NAME,
 	     REGISTERED_DISABLED_FLAG,
             SEX,
             TITLE,
             VENDOR_ID,
             WORK_TELEPHONE,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
	     ATTRIBUTE5,
	     ATTRIBUTE6,
	     ATTRIBUTE7,
	     ATTRIBUTE8,
	     ATTRIBUTE9,
	     ATTRIBUTE10,
	     ATTRIBUTE11,
	     ATTRIBUTE12,
   	     ATTRIBUTE13,
	     ATTRIBUTE14,
	     ATTRIBUTE15,
	     ATTRIBUTE16,
	     ATTRIBUTE17,
	     ATTRIBUTE18,
	     ATTRIBUTE19,
	     ATTRIBUTE20,
	     ATTRIBUTE21,
	     ATTRIBUTE22,
	     ATTRIBUTE23,
	     ATTRIBUTE24,
	     ATTRIBUTE25,
             ATTRIBUTE26,
             ATTRIBUTE27,
             ATTRIBUTE28,
	     ATTRIBUTE29,
             ATTRIBUTE30,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN

     INTO    p_Effective_Start_Date,
                     p_Effective_End_Date,
                     p_Business_Group_Id,
                     p_Person_Type_Id,
                     p_Last_Name,
                     p_Start_Date,
                     p_Hire_date,
                     p_Applicant_Number,
                     p_Comment_Id,
                     p_Current_Applicant_Flag,
                     p_Current_Emp_Or_Apl_Flag,
                     p_Current_Employee_Flag,
                     p_Date_Employee_Data_Verified,
                     p_Date_Of_Birth,
                     p_Email_Address,
                     p_Expense_Check_To_Address,
                     p_First_Name,
                     p_Full_Name,
                     p_Known_As,
                     p_Marital_Status,
                     p_Middle_Names,
                     p_Nationality,
                     p_National_Identifier,
                     p_Previous_Last_Name,
                     p_Registered_Disabled_Flag,
                     p_Sex,
                     p_Title,
                     p_Vendor_Id,
                     p_Work_Telephone,
                     p_Attribute_Category,
                     p_Attribute1,
                     p_Attribute2,
                     p_Attribute3,
                     p_Attribute4,
                     p_Attribute5,
                     p_Attribute6,
                     p_Attribute7,
                     p_Attribute8,
                     p_Attribute9,
                     p_Attribute10,
                     p_Attribute11,
                     p_Attribute12,
                     p_Attribute13,
                     p_Attribute14,
                     p_Attribute15,
                     p_Attribute16,
                     p_Attribute17,
                     p_Attribute18,
                     p_Attribute19,
                     p_Attribute20,
                     p_Attribute21,
                     p_Attribute22,
                     p_Attribute23,
                     p_Attribute24,
                     p_Attribute25,
                     p_Attribute26,
                     p_Attribute27,
                     p_Attribute28,
                     p_Attribute29,
                     p_Attribute30,
                     p_Last_Update_Date,
                     p_Last_Updated_By,
                     p_Last_Update_Login
     FROM    per_all_people_f
     WHERE   EMPLOYEE_NUMBER = x_employee_number;

END get_employee_details;

END POR_LOAD_EMPLOYEE;

/
