--------------------------------------------------------
--  DDL for Package Body PER_CAREER_PATHS_PKG_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAREER_PATHS_PKG_1" as
/* $Header: pecpt01.pkb 115.1 99/07/17 18:51:52 porting ship $ */

procedure stb_del_val(p_cpath_id IN NUMBER) IS
          l_exists VARCHAR2(1);

cursor c1 is
  select 'x'
  from per_career_path_elements
  where career_path_id = p_cpath_id;
--
begin
--
hr_utility.set_location('per_career_paths_pkg_1.stb_del_val',1);
--
open c1;
--
fetch c1 into l_exists;
--
  IF c1%found THEN
     hr_utility.set_message(800, 'PER_7840_DEF_CAR_PATH_DELETE');
     close c1;
     hr_utility.raise_error;
  END IF;
--
close c1;
--
end stb_del_val;


procedure unique_chk(p_bgroup_id IN NUMBER,
                   p_name IN VARCHAR2,
                   p_rowid IN VARCHAR2) IS
            l_exists2 VARCHAR2(1);

cursor c2 is
  select 'x'
  from per_career_paths
  where business_group_id + 0 = p_bgroup_id
  and upper(name) = upper(p_name)
  and (p_rowid is null
   or (p_rowid is not null and chartorowid(p_rowid) <> rowid));
--
begin
--
hr_utility.set_location('per_career_paths_pkg_1.unique_chk',1);
--
open c2;
--
fetch c2 into l_exists2;
--
  IF c2%found THEN
     hr_utility.set_message(800, 'PER_7841_DEF_CAR_PATH_EXISTS');
     close c2;
     hr_utility.raise_error;
  END IF;
--
close c2;
--
end unique_chk;


procedure get_id(p_cpath_id IN OUT NUMBER) IS

cursor c3 is
  select per_career_paths_s.nextval
  from sys.dual;
--
begin
--
hr_utility.set_location('per_career_paths_pkg_1.get_id',1);
--
open c3;
--
fetch c3 into p_cpath_id;
--
close c3;
--
end get_id;



end PER_CAREER_PATHS_PKG_1;

/
