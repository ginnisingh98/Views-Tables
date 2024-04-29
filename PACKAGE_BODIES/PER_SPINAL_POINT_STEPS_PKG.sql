--------------------------------------------------------
--  DDL for Package Body PER_SPINAL_POINT_STEPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPINAL_POINT_STEPS_PKG" as
/* $Header: pesps01t.pkb 120.0 2005/05/31 21:35:53 appldev noship $ */

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Step_Id                      IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Spinal_Point_Id                     NUMBER,
                     X_Grade_Spine_Id                      NUMBER,
                     X_Sequence                            NUMBER,
                     X_request_id                          NUMBER,
                     X_program_application_id              NUMBER,
                     X_program_id                          NUMBER,
                     X_program_update_date                 DATE,
                     X_Information1                        VARCHAR2,
                     X_Information2                        VARCHAR2,
                     X_Information3                        VARCHAR2,
                     X_Information4                        VARCHAR2,
                     X_Information5                        VARCHAR2,
                     X_Information6                        VARCHAR2,
                     X_Information7                        VARCHAR2,
                     X_Information8                        VARCHAR2,
                     X_Information9                        VARCHAR2,
                     X_Information10                       VARCHAR2,
                     X_Information11                       VARCHAR2,
                     X_Information12                       VARCHAR2,
                     X_Information13                       VARCHAR2,
                     X_Information14                       VARCHAR2,
                     X_Information15                       VARCHAR2,
                     X_Information16                       VARCHAR2,
                     X_Information17                       VARCHAR2,
                     X_Information18                       VARCHAR2,
                     X_Information19                       VARCHAR2,
                     X_Information20                       VARCHAR2,
                     X_Information21                       VARCHAR2,
                     X_Information22                       VARCHAR2,
                     X_Information23                       VARCHAR2,
                     X_Information24                       VARCHAR2,
                     X_Information25                       VARCHAR2,
                     X_Information26                       VARCHAR2,
                     X_Information27                       VARCHAR2,
                     X_Information28                       VARCHAR2,
                     X_Information29                       VARCHAR2,
                     X_Information30                       VARCHAR2,
                     X_Information_category                VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM per_spinal_point_steps
             WHERE  step_id = X_step_id;

    CURSOR C2 IS SELECT per_spinal_point_steps_s.nextval FROM sys.dual;
BEGIN
   if (X_step_id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_step_id;
     CLOSE C2;
   end if;
  INSERT INTO per_spinal_point_steps(
          step_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          spinal_point_id,
          grade_spine_id,
          sequence,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          information1,
          information2,
          information3,
          information4,
          information5,
          information6,
          information7,
          information8,
          information9,
          information10,
          information11,
          information12,
          information13,
          information14,
          information15,
          information16,
          information17,
          information18,
          information19,
          information20,
          information21,
          information22,
          information23,
          information24,
          information25,
          information26,
          information27,
          information28,
          information29,
          information30,
          information_category
         ) VALUES (
          X_Step_Id,
          X_Effective_Start_Date,
          X_Effective_End_Date,
          X_Business_Group_Id,
          X_Spinal_Point_Id,
          X_Grade_Spine_Id,
          X_Sequence,
          X_request_id,
          X_program_application_id,
          X_program_id,
          X_program_update_date,
          X_Information1,
          X_Information2,
          X_Information3,
          X_Information4,
          X_Information5,
          X_Information6,
          X_Information7,
          X_Information8,
          X_Information9,
          X_Information10,
          X_Information11,
          X_Information12,
          X_Information13,
          X_Information14,
          X_Information15,
          X_Information16,
          X_Information17,
          X_Information18,
          X_Information19,
          X_Information20,
          X_Information21,
          X_Information22,
          X_Information23,
          X_Information24,
          X_Information25,
          X_Information26,
          X_Information27,
          X_Information28,
          X_Information29,
          X_Information30,
          X_Information_category
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
                   X_Step_Id                               NUMBER,
                   X_Effective_Start_Date                  DATE,
                   X_Effective_End_Date                    DATE,
                   X_Business_Group_Id                     NUMBER,
                   X_Spinal_Point_Id                       NUMBER,
                   X_Grade_Spine_Id                        NUMBER,
                   X_Sequence                              NUMBER,
                   X_request_id                            NUMBER,
                   X_program_application_id                NUMBER,
                   X_program_id                            NUMBER,
                   X_program_update_date                   DATE,
                   X_Information1                          VARCHAR2,
                   X_Information2                          VARCHAR2,
                   X_Information3                          VARCHAR2,
                   X_Information4                          VARCHAR2,
                   X_Information5                          VARCHAR2,
                   X_Information6                          VARCHAR2,
                   X_Information7                          VARCHAR2,
                   X_Information8                          VARCHAR2,
                   X_Information9                          VARCHAR2,
                   X_Information10                         VARCHAR2,
                   X_Information11                         VARCHAR2,
                   X_Information12                         VARCHAR2,
                   X_Information13                         VARCHAR2,
                   X_Information14                         VARCHAR2,
                   X_Information15                         VARCHAR2,
                   X_Information16                         VARCHAR2,
                   X_Information17                         VARCHAR2,
                   X_Information18                         VARCHAR2,
                   X_Information19                         VARCHAR2,
                   X_Information20                         VARCHAR2,
                   X_Information21                         VARCHAR2,
                   X_Information22                         VARCHAR2,
                   X_Information23                         VARCHAR2,
                   X_Information24                         VARCHAR2,
                   X_Information25                         VARCHAR2,
                   X_Information26                         VARCHAR2,
                   X_Information27                         VARCHAR2,
                   X_Information28                         VARCHAR2,
                   X_Information29                         VARCHAR2,
                   X_Information30                         VARCHAR2,
                   X_Information_category                  VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   per_spinal_point_steps
      WHERE  rowid = chartorowid(X_Rowid)
      FOR UPDATE of step_id            NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if ( (   (Recinfo.step_id = X_Step_Id)
           OR (    (Recinfo.step_id IS NULL)
               AND (X_Step_Id IS NULL)))
      AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
           OR (    (Recinfo.effective_start_date IS NULL)
               AND (X_Effective_Start_Date IS NULL)))
      AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
           OR (    (Recinfo.effective_end_date IS NULL)
               AND (X_Effective_End_Date IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.spinal_point_id = X_Spinal_Point_Id)
           OR (    (Recinfo.spinal_point_id IS NULL)
               AND (X_Spinal_Point_Id IS NULL)))
      AND (   (Recinfo.grade_spine_id = X_Grade_Spine_Id)
           OR (    (Recinfo.grade_spine_id IS NULL)
               AND (X_Grade_Spine_Id IS NULL)))
      AND (   (Recinfo.sequence = X_Sequence)
           OR (    (Recinfo.sequence IS NULL)
               AND (X_Sequence IS NULL)))
      AND (   (Recinfo.request_id = X_request_id)
           OR (    (Recinfo.request_id IS NULL)
               AND (X_request_id IS NULL)))
      AND (   (Recinfo.program_application_id = X_program_application_id)
           OR (    (Recinfo.program_application_id IS NULL)
               AND (X_program_application_id IS NULL)))
      AND (   (Recinfo.program_id = X_program_id)
           OR (    (Recinfo.program_id IS NULL)
               AND (X_program_id IS NULL)))
      AND (   (Recinfo.program_update_date = X_program_update_date)
           OR (    (Recinfo.program_update_date IS NULL)
               AND (X_program_update_date IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;



PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Step_Id                             NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Spinal_Point_Id                     NUMBER,
                     X_Grade_Spine_Id                      NUMBER,
                     X_Sequence                            NUMBER,
                     X_request_id                          NUMBER,
                     X_program_application_id              NUMBER,
                     X_program_id                          NUMBER,
                     X_program_update_date                 DATE,
                     X_Information1                        VARCHAR2,
                     X_Information2                        VARCHAR2,
                     X_Information3                        VARCHAR2,
                     X_Information4                        VARCHAR2,
                     X_Information5                        VARCHAR2,
                     X_Information6                        VARCHAR2,
                     X_Information7                        VARCHAR2,
                     X_Information8                        VARCHAR2,
                     X_Information9                        VARCHAR2,
                     X_Information10                       VARCHAR2,
                     X_Information11                       VARCHAR2,
                     X_Information12                       VARCHAR2,
                     X_Information13                       VARCHAR2,
                     X_Information14                       VARCHAR2,
                     X_Information15                       VARCHAR2,
                     X_Information16                       VARCHAR2,
                     X_Information17                       VARCHAR2,
                     X_Information18                       VARCHAR2,
                     X_Information19                       VARCHAR2,
                     X_Information20                       VARCHAR2,
                     X_Information21                       VARCHAR2,
                     X_Information22                       VARCHAR2,
                     X_Information23                       VARCHAR2,
                     X_Information24                       VARCHAR2,
                     X_Information25                       VARCHAR2,
                     X_Information26                       VARCHAR2,
                     X_Information27                       VARCHAR2,
                     X_Information28                       VARCHAR2,
                     X_Information29                       VARCHAR2,
                     X_Information30                       VARCHAR2,
                     X_Information_category                VARCHAR2
) IS
BEGIN
  UPDATE per_spinal_point_steps
  SET
    step_id                                   =    X_Step_Id,
    effective_start_date                      =    X_Effective_Start_Date,
    effective_end_date                        =    X_Effective_End_Date,
    business_group_id                         =    X_Business_Group_Id,
    spinal_point_id                           =    X_Spinal_Point_Id,
    grade_spine_id                            =    X_Grade_Spine_Id,
    sequence                                  =    X_Sequence,
    request_id                                =    X_request_id,
    program_application_id                    =    X_program_application_id,
    program_id                                =    X_program_id,
    program_update_date                       =    X_program_update_date,
    information1                              =    X_Information1,
    information2                              =    X_Information2,
    information3                              =    X_Information3,
    information4                              =    X_Information4,
    information5                              =    X_Information5,
    information6                              =    X_Information6,
    information7                              =    X_Information7,
    information8                              =    X_Information8,
    information9                              =    X_Information9,
    information10                             =    X_Information10,
    information11                             =    X_Information11,
    information12                             =    X_Information12,
    information13                             =    X_Information13,
    information14                             =    X_Information14,
    information15                             =    X_Information15,
    information16                             =    X_Information16,
    information17                             =    X_Information17,
    information18                             =    X_Information18,
    information19                             =    X_Information19,
    information20                             =    X_Information20,
    information21                             =    X_Information21,
    information22                             =    X_Information22,
    information23                             =    X_Information23,
    information24                             =    X_Information24,
    information25                             =    X_Information25,
    information26                             =    X_Information26,
    information27                             =    X_Information27,
    information28                             =    X_Information28,
    information29                             =    X_Information29,
    information30                             =    X_Information30,
    information_category                      =    X_Information_category
  WHERE rowid = chartorowid(X_rowid);

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM per_spinal_point_steps
  WHERE  rowid = chartorowid(X_Rowid);

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;



procedure del_chks_del(p_step_id IN NUMBER,
                       p_sess IN DATE) is
   l_exists1 VARCHAR2(1);
   l_exists2 VARCHAR2(1);
--
-- Fix for bug 3404138.
-- Check that thisstep is used on or after the p_sess date.
--
cursor c1 is
select 'x'
from per_spinal_point_placements_f
where step_id = p_step_id
and p_sess < effective_end_date;
--
cursor c2 is
select 'x'
from per_all_assignments_f
where special_ceiling_step_id = p_step_id
and p_sess < effective_end_date;
--
begin
--
hr_utility.set_location('per_spinal_point_steps_pkg.del_chks_del',1);
--
open c1;
--
  fetch c1 into l_exists1;
  IF c1%found THEN
  hr_utility.set_message(801, 'PER_7938_DEL_STEP_PLACE');
  close c1;
  hr_utility.raise_error;
  END IF;
--
close c1;
--
hr_utility.set_location('per_spinal_point_steps_pkg.del_chks_del',2);
--
open c2;
--
  fetch c2 into l_exists2;
  IF c2%found THEN
  hr_utility.set_message(801, 'PER_7939_DEL_STEP_ASS');
  close c2;
  hr_utility.raise_error;
  END IF;
--
close c2;
--
end del_chks_del;



procedure del_chks_zap(p_step_id IN NUMBER) is
   l_exists VARCHAR2(1);
   l_exists2 VARCHAR2(1);

cursor c3 is
select 'x'
from per_spinal_point_placements_f
where step_id = p_step_id;
--
cursor c4 is
select 'x'
from per_all_assignments_f
where special_ceiling_step_id = p_step_id
and special_ceiling_step_id is not null;
--
begin
--
hr_utility.set_location('per_spinal_point_steps_pkg.del_chks_zap',1);
--
open c3;
--
  fetch c3 into l_exists;
  IF c3%found THEN
  hr_utility.set_message(801, 'PER_7938_DEL_STEP_PLACE');
  close c3;
  hr_utility.raise_error;
  END IF;
--
close c3;
--
hr_utility.set_location('per_spinal_point_steps_pkg.del_chks_zap',2);
--
open c4;
--
  fetch c4 into l_exists2;
  IF c4%found THEN
  hr_utility.set_message(801, 'PER_7939_DEL_STEP_ASS');
  close c4;
  hr_utility.raise_error;
  END IF;
--
close c4;
--
end del_chks_zap;



procedure chk_unq_step_point(p_gspine_id IN NUMBER,
                             p_spoint_id IN NUMBER,
                             p_step_id   IN NUMBER) is
   l_exists VARCHAR2(1);

cursor c5 is
select 'x'
from sys.dual
where exists
      (select null
       from per_spinal_point_steps_f sp
       --     per_grade_spines_f gs  Bug fix:3648542
       where sp.grade_spine_id = p_gspine_id
       and   sp.spinal_point_id = p_spoint_id
       and   sp.step_id <> p_step_id);
--
begin
--
hr_utility.set_location('per_spinal_point_steps_pkg.chk_unq_step_point',1);
--
open c5;
--
  fetch c5 into l_exists;
  IF c5%found THEN
  hr_utility.set_message(801, 'PER_7936_GRDSPN_POINT_EXISTS');
  close c5;
  hr_utility.raise_error;
  END IF;
--
close c5;
--
end chk_unq_step_point;



procedure pop_flds(p_d_step IN OUT NOCOPY NUMBER,
                   p_sess IN DATE,
                   p_spoint_id IN NUMBER,
                   p_gspine_id IN NUMBER) is

cursor c6 is
select count(*)
from per_spinal_points p1,
     per_spinal_points p2,
     per_spinal_point_steps_f s2
where s2.spinal_point_id = p2.spinal_point_id
and p1.sequence >= p2.sequence
and p_sess between
    s2.effective_start_date and s2.effective_end_date
and p1.spinal_point_id = p_spoint_id
and s2.grade_spine_id = p_gspine_id
group by p1.sequence,p1.spinal_point;
--
l_count           NUMBER;
--
begin
--
hr_utility.set_location('per_spinal_point_steps_pkg.pop_flds',1);
--
open c6;
--
  fetch c6 into l_count;
--
close c6;
--
  p_d_step := l_count +
              (hr_grade_scale_api.get_grade_scale_starting_step
              (p_gspine_id
              ,p_sess)
              -1);
--
end pop_flds;





end PER_SPINAL_POINT_STEPS_PKG;

/
