--------------------------------------------------------
--  DDL for Package PER_PEOPLE_V14_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEOPLE_V14_PKG" AUTHID CURRENT_USER AS
/* $Header: peper14t.pkh 120.0 2005/05/31 13:41:55 appldev noship $ */
PROCEDURE form_startup(X_Business_group_id IN OUT NOCOPY NUMBER
                      ,X_Set_Of_Books_Id IN OUT NOCOPY NUMBER
                      ,X_Resp_Appl_Id NUMBER
                      ,X_Resp_Id NUMBER
                      ,X_Legislation_Code IN OUT NOCOPY VARCHAR2
                      ,X_business_group_name IN OUT NOCOPY VARCHAR2
                      ,X_property_on NUMBER
                      ,X_property_off NUMBER
                      ,X_Query_Only_Flag VARCHAR2
                      ,X_employee_property IN OUT NOCOPY NUMBER
                      ,X_expense_check_to_address IN OUT NOCOPY VARCHAR2
                      ,X_expense_to_address_meaning IN OUT NOCOPY VARCHAR2
                      ,X_chart_of_accounts_id IN OUT NOCOPY NUMBER
                      ,X_set_of_books_name IN OUT NOCOPY VARCHAR2
                      ,X_Session_Date IN OUT NOCOPY DATE
                      ,X_End_Of_Time IN OUT NOCOPY DATE
                      ,X_current_appl_id IN OUT NOCOPY NUMBER
                      ,X_person_type_id IN OUT NOCOPY NUMBER
                      ,X_current_employee_flag IN OUT NOCOPY VARCHAR2
                      ,X_current_applicant_flag IN OUT NOCOPY VARCHAR2
                      ,X_current_emp_or_apl_flag IN OUT NOCOPY VARCHAR2);

--
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Person_Id                            IN OUT NOCOPY NUMBER,
                     X_Party_Id                             NUMBER DEFAULT NULL,
                     X_Effective_Start_Date                 DATE,
                     X_Effective_End_Date                   DATE,
                     X_Business_Group_Id                    NUMBER,
                     X_Person_Type_Id                       NUMBER,
                     X_Last_Name                            VARCHAR2,
                     X_Start_Date                           DATE,
                     X_Applicant_Number                     VARCHAR2,
                     X_Comment_Id                           NUMBER,
                     X_Current_Applicant_Flag               VARCHAR2,
                     X_Current_Emp_Or_Apl_Flag              VARCHAR2,
                     X_Current_Employee_Flag                VARCHAR2,
                     X_Date_Employee_Data_Verified          DATE,
                     X_Date_Of_Birth                        DATE,
                     X_Email_Address                        VARCHAR2,
                     X_Employee_Number                      VARCHAR2,
                     X_Expense_Check_To_Address        VARCHAR2,
                     X_First_Name                           VARCHAR2,
                     X_Full_Name                            VARCHAR2,
                     X_Known_As                             VARCHAR2,
                     X_Marital_Status                       VARCHAR2,
                     X_Middle_Names                         VARCHAR2,
                     X_Nationality                          VARCHAR2,
                     X_National_Identifier                  VARCHAR2,
                     X_Previous_Last_Name                   VARCHAR2,
                     X_Registered_Disabled_Flag             VARCHAR2,
                     X_Sex                                  VARCHAR2,
                     X_Title                                VARCHAR2,
                     X_Vendor_Id                            NUMBER,
                     X_Work_Telephone                       VARCHAR2,
                     X_Attribute_Category                   VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Attribute16                          VARCHAR2,
                     X_Attribute17                          VARCHAR2,
                     X_Attribute18                          VARCHAR2,
                     X_Attribute19                          VARCHAR2,
                     X_Attribute20                          VARCHAR2,
                     X_Attribute21                          VARCHAR2,
                     X_Attribute22                          VARCHAR2,
                     X_Attribute23                          VARCHAR2,
                     X_Attribute24                          VARCHAR2,
                     X_Attribute25                          VARCHAR2,
                     X_Attribute26                          VARCHAR2,
                     X_Attribute27                          VARCHAR2,
                     X_Attribute28                          VARCHAR2,
                     X_Attribute29                          VARCHAR2,
                     X_Attribute30                          VARCHAR2,
                     X_Per_Information_Category             VARCHAR2,
                     X_Per_Information1                     VARCHAR2,
                     X_Per_Information2                     VARCHAR2,
                     X_Per_Information3                     VARCHAR2,
                     X_Per_Information4                     VARCHAR2,
                     X_Per_Information5                     VARCHAR2,
                     X_Per_Information6                     VARCHAR2,
                     X_Per_Information7                     VARCHAR2,
                     X_Per_Information8                     VARCHAR2,
                     X_Per_Information9                     VARCHAR2,
                     X_Per_Information10                    VARCHAR2,
                     X_Per_Information11                    VARCHAR2,
                     X_Per_Information12                    VARCHAR2,
                     X_Per_Information13                    VARCHAR2,
                     X_Per_Information14                    VARCHAR2,
                     X_Per_Information15                    VARCHAR2,
                     X_Per_Information16                    VARCHAR2,
                     X_Per_Information17                    VARCHAR2,
                     X_Per_Information18                    VARCHAR2,
                     X_Per_Information19                    VARCHAR2,
                     X_Per_Information20                    VARCHAR2,
                     X_Per_Information21                    VARCHAR2,
                     X_Per_Information22                    VARCHAR2,
                     X_Per_Information23                    VARCHAR2,
                     X_Per_Information24                    VARCHAR2,
                     X_Per_Information25                    VARCHAR2,
                     X_Per_Information26                    VARCHAR2,
                     X_Per_Information27                    VARCHAR2,
                     X_Per_Information28                    VARCHAR2,
                     X_Per_Information29                    VARCHAR2,
                     X_Per_Information30                    VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Created_By                           NUMBER,
                     X_Creation_Date                        DATE,
                     X_Order_Name                           VARCHAR2,
                     X_Global_Name                          VARCHAR2,
                     X_Local_Name                           VARCHAR2,
                     X_PERIOD_OF_SERVICE_ID        IN OUT NOCOPY   NUMBER,
				 X_town_of_birth                        VARCHAR2 DEFAULT NULL,
				 X_region_of_birth                      VARCHAR2 DEFAULT NULL,
				 X_country_of_birth                     VARCHAR2 DEFAULT NULL,
				 X_global_person_id                     VARCHAR2 DEFAULT NULL,
                     X_blood_type            VARCHAR2 default NULL,
                     X_correspondence_language VARCHAR2 default NULL,
                     X_honors                 VARCHAR2 default NULL,
                     X_pre_name_adjunct       VARCHAR2 default NULL,
                     X_rehire_authorizor      VARCHAR2 default NULL,
                     X_rehire_recommendation  VARCHAR2 default NULL,
                     X_resume_exists          VARCHAR2 default NULL,
                     X_resume_last_updated    DATE default NULL,
                     X_second_passport_exists VARCHAR2 default NULL,
                     X_student_status     VARCHAR2 default NULL,
                     X_suffix             VARCHAR2 default NULL,
                     X_date_of_death      DATE default NULL,
                     X_uses_tobacco_flag  VARCHAR2 default NULL,
                     X_fast_path_employee VARCHAR2 default NULL,
                     X_fte_capacity    VARCHAR2 default NULL
                     );
--
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Person_Id                              NUMBER,
                   X_Effective_Start_Date                   DATE,
                   X_Effective_End_Date                     DATE,
                   X_Business_Group_Id                      NUMBER,
                   X_Person_Type_Id                         NUMBER,
                   X_Last_Name                              VARCHAR2,
                   X_Start_Date                             DATE,
                   X_Applicant_Number                       VARCHAR2,
                   X_Comment_Id                             NUMBER,
                   X_Current_Applicant_Flag                 VARCHAR2,
                   X_Current_Emp_Or_Apl_Flag                VARCHAR2,
                   X_Current_Employee_Flag                  VARCHAR2,
                   X_Date_Employee_Data_Verified            DATE,
                   X_Date_Of_Birth                          DATE,
                   X_Email_Address                          VARCHAR2,
                   X_Employee_Number                        VARCHAR2,
                   X_Expense_Check_To_Address          VARCHAR2,
                   X_First_Name                             VARCHAR2,
                   X_Full_Name                              VARCHAR2,
                   X_Known_As                               VARCHAR2,
                   X_Marital_Status                         VARCHAR2,
                   X_Middle_Names                           VARCHAR2,
                   X_Nationality                            VARCHAR2,
                   X_National_Identifier                    VARCHAR2,
                   X_Previous_Last_Name                     VARCHAR2,
                   X_Registered_Disabled_Flag               VARCHAR2,
                   X_Sex                                    VARCHAR2,
                   X_Title                                  VARCHAR2,
                   X_Vendor_Id                              NUMBER,
                   X_Work_Telephone                         VARCHAR2,
                   X_Attribute_Category                     VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2,
                   X_Attribute16                            VARCHAR2,
                   X_Attribute17                            VARCHAR2,
                   X_Attribute18                            VARCHAR2,
                   X_Attribute19                            VARCHAR2,
                   X_Attribute20                            VARCHAR2,
                   X_Attribute21                            VARCHAR2,
                   X_Attribute22                            VARCHAR2,
                   X_Attribute23                            VARCHAR2,
                   X_Attribute24                            VARCHAR2,
                   X_Attribute25                            VARCHAR2,
                   X_Attribute26                            VARCHAR2,
                   X_Attribute27                            VARCHAR2,
                   X_Attribute28                            VARCHAR2,
                   X_Attribute29                            VARCHAR2,
                   X_Attribute30                            VARCHAR2,
                   X_Per_Information_Category               VARCHAR2,
                   X_Per_Information1                       VARCHAR2,
                   X_Per_Information2                       VARCHAR2,
                   X_Per_Information3                       VARCHAR2,
                   X_Per_Information4                       VARCHAR2,
                   X_Per_Information5                       VARCHAR2,
                   X_Per_Information6                       VARCHAR2,
                   X_Per_Information7                       VARCHAR2,
                   X_Per_Information8                       VARCHAR2,
                   X_Per_Information9                       VARCHAR2,
                   X_Per_Information10                      VARCHAR2,
                   X_Per_Information11                      VARCHAR2,
                   X_Per_Information12                      VARCHAR2,
                   X_Per_Information13                      VARCHAR2,
                   X_Per_Information14                      VARCHAR2,
                   X_Per_Information15                      VARCHAR2,
                   X_Per_Information16                      VARCHAR2,
                   X_Per_Information17                      VARCHAR2,
                   X_Per_Information18                      VARCHAR2,
                   X_Per_Information19                      VARCHAR2,
                   X_Per_Information20                      VARCHAR2,
                   X_Per_Information21                      VARCHAR2,
                   X_Per_Information22                      VARCHAR2,
                   X_Per_Information23                      VARCHAR2,
                   X_Per_Information24                      VARCHAR2,
                   X_Per_Information25                      VARCHAR2,
                   X_Per_Information26                      VARCHAR2,
                   X_Per_Information27                      VARCHAR2,
                   X_Per_Information28                      VARCHAR2,
                   X_Per_Information29                      VARCHAR2,
                   X_Per_Information30                      VARCHAR2
                   );

PROCEDURE Insert_period_of_Service(X_Person_Id 			 NUMBER
                                  ,X_Business_Group_Id 		 NUMBER
                                  ,X_Date_Start 		 DATE
                                  ,X_Period_of_Service_Id IN OUT NOCOPY NUMBER
				  );

--
END PER_PEOPLE_V14_PKG;

 

/
