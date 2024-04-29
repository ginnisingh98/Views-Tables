--------------------------------------------------------
--  DDL for Package Body PER_PAY_PROPOSALS_POPULATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PAY_PROPOSALS_POPULATE" AS
/* $Header: pepaprpo.pkb 120.1 2006/10/30 13:54:13 abhshriv noship $ */
g_package  	varchar2(33) := 'per_pay_proposals_populate.';
g_debug boolean := hr_utility.debug_enabled;
--------------------------------------------------------------------------
/* Procedure to get the grade that a person is on given the
   date, assginment_id and business_group_id. If the person
   has not had a grade set at that date then nothing is
   returned */

  PROCEDURE GET_GRADE(p_date             DATE,
                      p_assignment_id    NUMBER,
                      p_business_group_id NUMBER,
                      p_grade            OUT NOCOPY VARCHAR2,
                      p_minimum_salary   OUT NOCOPY NUMBER,
                      p_maximum_salary   OUT NOCOPY NUMBER,
                      p_midpoint_salary  OUT NOCOPY NUMBER,
                      p_grade_uom        OUT NOCOPY VARCHAR2)
IS

cursor grade_rates IS
    SELECT fnd_number.canonical_to_number(PGR.MINIMUM)
    ,      fnd_number.canonical_to_number(PGR.MAXIMUM)
    ,      fnd_number.canonical_to_number(PGR.MID_VALUE)
    ,      PRV.RATE_UOM
    FROM   PER_PAY_BASES PPB
    ,      PAY_GRADE_RULES_F PGR
    ,      PAY_RATES_V PRV
    ,      PER_ALL_ASSIGNMENTS_F ASG
    WHERE  ASG.ASSIGNMENT_ID=p_assignment_id
    AND    PPB.PAY_BASIS_ID=ASG.PAY_BASIS_ID
    AND    PPB.RATE_ID=PGR.RATE_ID
    AND    PPB.RATE_ID=PRV.RATE_ID
    AND    ASG.GRADE_ID=PGR.GRADE_OR_SPINAL_POINT_ID
    AND    p_date BETWEEN asg.effective_start_date
                  AND     asg.effective_end_date
    AND    p_date BETWEEN pgr.effective_start_date
                  AND     pgr.effective_end_date;

cursor grade_name IS
    SELECT GRA.NAME
    FROM   PER_GRADES_VL GRA
    ,      PER_ALL_ASSIGNMENTS_F ASG
    WHERE  ASG.ASSIGNMENT_ID=p_assignment_id
    AND    ASG.GRADE_ID=GRA.GRADE_ID
    AND    p_date BETWEEN asg.effective_start_date
                  AND     asg.effective_end_date;

  l_proc    varchar2(72) := g_package||'get_grade';
BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
      open grade_rates;
      fetch grade_rates
      INTO p_minimum_salary,
           p_maximum_salary,
           p_midpoint_salary,
           p_grade_uom;
      close grade_rates;

      open grade_name;
      fetch grade_name
      INTO p_grade;
      close grade_name;

  EXCEPTION
    WHEN others THEN null;

END GET_GRADE;
-------------------------------------------------------------------------------
/* Procedure to get the previous element_entry_id ( and salary) given the date,
  assignment_id and business_group_id */

  PROCEDURE GET_ELEMENT_ID(p_assignment_id     IN    NUMBER,
                           p_business_group_id IN    NUMBER,
                           p_change_date       IN    DATE,
                           p_payroll_value       OUT NOCOPY NUMBER,
                           p_element_entry_id    OUT NOCOPY NUMBER)
IS

cursor get_element IS
 select fnd_number.canonical_to_number(pev.screen_entry_value)
   ,      pee.element_entry_id
   from   pay_element_entry_values_f pev
   ,      pay_element_entries_f pee
   ,      per_pay_bases ppb
   ,      per_all_assignments_f asg
   where  asg.assignment_id=p_assignment_id
   and    NVL(p_change_date,to_date('31-12-4127','DD-MM-YYYY')) between
          asg.effective_start_date and asg.effective_end_date
   and    NVL(p_change_date,to_date('31-12-4127','DD-MM-YYYY')) between
          pev.effective_start_date and pev.effective_end_date
   and    pev.element_entry_id=pee.element_entry_id
   and    asg.assignment_id=pee.assignment_id
   and    NVL(p_change_date,to_date('31-12-4127','DD-MM-YYYY')) between
          pee.effective_start_date and pee.effective_end_date
   and    pev.input_value_id+0=ppb.input_value_id
   and    asg.pay_basis_id=ppb.pay_basis_id
   -- the below line added for bug Fix# 3192448
   and    pee.creator_type = 'SP';

  l_proc    varchar2(72) := g_package||'get_element_id';
BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

      open get_element;
      fetch get_element
      INTO p_payroll_value,p_element_entry_id;
      close get_element;
    EXCEPTION WHEN no_data_found THEN
      p_payroll_value:=null;
      p_element_entry_id:=null;

END GET_ELEMENT_ID;
------------------------------------------------------------

PROCEDURE GET_CURRENCY_FORMAT(curcode VARCHAR2,
                              fstring IN OUT NOCOPY VARCHAR2) IS
  l_format_mask VARCHAR2(40);

  l_proc    varchar2(72) := g_package||'get_currency_format';
BEGIN
  hr_utility.set_location('Entering:'||l_proc,5);
  hr_utility.set_location('curcode= '||curcode,10);

  l_format_mask:= FND_CURRENCY.GET_FORMAT_MASK(curcode,30);
  hr_utility.set_location('format= '||l_format_mask,15);
  fstring:=l_format_mask;
  hr_utility.set_location('format= '||fstring,15);

END GET_CURRENCY_FORMAT;
------------------------------------------------------------

PROCEDURE GET_NUMBER_FORMAT(fstring IN OUT NOCOPY VARCHAR2) IS
  l_format_mask VARCHAR2(40);

  l_proc    varchar2(72) := g_package||'get_currency_format';
BEGIN
  hr_utility.set_location('Entering:'||l_proc,5);

  FND_CURRENCY.BUILD_FORMAT_MASK(format_mask   => l_format_mask
                                ,field_length  => 30
                                ,precision     => 5
                                ,min_acct_unit => null);
  hr_utility.set_location('format= '||l_format_mask,15);
  fstring:=l_format_mask;
  hr_utility.set_location('format= '||fstring,15);

END GET_NUMBER_FORMAT;
--------------------------------------------------------------------------------
/* Procedure the populate the default values for a new salary proposal,
   given the date and assignment_id */
  PROCEDURE GET_DEFAULTS(p_assignment_id           IN     NUMBER
                        ,p_date                    IN OUT NOCOPY DATE
                        ,p_business_group_id          OUT NOCOPY NUMBER
                        ,p_currency                   OUT NOCOPY VARCHAR2
                        ,p_format_string              OUT NOCOPY VARCHAR2
                        ,p_salary_basis_name          OUT NOCOPY VARCHAR2
                        ,p_pay_basis_name             OUT NOCOPY VARCHAR2
                        ,p_pay_basis                  OUT NOCOPY VARCHAR2
                        ,p_pay_annualization_factor   OUT NOCOPY NUMBER
                        ,p_grade                      OUT NOCOPY VARCHAR2
                        ,p_grade_annualization_factor OUT NOCOPY NUMBER
                        ,p_minimum_salary             OUT NOCOPY NUMBER
                        ,p_maximum_salary             OUT NOCOPY NUMBER
                        ,p_midpoint_salary            OUT NOCOPY NUMBER
                        ,p_prev_salary                OUT NOCOPY NUMBER
                        ,p_last_change_date           OUT NOCOPY DATE
                        ,p_element_entry_id           OUT NOCOPY NUMBER
                        ,p_basis_changed              OUT NOCOPY BOOLEAN
                        ,p_uom                        OUT NOCOPY VARCHAR2
                        ,p_grade_uom                  OUT NOCOPY VARCHAR2) IS

  Cursor bus_grp IS
  select business_group_id
  from   per_all_assignments_f
  where  assignment_id=p_assignment_id
  and    p_date BETWEEN
         effective_start_date AND
         effective_end_date;

  l_business_group_id      NUMBER;
  l_currency               VARCHAR2(15);
  l_salary_basis_name      VARCHAR2(30);
  l_pay_basis_name         VARCHAR2(80);
  l_pay_annualization_factor   NUMBER;
  l_grade_annualization_factor   NUMBER;
  l_grade                  VARCHAR2(240);
  l_grade_basis            VARCHAR2(80);
  l_minimum_rate           NUMBER;
  l_maximum_rate           NUMBER;
  l_midpoint_rate          NUMBER;
  l_next_sal_review_date   DATE default NULL;
  l_dummy_n                NUMBER;
  l_change_date            DATE;
  l_previous_salary        NUMBER;
  l_last_change_date       DATE;
  l_format_string          VARCHAR2(40);
  l_basis_changed          BOOLEAN;
  l_pay_basis              VARCHAR2(30);
  l_uom                    VARCHAR2(30);
  l_grade_uom              VARCHAR2(30);

  l_proc    varchar2(72) := g_package||'get_defaults';
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

  l_change_date:=p_date;

  GET_PREV_SALARY(l_change_date
                 ,p_assignment_id
                 ,l_previous_salary
                 ,l_last_change_date
                 ,l_basis_changed);

  p_date:=l_change_date;
  p_prev_salary:=l_previous_salary;
  p_last_change_date:=l_last_change_date;
  p_basis_changed:=l_basis_changed;

    open bus_grp;
    fetch bus_grp INTO l_business_group_id;
    close  bus_grp;

    p_business_group_id:=l_business_group_id;
            GET_BASIS_DETAILS(p_date
                             ,p_assignment_id
                             ,l_currency
                             ,l_salary_basis_name
                             ,l_pay_basis_name
                             ,l_pay_basis
                             ,l_pay_annualization_factor
                             ,l_grade_basis
                             ,l_grade_annualization_factor
                             ,l_dummy_n
                             ,l_uom);

    p_currency:=l_currency;
    p_salary_basis_name:=l_salary_basis_name;
    p_pay_basis_name:=l_pay_basis_name;
    p_pay_basis:=l_pay_basis;
    p_pay_annualization_factor:=l_pay_annualization_factor;
    p_grade_annualization_factor:=l_grade_annualization_factor;
    p_uom:=l_uom;
    GET_CURRENCY_FORMAT(l_currency
                       ,l_format_string);
    p_format_string:=l_format_string;

    GET_GRADE(p_date
             ,p_assignment_id
             ,l_business_group_id
             ,l_grade
             ,l_minimum_rate
             ,l_maximum_rate
             ,l_midpoint_rate
             ,l_grade_uom);

    p_grade:=l_grade;
    p_minimum_salary:=l_minimum_rate*l_grade_annualization_factor;
    p_maximum_salary:=l_maximum_rate*l_grade_annualization_factor;
    p_midpoint_salary:=l_midpoint_rate*l_grade_annualization_factor;
    p_grade_uom:=l_grade_uom;

  GET_ELEMENT_ID(p_assignment_id,
                     l_business_group_id,
                     p_date,
                     l_dummy_n,
                     p_element_entry_id);


  END GET_DEFAULTS;
-----------------------------------------------------------------------------
/* gets the information about the pay basis associated with an assignment */
  PROCEDURE GET_BASIS_DETAILS(p_effective_date             DATE
                             ,p_assignment_id              NUMBER
                             ,p_currency                   OUT NOCOPY VARCHAR2
                             ,p_salary_basis_name          OUT NOCOPY VARCHAR2
                             ,p_pay_basis_name             OUT NOCOPY VARCHAR2
                             ,p_pay_basis                  OUT NOCOPY VARCHAR2
                             ,p_pay_annualization_factor   OUT NOCOPY NUMBER
                             ,p_grade_basis                OUT NOCOPY VARCHAR2
                             ,p_grade_annualization_factor OUT NOCOPY NUMBER
                             ,p_element_type_id            OUT NOCOPY NUMBER
                             ,p_uom                        OUT NOCOPY VARCHAR2) IS

l_dummy VARCHAR2(30);
l_grade_basis VARCHAR2(30);
l_pay_basis VARCHAR2(30);
l_pay_basis_id NUMBER;
l_grade_annualization_factor NUMBER;
l_pay_annualization_factor NUMBER;

  CURSOR c_pay_basis is
  SELECT PAF.PAY_BASIS_ID
  FROM PER_ALL_ASSIGNMENTS_F        PAF
  WHERE PAF.ASSIGNMENT_ID=p_assignment_id
  AND p_effective_date  BETWEEN
  PAF.EFFECTIVE_START_DATE AND
  PAF.EFFECTIVE_END_DATE;
  --
  CURSOR Currency IS
  SELECT PET.INPUT_CURRENCY_CODE
, PPB.NAME
, HR_GENERAL.DECODE_LOOKUP('PAY_BASIS',PPB.PAY_BASIS)
, PPB.PAY_ANNUALIZATION_FACTOR
, PPB.GRADE_ANNUALIZATION_FACTOR
, PPB.PAY_BASIS
, PPB.RATE_BASIS
, PET.ELEMENT_TYPE_ID
, PIV.UOM
  FROM PAY_ELEMENT_TYPES_F PET
, PAY_INPUT_VALUES_F       PIV
, PER_PAY_BASES            PPB
--
  WHERE PPB.PAY_BASIS_ID=L_PAY_BASIS_ID
--
  AND PPB.INPUT_VALUE_ID=PIV.INPUT_VALUE_ID
  AND p_effective_date  BETWEEN
  PIV.EFFECTIVE_START_DATE AND
  PIV.EFFECTIVE_END_DATE
--
  AND PIV.ELEMENT_TYPE_ID=PET.ELEMENT_TYPE_ID
  AND p_effective_date  BETWEEN
  PET.EFFECTIVE_START_DATE AND
  PET.EFFECTIVE_END_DATE;

  l_proc    varchar2(72) := g_package||'get_basis_details';
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
    open c_pay_basis;
    fetch c_pay_basis into l_pay_basis_id;
    close c_pay_basis;
    --
    open Currency;
    fetch Currency
    into p_currency
,   p_salary_basis_name
,   p_pay_basis_name
,   l_pay_annualization_factor
,   l_grade_annualization_factor
,   l_pay_basis
,   l_grade_basis
,   p_element_type_id
,   p_uom;
--
    hr_utility.set_location(l_proc,10);
--
    close Currency;

    if(l_pay_basis ='PERIOD' and l_pay_annualization_factor is null) then
    hr_utility.set_location(l_proc,15);
--
     GET_PAYROLL(p_assignment_id
                       ,p_effective_date
                       ,l_dummy
                       ,l_pay_annualization_factor);
    end if;
--
    if(l_grade_basis ='PERIOD' and l_grade_annualization_factor is null) then
    hr_utility.set_location(l_proc,20);

     GET_PAYROLL(p_assignment_id
                       ,p_effective_date
                       ,l_dummy
                       ,l_grade_annualization_factor);
    end if;
--
    p_pay_basis:=l_pay_basis;
    p_grade_basis:=l_grade_basis;
    p_pay_annualization_factor:=l_pay_annualization_factor;
    p_grade_annualization_factor:=l_grade_annualization_factor;
    hr_utility.set_location('Leaving:'||l_proc,25);

  END GET_BASIS_DETAILS;
---------------------------------------------------------------------------
/* procedure to get the previous change date */
  PROCEDURE GET_PREV_SALARY(p_date          IN OUT NOCOPY    DATE
                           ,p_assignment_id IN     NUMBER
                           ,p_prev_salary      OUT NOCOPY NUMBER
                           ,p_last_change_date OUT NOCOPY DATE
                           ,p_basis_changed    OUT NOCOPY BOOLEAN) IS


      CURSOR previous_pay is
      select pro.proposed_salary_n
      ,      pro.change_date
      from per_pay_proposals pro
      where pro.assignment_id = p_assignment_id
      and pro.change_date =(select max(pro2.change_date)
                            from per_pay_proposals pro2
                            where pro2.assignment_id = p_assignment_id
                            and pro2.change_date<p_date);


  l_element_id       NUMBER;
  l_last_element_id  NUMBER;
  l_dummy_v          VARCHAR2(100);
  l_dummy_n          NUMBER;
  l_last_change_date DATE;

  l_proc    varchar2(72) := g_package||'get_prev_salary';
     BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
      --
       open previous_pay;
        fetch previous_pay
        into p_prev_salary
        ,    l_last_change_date;

       if previous_pay%found then
         close previous_pay;
--
         p_last_change_date:=l_last_change_date;
--
         if (l_last_change_date > p_date) THEN
           p_date:= l_last_change_date+1;
         end if;
            GET_BASIS_DETAILS(p_date
                             ,p_assignment_id
                             ,l_dummy_v
                             ,l_dummy_v
                             ,l_dummy_v
                             ,l_dummy_v
                             ,l_dummy_n
                             ,l_dummy_v
                            ,l_dummy_n
                             ,l_element_id
                             ,l_dummy_v);
            GET_BASIS_DETAILS(l_last_change_date
                             ,p_assignment_id
                             ,l_dummy_v
                             ,l_dummy_v
                             ,l_dummy_v
                             ,l_dummy_v
                             ,l_dummy_n
                             ,l_dummy_v
                             ,l_dummy_n
                             ,l_last_element_id
                             ,l_dummy_v);

          if (l_element_id <> l_last_element_id) then
        /**
	 * Bug Fix: 2279048
	 * Description: fixed to get the previous salary
	 **/
	  -- p_prev_salary:=null;
            p_basis_changed:=TRUE;
          else
            p_basis_changed:=FALSE;
          end if;
        else
          close previous_pay;
          p_prev_salary:=null;
          p_last_change_date:=null;
       end if;

      EXCEPTION

      WHEN NO_DATA_FOUND THEN
         NULL;

  END GET_PREV_SALARY;
---------------------------------------------------------------------------
/* gets the payroll name and frequency for an assignment */
  PROCEDURE GET_PAYROLL(p_assignment_id         NUMBER
                       ,p_date                  DATE
                       ,p_payroll           OUT NOCOPY VARCHAR2
                       ,p_payrolls_per_year OUT NOCOPY NUMBER) IS

  cursor payroll is
  select prl.payroll_name
  ,      tpt.number_per_fiscal_year
  from pay_all_payrolls_f prl
  ,    per_all_assignments_f paf
  ,    per_time_period_types tpt
  where paf.assignment_id=p_assignment_id
  and p_date between paf.effective_start_date
      and paf.effective_end_date
  and paf.payroll_id=prl.payroll_id
  and p_date between prl.effective_start_date
      and prl.effective_end_date
  and prl.period_type = tpt.period_type(+);

  l_proc    varchar2(72) := g_package||'get_payroll';
  begin
    hr_utility.set_location('Entering:'||l_proc,5);

  open payroll;
  fetch payroll into p_payroll,p_payrolls_per_year;
  close payroll;

  end get_payroll;
-----------------------------------------------------------------------------
/* gets the working hours for the person, first of all from the assignment
   then if that is null, from the position, then if that is null, from
   the organization then if that is null, from the business group */

  procedure get_hours(p_assignment_id      NUMBER
                     ,p_date               DATE
                     ,p_hours_per_year OUT NOCOPY NUMBER)is

  l_hours_per_year number;

  l_proc    varchar2(72) := g_package||'get_hours';
  begin
    hr_utility.set_location('Entering:'||l_proc,5);

    get_asg_hours(p_assignment_id
                 ,p_date
                 ,l_hours_per_year);

    if(nvl(l_hours_per_year,0) =0) then
      get_norm_hours(p_assignment_id
                    ,p_date
                    ,l_hours_per_year);
    end if;
    p_hours_per_year:=l_hours_per_year;
  end get_hours;
-----------------------------------------------------------------------------
/* gets the assignment working hours for the person */

  procedure get_asg_hours(p_assignment_id      NUMBER
                         ,p_date               DATE
                         ,p_hours_per_year OUT NOCOPY NUMBER)is

  cursor get_asg_hours is
  select asg.normal_hours
  ,      decode(asg.frequency
               ,'Y',1
               ,'M',12
               ,'W',52
               ,'D',365
               ,1)
  from   per_all_assignments_f asg
  where  asg.assignment_id =p_assignment_id
  and    p_date between asg.effective_start_date
         and asg.effective_end_date;

  l_hours NUMBER;
  l_frequency NUMBER;

  l_proc    varchar2(72) := g_package||'get_asg_hours';
  begin
    hr_utility.set_location('Entering:'||l_proc,5);

  open get_asg_hours;
  fetch get_asg_hours into l_hours,l_frequency;

  if (get_asg_hours%found and l_hours is not null) THEN
    p_hours_per_year:=nvl(l_hours,0)*l_frequency;
  else
    p_hours_per_year:=null;
  end if;
    close get_asg_hours;

  end get_asg_hours;
------------------------------------------------------------------------------
-----------------------------------------------------------------------------
/* gets the working hours for the person, first of all from the position,
   then if that is null, from
   the organization then if that is null, from the business group */
  procedure get_norm_hours(p_assignment_id      NUMBER
                     ,p_date               DATE
                     ,p_hours_per_year OUT NOCOPY NUMBER)is

  --
  -- Changed 01-Oct-99 SCNair (per_all_positions ro hr_all_positions) Date tracked positions requirement
  --
  --
  -- Changed 30-OCT-06 ABHSHRIV Error Handling for cases when the org_information3/working_hours
  -- are of invalid character type (BUG 5622048)
  --
  cursor get_pos_hours is
  select pos.working_hours
  ,      decode(pos.frequency
               ,'Y',1
               ,'M',12
               ,'W',52
               ,'D',365
               ,1)
  from   hr_all_positions pos
  ,      per_all_assignments_f asg
  where  asg.assignment_id =p_assignment_id
  and    p_date between asg.effective_start_date
         and asg.effective_end_date
  and    asg.position_id=pos.position_id;

  cursor get_org_hours is
  select fnd_number.canonical_to_number(org.org_information3) normal_hours
  ,      decode(org.org_information4
               ,'Y',1
               ,'M',12
               ,'W',52
               ,'D',365
               ,1)
  from   HR_ORGANIZATION_INFORMATION org
  ,      per_all_assignments_f asg
  where  asg.assignment_id =p_assignment_id
  and    p_date between asg.effective_start_date
         and asg.effective_end_date
  and    asg.organization_id=org.organization_id(+)
  and    org.org_information_context(+) = 'Work Day Information';

 cursor get_bus_hours is
  select fnd_number.canonical_to_number(bus.working_hours) normal_hours
  ,      decode(bus.frequency
               ,'Y',1
               ,'M',12
               ,'W',52
               ,'D',365
               ,1)
  from   per_business_groups bus
  ,      per_all_assignments_f asg
  where  asg.assignment_id =p_assignment_id
  and    p_date between asg.effective_start_date
         and asg.effective_end_date
  and    asg.business_group_id=bus.business_group_id;

  l_hours NUMBER;
  l_frequency NUMBER;

  l_proc    varchar2(72) := g_package||'get_norm_hours';
  begin
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc,5);
  end if;

    open get_pos_hours;
    fetch get_pos_hours into l_hours,l_frequency;
    close get_pos_hours;

    if l_hours is null or l_frequency is null then
        begin
             if g_debug then
                hr_utility.set_location('get_org_hours',7);
             end if;
            open get_org_hours;
            fetch get_org_hours into l_hours,l_frequency;
            close get_org_hours;
        exception
            when others then
             if g_debug then
                hr_utility.set_location('get_org_hours exception',8);
             end if;
                l_hours := null;
                l_frequency := null;
        end;
      if l_hours is null or l_frequency is null then
        begin
             if g_debug then
                hr_utility.set_location('get_bus_hours',10);
             end if;
           open get_bus_hours;
           fetch get_bus_hours into l_hours,l_frequency;
           close get_bus_hours;
        exception
           when others then
             if g_debug then
                hr_utility.set_location('get_bus_hours exception',12);
             end if;
                l_hours := null;
                l_frequency := null;
        end;
      end if;
    end if;
    p_hours_per_year:=nvl(l_hours,0)*l_frequency;
             if g_debug then
                hr_utility.set_location('Leaving:'||l_proc,15);
             end if;
  end get_norm_hours;


------------------------------------------------------------------------------
END PER_PAY_PROPOSALS_POPULATE;

/
