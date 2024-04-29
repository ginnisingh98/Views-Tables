--------------------------------------------------------
--  DDL for Package Body PAY_FR_COURT_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_COURT_ORDERS" as
/* $Header: pyfrcord.pkb 120.1 2006/02/02 04:35:17 aparkes noship $ */
g_package    CONSTANT VARCHAR2(31):= 'pay_fr_court_orders.';
/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**

Function  : VALIDATION - This validates the current court orders run. It checks whether both P4 and P5
                         court orders exist. If they do then return an error message.
Returns   : Error message
Called By : fr_court_orders.process

**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function validation return varchar2 is
--<<***BEGIN***>>--
begin
  --
  hr_utility.set_location('Entering:'||g_package||'validation', 10);
  --
  if total_order(40).number_of_orders > 0 and
     total_order(50).number_of_orders > 0 then
     hr_utility.set_location(g_package||'validation - FAILED', 15);
     fnd_message.set_name('PAY', 'PAY_74893_CO_P4S_P5S');
     return fnd_message.get;
  else
     hr_utility.set_location(g_package||'valid - PASSED', 20);
     return null;
  end if;
end validation;
--<<***END***>>--

/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**

Function  : VALIDATION - This validates the current court orders run. It checks whether both P4 and P5
                         court orders exist. If they do then return an error message.
Returns   : Error message
Called By : fr_court_orders.process

**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function net_pay_valid return varchar2 is
--<<***BEGIN***>>--
begin
  --
  hr_utility.set_location('Entering:'||g_package||'net_pay_valid', 10);
  --
  return g_net_pay_valid;
  --
  hr_utility.set_location(' Leaving:'||g_package||'net_pay_valid', 20);
  --
end net_pay_valid;
--<<***END***>>--

/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**
Function  : PROCESSED - This function will check to see whether any court orders have already
                        been processed - determines if the current element being processed
                        is the first court order element for this payroll run.
Returns   : 'Y' or 'N' indicating whether court orders have already been processed
Called By : Fast Fomula FR_COURT_ORDER_PAYMENTS
**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function processed (p_assignment_action_id in number) return varchar2 is
--<<***BEGIN***>>--
begin
  if g_assignment_action_id = p_assignment_action_id then
     hr_utility.set_location(g_package||'processed = Y', 10);
     return 'Y';
  else
     hr_utility.set_location(g_package||'processed = N', 10);
     return 'N';
  end if;
end processed;
--<<***END***>>--

/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**
Function  : CO_PAYMENT - This function simply returns the payment value for a given source id.
Returns   : Court Order Payment
Called By : get_payment
**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function co_payment (p_source_id in number) return number is
--<<***BEGIN***>>--
begin
  return nvl(court_order(p_source_id).payment,0);
  exception
     when no_data_found then
          return 0;
end co_payment;
--<<***END***>>--

/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**
Function  : GET_PAYMENT - Retrieves the payment for the current court order element being processed
                          and also produces any informational messages about the payment.
Returns   : Payment
            Any message relating to payment
            Flag indicating whether a message is being returned
Called By : Fast Formula FR_COURT_ORDER_PAYMENTS
**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function get_payment(p_source_id         in number
                    ,p_payment_reference in varchar2
                    ,p_element_name      in varchar2
                    ,p_message           out nocopy varchar2
                    ,p_message_text      out nocopy varchar2
                    ,p_stop              out nocopy varchar2 ) return number is
  --
  l_priority number;
  l_payment  number := 0;
  ---------------------------------------------------------------------------------------------------------
  procedure write_message (p_monthly_payment     in number
                          ,p_outstanding_balance in number
                          ,p_priority            in number
                          ,p_element_name        in varchar2
                          ,p_message_text        out nocopy varchar2
                          ,p_payment             out nocopy number
                          ,p_stop                out nocopy varchar2) is
    --
    l_payment         number(30,2) := co_payment(p_source_id);
    l_paid_in_period  number(30,3) := nvl(court_order(p_source_id).balance_ptd,0);
    l_value           number(30,2);
    --
  begin
    --
    hr_utility.set_location('Entering:Get_Payment - write_message', 16);
    --
    p_payment := l_payment - l_paid_in_period;
    --
    if p_priority in (20,30,40) then
       l_value := p_outstanding_balance;
    else
       l_value := p_monthly_payment;
    end if;
    --
    if l_payment < l_value then
       if p_payment > 0 then
          fnd_message.set_name('PAY', 'PAY_74889_CO_SHORTFALL');
          fnd_message.set_token('ELEMENT', p_element_name);
          fnd_message.set_token('REFERENCE', p_payment_reference);
          fnd_message.set_token('PAYMENT', l_payment);
          fnd_message.set_token('OWED', l_value);
          fnd_message.set_token('SHORTFALL', to_char(l_value - l_payment));
          p_message_text := fnd_message.get;
       else
          fnd_message.set_name('PAY', 'PAY_74890_CO_NO_PAYMENT');
          fnd_message.set_token('ELEMENT', p_element_name);
          fnd_message.set_token('REFERENCE', p_payment_reference);
          p_message_text := fnd_message.get;
       end if;
    else
       if l_payment >= p_outstanding_balance then
          fnd_message.set_name('PAY', 'PAY_74891_CO_PAID_OFF');
          fnd_message.set_token('ELEMENT', p_element_name);
          fnd_message.set_token('REFERENCE', p_payment_reference);
          p_message_text := fnd_message.get;
          p_stop := 'Y';
       end if;
    end if;
    --
    hr_utility.set_location('Entering:Get_Payment - write_message', 17);
    --
  end write_message;
  ---------------------------------------------------------------------------------------------------------
--<<***BEGIN***>>--
begin
  --
  hr_utility.set_location('Entering:'||g_package||'get_payment element'||substr(p_element_name,1,20), 10);
  --
  if not court_order.exists(p_source_id) then
     hr_utility.set_location('Element Source Id: '||substr(p_source_id,1,25)||' Not processed', 15);
     p_message := 'Y';
     fnd_message.set_name('PAY', 'PAY_74892_CO_NOT_PROCESSED');
     fnd_message.set_token('ELEMENT', p_element_name);
     fnd_message.set_token('REFERENCE', p_payment_reference);
     p_message_text := fnd_message.get;
     return 0;
  end if;
  --
  p_message_text := ' ';
  p_message      := 'N';
  p_stop         := 'N';
  l_priority     := court_order(p_source_id).priority;
  --
  write_message(p_monthly_payment     => court_order(p_source_id).monthly_payment
               ,p_outstanding_balance => court_order(p_source_id).outstanding_balance
               ,p_priority            => l_priority
               ,p_message_text        => p_message_text
               ,p_element_name        => indirect_to_direct(p_element_name)
               ,p_payment             => l_payment
               ,p_stop                => p_stop);
  --
  if p_message_text <> ' ' then
     hr_utility.set_location('Message = Y', 20);
     p_message := 'Y';
  end if;
  --
  hr_utility.set_location(' Leaving:'||g_package||'get_payment', 30);
  --
  return l_payment;
  --
end get_payment;
--<<***END***>>--

/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**
Function  : MAP_NAMES - Matches direct -> indirect or indirect -> direct, depending on the calling
                        function. It loops through pl/sql table map_element - which has been set up
                        by sub-procedure initialise within procedure process. Once
                        a matching value has been found then the corresponding indirect or direct
                        element name is returned.
Returns   : Indirect or Direct Element Name
Called By : direct_to_indirect
            indirect_to_direct
**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function map_names (p_direct_name   in varchar2
                   ,p_indirect_name in varchar2 ) return varchar2 is
--
l_name varchar2(80) := null;
i      number       := 0;
--
--<<***BEGIN***>>--
begin
  --
  hr_utility.set_location('Entering:'||g_package||'map_names', 10);
  --
  i := map_element.first;
  while i <= map_element.last loop
      if p_direct_name is not null then
         if map_element(i).direct_name = p_direct_name then
            l_name := map_element(i).indirect_name;
            exit;
         end if;
      elsif p_indirect_name is not null then
         if map_element(i).indirect_name = p_indirect_name then
            l_name := map_element(i).direct_name;
            exit;
         end if;
      end if;
      i := map_element.next(i);
  end loop;
  --
  hr_utility.set_location(' Leaving:'||g_package||'map_names', 20);
  --
  return l_name;
  --
end map_names;
--<<***END***>>--

/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**
Function  : DIRECT_TO_INDIRECT - Returns the name of the indirect element for a given direct element.
Returns   : Indirect Element Name
Called By : get_balance_value
**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function direct_to_indirect (p_direct_name in varchar2) return varchar2 is
--<<***BEGIN***>>--
begin
  --
  hr_utility.set_location('Entering:'||g_package||'direct_to_indirect', 10);
  --
  return map_names(p_direct_name => p_direct_name);
  --
end direct_to_indirect;
--<<***END***>>--

/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**
Function  : INDIRECT_TO_DIRECT - Returns the name of the direct element for a given indirect element.
Returns   : Direct Element Name
Called By : get_payment
**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function indirect_to_direct (p_indirect_name in varchar2) return varchar2 is
--<<***BEGIN***>>--
begin
  --
  hr_utility.set_location('Entering:'||g_package||'indirect_to_direct', 10);
  --
  return map_names(p_indirect_name => p_indirect_name);
  --
end indirect_to_direct;
--<<***END***>>--

/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**
Function  : GET_BALANCE_VALUE - This function returns the balance value of an indirect court orders
                                element given the source id and name of the corresponding direct
                                element and the name of the dimension.
                                N.B. The balance has the same name as the indirect element.
Returns   : Balance Value for a given defined balance
Called By : process
**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function get_balance_value(p_element_name    in varchar2
                          ,p_dimension_name  in varchar2
                          ,p_source_id       in number
                          ,p_assignment_action_id in number) return number is
--
cursor csr_get_dimension_id (p_balance_name in varchar2) is
  select db.defined_balance_id
  from   pay_defined_balances  db,
         pay_balance_types     bt,
         pay_balance_dimensions bdim
  where  bt.balance_name = p_balance_name
  and    bt.legislation_code = 'FR'
  and    bdim.dimension_name = p_dimension_name
  and    bdim.legislation_code = 'FR'
  and    db.balance_type_id = bt.balance_type_id
  and    db.balance_dimension_id = bdim.balance_dimension_id;
--
l_defined_balance_id number;
l_result             number := null;
l_balance_name       varchar2(100);
--
--<<***BEGIN***>>--
begin
  --
  hr_utility.set_location('Entering:'||g_package||'get_balance_value', 10);
  --
  l_balance_name := direct_to_indirect(p_element_name);
  --
  open csr_get_dimension_id(l_balance_name);
  fetch csr_get_dimension_id into l_defined_balance_id;
  close csr_get_dimension_id;
  --
  pay_balance_pkg.set_context ('ORIGINAL_ENTRY_ID',p_source_id);
  l_result := pay_balance_pkg.get_value (l_defined_balance_id, p_assignment_action_id);
  --
  hr_utility.set_location(' Leaving:'||g_package||'get_balance_value', 20);
  --
  return l_result;
  --
end get_balance_value;
--<<***END***>>--

/*-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**
Function  : PROCESS - This function will process all the court order elements and store the results
                      in two pl/sql tables. These tables can then be read by subsequent functions
                      to retrieve payments for a particular court order element type.
Returns   : A return value - 0 if there is no error
                             1 if there is an error
Called By : Fast Formula FR_COURT_ORDERS_PAYMENTS
**-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<**/

function process (p_assignment_action_id     in number
                 ,p_date_earned              in date
                 ,p_source_id                in number
                 ,p_net_payment_ptd          in number
                 ,p_rmi                      in number
                 ,p_addl_threshold_per_dpndt in number
                 ,p_addl_seizable            in number
                 ,p_error_msg                out nocopy varchar2) return number is
  --
  i                      number := 0;
  l_old_proc_order       number := 0;
  l_old_priority         number := 0;
  l_last_priority        number := 0;
  l_protected_amt        number := 0;
  l_funds                number := 0;
  l_max_seizure          number := 0;
  l_no_of_dpndts         number := 0;
  l_max_shortfall        number := 0;
  l_max_shortfall_order  number := 0;
  l_shortfall            number := 0;
  l_index                number := 0;
  l_rem_seizable         number := 0;
  l_payment              number := 0;
  l_payment_pro          number := 0;
  l_actual_total_payment number := 0;
  l_remainder            number := 0;
  l_total_remainder      number := 0;
  l_total_payment        number := 0;
  l_total_amount         number := 0;
  l_all_payments         number := 0;
  l_balance_itd          number;
  l_balance_ptd          number;
  co_paid_off            exception;
  TYPE COCurTyp IS REF CURSOR;
  cv   COCurTyp;
  cv_outstanding_balance number := 0;
  cv_index               number := 0;
  --
  cursor csr_get_court_orders is
    select decode(et.element_name
                 ,'FR_FAMILY_MAINTENANCE',10
                 ,'FR_FAMILY_MAINTENANCE_ARREARS',15
                 ,'FR_TAX',20
                 ,'FR_FINE',30
                 ,'FR_MISCELLANEOUS',40
                 ,'FR_SEIZURE',50)                                     PRIORITY
          ,max(decode(iv.name
                     ,'Monthly Payment',rrv.result_value))      MONTHLY_PAYMENT
          ,max(decode(iv.name,'Amount',rrv.result_value))                AMOUNT
          ,max(decode(iv.name
                     ,'Processing Order',rrv.result_value))    PROCESSING_ORDER
          ,et.element_name                                         ELEMENT_NAME
          ,rr.source_id                                               SOURCE_ID
          ,rr.run_result_id                                       RUN_RESULT_ID
    from   pay_element_types_f      et
          ,pay_run_results          rr
          ,pay_run_result_values    rrv
          ,pay_input_values_f       iv
    where et.element_name        in ('FR_FAMILY_MAINTENANCE'
                                    ,'FR_FAMILY_MAINTENANCE_ARREARS'
                                    ,'FR_TAX'
                                    ,'FR_FINE'
                                    ,'FR_MISCELLANEOUS'
                                    ,'FR_SEIZURE')
    and   et.legislation_code     = 'FR'
    and   et.business_group_id   is null
    and   p_date_earned     between et.effective_start_date
                                and et.effective_end_date
    and   et.element_type_id      = rr.element_type_id
    and   rr.assignment_action_id = p_assignment_action_id
    and   rr.run_result_id        = rrv.run_result_id
    and   rrv.input_value_id      = iv.input_value_id
    and   iv.element_type_id      = et.element_type_id
    and   p_date_earned     between iv.effective_start_date
                                and iv.effective_end_date
    and   iv.name                in ('Monthly Payment'
                                    ,'Amount'
                                    ,'Processing Order')
    and   rr.status              in ('P','PA')
    group by decode(et.element_name
                   ,'FR_FAMILY_MAINTENANCE',10
                   ,'FR_FAMILY_MAINTENANCE_ARREARS',15
                   ,'FR_TAX',20
                   ,'FR_FINE',30
                   ,'FR_MISCELLANEOUS',40
                   ,'FR_SEIZURE',50)
            ,et.element_name
            ,rr.source_id
            ,rr.run_result_id
    order by 1, 4;
  --
  /* BUG 2245520 Changed cursor to reflect PQH dynamic dependant calc */
  /* BUG 2481752 Cursor updated to reflect a fix by the PHQ team */
    Cursor csr_no_of_dpndts is
    select count(*)
    from PER_CONTACT_RELATIONSHIPS PCR
      , per_all_assignments_f  a
      , pay_assignment_actions aa
    where PCR.person_id = a.person_id
    and    a.assignment_id = aa.assignment_id
    and    aa.assignment_action_id = p_assignment_action_id
    and    p_date_earned
          between a.effective_start_date and a.effective_end_date
    and  PCR.DEPENDENT_FLAG = 'Y'
    and  ( pcr.date_start is NULL OR p_date_earned BETWEEN
		pcr.date_start AND NVL(pcr.date_end, p_date_earned) )
    and  (pcr.date_start IS NOT NULL OR
		EXISTS (SELECT person_id
		  	FROM per_all_people_f
			WHERE person_id = pcr.contact_person_id
			AND p_date_earned BETWEEN
			effective_start_date AND effective_end_date));

  ---------------------------------------------------------------------------------------------------------
  function get_maximum_allowable_seizure (p_net_payment              in number
                                         ,p_no_of_dependants         in number
                                         ,p_addl_threshold_per_dpndt in number) return number is
    --
    l_seize_amount   number := 0;
    l_addl_threshold number := 0;
    l_seize_basis    number := 0;
    l_low_value      number := 0;
    l_high_value     number := 0;
    l_effective_date date;
    --
    cursor csr_get_band_values is
      select  fnd_number.canonical_to_number(cinst.value)   rate,
              fnd_number.canonical_to_number(cinst2.value)  high_value,
              fnd_number.canonical_to_number(cinst3.value)  low_value
      from    pay_user_column_instances_f        cinst
             ,pay_user_columns                   c
             ,pay_user_column_instances_f        cinst2
             ,pay_user_columns                   c2
             ,pay_user_column_instances_f        cinst3
             ,pay_user_columns                   c3
             ,pay_user_tables                    tab
             ,pay_user_rows_f                    r
      where   tab.user_table_name              = 'FR_COURT_ORDER_BANDS'
      and     tab.user_key_units               = 'N'
      and     c.user_table_id                  = tab.user_table_id
      and     c.legislation_code               = 'FR'
      and     c.user_column_name               = 'DEDUCTION_RATE'
      and     cinst.user_column_id             = c.user_column_id
      and     l_effective_date between cinst.effective_start_date and cinst.effective_end_date
      and     cinst.legislation_code           = 'FR'
      and     c2.user_table_id                  = tab.user_table_id
      and     c2.legislation_code               = 'FR'
      and     c2.user_column_name               = 'Upper Bound'
      and     cinst2.user_column_id             = c2.user_column_id
      and     l_effective_date between cinst2.effective_start_date and cinst2.effective_end_date
      and     cinst2.legislation_code           = 'FR'
      and     c3.user_table_id                  = tab.user_table_id
      and     c3.legislation_code               = 'FR'
      and     c3.user_column_name               = 'Lower Bound'
      and     cinst3.user_column_id             = c3.user_column_id
      and     l_effective_date between cinst3.effective_start_date and cinst3.effective_end_date
      and     cinst3.legislation_code           = 'FR'
      and     r.user_table_id = tab.user_table_id
      and     r.user_row_id = cinst.user_row_id
      and     r.user_row_id = cinst2.user_row_id
      and     r.user_row_id = cinst3.user_row_id;
/*
      --
      -- Table structures changed - select below is if everything is in one row.
      select  fnd_number.canonical_to_number(R.row_low_range_or_name) low_value
             ,fnd_number.canonical_to_number(R.row_high_range)        high_value
             ,cinst.value                                             rate
      from    pay_user_column_instances_f        cinst
             ,pay_user_columns                   c
             ,pay_user_rows_f                    r
             ,pay_user_tables                    tab
      where   tab.user_table_name              = 'FR_COURT_ORDER_BANDS'
      and     c.user_table_id                  = tab.user_table_id
      and     c.legislation_code               = 'FR'
      and     c.user_column_name               = 'DEDUCTION_RATE'
      and     cinst.user_column_id             = c.user_column_id
      and     r.user_table_id                  = tab.user_table_id
      and     l_effective_date between r.effective_start_date and r.effective_end_date
      and     r.legislation_code               = 'FR'
      and     tab.user_key_units               = 'N'
      and     cinst.user_row_id                = r.user_row_id
      and     l_effective_date between cinst.effective_start_date and cinst.effective_end_date
      and     cinst.legislation_code           = 'FR';
*/
    --
  begin
    --
    hr_utility.set_location('Entering:Process - get_maximum_allowable_seizure',10);
    --
    select effective_date
    into   l_effective_date
    from   fnd_sessions
    where  session_id = userenv('SESSIONID');
    --
    /*=============================================================================
      Work out the additional threshold - this is added to each band range
      value, increasing the band range. This is determined by the no. of dependants
      =============================================================================*/
    l_addl_threshold := p_addl_threshold_per_dpndt * p_no_of_dependants;
    --
    hr_utility.set_location('Addl threshold is '||substr(l_addl_threshold,1,5), 15);
    --
    /*=============================================================================
      Use a cursor to retreive all relevant values from User Defind Tables
      The function hruserdt is not used because we want to loop thro' all values
      and not just one - we don't know what the value actually is
      =============================================================================*/
    for r in csr_get_band_values loop
        /*=============================================================================
          Get the low and high value for each band and add additional threshold
          This gives an annual figure which is divided by 12 to get monthly amount
          Then determine how much of the net pay fits into each band selected but don't
          mess the bottom value of zero
          =============================================================================*/
        if r.low_value = 0 then
           l_low_value := 0;
        else
           l_low_value := (r.low_value + l_addl_threshold)/12;
        end if;
        l_high_value   := (r.high_value + l_addl_threshold)/12;
        l_seize_basis  := least(greatest((p_net_payment - l_low_value),0),(l_high_value - l_low_value));
        l_seize_amount := l_seize_amount + (l_seize_basis * r.rate);
    end loop;
    hr_utility.set_location('Seizable is '||substr(l_seize_amount,1,5),15);
    --
    hr_utility.set_location(' Leaving:Process - get_maximum_allowable_seizure',20);
    return l_seize_amount;
    --
  end get_maximum_allowable_seizure;
  ---------------------------------------------------------------------------------------------------------
  procedure process_remainders (p_owed                 in number
                               ,p_max_shortfall_order  in number
                               ,p_total_remainder      in number
                               ,p_actual_total_payment in out nocopy number) is
  begin
     --
     hr_utility.set_location('Entering:Process - process_remainders',10);
     --
     if court_order(p_max_shortfall_order).payment + p_total_remainder
        <= p_owed then
        --
        hr_utility.set_location('Adding remainder:'||substr(p_total_remainder,1,5),15);
        court_order(p_max_shortfall_order).payment := court_order(p_max_shortfall_order).payment + p_total_remainder;
        p_actual_total_payment := p_actual_total_payment + p_total_remainder;
        --
     end if;
     --
     hr_utility.set_location(' Leaving:Process - process_remainders',20);
     --
  end process_remainders;
  ---------------------------------------------------------------------------------------------------------
  procedure init_totals (p_priority in number) is
  begin
      total_order(p_priority).monthly_payment      := 0;
      total_order(p_priority).amount               := 0;
      total_order(p_priority).outstanding_balance  := 0;
      total_order(p_priority).payment              := 0;
      total_order(p_priority).number_of_orders     := 0;
      total_order(p_priority).start_pos            := 0;
      total_order(p_priority).end_pos              := 0;
  end init_totals;
  ---------------------------------------------------------------------------------------------------------
  procedure initialise is
  begin
      hr_utility.set_location('Entering:Process - initialise' , 10);
      --
      -- Initialise the package global variables.
      g_funds := 0;
      g_net_pay_valid := 'Y';
      --
      total_order := total_order_null;
      court_order := court_order_null;
      court_order_index := court_order_index_null;
      init_totals(10);
      init_totals(15);
      init_totals(20);
      init_totals(30);
      init_totals(40);
      init_totals(50);
      /*==========================================================================
        Map direct element names to indirect element names. This mapping is
        used by messages and when getting balance values for indirects.
        ==========================================================================*/
      map_element(10).direct_name   := 'FR_FAMILY_MAINTENANCE';
      map_element(10).indirect_name := 'FR_FAMILY_MAINTENANCE_PAYMENT';
      map_element(15).direct_name   := 'FR_FAMILY_MAINTENANCE_ARREARS';
      map_element(15).indirect_name := 'FR_FAMILY_MAINTENANCE_ARREARS_PAYMENT';
      map_element(20).direct_name   := 'FR_FINE';
      map_element(20).indirect_name := 'FR_FINE_PAYMENT';
      map_element(30).direct_name   := 'FR_TAX';
      map_element(30).indirect_name := 'FR_TAX_PAYMENT';
      map_element(40).direct_name   := 'FR_MISCELLANEOUS';
      map_element(40).indirect_name := 'FR_MISCELLANEOUS_PAYMENT';
      map_element(50).direct_name   := 'FR_SEIZURE';
      map_element(50).indirect_name := 'FR_SEIZURE_PAYMENT';
      hr_utility.set_location(' Leaving:Process - initialise' , 20);
  end initialise;
  ---------------------------------------------------------------------------------------------------------
  procedure process_values (p_priority             in number
                           ,p_funds                in number
                           ,p_actual_total_payment out nocopy number) is
    --
    l_payment         number;
    l_prorate         varchar2(1) := 'N';
    l_sql_string      varchar2(32000);
    l_index           number;
    l_total_amount    number := 0;
    l_total_payment   number := 0;
    l_max_shortfall   number := 0;
    l_shortfall       number := 0;
    l_max_shortfall_order number := 0;
    l_payment_pro     number;
    l_total_remainder number;
    --
  begin
    --
    p_actual_total_payment := 0;
    --
    hr_utility.set_location('Entering:Process - process_values' , 10);
    --
    if total_order(p_priority).number_of_orders > 0 then
       --
       total_order(p_priority).payment := least(p_funds,total_order(p_priority).outstanding_balance);
       hr_utility.set_location('Payment is '||substr(total_order(p_priority).payment,1,5), 10);
       --
       if total_order(p_priority).payment < total_order(p_priority).outstanding_balance then
          l_prorate := 'Y';
          hr_utility.set_location('Prorate = Y', 10);
       end if;
       --
       l_sql_string := null;
       --
       hr_utility.set_location('Building Dynamic SQL',10);
       for i in total_order(p_priority).start_pos..total_order(p_priority).end_pos loop
           --
           l_index := court_order_index(i).source_id;
           --
           l_sql_string := l_sql_string||' select '||court_order(l_index).outstanding_balance||' balance'
                                       ||','||l_index ||' l_index'
                                       ||' from dual';
           --
           if i < total_order(p_priority).end_pos then
              l_sql_string := l_sql_string||' union all ';
           end if;
           --
       end loop;
       hr_utility.set_location('Built Dynamic stmt',10);
       --
       if l_sql_string is not null then
          l_sql_string := l_sql_string||' order by balance';
          --
          if l_prorate = 'Y' then
             l_total_payment := total_order(p_priority).payment;
             l_total_amount  := total_order(p_priority).amount;
          end if;
          --
          hr_utility.set_location('Opening Dynamic cursor',10);
          open cv for l_sql_string;
          loop
               fetch cv into cv_outstanding_balance, cv_index;
               exit when cv%notfound;
               if l_prorate = 'Y' then
                  --
                  if l_total_amount = 0 then
                     hr_utility.set_location('Divide by zero error l_total_amount (1)', 15);
                  end if;
                  l_payment_pro := l_total_payment/l_total_amount;
                  l_payment     := least(floor(l_payment_pro * 100 * court_order(cv_index).amount)/100, court_order(cv_index).outstanding_balance);
                  --
                  l_total_amount  := l_total_amount - court_order(cv_index).amount;
                  l_total_payment := l_total_payment - l_payment;
                  --
               else
                  l_payment := court_order(cv_index).outstanding_balance;
               end if;
               --
               l_shortfall := court_order(cv_index).outstanding_balance - l_payment;
               if l_max_shortfall < l_shortfall then
                  l_max_shortfall       := l_shortfall;
                  l_max_shortfall_order := cv_index;
               end if;
               --
               p_actual_total_payment                            := p_actual_total_payment + l_payment;
               court_order(cv_index).payment := l_payment;
               --
          end loop;
          close cv;
          hr_utility.set_location('Closing dynamic cursor',10);
          --
       end if; -- if l_sql_string not null
       --
       l_total_remainder := total_order(p_priority).payment - p_actual_total_payment;
       if l_total_remainder > 0 then
          process_remainders(court_order(l_max_shortfall_order).outstanding_balance
                            ,l_max_shortfall_order
                            ,l_total_remainder
                            ,p_actual_total_payment);
       end if;
       --
    end if; -- no of Arrears > 0
    --
    hr_utility.set_location(' Leaving:Process - process_values' , 20);
    --
  end process_values;
  ---------------------------------------------------------------------------------------------------------
--<<***BEGIN***>>--
begin
  --
  hr_utility.set_location('Entering:function Process' , 10);
  --
  initialise;
  /*=============================================================================
    Get the number of dependants. This is used in max seizable calculation.
    =============================================================================*/
  open csr_no_of_dpndts;
  fetch csr_no_of_dpndts into l_no_of_dpndts;
  close csr_no_of_dpndts;
  --
  hr_utility.set_location('. Dependants Found='||l_no_of_dpndts,15);
  g_assignment_action_id := p_assignment_action_id;
  l_protected_amt := p_rmi;
  --
  if (p_net_payment_ptd + p_addl_seizable) <= l_protected_amt then
     hr_utility.set_location('Net Pay Not Valid return = 0' , 10);
     g_net_pay_valid := 'N';
     return 0;
  end if;
  --
  g_funds         := (p_net_payment_ptd + p_addl_seizable) - l_protected_amt;
  l_max_seizure   := get_maximum_allowable_seizure(p_net_payment_ptd,nvl(l_no_of_dpndts,0),p_addl_threshold_per_dpndt) + p_addl_seizable;
  l_remainder     := g_funds - l_max_seizure;
  --
  /*=============================================================================
    These are both set to 10 as I know that the first priority to be returned
    by the cursor will be a P10 - and there will only be one of these
    =============================================================================*/
  l_old_priority   := 10;
  l_last_priority  := 10;
  -------------------------------------------------------------------------------------------------------
  --<*><*><*><*><*><*><*><*><*><*><*> Populate PL/SQL Tables <*><*><*><*><*><*><*><*><*><*><*><*><*><*>--
  -------------------------------------------------------------------------------------------------------
  hr_utility.set_location('Populating PL/SQL tables',15);
  i := 1;
  for o in csr_get_court_orders loop
      l_balance_itd := nvl(get_balance_value
                             (o.element_name
                             ,'FR Element-level ELE_ITD'
                             ,o.source_id,p_assignment_action_id),0);
      l_balance_ptd := nvl(get_balance_value
                             (o.element_name
                             ,'FR Element-level ELE_PTD'
                             ,o.source_id,p_assignment_action_id),0);
      --
      begin
        /*================================================================================================
          If the current element being processed has an amount input value (ie not type P1) then check if
          the total amount due has already been paid off. If it has then do not store this row and carry on.
          Also check on Arrears and Seizure payments whether the total amount due would be exceeded by the
          monthly payment value - if it would then set the monthly amount to the remaining that is owed,
          as at the start of the period.
          ================================================================================================*/
        if o.priority <> 10 then
           if l_balance_itd < fnd_number.canonical_to_number(o.amount) then
              if o.priority in (15,50) and
                 ((l_balance_itd +
                   nvl(fnd_number.canonical_to_number(o.monthly_payment),0)) >
                  fnd_number.canonical_to_number(o.amount))
              then
                 court_order(o.source_id).monthly_payment :=
                    fnd_number.canonical_to_number(o.amount) -
                    (l_balance_itd - l_balance_ptd);
              end if;
           else
              raise co_paid_off;
           end if;
        end if;
        /*==============================================================================
          If the monthly payment has not already been assigned above then assign it now.
          ==============================================================================*/
        if not court_order.exists(o.source_id) then
           court_order(o.source_id).monthly_payment :=
                             fnd_number.canonical_to_number(o.monthly_payment);
        end if;
        court_order(o.source_id).amount :=
           fnd_number.canonical_to_number(o.amount);
        court_order(o.source_id).outstanding_balance :=
           court_order(o.source_id).amount - (l_balance_itd - l_balance_ptd);
        court_order(o.source_id).balance_ptd := l_balance_ptd;
        court_order(o.source_id).priority := o.priority;
        --
        court_order_index(i).source_id := o.source_id;
        /*==============================================================================
          Work out whether the priority should be incremented by 10 - this is only
          applicable to P5's with a different/new processing sequence.
          ==============================================================================*/
        if o.priority = 50 then
           if l_index < 50 then
              l_index := 50;
              l_old_proc_order :=
                 fnd_number.canonical_to_number(o.processing_order);
           end if;
           if l_old_proc_order <>
              fnd_number.canonical_to_number(o.processing_order)
           then
              l_index := l_index + 10;
           end if;
        else
           l_index := o.priority;
        end if;
        --
        if l_old_priority < l_index then
           l_last_priority := l_old_priority;
        end if;
        --
        if total_order.exists(l_index) then
           total_order(l_index).monthly_payment     := total_order(l_index).monthly_payment + court_order(o.source_id).monthly_payment;
           total_order(l_index).amount              := total_order(l_index).amount + fnd_number.canonical_to_number(o.amount);
           total_order(l_index).number_of_orders    := total_order(l_index).number_of_orders+1;
           total_order(l_index).outstanding_balance := total_order(l_index).outstanding_balance + court_order(o.source_id).outstanding_balance;
           total_order(l_index).start_pos           := total_order(l_last_priority).end_pos + 1;
           total_order(l_index).end_pos             := i;
        else
           /*=========================================================================================
             This should only happen to priorities above 50 (ie for processing orders) as all values
             below 50 have been initialised by procedure initialise. Cannot initialise for any value
             above 50 because this depends upon the number of unique processing orders - which we
             don't know as they are defined by the user.
             =========================================================================================*/
           if o.priority > 40 then
              total_order(l_index).monthly_payment     :=
                 fnd_number.canonical_to_number(o.monthly_payment);
              total_order(l_index).payment             := 0;
              total_order(l_index).amount              :=
                 fnd_number.canonical_to_number(o.amount);
              total_order(l_index).number_of_orders    := 1;
              total_order(l_index).outstanding_balance := court_order(o.source_id).outstanding_balance;
              total_order(l_index).start_pos           := total_order(l_last_priority).end_pos + 1;
              total_order(l_index).end_pos             := i;
           end if;
        end if;
        --
        if o.priority = 50 then
           l_old_proc_order :=
               fnd_number.canonical_to_number(o.processing_order);
        end if;
        --
        l_old_priority := l_index;
        -- Row counter
        i := i + 1;
        --
      exception
        when co_paid_off then
             null;
      end;
      --
  end loop;
  hr_utility.set_location('PL/SQL tables populated',15);
  /*=====================================================================
    Cannot have both P4's and P5's in same run - check if this is true.
    =====================================================================*/
  p_error_msg := validation;
  if p_error_msg is not null then
     hr_utility.set_location(' Leaving:function Process return = 1' , 20);
     return 1;
  end if;
  hr_utility.set_location('Validation successful',15);
  --------------------------------------------------------------------------------------------------------
  --<*><*><*><*><*><*><*><*><*><*><*> Process Family Maintenance <*><*><*><*><*><*><*><*><*><*><*><*><*>--
  --------------------------------------------------------------------------------------------------------
  if total_order(10).number_of_orders > 0 then
     --
     l_index := court_order_index(total_order(10).start_pos).source_id;
     --
     total_order(10).payment := least(g_funds,total_order(10).monthly_payment);
     court_order(l_index).payment := total_order(10).payment;
     --
     l_actual_total_payment := total_order(10).payment;
     --
  end if;  -- if no of P1's > 0
  --
  hr_utility.set_location('P1 processing complete',15);
  g_funds := g_funds - l_actual_total_payment;
  l_all_payments := l_actual_total_payment;
  l_actual_total_payment := 0;
  --------------------------------------------------------------------------------------------------------
  --<*><*><*><*><*><*><*><*><*> Process Family Maintenance Arrears  <*><*><*><*><*><*><*><*><*><*><*><*>--
  --------------------------------------------------------------------------------------------------------
  if total_order(15).number_of_orders > 0 then
     --
     l_index := court_order_index(total_order(15).start_pos).source_id;
     --
     total_order(15).payment := least(g_funds,total_order(15).monthly_payment);
     court_order(l_index).payment := total_order(15).payment;
     --
     l_actual_total_payment := total_order(15).payment;
     --
  end if;  -- if no of P15's > 0
  --
  hr_utility.set_location('P15 processing complete',15);
  --
  g_funds := g_funds - l_actual_total_payment;
  l_all_payments := l_all_payments + l_actual_total_payment;
  --
  l_actual_total_payment := 0;
  l_max_shortfall := 0;
  --------------------------------------------------------------------------------------------------------
  --<*><*><*><*><*><*><*><*><*><*><*><*><*> Process Taxes  <*><*><*><*><*><*><*><*><*><*><*><*><*><*><*>--
  --------------------------------------------------------------------------------------------------------
  if g_funds > 0 then
     process_values(p_priority             => 20
                   ,p_funds                => g_funds
                   ,p_actual_total_payment => l_actual_total_payment);
  end if;
  hr_utility.set_location('P2 processing complete',15);
  --
  g_funds := g_funds - l_actual_total_payment;
  l_all_payments := l_all_payments + l_actual_total_payment;
  --------------------------------------------------------------------------------------------------------
  --<*><*><*><*><*><*><*><*><*><*><*><*><*> Process Fines  <*><*><*><*><*><*><*><*><*><*><*><*><*><*><*>--
  --------------------------------------------------------------------------------------------------------
  if g_funds > 0 then
     if total_order(30).number_of_orders > 0 then
        l_actual_total_payment := 0;
        l_max_shortfall := 0;
        /*=====================================================================================================
          Calculate how much of the max seizable is left after P10, P15 and P20 payments have been calculated.
          =====================================================================================================*/
        l_rem_seizable := l_max_seizure - least(l_max_seizure,total_order(20).payment)
                                        - greatest(((total_order(10).payment+total_order(15).payment) - l_remainder),0);
        --
        if l_rem_seizable > 0 then
           g_funds := l_rem_seizable;
           process_values(p_priority             => 30
                         ,p_funds                => g_funds
                         ,p_actual_total_payment => l_actual_total_payment);
           g_funds := g_funds - l_actual_total_payment;
           l_all_payments := l_all_payments + l_actual_total_payment;
        end if;
     end if;
  end if;
  hr_utility.set_location('P3 processing complete',15);
  --------------------------------------------------------------------------------------------------------
  --<*><*><*><*><*><*><*><*><*><*><*><*><*> Miscellaneous  <*><*><*><*><*><*><*><*><*><*><*><*><*><*><*>--
  --------------------------------------------------------------------------------------------------------
  if g_funds > 0 then
     if total_order(40).number_of_orders > 0 then
        --
        l_rem_seizable := l_max_seizure - least(l_max_seizure,total_order(20).payment)
                                        - greatest(((total_order(10).payment+total_order(15).payment) - l_remainder),0)
                                        - total_order(30).payment;
        --
        if l_rem_seizable > 0 then
           --
           g_funds := l_rem_seizable;
           l_index := court_order_index(total_order(40).start_pos).source_id;
           --
           total_order(40).payment := least(g_funds,total_order(40).amount);
           court_order(l_index).payment := total_order(40).payment;
           --
           l_actual_total_payment := total_order(40).payment;
           --
           g_funds := g_funds - l_actual_total_payment;
           --
        end if;
     end if;  -- if no of P40's > 0
  end if;
  hr_utility.set_location('P4 processing complete',15);
  /*=====================================================================
    Recalculate remaining seizable
    =====================================================================*/
  l_rem_seizable := l_max_seizure - least(l_max_seizure,total_order(20).payment)
                                  - greatest(((total_order(10).payment+total_order(15).payment) - l_remainder),0)
                                  - total_order(30).payment
                                  - total_order(40).payment;
  --------------------------------------------------------------------------------------------------------
  --<*><*><*><*><*><*><*><*><*><*><*><*><*> Process Seizure  <*><*><*><*><*><*><*><*><*><*><*><*><*><*>---
  --------------------------------------------------------------------------------------------------------
  if l_rem_seizable > 0 then
     /*===============================================================================
       Set i to 50 as it is known that the first P50 element will have this priority
       ===============================================================================*/
     g_funds := l_rem_seizable;
     i := 50;
     l_max_shortfall := 0;
     l_shortfall     := 0;
     --
     hr_utility.set_location('Processing P5 elements ..', 15);
     --
     while i <= total_order.last loop
           --
           l_actual_total_payment := 0;
           --
           if total_order(i).number_of_orders > 0 then
              --
              total_order(i).payment := least(g_funds,total_order(i).monthly_payment);
              l_total_payment := total_order(i).payment;
              l_total_amount  := total_order(i).monthly_payment;
              --
              if l_total_amount = 0 then
                 hr_utility.set_location('Divide by zero error l_total_amount (2)', 15);
              end if;
              --
              l_payment_pro   := l_total_payment/l_total_amount;
              /*===============================================================================
                Go thro' each indivdual P50 element for the current processing order
                ===============================================================================*/
              for c in total_order(i).start_pos..total_order(i).end_pos loop
                  --
                  l_index         := court_order_index(c).source_id;
                  l_payment       := floor(l_payment_pro * 100 * court_order(l_index).monthly_payment)/100;
                  --
                  l_shortfall := court_order(l_index).monthly_payment - l_payment;
                  if l_max_shortfall < l_shortfall then
                     l_max_shortfall       := l_shortfall;
                     l_max_shortfall_order := l_index;
                  end if;
                  --
                  l_actual_total_payment                       := l_actual_total_payment + l_payment;
                  court_order(l_index).payment := l_payment;
                  --
                  l_total_payment := l_total_payment - l_payment;
                  l_total_amount  := l_total_amount  - court_order(l_index).monthly_payment;
                  --
              end loop;
              --
              l_total_remainder := total_order(i).payment - l_actual_total_payment;
              if l_total_remainder > 0 then
                 process_remainders(court_order(l_max_shortfall_order).outstanding_balance
                                   ,l_max_shortfall_order
                                   ,l_total_remainder
                                   ,l_actual_total_payment);
              end if;
              g_funds := g_funds - l_actual_total_payment;
              --
           end if;
           /*===============================================================================
             Go on to next processing order (sub-priority)
             ===============================================================================*/
           i := i + 10;
           --
     end loop;
     --
     hr_utility.set_location('P5 processing complete',15);
     --
  end if; -- If rem_seizable > 0
  --
  hr_utility.set_location(' Leaving:function Process return = 0' , 10);
  return 0;
  --
end process;
--<<***END***>>--

end pay_fr_court_orders;

/
