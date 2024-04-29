--------------------------------------------------------
--  DDL for Package PER_ASSIGNMENTS_V7_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASSIGNMENTS_V7_PKG" AUTHID CURRENT_USER as
/* $Header: peasg07t.pkh 120.0.12010000.2 2008/08/06 08:58:53 ubhat ship $ */
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Assignment_Id                        IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                 DATE,
                     X_Effective_End_Date                   DATE,
                     X_Business_Group_Id                    NUMBER,
                     X_Recruiter_Id                         NUMBER,
                     X_Grade_Id                             NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Job_Id                               NUMBER,
                     X_Assignment_Status_Type_Id    IN OUT NOCOPY  NUMBER,
                     X_Payroll_Id                           NUMBER,
                     X_Location_Id                          NUMBER,
                     X_Person_Referred_By_Id                NUMBER,
                     X_Supervisor_Id                        NUMBER,
                     X_Special_Ceiling_Step_Id              NUMBER,
                     X_Person_Id                            NUMBER,
                     X_Employee_Number                      VARCHAR2,
                     X_Recruitment_Activity_Id              NUMBER,
                     X_Source_Organization_Id               NUMBER,
                     X_Organization_Id                      NUMBER,
                     X_People_Group_Id                      NUMBER,
                     X_Soft_Coding_Keyflex_Id               NUMBER,
                     X_Vacancy_Id                           NUMBER,
                     X_Pay_Basis_Id                         NUMBER,
                     X_Assignment_Sequence          IN OUT NOCOPY  NUMBER,
                     X_Assignment_Type                      VARCHAR2,
                     X_Primary_Flag                 IN OUT NOCOPY  VARCHAR2,
                     X_Application_Id                       NUMBER,
                     X_Assignment_Number            IN OUT NOCOPY  VARCHAR2,
                     X_Change_Reason                        VARCHAR2,
                     X_Comment_Id                           NUMBER,
                     X_Date_Probation_End                   DATE,
                     X_Default_Code_Comb_Id                 NUMBER,
                     X_Employment_Category                  VARCHAR2,
                     X_Frequency                            VARCHAR2,
                     X_Internal_Address_Line                VARCHAR2,
                     X_Manager_Flag                         VARCHAR2,
                     X_Normal_Hours                         NUMBER,
                     X_Perf_Review_Period                   NUMBER,
                     X_Perf_Review_Period_Frequency         VARCHAR2,
                     X_Period_Of_Service_Id                 NUMBER,
                     X_Probation_Period                     NUMBER,
                     X_Probation_Unit                       VARCHAR2,
                     X_Sal_Review_Period                    NUMBER,
                     X_Sal_Review_Period_Frequency          VARCHAR2,
                     X_Set_Of_Books_Id                      NUMBER,
                     X_Source_Type                          VARCHAR2,
                     X_Time_Normal_Finish                   VARCHAR2,
                     X_Time_Normal_Start                    VARCHAR2,
                     X_Ass_Attribute_Category               VARCHAR2,
                     X_Ass_Attribute1                       VARCHAR2,
                     X_Ass_Attribute2                       VARCHAR2,
                     X_Ass_Attribute3                       VARCHAR2,
                     X_Ass_Attribute4                       VARCHAR2,
                     X_Ass_Attribute5                       VARCHAR2,
                     X_Ass_Attribute6                       VARCHAR2,
                     X_Ass_Attribute7                       VARCHAR2,
                     X_Ass_Attribute8                       VARCHAR2,
                     X_Ass_Attribute9                       VARCHAR2,
                     X_Ass_Attribute10                      VARCHAR2,
                     X_Ass_Attribute11                      VARCHAR2,
                     X_Ass_Attribute12                      VARCHAR2,
                     X_Ass_Attribute13                      VARCHAR2,
                     X_Ass_Attribute14                      VARCHAR2,
                     X_Ass_Attribute15                      VARCHAR2,
                     X_Ass_Attribute16                      VARCHAR2,
                     X_Ass_Attribute17                      VARCHAR2,
                     X_Ass_Attribute18                      VARCHAR2,
                     X_Ass_Attribute19                      VARCHAR2,
                     X_Ass_Attribute20                      VARCHAR2,
                     X_Ass_Attribute21                      VARCHAR2,
                     X_Ass_Attribute22                      VARCHAR2,
                     X_Ass_Attribute23                      VARCHAR2,
                     X_Ass_Attribute24                      VARCHAR2,
                     X_Ass_Attribute25                      VARCHAR2,
                     X_Ass_Attribute26                      VARCHAR2,
                     X_Ass_Attribute27                      VARCHAR2,
                     X_Ass_Attribute28                      VARCHAR2,
                     X_Ass_Attribute29                      VARCHAR2,
                     X_Ass_Attribute30                      VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Created_By                           NUMBER,
                     X_Creation_Date                        DATE,
                     X_Title                                VARCHAR2
                     );
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Assignment_Id                          NUMBER,
                   X_Effective_Start_Date                   DATE,
                   X_Effective_End_Date                     DATE,
                   X_Business_Group_Id                      NUMBER,
                   X_Recruiter_Id                           NUMBER,
                   X_Grade_Id                               NUMBER,
                   X_Position_Id                            NUMBER,
                   X_Job_Id                                 NUMBER,
                   X_Assignment_Status_Type_Id              NUMBER,
                   X_Payroll_Id                             NUMBER,
                   X_Location_Id                            NUMBER,
                   X_Person_Referred_By_Id                  NUMBER,
                   X_Supervisor_Id                          NUMBER,
                   X_Special_Ceiling_Step_Id                NUMBER,
                   X_Person_Id                              NUMBER,
                   X_Source_Organization_Id                 NUMBER,
                   X_Recruitment_Activity_Id                NUMBER,
                   X_Organization_Id                        NUMBER,
                   X_People_Group_Id                        NUMBER,
                   X_Soft_Coding_Keyflex_Id                 NUMBER,
                   X_Vacancy_Id                             NUMBER,
                   X_Pay_Basis_Id                           NUMBER,
                   X_Assignment_Sequence                    NUMBER,
                   X_Assignment_Type                        VARCHAR2,
                   X_Primary_Flag                           VARCHAR2,
                   X_Application_Id                         NUMBER,
                   X_Assignment_Number                      VARCHAR2,
                   X_Change_Reason                          VARCHAR2,
                   X_Comment_Id                             NUMBER,
                   X_Date_Probation_End                     DATE,
                   X_Default_Code_Comb_Id                   NUMBER,
                   X_Employment_Category                    VARCHAR2,
                   X_Frequency                              VARCHAR2,
                   X_Internal_Address_Line                  VARCHAR2,
                   X_Manager_Flag                           VARCHAR2,
                   X_Normal_Hours                           NUMBER,
                   X_Perf_Review_Period                     NUMBER,
                   X_Perf_Review_Period_Frequency           VARCHAR2,
                   X_Period_Of_Service_Id                   NUMBER,
                   X_Probation_Period                       NUMBER,
                   X_Probation_Unit                         VARCHAR2,
                   X_Sal_Review_Period                      NUMBER,
                   X_Sal_Review_Period_Frequency            VARCHAR2,
                   X_Set_Of_Books_Id                        NUMBER,
                   X_Source_Type                            VARCHAR2,
                   X_Time_Normal_Finish                     VARCHAR2,
                   X_Time_Normal_Start                      VARCHAR2,
                   X_Ass_Attribute_Category                 VARCHAR2,
                   X_Ass_Attribute1                         VARCHAR2,
                   X_Ass_Attribute2                         VARCHAR2,
                   X_Ass_Attribute3                         VARCHAR2,
                   X_Ass_Attribute4                         VARCHAR2,
                   X_Ass_Attribute5                         VARCHAR2,
                   X_Ass_Attribute6                         VARCHAR2,
                   X_Ass_Attribute7                         VARCHAR2,
                   X_Ass_Attribute8                         VARCHAR2,
                   X_Ass_Attribute9                         VARCHAR2,
                   X_Ass_Attribute10                        VARCHAR2,
                   X_Ass_Attribute11                        VARCHAR2,
                   X_Ass_Attribute12                        VARCHAR2,
                   X_Ass_Attribute13                        VARCHAR2,
                   X_Ass_Attribute14                        VARCHAR2,
                   X_Ass_Attribute15                        VARCHAR2,
                   X_Ass_Attribute16                        VARCHAR2,
                   X_Ass_Attribute17                        VARCHAR2,
                   X_Ass_Attribute18                        VARCHAR2,
                   X_Ass_Attribute19                        VARCHAR2,
                   X_Ass_Attribute20                        VARCHAR2,
                   X_Ass_Attribute21                        VARCHAR2,
                   X_Ass_Attribute22                        VARCHAR2,
                   X_Ass_Attribute23                        VARCHAR2,
                   X_Ass_Attribute24                        VARCHAR2,
                   X_Ass_Attribute25                        VARCHAR2,
                   X_Ass_Attribute26                        VARCHAR2,
                   X_Ass_Attribute27                        VARCHAR2,
                   X_Ass_Attribute28                        VARCHAR2,
                   X_Ass_Attribute29                        VARCHAR2,
                   X_Ass_Attribute30                        VARCHAR2,
                   X_Title                                  VARCHAR2
                   );
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Assignment_Id                       NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Recruiter_Id                        NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Assignment_Status_Type_Id           NUMBER,
                     X_Payroll_Id                          NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Person_Referred_By_Id               NUMBER,
                     X_Supervisor_Id                       NUMBER,
                     X_Special_Ceiling_Step_Id             NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Recruitment_Activity_Id             NUMBER,
                     X_Source_Organization_Id              NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_People_Group_Id                     NUMBER,
                     X_Soft_Coding_Keyflex_Id              NUMBER,
                     X_Vacancy_Id                          NUMBER,
                     X_Pay_Basis_Id                        NUMBER,
                     X_Assignment_Sequence                 NUMBER,
                     X_Assignment_Type                     VARCHAR2,
                     X_Primary_Flag                        VARCHAR2,
                     X_Application_Id                      NUMBER,
                     X_Assignment_Number                   VARCHAR2,
                     X_Change_Reason                       VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Date_Probation_End                  DATE,
                     X_Default_Code_Comb_Id                NUMBER,
                     X_Employment_Category                 VARCHAR2,
                     X_Frequency                           VARCHAR2,
                     X_Internal_Address_Line               VARCHAR2,
                     X_Manager_Flag                        VARCHAR2,
                     X_Normal_Hours                        NUMBER,
                     X_Perf_Review_Period                  NUMBER,
                     X_Perf_Review_Period_Frequency        VARCHAR2,
                     X_Period_Of_Service_Id                NUMBER,
                     X_Probation_Period                    NUMBER,
                     X_Probation_Unit                      VARCHAR2,
                     X_Sal_Review_Period                   NUMBER,
                     X_Sal_Review_Period_Frequency         VARCHAR2,
                     X_Set_Of_Books_Id                     NUMBER,
                     X_Source_Type                         VARCHAR2,
                     X_Time_Normal_Finish                  VARCHAR2,
                     X_Time_Normal_Start                   VARCHAR2,
                     X_Ass_Attribute_Category              VARCHAR2,
                     X_Ass_Attribute1                      VARCHAR2,
                     X_Ass_Attribute2                      VARCHAR2,
                     X_Ass_Attribute3                      VARCHAR2,
                     X_Ass_Attribute4                      VARCHAR2,
                     X_Ass_Attribute5                      VARCHAR2,
                     X_Ass_Attribute6                      VARCHAR2,
                     X_Ass_Attribute7                      VARCHAR2,
                     X_Ass_Attribute8                      VARCHAR2,
                     X_Ass_Attribute9                      VARCHAR2,
                     X_Ass_Attribute10                     VARCHAR2,
                     X_Ass_Attribute11                     VARCHAR2,
                     X_Ass_Attribute12                     VARCHAR2,
                     X_Ass_Attribute13                     VARCHAR2,
                     X_Ass_Attribute14                     VARCHAR2,
                     X_Ass_Attribute15                     VARCHAR2,
                     X_Ass_Attribute16                     VARCHAR2,
                     X_Ass_Attribute17                     VARCHAR2,
                     X_Ass_Attribute18                     VARCHAR2,
                     X_Ass_Attribute19                     VARCHAR2,
                     X_Ass_Attribute20                     VARCHAR2,
                     X_Ass_Attribute21                     VARCHAR2,
                     X_Ass_Attribute22                     VARCHAR2,
                     X_Ass_Attribute23                     VARCHAR2,
                     X_Ass_Attribute24                     VARCHAR2,
                     X_Ass_Attribute25                     VARCHAR2,
                     X_Ass_Attribute26                     VARCHAR2,
                     X_Ass_Attribute27                     VARCHAR2,
                     X_Ass_Attribute28                     VARCHAR2,
                     X_Ass_Attribute29                     VARCHAR2,
                     X_Ass_Attribute30                     VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Title                               VARCHAR2,
							X_Current_application_id              NUMBER DEFAULT NULL
                     );
PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
PROCEDURE get_location_address (X_location_id        NUMBER
                               ,X_Address_Line_1     IN OUT NOCOPY VARCHAR2
                               ,X_Address_Line_2     IN OUT NOCOPY VARCHAR2
                               ,X_Address_Line_3     IN OUT NOCOPY VARCHAR2
			       ,X_Bill_to_site_flag  IN OUT NOCOPY VARCHAR2
                               ,X_Country            IN OUT NOCOPY VARCHAR2
			       ,X_Description	     IN OUT NOCOPY VARCHAR2
			       ,X_Designated_receiver_id    IN OUT NOCOPY NUMBER
			       ,X_In_organization_flag      IN OUT NOCOPY VARCHAR2
			       ,X_Inactive_date	     IN OUT NOCOPY DATE
			       ,X_Inventory_organization_id IN OUT NOCOPY NUMBER
			       ,X_Office_site_flag   IN OUT NOCOPY VARCHAR2
                               ,X_Postal_Code        IN OUT NOCOPY VARCHAR2
			       ,X_Receiving_site_flag       IN OUT NOCOPY VARCHAR2
                               ,X_Region_1           IN OUT NOCOPY VARCHAR2
                               ,X_Region_2           IN OUT NOCOPY VARCHAR2
                               ,X_Region_3           IN OUT NOCOPY VARCHAR2
			       ,X_Ship_to_location_id       IN OUT NOCOPY NUMBER
			       ,X_Ship_to_site_flag  IN OUT NOCOPY VARCHAR2
                               ,X_Style              IN OUT NOCOPY VARCHAR2
			       ,X_Tax_Name	     IN OUT NOCOPY VARCHAR2
                               ,X_Telephone_number_1 IN OUT NOCOPY VARCHAR2
                               ,X_Telephone_number_2 IN OUT NOCOPY VARCHAR2
                               ,X_Telephone_number_3 IN OUT NOCOPY VARCHAR2
                               ,X_Town_or_city       IN OUT NOCOPY VARCHAR2
                               ,X_Attribute_category IN OUT NOCOPY VARCHAR2
                               ,X_Attribute1         IN OUT NOCOPY VARCHAR2
                               ,X_Attribute2         IN OUT NOCOPY VARCHAR2
                               ,X_Attribute3         IN OUT NOCOPY VARCHAR2
                               ,X_Attribute4         IN OUT NOCOPY VARCHAR2
                               ,X_Attribute5         IN OUT NOCOPY VARCHAR2
                               ,X_Attribute6         IN OUT NOCOPY VARCHAR2
                               ,X_Attribute7         IN OUT NOCOPY VARCHAR2
                               ,X_Attribute8         IN OUT NOCOPY VARCHAR2
                               ,X_Attribute9         IN OUT NOCOPY VARCHAR2
                               ,X_Attribute10        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute11        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute12        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute13        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute14        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute15        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute16        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute17        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute18        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute19        IN OUT NOCOPY VARCHAR2
                               ,X_Attribute20        IN OUT NOCOPY VARCHAR2);
--
-- Added the parameter X_eff_dt for the bug 6817459
procedure check_primary(X_person_id NUMBER
			,X_eff_dt  date default sysdate
        		,X_primary_flag IN OUT NOCOPY VARCHAR2);
--
procedure get_previous_changes(X_assignment_id NUMBER
										,X_effective_start_date DATE
										,X_current_application_id NUMBER DEFAULT NULL);
--
procedure get_future_changes(X_assignment_id NUMBER
										,X_effective_start_date DATE
										,X_current_application_id NUMBER DEFAULT NULL);
END PER_ASSIGNMENTS_V7_PKG;

/
