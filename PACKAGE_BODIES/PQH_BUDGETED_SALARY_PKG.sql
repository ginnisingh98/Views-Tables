--------------------------------------------------------
--  DDL for Package Body PQH_BUDGETED_SALARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGETED_SALARY_PKG" as
/* $Header: pqbgtsal.pkb 120.0 2005/05/29 01:32:01 appldev noship $ */
--
--Added extra parameters
--
function get_pc_budgeted_salary(   p_position_id 	in number default null
				  ,p_job_id             in number default null
				  ,p_grade_id           in number default null
				  ,p_organization_id    in number default null
				  ,p_budget_entity      in varchar2
                                  ,p_start_date       	in date default sysdate
                                  ,p_end_date       	in date default sysdate
                                  ,p_effective_date 	in date default sysdate
                                  ,p_business_group_id  in number
                                  ) return number is
--
--
l_budget_detail_id number(20);
--
-- Cursor to fetch the Budgeted Salary or the given dates
--
   cursor c_budget_elements is
    select
        stp.start_date,
        etp.end_date, bud.period_set_name,
        (decode('MONEY',
         pqh_psf_bus.get_system_shared_type(bud.budget_unit1_id),bsets.budget_unit1_value,
         pqh_psf_bus.get_system_shared_type(bud.budget_unit2_id),bsets.budget_unit2_value,
         pqh_psf_bus.get_system_shared_type(bud.budget_unit3_id),bsets.budget_unit3_value,
	 0))
        * nvl(bele.distribution_percentage ,0)/100  budget_element_value
    from
        pqh_budgets bud,
        pqh_budget_versions bver,
        pqh_budget_details bdet,
        pqh_budget_periods bper,
        per_time_periods stp,
        per_time_periods etp,
        pqh_budget_sets bsets,
        pqh_budget_elements bele,
        pqh_bdgt_cmmtmnt_elmnts bcl
    where nvl(bud.position_control_flag,'X') = 'Y'
    and bud.budgeted_entity_cd = p_budget_entity
    and bud.business_group_id = p_business_group_id
--    and trunc(p_effective_date) between trunc(bud.budget_start_date) and trunc(bud.budget_end_date)
    and	((p_start_date <= bud.budget_start_date
          and p_end_date >= bud.budget_end_date)
          or
         (p_start_date between bud.budget_start_date and bud.budget_end_date) or
         (p_end_date between bud.budget_start_date and bud.budget_end_date)
        )
    and ( hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'MONEY'
        )
    and bud.budget_id = bver.budget_id
    and trunc(p_effective_date) between trunc(bver.date_from) and trunc(bver.date_to)
    and nvl(p_organization_id, nvl(bdet.organization_id,  -1)) =
                               nvl(bdet.organization_id,  -1)
    and nvl(p_job_id,          nvl(bdet.job_id,   -1)) =
		               nvl(bdet.job_id,   -1)
    and nvl(p_position_id,     nvl(bdet.position_id,      -1)) =
			       nvl(bdet.position_id,      -1)
    and nvl(p_grade_id,        nvl(bdet.grade_id,         -1)) =
			       nvl(bdet.grade_id,         -1)
    and bver.budget_version_id = bdet.budget_version_id
    and bper.budget_detail_id = bdet.budget_detail_id
    and bper.start_time_period_id = stp.time_period_id
    and bper.end_time_period_id = etp.time_period_id
    and etp.end_date >= p_start_date
    and stp.start_date <= p_end_date
    and bsets.budget_period_id = bper.budget_period_id
    and bele.budget_set_id = bsets.budget_set_id
    and bud.budget_id = bcl.budget_id
    and bele.element_type_id = bcl.element_type_id;

    --
    --
    -- Local Variables
    --
    l_salary    		number;
    calc_start_date		date;
    calc_end_date		date;
    l_temp_bdgt_element_value	number := 0;
    --
begin
  --
  -- Prorate the records if start date / end date are between the specified dates
  -- Add all the salary between the specified dates
  --
  hr_utility.set_location('Entering get_pc_budgeted_salary' , 100);

  for l_budget_elements in c_budget_elements
  loop

    --
    --
    -- Prorate the records if start date / end date are between the specified dates
    --
    if p_start_date between l_budget_elements.start_date and l_budget_elements.end_date
        or p_end_date between l_budget_elements.start_date and l_budget_elements.end_date then
      --
      calc_start_date := greatest(l_budget_elements.start_date, p_start_date);
      calc_end_date   := least(l_budget_elements.end_date, p_end_date);
      --
      l_temp_bdgt_element_value := nvl(l_budget_elements.budget_element_value,0) *
            get_prorate_ratio(calc_start_date , calc_end_date , l_budget_elements.period_set_name
            , l_budget_elements.start_date , l_budget_elements.end_date );
    else
      l_temp_bdgt_element_value := l_budget_elements.budget_element_value;
    end if;
    --
    l_salary := nvl(l_salary,0) + l_temp_bdgt_element_value;
    --
    --
  end loop;
    hr_utility.set_location('l_salary '||l_salary , 101);
  --
  -- Return the Total salary
  --
  return(trunc(l_salary,2));
  --
end;

--
-- Sreevijay- Function to calculate the budgeted hours
--
Function get_budgeted_hours(  p_position_id 	   in number default null
			     ,p_job_id             in number default null
			     ,p_grade_id           in number default null
			     ,p_organization_id    in number default null
			     ,p_budget_entity      in varchar2
			     ,p_start_date         in date default sysdate
			     ,p_end_date       	   in date default sysdate
			     ,p_effective_date 	   in date default sysdate
			     ,p_business_group_id  in number
                           ) return number is

   cursor c_budget_periods is
    select
        stp.start_date,
        etp.end_date, bud.period_set_name,
        (decode('HOURS',
         pqh_psf_bus.get_system_shared_type(bud.budget_unit1_id),bper.budget_unit1_value,
         pqh_psf_bus.get_system_shared_type(bud.budget_unit2_id),bper.budget_unit2_value,
         pqh_psf_bus.get_system_shared_type(bud.budget_unit3_id),bper.budget_unit3_value,
	 0)) budget_period_value
    from
        pqh_budgets bud,
        pqh_budget_versions bver,
        pqh_budget_details bdet,
        pqh_budget_periods bper,
        per_time_periods stp,
        per_time_periods etp
    where nvl(bud.position_control_flag,'X') = 'Y'
    and   bud.budgeted_entity_cd = p_budget_entity
    and   bud.business_group_id = p_business_group_id
    and	((p_start_date <= bud.budget_start_date
          and p_end_date >= bud.budget_end_date)
          or
         (p_start_date between bud.budget_start_date and bud.budget_end_date) or
         (p_end_date between bud.budget_start_date and bud.budget_end_date)
        )
    and ( hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'HOURS'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'HOURS'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'HOURS'
        )
    and bud.budget_id = bver.budget_id
    and trunc(p_effective_date) between trunc(bver.date_from) and trunc(bver.date_to)
    and nvl(p_organization_id, nvl(bdet.organization_id,  -1)) =
                               nvl(bdet.organization_id,  -1)
    and nvl(p_job_id,          nvl(bdet.job_id,   -1)) =
		               nvl(bdet.job_id,   -1)
    and nvl(p_position_id,     nvl(bdet.position_id,      -1)) =
			       nvl(bdet.position_id,      -1)
    and nvl(p_grade_id,        nvl(bdet.grade_id,         -1)) =
			       nvl(bdet.grade_id,         -1)
    and bver.budget_version_id = bdet.budget_version_id
    and bper.budget_detail_id = bdet.budget_detail_id
    and bper.start_time_period_id = stp.time_period_id
    and bper.end_time_period_id = etp.time_period_id
    and etp.end_date >= p_start_date
    and stp.start_date <= p_end_date;

    --
    -- Local Variables
    --
    l_hours      		number;
    calc_start_date		date;
    calc_end_date		date;
    l_temp_bdgt_period_value	number := 0;


Begin

  for l_budget_periods in c_budget_periods
  loop
    --
    --
    -- Prorate the records if start date / end date are between the specified dates
    --
    if p_start_date between l_budget_periods.start_date and l_budget_periods.end_date
        or p_end_date between l_budget_periods.start_date and l_budget_periods.end_date then
      --
      calc_start_date := greatest(l_budget_periods.start_date, p_start_date);
      calc_end_date   := least(l_budget_periods.end_date, p_end_date);
      --
      l_temp_bdgt_period_value := nvl(l_budget_periods.budget_period_value,0) *
            get_prorate_ratio(calc_start_date , calc_end_date , l_budget_periods.period_set_name
            , l_budget_periods.start_date , l_budget_periods.end_date );
    else
      l_temp_bdgt_period_value := nvl(l_budget_periods.budget_period_value,0);
    end if;
    --
    l_hours := nvl(l_hours,0) + l_temp_bdgt_period_value;
    --
    --
  end loop;
   hr_utility.set_location('l_hours '|| l_hours , 101);
  --
  -- Return the Total Hours
  --
  return(trunc(l_hours,2));
  --
End;


--
-- Function GET_PRORATE_RATIO which returns the prorate ratio of the parameters passed
--
function get_prorate_ratio(
		p_start_date 		date,
		p_end_date 		date,
        	p_period_set_name 	varchar2,
        	p_period_start_date 	date,
        	p_period_end_date 	date)
return number is
--
-- Cursor to fetch the number of periods in a Calendar(p_period_set_name) between p_start_date and p_end_date
--
cursor no_periods_tp(p_period_set_name varchar2, p_start_date date, p_end_date date) is
select
	count(*)
from
	per_time_periods
where
	period_set_name = p_period_set_name
and 	p_start_date <= start_date
and 	p_end_date >= end_date;
--
-- Cursor to fetch the start_date and end_date of the period which contains p_date
-- from calendar p_period_set_name
--
cursor c_period(p_period_set_name varchar2, p_start_date date, p_end_date date) is
select
	start_date,
	end_date
from
	per_time_periods
where
    	p_period_set_name = period_set_name
and 	((p_start_date <= start_date
          and p_end_date >= end_date
         ) or
        (p_start_date between start_date and end_date) or
        (p_end_date between start_date and end_date)
       	);
--
l_no_total_periods      number := 0;
calc_start_date         date;
calc_end_date           date;
l_temp_ratio            number := 0;
l_total_ratio          number := 0;
begin
--
-- Fetch the Total no of periods between p_period_start_date, p_period_end_date
--
open no_periods_tp(p_period_set_name, p_period_start_date, p_period_end_date);
fetch no_periods_tp into l_no_total_periods;
close no_periods_tp;
--
hr_utility.set_location('l_no_total_periods = ' || l_no_total_periods, 100);
--
--
-- Fetch the start_date and end_date of the period which contains p_start_date
-- and p_end_date from calendar p_period_set_name
--
for l_periods in c_period(p_period_set_name , p_start_date, p_end_date)
loop
    --
    -- Prorate the period if p_start_date between period dates
    -- or p_end_date between period_dates
    --
    if p_start_date between l_periods.start_date and l_periods.end_date
        or p_end_date between l_periods.start_date and l_periods.end_date then
      -- Calculate the calc_start_date  and calc_end_date
      calc_start_date := greatest(l_periods.start_date, p_start_date);
      calc_end_date   := least(l_periods.end_date, p_end_date);
      -- Calculate the l_temp_ratio ( Prorate )
      l_temp_ratio :=
            ((calc_end_date - calc_start_date) + 1)/((l_periods.end_date-l_periods.start_date) + 1);
      --
    else
      -- otherwise 1
      l_temp_ratio := 1;
      --
    end if;
    --
    hr_utility.set_location('l_temp_ratio = ' || l_temp_ratio, 110);
    l_total_ratio := l_total_ratio + l_temp_ratio;
end loop;
--
hr_utility.set_location('l_total_ratio = ' || l_total_ratio, 120);
--
return((l_total_ratio)/l_no_total_periods);
--
end;
--
end;

/
