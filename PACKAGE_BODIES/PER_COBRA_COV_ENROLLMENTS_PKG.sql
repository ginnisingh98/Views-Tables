--------------------------------------------------------
--  DDL for Package Body PER_COBRA_COV_ENROLLMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_COBRA_COV_ENROLLMENTS_PKG" as
/* $Header: pecobcce.pkb 120.0 2006/04/18 18:14:28 ssouresr noship $ */
--
PROCEDURE Insert_Row(X_Rowid                           IN OUT NOCOPY VARCHAR2,
                     X_Cobra_Coverage_Enrollment_Id           IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                      NUMBER,
                     X_Assignment_Id                          NUMBER,
                     X_Period_Type                            VARCHAR2,
                     X_Qualifying_Date                        DATE,
                     X_Qualifying_Event                       VARCHAR2,
                     X_Coverage_End_Date                      DATE,
                     X_Coverage_Start_Date                    DATE,
                     X_Termination_Reason                     VARCHAR2,
                     X_Contact_Relationship_Id                NUMBER,
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
                     X_Grace_Days                             NUMBER,
                     X_Comments                               VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM per_cobra_cov_enrollments
           WHERE cobra_coverage_enrollment_id = X_Cobra_Coverage_Enrollment_Id;
--
--
--
--
--
  CURSOR C2 IS SELECT per_cobra_cov_enrollments_s.nextval FROM sys.dual;
 BEGIN
--
hr_utility.set_location('cce insert_row', 0);
--
     if (X_Cobra_Coverage_Enrollment_Id is NULL) then
     OPEN  C2;
     FETCH C2 INTO X_Cobra_Coverage_Enrollment_Id;
     CLOSE C2;
   end if;
--
  INSERT INTO per_cobra_cov_enrollments(
         cobra_coverage_enrollment_id,
         business_group_id,
         assignment_id,
         period_type,
         qualifying_date,
         qualifying_event,
         coverage_end_date,
         coverage_start_date,
         termination_reason,
         contact_relationship_id,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         attribute16,
         attribute17,
         attribute18,
         attribute19,
         attribute20,
         grace_days,
         comments
        ) VALUES (
        X_Cobra_Coverage_Enrollment_Id,
        X_Business_Group_Id,
        X_Assignment_Id,
        X_Period_Type,
        X_Qualifying_Date,
        X_Qualifying_Event,
        X_Coverage_End_Date,
        X_Coverage_Start_Date,
        X_Termination_Reason,
        X_Contact_Relationship_Id,
        X_Attribute_Category,
        X_Attribute1,
        X_Attribute2,
        X_Attribute3,
        X_Attribute4,
        X_Attribute5,
        X_Attribute6,
        X_Attribute7,
        X_Attribute8,
        X_Attribute9,
        X_Attribute10,
        X_Attribute11,
        X_Attribute12,
        X_Attribute13,
        X_Attribute14,
        X_Attribute15,
        X_Attribute16,
        X_Attribute17,
        X_Attribute18,
        X_Attribute19,
        X_Attribute20,
        X_Grace_Days,
        X_comments
  );
--
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;
--
PROCEDURE Lock_Row(X_Rowid                             VARCHAR2,
                   X_Cobra_Coverage_Enrollment_Id      NUMBER,
                   X_Business_Group_Id                 NUMBER,
                   X_Assignment_Id                     NUMBER,
                   X_Period_Type                       VARCHAR2,
                   X_Qualifying_Date                   DATE,
                   X_Qualifying_Event                  VARCHAR2,
                   X_Coverage_End_Date                 DATE,
                   X_Coverage_Start_Date               DATE,
                   X_Termination_Reason                VARCHAR2,
                   X_Contact_Relationship_Id           NUMBER,
                   X_Attribute_Category                VARCHAR2,
                   X_Attribute1                        VARCHAR2,
                   X_Attribute2                        VARCHAR2,
                   X_Attribute3                        VARCHAR2,
                   X_Attribute4                        VARCHAR2,
                   X_Attribute5                        VARCHAR2,
                   X_Attribute6                        VARCHAR2,
                   X_Attribute7                        VARCHAR2,
                   X_Attribute8                        VARCHAR2,
                   X_Attribute9                        VARCHAR2,
                   X_Attribute10                       VARCHAR2,
                   X_Attribute11                       VARCHAR2,
                   X_Attribute12                       VARCHAR2,
                   X_Attribute13                       VARCHAR2,
                   X_Attribute14                       VARCHAR2,
                   X_Attribute15                       VARCHAR2,
                   X_Attribute16                       VARCHAR2,
                   X_Attribute17                       VARCHAR2,
                   X_Attribute18                       VARCHAR2,
                   X_Attribute19                       VARCHAR2,
                   X_Attribute20                       VARCHAR2,
                   X_Grace_Days                        NUMBER,
                   X_Comments                          VARCHAR2) IS
  CURSOR C IS
      SELECT *
      FROM   per_cobra_cov_enrollments
      WHERE  rowid = X_Rowid
      FOR UPDATE of COBRA_COVERAGE_ENROLLMENT_ID NOWAIT;
      /* FOR UPDATE of COBRA_COVERAGE_ENROLLMENT_ID NOWAIT; */
  Recinfo C%ROWTYPE;
BEGIN
--
hr_utility.set_location('cce lock_row', 0);
--
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
--
-- Ensure that we're not tricked into thinking the record has
-- changed if the user has inserted using sqlplus leaving trailing spaces
--
Recinfo.attribute9 := RTRIM(Recinfo.attribute9);
Recinfo.attribute10 := RTRIM(Recinfo.attribute10);
Recinfo.attribute11 := RTRIM(Recinfo.attribute11);
Recinfo.attribute12 := RTRIM(Recinfo.attribute12);
Recinfo.attribute13 := RTRIM(Recinfo.attribute13);
Recinfo.attribute14 := RTRIM(Recinfo.attribute14);
Recinfo.attribute15 := RTRIM(Recinfo.attribute15);
Recinfo.attribute16 := RTRIM(Recinfo.attribute16);
Recinfo.attribute17 := RTRIM(Recinfo.attribute17);
Recinfo.attribute18 := RTRIM(Recinfo.attribute18);
Recinfo.attribute19 := RTRIM(Recinfo.attribute19);
Recinfo.attribute20 := RTRIM(Recinfo.attribute20);
Recinfo.period_type := RTRIM(Recinfo.period_type);
Recinfo.qualifying_event := RTRIM(Recinfo.qualifying_event);
Recinfo.comments := RTRIM(Recinfo.comments);
Recinfo.termination_reason := RTRIM(Recinfo.termination_reason);
Recinfo.attribute_category := RTRIM(Recinfo.attribute_category);
Recinfo.attribute1 := RTRIM(Recinfo.attribute1);
Recinfo.attribute2 := RTRIM(Recinfo.attribute2);
Recinfo.attribute3 := RTRIM(Recinfo.attribute3);
Recinfo.attribute4 := RTRIM(Recinfo.attribute4);
Recinfo.attribute5 := RTRIM(Recinfo.attribute5);
Recinfo.attribute6 := RTRIM(Recinfo.attribute6);
Recinfo.attribute7 := RTRIM(Recinfo.attribute7);
Recinfo.attribute8 := RTRIM(Recinfo.attribute8);
--
  if (
         (   (Recinfo.cobra_coverage_enrollment_id =
     X_Cobra_Coverage_Enrollment_Id)
          OR (    (Recinfo.cobra_coverage_enrollment_id IS NULL)
              AND (X_Cobra_Coverage_Enrollment_Id IS NULL)))
     AND (   (Recinfo.business_group_id = X_Business_Group_Id)
          OR (    (Recinfo.business_group_id IS NULL)
              AND (X_Business_Group_Id IS NULL)))
     AND (   (Recinfo.assignment_id = X_Assignment_Id)
          OR (    (Recinfo.assignment_id IS NULL)
              AND (X_Assignment_Id IS NULL)))
     AND (   (Recinfo.period_type = X_Period_Type)
          OR (    (Recinfo.period_type IS NULL)
              AND (X_Period_Type IS NULL)))
     AND (   (Recinfo.qualifying_date = X_Qualifying_Date)
          OR (    (Recinfo.qualifying_date IS NULL)
              AND (X_Qualifying_Date IS NULL)))
     AND (   (Recinfo.qualifying_event = X_Qualifying_Event)
          OR (    (Recinfo.qualifying_event IS NULL)
              AND (X_Qualifying_Event IS NULL)))
     AND (   (Recinfo.coverage_end_date = X_Coverage_End_Date)
          OR (    (Recinfo.coverage_end_date IS NULL)
              AND (X_Coverage_End_Date IS NULL)))
     AND (   (Recinfo.coverage_start_date = X_Coverage_Start_Date)
          OR (    (Recinfo.coverage_start_date IS NULL)
              AND (X_Coverage_Start_Date IS NULL)))
     AND (   (Recinfo.termination_reason = X_Termination_Reason)
          OR (    (Recinfo.termination_reason IS NULL)
              AND (X_Termination_Reason IS NULL)))
     AND (   (Recinfo.contact_relationship_id = X_Contact_Relationship_Id)
          OR (    (Recinfo.contact_relationship_id IS NULL)
              AND (X_Contact_Relationship_Id IS NULL)))
     AND (   (Recinfo.attribute_category = X_Attribute_Category)
          OR (    (Recinfo.attribute_category IS NULL)
              AND (X_Attribute_Category IS NULL)))
     AND (   (Recinfo.attribute1 = X_Attribute1)
          OR (    (Recinfo.attribute1 IS NULL)
              AND (X_Attribute1 IS NULL)))
     AND (   (Recinfo.attribute2 = X_Attribute2)
          OR (    (Recinfo.attribute2 IS NULL)
              AND (X_Attribute2 IS NULL)))
     AND (   (Recinfo.attribute3 = X_Attribute3)
          OR (    (Recinfo.attribute3 IS NULL)
              AND (X_Attribute3 IS NULL)))
     AND (   (Recinfo.attribute4 = X_Attribute4)
          OR (    (Recinfo.attribute4 IS NULL)
              AND (X_Attribute4 IS NULL)))
     AND (   (Recinfo.attribute5 = X_Attribute5)
          OR (    (Recinfo.attribute5 IS NULL)
              AND (X_Attribute5 IS NULL)))
     AND (   (Recinfo.attribute6 = X_Attribute6)
          OR (    (Recinfo.attribute6 IS NULL)
              AND (X_Attribute6 IS NULL)))
     AND (   (Recinfo.attribute7 = X_Attribute7)
          OR (    (Recinfo.attribute7 IS NULL)
              AND (X_Attribute7 IS NULL)))
     AND (   (Recinfo.attribute8 = X_Attribute8)
          OR (    (Recinfo.attribute8 IS NULL)
              AND (X_Attribute8 IS NULL)))
     AND (   (Recinfo.attribute9 = X_Attribute9)
          OR (    (Recinfo.attribute9 IS NULL)
              AND (X_Attribute9 IS NULL)))
     AND (   (Recinfo.attribute10 = X_Attribute10)
          OR (    (Recinfo.attribute10 IS NULL)
              AND (X_Attribute10 IS NULL)))
     AND (   (Recinfo.attribute11 = X_Attribute11)
          OR (    (Recinfo.attribute11 IS NULL)
              AND (X_Attribute11 IS NULL)))
     AND (   (Recinfo.attribute12 = X_Attribute12)
          OR (    (Recinfo.attribute12 IS NULL)
              AND (X_Attribute12 IS NULL)))
     AND (   (Recinfo.attribute13 = X_Attribute13)
          OR (    (Recinfo.attribute13 IS NULL)
              AND (X_Attribute13 IS NULL)))
     AND (   (Recinfo.attribute14 = X_Attribute14)
          OR (    (Recinfo.attribute14 IS NULL)
              AND (X_Attribute14 IS NULL)))
     AND (   (Recinfo.attribute15 = X_Attribute15)
          OR (    (Recinfo.attribute15 IS NULL)
              AND (X_Attribute15 IS NULL)))
     AND (   (Recinfo.attribute16 = X_Attribute16)
          OR (    (Recinfo.attribute16 IS NULL)
              AND (X_Attribute16 IS NULL)))
     AND (   (Recinfo.attribute17 = X_Attribute17)
          OR (    (Recinfo.attribute17 IS NULL)
              AND (X_Attribute17 IS NULL)))
     AND (   (Recinfo.attribute18 = X_Attribute18)
          OR (    (Recinfo.attribute18 IS NULL)
              AND (X_Attribute18 IS NULL)))
     AND (   (Recinfo.attribute19 = X_Attribute19)
          OR (    (Recinfo.attribute19 IS NULL)
              AND (X_Attribute19 IS NULL)))
     AND (   (Recinfo.attribute20 = X_Attribute20)
          OR (    (Recinfo.attribute20 IS NULL)
              AND (X_Attribute20 IS NULL)))
     AND (   (Recinfo.grace_days = X_Grace_Days)
          OR (    (Recinfo.grace_days IS NULL)
              AND (X_Grace_Days IS NULL)))
     AND (   (Recinfo.comments = X_comments)
          OR (    (Recinfo.comments IS NULL)
              AND (X_comments IS NULL)))
          ) then
    return;
  else
    hr_utility.set_message(0, 'FORM_RECORD_CHANGED');
    hr_utility.raise_error;
  end if;
END Lock_Row;
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Business_Group_Id                   NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Period_Type                         VARCHAR2,
                     X_Qualifying_Date                     DATE,
                     X_Qualifying_Event                    VARCHAR2,
                     X_Coverage_End_Date                   DATE,
                     X_Coverage_Start_Date                 DATE,
                     X_Termination_Reason                  VARCHAR2,
                     X_Contact_Relationship_Id             NUMBER,
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
                     X_Grace_Days                          NUMBER,
                     X_Comments                            VARCHAR2
) IS
BEGIN
--
hr_utility.set_location('cce update_row', 0);
--
  UPDATE per_cobra_cov_enrollments
  SET
    business_group_id                    =   X_Business_Group_Id,
    assignment_id                        =   X_Assignment_Id,
    period_type                          =   X_Period_Type,
    qualifying_date                      =   X_Qualifying_Date,
    qualifying_event                     =   X_Qualifying_Event,
    coverage_end_date                    =   X_Coverage_End_Date,
    coverage_start_date                  =   X_Coverage_Start_Date,
    termination_reason                   =   X_Termination_Reason,
    contact_relationship_id              =   X_Contact_Relationship_Id,
    attribute_category                   =   X_Attribute_Category,
    attribute1                           =   X_Attribute1,
    attribute2                           =   X_Attribute2,
    attribute3                           =   X_Attribute3,
    attribute4                           =   X_Attribute4,
    attribute5                           =   X_Attribute5,
    attribute6                           =   X_Attribute6,
    attribute7                           =   X_Attribute7,
    attribute8                           =   X_Attribute8,
    attribute9                           =   X_Attribute9,
    attribute10                          =   X_Attribute10,
    attribute11                          =   X_Attribute11,
    attribute12                          =   X_Attribute12,
    attribute13                          =   X_Attribute13,
    attribute14                          =   X_Attribute14,
    attribute15                          =   X_Attribute15,
    attribute16                          =   X_Attribute16,
    attribute17                          =   X_Attribute17,
    attribute18                          =   X_Attribute18,
    attribute19                          =   X_Attribute19,
    attribute20                          =   X_Attribute20,
    grace_days                           =   X_Grace_Days,
    comments                             =   X_Comments
  WHERE rowid = X_rowid;
--
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
--
END Update_Row;
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
--
hr_utility.set_location('cce delete_row', 0);
--
  DELETE FROM per_cobra_cov_enrollments
  WHERE  rowid = X_Rowid;
--
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--
--
--
-- Name       hr_cobra_chk_unique_enrollment
--
-- Purpose
--
-- Checks that the enrollment entered is unique
--
-- Arguments
--
-- p_cobra_coverage_enrollment_id
-- p_assignment_id
-- p_contact_relationship_id
-- p_qualifying_event
-- p_qualifying_date
--
-- Example
--
-- Notes
--
--
PROCEDURE hr_cobra_chk_unique_enrollment ( p_cobra_coverage_enrollment_id NUMBER,
                                           p_assignment_id                NUMBER,
                                           p_contact_relationship_id      NUMBER,
                                           p_qualifying_event             VARCHAR2,
                                           p_qualifying_date              DATE ) IS
--
-- declare local variables
--
   l_coverage_exists VARCHAR2(2) := 'N';
--
-- declare cursors
--
   CURSOR employee_coverage IS
   SELECT 'E'
   FROM   per_cobra_cov_enrollments cce
   WHERE  (  cce.cobra_coverage_enrollment_id <> p_cobra_coverage_enrollment_id
          OR p_cobra_coverage_enrollment_id IS NULL)
   AND    cce.assignment_id   = p_assignment_id
   AND    cce.qualifying_date = p_qualifying_date
   AND    cce.qualifying_event= p_qualifying_event
   AND    cce.contact_relationship_id IS NULL;
--
   CURSOR contact_coverage IS
   SELECT 'C'
   FROM   per_cobra_cov_enrollments cce
   WHERE  (  cce.cobra_coverage_enrollment_id <> p_cobra_coverage_enrollment_id
          OR p_cobra_coverage_enrollment_id IS NULL)
   AND    cce.contact_relationship_id = p_contact_relationship_id
   AND    cce.qualifying_date         = p_qualifying_date
   AND    cce.qualifying_event        = p_qualifying_event
   AND    cce.contact_relationship_id IS NOT NULL;
--
BEGIN
--
hr_utility.set_location('cce.hr_cobra_chk_uinique_enrollment',1);
--
--
-- check to see if contact entered
--
   IF (p_contact_relationship_id IS NULL)
   THEN
       --
       -- Check employee coverage
       --
--
hr_utility.set_location('cce.hr_cobra_chk_uinique_enrollment',2);
--
          OPEN  employee_coverage;
          FETCH employee_coverage INTO l_coverage_exists;
          CLOSE employee_coverage;
--
hr_utility.set_location('cce.hr_cobra_chk_uinique_enrollment',3);
--
   ELSE
       --
       -- Check contact coverage
       --
--
hr_utility.set_location('cce.hr_cobra_chk_uinique_enrollment',4);
--
          OPEN  contact_coverage;
          FETCH contact_coverage INTO l_coverage_exists;
          CLOSE contact_coverage;
--
hr_utility.set_location('cce.hr_cobra_chk_uinique_enrollment',5);
--
   END IF;
--
-- check to see if coverage exists
--
--
hr_utility.set_location('cce.hr_cobra_chk_uinique_enrollment',6);
--
   IF (l_coverage_exists = 'C')
   THEN
       --
       -- error
       --
--
hr_utility.set_location('cce.hr_cobra_chk_uinique_enrollment',7);
--
          hr_utility.set_message(801, 'HR_13142_DEP_COV_EXISTS');
          hr_utility.raise_error;
       --
   ELSIF (l_coverage_exists = 'E')
   THEN
--
hr_utility.set_location('cce.hr_cobra_chk_uinique_enrollment',8);
--
       --
       -- error
       --
          hr_utility.set_message(801, 'HR_13141_COBRA_EMP_COV_EXISTS');
          hr_utility.raise_error;
       --
   END IF;
--
END hr_cobra_chk_unique_enrollment;
--
--
--
END PER_COBRA_COV_ENROLLMENTS_PKG;

/
