--------------------------------------------------------
--  DDL for Package Body PER_REQUISITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REQUISITIONS_PKG" as
/* $Header: pereq01t.pkb 115.3 2003/01/27 15:53:35 irgonzal ship $ */
--
/*   +======================================================================+
     |          Copyright (c) 1993 Oracle Corporation                       |
     |             Redwood Shores, California, USA                          |
     |                  All rights reserved.                                |
     +=======================================================================
  Name
    PER_REQUISITIONS_PKG
  Purpose
    Supports the REQUISITION block in the form PERWSVAC (Define Requisition
    and Vacancy).
  Notes

  History
    13-APR-94  H.Minton   40.0         Date created.
    23-NOV-94  RFine      70.3         Suppressed index on business_group_id
    02-FEB-95  DKerrr     70.5         Removed WHO columns for Set8 changes.
    05-MAR-97  JAlloun    70.6         Changed all occurances of system.dual
                                       to sys.dual for next release requirements.
    28-MAY-99  CCarter    115.2        Set token removed after message 6124.
    27-JAN-03  irgonzal   115.3        Bug fix 2743416: modified
                                       Date_from_raised_by procedure.

=============================================================================*/
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_Unique_Name                                                     --
-- Purpose                                                                 --
--   checks that the requisition name is unique. Called from the client    --
--   side package REQUISITION_ITEMS from the procedure 'name'. Called      --
--   on WHEN-VALIDATE-ITEM from Name.                                      --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Check_Unique_Name(P_Name                      VARCHAR2,
                            P_Business_group_id         NUMBER,
                            P_rowid                     VARCHAR2)  IS

   CURSOR name_exists IS
                       SELECT 1
                       FROM   per_requisitions  r
                       WHERE  r.NAME                = p_Name
                       AND    r.business_group_id + 0   = P_business_group_id
                       AND    (P_rowid             <> r.rowid
                                                    or P_rowid is NULL);
v_dummy number;
--
BEGIN
--
  OPEN name_exists;
  FETCH name_exists into v_dummy;
     IF name_exists%found THEN
        CLOSE name_exists;
        fnd_message.set_name('PER', 'HR_6123_ALL_UNIQUE_NAME');
        fnd_message.set_token('INFORMATION_TYPE','requisition');
        hr_utility.raise_error;
     ELSE CLOSE name_exists;
     END IF;
END Check_Unique_Name;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_date_from                                                         --
-- Purpose                                                                 --
--   checks that the requisition date_from is within the vacancy dates     --
-- Arguments								   --
--   see below.
-----------------------------------------------------------------------------
--
PROCEDURE chk_date_from(P_Date_from                 DATE,
                        P_Business_group_id         NUMBER,
                        P_Requisition_id            NUMBER)  IS

    CURSOR C_chk_date_from IS
                      SELECT 1
		      FROM   PER_VACANCIES PV
                      WHERE  P_Requisition_id      = PV.REQUISITION_ID
                      AND    PV.business_group_id + 0  = P_Business_group_id
                      AND    P_Date_from           > PV.DATE_FROM;


v_dummy number;
--
BEGIN
--
  OPEN C_chk_date_from;
  FETCH C_chk_date_from into v_dummy;
    IF C_chk_date_from%found THEN
        CLOSE C_chk_date_from;
        fnd_message.set_name('PER','HR_6834_VACS_REQ_IN_VAC_DATES');
        hr_utility.raise_error;
    ELSE CLOSE C_chk_date_from;
    END IF;


END chk_date_from;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Date_from_raised_by                                                   --
-- Purpose                                                                 --
--   checks that the requisition date_from does not invalidate the person  --
--   who raised the requisition, if such a person exists.                  --
-- Arguments								   --
--   see below.                                                            --
-----------------------------------------------------------------------------
--
-- 2743416: Business Group parameter is not necessary.
-- It might cause problems when Cross BG profile option is set to 'Y'.
--
PROCEDURE Date_from_raised_by(P_Person_id		NUMBER,
                              P_Business_group_id	NUMBER,
                              P_Date_from		DATE)     IS

	CURSOR C_chk_raised_by IS
               SELECT 1
	       FROM   PER_ALL_PEOPLE_F P
               WHERE  P_Person_id         = P.PERSON_ID
               --AND    P_business_group_id + 0 = P.BUSINESS_GROUP_ID
               AND    P_Date_from   between P.EFFECTIVE_START_DATE
                                    and     P.EFFECTIVE_END_DATE;

v_dummy number;
--
BEGIN
--
  OPEN C_chk_raised_by;
  FETCH C_chk_raised_by into v_dummy;
   IF C_chk_raised_by%NOTFOUND THEN
      CLOSE C_chk_raised_by;
       fnd_message.set_name('PER','HR_6643_VACS_RAISED_BY');
       hr_utility.raise_error;
   ELSE CLOSE C_chk_raised_by;
   END IF;

END Date_from_raised_by;

--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Date_to_in_vac_dates                                                  --
-- Purpose                                                                 --
--   checks that the requisition date_to does not invalidate the person    --
--   who raised the requisition, if such a person exists.                  --
-- Arguments								   --
--   see below.                                                            --
-----------------------------------------------------------------------------
--
PROCEDURE Date_to_in_vac_dates(P_Requisition_id		NUMBER,
                               P_Business_group_id	NUMBER,
                               P_Date_to		DATE)     IS

	CURSOR C_date_to_val IS
               SELECT 1
	       FROM   PER_VACANCIES PV
               WHERE  P_Requisition_id    = PV.REQUISITION_ID
               AND    P_business_group_id + 0 = PV.BUSINESS_GROUP_ID
               AND    PV.DATE_TO IS NOT NULL
               AND    P_Date_to           < PV.DATE_TO;

v_dummy number;
--
BEGIN
--
  OPEN C_date_to_val;
  FETCH C_date_to_val into v_dummy;
   IF C_date_to_val%FOUND THEN
      CLOSE C_date_to_val;
       fnd_message.set_name('PER','HR_6835_VACS_REQ_DATE_TO');
       hr_utility.raise_error;
   ELSE CLOSE C_date_to_val;
   END IF;

END Date_to_in_vac_dates;
----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_References                                                      --
-- Purpose                                                                 --
--   checks that deletes cannot take place of child records of vacancies   --
--   exist.                                                                --
-----------------------------------------------------------------------------
--
PROCEDURE Check_References(P_requisition_id		NUMBER,
                           P_Business_group_id		NUMBER)    IS


	CURSOR C_check_references IS
               SELECT PR.NAME
               FROM   PER_VACANCIES PV,
                      PER_REQUISITIONS PR
               WHERE  PV.REQUISITION_ID    = P_requisition_id
               AND    PR.REQUISITION_ID    = P_requisition_id
               AND    PR.business_group_id + 0 = P_Business_group_id
               AND    PV.business_group_id + 0 = P_Business_group_id;

v_name VARCHAR2(30);
--
BEGIN
--
  OPEN C_Check_References;
  FETCH C_Check_References into v_name;
  IF C_Check_References%FOUND THEN
     CLOSE C_Check_References;
     fnd_message.set_name('PER','HR_6124_REQS_VACS_DEL_VACANCY');
     hr_utility.raise_error;
  ELSE CLOSE C_Check_References;
  END IF;

END Check_References;
--
------------------------------------------------------------------------------
--
PROCEDURE Insert_Row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
                     X_Requisition_Id        IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Date_From                           DATE,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Description                         VARCHAR2,
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
                     X_Attribute20                         VARCHAR2)
IS
   CURSOR C IS SELECT rowid
               FROM  PER_REQUISITIONS
               WHERE requisition_id = X_Requisition_Id;
--
    CURSOR C2 IS SELECT per_requisitions_s.nextval
                 FROM sys.dual;
BEGIN

   if (X_Requisition_Id is NULL) then
     OPEN C2;
      FETCH C2 INTO X_Requisition_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_REQUISITIONS
         ( requisition_id,
          business_group_id,
          person_id,
          date_from,
          name,
          comments,
          date_to,
          description,
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
          attribute20)
  VALUES (
          X_Requisition_Id,
          X_Business_Group_Id,
          X_Person_Id,
          X_Date_From,
          X_Name,
          X_Comments,
          X_Date_To,
          X_Description,
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
          X_Attribute20);

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_requisitions_pkg.insert_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
END Insert_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Lock_Row                                                              --
-- Purpose                                                                 --
--   Table handler procedure that supports the insert , update and delete  --
--   Requistion and Vacancy form.                                            --
-- Arguments                                                               --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Requisition_Id                        NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Person_Id                             NUMBER,
                   X_Date_From                             DATE,
                   X_Name                                  VARCHAR2,
                   X_Comments                              VARCHAR2,
                   X_Date_To                               DATE,
                   X_Description                           VARCHAR2,
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
                   X_Attribute20                           VARCHAR2)
IS
  CURSOR C IS
      SELECT *
      FROM   PER_REQUISITIONS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Requisition_Id NOWAIT;
  Recinfo C%ROWTYPE;

BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_requistions_pkg.lock_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
--
Recinfo.name := rtrim(Recinfo.name);
Recinfo.comments := rtrim(Recinfo.comments);
Recinfo.description := rtrim(Recinfo.description);
Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
Recinfo.attribute1 := rtrim(Recinfo.attribute1);
Recinfo.attribute2 := rtrim(Recinfo.attribute2);
Recinfo.attribute3 := rtrim(Recinfo.attribute3);
Recinfo.attribute4 := rtrim(Recinfo.attribute4);
Recinfo.attribute5 := rtrim(Recinfo.attribute5);
Recinfo.attribute6 := rtrim(Recinfo.attribute6);
Recinfo.attribute7 := rtrim(Recinfo.attribute7);
Recinfo.attribute8 := rtrim(Recinfo.attribute8);
Recinfo.attribute9 := rtrim(Recinfo.attribute9);
Recinfo.attribute10 := rtrim(Recinfo.attribute10);
Recinfo.attribute11 := rtrim(Recinfo.attribute11);
Recinfo.attribute12 := rtrim(Recinfo.attribute12);
Recinfo.attribute13 := rtrim(Recinfo.attribute13);
Recinfo.attribute14 := rtrim(Recinfo.attribute14);
Recinfo.attribute15 := rtrim(Recinfo.attribute15);
Recinfo.attribute16 := rtrim(Recinfo.attribute16);
Recinfo.attribute17 := rtrim(Recinfo.attribute17);
Recinfo.attribute18 := rtrim(Recinfo.attribute18);
Recinfo.attribute19 := rtrim(Recinfo.attribute19);
Recinfo.attribute20 := rtrim(Recinfo.attribute20);
--
  if (
          (   (Recinfo.requisition_id = X_Requisition_Id)
           OR (    (Recinfo.requisition_id IS NULL)
               AND (X_Requisition_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.person_id = X_Person_Id)
           OR (    (Recinfo.person_id IS NULL)
               AND (X_Person_Id IS NULL)))
      AND (   (Recinfo.date_from = X_Date_From)
           OR (    (Recinfo.date_from IS NULL)
               AND (X_Date_From IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.date_to = X_Date_To)
           OR (    (Recinfo.date_to IS NULL)
               AND (X_Date_To IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
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
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Update_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the update of a REQUISTION via     --
--   DefineREquistion and Vacancyform.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Requisition_Id                      NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Date_From                           DATE,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Description                         VARCHAR2,
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
                     X_Attribute20                         VARCHAR2)

IS
BEGIN
  UPDATE PER_REQUISITIONS
  SET
    requisition_id                            =    X_Requisition_Id,
    business_group_id                         =    X_Business_Group_Id,
    person_id                                 =    X_Person_Id,
    date_from                                 =    X_Date_From,
    name                                      =    X_Name,
    comments                                  =    X_Comments,
    date_to                                   =    X_Date_To,
    description                               =    X_Description,
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
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_requisitions_pkg.update_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;

END Update_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Delete_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the delete of a REQUISITION via --
--   the Define Recruitment Activity form.                                 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PER_REQUISITIONS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_requisitions_pkg.delete_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
END Delete_Row;

END PER_REQUISITIONS_PKG;

/
