--------------------------------------------------------
--  DDL for Package PER_PEOPLE_V7_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEOPLE_V7_PKG" AUTHID CURRENT_USER as
/* $Header: peper07t.pkh 120.0.12000000.1 2007/01/22 01:04:51 appldev noship $ */
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Person_Id                           NUMBER,
                     X_Effective_Start_Date         IN OUT NOCOPY DATE,
                     X_Effective_End_Date           IN OUT NOCOPY DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Type_Id                      NUMBER,
                     X_Last_Name                           VARCHAR2,
                     X_Start_Date                   IN OUT NOCOPY DATE,
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
                     X_Per_Information_Category            VARCHAR2,
                     X_Per_Information1                    VARCHAR2,
                     X_Per_Information2                    VARCHAR2,
                     X_Per_Information3                    VARCHAR2,
                     X_Per_Information4                    VARCHAR2,
                     X_Per_Information5                    VARCHAR2,
                     X_Per_Information6                    VARCHAR2,
                     X_Per_Information7                    VARCHAR2,
                     X_Per_Information8                    VARCHAR2,
                     X_Per_Information9                    VARCHAR2,
                     X_Per_Information10                   VARCHAR2,
                     X_Per_Information11                   VARCHAR2,
                     X_Per_Information12                   VARCHAR2,
                     X_Per_Information13                   VARCHAR2,
                     X_Per_Information14                   VARCHAR2,
                     X_Per_Information15                   VARCHAR2,
                     X_Per_Information16                   VARCHAR2,
                     X_Per_Information17                   VARCHAR2,
                     X_Per_Information18                   VARCHAR2,
                     X_Per_Information19                   VARCHAR2,
                     X_Per_Information20                   VARCHAR2,
                     X_Per_Information21                   VARCHAR2,
                     X_Per_Information22                   VARCHAR2,
                     X_Per_Information23                   VARCHAR2,
                     X_Per_Information24                   VARCHAR2,
                     X_Per_Information25                   VARCHAR2,
                     X_Per_Information26                   VARCHAR2,
                     X_Per_Information27                   VARCHAR2,
                     X_Per_Information28                   VARCHAR2,
                     X_Per_Information29                   VARCHAR2,
                     X_Per_Information30                   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Current_Application_Id              NUMBER DEFAULT NULL,
                     X_Order_Name                          VARCHAR2,
                     X_Global_Name                         VARCHAR2,
                     X_Local_Name                          VARCHAR2
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
procedure modify_hire_date(X_Person_Id 	          NUMBER
		          ,X_Hire_Date            DATE
			  ,X_S_Hire_Date          DATE
			  ,X_System_Person_Type   VARCHAR2
			  ,X_Period_Of_Service_Id NUMBER );
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
END PER_PEOPLE_V7_PKG;

 

/
