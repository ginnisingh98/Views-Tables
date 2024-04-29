--------------------------------------------------------
--  DDL for Package Body PER_ASSIGNMENTS_V8_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASSIGNMENTS_V8_PKG" as
/* $Header: peasg08t.pkb 120.1 2006/01/23 06:35:44 eumenyio noship $ */
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
 ) IS
   --
   -- Cursor to get rest of the fields not used/required by PA but
   -- which may have had values added by other apps and therfore preserve them
   -- for these other APPS.
   --
   CURSOR C0 is select * from per_assignments_f
                where rowid = X_ROWID;
--
   --
   -- Get the rowid effective as of start date
   -- May not necessarily be one if EFS appears between another record.
   --
   CURSOR C IS SELECT rowid FROM PER_ASSIGNMENTS_F
             WHERE assignment_id = X_Assignment_Id
             and effective_start_date = X_effective_start_date
             for update of assignment_id;
   --
   --
   -- Cursor to ensure the Assignment was entered.
   --
   CURSOR C2 is
   select rowid
   from per_assignments_f
   where assignment_id = X_ASSIGNMENT_ID
   and   effective_start_Date = X_EFFECTIVE_START_DATE
   and   effective_end_date = X_EFFECTIVE_END_DATE;
   --
   --
   -- Update any records that exist between start and
   -- end of the new assignment.
   --
   CURSOR C3 is select rowid from per_assignments_f
                where rowid <> X_ROWID
                and   effective_end_date between
                  X_EFFECTIVE_START_DATE
                 and X_EFFECTIVE_END_DATE
                and assignment_id = X_ASSIGNMENT_ID
                for update of assignment_id;
   --
   ass_rec c0%ROWTYPE;
   asg_rec c3%ROWTYPE;
   l_sql_count NUMBER :=0;
   --
BEGIN
  if X_ROWID is not null
  then
    open C0;
    fetch c0 into ass_rec;
    if C0%NOTFOUND
    then
      raise NO_DATA_FOUND;
    end if;
    close C0;
  end if;
  --
  open C;
  fetch C into X_Rowid;
  if C%FOUND
  then
    per_assignments_v8_pkg.delete_record(X_ROWID);
  end if;
  --

  hr_utility.set_location('Enterring:per_assignments_v8_pkg.insert_row',10);

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
          ass_rec.Recruiter_Id,
          ass_rec.Grade_Id,
          X_Position_Id,  -- ass_rec.Position_Id,
          X_Job_Id,
          X_Assignment_Status_Type_Id,
          ass_rec.Payroll_Id,
          X_Location_Id,
          ass_rec.Person_Referred_By_Id,
          X_Supervisor_Id,
          ass_rec.Special_Ceiling_Step_Id,
          X_Person_Id,
          ass_rec.Recruitment_Activity_Id,
          ass_rec.Source_Organization_Id,
          X_Organization_Id,
          ass_rec.People_Group_Id,
          ass_rec.Soft_Coding_Keyflex_Id,
          ass_rec.Vacancy_Id,
          ass_rec.Pay_Basis_Id,
          X_Assignment_Sequence,
          X_Assignment_Type,
          X_Primary_Flag,
          ass_rec.Application_Id,
          X_Assignment_Number,
          ass_rec.Change_Reason,
          X_Comment_Id,
          ass_rec.Date_Probation_End,
          X_Default_Code_Comb_Id, --ass_rec.Default_Code_Comb_Id,
          ass_rec.Employment_Category,
          ass_rec.Frequency,
          ass_rec.Internal_Address_Line,
          ass_rec.Manager_Flag,
          ass_rec.Normal_Hours,
          ass_rec.Perf_Review_Period,
          ass_rec.Perf_Review_Period_Frequency,
          X_Period_Of_Service_Id,
          ass_rec.Probation_Period,
          ass_rec.Probation_Unit,
          ass_rec.Sal_Review_Period,
          ass_rec.Sal_Review_Period_Frequency,
          X_Set_Of_Books_Id,
          ass_rec.Source_Type,
          ass_rec.Time_Normal_Finish,
          ass_rec.Time_Normal_Start,
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
  open c2;
  fetch c2 into X_ROWID;
  if c2%notfound
  then
    raise NO_DATA_FOUND;
  end if;
  close c2;
  --
  open c3;
  fetch c3 into asg_rec;
  while c3%found loop
    UPDATE PER_ASSIGNMENTS_F
    SET EFFECTIVE_END_DATE = X_EFFECTIVE_START_DATE - 1,
      LAST_UPDATED_BY    = X_LAST_UPDATED_BY,
      LAST_UPDATE_DATE   = X_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN  = X_LAST_UPDATE_LOGIN
    WHERE CURRENT OF c3;
    l_sql_count := l_sql_count + SQL%ROWCOUNT;
    fetch c3 into asg_rec;
  end loop;
  --
  -- If the rows do not tally raise an exception.
  --
  if c3%ROWCOUNT < l_sql_count then
    raise NO_DATA_FOUND;
  end if;
  close c3;
END Insert_Row;
--
-- overload
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
 ) IS
l_position_id NUMBER;
BEGIN
    Insert_Row(X_Rowid                        ,
                     X_Assignment_Id                ,
                     X_Effective_Start_Date         ,
                     X_Effective_End_Date           ,
                     X_Business_Group_Id            ,
                     X_Job_Id                       ,
                     l_Position_Id                  ,
                     X_Assignment_Status_Type_Id    ,
                     X_Person_Id                    ,
                     X_Organization_Id              ,
                     X_Assignment_Sequence          ,
                     X_Assignment_Type              ,
                     X_Primary_Flag                 ,
                     X_Assignment_Number            ,
                     X_Comment_Id                   ,
                     X_Period_Of_Service_Id         ,
                     X_Default_Code_Comb_Id         ,
                     X_Set_Of_Books_Id              ,
                     X_Location_Id                  ,
                     X_Supervisor_Id                ,
                     X_Ass_Attribute_Category       ,
                     X_Ass_Attribute1               ,
                     X_Ass_Attribute2               ,
                     X_Ass_Attribute3               ,
                     X_Ass_Attribute4               ,
                     X_Ass_Attribute5               ,
                     X_Ass_Attribute6               ,
                     X_Ass_Attribute7               ,
                     X_Ass_Attribute8               ,
                     X_Ass_Attribute9               ,
                     X_Ass_Attribute10              ,
                     X_Ass_Attribute11              ,
                     X_Ass_Attribute12              ,
                     X_Ass_Attribute13              ,
                     X_Ass_Attribute14              ,
                     X_Ass_Attribute15              ,
                     X_Ass_Attribute16              ,
                     X_Ass_Attribute17              ,
                     X_Ass_Attribute18              ,
                     X_Ass_Attribute19              ,
                     X_Ass_Attribute20              ,
                     X_Ass_Attribute21              ,
                     X_Ass_Attribute22              ,
                     X_Ass_Attribute23              ,
                     X_Ass_Attribute24              ,
                     X_Ass_Attribute25              ,
                     X_Ass_Attribute26              ,
                     X_Ass_Attribute27              ,
                     X_Ass_Attribute28              ,
                     X_Ass_Attribute29              ,
                     X_Ass_Attribute30              ,
                     X_Last_Update_Date             ,
                     X_Last_Updated_By              ,
                     X_Last_Update_Login            ,
                     X_Created_By                   ,
                     X_Creation_Date                ,
                     X_Title);
END Insert_Row;
--
procedure delete_record(p_rowid VARCHAR2) is
begin
  delete from per_assignments_f
  where rowid = chartorowid(p_rowid);
end;
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
                     ,p_location_code                     IN OUT NOCOPY  VARCHAR2
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
                     ,p_warning_message                   IN OUT NOCOPY  VARCHAR2)
IS
--
-- Get tthe assignment whose effective_start_date is equal to the date
-- entered by the user.
--
-- Changed 02-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked position requirement
--
cursor get_asg_of_start_date
IS
SELECT NVL(p_ORGANIZATION_NAME, PO.NAME) ORGANIZATION_NAME,
       NVL(p_ORGANIZATION_ID, PO.ORGANIZATION_ID) ORGANIZATION_ID,
       NVL(p_JOB_NAME, PJ.NAME) JOB_NAME,
       NVL(p_JOB_ID,PJ.JOB_ID) JOB_ID,
       NVL(p_POSITION_NAME, PP.NAME) POSITION_NAME,
       NVL(p_POSITION_ID,PP.POSITION_ID) POSITION_ID,
       PAS.EFFECTIVE_END_DATE,
       PAS.ASSIGNMENT_ID,
       PAS.ASSIGNMENT_STATUS_TYPE_ID,
       PAS.BUSINESS_GROUP_ID,
       PAS.ASSIGNMENT_TYPE,
       PAS.PRIMARY_FLAG,
       PAS.COMMENT_ID,
       PAS.ASSIGNMENT_SEQUENCE,
       PAS.ASSIGNMENT_NUMBER,
       PAS.PERIOD_OF_SERVICE_ID,
       PAS.SET_OF_BOOKS_ID,
       LOC.LOCATION_CODE,
       PAS.LOCATION_ID,
       PER.FULL_NAME SUPERVISOR_NAME,
       PAS.TITLE,
       PAS.SUPERVISOR_ID,
       PAS.ASS_ATTRIBUTE_CATEGORY,
       PAS.ASS_ATTRIBUTE1,
       PAS.ASS_ATTRIBUTE2,
       PAS.ASS_ATTRIBUTE3,
       PAS.ASS_ATTRIBUTE4,
       PAS.ASS_ATTRIBUTE5,
       PAS.ASS_ATTRIBUTE6,
       PAS.ASS_ATTRIBUTE7,
       PAS.ASS_ATTRIBUTE8,
       PAS.ASS_ATTRIBUTE9,
       PAS.ASS_ATTRIBUTE10,
       PAS.ASS_ATTRIBUTE11,
       PAS.ASS_ATTRIBUTE12,
       PAS.ASS_ATTRIBUTE13,
       PAS.ASS_ATTRIBUTE14,
       PAS.ASS_ATTRIBUTE15,
       PAS.ASS_ATTRIBUTE16,
       PAS.ASS_ATTRIBUTE17,
       PAS.ASS_ATTRIBUTE18,
       PAS.ASS_ATTRIBUTE19,
       PAS.ASS_ATTRIBUTE20,
       PAS.ASS_ATTRIBUTE21,
       PAS.ASS_ATTRIBUTE22,
       PAS.ASS_ATTRIBUTE23,
       PAS.ASS_ATTRIBUTE24,
       PAS.ASS_ATTRIBUTE25,
       PAS.ASS_ATTRIBUTE26,
       PAS.ASS_ATTRIBUTE27,
       PAS.ASS_ATTRIBUTE28,
       PAS.ASS_ATTRIBUTE29,
       PAS.ASS_ATTRIBUTE30,
       PAS.EFFECTIVE_START_DATE
FROM PER_ALL_PEOPLE_F PER,
     PER_JOBS_V PJ,
     HR_POSITIONS_F PP,
     HR_LOCATIONS LOC,
     PER_ORGANIZATION_UNITS_PERF PO,
     PER_ASSIGNMENTS_F PAS
WHERE  PJ.JOB_ID(+) = PAS.JOB_ID
AND    PP.POSITION_ID(+) = PAS.POSITION_ID
AND    PP.JOB_ID(+) = PAS.JOB_ID
AND    PAS.ORGANIZATION_ID = PO.ORGANIZATION_ID
AND    LOC.LOCATION_ID (+) = PAS.LOCATION_ID
AND    PER.PERSON_ID (+) = PAS.SUPERVISOR_ID
AND    PAS.EFFECTIVE_START_DATE
     between PP.EFFECTIVE_START_DATE
      and PP.EFFECTIVE_END_DATE
AND    PAS.EFFECTIVE_START_DATE
     between nvl(PER.EFFECTIVE_START_DATE,PAS.EFFECTIVE_START_DATE)
      and PAS.EFFECTIVE_END_DATE
AND    PAS.PERSON_ID = p_person_id
AND    PAS.ASSIGNMENT_ID    = p_assignment_ID
AND    PAS.EFFECTIVE_START_DATE = p_effective_start_date
AND    PAS.PERIOD_OF_SERVICE_ID = p_period_of_service_id;
--
-- Get the minimum ene date for the current assignment
-- where a row exists after the date entered.
--
cursor get_minimum_end
IS
SELECT MIN(EFFECTIVE_START_DATE) - 1
FROM   PER_ASSIGNMENTS_F
WHERE  EFFECTIVE_START_DATE >
        p_EFFECTIVE_START_DATE
AND    PERSON_ID = p_PERSON_ID
and    assignment_id =p_assignment_id
and    period_of_service_id = p_period_of_service_id;
--
-- Get the minimum effective end date
-- where the effective end date is greater than the
-- current start.
--
cursor get_end_date
IS
SELECT MIN(EFFECTIVE_END_DATE)
FROM   PER_ASSIGNMENTS_F
WHERE  EFFECTIVE_END_DATE >
        p_effective_start_date
AND    PERSON_ID = p_person_id
and    assignment_id =p_assignment_id
and    period_of_service_id = p_period_of_service_id;
--
-- Get's the row which exists aroun the date entered
-- if none exists then get the first row
--
-- Changed 02-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked position requirement
--
-- #2720080: added effective date parameter, and removed UNION statement.
--
cursor get_row_between(p_effective_date DATE)
IS
SELECT NVL(p_ORGANIZATION_NAME, PO.NAME) ORGANIZATION_NAME,
       NVL(p_ORGANIZATION_ID, PO.ORGANIZATION_ID) ORGANIZATION_ID,
       NVL(p_JOB_NAME, PJ.NAME) JOB_NAME,
       NVL(p_JOB_ID,PJ.JOB_ID) JOB_ID,
       NVL(p_POSITION_NAME, PP.NAME) POSITION_NAME,
       NVL(p_POSITION_ID,PP.POSITION_ID) POSITION_ID,
       PAS.EFFECTIVE_END_DATE,
       PAS.ASSIGNMENT_ID,
       PAS.ASSIGNMENT_STATUS_TYPE_ID,
       PAS.BUSINESS_GROUP_ID,
       PAS.ASSIGNMENT_TYPE,
       PAS.PRIMARY_FLAG,
       PAS.COMMENT_ID,
       PAS.ASSIGNMENT_SEQUENCE,
       PAS.ASSIGNMENT_NUMBER,
       PAS.PERIOD_OF_SERVICE_ID,
       PAS.SET_OF_BOOKS_ID,
       LOC.LOCATION_CODE,
       PAS.LOCATION_ID,
       PER.FULL_NAME SUPERVISOR_NAME,
       PAS.TITLE,
       PAS.SUPERVISOR_ID,
       PAS.ASS_ATTRIBUTE_CATEGORY,
       PAS.ASS_ATTRIBUTE1,
       PAS.ASS_ATTRIBUTE2,
       PAS.ASS_ATTRIBUTE3,
       PAS.ASS_ATTRIBUTE4,
       PAS.ASS_ATTRIBUTE5,
       PAS.ASS_ATTRIBUTE6,
       PAS.ASS_ATTRIBUTE7,
       PAS.ASS_ATTRIBUTE8,
       PAS.ASS_ATTRIBUTE9,
       PAS.ASS_ATTRIBUTE10,
       PAS.ASS_ATTRIBUTE11,
       PAS.ASS_ATTRIBUTE12,
       PAS.ASS_ATTRIBUTE13,
       PAS.ASS_ATTRIBUTE14,
       PAS.ASS_ATTRIBUTE15,
       PAS.ASS_ATTRIBUTE16,
       PAS.ASS_ATTRIBUTE17,
       PAS.ASS_ATTRIBUTE18,
       PAS.ASS_ATTRIBUTE19,
       PAS.ASS_ATTRIBUTE20,
       PAS.ASS_ATTRIBUTE21,
       PAS.ASS_ATTRIBUTE22,
       PAS.ASS_ATTRIBUTE23,
       PAS.ASS_ATTRIBUTE24,
       PAS.ASS_ATTRIBUTE25,
       PAS.ASS_ATTRIBUTE26,
       PAS.ASS_ATTRIBUTE27,
       PAS.ASS_ATTRIBUTE28,
       PAS.ASS_ATTRIBUTE29,
       PAS.ASS_ATTRIBUTE30,
       PAS.EFFECTIVE_START_DATE
FROM PER_PEOPLE_F PER,
     PER_JOBS_V PJ,
     HR_POSITIONS_F PP,
     HR_LOCATIONS LOC,
     PER_ORGANIZATION_UNITS_PERF PO,
     PER_ASSIGNMENTS_F PAS
WHERE
      PAS.JOB_ID = PJ.JOB_ID (+)
AND   PP.POSITION_ID(+) = PAS.POSITION_ID
AND   PP.JOB_ID(+) = PAS.JOB_ID
AND   PAS.ORGANIZATION_ID = PO.ORGANIZATION_ID
AND   PAS.PERSON_ID = p_person_id
AND   LOC.LOCATION_ID (+) = PAS.LOCATION_ID
--
AND   PER.PERSON_ID (+) = PAS.SUPERVISOR_ID
AND   p_effective_date between PER.effective_start_date(+) and PER.effective_end_date(+)
--
AND    PAS.EFFECTIVE_START_DATE
     between PP.EFFECTIVE_START_DATE(+)    -- #2720080
      and PP.EFFECTIVE_END_DATE(+)
--
AND   PAS.ASSIGNMENT_ID    = p_assignment_ID
AND   p_effective_start_date BETWEEN
      PAS.EFFECTIVE_START_DATE AND PAS.EFFECTIVE_END_DATE
AND   PAS.PERIOD_OF_SERVICE_ID = p_period_of_service_id;
--
ass_rec get_asg_of_start_date%rowtype;
l_effective_date  date; --#2720080
--
begin
  --
  -- check the date is valid.
  --
  per_assignments_v8_pkg.validate_effective_start(p_effective_start_date
                                                 ,p_person_id
                                                 ,p_period_of_service_id);
  open get_asg_of_start_date;
  fetch  get_asg_of_start_date into ass_rec;
 --
 -- If record is found , then display warning message
 -- otherwise open secondary cursor.
 --
  if get_asg_of_start_date%FOUND
  then
    p_warning_message := 'Y';
    p_effective_end_Date := ass_rec.effective_end_Date;
    fnd_message.set_name('PA','PA_SU_DUP_ASSIGNMENT');
  else
  --
  --
    close get_asg_of_start_date;
  --
    open get_minimum_end;
    fetch get_minimum_end into p_effective_end_date;
    close get_minimum_end;
  --
    if p_effective_end_date is null
    then
      open get_end_date;
      fetch get_end_date into p_effective_end_date;
      close get_end_date;
    end if;
 --
    -- #2720080: needs to get greatest of sysdate or new effective start date
    -- this is to ensure supervisor_LOV does not fail when defaulting value.
    --
    if sysdate > p_effective_start_date then
      l_effective_date := sysdate;
    else
      l_effective_date := p_effective_start_date;
    end if;
    --
    open get_row_between(l_effective_date);
    fetch get_row_between into ass_rec;
    close get_row_between;
  end if;
 --
  p_assignment_id := ass_rec.assignment_id;
  p_business_group_id := ass_rec.business_group_id;
  p_job_id := ass_rec.job_id;
  p_job_name := ass_rec.job_name;
  p_position_id := ass_rec.position_id;
  p_position_name := ass_rec.position_name;
  p_organization_id := ass_rec.organization_id;
  p_organization_name := ass_rec.organization_name;
  p_assignment_sequence := ass_rec.assignment_sequence;
  p_assignment_status_type_id := ass_rec.assignment_status_type_id;
  p_assignment_type := ass_rec.assignment_type;
  p_primary_flag := ass_rec.primary_flag;
  p_comment_id := ass_rec.comment_id;
  p_set_of_books_id := ass_rec.set_of_books_id;
  p_supervisor_name := ass_rec.supervisor_name;
  p_supervisor_id := ass_rec.supervisor_id;
  p_location_code := ass_rec.location_code;
  p_location_id := ass_rec.location_id;
  p_title := ass_rec.title;
  p_ass_attribute_category := ass_rec.ass_attribute_category;
  p_ass_attribute1 := ass_rec.ass_attribute1;
  p_ass_attribute2 := ass_rec.ass_attribute2;
  p_ass_attribute3 := ass_rec.ass_attribute3;
  p_ass_attribute4 := ass_rec.ass_attribute4;
  p_ass_attribute5 := ass_rec.ass_attribute5;
  p_ass_attribute6 := ass_rec.ass_attribute6;
  p_ass_attribute7 := ass_rec.ass_attribute7;
  p_ass_attribute8 := ass_rec.ass_attribute8;
  p_ass_attribute9 := ass_rec.ass_attribute9;
  p_ass_attribute10 := ass_rec.ass_attribute10;
  p_ass_attribute11 := ass_rec.ass_attribute11;
  p_ass_attribute12 := ass_rec.ass_attribute12;
  p_ass_attribute13 := ass_rec.ass_attribute13;
  p_ass_attribute14 := ass_rec.ass_attribute14;
  p_ass_attribute15 := ass_rec.ass_attribute15;
  p_ass_attribute16 := ass_rec.ass_attribute16;
  p_ass_attribute17 := ass_rec.ass_attribute17;
  p_ass_attribute18 := ass_rec.ass_attribute18;
  p_ass_attribute19 := ass_rec.ass_attribute19;
  p_ass_attribute20 := ass_rec.ass_attribute20;
  p_ass_attribute21 := ass_rec.ass_attribute21;
  p_ass_attribute22 := ass_rec.ass_attribute22;
  p_ass_attribute23 := ass_rec.ass_attribute23;
  p_ass_attribute24 := ass_rec.ass_attribute24;
  p_ass_attribute25 := ass_rec.ass_attribute25;
  p_ass_attribute26 := ass_rec.ass_attribute26;
  p_ass_attribute27 := ass_rec.ass_attribute27;
  p_ass_attribute28 := ass_rec.ass_attribute28;
  p_ass_attribute29 := ass_rec.ass_attribute29;
  p_ass_attribute30 := ass_rec.ass_attribute30;
  if p_effective_end_date is null
  then
    p_effective_end_date := ass_rec.effective_end_date;
  end if;
end;
--
-- overload
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
                     ,p_location_code                     IN OUT NOCOPY  VARCHAR2
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
                     ,p_warning_message                   IN OUT NOCOPY  VARCHAR2)
IS
--
l_position_name VARCHAR2(30);
l_position_id NUMBER;
BEGIN
     get_enddate_and_defaults(p_effective_start_date
                     ,p_job_name
                     ,p_job_id
                     ,l_position_name
                     ,l_position_id
                     ,p_organization_name
                     ,p_organization_id
                     ,p_Assignment_Id
                     ,p_Effective_End_Date
                     ,p_Business_Group_Id
                     ,p_Assignment_Status_Type_Id
                     ,p_Person_Id
                     ,p_Period_of_service_id
                     ,p_Assignment_Sequence
                     ,p_Assignment_Type
                     ,p_Primary_Flag
                     ,p_Assignment_Number
                     ,p_Comment_Id
                     ,p_Set_Of_Books_Id
                     ,p_location_code
                     ,p_Location_Id
                     ,p_Supervisor_name
                     ,p_Supervisor_Id
                     ,p_Title
                     ,p_Ass_Attribute_Category
                     ,p_Ass_Attribute1
                     ,p_Ass_Attribute2
                     ,p_Ass_Attribute3
                     ,p_Ass_Attribute4
                     ,p_Ass_Attribute5
                     ,p_Ass_Attribute6
                     ,p_Ass_Attribute7
                     ,p_Ass_Attribute8
                     ,p_Ass_Attribute9
                     ,p_Ass_Attribute10
                     ,p_Ass_Attribute11
                     ,p_Ass_Attribute12
                     ,p_Ass_Attribute13
                     ,p_Ass_Attribute14
                     ,p_Ass_Attribute15
                     ,p_Ass_Attribute16
                     ,p_Ass_Attribute17
                     ,p_Ass_Attribute18
                     ,p_Ass_Attribute19
                     ,p_Ass_Attribute20
                     ,p_Ass_Attribute21
                     ,p_Ass_Attribute22
                     ,p_Ass_Attribute23
                     ,p_Ass_Attribute24
                     ,p_Ass_Attribute25
                     ,p_Ass_Attribute26
                     ,p_Ass_Attribute27
                     ,p_Ass_Attribute28
                     ,p_Ass_Attribute29
                     ,p_Ass_Attribute30
                     ,p_warning_message);
END get_enddate_and_defaults;
--
  procedure validate_effective_start(p_effective_start_date DATE
                                    ,p_person_id NUMBER
                                  ,p_period_of_service_id NUMBER)
IS
--
-- Get start date from current period of service
-- Not as before in getting the
-- Earliest effective start date from per_people_f
-- As this may cause an assignment to span multiple periods_of_service
-- Which it cannot by business_rule.
--
cursor  get_per_start_date
is
select  p.date_start
from    per_periods_of_service p
where   p.person_id = p_person_id
and     p.period_of_service_id = p_period_of_service_id;
--
cursor get_termination_date
is
select  pos.actual_termination_date
from    per_periods_of_service pos
where   pos.person_id = p_person_id
and     pos.period_of_service_id = p_period_of_service_id;
--
p_termination_date DATE;
p_start_date DATE;
begin
  open get_per_start_date;
  fetch get_per_start_date into p_start_date;
  close get_per_start_date;
  --
  open get_termination_date;
  fetch get_termination_date into p_termination_date;
  close get_termination_date;
  --
  if p_start_date > p_effective_start_date
  then
    FND_MESSAGE.SET_NAME('PA','PA_ALL_START_DATE_AFTER');
    FND_MESSAGE.SET_TOKEN('S_DATE',to_char(p_start_date,'DD-MON-YYYY'));
    HR_UTILITY.RAISE_ERROR;
  elsif ((p_termination_date is not null)
      and (p_effective_start_date > p_termination_date))
  then
    FND_MESSAGE.SET_NAME('PA','PA_ALL_START_DATE_BEFORE');
    FND_MESSAGE.SET_TOKEN('T_DATE',
             to_char(p_termination_date,'DD-MON-YYYY'));
    HR_UTILITY.RAISE_ERROR;
  end if;
end;
END PER_ASSIGNMENTS_V8_PKG;

/
