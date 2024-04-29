--------------------------------------------------------
--  DDL for Package Body HR_SPP_WI_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SPP_WI_DATA" AS
/* $Header: pesppwif.pkb 120.0.12010000.2 2009/07/09 09:21:22 lbodired ship $ */

function get_placement_id_val(p_placement_id NUMBER) return NUMBER is
begin
return(SPP_WI_DATA(p_placement_id).placement_id_val);
exception
when others then
  return null;
end;
--
function get_assignment_number_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPP_WI_DATA(p_placement_id).assignment_number_val);
exception
when others then
  return null;
end;
--
function get_pay_scale_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPP_WI_DATA(p_placement_id).pay_scale_val);
exception
when others then
  return null;
end;
--
function get_grade_name_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPP_WI_DATA(p_placement_id).grade_name_val);
exception
when others then
  return null;
end;
--
function get_old_spinal_point_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPP_WI_DATA(p_placement_id).old_spinal_point_val);
exception
when others then
  return null;
end;
--
function get_new_spinal_point_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPP_WI_DATA(p_placement_id).new_spinal_point_val);
exception
when others then
  return null;
end;
--
function get_old_value_val(p_placement_id NUMBER) return NUMBER is
begin
return(SPP_WI_DATA(p_placement_id).old_value_val);
exception
when others then
  return null;
end;
--
function get_new_value_val(p_placement_id NUMBER) return NUMBER is
begin
return(SPP_WI_DATA(p_placement_id).new_value_val);
exception
when others then
  return null;
end;
--
function get_difference_val(p_placement_id NUMBER) return NUMBER is
begin
return(SPP_WI_DATA(p_placement_id).difference_val);
exception
when others then
  return null;
end;
--
function get_full_name_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPP_WI_DATA(p_placement_id).full_name_val);
exception
when others then
  return null;
end;
--
function get_assignment_id_val(p_placement_id NUMBER) return NUMBER is
begin
return(SPP_WI_DATA(p_placement_id).assignment_id_val);
exception
when others then
  return null;
end;
--
function get_org_name_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPP_WI_DATA(p_placement_id).org_name_val);
exception
when others then
  return null;
end;

procedure populate_spp_wi_table
  (p_placement_id		number
  ,p_assignment_id 		number
  ,p_effective_date		date
  ,p_parent_spine_id		number
  ,p_step_id			number
  ,p_spinal_point_id		number
  ,p_rate_id			number
  ) is

   -- Bug fix 3571874. Cursor modified to check rate_type while min(rate_id)
   -- is fetched.
  cursor csr_point_values( l_old_spinal_point_id number ,
                           l_new_spinal_point_id number )  is
  select fnd_number.canonical_to_number(pgr1.value),
         fnd_number.canonical_to_number(pgr2.value)
  from pay_grade_rules_f pgr1,
       pay_grade_rules_f pgr2
  where pgr1.grade_or_spinal_point_id = l_old_spinal_point_id
  and   pgr2.grade_or_spinal_point_id = l_new_spinal_point_id
  and   pgr1.rate_type = 'SP'
  and   pgr2.rate_type = 'SP'
  and   pgr1.rate_id = (select min(rate_id)
			from pay_grade_rules_f pgr3
			where pgr1.grade_or_spinal_point_id = pgr3.grade_or_spinal_point_id
			and pgr3.rate_type = 'SP'
			and (p_rate_id is null
			  or p_rate_id = pgr3.rate_id))
  and   pgr2.rate_id = (select min(rate_id)
                        from pay_grade_rules_f pgr4
                        where pgr2.grade_or_spinal_point_id = pgr4.grade_or_spinal_point_id
				and pgr4.rate_type = 'SP'
                        and (p_rate_id is null
                          or p_rate_id = pgr4.rate_id))
  and   p_effective_date between pgr2.effective_start_date
                             and pgr2.effective_end_date
  and   (p_effective_date - 1) between pgr1.effective_start_date
                                   and pgr1.effective_end_date;

  l_full_name 		varchar2(60);
  l_pay_scale		varchar2(30);
  l_old_spinal_point    varchar2(30);
  l_new_spinal_point    varchar2(30);
  l_old_value		number;
  l_new_value		number;
  l_grade_name  	per_grades.name%TYPE;
  l_old_spinal_point_id number;
  l_new_spinal_point_id number;
  l_assignment_number   per_all_assignments_f.assignment_number%TYPE;
  l_effective_start_date date;
  l_org_name            varchar2(60);

begin
  hr_utility.set_location(p_placement_id,191);
  hr_utility.set_location(p_assignment_id,191);
  hr_utility.set_location(p_effective_date,191);
  hr_utility.set_location(p_parent_spine_id,191);
  hr_utility.set_location(p_step_id,191);
  hr_utility.set_location(p_spinal_point_id,191);

  select distinct substr(pap.full_name,1,60) ,paa.assignment_number,substr(org.name,1,60)
  into l_full_name ,l_assignment_number,l_org_name
  from per_all_people_f pap,
       per_all_assignments_f paa,
       hr_all_organization_units org
  where pap.person_id = paa.person_id
  and paa.organization_id = org.organization_id
  and   paa.assignment_id = p_assignment_id
  and   p_effective_date between paa.effective_start_date
			     and paa.effective_end_date
  and   p_effective_date between pap.effective_start_date  -- 2276901
			     and pap.effective_end_date;  -- 2276901

  --
  -- get the pay scale name
  --
  hr_utility.set_location(' Pay scale name',121);
  hr_utility.set_location('parent_spine_id'||p_parent_spine_id,121);
  select substr(pps.name,1,30)
  into l_pay_scale
  from per_parent_spines pps
  where pps.parent_spine_id = p_parent_spine_id;

  --
  -- get the grade name
  --
  hr_utility.set_location('grade name',122);
  select substr(pg.name,1,30)
  into l_grade_name
  from per_grades_vl pg,
       per_spinal_point_steps_f sps,
       per_grade_spines_f pgs
  where pg.grade_id         = pgs.grade_id
  and   pgs.grade_spine_id  = sps.grade_spine_id
  and   sps.step_id         = p_step_id
  and   p_effective_date between sps.effective_start_date	-- 2276901
                                and sps.effective_end_date	-- 2276901
  and   p_effective_date between pgs.effective_start_date	-- 2276901
                                and pgs.effective_end_date;	-- 2276901
--  and   sps.spinal_point_id = p_spinal_point_id;

   select min(effective_start_date)
   into l_effective_start_date
   from per_spinal_point_placements_f
   where placement_id = p_placement_id;

    if l_effective_start_date = p_effective_date
   then

    select substr(psp.spinal_point,1,30),
	   psp.spinal_point_id
    into   l_new_spinal_point,
	   l_new_spinal_point_id
    from   per_spinal_points psp,
	   per_spinal_point_steps_f sps
    where  psp.spinal_point_id = sps.spinal_point_id
    and    sps.step_id = p_step_id
    and    p_effective_date between sps.effective_start_date
			        and sps.effective_end_date;

    l_old_spinal_point := 'NULL';
    l_old_spinal_point_id := null;

  else

  --
  -- get the old and new spinal points
  --
  hr_utility.set_location('spinal points',123);
  select substr(psp1.spinal_point,1,30),
         substr(psp2.spinal_point,1,30),
	 psp1.spinal_point_id,
	 psp2.spinal_point_id
  into l_old_spinal_point,
       l_new_spinal_point,
       l_old_spinal_point_id,
       l_new_spinal_point_id
  from per_spinal_points psp1,
       per_spinal_points psp2,
       per_spinal_point_placements_f spp,
       per_spinal_point_steps_f sps1,
       per_spinal_point_steps_f sps2
  where psp1.spinal_point_id = sps1.spinal_point_id
  and   psp2.spinal_point_id = sps2.spinal_point_id
  and   sps2.step_id = p_step_id
  and   sps1.step_id = spp.step_id
  and   spp.placement_id = p_placement_id
  and   spp.effective_end_date = p_effective_date - 1
  and   p_effective_date between sps1.effective_start_date
			     and sps1.effective_end_date
  and   p_effective_date between sps2.effective_start_date
			     and sps2.effective_end_date;

 end if;

  hr_utility.set_location('l_old_spinal_point:'||l_old_spinal_point,124);
  hr_utility.set_location('l_new_spinal_point:'||l_new_spinal_point,124);
  hr_utility.set_location('l_old_spinal_point_id:'||l_old_spinal_point_id,124);

 open csr_point_values(l_old_spinal_point_id,l_new_spinal_point_id);
  fetch csr_point_values into l_old_value,l_new_value;
  if csr_point_values%notfound then
    l_old_value := 0;
    l_new_value := 0;
  end if;
 close csr_point_values;


  SPP_WI_DATA(p_placement_id).placement_id_val		:= p_placement_id;
  SPP_WI_DATA(p_placement_id).assignment_id_val		:= p_assignment_id;
  SPP_WI_DATA(p_placement_id).assignment_number_val	:= l_assignment_number;
  SPP_WI_DATA(p_placement_id).full_name_val		:= l_full_name;
  SPP_WI_DATA(p_placement_id).pay_scale_val		:= l_pay_scale;
  SPP_WI_DATA(p_placement_id).grade_name_val		:= l_grade_name;
  SPP_WI_DATA(p_placement_id).old_spinal_point_val	:= l_old_spinal_point;
  SPP_WI_DATA(p_placement_id).new_spinal_point_val	:= l_new_spinal_point;
  SPP_WI_DATA(p_placement_id).old_value_val		:= l_old_value;
  SPP_WI_DATA(p_placement_id).new_value_val             := l_new_value;
  SPP_WI_DATA(p_placement_id).difference_val 		:= (l_new_value - l_old_value);
  SPP_WI_DATA(p_placement_id).org_name_val              := l_org_name;

end populate_spp_wi_table;

END HR_SPP_WI_DATA;

/
