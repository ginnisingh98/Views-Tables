--------------------------------------------------------
--  DDL for Package Body PAY_SA_USER_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SA_USER_FUNCTION" as
/* $Header: pysarunf.pkb 120.0.12010000.2 2008/10/31 11:59:17 bkeshary ship $ */
  g_formula_name    ff_formulas_f.formula_name%TYPE;
  PROCEDURE run_formula(p_formula_id      IN NUMBER
                       ,p_effective_date  IN DATE
                       ,p_inputs          IN ff_exec.inputs_t
                       ,p_outputs         IN OUT NOCOPY ff_exec.outputs_t) IS
   l_inputs ff_exec.inputs_t;
   l_outputs ff_exec.outputs_t;
  BEGIN
   hr_utility.set_location('--In Formula ',20);
   --
   -- Initialize the formula
   --
   ff_exec.init_formula(p_formula_id, p_effective_date  , l_inputs, l_outputs);
   --
   hr_utility.trace('after ff_exec');
   -- Set up the input values
   --
   IF l_inputs.count > 0 and p_inputs.count > 0 THEN
    FOR i IN l_inputs.first..l_inputs.last LOOP
     FOR j IN p_inputs.first..p_inputs.last LOOP
      IF l_inputs(i).name = p_inputs(j).name THEN
       l_inputs(i).value := p_inputs(j).value;
       exit;
      END IF;
     END LOOP;
    END LOOP;
   END IF;
   --
   -- Run the formula
   --
   hr_utility.trace('about to exec');
   ff_exec.run_formula(l_inputs,l_outputs);
   --
   -- Populate the output table
   --
   IF l_outputs.count > 0 and p_inputs.count > 0 then
    FOR i IN l_outputs.first..l_outputs.last LOOP
     FOR j IN p_outputs.first..p_outputs.last LOOP
      IF l_outputs(i).name = p_outputs(j).name THEN
       p_outputs(j).value := l_outputs(i).value;
       exit;
      END IF;
     END LOOP;
    END LOOP;
   END IF;
  EXCEPTION
   /*WHEN hr_formula_error THEN
    fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
    fnd_message.set_token('1', g_formula_name);
    fnd_message.raise_error;*/
   WHEN OTHERS THEN
    raise;
  --
  END run_formula;

  function run_gosi_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   --,p_balance_date          IN DATE
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   --,p_jurisdiction_code     IN VARCHAR2
   --,p_tax_group             IN VARCHAR2
   --,p_source_id             IN NUMBER
   --,p_source_text           IN VARCHAR2
   )
  return NUMBER is
    cursor csr_get_formula_id  is
    select  HOI2.org_information1
    from    hr_organization_units HOU
            ,hr_organization_information HOI1
            ,hr_organization_information HOI2
            ,hr_soft_coding_keyflex HSCK
            ,per_all_assignments_f PAA
    where   HOU.business_group_id = p_business_group_id
    and    trunc(p_date_earned) between HOU.date_from and nvl(HOU.date_to,
	to_date('4712/12/31','YYYY/MM/DD'))
    and   HOU.organization_id = HOI1.organization_id
    and   HOI1.org_information_context = 'CLASS'
    and   HOI1.org_information1 = 'HR_LEGAL'
    and   HOI1.organization_id = HOI2.organization_id
    and   PAA.assignment_id = p_assignment_id
    and   trunc(p_date_earned) between PAA.effective_start_date and PAA.effective_end_date
    and   PAA.soft_coding_keyflex_id = HSCK.soft_coding_keyflex_id
    and   HSCK.id_flex_num = 20
    and   decode(HSCK.id_flex_num,20,to_number(HSCK.segment1),-9999) = HOU.organization_id
    and   HOI2.org_information_context = 'SA_GOSI_REFERENCE_FORMULA';
    l_formula_id NUMBER;
    l_inputs     ff_exec.inputs_t;
    l_outputs    ff_exec.outputs_t;
    l_value      NUMBER;
  begin
    open csr_get_formula_id;
    fetch csr_get_formula_id into l_formula_id;
    close csr_get_formula_id;
    l_inputs(1).name  := 'ASSIGNMENT_ID';
    l_inputs(1).value := p_assignment_id;
    l_inputs(2).name  := 'DATE_EARNED';
    l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
    l_inputs(3).name  := 'BUSINESS_GROUP_ID';
    l_inputs(3).value := p_business_group_id;
    l_inputs(4).name  := 'PAYROLL_ID';
    l_inputs(4).value := p_payroll_id;
    l_inputs(5).name  := 'PAYROLL_ACTION_ID';
    l_inputs(5).value := p_payroll_action_id;
    l_inputs(6).name  := 'ASSIGNMENT_ACTION_ID';
    l_inputs(6).value := p_assignment_action_id;
    l_inputs(7).name  := 'TAX_UNIT_ID';
    l_inputs(7).value := p_tax_unit_id;
    --l_inputs(8).name  := 'BALANCE_DATE';
    --l_inputs(8).value := fnd_date.date_to_canonical(p_balance_date);
    l_inputs(8).name  := 'ELEMENT_ENTRY_ID';
    l_inputs(8).value := p_element_entry_id;
    l_inputs(9).name  := 'ELEMENT_TYPE_ID';
    l_inputs(9).value := p_element_type_id;
    l_inputs(10).name  := 'ORIGINAL_ENTRY_ID';
    l_inputs(10).value := p_original_entry_id;
    --l_inputs(11).name  := 'JURISDICTION_CODE';
    --l_inputs(11).value := p_jurisdiction_code;
    --l_inputs(11).name  := 'TAX_GROUP';
    --l_inputs(11).value := p_tax_group;
    --l_inputs(12).name  := 'SOURCE_ID';
    --l_inputs(12).value := p_source_id;
    --l_inputs(12).name  := 'SOURCE_TEXT';
    --l_inputs(12).value := p_source_text;
    l_outputs(1).name := 'GOSI_REFERENCE';
    if l_formula_id is not null then
      run_formula (l_formula_id
                   ,p_date_earned
                   ,l_inputs
                   ,l_outputs);
      /* Modified for the bug 7526068 */
      l_value := NVL(fnd_number.canonical_to_number(l_outputs(l_outputs.first).value),0);
    else
      l_value := 0;
    end if;
    return(l_value);
  end run_gosi_formula;

end pay_sa_user_function;

/
