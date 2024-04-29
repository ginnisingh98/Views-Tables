--------------------------------------------------------
--  DDL for Package Body PAY_HK_AVG_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_AVG_PAY" AS
/* $Header: pyhkavgpay.pkb 120.0 2007/12/14 09:04:14 vamittal noship $ */

-- Package Variable
g_debug    boolean;
/* Bug 6318006 This function finds the time period start date for dimension _ASG_12MTHS_PREV */

FUNCTION TIME_START
(
   p_effective_date             IN         DATE
   ,p_assignment_action_id       IN         NUMBER
) RETURN DATE IS

     l_start_date       DATE :=  NULL ;
     l_date_earned      DATE;
     l_assignment_id    pay_assignment_actions.assignment_id%TYPE;

     CURSOR get_date_earned
     IS
     SELECT ppa.date_earned,paa.assignment_id
     FROM
     pay_payroll_actions ppa,
     pay_assignment_actions paa
     WHERE paa.assignment_action_id = p_assignment_action_id
     AND   ppa.payroll_action_id=paa.payroll_action_id;

BEGIN

    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
         hr_utility.set_location('Entering TIME_START',1);
         hr_utility.set_location('In Parameter p_effective_date '||p_effective_date,1);
         hr_utility.set_location('In Parameter p_assignment_action_id  '||p_assignment_action_id ,1);
    END if;

    OPEN get_date_earned;
    FETCH get_date_earned INTO l_date_earned,l_assignment_id;
    CLOSE get_date_earned;

    IF g_debug THEN
         hr_utility.set_location('After Cursor get_date_earned',1);
         hr_utility.set_location('l_date_earned '||l_date_earned,1);
         hr_utility.set_location('l_assignment_id  '||l_assignment_id ,1);
    END if;

    /* To fetch the start_date from absence element*/
    l_start_date := specified_date_absence(l_date_earned,l_assignment_id);
    IF l_start_date IS NULL
       THEN
       /* If absence is not present then fetch the start_date from Specified Date element*/
       l_start_date := specified_date_element(l_date_earned,l_assignment_id);
       IF l_start_date IS NULL
           THEN
	   /* If absence is not present then consider start_date as the effectice_date */
           l_start_date := l_date_earned;

       END IF;
    END IF;


    l_start_date := add_months(l_start_date,-13);
    l_start_date := last_day(l_start_date) + 1;

    IF g_debug THEN
         hr_utility.set_location('Retruned specified Date '||l_start_date,1);
    END if;

    RETURN l_start_date;

END TIME_START;

/* Bug 6318006
This Function will fetch the specified date from element entry of absence element for dimension _ASG_12MTHS_PREV */

Function SPECIFIED_DATE_ABSENCE
( p_date_earned                IN         DATE
 ,p_assignment_id              IN         NUMBER
) RETURN DATE IS

     l_start_date     DATE :=  NULL ;

     CURSOR csr_get_specified_date
     IS
     SELECT min(pea.date_start)
     FROM
     per_all_assignments_f paa,
     per_absence_attendances pea,
     pay_element_entries_f pee
     WHERE pee.assignment_id=p_assignment_id
     AND   paa.assignment_id=pee.assignment_id
     AND   pea.person_id = paa.person_id
     AND   pee.creator_type='A'
     AND   pee.creator_id = pea.absence_attendance_id
     AND   p_date_earned between pee.effective_start_date and pee.effective_end_date
     AND   p_date_earned between paa.effective_start_date and paa.effective_end_date;

BEGIN

    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
         hr_utility.set_location('Entering SPECIFIED_DATE_ABSENCE',1);
         hr_utility.set_location('In Parameter p_date_earned '||p_date_earned,1);
         hr_utility.set_location('In Parameter p_assignment_id  '||p_assignment_id ,1);
    END if;

    OPEN csr_get_specified_date;
    FETCH csr_get_specified_date INTO l_start_date;
    CLOSE csr_get_specified_date;

    IF g_debug THEN
         hr_utility.set_location('Retruned specified Date '||l_start_date,1);
    END if;

    RETURN l_start_date;

END SPECIFIED_DATE_ABSENCE;

/* Bug 6318006
This Function will fetch the specified date from element entry of Specified Date Element for dimension _ASG_12MTHS_PREV */

Function SPECIFIED_DATE_ELEMENT
( p_date_earned                IN         DATE
 ,p_assignment_id              IN         NUMBER
) RETURN DATE IS

     l_start_date     DATE :=  NULL ;

     CURSOR csr_get_specified_date
     IS
     SELECT fnd_date.canonical_to_date(peev.screen_entry_value)
     FROM
     pay_element_entries_f pee,
     pay_element_entry_values_f peev,
     pay_element_types_f pet,
     pay_input_values_f pivf
     WHERE pee.assignment_id=p_assignment_id
     AND   pet.element_name='Specified Date'
     AND   pee.element_type_id=pet.element_type_id
     AND   pivf.element_type_id = pet.element_type_id
     AND   pivf.name = 'Specified Date'
     AND   pee.element_entry_id=peev.element_entry_id
     AND   peev.input_value_id=pivf.input_value_id
     AND   p_date_earned between pee.effective_start_date and pee.effective_end_date
     AND   p_date_earned between peev.effective_start_date and peev.effective_end_date
     AND   p_date_earned between pet.effective_start_date and pet.effective_end_date
     AND   p_date_earned between pivf.effective_start_date and pivf.effective_end_date;

BEGIN

    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
         hr_utility.set_location('Entering SPECIFIED_DATE_ELEMENT',1);
         hr_utility.set_location('In Parameter p_date_earned '||p_date_earned,1);
         hr_utility.set_location('In Parameter p_assignment_id  '||p_assignment_id ,1);
    END if;

    OPEN csr_get_specified_date;
    FETCH csr_get_specified_date INTO l_start_date;
    CLOSE csr_get_specified_date;

    IF g_debug THEN
         hr_utility.set_location('Retruned specified Date '||l_start_date,1);
    END if;

    RETURN l_start_date;

END SPECIFIED_DATE_ELEMENT;

/* Bug 6318006
This Function will give the total number of days for dimension _ASG_12MTHS_PREV */

Function NO_OF_DAYS
( p_assignment_action_id              IN         NUMBER
) RETURN NUMBER IS

     l_specified_date  DATE :=  NULL;
     l_start_date     DATE :=  NULL ;
     l_end_date     DATE :=  NULL ;
     l_date_earned    DATE;
     l_effective_date DATE;
     l_hire_date      DATE;
     l_assignment_id  pay_assignment_actions.assignment_id%TYPE;
     l_no_of_days     NUMBER;

     CURSOR get_date_earned
     IS
     SELECT ppa.date_earned,paa.assignment_id,ppa.effective_date
     FROM
     pay_payroll_actions ppa,
     pay_assignment_actions paa
     WHERE paa.assignment_action_id = p_assignment_action_id
     AND   ppa.payroll_action_id=paa.payroll_action_id;

     CURSOR  csr_hire_date(p_assignment_id in number)
       IS
    SELECT  pps.date_start
    FROM  per_periods_of_service pps,
           per_people_f           ppf,
           per_assignments_f      paf
    WHERE  paf.person_id             = ppf.person_id
      AND  pps.person_id             = paf.person_id
      AND  paf.assignment_id         = p_assignment_id
      AND  paf.period_of_service_id  = pps.period_of_service_id;


BEGIN


    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
         hr_utility.set_location('Entering NO_OF_DAYS',1);
         hr_utility.set_location('In Parameter p_assignment_action_id '||p_assignment_action_id,1);
    END if;

    OPEN get_date_earned;
    FETCH get_date_earned INTO l_date_earned,l_assignment_id,l_effective_date;
    CLOSE get_date_earned;


    IF g_debug THEN
         hr_utility.set_location('After Cursor get_date_earned',1);
         hr_utility.set_location('l_date_earned '||l_date_earned,1);
         hr_utility.set_location('l_assignment_id  '||l_assignment_id ,1);
         hr_utility.set_location('l_effective_date  '||l_effective_date ,1);
    END if;

    /* To fetch the start_date from absence element*/
    l_specified_date := specified_date_absence(l_date_earned,l_assignment_id);
    IF l_specified_date IS NULL
       THEN
       /* If absence is not present then fetch the start_date from Specified Date element*/
       l_specified_date := specified_date_element(l_date_earned,l_assignment_id);
       IF l_specified_date IS NULL
           THEN
	   /* If absence is not present then consider start_date as the effectice_date */
           l_specified_date := l_date_earned;

       END IF;
    END IF;

    /* to get the hire date */

    OPEN csr_hire_date(l_assignment_id);
    FETCH csr_hire_date into l_hire_date;
    CLOSE csr_hire_date;

    IF g_debug THEN
         hr_utility.set_location('After Cursor csr_hire_date',1);
         hr_utility.set_location('l_hire_date '||l_hire_date,1);
    END if;

    l_start_date := last_day(add_months(l_specified_date,-13))+1;
    l_end_date := last_day(add_months(l_specified_date,-1));

    IF g_debug THEN
         hr_utility.set_location('l_start_date '||l_start_date,1);
         hr_utility.set_location('l_end_date '||l_end_date,1);
    END if;


         /*If hire_date is more then l_start_date */
	 IF l_start_date < l_hire_date
         THEN
         l_start_date := l_hire_date;
         END IF;

    l_no_of_days := trunc (l_end_date - l_start_date + 1);

    IF g_debug THEN
         hr_utility.set_location('Retruned l_no_of_days '||l_no_of_days,1);
    END if;

    RETURN l_no_of_days;


END NO_OF_DAYS;

END PAY_HK_AVG_PAY;

/
