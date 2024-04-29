--------------------------------------------------------
--  DDL for Package PER_PEOPLE_V15_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEOPLE_V15_PKG" AUTHID CURRENT_USER as
/* $Header: peper15t.pkh 115.2 2003/02/11 09:59:36 eumenyio ship $ */
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Person_Id                           NUMBER,
                     X_Effective_Start_Date         IN OUT NOCOPY DATE,
                     X_Effective_End_Date           IN OUT NOCOPY DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Type_Id                      NUMBER,
                     X_Last_Name                           VARCHAR2,
                     X_Start_Date                          DATE,
                     X_Hire_date                           DATE,
                     X_S_Hire_date                         DATE,
                     X_period_of_service_id                NUMBER,
                     X_Termination_Date                    DATE,
                     X_S_Termination_Date                  DATE,
                     X_Applicant_Number                    VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Current_Applicant_Flag              VARCHAR2,
                     X_Current_Emp_Or_Apl_Flag             VARCHAR2,
                     X_Current_Employee_Flag               VARCHAR2,
                     X_Date_Employee_Data_Verified         DATE,
                     X_Date_Of_Birth                       DATE,
                     X_Email_Address                       VARCHAR2,
                     X_Employee_Number                     VARCHAR2,
                     X_Expense_Check_To_Address       VARCHAR2,
                     X_First_Name                          VARCHAR2,
                     X_Full_Name                           VARCHAR2,
                     X_Known_As                            VARCHAR2,
                     X_Marital_Status                      VARCHAR2,
                     X_Middle_Names                        VARCHAR2,
                     X_Nationality                         VARCHAR2,
                     X_National_Identifier                 VARCHAR2,
                     X_Previous_Last_Name                  VARCHAR2,
                     X_Registered_Disabled_Flag            VARCHAR2,
                     X_Sex                                 VARCHAR2,
                     X_Title                               VARCHAR2,
                     X_Vendor_Id                           NUMBER,
                     X_Work_Telephone                      VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_Attribute21                         VARCHAR2,
                     X_Attribute22                         VARCHAR2,
                     X_Attribute23                         VARCHAR2,
                     X_Attribute24                         VARCHAR2,
                     X_Attribute25                         VARCHAR2,
                     X_Attribute26                         VARCHAR2,
                     X_Attribute27                         VARCHAR2,
                     X_Attribute28                         VARCHAR2,
                     X_Attribute29                         VARCHAR2,
                     X_Attribute30                         VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
							X_Current_Application_Id              NUMBER DEFAULT NULL
                     );
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
procedure terminate_employment(X_period_of_service_id NUMBER
                        ,X_person_id NUMBER
                        ,X_Rowid VARCHAR2
                        ,X_Business_group_id NUMBER
                        ,X_termination_Date DATE);
--
procedure update_employee_rows(X_period_of_service_id NUMBER
                        ,X_person_id NUMBER
                        ,X_hire_date DATE
                        ,X_s_hire_date DATE);
--
procedure cancel_termination(X_period_of_service_id NUMBER
                            ,X_Person_id NUMBER
                            ,X_termination_date DATE
                            ,X_s_termination_date DATE );
--
procedure rehire(X_Person_Id NUMBER
                ,X_Rowid VARCHAR2
                ,X_Business_group_id NUMBER
                ,X_Set_Of_Books_Id NUMBER
                ,X_Hire_Date DATE);
--
procedure check_future_person_types(p_system_person_type  VARCHAR2
                                   ,p_person_id IN INTEGER
                                   ,p_business_group_id IN INTEGER
                                   ,p_effective_start_date IN DATE);
--
procedure check_person_changes(p_person_id NUMBER
                              ,p_hire_date DATE
                              ,p_s_hire_Date DATE
										,p_current_application_id NUMBER DEFAULT NULL);
--
END PER_PEOPLE_V15_PKG;

 

/
