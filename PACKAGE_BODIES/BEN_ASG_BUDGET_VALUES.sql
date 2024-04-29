--------------------------------------------------------
--  DDL for Package Body BEN_ASG_BUDGET_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ASG_BUDGET_VALUES" as
/* $Header: bebudapi.pkb 120.0 2005/05/28 00:53:24 appldev noship $ */

--

Procedure create_budget_values
(p_assignment_id in number,
p_effective_date in date,
p_unit in varchar2,
p_business_group_id in number,
p_value in number,
p_datetrack_mode in varchar2
) is
cursor c1 is
select
assignment_budget_value_id,
effective_start_date,
effective_end_date,
business_group_id,
assignment_id,
unit,
value,
rowid
from per_assignment_budget_values_f
where
assignment_id = p_assignment_id and
p_effective_date between effective_start_date and effective_end_date and
business_group_id = p_business_group_id and
unit = p_unit;
l_rec c1%ROWTYPE;


BEGIN
open c1;
fetch c1 into l_rec;

IF c1%notfound then

	insert_budget_values
	(p_assignment_id=>p_assignment_id,
	p_effective_date=>p_effective_date,
	p_unit=>p_unit,
	p_business_group_id=>p_business_group_id,
	p_value=>p_value,
	p_rowid=>null,
	p_assignment_budget_value_id=>null);

ELSE
-- check if the value in database is different than the value passed in
  if  p_value <> l_rec.value then
	IF p_datetrack_mode='CORRECTION' OR p_effective_date = l_rec.effective_start_date THEN
	update_dml
	(P_ASSIGNMENT_BUDGET_VALUE_ID=>l_rec.assignment_budget_value_id,
	P_EFFECTIVE_END_DATE=>l_rec.effective_end_date,
	P_BUSINESS_GROUP_ID=>p_business_group_id,
	P_ASSIGNMENT_ID=>p_assignment_id,
	P_VALUE=>p_value
	);
	ELSIF p_datetrack_mode='UPDATE' THEN
	-- First end date the current Row
	update_dml
	(P_ASSIGNMENT_BUDGET_VALUE_ID=>l_rec.assignment_budget_value_id,
	P_EFFECTIVE_END_DATE=>(p_effective_date-1),
	P_BUSINESS_GROUP_ID=>p_business_group_id,
	P_ASSIGNMENT_ID=>p_assignment_id,
	P_VALUE=>l_rec.value
	);

	-- Create another row with
	insert_budget_values
	(p_assignment_id=>p_assignment_id,
	p_effective_date=>p_effective_date,
	p_unit=>p_unit,
	p_business_group_id=>p_business_group_id,
	p_value=>p_value,
	p_rowid=>l_rec.rowid,
	p_assignment_budget_value_id=>l_rec.assignment_budget_value_id);
	END IF;

  end if;
END IF;
close c1;
commit;
end create_budget_values;

---

procedure update_dml(P_ASSIGNMENT_BUDGET_VALUE_ID IN NUMBER,
P_EFFECTIVE_END_DATE IN DATE,
P_BUSINESS_GROUP_ID IN NUMBER,
P_ASSIGNMENT_ID  IN NUMBER,
P_VALUE IN NUMBER
) is
BEGIN
update per_assignment_budget_values_f
set
effective_end_date  = p_effective_end_date,
value = p_value
where assignment_budget_value_id = p_assignment_budget_value_id
and business_group_id = p_business_group_id
and assignment_id = p_assignment_id and
p_effective_end_date between effective_start_date and effective_end_date;
end update_dml;
--
--

PROCEDURE insert_budget_values
(p_assignment_id in number,
p_effective_date in date,
p_unit in varchar2,
p_business_group_id in number,
p_value in number,
p_rowid in varchar2,
p_assignment_budget_value_id in number) is

cursor c2 is
select effective_start_date, rowid from per_assignment_budget_values_f
where
assignment_id = p_assignment_id and
business_group_id = p_business_group_id
order by effective_start_date;

l2_rec c2%ROWTYPE;
l_parent_effective_end_date date;

l_assignment_budget_value_id per_assignment_budget_values_f.ASSIGNMENT_BUDGET_VALUE_ID%TYPE;
--
begin

	-- Date track coding,get the maximum effective end date from the assignment
        -- table (parent record) to ensure that budget values can not go pass
        -- this date.
 per_abv_pkg.get_parent_max_end_date(p_assignment_id => p_assignment_id
                                           ,p_end_date     => l_parent_effective_end_date);
        -- if the session date is greater than the parent assignment end date then raise an error
        -- as a record can not be inserted after the end of the parent assignment.
    if p_effective_date > l_parent_effective_end_date then
      fnd_message.set_name('PER','HR_6645_ASS_COST_DUPL');
      fnd_message.raise_error;
    end if;

	-- check if the records exist with an effective start date later than effective date

	open c2;
	fetch c2 into l2_rec;
	if p_effective_date < l2_rec.effective_start_date then
	l_parent_effective_end_date := (l2_rec.effective_start_date-1);
	--p_rowid := l2_rec.rowid;
	end if;
	close c2;

      -- Date track coding, check for an existing record,using the parent end date to determine
      -- if a record exists.
   per_abv_pkg.check_for_duplicate_record(p_assignment_id => p_assignment_id
                                  ,p_unit                 => p_unit
                                  ,p_start_date           => p_effective_date
                                  ,p_end_date             => l_parent_effective_end_date);
    per_abv_pkg.pre_commit_checks
            (p_assignment_id => p_assignment_id
            ,p_unit => p_unit
            ,p_rowid => p_rowid
            ,p_unique_id => l_assignment_budget_value_id);

if l_assignment_budget_value_id is null then
insert_dml
(P_ASSIGNMENT_BUDGET_VALUE_ID=>p_assignment_budget_value_id,
p_EFFECTIVE_START_DATE=>p_effective_date,
P_EFFECTIVE_END_DATE=>l_parent_effective_end_date,
P_BUSINESS_GROUP_ID=>p_business_group_id,
P_ASSIGNMENT_ID=>p_assignment_id,
P_UNIT=>p_unit,
P_VALUE=>p_value
);
else
insert_dml
(P_ASSIGNMENT_BUDGET_VALUE_ID=>l_assignment_budget_value_id,
p_EFFECTIVE_START_DATE=>p_effective_date,
P_EFFECTIVE_END_DATE=>l_parent_effective_end_date,
P_BUSINESS_GROUP_ID=>p_business_group_id,
P_ASSIGNMENT_ID=>p_assignment_id,
P_UNIT=>p_unit,
P_VALUE=>p_value
);
end if;
end insert_budget_values;
procedure insert_dml
(P_ASSIGNMENT_BUDGET_VALUE_ID IN NUMBER,
p_EFFECTIVE_START_DATE IN DATE,
P_EFFECTIVE_END_DATE IN DATE,
P_BUSINESS_GROUP_ID IN NUMBER,
P_ASSIGNMENT_ID  IN NUMBER,
P_UNIT IN VARCHAR2,
P_VALUE IN NUMBER
) IS
BEGIN
insert into per_assignment_budget_values_f
(ASSIGNMENT_BUDGET_VALUE_ID,
 EFFECTIVE_START_DATE,
 EFFECTIVE_END_DATE,
 BUSINESS_GROUP_ID,
 ASSIGNMENT_ID,
 UNIT,
 VALUE
)
values
(P_ASSIGNMENT_BUDGET_VALUE_ID,
p_EFFECTIVE_START_DATE,
P_EFFECTIVE_END_DATE,
P_BUSINESS_GROUP_ID,
P_ASSIGNMENT_ID,
P_UNIT,
P_VALUE
);
end insert_dml;
end ben_asg_budget_values;

/
