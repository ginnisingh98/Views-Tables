--------------------------------------------------------
--  DDL for Package Body PER_ABS_ATTENDANCE_REASONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABS_ATTENDANCE_REASONS_PKG" as
/* $Header: peaar01t.pkb 115.0 99/07/17 18:23:02 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
/*-----------------------------------------------------------------------------

Description
-----------

Date      Version   Author      Description
--------  -------   ---------   ---------------
17/02/94  80.0      JRhodes     Initial Version
14/04/94  80.1      JRhodes     Modified Lock-Row to rtrim VARCHAR2
04/03/97  80.2      JAlloun     Changed all occurances of system.dual
                                to sys.dual for next release requirements.

-----------------------------------------------------------------------------*/
PROCEDURE Insert_Row(X_Rowid                        IN OUT VARCHAR2,
                     X_Abs_Attendance_Reason_Id            IN OUT NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Absence_Attendance_Type_Id          NUMBER,
                     X_Name                                VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE
 ) IS
--
   CURSOR C IS
      SELECT rowid
      FROM PER_ABS_ATTENDANCE_REASONS
      WHERE abs_attendance_reason_id = X_Abs_Attendance_Reason_Id;
--
    CURSOR C2 IS
      SELECT per_abs_attendance_reasons_s.nextval
      FROM sys.dual;
--
BEGIN
   --
   check_unique_reason(X_Rowid
                      ,X_Name
                      ,X_Absence_Attendance_Type_Id);
   --
   if (X_Abs_Attendance_Reason_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Abs_Attendance_Reason_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_ABS_ATTENDANCE_REASONS(
          abs_attendance_reason_id,
          business_group_id,
          absence_attendance_type_id,
          name,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date
         ) VALUES (
          X_Abs_Attendance_Reason_Id,
          X_Business_Group_Id,
          X_Absence_Attendance_Type_Id,
          X_Name,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Created_By,
          X_Creation_Date
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
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Abs_Attendance_Reason_Id              NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Absence_Attendance_Type_Id            NUMBER,
                   X_Name                                  VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PER_ABS_ATTENDANCE_REASONS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Abs_Attendance_Reason_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
--
Recinfo.Name := rtrim(Recinfo.Name);
--
  if (
          (   (Recinfo.abs_attendance_reason_id = X_Abs_Attendance_Reason_Id)
           OR (    (Recinfo.abs_attendance_reason_id IS NULL)
               AND (X_Abs_Attendance_Reason_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.absence_attendance_type_id = X_Absence_Attendance_Type_Id)
           OR (    (Recinfo.absence_attendance_type_id IS NULL)
               AND (X_Absence_Attendance_Type_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Abs_Attendance_Reason_Id            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Absence_Attendance_Type_Id          NUMBER,
                     X_Name                                VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER
) IS
BEGIN
   --
   check_unique_reason(X_Rowid
                      ,X_Name
                      ,X_Absence_Attendance_Type_Id);
   --
  UPDATE PER_ABS_ATTENDANCE_REASONS
  SET
    abs_attendance_reason_id                  =    X_Abs_Attendance_Reason_Id,
    business_group_id                         =    X_Business_Group_Id,
    absence_attendance_type_id                =    X_Absence_Attendance_Type_Id,
    name                                      =    X_Name,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login
  WHERE rowid = X_rowid;
--
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
--
END Update_Row;
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2
                    ,X_abs_attendance_reason_id NUMBER) IS
BEGIN
  --
  abr_del_validation(X_abs_attendance_reason_id);
  --
  DELETE FROM PER_ABS_ATTENDANCE_REASONS
  WHERE  rowid = X_Rowid;
--
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--
PROCEDURE Get_Name(X_CODE Varchar2
                  ,X_MEANING IN OUT Varchar2) is
cursor c is
   select meaning
   from   hr_lookups
   where  lookup_code = X_CODE
   and    lookup_type = 'ABSENCE_REASON';
--
begin
hr_utility.set_location('per_abs_attendance_reasons_pkg.Get_Name',1);
   OPEN C;
   FETCH C INTO X_MEANING;
   CLOSE C;
end Get_Name;
--
PROCEDURE abr_del_validation(p_abs_attendance_reason_id NUMBER) is
--
cursor c is
   select ''
   from   per_absence_attendances
   where  ABS_ATTENDANCE_REASON_ID =p_abs_attendance_reason_id;
abs_rec c%rowtype;
--
begin
hr_utility.set_location('per_abs_attendance_reasons_pkg.abr_del_validation',1);
     OPEN C;
     FETCH C INTO abs_rec;
     if (C%FOUND) then
          CLOSE C;
          hr_utility.set_message(801,'PER_7060_EMP_ABS_DEL_REAS');
          hr_utility.raise_error;
     end if;
     CLOSE C;
end;
--
--
PROCEDURE check_unique_reason(p_rowid VARCHAR2
                             ,p_name VARCHAR2
                             ,p_absence_attendance_type_id NUMBER) is
--
cursor c is
   select ''
   from   per_abs_attendance_reasons
   where  absence_attendance_type_id = p_absence_attendance_type_id
   and    name = p_name
   and   (p_rowid is null
      or (p_rowid is not null
      and rowid = chartorowid(p_rowid)));
abr_rec c%rowtype;
--
begin
hr_utility.set_location('per_abs_attendance_reasons_pkg.check_unique_reason',1);
  OPEN C;
     FETCH C INTO abr_rec;
     if (C%FOUND) then
          CLOSE C;
          hr_utility.set_message(801,'PER_7807_DEF_ABS_REASON_EXIST');
          hr_utility.raise_error;
     end if;
     CLOSE C;
end check_unique_reason;
--
--
END PER_ABS_ATTENDANCE_REASONS_PKG;

/
