--------------------------------------------------------
--  DDL for Package Body PAY_IN_TAX_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_TAX_UTILS" AS
/* $Header: pyintxut.pkb 120.24.12010000.14 2010/03/12 07:18:19 mdubasi ship $ */

  type t_rent_paid   is table of number index by binary_integer ;
  type t_assact      is table of number index by binary_integer ;
  type t_month       is table of varchar2(30) index by binary_integer ;
  type t_bal_value   is table of number index by binary_integer ;
  type t_eff_date    is table of date index by binary_integer ;

  g_debug  boolean ;
  g_package CONSTANT VARCHAR2(20):= 'pay_in_tax_utils.';

--------------------------------------------------------------------------
-- Name           : get_financial_year_start                            --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the beginning of a tax year      --
-- Parameters     :                                                     --
--             IN :  p_date    DATE                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_financial_year_start (p_date in date ) return date is
    l_year varchar2(4);
    l_procedure    VARCHAR2(100);
    l_message      VARCHAR2(250);
BEGIN
    l_procedure := g_package||'get_financial_year_start';
    g_debug := hr_utility.debug_enabled;
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    if to_number(to_char(p_date,'MM')) >=4 then
        l_year := to_char(p_date,'YYYY');
        pay_in_utils.set_location(g_debug,l_procedure,20);
     else
        l_year := to_number(to_char(p_date,'YYYY')) -1 ;
        pay_in_utils.set_location(g_debug,l_procedure,30);
     end if ;

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
    return (to_date('01-04-'||l_year,'DD-MM-YYYY'));
END get_financial_year_start;

--------------------------------------------------------------------------
-- Name           : get_financial_year_end                              --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the end of a tax year            --
-- Parameters     :                                                     --
--             IN :  p_date    DATE                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_financial_year_end   (p_date in date ) return date is
    l_year varchar2(4);
    l_procedure    VARCHAR2(100);
    l_message      VARCHAR2(250);
BEGIN
    l_procedure := g_package||'get_financial_year_end';
    g_debug := hr_utility.debug_enabled;
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    if to_number(to_char(p_date,'MM')) <=3 then
        l_year := to_char(p_date,'YYYY');
        pay_in_utils.set_location(g_debug,l_procedure,20);
    else
        l_year := to_number(to_char(p_date,'YYYY')) +1 ;
        pay_in_utils.set_location(g_debug,l_procedure,30);
    end if ;

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
    return (to_date('31-03-'||l_year,'DD-MM-YYYY')) ;

END get_financial_year_end;

--------------------------------------------------------------------------
-- Name           : get_metro_status                                    --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the metro status of the assignment  --
-- Parameters     :                                                     --
--             IN : p_assignment_id      NUMBER                         --
--                  p_effective_date     DATE                           --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_metro_status (p_assignment_id     in number,
                           p_effective_date    in date)
return Varchar2 is
/*Bug:3907894 Added the date effective check on per_addresses table */
  cursor c_metro_status
      is
   select pad.add_information16
    from per_addresses pad,
         per_all_assignments_f paa
   where paa.assignment_id = p_assignment_id
     and pad.person_id = paa.person_id
     and pad.primary_flag = 'Y'
     and pad.style = 'IN'
     and p_effective_date between paa.effective_start_date and paa.effective_end_date
     and p_effective_date between pad.date_from and nvl(pad.date_to,to_date('31-12-4712','DD-MM-YYYY'));

  l_status       VARCHAR(2);
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_metro_status';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_id ',p_assignment_id);
        pay_in_utils.trace('p_effective_date',p_effective_date);
        pay_in_utils.trace('**************************************************','********************');
   END IF;

  l_status  :='N';

  open c_metro_status;
  fetch c_metro_status into l_status;
  /* Bug 3899924 Added the following IF condition */
  if c_metro_status%notfound then
     l_status := 'X';
     pay_in_utils.set_location(g_debug,l_procedure,20);
  end if;
  close c_metro_status;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
  return l_status ;

END get_metro_status;

--------------------------------------------------------------------------
-- Name           : get_period_number                                   --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the payroll period number on a given--
--                  date                                                --
-- Parameters     :                                                     --
--             IN : p_payroll_id     NUMBER                             --
--                  p_date           DATE                               --
--------------------------------------------------------------------------
FUNCTION get_period_number
            ( p_payroll_id in pay_all_payrolls_f.payroll_id%type,
              p_date       in date )
return number is
  l_start_date date;
  l_end_date   date;
  l_period_num number ;

  cursor csr_get_payroll_period is
  select start_date
  ,      end_date
  ,      decode(to_char(end_date,'MM'),'04',1,'05',2,'06',3,
        		               '07',4,'08',5,'09',6,
	                               '10',7,'11',8,'12',9,
	                               '01',10,'02',11,'03',12)
  from   per_time_periods
  where  payroll_id = p_payroll_id
    and    p_date  between start_date and end_date;

  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_period_number';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_period_num :=-99;
  open csr_get_payroll_period;
  fetch csr_get_payroll_period into l_start_date, l_end_date , l_period_num;
  close csr_get_payroll_period;

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('l_start_date',l_start_date);
        pay_in_utils.trace('l_end_date',l_end_date);
        pay_in_utils.trace('l_period_num',l_period_num);
   END IF;
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
   return l_period_num ;

END get_period_number;

--------------------------------------------------------------------------
-- Name           : get_house_rent_info_entry_id                        --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : Function to get the EE ID of House Rent Info Element--
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_house_rent_info_entry_id
        (p_assact         in pay_assignment_actions.assignment_Action_id%type,
         p_effective_date in date,
         p_year_start     in date,
         p_year_end       in date,
         p_entry_id_type_flag out nocopy  varchar2 ,
         p_entry_end_date  out nocopy date ) return number
 is
  l_houserentinfo_entry_id pay_element_entries_f.element_entry_id%type :=-999;

  l_entry_id_type_flag varchar2(2) ;
  --
  -- Note on usage of this flag
  -- 'E'  - entry exists in this pay period
  -- 'DP' - entry does not exist in this pay period
  --        but exists in this tax year
  -- 'DT' - entry does not exist in this tax year


  cursor c_ele_id
      is
  select  pee.element_entry_id,pee.effective_end_date
  from  pay_element_types_f pet
       ,pay_input_values_f piv
       ,pay_element_entries_f pee
       ,pay_element_entry_values_f pev
       ,pay_assignment_actions     pac
 where  pet.element_name         ='House Rent Information'
   and  piv.name                 = 'JAN'
   and  pet.legislation_code     ='IN'
   and  pet.element_type_id      = piv.element_type_id
   and  piv.input_value_id       = pev.input_value_id
   and  pee.element_entry_id     = pev.element_entry_id
   and  pee.assignment_id        = pac.assignment_id
   and  pac.assignment_action_id = p_assact
   and  p_effective_date between pet.effective_start_date and pet.effective_end_date
   and  p_effective_date between piv.effective_start_date and piv.effective_end_date
   and  p_effective_date between pee.effective_start_date and pee.effective_end_date ;

cursor c_ele_id_latest
      is
  select  pee.element_entry_id,pee.effective_end_date
  from  pay_element_types_f pet
       ,pay_input_values_f piv
       ,pay_element_entries_f pee
       ,pay_element_entry_values_f pev
       ,pay_assignment_actions     pac
 where  pet.element_name         ='House Rent Information'
   and  piv.name                 = 'JAN'
   and  pet.legislation_code     ='IN'
   and  pet.element_type_id      = piv.element_type_id
   and  piv.input_value_id       = pev.input_value_id
   and  pee.element_entry_id     = pev.element_entry_id
   and  pee.assignment_id        = pac.assignment_id
   and  pac.assignment_action_id = p_assact
   and  p_effective_date between pet.effective_start_date and pet.effective_end_date
   and  p_effective_date between piv.effective_start_date and piv.effective_end_date
   and  pee.effective_end_date <  p_effective_date
   and  pee.effective_end_date >  p_year_start
   order by pee.effective_end_date desc ;

    l_procedure    VARCHAR2(100);
    l_message     VARCHAR2(250);
BEGIN
    l_procedure := g_package||'get_house_rent_info_entry_id';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   l_entry_id_type_flag :='E';
   open  c_ele_id ;
   fetch c_ele_id into l_houserentinfo_entry_id,p_entry_end_date ;
   close c_ele_id ;

   pay_in_utils.set_location(g_debug,l_procedure,20);

  if l_houserentinfo_entry_id = -999 then
  --
  -- element entry does not exist in the current pay period
  -- get the latest element entry id
  --
    open  c_ele_id_latest ;
    fetch c_ele_id_latest  into l_houserentinfo_entry_id,p_entry_end_date ;
    close c_ele_id_latest ;
    pay_in_utils.set_location(g_debug,l_procedure,30);

    if l_houserentinfo_entry_id = -999 then
    --
    -- ok. entry id still not found in this financial year.
    -- Set the rent paid value to 0 for all months in this tax year
    --
      p_entry_id_type_flag := 'DT';
      pay_in_utils.set_location(g_debug,l_procedure,40);
    else
      p_entry_id_type_flag := 'DP';
      pay_in_utils.set_location(g_debug,l_procedure,50);
    end if;
  else
    p_entry_id_type_flag := 'E';
    pay_in_utils.set_location(g_debug,l_procedure,60);
  end if ;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,70);
  return l_houserentinfo_entry_id ;

END get_house_rent_info_entry_id;

--------------------------------------------------------------------------
-- Name           : get_defined_balance                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to return the defined balance id           --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_defined_balance
           (p_balance_type   in pay_balance_types.balance_name%type
          , p_dimension_name in pay_balance_dimensions.dimension_name%type)
return number
is
    CURSOR csr_def_bal_id
    IS
      SELECT pdb.defined_balance_id
       FROM   pay_defined_balances pdb
             ,pay_balance_types pbt
             ,pay_balance_dimensions pbd
       WHERE  pbt.balance_name =    p_balance_type
       AND    pbd.dimension_name =  p_dimension_name
       AND    pdb.balance_type_id = pbt.balance_type_id
        AND  ( pbt.legislation_code = 'IN' OR pbt.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'))
        AND  ( pbd.legislation_code = 'IN' OR pbd.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'))
        AND  ( pdb.legislation_code = 'IN' OR pdb.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'))
       AND    pdb.balance_dimension_id = pbd.balance_dimension_id;

    l_def_bal_id     pay_defined_balances.defined_balance_id%TYPE;
    l_message   VARCHAR2(255);
    l_procedure VARCHAR2(100);

BEGIN
   g_debug          := hr_utility.debug_enabled;
   l_procedure      := g_package ||'get_defined_balance';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure, 10);
   l_message := 'SUCCESS';

   OPEN  csr_def_bal_id;
   FETCH csr_def_bal_id
   INTO  l_def_bal_id;
   CLOSE csr_def_bal_id;

   pay_in_utils.set_location(g_debug,l_procedure, 20);

   IF g_debug THEN
     hr_utility.trace ('.   '||RPAD(TRIM(p_balance_type||p_dimension_name),35,' ')||' : '||l_def_bal_id);
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

   RETURN l_def_bal_id;

EXCEPTION
   WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      hr_utility.trace(l_message);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
      RETURN -1;

END get_defined_balance ;

--------------------------------------------------------------------------
-- Name           : get_monthly_rent                                    --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the monthly rents into a table   --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE get_monthly_rent
          (p_element_entry_id in pay_element_entries_f.element_entry_id%type ,
           p_effective_date   in date ,
           p_entry_type_flag  in varchar2,
           p_entry_end_date   in date ,
           p_payroll_id       in pay_all_payrolls_f.payroll_id%type,
           p_rent_paid        out nocopy t_rent_paid,
           p_month            out nocopy t_month    )
is
  l_effective_date date;
  l_procedure      VARCHAR2(100);
  l_message        VARCHAR2(250);

BEGIN
   l_procedure      := g_package ||'get_monthly_rent';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure, 10);

  if p_entry_end_date < p_effective_date then
    l_effective_date := p_entry_end_date ;
  else
    l_effective_date := p_effective_date ;
  end if ;
  pay_in_utils.set_location(g_debug,l_procedure, 20);

  /* Bug:3902174 Added nvl in the below select statement */
  select nvl(pev.screen_entry_value,0)
        ,piv.name
    bulk collect into
         p_rent_paid ,
         p_month
    from pay_element_entries_f      pee,
         pay_element_entry_values_f pev,
         pay_input_values_f         piv
   where pee.element_entry_id = p_element_entry_id
     and pev.element_entry_id = pee.element_entry_id
     and pee.element_type_id  = piv.element_type_id
     and pev.input_value_id   = piv.input_value_id
     and l_effective_date between piv.effective_start_date and piv.effective_end_date
     and l_effective_date between pee.effective_start_date and pee.effective_end_date
     and l_effective_date between pev.effective_start_date and pev.effective_end_date
   order by decode ( piv.name , 'APR',1
                              , 'MAY',2
                              , 'JUN',3
                              , 'JUL',4
                              , 'AUG',5
                              , 'SEP',6
                              , 'OCT',7
                              , 'NOV',8
                              , 'DEC',9
                              , 'JAN',10
                              , 'FEB',11
                              , 'MAR',12
                  );
   if p_entry_type_flag = 'DT' then
     pay_in_utils.set_location(g_debug,l_procedure, 30);
     p_month(1) :='APR';
     p_month(2) :='MAY';
     p_month(3) :='JUN';
     p_month(4) :='JUL';
     p_month(5) :='AUG';
     p_month(6) :='SEP';
     p_month(7) :='OCT';
     p_month(8) :='NOV';
     p_month(9) :='DEC';
     p_month(10):='JAN';
     p_month(11):='FEB';
     p_month(12):='MAR';
     for i in 1..12 loop
       p_rent_paid(i) :=0;
     end loop;
   elsif p_entry_type_flag = 'DP' then
      pay_in_utils.set_location(g_debug,l_procedure, 40);
      --
      -- set rent paid for months after the end date as 0
      --
      for i in get_period_number(p_payroll_id,p_entry_end_date)+1..12 loop
        p_rent_paid(i) :=0;
      end loop ;
   end if ;

   if g_debug then
    hr_utility.trace('----------House Rent Information ----------');
    for i in p_rent_paid.first..p_rent_paid.last loop
      hr_utility.trace(p_month(i)||'------------------'||p_rent_paid(i));
    end loop ;

    hr_utility.trace('-------------------------------------------');
   end if ;

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure, 50);

END get_monthly_rent ;

--------------------------------------------------------------------------
-- Name           : get_monthly_max_assact                              --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : This procedure will return the maximum assignment   --
--                  action ids for each month. This will be used to get --
--                  the HRA related balance values if there is a        --
--                  historical update on the rent paid information.     --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE get_monthly_max_assact
          ( p_assignment_id in per_all_assignments_f.assignment_id%type,
            p_year_start    in date ,
            p_year_end      in date ,
            p_assact_tbl    out nocopy  t_assact,
            p_eff_date_tbl  out nocopy  t_eff_date)
IS
  idx number ;
  l_month_number_tbl t_Assact; -- number type pl/sql table
  l_assact_tbl       t_Assact;
  l_eff_date_tbl     t_eff_date;

  l_procedure VARCHAR2(100);
  l_message   VARCHAR2(250);
BEGIN
   l_procedure      := g_package ||'get_monthly_max_assact';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure, 10);

  /*Bug:3907894 Added ppa.effective_date in the select statement and fetched it in the table l_eff_date_tbl */
  select paa.assignment_action_id,pay_in_tax_utils.get_period_number(ppa.payroll_id,ppa.date_earned),ppa.date_earned
  bulk collect into l_assact_tbl,l_month_number_tbl,l_eff_date_tbl
   from  pay_payroll_Actions    ppa,
         pay_assignment_Actions paa,
         per_assignments_f asg -- Added to remove NMV as per bug 4774108
  where  ppa.payroll_Action_id   = paa.payroll_Action_id
    and  paa.assignment_id  = p_assignment_id
    and  paa.assignment_id  = asg.assignment_id-- Added to remove NMV as per bug 4774108
    and  asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
    and  ppa.action_type in ('B','V','I','R','Q')
--    and  paa.source_action_id is not null -- Commented for bug 4774514
    and  ppa.date_earned between p_year_start and p_year_end
    and  ppa.date_earned between asg.effective_start_date and asg.effective_end_date
    and  paa.action_sequence = ( select max(pac.action_sequence)
                                  from pay_assignment_actions pac
                                      ,pay_payroll_actions    ppa1
                                 where pac.assignment_id             = paa.assignment_id
                                   and pac.payroll_action_id         = ppa1.payroll_action_id
                                   and ppa1.date_earned between p_year_start and p_year_end
                                   and trunc(ppa.date_earned,'MM') = trunc(ppa1.date_earned,'MM')
                                   and ppa1.action_type in ('B','V','I','R','Q')
--                                 and  pac.source_action_id is not null -- Commented for bug 4774514
                             )
  order by decode(to_number(to_char(ppa.date_earned,'MM'))
                              , 4,1
                              , 5,2
                              , 6,3
                              , 7,4
                              , 8,5
                              , 9,6
                              , 10,7
                              , 11,8
                              , 12,9
                              , 1,10
                              , 2,11
                              , 3,12 ) ;
   --
   -- reorder the assignment action table for each month if the employee
   -- joins in the middle of the year.
   -- assignment action id and effective date for a particular month should be held at the same
   -- index . eg . APR - 1, MAY 2 ...MAR-12
   -- for months where no assignment action exists assact will be set to -99
   -- Bug:3907894 for months where no effective date exists, it would be set to 31/12/4712
   --
   if l_month_number_tbl.count >0 then
     if l_month_number_tbl(1) <> 1 then
       for i in 1..l_month_number_tbl.last loop
         p_assact_tbl(l_month_number_tbl(i)):=l_assact_tbl(i) ;
         p_eff_date_tbl(l_month_number_tbl(i)):=l_eff_date_tbl(i) ;
       end loop;
       idx := p_assact_tbl.last ;
       while idx>= 1 loop
         if not p_assact_tbl.exists(idx) then
           p_assact_tbl(idx):= -99;
           p_eff_date_tbl(idx):= to_date('31/12/4712','dd/mm/yyyy');
         end if;
         idx:= idx-1;
       end loop ;
     else
       p_assact_tbl := l_assact_tbl ;
       p_eff_date_tbl := l_eff_date_tbl;
     end if;
   end if;


   if g_debug then
    hr_utility.trace('----------Maximum Assignment action ----------');
    for i in 1..p_assact_tbl.count loop
    hr_utility.trace(p_assact_tbl(i));
    end loop ;
    hr_utility.trace('-------------------------------------------');
   end if ;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure, 10);
END get_monthly_max_assact;

--------------------------------------------------------------------------
-- Name           : hra_tax_rule                                        --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : This procedure encapsulates the actual hra rule     --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE  hra_tax_rule( hra_received  in  number ,
                         rent_paid     in  number ,
                         hra_salary    in  number ,
                         metro_flag    in  varchar2 ,
                         taxable_hra   out nocopy number ,
                         exempt_hra    out nocopy number )
IS
   l_percent number;
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(250);

BEGIN
   l_procedure      := g_package ||'hra_tax_rule';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure, 10);

   if g_debug then
       hr_utility.trace('---------------------------------------');
       hr_utility.trace('hra received -'||hra_received);
       hr_utility.trace('hra salary - '||hra_salary);
       hr_utility.trace('rent paid - '||rent_paid);
   end if ;

   if metro_flag = 'Y' then
       l_percent :=0.5 ;
   else
       l_percent :=0.4 ;
   end if ;

     exempt_hra  := least ( hra_salary*l_percent , hra_received, greatest((rent_paid - 0.10 * hra_salary  ),0)) ;
     taxable_hra := greatest((hra_received - exempt_hra),0) ;

   if g_debug then
     hr_utility.trace('exempt_hra - '||exempt_hra);
     hr_utility.trace('taxable hra  -'||taxable_hra);
     hr_utility.trace('---------------------------------------');
   END IF;
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure, 20);

END hra_tax_rule;

--------------------------------------------------------------------------
-- Name           : historical_update_exists                            --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : Function to check if there is any update on House   --
--                  Rent Information element in this tax year           --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION historical_update_exists( p_element_entry_id      in number ,
                                   p_year_start     in date ,
                                   p_year_end       in date ,
                                   p_effective_date in date )
return boolean
is

  l_exists varchar2(1)  ;

  cursor c_exists
      is
  select 'Y'
    from dual
   where exists
    (
      select element_entry_id
        from pay_element_entries_f
       where element_entry_id=p_element_entry_id
         and  effective_start_date between p_year_start
                                       and p_year_end
      having count(element_entry_id) > 1
      group by element_entry_id
      union
      select element_entry_id
        from pay_element_entries_f
       where element_entry_id=p_element_entry_id
         and effective_start_date > p_year_start
         and effective_start_date < p_year_end
    );
    l_procedure VARCHAR2(100);
    l_message   VARCHAR2(250);

BEGIN
   l_procedure      := g_package ||'historical_update_exists';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure, 10);

  l_exists :='N' ;

   open c_exists ;
   fetch c_exists into l_exists ;
   close c_exists;

   if l_exists ='Y' then
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure, 20);
      return true ;
   else
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure, 30);
      return false ;
   end if;
end historical_update_exists;

--------------------------------------------------------------------------
-- Name           : get_hra_bal_information                             --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure to calculate the monthly house rent       --
--                  allowance received and the monthly house rent salary--
--                  for an employee.This procedure will be called when  --
--                  there are historical updates on rent paid information.
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE get_hra_bal_information
           ( p_assignment_id in per_all_assignments_f.assignment_id%type,
             p_year_start    in date ,
             p_year_end      in date ,
             p_hra_tbl       out nocopy t_bal_value,
             p_hra_sal_tbl   out nocopy t_bal_value,
             p_eff_date_tbl  out nocopy t_eff_date )
is
 l_assact_tbl   t_assact ;
 l_eff_date_tbl t_eff_date;
 l_hra_sal_bal_id     pay_defined_balances.defined_balance_id%type;
 l_hra_alw_bal_id     pay_defined_balances.defined_balance_id%type;
 l_hra_advance_alw_bal_id  pay_defined_balances.defined_balance_id%type;
 l_procedure    VARCHAR2(100);
 l_message      VARCHAR2(250);

BEGIN
   l_procedure      := g_package ||'get_defined_balance';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure, 10);

   --
   -- get defined_balance_id
   --
   l_hra_alw_bal_id  := get_defined_balance('House Rent Allowance','_ASG_PTD');
   l_hra_advance_alw_bal_id  := get_defined_balance( 'Adjusted Advance for HRA','_ASG_PTD');
   l_hra_sal_bal_id  := get_defined_balance( 'Salary for HRA and Related Exemptions','_ASG_PTD');

   /* Bug:3907894 pass p_eff_date_tbl as the out parameter */
   get_monthly_max_assact( p_assignment_id , p_year_start, p_year_end , l_assact_tbl,p_eff_date_tbl);

   if g_debug then
     hr_utility.trace('-----------------------------------------');
   end if ;

   for i in 1..l_assact_tbl.count loop
     IF l_assact_tbl(i) > 0 THEN
        p_hra_tbl(i)     := pay_balance_pkg.get_value(l_hra_alw_bal_id , l_assact_tbl(i)) +
                            pay_balance_pkg.get_value(l_hra_advance_alw_bal_id , l_assact_tbl(i));
        p_hra_sal_tbl(i) := pay_balance_pkg.get_value(l_hra_sal_bal_id , l_assact_tbl(i)) ;
     ELSE
        p_hra_tbl(i)     := 0 ;
        p_hra_sal_tbl(i) := 0 ;
     END IF;

     if g_debug then
       hr_utility.trace('Assact Id -----HRA Allow----HRA Salary--');
       hr_utility.trace(l_assact_tbl(i)||'-----'||p_hra_tbl(i)||'------'||p_hra_sal_tbl(i));
     end if ;

   end loop;

   if g_debug then
     hr_utility.trace('-----------------------------------------');
   end if ;
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure, 10);

end get_hra_bal_information ;

--------------------------------------------------------------------------
-- Name           : taxable_hra                                         --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Main Function to calculate taxable portion of HRA   --
--                  This is called from FF IN_CALCULATE_TAXABLE_HRA     --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.1   04-Oct-05 Sukukuma   modified this procedure(4638402)          --
-- 1.2   02-Feb-07 lnagaraj   Used  Std value for projection(5859435)   --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION taxable_hra(  p_assact_id              in number
                      ,p_element_entry_id       in number
                      ,p_effective_date         in date
                      ,p_pay_period_num         in number
                      ,p_hra_salary             in number
                      ,p_std_hra_salary         in number
                      ,p_hra_allowance_asg_run  in number
                      ,p_hra_allowance_asg_ytd  in number
                      ,p_std_hra_allow_asg_run  in number
                      ,p_std_hra_allow_asg_ytd  in number
                      ,p_hra_taxable_mth        out nocopy number
                      ,p_hra_taxable_annual     out nocopy number
                      ,p_message                out nocopy varchar2)
RETURN  NUMBER
IS
  /**** Scenarios:
   => HRA can be updated in between a year for previous months.
   => An employee can claim 80 GG / Rent free accomodation in between the year.
      Assumption is - if the employee gets House Rent allowance then
      Value of Rent Free accomodation becomes entirely taxable
      also the employee can not claim exemption under section 80GG
  Logic :
  => If there is no date track update on the HRA element in this tax year then there is no
     use calculating the hra individually for each month. Balances can be safely used.
     calcualte taxable hra only for current month.
  => But if there is any date track update on the House Rent Information element then
  => we need to recalculate the taxable amount for HRA for the entire tax year.
  => Also taxable HRA will be recalculated for the entire tax year in the last month of
     of the tax year or termination date
  ****/

  l_assignment_id           per_all_assignments_f.assignment_id%type ;
  l_asg_end_date            DATE ;
  l_last_period_num         NUMBER ;
  l_payroll_id              pay_all_payrolls_f.payroll_id%type;
  l_current_month_rent      NUMBER  ;
  l_rent_paid_tbl	    t_rent_paid ;
  l_month_tbl               t_month ;
  l_hra_tbl                 t_bal_value ;
  l_hra_sal_tbl             t_bal_value ;
  l_eff_date_tbl            t_eff_date;
  l_year_start              DATE ;
  l_year_end                DATE ;
  l_current_gre_end_date    DATE;
  l_effective_start_date    DATE;
  l_hra_salary              NUMBER;
  l_hra_allowance           NUMBER;
  l_taxable_hra_asg_ytd     NUMBER;
  l_taxable_hra_asg_ptd     NUMBER;
  l_taxable_hra_proj_ptd    NUMBER;
  l_taxable_hra             NUMBER ;
  l_taxable_hra_curr        NUMBER ;
  l_taxable_hra_proj        NUMBER ;
  l_exemption_on_hra        NUMBER ;
  l_metro_status            varchar2(1);
  l_hri_entry_id            pay_element_entries_f.element_entry_id%type;
  l_taxable_hra_def_bal_id  pay_defined_balances.defined_balance_id%type;
  l_taxable_hra_ptd_bal_id  pay_defined_balances.defined_balance_id%type;
  l_taxable_hra_proj_bal_id pay_defined_balances.defined_balance_id%type;
  l_current_gre             hr_soft_coding_keyflex.segment1%type;
  l_gre                     hr_soft_coding_keyflex.segment1%type;
  l_entry_type_flag         varchar2(2) ;
  l_entry_end_date          DATE;
  l_check_date              DATE;
  l_terminate_date          DATE;
  l_last_month              DATE;

  CURSOR csr_get_current_gre( p_assignment_id      per_all_assignments_f.assignment_id%type)
  IS
     SELECT   scl.segment1
     FROM     hr_soft_coding_keyflex scl
             ,per_all_assignments_f paf
     WHERE    paf.assignment_id=p_assignment_id
     AND      paf.SOFT_CODING_KEYFLEX_ID=scl.SOFT_CODING_KEYFLEX_ID
     AND      p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date;

  CURSOR csr_get_date(  p_assignment_id      per_all_assignments_f.assignment_id%type
                       ,p_check_date                                             DATE)
  IS
     SELECT    scl.segment1
              ,paf.effective_start_date
     FROM      hr_soft_coding_keyflex scl,
               per_all_assignments_f paf
     WHERE     paf.assignment_id=p_assignment_id
     AND       paf.SOFT_CODING_KEYFLEX_ID=scl.SOFT_CODING_KEYFLEX_ID
     AND       paf.effective_start_date BETWEEN p_effective_date AND p_check_date ;

    l_procedure  VARCHAR2(100);
    l_message    VARCHAR2(250);

BEGIN

   g_debug          := hr_utility.debug_enabled;
   l_procedure      := g_package ||'taxable_hra';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure, 10);

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_element_entry_id     ',p_element_entry_id     );
        pay_in_utils.trace('p_effective_date       ',p_effective_date       );
        pay_in_utils.trace('p_pay_period_num       ',p_pay_period_num       );
        pay_in_utils.trace('p_hra_salary           ',p_hra_salary           );
        pay_in_utils.trace('p_std_hra_salary       ',p_std_hra_salary       );
        pay_in_utils.trace('p_hra_allowance_asg_run',p_hra_allowance_asg_run);
        pay_in_utils.trace('p_hra_allowance_asg_ytd',p_hra_allowance_asg_ytd);
        pay_in_utils.trace('p_std_hra_allow_asg_run',p_std_hra_allow_asg_run);
        pay_in_utils.trace('p_std_hra_allow_asg_ytd',p_std_hra_allow_asg_ytd);
        pay_in_utils.trace('**************************************************','********************');
   END IF;


  l_current_month_rent      :=0;
  l_hra_salary              :=0;
  l_hra_allowance           :=0;
  l_taxable_hra_asg_ytd     :=0;
  l_taxable_hra             :=0;
  l_taxable_hra_curr        :=0;
  l_taxable_hra_proj        :=0;
  l_exemption_on_hra        :=0;
  p_message                 := 'TRUE';

   --
   -- set global variables like assignment id , year start etc
   --

   SELECT  assignment_id
     INTO  l_assignment_id
     FROM  pay_assignment_actions
    WHERE  assignment_action_id = p_assact_id ;

   -- Get the termination date of the employee
   SELECT SERVICE.actual_termination_date
    INTO l_terminate_date
    FROM per_assignments_f    ASSIGN,
         per_periods_of_service    SERVICE
   WHERE  p_effective_date BETWEEN ASSIGN.effective_start_date AND ASSIGN.effective_end_date
     AND  ASSIGN.assignment_id  = l_assignment_id
     AND  SERVICE.period_of_Service_id = ASSIGN.period_of_service_id;

   SELECT  nvl(pps.actual_termination_date,paa.effective_end_Date),payroll_id
     INTO  l_asg_end_date,l_payroll_id
     FROM   per_Assignments_f  paa,-- Modified this for 4774108 to remove NMV
           per_periods_of_Service pps
    WHERE  paa.assignment_id = l_assignment_id
      AND  paa.period_of_service_id =pps.period_of_service_id
      AND  paa.effective_end_date = ( SELECT  MAX (b.effective_end_date)
                                       FROM  per_all_assignments_f b
                                      WHERE  paa.assignment_id=b.assignment_id );

   -- get tax year start ,tax year end and assignment end date in case of terminations
   --
    l_year_start := pay_in_tax_utils.get_financial_year_start(p_effective_date );
    l_year_end   := pay_in_tax_utils.get_financial_year_end(p_effective_date );
    l_check_date :=LEAST (l_asg_end_date,l_year_end);

------------------------------
/*To get current gre_id */
------------------------------
   OPEN csr_get_current_gre(l_assignment_id);
   FETCH csr_get_current_gre INTO l_current_gre;
   CLOSE csr_get_current_gre;
   hr_utility.trace('INHRA:l_current_gre     : '||l_current_gre);

--------------------------------------------------------
/*To get the end date of  GRE in which payroll is run */
--------------------------------------------------------
   OPEN csr_get_date(l_assignment_id,l_check_date);
     LOOP
       FETCH csr_get_date INTO l_gre,l_effective_start_date;
         IF(l_gre<>l_current_gre) THEN
           l_current_gre_end_date:=l_effective_start_date-1;
           EXIT;
         END  IF ;
      EXIT WHEN csr_get_date%NOTFOUND;
     END LOOP;
   CLOSE csr_get_date;

   hr_utility.trace('INHRA:l_current_gre_end_date     : '||l_current_gre_end_date);

    pay_in_utils.set_location(g_debug,l_procedure, 20);

    --------------------------------
   /*IF employee gets terminated*/
    --------------------------------
   IF  l_asg_end_date < l_year_end THEN
        --------------------------
         /*If GRE gets changed */
        --------------------------
        IF l_current_gre_end_date IS NOT NULL THEN
	    l_last_period_num:=get_period_number(l_payroll_id,l_current_gre_end_date);
	ELSE
            l_last_period_num := get_period_number(l_payroll_id,l_asg_end_date);
	END IF;
    ELSE
        --------------------------
         /*If GRE gets changed */
        --------------------------
       IF l_current_gre_end_date IS NOT NULL THEN
          l_last_period_num:=get_period_number(l_payroll_id,l_current_gre_end_date);
       ELSE
          l_last_period_num := 12;
       END IF;
    END  IF ;

    pay_in_utils.set_location(g_debug,l_procedure, 30);

    IF  g_debug THEN
      hr_utility.trace('INHRA: Last Period Number     : '||l_last_period_num);
      hr_utility.trace('INHRA: current no     : '||p_pay_period_num);
      hr_utility.trace('INHRA: Assgn End Date         : '||l_asg_end_date);
    END  IF  ;

    --
    -- get metro status of the employee
    --

   l_metro_status := get_metro_status(l_assignment_id, p_effective_date );
   /* Bug 3899924 Added the following condition */
   IF l_metro_status = 'X' THEN
      p_message := 'FALSE';
   END IF;

   --
   --  get defined balance for Balance Taxable HRA
   --

   l_taxable_hra_def_bal_id  := get_defined_balance('Taxable House Rent Allowance', '_ASG_YTD') ;

   pay_in_utils.set_location(g_debug,l_procedure, 40);

   --
   -- get element entry id for House Rent information element
   --
    l_hri_entry_id := get_house_rent_info_entry_id(p_assact_id,
                                                   p_effective_date,
                                                   l_year_start,
                                                   l_year_end,
                                                   l_entry_type_flag,
                                                   l_entry_end_date );

   --
   -- get monthly rent paid for each month in the current tax year
   -- April = 1 , May =2 ...March = 12
   --
   pay_in_utils.set_location(g_debug,l_procedure, 50);

   get_monthly_rent( l_hri_entry_id,
                     p_effective_date ,
                     l_entry_type_flag ,
                     l_entry_end_Date,
                     l_payroll_id,
                     l_rent_paid_tbl ,
                     l_month_tbl  ) ;

   pay_in_utils.set_location(g_debug,l_procedure, 60);
   --
   -- Calculate annual value of taxable hra before this run
   --

   l_last_month := last_day(p_effective_date);

   -- Recalculating the HRA for enitre tax year

   IF ( historical_update_exists(l_hri_entry_id,l_year_start,l_year_end,p_effective_date)
        OR l_last_month = l_year_end OR l_terminate_date is NOT NULL )
   THEN
      p_hra_taxable_annual := 0;
      pay_in_utils.set_location(g_debug,l_procedure, 70);

      --
      -- get monthly balance values for 'House Rent Allowance' and 'HRA Salary'
      -- for all the pay periods prior to this run
      -- Bug:3907894 Get the effective dates for each run in the table l_eff_date_tbl

      get_hra_bal_information ( l_assignment_id,
                              l_year_start,
                              l_year_end,
                              l_hra_tbl,
                              l_hra_sal_tbl,
                              l_eff_date_tbl);

      IF g_debug THEN
        hr_utility.trace('INHRA: ------- HRA Amount--------');
        FOR  i in 1..l_hra_tbl.count LOOP
           hr_utility.trace('INHRA: '||l_hra_tbl(i));
        END  LOOP ;
        hr_utility.trace('INHRA: ------- HRA Salary--------');
        FOR  i in 1..l_hra_sal_tbl.count loop
           hr_utility.trace('INHRA: '||l_hra_sal_tbl(i));
        END LOOP ;
      END IF ;

  -- Bug:3907894 Get the metro status as of the payroll period
     For i in 1..l_hra_tbl.count-1  LOOP
       hra_tax_rule( l_hra_tbl(i) ,
                     l_rent_paid_tbl(i),
                     l_hra_sal_tbl(i) ,
                     get_metro_status(l_assignment_id, l_eff_date_tbl(i) ),
                     l_taxable_hra ,
                     l_exemption_on_hra ) ;
       l_taxable_hra_asg_ytd := l_taxable_hra_asg_ytd + l_taxable_hra ;
     END  LOOP;
   ELSE
      pay_in_utils.set_location(g_debug,l_procedure, 80);

     --
     -- There is no update on the rent paid information this year
     hr_utility.trace('INHRA: --tax_unit_id =>'||l_current_gre);

      l_taxable_hra_asg_ytd := pay_balance_pkg.get_value(l_taxable_hra_def_bal_id,
                                                         p_assact_id ,
                                                         null,
                                                         null,
                                                         null,
                                                         null,
                                                         null,
                                                         null,
                                                         null,
                                                         'TRUE');

   END IF  ;

   IF g_debug THEN
       hr_utility.trace('INHRA: No update to HRI element. Hence direct results');
      hr_utility.trace ('INHRA: Taxable HRA_LE_ASG_YTD    : '||l_taxable_hra_asg_ytd);
   END IF;
    --
    -- Calculate current month's taxable hra
    --

     l_current_month_rent :=  l_rent_paid_tbl( p_pay_period_num ) ;


     hra_tax_rule( p_hra_allowance_asg_run,
                   l_current_month_rent ,
                   p_hra_salary ,
                   l_metro_status,
                   l_taxable_hra_curr ,
                   l_exemption_on_hra ) ;

    --
    -- calculate projected value of taxable hra for future months in this tax year
    --
   IF g_debug THEN
      hr_utility.trace ('INHRA: Taxable HRA_ASG_PTD    : '||l_taxable_hra_curr);
   END IF;

    pay_in_utils.set_location(g_debug,l_procedure, 90);
     --
     -- use only std value for projection
     --

       l_hra_salary    := p_std_hra_salary;
       l_hra_allowance := p_std_hra_allow_asg_run;


     pay_in_utils.set_location(g_debug,l_procedure, 100);

     FOR  i in p_pay_period_num+1..l_last_period_num LOOP
       hra_tax_rule( l_hra_allowance ,
                     l_rent_paid_tbl(i),
                     l_hra_salary,
                     l_metro_status,
                     l_taxable_hra,
                     l_exemption_on_hra ) ;
       l_taxable_hra_proj := l_taxable_hra_proj+l_taxable_hra ;
     END  LOOP ;

     l_taxable_hra_ptd_bal_id  := get_defined_balance('Taxable House Rent Allowance', '_ASG_PTD') ;

     l_taxable_hra_asg_ptd := pay_balance_pkg.get_value(l_taxable_hra_ptd_bal_id,
                                                        p_assact_id ,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        'TRUE');

     l_taxable_hra_proj_bal_id  := get_defined_balance('Taxable House Rent Allowance for Projection', '_ASG_PTD') ;

     l_taxable_hra_proj_ptd := pay_balance_pkg.get_value(l_taxable_hra_proj_bal_id,
                                                        p_assact_id ,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        'TRUE');

     pay_in_utils.set_location(g_debug,l_procedure, 110);

	     p_hra_taxable_annual := (l_taxable_hra_curr - l_taxable_hra_asg_ptd ) +
	                             (l_taxable_hra_proj - (l_taxable_hra_proj_ptd- l_taxable_hra_asg_ytd));

     p_hra_taxable_mth    := l_taxable_hra_curr  - l_taxable_hra_asg_ptd;

   IF g_debug THEN
      hr_utility.trace ('INHRA: p_hra_taxable_annual   : '||p_hra_taxable_annual);
      hr_utility.trace ('INHRA: p_hra_taxable_mth      : '||p_hra_taxable_mth);
   END IF;

   RETURN  0 ;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure, 120);
END taxable_hra;

--------------------------------------------------------------------------
-- Name           : prev_emplr_details                                  --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the Previous Employment Details     --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION prev_emplr_details(p_assignment_id in number
                             ,p_date_earned in date
                             ,p_prev_sal out nocopy number
                             ,p_prev_tds out nocopy number
                             ,p_prev_pt out nocopy number
                             ,p_prev_ent_alw out NOCOPY number
                             ,p_prev_pf OUT NOCOPY number
                             ,p_prev_super OUT NOCOPY number
                             ,p_prev_govt_ent_alw out nocopy number
                             ,p_prev_grat OUT NOCOPY NUMBER
                             ,p_prev_leave_encash OUT NOCOPY NUMBER
                             ,p_prev_retr_amt OUT NOCOPY NUMBER
                             ,p_designation OUT NOCOPY VARCHAR2
                             ,p_annual_sal OUT NOCOPY NUMBER
                             ,p_pf_number OUT NOCOPY VARCHAR2
                             ,p_pf_estab_code OUT NOCOPY VARCHAR2
                             ,p_epf_number OUT NOCOPY VARCHAR2
                             ,p_emplr_class OUT NOCOPY VARCHAR2
                             ,p_ltc_curr_block OUT NOCOPY NUMBER
                             ,p_vrs_amount OUT NOCOPY NUMBER
                             ,p_prev_sc   OUT NOCOPY NUMBER
                             ,p_prev_cess OUT NOCOPY NUMBER
                             ,p_prev_exemp_80gg OUT NOCOPY NUMBER
                             ,p_prev_med_reimburse_amt OUT NOCOPY NUMBER
                             ,p_prev_sec_and_he_cess OUT NOCOPY NUMBER
			     ,p_prev_exemp_80ccd OUT NOCOPY NUMBER
                             ,p_prev_cghs_exemp_80D OUT NOCOPY NUMBER)
Return Number is
/*Bug:3919215 Modified the cursor. selected Employer classification of prev emplr */
 Cursor c_prev_emp_details is
 select nvl(ppm.pem_information1,'X'), -- Designation
        fnd_number.canonical_to_number(nvl(ppm.pem_information2,0)),   -- Annual Salary
        nvl(ppm.pem_information3,'X'), -- PF Number
        nvl(ppm.pem_information4,'X'), -- PF Establishment Code
        nvl(ppm.pem_information5,'X'), -- EPF Number
        nvl(ppm.pem_information6,'X'), -- Emplr class
        fnd_number.canonical_to_number(nvl(ppm.pem_information8,0)),   -- LTC Curr
        fnd_number.canonical_to_number(nvl(ppm.pem_information9,0)),   -- Leave Encashment
        fnd_number.canonical_to_number(nvl(ppm.pem_information10,0)),  -- Gratuity
        fnd_number.canonical_to_number(nvl(ppm.pem_information11,0)),  -- Retrenchment Amount
        fnd_number.canonical_to_number(nvl(ppm.pem_information12,0)),  -- VRS
        fnd_number.canonical_to_number(nvl(ppm.pem_information13,0)),  -- Gross Sal
        fnd_number.canonical_to_number(nvl(ppm.pem_information14,0)),  -- PF
        fnd_number.canonical_to_number(nvl(ppm.pem_information15,0)),  -- Ent Alw
        fnd_number.canonical_to_number(nvl(ppm.pem_information16,0)),  -- PT
        fnd_number.canonical_to_number(nvl(ppm.pem_information17,0)),  -- TDS
        fnd_number.canonical_to_number(nvl(ppm.pem_information18,0)),  -- Superannuation
        fnd_number.canonical_to_number(nvl(ppm.pem_information19,0)),  -- Prev Surcharge
        fnd_number.canonical_to_number(nvl(ppm.pem_information20,0)),  -- Prev Cess
        fnd_number.canonical_to_number(nvl(ppm.pem_information21,0)),  -- Exemption under 80gg
        fnd_number.canonical_to_number(nvl(ppm.pem_information22,0)),  -- Medical Reimbursement
        fnd_number.canonical_to_number(nvl(ppm.pem_information23,0)),  -- Sec and HE Cess
        fnd_number.canonical_to_number(nvl(ppm.pem_information24,0)),  -- Exemption under 80ccd
	fnd_number.canonical_to_number(nvl(ppm.pem_information25,0)),  -- CGHS Exemption under 80D
        ppm.end_date
   from per_previous_employers ppm,
        per_all_assignments_f paa
  where paa.assignment_id = p_assignment_id
    and paa.person_id = ppm.person_id
    and p_date_earned between paa.effective_start_date and paa.effective_end_date;

 l_start DATE;
 l_end DATE;
 l_sal NUMBER;
 l_ent NUMBER;
 l_pt NUMBER;
 l_tds NUMBER;
 l_pf NUMBER;
 l_super NUMBER;
 l_grat  NUMBER;
 l_leave_encash NUMBER;
 l_retr_amt NUMBER;
 l_emplr_class VARCHAR2(10);
 l_end_date DATE;
 l_designation VARCHAR2(100);
 l_annual_sal NUMBER;
 l_pf_number VARCHAR2(30);
 l_pf_estab_code VARCHAR2(15);
 l_epf_number VARCHAR2(30);
 l_ltc_curr NUMBER;
 l_vrs_amount NUMBER;
 l_prev_sc    NUMBER;
 l_prev_cess  NUMBER;
 l_prev_sec_and_he_cess  NUMBER;
 l_prev_exemp_80gg NUMBER;
 l_prev_med_reimburse_amt NUMBER;
 l_prev_exemp_80ccd NUMBER ;
 l_prev_cghs_exemp_80d NUMBER;


  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN

   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'prev_emplr_details';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_id',p_assignment_id);
        pay_in_utils.trace('p_date_earned',p_date_earned);
   END IF;

p_prev_sal := 0;
p_prev_ent_alw := 0;
p_prev_pt := 0;
p_prev_tds := 0;
p_prev_pf := 0;
p_prev_super := 0;
p_prev_govt_ent_alw := 0;
p_prev_grat := 0;
p_prev_leave_encash := 0;
p_prev_retr_amt := 0;
p_designation := 'X';
p_annual_sal := 0;
p_pf_number := 'X';
p_pf_estab_code := 'X';
p_epf_number := 'X';
p_emplr_class := 'X';
p_ltc_curr_block := 0;
p_vrs_amount := 0;
p_prev_sc  := 0;
p_prev_cess := 0;
p_prev_sec_and_he_cess := 0;
p_prev_exemp_80gg := 0;
p_prev_med_reimburse_amt := 0;
p_prev_exemp_80ccd :=0;
p_prev_cghs_exemp_80d := 0;

l_start := get_financial_year_start(p_date_earned);
l_end   := get_financial_year_end(p_date_earned);

Open c_prev_emp_details;
Loop

   Fetch c_prev_emp_details
   Into l_designation,l_annual_sal,l_pf_number,l_pf_estab_code,l_epf_number,l_emplr_class,
        l_ltc_curr,l_leave_encash,l_grat,l_retr_amt,l_vrs_amount,l_sal,l_pf,l_ent,l_pt,l_tds,
        l_super,l_prev_sc, l_prev_cess,l_prev_exemp_80gg,l_prev_med_reimburse_amt,l_prev_sec_and_he_cess,l_prev_exemp_80ccd,
        l_prev_cghs_exemp_80d,l_end_date;
   If c_prev_emp_details%NotFound Then
     Close c_prev_emp_details;
     Return 0;
   End if;

   If l_end_date BETWEEN l_start AND l_end then
     p_prev_sal := p_prev_sal + l_sal;
     p_prev_pt  := p_prev_pt  + l_pt;
     p_prev_tds := p_prev_tds + l_tds;
     p_prev_pf := p_prev_pf + l_pf;
     p_prev_super := p_prev_super + l_super;
     p_prev_sc := p_prev_sc + l_prev_sc;
     p_prev_cess := p_prev_cess + l_prev_cess;
     p_prev_sec_and_he_cess := p_prev_sec_and_he_cess + l_prev_sec_and_he_cess;
     p_prev_exemp_80gg :=p_prev_exemp_80gg + l_prev_exemp_80gg;
     p_prev_med_reimburse_amt := p_prev_med_reimburse_amt + l_prev_med_reimburse_amt;
     p_prev_exemp_80ccd := p_prev_exemp_80ccd + l_prev_exemp_80ccd;
     IF ( l_emplr_class = 'CG' OR l_emplr_class = 'CGC' OR l_emplr_class = 'SG' OR l_emplr_class = 'SGC') THEN
     p_prev_cghs_exemp_80d := p_prev_cghs_exemp_80d + l_prev_cghs_exemp_80d;
     END IF;
     If (l_emplr_class = 'CG' or l_emplr_class = 'SG') Then
       p_prev_govt_ent_alw := p_prev_govt_ent_alw + l_ent;
     Else
       p_prev_ent_alw := p_prev_ent_alw + l_ent;
     End if;
   End if;

  p_prev_retr_amt := p_prev_retr_amt + l_retr_amt;
  If (l_emplr_class <> 'CG' and l_emplr_class <> 'SG') Then
    p_prev_leave_encash := p_prev_leave_encash + l_leave_encash;
  End If;
-- Fix for bug 3980777 starts
  If (l_emplr_class NOT IN ('CG','SG','LA')) Then
      p_prev_grat := p_prev_grat + l_grat;
  End If;
-- Fix for bug 3980777 ends
  p_vrs_amount := p_vrs_amount + l_vrs_amount;
  p_emplr_class := l_emplr_class;
 End Loop;
Close c_prev_emp_details;

   IF (g_debug)
   THEN
        pay_in_utils.trace('p_assignment_id    ',p_assignment_id    );
        pay_in_utils.trace('p_date_earned      ',p_date_earned      );
        pay_in_utils.trace('p_prev_sal         ',p_prev_sal         );
        pay_in_utils.trace('p_prev_tds         ',p_prev_tds         );
        pay_in_utils.trace('p_prev_pt          ',p_prev_pt          );
        pay_in_utils.trace('p_prev_ent_alw     ',p_prev_ent_alw     );
        pay_in_utils.trace('p_prev_pf          ',p_prev_pf          );
        pay_in_utils.trace('p_prev_super       ',p_prev_super       );
        pay_in_utils.trace('p_prev_govt_ent_alw',p_prev_govt_ent_alw);
        pay_in_utils.trace('p_prev_grat        ',p_prev_grat        );
        pay_in_utils.trace('p_prev_leave_encash',p_prev_leave_encash);
        pay_in_utils.trace('p_prev_retr_amt    ',p_prev_retr_amt    );
        pay_in_utils.trace('p_designation      ',p_designation      );
        pay_in_utils.trace('p_annual_sal       ',p_annual_sal       );
        pay_in_utils.trace('p_pf_number        ',p_pf_number        );
        pay_in_utils.trace('p_pf_estab_code    ',p_pf_estab_code    );
        pay_in_utils.trace('p_epf_number       ',p_epf_number       );
        pay_in_utils.trace('p_emplr_class      ',p_emplr_class      );
        pay_in_utils.trace('p_ltc_curr_block   ',p_ltc_curr_block   );
        pay_in_utils.trace('p_vrs_amount       ',p_vrs_amount       );
        pay_in_utils.trace('p_prev_sc          ',p_prev_sc          );
        pay_in_utils.trace('p_prev_cess        ',p_prev_cess        );
        pay_in_utils.trace('p_prev_exemp_80gg  ',p_prev_exemp_80gg  );
        pay_in_utils.trace('p_prev_med_reimburse_amt',p_prev_med_reimburse_amt);
        pay_in_utils.trace('p_prev_exemp_80ccd' ,p_prev_exemp_80ccd);
        pay_in_utils.trace('p_prev_cghs_exemp_80d' ,p_prev_cghs_exemp_80d);
   END IF;
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
Return 0;

End prev_emplr_details;

--------------------------------------------------------------------------
-- Name           : other_allowance_details                             --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get details for Other Allowances        --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION other_allowance_details
                  ( p_element_type_id in number
                   ,p_date_earned in date
                   ,p_allowance_name out NOCOPY varchar2
                   ,p_allowance_category out NOCOPY varchar2
                   ,p_max_exemption_amount out NOCOPY number
                   ,p_nature_of_expense OUT NOCOPY VARCHAR2 )
Return Number is

Cursor c_alw_details is
  Select element_information1,
         element_information2,
         element_information3,
         element_information4
    From pay_element_types_f
   Where element_type_id = p_element_type_id
     and p_date_earned between effective_start_date and effective_end_date;

  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'other_allowance_details';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_element_type_id',p_element_type_id);
        pay_in_utils.trace('p_date_earned',p_date_earned);
   END IF;


  OPEN c_alw_details;
  FETCH c_alw_details
  INTO  p_allowance_name,
        p_allowance_category,
        p_max_exemption_amount,
        p_nature_of_expense;
  CLOSE c_alw_details;

   IF (g_debug)
   THEN
        pay_in_utils.set_location(g_debug,'Out Paramters value is',20);
        pay_in_utils.trace('p_allowance_name      ',p_allowance_name);
        pay_in_utils.trace('p_allowance_category  ',p_allowance_category);
        pay_in_utils.trace('p_max_exemption_amount',p_max_exemption_amount);
        pay_in_utils.trace('p_nature_of_expense   ',p_nature_of_expense);
   END IF;

   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  Return 0;
END other_allowance_details;

--------------------------------------------------------------------------
-- Name           : get_disability_details                              --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the Disability Details of a person  --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_disability_details( p_assignment_id in number
                                ,p_date_earned in date
                                ,p_disable_catg out nocopy varchar2
                                ,p_disable_degree out nocopy number
                                ,p_disable_proof out  NOCOPY varchar2)
Return Number is

 Cursor c_disab_details is
   select pdf.category,pdf.degree,pdf.dis_information1
     from per_disabilities_f pdf,
          per_all_assignments_f paa
    where paa.assignment_id = p_assignment_id
      and paa.person_id = pdf.person_id
      and p_date_earned between paa.effective_start_date and paa.effective_end_date
      and p_date_earned between pdf.effective_start_date and pdf.effective_end_date
      order by nvl(pdf.dis_information1,'N') desc;

 l_catg Varchar2(10);
 l_degree number;
 l_proof Varchar2(10);
 l_procedure   VARCHAR2(250);
 l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_disability_details';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_id',p_assignment_id);
        pay_in_utils.trace('p_date_earned',p_date_earned);
   END IF;

  l_catg := 'XX';
  l_degree := 0;
  l_proof := 'N';

  Open c_disab_details;
  Fetch c_disab_details into l_catg,l_degree,l_proof;
  Close c_disab_details;

  p_disable_catg := l_catg;
  p_disable_degree := l_degree;
  p_disable_proof := l_proof;

  IF (g_debug)
  THEN
       pay_in_utils.set_location(g_debug,'Out Paramters value is',20);
       pay_in_utils.trace('p_disable_catg      ',p_disable_catg);
       pay_in_utils.trace('p_disable_degree  ',p_disable_degree);
       pay_in_utils.trace('p_disable_proof',p_disable_proof);
  END IF;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  Return 0;

END get_disability_details;

--------------------------------------------------------------------------
-- Name           : get_age                                             --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to check the age of the employee           --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_age(p_assignment_id in number,p_date_earned in date)
Return number is

Cursor c_dob is
  select pap.date_of_birth
    from per_all_people_f pap,
         per_all_assignments_f paa
   where paa.assignment_id = p_assignment_id
     and pap.person_id = paa.person_id
         and p_date_earned between paa.effective_start_date and paa.effective_end_date
         and p_date_earned between pap.effective_start_date and pap.effective_end_date;

l_dob date;
l_cur_fin_year_end date;
l_age number;

  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_age';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_id',p_assignment_id);
        pay_in_utils.trace('p_date_earned',p_date_earned);
   END IF;


  Open c_dob;
  Fetch c_dob into l_dob;
  Close c_dob;

  l_cur_fin_year_end := get_financial_year_end(p_date_earned);

  l_age := trunc((l_cur_fin_year_end - l_dob)/365);

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_cur_fin_year_end',l_cur_fin_year_end);
        pay_in_utils.trace('l_age',l_age);
   END IF;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  Return l_age;

END get_age;

--------------------------------------------------------------------------
-- Name           : act_rent_paid                                       --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the actual rent paid value          --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION act_rent_paid(p_assignment_action_id IN number
                      ,p_date_earned IN date)
 Return NUMBER is

Cursor c_act_rent_paid(l_element_entry_id IN number,l_curr_mon IN Varchar2) is
select pev.screen_entry_value
  from pay_element_entries_f pee,
       pay_element_entry_values_f pev,
       pay_input_values_f piv
 where pee.element_entry_id = l_element_entry_id
   and pev.element_entry_id = pee.element_entry_id
   and pee.element_type_id  = piv.element_type_id
   and pev.input_value_id   = piv.input_value_id
   and piv.name = l_curr_mon
   and p_date_earned between pev.effective_start_date and pev.effective_end_date
   and p_date_earned between pee.effective_start_date and pee.effective_end_date
   and p_date_earned between piv.effective_start_date and piv.effective_end_date;


l_hri_entry_id pay_element_entries_f.element_entry_id%type;
l_rent_paid varchar2(10);
l_year_start         date;
l_year_end           date;
l_entry_type_flag    varchar2(2) ;
l_entry_end_date     date;
l_curr_mon varchar2(3);
l_procedure   VARCHAR2(250);
l_message     VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'act_rent_paid';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_action_id',p_assignment_action_id);
        pay_in_utils.trace('p_date_earned',p_date_earned);
   END IF;

l_year_start := pay_in_tax_utils.get_financial_year_start(p_date_earned);
l_year_end   := pay_in_tax_utils.get_financial_year_end(p_date_earned);

l_curr_mon := to_char(p_date_earned,'MON');

l_hri_entry_id := get_house_rent_info_entry_id(p_assignment_action_id,
                                               p_date_earned,
                                               l_year_start,
                                               l_year_end,
                                               l_entry_type_flag,
                                               l_entry_end_date );

IF (g_debug)
THEN
     pay_in_utils.trace('l_year_start',l_year_start);
     pay_in_utils.trace('l_year_end',l_year_end);
     pay_in_utils.trace('l_curr_mon',l_curr_mon);
     pay_in_utils.trace('l_hri_entry_id',l_hri_entry_id);
END IF;

If l_entry_type_flag = 'E' Then
  Open c_act_rent_paid(l_hri_entry_id,l_curr_mon);
  Fetch c_act_rent_paid INTO l_rent_paid;
  Close c_act_rent_paid;

  pay_in_utils.set_location(g_debug,'Rent paid is' || l_rent_paid,20);
  pay_in_utils.trace('**************************************************','********************');
  Return fnd_number.canonical_to_number(l_rent_paid);
Else
  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
  Return 0;
End If;

END act_rent_paid;

--------------------------------------------------------------------------
-- Name           : check_ee_exists                                     --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to check if EE exists                      --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION check_ee_exists(p_element_name   IN VARCHAR2
                        ,p_assignment_id  IN NUMBER
                        ,p_effective_date IN DATE
                        ,p_element_entry_id OUT NOCOPY NUMBER
                        ,p_start_date       OUT NOCOPY DATE
                        ,p_ee_ovn           OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
  CURSOR csr_asg_details
  IS
    SELECT  asg.business_group_id
           ,asg.payroll_id
    FROM   per_assignments_f asg
    WHERE  asg.assignment_id     = p_assignment_id
    AND    asg.primary_flag      = 'Y'
    AND    p_effective_date  BETWEEN asg.effective_start_date
                            AND      asg.effective_end_date ;

  CURSOR csr_element_link (l_business_group_id IN NUMBER,
                           l_payroll_id        IN NUMBER)
  IS
    SELECT pel.element_link_id
    FROM   pay_element_links_f pel,
           pay_element_types_f pet
    WHERE  pet.element_name      = p_element_name
    AND    pet.element_type_id   = pel.element_type_id
    AND    (pel.payroll_id       = l_payroll_id
           OR (pel.payroll_id IS NULL
              AND pel.link_to_all_payrolls_flag = 'Y' ) )
    AND    pel.business_group_id = l_business_group_id
    AND    p_effective_date  BETWEEN pet.effective_start_date
                             AND     pet.effective_end_date
    AND    p_effective_date  BETWEEN pel.effective_start_date
                             AND     pel.effective_end_date ;


  CURSOR csr_element_entry (c_element_link_id IN NUMBER)
  IS
    SELECT element_entry_id
          ,object_version_number
          ,effective_start_date
    FROM   pay_element_entries_f
    WHERE  assignment_id   = p_assignment_id
    AND    element_link_id = c_element_link_id
    AND    p_effective_date BETWEEN effective_start_date
                            AND     effective_end_date ;

  l_business_group_id      NUMBER;
  l_element_link_id        NUMBER;
  l_payroll_id             NUMBER;
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'check_ee_exists';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_element_name  ',p_element_name  );
        pay_in_utils.trace('p_assignment_id ',p_assignment_id );
        pay_in_utils.trace('p_effective_date',p_effective_date);
   END IF;
   p_element_entry_id := NULL;
   p_ee_ovn := NULL;

   OPEN csr_asg_details;
   FETCH csr_asg_details
   INTO  l_business_group_id, l_payroll_id;
   CLOSE csr_asg_details;

   IF g_debug THEN
      hr_utility.trace('Business Group ID : '||l_business_group_id);
      hr_utility.trace('Payroll ID : '||l_payroll_id);
   END IF;

   OPEN csr_element_link (l_business_group_id, l_payroll_id);
   FETCH csr_element_link INTO l_element_link_id;

   IF csr_element_link%NOTFOUND OR l_element_link_id IS NULL THEN
       CLOSE csr_element_link;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN FALSE;
   ELSE
       IF g_debug THEN
          hr_utility.trace('Element Link ID : '||l_element_link_id);
       END IF;

       CLOSE csr_element_link;
     --
       OPEN csr_element_entry(l_element_link_id) ;
       FETCH csr_element_entry INTO p_element_entry_id, p_ee_ovn, p_start_date ;
       IF g_debug then
          hr_utility.trace('Element Entry ID : '||p_element_entry_id);
       END IF;

       IF p_element_entry_id IS NULL OR csr_element_entry%NOTFOUND
       THEN
          CLOSE csr_element_entry;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN FALSE;
       END IF;
   END IF;
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
   RETURN TRUE;
--
END check_ee_exists;
--------------------------------------------------------------------------
-- Name           : get_entry_earliest_start_date                       --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to find the earliest start date of an      --
--                  element entry                                       --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_entry_earliest_start_date(p_element_entry_id IN NUMBER
                                      ,p_element_type_id  IN NUMBER
                                      ,p_assignment_id    IN NUMBER
                                      )
RETURN DATE IS

  CURSOR c_get_earliest_start_Date
  IS
  SELECT MIN(pee.effective_start_date)
    FROM pay_element_entries_f pee
   WHERE pee.element_entry_id =p_element_entry_id
     AND pee.assignment_id =p_assignment_id
     AND pee.element_type_id =p_element_type_id;

  l_date DATE;
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_date_earned';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_element_entry_id',p_element_entry_id);
        pay_in_utils.trace('p_element_type_id ',p_element_type_id);
        pay_in_utils.trace('p_assignment_id   ',p_assignment_id);
   END IF;


  OPEN c_get_earliest_start_Date;
  FETCH c_get_earliest_start_Date INTO l_date;
  CLOSE c_get_earliest_start_Date;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_date',l_date);
   END IF;

RETURN l_date;
END get_entry_earliest_start_date;

--------------------------------------------------------------------------
-- Name           : get_projected_loan_perquisite                       --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the Projected Loan perquisite value --
--                  for the rest of the tax year                        --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_projected_loan_perquisite(p_outstanding_balance   IN NUMBER
                                      ,p_remaining_period      IN NUMBER
                                      ,p_employee_contribution IN NUMBER
                                      ,p_interest              IN NUMBER
                                      ,p_concessional_interest IN NUMBER
                                      )
RETURN NUMBER IS
  p_value  number;
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_projected_loan_perquisite';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_outstanding_balance  ',p_outstanding_balance  );
        pay_in_utils.trace('p_remaining_period     ',p_remaining_period     );
        pay_in_utils.trace('p_employee_contribution',p_employee_contribution);
        pay_in_utils.trace('p_interest             ',p_interest             );
        pay_in_utils.trace('p_concessional_interest',p_concessional_interest);
   END IF;



  p_value :=0;

  FOR i in 1..p_remaining_period LOOP
    -- Added additional check for Bugfix 3956926
    IF (p_outstanding_balance - (i* p_employee_contribution)) >=0 THEN
      p_value := p_value + ((p_outstanding_balance - (i* p_employee_contribution))
                         *(p_interest - p_concessional_interest)/(12*100));
    END IF;
  END LOOP;

  IF (g_debug)
  THEN
      pay_in_utils.trace('p_value',p_value);
  END IF;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

RETURN p_value;

END get_projected_loan_perquisite;

--------------------------------------------------------------------------
-- Name           : get_perquisite_details                              --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the exemption amount of Other Perks --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_perquisite_details (p_element_type_id       IN NUMBER
                                ,p_date_earned           IN DATE
                                ,p_assignment_action_id  IN NUMBER
                                ,p_assignment_id         IN NUMBER
                                ,p_business_group_id     IN NUMBER
                                ,p_element_entry_id      IN NUMBER
                                ,p_emp_status            IN VARCHAR2
                                ,p_taxable_flag          OUT NOCOPY VARCHAR2
                                ,p_exemption_amount      OUT NOCOPY NUMBER
                                )
RETURN NUMBER IS
  CURSOR c_get_perk_details IS
  SELECT element_information1
            ,NVL(element_information6,'Y')
    FROM pay_element_types_f
   WHERE element_type_id = p_element_type_id
     AND p_date_earned BETWEEN effective_start_date AND effective_end_date;

  CURSOR c_exemption (p_perk_name IN VARCHAR2) IS
   SELECT fnd_number.canonical_to_number(exemption_amount)
     FROM pay_in_other_perquisites_v
   WHERE  perquisite_name = p_perk_name;

   l_perk_name     pay_element_types_f.element_information1%TYPE;
   l_procedure     VARCHAR2(100);
   l_message       VARCHAR2(255);

BEGIN
  g_debug := hr_utility.debug_enabled ;
  l_procedure :=  'pay_in_tax_utils.get_perquisite_details' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_taxable_flag := 'Y';

  OPEN c_get_perk_details;
  FETCH c_get_perk_details INTO l_perk_name ,p_taxable_flag;
  CLOSE c_get_perk_details;

  pay_in_utils.set_location(g_debug,l_procedure,20);

  OPEN c_exemption (l_perk_name);
  FETCH c_exemption INTO p_exemption_amount;
  CLOSE c_exemption;

  IF p_exemption_amount IS NULL
  THEN
     p_exemption_amount := 0;
  END IF ;
  RETURN 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN -1;
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,' Leaving : '||l_procedure, 40);
      hr_utility.trace(l_message);
      RETURN -1;

END get_perquisite_details;

--------------------------------------------------------------------------
-- Name           : calculate_80gg_exemption                            --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to calculate Sec 80GG Exemption            --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION calculate_80gg_exemption (p_assact_id          IN NUMBER
                                  ,p_assignment_id      IN NUMBER
                                  ,p_payroll_id         IN NUMBER
                                  ,p_effective_date     IN DATE
                                  ,p_std_exemption      IN NUMBER
                                  ,p_adj_tot_income     IN NUMBER
                                  ,p_std_exem_percent   IN NUMBER
                                  ,p_start_period_num   IN NUMBER
                                  ,p_last_period_number IN NUMBER
                                  ,p_flag               IN VARCHAR2)
 RETURN NUMBER IS

  l_rent_paid_tbl      t_rent_paid ;
  l_month_tbl          t_month ;
  l_year_start         date;
  l_year_end           date;
  l_hri_entry_id        pay_element_entries_f.element_entry_id%type;
  l_entry_type_flag    varchar2(2) ;
  l_entry_end_date     date;

  l3 number;
  l_80_exem number;
  l_10percent_adj_tot_inc number;
  l_25percent_adj_tot_inc number;
  l_adj_tot_inc number;
  l_def_bal_id pay_defined_balances.defined_balance_id%type;
  l_def_bal_id_80gg pay_defined_balances.defined_balance_id%type;
  l_def_bal_id_advance pay_defined_balances.defined_balance_id%type;
  l_assact_tbl   t_assact ;
  l_eff_date_tbl t_eff_date;
  l_hra number;
  l_curr_period_num number;
  l_80gg_flag VARCHAR2(3);
  l_element_name pay_element_types_f.element_name %TYPE;
  l_input_name   pay_input_values_f.name%TYPE;

  CURSOR c_claim_80gg_flag(c_assignment_action_id NUMBER
                          ,c_element_name IN VARCHAR2
                          ,c_input_name   IN VARCHAR2) IS
  SELECT prv.result_value
    FROM pay_run_result_values prv,
         pay_run_results prr,
         pay_input_values_f piv,
         pay_element_types_f pet
   WHERE prv.run_result_id = prr.run_result_id
     AND prr.assignment_action_id = c_assignment_action_id
     AND prr.element_type_id = pet.element_type_id
     AND pet.element_name = c_element_name
     AND piv.element_type_id = pet.element_type_id
     AND piv.name = c_input_name
     AND piv.input_value_id = prv.input_value_id
     AND pet.legislation_code = 'IN'
     AND piv.legislation_code = 'IN';

  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'calculate_80gg_exemption';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assact_id         ',p_assact_id         );
        pay_in_utils.trace('p_assignment_id     ',p_assignment_id     );
        pay_in_utils.trace('p_payroll_id        ',p_payroll_id        );
        pay_in_utils.trace('p_effective_date    ',p_effective_date    );
        pay_in_utils.trace('p_std_exemption     ',p_std_exemption     );
        pay_in_utils.trace('p_adj_tot_income    ',p_adj_tot_income    );
        pay_in_utils.trace('p_std_exem_percent  ',p_std_exem_percent  );
        pay_in_utils.trace('p_start_period_num  ',p_start_period_num  );
        pay_in_utils.trace('p_last_period_number',p_last_period_number);
        pay_in_utils.trace('p_flag              ',p_flag              );
   END IF;

   l3 := 0;
   l_80_exem := 0;
   l_adj_tot_inc := 0;

   l_curr_period_num := get_period_number(p_payroll_id,p_effective_date);
   l_def_bal_id := get_defined_balance('House Rent Allowance','_ASG_PTD');
   l_def_bal_id_advance := get_defined_balance('Adjusted Advance for HRA','_ASG_PTD');
   l_def_bal_id_80gg := get_defined_balance('Adjusted Total Income for 80GG','_ASG_PTD');
   l_year_start := pay_in_tax_utils.get_financial_year_start(p_effective_date );
   l_year_end   := pay_in_tax_utils.get_financial_year_end(p_effective_date );

   IF l_year_start = to_date('01-04-2004','dd-mm-yyyy') THEN
     l_element_name :='Deductions under Chapter VI A';
     l_input_name   := 'Claim Exemption Sec 80GG';
   ELSE
     l_element_name := 'Deduction under Section 80GG';
     l_input_name   := 'Claim Exemption';
   END IF;

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_element_name',l_element_name);
        pay_in_utils.trace('l_input_name',l_input_name);
   END IF;

   l_hri_entry_id := get_house_rent_info_entry_id(p_assact_id,
                                                  p_effective_date,
                                                  l_year_start,
                                                  l_year_end,
                                                  l_entry_type_flag,
                                                  l_entry_end_date );

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_hri_entry_id',l_hri_entry_id);
   END IF;

   get_monthly_rent( l_hri_entry_id,
                     p_effective_date,
                     l_entry_type_flag,
                     l_entry_end_Date,
                     p_payroll_id,
                     l_rent_paid_tbl,
                     l_month_tbl  );

  get_monthly_max_assact(p_assignment_id,l_year_start,l_year_end,l_assact_tbl,l_eff_date_tbl);


  IF l_assact_tbl.COUNT > 0 THEN

    FOR i IN p_start_period_num..p_last_period_number LOOP
        l3 := 0;
        l_25percent_adj_tot_inc := 0.25 * p_adj_tot_income;
        l_10percent_adj_tot_inc := p_std_exem_percent * p_adj_tot_income;

        IF i < l_curr_period_num  THEN

           IF i <= l_assact_tbl.COUNT AND l_assact_tbl(i) > 0 THEN

              OPEN c_claim_80gg_flag(l_assact_tbl(i),l_element_name,l_input_name);
              FETCH c_claim_80gg_flag INTO l_80gg_flag;
              /* Bug 4224201 Starts */
                IF c_claim_80gg_flag%NOTFOUND THEN
                   l_80gg_flag := 'N';
                END IF;
              /* Bug 4224201 Ends */
              CLOSE c_claim_80gg_flag;

              l_hra := pay_balance_pkg.get_value(l_def_bal_id,l_assact_tbl(i))
                       + pay_balance_pkg.get_value(l_def_bal_id_advance,l_assact_tbl(i));

              l_adj_tot_inc := pay_balance_pkg.get_value(l_def_bal_id_80gg,l_assact_tbl(i));
              l_25percent_adj_tot_inc := 0.25 * l_adj_tot_inc;
              l_10percent_adj_tot_inc := p_std_exem_percent * l_adj_tot_inc;

              IF l_hra = 0 AND l_80gg_flag = 'Y' THEN
                 l3 := GREATEST (l_rent_paid_tbl(i) - l_10percent_adj_tot_inc,0);
              END IF;
           ELSE
             l3:= 0;
           END IF;

        ELSIF p_flag = 'Y'  THEN

          l3 := GREATEST (l_rent_paid_tbl(i) - l_10percent_adj_tot_inc,0);

        END IF;

        l_80_exem := l_80_exem + LEAST (p_std_exemption,l_25percent_adj_tot_inc,l3);

    END LOOP;

  END IF;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  RETURN l_80_exem;
END calculate_80gg_exemption;

--------------------------------------------------------------------------
-- Name           : check_ltc_exemption                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to check the LTC Exemptions                --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION check_ltc_exemption(p_element_type_id      IN NUMBER
                          ,p_date_earned            IN DATE
                          ,p_assignment_action_id   IN NUMBER
                          ,p_assignment_id          IN NUMBER
                          ,p_element_entry_id       IN NUMBER
                          ,p_carry_over_flag        IN OUT  NOCOPY VARCHAR2
                          ,p_exempted_flag          IN OUT NOCOPY VARCHAR2
                          )
RETURN NUMBER IS
/* Cursor to find the LTC Block at the given effective Date */
  CURSOR c_ltc_block(p_date DATE)
      IS
  SELECT hrl.lookup_code
        ,hrl.meaning
    FROM hr_lookups hrl
   WHERE hrl.lookup_type ='IN_LTC_BLOCK'
     AND to_number(to_char(p_date,'YYYY')) BETWEEN
         to_number(SUBSTR(HRL.LOOKUP_CODE,1,4)) AND  to_number(SUBSTR(HRL.LOOKUP_CODE,8,4)) ;


/* Cursor to find the LTC Availed in Previous employment given the  LTC Block Start and End Dates */
  CURSOR c_prev_employer_ltc_availed(p_start_date date
                                    ,p_end_date date
                                    ,p_assignment_id NUMBER)
      IS
  SELECT sum(nvl(ppm.pem_information8,0))
    FROM per_previous_employers ppm,
         per_all_assignments_f paa
   WHERE paa.assignment_id = p_assignment_id
     AND p_date_earned BETWEEN paa.effective_start_date AND paa.effective_end_date
     AND paa.person_id =ppm.person_id
     AND ppm.end_date BETWEEN p_start_date and p_end_date;


 /*  LTC element entries processed in current payroll run for a given 'carry over from previous block' flag */

 CURSOR c_entry_id (p_input_value_id NUMBER
                  , p_flag_value     VARCHAR2
                  )
     IS
  SELECT ee.element_entry_id
    FROM pay_assignment_actions aa,
         pay_payroll_actions    pa,
         pay_element_entries_f  ee,
         pay_element_links_f    el,
         pay_element_types_f    et,
         pay_element_entry_values_f peev
   WHERE aa.payroll_action_id = pa.payroll_action_id
     AND aa.assignment_id     = ee.assignment_id
     and ee.element_entry_id  = peev.element_entry_id
     and peev.input_value_id  = p_input_value_id
     and nvl(peev.screen_entry_value,'N') =  p_flag_value
     AND pa.date_earned BETWEEN ee.effective_start_date
                        AND     ee.effective_end_date
     AND pa.date_earned BETWEEN peev.effective_start_date
                        AND     peev.effective_end_date
     AND ee.element_link_id   = el.element_link_id
     AND pa.date_earned BETWEEN el.effective_start_date
                        AND     el.effective_end_date
     AND el.element_type_id   = et.element_type_id
     AND et.element_type_id= p_element_type_id
     AND pa.date_earned  BETWEEN et.effective_start_date
                         AND     et.effective_end_date
     AND aa.assignment_action_id = p_assignment_action_id
     AND NOT EXISTS (SELECT 1 FROM pay_quickpay_exclusions pqe
                      WHERE pqe.assignment_action_id =nvl(aa.source_action_id,aa.assignment_Action_id)
		      AND pqe.element_entry_id = ee.element_entry_id)
    ORDER BY ee.element_entry_id  ;

 /* Cursor to find the screen entry value */
  CURSOR c_entry_values(l_entry_id NUMBER
                       ,l_input_value_id NUMBER) IS
   SELECT peev.screen_entry_value
     FROM pay_element_entry_values_f peev
    WHERE peev.element_entry_id = l_entry_id
      AND peev.input_value_id   = l_input_value_id
      AND p_date_earned between peev.effective_start_date  and peev.effective_end_date;

/* Cursor to find input value id given the element and input value name*/
   CURSOR c_input_value_id(p_input_name VARCHAR2)
       IS
   SELECT piv.input_value_id
     FROM pay_input_values_f piv
    WHERE piv.element_type_id = p_element_type_id
      AND piv.NAME = p_input_name
      AND p_date_earned BETWEEN piv.effective_start_date AND piv.effective_end_date;

   /* Cursor to find the the global value as on date earned */
    CURSOR c_global_value(l_global_name VARCHAR2) IS
    SELECT global_value
      from ff_globals_f ffg
     WHERE ffg.global_name = l_global_name
       AND p_date_earned BETWEEN ffg.effective_start_date AND ffg.effective_end_date;

  /* Cursor to find the count of LTC entries already processed in an LTC block,given the block start and end dates, the value of carry over flag and the value of exempted flag  */
   CURSOR c_curr_emplr_ltc_block(p_start_date DATE
                                ,p_end_date    DATE
                                ,p_carry_over  VARCHAR2
                                ,p_exempted   VARCHAR2
                                ,p_carry_over_id NUMBER
                                ,p_exempted_id NUMBER)
   IS
   SELECT count(*)
   FROM pay_run_results prr
       ,pay_run_result_values prrv1
       ,pay_run_result_values prrv2
       ,pay_assignment_actions paa
       ,pay_payroll_actions ppa
  where prr.run_result_id =prrv1.run_result_id
    and prrv1.input_value_id = p_exempted_id
    and prrv2.input_value_id = p_carry_over_id
    and prr.run_result_id =prrv2.run_result_id
    and prrv1.result_value = p_exempted
    and nvl(prrv2.result_value,'N') = p_carry_over
    and prr.element_type_id =p_element_type_id
    and prr.assignment_action_id =paa.assignment_action_id
    AND paa.assignment_action_id <= p_assignment_action_id
    and paa.assignment_id = p_assignment_id
    and prr.status in ('P','PA')
    and paa.payroll_action_id =ppa.payroll_action_id
    and ppa.date_earned BETWEEN p_start_date and p_end_date;

  TYPE tab_entry_id IS TABLE OF pay_element_entries_f.element_entry_id%TYPE INDEX BY BINARY_INTEGER;
  l_element_entry_id tab_entry_id;
  l_curr_element_entry  tab_entry_id;

  l_max_ltc NUMBER;
  l_carry_over_entry_count NUMBER;
  l_curr_block HR_LOOKUPS.LOOKUP_CODE%TYPE;
  l_curr_period HR_LOOKUPS.meaning%TYPE;
  l_curr_end_date DATE;
  l_curr_start_date DATE;

  l_prev_blk_date DATE;
  l_prev_block HR_LOOKUPS.LOOKUP_CODE%TYPE;
  l_prev_period HR_LOOKUPS.meaning%TYPE;
  l_prev_end_date DATE;
  l_prev_start_date DATE;


  i number;
  j number;
  k number;
  l_count number;
  l_procedure VARCHAR2(100);
  l_carry_over_id number;
  l_exempted_id number;

  l_prev_emplr_curr_blk NUMBER;
  l_curr_emplr_prev_blk NUMBER;
  l_prev_emplr_prev_blk NUMBER;
  l_curr_emplr_curr_blk_exempted NUMBER;
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'check_ltc_exemption';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

/*1.Find the LTC entries which have been carried over from previous LTC Block in the current run and store it in a PL/SQL table.
2.When such entries exist and the user enters the previous employment information after making element entries, we need to validate if the user can still opt for carry over. So,we find the LTC journeys made
in previous block in both current employment and previous employment and validate the entry.
3.If it is exempted, set the exempted flag and return .Else, copy this element entry in another PL/SQL table.
  For an invalid entry ,we need to set the carry over flag to 'No' .However ,this may or may not be exempted.
4.In case, carry over is not opted, we need to find the number of LTC exemptions already availed in current block
in both current and previous employment and then decide if the current journey is exempted or not.
*/

  k:=0;
  OPEN c_input_value_id('Carryover from Prev Block');
  FETCH c_input_value_id INTO l_carry_over_id;
  CLOSE c_input_value_id;

  OPEN c_input_value_id('Exempted');
  FETCH c_input_value_id INTO l_exempted_id;
  CLOSE c_input_value_id;

  OPEN c_entry_id(l_carry_over_id, 'Y');
    LOOP
      FETCH c_entry_id into l_element_entry_id(k);
      EXIT WHEN c_entry_id%NOTFOUND;
      pay_in_utils.set_location(g_debug,'Entry id with carry over as Yes in current run '|| l_element_entry_id(k),10);
      k := k+1;
    END LOOP;
  CLOSE c_entry_id;

  pay_in_utils.set_location(g_debug,'ASSIGNMENT ACTION ID '||p_assignment_action_id,20);

  OPEN c_global_value('IN_MAX_JOURNEY_BLOCK_LTC');
  FETCH c_global_value INTO l_max_ltc;
  CLOSE c_global_value;

  l_carry_over_entry_count := l_element_entry_id.COUNT;
  pay_in_utils.set_location(g_debug,'count is '||l_carry_over_entry_count,30);

 --------------------------
 --Carry over is opted
 --------------------------

  IF l_carry_over_entry_count >0 THEN
    /* CHECK IF THIS CARRY OVER IS VALID -- Get the Previous Block start and End Dates*/
    l_prev_blk_date := ADD_MONTHS(p_date_earned,-48);

    OPEN c_ltc_block(l_prev_blk_date);
    FETCH c_ltc_block INTO l_prev_block,l_prev_period;
    CLOSE c_ltc_block;

    l_prev_start_date := to_date(substr(l_prev_period,1,11),'DD-MM-YYYY');
    l_prev_end_date   := to_date(substr(l_prev_period,15,11),'DD-MM-YYYY');

    -- Previous Block Previous Employment
    OPEN c_prev_employer_ltc_availed(l_prev_start_date
                                    ,l_prev_end_date
                                    ,p_assignment_id );
    FETCH c_prev_employer_ltc_availed INTO l_prev_emplr_prev_blk;
    CLOSE c_prev_employer_ltc_availed;

    pay_in_utils.set_location(g_debug,'LTC in previous blk,previous employment '||l_prev_emplr_prev_blk,40);

    -- Previous Block Current Employment
    OPEN c_curr_emplr_ltc_block(l_prev_start_date
                               ,l_prev_end_date
                               ,'N' -- carry over
                               ,'Y' -- exempted
                               ,l_carry_over_id
                               ,l_exempted_id );
    FETCH c_curr_emplr_ltc_block INTO l_curr_emplr_prev_blk;
    CLOSE c_curr_emplr_ltc_block;

    pay_in_utils.set_location(g_debug,'LTC in previous blk,current employment '||l_curr_emplr_prev_blk,50);
    j := 0;

   --
   --  Start - Set the carry over flag appropriately
   --
    FOR i IN 0..l_carry_over_entry_count-1 LOOP
       IF (nvl(l_curr_emplr_prev_blk,0) + nvl(l_prev_emplr_prev_blk,0) +i < l_max_ltc) THEN

         IF (l_element_entry_id(i) = p_element_entry_id)    THEN
            p_carry_over_flag := 'Y';
            p_exempted_flag   := 'Y';

            IF l_curr_element_entry.COUNT > 0 THEN l_curr_element_entry.delete; END IF;
            IF l_element_entry_id.COUNT > 0 THEN l_element_entry_id.delete; END IF;

            RETURN 0;

         END IF;
         pay_in_utils.set_location(g_debug,'valid carryover ',60);
       ELSE
          pay_in_utils.set_location(g_debug,'invalid carryover ',70);
          l_curr_element_entry(j) := l_element_entry_id(i);
          j:=j+1;
       END IF;
    END LOOP;
   --
   --  End - Set the carry over flag appropriately
   --

      IF l_element_entry_id.COUNT > 0 THEN l_element_entry_id.delete; END IF;


    END IF;

 --------------------------
 --Carry over is not opted
 --------------------------
  l_count := l_curr_element_entry.COUNT;

  pay_in_utils.set_location(g_debug, 'not the carry over stuff',80);

  OPEN c_ltc_block(p_date_earned);
  FETCH c_ltc_block INTO l_curr_block,l_curr_period;
  CLOSE c_ltc_block;

  l_curr_start_date := to_date(substr(l_curr_period,1,11),'DD-MM-YYYY');
  l_curr_end_date   := to_date(substr(l_curr_period,15,11),'DD-MM-YYYY');

  -- Current Block Previous Employment
  OPEN c_prev_employer_ltc_availed(l_curr_start_date
                                  ,l_curr_end_date
                                  ,p_assignment_id );
  FETCH c_prev_employer_ltc_availed INTO l_prev_emplr_curr_blk;
  CLOSE c_prev_employer_ltc_availed;

  pay_in_utils.set_location(g_debug,'Previous Employer Current block '||l_prev_emplr_curr_blk,90);

  -- Current Block Current Employment Exempted LTC entries that have been processed
  OPEN c_curr_emplr_ltc_block(l_curr_start_date
                             ,l_curr_end_date
                             ,'N' --carry over
                             ,'Y' -- exempted
                             ,l_carry_over_id
                             ,l_exempted_id);
  FETCH c_curr_emplr_ltc_block INTO l_curr_emplr_curr_blk_exempted;
  CLOSE c_curr_emplr_ltc_block;

  pay_in_utils.set_location(g_debug,'l_count '||l_count||' '||l_curr_emplr_curr_blk_exempted||' '||l_prev_emplr_curr_blk ,100);

  /* Start - Find if the entries with invalid carry over are exempted in current block or not */
  IF l_count>0 then
    FOR i IN 0..l_count-1 LOOP
     IF(nvl(l_prev_emplr_curr_blk,0) +nvl(l_curr_emplr_curr_blk_exempted,0) + i < l_max_ltc ) THEN
       IF l_curr_element_entry(i)= p_element_entry_id THEN
         p_exempted_flag := 'Y';
         p_carry_over_flag := 'N';
       END IF;
     END IF;
    END LOOP;
    pay_in_utils.set_location(g_debug,'find exemption for invalid carry overs ',110);
  END IF;
  /* End - Find if the entries with invalid carry over are exempted in current block or not */

  k := l_count;
  OPEN c_entry_id(l_carry_over_id, 'N');
    LOOP
      FETCH c_entry_id into l_curr_element_entry(k);
      EXIT WHEN c_entry_id%NOTFOUND;
      pay_in_utils.set_location(g_debug,'Entry id with carry over  as No in current run '|| l_curr_element_entry(k),77);
      k := k+1;
    END LOOP;
  CLOSE c_entry_id;

  k := l_curr_element_entry.COUNT;
  pay_in_utils.set_location(g_debug,'Entry Count '||k,70);

  FOR i IN 0..k-1 LOOP
   IF(nvl(l_prev_emplr_curr_blk,0) +nvl(l_curr_emplr_curr_blk_exempted,0) + i < l_max_ltc ) THEN
     IF l_curr_element_entry(i)= p_element_entry_id THEN
        p_exempted_flag := 'Y';
     END IF;
   END IF;
  END LOOP;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

RETURN 0;

END check_ltc_exemption;

----------------------------------------------------------------------------
--                                                                        --
-- Name         : GET_BALANCE_VALUE                                       --
-- Type         : Function                                                --
-- Access       : Public                                                  --
-- Description  : Function to get the balance value                       --
--                                                                        --
-- Parameters   :                                                         --
--           IN : p_assignment_action_id       NUMBER                     --
--                p_balance_name               VARCHAR2                   --
--                p_dimension_name             VARCHAR2                   --
--                p_context_name               VARCHAR2                   --
--                p_context_value              VARCHAR2                   --
--       RETURN : NUMBER                                                  --
--                                                                        --
-- Change History :                                                       --
----------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                                 --
----------------------------------------------------------------------------
-- 1.0   06-Apr-04  statkar  Created this function                        --
----------------------------------------------------------------------------
FUNCTION get_balance_value
        (p_assignment_action_id IN NUMBER
        ,p_balance_name         IN pay_balance_types.balance_name%TYPE
        ,p_dimension_name       IN pay_balance_dimensions.dimension_name%TYPE
        ,p_context_name         IN ff_contexts.context_name%TYPE
        ,p_context_value        IN VARCHAR2
        )
RETURN NUMBER
IS
   l_balance_value    NUMBER ;
   l_message          VARCHAR2(255);
   l_procedure        VARCHAR2(100);
   l_def_bal_id       NUMBER ;
BEGIN
   g_debug          := hr_utility.debug_enabled;
   l_procedure      := g_package ||'get_balance_value';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure, 10);
   l_message := 'SUCCESS';

   l_def_bal_id := get_defined_balance
                                 (p_balance_type   => p_balance_name
                                 ,p_dimension_name => p_dimension_name);

   pay_in_utils.set_location(g_debug,l_procedure, 20);

   IF l_def_bal_id = -1 THEN
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure, 25);
      RETURN -1;
   END IF;

   IF g_debug THEN
      hr_utility.trace ('INDIA: Assignment Action Id : '||p_assignment_action_id);
      hr_utility.trace ('INDIA: Balance Name         : '||p_balance_name);
      hr_utility.trace ('INDIA: Dimension_name       : '||p_dimension_name);
      hr_utility.trace ('INDIA: Defined Balance Id   : '||l_def_bal_id);
      hr_utility.trace ('INDIA: Context Name         : '||p_context_name);
      hr_utility.trace ('INDIA: Context Value        : '||p_context_value);
   END IF;

   IF p_context_name = 'NULL' THEN
      pay_in_utils.set_location(g_debug,l_procedure, 30);
      l_balance_value := pay_balance_pkg.get_value
                         (p_assignment_action_id => p_assignment_action_id
                         ,p_defined_balance_id   => l_def_bal_id
                         ,p_tax_unit_id          => null
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );
    ELSE
      pay_in_utils.set_location(g_debug,l_procedure, 40);
      IF p_context_name NOT IN ('SOURCE_ID'
                               ,'SOURCE_TEXT'
                               ,'SOURCE_TEXT2'
                               ,'JURISDICTION_CODE'
                               ,'TAX_UNIT_ID')
      THEN
         pay_in_utils.set_location(g_debug,l_procedure, 50);
         l_balance_value := -1;
      ELSE
         pay_in_utils.set_location(g_debug,l_procedure, 60);
         pay_balance_pkg.set_context(p_context_name, p_context_value);
         IF p_context_name = 'SOURCE_ID' THEN
            pay_in_utils.set_location(g_debug,l_procedure, 70);
            l_balance_value := pay_balance_pkg.get_value
                         (p_assignment_action_id => p_assignment_action_id
                         ,p_defined_balance_id   => l_def_bal_id
                         ,p_tax_unit_id          => null
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => TO_NUMBER(p_context_value)
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );
         ELSIF p_context_name = 'SOURCE_TEXT' THEN
            pay_in_utils.set_location(g_debug,l_procedure, 80);
            l_balance_value := pay_balance_pkg.get_value
                         (p_assignment_action_id => p_assignment_action_id
                         ,p_defined_balance_id   => l_def_bal_id
                         ,p_tax_unit_id          => null
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => p_context_value
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );
         ELSIF p_context_name = 'SOURCE_TEXT2' THEN
            pay_in_utils.set_location(g_debug,l_procedure, 90);
            l_balance_value := pay_balance_pkg.get_value
                         (p_assignment_action_id => p_assignment_action_id
                         ,p_defined_balance_id   => l_def_bal_id
                         ,p_tax_unit_id          => null
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => p_context_value
                         ,p_source_number        => null
                         );
         ELSIF p_context_name = 'JURISDICTION_CODE' THEN
            pay_in_utils.set_location(g_debug,l_procedure, 100);
            l_balance_value := pay_balance_pkg.get_value
                         (p_assignment_action_id => p_assignment_action_id
                         ,p_defined_balance_id   => l_def_bal_id
                         ,p_tax_unit_id          => null
                         ,p_jurisdiction_code    => p_context_value
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );
         ELSIF p_context_name = 'TAX_UNIT_ID' THEN
                pay_in_utils.set_location(g_debug,l_procedure, 110);
            l_balance_value := pay_balance_pkg.get_value
                         (p_assignment_action_id => p_assignment_action_id
                         ,p_defined_balance_id   => l_def_bal_id
                         ,p_tax_unit_id          => TO_NUMBER(p_context_value)
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );
          END IF;
       END IF;
    END IF;

    hr_utility.trace ('INDIA: Balance Value        : '||to_char(l_balance_value));
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure, 120);
    RETURN l_balance_value;

EXCEPTION
   WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      hr_utility.trace(l_message);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 130);
      RETURN -1;
END get_balance_value;


--------------------------------------------------------------------------
-- Name           : get_org_id                                          --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the Org Id of PF/ESI/PT Organization--
--                  on a particular date                                --
-- Parameters     :                                                     --
--             IN : p_assignment_id        IN NUMBER                    --
--                  p_business_group_id    IN NUMBER                    --
--                  p_date                 IN DATE                      --
--                  p_org_type             IN VARCHAR2                  --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   08-Apr-05  abhjain   Created this function to get the org id   --
--------------------------------------------------------------------------
FUNCTION get_org_id(p_assignment_id     IN NUMBER
                   ,p_business_group_id IN NUMBER
                   ,p_date              IN DATE
                   ,p_org_type          IN VARCHAR2)
RETURN NUMBER
IS
  CURSOR cur_org (p_assignment_id      NUMBER
                 ,p_business_group_id  NUMBER
                 ,p_date               DATE)
       IS
   SELECT hsc.segment2
         ,hsc.segment3
         ,hsc.segment4
     FROM per_assignments_f      paf
         ,hr_soft_coding_keyflex hsc
    WHERE paf.assignment_id = p_assignment_id
      AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
      AND paf.business_group_id = p_business_group_id
      AND p_date BETWEEN paf.effective_start_date
                     AND paf.effective_end_date;

  l_segment2 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment3 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment4 hr_soft_coding_keyflex.segment1%TYPE;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);

BEGIN

  l_procedure := g_package||'get_org_id';
  g_debug          := hr_utility.debug_enabled;

  pay_in_utils.set_location(g_debug,'Entering : '||l_procedure, 10);

  OPEN cur_org (p_assignment_id
               ,p_business_group_id
               ,p_date);
  FETCH cur_org into l_segment2
                    ,l_segment3
                    ,l_segment4;
  pay_in_utils.set_location (g_debug,'l_segment2 = '||l_segment2,20);
  pay_in_utils.set_location (g_debug,'l_segment3 = '||l_segment3,30);
  pay_in_utils.set_location (g_debug,'l_segment4 = '||l_segment4,40);
  CLOSE cur_org;

  IF p_org_type = 'PF' THEN
     RETURN to_number(l_segment2);
  ELSIF p_org_type = 'PT' THEN
     RETURN to_number(l_segment3);
  ELSIF p_org_type = 'ESI' THEN
     RETURN to_number(l_segment4);
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,' Leaving : '||l_procedure, 30);
       hr_utility.trace(l_message);
       RETURN NULL;


END get_org_id;

--------------------------------------------------------------------------
-- Name           : le_start_date                                       --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : Function to get the LE start date                   --
-- Parameters     :                                                     --
--             IN : p_tax_unit_id       IN NUMBER                       --
--                  p_assignment_id     IN NUMBER                       --
--                  p_effective_date    IN DATE                         --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-Jul-05  statkar   Created this function                    --
--------------------------------------------------------------------------
FUNCTION le_start_date(p_tax_unit_id IN NUMBER
                      ,p_assignment_id IN NUMBER
                      ,p_effective_date IN DATE
                      )
RETURN DATE
IS
  l_le_asg_start DATE;

  CURSOR csr_asg_start IS
  SELECT MAX(asg.effective_end_date) + 1
    FROM per_all_assignments_f asg
       , hr_soft_coding_keyflex scl
   WHERE asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
     AND nvl(scl.segment1,'-1')<> TO_CHAR(p_tax_unit_id)
     AND asg.assignment_id = p_assignment_id
     AND asg.effective_end_date < p_effective_date;

 CURSOR csr_asg_start_le
  IS
  select min(asg.effective_start_date)
  from per_all_assignments_f asg
      , hr_soft_coding_keyflex scl
  WHERE asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND scl.segment1 =  TO_CHAR(p_tax_unit_id)
    AND asg.assignment_id = p_assignment_id
    AND asg.effective_start_date < p_effective_date;


 l_procedure   VARCHAR2(250);
 l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'le_start_date';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_tax_unit_id',p_tax_unit_id);
        pay_in_utils.trace('p_assignment_id',p_assignment_id);
        pay_in_utils.trace('p_effective_date',p_effective_date);
   END IF;

  OPEN csr_asg_start;
  FETCH csr_asg_start INTO l_le_asg_start;
  CLOSE csr_asg_start;

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_le_asg_start',l_le_asg_start);
   END IF;


  IF l_le_asg_start IS NULL THEN
    OPEN csr_asg_start_le;
    FETCH csr_asg_start_le INTO l_le_asg_start;
    CLOSE csr_asg_start_le;
  END IF;

  IF (g_debug)
  THEN
       pay_in_utils.trace('l_le_asg_start',l_le_asg_start);
  END IF;

  RETURN l_le_asg_start;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

END le_start_date;

--------------------------------------------------------------------------
-- Name           : le_end_date                                         --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : Function to get the LE end date                     --
-- Parameters     :                                                     --
--             IN : p_tax_unit_id       IN NUMBER                       --
--                  p_assignment_id     IN NUMBER                       --
--                  p_effective_date    IN DATE                         --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-Jul-05  statkar   Created this function                    --
--------------------------------------------------------------------------
FUNCTION le_end_date(p_tax_unit_id IN NUMBER
                    ,p_assignment_id IN NUMBER
                    ,p_effective_date IN DATE
                     )
RETURN DATE
IS
  l_le_asg_end DATE;

  CURSOR csr_asg_end IS
   SELECT MIN(asg.effective_start_date) -1
   FROM per_all_assignments_f asg
      , hr_soft_coding_keyflex scl
  WHERE asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND NVL(scl.segment1,'-1')<> TO_CHAR(p_tax_unit_id)
    AND asg.assignment_id = p_assignment_id
    AND asg.effective_start_date > p_effective_date;

  CURSOR csr_asg_end_le
  IS
  select max(asg.effective_end_date)
  from per_all_assignments_f asg
      , hr_soft_coding_keyflex scl
  WHERE asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND scl.segment1 =  TO_CHAR(p_tax_unit_id)
    AND asg.assignment_id = p_assignment_id
    AND asg.effective_end_date >= p_effective_date;

  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'le_end_date';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_tax_unit_id',p_tax_unit_id);
        pay_in_utils.trace('p_assignment_id',p_assignment_id);
        pay_in_utils.trace('p_effective_date',p_effective_date);
   END IF;


  OPEN csr_asg_end;
  FETCH csr_asg_end INTO l_le_asg_end;
  CLOSE csr_asg_end;

   IF l_le_asg_end IS NULL THEN
    OPEN csr_asg_end_le;
    FETCH csr_asg_end_le INTO l_le_asg_end;
    CLOSE csr_asg_end_le;
  END IF;

  IF (g_debug)
  THEN
       pay_in_utils.trace('l_le_asg_start',l_le_asg_end);
  END IF;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  RETURN l_le_asg_end;

END le_end_date;

--------------------------------------------------------------------------
-- Name           : get_pay_periods                                     --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the balance periods in the current  --
--                  tax year                                            --
-- Parameters     :                                                     --
--             IN : p_payroll_id        IN NUMBER                       --
--                  p_tax_unit_id       IN NUMBER                       --
--                  p_assignment_id     IN NUMBER                       --
--                  p_period_end_date   IN DATE                         --
--                  p_termination_date  IN DATE                         --
--                  p_period_number     IN NUMBER                       --
--                  p_condition         IN VARCHAR2                     --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27-Apr-05  lnagaraj   Created this function                    --
-- 2.0   18-Jul-05  statkar    Added LE change functionality            --
-- 3.0   04-Jun-07  rsaharay   TO calculate LRPP correctly FOR          --
--                             employees terminated                     --
--                             IN previous financial year.              --
--------------------------------------------------------------------------
FUNCTION get_pay_periods (p_payroll_id       IN NUMBER
                         ,p_tax_unit_id      IN NUMBER
                         ,p_assignment_id    IN NUMBER
                         ,p_date_earned      IN DATE
                         ,p_period_end_date  IN DATE
                         ,p_termination_date IN DATE
                         ,p_period_number    IN NUMBER
                         ,p_condition        IN VARCHAR2
                         )
RETURN NUMBER IS

l_rem_pay_periods NUMBER;
l_le_end          DATE;
l_tot_pay_periods NUMBER;
l_year_end        DATE;
l_year_start      DATE;
l_term            DATE;
l_end_date        DATE;
l_procedure       VARCHAR2(250);
l_message         VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_pay_periods';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_payroll_id      ',p_payroll_id      );
        pay_in_utils.trace('p_tax_unit_id     ',p_tax_unit_id     );
        pay_in_utils.trace('p_assignment_id   ',p_assignment_id   );
        pay_in_utils.trace('p_date_earned     ',p_date_earned     );
        pay_in_utils.trace('p_period_end_date ',p_period_end_date );
        pay_in_utils.trace('p_termination_date',p_termination_date);
        pay_in_utils.trace('p_period_number   ',p_period_number   );
        pay_in_utils.trace('p_condition       ',p_condition       );
   END IF;

  l_tot_pay_periods :=12;
  l_year_end   := get_financial_year_end(p_period_end_date);
  l_year_start := get_financial_year_start(p_period_end_date);

  hr_utility.trace('p_payroll_id      = '||to_char(p_payroll_id));
  hr_utility.trace('p_tax_unit_id     = '||to_char(p_tax_unit_id));
  hr_utility.trace('p_period_number   = '||to_char(p_period_number));
  hr_utility.trace('l_year_end        = '||to_char(l_year_end,'DD-MM-YYYY'));
  hr_utility.trace('l_year_start      = '||to_char(l_year_start,'DD-MM-YYYY'));

  IF p_condition = 'GRE' THEN
     l_le_end  := le_end_date(p_tax_unit_id, p_assignment_id, p_date_earned);
  ELSE
     l_le_end  := l_year_end;
  END IF;
  hr_utility.trace('l_le_end   = '||to_char(l_le_end,'DD-MM-YYYY'));

  l_term := GREATEST(p_termination_date, l_year_start);

  l_end_date := LEAST(l_year_end, l_le_end, l_term);

  hr_utility.trace('l_end_date = '||to_char(l_end_date,'DD-MM-YYYY'));

  l_tot_pay_periods := get_period_number(p_payroll_id,l_end_date);
  l_rem_pay_periods := GREATEST(l_tot_pay_periods - p_period_number, 0);

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  RETURN l_rem_pay_periods;

END get_pay_periods;

--------------------------------------------------------------------------
-- Name           : get_income_tax                                      --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the income tax,surcharge, education --
--                  cess                                                --
-- Parameters     :                                                     --
--             IN : p_business_group_id    IN NUMBER                    --
--                  p_total_income         IN NUMBER                    --
--                  p_gender               IN VARCHAR2                  --
--                  p_age                  IN NUMBER                    --
--	            p_pay_end_date         IN DATE                      --
--                  p_marginal_relief      OUT NUMBER                   --
--                  p_surcharge            OUT NUMBER                   --
--                  p_education_cess       OUT NUMBER                   --
--                  p_message              OUT VARCHAR2                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27-Apr-05  lnagaraj   Created this function                    --
--------------------------------------------------------------------------
FUNCTION get_income_tax(p_business_group_id IN NUMBER
                       ,p_total_income      IN NUMBER
                       ,p_gender            IN VARCHAR2
                       ,p_age               IN NUMBER
                       ,p_pay_end_date      IN DATE
                       ,p_marginal_relief OUT NOCOPY NUMBER
                       ,p_surcharge       OUT NOCOPY NUMBER
                       ,p_education_cess  OUT NOCOPY NUMBER
                       ,p_message         OUT NOCOPY VARCHAR2
		       ,p_sec_and_he_cess     OUT NOCOPY NUMBER)
RETURN NUMBER
IS

l_tax_slab NUMBER;
l_additional_amount NUMBER;
l_reduced_amount NUMBER;
l_income_tax NUMBER;

l_surcharge_applicable_amt NUMBER;
l_relief_ceiling ff_globals_f.global_name%TYPE;
l_relief_limit NUMBER;
tax_on_mr_ceiling NUMBER;

l_cess_percent NUMBER;
l_sec_and_he_cess_percent NUMBER;

l_table_name VARCHAR2(100);
p_tax_on_income NUMBER;

CURSOR csr_global_value(p_global_name IN VARCHAR2
                       ,p_date        IN DATE)
IS
SELECT fnd_number.canonical_to_number(glb.global_value)
  FROM ff_globals_f glb
 WHERE glb.global_name = p_global_name
   AND p_date BETWEEN glb.effective_start_date
                  AND glb.effective_end_date
   AND glb.legislation_code='IN';

  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_income_tax';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_business_group_id',p_business_group_id);
        pay_in_utils.trace('p_total_income     ',p_total_income     );
        pay_in_utils.trace('p_gender           ',p_gender           );
        pay_in_utils.trace('p_age              ',p_age              );
        pay_in_utils.trace('p_pay_end_date     ',p_pay_end_date     );
   END IF;

  l_income_tax:=0;

  IF p_age >=65 THEN
    l_table_name :='India Income Tax Rates for Senior Citizen';
  ELSIF p_gender = 'F' THEN
    l_table_name := 'India Income Tax Rates for Women';
  ELSE
    l_table_name := 'India Income Tax Rates';
  END IF;

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_table_name',l_table_name);
   END IF;

  l_tax_slab := fnd_number.canonical_to_number(pay_in_utils.get_user_table_value
                  (p_business_group_id    => p_business_group_id
                  ,p_table_name           => l_table_name
                  ,p_column_name          => 'Tax Rate'
	              ,p_row_name             => 'Tax Slabs'
                  ,p_row_value            => p_total_income
	              ,p_effective_date       => p_pay_end_date
	              ,p_message              => p_message
                  ));

  l_additional_amount := fnd_number.canonical_to_number(pay_in_utils.get_user_table_value
                         (p_business_group_id    => p_business_group_id
                         ,p_table_name           => l_table_name
                         ,p_column_name          => 'Additional Amount'
	                     ,p_row_name             => 'Tax Slabs'
                         ,p_row_value            => p_total_income
	                     ,p_effective_date       => p_pay_end_date
	                     ,p_message              => p_message
                         ));

  l_reduced_amount := fnd_number.canonical_to_number(pay_in_utils.get_user_table_value
                         (p_business_group_id    => p_business_group_id
                         ,p_table_name           => l_table_name
                         ,p_column_name          => 'Reduced Amount'
	                     ,p_row_name             => 'Tax Slabs'
                         ,p_row_value            => p_total_income
	                     ,p_effective_date       => p_pay_end_date
	                     ,p_message              => p_message
                         ));

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_tax_slab',l_tax_slab);
        pay_in_utils.trace('l_additional_amount',l_additional_amount);
        pay_in_utils.trace('l_reduced_amount',l_reduced_amount);
   END IF;

  l_income_tax := l_tax_slab * (p_total_income - l_reduced_amount) + l_additional_amount;
  p_marginal_relief := 0;
  p_surcharge := 0;
  p_education_cess := 0;
  p_sec_and_he_cess := 0;

  OPEN csr_global_value('IN_SURCHARGE_APPLICABLE_AMOUNT',p_pay_end_date);
  FETCH csr_global_value INTO l_surcharge_applicable_amt;
  CLOSE csr_global_value;

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_surcharge_applicable_amt',l_surcharge_applicable_amt);
   END IF;


  /* Calculate Surcharge and marginal relief */
  IF p_total_income > l_surcharge_applicable_amt THEN
    p_surcharge := 0.1 * l_income_tax;

    IF p_age >= 65 THEN
      l_relief_ceiling := 'IN_MARGINAL_RELIEF_SENIORS';
    ELSIF p_gender = 'F' THEN
      l_relief_ceiling := 'IN_MARGINAL_RELIEF_FEMALES';
    ELSE
      l_relief_ceiling := 'IN_MARGINAL_RELIEF';
    END IF;

    OPEN csr_global_value(l_relief_ceiling,p_pay_end_date);
    FETCH csr_global_value INTO l_relief_limit;
    CLOSE csr_global_value;

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_relief_ceiling',l_relief_ceiling);
        pay_in_utils.trace('l_relief_limit',l_relief_limit);
        pay_in_utils.trace('p_pay_end_date',p_pay_end_date);
   END IF;

    IF p_total_income <= l_relief_limit THEN
      tax_on_mr_ceiling := l_additional_amount
                         + (l_surcharge_applicable_amt - l_reduced_amount) * l_tax_slab;

      p_marginal_relief := l_income_tax
                         + p_surcharge
                         - tax_on_mr_ceiling
			             - (p_total_income - l_surcharge_applicable_amt);
    END IF;

  END IF;


  p_tax_on_income := l_income_tax + GREATEST (p_surcharge - p_marginal_relief,0);

  OPEN csr_global_value('IN_EDUCATION_CESS_PERCENTAGE',p_pay_end_date);
  FETCH csr_global_value INTO l_cess_percent;
  CLOSE csr_global_value;

  p_education_cess := l_cess_percent * p_tax_on_income ;

  OPEN csr_global_value('IN_SEC_AND_HE_CESS_PERCENTAGE',p_pay_end_date);
  IF csr_global_value%NOTFOUND THEN
	l_sec_and_he_cess_percent:=0;
  END IF ;
  FETCH csr_global_value INTO l_sec_and_he_cess_percent;
  CLOSE csr_global_value;

  p_sec_and_he_cess := l_sec_and_he_cess_percent * p_tax_on_income ;

  p_marginal_relief  := GREATEST(p_marginal_relief,0);
  p_surcharge        := GREATEST(p_surcharge,0);
  p_education_cess   := GREATEST(p_education_cess,0);
  p_sec_and_he_cess  := GREATEST(p_sec_and_he_cess,0);
  l_income_tax       := GREATEST(l_income_tax,0);

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_cess_percent',l_cess_percent);
        pay_in_utils.trace('p_marginal_relief',p_marginal_relief);
        pay_in_utils.trace('p_surcharge',p_surcharge);
        pay_in_utils.trace('p_education_cess',p_education_cess);
        pay_in_utils.trace('p_sec_and_he_cess',p_sec_and_he_cess);
        pay_in_utils.trace('l_income_tax',l_income_tax);
        pay_in_utils.trace('p_tax_on_income',p_tax_on_income);
   END IF;

  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

 RETURN l_income_tax;
 END get_income_tax;

FUNCTION set_context(p_context_name   IN VARCHAR2
                    ,p_context_value  IN VARCHAR2
                     )
RETURN NUMBER
IS

  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'set_context';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_context_name',p_context_name);
        pay_in_utils.trace('p_context_value',p_context_value);
   END IF;

   pay_balance_pkg.set_context('IN',p_context_name, p_context_value);

   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

   RETURN 0;
END set_context;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_value_on_le_start                               --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return balance value as on the          --
--                  le start. This will be accessed while processing    --
--                  Actual Expecnditure type of allowances and can be   --
--                  safely used during payroll run as it fetches        --
--                  previous runs values only                           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id                NUMBER               --
--                  p_tax_unit_id                  NUMBER               --
--                  p_effective_date               DATE                 --
--                  p_balance_name                 VARCHAR2             --
--                  p_dimension_name               VARCHAR2             --
--                  p_context_name                 VARCHAR2             --
--                  p_context_value                VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   11-Oct-05  lnagaraj   Created this function                    --
--------------------------------------------------------------------------
FUNCTION get_value_on_le_start
    (p_assignment_id      IN NUMBER
    ,p_tax_unit_id        IN NUMBER
    ,p_effective_date     IN DATE
    ,p_balance_name       IN pay_balance_types.balance_name%TYPE
    ,p_dimension_name     IN pay_balance_dimensions.dimension_name%TYPE
    ,p_context_name       IN ff_contexts.context_name%TYPE
    ,p_context_value      IN VARCHAR2
    ,p_success            OUT NOCOPY VARCHAR2
    )
RETURN NUMBER
IS

CURSOR c_max_asact(l_le_end_date DATE) IS
SELECT MAX(paa.assignment_action_id)
  FROM pay_payroll_Actions ppa
      ,pay_assignment_actions paa
 WHERE paa.assignment_id =p_assignment_id
   AND paa.payroll_action_id = ppa.payroll_Action_id
   AND ppa.action_type in('R','Q')
   AND TRUNC(ppa.date_earned,'MM') = TRUNC(l_le_end_date,'MM')
   AND paa.source_action_id IS NULL;

CURSOR csr_cyclic_gre(p_start_date DATE,p_pre_le_end_date DATE) IS
 SELECT 1
   FROM per_assignments_f paf,
        hr_soft_coding_keyflex scl
  WHERE paf.assignment_id = p_assignment_id
    AND scl.segment1 = TO_CHAR(p_tax_unit_id)
    AND paf.SOFT_CODING_KEYFLEX_ID=scl.SOFT_CODING_KEYFLEX_ID
    AND paf.effective_end_date BETWEEN p_start_date AND p_pre_le_end_date;

   l_year_start DATE;
   l_pre_le_end_date DATE;
   l_le_start_date DATE;
   l_exists NUMBER;
   p_assignment_action_id NUMBER;
   l_def_bal_id NUMBER;
   l_balance_value NUMBER :=0 ;
   l_proc VARCHAR2(200);
   l_message VARCHAR2(250);

BEGIN
   --
   g_debug := hr_utility.debug_enabled;
   l_proc := g_package||'get_value_on_le_start';

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_id ',p_assignment_id );
        pay_in_utils.trace('p_tax_unit_id   ',p_tax_unit_id   );
        pay_in_utils.trace('p_effective_date',p_effective_date);
        pay_in_utils.trace('p_context_value',p_context_value);
   END IF;


    l_year_start := pay_in_tax_utils.get_financial_year_start(p_effective_date );

    l_le_start_date := le_start_date(p_tax_unit_id
                                    ,p_assignment_id
                                    ,p_effective_date);
    l_pre_le_end_date := l_le_start_date - 1;

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_year_start ',l_year_start );
        pay_in_utils.trace('l_le_start_date   ',l_le_start_date   );
        pay_in_utils.trace('l_pre_le_end_date',l_pre_le_end_date);
   END IF;


   OPEN csr_cyclic_gre(l_year_start,l_pre_le_end_date);
   FETCH csr_cyclic_gre INTO l_exists;
     IF csr_cyclic_gre%NOTFOUND THEN
       CLOSE csr_cyclic_gre;
       p_success := 'N';
       RETURN 0;
     END IF;
   CLOSE csr_cyclic_gre;

   l_def_bal_id := pay_in_tax_utils.get_defined_balance(p_balance_name, p_dimension_name);
   pay_in_utils.set_location(g_debug, ' INDIA:l_def_bal_id '||l_def_bal_id,30);

   OPEN c_max_asact(l_pre_le_end_date);
   FETCH c_max_asact INTO p_assignment_action_id;
   CLOSE c_max_asact;

   pay_in_utils.set_location(g_debug, ' INDIA:l_asg_action_id '||p_assignment_action_id,50);


   IF p_context_name = 'SOURCE_TEXT2' THEN

      l_balance_value := pay_balance_pkg.get_value
                         (p_assignment_action_id => p_assignment_action_id
                         ,p_defined_balance_id   => l_def_bal_id
                         ,p_tax_unit_id          => p_tax_unit_id
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => p_context_value
                         ,p_source_number        => null
                         );
   ELSIF p_context_name = 'TAX_UNIT_ID' THEN

      l_balance_value := pay_balance_pkg.get_value
                         (p_assignment_action_id => p_assignment_action_id
                         ,p_defined_balance_id   => l_def_bal_id
                         ,p_tax_unit_id          => p_tax_unit_id
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );
  END IF;

   pay_in_utils.set_location(g_debug, ' INDIA:l_value '||l_balance_value,60);
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_proc,70);
       p_success := 'Y';
   RETURN l_balance_value;
   --
END get_value_on_le_start;


--------------------------------------------------------------------------
-- Name           : prev_med_reimbursement                              --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the Medical Reimbursement provided  --
--                  by the Previous Employer                            --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION prev_med_reimbursement(p_assignment_id IN NUMBER
                               ,p_date_earned IN DATE
                               )
RETURN NUMBER IS

  CURSOR c_prev_emp_details is
  SELECT NVL(ppm.pem_information22,0),  -- Medical Reimbursement
         ppm.end_date
    FROM per_previous_employers ppm,
         per_all_assignments_f paa
   WHERE paa.assignment_id = p_assignment_id
     AND paa.person_id = ppm.person_id
     AND p_date_earned BETWEEN paa.effective_start_date AND paa.effective_end_date;

  l_start DATE;
  l_end DATE;
  l_end_date DATE;
  p_prev_med_reimburse_amt NUMBER;
  l_prev_med_reimburse_amt NUMBER;


  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN

   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'prev_med_reimbursement';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_id',p_assignment_id);
        pay_in_utils.trace('p_date_earned',p_date_earned);

   END IF;

  p_prev_med_reimburse_amt := 0;

  l_start := get_financial_year_start(p_date_earned);
  l_end   := get_financial_year_end(p_date_earned);

  OPEN c_prev_emp_details;
  LOOP

    FETCH c_prev_emp_details
    INTO l_prev_med_reimburse_amt,l_end_date;
      IF c_prev_emp_details%NOTFOUND THEN
        CLOSE c_prev_emp_details;
        RETURN p_prev_med_reimburse_amt;
      END IF;

    IF l_end_date BETWEEN l_start AND l_end THEN
      p_prev_med_reimburse_amt := p_prev_med_reimburse_amt + TO_NUMBER(l_prev_med_reimburse_amt);
    END IF;

   END LOOP;
  CLOSE c_prev_emp_details;

   IF (g_debug)
   THEN
        pay_in_utils.trace('p_prev_med_reimburse_amt',p_prev_med_reimburse_amt);
   END IF;
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  RETURN p_prev_med_reimburse_amt;

END prev_med_reimbursement;

--------------------------------------------------------------------------
-- Name           : get_value_prev_period                               --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get value in the previous run that      --
--                  processed the tax information element               --
-- Parameters     :                                                     --
--             IN :   p_assignment_id NUMBER                            --
--                    p_assignment_action_id NUMBER                     --
--                    p_payroll_action_id NUMBER                        --
--                    p_tax_unit_id   NUMBER                            --
--                    p_balance_name  VARCAHR2                          --
--                    p_le_start_date DATE                              --
--                                                                      --

--------------------------------------------------------------------------
FUNCTION get_value_prev_period
    (p_assignment_id          IN NUMBER
    ,p_assignment_action_id   IN NUMBER
    ,p_payroll_action_id      IN NUMBER
    ,p_tax_unit_id            IN NUMBER
    ,p_balance_name           IN pay_balance_types.balance_name%TYPE
    ,p_le_start_date          IN DATE
    )
RETURN NUMBER IS

 /* In case of suspension, the run assignment action exists, but no elements
 are picked up during payroll run. So, we need the exists clause.Be it suspension
 or Otherwise, this cursor picks the most recent payroll run that populated the
 tax information elements in the current le in this tax year*/

  CURSOR c_recent_run_action IS
  SELECT to_number(substr(max(lpad(prev_asg.action_sequence,15,'0')||prev_asg.assignment_action_id),16))
    FROM pay_assignment_actions prev_asg,
         pay_payroll_actions prev_pay,
         per_time_periods ptp,
         pay_assignment_actions cur_asg,
         pay_payroll_actions cur_pay
   WHERE prev_asg.assignment_id = p_assignment_id
     AND prev_asg.payroll_action_id = prev_pay.payroll_action_id
     AND prev_pay.action_type IN('R','Q')
     AND prev_asg.source_action_id IS NOT NULL
     AND prev_pay.effective_date < ptp.start_date
     AND cur_asg.assignment_action_id = p_assignment_action_id
     AND cur_asg.payroll_action_id = cur_pay.payroll_action_id
     AND prev_asg.action_sequence <= cur_asg.action_sequence
     AND cur_pay.effective_date between ptp.start_date and ptp.end_date
     AND ptp.payroll_id = cur_pay.payroll_id
     AND EXISTS (SELECT ''
                   FROM pay_run_results prr,
                        pay_element_types_f pet
                  WHERE prr.assignment_action_id = prev_asg.assignment_action_id
                    AND prr.element_type_id = pet.element_type_id
                    AND pet.legislation_code ='IN'
                    AND pet.element_name ='Form16 Income Tax Information')
     AND prev_pay.date_earned >= p_le_start_date;

l_suspend_end_date DATE;
l_balance_value    NUMBER;
l_assignment_action_id NUMBER;
l_def_bal_id       NUMBER;
l_procedure   VARCHAR2(250);

BEGIN

   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_value_prev_period';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_id ',p_assignment_id );
        pay_in_utils.trace('p_assignment_action_id   ',p_assignment_action_id   );
        pay_in_utils.trace('p_payroll_action_id',p_payroll_action_id);
        pay_in_utils.trace('p_tax_unit_id',p_tax_unit_id);
        pay_in_utils.trace('p_balance_name',p_balance_name);
        pay_in_utils.trace('p_le_start_date',p_le_start_date);
   END IF;

  OPEN c_recent_run_action;
  FETCH c_recent_run_action INTO l_assignment_action_id ;
  CLOSE c_recent_run_action;

  IF l_assignment_action_id IS NULL THEN
    l_balance_value :=0;
  ELSE
    l_def_bal_id := pay_in_tax_utils.get_defined_balance(p_balance_name, '_ASG_LE_PTD');

    l_balance_value := pay_balance_pkg.get_value
                         (p_assignment_action_id => l_assignment_action_id
                         ,p_defined_balance_id   => l_def_bal_id
                         ,p_tax_unit_id          => p_tax_unit_id
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );
   IF (g_debug)
   THEN
     pay_in_utils.trace('l_balance_value',l_balance_value);
   END IF;

  END IF;
    pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

    RETURN l_balance_value;
END get_value_prev_period;

--------------------------------------------------------------------------
-- Name           : get_regular_run_exists                              --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to find if a regular run has already been  --
--                  run in the current period                           --
-- Parameters     :                                                     --
--             IN :   p_assignment_action_id NUMBER                     --
--------------------------------------------------------------------------

FUNCTION get_regular_run_exists
                             (p_assignment_action_id NUMBER)
RETURN VARCHAR2
IS
  CURSOR csr_regular_run IS
  SELECT 'Y' FROM
          per_time_periods               ptp,
         pay_payroll_actions            pact,
         pay_assignment_actions         assact,
         pay_payroll_actions            bact,
         pay_assignment_actions         bal_assact,
         pay_run_types_f                prt
  WHERE  bal_assact.assignment_action_id  = p_assignment_action_id
  AND    bal_assact.payroll_action_id     = bact.payroll_action_id
  AND    assact.payroll_action_id         = pact.payroll_action_id
  AND    assact.action_sequence           <= bal_assact.action_sequence
  AND    assact.assignment_id             = bal_assact.assignment_id + DECODE(ptp.start_date, null, 0, 0)
  AND    bact.effective_date BETWEEN ptp.start_date AND ptp.end_date
  AND    ptp.payroll_id = bact.payroll_id
  AND    pact.effective_date >=  ptp.start_date
  AND    pact.effective_date <=  ptp.end_date
  AND    pact.action_type in('R','Q')
  AND    prt.run_type_id = ASSACT.run_type_id
  AND    prt.run_type_name ='Regular Run'
  AND EXISTS ( SELECT '1' FROM
               pay_run_results prr,
               pay_element_types_f pet
                  WHERE prr.assignment_action_id = ASSACT.assignment_action_id
                    AND prr.element_type_id = pet.element_type_id
                    AND pet.legislation_code ='IN'
                    AND pet.element_name ='Form16 Income Information');

  l_exists VARCHAR2(10);
  l_procedure   VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_regular_run_exists';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

      IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_action_id ',p_assignment_action_id );
   END IF;


  l_exists := 'N';

  OPEN csr_regular_run;
  FETCH csr_regular_run INTO l_exists;
  CLOSE csr_regular_run;

   pay_in_utils.set_location(g_debug, ' INDIA:l_exists '||l_exists,30);
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

  RETURN l_exists;

END get_regular_run_exists;

--------------------------------------------------------------------------
-- Name           : bon_section_89_relief                               --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to find Section 89 relief in the Bonus     --
--                  formula                                             --
-- Parameters     :                                                     --
--             IN :   p_business_group_id       NUMBER                  --
--                    p_total_income            NUMBER                  --
--                    p_retro_earnings_py       NUMBER                  --
--                    p_retro_allw_exempt_py    NUMBER                  --
--                    p_emplr_class             VARCHAR2                --
--                    p_retro_ent_allw_py       NUMBER                  --
--                    p_pay_end_date            DATE                    --
--                    p_tax_section_89          NUMBER                  --
--                    p_tax_Pyble_Curr_Yr       NUMBER                  --
--                    p_gender                  VARCHAR2                --
--                    p_age                     NUMBER                  --
--------------------------------------------------------------------------

FUNCTION bon_section_89_relief(p_business_group_id IN NUMBER
                          ,p_total_income IN NUMBER
                          ,p_retro_earnings_py IN NUMBER
                          ,p_retro_allw_exempt_py IN NUMBER
                          ,p_emplr_class IN VARCHAR2
                          ,p_retro_ent_allw_py IN NUMBER
                          ,p_pay_end_date IN DATE
                          ,p_tax_section_89 IN NUMBER
                          ,p_tax_Pyble_Curr_Yr IN NUMBER
                          ,p_gender IN VARCHAR2
                          ,p_age IN NUMBER)
RETURN NUMBER IS

  Total_Income_wo_arrears   NUMBER;
  Tax_Payable_cy_wo_arrears NUMBER;
  l_sec89_relief_bon        NUMBER;
  tax_payable_wo_arrears    NUMBER;
  Tax_Difference_Curr_Year  NUMBER;
  Tax_Difference_Prev_Year  NUMBER;
  relief_wo_arrears         NUMBER;
  surcharge_wo_arrears      NUMBER;
  edu_cess_wo_arrears       NUMBER;
  sec_and_he_cess_wo_arrears       NUMBER;
  p_messsage                VARCHAR2(40);
  l_procedure   VARCHAR2(250);



BEGIN

   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'bon_section_89_relief';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_business_group_id ',p_business_group_id );
        pay_in_utils.trace('p_retro_earnings_py   ',p_retro_earnings_py   );
        pay_in_utils.trace('p_retro_allw_exempt_py',p_retro_allw_exempt_py);
        pay_in_utils.trace('p_emplr_class',p_emplr_class);
        pay_in_utils.trace('p_retro_ent_allw_py',p_retro_ent_allw_py);
        pay_in_utils.trace('p_pay_end_date',p_pay_end_date);
        pay_in_utils.trace('p_tax_section_89',p_tax_section_89);
        pay_in_utils.trace('p_tax_Pyble_Curr_Yr',p_tax_Pyble_Curr_Yr);
        pay_in_utils.trace('p_gender',p_gender);
        pay_in_utils.trace('p_age',p_age);
   END IF;

  Total_Income_wo_arrears := p_total_income
                           - p_retro_earnings_py
                           + p_retro_allw_exempt_py;

  IF (p_emplr_class = 'CG' OR p_emplr_class = 'SG') THEN
    Total_Income_wo_arrears := Total_Income_wo_arrears
                             + p_retro_allw_exempt_py;
  END IF;

   pay_in_utils.set_location(g_debug, ' INDIA:Total_Income_wo_arrears '||Total_Income_wo_arrears,30);

  tax_payable_wo_arrears := get_income_tax( p_business_group_id
                                          ,Total_Income_wo_arrears
                                          ,p_gender
                                          ,p_age
                                          ,p_pay_end_date
                                          ,relief_wo_arrears
                                          ,surcharge_wo_arrears
                                          ,edu_cess_wo_arrears
					  ,p_messsage
					  ,sec_and_he_cess_wo_arrears);


  Tax_Payable_cy_wo_arrears := tax_payable_wo_arrears
                             - relief_wo_arrears
                             + surcharge_wo_arrears
                             + edu_cess_wo_arrears
                             + sec_and_he_cess_wo_arrears;


  Tax_Difference_Curr_Year := p_tax_Pyble_Curr_Yr - Tax_Payable_cy_wo_arrears;
  Tax_Difference_Prev_Year := p_tax_section_89;

  IF (g_debug)
   THEN
        pay_in_utils.trace('Tax_Difference_Curr_Year ',Tax_Difference_Curr_Year );
        pay_in_utils.trace('Tax_Difference_Prev_Year   ',Tax_Difference_Prev_Year   );
   END IF;

  l_sec89_relief_bon := ROUND(GREATEST(Tax_Difference_Curr_Year - Tax_Difference_Prev_Year,0),0);

   pay_in_utils.set_location(g_debug, ' INDIA:l_sec89_relief_bon '||l_sec89_relief_bon,40);
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);


  RETURN l_sec89_relief_bon;

END bon_section_89_relief;

--------------------------------------------------------------------------
-- Name           : bon_calculate_80g_gg                                --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to find Section 80G and 80GG exemptions in --
--                  the Bonus formula                                   --
-- Parameters     :                                                     --
--             IN :   p_assact_id               NUMBER                  --
--                    p_assignment_id           NUMBER                  --
--                    p_payroll_id              NUMBER                  --
--                    p_effective_date          DATE                    --
--                    p_gross_Total_Income      NUMBER                  --
--                    p_tot_via_exc_80gg_g      NUMBER                  --
--                    p_oth_inc                 NUMBER                  --
--                    p_80gg_periods            NUMBER                  --
--                    p_start_period            NUMBER                  --
--                    p_end_period              NUMBER                  --
--                    p_flag                    VARCHAR2                --
--                    p_exemptions_80g_ue       NUMBER                  --
--                    p_exemptions_80g_le       NUMBER                  --
--                    p_exemptions_80g_fp       NUMBER                  --
--                                                                      --
--            OUT :   p_dedn_Sec_80GG           NUMBER                  --
--                    p_dedn_Sec_80G            NUMBER                  --
--                    p_dedn_Sec_80G_UE         NUMBER                  --
--                    p_dedn_Sec_80G_LE         NUMBER                  --
--                    p_Dedn_Sec_80G_FP         NUMBER                  --
--                    p_adj_total_income        NUMBER                  --

--------------------------------------------------------------------------


FUNCTION bon_calculate_80g_gg(p_assact_id          IN NUMBER,
                              p_assignment_id      IN NUMBER,
                              p_payroll_id         IN NUMBER,
                              p_effective_date     IN DATE,
                              p_gross_Total_Income IN NUMBER,
                              p_tot_via_exc_80gg_g IN NUMBER,
                              p_oth_inc            IN NUMBER,
                              p_80gg_periods       IN NUMBER,
                              p_start_period       IN NUMBER,
                              p_end_period         IN NUMBER,
                              p_flag               IN VARCHAR2,
                              p_exemptions_80g_ue  IN NUMBER,
                              p_exemptions_80g_le  IN NUMBER,
                              p_exemptions_80g_fp  IN NUMBER,
                              p_dedn_Sec_80GG      OUT NOCOPY NUMBER,
                              p_dedn_Sec_80G       OUT NOCOPY NUMBER,
                              p_dedn_Sec_80G_UE    OUT NOCOPY NUMBER,
                              p_dedn_Sec_80G_LE    OUT NOCOPY NUMBER,
                              p_Dedn_Sec_80G_FP    OUT NOCOPY NUMBER,
                              p_adj_total_income   OUT NOCOPY NUMBER  )
RETURN NUMBER
IS

CURSOR csr_global_value(p_global_name IN VARCHAR2
                       ,p_date        IN DATE)
IS
  SELECT fnd_number.canonical_to_number(glb.global_value)
    FROM ff_globals_f glb
   WHERE glb.global_name = p_global_name
     AND p_date BETWEEN glb.effective_start_date
                    AND glb.effective_end_date
     AND glb.legislation_code='IN';

  l_don_charity_80g         NUMBER;
  l_tot_VI_A_ded_except_80g NUMBER;
  l_total_income            NUMBER;
  elig_amt NUMBER;
  adj_tot_income  number;
  l_std_exemption     NUMBER;
  l_std_exem_percent  NUMBER;
  l_procedure   VARCHAR2(250);


BEGIN

 /* 80gg Starts without bonus */
  g_debug     := hr_utility.debug_enabled;
  l_procedure := g_package ||'bon_calculate_80g_gg';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assact_id         ',p_assact_id );
        pay_in_utils.trace('p_assignment_id     ',p_assignment_id   );
        pay_in_utils.trace('p_payroll_id        ',p_payroll_id);
        pay_in_utils.trace('p_effective_date    ',p_effective_date);
        pay_in_utils.trace('p_gross_Total_Income',p_gross_Total_Income);
        pay_in_utils.trace('p_tot_via_exc_80gg_g',p_tot_via_exc_80gg_g);
        pay_in_utils.trace('p_oth_inc           ',p_oth_inc);
        pay_in_utils.trace('p_80gg_periods      ',p_80gg_periods);
        pay_in_utils.trace('p_start_period      ',p_start_period);
        pay_in_utils.trace('p_end_period        ',p_end_period);
        pay_in_utils.trace('p_flag              ',p_flag);
        pay_in_utils.trace('p_exemptions_80g_ue ',p_exemptions_80g_ue);
        pay_in_utils.trace('p_exemptions_80g_le ',p_exemptions_80g_le);
        pay_in_utils.trace('p_exemptions_80g_fp ',p_exemptions_80g_fp);

   END IF;

  p_dedn_Sec_80GG      := 0;
  p_dedn_Sec_80G       := 0;
  p_dedn_Sec_80G_UE    := 0;
  p_dedn_Sec_80G_LE    := 0;
  p_Dedn_Sec_80G_FP    := 0;
  p_adj_total_income   := 0;

  p_adj_total_income  := GREATEST (0,
                       (p_gross_Total_Income
                      - p_tot_via_exc_80gg_g
                      - p_oth_inc));


  p_adj_total_income  := p_adj_total_income /p_80gg_periods ;

  OPEN csr_global_value('IN_RENT_PAID_PERCENT_80GG_EXEMPTION',p_effective_date);
  FETCH csr_global_value INTO l_std_exem_percent;
  CLOSE csr_global_value;

  OPEN csr_global_value('IN_RENT_PAID_AMOUNT_80GG_EXEMPTION',p_effective_date);
  FETCH csr_global_value INTO l_std_exemption;
  CLOSE csr_global_value;

  p_dedn_Sec_80GG  := calculate_80gg_exemption(p_assact_id
                                              ,p_assignment_id
                                              ,p_payroll_id
                                              ,p_effective_date
                                              ,l_std_exemption
                                              ,p_adj_total_income
                                              ,l_std_exem_percent
                                              ,p_start_period
                                              ,p_end_period
                                              ,p_flag);
   pay_in_utils.set_location(g_debug, ' INDIA:p_dedn_Sec_80GG '||p_dedn_Sec_80GG,30);

  /* Sec 80GG Ends */

  /* Sec 80G Starts with bonus  */

  OPEN csr_global_value('IN_DONATION_TO_CHARITABLE_INSTITUTIONS_80G',p_effective_date);
  FETCH csr_global_value INTO l_don_charity_80g;
  CLOSE csr_global_value;


  l_tot_VI_A_ded_except_80g := p_tot_via_exc_80gg_g
                             + p_dedn_Sec_80GG;

  IF p_exemptions_80g_ue <> 0 THEN
     p_dedn_Sec_80G_UE  := p_exemptions_80g_ue;
  END IF;

  l_total_income  := p_gross_Total_Income  - l_tot_VI_A_ded_except_80g;

  IF l_total_income  < 0
  THEN
     l_total_income  := 0;
  END IF;

  IF p_exemptions_80g_le <> 0 THEN

    adj_tot_income  := GREATEST(l_total_income - p_oth_inc,0) ;

    pay_in_utils.set_location(g_debug, ' INDIA:adj_tot_income '||adj_tot_income,40);

    elig_amt  := LEAST((p_exemptions_80g_le + p_exemptions_80g_fp),
                       l_don_charity_80g * adj_tot_income) ;

   pay_in_utils.set_location(g_debug, ' INDIA:elig_amt '||elig_amt,40);

    IF elig_amt  < p_exemptions_80g_fp THEN
       p_dedn_Sec_80G_LE  := elig_amt;
    ELSE
       p_dedn_Sec_80G_LE  := p_exemptions_80g_fp
                           + 0.5 * (elig_amt  - p_exemptions_80g_fp) ;
    END IF;
  ELSIF p_exemptions_80g_fp <> 0 THEN

    adj_tot_income  := GREATEST(l_total_income - p_oth_inc,0) ;

    elig_amt  := LEAST(p_exemptions_80g_fp,
                   l_don_charity_80g * adj_tot_income);
    p_dedn_Sec_80G_FP  := elig_amt;

  END IF;

  p_dedn_Sec_80G  :=  p_dedn_Sec_80G_UE
                    + p_dedn_Sec_80G_LE
                    + p_dedn_Sec_80G_FP;

   IF (g_debug)
   THEN
     pay_in_utils.trace('p_dedn_Sec_80GG     ',p_dedn_Sec_80GG);
     pay_in_utils.trace('p_dedn_Sec_80G      ',p_dedn_Sec_80G);
     pay_in_utils.trace('p_dedn_Sec_80G_UE   ',p_dedn_Sec_80G_UE);
     pay_in_utils.trace('p_dedn_Sec_80G_LE   ',p_dedn_Sec_80G_LE);
     pay_in_utils.trace('p_Dedn_Sec_80G_FP   ',p_Dedn_Sec_80G_FP);
     pay_in_utils.trace('p_adj_total_income  ',p_adj_total_income);
     pay_in_utils.trace('**************************************************','********************');
  END IF;
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);

  RETURN 0;

END bon_calculate_80g_gg;

END pay_in_tax_utils ;

/
