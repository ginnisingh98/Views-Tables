--------------------------------------------------------
--  DDL for Package Body PER_COBRA_COV_BENEFITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_COBRA_COV_BENEFITS_PKG" as
/* $Header: pecobccb.pkb 115.0 99/07/17 18:49:46 porting ship $ */


PROCEDURE Insert_Row(X_Rowid                        IN OUT VARCHAR2,
                     X_Cobra_Coverage_Benefit_Id           IN OUT NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Cobra_Coverage_Enrollment_Id        NUMBER,
                     X_Element_Type_Id                     NUMBER,
                     X_Accept_Reject_Flag                  VARCHAR2,
                     X_Coverage_Amount                     VARCHAR2,
                     X_Coverage_Type                       VARCHAR2,
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
                     X_Attribute20                         VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM PER_COBRA_COVERAGE_BENEFITS_F

             WHERE cobra_coverage_benefit_id = X_Cobra_Coverage_Benefit_Id;





    CURSOR C2 IS SELECT per_cobra_coverage_benefits_s.nextval FROM sys.dual;
BEGIN

   if (X_Cobra_Coverage_Benefit_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Cobra_Coverage_Benefit_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_COBRA_COVERAGE_BENEFITS_F(
          cobra_coverage_benefit_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          cobra_coverage_enrollment_id,
          element_type_id,
          accept_reject_flag,
          coverage_amount,
          coverage_type,
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
          attribute20
         ) VALUES (
          X_Cobra_Coverage_Benefit_Id,
          X_Effective_Start_Date,
          X_Effective_End_Date,
          X_Business_Group_Id,
          X_Cobra_Coverage_Enrollment_Id,
          X_Element_Type_Id,
          X_Accept_Reject_Flag,
          X_Coverage_Amount,
          X_Coverage_Type,
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
          X_Attribute20
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Cobra_Coverage_Benefit_Id             NUMBER,
                   X_Effective_Start_Date                  DATE,
                   X_Effective_End_Date                    DATE,
                   X_Business_Group_Id                     NUMBER,
                   X_Cobra_Coverage_Enrollment_Id          NUMBER,
                   X_Element_Type_Id                      NUMBER,
                   X_Accept_Reject_Flag                    VARCHAR2,
                   X_Coverage_Amount                       VARCHAR2,
                   X_Coverage_Type                         VARCHAR2,
                   X_Attribute_Category                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Attribute16                           VARCHAR2,
                   X_Attribute17                           VARCHAR2,
                   X_Attribute18                           VARCHAR2,
                   X_Attribute19                           VARCHAR2,
                   X_Attribute20                           VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PER_COBRA_COVERAGE_BENEFITS_F
      WHERE  rowid = X_Rowid
      FOR UPDATE of Cobra_Coverage_Benefit_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
-- hr_utility.trace_on;
hr_utility.set_location('ccb on lock', 1);
  OPEN C;
hr_utility.set_location('ccb on lock', 2);
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
hr_utility.set_location('ccb on lock', 3);
    RAISE NO_DATA_FOUND;
  end if;
hr_utility.set_location('ccb on lock', 4);
  CLOSE C;
--
-- Ensure that we're not tricked into thinking the record has
-- changed if the user has inserted using sqlplus leaving trailing spaces
--
Recinfo.attribute18 := RTRIM(Recinfo.attribute18);
Recinfo.attribute19 := RTRIM(Recinfo.attribute19);
Recinfo.attribute20 := RTRIM(Recinfo.attribute20);
Recinfo.accept_reject_flag := RTRIM(Recinfo.accept_reject_flag);
Recinfo.coverage_amount := RTRIM(Recinfo.coverage_amount);
Recinfo.coverage_type := RTRIM(Recinfo.coverage_type);
Recinfo.attribute_category := RTRIM(Recinfo.attribute_category);
Recinfo.attribute1 := RTRIM(Recinfo.attribute1);
Recinfo.attribute2 := RTRIM(Recinfo.attribute2);
Recinfo.attribute3 := RTRIM(Recinfo.attribute3);
Recinfo.attribute4 := RTRIM(Recinfo.attribute4);
Recinfo.attribute5 := RTRIM(Recinfo.attribute5);
Recinfo.attribute6 := RTRIM(Recinfo.attribute6);
Recinfo.attribute7 := RTRIM(Recinfo.attribute7);
Recinfo.attribute8 := RTRIM(Recinfo.attribute8);
Recinfo.attribute9 := RTRIM(Recinfo.attribute9);
Recinfo.attribute10 := RTRIM(Recinfo.attribute10);
Recinfo.attribute11 := RTRIM(Recinfo.attribute11);
Recinfo.attribute12 := RTRIM(Recinfo.attribute12);
Recinfo.attribute13 := RTRIM(Recinfo.attribute13);
Recinfo.attribute14 := RTRIM(Recinfo.attribute14);
Recinfo.attribute15 := RTRIM(Recinfo.attribute15);
Recinfo.attribute16 := RTRIM(Recinfo.attribute16);
Recinfo.attribute17 := RTRIM(Recinfo.attribute17);
--
  if (
          (   (Recinfo.cobra_coverage_benefit_id = X_Cobra_Coverage_Benefit_Id)
           OR (    (Recinfo.cobra_coverage_benefit_id IS NULL)
               AND (X_Cobra_Coverage_Benefit_Id IS NULL)))
      AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
           OR (    (Recinfo.effective_start_date IS NULL)
               AND (X_Effective_Start_Date IS NULL)))
      AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
           OR (    (Recinfo.effective_end_date IS NULL)
               AND (X_Effective_End_Date IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.cobra_coverage_enrollment_id = X_Cobra_Coverage_Enrollment_Id)
           OR (    (Recinfo.cobra_coverage_enrollment_id IS NULL)
               AND (X_Cobra_Coverage_Enrollment_Id IS NULL)))
      AND (   (Recinfo.element_type_id = X_Element_Type_Id)
           OR (    (Recinfo.element_type_id IS NULL)
               AND (X_Element_Type_Id IS NULL)))
      AND (   (Recinfo.accept_reject_flag = X_Accept_Reject_Flag)
           OR (    (Recinfo.accept_reject_flag IS NULL)
               AND (X_Accept_Reject_Flag IS NULL)))
      AND (   (TO_NUMBER(Recinfo.coverage_amount) = TO_NUMBER(X_Coverage_Amount))
           OR (    (Recinfo.coverage_amount IS NULL)
               AND (X_Coverage_Amount IS NULL)))
      AND (   (Recinfo.coverage_type = X_Coverage_Type)
           OR (    (Recinfo.coverage_type IS NULL)
               AND (X_Coverage_Type IS NULL)))
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
          ) then
hr_utility.set_location('ccb on lock', 5);
    return;
  else
hr_utility.set_location('ccb on lock', 6);
    hr_utility.set_message(0, 'FORM_RECORD_CHANGED');
    hr_utility.raise_error;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Cobra_Coverage_Benefit_Id           NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Cobra_Coverage_Enrollment_Id        NUMBER,
                     X_Element_Type_Id                    NUMBER,
                     X_Accept_Reject_Flag                  VARCHAR2,
                     X_Coverage_Amount                     VARCHAR2,
                     X_Coverage_Type                       VARCHAR2,
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
                     X_Attribute20                         VARCHAR2
) IS
BEGIN
  UPDATE PER_COBRA_COVERAGE_BENEFITS_F
  SET
    cobra_coverage_benefit_id                 =    X_Cobra_Coverage_Benefit_Id,
    effective_start_date                      =    X_Effective_Start_Date,
    effective_end_date                        =    X_Effective_End_Date,
    business_group_id                         =    X_Business_Group_Id,
    cobra_coverage_enrollment_id              =    X_Cobra_Coverage_Enrollment_Id,
    element_type_id                           =    X_Element_Type_Id,
    accept_reject_flag                        =    X_Accept_Reject_Flag,
    coverage_amount                           =    X_Coverage_Amount,
    coverage_type                             =    X_Coverage_Type,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    attribute16                               =    X_Attribute16,
    attribute17                               =    X_Attribute17,
    attribute18                               =    X_Attribute18,
    attribute19                               =    X_Attribute19,
    attribute20                               =    X_Attribute20
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PER_COBRA_COVERAGE_BENEFITS_F
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END PER_COBRA_COV_BENEFITS_PKG;

/
