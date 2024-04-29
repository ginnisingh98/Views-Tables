--------------------------------------------------------
--  DDL for Package Body PER_ABT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABT_PKG" as
/* $Header: peabt01t.pkb 115.1 99/07/17 18:23:36 porting ship $ */
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
01/07/94  70.1      JRhodes     Chnaged Get_UOM to return only the lookup_code
				now that UOM is a checkbox on the form
23/11/94  70.4      rfine       Suppressed index on business_group_id
31/01/95  70.6      JRhodes     Removed AOL WHO Columns
21/07/95  70.7      aforte	Replaced tokenised messages, ALL_MANDATORY_FIELD		    amills	with hard coded messages ALL_MAN_HOU_FIELD
				ALL_MAN_INC_FIELD and ALL_MAN_VAL_FIELD.
04/03/97  70.8      JAlloun     Changed all occurances of system.dual
                                to sys.dual for next release requirements.
---------------------------------------------------------------------------*/
PROCEDURE Insert_Row(X_Rowid                        IN OUT VARCHAR2,
                     X_Absence_Attendance_Type_Id          IN OUT NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Input_Value_Id                      NUMBER,
                     X_Date_Effective                      DATE,
                     X_Name                                VARCHAR2,
                     X_Absence_Category                    VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            IN OUT DATE,
                     X_Hours_Or_Days                       VARCHAR2,
                     X_Inc_Or_Dec_Flag                     VARCHAR2,
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
                     X_Element_Type_ID                     NUMBER,
                     X_Element_End_Date                    DATE,
                     X_END_OF_TIME                         DATE
 ) IS
   CURSOR C IS
     SELECT rowid FROM PER_ABSENCE_ATTENDANCE_TYPES
     WHERE absence_attendance_type_id = X_Absence_Attendance_Type_Id;
--
   CURSOR C2 IS
     SELECT per_absence_attendance_types_s.nextval
     FROM sys.dual;
BEGIN
   -- check the uniqueness of the name
   --
   per_abt_pkg.check_unique_name(X_Rowid
                                ,X_Business_Group_Id
                                ,X_Name);
   --
   --
   per_abt_pkg.ensure_fields_populated(X_inc_or_dec_flag
                                      ,X_hours_or_days
                                      ,X_input_value_id
                                      ,X_element_type_id);
   --
   --
   per_abt_pkg.check_inputs_required(X_element_type_id
                                    ,X_Input_Value_Id );
   --
   --
   per_abt_pkg.val_date_end(X_date_end
                           ,X_element_end_date
                           ,X_end_of_time );
   --
   if (X_Absence_Attendance_Type_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Absence_Attendance_Type_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_ABSENCE_ATTENDANCE_TYPES(
          absence_attendance_type_id,
          business_group_id,
          input_value_id,
          date_effective,
          name,
          absence_category,
          comments,
          date_end,
          hours_or_days,
          increasing_or_decreasing_flag,
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
          X_Absence_Attendance_Type_Id,
          X_Business_Group_Id,
          X_Input_Value_Id,
          X_Date_Effective,
          X_Name,
          X_Absence_Category,
          X_Comments,
          X_Date_End,
          X_Hours_Or_Days,
          X_Inc_Or_Dec_Flag              ,
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
--
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','PER_ABT_PKG.Insert_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  CLOSE C;
--
  hrdyndbi.create_absence_dict(X_ABSENCE_ATTENDANCE_TYPE_ID);
--
END Insert_Row;
--
--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Absence_Attendance_Type_Id            NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Input_Value_Id                        NUMBER,
                   X_Date_Effective                        DATE,
                   X_Name                                  VARCHAR2,
                   X_Absence_Category                      VARCHAR2,
                   X_Comments                              VARCHAR2,
                   X_Date_End                              DATE,
                   X_Hours_Or_Days                         VARCHAR2,
                   X_Inc_Or_Dec_Flag                       VARCHAR2,
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
      FROM   PER_ABSENCE_ATTENDANCE_TYPES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Absence_Attendance_Type_Id NOWAIT;
  Recinfo C%ROWTYPE;
--
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','PER_ABT_PKG.Lock_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  CLOSE C;
--
Recinfo.Name := rtrim(Recinfo.Name);
Recinfo.Absence_Category := rtrim(Recinfo.Absence_Category);
Recinfo.Comments := rtrim(Recinfo.Comments);
Recinfo.Hours_Or_Days := rtrim(Recinfo.Hours_Or_Days);
Recinfo.increasing_or_decreasing_flag :=
                  rtrim(Recinfo.increasing_or_decreasing_flag);
Recinfo.Attribute_Category := rtrim(Recinfo.Attribute_Category);
Recinfo.Attribute1 := rtrim(Recinfo.Attribute1);
Recinfo.Attribute2 := rtrim(Recinfo.Attribute2);
Recinfo.Attribute3 := rtrim(Recinfo.Attribute3);
Recinfo.Attribute4 := rtrim(Recinfo.Attribute4);
Recinfo.Attribute5 := rtrim(Recinfo.Attribute5);
Recinfo.Attribute6 := rtrim(Recinfo.Attribute6);
Recinfo.Attribute7 := rtrim(Recinfo.Attribute7);
Recinfo.Attribute8 := rtrim(Recinfo.Attribute8);
Recinfo.Attribute9 := rtrim(Recinfo.Attribute9);
Recinfo.Attribute10 := rtrim(Recinfo.Attribute10);
Recinfo.Attribute11 := rtrim(Recinfo.Attribute11);
Recinfo.Attribute12 := rtrim(Recinfo.Attribute12);
Recinfo.Attribute13 := rtrim(Recinfo.Attribute13);
Recinfo.Attribute14 := rtrim(Recinfo.Attribute14);
Recinfo.Attribute15 := rtrim(Recinfo.Attribute15);
Recinfo.Attribute16 := rtrim(Recinfo.Attribute16);
Recinfo.Attribute17 := rtrim(Recinfo.Attribute17);
Recinfo.Attribute18 := rtrim(Recinfo.Attribute18);
Recinfo.Attribute19 := rtrim(Recinfo.Attribute19);
Recinfo.Attribute20 := rtrim(Recinfo.Attribute20);
--
  if (
          (   (Recinfo.absence_attendance_type_id = X_Absence_Attendance_Type_Id)
           OR (    (Recinfo.absence_attendance_type_id IS NULL)
               AND (X_Absence_Attendance_Type_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.input_value_id = X_Input_Value_Id)
           OR (    (Recinfo.input_value_id IS NULL)
               AND (X_Input_Value_Id IS NULL)))
      AND (   (Recinfo.date_effective = X_Date_Effective)
           OR (    (Recinfo.date_effective IS NULL)
               AND (X_Date_Effective IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.absence_category = X_Absence_Category)
           OR (    (Recinfo.absence_category IS NULL)
               AND (X_Absence_Category IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.date_end = X_Date_End)
           OR (    (Recinfo.date_end IS NULL)
               AND (X_Date_End IS NULL)))
      AND (   (Recinfo.hours_or_days = X_Hours_Or_Days)
           OR (    (Recinfo.hours_or_days IS NULL)
               AND (X_Hours_Or_Days IS NULL)))
      AND (   (Recinfo.increasing_or_decreasing_flag =
      X_Inc_Or_Dec_Flag              )
           OR (    (Recinfo.increasing_or_decreasing_flag IS NULL)
               AND (X_Inc_Or_Dec_Flag               IS NULL)))
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
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Absence_Attendance_Type_Id          NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Input_Value_Id                      NUMBER,
                     X_Date_Effective                      DATE,
                     X_Name                                VARCHAR2,
                     X_Absence_Category                    VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            IN OUT DATE,
                     X_Hours_Or_Days                       VARCHAR2,
                     X_Inc_Or_Dec_Flag                     VARCHAR2,
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
                     X_Element_Type_ID                     NUMBER,
                     X_Element_End_Date                    DATE,
                     X_END_OF_TIME                         DATE,
                     X_old_absence_category                VARCHAR2,
                     X_Old_Name                            VARCHAR2
) IS
BEGIN
   -- check the uniqueness of the name
   --
   per_abt_pkg.check_unique_name(X_Rowid
                                ,X_Business_Group_Id
                                ,X_Name);
   --
   --
   per_abt_pkg.ensure_fields_populated(X_inc_or_dec_flag
                                      ,X_hours_or_days
                                      ,X_input_value_id
                                      ,X_element_type_id);
   --
   --
   per_abt_pkg.check_inputs_required(X_element_type_id
                                    ,X_Input_Value_Id );
   --
   --
   per_abt_pkg.check_category(X_old_absence_category
                             ,X_absence_category
                             ,X_absence_attendance_type_id );
   --
   --
   per_abt_pkg.val_date_end(X_date_end
                           ,X_element_end_date
                           ,X_end_of_time );
   --
   --
  if X_Name <> X_Old_Name then
     hrdyndbi.delete_absence_dict(X_ABSENCE_ATTENDANCE_TYPE_ID);
  end if;
--
  UPDATE PER_ABSENCE_ATTENDANCE_TYPES
  SET
    absence_attendance_type_id                =    X_Absence_Attendance_Type_Id,
    business_group_id                         =    X_Business_Group_Id,
    input_value_id                            =    X_Input_Value_Id,
    date_effective                            =    X_Date_Effective,
    name                                      =    X_Name,
    absence_category                          =    X_Absence_Category,
    comments                                  =    X_Comments,
    date_end                                  =    X_Date_End,
    hours_or_days                             =    X_Hours_Or_Days,
    increasing_or_decreasing_flag          =    X_Inc_Or_Dec_Flag              ,
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
--
  if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','PER_ABT_PKG.Update_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
--
  if X_Name <> X_Old_Name then
     hrdyndbi.create_absence_dict(X_ABSENCE_ATTENDANCE_TYPE_ID);
  end if;
--
END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2
                    ,X_Absence_attendance_type_id NUMBER) IS
BEGIN
  --
hr_utility.set_location('per_abt_pkg.delete_row',1);
  per_abt_pkg.abt_del_validation(X_Absence_attendance_type_id);
  --
hr_utility.set_location('per_abt_pkg.delete_row',2);
  hrdyndbi.delete_absence_dict(X_Absence_attendance_type_id);
  --
hr_utility.set_location('per_abt_pkg.delete_row',3);
  DELETE FROM PER_ABSENCE_ATTENDANCE_TYPES
  WHERE  rowid = X_Rowid;
--
  if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','PER_ABT_PKG.Delete_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
END Delete_Row;
--
--
procedure check_unique_name(p_rowid varchar2
                           ,p_business_group_id number
                           ,p_name varchar2) is
--
cursor c is
   select ''
   from per_absence_attendance_types
   where upper(p_name) = upper(name)
   and   business_group_id + 0 = p_business_group_id
   and   (rowidtochar(rowid) <> p_rowid or p_rowid is null);
abt_rec c%rowtype;
--
begin
--
hr_utility.set_location('per_abt_pkg.check_unique_name',1);
  OPEN C;
  FETCH C INTO ABT_REC;
  if (C%FOUND) then
    CLOSE C;
      hr_utility.set_message(801,'PER_7806_DEF_ABS_EXISTS');
      hr_utility.raise_error;
  end if;
  CLOSE C;

end check_unique_name;
--
--
procedure validate_date_effective(p_date_effective DATE
                                 ,p_element_type_id NUMBER
                                 ,p_absence_attendance_type_id NUMBER) is
--
cursor c1 is
   select ''
   from   pay_element_types_f
   where  element_type_id = p_element_type_id
   and    p_date_effective between
          effective_start_date and effective_end_date;
elt_rec c1%rowtype;
--
cursor c2 is
   select ''
   from   per_absence_attendances
   where  absence_attendance_type_id = p_absence_attendance_type_id
   and    date_start < p_date_effective;
abs_rec c2%rowtype;
--
begin
--
hr_utility.set_location('per_abt_pkg.validate_date_effective',1);
  if p_element_type_id is not null then
     OPEN C1;
     FETCH C1 INTO ELT_REC;
     if (C1%NOTFOUND) then
       CLOSE C1;
         hr_utility.set_message(801,'HR_6789_ABS_NO_CHANGE_DATE');
         hr_utility.raise_error;
     end if;
     CLOSE C1;
  end if;
--
hr_utility.set_location('per_abt_pkg.validate_date_effective',2);
  if p_absence_attendance_type_id is not null then
     OPEN C2;
     FETCH C2 INTO ABS_REC;
     if (C2%FOUND) then
       CLOSE C2;
         hr_utility.set_message(801,'HR_6790_ABS_NO_CHANGE_2');
         hr_utility.raise_error;
     end if;
     CLOSE C2;
  end if;
--
end validate_date_effective;
--
--
procedure validate_element_name(p_element_type_id NUMBER
                               ,p_date_effective DATE
                               ,p_rowid VARCHAR2
                               ,p_default_value IN OUT VARCHAR2
                               ,p_input_value_name IN OUT VARCHAR2
                               ,p_input_value_id IN OUT NUMBER
                               ,p_value_uom IN OUT VARCHAR2
                               ,p_element_end_date IN OUT DATE) is
cursor c is
   select ipv.name
   ,      ipv.uom
   ,      ipv.input_value_id
   from   pay_input_values ipv
   ,      hr_lookups lkp
   where  ipv.element_type_id = p_element_type_id
   and    ipv.uom = lkp.lookup_code
   and    lkp.lookup_type = 'UNITS'
   and    lkp.lookup_code in
          ('ND','H_HH','H_DECIMAL1','H_DECIMAL2','H_DECIMAL3')
   and    p_date_effective between
          ipv.effective_start_date and ipv.effective_end_date;
--
IPV_REC  c%rowtype;
IPV_REC2 c%rowtype;
--
cursor c1(l_input_value_id NUMBER) is
    select ''
    from per_absence_attendance_types abt
    where abt.input_value_id = l_input_value_id
    and   p_rowid is not null
    and   chartorowid(p_rowid) <> abt.rowid;
--
ABT_REC c1%rowtype;
--
cursor c2 is
   select max(effective_end_date)
   from   pay_element_types_f
   where  element_type_id = p_element_type_id;
--
l_temp_iv NUMBER(22);
--
begin
--
/* If there is only one row returned by this statement then default the
   values otherwise nullify the values */
--
hr_utility.set_location('per_abt_pkg.validate_element_name',1);
  p_default_value := 'N';
  OPEN C;
  FETCH C INTO IPV_REC2;
  if (C%FOUND) then
     l_temp_iv := IPV_REC2.input_value_id;
     FETCH C INTO IPV_REC2;
     if (C%NOTFOUND) then
        OPEN C1(l_temp_iv);
        FETCH C1 INTO ABT_REC;
        if (C1%NOTFOUND) then
           IPV_REC := IPV_REC2;
           p_default_value := 'Y';
        end if;
        CLOSE C1;
     end if;
  end if;
  CLOSE C;
  --
  p_input_value_name := IPV_REC.name;
  p_input_value_id   := IPV_REC.input_value_id;
  p_value_uom        := IPV_REC.uom;
--
--
/* Get the maximum end date of the Element Type */
--
  p_element_end_date := null;
--
  OPEN C2;
  FETCH C2 INTO p_element_end_date;
  CLOSE C2;
--
end validate_element_name;
--
--
procedure get_uom(p_value_uom varchar2
                 ,p_hours_or_days IN OUT varchar2) is
--
cursor c is
   select lookup_code
   from   hr_lookups
   where  lookup_type = 'HOURS_OR_DAYS'
   and    lookup_code = 'H'
   and    p_value_uom in
         ('H_HH','H_DECIMAL1','H_DECIMAL2','H_DECIMAL3');
LKP_REC c%rowtype;
--
begin
--
hr_utility.set_location('per_abt_pkg.get_uom',1);
  OPEN C;
  FETCH C INTO LKP_REC;
  if (C%FOUND) then
     p_hours_or_days := LKP_REC.lookup_code;
  end if;
  CLOSE C;
--
end;
--
--
procedure ensure_fields_populated(p_inc_or_dec_flag VARCHAR2
                                 ,p_hours_or_days VARCHAR2
                                 ,p_input_value_id NUMBER
                                 ,p_element_type_id NUMBER) is
begin
--
hr_utility.set_location('per_abt_pkg.ensure_fields_populated',1);
   if p_element_type_id is not null then
   --
      if p_input_value_id is null then
         hr_utility.set_message(801,'HR_7572_ALL_MAN_VAL_FIELD');
         hr_utility.raise_error;
      end if;
      if p_hours_or_days is null then
         hr_utility.set_message(801,'HR_7582_ALL_MAN_HOU_FIELD');
         hr_utility.raise_error;
      end if;
      if p_inc_or_dec_flag is null then
         hr_utility.set_message(801,'HR_7583_ALL_MAN_INC_FIELD');
         hr_utility.raise_error;
      end if;
   end if;
--
end ensure_fields_populated;
--
--
procedure check_inputs_required(p_element_type_id NUMBER
                               ,p_input_value_id NUMBER) is
--
cursor c is
   select ''
   from   pay_input_values
   where  element_type_id = p_element_type_id
   and    input_value_id  <> p_input_value_id
   and  ((hot_default_flag = 'N'
      and mandatory_flag = 'Y')
     or  (hot_default_flag = 'Y'
      and default_value is null));
ipv_rec c%rowtype;
--
begin
--
hr_utility.set_location('per_abt_pkg.check_inputs_required',1);
  OPEN C;
  FETCH C INTO IPV_REC;
  if (C%FOUND) then
       CLOSE C;
         hr_utility.set_message(801,'PER_7717_ABS_IPVAL_EXISTS');
         hr_utility.raise_error;
  end if;
  CLOSE C;
--
end check_inputs_required;
--
--
procedure check_category(p_old_absence_category VARCHAR2
                        ,p_new_absence_category VARCHAR2
                        ,p_absence_attendance_type_id NUMBER) is
--
cursor c is
   select ''
   from   per_absence_attendances
   where  absence_attendance_type_id = p_absence_attendance_type_id;
abs_rec c%rowtype;
--
begin
hr_utility.set_location('per_abt_pkg.check_category',1);
  if p_old_absence_category is null or
     p_old_absence_category = p_new_absence_category then
     null;
  else
     OPEN C;
     FETCH C INTO ABS_REC;
     if (C%FOUND) then
          CLOSE C;
          hr_utility.set_message(801,'HR_6383_ABS_DET_NO_CHANGE');
          hr_utility.raise_error;
     end if;
     CLOSE C;
  end if;
end check_category;
--
--
procedure val_date_end(p_date_end IN OUT DATE
                      ,p_element_end_date DATE
                      ,p_end_of_time DATE) is
begin
hr_utility.set_location('per_abt_pkg.val_date_end',1);
  if p_date_end is null then
     if p_element_end_date is null or
        p_element_end_date = p_end_of_time then
        null;
     else
        p_date_end := p_element_end_date;
     end if;
  else
     if p_element_end_date is not null and p_element_end_date < p_date_end
      or p_element_end_date is null and p_end_of_time < p_date_end then
         hr_utility.set_message(801,'PER_7800_DEF_ABS_ELEMENT_ENDS');
         hr_utility.raise_error;
     end if;
  end if;
end val_date_end;
--
--
procedure abt_del_validation(p_absence_attendance_type_id NUMBER) is
--
l_exists VARCHAR2(1);
--
cursor c1 is
   select ''
   from per_absence_attendances
   where absence_attendance_type_id = p_absence_attendance_type_id;
--
cursor c2 is
   select ''
   from per_abs_attendance_reasons
   where absence_attendance_type_id = p_absence_attendance_type_id;
--
begin
--
hr_utility.set_location('per_abt_pkg.abt_del_validation',1);
     OPEN C1;
     FETCH C1 INTO l_exists;
     if (C1%FOUND) then
          CLOSE C1;
          hr_utility.set_message(801,'PER_7059_EMP_ABS_DEL_TYPE');
          hr_utility.raise_error;
     end if;
     CLOSE C1;
--
hr_utility.set_location('per_abt_pkg.abt_del_validation',2);
     OPEN C2;
     FETCH C2 INTO l_exists;
     if (C2%FOUND) then
          CLOSE C2;
          hr_utility.set_message(801,'PER_7805_DEF_ABS_DEL_REASON');
          hr_utility.raise_error;
     end if;
     CLOSE C2;
--
end abt_del_validation;
--
END PER_ABT_PKG;

/
