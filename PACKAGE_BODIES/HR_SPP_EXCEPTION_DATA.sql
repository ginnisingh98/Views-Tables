--------------------------------------------------------
--  DDL for Package Body HR_SPP_EXCEPTION_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SPP_EXCEPTION_DATA" AS
/* $Header: pesppexc.pkb 115.20 2003/07/11 13:29:53 vramanai noship $ */

--
function get_full_name_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPPDATA(p_placement_id).full_name_val);
exception
when others then
  return ('0');
end;
--
function get_start_date_val(p_placement_id NUMBER) return DATE is
begin
return(SPPDATA(p_placement_id).start_date_val);
exception
when others then
  return null;
end;
--
function get_end_date_val(p_placement_id NUMBER) return DATE is
begin
return(SPPDATA(p_placement_id).end_date_val);
exception
when others then
  return null;
end;
--
function get_assignment_number_val(p_placement_id NUMBER) return varchar2 is
begin
return(SPPDATA(p_placement_id).assignment_number_val);
exception
when others then
  return (0);
end;
--
function get_increment_number_val(p_placement_id NUMBER) return NUMBER is
begin
return(SPPDATA(p_placement_id).increment_number_val);
exception
when others then
  return (0);
end;
--
function get_sequence_number_val(p_placement_id NUMBER) return NUMBER  is
begin
return(SPPDATA(p_placement_id).sequence_number_val);
exception
when others then
  return (0);
end;
--
function get_next_sequence_number_val(p_placement_id NUMBER) return NUMBER  is
begin
return(SPPDATA(p_placement_id).next_sequence_number_val);
exception
when others then
  return (0);
end;
--
function get_original_inc_number_val(p_placement_id NUMBER) return NUMBER is
begin
return(SPPDATA(p_placement_id).original_inc_number_val);
exception
when others then
  return (0);
end;
--
function get_spinal_point_val(p_placement_id NUMBER) return NUMBER is
begin
return(SPPDATA(p_placement_id).spinal_point_val);
exception
when others then
  return (0);
end;
--
function get_reason_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPPDATA(p_placement_id).reason_val);
exception
when others then
  return null;
end;
--
function get_pay_scale_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPPDATA(p_placement_id).pay_scale_val);
exception
when others then
  return null;
end;
--
function get_grade_name_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPPDATA(p_placement_id).grade_name_val);
exception
when others then
  return null;
end;
--

function get_placement_id_val(p_placement_id NUMBER) return NUMBER is
begin
return(SPPDATA(p_placement_id).placement_id_val);
exception
when others then
  return null;
end;
--

function get_org_name_val(p_placement_id NUMBER) return VARCHAR2 is
begin
return(SPPDATA(p_placement_id).org_name_val);
exception
when others
then
  return ('0');
end;
--

procedure populate_spp_table
  (p_effective_date		date
  ,p_placement_id		number
  ,p_effective_start_date	date
  ,p_effective_end_date		date
  ,p_assignment_id		number
  ,p_parent_spine_id		number
  ,p_increment_number		number
  ,p_original_increment_number  number
  ,p_sequence_number		number
  ,p_next_sequence_number	number
  ,p_spinal_point_id		number
  ,p_step_id			number
  ,p_new_step_id		number
  ,p_grade_spine_id		number
  ,p_update			varchar2
  ) is

l_pay_scale		  varchar2(30);
l_grade_name    	  per_grades.name%TYPE;
l_full_name     	  varchar2(60);
l_sequence_number 	  number;
l_parent_spine_id 	  number;
l_special_ceiling_step_id number;
l_ceiling_step_id 	  number;
l_step_id 	 	  number;
l_lookup_code		  varchar2(10);
l_assignment_number	  per_all_assignments_f.assignment_number%TYPE;
l_new_sequence_number	  number;
l_flag			  varchar2(2);
l_effective_end_date	  date;
l_grade_spine_id	  number;
l_payroll_id		  number;
l_org_name                varchar2(60);

--
-- Cursor to determine if the record was flagged due to the next
-- record being on the same pay scale with a greater sequence number
-- than the one being inserted or if the step_id beeing inserted has
-- a greater sequence number than the future record ands so no update
-- done.
--
cursor csr_sequence_number is
select sps.sequence,spp1.parent_spine_id
  from per_spinal_point_placements_f spp1,
       per_spinal_point_placements_f spp2,
       per_spinal_point_steps_f sps
  where spp1.step_id = sps.step_id
  and p_effective_date = spp1.effective_start_date
  and spp2.effective_start_date = spp1.effective_end_date +1
  and spp2.placement_id = spp1.placement_id
  and spp1.placement_id = p_placement_id;

--
-- If csr_sequence_number not found then check for future record
-- with same parent spine
--
cursor csr_future_record is
select parent_spine_id
from per_spinal_point_placements_f
where placement_id = p_placement_id
and parent_spine_id = p_parent_spine_id
and p_effective_date between effective_start_date
			 and effective_end_date;

begin
  hr_utility.set_location(p_placement_id,191);
  hr_utility.set_location(p_effective_start_date,192);
  hr_utility.set_location(p_effective_end_date,193);
  hr_utility.set_location(p_assignment_id,194);
  hr_utility.set_location(p_parent_spine_id,195);
  hr_utility.set_location(p_increment_number,196);
  hr_utility.set_location(p_original_increment_number,197);
  hr_utility.set_location(p_sequence_number,198);
  hr_utility.set_location(p_next_sequence_number,199);
  hr_utility.set_location(p_spinal_point_id,200);
  hr_utility.set_location(p_step_id,201);
  hr_utility.set_location(p_new_step_id,202);
  --
  -- get the full name and assignment number of the employee
  --
  hr_utility.set_location('full name and assignment number',120);
  select distinct substr(pap.full_name,1,60),paa.assignment_number,paa.payroll_id,
         substr(org.name ,1,60)
  into l_full_name,l_assignment_number,l_payroll_id,l_org_name
  from per_all_people_f pap,
       per_all_assignments_f paa,
       hr_all_organization_units org
  where pap.person_id     = paa.person_id
  and   paa.organization_id = org.organization_id
  and   paa.assignment_id = p_assignment_id
  and   p_effective_date between paa.effective_start_date
                             and paa.effective_end_date
  and   p_effective_date between pap.effective_start_date    -- 2276901
                             and pap.effective_end_date;    -- 2276901


  --
  -- get the pay scale name
  --
  hr_utility.set_location(' Pay scale name',121);
  hr_utility.set_location('parent_spine_id'||p_parent_spine_id,121);
  select pps.name
  into l_pay_scale
  from per_parent_spines pps
  where pps.parent_spine_id = p_parent_spine_id;

  --
  -- get the grade name
  --
  hr_utility.set_location('grade name',122);
  select substr(pg.name,1,30),pgs.grade_spine_id
  into l_grade_name,l_grade_spine_id
  from per_grades_vl pg,
       per_spinal_point_steps_f sps,
       per_grade_spines_f pgs
  where pg.grade_id 	    = pgs.grade_id
  and   pgs.grade_spine_id  = sps.grade_spine_id
  and   sps.step_id         = p_step_id
  and   p_effective_date between sps.effective_start_date
			     and sps.effective_end_date
  and   p_effective_date between pgs.effective_start_date	-- 2276901
			     and pgs.effective_end_date		-- 2276901
  and   sps.spinal_point_id = p_spinal_point_id;

  --
  -- get the max step_id for the pay scale
  --
  hr_utility.set_location('max step_id for the pay scale',123);
  select max(sps2.sequence)
  into l_step_id
  from per_spinal_point_steps_f sps2
  where sps2.grade_spine_id = p_grade_spine_id
  and   p_effective_date between sps2.effective_start_date
			   and sps2.effective_end_date;

  --
  -- select the ceiling step id for the pay scale and the special
  -- ceiling step id fro the assignment
  --
  hr_utility.set_location('ceiling step id for the assignment',124);
  hr_utility.set_location('p_assignment_id:'||p_assignment_id,124);
  hr_utility.set_location('p_new_step_id:'||p_new_step_id,124);
  hr_utility.set_location('p_step_id:'||p_step_id,124);
  hr_utility.set_location('p_effective_start_date:'||p_effective_start_date,124);
  --
  select distinct pgs.ceiling_step_id,
         nvl(paa.special_ceiling_step_id,pgs.ceiling_step_id)
  into l_ceiling_step_id, l_special_ceiling_step_id
  from per_grade_spines_f pgs,
       per_spinal_point_steps_f sps,
       per_spinal_point_placements_f spp,
       per_all_assignments_f paa
  where pgs.grade_spine_id = sps.grade_spine_id
  and   paa.assignment_id  = spp.assignment_id
  and   spp.assignment_id  = p_assignment_id
  and   sps.step_id	   = spp.step_id
  -- and   spp.step_id	   = nvl(p_new_step_id,p_step_id)
  and   p_effective_start_date between paa.effective_start_date
			           and paa.effective_end_date
  and   p_effective_start_date between pgs.effective_start_date
                                   and pgs.effective_end_date
  and   p_effective_start_date between sps.effective_start_date
                                   and sps.effective_end_date
  and   p_effective_start_date between spp.effective_start_date
                                   and spp.effective_end_date;
  --
  hr_utility.set_location('CEILINGS - Special: '||l_special_ceiling_step_id,125);
  hr_utility.set_location('Pay Scale Ceiling : '||l_ceiling_step_id,125);
  hr_utility.set_location('Entering csr_sequence_number',125);
  hr_utility.set_location('Lookup Code : '||l_lookup_code,125);
  --
  -- Set the lookup code for the reason for employee being included in
  -- the report
  --

  -- ------------------------------------------------------------------
  -- Open cursor to discover if future record existed.
  -- ------------------------------------------------------------------
  open csr_sequence_number;
  hr_utility.set_location('opening cursor',125);
  fetch csr_sequence_number into l_sequence_number,l_parent_spine_id;
   if csr_sequence_number%found then
    hr_utility.set_location('cursor found',126);
    hr_utility.set_location('l_sequence_number'||l_sequence_number,126);
    hr_utility.set_location('p_sequence_number:'||p_sequence_number,126);
    hr_utility.set_location('p_parent_spine_id:'||p_parent_spine_id,126);
    hr_utility.set_location('l_parent_spine_id'||l_parent_spine_id,126);
    hr_utility.set_location('p_original_increment_number:'||p_original_increment_number,126);
    hr_utility.set_location('p_increment_number:'||p_increment_number,126);
    -- ------------------------------------------------------------------
    -- update done as sequence number <= next sequence number
    -- l_sequence_number = sequence number of next record for placement
    -- ------------------------------------------------------------------
    if l_sequence_number >= p_sequence_number
     and l_parent_spine_id = p_parent_spine_id
       and l_grade_spine_id = p_grade_spine_id then
       hr_utility.set_location('Insert done but flagged as future change',127);
       l_lookup_code := 'EXC_INC_1';
    -- ------------------------------------------------------------------
    -- Check that ceiling step id hasn't been reached
    -- ------------------------------------------------------------------
    elsif (p_new_step_id = l_ceiling_step_id) then
      hr_utility.set_location('Ceiling step id reached',130);
      l_lookup_code := 'EXC_INC_2';
    -- ------------------------------------------------------------------
    -- Check that special ceiling step id hasn't been reached
    -- ------------------------------------------------------------------
    elsif (p_new_step_id = l_special_ceiling_step_id) then
      hr_utility.set_location('Special ceiling step id reached',131);
      l_lookup_code := 'EXC_INC_3';
    -- ------------------------------------------------------------------
    -- Check to see if max step id for pay scale reached
    -- ------------------------------------------------------------------
    elsif (l_step_id = p_new_step_id) then
      hr_utility.set_location('Max step id for pay scale reached',132);
      l_lookup_code := 'EXC_INC_4';
    -- ------------------------------------------------------------------
    -- Check increment number was greater than the number of steps
    -- available for the pay scale
    -- ------------------------------------------------------------------
    elsif (p_original_increment_number <> p_increment_number)
      and p_increment_number <> 0 then
      hr_utility.set_location('Increment number changed',129);
      l_lookup_code := 'EXC_INC_5';
    -- ------------------------------------------------------------------
    -- Future grade scale change
    -- ------------------------------------------------------------------
    elsif (p_grade_spine_id <> l_grade_spine_id) then
      hr_utility.set_location('Future grade change',129);
       l_lookup_code := 'EXC_INC_1';
    end if;
    --
  elsif csr_sequence_number%notfound or
    l_lookup_code is null then

    open csr_future_record;
    fetch csr_future_record into l_parent_spine_id;
    if csr_future_record%found then
      l_flag := 'Y';
    else
      l_flag := 'N';
    end if;
    close csr_future_record;
    --
    hr_utility.set_location('cursor not found',127);
    hr_utility.set_location('l_sequence_number:'||l_sequence_number,127);
    hr_utility.set_location('p_sequence_number:'||p_sequence_number,127);
    hr_utility.set_location('l_parent_spine_id:'||l_parent_spine_id,127);
    hr_utility.set_location('p_parent_spine_id:'||p_parent_spine_id,127);
    hr_utility.set_location('p_original_increment_number:'||p_original_increment_number,127);
    hr_utility.set_location('p_increment_number:'||p_increment_number,127);
    hr_utility.set_location('***********************',127);
    hr_utility.set_location('p_step_id:'||p_step_id,128);
    hr_utility.set_location('l_ceiling_step_id:'||l_ceiling_step_id,128);
    hr_utility.set_location('l_special_ceiling_step_id:'||l_special_ceiling_step_id,128);
    hr_utility.set_location('l_step_id:'||l_step_id,128);
    hr_utility.set_location('l_flag:'||l_flag,128);
    --
    -- ------------------------------------------------------------------
    -- Check if record not inserted
    -- ------------------------------------------------------------------
    if p_original_increment_number <> p_increment_number
     and l_flag = 'Y'
      and p_new_step_id <> l_ceiling_step_id
       and p_new_step_id <> l_special_ceiling_step_id
        and p_new_step_id <> l_step_id then
       hr_utility.set_location('No insert done as future change',128);
       l_lookup_code := 'EXC_4';
    -- ------------------------------------------------------------------
    -- Check that ceiling step id hasn't been reached
    -- ------------------------------------------------------------------
    elsif (p_new_step_id = l_ceiling_step_id) then
      if p_update = 'Y' then
        l_lookup_code := 'EXC_INC_2';
      else
      hr_utility.set_location('Ceiling step id reached',130);
      l_lookup_code := 'EXC_1';
      end if;
    -- ------------------------------------------------------------------
    -- Check that special ceiling step id hasn't been reached
    -- ------------------------------------------------------------------
    elsif (p_new_step_id = l_special_ceiling_step_id) then
      if p_update = 'Y' then
        l_lookup_code := 'EXC_INC_3';
      else
      hr_utility.set_location('Special ceiling step id reached',131);
      l_lookup_code := 'EXC_2';
      end if;
    -- ------------------------------------------------------------------
    -- Check to see if max step id for pay scale reached
    -- ------------------------------------------------------------------
    elsif (l_step_id = p_new_step_id) then
       if p_update = 'Y' then
        l_lookup_code := 'EXC_INC_4';
       else
      hr_utility.set_location('Max step id for pay scale reached',132);
      l_lookup_code := 'EXC_3';
       end if;
    end if;
  end if;
  close csr_sequence_number;

  -- ----------------------------------------------------------------------
  -- Check if the lookup code is null and if so the payroll_id
  -- ----------------------------------------------------------------------

  if l_lookup_code is null and l_payroll_id is null then

     hr_utility.set_location('No payroll set when using business rule for next pay period.',133);
     l_lookup_code := 'EXC_5';

  end if;


  -- ----------------------------------------------------------------------
  -- Setup the reason code if spinal point
  -- ----------------------------------------------------------------------
  --
  -- End of lookup code
  --
  SPPDATA(p_placement_id).placement_id_val		:= p_placement_id;
  SPPDATA(p_placement_id).full_name_val 		:= l_full_name;
  SPPDATA(p_placement_id).pay_scale_val			:= l_pay_scale;
  SPPDATA(p_placement_id).grade_name_val		:= l_grade_name;
  SPPDATA(p_placement_id).start_date_val		:= p_effective_start_date;
  SPPDATA(p_placement_id).end_date_val			:= p_effective_end_date;
  SPPDATA(p_placement_id).assignment_number_val		:= l_assignment_number;
  SPPDATA(p_placement_id).increment_number_val		:= p_increment_number;
  SPPDATA(p_placement_id).original_inc_number_val 	:= p_original_increment_number;
  SPPDATA(p_placement_id).sequence_number_val 		:= p_sequence_number;
  SPPDATA(p_placement_id).next_sequence_number_val	:= p_next_sequence_number;
  SPPDATA(p_placement_id).spinal_point_val		:= p_spinal_point_id;
  SPPDATA(p_placement_id).reason_val			:= l_lookup_code;
  SPPDATA(p_placement_id).org_name_val                  := l_org_name;

end populate_spp_table;

END HR_SPP_EXCEPTION_DATA;

/
