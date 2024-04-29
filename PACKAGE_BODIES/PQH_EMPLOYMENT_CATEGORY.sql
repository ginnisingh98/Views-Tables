--------------------------------------------------------
--  DDL for Package Body PQH_EMPLOYMENT_CATEGORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_EMPLOYMENT_CATEGORY" AS
/* $Header: pqhuseeo.pkb 115.7 2003/11/17 11:39:33 nsanghal noship $*/
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_employment_category.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< fetch_empl_categories >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE fetch_empl_categories (
	p_business_group_id	 in number,
	p_full_time_regular out nocopy varchar2,
	p_full_time_temp    out nocopy varchar2,
	p_part_time_regular out nocopy varchar2,
	p_part_time_temp    out nocopy varchar2 ) IS
--
l_proc        varchar2(72) := g_package||'fetch_empl_categories';
--
l_effective_date date	:= TRUNC(SYSDATE);
l_outputs 	ff_exec.outputs_t;
l_inputs 	ff_exec.inputs_t;
l_formula_id	number;
--
--
cursor  c_frml is
select  formula_id
from	ff_formulas_f
where	formula_name  = 'PQH_EMPLOYMENT_CATEGORY'
and     business_group_id = p_business_group_id
and 	l_effective_date  between effective_start_date and effective_end_date;
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
--
open  c_frml;
  fetch c_frml into l_formula_id;
close c_frml;
--
-- ------------------------------------------------
-- Set the defaults if the formula is not defined.
-- ------------------------------------------------
--

if l_formula_id is null then
 p_full_time_regular	:= '''FR''';
 p_full_time_temp	:= '''FT''';
 p_part_time_regular	:= '''PR''';
 p_part_time_temp	:= '''PT''';
--
else
  --
  begin
  --
  insert into fnd_sessions (
	session_id, effective_date)
	values (userenv('sessionid'), l_effective_date);
  --
  exception
  --
  when dup_val_on_index then
    null;
  end;
  --
  --

  ff_exec.init_formula(l_formula_id, l_effective_date, l_inputs, l_outputs);
  ff_exec.run_formula(l_inputs, l_outputs);
  --
  for l_out_cnt in l_outputs.first..l_outputs.last loop
      if    l_outputs(l_out_cnt).name = 'FULL_TIME_REGULARS' then
  	p_full_time_regular	 := ''''||l_outputs(l_out_cnt).value||'''';
      elsif l_outputs(l_out_cnt).name = 'FULL_TIME_TEMPS' then
	p_full_time_temp  	 := ''''||l_outputs(l_out_cnt).value||'''';
      elsif l_outputs(l_out_cnt).name = 'PART_TIME_REGULARS' then
	p_part_time_regular	 := ''''||l_outputs(l_out_cnt).value||'''';
      elsif l_outputs(l_out_cnt).name = 'PART_TIME_TEMPS' then
	p_part_time_temp  	 := ''''||l_outputs(l_out_cnt).value||'''';
      end if;
  end loop;
end if;
--
hr_utility.set_location(' Leaving:'||l_proc, 10);
--
exception when others then
p_full_time_regular := null;
p_full_time_temp    := null;
p_part_time_regular := null;
p_part_time_temp    := null;
raise;
End;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< identify_empl_categories >----------------------|
-- ----------------------------------------------------------------------------
FUNCTION  identify_empl_category (
	p_empl_category		in varchar2,
	p_full_time_regular	in varchar2,
	p_full_time_temp   	in varchar2,
	p_part_time_regular	in varchar2,
	p_part_time_temp   	in varchar2 ) RETURN varchar2 IS
--
l_proc        varchar2(72)    := g_package||'identify_empl_category';
l_delim     varchar2(3)  := ',';
l_fr     varchar2(10000) := replace(replace(p_full_time_regular,'''',null),'  ',null);
l_ft     varchar2(10000) := replace(replace(p_full_time_temp,'''',null),'  ',null);
l_pr     varchar2(10000) := replace(replace(p_part_time_regular,'''',null),'  ',null);
l_pt     varchar2(10000) := replace(replace(p_part_time_temp,'''',null),'  ',null);
--
l_empl_cat  varchar2(100) := l_delim||p_empl_category||l_delim;
--
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   l_fr   := replace( replace(l_delim||l_fr||l_delim,', ',l_delim), ' ,', l_delim);
   l_ft   := replace( replace(l_delim||l_ft||l_delim,', ',l_delim), ' ,', l_delim);
   l_pr   := replace( replace(l_delim||l_pr||l_delim,', ',l_delim), ' ,', l_delim);
   l_pt   := replace( replace(l_delim||l_pt||l_delim,', ',l_delim), ' ,', l_delim);

  if  instr(l_fr, l_empl_cat) > 0 then
    return 'FR';
  elsif  instr(l_ft, l_empl_cat) > 0 then
    return 'FT';
  elsif  instr(l_pr, l_empl_cat) > 0 then
   return 'PR';
  elsif  instr(l_pt, l_empl_cat) > 0 then
   return 'PT';
  else
   return 'XX';
  end if;

   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
   --
END;
--
--
FUNCTION get_duration_in_months (p_duration IN NUMBER,
                                 p_duration_units IN VARCHAR2,
                                 p_business_group_id IN NUMBER,
                                 p_ref_date IN DATE default sysdate)
RETURN NUMBER IS
l_ref_date  DATE := trunc(NVL(p_ref_date,sysdate));
l_ret_months NUMBER;
l_conv_factor  NUMBER;
CURSOR  csr_conv_factor IS
   SELECT information1
   FROM   per_shared_types
   WHERE  lookup_type = 'QUALIFYING_UNITS'
   AND    business_group_id = p_business_group_id
   AND    system_type_cd = p_duration_units
 UNION ALL
   SELECT information1
   FROM   per_shared_types
   WHERE  lookup_type = 'QUALIFYING_UNITS'
   AND    business_group_id IS NULL
   AND    system_type_cd = p_duration_units;
BEGIN
-- return the duration as it is if the units are Months
    if p_duration_units = 'M' THEN
        RETURN p_duration;
    end if;
--
--get the conversion factor for the Units
    OPEN csr_conv_factor;
    FETCH csr_conv_factor INTO l_conv_factor;
    CLOSE csr_conv_factor;
-- if the conversion factor is set, multiply the duration with CF to get the
-- equivalent months else use default conversion for the known units
    IF l_conv_factor IS NOT NULL THEN
       l_ret_months := p_duration*l_conv_factor;
    ELSE
      IF p_duration_units = 'D' THEN
         l_ret_months := Months_Between(l_ref_date+p_duration,l_ref_date);
      ELSIF p_duration_units = 'Y' THEN
         l_ret_months := p_duration*12;
      ELSIF p_duration_units = 'W' THEN
         l_ret_months := Months_between(l_ref_date+(p_duration*7),l_ref_date );
      ELSE
         l_ret_months := 0;
      END IF;
    END IF;
    RETURN l_ret_months;
END;
FUNCTION get_service_start_date(p_period_of_service_id IN NUMBER) RETURN DATE IS
l_start_date DATE;
CURSOR  csr_pos_date_start IS
SELECT  date_start
FROM    per_periods_of_service
WHERE   period_of_service_id = p_period_of_service_id;
BEGIN
   OPEN csr_pos_date_start;
   FETCH csr_pos_date_start INTO l_start_date;
   CLOSE csr_pos_date_start;
   RETURN l_start_date;
END;
END pqh_employment_category;

/
