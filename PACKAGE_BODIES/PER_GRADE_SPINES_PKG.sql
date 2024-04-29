--------------------------------------------------------
--  DDL for Package Body PER_GRADE_SPINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GRADE_SPINES_PKG" as
/* $Header: pegrs01t.pkb 120.0 2005/05/31 09:32:19 appldev noship $ */

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Grade_Spine_Id               IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Parent_Spine_Id                     NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Ceiling_Step_Id              IN OUT NOCOPY NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM per_grade_spines_f
             WHERE grade_spine_id = X_Grade_Spine_Id;

    CURSOR C2 IS SELECT per_grade_spines_s.nextval
                   FROM sys.dual;

    CURSOR C3 is select per_spinal_point_steps_s.nextval
                 from sys.dual;

BEGIN
   if (X_grade_spine_id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_grade_spine_id;
     CLOSE C2;

     OPEN C3;
     FETCH C3 into X_ceiling_step_id;
     CLOSE C3;
   end if;
  INSERT INTO per_grade_spines(
          grade_spine_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          parent_spine_id,
          grade_id,
          ceiling_step_id
         ) VALUES (
          X_Grade_Spine_Id,
          X_Effective_Start_Date,
          X_Effective_End_Date,
          X_Business_Group_Id,
          X_Parent_Spine_Id,
          X_Grade_Id,
          X_Ceiling_Step_Id

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
                   X_Grade_Spine_Id                        NUMBER,
                   X_Effective_Start_Date                  DATE,
                   X_Effective_End_Date                    DATE,
                   X_Business_Group_Id                     NUMBER,
                   X_Parent_Spine_Id                       NUMBER,
                   X_Grade_Id                              NUMBER,
                   X_Ceiling_Step_Id                       NUMBER,
                   X_starting_step                         NUMBER,
                   X_request_id                            NUMBER,
                   X_program_application_id                NUMBER,
                   X_program_id                            NUMBER,
                   X_program_update_date                   DATE
) IS
  CURSOR C IS
SELECT *
      FROM   per_grade_spines_f
      WHERE  rowid = chartorowid(X_Rowid)
      FOR UPDATE of Grade_Spine_Id NOWAIT;

  Recinfo C%ROWTYPE;

BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.grade_spine_id = X_Grade_Spine_Id)
           OR (    (Recinfo.grade_spine_id IS NULL)
               AND (X_Grade_Spine_Id IS NULL)))
      AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
           OR (    (Recinfo.effective_start_date IS NULL)
               AND (X_Effective_Start_Date IS NULL)))
      AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
           OR (    (Recinfo.effective_end_date IS NULL)
               AND (X_Effective_End_Date IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.parent_spine_id = X_Parent_Spine_Id)
           OR (    (Recinfo.parent_spine_id IS NULL)
               AND (X_Parent_Spine_Id IS NULL)))
      AND (   (Recinfo.grade_id = X_Grade_Id)
           OR (    (Recinfo.grade_id IS NULL)
               AND (X_Grade_Id IS NULL)))
      AND (   (Recinfo.ceiling_step_id = X_Ceiling_Step_Id)
           OR (    (Recinfo.ceiling_step_id IS NULL)
               AND (X_Ceiling_Step_Id IS NULL)))
      AND (   (Recinfo.starting_step = X_starting_step)
           OR (    (Recinfo.starting_step IS NULL)
               AND (X_starting_step IS NULL)))
      AND (   (Recinfo.request_id = X_request_Id)
           OR (    (Recinfo.request_id IS NULL)
               AND (X_request_Id IS NULL)))
      AND (   (Recinfo.program_application_id = X_program_application_Id)
           OR (    (Recinfo.program_application_id IS NULL)
               AND (X_program_application_Id IS NULL)))
      AND (   (Recinfo.program_id = X_program_Id)
           OR (    (Recinfo.program_id IS NULL)
               AND (X_program_Id IS NULL)))
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
                     X_Grade_Spine_Id                      NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Parent_Spine_Id                     NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Ceiling_Step_Id                     NUMBER
) IS
BEGIN
  UPDATE per_grade_spines_f
  SET
    grade_spine_id                            =    X_Grade_Spine_Id,
    effective_start_date                      =    X_Effective_Start_Date,
    effective_end_date                        =    X_Effective_End_Date,
    business_group_id                         =    X_Business_Group_Id,
    parent_spine_id                           =    X_Parent_Spine_Id,
    grade_id                                  =    X_Grade_Id,
    ceiling_step_id                           =    X_Ceiling_Step_Id
  WHERE rowid = chartorowid(X_rowid);

  if (SQL%NOTFOUND) then
  hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token('PROCEDURE','update_row');
  hr_utility.set_message_token('STEP','1');
  hr_utility.raise_error;
  end if;

END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN

-- Start of fix for Bug 2694503.

  DECLARE
    l_grade_spine_id  per_grade_spines_f.grade_spine_id%Type;
  BEGIN
	select grade_spine_id
        into  l_grade_spine_id
        from per_grade_spines_f
        where rowid = chartorowid(X_Rowid);

        Delete from per_spinal_point_steps_f
        where grade_spine_id = l_grade_spine_id;

  Exception
        When NO_DATA_FOUND then
           null;

   end ;

-- End of fix for Bug 2694503.

  DELETE FROM per_grade_spines_f
  WHERE  rowid = chartorowid(X_Rowid);

  if (SQL%NOTFOUND) then
   hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
   hr_utility.set_message_token('PROCEDURE','delete_row');
   hr_utility.set_message_token('STEP','1');
   hr_utility.raise_error;
  end if;
END Delete_Row;



procedure stb_del_validation(p_pspine_id IN NUMBER,
                             p_grd_id IN NUMBER) is
   l_exists1 VARCHAR2(1);
   l_exists2 VARCHAR2(1);

cursor c1 is
select 'x'
from per_spinal_point_steps_f sps,
     per_grade_spines_f gs
where gs.grade_spine_id = sps.grade_spine_id
and gs.parent_spine_id = p_pspine_id
and gs.grade_id = p_grd_id
and exists
    (select null
     from per_spinal_point_placements_f sp
     where sp.step_id = sps.step_id);
--
cursor c2 is
select 'x'
from per_spinal_point_steps_f sps,
     per_grade_spines_f gs
where gs.grade_spine_id = sps.grade_spine_id
and gs.parent_spine_id = p_pspine_id
and gs.grade_id = p_grd_id
and exists
    (select null
     from per_assignments_f a
     where a.special_ceiling_step_id = sps.step_id
     and a.special_ceiling_step_id is not null);
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.stb_del_validation',1);
--
open c1;
--
  fetch c1 into l_exists1;
  IF c1%found THEN
  hr_utility.set_message(801, 'PER_7933_DEL_GRDSPN_PLACE');
  close c1;
  hr_utility.raise_error;
  END IF;
--
close c1;
--
hr_utility.set_location('per_grade_spines_pkg.stb_del_validation',2);
--
open c2;
--
  fetch c2 into l_exists2;
  IF c2%found THEN
  hr_utility.set_message(801, 'PER_7934_DEL_GRDSPN_ASS');
  close c2;
  hr_utility.raise_error;
  END IF;
--
close c2;
--
end stb_del_validation;



procedure chk_unq_grade_spine(p_grd_id IN NUMBER,
                              p_sess IN DATE) is
   l_exists VARCHAR2(1);

cursor c3 is
select 'x'
from per_grade_spines_f
where grade_id = p_grd_id
and p_sess between effective_start_date and effective_end_date;
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.stb_del_validation',1);
--
open c3;
--
  fetch c3 into l_exists;
  IF c3%found THEN
  hr_utility.set_message(801, 'PER_7932_GRDSPN_GRD_EXISTS');
  close c3;
  hr_utility.raise_error;
  END IF;
--
close c3;
--
end chk_unq_grade_spine;



procedure first_step(
                     p_step_id IN NUMBER,
                     p_grade_spine_id IN NUMBER,
                     p_spinal_point_id IN NUMBER,
                     p_sequence IN NUMBER,
                     p_effective_start_date IN DATE,
                     p_effective_end_date IN DATE,
                     p_business_group_id IN NUMBER,
                     p_last_update_date IN DATE,
                     p_last_updated_by IN NUMBER,
                     p_last_update_login IN NUMBER,
                     p_created_by IN NUMBER,
                     p_creation_date IN DATE,
                     p_information_category in VARCHAR2) IS

begin

insert into per_spinal_point_steps_f(
       step_id,
       grade_spine_id,
       spinal_point_id,
       sequence,
       effective_start_date,
       effective_end_date,
       business_group_id,
       last_update_date,
       last_updated_by,
       last_update_login,
       created_by,
       creation_date,
       information_category)
values (
       p_step_id,
       p_grade_spine_id,
       p_spinal_point_id,
       p_sequence,
       p_effective_start_date,
       p_effective_end_date,
       p_business_group_id,
       p_last_update_date,
       p_last_updated_by,
       p_last_update_login,
       p_created_by,
       p_creation_date,
       p_information_category);


end first_step;

--
-- first_step_api inserts object_verson_number into per_spinal_point_steps_f
-- bug2999562
--
procedure first_step_api(
                     p_step_id IN NUMBER,
                     p_grade_spine_id IN NUMBER,
                     p_spinal_point_id IN NUMBER,
                     p_sequence IN NUMBER,
                     p_effective_start_date IN DATE,
                     p_effective_end_date IN DATE,
                     p_business_group_id IN NUMBER,
                     p_last_update_date IN DATE,
                     p_last_updated_by IN NUMBER,
                     p_last_update_login IN NUMBER,
                     p_created_by IN NUMBER,
                     p_creation_date IN DATE,
                     p_information_category in VARCHAR2,
                     p_object_version_number in number,
                     p_effective_date in date) IS

--
-- declare local variables
--
  l_proc              varchar2(72) := 'per_grade_spines_pkg.first_step_api';
  l_pay_scale_name    varchar2(30);
  l_spinal_point_name varchar2(30);
  l_grade_id          number;
  l_return            varchar2(20);
  l_message           varchar2(2000) := null;
  --
  cursor csr_get_names is
    select pps.name
          ,psp.spinal_point
          ,pgs.grade_id
    from   per_parent_spines pps
          ,per_grade_spines_f pgs
          ,per_spinal_points psp
    where  pgs.grade_spine_id = p_grade_spine_id
    and    p_effective_date between
           pgs.effective_start_date and pgs.effective_end_date
    and    pps.parent_spine_id = pgs.parent_spine_id
    and    psp.spinal_point_id = p_spinal_point_id;


begin

  hr_utility.set_location('Entering:' ||l_proc, 10);

  insert into per_spinal_point_steps_f(
       step_id,
       grade_spine_id,
       spinal_point_id,
       sequence,
       effective_start_date,
       effective_end_date,
       business_group_id,
       last_update_date,
       last_updated_by,
       last_update_login,
       created_by,
       creation_date,
       information_category,
       object_version_number)
  values (
       p_step_id,
       p_grade_spine_id,
       p_spinal_point_id,
       p_sequence,
       p_effective_start_date,
       p_effective_end_date,
       p_business_group_id,
       p_last_update_date,
       p_last_updated_by,
       p_last_update_login,
       p_created_by,
       p_creation_date,
       p_information_category,
       p_object_version_number);

  hr_utility.set_location(l_proc, 20);

  --
  -- Need to create option and option in plan for Benefit
  --
  --
  open csr_get_names;
  fetch csr_get_names into l_pay_scale_name,l_spinal_point_name,l_grade_id;
  if csr_get_names%notfound then
    close csr_get_names;
    hr_utility.set_location(l_proc, 30);
  else
  /* Comment out for BUG3179239
    l_return := pqh_gsp_sync_compensation_obj.create_option_for_point
      (p_spinal_point_id         => p_spinal_point_id
      ,p_pay_scale_name          => l_pay_scale_name
      ,p_spinal_point_name       => l_spinal_point_name
      );
    --
    hr_utility.trace('pqh_gsp_sync_compensation_obj.create_option_for_point : '
                || l_return);
    --
    if l_return <> 'SUCCESS' Then
       l_message := fnd_message.get;
       hr_utility.trace('error message : ' || l_message);
       fnd_message.set_name('PER','HR_289527_CRE_OPTION_FOR_POINT');
       if l_message is not null then
         fnd_message.set_token('ERR_CODE',l_message);
       else
         fnd_message.set_token('ERR_CODE','-1');
       end if;
       --
       fnd_message.raise_error;
    End if;
  */ -- End of BUG3179239

    l_return := pqh_gsp_sync_compensation_obj.create_oipl_for_step
      (p_grade_id                => l_grade_id
      ,p_spinal_point_id         => p_spinal_point_id
      ,p_step_id                 => p_step_id
      ,p_effective_date          => p_effective_date
      ,p_datetrack_mode          => 'INSERT'
      );
    --
    hr_utility.trace('pqh_gsp_sync_compensation_obj.oipl_for_step : '
                  || l_return);
    --
    if l_return <> 'SUCCESS' Then
       l_message := fnd_message.get;
       hr_utility.trace('error message : ' || l_message);
       fnd_message.set_name('PER','HR_289528_CRE_OPTION_IN_PLAN');
       if l_message is not null then
         fnd_message.set_token('ERR_CODE',l_message);
       else
         fnd_message.set_token('ERR_CODE','-1');
       end if;
       --
       fnd_message.raise_error;
    End if;

  end if;
  hr_utility.set_location(' Leaving:' || l_proc, 40);
  --
end first_step_api;


procedure chk_low_ceiling(p_val_start IN DATE,
                          p_val_end IN DATE,
                          p_gspine_id IN NUMBER,
                          p_new_ceil IN NUMBER) is
   l_exists VARCHAR2(1);

cursor c5 is
select 'x'
from sys.dual
where exists
      (select null
       from per_all_assignments_f a,
            per_spinal_point_placements_f p,
            per_spinal_point_steps_f s
       where a.assignment_id = p.assignment_id
       and   a.effective_start_date <= p_val_start
       and   a.effective_end_date >= p_val_end
       and   p.effective_start_date <= p_val_start
       and   p.effective_end_date >= p_val_end
       and   s.effective_start_date <= p_val_start
       and   s.effective_end_date >= p_val_end
       and   p.step_id = s.step_id
       and   a.special_ceiling_step_id is null
       and   s.grade_spine_id = p_gspine_id
       and   s.sequence > p_new_ceil);
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.chk_low_ceiling',1);
--
open c5;
--
  fetch c5 into l_exists;
  IF c5%found THEN
  hr_utility.set_message(801, 'PER_7935_CEIL_PLACE_HIGH_EXIST');
  close c5;
  hr_utility.raise_error;
  END IF;
--
close c5;
--
end chk_low_ceiling;

--
--this is the the new code required to add date effective
--deletes to the grade spines entity
--KSLIPPER 16/12/94
--
--
--
-- supporting prcoedures that perform DML or specific validation
-- routines for controlling procedures close_gspine and open_gspine.
--
--
procedure zap_placement(p_placement_id in number,
			p_step_id in number,
			p_eff_start_date in date) is
--
-- completely removes a placement record from the DB as it starts after
-- the point in time where the grade spine is being ended.
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.zap_placement',1);
--
delete from per_spinal_point_placements_f
where placement_id = p_placement_id
and step_id = p_step_id
and effective_start_date = p_eff_start_date;
--
hr_utility.set_location('per_grade_spines_pkg.zap_placement',2);
--
end zap_placement;


procedure update_placement(p_placement_id in number,
			   p_step_id in number,
			   p_eff_start_date in date,
			   p_newdate in date) is
--
-- performs a date effective delete/opening of the placement record setting the
-- EED to the date the grade spine is being ended/opened up until.
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.update_placement',1);
--
update per_spinal_point_placements_f
set effective_end_date = p_newdate
where placement_id = p_placement_id
and step_id = p_step_id
and effective_start_date = p_eff_start_date;
--
hr_utility.set_location('per_grade_spines_pkg.update_placement',2);
--
end update_placement;


procedure zap_step(p_step_id in number,
		   p_eff_start_date in date,
		   p_grade_spine_id in number) is
--
-- completely removes a step record from the DB as it starts after the
-- point in time where the grade spine is being ended.
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.zap_step',1);
--
delete from per_spinal_point_steps_f
where step_id = p_step_id
and grade_spine_id = p_grade_spine_id
and effective_start_date = p_eff_start_date;
--
hr_utility.set_location('per_grade_spines_pkg.zap_step',2);
--
end zap_step;


procedure update_step(p_step_id in number,
		      p_eff_start_date in date,
		      p_grade_spine_id in number,
		      p_newdate in date) is
--
-- performs a date effective delete/opening of the step record setting the EED
-- to the date the grade spine is being ended/opened up until.
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.update_step',1);
--
update per_spinal_point_steps_f
set effective_end_date = p_newdate
where step_id = p_step_id
and grade_spine_id = p_grade_spine_id
and effective_start_date = p_eff_start_date;
--
hr_utility.set_location('per_grade_spines_pkg.update_step',2);
--
end update_step;


procedure get_gspine_end(p_gspine_id in number,
                         p_grade_id in number,
                         p_eff_end_date in date,
                         p_gspine_opento_date in out nocopy date) is
l_end_of_time date := to_date('31-12-4712','DD-MM-YYYY');
--
-- determines the date to extend the grade spine to if the grade is used
-- in a future grade spine.
--
-- If the grade is not used in another grade spine in the future then
-- the steps can be opened to the end of time.
--
cursor get_end is
select effective_start_date -1
from per_grade_spines_f
where grade_id = p_grade_id
and effective_start_date > p_eff_end_date
and grade_spine_id <> p_gspine_id;
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.get_gspine_end',1);
--
open get_end;
--
fetch get_end into p_gspine_opento_date;
--
close get_end;
--
IF p_gspine_opento_date is null THEN
   p_gspine_opento_date := l_end_of_time;
END IF;
--
hr_utility.set_location('per_grade_spines_pkg.get_gspine_end',2);
--
end get_gspine_end;


--
-- The master or controlling procedures
--

procedure close_gspine(p_gspine_id IN NUMBER,
		       p_sess IN DATE) is
l_exists NUMBER;
l_step_id number;
l_placement_id number;
l_stp_eff_start DATE;
l_stp_eff_end DATE;
l_plc_eff_start DATE;
l_plc_eff_end DATE;
--
-- cursor to check that none of the grade spines steps are in use as
-- special ceiling steps in assignment records.
--
-- bug# 2556700. There should not be any asignment records with end date
-- greater than the propposed end date of spinal point steps
--
cursor check_ass is
select 1
from per_all_assignments_f paa,
     per_spinal_point_steps_f psps
where psps.grade_spine_id = p_gspine_id
and paa.special_ceiling_step_id = psps.step_id
and p_sess < paa.effective_end_date;
--
-- cursor to locate each step belonging to the grade spine ready for
-- updating.
--
cursor get_steps is
select step_id,
       effective_start_date,
       effective_end_date
from per_spinal_point_steps_f
where grade_spine_id = p_gspine_id;
--
cursor get_plcmnts(p_step_id in number) is
select placement_id,
       effective_start_date,
       effective_end_date
from per_spinal_point_placements_f
where step_id = p_step_id;
--
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.close_gspine',1);
--
open check_ass;
--
fetch check_ass into l_exists;
IF check_ass%found THEN
  hr_utility.set_message(801,'PER_7939_DEL_STEP_ASS');
  close check_ass;
  hr_utility.raise_error;
END IF;
--
close check_ass;
--
hr_utility.set_location('per_grade_spines_pkg.close_gspine',2);
--
open get_steps;
--
LOOP
--
-- delete/update the step records.
--
   fetch get_steps into l_step_id,
                        l_stp_eff_start,
                        l_stp_eff_end;
   exit when get_steps%notfound;
   IF p_sess < l_stp_eff_end THEN
--
      --
      hr_utility.set_location('per_grade_spines_pkg.close_gspine',3);
      --
      open get_plcmnts(l_step_id);
      --
      -- delete/update the placement records.
      --
      LOOP
      --
         fetch get_plcmnts into l_placement_id,
      			        l_plc_eff_start,
			        l_plc_eff_end;
         exit when get_plcmnts%notfound;
         IF l_plc_eff_start > p_sess THEN
	    zap_placement(l_placement_id,
		          l_step_id,
		          l_plc_eff_start);
         ELSIF l_plc_eff_start <= p_sess and l_plc_eff_end >= p_sess THEN
            update_placement(l_placement_id,
			     l_step_id,
			     l_plc_eff_start,
			     p_sess);
         END IF;
      --
      END LOOP;
      --
      close get_plcmnts;
   --
   END IF;
   --
   IF l_stp_eff_start > p_sess THEN
      zap_step(l_step_id,
	       l_stp_eff_start,
	       p_gspine_id);
   ELSIF l_stp_eff_start <= p_sess and l_stp_eff_end >= p_sess THEN
      update_step(l_step_id,
	          l_stp_eff_start,
	          p_gspine_id,
	          p_sess);
   END IF;
--
END LOOP;
--
close get_steps;
--
end close_gspine;




procedure open_gspine(p_gspine_id in number,
		      p_grade_id in number,
		      p_eff_end_date in date) is
l_step_id per_spinal_point_steps_f.step_id%TYPE;
l_stp_eff_start per_spinal_point_steps_f.effective_start_date%TYPE;
l_plcmnt_id per_spinal_point_placements_f.placement_id%TYPE;
l_plc_eff_start per_spinal_point_placements_f.effective_start_date%TYPE;
l_gspine_opento_date date;
l_stp_opento_date date;
l_plc_opento_date date;
l_eot date := to_date('31-12-4712','DD-MM-YYYY');
l_grdchng_date date;
l_ass_maxend date;
l_exists number;
--
-- cursor to check that the grade spine has been closed and does require
-- opening up. If no rows returned then records end is just a ceiling
-- step change.
--
cursor check_notceilchng is
select 1
from per_grade_spines_f
where grade_spine_id = p_gspine_id
and effective_start_date > p_eff_end_date;
--
-- cursor to locate the spinal point steps that require re-opening.
--
cursor get_steps is
select step_id,
       effective_start_date
from per_spinal_point_steps_f
where grade_spine_id = p_gspine_id
and effective_end_date = p_eff_end_date;
--
-- cursor to locate the spinal point placements that require
-- re-opening.
--
cursor get_placements(p_step_id in number) is
select placement_id,
       effective_start_date
from per_spinal_point_placements_f
where step_id = p_step_id
and effective_end_date = p_eff_end_date;
--
-- cursor to determine the date to extend the placement records to if
-- the grade of the assignment has changed.
--
cursor get_plcdate(p_plc_id in number,
		   p_grd_id in number,
		   p_plc_start in date) is
select a.effective_start_date -1
from per_spinal_point_placements_f p,
     per_all_assignments_f a
where p.placement_id = p_plc_id
and p.effective_start_date = p_plc_start
and a.assignment_id = p.assignment_id
and a.effective_start_date > p_plc_start
and a.grade_id <> p_grd_id;
--
-- cursor to check if assignment has been ended in between the closing
-- and reopening of the placement.
--
cursor get_assend(p_plc_id in number) is
select max(a.effective_end_date)
from per_spinal_point_placements_f p,
     per_all_assignments_f a
where p.placement_id = p_plc_id
and p.assignment_id = a.assignment_id;
--
--
begin
--
hr_utility.set_location('per_grade_spines_pkg.open_gspine',1);
--
open check_notceilchng;
--
fetch check_notceilchng into l_exists;
IF check_notceilchng%notfound THEN
   close check_notceilchng;
   --
   hr_utility.set_location('per_grade_spines_pkg.open_gspine',2);
   --
   per_grade_spines_pkg.get_gspine_end(p_gspine_id,
                                       p_grade_id,
                                       p_eff_end_date,
                                       l_gspine_opento_date);
   --
   l_stp_opento_date := nvl(l_gspine_opento_date,l_eot);
   --
   hr_utility.set_location('per_grade_spines_pkg.open_gspine',3);
   --
   FOR steps IN get_steps LOOP
      --
      -- re-open step records for grade spine
      --
      l_step_id := steps.step_id;
      l_stp_eff_start := steps.effective_start_date;
      --
      hr_utility.set_location('per_grade_spines_pkg.open_gspine',4);
      --
      FOR placements IN get_placements(l_step_id) LOOP
         --
	 -- re-open placement records for each step re-opened
	 --
         l_plcmnt_id := placements.placement_id;
	 l_plc_eff_start := placements.effective_start_date;
         --
	 -- check if assignment has been ended
	 --
         hr_utility.set_location('per_grade_spines_pkg.open_gspine',5);
         --
         open get_assend(l_plcmnt_id);
         fetch get_assend into l_ass_maxend;
         close get_assend;
         --
	 -- check if assignments grade has been changed
	 --
         hr_utility.set_location('per_grade_spines_pkg.open_gspine',6);
         --
         open get_plcdate(l_plcmnt_id,
		          p_grade_id,
		          l_plc_eff_start);
         fetch get_plcdate into l_grdchng_date;
         close get_plcdate;
         --
	 -- locate the maximum date the placement can be opened until
	 --
         l_plc_opento_date :=
          least(l_stp_opento_date,nvl(l_grdchng_date,l_eot),
                nvl(l_ass_maxend,l_eot));
         --
	 -- perform the update
	 --
         update_placement(l_plcmnt_id,
		          l_step_id,
		          l_plc_eff_start,
		          l_plc_opento_date);
      --
      END LOOP;
   --
   -- perform the update for the step record
   --
   update_step(l_step_id,
	       l_stp_eff_start,
	       p_gspine_id,
	       l_stp_opento_date);
   --
   END LOOP;
--
ELSE close check_notceilchng;
--
END IF;
--
end open_gspine;


end PER_GRADE_SPINES_PKG;

/
