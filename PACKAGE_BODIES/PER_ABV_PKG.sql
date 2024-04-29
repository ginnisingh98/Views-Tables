--------------------------------------------------------
--  DDL for Package Body PER_ABV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABV_PKG" as
/* $Header: peabv01t.pkb 115.2 99/07/17 18:23:43 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/

--
-- 110.1  31-MAR-1998   SASmith  Change to add two new procedures related to datetracking
--                               of table per_assignment_budget_values.
--                               1. get_parent_max_end_date. This procedure will return the
--                                  maximum end date for the assignment id. This is required to
--                                  be used to set the end date for the child record(s)
--                               2. check_for_duplicate_record. If the current record has effective dates
--                                  which 'fall' within that of an existing record then signal error as this
--                                  is a duplicate record.
--
--
-- ======================================================================================================



procedure check_unique_row(p_assignment_id number
                          ,p_unit varchar2
                          ,p_rowid varchar2);
--
function get_unique_id return number;
--
procedure check_unique_row(p_assignment_id number
                          ,p_unit varchar2
                          ,p_rowid varchar2) is
cursor c is
select 'x'
from   per_assignment_budget_values
where  assignment_id = p_assignment_id
and    unit = p_unit
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
     hr_utility.set_message(801,'HR_6433_EMP_ASS_BUDGET');
     hr_utility.raise_error;
  end if;
  close c;
end check_unique_row;
--
--
function get_unique_id return number is
cursor c is
select per_assignment_budget_values_s.nextval
from sys.dual;
--
l_id number;
--
begin
   open c;
   fetch c into l_id;
   close c;
   return(l_id);
end get_unique_id;
--
--
procedure pre_commit_checks(p_assignment_id number
                          ,p_unit varchar2
                          ,p_rowid varchar2
                          ,p_unique_id IN OUT number) is
begin
   check_unique_row(p_assignment_id
                          ,p_unit
                          ,p_rowid);
--
   if p_rowid is null then
      p_unique_id := get_unique_id;
   end if;
end pre_commit_checks;
--
--
procedure populate_fields(p_unit varchar2
                         ,p_unit_meaning IN OUT varchar2) is
cursor c is
select meaning
from hr_lookups
where lookup_type = 'BUDGET_MEASUREMENT_TYPE'
and   lookup_code = p_unit;
begin
   open c;
   fetch c into p_unit_meaning;
   close c;
end populate_fields;
--
--

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- REQUIRED EXTRA VALIDATION FOR DATE TRACK CODE
-- retireve the maximum effective end date from the assignment to be used to
-- set the effective end date for the budget values record being created.
-- This is because the child record (budget values) cannot have an end date
-- greater than it's parent (assignment).
--
-- SASmith 31-MAR-1998
--------------------------------------------------------------------------------------------

procedure get_parent_max_end_date(p_assignment_id IN number
                                 ,p_end_date      IN OUT date) is
cursor c_end is
select MAX(effective_end_date)
from per_all_assignments_f
where assignment_id = p_assignment_id;

begin
   open c_end;
   fetch c_end into p_end_date;
   close c_end;

end  get_parent_max_end_date;





--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- REQUIRED EXTRA VALIDATION FOR DATE TRACK CODE
-- This procedure tests for an existence of a budget value with the same id
--  which overlaps on any day within the lifetime of the existing row.
-- If this occurs then the record can not be inserted/updated
--
--
-- SASmith 31-Mar-98
--

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

procedure check_for_duplicate_record(p_assignment_id number
                                    ,p_unit varchar2
                                    ,p_start_date date
                                    ,p_end_date date ) is

 cursor C_EXIST_1 is
 select null
 from   PER_ASSIGNMENT_BUDGET_VALUES_F
 where  assignment_id          = p_assignment_id
 and    unit                   = p_unit
 and    effective_start_date  <= p_end_date
 and    effective_end_date    >= p_start_date;

--

--

 d_dummy varchar2(1);
--
BEGIN
open C_EXIST_1;
  fetch C_EXIST_1 into d_dummy;
  if C_EXIST_1%found then
     close C_EXIST_1;

     hr_utility.set_message(800,'HR_52404_ASS_BUD_VAL_DUPL');
     hr_utility.raise_error;

  end if;
  close C_EXIST_1;

END check_for_duplicate_record;

--
--
END PER_ABV_PKG;

/
