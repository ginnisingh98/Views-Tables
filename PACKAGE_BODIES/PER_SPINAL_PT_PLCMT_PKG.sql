--------------------------------------------------------
--  DDL for Package Body PER_SPINAL_PT_PLCMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPINAL_PT_PLCMT_PKG" as
/* $Header: pespp01t.pkb 120.0 2005/05/31 21:28:38 appldev noship $ */

procedure check_ass_end(p_ass_id IN NUMBER,
                        p_sess IN DATE,
                        p_grd_id IN NUMBER) IS
  l_exists VARCHAR2(1);

cursor c20 is
select 'x'
from per_assignments_f a
where a.assignment_id = p_ass_id
and a.effective_start_date >= p_sess
and a.grade_id <> p_grd_id;
--
begin
--
hr_utility.set_location('per_spinal_pt_plcmt_pkg.check_ass_end',1);
--
open c20;
--
  fetch c20 into l_exists;
  IF c20%found THEN
  hr_utility.set_message(801,'HR_51770_GRD_PLC_ASS_EXIST');
  close c20;
  hr_utility.raise_error;
  END IF;
--
close c20;
--
end check_ass_end;


procedure b_delete_valid(p_ass_id IN NUMBER,
                         p_pmt_id IN NUMBER,
                         p_eed IN DATE) IS
   l_exists VARCHAR2(1);

cursor c1 is
select 'x'
from per_spinal_point_placements_f
where assignment_id = p_ass_id
and placement_id <> p_pmt_id
and effective_start_date > p_eed;
--
begin
--
hr_utility.set_location('per_spinal_pt_plcmt_pkg.b_delete_valid',1);
--
open c1;
--
  fetch c1 into l_exists;
  IF c1%found THEN
  hr_utility.set_message(801, 'PER_7929_SP_PLACE_FUT_EXISTS');
  close c1;
  hr_utility.raise_error;
  END IF;
--
close c1;
--
end b_delete_valid;


procedure pop_flds(p_sess IN DATE,
                   p_step_id IN NUMBER,
                   p_step_dsc IN OUT NOCOPY VARCHAR2,
                   p_step_no IN OUT NOCOPY NUMBER,
                   p_spoint_id IN OUT NOCOPY NUMBER,
                   p_rsn IN VARCHAR2,
                   p_rsn_desc IN OUT NOCOPY VARCHAR2) IS

cursor c2 is
select p1.spinal_point,
       (nvl(gs.starting_step,1) + count(*))-1 count ,
       p1.spinal_point_id
from   per_spinal_points p1,
       per_spinal_point_steps_f s2,
       per_spinal_point_steps_f s1,
       per_grade_spines_f gs
where  p1.spinal_point_id = s1.spinal_point_id
and    s1.grade_spine_id = s2.grade_spine_id
and    s1.grade_spine_id = gs.grade_spine_id
and    s1.sequence >= s2.sequence
and    p_sess between s1.effective_start_date and s1.effective_end_date
and    p_sess between s2.effective_start_date and s2.effective_end_date
and    p_sess between gs.effective_start_date and gs.effective_end_date
and    s1.step_id = p_step_id
group by p1.spinal_point,gs.starting_step, p1.spinal_point_id;
--
cursor c21 is
select meaning
from hr_lookups
where lookup_type = 'PLACEMENT_REASON'
and lookup_code = p_rsn;
--
 l_count   NUMBER;
begin
--
hr_utility.set_location('per_spinal_pt_plcmt_pkg.pop_flds',1);
--
open c2;
--
  fetch c2 into p_step_dsc,
                p_step_no,
                p_spoint_id;
--
close c2;

--

--
hr_utility.set_location('per_spinal_pt_plcmt_pkg.pop_flds',2);
--
open c21;
--
  fetch c21 into p_rsn_desc;
--
close c21;
--
end pop_flds;



procedure chk_exist(p_ass_id IN NUMBER,
                    p_sess IN DATE) IS
   l_exists VARCHAR2(1);

cursor c3 is
select 'x'
from per_spinal_point_placements_f
where assignment_id = p_ass_id
and effective_end_date >= p_sess;
--
begin
--
hr_utility.set_location('per_spinal_pt_plcmt_pkg.chk_exist',1);
--
open c3;
--
  fetch c3 into l_exists;
  IF c3%found THEN
  hr_utility.set_message(801, 'PER_7928_SP_PLACE_EXISTS');
  close c3;
  hr_utility.raise_error;
  END IF;
--
close c3;
--
end chk_exist;



PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Placement_Id                 IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Step_Id                             NUMBER,
                     X_Auto_Increment_Flag                 VARCHAR2,
                     X_Parent_Spine_Id                     NUMBER,
                     X_Reason                              VARCHAR2,
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
   CURSOR C IS SELECT rowid FROM per_spinal_point_placements_f
             WHERE  placement_id = x_placement_id;

    CURSOR C2 IS SELECT per_spinal_point_placements_s.nextval FROM sys.dual;
BEGIN
   if (X_placement_id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_placement_id;
     CLOSE C2;
   end if;
  INSERT INTO per_spinal_point_placements_f(
          placement_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          assignment_id,
          step_id,
          auto_increment_flag,
          parent_spine_id,
          reason,
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
          X_Placement_Id,
          X_Effective_Start_Date,
          X_Effective_End_Date,
          X_Business_Group_Id,
          X_Assignment_Id,
          X_Step_Id,
          X_Auto_Increment_Flag,
          X_Parent_Spine_Id,
          X_Reason,
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
                   X_Placement_Id                          NUMBER,
                   X_Effective_Start_Date                  DATE,
                   X_Effective_End_Date                    DATE,
                   X_Business_Group_Id                     NUMBER,
                   X_Assignment_Id                         NUMBER,
                   X_Step_Id                               NUMBER,
                   X_Auto_Increment_Flag                   VARCHAR2,
                   X_Parent_Spine_Id                       NUMBER,
                   X_Reason                                VARCHAR2,
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
      FROM   per_spinal_point_placements_f
      WHERE  rowid = chartorowid(X_Rowid)
      FOR UPDATE of placement_id           NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

recinfo.auto_increment_flag := rtrim(recinfo.auto_increment_flag);
recinfo.reason := rtrim(recinfo.reason);

  if (
          (   (Recinfo.placement_id = X_Placement_Id)
           OR (    (Recinfo.placement_id IS NULL)
               AND (X_Placement_Id IS NULL)))
      AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
           OR (    (Recinfo.effective_start_date IS NULL)
               AND (X_Effective_Start_Date IS NULL)))
      AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
           OR (    (Recinfo.effective_end_date IS NULL)
               AND (X_Effective_End_Date IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.assignment_id = X_Assignment_Id)
           OR (    (Recinfo.assignment_id IS NULL)
               AND (X_Assignment_Id IS NULL)))
      AND (   (Recinfo.step_id = X_Step_Id)
           OR (    (Recinfo.step_id IS NULL)
               AND (X_Step_Id IS NULL)))
      AND (   (Recinfo.auto_increment_flag = X_Auto_Increment_Flag)
           OR (    (Recinfo.auto_increment_flag IS NULL)
               AND (X_Auto_Increment_Flag IS NULL)))
      AND (   (Recinfo.parent_spine_id = X_Parent_Spine_Id)
           OR (    (Recinfo.parent_spine_id IS NULL)
               AND (X_Parent_Spine_Id IS NULL)))
      AND (   (Recinfo.reason = X_Reason)
           OR (    (Recinfo.reason IS NULL)
               AND (X_Reason IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;



PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Placement_Id                        NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Step_Id                             NUMBER,
                     X_Auto_Increment_Flag                 VARCHAR2,
                     X_Parent_Spine_Id                     NUMBER,
                     X_Reason                              VARCHAR2,
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
  UPDATE per_spinal_point_placements_f
  SET
    placement_id                              =    X_Placement_Id,
    effective_start_date                      =    X_Effective_Start_Date,
    effective_end_date                        =    X_Effective_End_Date,
    business_group_id                         =    X_Business_Group_Id,
    assignment_id                             =    X_Assignment_Id,
    step_id                                   =    X_Step_Id,
    auto_increment_flag                       =    X_Auto_Increment_Flag,
    parent_spine_id                           =    X_Parent_Spine_Id,
    reason                                    =    X_Reason,
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
  WHERE rowid = chartorowid(X_Rowid);

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM per_spinal_point_placements_f
  WHERE  rowid = chartorowid(X_rowid);

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;


--procedure to populate the control block (CTRL) in the form PERWSSPP
--this was placed in the 'per_spinal_pt_plcmt_pkg' as there
--were none for the control block being as it wasn't based
--on a table.

procedure pop_ctrl(p_ass_id       IN NUMBER,
                   p_grd_id       IN OUT NOCOPY NUMBER ,
                   p_grd_name     IN OUT NOCOPY VARCHAR2 ,
                   p_ceil_sp      IN OUT NOCOPY VARCHAR2 ,
                   p_parent_name  IN OUT NOCOPY VARCHAR2 ,
                   p_parent_id    IN OUT NOCOPY NUMBER ,
                   p_ceil_seq     In OUT NOCOPY NUMBER ,
                   p_ceil_step    In OUT NOCOPY NUMBER ,
                   p_ass_eed      IN OUT NOCOPY DATE ,
                   p_inc_def      IN OUT NOCOPY VARCHAR2 ,
                   p_sess         In DATE,
                   p_bgroup_id    IN NUMBER,
		   p_check        IN VARCHAR2,
                   p_grd_ldr_name in out nocopy varchar2) IS

cursor c5 is
select asg.effective_end_date,
       g.grade_id,
       g.name,
       sp.spinal_point,
       ps.name,
       ps.parent_spine_id,
       sp.sequence,
       pgm.name
from   per_grades_vl g,
       per_grade_spines_f gs,
       per_parent_spines ps,
       per_spinal_points sp,
       per_spinal_point_steps_f sps,
       per_all_assignments_f asg,
       ben_pgm_f pgm
where  asg.assignment_id = p_ass_id
and    asg.grade_id is not null
and    asg.grade_id = g.grade_id
and    asg.grade_ladder_pgm_id = pgm.pgm_id(+)
and    g.grade_id = gs.grade_id
and    ps.parent_spine_id = gs.parent_spine_id
and    sps.spinal_point_id = sp.spinal_point_id
and    nvl(asg.special_ceiling_step_id,gs.ceiling_step_id) = sps.step_id
and    p_sess between asg.effective_start_date and asg.effective_end_date
and    p_sess between sps.effective_start_date and sps.effective_end_date
and    p_sess between gs.effective_start_date and gs.effective_end_date
and    p_sess between NVL(pgm.effective_start_date,p_sess)
       and nvl(pgm.effective_end_date,p_sess)
and    asg.business_group_id + 0 = p_bgroup_id;
--
cursor c6 is
select (nvl(gs.starting_step,1)+count(*))-1
from   per_spinal_points p2,
       per_spinal_point_steps_f s2,
       per_grade_spines_f gs
where  s2.spinal_point_id = p2.spinal_point_id
and    p_ceil_seq >= p2.sequence
and    p_sess between s2.effective_start_date and s2.effective_end_date
and    p_sess between gs.effective_start_date and gs.effective_end_date
and    gs.grade_spine_id = s2.grade_spine_id
and    gs.grade_id = p_grd_id
and    gs.parent_spine_id = p_parent_id
group by gs.starting_step;
--
cursor c7 is
select meaning
from   fnd_lookups
where  lookup_type = 'YES_NO'
and    lookup_code = 'Y';
--
 l_ceil_step        NUMBER;
begin
--
hr_utility.set_location('per_spinal_pt_plcmt_pkg.pop_ctrl',1);
--
open c5;
--
  fetch c5 into p_ass_eed,
                p_grd_id,
                p_grd_name,
                p_ceil_sp,
                p_parent_name,
                p_parent_id,
                p_ceil_seq,
                p_grd_ldr_name;
--
  IF c5%notfound AND upper(p_check) = 'Y' THEN
    hr_utility.set_message(801, 'HR_7112_WFLOW_ASSGT_NO_PLAC');
    close c5;
    hr_utility.raise_error;
  END IF;
--
close c5;
--
hr_utility.set_location('per_spinal_pt_plcmt_pkg.pop_ctrl',2);
--
open c6;
--
  fetch c6 into p_ceil_step;
--
close c6;

--
hr_utility.set_location('per_spinal_pt_plcmt_pkg.pop_ctrl',3);
--
open c7;
--
  fetch c7 into p_inc_def;
--
close c7;
--
end pop_ctrl;

procedure test_path_to_perwsspp (p_ass_id    NUMBER) is
--
l_grd_id NUMBER;
l_grd_name VARCHAR2(240);
l_ceil_sp VARCHAR2(30);
l_parent_name VARCHAR2(30);
l_parent_id NUMBER;
l_ceil_seq NUMBER;
l_ceil_step NUMBER;
l_ass_eed DATE;
l_inc_def VARCHAR2(80);
l_sess DATE;
l_bgroup_id NUMBER;
l_proc VARCHAR2(30) := 'test_path_to_perwsspp';
l_grd_ldr_name varchar2(240);
--
cursor c_derive_info is
select asg.business_group_id,
       ses.effective_date
from   per_assignments_f asg,
       fnd_sessions ses
where  asg.assignment_id = p_ass_id
and    ses.session_id = userenv('SESSIONID')
and    ses.effective_date between
       asg.effective_start_date and asg.effective_end_date;
--
begin
--
open c_derive_info;
--
  fetch c_derive_info into l_bgroup_id,
                           l_sess;
  IF c_derive_info%notfound THEN
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',l_proc);
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
    close c_derive_info;
  END IF;
--
close c_derive_info;
--
  per_spinal_pt_plcmt_pkg.pop_ctrl(p_ass_id
                                  ,l_grd_id
                                  ,l_grd_name
                                  ,l_ceil_sp
                                  ,l_parent_name
                                  ,l_parent_id
                                  ,l_ceil_seq
                                  ,l_ceil_step
                                  ,l_ass_eed
                                  ,l_inc_def
                                  ,l_sess
                                  ,l_bgroup_id
                                  ,'Y'
                                  ,l_grd_ldr_name);
end test_path_to_perwsspp;

end PER_SPINAL_PT_PLCMT_PKG;

/
