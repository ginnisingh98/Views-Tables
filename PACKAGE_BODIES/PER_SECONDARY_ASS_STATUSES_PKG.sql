--------------------------------------------------------
--  DDL for Package Body PER_SECONDARY_ASS_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SECONDARY_ASS_STATUSES_PKG" as
/* $Header: pesas01t.pkb 115.2 2003/02/10 17:09:39 eumenyio ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
/*-----------------------------------------------------------------------------

Description
-----------


History
-------
Date       Author      Version  Description
---------  ----------  ------   ----------------------------------
18-Apr-93  JRhodes     80.1     Changed Lock-Row to rtrim varchar2 columns
27-Jan-95  JRhodes     70.5     Removed AOL WHO Columns
05-Mar-97  JAlloun     70.6     Changed all occurances of system.dual to
                                sys.dual for next release requirements.
-----------------------------------------------------------------------------*/

procedure check_unique_row(p_assignment_id number
                          ,p_assignment_status_type_id number
                          ,p_start_date date
                          ,p_rowid varchar2);
--
procedure validate_date(p_assignment_id number
                       ,p_date date
                       ,p_date_type varchar2);
--
procedure validate_start_end_date(p_start_date date
                                 ,p_end_date date);
--
function set_end_date(p_assignment_id number
                     ,p_end_date date) return date;
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Secondary_Ass_Status_Id             IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Assignment_Status_Type_Id           NUMBER,
                     X_Start_Date                          DATE,
                     X_Comments                            VARCHAR2,
                     X_End_Date                            IN OUT NOCOPY DATE,
                     X_Reason                              VARCHAR2,
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
   CURSOR C IS SELECT rowid FROM PER_SECONDARY_ASS_STATUSES
             WHERE secondary_ass_status_id = X_Secondary_Ass_Status_Id;

    CURSOR C2 IS SELECT per_secondary_ass_statuses_s.nextval FROM sys.dual;
BEGIN
--
   check_unique_row(X_Assignment_Id
                   ,X_Assignment_Status_Type_Id
                   ,X_Start_Date
                   ,X_Rowid);
--
   validate_date(X_Assignment_Id
                ,X_Start_Date
                ,'S');
--
   if X_End_Date is not null then
      validate_date(X_Assignment_Id
                   ,X_End_Date
                   ,'E');
      --
      validate_start_end_date(X_Start_Date
                             ,X_End_Date);
      --
   end if;
--
   X_End_Date := set_end_date(X_Assignment_Id,X_End_Date);
--
   if (X_Secondary_Ass_Status_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Secondary_Ass_Status_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_SECONDARY_ASS_STATUSES(
          secondary_ass_status_id,
          business_group_id,
          assignment_id,
          assignment_status_type_id,
          start_date,
          comments,
          end_date,
          reason,
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
          X_Secondary_Ass_Status_Id,
          X_Business_Group_Id,
          X_Assignment_Id,
          X_Assignment_Status_Type_Id,
          X_Start_Date,
          X_Comments,
          X_End_Date,
          X_Reason,
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
                   X_Secondary_Ass_Status_Id               NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Assignment_Id                         NUMBER,
                   X_Assignment_Status_Type_Id             NUMBER,
                   X_Start_Date                            DATE,
                   X_Comments                              VARCHAR2,
                   X_End_Date                              DATE,
                   X_Reason                                VARCHAR2,
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
      FROM   PER_SECONDARY_ASS_STATUSES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Secondary_Ass_Status_Id NOWAIT;
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
Recinfo.comments := rtrim(Recinfo.comments);
Recinfo.reason := rtrim(Recinfo.reason);
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
          (   (Recinfo.secondary_ass_status_id = X_Secondary_Ass_Status_Id)
           OR (    (Recinfo.secondary_ass_status_id IS NULL)
               AND (X_Secondary_Ass_Status_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.assignment_id = X_Assignment_Id)
           OR (    (Recinfo.assignment_id IS NULL)
               AND (X_Assignment_Id IS NULL)))
      AND (   (Recinfo.assignment_status_type_id = X_Assignment_Status_Type_Id)
           OR (    (Recinfo.assignment_status_type_id IS NULL)
               AND (X_Assignment_Status_Type_Id IS NULL)))
      AND (   (Recinfo.start_date = X_Start_Date)
           OR (    (Recinfo.start_date IS NULL)
               AND (X_Start_Date IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.end_date = X_End_Date)
           OR (    (Recinfo.end_date IS NULL)
               AND (X_End_Date IS NULL)))
      AND (   (Recinfo.reason = X_Reason)
           OR (    (Recinfo.reason IS NULL)
               AND (X_Reason IS NULL)))
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

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Secondary_Ass_Status_Id             NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Assignment_Status_Type_Id           NUMBER,
                     X_Start_Date                          DATE,
                     X_Comments                            VARCHAR2,
                     X_End_Date                            IN OUT NOCOPY DATE,
                     X_Reason                              VARCHAR2,
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
--
   check_unique_row(X_Assignment_Id
                   ,X_Assignment_Status_Type_Id
                   ,X_Start_Date
                   ,X_Rowid);
--
   validate_date(X_Assignment_Id
                ,X_Start_Date
                ,'S');
--
   if X_End_Date is not null then
      validate_date(X_Assignment_Id
                   ,X_End_Date
                   ,'E');
      --
      validate_start_end_date(X_Start_Date
                             ,X_End_Date);
   end if;
--
   X_End_Date := set_end_date(X_Assignment_Id,X_End_Date);
--
  UPDATE PER_SECONDARY_ASS_STATUSES
  SET
    secondary_ass_status_id                   =    X_Secondary_Ass_Status_Id,
    business_group_id                         =    X_Business_Group_Id,
    assignment_id                             =    X_Assignment_Id,
    assignment_status_type_id                 =    X_Assignment_Status_Type_Id,
    start_date                                =    X_Start_Date,
    comments                                  =    X_Comments,
    end_date                                  =    X_End_Date,
    reason                                    =    X_Reason,
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
  DELETE FROM PER_SECONDARY_ASS_STATUSES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--
--
procedure check_unique_row(p_assignment_id number
                          ,p_assignment_status_type_id number
                          ,p_start_date date
                          ,p_rowid varchar2) is
cursor c is
select 'x'
from   per_secondary_ass_statuses
where  assignment_id = p_assignment_id
and    assignment_status_type_id = p_assignment_status_type_id
and    start_date = p_start_date
AND    ((p_rowid IS NULL)
OR      (p_rowid is not null and
         rowid <> chartorowid(p_rowid))
       );
l_exists varchar2(1);
begin
  open c;
  fetch c into l_exists;
  if c%found then
     close c;
     hr_utility.set_message(801,'HR_6436_EMP_STATUS_STAT_EXIST');
     hr_utility.raise_error;
  end if;
  close c;
end check_unique_row;
--
--
procedure validate_date(p_assignment_id number
                       ,p_date date
                       ,p_date_type varchar2) is
cursor c is
select 'x'
from    per_assignments_f x
where   x.assignment_id = p_assignment_id
and     p_date >=
          (select min(y.effective_start_date)
           from   per_assignments_f y
           where  y.assignment_id = x.assignment_id)
and     p_date <=
          (select max(y.effective_end_date)
           from   per_assignments_f y
           where  y.assignment_id = x.assignment_id);
--
l_exists varchar2(1);
begin
   open c;
   fetch c into l_exists;
   if c%notfound then
      close c;
      if p_date_type = 'S' then
         hr_utility.set_message(801,'HR_6464_EMP_STATUS_ASS_DATE');
      else
         hr_utility.set_message(801,'HR_6851_EMP_STATUS_END_DATE');
      end if;
      hr_utility.raise_error;
   end if;
   close c;
end validate_date;
--
--
procedure validate_start_end_date(p_start_date date
                                 ,p_end_date date) is
begin
   if p_start_date > p_end_date then
      hr_utility.set_message(801,'HR_6021_ALL_START_END_DATE');
      hr_utility.raise_error;
   end if;
end validate_start_end_date;
--
--
function set_end_date(p_assignment_id number
                     ,p_end_date date) return date is
cursor c is
select max(effective_end_date)
from per_assignments_f
where assignment_id = p_assignment_id;
--
l_new_end_date date;
begin
   if p_end_date is not null then
      l_new_end_date := p_end_date;
   else
      open c;
      fetch c into l_new_end_date;
      close c;
   end if;
--
   if l_new_end_date <> hr_general.end_of_time then
      return(l_new_end_date);
   else
      return(null);
   end if;
end set_end_date;
--
--
END PER_SECONDARY_ASS_STATUSES_PKG;

/
