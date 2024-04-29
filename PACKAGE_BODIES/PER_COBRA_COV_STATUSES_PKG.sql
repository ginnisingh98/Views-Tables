--------------------------------------------------------
--  DDL for Package Body PER_COBRA_COV_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_COBRA_COV_STATUSES_PKG" as
/* $Header: pecobccs.pkb 115.1 99/07/17 18:50:00 porting ship $ */
--
PROCEDURE Insert_Row(X_Rowid                           IN OUT VARCHAR2,
                     X_Cobra_Coverage_Status_Id               IN OUT NUMBER,
                     X_Business_Group_Id                      NUMBER,
                     X_Cobra_Coverage_Enrollment_Id           NUMBER,
                     X_Cobra_Coverage_Status_Type             VARCHAR2,
                     X_Effective_Date                         DATE,
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
                     X_Comments                               VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM per_cobra_coverage_statuses
           WHERE cobra_coverage_status_id = X_Cobra_Coverage_Status_Id;
--
--
--
--
  CURSOR C2 IS SELECT per_cobra_coverage_statuses_s.nextval FROM sys.dual;
 BEGIN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg hr_ccs.insert_row',1);
--
hr_utility.set_location('per_cobra_cov_statuses_pkg hr_ccs.insert_row',2);
--
   if (X_Cobra_Coverage_Status_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Cobra_Coverage_Status_Id;
     CLOSE C2;
   end if;
--
hr_utility.set_location('per_cobra_cov_statuses_pkg hr_ccs.insert_row',3);
-- hr_utility.trace(X_Cobra_Coverage_Status_Id);
--
--
  INSERT INTO per_cobra_coverage_statuses(
         cobra_coverage_status_id,
         business_group_id,
         cobra_coverage_enrollment_id,
         cobra_coverage_status_type,
         effective_date,
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
         comments
        ) VALUES (
        X_Cobra_Coverage_Status_Id,
        X_Business_Group_Id,
        X_Cobra_Coverage_Enrollment_Id,
        X_Cobra_Coverage_Status_Type,
        X_Effective_Date,
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
        X_Comments
  );
--
hr_utility.set_location('per_cobra_cov_statuses_pkg hr_ccs.insert_row',4);
--
--
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
--
hr_utility.set_location('per_cobra_cov_statuses_pkg hr_ccs.insert_row',5);
--
END Insert_Row;
--
PROCEDURE Lock_Row(X_Rowid                             VARCHAR2,
                   X_Cobra_Coverage_Status_Id          NUMBER,
                   X_Business_Group_Id                 NUMBER,
                   X_Cobra_Coverage_Enrollment_Id      NUMBER,
                   X_Cobra_Coverage_Status_Type        VARCHAR2,
                   X_Effective_Date                    DATE,
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
                   X_Comments                          VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   per_cobra_coverage_statuses
      WHERE  rowid = X_Rowid
      FOR UPDATE of Cobra_Coverage_Status_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg lock_row ccs',0);
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
Recinfo.attribute14 := RTRIM(Recinfo.attribute14);
Recinfo.attribute15 := RTRIM(Recinfo.attribute15);
Recinfo.attribute16 := RTRIM(Recinfo.attribute16);
Recinfo.attribute17 := RTRIM(Recinfo.attribute17);
Recinfo.attribute18 := RTRIM(Recinfo.attribute18);
Recinfo.attribute19 := RTRIM(Recinfo.attribute19);
Recinfo.attribute20 := RTRIM(Recinfo.attribute20);
Recinfo.cobra_coverage_status_type := RTRIM(Recinfo.cobra_coverage_status_type);
Recinfo.comments := RTRIM(Recinfo.comments);
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
--
  if (
         (   (Recinfo.cobra_coverage_status_id = X_Cobra_Coverage_Status_Id)
          OR (    (Recinfo.cobra_coverage_status_id IS NULL)
              AND (X_Cobra_Coverage_Status_Id IS NULL)))
     AND (   (Recinfo.business_group_id = X_Business_Group_Id)
          OR (    (Recinfo.business_group_id IS NULL)
              AND (X_Business_Group_Id IS NULL)))
     AND (   (Recinfo.cobra_coverage_enrollment_id =
     X_Cobra_Coverage_Enrollment_Id)
          OR (    (Recinfo.cobra_coverage_enrollment_id IS NULL)
              AND (X_Cobra_Coverage_Enrollment_Id IS NULL)))
     AND (   (Recinfo.cobra_coverage_status_type =
     X_Cobra_Coverage_Status_Type)
          OR (    (Recinfo.cobra_coverage_status_type IS NULL)
              AND (X_Cobra_Coverage_Status_Type IS NULL)))
     AND (   (Recinfo.effective_date = X_Effective_Date)
          OR (    (Recinfo.effective_date IS NULL)
              AND (X_Effective_Date IS NULL)))
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
     AND (   (Recinfo.comments = X_Comments)
          OR (    (Recinfo.comments IS NULL)
              AND (X_Comments IS NULL)))
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
                     X_Cobra_Coverage_Enrollment_Id        NUMBER,
                     X_Cobra_Coverage_Status_Type          VARCHAR2,
                     X_Effective_Date                      DATE,
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
                     X_Comments                            VARCHAR2
) IS
BEGIN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg update_row ccs',0);
--
  UPDATE per_cobra_coverage_statuses
  SET
    business_group_id                    =   X_Business_Group_Id,
    cobra_coverage_enrollment_id         =   X_Cobra_Coverage_Enrollment_Id,
    cobra_coverage_status_type           =   X_Cobra_Coverage_Status_Type,
    effective_date                       =   X_Effective_Date,
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
    comments                             =   X_Comments
  WHERE rowid = X_rowid;
--
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
--
END Update_Row;
--
--
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg delete_row',0);
--
  DELETE FROM per_cobra_coverage_statuses
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--
--
--
-- Name        hr_cobra_chk_status_unique
--
-- Purpose
--
-- Ensures that the status being entered is unique
--
-- Arguments
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_chk_status_unique ( p_business_group_id            NUMBER,
				       p_cobra_coverage_status_id     NUMBER,
				       p_cobra_coverage_enrollment_id NUMBER,
				       p_cobra_coverage_status_type   VARCHAR2) IS
--
-- declare local variables
--
   l_status_exists VARCHAR2(1) := 'N';
--
-- declare cursor
--
   CURSOR status IS
   SELECT 'Y'
   FROM   per_cobra_coverage_statuses ccs
   WHERE  ccs.business_group_id + 0             = p_business_group_id
   AND    ccs.cobra_coverage_enrollment_id  = p_cobra_coverage_enrollment_id
   AND    ccs.cobra_coverage_status_type    = p_cobra_coverage_status_type
   AND    (   ccs.cobra_coverage_status_id <> p_cobra_coverage_status_id
           OR p_cobra_coverage_status_id IS NULL);
--
BEGIN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs hr_cobra_chk_status_unique',0);
--
--
-- get status
--
   OPEN  status;
   FETCH status INTO l_status_exists;
   CLOSE status;
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs hr_cobra_chk_status_unique',1);
--
--
-- Check flag
--
IF (l_status_exists = 'Y')
THEN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs hr_cobra_chk_status_unique',2);
--
    -- raise error
    --
      hr_utility.set_message(801, 'HR_13143_COBRA_DUP_STATUS');
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs hr_cobra_chk_status_unique',2.5);
--
      hr_utility.raise_error;
    --
END IF;
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs hr_cobra_chk_status_unique',3);
--
--
END hr_cobra_chk_status_unique;
--
--
--
-- Name
--
-- Purpose
--
-- Ensures status inserted in correct order
--
-- Arguments
--
-- Example
--
-- Notes
--
--
PROCEDURE hr_cobra_chk_status_order ( p_business_group_id            NUMBER,
				      p_cobra_coverage_enrollment_id NUMBER,
                                      p_cobra_coverage_status_id     NUMBER,
				      p_cobra_coverage_status_type   VARCHAR2,
				      p_effective_date               DATE ) IS
--
-- declare local variables
--
   l_status_order_ok VARCHAR2(1) := 'N';
--
-- declare cursors
--
  CURSOR elect_or_reject_status IS
  SELECT  'Y'
  FROM    per_cobra_coverage_statuses ccs
  WHERE   ccs.business_group_id + 0            = p_business_group_id
  AND     ccs.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
  AND     (   ccs.cobra_coverage_status_id  <> p_cobra_coverage_status_id
           OR p_cobra_coverage_status_id IS NULL )
  AND     ccs.cobra_coverage_status_type   IN ('ELEC', 'REJ')
  AND     ccs.effective_date               <= p_effective_date;
--
  CURSOR notified_status IS
  SELECT 'Y'
  FROM   per_cobra_coverage_statuses ccs
  WHERE  ccs.business_group_id + 0             = p_business_group_id
  AND    ccs.cobra_coverage_enrollment_id  = p_cobra_coverage_enrollment_id
  AND     (   ccs.cobra_coverage_status_id  <> p_cobra_coverage_status_id
           OR p_cobra_coverage_status_id IS NULL )
  AND    ccs.cobra_coverage_status_type    = 'NOT'
  AND    ccs.effective_date               <= p_effective_date;
--
BEGIN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk correct order', 1);
--
--
-- chk terminated
--
  IF (p_cobra_coverage_status_type = 'TERM')
  THEN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk correct order', 2);
       --
       -- chk elect or reject exist
       --
          OPEN  elect_or_reject_status;
          FETCH elect_or_reject_status INTO l_status_order_ok;
          CLOSE elect_or_reject_status;
       --
--
-- check elect /reject
--
  ELSIF (p_cobra_coverage_status_type IN ('ELEC', 'REJ'))
  THEN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk correct order', 3);
      --
      -- chk notified exists
      --
         OPEN  notified_status;
         FETCH notified_status INTO l_status_order_ok;
         CLOSE notified_status;
      --
  ELSE
       -- do nothing
       RETURN;
  END IF;
--
-- check order ok
--
  IF (l_status_order_ok = 'N')
  THEN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk correct order', 4);
      --
      -- chk which error to raise
      --
         IF (p_cobra_coverage_status_type = 'TERM')
         THEN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk correct order', 5);
              --
              -- Elect/Reject before Term error
              --
                 hr_utility.set_message(801, 'HR_13134_COBRA_CANT_TERM_YET');
                 hr_utility.raise_error;
         ELSE
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk correct order', 6);
              --
              -- Notify before Elect/Reject error
              --
                 hr_utility.set_message(801, 'HR_13135_COBRA_CANT_EL_REJ_YET');
                 hr_utility.raise_error;
         END IF;
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk correct order', 7);
  END IF;
END hr_cobra_chk_status_order;
--
--
--
-- Name       hr_cobra_chk_status_elect_rej
--
-- Purpose
--
-- Ensures that Accept/Reject do not coexist
--
-- Arguments
--
-- Example
--
-- Notes
--
PROCEDURE hr_cobra_chk_status_elect_rej( p_business_group_id            NUMBER,
                                         p_cobra_coverage_enrollment_id NUMBER,
                                         p_cobra_coverage_status_id     NUMBER,
                                         p_cobra_coverage_status_type   VARCHAR2) IS
--
-- declare local variables
--
  l_status_ok VARCHAR2(1) := 'Y';
--
-- declare cursor
--
   CURSOR elect_reject IS
   SELECT  'N'
   FROM    per_cobra_coverage_statuses ccs
   WHERE   ccs.business_group_id + 0            = p_business_group_id
   AND     ccs.cobra_coverage_enrollment_id = p_cobra_coverage_enrollment_id
   AND     ccs.cobra_coverage_status_type  IN ('ELEC', 'REJ')
   AND     ccs.cobra_coverage_status_type  = DECODE(p_cobra_coverage_status_type,
                                                    'ELEC', 'REJ',
                                                    'ELEC');
--
BEGIN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk elect reject', 1);
--
-- check if elect / reject co-exist
--
   OPEN  elect_reject;
   FETCH elect_reject INTO l_status_ok;
   CLOSE elect_reject;
--
-- chk if Elect/Reject rule violated
--
   IF (l_status_ok = 'N')
   THEN
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk elect reject', 2);
--
        -- Reject/Elect cannot co-exist error
        --
          hr_utility.set_message(801, 'HR_13136_COBRA_EL_REJ_NOT_COEX');
          hr_utility.raise_error;
END IF;
--
hr_utility.set_location('per_cobra_cov_statuses_pkg ccs pkg - chk elect reject', 3);
--
--
END hr_cobra_chk_status_elect_rej;
--
--
--
--
END PER_COBRA_COV_STATUSES_PKG;

/
