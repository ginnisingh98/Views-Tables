--------------------------------------------------------
--  DDL for Package Body PAY_FI_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_GENERAL" AS
/* $Header: pyfigenr.pkb 120.23.12010000.2 2008/08/19 14:03:04 rmurahar ship $ */
 --
g_formula_name    ff_formulas_f.formula_name%TYPE;
--
g_formula_name    ff_formulas_f.formula_name%TYPE;
--
g_package  varchar2(33) := '  PAY_FI_GENERAL.';  -- Global package name
g_legislation_code            varchar2(150)  default null;
g_absence_attendance_id       number         default null;
FUNCTION good_time_format ( p_time IN VARCHAR2 ) RETURN BOOLEAN IS
--
BEGIN
  --
  IF p_time IS NOT NULL THEN
    --
    IF NOT (SUBSTR(p_time,1,2) BETWEEN '00' AND '23' AND
            SUBSTR(p_time,4,2) BETWEEN '00' AND '59' AND
            SUBSTR(p_time,3,1) = ':' AND
            LENGTH(p_time) = 5) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
    --
  ELSE
    RETURN FALSE;
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    RETURN FALSE;
  --
END good_time_format;

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


    function run_holiday_pay_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   ,p_balance_date      IN DATE
   ,p_holiday_days      OUT NOCOPY NUMBER
   ,p_holiday_compensation      OUT NOCOPY NUMBER
   ,p_holiday_pay_reserve      OUT NOCOPY NUMBER
   ,p_working_days      OUT NOCOPY NUMBER
   ,p_working_hours      OUT NOCOPY NUMBER
   )
  return NUMBER is
  cursor csr_get_formula_id(p_effective_date in date,p_assignment_id in number,p_input_value in varchar2) is
   SELECT FF.FORMULA_ID
   FROM   per_all_assignments_f      asg1
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
		 , ff_formulas_f      ff
   WHERE  asg1.assignment_id    = p_assignment_id
     AND  p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  et.element_name       = 'Holiday Pay Information'
     AND  et.legislation_code   = 'FI'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = asg1.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg1.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  p_effective_date BETWEEN el.effective_start_date AND el.effective_end_date
     AND  p_effective_date BETWEEN et.effective_start_date AND et.effective_end_date
     AND  p_effective_date BETWEEN iv1.effective_start_date AND iv1.effective_end_date
	 AND FF.FORMULA_NAME=eev1.SCREEN_ENTRY_VALUE;


/*  SELECT PRL_INFORMATION1
  FROM PAY_PAYROLLS PP
  WHERE pp.business_group_id +0 = p_business_group_id
  and pp.payroll_id = p_payroll_id
  and trunc(p_date_earned) between pp.effective_start_date and nvl(pp.effective_end_date,p_date_earned)
  and PRL_INFORMATION_CATEGORY = 'FI';
 */
    l_formula_id NUMBER;
    l_inputs     ff_exec.inputs_t;
    l_outputs    ff_exec.outputs_t;
    l_value      NUMBER;
  begin
    open csr_get_formula_id(p_date_earned,p_assignment_id,'Accrual Formula');
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
    l_inputs(8).name  := 'ELEMENT_ENTRY_ID';
    l_inputs(8).value := p_element_entry_id;
    l_inputs(9).name  := 'ELEMENT_TYPE_ID';
    l_inputs(9).value := p_element_type_id;
    l_inputs(10).name  := 'ORIGINAL_ENTRY_ID';
    l_inputs(10).value := p_original_entry_id;
    l_inputs(11).name  := 'BALANCE_DATE';
    l_inputs(11).value := fnd_date.date_to_canonical(p_balance_date);

    l_outputs(1).name := 'HOLIDAY_DAYS';
    l_outputs(2).name := 'HOLIDAY_COMPENSATION';
    l_outputs(3).name := 'HOLIDAY_PAY_RESERVE';
    l_outputs(4).name := 'WORKING_DAYS';
    l_outputs(5).name := 'WORKING_HOURS';

--hr_utility.trace_on(null,'A');
hr_utility.trace('p_assignment_id '||p_assignment_id);
hr_utility.trace('p_date_earned '||l_inputs(2).value);
hr_utility.trace('p_balance_date '||l_inputs(11).value);
l_inputs(11).value :=l_inputs(2).value ;
hr_utility.trace('p_date_earned '||l_inputs(2).value);
hr_utility.trace('p_balance_date '||l_inputs(11).value);
--hr_utility.trace_off;

    if l_formula_id is not null then
      run_formula (l_formula_id
                   ,p_date_earned
                   ,l_inputs
                   ,l_outputs);

    end if;


   IF l_outputs.count > 0 and l_outputs.count > 0 THEN
     FOR i IN l_outputs.first..l_outputs.last LOOP
         IF l_outputs(i).name like 'HOLIDAY_DAYS' THEN
           p_holiday_days := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'HOLIDAY_COMPENSATION'  THEN
           p_holiday_compensation := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'HOLIDAY_PAY_RESERVE'  THEN
           p_holiday_pay_reserve := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WORKING_DAYS'  THEN
           p_working_days := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WORKING_HOURS'  THEN
           p_working_hours := l_outputs(i).value;
      END IF;
      END LOOP;
   END IF;
 RETURN '1';
--    return(l_value);
  end run_holiday_pay_formula;


FUNCTION get_accrual_status
 (p_time_definition_id 	IN 	NUMBER
 ,p_balance_date			IN      DATE
  ,p_payroll_start_date	IN      DATE
 ,p_payroll_end_date		IN      DATE
 ) RETURN NUMBER
AS
	CURSOR c_ptp IS
	SELECT  end_date
	FROM  per_time_periods
	WHERE time_definition_id = p_time_definition_id
	AND end_date  BETWEEN p_payroll_start_date
	AND p_payroll_end_date	;

	l_end_date		DATE ;

 BEGIN


	OPEN  c_ptp;
	FETCH  c_ptp INTO l_end_date;
	CLOSE  c_ptp ;

	IF   l_end_date IS NULL THEN

		RETURN 0 ;

	ELSE

		IF	trunc(l_end_date) = trunc(p_balance_date)	 THEN

			RETURN 1 ;

		ELSE

			RETURN 0 ;

		END IF;

	END IF;
EXCEPTION

	WHEN others THEN
	RETURN 0 ;

 END ;
function element_exist(p_assignment_id in number ,p_date_earned in date,p_element_name in varchar2 ) return number is
l_element_exist number;
cursor  check_element_exist(p_assignment_id in number ,p_effective_date in date,p_element_name in varchar2 ) is
   SELECT 1
   FROM   per_all_assignments_f      asg
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_element_entries_f      ee
   WHERE  asg.assignment_id    = p_assignment_id
     AND  et.element_name       = p_element_name
     AND  et.legislation_code   = 'FI'
     AND  el.business_group_id  = asg.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND p_effective_date BETWEEN et.effective_start_date AND et.effective_end_date
     AND p_effective_date BETWEEN el.effective_start_date AND el.effective_end_date	;


begin

l_element_exist := 0;
open check_element_exist(p_assignment_id,p_date_earned ,p_element_name  );
fetch check_element_exist into l_element_exist;
close check_element_exist;

return l_element_exist;

end  element_exist;



   function run_holiday_pay_entitlement
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   ,p_balance_date      IN DATE
   , p_summer_holiday_days			OUT NOCOPY NUMBER
 , p_winter_holiday_days	OUT NOCOPY NUMBER
 , p_holiday_pay 	OUT NOCOPY NUMBER
 , p_holiday_compensation 	        OUT NOCOPY NUMBER
 , p_carryover_holiday_days   OUT NOCOPY NUMBER
 , p_carryover_holiday_pay   OUT NOCOPY NUMBER
 , p_carryover_holiday_compen   OUT NOCOPY NUMBER

   )
  return NUMBER is
  cursor csr_get_formula_id(p_effective_date in date,p_assignment_id in number,p_input_value in varchar2) is
   SELECT FF.FORMULA_ID
   FROM   per_all_assignments_f      asg1
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
		 , ff_formulas_f      ff
   WHERE  asg1.assignment_id    = p_assignment_id
     AND  p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  et.element_name       = 'Holiday Pay Information'
     AND  et.legislation_code   = 'FI'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = asg1.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg1.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  p_effective_date BETWEEN el.effective_start_date AND el.effective_end_date
     AND  p_effective_date BETWEEN et.effective_start_date AND et.effective_end_date
     AND  p_effective_date BETWEEN iv1.effective_start_date AND iv1.effective_end_date
	 AND FF.FORMULA_NAME=eev1.SCREEN_ENTRY_VALUE;


/*  SELECT PRL_INFORMATION1
  FROM PAY_PAYROLLS PP
  WHERE pp.business_group_id +0 = p_business_group_id
  and pp.payroll_id = p_payroll_id
  and trunc(p_date_earned) between pp.effective_start_date and nvl(pp.effective_end_date,p_date_earned)
  and PRL_INFORMATION_CATEGORY = 'FI';
 */
    l_formula_id NUMBER;
    l_inputs     ff_exec.inputs_t;
    l_outputs    ff_exec.outputs_t;
    l_value      NUMBER;
  begin
    open csr_get_formula_id(p_date_earned,p_assignment_id,'Entitlement Formula');
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
    l_inputs(8).name  := 'ELEMENT_ENTRY_ID';
    l_inputs(8).value := p_element_entry_id;
    l_inputs(9).name  := 'ELEMENT_TYPE_ID';
    l_inputs(9).value := p_element_type_id;
    l_inputs(10).name  := 'ORIGINAL_ENTRY_ID';
    l_inputs(10).value := p_original_entry_id;
    l_inputs(11).name  := 'BALANCE_DATE';
    l_inputs(11).value := fnd_date.date_to_canonical(p_balance_date);

    l_outputs(1).name := 'SUMMER_HOLIDAY_DAYS';
    l_outputs(2).name := 'WINTER_HOLIDAY_DAYS';
    l_outputs(3).name := 'HOLIDAY_PAY';
    l_outputs(4).name := 'HOLIDAY_COMPENSATION';
    l_outputs(5).name := 'CARRYOVER_HOLIDAY_DAYS';
    l_outputs(6).name := 'CARRYOVER_HOLIDAY_PAY';
    l_outputs(7).name := 'CARRYOVER_HOLIDAY_COMPEN';

    if l_formula_id is not null then
      run_formula (l_formula_id
                   ,p_date_earned
                   ,l_inputs
                   ,l_outputs);

    end if;


   IF l_outputs.count > 0 and l_outputs.count > 0 THEN
     FOR i IN l_outputs.first..l_outputs.last LOOP
         IF l_outputs(i).name like 'SUMMER_HOLIDAY_DAYS' THEN
            p_summer_holiday_days:= l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WINTER_HOLIDAY_DAYS'  THEN
           p_winter_holiday_days := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'HOLIDAY_PAY'  THEN
           p_holiday_pay := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'HOLIDAY_COMPENSATION'  THEN
           p_holiday_compensation := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'CARRYOVER_HOLIDAY_DAYS'  THEN
           p_carryover_holiday_days := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'CARRYOVER_HOLIDAY_COMPEN'  THEN
           p_carryover_holiday_compen := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'CARRYOVER_HOLIDAY_PAY'  THEN
           p_carryover_holiday_pay := l_outputs(i).value;


      END IF;
      END LOOP;
   END IF;

 RETURN '1';
--    return(l_value);
  end run_holiday_pay_entitlement;
  FUNCTION get_holiday_pay_accr_override
 (p_assignment_id 		NUMBER
 , p_effective_date             DATE
 , p_holiday_days			OUT NOCOPY NUMBER
 , p_holiday_compensation	OUT NOCOPY NUMBER
 , p_holiday_pay_reserve 	OUT NOCOPY NUMBER
 , p_working_days 	        OUT NOCOPY NUMBER
 , p_working_hours 	        OUT NOCOPY NUMBER
 ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER,p_effective_date  DATE  , p_input_value VARCHAR2 ) IS
      SELECT eev1.SCREEN_ENTRY_VALUE
   FROM   per_all_assignments_f      asg1
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  et.element_name       = 'Holiday Pay Accrual Override'
     AND  et.legislation_code   = 'FI'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = asg1.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg1.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date;

  --
  --
 BEGIN
  --
  OPEN  get_details(p_assignment_id ,p_effective_date,'Holiday Days');
  FETCH get_details INTO p_holiday_days ;
  CLOSE get_details;

  OPEN  get_details(p_assignment_id ,p_effective_date,'Holiday Compensation');
  FETCH get_details INTO p_holiday_compensation ;
  CLOSE get_details;
  OPEN  get_details(p_assignment_id ,p_effective_date,'Holiday Pay Reserve');
  FETCH get_details INTO p_holiday_pay_reserve ;
  CLOSE get_details;

  OPEN  get_details(p_assignment_id ,p_effective_date,'Working Days');
  FETCH get_details INTO p_working_days ;
  CLOSE get_details;

  OPEN  get_details(p_assignment_id ,p_effective_date,'Working Hours');
  FETCH get_details INTO p_working_hours ;
  CLOSE get_details;

  IF p_holiday_days IS NULL THEN
	p_holiday_days:= -1;
  END IF;

  IF p_holiday_compensation IS NULL THEN
	p_holiday_compensation:= -1;
  END IF;

  IF p_holiday_pay_reserve IS NULL THEN
	p_holiday_pay_reserve:= -1;
  END IF;

  IF p_working_days IS NULL THEN
	p_working_days:= -1;
  END IF;

    IF p_working_hours IS NULL THEN
	p_working_hours:= -1;
  END IF;
  --
IF p_holiday_days = -1  AND
   p_holiday_compensation  = -1  AND
   p_holiday_pay_reserve  = -1  AND
   p_working_days = -1  AND
   p_working_hours = -1
  THEN RETURN -1;
  ELSE
  RETURN 1;
  END IF;

--    RETURN 1;



 EXCEPTION
	WHEN OTHERS THEN
	RETURN 0 ;
  --
 END ;

 FUNCTION get_holiday_pay_entitle_over
 (p_assignment_id 		NUMBER
 , p_effective_date             DATE
 , p_summer_holiday_days			OUT NOCOPY NUMBER
 , p_winter_holiday_days	OUT NOCOPY NUMBER
 , p_holiday_pay 	OUT NOCOPY NUMBER
 , p_holiday_compensation 	        OUT NOCOPY NUMBER
 , p_carryover_holiday_days   OUT NOCOPY NUMBER
 , p_carryover_holiday_pay   OUT NOCOPY NUMBER
 , p_carryover_holiday_compen   OUT NOCOPY NUMBER
, p_average_hourly_pay  OUT NOCOPY NUMBER
, p_average_daily_pay  OUT NOCOPY NUMBER
 ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER,p_effective_date  DATE  , p_input_value VARCHAR2 ) IS
      SELECT eev1.SCREEN_ENTRY_VALUE
   FROM   per_all_assignments_f      asg1
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  et.element_name       = 'Holiday Pay Entitlement Override'
     AND  et.legislation_code   = 'FI'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = asg1.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg1.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date;

  --
  --
 BEGIN
  --
  OPEN  get_details(p_assignment_id ,p_effective_date,'Summer Holiday Days');
  FETCH get_details INTO p_summer_holiday_days ;
  CLOSE get_details;

  OPEN  get_details(p_assignment_id ,p_effective_date,'Winter Holiday Days');
  FETCH get_details INTO p_winter_holiday_days ;
  CLOSE get_details;

  OPEN  get_details(p_assignment_id ,p_effective_date,'Holiday Pay');
  FETCH get_details INTO p_holiday_pay ;
  CLOSE get_details;

  OPEN  get_details(p_assignment_id ,p_effective_date,'Holiday Compensation');
  FETCH get_details INTO p_holiday_compensation ;
  CLOSE get_details;

  OPEN  get_details(p_assignment_id ,p_effective_date,'Holiday Days Carryover');
  FETCH get_details INTO p_carryover_holiday_days ;
  CLOSE get_details;


  OPEN  get_details(p_assignment_id ,p_effective_date,'Holiday Pay Carryover');
  FETCH get_details INTO p_carryover_holiday_pay ;
  CLOSE get_details;

   OPEN  get_details(p_assignment_id ,p_effective_date,'Holiday Compensation Carryover');
  FETCH get_details INTO p_carryover_holiday_compen ;
  CLOSE get_details;

  OPEN  get_details(p_assignment_id ,p_effective_date,'Average Hourly Pay');
  FETCH get_details INTO p_average_hourly_pay ;
  CLOSE get_details;

   OPEN  get_details(p_assignment_id ,p_effective_date,'Average Daily Pay');
  FETCH get_details INTO p_average_daily_pay ;
  CLOSE get_details;


/*  IF p_summer IS NULL THEN
	p_holiday_days:= -1;
  END IF;

  IF p_holiday_compensation IS NULL THEN
	p_holiday_compensation:= -1;
  END IF;

  IF p_holiday_pay_reserve IS NULL THEN
	p_holiday_pay_reserve:= -1;
  END IF;

  IF p_working_days IS NULL THEN
	p_working_days:= -1;
  END IF;

    IF p_working_hours IS NULL THEN
	p_working_hours:= -1;
  END IF;
  --
IF p_holiday_days = -1  AND
   p_holiday_compensation  = -1  AND
   p_holiday_pay_reserve  = -1  AND
   p_working_days = -1  AND
   p_working_hours = -1
  THEN RETURN -1;
  ELSE
  RETURN 1;
  END IF;
*/
    RETURN 1;



 EXCEPTION
	WHEN OTHERS THEN
	RETURN 0 ;
  --
 END ;


FUNCTION get_local_unit
 (p_assignment_id 		NUMBER
 , p_effective_date             DATE )
 RETURN VARCHAR2 AS
	l_local_unit  hr_soft_coding_keyflex.segment2%TYPE;

	CURSOR c_local_unit(p_assignment_id NUMBER ,  p_effective_date DATE) IS
	SELECT sck.segment2
	FROM   per_all_assignments_f         asg1
		, hr_soft_coding_keyflex sck
	WHERE  asg1.assignment_id    = p_assignment_id
	AND  asg1.soft_coding_keyflex_id=sck.soft_coding_keyflex_id
	AND  p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date;
 BEGIN
	 OPEN  c_local_unit(p_assignment_id ,  p_effective_date) ;
	 FETCH c_local_unit INTO l_local_unit ;
	 CLOSE c_local_unit;

	 RETURN l_local_unit;
 EXCEPTION
	WHEN OTHERS THEN
		       fnd_file.put_line(fnd_file.log,'Error message : '||SQLERRM);
	RETURN NULL ;
 END ;

FUNCTION get_tax_card_details
 (p_assignment_id             NUMBER
 , p_effective_date           DATE
 ,P_julian_effective_date OUT NOCOPY NUMBER
 ,P_tax_card_type         OUT NOCOPY VARCHAR2
 ,P_base_rate             OUT NOCOPY NUMBER
 ,P_additional_rate       OUT NOCOPY NUMBER
 ,P_yearly_income_limit   OUT NOCOPY NUMBER
 ,P_previous_income       OUT NOCOPY NUMBER
 ,p_lower_income_Percentage OUT NOCOPY NUMBER ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE , p_input_value VARCHAR2 ) IS
   SELECT TO_NUMBER(TO_CHAR(ee.effective_start_date, 'J')) julian_effective_date
         ,eev1.screen_entry_value  screen_entry_value
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  asg2.primary_flag     = 'Y'
     AND  et.element_name       = 'Tax Card'
     AND  et.legislation_code   = 'FI'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date;
  --
  l_rec get_details%ROWTYPE;
  --
 BEGIN
  --


  OPEN  get_details(p_assignment_id , p_effective_date ,'Base Rate' );
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_base_rate             := l_rec.screen_entry_value ;

  /* Added for lower income limit */

  OPEN  get_details(p_assignment_id , p_effective_date ,'Lower Income Percentage' );
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_lower_income_Percentage             := l_rec.screen_entry_value ;

  OPEN  get_details(p_assignment_id , p_effective_date ,'Additional Rate' );
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_additional_rate       := l_rec.screen_entry_value ;

  OPEN  get_details(p_assignment_id , p_effective_date ,'Yearly Income Limit' );
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_yearly_income_limit   := l_rec.screen_entry_value ;

  OPEN  get_details(p_assignment_id , p_effective_date ,'Previous Income');
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_previous_income       := l_rec.screen_entry_value ;

 OPEN  get_details(p_assignment_id , p_effective_date ,'Tax Card Type' );
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_julian_effective_date := l_rec.julian_effective_date;
  p_tax_card_type         := l_rec.screen_entry_value ;

    --
  RETURN 1;
  --
 END get_tax_card_details;
 --
 FUNCTION get_tax_days_override
 (p_assignment_id 		NUMBER
 , p_effective_date             DATE
 ,p_tax_days			OUT NOCOPY NUMBER
 ,p_ref_tax_days		OUT NOCOPY NUMBER

) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER,p_effective_date  DATE  , p_input_value VARCHAR2 ) IS
   SELECT eev1.screen_entry_value tax_days
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
    AND p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  asg2.primary_flag     = 'Y'
     AND  et.element_name       = 'Tax Days Override'
     AND  et.legislation_code   = 'FI'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date;
  --
  --
 BEGIN
  --
  OPEN  get_details(p_assignment_id ,p_effective_date,'Tax Days');
  FETCH get_details INTO p_tax_days ;
  CLOSE get_details;

  OPEN  get_details(p_assignment_id ,p_effective_date,'Reference Tax Days');
  FETCH get_details INTO p_ref_tax_days ;
  CLOSE get_details;
  IF p_tax_days IS NULL THEN
	p_tax_days:= -1;
  END IF;

  IF p_ref_tax_days IS NULL THEN
	p_ref_tax_days:= -1;
  END IF;

  --
  RETURN 1 ;

 EXCEPTION
	WHEN OTHERS THEN
	RETURN 0 ;
  --
 END get_tax_days_override;
 --

  function run_tax_days_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   )
  return NUMBER is
  cursor csr_get_formula_id  is
  SELECT PRL_INFORMATION1
  FROM PAY_PAYROLLS PP
  WHERE pp.business_group_id +0 = p_business_group_id
  and pp.payroll_id = p_payroll_id
  and trunc(p_date_earned) between pp.effective_start_date and nvl(pp.effective_end_date,p_date_earned)
  and PRL_INFORMATION_CATEGORY = 'FI';
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
    l_inputs(8).name  := 'ELEMENT_ENTRY_ID';
    l_inputs(8).value := p_element_entry_id;
    l_inputs(9).name  := 'ELEMENT_TYPE_ID';
    l_inputs(9).value := p_element_type_id;
    l_inputs(10).name  := 'ORIGINAL_ENTRY_ID';
    l_inputs(10).value := p_original_entry_id;
    l_outputs(1).name := 'TAX_DAYS';
    if l_formula_id is not null then
      run_formula (l_formula_id
                   ,p_date_earned
                   ,l_inputs
                   ,l_outputs);
      l_value := NVL(l_outputs(l_outputs.first).value,0);
    else
      l_value := 0;
    end if;
    return(l_value);
  end run_tax_days_formula;
--

 FUNCTION get_tax_details
 (p_assignment_id             IN NUMBER
 , p_effective_date           IN DATE

  ) RETURN NUMBER IS
  --
   l_julian_effective_date  NUMBER;

  CURSOR get_tax_details(p_assignment_id NUMBER ,  p_effective_date DATE) IS
   SELECT TO_NUMBER(TO_CHAR(ee.effective_start_date, 'J')) julian_effective_date
   FROM   per_all_assignments_f      asg1
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_element_entries_f      ee
   WHERE  asg1.assignment_id    = p_assignment_id
     AND  per.person_id         = asg1.person_id
     AND  p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
     AND  et.element_name       = 'Tax'
     AND  et.legislation_code   = 'FI'
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg1.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date;
  --
  l_rec get_tax_details%ROWTYPE;
  --
 BEGIN
  --
  OPEN  get_tax_details(p_assignment_id ,p_effective_date );
  FETCH get_tax_details INTO l_rec;
  CLOSE get_tax_details;
  --
 l_julian_effective_date := l_rec.julian_effective_date;
  --
  RETURN l_julian_effective_date;
EXCEPTION
	WHEN OTHERS THEN
	RETURN NULL;
  --
 END get_tax_details;
 --

  FUNCTION get_tax_calendar_days
 ( p_business_group_id		IN NUMBER
  , p_tax_unit_id		IN NUMBER
 ) RETURN NUMBER
 IS


	l_tax_calendar_days hr_organization_information.org_information10%TYPE;

	CURSOR c_tax_calendar_days( p_business_group_id	NUMBER , p_tax_unit_id NUMBER) IS
	SELECT NVL(hoi2.org_information10,'364')   org_information10
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  p_tax_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_LEGAL_EMPLOYER_DETAILS';

 BEGIN

	 OPEN c_tax_calendar_days( p_business_group_id	, p_tax_unit_id ) ;
	 FETCH c_tax_calendar_days INTO l_tax_calendar_days ;
	 CLOSE c_tax_calendar_days;

	IF l_tax_calendar_days IS NULL THEN
		l_tax_calendar_days :='364';
        END IF;

	 RETURN l_tax_calendar_days ;

 EXCEPTION
	WHEN OTHERS THEN
	RETURN NULL;
 END ;


FUNCTION get_social_security_info
 ( p_business_group_id		IN NUMBER
  ,p_tax_unit_id		IN NUMBER
  ,p_social_security_category	OUT NOCOPY NUMBER
  ,p_social_security_exempt     OUT NOCOPY VARCHAR2
 ) RETURN NUMBER
 IS

	CURSOR c_social_security_info( p_business_group_id	NUMBER , p_tax_unit_id NUMBER) IS
	SELECT NVL(hoi2.org_information3,0 )   org_information3 ,
	NVL(hoi2.org_information12,'N') org_information11
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  p_tax_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_LEGAL_EMPLOYER_DETAILS';

 BEGIN

	 OPEN  c_social_security_info( p_business_group_id , p_tax_unit_id ) ;
	 FETCH  c_social_security_info INTO p_social_security_category , p_social_security_exempt  ;
	 CLOSE  c_social_security_info;

	IF  p_social_security_category IS NULL THEN
		p_social_security_category := 0 ;
        END IF;

	IF  p_social_security_exempt  IS NULL THEN
		 p_social_security_exempt  :='N';
        END IF;


	 RETURN 1 ;

 EXCEPTION
	WHEN OTHERS THEN
	RETURN 0 ;
 END ;


FUNCTION get_accident_insurance_info
 ( p_business_group_id		IN NUMBER
  ,p_tax_unit_id		IN NUMBER
  , p_effective_date           DATE
 ) RETURN NUMBER
 IS

	l_accident_insurance_id hr_organization_information.org_information3%TYPE;

	CURSOR c_accident_insurance_info( p_business_group_id	NUMBER , p_tax_unit_id NUMBER , p_effective_date DATE ) IS
	SELECT hoi2.org_information3
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  p_tax_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_ACCIDENT_PROVIDERS'
	AND p_effective_date between  fnd_date.canonical_to_date(hoi2.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi2.org_information2),to_date('31/12/4712','DD/MM/YYYY'))   ;


 BEGIN

	 OPEN  c_accident_insurance_info( p_business_group_id , p_tax_unit_id , p_effective_date ) ;
	 FETCH  c_accident_insurance_info INTO l_accident_insurance_id ;
	 CLOSE  c_accident_insurance_info;

	IF  l_accident_insurance_id IS NULL THEN
		l_accident_insurance_id := -999 ;

        END IF;

	 RETURN l_accident_insurance_id ;

 EXCEPTION
	WHEN OTHERS THEN
	RETURN -999 ;
 END ;


  FUNCTION get_accident_insurance_rate
 ( p_business_group_id		IN NUMBER
  ,p_tax_unit_id		IN NUMBER
  ,p_effective_date		IN DATE
  ,p_assignment_id		IN NUMBER
  ,p_rate_type			IN VARCHAR2
  ,p_accident_insurance_id	OUT NOCOPY NUMBER
  ,p_rate			OUT NOCOPY NUMBER
 ) RETURN NUMBER
 IS

	l_accident_insurance_id hr_organization_information.org_information3%TYPE;
	l_lc_accident_insurance_pct hr_organization_information.org_information4%TYPE;
	l_accident_insurance_pct hr_organization_information.org_information3%TYPE;
	l_group_insurance_pct hr_organization_information.org_information3%TYPE;
	l_local_unit  hr_soft_coding_keyflex.segment2%TYPE;

	CURSOR c_accident_insurance_info( p_business_group_id	NUMBER , p_tax_unit_id NUMBER , p_effective_date DATE ) IS
	SELECT hoi2.org_information3   org_information3 ,
	NVL(hoi2.org_information5,0 )   org_information5 ,
	NVL(hoi2.org_information6,0 )   org_information6
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  p_tax_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_ACCIDENT_PROVIDERS'
	AND p_effective_date between  fnd_date.canonical_to_date(hoi2.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi2.org_information2),to_date('31/12/4712','DD/MM/YYYY'))   ;


	CURSOR c_lc_accident_insurance_info( p_business_group_id NUMBER , p_local_unit_id NUMBER ,  p_effective_date DATE ) IS
	SELECT hoi2.org_information4   org_information4
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  p_local_unit_id
	AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_LU_ACCIDENT_PROVIDERS'
	AND p_effective_date between  fnd_date.canonical_to_date(hoi2.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi2.org_information2),to_date('31/12/4712','DD/MM/YYYY'))   ;

 BEGIN
	  l_local_unit := get_local_unit( p_assignment_id  ,  p_effective_date) ;

         OPEN  c_lc_accident_insurance_info( p_business_group_id , l_local_unit , p_effective_date );
	 FETCH  c_lc_accident_insurance_info INTO l_lc_accident_insurance_pct ;
	 CLOSE  c_lc_accident_insurance_info;


	 OPEN  c_accident_insurance_info( p_business_group_id , p_tax_unit_id , p_effective_date );
	 FETCH  c_accident_insurance_info INTO p_accident_insurance_id , l_accident_insurance_pct ,
	 l_group_insurance_pct ;
	 CLOSE  c_accident_insurance_info;


	IF  p_accident_insurance_id IS NULL THEN
		p_accident_insurance_id := -999 ;

        END IF;

	IF  l_lc_accident_insurance_pct IS NULL THEN
		IF  l_accident_insurance_pct IS NULL THEN
			l_accident_insurance_pct := 0 ;

		END IF;
	ELSE
		l_accident_insurance_pct := l_lc_accident_insurance_pct ;

	END IF;
	IF  l_group_insurance_pct IS NULL THEN
		l_group_insurance_pct := 0 ;

        END IF;

	IF p_rate_type ='AI' THEN
		p_rate	:= l_accident_insurance_pct;
	ELSE
		p_rate	:= l_group_insurance_pct ;
	END IF;


	 RETURN 1 ;

 EXCEPTION
	WHEN OTHERS THEN
	RETURN 0 ;
 END ;

FUNCTION get_person_pension_info
 ( p_business_group_id		IN NUMBER
  ,p_tax_unit_id		IN NUMBER
  ,p_assignment_id		IN NUMBER
  ,p_effective_date		IN DATE
  ,p_pension_type		OUT NOCOPY VARCHAR2
  ,p_pension_group		OUT NOCOPY NUMBER
  ,p_pension_provider		OUT NOCOPY NUMBER
  ,p_pension_rate		OUT NOCOPY NUMBER
 ) RETURN NUMBER
 IS

        l_pension_group_id hr_organization_information.org_information_id%TYPE;
	l_pension_num hr_organization_information.org_information1%TYPE;
	l_local_unit  hr_soft_coding_keyflex.segment2%TYPE;
	l_pension_rate hr_organization_information.org_information1%TYPE;

	CURSOR c_person_pension_num(p_assignment_id NUMBER ,  p_effective_date DATE) IS
	SELECT PER_INFORMATION15, PER_INFORMATION16, PER_INFORMATION24
	FROM   per_all_assignments_f         asg1
		 ,per_all_people_f           per
	WHERE  asg1.assignment_id    = p_assignment_id
	AND  per.person_id         = asg1.person_id
	AND  p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
	AND  p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
       AND   p_effective_date BETWEEN  nvl(fnd_date.canonical_to_date(per.per_information14),to_date('01/01/0001','DD/MM/YYYY'))
       AND  nvl(fnd_date.canonical_to_date(per.per_information20),to_date('31/12/4712','DD/MM/YYYY'));

	CURSOR c_pension_provider_info( p_business_group_id	NUMBER , p_tax_unit_id NUMBER , p_pension_num VARCHAR2  , p_effective_date DATE) IS
	SELECT   NVL(hoi2.org_information4,0 )   org_information4  , NVL(hoi2.org_information7,0 )   org_information7
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  p_tax_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_PENSION_PROVIDERS'
	AND hoi2.org_information6 = p_pension_num
	AND p_effective_date between  fnd_date.canonical_to_date(hoi2.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi2.org_information2),to_date('31/12/4712','DD/MM/YYYY'))
	AND hoi2.org_information6 IN
	(
	SELECT NVL(hoi2.org_information1,0 )
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id = p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id = l_local_unit
	AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.org_information1 = p_pension_num
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_LU_PENSION_PROVIDERS' );

BEGIN

	OPEN  c_person_pension_num( p_assignment_id  ,  p_effective_date ) ;
	FETCH  c_person_pension_num INTO p_pension_type, p_pension_group, l_pension_num ;
	CLOSE  c_person_pension_num;

	  l_local_unit := get_local_unit( p_assignment_id  ,  p_effective_date) ;

	IF   l_pension_num IS NOT NULL THEN
		 OPEN  c_pension_provider_info(  p_business_group_id	, p_tax_unit_id , l_pension_num ,  p_effective_date ) ;
		 FETCH  c_pension_provider_info INTO  p_pension_provider , l_pension_rate ;
		 CLOSE  c_pension_provider_info;

		p_pension_rate:= fnd_number.canonical_to_number(l_pension_rate);

	END IF;

 		  IF  p_pension_provider  IS NULL THEN
			 p_pension_provider  := -999 ;

	         END IF;

		  IF  p_pension_type IS NULL THEN
			p_pension_type := ' ';
		 END IF;

		  IF  p_pension_group IS NULL THEN
			p_pension_group := -99;
		 END IF;


		IF  p_pension_rate IS NULL THEN
			p_pension_rate := 0 ;

		END IF;


	RETURN 1 ;

 EXCEPTION
	WHEN OTHERS THEN
	       fnd_file.put_line(fnd_file.log,'Error message : '||SQLERRM);
	RETURN 0 ;
 END ;

FUNCTION get_retirement_date
 (p_assignment_id 		NUMBER
 , p_effective_date             DATE )
 RETURN DATE AS
 l_return_value	DATE ;
 l_retire_date	VARCHAR2(150) ;

 CURSOR c_retire_date IS
 SELECT PER_INFORMATION8
 FROM   per_all_assignments_f      asg1
       ,per_all_people_f           per
 WHERE  asg1.assignment_id    = p_assignment_id
 AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
 AND  p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
 AND  per.person_id         = asg1.person_id;

 BEGIN
	 OPEN  c_retire_date ;
	 FETCH c_retire_date INTO l_retire_date;
	 CLOSE c_retire_date;
	 IF   l_retire_date IS NULL THEN
		l_return_value :=fnd_date.canonical_to_date('4712/12/31 00:00:00');
	 ELSE
		l_return_value :=fnd_date.canonical_to_date(l_retire_date);
	 END IF;
	 RETURN l_return_value;
 EXCEPTION
	WHEN OTHERS THEN
	l_return_value :=fnd_date.canonical_to_date('4712/12/31 00:00:00');
	RETURN l_return_value;

 END ;


FUNCTION xml_parser
( P_DATA	VARCHAR2)
RETURN VARCHAR2 AS
l_data VARCHAR2(4000);
BEGIN
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        return l_data;
EXCEPTION
	WHEN OTHERS THEN
	l_data :=NULL ;
	RETURN l_data;
END xml_parser;



 PROCEDURE INS_OR_UPD_PERSON_EIT_COLUMN
 ( p_person_id 		IN NUMBER
  ,p_new_value  in VARCHAR2
  ,p_Session_Date in VARCHAR2
  ,p_COLUMN_NAME  in  per_people_extra_info.PEI_INFORMATION3%TYPE
  ,p_dt_update_mode in varchar2
 )
 IS
        CURSOR CSR_PERSON_EIT
        IS
        select PERSON_EXTRA_INFO_ID,
                object_version_number,
                person_id,
                information_type,
                pei_information_category,
                pei_information1,
                pei_information2,
                pei_information3,
                pei_information4,
                pei_information5,
                pei_information6,
                pei_information7
         from per_people_extra_info
        where information_type='FI_PENSION'
        AND PEI_INFORMATION_CATEGORY='FI_PENSION'
        AND PEI_INFORMATION3=p_COLUMN_NAME
        AND PERSON_ID = P_PERSON_ID;

        LR_PERSON_EIT CSR_PERSON_EIT%ROWTYPE;
        L_OVN per_people_extra_info.object_version_number%TYPE;
        L_person_extra_info_id number;
        l_Action VARCHAR2(3);

BEGIN

        --hr_utility.trace('In Column Update or insert  ');
        --hr_utility.trace(' p_Session_Date ==>' || p_Session_Date);
        --hr_utility.trace('p_new_value ==> ' ||p_new_value );

			OPEN  csr_PERSON_EIT;
			        FETCH csr_PERSON_EIT
                    INTO lr_PERSON_EIT;
				IF csr_PERSON_EIT%NOTFOUND
				THEN
                    --hr_utility.trace('In Not Found So Creation is gonna happen');

						hr_person_extra_info_api.create_person_extra_info
						  (p_person_id                     => p_PERSON_ID
						  ,p_information_type              =>'FI_PENSION'
						  ,p_pei_information_category      =>'FI_PENSION'
						  ,p_pei_information1              =>'Y'
						  ,p_pei_information3              =>p_COLUMN_NAME
						  ,p_pei_information4              => p_new_value
						  ,p_pei_information5              =>'N'
						  ,p_pei_information6              =>'I'
						  ,p_pei_information7              =>FND_DATE.DATE_TO_CANONICAL(p_Session_Date)
						  ,p_person_extra_info_id          =>L_person_extra_info_id
						  ,p_object_version_number         =>L_OVN
						  ) ;
                        hr_utility.trace('p_person_extra_info_id Created ==> ' ||L_person_extra_info_id );


				ELSE

                 hr_utility.trace('Found record so Updation gonna Happen  '||p_new_value);

        			L_OVN := lr_PERSON_EIT.object_version_number;
        			IF p_dt_update_mode ='UPDATE' or p_dt_update_mode='UPDATE_CHANGE'
        			THEN
        			     l_Action :='U';
                    ELSE
        			     l_Action :='I';
        			END IF;

        			IF p_dt_update_mode ='INSERT_CHANGE' or p_dt_update_mode='UPDATE_CHANGE'
        			THEN
        				-- as the changes update mode
        				-- is called, we need to pass the new value,
        				-- and the action as insert, and reported as No
        				-- along with the session date
                        	hr_person_extra_info_api.update_person_extra_info
                         	(
                         	p_person_extra_info_id       => lr_PERSON_EIT.person_extra_info_id,
                         	p_object_version_number      => L_OVN,
                        	-- p_pei_information_category  => lr_PERSON_EIT.pei_information_category,
                        	-- p_pei_information1         => lr_PERSON_EIT.pei_information1,
                         	p_pei_information2           => null,
                        	-- p_pei_information3         => lr_PERSON_EIT.pei_information3,
                        	p_pei_information4         => p_new_value,
                         	p_pei_information5           => 'N',
                         	p_pei_information6           => l_Action,
 				 			p_pei_information7           =>FND_DATE.DATE_TO_CANONICAL(p_Session_Date)
 				 			);

                    ELSE

        			    IF lr_PERSON_EIT.pei_information5 ='Y'
                    	THEN
                        	hr_person_extra_info_api.update_person_extra_info
                         	(
                         	p_person_extra_info_id       => lr_PERSON_EIT.person_extra_info_id,
                         	p_object_version_number      => L_OVN,
                        	-- p_pei_information_category  => lr_PERSON_EIT.pei_information_category,
                        	-- p_pei_information1         => lr_PERSON_EIT.pei_information1,
                         	p_pei_information2           => null,
                        	-- p_pei_information3         => lr_PERSON_EIT.pei_information3,
                        	-- p_pei_information4         => p_new_value,
                         	p_pei_information5           => 'N',
                         	p_pei_information6           => l_Action,
 				 			p_pei_information7           =>FND_DATE.DATE_TO_CANONICAL(p_Session_Date)
                          	);
                    	ELSE
                        	hr_person_extra_info_api.update_person_extra_info
                         	(
                         	p_person_extra_info_id         => lr_PERSON_EIT.person_extra_info_id,
                         	p_object_version_number        => L_OVN,
                        	--p_pei_information_category    => lr_PERSON_EIT.pei_information_category,
                        	--p_pei_information1            => lr_PERSON_EIT.pei_information1,
	                        --p_pei_information2            => lr_PERSON_EIT.pei_information2,
    	                    --p_pei_information3            => lr_PERSON_EIT.pei_information3,
        	                --p_pei_information4            => p_new_value,
            	             p_pei_information5             => 'N',
                	         p_pei_information6             => l_Action
                    	      );
                    	END IF;
    					--hr_utility.trace('Updated Record ==> ' ||lr_PERSON_EIT.person_extra_info_id);
        			END IF; -- END if of INSERT_CHANGE
        		END IF;
        CLOSE csr_PERSON_EIT ;
END INS_OR_UPD_PERSON_EIT_COLUMN;

PROCEDURE INSERT_OR_UPDATE_PERSON_EIT
 (p_person_id 		IN NUMBER,
  p_new_PENSION_JOINING_DATE   IN VARCHAR2,
  p_old_PENSION_JOINING_DATE  in  VARCHAR2,
  p_new_PENSION_TYPES   IN VARCHAR2,
  p_old_PENSION_TYPES  in  VARCHAR2,
  p_new_PENSION_INS_NUM   IN VARCHAR2,
  p_old_PENSION_INS_NUM  in  VARCHAR2,
  p_new_PENSION_GROUP   IN VARCHAR2,
  p_old_PENSION_GROUP  in  VARCHAR2,
  p_new_LOCAL_UNIT   IN VARCHAR2,
  p_old_LOCAL_UNIT  in  VARCHAR2,
  p_Session_Date in VARCHAR2,
  p_dt_update_mode in varchar2,
  p_where IN VARCHAR2 default NULL
 )
 is
 BEGIN

 -- if any of the 14,15,16 ,24 has been changed then call the API to insert or update acc

	-- PER_INFORMATION14         Pension Joining Date         PERSON.LOC_DATE04
	-- PER_INFORMATION15         Pension Types                PERSON.LOC_ITEM18
	-- PER_INFORMATION16         Pension Group                PERSON.LOC_INFORMATION_C01
	-- PER_INFORMATION24         Pension Insurance Number PERSON.LOC_INFORMATION_C06
	-- PER_INFORMATION17         Planned Retirement age       PERSON.LOC_NUM03

        --hr_utility.trace_on(NULL,'TELL');
        --hr_utility.trace(' In p_new_PENSION_JOINING_DATE => ' || p_new_PENSION_JOINING_DATE);
        --hr_utility.trace(' In p_old_PENSION_JOINING_DATE => ' || p_old_PENSION_JOINING_DATE);
        --hr_utility.trace(' In p_new_PENSION_TYPES => ' || p_new_PENSION_TYPES);
        --hr_utility.trace(' In p_old_PENSION_TYPES => ' || p_old_PENSION_TYPES);
	--hr_utility.trace(' In p_new_PENSION_INS_NUM => ' || p_new_PENSION_INS_NUM);
        --hr_utility.trace(' In p_old_PENSION_INS_NUM => ' || p_old_PENSION_INS_NUM);
        --hr_utility.trace(' In p_new_PENSION_GROUP => ' || p_new_PENSION_GROUP);
        --hr_utility.trace(' In p_old_PENSION_GROUP => ' || p_old_PENSION_GROUP);
        --hr_utility.trace(' In p_new_PENSION_RETIRE_DATE => ' || p_new_PENSION_RETIRE_DATE);
        --hr_utility.trace(' In p_old_PENSION_RETIRE_DATE => ' || p_old_PENSION_RETIRE_DATE);
        --hr_utility.trace(' In p_new_LOCAL_UNIT => ' || p_new_LOCAL_UNIT);
        --hr_utility.trace(' In p_old_LOCAL_UNIT => ' || p_old_LOCAL_UNIT);

  		IF p_where ='ASSIGN' or p_where ='MAINTAIN'
 		THEN

            IF (p_new_LOCAL_UNIT IS NOT null or p_old_LOCAL_UNIT IS NOT NULL )
            THEN
                IF ( trim(p_new_LOCAL_UNIT) = trim(p_old_LOCAL_UNIT) )
                THEN
                    hr_utility.trace('In Equals for  Local Unit');
                ELSE
                    hr_utility.trace('In Not Equals for  Local Unit');
                    INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_LOCAL_UNIT,p_Session_Date,'Local Unit',p_dt_update_mode);
                END IF;
            END IF;
         END IF;
        IF p_where ='PERSON' or p_where ='MAINTAIN'
 		THEN
			IF (p_new_PENSION_JOINING_DATE IS null AND p_old_PENSION_JOINING_DATE IS null )
			THEN
			    INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_JOINING_DATE,p_Session_Date,'Pension Joining Date','INSERT');
            ELSIF (p_new_PENSION_JOINING_DATE IS NOT null or p_old_PENSION_JOINING_DATE IS NOT null )
            THEN
                    IF(FND_DATE.CANONICAL_to_date(p_new_PENSION_JOINING_DATE)=
                        FND_DATE.CANONICAL_to_date(p_old_PENSION_JOINING_DATE))
                    THEN
                        hr_utility.trace('In Equals for Pension Date');
                    ELSE
                        hr_utility.trace('Calling the Column update ');
                        INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_JOINING_DATE,p_Session_Date,'Pension Joining Date',p_dt_update_mode);
                    END IF;
            END IF;
/*
        IF (p_new_PENSION_RETIRE_DATE IS NOT null OR p_old_PENSION_RETIRE_DATE IS NOT null )
            THEN
                IF ( to_number(p_new_PENSION_RETIRE_DATE) = to_number(p_old_PENSION_RETIRE_DATE) )
                THEN
                    hr_utility.trace('In Equals for AGE');
                ELSE
                        hr_utility.trace('In Not Equals for AGE');
                    INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_RETIRE_DATE,p_Session_Date,'Pension Retirement Age');
                END IF;
            END IF;
*/

            IF (p_new_PENSION_GROUP IS null AND p_old_PENSION_GROUP IS null )
            THEN
                INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_GROUP,p_Session_Date,'Pension Group','INSERT');
            ELSIF (p_new_PENSION_GROUP IS NOT null OR p_old_PENSION_GROUP IS NOT null )
            THEN
            hr_utility.trace('IF NOT NULL for Pension Group' || p_new_PENSION_GROUP ||' '||p_old_PENSION_GROUP);
                IF ( trim(p_new_PENSION_GROUP) = trim(p_old_PENSION_GROUP) )
                THEN
                    hr_utility.trace('In Equals for Pension group');
                ELSE
                        hr_utility.trace('value ' ||p_new_PENSION_GROUP );
                    INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_GROUP,p_Session_Date,'Pension Group',p_dt_update_mode);
                END IF;
            END IF;

	       IF (p_new_PENSION_INS_NUM IS null AND p_old_PENSION_INS_NUM IS null )
            THEN
                INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_INS_NUM,p_Session_Date,'Insurance Number','INSERT');
            ELSIF (p_new_PENSION_INS_NUM IS NOT null OR p_old_PENSION_INS_NUM IS NOT null )
            THEN
            hr_utility.trace('IF NOT NULL for Pension Insurance Number' || p_new_PENSION_INS_NUM ||' '||p_old_PENSION_INS_NUM);
                IF ( trim(p_new_PENSION_INS_NUM) = trim(p_old_PENSION_INS_NUM) )
                THEN
                    hr_utility.trace('In Equals for Pension Insurance Number');
                ELSE
                        hr_utility.trace('value ' ||p_new_PENSION_INS_NUM );
                    INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_INS_NUM,p_Session_Date,'Insurance Number',p_dt_update_mode);
                END IF;
            END IF;

            IF (p_new_PENSION_TYPES IS null AND p_old_PENSION_TYPES IS null )
            THEN
               	INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_TYPES,p_Session_Date,'Pension Types','INSERT');
            ELSIF (p_new_PENSION_TYPES IS NOT null OR p_old_PENSION_TYPES IS NOT null )
            THEN
                IF ( trim(p_new_PENSION_TYPES) = trim(p_old_PENSION_TYPES) )
                THEN
                    hr_utility.trace('In Equals for Pension Types');
                ELSE
                        hr_utility.trace('Value ' ||p_new_PENSION_TYPES );
                    INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_TYPES,p_Session_Date,'Pension Types',p_dt_update_mode);
                    -- Pension type has been changed, so insert the joinig date and group.
                    -- so that pension joindate record displayed in report
                    INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_JOINING_DATE,p_Session_Date,'Pension Joining Date','INSERT_CHANGE');
                    IF ( trim(p_old_PENSION_TYPES) ='TYEL' )
                    THEN
                    	-- if the Old was TYEL then change the joining date value and insert and Not reported
                    	-- then dont change the group value but, make insert and Not reported
						INS_OR_UPD_PERSON_EIT_COLUMN(p_person_id,p_new_PENSION_GROUP,p_Session_Date,'Pension Group','INSERT');
                    	-- then dont change the Type value but, make update and Not reported

                    END IF;


                END IF;
            END IF;


           END IF;

 END INSERT_OR_UPDATE_PERSON_EIT;
  FUNCTION calc_sch_based_dur (  p_assignment_id IN NUMBER,
  			                    p_days_or_hours IN VARCHAR2,
--          			           p_include_event IN VARCHAR2 DEFAULT 'Y',
                               p_date_start    IN DATE,
                               p_date_end      IN DATE,
                               p_time_start    IN VARCHAR2,
                               p_time_end      IN VARCHAR2,
                               p_duration      IN OUT NOCOPY NUMBER
                             ) RETURN NUMBER IS
  --
  l_return	    NUMBER;
  l_idx             NUMBER;
  l_ref_date        DATE;
  l_first_band      BOOLEAN;
  l_day_start_time  VARCHAR2(5);
  l_day_end_time    VARCHAR2(5);
  l_start_time      VARCHAR2(5);
  l_end_time        VARCHAR2(5);
  --
  l_start_date      DATE;
  l_end_date        DATE;
  l_schedule        cac_avlblty_time_varray;
  l_schedule_source VARCHAR2(10);
  l_return_status   VARCHAR2(1);
  l_return_message  VARCHAR2(2000);
  --
  l_time_start      VARCHAR2(10); --5 to 10
  l_time_end        VARCHAR2(10); --5 to 10
  --
  e_bad_time_format EXCEPTION;
  CURSOR get_time_format(l_time varchar2) is
  SELECT replace(trim(to_char(to_number(l_time),'00.00')),'.',':') FROM dual;
  --
BEGIN
  hr_utility.set_location('Entering '||'.calc_sch_based_dur',10);
  l_return := 0;
  p_duration := 0;
  l_time_start := p_time_start;
  l_time_end := p_time_end;
  /*knelli */
  OPEN get_time_format(l_time_start);
  FETCH get_time_format INTO l_time_start;
  CLOSE get_time_format;
  OPEN get_time_format(l_time_end);
  FETCH get_time_format INTO l_time_end;
  CLOSE get_time_format;
  /* knelli */
  --
  IF l_time_start IS NULL THEN
    l_time_start := '00:00';
  ELSE
    IF NOT good_time_format(l_time_start) THEN
      RAISE e_bad_time_format;
    END IF;
  END IF;
  IF l_time_end IS NULL THEN
    l_time_end := '00:00';
  ELSE
    IF NOT good_time_format(l_time_end) THEN
      RAISE e_bad_time_format;
    END IF;
  END IF;
  l_start_date := TO_DATE(TO_CHAR(p_date_start,'DD-MM-YYYY')||' '||l_time_start,'DD-MM-YYYY HH24:MI');
  l_end_date := TO_DATE(TO_CHAR(p_date_end,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');
  IF p_days_or_hours = 'D' THEN
    l_end_date := l_end_date + 1;
--    l_end_date := l_end_date; --knelli
  END IF;
  --
  -- Fetch the work schedule
    hr_utility.set_location('calling hr_wrk_sch_pkg.get_per_asg_schedule',10);
  --
  hr_wrk_sch_pkg.get_per_asg_schedule
  ( p_person_assignment_id => p_assignment_id
  , p_period_start_date    => l_start_date
  , p_period_end_date      => l_end_date
  , p_schedule_category    => NULL  --knelli change
  , p_include_exceptions   =>'Y' --p_include_event
  , p_busy_tentative_as    => 'FREE' --Knelli change
  , x_schedule_source      => l_schedule_source
  , x_schedule             => l_schedule
  , x_return_status        => l_return_status
  , x_return_message       => l_return_message
  );
  --
  --knelli
  hr_utility.set_location('l_return status :' || l_return_status,10);
  IF l_return_status = '0' THEN
    --
    -- Calculate duration
    --
    l_idx := l_schedule.first;
    hr_utility.set_location('l_idx - loop index :' || l_schedule.first,10);
    --
    IF p_days_or_hours = 'D' THEN
      --
      l_first_band := TRUE;
      l_ref_date := NULL;
      WHILE l_idx IS NOT NULL
      LOOP
        --knelli
	--hr_utility.set_location('free or busy '|| l_schedule(l_idx).FREE_BUSY_TYPE,20);
	--l_schedule(l_idx).FREE_BUSY_TYPE := 'FREE'; --SET BY KNELLI
	--knelli
	IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN --knelli changed FREE to BUSY
            IF l_first_band THEN
              l_first_band := FALSE;
              l_ref_date := TRUNC(l_schedule(l_idx).START_DATE_TIME);
		--knelli
		hr_utility.set_location('start date time '|| l_schedule(l_idx).START_DATE_TIME,20);
		hr_utility.set_location('end date time '|| l_schedule(l_idx).END_DATE_TIME,20);
              IF (TRUNC(l_schedule(l_idx).END_DATE_TIME) = TRUNC(l_schedule(l_idx).START_DATE_TIME)) THEN
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
              ELSE
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
              END IF;
            ELSE -- not first time
              IF TRUNC(l_schedule(l_idx).START_DATE_TIME) = l_ref_date THEN
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
              ELSE
                l_ref_date := TRUNC(l_schedule(l_idx).END_DATE_TIME);
                IF (TRUNC(l_schedule(l_idx).END_DATE_TIME) = TRUNC(l_schedule(l_idx).START_DATE_TIME)) THEN
                  p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
                ELSE
                  p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      --
    ELSE -- p_days_or_hours is 'H'
      --
      l_day_start_time := '00:00';
      l_day_end_time := '23:59';
      WHILE l_idx IS NOT NULL
      LOOP
	 --knelli
	--hr_utility.set_location('free or busy '|| l_schedule(l_idx).FREE_BUSY_TYPE,20);
	--l_schedule(l_idx).FREE_BUSY_TYPE := 'FREE'; --SET BY KNELLI
	IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN ----knelli changed FREE to BUSY
            IF l_schedule(l_idx).END_DATE_TIME < l_schedule(l_idx).START_DATE_TIME THEN
              -- Skip this invalid slot which ends before it starts
              NULL;
            ELSE
              IF TRUNC(l_schedule(l_idx).END_DATE_TIME) > TRUNC(l_schedule(l_idx).START_DATE_TIME) THEN
                -- Start and End on different days
                --
                -- Get first day hours
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_day_end_time,1,2)*60 + SUBSTR(l_day_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
                --
                -- Get last day hours
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_day_start_time,1,2)*60 + SUBSTR(l_day_start_time,4,2)) + 1)/60)
                INTO p_duration
                FROM DUAL;
                --
                -- Get between full day hours
                SELECT p_duration + ((TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) - 1) * 24)
                INTO p_duration
                FROM DUAL;
              ELSE
                -- Start and End on same day
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      p_duration := ROUND(p_duration,2);
      --
    END IF;
  END IF;
  RETURN l_return;
  --
  hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',20);
EXCEPTION
  --
  WHEN e_bad_time_format THEN
    hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',30);
    hr_utility.set_location(SQLERRM,35);
    RAISE;
  --
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',40);
    hr_utility.set_location(SQLERRM,45);
    RAISE;
  --
  RETURN l_return;
END calc_sch_based_dur;


FUNCTION GET_BALANCE_DATE(p_BALANCE_DATE IN DATE)RETURN DATE IS
BEGIN
RETURN P_BALANCE_DATE;
END ;


FUNCTION clear_cache RETURN NUMBER
is
begin
g_fi_cache_table.delete;
	    RETURN 1;
end;


FUNCTION  set_value_cache(p_cache_code in varchar2, p_cache_value in varchar2)
RETURN NUMBER
is
l_cache_index number;
l_updated boolean;
begin
l_cache_index := g_fi_cache_table.FIRST;
l_updated:= FALSE;

-- filter out the desired preference

WHILE l_cache_index IS NOT NULL
LOOP

	IF ( g_fi_cache_table(l_cache_index).cache_code = p_cache_code )
	THEN

g_fi_cache_table(l_cache_index).cache_value:=		p_cache_value ;
l_updated:= true;
RETURN 1;

	END IF;

	l_cache_index := g_fi_cache_table.NEXT(l_cache_index);

END LOOP;

   if (not l_updated) then

    If (g_fi_cache_table.count > 0) then
	l_cache_index := g_fi_cache_table.last + 1;
    else
	l_cache_index := 1;
    End If;

    g_fi_cache_table(l_cache_index).cache_code :=p_cache_code;
    g_fi_cache_table(l_cache_index).cache_value :=p_cache_value;
    RETURN 1;
  end if;
    RETURN 0;
end ;

FUNCTION get_value_cache(p_cache_code in varchar2, p_cache_value out nocopy varchar2)
RETURN NUMBER
is
l_cache_index number;
begin
l_cache_index := g_fi_cache_table.FIRST;

-- filter out the desired preference

WHILE l_cache_index IS NOT NULL
LOOP

	IF ( g_fi_cache_table(l_cache_index).cache_code = p_cache_code )
	THEN

		p_cache_value := g_fi_cache_table(l_cache_index).cache_value;
    RETURN 1;
	END IF;

	l_cache_index := g_fi_cache_table.NEXT(l_cache_index);

END LOOP;
    RETURN 0;
end ;

FUNCTION delete_cache_table_row(p_cache_code in varchar2)RETURN NUMBER
is
l_cache_index number;
begin
l_cache_index := g_fi_cache_table.FIRST;


-- filter out the desired preference

WHILE l_cache_index IS NOT NULL
LOOP

	IF ( g_fi_cache_table(l_cache_index).cache_code = p_cache_code )
	THEN

    g_fi_cache_table.delete(l_cache_index);

	    RETURN 1;
	END IF;

	l_cache_index := g_fi_cache_table.NEXT(l_cache_index);


END LOOP;
	    RETURN 0;
end ;

FUNCTION PRINT1(P_LEVEL IN NUMBER,P_TEXT IN VARCHAR2,P_VALUE IN VARCHAR2) RETURN NUMBER
IS
BEGIN
HR_UTILITY.TRACE_ON(NULL,'X');
HR_UTILITY.TRACE(P_LEVEL ||' ' || P_TEXT || ' ' || P_VALUE );
HR_UTILITY.TRACE_OFF;
RETURN 1;
END;

 FUNCTION get_input_value_in_varchar
 (p_assignment_id 	in	NUMBER
 ,p_effective_date   in    DATE
 ,p_element_name	in	varchar2
 ,p_input_value_name  in varchar2
 ,p_input_value   out nocopy  varchar2
) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER,p_effective_date  DATE  ,
p_element_name varchar2,
p_input_value_name varchar2)
   IS
  SELECT eev1.SCREEN_ENTRY_VALUE
   FROM   per_all_assignments_f      asg1
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  et.element_name       =p_element_name
     AND  et.legislation_code   = 'FI'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value_name
     AND  el.business_group_id  = asg1.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg1.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date;

  --
  --
 BEGIN
  --
  OPEN  get_details(p_assignment_id ,p_effective_date,p_element_name,p_input_value_name);
  FETCH get_details INTO p_input_value ;
  CLOSE get_details;

    --
  RETURN 1 ;

 EXCEPTION
	WHEN OTHERS THEN
	RETURN 0 ;
  --
 END get_input_value_in_varchar;

function get_hourly_salaried_type(p_assignment_id in number,
p_date_earned in date
) return varchar2 is
cursor csr_hourly_salaried_type(p_assignment_id in number,
p_date_earned in date)
is
SELECT HOURLY_SALARIED_CODE FROM PER_ALL_ASSIGNMENTS_F WHERE ASSIGNMENT_ID=p_assignment_id and
p_date_earned between effective_start_date and effective_end_Date;

p_hourly_salaried varchar2(1);

begin
open csr_hourly_salaried_type(p_assignment_id,p_date_earned);
fetch csr_hourly_salaried_type into p_hourly_salaried;
close csr_hourly_salaried_type;
return p_hourly_salaried;
end;

FUNCTION get_payroll_period_info
 (p_payroll_id               IN NUMBER
 ,p_payroll_start_date          IN      DATE
 ,p_payroll_end_date          IN      DATE
 ,p_S_hp_pcent                    OUT  NOCOPY NUMBER
 ,p_W_hp_pcent                    OUT  NOCOPY NUMBER
 ,p_S_hb_pcent                    OUT  NOCOPY NUMBER
 ,p_W_hb_pcent                    OUT  NOCOPY NUMBER
 ,p_hc_pcent                    OUT  NOCOPY NUMBER
 ) RETURN NUMBER
AS
     CURSOR c_period_info IS
     SELECT     PRD_INFORMATION1
          ,PRD_INFORMATION2
          ,PRD_INFORMATION3
          ,PRD_INFORMATION4
          ,PRD_INFORMATION5
     FROM  per_time_periods
     WHERE payroll_id  = p_payroll_id
     AND start_date        = p_payroll_start_date
     AND end_date        = p_payroll_end_date;

     l_return               NUMBER;

 BEGIN


     OPEN  c_period_info;
     FETCH  c_period_info INTO p_S_hp_pcent  ,p_S_hb_pcent ,p_W_hp_pcent , p_W_hb_pcent ,p_hc_pcent;
          IF c_period_info%FOUND THEN
               l_return := 1 ;
          ELSE
               l_return := 0 ;
          END IF;
     CLOSE  c_period_info ;

     RETURN l_return;
EXCEPTION

     WHEN others THEN
     RETURN 0 ;
 END ;


END pay_fi_general;

/
