--------------------------------------------------------
--  DDL for Package Body PER_SPINAL_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPINAL_POINTS_PKG" as
/* $Header: pespo01t.pkb 115.1 99/07/18 15:08:24 porting ship $ */


procedure chk_unq_point(p_spoint IN VARCHAR2,
                        p_pspine_id IN NUMBER,
                        p_rowid IN VARCHAR2) is
  l_exists VARCHAR2(1);

cursor c1 is
select 'x'
from per_spinal_points
where spinal_point = p_spoint
and parent_spine_id = p_pspine_id
and ((p_rowid is null)
 or (p_rowid is not null and chartorowid(p_rowid) <> rowid));
--
begin
--
hr_utility.set_location('per_spinal_points_pkg.chk_unq_point',1);
--
open c1;
--
  fetch c1 into l_exists;
--
  IF c1%found THEN
    hr_utility.set_message(801, 'PER_7924_POINT_EXISTS');
    close c1;
    hr_utility.raise_error;
  END IF;
--
close c1;

end chk_unq_point;



procedure chk_unq_seq(p_seq IN NUMBER,
                      p_pspine_id IN NUMBER,
                      p_rowid IN VARCHAR2) is
  l_exists VARCHAR2(1);

cursor c2 is
select 'x'
from per_spinal_points
where sequence = p_seq
and parent_spine_id = p_pspine_id
and ((p_rowid is null)
 or  (p_rowid is not null and chartorowid(p_rowid) <> rowid));
--
begin
--
hr_utility.set_location('per_spinal_points_pkg.chk_unq_seq',1);
--
open c2;
--
  fetch c2 into l_exists;
--
  IF c2%found THEN
    hr_utility.set_message(801, 'PER_7925_POINT_SEQ_EXISTS');
    close c2;
    hr_utility.raise_error;
  END IF;
--
close c2;

end chk_unq_seq;



procedure rules_steps_update(p_seq IN NUMBER,
                       p_spoint_id IN NUMBER) is

begin
--
begin
--
update pay_grade_rules_f
set sequence = p_seq
where rate_type = 'SP'
and grade_or_spinal_point_id = p_spoint_id;
--
end;
--
begin
--
update per_spinal_point_steps
set sequence = p_seq
where spinal_point_id = p_spoint_id;
--
end;
--
end rules_steps_update;



procedure get_id(p_spoint_id IN OUT NUMBER) is

cursor c3 is
select per_spinal_points_s.nextval
from sys.dual;
--
begin
--
hr_utility.set_location('per_spinal_points_pkg.get_id',1);
--
open c3;
--
  fetch c3 into p_spoint_id;
--
close c3;
--
end get_id;



procedure stb_del_validation(p_pspine_id IN NUMBER,
                             p_spoint_id IN NUMBER) is
  l_exists1 VARCHAR2(1);
  l_exists2 VARCHAR2(1);

cursor c4 is
select 'x'
from per_spinal_point_steps_f f,
     per_grade_spines g
where f.grade_spine_id = g.grade_spine_id
and g.parent_spine_id = p_pspine_id
and f.spinal_point_id = p_spoint_id;
--
cursor c5 is
select 'x'
from pay_grade_rules_f
where grade_or_spinal_point_id = p_spoint_id
and rate_type = 'SP';
--
begin
--
hr_utility.set_location('per_spinal_points_pkg.stb_del_validation',1);
--
open c4;
--
  fetch c4 into l_exists1;
  IF c4%found THEN
    hr_utility.set_message(801, 'PER_7926_DEL_POINT_STEP');
    close c4;
    hr_utility.raise_error;
  END IF;
--
close c4;
--
hr_utility.set_location('per_spinal_points_pkg.stb_del_validation',2);
--
open c5;
--
  fetch c5 into l_exists2;
  IF c5%found THEN
    hr_utility.set_message(801, 'PER_7927_DEL_POINT_VALUE');
    close c5;
    hr_utility.raise_error;
  END IF;
--
close c5;
--
end stb_del_validation;



end PER_SPINAL_POINTS_PKG;

/
