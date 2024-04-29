--------------------------------------------------------
--  DDL for Package Body PER_CAREER_PATH_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAREER_PATH_ELEMENTS_PKG" as
/* $Header: pecpe01t.pkb 120.0 2005/05/31 07:11:08 appldev noship $ */

procedure navigate_path(p_child_id IN NUMBER,
                        p_child_name IN OUT nocopy VARCHAR2,
                        p_cpath_id IN NUMBER,
                        p_parent_id IN OUT nocopy NUMBER,
                        p_parent_name IN OUT nocopy VARCHAR2,
                        p_bgroup_id IN NUMBER) IS

cursor c1 is
select name
from   per_jobs_v
where  job_id = p_child_id;
--

cursor c2 is
select x.job_id,
       x.name
from   per_jobs_v x,
       per_career_path_elements y
where  x.business_group_id + 0 = p_bgroup_id
and    x.job_id = y.parent_job_id
and    y.career_path_id = p_cpath_id
and    y.subordinate_job_id = p_child_id;
--
--
begin
--
hr_utility.set_location('per_career_path_elements_pkg.navigate_path',1);
--
open c1;
--
  fetch c1 into p_child_name;
--
close c1;
--
hr_utility.set_location('per_career_path_elements_pkg.navigate_path',2);
--
open c2;
--
  fetch c2 into p_parent_id,
                p_parent_name;
--
close c2;


end navigate_path;



procedure get_id(p_cpath_ele_id IN OUT nocopy NUMBER) IS

cursor c3 is
select per_career_path_elements_s.nextval
from sys.dual;
--
begin
--
hr_utility.set_location('per_career_path_elements_pkg.get_id',1);
--
open c3;
--
  fetch c3 into p_cpath_ele_id;
--
close c3;

end get_id;




procedure stb_del_validation(p_bgroup_id IN NUMBER,
                             p_cpath_id IN NUMBER,
                             p_sjob_id IN NUMBER) IS
  l_exists VARCHAR2(1);

cursor c4 is
select 'x'
from per_career_path_elements
where business_group_id + 0 = p_bgroup_id
and career_path_id = p_cpath_id
and parent_job_id = p_sjob_id;
--
begin
--
hr_utility.set_location('per_career_path_elements_pkg.stb_del_validation',1);
--
open c4;
--
  fetch c4 into l_exists;
--
  IF c4%found THEN
  close c4;
  hr_utility.set_message(801, 'PER_7845_DEF_CAR_MAP_DELETE');
  hr_utility.raise_error;

  END IF;

close c4;

end stb_del_validation;



procedure get_name(p_sjob_id IN NUMBER,
                   p_sjob_name IN OUT nocopy VARCHAR2) is

cursor c5 is
select name
from per_jobs_v
where job_id = p_sjob_id;
--
begin
--
hr_utility.set_location('per_career_path_elements_pkg.get_name',1);
--
open c5;
--
fetch c5 into p_sjob_name;
--
close c5;

end get_name;


end PER_CAREER_PATH_ELEMENTS_PKG;

/
