--------------------------------------------------------
--  DDL for Package Body PER_PARENT_SPINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PARENT_SPINES_PKG" as
/* $Header: pepsp01t.pkb 115.2 2003/02/10 17:20:43 eumenyio ship $ */


procedure chk_unique_name(p_name IN VARCHAR2,
                          p_rowid IN VARCHAR2,
                          p_bgroup_id IN NUMBER) IS
    l_exists VARCHAR2(1);

cursor c1 is
select 'x'
from per_parent_spines
where upper(name) = upper(p_name)
and (p_rowid is null
 or (p_rowid is not null and chartorowid(p_rowid) <> rowid))
and business_group_id + 0 = p_bgroup_id;
--
begin
--
hr_utility.set_location('per_parent_spines_pkg.chk_unique_name',1);
--
open c1;
--
  fetch c1 into l_exists;
--
  IF c1%found THEN
    hr_utility.set_message(801, 'PER_7920_PAR_SPN_EXISTS');
    close c1;
    hr_utility.raise_error;
  END IF;
--
close c1;

end chk_unique_name;



procedure stb_del_validation(p_pspine_id IN NUMBER) is
    l_exists1 VARCHAR2(1);
    l_exists2 VARCHAR2(1);
    l_exists3 VARCHAR2(1);

cursor c2 is
select 'x'
from per_spinal_points
where parent_spine_id = p_pspine_id;
--
cursor c3 is
select 'x'
from per_grade_spines_f
where parent_spine_id = p_pspine_id;
--
cursor c4 is
select 'x'
from pay_rates
where parent_spine_id = p_pspine_id;
--
begin
--
hr_utility.set_location('per_parent_spines_pkg.stb_del_validation',1);
--
open c2;
--
  fetch c2 into l_exists1;
--
  IF c2%found THEN
    hr_utility.set_message(801, 'PER_7921_DEL_PAR_SPN_POINT');
    close c2;
    hr_utility.raise_error;
  END IF;
--
close c2;
--
hr_utility.set_location('per_parent_spines_pkg.stb_del_validation',2);
--
open c3;
--
  fetch c3 into l_exists2;
--
  IF c3%found THEN
    hr_utility.set_message(801, 'PER_7922_DEL_PAR_SPN_GRDSPN');
    close c3;
    hr_utility.raise_error;
  END IF;
--
close c3;
--
hr_utility.set_location('per_parent_spines_pkg.stb_del_validation',3);
--
open c4;
--
  fetch c4 into l_exists3;
--
  IF c4%found THEN
    hr_utility.set_message(801, 'PER_7923_DEL_PAR_SPN_RATE');
    close c4;
    hr_utility.raise_error;
  END IF;
--
close c4;
--
end stb_del_validation;



procedure get_id(p_pspine_id IN OUT NOCOPY NUMBER) is

cursor c5 is
select per_parent_spines_s.nextval
from sys.dual;
--
begin
--
hr_utility.set_location('per_parent_spines_pkg.get_id',1);
--
open c5;
--
  fetch c5 into p_pspine_id;
--
close c5;
--
end get_id;



procedure get_name(p_incp IN VARCHAR2,
                   p_dinc IN OUT NOCOPY VARCHAR2) is

cursor c6 is
select meaning
from hr_lookups
where lookup_type = 'FREQUENCY'
and lookup_code = p_incp;
--
begin
--
hr_utility.set_location('per_parent_spines_pkg.get_name',1);
--
open c6;
--
  fetch c6 into p_dinc;
--
close c6;
--
end get_name;




end PER_PARENT_SPINES_PKG;

/
