--------------------------------------------------------
--  DDL for Package Body BEN_EXT_PAYROLL_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_PAYROLL_BALANCE" as
/* $Header: benxpybl.pkb 120.4.12010000.2 2008/08/05 14:59:29 ubhat ship $ */
--
--
function Get_us_Balance_Value
        (p_business_group_id  in number
        ,p_assignment_id      in number
        ,p_effective_date     in date
        ,p_legislation_code   in varchar2
        ,p_defined_balance_id in number) return number as

  cursor c_tax_id (c_assignment_id  in number
                  ,c_effective_date in date) is
  select to_number(sft.segment1)
    from hr_soft_coding_keyflex sft,
         per_assignments_f      asg
   where sft.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
     and asg.assignment_id          = c_assignment_id
     and c_effective_date between asg.effective_start_date
                              and asg.effective_end_date;

  cursor c_jur_code(c_assignment_id     in number
                   ,c_business_group_id in number
                   ,c_effective_date    in date) is
  select str.jurisdiction_code
    from pay_us_emp_state_tax_rules_f str
   where c_effective_date between str.effective_start_date
                              and str.effective_end_date
     and    str.assignment_id     = c_assignment_id
     and str.business_group_id = c_business_group_id;


  cursor c_fr_tax_id (c_assignment_id     in number
                   ,c_effective_date    in date) is
  select asg.ESTABLISHMENT_ID
    from per_all_assignments_f asg
   where asg.assignment_id = c_assignment_id
     and c_effective_date between asg.effective_start_date
                              and asg.effective_end_date
  ;

  -- check the dimension has tax_unit_id context
  cursor c_tax_context is
  select pbd.DIMENSION_NAME
  from ff_contexts ffc
      ,ff_route_context_usages frc
      ,pay_defined_balances pdb
      ,pay_balance_dimensions pbd
 where pdb.defined_balance_id = p_defined_balance_id
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pbd.route_id = frc.route_id
   and frc.context_id = ffc.context_id
   and ffc.context_name = 'TAX_UNIT_ID'
  ;

  l_balance_amount      number;
  l_gre_id              number;
  l_jurisdiction_code   varchar2(150);
  l_DIMENSION_NAME     pay_balance_dimensions.DIMENSION_NAME%type ;

  l_proc_name  constant varchar2(150) := g_package ||'Get_us_Balance_Value';

begin
  hr_utility.set_location('Entering: '||l_proc_name, 5);

    --
  open c_tax_id(c_assignment_id  => p_assignment_id
               ,c_effective_date => p_effective_date);
  fetch c_tax_id into l_gre_id;
  close c_tax_id;
  pay_balance_pkg.set_context('tax_unit_id', l_gre_id);
  pay_balance_pkg.set_context('date_earned', p_effective_date);

  if p_legislation_code = 'US' then
     open c_jur_code(c_assignment_id     => p_assignment_id
                    ,c_business_group_id => p_business_group_id
                    ,c_effective_date    => p_effective_date);
     fetch c_jur_code into l_jurisdiction_code;
     close c_jur_code;
     pay_balance_pkg.set_context('jurisdiction_code', l_jurisdiction_code);
  End if ;

  if p_legislation_code = 'FR' then

     -- set the context for france
     open c_tax_id(c_assignment_id  => p_assignment_id
               ,c_effective_date => p_effective_date);
     fetch c_tax_id into l_gre_id;
     close c_tax_id;
     pay_balance_pkg.set_context('tax_unit_id', l_gre_id);

  End if ;

 /*
  -- validate context, if the context has tax unit and gre is null then
  -- log a message and return null
  open c_tax_context ;
  fetch c_tax_context into l_DIMENSION_NAME ;
  if c_tax_context%found  then
     if l_gre_id is null then
        close c_tax_context
        -- context tax unit id found but no tax unit id
        -- log warning
       return null ;
     end if ;
  end if ;
  close c_tax_context ;
 */

  -- Call the pay balance pkg in date mode
  l_balance_amount := pay_balance_pkg.get_value
                      (p_defined_balance_id
                      ,p_assignment_id
                      ,p_effective_date);


  hr_utility.set_location('Leaving: '||l_proc_name, 80);
  return l_balance_amount;
exception
   when others then
   hr_utility.set_location('Leaving: '||l_proc_name, 90);
   l_balance_amount := null ;
   raise;
end Get_us_Balance_Value;



function Get_fn_Balance_Value
        (p_business_group_id  in number
        ,p_assignment_id      in number
        ,p_effective_date     in date
        ,p_legislation_code   in varchar2
        ,p_defined_balance_id in number) return number as

  l_balance_amount      number;
  l_gre_id              number;
  l_proc_name  constant varchar2(150) := g_package ||'Get_fn_Balance_Value';

begin
  hr_utility.set_location('Entering: '||l_proc_name, 5);

  --
  if  p_legislation_code = 'FI' then

      pay_FI_rules.get_main_tax_unit_id
          (p_assignment_id   => p_assignment_id
          ,p_effective_date  => p_effective_date
          ,p_tax_unit_id     => l_gre_id
          ) ;

  elsif p_legislation_code = 'IE' then

        pay_IE_rules.get_main_tax_unit_id
          (p_assignment_id   => p_assignment_id
          ,p_effective_date  => p_effective_date
          ,p_tax_unit_id     => l_gre_id
          ) ;

  elsif p_legislation_code = 'MX' then

        pay_MX_rules.get_main_tax_unit_id
          (p_assignment_id   => p_assignment_id
          ,p_effective_date  => p_effective_date
          ,p_tax_unit_id     => l_gre_id
          ) ;

  elsif p_legislation_code = 'ES' then

        pay_ES_rules.get_main_tax_unit_id
          (p_assignment_id   => p_assignment_id
          ,p_effective_date  => p_effective_date
          ,p_tax_unit_id     => l_gre_id
          ) ;

  elsif p_legislation_code = 'NL' then

        pay_NL_rules.get_main_tax_unit_id
          (p_assignment_id   => p_assignment_id
          ,p_effective_date  => p_effective_date
          ,p_tax_unit_id     => l_gre_id
          ) ;

  elsif p_legislation_code = 'SE' then

        pay_SE_rules.get_main_tax_unit_id
          (p_assignment_id   => p_assignment_id
          ,p_effective_date  => p_effective_date
          ,p_tax_unit_id     => l_gre_id
          ) ;

  else
        l_gre_id  := null ;
  end if ;

  pay_balance_pkg.set_context('tax_unit_id', l_gre_id);
  pay_balance_pkg.set_context('date_earned', p_effective_date);

  -- Call the pay balance pkg in date mode
  l_balance_amount := pay_balance_pkg.get_value
                      (p_defined_balance_id
                      ,p_assignment_id
                      ,p_effective_date);


  hr_utility.set_location('Leaving: '||l_proc_name, 80);
  return l_balance_amount;
exception
   when others then
   hr_utility.set_location('Leaving: '||l_proc_name, 90);
   l_balance_amount := null ;
   raise;
end Get_fn_Balance_Value;






function Get_Balance_Value
        (p_business_group_id  in number
        ,p_assignment_id      in number
        ,p_effective_date     in date
        ,p_legislation_code   in varchar2
        ,p_defined_balance_id in number) return number as

 l_balance_amount      number;
 l_proc_name  constant varchar2(150) := g_package ||'Get_Balance_Value';


begin

  hr_utility.set_location('Entering: '||l_proc_name, 5);

  if p_legislation_code in ( 'US','CA','AU','CN','DK','HK','IN','KW','SA','SG','AE','FR')  then
     l_balance_amount := Get_US_Balance_Value
                         (p_business_group_id  => p_business_group_id
                         ,p_assignment_id      => p_assignment_id
                         ,p_effective_date     => p_effective_date
                         ,p_legislation_code   => p_LEGISLATION_CODE
                         ,p_defined_balance_id => p_defined_balance_id
                         ) ;

 elsif  p_legislation_code in ('FI','IE','MX','ES','NL','SE') then

   l_balance_amount := Get_fn_Balance_Value
                         (p_business_group_id  => p_business_group_id
                         ,p_assignment_id      => p_assignment_id
                         ,p_effective_date     => p_effective_date
                         ,p_legislation_code   => p_LEGISLATION_CODE
                         ,p_defined_balance_id => p_defined_balance_id
                         ) ;

 else
    l_balance_amount := pay_balance_pkg.get_value
                      (p_defined_balance_id
                      ,p_assignment_id
                      ,p_effective_date);
 end if ;

  hr_utility.set_location('Leaving: '||l_proc_name, 80);
  return l_balance_amount;

exception
   when others then
     hr_utility.set_location('Leaving: '||l_proc_name, 90);
     l_balance_amount := null;
     return l_balance_amount ;
end  Get_Balance_Value ;

--

PROCEDURE sort_payroll_events
            (p_pay_events_tab IN  ben_ext_person.t_detailed_output_table)
IS

  l_pay_events_tab      ben_ext_person.t_detailed_output_table;
  l_sortrec             ben_ext_person.t_detailed_output_tab_rec;
  l_next_event_date     date  ;
  l_proc   varchar2(75) ;
BEGIN

  l_proc   := g_package ||'sort_payroll_events';
  hr_utility.set_location('Entering: '||l_proc, 5);
  -- nullify the global table
  ben_ext_person.g_pay_proc_evt_tab := l_pay_events_tab ;
  --intiali
  l_pay_events_tab := p_pay_events_tab;

  hr_utility.set_location('Before Looping  ', 10);
  hr_utility.set_location('Count:'||to_char(l_pay_events_tab.COUNT), 10 );

  IF (l_pay_events_tab.COUNT > 0) THEN

    --
    -- Bubble sort the events by effective_date
    --
    FOR i IN l_pay_events_tab.FIRST .. l_pay_events_tab.LAST
    LOOP
       hr_utility.trace('Inside Loop1');
       l_next_event_date  :=  null ;
       FOR j IN l_pay_events_tab.FIRST + i .. l_pay_events_tab.LAST
       LOOP
          hr_utility.trace('Inside Loop2');
          IF (l_pay_events_tab (i).effective_date > l_pay_events_tab (j).effective_date)
          THEN
             hr_utility.trace('Inside IF');
             l_sortrec := l_pay_events_tab (i);
             l_pay_events_tab (i) := l_pay_events_tab (j);
             l_pay_events_tab (j) := l_sortrec;
          END IF;
       END LOOP;
       l_next_event_date    := l_pay_events_tab(i).effective_date ;
       -- update the previous rows next event start date
       if l_next_event_date is not null and i > 1 and l_pay_events_tab.exists(i-1) then
          l_pay_events_tab(i-1).next_evt_start_date := l_next_event_date ;
          hr_utility.set_location('previous date ' || l_next_event_date , 99 ) ;
       end if ;

    END LOOP;

    hr_utility.set_location('Finished Looping', 10 );
    --
  END IF;

  -- Assign back the sorted collection
  ben_ext_person.g_pay_proc_evt_tab := l_pay_events_tab;

  hr_utility.set_location('Leaving: '||l_proc, 80);
EXCEPTION
  WHEN OTHERS THEN
    ben_ext_person.g_pay_proc_evt_tab :=  p_pay_events_tab  ;
    hr_utility.set_location('error  ' || substr(sqlerrm,1,200) , 99 ) ;
    RAISE;
END;


end ben_ext_payroll_balance;

/
