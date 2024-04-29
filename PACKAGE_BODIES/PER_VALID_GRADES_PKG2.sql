--------------------------------------------------------
--  DDL for Package Body PER_VALID_GRADES_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VALID_GRADES_PKG2" as
/* $Header: pevgr02t.pkb 120.1 2005/10/03 12:04:46 hsajja noship $ */

Procedure check_duplicate_valid_grade (X_Rowid VARCHAR2,
                                       X_Business_Group_Id NUMBER,
                                       X_Position_Id NUMBER,
                                       X_Grade_Id NUMBER,
                                       X_Date_from DATE,
                                       X_Date_to DATE,
                                       x_end_of_time DATE) is

          l_exists  boolean;

          l_dummy varchar2(1);

          cursor csr_exists is
          SELECT '1'
          FROM     PER_VALID_GRADES VG
          WHERE    (ROWID <> X_Rowid
          OR       X_Rowid IS NULL)
          AND      VG.business_group_id + 0 = X_Business_Group_Id
          AND      VG.POSITION_ID = X_Position_Id
          AND      VG.GRADE_ID = X_Grade_Id
          AND      (nvl(vg.date_to,x_end_of_time) >=  X_Date_from
                    and vg.date_from <=  nvl(X_Date_to,x_end_of_time));
begin
     open csr_exists;
     fetch csr_exists into l_dummy;
     l_exists := csr_exists%found;
     close csr_exists;
     if l_exists then
       hr_utility.set_message(800,'PER_POS_GRD_DATES_EXISTS');
       hr_utility.raise_error;
    end if;

end check_duplicate_valid_grade;

procedure check_valid_grade_date_to (x_end_of_time date,
                                     X_Date_To date,
                                     x_pst1_date_end date,
                                     x_grade_id number)  is

          l_exists  boolean;
          l_date_to date;

          cursor csr_exists is
          select g.date_to
          from    per_grades g
          where   g.grade_id = x_grade_id
          and     nvl(X_Date_To,x_end_of_time) >
          nvl(g.date_to, x_end_of_time);

begin


  -- valid grade date_to can not exceed position date_to.

    if nvl(X_Date_To,x_end_of_time) > nvl(x_pst1_date_end,x_end_of_time) then
       hr_utility.set_message(801,'PER_7826_DEF_GRD_JOB_END_JOB');
       hr_utility.set_message_token('DATE',x_pst1_date_end);
       hr_utility.raise_error;
    end if;

  -- valid grade date_to can not exceed grade date_to.

    open csr_exists;
    fetch csr_exists into l_date_to;
    l_exists := csr_exists%found;
    close csr_exists;
    if l_exists then
       hr_utility.set_message(801,'PER_7872_DEF_GRD_POS_END_POS');
       hr_utility.set_message_token('DATE',l_date_to);
       hr_utility.raise_error;
    end if;

end check_valid_grade_date_to;


procedure check_valid_grade_date_from (x_Date_From date,
                                       x_pst1_date_effective date,
                                       x_grade_id number)  is

          l_exists  boolean;
          l_date_from date;

          cursor csr_exists is
          select g.date_from
          from    per_grades g
          where   g.grade_id = x_grade_id
          and     x_Date_from < g.date_from;

begin

    if x_Date_From >= x_pst1_date_effective then
       open csr_exists;
       fetch csr_exists into l_date_from;
       l_exists := csr_exists%found;
       close csr_exists;

   -- valid grade date_from can not preceed grade date_from.

       if l_exists then
          hr_utility.set_message(801,'PER_7871_DEF_POS_GRD_START_GRD');
          hr_utility.set_message_token('DATE',l_date_from);
          hr_utility.raise_error;
       end if;

   -- valid grade date_from can not preceed position date_from.

    else
        hr_utility.set_message(801,'PER_7870_DEF_POS_GRD_START_POS');
        hr_utility.set_message_token('DATE',x_pst1_date_effective);
        hr_utility.raise_error;
    end if;

end check_valid_grade_date_from;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Valid_Grade_Id               IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Date_From                           DATE,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Job_Id                              NUMBER,
                     X_Position_Id                         NUMBER,
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
                     x_end_of_time                         DATE,
                     x_pst1_date_end                       DATE,
                     x_pst1_date_effective                 DATE
 ) IS
   CURSOR C IS SELECT rowid FROM PER_VALID_GRADES

             WHERE valid_grade_id = X_Valid_Grade_Id;





    CURSOR C2 IS SELECT per_valid_grades_s.nextval FROM sys.dual;
BEGIN

     -- date to must be greater than date from.

     if x_date_from > nvl(x_date_to,x_end_of_time) then
       hr_utility.set_message(801,'HR_6021_ALL_START_END_DATE');
       hr_utility.raise_error;
     end if;

   check_duplicate_valid_grade(X_Rowid ,
                               X_Business_Group_Id ,
                               X_Position_Id ,
                               X_Grade_Id,
                               X_Date_From,
                               X_Date_To,
                               x_end_of_time  );

   check_valid_grade_date_to(x_end_of_time ,
                             X_Date_To ,
                             x_pst1_date_end ,
                             x_grade_id );

   check_valid_grade_date_from(x_Date_From ,
                               x_pst1_date_effective ,
                               x_grade_id);

   if (X_Valid_Grade_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Valid_Grade_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_VALID_GRADES(
          valid_grade_id,
          business_group_id,
          grade_id,
          date_from,
          comments,
          date_to,
          job_id,
          position_id,
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
          X_Valid_Grade_Id,
          X_Business_Group_Id,
          X_Grade_Id,
          X_Date_From,
          X_Comments,
          X_Date_To,
          X_Job_Id,
          X_Position_Id,
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
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Insert_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Valid_Grade_Id                        NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Grade_Id                              NUMBER,
                   X_Date_From                             DATE,
                   X_Comments                              VARCHAR2,
                   X_Date_To                               DATE,
                   X_Job_Id                                NUMBER,
                   X_Position_Id                           NUMBER,
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
      FROM   PER_VALID_GRADES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Valid_Grade_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','lock_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
--
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
  if (
          (   (Recinfo.valid_grade_id = X_Valid_Grade_Id)
           OR (    (Recinfo.valid_grade_id IS NULL)
               AND (X_Valid_Grade_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.grade_id = X_Grade_Id)
           OR (    (Recinfo.grade_id IS NULL)
               AND (X_Grade_Id IS NULL)))
      AND (   (Recinfo.date_from = X_Date_From)
           OR (    (Recinfo.date_from IS NULL)
               AND (X_Date_From IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.date_to = X_Date_To)
           OR (    (Recinfo.date_to IS NULL)
               AND (X_Date_To IS NULL)))
      AND (   (Recinfo.job_id = X_Job_Id)
           OR (    (Recinfo.job_id IS NULL)
               AND (X_Job_Id IS NULL)))
      AND (   (Recinfo.position_id = X_Position_Id)
           OR (    (Recinfo.position_id IS NULL)
               AND (X_Position_Id IS NULL)))
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
                     X_Valid_Grade_Id                      NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Date_From                           DATE,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Job_Id                              NUMBER,
                     X_Position_Id                         NUMBER,
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
                     x_end_of_time                         DATE,
                     x_pst1_date_end                       DATE,
                     x_pst1_date_effective                 DATE
) IS
BEGIN

  -- date to must be greater than date from.

  if x_date_from > nvl(x_date_to,x_end_of_time) then
    hr_utility.set_message(801,'HR_6021_ALL_START_END_DATE');
    hr_utility.raise_error;
  end if;

  check_duplicate_valid_grade(X_Rowid ,
                               X_Business_Group_Id ,
                               X_Position_Id ,
                               X_Grade_Id,
                               X_Date_From,
                               X_Date_To,
                               x_end_of_time );

  check_valid_grade_date_to(x_end_of_time ,
                             X_Date_To ,
                             x_pst1_date_end ,
                             x_grade_id );

  check_valid_grade_date_from(x_Date_From ,
                               x_pst1_date_effective ,
                               x_grade_id);

  UPDATE PER_VALID_GRADES
  SET

    valid_grade_id                            =    X_Valid_Grade_Id,
    business_group_id                         =    X_Business_Group_Id,
    grade_id                                  =    X_Grade_Id,
    date_from                                 =    X_Date_From,
    comments                                  =    X_Comments,
    date_to                                   =    X_Date_To,
    job_id                                    =    X_Job_Id,
    position_id                               =    X_Position_Id,
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
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','update_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PER_VALID_GRADES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','delete_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
END Delete_Row;

END PER_VALID_GRADES_PKG2;

/
