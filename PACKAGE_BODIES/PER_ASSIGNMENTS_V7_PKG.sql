--------------------------------------------------------
--  DDL for Package Body PER_ASSIGNMENTS_V7_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASSIGNMENTS_V7_PKG" as
/* $Header: peasg07t.pkb 120.2.12010000.2 2008/08/06 08:58:41 ubhat ship $ */
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Assignment_Id                       IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Recruiter_Id                        NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Assignment_Status_Type_Id   IN OUT NOCOPY  NUMBER,
                     X_Payroll_Id                          NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Person_Referred_By_Id               NUMBER,
                     X_Supervisor_Id                       NUMBER,
                     X_Special_Ceiling_Step_Id             NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Employee_Number                     VARCHAR2,
                     X_Recruitment_Activity_Id             NUMBER,
                     X_Source_Organization_Id              NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_People_Group_Id                     NUMBER,
                     X_Soft_Coding_Keyflex_Id              NUMBER,
                     X_Vacancy_Id                          NUMBER,
                     X_Pay_Basis_Id                        NUMBER,
                     X_Assignment_Sequence          IN OUT NOCOPY NUMBER,
                     X_Assignment_Type                     VARCHAR2,
                     X_Primary_Flag                 IN OUT NOCOPY VARCHAR2,
                     X_Application_Id                      NUMBER,
                     X_Assignment_Number            IN OUT NOCOPY VARCHAR2,
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
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Title                               VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM PER_ASSIGNMENTS_F
             WHERE assignment_id = X_Assignment_Id;
    CURSOR C2 IS SELECT per_assignments_s.nextval FROM sys.dual;
    cursor c3 is
   select past.assignment_status_type_id
   from per_assignment_status_types past
,      per_ass_status_type_amends pasa
,      per_business_groups pbg
where  pasa.assignment_status_type_id(+) = past.assignment_status_type_id
and    pasa.business_group_id(+) = X_Business_Group_id
and    pbg.business_group_id = X_Business_Group_id
and    nvl(past.business_group_id,X_Business_Group_id) = X_Business_Group_id
and    nvl(past.legislation_code, pbg.legislation_code) = pbg.legislation_code
and    nvl(pasa.active_flag,past.active_flag) = 'Y'
and    nvl(pasa.default_flag,past.default_flag) = 'Y'
and    nvl(pasa.per_system_status,past.per_system_status) = 'ACTIVE_ASSIGN';
--
BEGIN
        hr_utility.set_location('per_assignments_v7_pkg.insert_row',10);
   if (X_Assignment_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Assignment_Id;
     CLOSE C2;
   end if;
        hr_utility.set_location('per_assignments_v7_pkg.insert_row',20);
   open c3;
   fetch c3 into X_assignment_status_type_id;
   close c3;
--
        hr_utility.set_location('per_assignments_v7_pkg.insert_row',30);
   hr_assignment.gen_new_ass_sequence(X_person_id
                                     ,X_Assignment_type
                                     ,X_assignment_sequence);
--
        hr_utility.set_location('per_assignments_v7_pkg.insert_row',40);
   hr_assignment.gen_new_ass_number(X_Assignment_Id
                                  ,X_business_group_id
                                  ,X_employee_number
                                  ,X_assignment_sequence
                                  ,X_assignment_number);
  --
  -- Check for current primary
  --
        hr_utility.set_location('per_assignments_v7_pkg.insert_row',50);

	-- Added the parameter X_eff_dt for the bug 6817459
  per_assignments_v7_pkg.check_primary(X_person_id => X_person_id
				       ,X_eff_dt => X_Effective_Start_Date
				       ,X_primary_flag => X_primary_flag);
--
        hr_utility.set_location('per_assignments_v7_pkg.insert_row',60);
  INSERT INTO PER_ASSIGNMENTS_F(
          assignment_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          recruiter_id,
          grade_id,
          position_id,
          job_id,
          assignment_status_type_id,
          payroll_id,
          location_id,
          person_referred_by_id,
          supervisor_id,
          special_ceiling_step_id,
          person_id,
          recruitment_activity_id,
          source_organization_id,
          organization_id,
          people_group_id,
          soft_coding_keyflex_id,
          vacancy_id,
          pay_basis_id,
          assignment_sequence,
          assignment_type,
          primary_flag,
          application_id,
          assignment_number,
          change_reason,
          comment_id,
          date_probation_end,
          default_code_comb_id,
          employment_category,
          frequency,
          internal_address_line,
          manager_flag,
          normal_hours,
          perf_review_period,
          perf_review_period_frequency,
          period_of_service_id,
          probation_period,
          probation_unit,
          sal_review_period,
          sal_review_period_frequency,
          set_of_books_id,
          source_type,
          time_normal_finish,
          time_normal_start,
          ass_attribute_category,
          ass_attribute1,
          ass_attribute2,
          ass_attribute3,
          ass_attribute4,
          ass_attribute5,
          ass_attribute6,
          ass_attribute7,
          ass_attribute8,
          ass_attribute9,
          ass_attribute10,
          ass_attribute11,
          ass_attribute12,
          ass_attribute13,
          ass_attribute14,
          ass_attribute15,
          ass_attribute16,
          ass_attribute17,
          ass_attribute18,
          ass_attribute19,
          ass_attribute20,
          ass_attribute21,
          ass_attribute22,
          ass_attribute23,
          ass_attribute24,
          ass_attribute25,
          ass_attribute26,
          ass_attribute27,
          ass_attribute28,
          ass_attribute29,
          ass_attribute30,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date,
          title
         ) VALUES (
          X_Assignment_Id,
          X_Effective_Start_Date,
          X_Effective_End_Date,
          X_Business_Group_Id,
          X_Recruiter_Id,
          X_Grade_Id,
          X_Position_Id,
          X_Job_Id,
          X_Assignment_Status_Type_Id,
          X_Payroll_Id,
          X_Location_Id,
          X_Person_Referred_By_Id,
          X_Supervisor_Id,
          X_Special_Ceiling_Step_Id,
          X_Person_Id,
          X_Recruitment_Activity_Id,
          X_Source_Organization_Id,
          X_Organization_Id,
          X_People_Group_Id,
          X_Soft_Coding_Keyflex_Id,
          X_Vacancy_Id,
          X_Pay_Basis_Id,
          X_Assignment_Sequence,
          X_Assignment_Type,
          X_Primary_Flag,
          X_Application_Id,
          X_Assignment_Number,
          X_Change_Reason,
          X_Comment_Id,
          X_Date_Probation_End,
          X_Default_Code_Comb_Id,
          X_Employment_Category,
          X_Frequency,
          X_Internal_Address_Line,
          X_Manager_Flag,
          X_Normal_Hours,
          X_Perf_Review_Period,
          X_Perf_Review_Period_Frequency,
          X_Period_Of_Service_Id,
          X_Probation_Period,
          X_Probation_Unit,
          X_Sal_Review_Period,
          X_Sal_Review_Period_Frequency,
          X_Set_Of_Books_Id,
          X_Source_Type,
          X_Time_Normal_Finish,
          X_Time_Normal_Start,
          X_Ass_Attribute_Category,
          X_Ass_Attribute1,
          X_Ass_Attribute2,
          X_Ass_Attribute3,
          X_Ass_Attribute4,
          X_Ass_Attribute5,
          X_Ass_Attribute6,
          X_Ass_Attribute7,
          X_Ass_Attribute8,
          X_Ass_Attribute9,
          X_Ass_Attribute10,
          X_Ass_Attribute11,
          X_Ass_Attribute12,
          X_Ass_Attribute13,
          X_Ass_Attribute14,
          X_Ass_Attribute15,
          X_Ass_Attribute16,
          X_Ass_Attribute17,
          X_Ass_Attribute18,
          X_Ass_Attribute19,
          X_Ass_Attribute20,
          X_Ass_Attribute21,
          X_Ass_Attribute22,
          X_Ass_Attribute23,
          X_Ass_Attribute24,
          X_Ass_Attribute25,
          X_Ass_Attribute26,
          X_Ass_Attribute27,
          X_Ass_Attribute28,
          X_Ass_Attribute29,
          X_Ass_Attribute30,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Created_By,
          X_Creation_Date,
          X_Title
  );
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
--
-- add the person to the appropriate security lists
--
        hr_utility.set_location('per_assignments_v7_pkg.insert_row',70);
  hr_security_internal.add_to_person_list
  (p_effective_date        => sysdate
  ,p_assignment_id         => X_Assignment_Id);
--
        hr_utility.set_location('per_assignments_v7_pkg.insert_row',80);
END Insert_Row;
--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Assignment_Id                         NUMBER,
                   X_Effective_Start_Date                  DATE,
                   X_Effective_End_Date                    DATE,
                   X_Business_Group_Id                     NUMBER,
                   X_Recruiter_Id                          NUMBER,
                   X_Grade_Id                              NUMBER,
                   X_Position_Id                           NUMBER,
                   X_Job_Id                                NUMBER,
                   X_Assignment_Status_Type_Id             NUMBER,
                   X_Payroll_Id                            NUMBER,
                   X_Location_Id                           NUMBER,
                   X_Person_Referred_By_Id                 NUMBER,
                   X_Supervisor_Id                         NUMBER,
                   X_Special_Ceiling_Step_Id               NUMBER,
                   X_Person_Id                             NUMBER,
                   X_Source_Organization_Id              NUMBER,
                   X_Recruitment_Activity_Id               NUMBER,
                   X_Organization_Id                       NUMBER,
                   X_People_Group_Id                       NUMBER,
                   X_Soft_Coding_Keyflex_Id                NUMBER,
                   X_Vacancy_Id                            NUMBER,
                   X_Pay_Basis_Id                          NUMBER,
                   X_Assignment_Sequence                   NUMBER,
                   X_Assignment_Type                       VARCHAR2,
                   X_Primary_Flag                          VARCHAR2,
                   X_Application_Id                        NUMBER,
                   X_Assignment_Number                     VARCHAR2,
                   X_Change_Reason                         VARCHAR2,
                   X_Comment_Id                            NUMBER,
                   X_Date_Probation_End                    DATE,
                   X_Default_Code_Comb_Id                  NUMBER,
                   X_Employment_Category                   VARCHAR2,
                   X_Frequency                             VARCHAR2,
                   X_Internal_Address_Line                 VARCHAR2,
                   X_Manager_Flag                          VARCHAR2,
                   X_Normal_Hours                          NUMBER,
                   X_Perf_Review_Period                    NUMBER,
                   X_Perf_Review_Period_Frequency          VARCHAR2,
                   X_Period_Of_Service_Id                  NUMBER,
                   X_Probation_Period                      NUMBER,
                   X_Probation_Unit                        VARCHAR2,
                   X_Sal_Review_Period                     NUMBER,
                   X_Sal_Review_Period_Frequency           VARCHAR2,
                   X_Set_Of_Books_Id                       NUMBER,
                   X_Source_Type                           VARCHAR2,
                   X_Time_Normal_Finish                    VARCHAR2,
                   X_Time_Normal_Start                     VARCHAR2,
                   X_Ass_Attribute_Category                VARCHAR2,
                   X_Ass_Attribute1                        VARCHAR2,
                   X_Ass_Attribute2                        VARCHAR2,
                   X_Ass_Attribute3                        VARCHAR2,
                   X_Ass_Attribute4                        VARCHAR2,
                   X_Ass_Attribute5                        VARCHAR2,
                   X_Ass_Attribute6                        VARCHAR2,
                   X_Ass_Attribute7                        VARCHAR2,
                   X_Ass_Attribute8                        VARCHAR2,
                   X_Ass_Attribute9                        VARCHAR2,
                   X_Ass_Attribute10                       VARCHAR2,
                   X_Ass_Attribute11                       VARCHAR2,
                   X_Ass_Attribute12                       VARCHAR2,
                   X_Ass_Attribute13                       VARCHAR2,
                   X_Ass_Attribute14                       VARCHAR2,
                   X_Ass_Attribute15                       VARCHAR2,
                   X_Ass_Attribute16                       VARCHAR2,
                   X_Ass_Attribute17                       VARCHAR2,
                   X_Ass_Attribute18                       VARCHAR2,
                   X_Ass_Attribute19                       VARCHAR2,
                   X_Ass_Attribute20                       VARCHAR2,
                   X_Ass_Attribute21                       VARCHAR2,
                   X_Ass_Attribute22                       VARCHAR2,
                   X_Ass_Attribute23                       VARCHAR2,
                   X_Ass_Attribute24                       VARCHAR2,
                   X_Ass_Attribute25                       VARCHAR2,
                   X_Ass_Attribute26                       VARCHAR2,
                   X_Ass_Attribute27                       VARCHAR2,
                   X_Ass_Attribute28                       VARCHAR2,
                   X_Ass_Attribute29                       VARCHAR2,
                   X_Ass_Attribute30                       VARCHAR2,
                   X_Title                                 VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PER_ASSIGNMENTS_F
      WHERE  rowid = X_Rowid
      FOR UPDATE of Assignment_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
        hr_utility.set_location('per_assignments_v7_pkg.lock_row',10);
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
        hr_utility.set_location('per_assignments_v7_pkg.lock_row',20);
  if (
          (   (Recinfo.assignment_id = X_Assignment_Id)
           OR (    (Recinfo.assignment_id IS NULL)
               AND (X_Assignment_Id IS NULL)))
      AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
           OR (    (Recinfo.effective_start_date IS NULL)
               AND (X_Effective_Start_Date IS NULL)))
      AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
           OR (    (Recinfo.effective_end_date IS NULL)
               AND (X_Effective_End_Date IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.recruiter_id = X_Recruiter_Id)
           OR (    (Recinfo.recruiter_id IS NULL)
               AND (X_Recruiter_Id IS NULL)))
      AND (   (Recinfo.grade_id = X_Grade_Id)
           OR (    (Recinfo.grade_id IS NULL)
               AND (X_Grade_Id IS NULL)))
      AND (   (Recinfo.position_id = X_Position_Id)
           OR (    (Recinfo.position_id IS NULL)
               AND (X_Position_Id IS NULL)))
      AND (   (Recinfo.job_id = X_Job_Id)
           OR (    (Recinfo.job_id IS NULL)
               AND (X_Job_Id IS NULL)))
      AND (   (Recinfo.assignment_status_type_id = X_Assignment_Status_Type_Id)
           OR (    (Recinfo.assignment_status_type_id IS NULL)
               AND (X_Assignment_Status_Type_Id IS NULL)))
      AND (   (Recinfo.payroll_id = X_Payroll_Id)
           OR (    (Recinfo.payroll_id IS NULL)
               AND (X_Payroll_Id IS NULL)))
      AND (   (Recinfo.location_id = X_Location_Id)
           OR (    (Recinfo.location_id IS NULL)
               AND (X_Location_Id IS NULL)))
      AND (   (Recinfo.person_referred_by_id = X_Person_Referred_By_Id)
           OR (    (Recinfo.person_referred_by_id IS NULL)
               AND (X_Person_Referred_By_Id IS NULL)))
      AND (   (Recinfo.supervisor_id = X_Supervisor_Id)
           OR (    (Recinfo.supervisor_id IS NULL)
               AND (X_Supervisor_Id IS NULL)))
      AND (   (Recinfo.special_ceiling_step_id = X_Special_Ceiling_Step_Id)
           OR (    (Recinfo.special_ceiling_step_id IS NULL)
               AND (X_Special_Ceiling_Step_Id IS NULL)))
      AND (   (Recinfo.person_id = X_Person_Id)
           OR (    (Recinfo.person_id IS NULL)
               AND (X_Person_Id IS NULL)))
      AND (   (Recinfo.recruitment_activity_id = X_Recruitment_Activity_Id)
           OR (    (Recinfo.recruitment_activity_id IS NULL)
               AND (X_Recruitment_Activity_Id IS NULL)))
      AND (   (Recinfo.source_organization_id = X_Source_Organization_Id)
           OR (    (Recinfo.source_organization_id IS NULL)
               AND (X_Source_Organization_Id IS NULL)))
      AND (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.people_group_id = X_People_Group_Id)
           OR (    (Recinfo.people_group_id IS NULL)
               AND (X_People_Group_Id IS NULL)))
      AND (   (Recinfo.soft_coding_keyflex_id = X_Soft_Coding_Keyflex_Id)
           OR (    (Recinfo.soft_coding_keyflex_id IS NULL)
               AND (X_Soft_Coding_Keyflex_Id IS NULL)))
      AND (   (Recinfo.vacancy_id = X_Vacancy_Id)
           OR (    (Recinfo.vacancy_id IS NULL)
               AND (X_Vacancy_Id IS NULL)))
      AND (   (Recinfo.pay_basis_id = X_Pay_Basis_Id)
           OR (    (Recinfo.pay_basis_id IS NULL)
               AND (X_Pay_Basis_Id IS NULL)))
      AND (   (Recinfo.assignment_sequence = X_Assignment_Sequence)
           OR (    (Recinfo.assignment_sequence IS NULL)
               AND (X_Assignment_Sequence IS NULL)))
      AND (   (Recinfo.assignment_type = X_Assignment_Type)
           OR (    (Recinfo.assignment_type IS NULL)
               AND (X_Assignment_Type IS NULL)))
      AND (   (Recinfo.primary_flag = X_Primary_Flag)
           OR (    (Recinfo.primary_flag IS NULL)
               AND (X_Primary_Flag IS NULL)))
      AND (   (Recinfo.application_id = X_Application_Id)
           OR (    (Recinfo.application_id IS NULL)
               AND (X_Application_Id IS NULL)))
      AND (   (Recinfo.assignment_number = X_Assignment_Number)
           OR (    (Recinfo.assignment_number IS NULL)
               AND (X_Assignment_Number IS NULL)))
      AND (   (Recinfo.change_reason = X_Change_Reason)
           OR (    (Recinfo.change_reason IS NULL)
               AND (X_Change_Reason IS NULL)))
      AND (   (Recinfo.comment_id = X_Comment_Id)
           OR (    (Recinfo.comment_id IS NULL)
               AND (X_Comment_Id IS NULL)))
      AND (   (Recinfo.date_probation_end = X_Date_Probation_End)
           OR (    (Recinfo.date_probation_end IS NULL)
               AND (X_Date_Probation_End IS NULL)))
      AND (   (Recinfo.default_code_comb_id = X_Default_Code_Comb_Id)
           OR (    (Recinfo.default_code_comb_id IS NULL)
               AND (X_Default_Code_Comb_Id IS NULL)))
      AND (   (Recinfo.employment_category = X_Employment_Category)
           OR (    (Recinfo.employment_category IS NULL)
               AND (X_Employment_Category IS NULL)))
      AND (   (Recinfo.frequency = X_Frequency)
           OR (    (Recinfo.frequency IS NULL)
               AND (X_Frequency IS NULL)))
      AND (   (Recinfo.internal_address_line = X_Internal_Address_Line)
           OR (    (Recinfo.internal_address_line IS NULL)
               AND (X_Internal_Address_Line IS NULL)))
      AND (   (Recinfo.manager_flag = X_Manager_Flag)
           OR (    (Recinfo.manager_flag IS NULL)
               AND (X_Manager_Flag IS NULL)))
      AND (   (Recinfo.normal_hours = X_Normal_Hours)
           OR (    (Recinfo.normal_hours IS NULL)
               AND (X_Normal_Hours IS NULL)))
      AND (   (Recinfo.perf_review_period = X_Perf_Review_Period)
           OR (    (Recinfo.perf_review_period IS NULL)
               AND (X_Perf_Review_Period IS NULL)))
      AND (   (Recinfo.perf_review_period_frequency =
                X_Perf_Review_Period_Frequency)
           OR (    (Recinfo.perf_review_period_frequency IS NULL)
               AND (X_Perf_Review_Period_Frequency IS NULL)))
      AND (   (Recinfo.period_of_service_id = X_Period_Of_Service_Id)
           OR (    (Recinfo.period_of_service_id IS NULL)
               AND (X_Period_Of_Service_Id IS NULL)))
      AND (   (Recinfo.probation_period = X_Probation_Period)
           OR (    (Recinfo.probation_period IS NULL)
               AND (X_Probation_Period IS NULL)))
      AND (   (Recinfo.probation_unit = X_Probation_Unit)
           OR (    (Recinfo.probation_unit IS NULL)
               AND (X_Probation_Unit IS NULL)))
      AND (   (Recinfo.sal_review_period = X_Sal_Review_Period)
           OR (    (Recinfo.sal_review_period IS NULL)
               AND (X_Sal_Review_Period IS NULL)))
      AND (   (Recinfo.sal_review_period_frequency =
              X_Sal_Review_Period_Frequency)
           OR (    (Recinfo.sal_review_period_frequency IS NULL)
               AND (X_Sal_Review_Period_Frequency IS NULL)))
      AND (   (Recinfo.set_of_books_id = X_Set_Of_Books_Id)
           OR (    (Recinfo.set_of_books_id IS NULL)
               AND (X_Set_Of_Books_Id IS NULL)))
      AND (   (Recinfo.source_type = X_Source_Type)
           OR (    (Recinfo.source_type IS NULL)
               AND (X_Source_Type IS NULL)))
      AND (   (Recinfo.time_normal_finish = X_Time_Normal_Finish)
           OR (    (Recinfo.time_normal_finish IS NULL)
               AND (X_Time_Normal_Finish IS NULL)))
      AND (   (Recinfo.time_normal_start = X_Time_Normal_Start)
           OR (    (Recinfo.time_normal_start IS NULL)
               AND (X_Time_Normal_Start IS NULL)))
      AND (   (Recinfo.ass_attribute_category = X_Ass_Attribute_Category)
           OR (    (Recinfo.ass_attribute_category IS NULL)
               AND (X_Ass_Attribute_Category IS NULL)))
       )
      then
      if (
          (   (Recinfo.ass_attribute1 = X_Ass_Attribute1)
           OR (    (Recinfo.ass_attribute1 IS NULL)
               AND (X_Ass_Attribute1 IS NULL)))
      AND (   (Recinfo.ass_attribute2 = X_Ass_Attribute2)
           OR (    (Recinfo.ass_attribute2 IS NULL)
               AND (X_Ass_Attribute2 IS NULL)))
      AND (   (Recinfo.ass_attribute3 = X_Ass_Attribute3)
           OR (    (Recinfo.ass_attribute3 IS NULL)
               AND (X_Ass_Attribute3 IS NULL)))
      AND (   (Recinfo.ass_attribute4 = X_Ass_Attribute4)
           OR (    (Recinfo.ass_attribute4 IS NULL)
               AND (X_Ass_Attribute4 IS NULL)))
      AND (   (Recinfo.ass_attribute5 = X_Ass_Attribute5)
           OR (    (Recinfo.ass_attribute5 IS NULL)
               AND (X_Ass_Attribute5 IS NULL)))
      AND (   (Recinfo.ass_attribute6 = X_Ass_Attribute6)
           OR (    (Recinfo.ass_attribute6 IS NULL)
               AND (X_Ass_Attribute6 IS NULL)))
      AND (   (Recinfo.ass_attribute7 = X_Ass_Attribute7)
           OR (    (Recinfo.ass_attribute7 IS NULL)
               AND (X_Ass_Attribute7 IS NULL)))
      AND (   (Recinfo.ass_attribute8 = X_Ass_Attribute8)
           OR (    (Recinfo.ass_attribute8 IS NULL)
               AND (X_Ass_Attribute8 IS NULL)))
      AND (   (Recinfo.ass_attribute9 = X_Ass_Attribute9)
           OR (    (Recinfo.ass_attribute9 IS NULL)
               AND (X_Ass_Attribute9 IS NULL)))
      AND (   (Recinfo.ass_attribute10 = X_Ass_Attribute10)
           OR (    (Recinfo.ass_attribute10 IS NULL)
               AND (X_Ass_Attribute10 IS NULL)))
      AND (   (Recinfo.ass_attribute11 = X_Ass_Attribute11)
           OR (    (Recinfo.ass_attribute11 IS NULL)
               AND (X_Ass_Attribute11 IS NULL)))
      AND (   (Recinfo.ass_attribute12 = X_Ass_Attribute12)
           OR (    (Recinfo.ass_attribute12 IS NULL)
               AND (X_Ass_Attribute12 IS NULL)))
      AND (   (Recinfo.ass_attribute13 = X_Ass_Attribute13)
           OR (    (Recinfo.ass_attribute13 IS NULL)
               AND (X_Ass_Attribute13 IS NULL)))
      AND (   (Recinfo.ass_attribute14 = X_Ass_Attribute14)
           OR (    (Recinfo.ass_attribute14 IS NULL)
               AND (X_Ass_Attribute14 IS NULL)))
      AND (   (Recinfo.ass_attribute15 = X_Ass_Attribute15)
           OR (    (Recinfo.ass_attribute15 IS NULL)
               AND (X_Ass_Attribute15 IS NULL)))
      AND (   (Recinfo.ass_attribute16 = X_Ass_Attribute16)
           OR (    (Recinfo.ass_attribute16 IS NULL)
               AND (X_Ass_Attribute16 IS NULL)))
      AND (   (Recinfo.ass_attribute17 = X_Ass_Attribute17)
           OR (    (Recinfo.ass_attribute17 IS NULL)
               AND (X_Ass_Attribute17 IS NULL)))
      AND (   (Recinfo.ass_attribute18 = X_Ass_Attribute18)
           OR (    (Recinfo.ass_attribute18 IS NULL)
               AND (X_Ass_Attribute18 IS NULL)))
      AND (   (Recinfo.ass_attribute19 = X_Ass_Attribute19)
           OR (    (Recinfo.ass_attribute19 IS NULL)
               AND (X_Ass_Attribute19 IS NULL)))
      AND (   (Recinfo.ass_attribute20 = X_Ass_Attribute20)
           OR (    (Recinfo.ass_attribute20 IS NULL)
               AND (X_Ass_Attribute20 IS NULL)))
      AND (   (Recinfo.ass_attribute21 = X_Ass_Attribute21)
           OR (    (Recinfo.ass_attribute21 IS NULL)
               AND (X_Ass_Attribute21 IS NULL)))
      AND (   (Recinfo.ass_attribute22 = X_Ass_Attribute22)
           OR (    (Recinfo.ass_attribute22 IS NULL)
               AND (X_Ass_Attribute22 IS NULL)))
      AND (   (Recinfo.ass_attribute23 = X_Ass_Attribute23)
           OR (    (Recinfo.ass_attribute23 IS NULL)
               AND (X_Ass_Attribute23 IS NULL)))
      AND (   (Recinfo.ass_attribute24 = X_Ass_Attribute24)
           OR (    (Recinfo.ass_attribute24 IS NULL)
               AND (X_Ass_Attribute24 IS NULL)))
      AND (   (Recinfo.ass_attribute25 = X_Ass_Attribute25)
           OR (    (Recinfo.ass_attribute25 IS NULL)
               AND (X_Ass_Attribute25 IS NULL)))
      AND (   (Recinfo.ass_attribute26 = X_Ass_Attribute26)
           OR (    (Recinfo.ass_attribute26 IS NULL)
               AND (X_Ass_Attribute26 IS NULL)))
      AND (   (Recinfo.ass_attribute27 = X_Ass_Attribute27)
           OR (    (Recinfo.ass_attribute27 IS NULL)
               AND (X_Ass_Attribute27 IS NULL)))
      AND (   (Recinfo.ass_attribute28 = X_Ass_Attribute28)
           OR (    (Recinfo.ass_attribute28 IS NULL)
               AND (X_Ass_Attribute28 IS NULL)))
      AND (   (Recinfo.ass_attribute29 = X_Ass_Attribute29)
           OR (    (Recinfo.ass_attribute29 IS NULL)
               AND (X_Ass_Attribute29 IS NULL)))
      AND (   (Recinfo.ass_attribute30 = X_Ass_Attribute30)
           OR (    (Recinfo.ass_attribute30 IS NULL)
               AND (X_Ass_Attribute30 IS NULL)))
      AND (   (Recinfo.title = X_Title)
           OR (    (Recinfo.title IS NULL)
               AND (X_Title IS NULL)))
          ) then
    return;
   end if;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
        hr_utility.set_location('per_assignments_v7_pkg.lock_row',30);
END Lock_Row;
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
) IS
--
cursor org is
select organization_id
from per_all_assignments_f
where assignment_id=X_Assignment_Id
and X_Effective_Start_Date between effective_start_date
and effective_end_date;
--
l_old_org_id per_all_assignments_f.organization_id%TYPE;
--
BEGIN
        hr_utility.set_location('per_assignments_v7_pkg.update_row',10);
  if X_Current_application_id = 810
  then
        hr_utility.set_location('per_assignments_v7_pkg.update_row',20);
    per_assignments_v7_pkg.get_future_changes(X_assignment_id
                      ,X_effective_start_date
                      ,X_Current_application_id);
        hr_utility.set_location('per_assignments_v7_pkg.update_row',30);
  end if;
--
-- get the current organization
--
  open org;
  fetch org into l_old_org_id;
  if org%NOTFOUND then
    close org;
  else
        hr_utility.set_location('per_assignments_v7_pkg.update_row',40);
    close org;
  end if;
--
        hr_utility.set_location('per_assignments_v7_pkg.update_row',50);
  UPDATE PER_ASSIGNMENTS_F
  SET
    assignment_id                             =    X_Assignment_Id,
    effective_start_date                      =    X_Effective_Start_Date,
    effective_end_date                        =    X_Effective_End_Date,
    business_group_id                         =    X_Business_Group_Id,
    recruiter_id                              =    X_Recruiter_Id,
    grade_id                                  =    X_Grade_Id,
    position_id                               =    X_Position_Id,
    job_id                                    =    X_Job_Id,
    assignment_status_type_id                 =    X_Assignment_Status_Type_Id,
    payroll_id                                =    X_Payroll_Id,
    location_id                               =    X_Location_Id,
    person_referred_by_id                     =    X_Person_Referred_By_Id,
    supervisor_id                             =    X_Supervisor_Id,
    special_ceiling_step_id                   =    X_Special_Ceiling_Step_Id,
    person_id                                 =    X_Person_Id,
    recruitment_activity_id                   =    X_Recruitment_Activity_Id,
    source_organization_id                    =    X_Source_Organization_Id,
    organization_id                           =    X_Organization_Id,
    people_group_id                           =    X_People_Group_Id,
    soft_coding_keyflex_id                    =    X_Soft_Coding_Keyflex_Id,
    vacancy_id                                =    X_Vacancy_Id,
    pay_basis_id                              =    X_Pay_Basis_Id,
    assignment_sequence                       =    X_Assignment_Sequence,
    assignment_type                           =    X_Assignment_Type,
    primary_flag                              =    X_Primary_Flag,
    application_id                            =    X_Application_Id,
    assignment_number                         =    X_Assignment_Number,
    change_reason                             =    X_Change_Reason,
    comment_id                                =    X_Comment_Id,
    date_probation_end                        =    X_Date_Probation_End,
    default_code_comb_id                      =    X_Default_Code_Comb_Id,
    employment_category                       =    X_Employment_Category,
    frequency                                 =    X_Frequency,
    internal_address_line                     =    X_Internal_Address_Line,
    manager_flag                              =    X_Manager_Flag,
    normal_hours                              =    X_Normal_Hours,
    perf_review_period                        =    X_Perf_Review_Period,
    perf_review_period_frequency              =    X_Perf_Review_Period_Frequency,
    period_of_service_id                      =    X_Period_Of_Service_Id,
    probation_period                          =    X_Probation_Period,
    probation_unit                            =    X_Probation_Unit,
    sal_review_period                         =    X_Sal_Review_Period,
    sal_review_period_frequency               =    X_Sal_Review_Period_Frequency
,
    set_of_books_id                           =    X_Set_Of_Books_Id,
    source_type                               =    X_Source_Type,
    time_normal_finish                        =    X_Time_Normal_Finish,
    time_normal_start                         =    X_Time_Normal_Start,
    ass_attribute_category                    =    X_Ass_Attribute_Category,
    ass_attribute1                            =    X_Ass_Attribute1,
    ass_attribute2                            =    X_Ass_Attribute2,
    ass_attribute3                            =    X_Ass_Attribute3,
    ass_attribute4                            =    X_Ass_Attribute4,
    ass_attribute5                            =    X_Ass_Attribute5,
    ass_attribute6                            =    X_Ass_Attribute6,
    ass_attribute7                            =    X_Ass_Attribute7,
    ass_attribute8                            =    X_Ass_Attribute8,
    ass_attribute9                            =    X_Ass_Attribute9,
    ass_attribute10                           =    X_Ass_Attribute10,
    ass_attribute11                           =    X_Ass_Attribute11,
    ass_attribute12                           =    X_Ass_Attribute12,
    ass_attribute13                           =    X_Ass_Attribute13,
    ass_attribute14                           =    X_Ass_Attribute14,
    ass_attribute15                           =    X_Ass_Attribute15,
    ass_attribute16                           =    X_Ass_Attribute16,
    ass_attribute17                           =    X_Ass_Attribute17,
    ass_attribute18                           =    X_Ass_Attribute18,
    ass_attribute19                           =    X_Ass_Attribute19,
    ass_attribute20                           =    X_Ass_Attribute20,
    ass_attribute21                           =    X_Ass_Attribute21,
    ass_attribute22                           =    X_Ass_Attribute22,
    ass_attribute23                           =    X_Ass_Attribute23,
    ass_attribute24                           =    X_Ass_Attribute24,
    ass_attribute25                           =    X_Ass_Attribute25,
    ass_attribute26                           =    X_Ass_Attribute26,
    ass_attribute27                           =    X_Ass_Attribute27,
    ass_attribute28                           =    X_Ass_Attribute28,
    ass_attribute29                           =    X_Ass_Attribute29,
    ass_attribute30                           =    X_Ass_Attribute30,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    title                                     =    X_Title
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
        hr_utility.set_location('per_assignments_v7_pkg.update_row',60);
  --
  -- update the security lists
  --
  if (l_old_org_id = X_Business_Group_Id
  and X_Organization_Id <> X_Business_Group_Id) then
                 hr_utility.set_location('per_assignments_v7_pkg.update_row',70);
    hr_security_internal.clear_from_person_list(X_Person_Id);
  end if;
                 hr_utility.set_location('per_assignments_v7_pkg.update_row',80);
  --2468956: change the date from sysdate to x_effective_start_date in following
  hr_security_internal.add_to_person_list(X_Effective_Start_Date,X_Assignment_Id);
                 hr_utility.set_location('per_assignments_v7_pkg.update_row',90);
  --
END Update_Row;
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
        hr_utility.set_location('per_assignments_v7_pkg.delete_row',10);
  DELETE FROM PER_ASSIGNMENTS_F
  WHERE  rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
        hr_utility.set_location('per_assignments_v7_pkg.delete_row',20);
END Delete_Row;
--
PROCEDURE get_location_address (X_location_id        NUMBER
                               ,X_Address_Line_1     IN OUT NOCOPY VARCHAR2
                               ,X_Address_Line_2     IN OUT NOCOPY VARCHAR2
                               ,X_Address_Line_3     IN OUT NOCOPY VARCHAR2
			       ,X_Bill_to_site_flag  IN OUT NOCOPY VARCHAR2
                               ,X_Country            IN OUT NOCOPY VARCHAR2
			       ,X_Description	     IN OUT NOCOPY VARCHAR2
			       ,X_Designated_receiver_id    IN OUT NOCOPY NUMBER
			       ,X_In_organization_flag	    IN OUT NOCOPY VARCHAR2
			       ,X_Inactive_date	     IN OUT NOCOPY DATE
			       ,X_Inventory_organization_id IN OUT NOCOPY NUMBER
			       ,X_Office_site_flag   IN OUT NOCOPY VARCHAR2
                               ,X_Postal_Code        IN OUT NOCOPY VARCHAR2
			       ,X_Receiving_site_flag IN OUT NOCOPY VARCHAR2
                               ,X_Region_1           IN OUT NOCOPY VARCHAR2
                               ,X_Region_2           IN OUT NOCOPY VARCHAR2
                               ,X_Region_3           IN OUT NOCOPY VARCHAR2
			       ,X_Ship_to_location_id IN OUT NOCOPY NUMBER
			       ,X_Ship_to_site_flag   IN OUT NOCOPY VARCHAR2
                               ,X_Style              IN OUT NOCOPY VARCHAR2
			       ,X_Tax_name	     IN OUT NOCOPY VARCHAR2
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
                               ,X_Attribute20        IN OUT NOCOPY VARCHAR2)
IS
cursor location
IS
select Address_Line_1
       ,Address_Line_2
       ,Address_Line_3
       ,bill_to_site_flag
       ,Country
       ,Description
       ,Designated_receiver_id
       ,In_organization_flag
       ,Inactive_date
       ,Inventory_organization_id
       ,Office_site_flag
       ,Postal_Code
       ,Receiving_site_flag
       ,Region_1
       ,Region_2
       ,Region_3
       ,Ship_to_location_id
       ,Ship_to_site_flag
       ,Style
       ,Tax_name
       ,Telephone_number_1
       ,Telephone_number_2
       ,Telephone_number_3
       ,Town_or_city
       ,Attribute_category
       ,Attribute1
       ,Attribute2
       ,Attribute3
       ,Attribute4
       ,Attribute5
       ,Attribute6
       ,Attribute7
       ,Attribute8
       ,Attribute9
       ,Attribute10
       ,Attribute11
       ,Attribute12
       ,Attribute13
       ,Attribute14
       ,Attribute15
       ,Attribute16
       ,Attribute17
       ,Attribute18
       ,Attribute19
       ,Attribute20
from hr_locations
where location_id = X_location_id;
--
BEGIN
  open location;
  fetch location into  X_Address_Line_1
                       ,X_Address_Line_2
                       ,X_Address_Line_3
		       ,X_Bill_to_site_flag
                       ,X_Country
		       ,X_Description
		       ,X_Designated_receiver_id
		       ,X_In_organization_flag
		       ,X_Inactive_date
		       ,X_Inventory_organization_id
		       ,X_Office_site_flag
                       ,X_Postal_Code
		       ,X_Receiving_site_flag
                       ,X_Region_1
                       ,X_Region_2
                       ,X_Region_3
		       ,X_Ship_to_location_id
		       ,X_Ship_to_site_flag
                       ,X_Style
		       ,X_Tax_name
                       ,X_Telephone_number_1
                       ,X_Telephone_number_2
                       ,X_Telephone_number_3
                       ,X_Town_or_city
                       ,X_Attribute_category
                       ,X_Attribute1
                       ,X_Attribute2
                       ,X_Attribute3
                       ,X_Attribute4
                       ,X_Attribute5
                       ,X_Attribute6
                       ,X_Attribute7
                       ,X_Attribute8
                       ,X_Attribute9
                       ,X_Attribute10
                       ,X_Attribute11
                       ,X_Attribute12
                       ,X_Attribute13
                       ,X_Attribute14
                       ,X_Attribute15
                       ,X_Attribute16
                       ,X_Attribute17
                       ,X_Attribute18
                       ,X_Attribute19
                       ,X_Attribute20;
  close location;
END;
-- Added the parameter X_eff_dt for the bug 6817459
procedure check_primary(X_person_id NUMBER
			,X_eff_dt  date default sysdate
			,X_primary_flag IN OUT NOCOPY VARCHAR2)
IS
cursor primary_exists
is
select 'Y'
from  sys.dual
where exists (select 1 from
				  per_assignments_f
				  where person_id =X_person_id
				  and   X_eff_dt between effective_start_date
				  and    effective_end_date);
--
l_dummy VARCHAR2(1);
begin
  open primary_exists;
  fetch primary_exists into l_dummy;
  if primary_exists%found
  then
		X_primary_flag := 'N';
  else
		X_primary_flag := 'Y';
    end if;
  close primary_exists;
end;
--
procedure get_previous_changes(X_assignment_id NUMBER
                              ,X_effective_start_date DATE
                              ,X_current_application_id NUMBER DEFAULT NULL) is
--
cursor get_previous_changes is
select 'Y'
from   per_assignments_f p
where  p.effective_start_date < x_effective_start_date
and    p.effective_end_date <> hr_general.end_of_time
and    p.assignment_id = x_assignment_id
and    p.effective_start_date = (select max(p1.effective_start_date)
											from per_assignments_f p1
											where p1.assignment_id = p.assignment_id);
--
l_dummy VARCHAR2(1);
--
begin
    hr_utility.set_location('Entering: get_previous_changes',10);
    open get_previous_changes;
    fetch get_previous_changes into l_dummy;
    if get_previous_changes%found
    then
      close get_previous_changes;
      fnd_message.set_name('PER','HR_6839_EMP_REF_DATE_CHG');
      app_exception.raise_exception;
    end if;
    close get_previous_changes;
    hr_utility.set_location('Leaving: get_previous_changes',20);
end;
--
procedure get_future_changes (x_assignment_id NUMBER
                             ,x_effective_start_date DATE
                             ,x_current_application_id NUMBER DEFAULT NULL) is
cursor get_future_changes is
select 'Y'
from   per_assignments_f p
where  trunc(p.effective_start_date) > trunc(x_effective_start_date) -- #1862029
and    p.assignment_id = x_assignment_id;
--
l_dummy VARCHAR2(1);
--
begin
    open get_future_changes;
    fetch get_future_changes into l_dummy;
    if get_future_changes%found
    then
      -- VT 09/22/99 #999960 there is no need to check for Oracle Project
      -- #1394091
--      if nvl(x_current_application_id,0) <> 275 then
        close get_future_changes;
        fnd_message.set_name('PER','HR_7510_PER_FUT_CHANGE');
        app_exception.raise_exception;
--      end if;
      --
    end if;
    close get_future_changes;
end;
END PER_ASSIGNMENTS_V7_PKG;

/
