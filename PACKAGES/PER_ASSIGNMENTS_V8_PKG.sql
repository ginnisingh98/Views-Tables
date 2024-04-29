--------------------------------------------------------
--  DDL for Package PER_ASSIGNMENTS_V8_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASSIGNMENTS_V8_PKG" AUTHID CURRENT_USER as
/* $Header: peasg08t.pkh 120.1 2006/01/23 06:35:05 eumenyio noship $ */
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Assignment_Id                       IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Assignment_Status_Type_Id   IN OUT NOCOPY  NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Assignment_Sequence          IN OUT NOCOPY NUMBER,
                     X_Assignment_Type                     VARCHAR2,
                     X_Primary_Flag                 IN OUT NOCOPY VARCHAR2,
                     X_Assignment_Number            IN OUT NOCOPY VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Period_Of_Service_Id                NUMBER,
                     X_Default_Code_Comb_Id                NUMBER,
                     X_Set_Of_Books_Id                     NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Supervisor_Id                       NUMBER,
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
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Title                               VARCHAR2
                     );
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Assignment_Id                       IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Assignment_Status_Type_Id   IN OUT NOCOPY  NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Assignment_Sequence          IN OUT NOCOPY NUMBER,
                     X_Assignment_Type                     VARCHAR2,
                     X_Primary_Flag                 IN OUT NOCOPY VARCHAR2,
                     X_Assignment_Number            IN OUT NOCOPY VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Period_Of_Service_Id                NUMBER,
                     X_Default_Code_Comb_Id                NUMBER,
                     X_Set_Of_Books_Id                     NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Supervisor_Id                       NUMBER,
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
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Title                               VARCHAR2
                     );
--
procedure delete_record(p_ROWID Varchar2);
--
procedure get_enddate_and_defaults(p_effective_start_date IN OUT NOCOPY  DATE
                     ,p_job_name                          IN OUT NOCOPY  VARCHAR2
                     ,p_job_id                            IN OUT NOCOPY  NUMBER
                     ,p_position_name                     IN OUT NOCOPY  VARCHAR2
                     ,p_position_id                       IN OUT NOCOPY  NUMBER
                     ,p_organization_name                 IN OUT NOCOPY  VARCHAR2
                     ,p_organization_id                   IN OUT NOCOPY  NUMBER
                     ,p_Assignment_Id                     IN OUT NOCOPY  NUMBER
                     ,p_Effective_End_Date                IN OUT NOCOPY  DATE
                     ,p_Business_Group_Id                 IN OUT NOCOPY  NUMBER
                     ,p_Assignment_Status_Type_Id         IN OUT NOCOPY  NUMBER
                     ,p_Person_Id                         IN OUT NOCOPY  NUMBER
                     ,p_Period_of_service_id              IN OUT NOCOPY  NUMBER
                     ,p_Assignment_Sequence               IN OUT NOCOPY NUMBER
                     ,p_Assignment_Type                   IN OUT NOCOPY  VARCHAR2
                     ,p_Primary_Flag                      IN OUT NOCOPY VARCHAR2
                     ,p_Assignment_Number                 IN OUT NOCOPY VARCHAR2
                     ,p_Comment_Id                        IN OUT NOCOPY  NUMBER
                     ,p_Set_Of_Books_Id                   IN OUT NOCOPY  NUMBER
                     ,p_Location_code                     IN OUT NOCOPY  VARCHAR2
                     ,p_Location_Id                       IN OUT NOCOPY  NUMBER
                     ,p_Supervisor_name                   IN OUT NOCOPY  VARCHAR2
                     ,p_Supervisor_Id                     IN OUT NOCOPY  NUMBER
                     ,p_Title                             IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute_Category            IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute1                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute2                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute3                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute4                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute5                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute6                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute7                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute8                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute9                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute10                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute11                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute12                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute13                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute14                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute15                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute16                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute17                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute18                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute19                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute20                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute21                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute22                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute23                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute24                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute25                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute26                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute27                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute28                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute29                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute30                   IN OUT NOCOPY  VARCHAR2
                     ,p_warning_message                   IN OUT NOCOPY  VARCHAR2);
--
procedure get_enddate_and_defaults(p_effective_start_date IN OUT NOCOPY  DATE
                     ,p_job_name                          IN OUT NOCOPY  VARCHAR2
                     ,p_job_id                            IN OUT NOCOPY  NUMBER
                     ,p_organization_name                 IN OUT NOCOPY  VARCHAR2
                     ,p_organization_id                   IN OUT NOCOPY  NUMBER
                     ,p_Assignment_Id                     IN OUT NOCOPY  NUMBER
                     ,p_Effective_End_Date                IN OUT NOCOPY  DATE
                     ,p_Business_Group_Id                 IN OUT NOCOPY  NUMBER
                     ,p_Assignment_Status_Type_Id         IN OUT NOCOPY  NUMBER
                     ,p_Person_Id                         IN OUT NOCOPY  NUMBER
                     ,p_Period_of_service_id              IN OUT NOCOPY  NUMBER
                     ,p_Assignment_Sequence               IN OUT NOCOPY NUMBER
                     ,p_Assignment_Type                   IN OUT NOCOPY  VARCHAR2
                     ,p_Primary_Flag                      IN OUT NOCOPY VARCHAR2
                     ,p_Assignment_Number                 IN OUT NOCOPY VARCHAR2
                     ,p_Comment_Id                        IN OUT NOCOPY  NUMBER
                     ,p_Set_Of_Books_Id                   IN OUT NOCOPY  NUMBER
                     ,p_Location_code                     IN OUT NOCOPY  VARCHAR2
                     ,p_Location_Id                       IN OUT NOCOPY  NUMBER
                     ,p_Supervisor_name                   IN OUT NOCOPY  VARCHAR2
                     ,p_Supervisor_Id                     IN OUT NOCOPY  NUMBER
                     ,p_Title                             IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute_Category            IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute1                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute2                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute3                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute4                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute5                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute6                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute7                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute8                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute9                    IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute10                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute11                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute12                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute13                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute14                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute15                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute16                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute17                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute18                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute19                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute20                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute21                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute22                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute23                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute24                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute25                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute26                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute27                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute28                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute29                   IN OUT NOCOPY  VARCHAR2
                     ,p_Ass_Attribute30                   IN OUT NOCOPY  VARCHAR2
                     ,p_warning_message                   IN OUT NOCOPY  VARCHAR2);
--
procedure validate_effective_start(p_effective_start_date DATE
                                  ,p_person_id NUMBER
                                  ,p_period_of_service_id NUMBER);
--
END PER_ASSIGNMENTS_V8_PKG;

 

/
