--------------------------------------------------------
--  DDL for Package Body HR_CAGR_FF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAGR_FF_PKG" AS
/* $Header: hrcagrff.pkb 115.6 2002/12/09 14:45:49 hjonnala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_cagr_ff_pkg.';

/*
 Name        : hr_cagr_ff_pkg  (BODY)
*/
--
-- ------------------- cagr_entitlement_ff --------------------
--
--
procedure cagr_entitlement_ff
( p_formula_id    	IN  NUMBER,
  p_effective_date      IN  DATE,
  p_assignment_id       IN  NUMBER,
  p_category_name	IN  VARCHAR2,
  p_out_rec	 OUT NOCOPY hr_cagr_ff_pkg.cagr_FF_record) IS
--
  l_proc      varchar2(72)  := g_package||'cagr_entitlement_ff';
--
  l_formula_id 			NUMBER;
  l_effective_start_date	DATE;
  l_effective_end_date		DATE;
  l_inputs			ff_exec.inputs_t;
  l_outputs			ff_exec.outputs_t;
  l_business_group_id		NUMBER;
  l_person_id         		NUMBER;
  l_organization_id   		NUMBER;
  l_payroll_id        		NUMBER;
  l_tax_unit_id        		NUMBER;
  l_formula_name       		VARCHAR2(30);

  cursor csr_assignment is
    select paf.business_group_id
	, paf.organization_id
	, paf.payroll_id
	, paf.person_id
	, scl.segment1
    from per_all_assignments_f paf,
	 hr_soft_coding_keyflex scl
    where paf.assignment_id = p_assignment_id
    and   p_effective_date between paf.effective_start_date
				and paf.effective_end_date
    and	  paf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id(+);

  cursor csr_formula is
    select  ff.formula_name
    from    ff_formulas_f ff
    where   ff.formula_id = p_formula_id
    and     p_effective_date between ff.effective_start_date
                                and ff.effective_end_date;

--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- validate arguments prior to calling FF
  --
  -- check national identifier is not null
  --
  if p_assignment_id is null then
    hr_utility.set_message(800,'HR_XXXXX_ASSIGNMENT_ID_NULL');
    hr_utility.raise_error;
  end if;
  --
open csr_formula;

fetch csr_formula into l_formula_name;

close csr_formula;
  --
  hr_utility.set_location(l_proc, 20);
  --
open csr_assignment;

fetch csr_assignment into
	  l_business_group_id
	, l_organization_id
	, l_payroll_id
	, l_person_id
	, l_tax_unit_id;
  --
close csr_assignment;

  --
hr_utility.set_location('l_business_group_id = '||to_char(l_business_group_id),11);
hr_utility.set_location('l_organization_id = '||to_char(l_organization_id),11);
hr_utility.set_location('l_payroll_id = '||to_char(l_payroll_id),11);
hr_utility.set_location('l_person_id = '||to_char(l_person_id),11);
   --
per_cagr_utility_pkg.put_log('   Information : Formula '||l_formula_name);
per_cagr_utility_pkg.put_log('   Information : Business Group ID = '||l_business_group_id);
per_cagr_utility_pkg.put_log('   Information : Organization ID   = '||l_organization_id);
per_cagr_utility_pkg.put_log('   Information : Payroll ID        = '||l_payroll_id);
per_cagr_utility_pkg.put_log('   Information : Person ID         = '||l_person_id);
per_cagr_utility_pkg.put_log('   Information : Tax Unit ID       = '||l_tax_unit_id);

   ff_exec.init_formula(p_formula_id,p_effective_date,l_inputs,l_outputs);
   --
      hr_utility.set_location('Inputs='||ff_exec.input_count,6);
      hr_utility.set_location('Contexts='||ff_exec.context_count,6);
      hr_utility.set_location('Outputs='||ff_exec.output_count,6);

      if ff_exec.input_count > 0  then
      per_cagr_utility_pkg.put_log('ERROR : CAGR formula has unexpected Input values defined.');
      end if;
--      if ff_exec.output_count < 8  then
--      per_cagr_utility_pkg.put_log('ERROR : CAGR formula has less than 8 Output values defined.');
--      end if;
--      if ff_exec.output_count > 8  then
--      per_cagr_utility_pkg.put_log('ERROR : CAGR formula has more than 8 Output values defined.');
--      end if;
--      hr_utility.set_location('FF',12);
   --

   for l_in_cnt in l_inputs.first..l_inputs.last
   loop
      if l_inputs(l_in_cnt).name='ASSIGNMENT_ID' then
         l_inputs(l_in_cnt).value := p_assignment_id;
-- per_cagr_utility_pkg.put_log('Information : Context - Assignment ID');
      hr_utility.set_location('ASSIGNMENT_ID',13);
      elsif l_inputs(l_in_cnt).name='DATE_EARNED' then
         l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(p_effective_date);
-- per_cagr_utility_pkg.put_log('Information : Context - DATE_EARNED');
      hr_utility.set_location('DATE_EARNED',14);
      elsif l_inputs(l_in_cnt).name='PERSON_ID' then
         l_inputs(l_in_cnt).value := l_person_id;
-- per_cagr_utility_pkg.put_log('Information : Context - PERSON_ID');
      hr_utility.set_location('PERSON_ID',15);
      elsif l_inputs(l_in_cnt).name='ORGANIZATION_ID' then
         l_inputs(l_in_cnt).value := l_organization_id;
-- per_cagr_utility_pkg.put_log('Information : Context - ORGANIZATION_ID');
      hr_utility.set_location('ORGANIZATION_ID',16);
      elsif l_inputs(l_in_cnt).name='BUSINESS_GROUP_ID' then
         l_inputs(l_in_cnt).value := l_business_group_id;
-- per_cagr_utility_pkg.put_log('Information : Context - BUSINESS_GROUP_ID');
      hr_utility.set_location('BUSINESS_GROUP_ID',17);
      elsif l_inputs(l_in_cnt).name='PAYROLL_ID' then
         l_inputs(l_in_cnt).value := l_payroll_id;
-- per_cagr_utility_pkg.put_log('Information : Context - PAYROLL_ID');
      hr_utility.set_location('PAYROLL_ID',18);
      elsif l_inputs(l_in_cnt).name='TAX_UNIT_ID' then
         l_inputs(l_in_cnt).value := l_tax_unit_id;
-- per_cagr_utility_pkg.put_log('Information : Context - TAX_UNIT_ID');
      hr_utility.set_location('TAX_UNIT_ID',19);
      end if;
-- per_cagr_utility_pkg.put_log('Information : End of Context Section ');
   end loop;
   --
   hr_utility.set_location(l_proc, 15);
   --
   --
-- per_cagr_utility_pkg.put_log('Before Start of Run Formula ');
   ff_exec.run_formula
	(P_INPUTS	=> l_inputs
	,P_OUTPUTS	=> l_outputs
	,P_USE_DBI_CACHE=> FALSE);
   --
-- per_cagr_utility_pkg.put_log('Start of Run Formula ');
   for l_out_cnt in
   l_outputs.first..l_outputs.last
   loop
      if l_outputs(l_out_cnt).name='VALUE' then
         p_out_rec.value := l_outputs(l_out_cnt).value;
-- per_cagr_utility_pkg.put_log('Information : Output - Value');
      elsif
         l_outputs(l_out_cnt).name='RANGE_FROM' then
         p_out_rec.range_from := l_outputs(l_out_cnt).value;
-- per_cagr_utility_pkg.put_log('Information : Output - Range From');
      elsif
         l_outputs(l_out_cnt).name='RANGE_TO' then
         p_out_rec.range_to := l_outputs(l_out_cnt).value;
-- per_cagr_utility_pkg.put_log('Information : Output - Range To');
      elsif
         l_outputs(l_out_cnt).name='PARENT_SPINE_ID' then
         p_out_rec.parent_spine_id := l_outputs(l_out_cnt).value;
-- per_cagr_utility_pkg.put_log('Information : Output - Parent Spine ID');
      elsif
         l_outputs(l_out_cnt).name='STEP_ID' then
         p_out_rec.step_id := l_outputs(l_out_cnt).value;
-- per_cagr_utility_pkg.put_log('Information : Output - Step ID');
      elsif
         l_outputs(l_out_cnt).name='FROM_STEP_ID' then
         p_out_rec.from_step_id := l_outputs(l_out_cnt).value;
-- per_cagr_utility_pkg.put_log('Information : Output - From Step ID');
      elsif
         l_outputs(l_out_cnt).name='TO_STEP_ID' then
         p_out_rec.to_step_id := l_outputs(l_out_cnt).value;
-- per_cagr_utility_pkg.put_log('Information : Output - To Step ID');
      elsif
         l_outputs(l_out_cnt).name='GRADE_SPINE_ID' then
         p_out_rec.grade_spine_id := l_outputs(l_out_cnt).value;
-- per_cagr_utility_pkg.put_log('Information : Output - Grade Spine ID');
      end if;
-- per_cagr_utility_pkg.put_log('Information : End of Output Section');
   end loop;
   --
   --

 if p_category_name = 'PYS' then

  --   if
  --    (p_out_rec.parent_spine_id is null OR
  --     p_out_rec.step_id is null OR
  --     p_out_rec.grade_spine_id is null) THEN
  --     hr_utility.set_location('Mandatory Outputs missing for Category '||p_category_name,100);
  --     per_cagr_utility_pkg.put_log('Warning : Mandatory Outputs missing for Category '||p_category_name);
  --   end if;
   if
    (p_out_rec.value is not null OR
     p_out_rec.range_from is not null OR
     p_out_rec.range_to is not null) THEN
     hr_utility.set_location('Invalid Outputs Returned for Category '||p_category_name,200);
     per_cagr_utility_pkg.put_log('Warning : Invalid Outputs Returned for Category '||p_category_name);
   end if;
 elsif p_category_name in ('ASG','PAY','ABS') then
     --  if
     --    p_out_rec.value is null then
     --    hr_utility.set_location('Mandatory Output missing for Category '||p_category_name,300);
     --    per_cagr_utility_pkg.put_log('Warning : Mandatory Output missing for Category '||p_category_name);
     --  end if;
   if
    (p_out_rec.parent_spine_id is not null OR
     p_out_rec.step_id is not null OR
     p_out_rec.from_step_id is not null OR
     p_out_rec.to_step_id is not null or
     p_out_rec.grade_spine_id is not null) THEN
     hr_utility.set_location('Invalid Outputs Returned for Category '||p_category_name,400);
     per_cagr_utility_pkg.put_log('Warning : Invalid Outputs Returned for Category '||p_category_name);
   end if;
  else
   hr_utility.set_location('Incorrect Category Name = '||p_category_name,500);
   per_cagr_utility_pkg.put_log('Warning : Category is incorrect');
  end if;

   hr_utility.set_location('Leaving:'|| l_proc, 22);
   --
   per_cagr_utility_pkg.put_log('   Information : End of Fast Formula Evaluation.');
  EXCEPTION
    when OTHERS then
    p_out_rec := null;
    hr_utility.set_location('Formula Not Compiled',600);
--    per_cagr_utility_pkg.put_log('Error : Formula '||l_formula_name||' has not been compiled or is invalid : '||sqlerrm,1);
    per_cagr_utility_pkg.put_log('Error : Formula '||l_formula_name);
    per_cagr_utility_pkg.put_log('Error : '||sqlerrm);
--
end cagr_entitlement_ff;


end hr_cagr_ff_pkg;

/
