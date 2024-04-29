--------------------------------------------------------
--  DDL for Package Body HR_LEGISLATION_SUBGROUPS_PKG_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEGISLATION_SUBGROUPS_PKG_1" as
/* $Header: pylgs01t.pkb 115.1 99/07/17 06:15:40 porting ship  $ */

procedure b_check_duplicate_in (p_legis_code IN VARCHAR2,
                                 p_legis_sub IN VARCHAR2,
                                 p_rowid IN VARCHAR2) IS
              l_exists VARCHAR2(1);

cursor c1 is
  select 'x'
  from hr_legislation_subgroups
  where legislation_code = p_legis_code
  and legislation_subgroup = p_legis_sub
  and (p_rowid is null
   or (p_rowid is not null and chartorowid(p_rowid) <> rowid));
--
begin
--
hr_utility.set_location('hr_legislation_subgroups_pkg_1.b_check_duplicate_in',1);
--
open c1;
--
  fetch c1 into l_exists;
  IF c1%found THEN
     hr_utility.set_message('801', 'HR_6890_PAY_LEG_SUB');
     close c1;
     hr_utility.raise_error;
  END IF;
--
close c1;
--
end b_check_duplicate_in;



end HR_LEGISLATION_SUBGROUPS_PKG_1;

/
