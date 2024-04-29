--------------------------------------------------------
--  DDL for Package Body PER_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VIEWS_PKG" as
/* $Header: peronvew.pkb 120.0.12010000.3 2008/09/25 05:02:24 nshrikha ship $ */
--
CURSOR csr_get_payroll (P_assignment_id    number,
                        P_calculation_date date )  IS
       select a.payroll_id,
              a.effective_start_date,
              a.effective_end_date,
              a.business_group_id,
              b.DATE_START,
              b.ACTUAL_TERMINATION_DATE
       from   PER_ASSIGNMENTS_F      a,
              PER_PERIODS_OF_SERVICE b
       where  a.assignment_id        = P_assignment_id
       and    P_calculation_date between a.effective_start_date and
                                         a.effective_end_date
       and    a.PERIOD_OF_SERVICE_ID = b.PERIOD_OF_SERVICE_ID;
--
--
CURSOR csr_get_period (p_payroll_id     number,
                       p_effective_date date   )  is
       select PERIOD_NUM,
              START_DATE,
              END_DATE
       from   PER_TIME_PERIODS
       where  PAYROLL_ID             = p_payroll_id
       and    p_effective_date between START_DATE and END_DATE;
--
--
CURSOR csr_calc_accrual (P_start_date    date,
                         P_end_date      date,
                         P_assignment_id number,
                         P_plan_id       number ) IS
       select sum(to_number(nvl(pev.SCREEN_ENTRY_VALUE,'0')) *
                  to_number(pnc.add_or_subtract))
       from   pay_net_calculation_rules    pnc,
              pay_element_entry_values_f   pev,
              pay_element_entries_f        pee
       where  pnc.accrual_plan_id    = p_plan_id
       and    pnc.input_value_id     = pev.input_value_id + 0
       and    pev.element_entry_id    = pee.element_entry_id
       and    pee.assignment_id      = P_assignment_id
       and    pee.effective_start_date between P_start_date and
                                               P_end_date;
--
--
CURSOR csr_get_total_periods ( p_payroll_id     number,
                               p_date           date   ) is
       select min(start_date),
              min(end_date),
              max(start_date),
              max(end_date),
              count(period_num)
       from   per_time_periods
       where  payroll_id             = p_payroll_id
      -- and    to_char(P_date,'YYYY/MM/DD') = to_char(end_date,'YYYY/MM/DD'); -- bug 6706398
       and    to_char(P_date,'YYYY') = to_char(end_date,'YYYY'); -- bug 6706398


--
-- -------------------------------------------------------------------------
-- --------------------< PER_GET_GRADE_STEP >-------------------------------
-- -------------------------------------------------------------------------
function PER_GET_GRADE_STEP
           (  p_grade_spine_id        NUMBER,
              p_step_id               NUMBER,
              p_parent_spine_id       NUMBER,
              p_effective_start_date  DATE
           )
return number
is
   l_grade_step    number ;
BEGIN

   select  count(*)
   into    l_grade_step
   from    per_spinal_point_steps_f psps
   ,       per_spinal_points        psp
   ,       per_spinal_point_steps_f psps1
   where   psps.grade_spine_id  = p_grade_spine_id
   and     psps.step_id         = p_step_id
   and     psps1.grade_spine_id  = psps.grade_spine_id
   and     psp.spinal_point_id  = psps.spinal_point_id
   and     psps.sequence       >= psps1.sequence
   and     psp.parent_spine_id  = p_parent_spine_id
   and     p_effective_start_date between psps.effective_start_date
                                  and     psps.effective_end_date
   and     p_effective_start_date between psps1.effective_start_date
                                  and     psps1.effective_end_date ;

  return (l_grade_step);

END PER_GET_GRADE_STEP ;

-- -------------------------------------------------------------------------
-- --------------------< PER_CALC_COMPARATIO >------------------------------
-- -------------------------------------------------------------------------
function PER_CALC_COMPARATIO
             ( p_assignment_id          NUMBER,
               p_change_date            DATE,
               p_actual_salary          NUMBER,
               p_element_entry_id       NUMBER,
               p_normal_hours           NUMBER,
               p_org_working_hours      NUMBER,
               p_pos_working_hours      NUMBER,
               p_org_frequency          VARCHAR2,
               p_pos_frequency          VARCHAR2,
               p_number_per_fiscal_year NUMBER,
               p_grade_id               NUMBER,
               p_rate_id                NUMBER,
               p_pay_basis              VARCHAR2,
               p_rate_basis             VARCHAR2,
               p_business_group_id      NUMBER
             )
             return number
is
    --
    -- Declare Variables
    --
    v_minimum           NUMBER;
    v_maximum           NUMBER;
    v_mid_value         NUMBER;
    v_working_hours     NUMBER;
    v_frequency         VARCHAR2(80);
    v_adj_mid           NUMBER;
--changes for bug no 5945278 starts here
    v_PAY_BASIS_ID      per_assignments_f.pay_basis_id%type;
    v_PAY_ANNUALIZATION_FACTOR      PER_PAY_BASES.PAY_ANNUALIZATION_FACTOR%type;
    v_GRADE_ANNUALIZATION_FACTOR    PER_PAY_BASES.GRADE_ANNUALIZATION_FACTOR%type;
    v_proposed_salary               number;
--changes for bug no 5945278 ends here
  cursor grade_rate_values (l_assignment_id    NUMBER,
                            l_grade_id         NUMBER,
                            l_rate_id          NUMBER,
                            l_change_date      DATE)
  is
     select   gr.minimum
     ,        gr.mid_value
     ,        gr.maximum
--changes for bug no 5945278 starts here
     ,        a.PAY_BASIS_ID
--changes for bug no 5945278 ends here
     from     pay_grade_rules_f       gr
     ,        per_assignments_f       a
     ,        per_pay_proposals       pp
     where    gr.grade_or_spinal_point_id = a.grade_id
     and      pp.change_date between gr.effective_start_date
                             and gr.effective_end_date
     and      pp.change_date between a.effective_start_date
                             and a.effective_end_date
     and      a.assignment_id = pp.assignment_id
     and      pp.assignment_id = l_assignment_id
     and      gr.grade_or_spinal_point_id = l_grade_id
     and      gr.rate_id = l_rate_id
     and      l_change_date between gr.effective_start_date
                            and gr.effective_end_date
     order by gr.effective_start_date desc ;
--changes for bug no 5945278 starts here
         Cursor ANNUALIZATION_FACTOR(l_PAY_BASIS_ID number) is
         select PAY_ANNUALIZATION_FACTOR,GRADE_ANNUALIZATION_FACTOR from PER_PAY_BASES
         where PAY_BASIS_ID = l_PAY_BASIS_ID;
--changes for bug no 5945278 ends here
     ---------------------------------------------------------------------------
     -- This function pro-rates a non-hourly salary based on the normal hours
     -- worked and the standard hours for the organization
     ---------------------------------------------------------------------------
     function std_hours_adjustment(l_salary        NUMBER,
                                   l_normal_hours  NUMBER,
                                   l_working_hours NUMBER,
                                   l_pay_basis     VARCHAR2,
                                   l_rate_basis    VARCHAR2,
--changes for bug no 5945278 starts here
                                   l_GRADE_ANNUALIZATION_FACTOR     number)
--changes for bug no 5945278 ends here
                return NUMBER
     is
         v_adjustment_factor       NUMBER (15,5) ;
         v_adjusted_salary         NUMBER (15,5) ;
     BEGIN
--changes for bug no 5945278 starts here
/*         if ( (l_working_hours is not null) and (l_working_hours <> 0) )  and
            (l_normal_hours is not null) and
            (l_pay_basis <> 'HOURLY') and
            (l_rate_basis <> 'HOURLY') then
             v_adjustment_factor := l_normal_hours/l_working_hours ;*/
         if  (l_pay_basis = 'HOURLY') and
            (l_rate_basis = 'HOURLY') then
--             v_adjustment_factor := l_normal_hours/l_working_hours ;
             v_adjusted_salary   := l_salary  ;
          else
             v_adjusted_salary   := l_salary * l_GRADE_ANNUALIZATION_FACTOR ;
--changes for bug no 5945278 ends here
          end if;
          return (v_adjusted_salary);
    END std_hours_adjustment;

--changes for bug no 5945278 starts here
     function proposed_Sal_adjustment(l_assignment_id NUMBER,
                                      l_change_date   Date,
                                      l_salary        NUMBER,
                                      l_pay_basis     VARCHAR2,
                                      l_rate_basis    VARCHAR2,
                                      l_PAY_ANNUALIZATION_FACTOR     number)
                                       return NUMBER
                                      is
         v_fte_factor       NUMBER (15,5) ;
         v_proposed_salary         NUMBER (15,5) ;
     BEGIN
        v_fte_factor:=PER_SALADMIN_UTILITY.get_fte_factor(l_assignment_id ,l_change_date);
         if  (l_pay_basis = 'HOURLY') and
            (l_rate_basis = 'HOURLY') then
            v_proposed_salary   := l_salary /v_fte_factor;
         else
             v_proposed_salary   := l_salary * l_PAY_ANNUALIZATION_FACTOR/v_fte_factor ;
         end if;
          return (v_proposed_salary);
    END proposed_Sal_adjustment;
--changes for bug no 5945278 ends here
    ----------------------------------------------------------------------------
    -- Function to calculate the period salaries based on the period
    -- salary to be calculated and salary basis of the value being passed
    ----------------------------------------------------------------------------
    function sal_basis_adjustment (l_basis_1         VARCHAR2,
                                   l_basis_2         VARCHAR2,
                                   l_value           NUMBER,
                                   l_normal_hours    NUMBER DEFAULT NULL,
                                   l_frequency       VARCHAR2 DEFAULT NULL,
                                   l_number_per_fiscal_year NUMBER DEFAULT NULL)
                            return number
     is
     --
     v_adjusted_value    NUMBER;
     v_annual            NUMBER;
     v_monthly           NUMBER;
     v_period            NUMBER;
     --
     BEGIN
         if l_basis_1 = l_basis_2 then
             return l_value;
         end if;
         --
         if l_basis_1 = 'ANNUAL' then
             if l_basis_2 = 'MONTHLY' then
                 v_annual :=  12;
             elsif l_basis_2 = 'PERIOD' then
                 v_annual :=  l_number_per_fiscal_year;
             elsif l_basis_2 = 'HOURLY' then
                 if l_frequency = 'D' then
                   v_annual  := 261 * l_normal_hours;
                 elsif l_frequency = 'M' then
                   v_annual := 12 * l_normal_hours;
                 elsif l_frequency = 'W' then
                   v_annual := 52 * l_normal_hours;
                 elsif l_frequency = 'Y' then
                   v_annual := l_normal_hours;
                 end if;
             end if;
             v_adjusted_value := round (l_value * v_annual,2);
         --
         elsif l_basis_1 = 'MONTHLY' then
              if l_basis_2 = 'ANNUAL' then
                v_monthly := 1/12;
              elsif l_basis_2 = 'PERIOD' then
                v_monthly := l_number_per_fiscal_year/12;
              elsif l_basis_2 = 'HOURLY' then
                 if l_frequency = 'D' then
                   v_monthly  := 22.5 * l_normal_hours;
                 elsif l_frequency = 'M' then
                   v_monthly :=  l_normal_hours;
                 elsif l_frequency = 'W' then
                   v_monthly := (52/12) * l_normal_hours;
                 elsif l_frequency = 'Y' then
                   v_monthly := (1/12) * l_normal_hours;
                 end if;
             end if;
             v_adjusted_value := round( l_value * v_monthly, 2);
        --
         elsif l_basis_1 = 'PERIOD' then
              if l_basis_2 = 'ANNUAL' then
                v_period := 1/l_number_per_fiscal_year;
              elsif l_basis_2 = 'PERIOD' then
                v_period := 1;
              elsif l_basis_2 = 'MONTHLY' then
                v_period := (1/l_number_per_fiscal_year) * 12;
              elsif l_basis_2 = 'HOURLY' then
                 if l_frequency = 'D' then
                   v_period  := (261/l_number_per_fiscal_year) * l_normal_hours;
                 elsif l_frequency = 'M' then
                   v_period :=  (12/l_number_per_fiscal_year) * l_normal_hours;
                 elsif l_frequency = 'W' then
                   v_period := (52/l_number_per_fiscal_year) * l_normal_hours;
                 elsif l_frequency = 'Y' then
                   v_period := (1/l_number_per_fiscal_year) * l_normal_hours;
                 end if;
             end if;
             v_adjusted_value := round (l_value * v_period,2);
          end if;
          --
          return v_adjusted_value;
          --
   EXCEPTION
          WHEN ZERO_DIVIDE then
              return NULL;
    --
   END sal_basis_adjustment;

    ----------------------------------------------------------------------------
    -- Function to calculate the comparatio
    ----------------------------------------------------------------------------
    function      comparatio (l_actual_salary   NUMBER,
                              l_mid_value       NUMBER,
                              l_rate_basis      VARCHAR2,
                              l_salary_basis    VARCHAR2,
                              l_normal_hours    NUMBER DEFAULT NULL,
                              l_frequency       VARCHAR2 DEFAULT NULL,
                              l_number_per_fiscal_year  NUMBER DEFAULT NULL
                             )
                    return number
    is
       v_adj_mid_value      NUMBER := l_mid_value ;
       v_adj_actual_salary  NUMBER := l_actual_salary ;
       v_comparatio         NUMBER ;
    BEGIN
       if(l_rate_basis = 'HOURLY') then
          v_adj_mid_value := sal_basis_adjustment(l_salary_basis,
                                                  l_rate_basis,
                                                  l_mid_value,
                                                  l_normal_hours,
                                                  l_frequency,
                                                  l_number_per_fiscal_year );
       else
          v_adj_actual_salary := sal_basis_adjustment(l_rate_basis,
                                                  l_salary_basis,
                                                  l_actual_salary,
                                                  l_normal_hours,
                                                  l_frequency,
                                                  l_number_per_fiscal_year );
       end if;

       v_comparatio := round ( (v_adj_actual_salary/v_adj_mid_value) * 100, 2) ;

       return v_comparatio ;

    EXCEPTION
         WHEN ZERO_DIVIDE then
              return NULL;
    END comparatio;

BEGIN
    --
    -- No Comparatio if the elements are not present
    --
    if p_element_entry_id is null then
       return null;
    end if;

    --
    -- Populate working hours and frequency that is to be used in calculations
    --
    if (p_pos_working_hours is null) then
      if(p_org_working_hours is null) then
        select fnd_number.canonical_to_number(working_hours)
        into   v_working_hours
        from   per_business_groups
        where  business_group_id = p_business_group_id ;
      else
        v_working_hours := p_org_working_hours ;
      end if;
   else
     v_working_hours := p_pos_working_hours ;
   end if;

    if (p_pos_frequency is null) then
      if(p_org_frequency is null) then
        select frequency
        into   v_frequency
        from   per_business_groups
        where  business_group_id = p_business_group_id ;
      else
        v_frequency := p_org_frequency ;
      end if;
   else
     v_frequency := p_pos_frequency ;
   end if;

    --
    -- Get the Grade Rate Values for the particular assignment Grade
    --
    open grade_rate_values ( p_assignment_id,
                             p_grade_id,
                             p_rate_id,
                             p_change_date) ;
--changes for bug no 5945278 starts here
    fetch grade_rate_values into v_minimum, v_mid_value, v_maximum,v_PAY_BASIS_ID ;
--changes for bug no 5945278 ends here
    if grade_rate_values%found then

    open ANNUALIZATION_FACTOR ( v_PAY_BASIS_ID);
    fetch ANNUALIZATION_FACTOR into v_PAY_ANNUALIZATION_FACTOR, v_GRADE_ANNUALIZATION_FACTOR ;
    if ANNUALIZATION_FACTOR%found then
            v_adj_mid     :=  std_hours_adjustment(v_mid_value,
                                                   p_normal_hours,
                                                   v_working_hours,
                                                   p_pay_basis,
                                                   p_rate_basis,
--changes for bug no 5945278 starts here
                                                   v_GRADE_ANNUALIZATION_FACTOR ) ;

     v_proposed_salary:= proposed_Sal_adjustment(p_assignment_id,
                                                 p_change_date ,
                                                 p_actual_salary,
                                                 p_pay_basis ,
                                                 p_rate_basis,
                                                 v_PAY_ANNUALIZATION_FACTOR);
    end if;
    close ANNUALIZATION_FACTOR ;
--changes for bug no 5945278 ends here
    end if;
    close grade_rate_values ;
--changes for bug no 5945278 starts here
/*    return (      comparatio( to_number(p_actual_salary),
                              v_adj_mid,
                              p_rate_basis,
                              p_pay_basis,
                              p_normal_hours,
                              v_frequency,
                              p_number_per_fiscal_year) ) ;
*/

    return round ( (v_proposed_salary/v_adj_mid) * 100, 3);
    EXCEPTION
         WHEN ZERO_DIVIDE then
              return NULL;
--changes for bug no 5945278 ends here
END PER_CALC_COMPARATIO;


-- -------------------------------------------------------------------------
-- --------------------< PER_GET_PARENT_ORG >-------------------------------
-- -------------------------------------------------------------------------
--  View uses the function PER_GET_PARENT_ORG to find out the parent node
--  in the organization hierarchy, given the child organization and its
--  level in the hierarchy. The function traverses the  hierarchy and
--  gets the parent at the given level.

function PER_GET_PARENT_ORG
                      ( p_org_child                  number,
                        p_level                      number,
                        p_business_group_id          number,
                        p_org_structure_version_id   number)
   return number
is
   org_id_parent        number;
BEGIN
  --------------------------------------------------------------
  -- Traverse the hierarchy tree upto the input level starting
  -- from the child organization and return the parent org name
  --------------------------------------------------------------
  select  str.organization_id_parent
  into    org_id_parent
  from    per_org_structure_elements str
  where   level = p_level
  connect by str.organization_id_child = prior str.organization_id_parent
  and     str.org_structure_version_id = p_org_structure_version_id
  and     str.business_group_id        = p_business_group_id
  start with str.organization_id_child = p_org_child
  and     str.org_structure_version_id = p_org_structure_version_id
  and     str.business_group_id        = p_business_group_id ;

  return org_id_parent;

END PER_GET_PARENT_ORG ;

-- -------------------------------------------------------------------------
-- --------------------< PER_GET_EFFECTIVE_END_DATE >-----------------------
-- -------------------------------------------------------------------------
--
-- Function to get the Effective End Date for the Assignment History View
--
function PER_GET_EFFECTIVE_END_DATE
                     ( p_assignment_id     number,
                       p_effective_start_date  date
                     )
                     return date
IS
  CURSOR E_DATE1 is
    select min(EFFECTIVE_START_DATE) - 1
    from   PER_ALL_ASSIGNMENTS_F
    where  ASSIGNMENT_ID = p_assignment_id
    and    EFFECTIVE_START_DATE > p_effective_start_date ;

  CURSOR E_DATE2 is
     select max(EFFECTIVE_END_DATE)
     from   PER_ALL_ASSIGNMENTS_F
     where  ASSIGNMENT_ID = p_assignment_id ;

  d_date   date ;
BEGIN
  open E_DATE1 ;
  fetch E_DATE1 into d_date ;

  if E_DATE1%notfound or E_DATE1%notfound is null or d_date is null then

     open E_DATE2 ;
     fetch E_DATE2 into d_date ;

     if E_DATE2%notfound or E_DATE2%notfound is null then
        close E_DATE1;
        close E_DATE2;
        return (null);
     end if;

     if d_date = hr_general.end_of_time then
         d_date := null;
     end if;

     close E_DATE2;
     return (d_date);
  else
     close E_DATE1 ;
      return (d_date);
  end if;

END PER_GET_EFFECTIVE_END_DATE;


-- -------------------------------------------------------------------------
-- --------------------< PER_GET_ORGANIZATION_EMPLOYEES >-------------------
-- -------------------------------------------------------------------------
function PER_GET_ORGANIZATION_EMPLOYEES
               ( p_organization_id   number
               )
               return number
IS
 l_number_of_emps     number ;
BEGIN

   select count(distinct PERSON_ID)
   into   l_number_of_emps
   from   PER_ASSIGNMENTS_X      ass
   where  ass.ORGANIZATION_ID = p_organization_id
   and    ass.ASSIGNMENT_TYPE = 'E' ;

  return (l_number_of_emps) ;

END PER_GET_ORGANIZATION_EMPLOYEES ;

-- -------------------------------------------------------------------------
-- --------------------< PER_GET_ELEMENT_ACCRUAL >--------------------------
-- -------------------------------------------------------------------------
FUNCTION PER_GET_ELEMENT_ACCRUAL
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_input_value_id       number,
                      P_plan_id              number   DEFAULT NULL,
                      P_plan_category        varchar2 DEFAULT NULL)
         RETURN Number is
--
l_accrual  number := 0;
--
c_date date := P_calculation_date;
n1 number;
n2 number;
n3 number;
d1 date;
d2 date;
d3 date;
d4 date;
d5 date;
d6 date;
d7 date;
p_mod varchar2(1) := 'N';
--
BEGIN
--
   per_views_pkg.per_accrual_calc_detail(
       P_assignment_id      => P_assignment_id,
       P_calculation_date   => c_date,
       P_plan_id            => P_plan_id,
       P_plan_category      => P_plan_category,
       P_accrual            => l_accrual,
       P_payroll_id         => n1,
       P_first_period_start => d1,
       P_first_period_end   => d2,
       P_last_period_start  => d3,
       P_last_period_end    => d4,
       P_cont_service_date  => d5,
       P_start_date         => d6,
       P_end_date           => d7,
       P_current_ceiling    => n2,
       P_current_carry_over => n3);
--
  	select 	nvl(sum(to_number(nvl(pev.SCREEN_ENTRY_VALUE,'0'))), 0)
   	into  	l_accrual
   	from  	pay_element_entry_values_f   pev,
         	pay_element_entries_f        pee
   	where  pev.input_value_id     = p_input_value_id
   	and    pev.element_entry_id   = pee.element_entry_id
   	and    pee.assignment_id      = p_assignment_id
   	and    pee.effective_start_date between d6 and d7 ;
  --
  IF l_accrual is null
  THEN
    l_accrual := 0;
  END IF;
--
  RETURN(l_accrual);
--
END PER_GET_ELEMENT_ACCRUAL;

-- -------------------------------------------------------------------------
-- --------------------< PER_GET_ACCRUAL >----------------------------------
-- -------------------------------------------------------------------------
FUNCTION PER_GET_ACCRUAL
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_plan_id              number   DEFAULT NULL,
                      P_plan_category        varchar2 DEFAULT NULL)
         RETURN Number is
--
l_accrual  number := 0;
--
c_date date := P_calculation_date;
n1 number;
n2 number;
n3 number;
d1 date;
d2 date;
d3 date;
d4 date;
d5 date;
d6 date;
d7 date;
p_mod varchar2(1) := 'N';
--
BEGIN
--
   per_views_pkg.per_accrual_calc_detail(
       P_assignment_id      => P_assignment_id,
       P_calculation_date   => c_date,
       P_plan_id            => P_plan_id,
       P_plan_category      => P_plan_category,
       P_accrual            => l_accrual,
       P_payroll_id         => n1,
       P_first_period_start => d1,
       P_first_period_end   => d2,
       P_last_period_start  => d3,
       P_last_period_end    => d4,
       P_cont_service_date  => d5,
       P_start_date         => d6,
       P_end_date           => d7,
       P_current_ceiling    => n2,
       P_current_carry_over => n3);
--
  IF l_accrual is null
  THEN
    l_accrual := 0;
  END IF;
--
  RETURN(l_accrual);
--
END PER_GET_ACCRUAL;

-- -------------------------------------------------------------------------
-- --------------------< PER_ACCRUAL_CALC_DETAIL >--------------------------
-- -------------------------------------------------------------------------
PROCEDURE PER_ACCRUAL_CALC_DETAIL
              (P_assignment_id          IN    number,
               P_calculation_date    IN OUT NOCOPY   date,
               P_plan_id                IN    number   DEFAULT NULL,
               P_plan_category          IN    varchar2 DEFAULT NULL,
               P_mode                   IN    varchar2 DEFAULT 'N',
               P_accrual                OUT NOCOPY   number,
               P_payroll_id          IN OUT NOCOPY   number,
               P_first_period_start  IN OUT NOCOPY   date,
               P_first_period_end    IN OUT NOCOPY   date,
               P_last_period_start   IN OUT NOCOPY   date,
               P_last_period_end     IN OUT NOCOPY   date,
               P_cont_service_date      OUT NOCOPY   date,
               P_start_date             OUT NOCOPY   date,
               P_end_date               OUT NOCOPY   date,
               P_current_ceiling        OUT NOCOPY   number,
               P_current_carry_over     OUT NOCOPY   number)  IS
-- Get Plan details
CURSOR csr_get_plan_details ( P_business_group Number) is
       select pap.accrual_plan_id,
              pap.accrual_plan_element_type_id,
              pap.accrual_units_of_measure,
              pap.ineligible_period_type,
              pap.ineligible_period_length,
              pap.accrual_start,
              pev.SCREEN_ENTRY_VALUE,
              pee.element_entry_id
       from   pay_accrual_plans            pap,
              pay_element_entry_values_f   pev,
              pay_element_entries_f        pee,
              pay_element_links_f          pel,
              pay_element_types_f          pet,
              pay_input_values_f           piv
       where  ( pap.accrual_plan_id            = p_plan_id     OR
                pap.accrual_category           = P_plan_category )
       and    pap.business_group_id + 0            = P_business_group
       and    pap.accrual_plan_element_type_id = pet.element_type_id
       and    P_calculation_date between pet.effective_start_date and
                                         pet.effective_end_date
       and    pet.element_type_id              = pel.element_type_id
       and    P_calculation_date between pel.effective_start_date and
                                         pel.effective_end_date
       and    pel.element_link_id              = pee.element_link_id
       and    pee.assignment_id                = P_assignment_id
       and    P_calculation_date between pee.effective_start_date and
                                         pee.effective_end_date
       and    piv.element_type_id              =
                                         pap.accrual_plan_element_type_id
       and    piv.name                         = 'Continuous Service Date'
       and    P_calculation_date between piv.effective_start_date and
                                         piv.effective_end_date
       and    pev.element_entry_id             = pee.element_entry_id
       and    pev.input_value_id + 0           = piv.input_value_id
       and    P_calculation_date between pev.effective_start_date and
                                         pev.effective_end_date;
--
--
l_asg_eff_start_date date   := null;
l_asg_eff_end_date   date   := null;
l_business_group_id  number := null;
l_service_start_date date   := null;
l_termination_date   date   := null;
--
l_calc_period_num    number := 0;
l_calc_start_date    date   := null;
l_calc_end_date      date   := null;
--
l_number_of_period   number := 0;
--
l_acc_plan_type_id   number := 0;
l_acc_plan_ele_type  number := 0;
l_acc_uom            varchar2(30) := null;
l_inelig_period      varchar2(30) := null;
l_inelig_p_length    number := 0;
l_accrual_start      varchar2(30) := null;
l_cont_service_date  date := null;
l_csd_screen_value   varchar2(30) := null;
l_element_entry_id   number := 0;
--
l_plan_start_date    date   := null;
--
l_total_accrual      number := 0;
l_plan_accrual       number := 0;
--
l_temp               varchar2(30) := null;
l_temp_date          date         := null;
--
p_param_first_pstdt  date   := null;
p_param_first_pendt  date   := null;
p_param_first_pnum   number := 0;
p_param_acc_calc_edt date   := null;
p_param_acc_calc_pno number := 0;
--
-- Main process
--
BEGIN
--
  P_payroll_id         := 0;
  P_first_period_start := null;
  P_first_period_end   := null;
  P_last_period_start  := null;
  P_last_period_end    := null;
--
---
--- If both param null. RETURN
--
  IF P_plan_id is null AND P_plan_category is null
  THEN
    return ;
  END IF;
  OPEN  csr_get_payroll(P_assignment_id, P_calculation_date);
  FETCH csr_get_payroll INTO P_payroll_id,
                             l_asg_eff_start_date,
                             l_asg_eff_end_date,
                             l_business_group_id,
                             l_service_start_date,
                             l_termination_date;
  IF csr_get_payroll%NOTFOUND
  THEN
    CLOSE csr_get_payroll;
    return ;
  END IF;
  CLOSE csr_get_payroll;
--
-- Get start and end date for the Calculation date
--
  OPEN  csr_get_period(P_payroll_id, P_calculation_date);
  FETCH csr_get_period INTO l_calc_period_num,
                            l_calc_start_date,
                            l_calc_end_date;
  IF csr_get_period%NOTFOUND
  THEN
    CLOSE csr_get_period;
    return ;
  END IF;
  CLOSE csr_get_period;
--
-- Partial first period if start
--
-- Set return dates for the net process if nothing to accrue in this period
--
      P_start_date := l_calc_start_date;
      P_end_date   := P_calculation_date;
--
--
-- Get total number of periods for the year of calculation
--
  OPEN  csr_get_total_periods(P_payroll_id, l_calc_end_date);
  FETCH csr_get_total_periods INTO P_first_period_start,
                                   P_first_period_end,
                                   P_last_period_start,
                                   P_last_period_end,
                                   l_number_of_period;
  IF csr_get_total_periods%NOTFOUND
  THEN
    CLOSE csr_get_total_periods;
    return ;
  END IF;
  CLOSE csr_get_total_periods;
  -- Set l_number_of_period such that it is based on NUMBER_PER_FISCAL_YEAR
  -- for period type of payroll.  Ie. The number returned from
  -- csr_get_total_periods is the number of periods defined for this payroll
  -- in the given calendar year - so payrolls defined mid-year accrue at a
  -- different rate than if it had a full year of payroll periods.
  --
  SELECT number_per_fiscal_year
  INTO   l_number_of_period
  FROM   per_time_period_types TPT,
         pay_payrolls_f PPF
  WHERE  TPT.period_type = PPF.period_type
  AND    PPF.payroll_id = P_payroll_id
  AND    l_calc_end_date BETWEEN PPF.effective_start_date
			     AND PPF.effective_end_date;
  --
  --
  -- In case of carry over a dummy date of 31-JUL-YYYY is passed in order to get

  OPEN  csr_get_period (P_payroll_id, P_first_period_start);
  FETCH csr_get_period INTO p_param_first_pnum,
                            p_param_first_pstdt,
                            p_param_first_pendt;
  IF csr_get_period%NOTFOUND
  THEN
     CLOSE csr_get_period;
     return ;
  END IF;
  CLOSE csr_get_period;
  --
  --  Check termination date and adjust end date of the last calc Period
  --
  OPEN  csr_get_period (P_payroll_id,
                        nvl(l_termination_date,P_calculation_date));
  FETCH csr_get_period INTO p_param_acc_calc_pno,
                            l_temp_date,
                            p_param_acc_calc_edt;
  IF csr_get_period%NOTFOUND
  THEN
	CLOSE csr_get_period;
        return ;
  END IF;
  CLOSE csr_get_period;
--
--
-- No accruals for the partial periods
--
  IF nvl(l_termination_date,P_calculation_date) < p_param_acc_calc_edt
  THEN
     p_param_acc_calc_pno := p_param_acc_calc_pno - 1;
     p_param_acc_calc_edt := l_temp_date - 1;
  END IF;
--
-- Open plan cursor and check at least one plan should be there
--
  OPEN  csr_get_plan_details(l_business_group_id);
  FETCH csr_get_plan_details INTO l_acc_plan_type_id,
                                  l_acc_plan_ele_type,
                                  l_acc_uom,
                                  l_inelig_period,
                                  l_inelig_p_length,
                                  l_accrual_start,
                                  l_csd_screen_value,
                                  l_element_entry_id;
  IF csr_get_plan_details%NOTFOUND
  THEN
    CLOSE csr_get_plan_details;
    return ;
  END IF;
--
-- Loop thru all the plans and call function to calc. accruals for a plan
--
  LOOP
    l_temp_date := null;
    --
    --
    --	"Continous Service Date" is ALWAYS determined by:
    --	1. "Continuous Service Date" entry value on accrual plan.
    --	2. Hire Date of current period of service (ie. in absence of 1.)
    --
    IF l_csd_screen_value is null
    THEN
       l_cont_service_date := l_service_start_date;
    ELSE
       --
       -- Fix for WWBUG 1717601.
       -- Changed below line to use canonical_to_date rather than DD_MON-YYYY
       -- format mask.
       --
       l_cont_service_date := fnd_date.canonical_to_date(l_csd_screen_value);
    END IF;
    --
    -- The "p_param_first..." variables determine when accrual begins for this
    -- plan and assignment.  Accrual begins according to "Accrual Start Rule" and
    -- hire date as follows:
    -- Accrual Start Rule	Begin Accrual on...
    -- ==================	==================================================
    -- Beginning of Year	First period of new calendar year FOLLOWING hire date.
    -- Hire Date		First period following hire date
    -- 6 Months After Hire	First period following 6 month anniversary of hire date.
    -- NOTE: "Hire Date" is the "Continuous Service Date" as determined above.
    --
      IF l_accrual_start = 'BOY'
      THEN
          l_temp_date := TRUNC(ADD_MONTHS(l_cont_service_date,12),'YEAR');
          OPEN  csr_get_period (P_payroll_id, l_temp_date);
          FETCH csr_get_period INTO p_param_first_pnum,
                                    p_param_first_pstdt,
                                    p_param_first_pendt;
          IF csr_get_period%NOTFOUND
          THEN
             CLOSE csr_get_period;
             return ;
          END IF;
          CLOSE csr_get_period;
          l_temp_date := null;
      ELSIF l_accrual_start = 'HD'
      THEN
        NULL;
          -- p_param_first... vars have been set above (location get_accrual.30)

      ELSIF l_accrual_start = 'PLUS_SIX_MONTHS'
      THEN
	  --
	  -- Actually get the period in force the day before the six months is up.
	  -- This is because we subsequently get the following period as the one
	  -- in which accruals should start. If a period starts on the six
	  -- month anniversary, the asg should qualify from that period, and
	  -- not have to wait for the next one. Example:
	  --
	  -- Assume monthly periods.
	  --
	  -- l_cont_service_date = 02-Jan-95
	  -- six month anniversary = 02-Jul-95
	  -- accruals start on 01-Aug-95
	  --
	  -- l_cont_service_date = 01-Jan-95
	  -- six month anniversary = 01-Jul-95
	  -- accruals should start on 01-Jul-95, not 01-Aug-95
	  --
	  --
          OPEN  csr_get_period (P_payroll_id,
		  	        ADD_MONTHS(l_cont_service_date,6) -1 );
          FETCH csr_get_period INTO p_param_first_pnum,
                                    p_param_first_pstdt,
				    l_temp_date;
          IF csr_get_period%NOTFOUND
          THEN
             CLOSE csr_get_period;
             return ;
          END IF;
          CLOSE csr_get_period;
          --
          OPEN  csr_get_period (P_payroll_id, l_temp_date + 1);
          FETCH csr_get_period INTO p_param_first_pnum,
                                    p_param_first_pstdt,
                                    p_param_first_pendt;
          IF csr_get_period%NOTFOUND
          THEN
             CLOSE csr_get_period;
             return ;
          END IF;
          CLOSE csr_get_period;
          l_temp_date := null;
      END IF;
--
--    Add period of ineligibility
--
      IF l_accrual_start   <> 'PLUS_SIX_MONTHS'  AND
         l_inelig_p_length >  0
      THEN
        IF l_inelig_period = 'BM'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    (l_inelig_p_length * 2));
        ELSIF l_inelig_period = 'F'
        THEN
          l_temp_date := to_date((l_cont_service_date +
                                -- (l_inelig_p_length * 14)),'YYYY/MM/DD HH24:MI:SS');
				   (l_inelig_p_length * 14)));  -- bug 6706398

        ELSIF l_inelig_period = 'CM'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    l_inelig_p_length);
        ELSIF l_inelig_period = 'LM'
        THEN
          l_temp_date := to_date((l_cont_service_date +
                           -- ( l_inelig_p_length * 28)),'YYYY/MM/DD HH24:MI:SS');
			      ( l_inelig_p_length * 28))); -- bug 6706398

        ELSIF l_inelig_period = 'Q'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    (l_inelig_p_length * 3));
        ELSIF l_inelig_period = 'SM'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                   (l_inelig_p_length/2));
        ELSIF l_inelig_period = 'SY'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    (l_inelig_p_length * 6));
        ELSIF l_inelig_period = 'W'
        THEN
          l_temp_date := to_date((l_cont_service_date +
                          -- (l_inelig_p_length * 7)),'YYYY/MM/DD HH24:MI:SS');
			     ( l_inelig_p_length * 28))); -- bug 6706398

        ELSIF l_inelig_period = 'Y'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    (l_inelig_p_length * 12));
        END IF;
      END IF;
--
-- Determine start and end date and setup return parmas.
--    check Period of Service start date, plan element entry start date
--    if later then first period start. Accrual period start date accordingly.
--
      select min(effective_start_date)
      into   l_plan_start_date
      from   pay_element_entries_f
      where  element_entry_id = l_element_entry_id;
---
--- Set the return params
--
      P_cont_service_date := l_cont_service_date;
      P_start_date := GREATEST(l_service_start_date,l_cont_service_date,
                              l_plan_start_date,P_first_period_start);
      P_end_date   := LEAST(NVL(L_termination_date,P_calculation_date)
                             ,P_calculation_date);
--
    IF ( l_temp_date is not null AND
         l_temp_date >= p_param_acc_calc_edt ) OR
       l_cont_service_date >= p_param_acc_calc_edt OR
       p_param_first_pstdt >= p_param_acc_calc_edt
    THEN
      l_plan_accrual := 0;
    ELSE
      --
      -- Set the Start Date appropriately.
      --
      l_temp_date := GREATEST(l_service_start_date,l_cont_service_date,
                              l_plan_start_date);
      --
      IF  l_temp_date > P_first_period_start
          AND l_temp_date > nvl(p_param_first_pstdt, l_temp_date - 1)
      THEN
           OPEN  csr_get_period (P_payroll_id, l_temp_date);
           FETCH csr_get_period INTO p_param_first_pnum,
                                     p_param_first_pstdt,
                                     p_param_first_pendt;
           IF csr_get_period%NOTFOUND
           THEN
	      CLOSE csr_get_period;
              return ;
           END IF;
           CLOSE csr_get_period;
      --
      -- No Accruals fro the partial periods. First period to start the
      -- accrual will be next one.
      --
           IF l_temp_date > p_param_first_pstdt
           THEN
              p_param_first_pendt := p_param_first_pendt +1;
              OPEN  csr_get_period (P_payroll_id, p_param_first_pendt);
              FETCH csr_get_period INTO p_param_first_pnum,
                                         p_param_first_pstdt,
                                         p_param_first_pendt;
              IF csr_get_period%NOTFOUND
              THEN
	         CLOSE csr_get_period;
                 return ;
              END IF;
              CLOSE csr_get_period;
           END IF;
      END IF;
      --
      --      Call Function to Calculate accruals for a plan
      --
      IF p_param_acc_calc_edt < P_first_period_end
      THEN
        l_plan_accrual := 0;
      ELSE
      --
        per_views_pkg.per_get_accrual_for_plan
                  ( p_plan_id                 => l_acc_plan_type_id,
                    p_first_p_start_date      => p_param_first_pstdt,
                    p_first_p_end_date        => p_param_first_pendt,
                    p_first_calc_P_number     => p_param_first_pnum,
                    p_accrual_calc_p_end_date => p_param_acc_calc_edt,
                    P_accrual_calc_P_number   => p_param_acc_calc_pno,
                    P_number_of_periods       => l_number_of_period,
                    P_payroll_id              => P_payroll_id,
                    P_assignment_id           => P_assignment_id,
                    P_plan_ele_type_id        => l_acc_plan_ele_type,
                    P_continuous_service_date => l_cont_service_date,
                    P_Plan_accrual            => l_plan_accrual,
                    P_current_ceiling         => P_current_ceiling,
                    P_current_carry_over      => P_current_carry_over);
      END IF;
      --
    END IF;
--
--    Add accrual to the total and Fetch next set of plan
--
    l_total_accrual := l_total_accrual + l_plan_accrual;
    l_plan_accrual  := 0;
    FETCH csr_get_plan_details INTO l_acc_plan_type_id,
                                    l_acc_plan_ele_type,
                                    l_acc_uom,
                                    l_inelig_period,
                                    l_inelig_p_length,
                                    l_accrual_start,
                                    l_csd_screen_value,
                                    l_element_entry_id;
--
    EXIT WHEN csr_get_plan_details%NOTFOUND;
--
  END LOOP;
--
  CLOSE csr_get_plan_details;
--
  IF l_total_accrual is null
  THEN
     l_total_accrual := 0;
  END IF;
  l_total_accrual := round(l_total_accrual,3);
  P_accrual := l_total_accrual;
--
-- Partial first period if end
--
--
END PER_ACCRUAL_CALC_DETAIL;

-- -------------------------------------------------------------------------
-- --------------------< PER_GET_ACCRUAL_FOR_PLAN >-------------------------
-- -------------------------------------------------------------------------
PROCEDURE PER_GET_ACCRUAL_FOR_PLAN
                    ( p_plan_id                 Number,
                      p_first_p_start_date      date,
                      p_first_p_end_date        date,
                      p_first_calc_P_number     number,
                      p_accrual_calc_p_end_date date,
                      P_accrual_calc_P_number   number,
                      P_number_of_periods       number,
                      P_payroll_id              number,
                      P_assignment_id           number,
                      P_plan_ele_type_id        number,
                      P_continuous_service_date date,
                      P_Plan_accrual            OUT NOCOPY number,
                      P_current_ceiling         OUT NOCOPY number,
                      P_current_carry_over      OUT NOCOPY number) IS
--
--
CURSOR csr_all_asg_status is
       select a.effective_start_date,
              a.effective_end_date,
              b.PER_SYSTEM_STATUS
       from   per_assignments_f           a,
              per_assignment_status_types b
       where  a.assignment_id       = P_assignment_id
       and    a.effective_end_date between p_first_p_start_date and
                                   hr_general.end_of_time
       and    a.ASSIGNMENT_STATUS_TYPE_ID =
                                      b.ASSIGNMENT_STATUS_TYPE_ID;
--
--
CURSOR csr_get_bands (P_time_worked number ) is
       select annual_rate,
              ceiling,
              lower_limit,
              upper_limit,
              max_carry_over
       from   pay_accrual_bands
       where  accrual_plan_id     = P_plan_id
       and    P_time_worked      >= lower_limit
       and    P_time_worked      <  upper_limit;
--
--
/* Fix for bug 6706398 starts here
CURSOR csr_get_time_periods is
       select start_date,
              end_date,
              period_num
       from   per_time_periods
       where  to_char(end_date,'YYYY/MM/DD') =
                         to_char(p_accrual_calc_p_end_date,'YYYY/MM/DD')
       and    end_date                 <= p_accrual_calc_p_end_date
       and    period_num               >=
		decode (to_char(p_first_p_start_date,'YYYY/MM/DD'),
			to_char(p_accrual_calc_p_end_date,'YYYY/MM/DD'),
			p_first_calc_P_number, 1)
       and    payroll_id                 = p_payroll_id
ORDER by period_num;      */

CURSOR csr_get_time_periods is
       select start_date,
              end_date,
              period_num
       from   per_time_periods
       where  to_char(end_date,'YYYY') =
                         to_char(p_accrual_calc_p_end_date,'YYYY')
       and    end_date                 <= p_accrual_calc_p_end_date
       and    period_num               >=
		decode (to_char(p_first_p_start_date,'YYYY'),
			to_char(p_accrual_calc_p_end_date,'YYYY'),
			p_first_calc_P_number, 1)
       and    payroll_id                 = p_payroll_id

ORDER by period_num;

/*Fix for bug 6706398 ends here*/

--
--Local varaiables
l_start_Date         date :=null;
l_end_date           date :=null;
l_period_num         number := 0;
l_asg_eff_start_date date := null;
l_asg_eff_end_date   date := null;
l_asg_status         varchar2(30) := null;
l_acc_rate_pp_1      number := 0;
l_acc_rate_pp_2      number := 0;
l_acc_deds           number := 0;
l_annual_rate        number := 0;
l_ceiling_1          number := 0;
l_ceiling_2          number := 0;
l_carry_over_1       number := 0;
l_carry_over_2       number := 0;
l_lower_limit        number := 0;
l_upper_limit        number := 0;
l_year_1             number := 0;
l_year_2             number := 0;
l_accrual            number := 0;
l_temp               number := 0;
l_temp2              varchar2(30) := null;
l_band_change_date   date   := null;
l_ceiling_flag       varchar2(1) := 'N';
l_curr_p_stdt        date   := null;
l_curr_p_endt        date   := null;
l_curr_p_num         number := 0;
l_mult_factor        number := 0;
l_unpaid_day         number := 0;
l_vac_taken          number := 0;
l_prev_end_date      date   := null;
l_running_total      number := 0;
l_curr_p_acc         number := 0;
l_working_day        number := 0;
l_curr_ceiling       number := 0;
--
--
BEGIN
--
  l_year_1 := TRUNC(ABS(months_between(P_continuous_service_date,
                             P_first_p_end_date)/12));
  l_year_2 := TRUNC(ABS(months_between(P_continuous_service_date,
                             p_accrual_calc_p_end_date)/12));
--
-- Get the band details using the years of service.
--
  OPEN  csr_get_bands (l_year_1);
  FETCH csr_get_bands INTO l_annual_rate,l_ceiling_1,
                           l_lower_limit,l_upper_limit,
                           l_carry_over_1;
  IF csr_get_bands%NOTFOUND THEN
     l_acc_rate_pp_1 := 0;
  ELSE
     l_acc_rate_pp_1 := l_annual_rate/P_number_of_periods;
     IF l_ceiling_1 is not null THEN
        l_ceiling_flag := 'Y';
     END IF;
  END IF;
  CLOSE csr_get_bands;
  --
  IF l_year_2 < l_upper_limit and l_acc_rate_pp_1 > 0 THEN
     l_acc_rate_pp_2 := 0;
  ELSE
     OPEN  csr_get_bands (l_year_2);
     FETCH csr_get_bands INTO l_annual_rate,l_ceiling_2,
                              l_lower_limit,l_upper_limit,
                              l_carry_over_2;
     IF csr_get_bands%NOTFOUND THEN
        CLOSE csr_get_bands;
        l_accrual := 0;
        P_current_ceiling    := 0;
        P_current_carry_over := 0;
        --
        -- Fix for WWBUG 1717601.
        -- Removed duplicate close cursor.
        --
        GOTO exit_out;
     ELSE
        l_acc_rate_pp_2 := l_annual_rate/P_number_of_periods;
        IF l_ceiling_1 is not null THEN
           l_ceiling_flag := 'Y';
        END IF;
        CLOSE csr_get_bands;
     END IF;
  END IF;
--
--
  IF ((l_acc_rate_pp_1 <> l_acc_rate_pp_2) AND
       l_acc_rate_pp_2 <> 0 ) THEN
     l_temp := trunc(ABS(months_between(P_continuous_service_date,
                             p_accrual_calc_p_end_date))/12) * 12 ;
     l_band_change_date := ADD_MONTHS(P_continuous_service_date,l_temp);
  ELSE
     l_band_change_date := (p_accrual_calc_p_end_date + 2);
  END IF;
  --
  -- Set output params.
  --
  IF l_ceiling_2 = 0 OR l_ceiling_2 is null
  THEN
     P_current_ceiling := l_ceiling_1;
  ELSE
     P_current_ceiling := l_ceiling_2;
  END IF;
  --
  IF l_carry_over_2 = 0 OR l_carry_over_2 is null
  THEN
     P_current_carry_over := l_carry_over_1;
  ELSE
     P_current_carry_over := l_carry_over_2;
  END IF;
  --
  OPEN  csr_all_asg_status;
  FETCH csr_all_asg_status into l_asg_eff_start_date,
                                l_asg_eff_end_date,
                                l_asg_status;
  --
  -- Check if calc method should use ceiling calculation or Non-ceiling
  -- calculation. For simplicity if there is any asg. status change then
  -- ceiling calculation method is used.
  --
  IF l_ceiling_flag = 'N'
     and  (p_first_p_end_date   	>= l_asg_eff_start_date
     and   p_accrual_calc_p_end_date    <= l_asg_eff_end_date
     and   l_asg_status                  =  'ACTIVE_ASSIGN') THEN
    --
    -- Non Ceiling Calc
    --
    OPEN  csr_get_period(P_Payroll_id, l_band_change_date);
    FETCH csr_get_period INTO l_curr_p_num,l_curr_p_stdt,l_curr_p_endt;
    IF csr_get_period%NOTFOUND THEN
      CLOSE csr_get_period;
      return ;
    END IF;
    CLOSE csr_get_period;
--
--
    --
    if l_curr_p_num = 1 AND
      p_accrual_calc_p_end_date < l_band_change_date
    then
      l_curr_p_num := P_number_of_periods;
    elsif p_accrual_calc_p_end_date >= l_band_change_date  then
      l_curr_p_num := l_curr_p_num - 1;
    else
      l_curr_p_num := P_accrual_calc_P_number;
    end if;
    --
    -- Entitlement from first period to Band change date.
    --
    l_accrual := l_acc_rate_pp_1 * (l_curr_p_num - (p_first_calc_P_number - 1));

    --
    -- Entitlement from Band change date to Calc. date
    --
    IF p_accrual_calc_p_end_date >= l_band_change_date  THEN
      l_accrual := l_accrual + l_acc_rate_pp_2 * (P_accrual_calc_P_number - l_curr_p_num);

    END IF;
 ELSE
   --
   -- Ceiling Calc
   --
   OPEN  csr_get_time_periods;
   l_running_total := 0;
   l_curr_p_acc    := 0;
   LOOP
     FETCH csr_get_time_periods into l_start_Date,
                                       	l_end_date,
                                       	l_period_num;
     EXIT WHEN csr_get_time_periods%NOTFOUND;
     IF l_period_num > P_accrual_calc_P_number then
       EXIT;
     END IF;
  	--
  	--      Check for Any assignment status change in the current period
  	--
        	l_mult_factor   := 1;
        	l_working_day   := 0;
        	l_unpaid_day    := 0;
        	l_vac_taken     := 0;
        	l_prev_end_date := l_asg_eff_end_date;
        	--
        	IF l_asg_eff_end_date between l_start_Date and l_end_date
        	THEN
          	  IF l_asg_status <> 'ACTIVE_ASSIGN' THEN
             	  l_unpaid_day := per_views_pkg.per_get_working_days(l_start_Date,
                                              l_asg_eff_end_date);
            	END IF;
          	--
          	--
          	LOOP
            		l_prev_end_date := l_asg_eff_end_date;
            		FETCH csr_all_asg_status into 	l_asg_eff_start_date,
                                         		l_asg_eff_end_date,
                                          		l_asg_status;
            		IF csr_all_asg_status%NOTFOUND THEN
               		  CLOSE csr_all_asg_status;
               		  EXIT;
            		ELSIF l_asg_status <> 'ACTIVE_ASSIGN'  and
                  	  l_asg_eff_start_date <= l_end_date
            		THEN
               		  l_unpaid_day := l_unpaid_day +
                          per_views_pkg.per_get_working_days(l_asg_eff_start_date,
                          least(l_end_date,l_asg_eff_end_date));
            		END IF;
            	EXIT WHEN l_asg_eff_end_date > l_end_date;
          	END LOOP;
           	--
           	--
 ELSIF csr_all_asg_status%ISOPEN and l_asg_status <> 'ACTIVE_ASSIGN'   THEN
   l_mult_factor   := 0;
 ELSIF NOT (csr_all_asg_status%ISOPEN ) THEN
    l_mult_factor   := 0;
 ELSE
    l_mult_factor   := 1;
 END IF;
 --
 --
 IF l_unpaid_day <> 0 THEN
    l_working_day := per_views_pkg.per_get_working_days(l_start_Date,l_end_date);
    IF l_working_day = l_unpaid_day THEN
       l_mult_factor := 0;
    ELSE
       l_mult_factor := (1 - (l_unpaid_day/l_working_day));
    END IF;
 END IF;
--
-- Find out vacation and carry over if the method is ceiling
--
 IF l_ceiling_flag = 'Y' THEN
    OPEN  csr_calc_accrual(l_start_Date,    l_end_date,
                           P_assignment_id, P_plan_id);
    FETCH csr_calc_accrual INTO l_vac_taken;
    IF csr_calc_accrual%NOTFOUND  or l_vac_taken is null THEN
           l_vac_taken := 0;
    END IF;
           CLOSE csr_calc_accrual;
 END IF;
 --
 --  Multiply the Accrual rate for the current band and  Multiplication
 --  Factor to get current period accrual.
 --
  IF (l_band_change_date between l_start_Date and l_end_date)
      OR ( l_band_change_date < l_end_date)
  THEN
     l_curr_p_acc   := l_acc_rate_pp_2 * l_mult_factor;
     l_curr_ceiling := l_ceiling_2;
  ELSE
     l_curr_p_acc   := l_acc_rate_pp_1 * l_mult_factor;
     l_curr_ceiling := l_ceiling_1;
  END IF;
  --
  --
  --   Check for ceiling limits
  --
  IF l_ceiling_flag = 'Y' THEN
     l_running_total := l_running_total + l_vac_taken + l_curr_p_acc;
     IF l_running_total > l_curr_ceiling THEN
        IF (l_running_total - l_curr_ceiling) < l_curr_p_acc
           THEN
              l_temp    := (l_curr_p_acc -
                           (l_running_total - l_curr_ceiling));
              l_accrual := l_accrual + l_temp;
              l_running_total := l_running_total + l_temp;
         END IF;
              l_running_total := l_running_total - l_curr_p_acc;
         ELSE
              l_accrual := l_accrual + l_curr_p_acc;
         END IF;
     ELSE
       l_accrual := l_accrual + l_curr_p_acc;
     END IF;
     --
     --
   END LOOP;
   --
   CLOSE csr_get_time_periods;
  --
  END IF;
--
--
IF l_accrual is null THEN
   l_accrual := 0;
END IF;
--
<<exit_out>>
P_Plan_accrual := l_accrual;
--
--
END PER_GET_ACCRUAL_FOR_PLAN;

-- -------------------------------------------------------------------------
-- --------------------< PER_GET_WORKING_DAYS >-----------------------------
-- -------------------------------------------------------------------------
FUNCTION PER_GET_WORKING_DAYS
                    (P_start_date date,
                     P_end_date   date )
         RETURN   NUMBER is
l_total_days    NUMBER        := 0;
l_curr_date     DATE          := NULL;
l_curr_day      VARCHAR2(3)   := NULL;
--
BEGIN
--
-- Check for valid range
IF p_start_date > P_end_date THEN
  RETURN l_total_days;
END IF;
--
l_curr_date := P_start_date;
LOOP
  -- l_curr_day := TO_CHAR(l_curr_date,'YYYY/MM/DD'); -- bug6706398
    l_curr_day := TO_CHAR(l_curr_date,'DY'); -- bug 6706398


  IF UPPER(l_curr_day) in ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
    l_total_days := l_total_days + 1;
  END IF;
  l_curr_date := l_curr_date + 1;
  EXIT WHEN l_curr_date > P_end_date;
END LOOP;
--
RETURN l_total_days;
--
END PER_GET_WORKING_DAYS;

-- -------------------------------------------------------------------------
-- --------------------< PER_GET_NET_ACCRUAL >------------------------------
-- -------------------------------------------------------------------------
FUNCTION PER_GET_NET_ACCRUAL
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_plan_id              number   default null,
                      P_plan_category        Varchar2 default null)
         RETURN NUMBER is
--
--
-- Function calls the actual proc. which will calc. net accrual and pass back
-- the details.In formula we will call functions so this will be the cover
-- function to call the proc.
--
l_accrual  number := 0;
--
c_date date := P_calculation_date;
n1 number;
n2 number;
n3 number;
n4 number;
d1 date;
d2 date;
d3 date;
d4 date;
d5 date;
d6 date;
d7 date;
--
BEGIN
--
   per_views_pkg.per_net_accruals(
       P_assignment_id      => P_assignment_id,
       P_calculation_date   => c_date,
       P_plan_id            => P_plan_id,
       P_plan_category      => P_plan_category,
       P_mode               => 'N',
       P_accrual            => n4,
       P_net_accrual        => l_accrual,
       P_payroll_id         => n1,
       P_first_period_start => d1,
       P_first_period_end   => d2,
       P_last_period_start  => d3,
       P_last_period_end    => d4,
       P_cont_service_date  => d5,
       P_start_date         => d6,
       P_end_date           => d7,
       P_current_ceiling    => n2,
       P_current_carry_over => n3);
--
  IF l_accrual is null
  THEN
    l_accrual := 0;
  END IF;
--
  RETURN(l_accrual);
--
END PER_GET_NET_ACCRUAL;

-- -------------------------------------------------------------------------
-- --------------------< PER_NET_ACCRUALS >---------------------------------
-- -------------------------------------------------------------------------
PROCEDURE PER_NET_ACCRUALS
              (P_assignment_id          IN    number,
               P_calculation_date    IN OUT NOCOPY   date,
               P_plan_id                IN    number   DEFAULT NULL,
               P_plan_category          IN    varchar2 DEFAULT NULL,
               P_mode                   IN    varchar2 DEFAULT 'N',
               P_accrual             IN OUT NOCOPY   number,
               P_net_accrual            OUT NOCOPY   number,
               P_payroll_id          IN OUT NOCOPY   number,
               P_first_period_start  IN OUT NOCOPY   date,
               P_first_period_end    IN OUT NOCOPY   date,
               P_last_period_start   IN OUT NOCOPY   date,
               P_last_period_end     IN OUT NOCOPY   date,
               P_cont_service_date      OUT NOCOPY   date,
               P_start_date          IN OUT NOCOPY   date,
               P_end_date            IN OUT NOCOPY   date,
               P_current_ceiling        OUT NOCOPY   number,
               P_current_carry_over     OUT NOCOPY   number)  IS
--
--
l_taken              number := 0;
l_temp               number := 0;
--
BEGIN
--
-- Get vaction accrued
--
  per_views_pkg.per_accrual_calc_detail(
       P_assignment_id      => P_assignment_id,
       P_calculation_date   => P_calculation_date,
       P_plan_id            => P_plan_id,
       P_plan_category      => P_plan_category,
       P_mode               => P_mode,
       P_accrual            => P_accrual,
       P_payroll_id         => P_payroll_id,
       P_first_period_start => P_first_period_start,
       P_first_period_end   => P_first_period_end,
       P_last_period_start  => P_last_period_start,
       P_last_period_end    => P_last_period_end,
       P_cont_service_date  => P_cont_service_date,
       P_start_date         => P_start_date,
       P_end_date           => P_end_date,
       P_current_ceiling    => P_current_ceiling,
       P_current_carry_over => P_current_carry_over);
--
-- Get vac taken purchase etc using net Calc rules.
--
   OPEN  csr_calc_accrual(P_start_Date,    P_end_date,
                          P_assignment_id, P_plan_id);
   FETCH csr_calc_accrual INTO l_taken;
   IF csr_calc_accrual%NOTFOUND  or
      l_taken is null
   THEN
      l_taken := 0;
   END IF;
   CLOSE csr_calc_accrual;
--
--
   P_net_accrual := ROUND((P_accrual + l_taken),3);
--
-- if mode is carry over then return next years first period start
-- and end dates in P_start_date nad P_end_date params.
--
   IF P_mode = 'C'
   THEN
     OPEN csr_get_period(p_payroll_id,(P_last_period_end +1));
     FETCH csr_get_period into l_temp,P_start_date,P_end_date;
     IF csr_get_period%NOTFOUND THEN
       CLOSE csr_get_period;
       return ;
     END IF;
     CLOSE csr_get_period;
   END IF;
--
--
END PER_NET_ACCRUALS;

END PER_VIEWS_PKG ;

/
