--------------------------------------------------------
--  DDL for Package Body PAY_CALENDARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CALENDARS_PKG" as
/* $Header: pycal01t.pkb 120.1 2005/10/05 21:59:16 saurgupt noship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_calendars_pkg
  Purpose
    Table Handler for the block CAL in the Define Budgetary Calendar form.
  Notes
    Used by the PAYWSDCL (Define Budgetary Calendar) form.
  History
    11-Mar-94   J.S.Hobbs   40.0         Date created.
    22-Apr-94   J.S.Hobbs   40.1         Added rtrim to Lock_Row.
    02-Feb-95   J.S.Hobbs   40.5         Removed aol WHO columns.
    07-JAN-2000 C.Simpson  110.1         Added chk_budget_exists to prevent
					 delete where per_budget record exists
					 of Training Plan type (OTA_BUDGET).
    24-APR-2000 S Goyal    115.1         Updated chk_budget_exists to prevent
					 delete where pqh_budget record exists
 ============================================================================*/

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
g_package  varchar2(33) := '  PAY_CALENDARS_PKG.';  -- Global package name



-- ----------------------------------------------------------------------------
-- |                           chk_budget_exists                              |
-- ----------------------------------------------------------------------------
PROCEDURE chk_budget_exists(X_Period_Set_Name IN VARCHAR2) IS
--
-- Private procedure
-- Called by Delete_Row
--
  CURSOR c_budgets IS
    SELECT NULL
    FROM  per_budgets pb
    WHERE pb.period_set_name = X_Period_Set_Name
    AND   pb.budget_type_code = 'OTA_BUDGET';
--
  CURSOR c_pqh_budgets IS
    SELECT NULL
    FROM  pqh_budgets pb
    WHERE pb.period_set_name = X_Period_Set_Name;
--
  l_result VARCHAR2(255);
  l_proc   VARCHAR2(72) := g_package||'chk_budget_exists';
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  OPEN c_budgets;
  FETCH c_budgets INTO l_result;
  IF c_budgets%FOUND THEN
    CLOSE c_budgets;
    hr_utility.set_location(' ota budget exists'||l_proc, 10);
    hr_utility.set_message(800,'PER_52887_BUD_CAL_DELETE_FAIL');
    hr_utility.raise_error;
  END IF;
  CLOSE c_budgets;
--
  OPEN c_pqh_budgets;
  FETCH c_pqh_budgets INTO l_result;
  IF c_pqh_budgets%FOUND THEN
    CLOSE c_pqh_budgets;
    hr_utility.set_location(' pqh budget exists'||l_proc, 20);
    hr_utility.set_message(800,'PQH_52887_BUD_CAL_DELETE_FAIL');
    hr_utility.raise_error;
  END IF;
  CLOSE c_pqh_budgets;
--
  hr_utility.set_location(' Leaving:'||l_proc, 50);
--
END chk_budget_exists;
--
--
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a calendar via the--
 --   Define Budgetary Calendar form.                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT nocopy VARCHAR2,
                      X_Period_Set_Name                     VARCHAR2,
                      X_Actual_Period_Type                  VARCHAR2,
                      X_Proc_Period_Type                    VARCHAR2,
                      X_Start_Date                          DATE,
                      X_Comments                            VARCHAR2,
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
 		     -- Extra Columns
                      X_Midpoint_Offset                     NUMBER) IS
 --
    CURSOR C IS SELECT rowid FROM pay_calendars
                WHERE  period_set_name = X_Period_Set_Name;
--
 BEGIN
--
   INSERT INTO pay_calendars
   (period_set_name,
    actual_period_type,
    proc_period_type,
    start_date,
    comments,
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
   VALUES
   (X_Period_Set_Name,
    X_Actual_Period_Type,
    X_Proc_Period_Type,
    X_Start_Date,
    X_Comments,
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
--
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','pay_calendars_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Create a years worth of calendar by default.
   hr_budget_calendar.generate
     (x_period_set_name,
      x_midpoint_offset,
      1);
--
 END Insert_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a calendar by applying a lock on a calendar in the Define          --
 --   Budgetary Calendar form.                                              --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Period_Set_Name                       VARCHAR2,
                    X_Actual_Period_Type                    VARCHAR2,
                    X_Proc_Period_Type                      VARCHAR2,
                    X_Start_Date                            DATE,
                    X_Comments                              VARCHAR2,
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
                    X_Attribute20                           VARCHAR2) IS
--
   CURSOR C IS SELECT * FROM pay_calendars
               WHERE  rowid = X_Rowid FOR UPDATE of Period_Set_Name NOWAIT;
--
   Recinfo C%ROWTYPE;
--
 BEGIN
--
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','pay_calendars_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Remove trailing spaces.
   Recinfo.period_set_name := rtrim(Recinfo.period_set_name);
   Recinfo.actual_period_type := rtrim(Recinfo.actual_period_type);
   Recinfo.proc_period_type := rtrim(Recinfo.proc_period_type);
   Recinfo.comments := rtrim(Recinfo.comments);
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
   if (    (   (Recinfo.period_set_name = X_Period_Set_Name)
            OR (    (Recinfo.period_set_name IS NULL)
                AND (X_Period_Set_Name IS NULL)))
       AND (   (Recinfo.actual_period_type = X_Actual_Period_Type)
            OR (    (Recinfo.actual_period_type IS NULL)
                AND (X_Actual_Period_Type IS NULL)))
       AND (   (Recinfo.proc_period_type = X_Proc_Period_Type)
            OR (    (Recinfo.proc_period_type IS NULL)
                AND (X_Proc_Period_Type IS NULL)))
       AND (   (Recinfo.start_date = X_Start_Date)
            OR (    (Recinfo.start_date IS NULL)
                AND (X_Start_Date IS NULL)))
       AND (   (Recinfo.comments = X_Comments)
            OR (    (Recinfo.comments IS NULL)
                AND (X_Comments IS NULL)))
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
--
 END Lock_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a calendar via the--
 --   Define Budgetary Calendar form.                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Period_Set_Name                     VARCHAR2,
                      X_Actual_Period_Type                  VARCHAR2,
                      X_Proc_Period_Type                    VARCHAR2,
                      X_Start_Date                          DATE,
                      X_Comments                            VARCHAR2,
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
                      X_Attribute20                         VARCHAR2) IS
--
 BEGIN
--
   UPDATE pay_calendars
   SET period_set_name            =    X_Period_Set_Name,
       actual_period_type         =    X_Actual_Period_Type,
       proc_period_type           =    X_Proc_Period_Type,
       start_date                 =    X_Start_Date,
       comments                   =    X_Comments,
       attribute_category         =    X_Attribute_Category,
       attribute1                 =    X_Attribute1,
       attribute2                 =    X_Attribute2,
       attribute3                 =    X_Attribute3,
       attribute4                 =    X_Attribute4,
       attribute5                 =    X_Attribute5,
       attribute6                 =    X_Attribute6,
       attribute7                 =    X_Attribute7,
       attribute8                 =    X_Attribute8,
       attribute9                 =    X_Attribute9,
       attribute10                =    X_Attribute10,
       attribute11                =    X_Attribute11,
       attribute12                =    X_Attribute12,
       attribute13                =    X_Attribute13,
       attribute14                =    X_Attribute14,
       attribute15                =    X_Attribute15,
       attribute16                =    X_Attribute16,
       attribute17                =    X_Attribute17,
       attribute18                =    X_Attribute18,
       attribute19                =    X_Attribute19,
       attribute20                =    X_Attribute20
   WHERE rowid = X_rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','pay_calendars_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a calendar via the--
 --   Define Budgetary Calendar form.                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid           VARCHAR2,
 		      -- Extra Columns
 		      X_Period_Set_Name VARCHAR2) IS
 BEGIN
--
   -- New check procedure added to prevent delete of calendar record
   -- if per_budgets record of 'OTA_BUDGET' budget_type_code exists
   chk_budget_exists(X_Period_Set_Name);

   -- Remove all the time periods for the calendar NB. makes sure that the
   -- calendar has not been used for budgetting.
   hr_budget_calendar.remove
     (x_period_set_name,
      0,      -- number of years
      false); -- at least one year to be kept
--
   DELETE FROM pay_calendars
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','pay_calendars_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Delete_Row;
--
END PAY_CALENDARS_PKG;

/
