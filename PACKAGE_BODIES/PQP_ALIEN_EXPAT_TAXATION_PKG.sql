--------------------------------------------------------
--  DDL for Package Body PQP_ALIEN_EXPAT_TAXATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ALIEN_EXPAT_TAXATION_PKG" as
/* $Header: pqalnexp.pkb 120.3.12010000.5 2008/09/17 22:12:45 rnestor ship $ */

  -- global Variable
     g_package        constant varchar2(150) := 'pqp_alien_expat_taxation_pkg';
     g_bus_grp_id              number(15);
  --
  -- The cursor below selects the process_event_id, object_version_number,
  -- assignment_id, description from pay_process_events with status = 'NOT_READ'
  --
    cursor pay_process_events_ovn_cursor(p_person_id1      in number
                                        ,p_change_type1    in varchar2
                                        ,p_effective_date1 in date) is

    select ppe.process_event_id      process_event_id
          ,ppe.object_version_number object_version_number
          ,paf.assignment_id         assignment_id
          ,ppe.description           description

      from pay_process_events ppe
          ,per_people_f       ppf
          ,per_assignments_f  paf

     where ppf.person_id                  = p_person_id1
       and ppf.person_id                  = paf.person_id
       and ppe.assignment_id              = paf.assignment_id
       and ppe.change_type                = p_change_type1
       and ppf.effective_start_date <= to_date(('12/31/' ||
                      to_char(p_effective_date1,'YYYY')), 'MM/DD/YYYY')
       and ppf.effective_end_date   >= to_date(('01/01/' ||
                      to_char(p_effective_date1,'YYYY')), 'MM/DD/YYYY')
       and ppf.effective_start_date =
               (select max(effective_start_date)
                  from per_people_f
                 where person_id = ppf.person_id
                   and effective_start_date <=
                       to_date(('12/31/' ||TO_CHAR(p_effective_date1,'YYYY')), 'MM/DD/YYYY')
                )

       and paf.effective_start_date <=
               to_date(('12/31/' ||TO_CHAR(p_effective_date1,'YYYY')), 'MM/DD/YYYY')
       and paf.effective_end_date  >=
               to_date(('01/01/' || to_char(p_effective_date1,'YYYY')), 'MM/DD/YYYY')
       and paf.effective_start_date =
            (select max(effective_start_date)
               from per_assignments_f
              where assignment_id = paf.assignment_id
                and effective_start_date <=
                    to_date(('12/31/' ||to_char(p_effective_date1,'YYYY')), 'MM/DD/YYYY')
             )
       and ppe.status = 'N';
  --
  -- The cursor below checks whether a country code passed is a valid
  -- IRS country code or not
  --
    cursor c_tax_country_code_cursor(p_country_code   in varchar2,
                                     p_effective_date in date) is
    select count(*)
      from hr_lookups hrl
     where hrl.lookup_type        = 'PER_US_COUNTRY_CODE'
       and hrl.enabled_flag       = 'Y'
       and nvl(start_date_active, p_effective_date) <= to_date(('12/31/' ||
              to_char(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
       and nvl(end_date_active, p_effective_date) >= to_date(('01/01/' ||
              to_char(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
       and upper(hrl.lookup_code) = upper(p_country_code)
       order  by hrl.lookup_code;
  --
  -- The cursor c_person_visit_spouse_info gives the Visit history of a particular
  -- person id. Duplicated the information_category where clause of the virtual
  -- view, in the actual where clause as this query behaves differently in
  -- different databases.
  --
    cursor c_person_visit_spouse_info(p_person_id       in number
                                     ,p_effective_date  in date) is
    select pei_information5   purpose
          ,pei_information7   start_date
          ,pei_information8   end_date
          ,pei_information9   spouse_accompanied
          ,pei_information10  child_accompanied
      from (select *
              from per_people_extra_info
             where information_type  = 'PER_US_VISIT_HISTORY'
           ) ppei
     where ppei.person_id           = p_person_id
       and ppei.information_type    = 'PER_US_VISIT_HISTORY'
       and (to_char(fnd_date.canonical_to_date(ppei.pei_information7),'YYYY')=
            to_char(p_effective_date, 'YYYY')
            or
            to_char(fnd_date.canonical_to_date(ppei.pei_information8),'YYYY')=
            to_char(p_effective_date, 'YYYY')
            or
            p_effective_date
               between fnd_date.canonical_to_date(ppei.pei_information7)
                   and nvl(fnd_date.canonical_to_date(ppei.pei_information8),
                           to_date('12/31/4712','MM/DD/YYYY')
                           )
           )
       order by 4 asc;
  --
  -- The cursor below gets the batch size
  --
     cursor c_pay_action_parameter is
     select parameter_value
       from pay_action_parameters
      where parameter_name = 'PQP_US_WINDSTAR_READ_BATCH';
  --
  -- The cursor below gets the additional details of a person
  --
     cursor c_person_additional_info(p_person_id   in number   ) is
     select pei_information5            residency_status
           ,pei_information7            resident_status_date
           ,pei_information12           process_type
           ,pei_information8            first_entry_date
           ,nvl(pei_information10, 0)   dep_children_total
           ,nvl(pei_information11, 0)   dep_children_in_cntry
           ,pei_information9            tax_res_country_code
      from (select *
              from per_people_extra_info
             where information_type  = 'PER_US_ADDITIONAL_DETAILS'
               and person_id         = p_person_id );
  --
  -- The cursor below selects the object version number in pay_process_events table.
  --
     cursor c_ovn_ppe(p_process_event_id in number) is
     select object_version_number
       from pay_process_events
      where process_event_id = p_process_event_id;

  -- local Variable
     l_batch_size              number;

  -- ===========================================================================
  --  Name     : IsPayrollRun
  --  Purpose  : The following function return TRUE or FALSE when a person id
  --             and a date in a year is passed as input. It return TRUE if a
  --             payroll has been run for that person. Otherwise it returns a
  --             FALSE.
  --  Arguments :
  --   IN
  --      p_person_id       : Person Id
  --      p_effective_date  : Effective date.
  --      p_income_code     : Income Code
  --   OUT NOCOPY           : Boolean
  --  Notes                 : Private
  --  Added p_income_code parameter and changed the main select statement
  --  to check if the income code was processed during the payroll run.
  -- ===========================================================================

  function IsPayrollRun(p_person_id      in number
                       ,p_effective_date in date
                       ,p_income_code    in varchar2)
  return boolean is

   cursor IsPayrollRun (p_person_id      in number
                       ,p_effective_date in date
                       ,p_income_code    in varchar2 ) is
   select 'Y' from
   dual where exists
              (select ppa.date_earned
                 from pay_payroll_actions         ppa
                     ,pay_assignment_actions      paa
                     ,pay_run_results             prr
                     ,pay_element_types_f         pet
                     ,pay_element_classifications pec
                     ,per_assignments_f           paf
                where ppa.payroll_action_id      = paa.payroll_action_id
                  and paa.assignment_id          = paf.assignment_id
                  and ppa.action_status          = 'C'
                  and paa.action_status          = 'C'
                  and ppa.action_type            in ('R','Q','I','B','V')
                  and paf.person_id              = p_person_id
                  and prr.assignment_action_id   = paa.assignment_action_id
                  and pet.element_type_id        = prr.element_type_id
                  and prr.status                 = 'P'
                  and pet.classification_id      = pec.classification_id
                  and pec.classification_name    = 'Alien/Expat Earnings'
                  and pet.element_information1   = p_income_code
                  and paf.effective_start_date  <= p_effective_date
                  and ppa.effective_date        <= p_effective_date);

    l_temp_var         varchar2(10);
    l_proc    constant varchar2(150) := g_package||'IsPayrollRun';

  begin

    hr_utility.set_location('Entering: '||l_proc, 5);

    l_temp_var := 'N';

    open IsPayrollRun(p_person_id,
                      p_effective_date,
                      p_income_code);
    fetch IsPayrollRun into l_temp_var;
    close IsPayrollRun;
    if (l_temp_var = 'Y') then
       return true;
    else
        return false;
    end if;

    hr_utility.set_location('Leaving: '||l_proc, 80);

  end IsPayrollRun;

  -- ===========================================================================
  --  Name     : PQP_Balance
  --  Purpose  : The following function is called from pqp_windstar_balance_read.
  --             This returns the balance amount for an assignment and dimension
  --             on an effective_date. If an assignment for the person is passed,
  --             then the balances are given for a person. This is due to the
  --             default dimension this function uses.
  --  Arguments :
  --   In
  --      p_balance_name        : Name of the balance
  --      p_dimension_name      : Dimension Name
  --      p_assignment_id       : Assignment Id
  --      p_effective_date      : Effective date.
  --   Out NoCopy               : None
  --  Notes                     : Private
  -- ===========================================================================
  function PQP_Balance
          (p_income_code      in varchar2
          ,p_dimension_name   in varchar2
          ,p_assignment_id    in number
          ,p_effective_date   in date
          ,p_state_code       in varchar2
          ,p_fit_wh_bal_flag  in varchar2
          ,p_balance_name     in varchar2
           )
  return number is

    l_balance_amount  number := 0   ;
    l_proc   constant varchar2(150) := g_package||'PQP_Balance';

  begin

    hr_utility.set_location('Entering: '||l_proc, 5);

    l_balance_amount :=  pqp_us_ff_functions.get_alien_bal
                        (p_assignment_id   => p_assignment_id
                        ,p_effective_date  => p_effective_date
                        ,p_tax_unit_id     => null
                        ,p_income_code     => p_income_code
                        ,p_balance_name    => p_balance_name
                        ,p_dimension_name  => p_dimension_name
                        ,p_state_code      => p_state_code
                        ,p_fit_wh_bal_flag => p_fit_wh_bal_flag
                         );

    hr_utility.set_location('Leaving: '||l_proc, 10);

    return l_balance_amount;

  exception
    when others then
     hr_utility.set_location('Leaving: '||l_proc, 15);
     return 0;

  end PQP_Balance;

  -- ===========================================================================
  --  Name     : PQP_Forecasted_Balance
  --  Purpose  : The following function is called from pqp_windstar_balance_read.
  --             This returns the forecasted balance amount for a person.
  --  Arguments :
  --   IN
  --      p_person_id           : Person Id
  --      p_income_code         : Income Code
  --      p_effective_date      : Effective date.
  --   Out NoCopy               : None
  --  Notes                     : Private
  -- ===========================================================================
  function PQP_Forecasted_Balance
          (p_person_id      in number
          ,p_income_code    in varchar2
          ,p_effective_date in date
           )
  return number is

  --
  -- Segments: Income_Code - pei_information5
  --           Amount      - pei_information7
  --           Year        - pei_information8
  --
    cursor c2 is
    select pei_information7 amount
      from (select *
              from per_people_extra_info
             where person_id = p_person_id
               and information_type = 'PER_US_INCOME_FORECAST'
            )
     where pei_information5 = p_income_code
       and pei_information8 = to_char(p_effective_date, 'YYYY');

    lnum             number;
    l_proc  constant varchar2(72) := g_package||'PQP_Forecasted_Balance';

  begin

    hr_utility.set_location('Entering: '||l_proc, 5);
    lnum := 0;

    for c2_cur in c2
    loop
        lnum := c2_cur.amount;
        hr_utility.set_location(l_proc, 6);
    end loop;

    hr_utility.set_location('Leaving: '||l_proc, 10);

    return lnum;
  exception
     when others then
      hr_utility.set_location('Leaving: '||l_proc, 15);
      return 0;

  end PQP_Forecasted_Balance;

  -- ===========================================================================
  --  Name      : PQP_Windstar_Person_Validate
  --  Purpose   : The following procedure is called from pqp_windstar_person_read.
  --              This validates the person record.
  --  Arguments :
  --    IN
  --        p_in_data_rec    : The PL/SQL table that contains the Person Records
  --        p_effective_date : DATE
  --    OUT
  --        p_out_mesg     : Error Message.
  --  Notes                : Private
  -- ===========================================================================
  procedure PQP_Windstar_Person_Validate
           (p_in_data_rec    in  t_people_rec_type
           ,p_effective_date in  date
           ,p_out_mesg       out nocopy   out_mesg_type
            ) is

  --
  -- The following cursor verifies whether the country code passed is a valid
  -- coutry code
  --
     cursor c_non_us_address_cur(p_country_code  in varchar2) is
     select count(*)
       from fnd_territories_vl
      where territory_code = upper(p_country_code);

    l_temp_prefix          varchar2(45) := ':';
    l_count                number := 0;
    l_non_us_country_code  varchar2(100);
    l_proc  constant       varchar2(150):= g_package||'PQP_Windstar_Person_Validate';

  begin
    hr_utility.set_location('Entering:'||l_proc, 5);

    p_out_mesg := 'ERROR ==> ';

    if (rtrim(ltrim(p_in_data_rec.last_name))  is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Last Name is NULL';
    end if;
    if (rtrim(ltrim(p_in_data_rec.first_name)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'First Name is NULL';
    end if;
    if (rtrim(ltrim(p_in_data_rec.person_id))  is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Person Id is NULL';
    end if;
    if (rtrim(ltrim(p_in_data_rec.national_identifier))  is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix ||
                                 'National Identifier is NULL';
    end if;
    if (rtrim(ltrim(p_in_data_rec.city))                 is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'City is NULL';
    end if;
    if (rtrim(ltrim(p_in_data_rec.address_line1))        is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Address Line1 is NULL';
    end if;
    if (rtrim(ltrim(p_in_data_rec.state))                is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'State is NULL';
    end if;
    if (rtrim(ltrim(p_in_data_rec.postal_code))          is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Postal Code is NULL';
    end if;
    if (rtrim(ltrim(p_in_data_rec.citizenship_c_code)) is null or
        p_in_data_rec.citizenship_c_code  = ' '    ) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Citizenship Code is NULL';
        null;
    else
        hr_utility.set_location(l_proc, 6);
        open c_tax_country_code_cursor(p_in_data_rec.citizenship_c_code ,
                                       p_effective_date                 );
        fetch c_tax_country_code_cursor into l_count;
        hr_utility.set_location(l_proc, 7);
        close c_tax_country_code_cursor;
        if (l_count = 0) then
            p_out_mesg := p_out_mesg || l_temp_prefix ||
                               'citizenship code is invalid';
        end if;
        hr_utility.set_location(l_proc, 8);
    end if;
    if (p_out_mesg = 'ERROR ==> ') then
        p_out_mesg := null;
    end if;
    hr_utility.set_location('Leaving: '||l_proc, 10);

  exception
    when others then
     hr_utility.set_location('Leaving: '||l_proc, 15);

     p_out_mesg := SUBSTR(p_out_mesg || TO_CHAR(SQLCODE) || SQLERRM, 1, 240) ;

  end PQP_Windstar_Person_Validate;

  -- ===========================================================================
  --  Name      : PQP_Windstar_Visa_Validate
  --  Purpose   : The following procedure is called from pqp_windstar_visa_read.
  --              This validates the visa record.
  --  Arguments :
  --    IN
  --      p_in_data_rec    : The PL/SQL table that contains the Visa Records
  --      p_effective_date : DATE
  --    OUT
  --        p_out_mesg     : Error Message.
  --  Notes                : Private
  -- ===========================================================================
  procedure PQP_Windstar_Visa_Validate
         (p_in_data_rec    in    t_visa_rec_type
         ,p_effective_date in    date
         ,p_prev_end_date  in    date
         ,p_out_mesg       out nocopy   out_mesg_type
         ) is
    l_proc  constant varchar2(72) := g_package||'PQP_Windstar_Visa_Validate';
    l_temp_prefix    varchar2(45) := ':';

  begin

    hr_utility.set_location('Entering:'||l_proc, 5);

    p_out_mesg := 'ERROR ==> ';
    if (ltrim(rtrim(p_in_data_rec.visa_type)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Visa Type is NULL';
    end if;

    if (p_prev_end_date is not null) then
       if (p_prev_end_date = p_in_data_rec.visa_start_date ) then
           p_out_mesg := p_out_mesg || l_temp_prefix || 'Visa record having a'
                         ||' start date of ' || TO_CHAR(p_in_data_rec.visa_start_date,'DD/MM/YYYY')
                         || '(DD/MM/YYYY) is overlapping with the end date of another visa record';
       end if;
    end if;

    if (p_in_data_rec.visa_type = 'J-1' or
        p_in_data_rec.visa_type = 'J-2') then
        if (ltrim(rtrim(p_in_data_rec.j_category_code)) is null) then
           p_out_mesg := p_out_mesg || l_temp_prefix || 'Visa Category is NULL';
        end if;
    end if;

    if (ltrim(rtrim(p_in_data_rec.visa_end_date)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Visa End Date is NULL';
    end if;

    if (ltrim(rtrim(p_in_data_rec.visa_number)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Visa number is NULL';
    end if;

    if (ltrim(rtrim(p_in_data_rec.primary_activity_code)) is null) then
         p_out_mesg := p_out_mesg || l_temp_prefix ||
                                  'Primary Activity/Purpose is NULL';
    end if;

    if (p_out_mesg = 'ERROR ==> ') then
        p_out_mesg := null;
    end if;

    hr_utility.set_location('Leaving:'||l_proc, 10);

  exception
    when others then
       hr_utility.set_location('Entering excep:'||l_proc, 15);
       p_out_mesg := SUBSTR(p_out_mesg || TO_CHAR(SQLCODE) || SQLERRM, 1, 240) ;

  end PQP_Windstar_Visa_Validate;

  -- ===========================================================================
  --  Name      : PQP_Windstar_Balance_Validate
  --  Purpose   : The following procedure is called from pqp_windstar_person_read.
  --              This validates the person record.
  --  Arguments :
  --    IN
  --        p_in_data_rec    : The PL/SQL table that contains the Person Records
  --        p_effective_date : Date
  --    OUT
  --        p_out_mesg       : Error Message.
  --  Notes                  : Private
  -- ===========================================================================
  procedure PQP_Windstar_Balance_Validate
           (p_in_data_rec    in  t_balance_rec_type
           ,p_effective_date in  date
           ,p_out_mesg       out nocopy out_mesg_type
           ,p_forecasted     in  boolean
            ) is
  --
  l_proc  constant varchar2(72) := g_package||'PQP_Windstar_Balance_Validate';
  l_temp_prefix    varchar2(45) := ':';
  --
  begin
    hr_utility.set_location('Entering: '||l_proc, 5);

    p_out_mesg := 'ERROR ==> ';

    if (rtrim(ltrim(p_in_data_rec.income_code)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Income Code is NULL';
    end if;

    if (rtrim(ltrim(p_in_data_rec.income_code_sub_type)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix ||
                                   'Income Code Sub Type is NULL';
    end if;

    if (rtrim(ltrim(p_in_data_rec.exemption_code)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Exemption Code is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.gross_amount)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Gross Amount is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.withholding_allowance)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix ||
                                               'Withholding Allowance is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.withholding_rate)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Withholding Rate is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.withheld_amount)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Withheld Amount is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.income_code_sub_type)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix ||
                                               'Income Code Sub Type is NULL';
    end if;
    if (RTRIM(LTRIM(p_in_data_rec.country_code)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Country Code is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.tax_year)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Tax Year is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.state_withheld_amount)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix ||
                                              'State Withheld Amount is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.state_code)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'State Code is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.payment_type)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Payment Type is NULL';
    end if;

    if (RTRIM(LTRIM(p_in_data_rec.record_status)) is null) then
        p_out_mesg := p_out_mesg || l_temp_prefix || 'Record Status is NULL';
    end if;

    --
    -- commented the following by skutteti. Even though there is a record in
    -- Analyzed alien data/details table, it does not mean that the payroll
    -- has been run for the person. Hence the last date of earnings and
    -- cycle date might be null. Since for forecasted it is null, temporarily
    -- commenting it
    --
    --IF (p_forecasted = FALSE) THEN
    --    IF (RTRIM(LTRIM(p_in_data_rec.last_date_of_earnings))     IS NULL) THEN
    --        p_out_mesg := p_out_mesg || l_temp_prefix ||
    --                                         'Last date of earnings is NULL';
    --    END IF;
    --    IF (RTRIM(LTRIM(p_in_data_rec.cycle_date))                IS NULL) THEN
    --        p_out_mesg := p_out_mesg || l_temp_prefix || 'Cycle Date is NULL';
    --    END IF;
    --END IF;

    if hr_api.not_exists_in_hr_lookups
      (p_lookup_type    => 'PER_US_INCOME_TYPES'
      ,p_lookup_code    => p_in_data_rec.income_code ||
                           p_in_data_rec.income_code_sub_type
      ,p_effective_date => p_effective_date)  then

       hr_utility.set_location(l_proc, 6);

       p_out_mesg := p_out_mesg || l_temp_prefix ||
                     'Invalid combination of Income code and scholarship code :'
                          || p_in_data_rec.income_code ||
                               p_in_data_rec.income_code_sub_type;
    end if;

    if (p_out_mesg = 'ERROR ==> ') then
        p_out_mesg := null;
    end if;

    hr_utility.set_location('Leaving:'||l_proc, 10);
  exception
    when OTHERS then
     hr_utility.set_location('Entering excep:'||l_proc, 15);
     p_out_mesg := SUBSTR(p_out_mesg || TO_CHAR(SQLCODE) || SQLERRM, 1, 240) ;

  end PQP_Windstar_Balance_Validate;

  -- ===========================================================================
  -- Name      : PQP_Process_Events_ErrorLog
  -- Purpose   : the following procedure is called from pqp_windstar_person_read.
  --            This inserts a record in pay_process_events table
  --            with DATA_VALIDATION_FAILED status.  A record is created only
  --            if a record for an assignment does not already exist
  -- Arguments :
  --  In
  --    p_assignment_id1         : Assignment Id
  --    p_effective_date1        : Effective date.
  --    p_change_type1           : source type (Windstar)
  --    p_status1                : DATA_VALIDATION_FAILED
  --    p_description1           : Description of the error
  --  Out NoCopy                 : none
  -- Notes                       : private
  -- ===========================================================================
  procedure PQP_Process_Events_ErrorLog
           (p_assignment_id1        in     per_assignments_f.assignment_id%type
           ,p_effective_date1       in     date
           ,p_change_type1          in     pay_process_events.change_type%type
           ,p_status1               in     pay_process_events.status%type
           ,p_description1          in     pay_process_events.description%type
            ) is
  --
    l_process_event_id        pay_process_events.process_event_id%type;
    l_object_version_number   pay_process_events.object_version_number%type;
    l_proc      varchar2(72) := g_package||'PQP_Process_Events_ErrorLog';

  begin
  --
  -- The procedure pqp_process_events_errorlog creates a record in pay_process_events
  -- table, if a record for an assignment does not already exist
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- The following procedure pay_ppe_api.create_process_event creates a record
  -- in the pay_process_events table
  --
    pay_ppe_api.create_process_event
   (p_validate                  => false
   ,p_assignment_id             => p_assignment_id1
   ,p_effective_date            => p_effective_date1
   ,p_change_type               => p_change_type1
   ,p_status                    => p_status1
   ,p_description               => SUBSTR(p_description1, 1, 240)
   ,p_process_event_id          => l_process_event_id
   ,p_object_version_number     => l_object_version_number
    );
    hr_utility.set_location('Leaving:'||l_proc, 10);
  exception
    when OTHERS then
     hr_utility.set_location('Entering exception:'||l_proc, 15);
     hr_utility.set_message(800, 'DTU10_GENERAL_ORACLE_ERROR');
     hr_utility.set_message_token('2', 'Error in '
        || 'pqp_alien_expat_taxation_pkg.pqp_process_events_errorlog(create). Error '
        || 'Code = ' || TO_CHAR(Sqlcode) || ' ' || sqlerrm);
     hr_utility.raise_error;

  end PQP_Process_Events_ErrorLog;

  -- ===========================================================================
  -- Name      : PQP_Process_Events_ErrorLog
  --Purpose   : the following procedure is called from pqp_windstar_person_read.
  --            This updates a record in pay_process_events table
  --            with DATA_VALIDATION_FAILED status.
  --Arguments :
  --  In
  --   t_people_tab             : PL/sql table contains the Personal details.
  --                               This is passed a an I/P parameter as this
  --                               procedure returns the visa details only
  --                               for the assignments present in this
  --                               table.
  --    p_effective_date      : Effective date.
  --  Out
  -- Arguments :
  --  In
  --    p_process_event_id1      : Process Event Id for the PK purpose
  --    p_object_version_number1 : Object version number for the PK purpose
  --    p_status1                : DATA_VALIDATION_FAILED
  --    p_description1           : Description of the error
  --  Out NoCopy                 : none
  -- Notes                       : private
  -- ===========================================================================
  procedure pqp_process_events_errorlog
           (p_process_event_id1      in pay_process_events.process_event_id%type
           ,p_object_version_number1 in pay_process_events.object_version_number%type
           ,p_status1                in pay_process_events.status%type
           ,p_description1           in pay_process_events.description%type
           ) is
  --
  -- the procedure pqp_process_events_errorlog updates a record in
  -- pay_process_events table. the following procedure
  -- pay_ppe_api.update_process_event updates a record
  -- in the pay_process_events table
  --

    l_object_version_number   pay_process_events.object_version_number%type;
    l_proc        varchar2(72) := g_package||'PQP_Process_Events_ErrorLog';

  begin

    hr_utility.set_location('Entering:'||l_proc, 5);

    l_object_version_number := p_object_version_number1;

    pay_ppe_api.update_process_event
   (p_validate                => false
   ,p_status                  => p_status1
   ,p_description             => substr(p_description1, 1, 240)
   ,p_process_event_id        => p_process_event_id1
   ,p_object_version_number   => l_object_version_number
    );

    hr_utility.set_location('Leaving:'||l_proc, 10);

  exception
    when others then
     hr_utility.set_location('Entering exception:'||l_proc, 15);
     hr_utility.set_message(800, 'DTU10_GENERAL_ORACLE_ERROR');
     hr_utility.set_message_token('2', 'Error in '
      || 'pqp_alien_expat_taxation_pkg.pqp_process_events_errorlog(Update). Error '
      || 'Code = ' || TO_CHAR(Sqlcode) || ' ' || sqlerrm);
     hr_utility.raise_error;

  end PQP_Process_Events_ErrorLog;

  -- ===========================================================================
  -- Name      : Insert_Pay_Process_Events
  -- Purpose   : The following procedure is called from pqp_windstar_person_read.
  --             This inserts a record in pay_process_events table.
  -- Arguments :
  -- In
  --    p_type           'ALL' or a valid SSN
  --    p_effective_date  Effective Date
  --
  -- Out NoCopy: NONE
  --
  -- Notes     : Private
  -- ===========================================================================

procedure Insert_Pay_Process_Events
       (p_type           in varchar2
       ,p_effective_date in date) is

--
-- The following cursor gets executed when the p_type is ALL. It selects
-- all assignments that are active in the calendar year of the effective date.
--
 cursor all_people_f_cursor_n (c_start_date           in date
                              ,c_end_date             in date
                              ,c_national_indentifier in varchar2
                              ,c_effective_date       in date) is
 select paf.assignment_id
       ,paf.effective_start_date
   from per_people_f           ppf
       ,per_person_types       ppt
       ,per_people_extra_info  pei
       ,per_all_assignments_f  paf
  where ppf.person_type_id     = ppt.person_type_id
    and ppf.business_group_id  = ppt.business_group_id
    and ppt.system_person_type in ('EMP', 'EX_EMP', 'EMP_APL')
    --
    and pei.person_id          = ppf.person_id
    and pei.information_type  = 'PER_US_ADDITIONAL_DETAILS'
    and pei.pei_information12 = 'WINDSTAR'
    and to_char(c_effective_date, 'YYYY') <=
        to_char(nvl(fnd_date.canonical_to_date(pei.pei_information13)
                   ,to_date('31/12/4712','DD/MM/YYYY')
                    ),'YYYY'
                )
    --
    and paf.person_id = ppf.person_id
    and paf.business_group_id = ppf.business_group_id
    and paf.effective_end_date between ppf.effective_start_date
                                   and ppf.effective_end_date
    and ((c_end_date between paf.effective_start_date
                         and paf.effective_end_date
          )
         or
         (paf.effective_end_date =
              (select max(asx.effective_end_date)
                 from per_all_assignments_f asx
                where asx.assignment_id = paf.assignment_id
                  and asx.effective_end_date between c_start_date
                                                 and c_end_date)
          )
        )
    and not exists (select 1
                      from pay_process_events
                     where assignment_id = paf.assignment_id
                       and change_type   = 'PQP_US_ALIEN_WINDSTAR'
                       and status  in ('N', 'D')

                      )
    order  by paf.assignment_id  desc;

/*  CURSOR all_people_f_cursor_n  IS
      select paf.assignment_id             ,
             paf.effective_start_date
      from   per_people_f           ppf ,
             per_person_types       ppt ,
             per_people_extra_info  ppei,
             per_assignments_f      paf
      where  ppf.person_type_id     = ppt.person_type_id
      and    ppt.system_person_type in ('EMP' , 'EX_EMP')
      and    ppf.effective_start_date <=
        TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_end_date   >=
        TO_DATE(('01/01/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_people_f
                                         where  person_id =
                                                   ppf.person_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    ppf.person_id                 = ppei.person_id
      and    ppei.information_type         = 'PER_US_ADDITIONAL_DETAILS'
      and    ppei.pei_information12        = 'WINDSTAR'
      and    TO_CHAR(p_effective_date, 'YYYY') <=
                      TO_CHAR(NVL(fnd_date.canonical_to_date(ppei.pei_information13),
                                    TO_DATE('31/12/4712','DD/MM/YYYY')),'YYYY')
      and    paf.person_id          = ppf.person_id
      and    paf.effective_start_date <= TO_DATE(('12/31/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and     paf.effective_end_date  >= TO_DATE(('01/01/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_assignments_f
                                         where  assignment_id =
                                                   paf.assignment_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    not exists (select 1
                         from   pay_process_events
                         where  assignment_id = paf.assignment_id
                         and    status        in ('N', 'D')
                         and    change_type   = 'PQP_US_ALIEN_WINDSTAR'
                        )
      order  by paf.assignment_id  desc ;
      */
--
-- The following cursor gets executed when the p_type is ALL. It selects
-- all assignments that are active in the calendar year of the effective date.
--
 cursor all_people_f_cursor_d (c_start_date           in date
                              ,c_end_date             in date
                              ,c_national_indentifier in varchar2
                              ,c_effective_date       in date) is
 select paf.assignment_id
       ,paf.effective_start_date
       ,ppe.process_event_id
       ,ppe.object_version_number

   from per_people_f           ppf
       ,per_person_types       ppt
       ,per_people_extra_info  pei
       ,pay_process_events     ppe
       ,per_all_assignments_f  paf

  where ppt.person_type_id     = ppf.person_type_id
    and ppt.business_group_id  = ppf.business_group_id
    and ppt.system_person_type in ('EMP', 'EX_EMP', 'EMP_APL')
    --
    and ppe.assignment_id = paf.assignment_id
    and ppe.change_type   = 'PQP_US_ALIEN_WINDSTAR'
    and ppe.status  in ('D')
    -- only if person EIT exists
    and pei.person_id          = ppf.person_id
    and pei.information_type   = 'PER_US_ADDITIONAL_DETAILS'
    and pei.pei_information12  = 'WINDSTAR'
    and to_char(c_effective_date, 'YYYY') <=
        to_char(nvl(fnd_date.canonical_to_date(pei_information13)
                   ,to_date('31/12/4712','DD/MM/YYYY')
                    ),'YYYY'
                )
    --
    and paf.person_id = ppf.person_id
    and paf.business_group_id = ppf.business_group_id
    and paf.effective_end_date between ppf.effective_start_date
                                   and ppf.effective_end_date
    and ((c_end_date between paf.effective_start_date
                         and paf.effective_end_date
          )
         or
         (paf.effective_end_date =
              (select max(asx.effective_end_date)
                 from per_all_assignments_f asx
                where asx.assignment_id = paf.assignment_id
                  and asx.effective_end_date between c_start_date
                                                 and c_end_date)
          )
        )

    --
    order  by paf.assignment_id  desc;

 /* CURSOR all_people_f_cursor_d  IS
      select paf.assignment_id             ,
             paf.effective_start_date      ,
             ppe.process_event_id          ,
             ppe.object_version_number
      from   per_people_f           ppf ,
             per_person_types       ppt ,
             per_people_extra_info  ppei,
             pay_process_events     ppe ,
             per_assignments_f      paf
      where  ppf.person_type_id     = ppt.person_type_id
      and    ppt.system_person_type in ('EMP' , 'EX_EMP')
      and    ppf.effective_start_date <=
        TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_end_date   >=
        TO_DATE(('01/01/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_people_f
                                         where  person_id =
                                                   ppf.person_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    ppf.person_id                 = ppei.person_id
      and    ppei.information_type         = 'PER_US_ADDITIONAL_DETAILS'
      and    ppei.pei_information12        = 'WINDSTAR'
      and   TO_CHAR(p_effective_date, 'YYYY') <=
                      TO_CHAR(NVL(fnd_date.canonical_to_date(ppei.pei_information13),
                                    TO_DATE('31/12/4712','DD/MM/YYYY')),'YYYY')
      and    paf.effective_start_date <= TO_DATE(('12/31/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and     paf.effective_end_date  >= TO_DATE(('01/01/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_assignments_f
                                         where  assignment_id =
                                                   paf.assignment_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    paf.person_id          = ppf.person_id
      and    paf.assignment_id      = ppe.assignment_id
      and    exists (select 1
                         from   pay_process_events
                         where  assignment_id = paf.assignment_id
                         and    status        in ('D')
                         and    change_type   = 'PQP_US_ALIEN_WINDSTAR'
                        )
      order  by paf.assignment_id  desc; */

--
-- Cursor when national identifier is passed and no pay process events exists
--
 cursor ssn_cursor_n (c_start_date           in date
                     ,c_end_date             in date
                     ,c_national_indentifier in varchar2
                     ,c_effective_date       in date) is
 select paf.assignment_id
       ,paf.effective_start_date

   from per_all_assignments_f  paf
       ,per_people_f           ppf
       ,per_person_types       ppt

  where ppf.person_id           = paf.person_id
    and ppf.person_type_id      = ppt.person_type_id
    and ppf.national_identifier = c_national_indentifier
    and ppt.system_person_type in ('EMP', 'EX_EMP')
    and ((c_end_date between paf.effective_start_date
                         and paf.effective_end_date
          )
         or
         (paf.effective_end_date =
              (select max(asx.effective_end_date)
                 from per_all_assignments_f asx
                where asx.assignment_id = paf.assignment_id
                  and asx.effective_end_date between c_start_date
                                                 and c_end_date)
          )
        )
    and paf.effective_end_date between ppf.effective_start_date
                                   and ppf.effective_end_date
    and not exists (select 1
                      from pay_process_events
                     where assignment_id = paf.assignment_id
                       and status in ('N', 'D')
                       and change_type   = 'PQP_US_ALIEN_WINDSTAR'
                    )
    and exists
          (select 1
             from per_people_extra_info pei
            where pei.information_type  = 'PER_US_ADDITIONAL_DETAILS'
              and pei.pei_information12 = 'WINDSTAR'
              and pei.person_id = ppf.person_id
              and to_char(c_effective_date, 'YYYY') <=
                  to_char(nvl(fnd_date.canonical_to_date(pei_information13)
                             ,to_date('31/12/4712','DD/MM/YYYY')
                              ),'YYYY'
                          )
           )
   order  by paf.assignment_id;

/*  CURSOR ssn_cursor_n  IS
      select paf.assignment_id             ,
             paf.effective_start_date
      from   per_assignments_f      paf ,
             per_people_f           ppf ,
             per_person_types       ppt ,
             (select * from per_people_extra_info
              where information_type = 'PER_US_ADDITIONAL_DETAILS'
              and   pei_information12        = 'WINDSTAR'
              and   TO_CHAR(p_effective_date, 'YYYY') <=
                      TO_CHAR(NVL(fnd_date.canonical_to_date(pei_information13),
                                    TO_DATE('31/12/4712','DD/MM/YYYY')),'YYYY')
              )   ppei
      where  ppf.person_id          = paf.person_id
      and    ppf.person_type_id     = ppt.person_type_id
      and    ppf.national_identifier= p_type
      and    ppt.system_person_type in ('EMP' , 'EX_EMP')
      and    ppf.effective_start_date <=
        TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_end_date   >=
        TO_DATE(('01/01/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_people_f
                                         where  person_id =
                                                   ppf.person_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    paf.effective_start_date <= TO_DATE(('12/31/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and     paf.effective_end_date  >= TO_DATE(('01/01/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_assignments_f
                                         where  assignment_id =
                                                   paf.assignment_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    ppf.person_type_id            = ppt.person_type_id
      and    ppf.person_id                 = ppei.person_id
      and    ppei.information_type = 'PER_US_ADDITIONAL_DETAILS'
      and    ppei.pei_information12         = 'WINDSTAR'
      and    not exists (select 1
                         from   pay_process_events
                         where  assignment_id = paf.assignment_id
                         and    status        in ('N', 'D')
                         and    change_type   = 'PQP_US_ALIEN_WINDSTAR'
                        )
      order  by paf.assignment_id ;
*/
--
-- Cursor when national identifier is passed and with pay process events
--
 cursor ssn_cursor_d (c_start_date           in date
                     ,c_end_date             in date
                     ,c_national_indentifier in varchar2
                     ,c_effective_date       in date) is
 select paf.assignment_id
       ,paf.effective_start_date
       ,ppe.process_event_id
       ,ppe.object_version_number

   from per_all_assignments_f  paf
       ,per_people_f           ppf
       ,per_person_types       ppt
       ,pay_process_events     ppe

  where ppf.person_id           = paf.person_id
    and ppf.person_type_id      = ppt.person_type_id
    and ppf.business_group_id   = ppt.business_group_id
    and ppf.national_identifier = c_national_indentifier
    and ppt.system_person_type in ('EMP', 'EX_EMP')
    and ((c_end_date between paf.effective_start_date
                         and paf.effective_end_date
          )
         or
         (paf.effective_end_date =
              (select max(asx.effective_end_date)
                 from per_all_assignments_f asx
                where asx.assignment_id = paf.assignment_id
                  and asx.business_group_id = paf.business_group_id
                  and asx.person_id         = paf.person_id
                  and asx.effective_end_date between c_start_date
                                                 and c_end_date)
          )
        )
    and paf.effective_end_date between ppf.effective_start_date
                                   and ppf.effective_end_date
    and paf.business_group_id = ppf.business_group_id
    and ppe.assignment_id     = paf.assignment_id
    and ppe.status in ('D')
    and ppe.change_type = 'PQP_US_ALIEN_WINDSTAR'
    and exists (select 1
                  from per_people_extra_info pei
                 where pei.information_type  = 'PER_US_ADDITIONAL_DETAILS'
                   and pei.pei_information12 = 'WINDSTAR'
                   and pei.person_id = ppf.person_id
                   and to_char(c_effective_date, 'YYYY') <=
                       to_char(nvl(fnd_date.canonical_to_date(pei_information13)
                                  ,to_date('31/12/4712','DD/MM/YYYY')
                                   ),'YYYY'
                               )
                )
    order  by paf.assignment_id;

/*  CURSOR ssn_cursor_d  IS
      select paf.assignment_id,
             paf.effective_start_date,
             ppe.process_event_id,
             ppe.object_version_number

        from per_assignments_f      paf ,
             per_people_f           ppf ,
             per_person_types       ppt ,
             (select * from per_people_extra_info
              where information_type = 'PER_US_ADDITIONAL_DETAILS'
              and   pei_information12        = 'WINDSTAR'
              and   TO_CHAR(p_effective_date, 'YYYY') <=
                      TO_CHAR(NVL(fnd_date.canonical_to_date(pei_information13),
                                    TO_DATE('31/12/4712','DD/MM/YYYY')),'YYYY')
              )   ppei  ,
             pay_process_events ppe
      where  ppf.person_id          = paf.person_id
      and    ppf.person_type_id     = ppt.person_type_id
      and    ppf.national_identifier= p_type
      and    ppt.system_person_type in ('EMP' , 'EX_EMP')
      and    ppf.effective_start_date <=
        TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_end_date   >=
        TO_DATE(('01/01/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_people_f
                                         where  person_id =
                                                   ppf.person_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    paf.effective_start_date <= TO_DATE(('12/31/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and     paf.effective_end_date  >= TO_DATE(('01/01/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_assignments_f
                                         where  assignment_id =
                                                   paf.assignment_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))

      and    ppf.person_id                 = ppei.person_id
      and    ppei.information_type = 'PER_US_ADDITIONAL_DETAILS'
      and    ppei.pei_information12         = 'WINDSTAR'
      and    paf.assignment_id              = ppe.assignment_id
      and    exists (select 1
                         from   pay_process_events
                         where  assignment_id = paf.assignment_id
                         and    status        in ('D')
                         and    change_type   = 'PQP_US_ALIEN_WINDSTAR'
                        )
      order  by paf.assignment_id ;
 */
 l_process_event_id      number;
 l_object_version_number number;
 l_assignment_id         number;
 l_start_date            date;
 l_end_date              date;

 l_proc   constant       varchar2(150) := g_package||'Insert_Pay_Process_Events';

begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the start and end date of year for the effective date passed.
  --
  l_start_date
    := to_date(('01/01/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY');
  l_end_date
    := to_date(('12/31/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY');

  if  p_type = 'ALL'  then

      hr_utility.set_location(l_proc, 10);
      --
      for apfc in all_people_f_cursor_n
                 (c_start_date           => l_start_date
                 ,c_end_date             => l_end_date
                 ,c_national_indentifier => p_type
                 ,c_effective_date       => p_effective_date)

      loop

        begin
            hr_utility.set_location(l_proc, 20);
            pay_ppe_api.create_process_event
           (p_validate              => false
           ,p_assignment_id         => apfc.assignment_id
           ,p_effective_date        => apfc.effective_start_date
           ,p_change_type           => 'PQP_US_ALIEN_WINDSTAR'
           ,p_status                => 'N'
           ,p_description           => '| Inserted thru PL/SQL Code |'
           ,p_process_event_id      => l_process_event_id
           ,p_object_version_number => l_object_version_number
            );
            hr_utility.set_location(l_proc, 30);
        exception
          when others then
           hr_utility.set_location(l_proc, 40);
           null;
        end;

      end loop;
      --
      --
      for apfc in all_people_f_cursor_d
                 (c_start_date           => l_start_date
                 ,c_end_date             => l_end_date
                 ,c_national_indentifier => p_type
                 ,c_effective_date       => p_effective_date)
      loop

        begin
            hr_utility.set_location(l_proc, 50);
            pay_ppe_api.update_process_event
           (p_validate              => false
           ,p_status                => 'N'
           ,p_description           => null
           ,p_process_event_id      => apfc.process_event_id
           ,p_object_version_number => apfc.object_version_number
            );
            hr_utility.set_location(l_proc, 60);
        exception
          when others then
           hr_utility.set_location(l_proc, 70);
           null;
        end;

      end loop;
  else
      hr_utility.set_location(l_proc, 80);
      --
      for c1 in ssn_cursor_n (c_start_date           => l_start_date
                             ,c_end_date             => l_end_date
                             ,c_national_indentifier => p_type
                             ,c_effective_date       => p_effective_date)
      loop

        begin
           hr_utility.set_location(l_proc, 90);
           pay_ppe_api.create_process_event
           (p_validate              => false
           ,p_assignment_id         => c1.assignment_id
           ,p_effective_date        => c1.effective_start_date
           ,p_change_type           => 'PQP_US_ALIEN_WINDSTAR'
           ,p_status                => 'N'
           ,p_description           => '| Inserted thru PL/SQL Code |'
           ,p_process_event_id      => l_process_event_id
           ,p_object_version_number => l_object_version_number
            );
           hr_utility.set_location(l_proc, 100);
        exception
          when others then
           hr_utility.set_location(l_proc, 110);
           null;
        end;

      end loop;
      --
      --
      for c1 in ssn_cursor_d (c_start_date           => l_start_date
                             ,c_end_date             => l_end_date
                             ,c_national_indentifier => p_type
                             ,c_effective_date       => p_effective_date)
      loop

        begin
            hr_utility.set_location(l_proc, 120);
            pay_ppe_api.update_process_event
            (p_validate              => false
            ,p_status                => 'N'
            ,p_description           => null
            ,p_process_event_id      => c1.process_event_id
            ,p_object_version_number => c1.object_version_number
             );
            hr_utility.set_location(l_proc, 130);
        exception
          when others then
           hr_utility.set_location(l_proc, 140);
           null;
        end;

      end loop;
      --
  end if;

  hr_utility.set_location('Leaving:'||l_proc, 150);

exception
  when others then
   hr_utility.set_message(800, 'DTU10_GENERAL_ORACLE_ERROR');
   hr_utility.set_message_token('2',
   'Error in pqp_alien_expat_taxation_pkg.insert_pay_process_'||
   'events. Error Code = ' || TO_CHAR(Sqlcode) || ' ' || sqlerrm);
   hr_utility.set_location('Leaving :'||l_proc, 160);
   hr_utility.raise_error;

end insert_pay_process_events;

/**************************************************************************
  name      : address_select
  Purpose   : the following procedure is called from pqp_windstar_person_read.
              This selects the address of an assignment.
  Arguments :
    in
                       p_per_assign_id     : Person or Assignment Id.
                                             Person Id if home address is
                                             needed. Assignment Id if work
                                             address is needed.

                       p_effective_date    : Effective date
    in/out
                       p_work_home         : Flag to select Home or work
                                             address. if it is HOME, then
                                             home address is selected. if it
                                             is work then work address is
                                             selected.
    out
                       p_county            : County
                       p_state             : State
                       p_city              : City
                       p_address_line1     : Address Line 1
                       p_address_line2     : Address Line 2
                       p_address_line3     : Address Line 3
                       p_telephone_number_1: Tel Phone 1
                       p_telephone_number_2: Tel Phone 2
                       p_telephone_number_3: Tel Phone 3
                       p_postal_code       : Postal Code
  Notes                     : private
***************************************************************************/
procedure address_select(p_per_assign_id      in     number   ,
                       p_effective_date     in     date     ,
                       p_work_home          in out NOCOPY varchar2 ,
                       p_county             out NOCOPY    varchar2 ,
                       p_state              out NOCOPY    varchar2 ,
                       p_city               out NOCOPY    varchar2 ,
                       p_address_line1      out NOCOPY    varchar2 ,
                       p_address_line2      out NOCOPY    varchar2 ,
                       p_address_line3      out NOCOPY    varchar2 ,
                       p_telephone_number_1 out NOCOPY    varchar2 ,
                       p_telephone_number_2 out NOCOPY    varchar2 ,
                       p_telephone_number_3 out NOCOPY    varchar2 ,
                       p_postal_code        out NOCOPY    varchar2 )
is --{
/*****
  This procedure selects HOME/work the address of an assignment
*****/
/*****
the following cursor selects the details of the home address

08-JAN-04 Bug #3347853 Fix latest addrress is send now instead of
the address as of the interface date.

MAX(date_from) is now being equated instead of less then equal to.
*****/
cursor home_address_cur is
  select NVL(addr.add_information19 , addr.region_1    ) county             ,
         NVL(addr.add_information17 , addr.region_2    ) state              ,
         NVL(addr.add_information18 , addr.town_or_city) city               ,
         NVL(addr.address_line1     , ' '              ) address_line1      ,
         NVL(addr.address_line2     , ' '              ) address_line2      ,
         NVL(addr.address_line3     , ' '              ) address_line3      ,
         NVL(addr.telephone_number_1, ' '              ) telephone_number_1 ,
         NVL(addr.telephone_number_2, ' '              ) telephone_number_2 ,
         NVL(addr.telephone_number_3, ' '              ) telephone_number_3 ,
         NVL(addr.postal_code       , ' '              ) postal_code
  from   per_addresses         addr
  where  addr.person_id       = p_per_assign_id
  and    addr.primary_flag          = 'Y'
  and    NVL(addr.address_type,' ') <> 'PHCA'
  and    addr.date_from = (select MAX(date_From)
                            from   per_addresses
                            where  person_id  =  p_per_assign_id
                            and    primary_flag          = 'Y'
                            and    NVL(address_type,' ') <> 'PHCA');

/*****
the following cursor selects the details of the work address
*****/
cursor work_address_cur is
  select NVL(hrlock.loc_information19  , hrlock.region_1) county            ,
         NVL(hrlock.loc_information17  , hrlock.region_2) state             ,
         NVL(hrlock.loc_information18  , hrlock.town_or_city) city          ,
         NVL(hrlock.address_line_1     , ' '            ) address_line_1    ,
         NVL(hrlock.address_line_2     , ' '            ) address_line_2    ,
         NVL(hrlock.address_line_3     , ' '            ) address_line_3    ,
         NVL(hrlock.telephone_number_1 , ' '            ) telephone_number_1,
         NVL(hrlock.telephone_number_2 , ' '            ) telephone_number_2,
         NVL(hrlock.telephone_number_3 , ' '            ) telephone_number_3,
         NVL(hrlock.postal_code        , ' '            ) postal_code
  from   hr_locations             hrlock,
         hr_soft_coding_keyflex   hrsckf,
         per_all_assignments_f    assign
  where  p_effective_date between assign.effective_start_date
                          and     assign.effective_end_date
  and    assign.assignment_id                 = p_per_assign_id
  and    assign.soft_coding_keyflex_id        = hrsckf.soft_coding_keyflex_id
  and    NVL(hrsckf.segment18,assign.location_id) = hrlock.location_id;

  l_proc        varchar2(72) := g_package||'address_select'  ;
begin --}{
  hr_utility.set_location('Entering:'||l_proc, 10);

  /* Person Address Details */
  if (UPPER(p_work_home) = 'HOME') then
      hr_utility.set_location(l_proc, 20);
      open home_address_cur;
      fetch home_address_cur into
          p_county             ,
          p_state              ,
          p_city               ,
          p_address_line1      ,
          p_address_line2      ,
          p_address_line3      ,
          p_telephone_number_1 ,
          p_telephone_number_2 ,
          p_telephone_number_3 ,
          p_postal_code        ;
      hr_utility.set_location('Entering:'||l_proc, 30);
      if (home_address_cur%notfound) then
          p_county             := ''         ;
          p_state              := ''         ;
          p_city               := ''         ;
          p_address_line1      := ''         ;
          p_address_line2      := ''         ;
          p_address_line3      := ''         ;
          p_telephone_number_1 := ''         ;
          p_telephone_number_2 := ''         ;
          p_telephone_number_3 := ''         ;
          p_postal_code        := ''         ;
          p_work_home          := 'NOT_FOUND';
          hr_utility.set_location(l_proc, 40);
      end if;
       close home_address_cur;
  elsif (UPPER(p_work_home) = 'WORK') then
      hr_utility.set_location(l_proc, 50);
      open work_address_cur;
      fetch work_address_cur into
          p_county             ,
          p_state              ,
          p_city               ,
          p_address_line1      ,
          p_address_line2      ,
          p_address_line3      ,
          p_telephone_number_1 ,
          p_telephone_number_2 ,
          p_telephone_number_3 ,
          p_postal_code        ;
      hr_utility.set_location(l_proc, 60);
      if (work_address_cur%notfound) then
          p_county             := ''          ;
          p_state              := ''          ;
          p_city               := ''          ;
          p_address_line1      := ''          ;
          p_address_line2      := ''          ;
          p_address_line3      := ''          ;
          p_telephone_number_1 := ''          ;
          p_telephone_number_2 := ''          ;
          p_telephone_number_3 := ''          ;
          p_postal_code        := ''          ;
          p_work_home          := 'NOT_FOUND' ;
          hr_utility.set_location(l_proc, 70);
      end if;
       close work_address_cur;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 80);
exception
when OTHERS then
  hr_utility.set_location('Entering exc:'||l_proc, 90);
          p_county             := ''          ;
          p_state              := ''          ;
          p_city               := ''          ;
          p_address_line1      := ''          ;
          p_address_line2      := ''          ;
          p_address_line3      := ''          ;
          p_telephone_number_1 := ''          ;
          p_telephone_number_2 := ''          ;
          p_telephone_number_3 := ''          ;
          p_postal_code        := ''          ;
          p_work_home          := 'NOT_FOUND' ;
end address_select;

-- Function to format the telephone no.'s as required by Windstar before
-- Interfacing.
-- Added by tmehra - 09-APR-2002


function format_tele
( p_tele    in    varchar2               --
) return varchar2                        -- Return Formated value
is

l_value       hr_locations.telephone_number_1%type;
l_len         number := 0;
l_sep_pos     number := 0;
l_pre         hr_locations.telephone_number_1%type;
l_char        varchar2(1);

begin
-- Strip the blanks
l_value := trim(p_tele);
l_pre   := '';
l_len   := nvl(length(l_value),0);
l_char  := ' ';

if l_len = 0 then
return '       ';
end if;

for i in 1 .. l_len
loop
l_char    := substr(l_value,i,1);
l_sep_pos := instr('0123456789',l_char);
if l_sep_pos <> 0 then
  l_pre := l_pre || l_char;
end if;
end loop;

return l_pre;

end;
/**************************************************************************
  name      : spouse_here
  Purpose   : the following procedure is called from pqp_windstar_person_read.
              This returns Y/N depending on the condition whether the spouse
              of the person accompanied her.
  Arguments :
    in              p_person_id         : Person Id

                    p_effective_date    : Effective date
    out NOCOPY             Y/N
  Notes     : private
***************************************************************************/
function spouse_here(p_person_id      in  number ,
                   p_effective_date in  date   ) return varchar2
is
  l_spouse_here varchar2(1) := 'N';
  l_proc        varchar2(72) := g_package||'spouse_here';
begin  -- {
  hr_utility.set_location('Entering '||l_proc, 10);
  for csh1 in c_person_visit_spouse_info(p_person_id     ,
                                         p_effective_date)

  loop
      l_spouse_here := csh1.spouse_accompanied;
      hr_utility.set_location('Leaving '||l_proc, 20);
  end loop;
  hr_utility.set_location('Leaving '||l_proc, 30);
  return l_spouse_here;
end spouse_here;
-- =============================================================================
-- name   : PQP_Windstar_Person_Read
-- Purpose: The following procedure is called from pqp_read_public. This
--          procedure returns the person details in a PL/sql table t_people_tab.
-- Arguments :
--  IN
--    p_selection_criterion : if the user wants to select all records,
--                            or the records in the PAY_PROCESS_EVENTS table,
--                            or a specifice national_identifier.
--    p_source_type         : if the req is from Windstar or some other sys.
--    p_effective_date      : Effective date.
--  Out
--    t_people_tab          : PL/sql table contains the Personal details.
--  In Out
--    t_error_tab           : PL/sql table contains the Error details.
--
--    Notes                     : private
-- =============================================================================

procedure PQP_Windstar_Person_Read
         (p_selection_criterion in   varchar2
         ,p_source_type         in   varchar2
         ,p_effective_date      in   date
         ,t_people_tab          out  nocopy  t_people_tab_type
         ,t_error_tab           in out nocopy t_error_tab_type
         ,p_person_read_count   out nocopy  number
         ,p_person_err_count    out nocopy  number
          ) is

--
-- The cursor selects all the assignment_id's from pay_process_events table
-- that have a status of NOT_READ and then joins it with the per_people_f,
-- and per_assignments_f table. This cursor can be coded without the parameter
-- p_source_type, since the only user will be Windstar. But just to make the
-- program flexible, p_source_type is used.
-- 1. A status of 'N' means 'NOT_READ'
-- 2. pei_information12 is process_type. It means that the person is an alien
--    and has to be processed by WINDSTAR
--
   cursor pay_process_events_cursor
         (c_year_start_date in date
         ,c_year_end_date   in date
         ,p_source_type     in varchar2) is
   select distinct
          ppf.last_name
         ,ppf.first_name
         ,ppf.middle_names
         ,ppf.national_identifier
         ,ppf.employee_number
         ,ppf.date_of_birth
         ,ppf.title
         ,ppf.suffix
         ,upper(ppf.marital_status)
         ,ppf.person_id

     from per_all_assignments_f   paf
         ,per_people_f            ppf
         ,pay_process_events      ppe
         ,per_person_types        ppt
         ,per_people_extra_info   pei

    where ppf.person_id          = paf.person_id
      and ppf.person_type_id     = ppt.person_type_id
      and ppt.system_person_type in ('EMP', 'EX_EMP', 'EMP_APL')
      --
      and ppe.change_type        = p_source_type
      and ppe.assignment_id      = paf.assignment_id
      and ppe.status             = 'N'
      -- Person extra Info
      and ppf.person_id          = pei.person_id
      and pei.information_type   = 'PER_US_ADDITIONAL_DETAILS'
      and pei.pei_information12  = 'WINDSTAR'
      and to_char(c_year_end_date, 'YYYY') <=
          to_char(nvl(fnd_date.canonical_to_date(pei.pei_information13),
                      c_year_end_date),'YYYY')
      and ((c_year_end_date between paf.effective_start_date
                                and paf.effective_end_date
           )
           or
           (paf.effective_end_date =
              (select max(asx.effective_end_date)
                 from per_all_assignments_f asx
                where asx.assignment_id = paf.assignment_id
                  and asx.business_group_id = paf.business_group_id
                  and asx.person_id         = paf.person_id
                  and asx.effective_end_date between c_year_start_date
                                                 and c_year_end_date)
           )
          )
      and ((c_year_end_date between ppf.effective_start_date
                                and ppf.effective_end_date
           )
           or
           (paf.effective_end_date between ppf.effective_start_date
                                       and ppf.effective_end_date)
           )
     order by ppf.person_id;

/*  cursor pay_process_events_cursor(p_effective_date in date    ,
                                     p_source_type    in varchar2) is
      select distinct
             ppf.last_name            ,
             ppf.first_name           ,
             ppf.middle_names         ,
             ppf.national_identifier  ,
             ppf.employee_number      ,
             ppf.date_of_birth        ,
             ppf.title                ,
             ppf.suffix               ,
             UPPER(ppf.marital_status),
             ppf.person_id
      from   per_assignments_f       paf ,
             per_people_f            ppf ,
             pay_process_events      ppe ,
             per_person_types        ppt ,
             per_people_extra_info   ppei
      where  ppf.person_id             = paf.person_id
      and    ppf.effective_start_date <= TO_DATE(('12/31/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_end_date   >= TO_DATE(('01/01/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_people_f
                                         where  person_id = ppf.person_id
                                         and    effective_start_date <=
                                                         TO_DATE(('12/31/' ||
                            TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
     and   ppei.information_type    = 'PER_US_ADDITIONAL_DETAILS'
     and   ppei.pei_information12   = 'WINDSTAR'
     and   TO_CHAR(p_effective_date, 'YYYY') <=
                TO_CHAR(NVL(fnd_date.canonical_to_date(ppei.pei_information13),
                                    TO_DATE('31/12/4712','DD/MM/YYYY')),'YYYY')

      and    paf.effective_start_date <= TO_DATE(('12/31/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_end_date   >= TO_DATE(('01/01/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_assignments_f
                                         where  assignment_id =
                                                    paf.assignment_id
                                         and    effective_start_date <=
                                                         TO_DATE(('12/31/' ||
                            TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    ppf.person_type_id            = ppt.person_type_id
      and    ppt.system_person_type        in ('EMP' , 'EX_EMP')
      and    ppe.change_type               = p_source_type
      and    ppe.assignment_id             = paf.assignment_id
      and    ppe.status                    = 'N'
      and    ppf.person_id                 = ppei.person_id
      order by ppf.person_id;
*/

--
-- The cursor(written below) per_people_f_cursor selects the details of all the
-- persons that are to be processed by Windstar. Basically pei_information12
-- = 'WINDSTAR' tells that the particular person will be processed by Windstar
--

  cursor per_people_f_cursor(p_effective_date in date) is
      select ppf.last_name             ,
             ppf.first_name            ,
             ppf.middle_names          ,
             ppf.national_identifier   ,
             ppf.employee_number       ,
             ppf.date_of_birth         ,
             ppf.title                 ,
             ppf.suffix                ,
             UPPER(ppf.marital_status) ,
             ppf.person_id
      from   per_people_f           ppf ,
             per_person_types       ppt ,
             per_people_extra_info  ppei
      where  ppf.person_type_id     = ppt.person_type_id
      and    ppt.system_person_type in ('EMP', 'EX_EMP', 'EMP_APL')
      and    ppf.effective_start_date <=
        TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_end_date   >=
        TO_DATE(('01/01/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_people_f
                                         where  person_id =
                                                   ppf.person_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    ppf.person_type_id            = ppt.person_type_id
      and    ppf.person_id                 = ppei.person_id
      and    ppei.information_type         = 'PER_US_ADDITIONAL_DETAILS'
      and    ppei.pei_information12        = 'WINDSTAR'
      and    TO_CHAR(p_effective_date, 'YYYY') <=
                      TO_CHAR(NVL(fnd_date.canonical_to_date(ppei.pei_information13),
                                    TO_DATE('31/12/4712','DD/MM/YYYY')),'YYYY')
      order  by ppf.person_id   ;

/*****
the cursor(written below) national_identifier_cursor selects the details of
a person with the passed national Identifier
*****/

  cursor national_identifier_cursor(p_effective_date      in date    ,
                                    p_national_identifier in varchar2) is
      select ppf.last_name             ,
             ppf.first_name            ,
             ppf.middle_names          ,
             ppf.national_identifier   ,
             ppf.employee_number       ,
             ppf.date_of_birth         ,
             ppf.title                 ,
             ppf.suffix                ,
             UPPER(ppf.marital_status) ,
             ppf.person_id
      from   per_people_f           ppf  ,
             per_person_types       ppt  ,
             (select * from per_people_extra_info
              where  information_type = 'PER_US_ADDITIONAL_DETAILS'
              and    pei_information12        = 'WINDSTAR'
              and   TO_CHAR(p_effective_date, 'YYYY') <=
                      TO_CHAR(NVL(fnd_date.canonical_to_date(pei_information13),
                                    TO_DATE('31/12/4712','DD/MM/YYYY')),'YYYY')
             )  ppei
      where  ppf.person_type_id     = ppt.person_type_id
      and    ppt.system_person_type in ('EMP', 'EX_EMP', 'EMP_APL')
      and    ppf.effective_start_date <=
        TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_end_date   >=
        TO_DATE(('01/01/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_people_f
                                         where  person_id =
                                                   ppf.person_id
                                         and    effective_start_date <=
       TO_DATE(('12/31/' || TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    ppf.national_identifier       = p_national_identifier
      and    ppf.person_id                 = ppei.person_id
      and    ppei.information_type = 'PER_US_ADDITIONAL_DETAILS'
      and    ppei.pei_information12        = 'WINDSTAR'
      order  by ppf.person_id   ;

/*****
 the cursor c_person_passport_info gives the passport details of a particular
 person id . rownum is used as we are interested in selecting just a single
 row.
****/

  cursor c_person_passport_info(p_person_id                in number   ) is
      select ppei.pei_information5   country         ,
             ppei.pei_information6   passport_number ,
             ppei.pei_information7   issue_date      ,
             ppei.pei_information8   expiry_date
      from   (select *
      from   per_people_extra_info
      where  information_type = 'PER_US_PASSPORT_DETAILS'
      and    person_id                 = p_person_id) ppei
      where    rownum < 2;

/*****
 the cursor c_lookup_values_cursor gives the count for a lookup_type
 and a country code. the lookup type used while invoking this cursor is
 PQP_US_DEPENDENTS_IN_USA. on the GUI, on person extra information
 'Additional Details', a user can enter value either in 'total dependents
 children' or 'dependent children in country'. If a row is present in
 fnd_common_lookups for lookup_type = PQP_US_DEPENDENTS_IN_USA and
 the respective country code, then the t_people_tab(i).dependents will
 be populated by value present in 'dependent children in country'.


 Bug 3780751 Fix - Changed the FND_COMMON_LOOKUP reference to hr_lookups
 by tmehra 23-dec-2004.
****/

  cursor c_lookup_values_cursor(p_effective_date in date     ,
                                p_lookup_type    in varchar2 ,
                                p_country_code   in varchar2 ) is
      select COUNT(*) count
      from   hr_lookups
      where  lookup_type                             = p_lookup_type
      and    enabled_flag                            = 'Y'
      and    NVL(end_date_active, p_effective_date) >= p_effective_date
      and    lookup_code                             = p_country_code;

/*****
the following cursor c_non_us_address_cur selects the Non US address for a
person_id
Added the code to fetch the complete non us address - tmehra 15-OCT-2001
Added region_2 --> non_us_region_postal_cd - 05-APR-2002

08-JAN-04 Bug #3347853 Fix - foreign Address was not being passed if the primary address
was updated and the update date was in the new year. A new clause to check for 'PHCA'
has been added to the subquery.
*****/

  cursor c_non_us_address_cur(p_person_id      in number ,
                              p_effective_date in date   ) is
      select NVL(addr.address_line1,' ') non_us_addr1,
             NVL(addr.address_line2,' ') non_us_addr2,
             NVL(addr.address_line3,' ') non_us_addr3,
             NVL(addr.postal_code,' '  ) non_us_city_postal_cd,
             NVL(addr.town_or_city,' ' ) non_us_city,
             NVL(addr.region_1,' '     ) non_us_region,
             NVL(addr.region_2,' '     ) non_us_region_postal_cd,
             NVL(addr.country, ' '     ) non_us_cc
      from   per_addresses         addr
      where  addr.person_id     = p_person_id
      and    addr.address_type    = 'PHCA'
      and    addr.date_from  = (select MAX(date_from)
                               from   per_addresses
                               where  person_id       =  p_person_id
                               and    address_type    = 'PHCA'
                               )
      and rownum < 2;

/* Original cursor
  cursor c_non_us_address_cur(p_person_id      in number ,
                              p_effective_date in date   ) is
      select NVL(addr.country, ' ') non_us_cc
      from   per_addresses         addr
      where  addr.person_id     = p_person_id
      and    addr.address_type    = 'PHCA'
      and    NVL(addr.date_from, p_effective_date) <= TO_DATE(('12/31/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    NVL(addr.date_to, p_effective_date)   >= TO_DATE(('01/01/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    NVL(addr.date_from, p_effective_date) = (select MAX(date_from)
                               from   per_addresses
                               where  person_id  =  p_person_id
                               and    NVL(date_from, p_effective_date) <=
                                  TO_DATE(('12/31/' ||
                           TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and rownum < 2;
*/


/*****
the cursor below gives the translation of Oracle Application Country codes to
IRS country codes
*****/

  cursor c_country_code_xlat_cursor(p_country_code   in varchar2 ,
                                    p_effective_date in date     ) is
      select hrl.meaning
      from   hr_lookups hrl
      where  hrl.lookup_type        = 'PQP_US_COUNTRY_TRANSLATE'
      and    hrl.enabled_flag       = 'Y'
      and    NVL(start_date_active, p_effective_date) <= TO_DATE(('12/31/' ||
                            TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    NVL(end_date_active, p_effective_date) >= TO_DATE(('01/01/' ||
                            TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    UPPER(hrl.lookup_code) = UPPER(p_country_code)
      and    rownum < 2;

  t_people_rec                t_people_rec_type                            ;
  l_last_name                 per_people_f.last_name%type                  ;
  l_first_name                per_people_f.first_name%type                 ;
  l_middle_names              per_people_f.middle_names%type               ;
  l_national_identifier       per_people_f.national_identifier%type        ;
  l_employee_number           per_people_f.employee_number%type            ;
  l_date_of_birth             per_people_f.date_of_birth%type              ;
  l_title                     per_people_f.title%type                      ;
  l_suffix                    per_people_f.suffix%type                     ;
  l_person_id                 per_people_f.person_id%type                  ;
  l_marital_status            per_people_f.marital_status%type             ;
  l_assignment_id             per_assignments_f.assignment_id%type         ;
  l_county                    hr_locations.loc_information19%type          ;
  l_state                     hr_locations.loc_information18%type          ;
  l_city                      hr_locations.loc_information17%type          ;
  l_address_line1             hr_locations.address_line_1%type             ;
  l_address_line2             hr_locations.address_line_2%type             ;
  l_address_line3             hr_locations.address_line_3%type             ;
  l_telephone_number_1        hr_locations.telephone_number_1%type         ;
  l_telephone_number_2        hr_locations.telephone_number_2%type         ;
  l_telephone_number_3        hr_locations.telephone_number_3%type         ;
  l_postal_code               hr_locations.postal_code%type                ;
  l_process_event_id          pay_process_events.process_event_id%type     ;
  l_object_version_number     pay_process_events.object_version_number%type;
  l_out_mesg                  out_mesg_type                                ;

  l_work_home                 varchar2(15)                                 ;
  l_description               varchar2(250)                                ;
  l_non_us_country_code       varchar2(100)                                ;
  l_xlat_country              varchar2(100)                                ;
  l_warn_mesg                 varchar2(100)                                ;
  l_proc              varchar2(72) := g_package||'pqp_windstar_person_read';

  i                           number                                       ;
  j                           number                                       ;
  l_err_count                 number                                       ;
  l_count                     number                                       ;
  l_temp_count                number := 0                                  ;
  l_country_validate_count    number := 0                                  ;
  l_person_read_count         number := 0                                  ;
  l_person_err_count          number := 0                                  ;

  l_flag                      boolean := false;
  l_year_start_date           date;
  l_year_end_date             date;

begin
  hr_utility.set_location('Entering '||l_proc, 5);

  l_year_start_date  := to_date(('01/01/'||to_char(p_effective_date, 'YYYY'))
                                ,'MM/DD/YYYY');
  l_year_end_date    := to_date(('12/31/'||to_char(p_effective_date, 'YYYY'))
                                ,'MM/DD/YYYY');

  --
  -- raise error message as source type must be entered while invoking this
  -- procedure. The Error is to show user that a blank/Null Source
  -- Type has been passed.
  --
  if (p_source_type is null) then
      hr_utility.set_location('Entering '||l_proc, 6);
      hr_utility.set_message(800, 'HR_7207_API_MANDATORY_ARG');
      hr_utility.set_message_token('ARGUMENT', 'Source Type');
      hr_utility.set_message_token
       ('API_NAME','pqp_alien_expat_taxation_pkg.pqp_windstar_person_read');
      hr_utility.raise_error;

  elsif (p_source_type <> 'PQP_US_ALIEN_WINDSTAR') then
      hr_utility.set_location('Entering '||l_proc, 6);
      --
      -- raise error message as this package caters to PQP_US_ALIEN_WINDSTAR
      -- only as of now. Error is to show user that Invalid Source
      -- Type has been passed.
      --
      hr_utility.set_message(800, 'HR_7462_PLK_INVLD_VALUE');
      hr_utility.set_message_token('COLUMN_NAME', 'Source Type');
      hr_utility.set_message_token
        ('API_NAME','pqp_alien_expat_taxation_pkg.pqp_windstar_person_read');
      hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 10);
  --
  -- The following BEGIN...END block is used so that the error generated
  -- due to the above error condition is not trapped
  --
  if (p_source_type = 'PQP_US_ALIEN_WINDSTAR') then
      hr_utility.set_location(l_proc, 15);

      if (p_selection_criterion = 'PAY_PROCESS_EVENTS' ) then
          hr_utility.set_location(l_proc, 20);
          open pay_process_events_cursor
              (c_year_start_date => l_year_start_date
              ,c_year_end_date   => l_year_end_date
              ,p_source_type     => p_source_type);

      elsif (p_selection_criterion = 'ALL' ) then
          hr_utility.set_location(l_proc, 25);
          open per_people_f_cursor(p_effective_date);

      else
          hr_utility.set_location(l_proc, 30);
          --
          -- Else executes when p_selection_criterion is neither 'ALL' nor
          -- 'PAY_PROCESS_EVENTS'. Program flow assumes that the
          -- NOT NULL string  present in the p_selection_criterion is a valid
          -- National Identifier (SSN Number). p_selection_criterion string is
          -- NOT NULL at this stage as NULL error is checked earlier.
          --
          open national_identifier_cursor(p_effective_date      ,
                                          p_selection_criterion );
      end if;
  end if;

  hr_utility.set_location(l_proc, 35);

  -- Counter for the t_people_tab - PL/SQL table
  i := 1;
  -- Counter for the t_error_tab - PL/SQL table
  l_err_count := 0;

  if (p_selection_criterion = 'ALL') then

      hr_utility.set_location(l_proc, 40);
      --
      -- Insert_Pay_Process_Events procedure inserts into pay_process_events
      -- table. The records are inserted in this table for the
      -- reconciliation purpose.
      --
      Insert_Pay_Process_Events
      (p_type           => 'ALL'
      ,p_effective_date => p_effective_date);

      loop
      begin
          l_last_name             := null;
          l_first_name            := null;
          l_middle_names          := null;
          l_national_identifier   := null;
          l_employee_number       := null;
          l_date_of_birth         := null;
          l_title                 := null;
          l_suffix                := null;
          l_marital_status        := null;
          l_person_id             := null;
          l_work_home             := null;
          l_county                := null;
          l_state                 := null;
          l_city                  := null;
          l_address_line1         := null;
          l_address_line2         := null;
          l_address_line3         := null;
          l_telephone_number_1    := null;
          l_telephone_number_2    := null;
          l_telephone_number_3    := null;
          l_postal_code           := null;
          l_out_mesg              := null;

          fetch per_people_f_cursor into
                                    l_last_name
                                   ,l_first_name
                                   ,l_middle_names
                                   ,l_national_identifier
                                   ,l_employee_number
                                   ,l_date_of_birth
                                   ,l_title
                                   ,l_suffix
                                   ,l_marital_status
                                   ,l_person_id;

          hr_utility.set_location(l_proc, 50);

          exit when per_people_f_cursor%notfound;

          l_person_read_count := l_person_read_count + 1;

          l_work_home := 'HOME';

          Address_Select(l_person_id          ,
                         p_effective_date     ,
                         l_work_home          ,
                         l_county             ,
                         l_state              ,
                         l_city               ,
                         l_address_line1      ,
                         l_address_line2      ,
                         l_address_line3      ,
                         l_telephone_number_1 ,
                         l_telephone_number_2 ,
                         l_telephone_number_3 ,
                         l_postal_code);

          hr_utility.set_location(l_proc, 60);

          t_people_tab(i).last_name          := l_last_name           ;
          t_people_tab(i).first_name         := l_first_name          ;
          t_people_tab(i).middle_names       := l_middle_names        ;
          t_people_tab(i).national_identifier:= l_national_identifier ;
          t_people_tab(i).employee_number    := l_employee_number     ;
          t_people_tab(i).date_of_birth      := l_date_of_birth       ;
          t_people_tab(i).title              := l_title               ;
          t_people_tab(i).suffix             := l_suffix              ;
          t_people_tab(i).marital_status     := l_marital_status      ;
          t_people_tab(i).person_id          := l_person_id           ;
          t_people_tab(i).state              := l_state               ;
          t_people_tab(i).city               := l_city                ;
          t_people_tab(i).address_line1      := l_address_line1       ;
          t_people_tab(i).address_line2      := l_address_line2       ;
          t_people_tab(i).address_line3      := l_address_line3       ;
          t_people_tab(i).telephone_number_1 := format_tele(l_telephone_number_1)  ;
          t_people_tab(i).telephone_number_2 := format_tele(l_telephone_number_2)  ;
          t_people_tab(i).telephone_number_3 := format_tele(l_telephone_number_3)  ;
          t_people_tab(i).postal_code        := l_postal_code         ;
          t_people_tab(i).spouse_here        := spouse_here(l_person_id     ,
                                                            p_effective_date);


          for c_passport in c_person_passport_info(l_person_id)
          loop
              t_people_tab(i).passport_number := c_passport.passport_number;
          end loop;
          hr_utility.set_location(l_proc, 70);

          for c_additional in c_person_additional_info(l_person_id)
          loop
              t_people_tab(i).citizenship_c_code
                 := c_additional.tax_res_country_code;
              for c1_lookup in
                    c_lookup_values_cursor
                    (p_effective_date,
                     'PQP_US_DEPENDENTS_IN_USA',
                     t_people_tab(i).citizenship_c_code
                     )
              loop
                  l_temp_count := c1_lookup.count ;
              end loop;

              if (l_temp_count > 0) then
                  t_people_tab(i).dependents
                    := c_additional.dep_children_in_cntry;
              else
                  t_people_tab(i).dependents :=
                                c_additional.dep_children_total;
              end if;

              t_people_tab(i).date_first_entered_us :=
                  fnd_date.canonical_to_date(c_additional.first_entry_date);
          end loop;

          hr_utility.set_location(l_proc, 80);
          --
          -- to fetch the complete non us address
          --
          for c_non_us_addr in c_non_us_address_cur(l_person_id     ,
                                                    p_effective_date)
          loop
            t_people_tab(i).non_us_address_line1     := c_non_us_addr.non_us_addr1;
            t_people_tab(i).non_us_address_line2     := c_non_us_addr.non_us_addr2;
            t_people_tab(i).non_us_address_line3     := c_non_us_addr.non_us_addr3;
            t_people_tab(i).non_us_city_postal_cd    := c_non_us_addr.non_us_city_postal_cd;
            t_people_tab(i).non_us_city              := c_non_us_addr.non_us_city;
            t_people_tab(i).non_us_region            := c_non_us_addr.non_us_region;
            t_people_tab(i).non_us_region_postal_cd  := c_non_us_addr.non_us_region_postal_cd;
            t_people_tab(i).non_us_country_code      := c_non_us_addr.non_us_cc;
          end loop;

          hr_utility.set_location(l_proc, 90);
          --
          -- After a row in PL/SQL table t_people_tab is populated, we pass
          -- the just filled row of PL/SQL table to the validation proc
          -- pqp_windstar_person_validate
          --
          PQP_Windstar_Person_Validate
         (p_in_data_rec    => t_people_tab(i)
         ,p_effective_date => p_effective_date
         ,p_out_mesg       => l_out_mesg
          );
          hr_utility.set_location(l_proc, 100);
          --
          -- t_people_tab PL/SQL table cannot be modified in
          -- pqp_windstar_person_validate  procedure. c_country_code_xlat_cursor
          -- cursor will translate the Oracle Application country code to
          -- a valid IRS country code
          --
          if (t_people_tab(i).non_us_country_code is not null) then

              -- tmehra added the following code as a temporary measure
              -- to include more countries in the translation
              if t_people_tab(i).non_us_country_code = 'SG' then
                 t_people_tab(i).non_us_country_code := 'SN';

              elsif t_people_tab(i).non_us_country_code = 'NG' then
                    t_people_tab(i).non_us_country_code := 'NI';

              elsif t_people_tab(i).non_us_country_code = 'BD' then
                    t_people_tab(i).non_us_country_code := 'BG';

              elsif t_people_tab(i).non_us_country_code = 'NI' then
                    t_people_tab(i).non_us_country_code := 'NU';

              elsif t_people_tab(i).non_us_country_code = 'BA' then
                    t_people_tab(i).non_us_country_code := 'BK';

              else
                  for c1_xlat in c_country_code_xlat_cursor
                                 (t_people_tab(i).non_us_country_code
                                 ,p_effective_date
                                 )
                  loop
                    --
                    -- changed the following to strip the 'IRS-' from
                    -- the meaning bug #2170501
                    --
                    t_people_tab(i).non_us_country_code
                      := substr(c1_xlat.meaning,5,length(c1_xlat.meaning)) ;
                  end loop;
                end if;
          end if;

          hr_utility.set_location(l_proc, 110);
          --
          -- A warning message is appended to the description field of the
          -- pay_process_events table, if the Non US Country code is not a
          -- valid tax country code
          --
          l_country_validate_count := 0;
          l_warn_mesg := null;

          open c_tax_country_code_cursor
               (t_people_tab(i).non_us_country_code,
                p_effective_date);
          fetch c_tax_country_code_cursor
           into l_country_validate_count;
          close c_tax_country_code_cursor;

          if (l_country_validate_count = 0) then
              if (t_people_tab(i).non_us_country_code is null) then
                  l_warn_mesg :='| Warning ==> Non US Country Code is NULL |';
              else
              l_warn_mesg := '| Warning ==> Non US Country Code [' ||
                                    t_people_tab(i).non_us_country_code ||
                                         '] may be Invalid |';
              end if;
          end if;
          hr_utility.set_location(l_proc, 120);
          --
          -- Delete the current row in the PL/SQL table. Update the status
          -- in the pay_process_events table to reflect the status as
          -- DATA_VALIDATION_FAILED. The row is deleted as we do not want
          -- to insert the row containing an error/validation failure
          -- in indv_rev1_temp table.
          --
          l_process_event_id := null;

          open pay_process_events_ovn_cursor(l_person_id
                                            ,p_source_type
                                            ,p_effective_date);
          loop
              l_description := null;
              fetch pay_process_events_ovn_cursor
               into
                   l_process_event_id      ,
                   l_object_version_number ,
                   l_assignment_id         ,
                   l_description           ;
              hr_utility.set_location(l_proc, 130);

              exit when pay_process_events_ovn_cursor%notfound;

              if (l_out_mesg is null) then
              --
              -- l_out_mesg = NULL means that there was no failure. Increment
              -- the counter and proceed for fetching of the next row from
              -- the respective cursor. We therefore do NOT change the status.
              --  The status is changed from N to R after a row in inserted
              -- in ten42s_state_temp table.
              --
                  if (l_warn_mesg is not null) then
                      pqp_process_events_errorlog
                      (p_process_event_id1      => l_process_event_id
                      ,p_object_version_number1 => l_object_version_number
                      ,p_status1                => hr_api.g_varchar2
                      ,p_description1 => substr(l_description || l_warn_mesg, 1, 240)
                      );
                  end if;

                  hr_utility.set_location(l_proc, 140);
                  -- If the warning message is NOT null, then we do not
                  -- change the status to D as this is just a warning
              else
              --
              -- Since l_out_mesg is NOT NULL, that means an error was
              -- detected. We therefore change the status of the
              -- pay_process_events table to 'D' meaning DATA_VALIDATION_FAILED
              --
                  pqp_process_events_errorlog
                  (p_process_event_id1      => l_process_event_id
                  ,p_object_version_number1 => l_object_version_number
                  ,p_status1                => 'D'
                  ,p_description1 => SUBSTR(l_out_mesg || l_warn_mesg ||
                                            l_description, 1, 240)
                  );
              end if;
              hr_utility.set_location(l_proc, 150);

          end loop;

          close pay_process_events_ovn_cursor;

          if (l_out_mesg is null) then
              i := i + 1;
              hr_utility.set_location(l_proc, 160);
          else
              hr_utility.set_location(l_proc, 170);
              --
              -- for wf notification consolidation
              --
              if l_process_event_id is not null then

                 l_err_count := l_err_count+1;
                 t_error_tab(l_err_count).person_id := t_people_tab(i).person_id;
                 t_error_tab(l_err_count).process_event_id:= l_process_event_id;

              end if;

              t_people_tab.delete(i) ;
              l_person_err_count := l_person_err_count + 1;
              l_out_mesg  := null;
              l_warn_mesg := null;

          end if; -- if (l_out_mesg

      exception
          when others then
            hr_utility.set_location(l_proc, 180);
            l_person_id := t_people_tab(i).person_id;
            l_out_mesg := SUBSTR('Oracle Error ' || TO_CHAR(sqlcode) ||
                                  sqlerrm, 1, 240);
            if (t_people_tab.exists(i)) then
                t_people_tab.delete(i) ;
                l_person_err_count := l_person_err_count + 1;
            end if;
            if (pay_process_events_ovn_cursor%isopen = true) then
                close pay_process_events_ovn_cursor;
            end if;

            l_process_event_id := null;

            open pay_process_events_ovn_cursor(l_person_id
                                              ,p_source_type
                                              ,p_effective_date);
            loop
              fetch pay_process_events_ovn_cursor
              into l_process_event_id
                  ,l_object_version_number
                  ,l_assignment_id
                  ,l_description;

              hr_utility.set_location(l_proc, 190);

              exit when pay_process_events_ovn_cursor%notfound;

              pqp_process_events_errorlog
              (p_process_event_id1      => l_process_event_id
              ,p_object_version_number1 => l_object_version_number
              ,p_status1                => 'D'
              ,p_description1 => substr('Oralce Error ' || to_char(sqlcode) ||
                                        ' ' ||sqlerrm, 1, 240)
               );

             end loop;
             close pay_process_events_ovn_cursor;
             --
             -- for wf notification consolidation
             --
             if l_process_event_id is not null then

                l_err_count := l_err_count+1;
                t_error_tab(l_err_count).person_id := t_people_tab(i).person_id;
                t_error_tab(l_err_count).process_event_id := l_process_event_id;

             end if;
             l_out_mesg  := null;
             l_warn_mesg := null;
      end;
      end loop;

      close per_people_f_cursor;

  elsif (p_selection_criterion = 'PAY_PROCESS_EVENTS' ) then
      loop
      begin
          l_last_name             := null;
          l_first_name            := null;
          l_middle_names          := null;
          l_national_identifier   := null;
          l_employee_number       := null;
          l_date_of_birth         := null;
          l_title                 := null;
          l_suffix                := null;
          l_marital_status        := null;
          l_person_id             := null;
          l_work_home             := null;
          l_county                := null;
          l_state                 := null;
          l_city                  := null;
          l_address_line1         := null;
          l_address_line2         := null;
          l_address_line3         := null;
          l_telephone_number_1    := null;
          l_telephone_number_2    := null;
          l_telephone_number_3    := null;
          l_postal_code           := null;
          l_out_mesg              := null;

          fetch pay_process_events_cursor
           into l_last_name
               ,l_first_name
               ,l_middle_names
               ,l_national_identifier
               ,l_employee_number
               ,l_date_of_birth
               ,l_title
               ,l_suffix
               ,l_marital_status
               ,l_person_id;

          hr_utility.set_location(l_proc, 200);

          exit when pay_process_events_cursor%notfound;

          l_person_read_count := l_person_read_count + 1;
          l_work_home := 'HOME';

          Address_Select(l_person_id          ,
                         p_effective_date     ,
                         l_work_home          ,
                         l_county             ,
                         l_state              ,
                         l_city               ,
                         l_address_line1      ,
                         l_address_line2      ,
                         l_address_line3      ,
                         l_telephone_number_1 ,
                         l_telephone_number_2 ,
                         l_telephone_number_3 ,
                         l_postal_code);

          hr_utility.set_location(l_proc, 210);

          t_people_tab(i).last_name          := l_last_name           ;
          t_people_tab(i).first_name         := l_first_name          ;
          t_people_tab(i).middle_names       := l_middle_names        ;
          t_people_tab(i).national_identifier:= l_national_identifier ;
          t_people_tab(i).employee_number    := l_employee_number     ;
          t_people_tab(i).date_of_birth      := l_date_of_birth       ;
          t_people_tab(i).title              := l_title               ;
          t_people_tab(i).suffix             := l_suffix              ;
          t_people_tab(i).marital_status     := l_marital_status      ;
          t_people_tab(i).person_id          := l_person_id           ;
          t_people_tab(i).state              := l_state               ;
          t_people_tab(i).city               := l_city                ;
          t_people_tab(i).address_line1      := l_address_line1       ;
          t_people_tab(i).address_line2      := l_address_line2       ;
          t_people_tab(i).address_line3      := l_address_line3       ;
          t_people_tab(i).telephone_number_1 := format_tele(l_telephone_number_1)  ;
          t_people_tab(i).telephone_number_2 := format_tele(l_telephone_number_2)  ;
          t_people_tab(i).telephone_number_3 := format_tele(l_telephone_number_3)  ;
          t_people_tab(i).postal_code        := l_postal_code         ;
          t_people_tab(i).spouse_here        := spouse_here(l_person_id     ,
                                                            p_effective_date);

          for c_passport in c_person_passport_info(l_person_id)
          loop
              t_people_tab(i).passport_number := c_passport.passport_number;
          end loop;

          hr_utility.set_location(l_proc, 220);

          for c_additional in c_person_additional_info(l_person_id)
          loop
              t_people_tab(i).citizenship_c_code:=
                              c_additional.tax_res_country_code;
              for c1_lookup in c_lookup_values_cursor
                           (
                               p_effective_date                  ,
                               'PQP_US_DEPENDENTS_IN_USA'        ,
                               t_people_tab(i).citizenship_c_code
                           )
              loop
                  l_temp_count := c1_lookup.count ;
              end loop;

              if (l_temp_count > 0) then
                  t_people_tab(i).dependents :=
                                c_additional.dep_children_in_cntry;
              else
                  t_people_tab(i).dependents :=
                                c_additional.dep_children_total;
              end if;

              t_people_tab(i).date_first_entered_us :=
                  fnd_date.canonical_to_date(c_additional.first_entry_date);
          end loop;

          hr_utility.set_location(l_proc, 230);

          -- to fetch the complete non us address

          for c_non_us_addr in c_non_us_address_cur(l_person_id     ,
                                                    p_effective_date)
          loop
            t_people_tab(i).non_us_address_line1  := c_non_us_addr.non_us_addr1;
            t_people_tab(i).non_us_address_line2  := c_non_us_addr.non_us_addr2;
            t_people_tab(i).non_us_address_line3  := c_non_us_addr.non_us_addr3;
            t_people_tab(i).non_us_city_postal_cd := c_non_us_addr.non_us_city_postal_cd;
            t_people_tab(i).non_us_city           := c_non_us_addr.non_us_city;
            t_people_tab(i).non_us_region         := c_non_us_addr.non_us_region;
            t_people_tab(i).non_us_country_code   := c_non_us_addr.non_us_cc;
          end loop;

          hr_utility.set_location(l_proc, 240);
          -- After a row in PL/SQL table t_people_tab is populated, we pass
          -- the just filled row of PL/SQL table to the validation proc
          -- pqp_windstar_person_validate
          --
          pqp_windstar_person_validate
          (p_in_data_rec    => t_people_tab(i)
          ,p_effective_date => p_effective_date
          ,p_out_mesg       => l_out_mesg
           );

          hr_utility.set_location(l_proc, 250);
          -- t_people_tab PL/SQL table cannot be modified in pqp_windstar_person_validate
          -- procedure. c_country_code_xlat_cursor cursor will translate the
          -- Oracle Application country code to a valid IRS country code
          --
          if (t_people_tab(i).non_us_country_code is not null) then
              for c1_xlat in c_country_code_xlat_cursor
                            (t_people_tab(i).non_us_country_code
                            ,p_effective_date
                             )
              loop
                  -- t_people_tab(i).non_us_country_code := c1_xlat.meaning ;
                  -- changed the following to strip the 'IRS-' from the meaning

                  t_people_tab(i).non_us_country_code
                    := SUBSTR(c1_xlat.meaning,5,length(c1_xlat.meaning)) ;

              end loop;
          end if;
          hr_utility.set_location(l_proc, 260);
          -- A warning message is appended to the description field of
          -- the pay_process_events table, if the Non US Country code
          -- is not a valid tax country code

          l_country_validate_count := 0;
          l_warn_mesg              := null;

          open c_tax_country_code_cursor(t_people_tab(i).non_us_country_code
                                        ,p_effective_date);
          fetch c_tax_country_code_cursor
           into l_country_validate_count;
          close c_tax_country_code_cursor;

          if (l_country_validate_count = 0) then
              if (t_people_tab(i).non_us_country_code is null) then
                  l_warn_mesg :='| Warning ==> Non US Country Code is NULL |';
              else
              l_warn_mesg := '| Warning ==> Non US Country Code [' ||
                                    t_people_tab(i).non_us_country_code ||
                                         '] may be Invalid |';
              end if;
          end if;
          hr_utility.set_location(l_proc, 270);
          -- Delete the current row in the PL/SQL table. Update the status in
          -- the pay_process_events table to reflect the status as DATA_VALIDATION_FAILED.
          -- The row is deleted as we do not want to insert the row containing
          -- an error/validation failure in indv_rev1_temp table.

          l_process_event_id := null;

          open pay_process_events_ovn_cursor(l_person_id     ,
                                             p_source_type   ,
                                             p_effective_date);
          loop

              l_description := null;
              fetch pay_process_events_ovn_cursor into
                   l_process_event_id      ,
                   l_object_version_number ,
                   l_assignment_id         ,
                   l_description           ;
              hr_utility.set_location(l_proc, 280);

              exit when pay_process_events_ovn_cursor%notfound;

              if (l_out_mesg is null) then
                  hr_utility.set_location(l_proc, 290);
                  -- l_out_mesg = NULL means that there was no failure.
                  -- Increment the counter and proceed for fetching of the
                  -- next row from the respective cursor. We therefore do
                  -- NOT change the status. The status is changed from N to R
                  --  after a row in inserted in ten42s_state_temp table

                  if (l_warn_mesg is not null) then
                      hr_utility.set_location(l_proc, 300);

                      pqp_process_events_errorlog
                      (p_process_event_id1      => l_process_event_id
                      ,p_object_version_number1 => l_object_version_number
                      ,p_status1                => hr_api.g_varchar2
                      ,p_description1 => SUBSTR(l_description ||
                                                l_warn_mesg, 1, 240)
                      );
                  end if;
             else
                hr_utility.set_location(l_proc, 310);
                -- Since l_out_mesg is NOT NULL, that means an error was
                -- detected. We therefore change the status of the
                -- pay_process_events table to 'D' meaning DATA_VALIDATION_FAILED
                --
                pqp_process_events_errorlog
                (p_process_event_id1      => l_process_event_id
                ,p_object_version_number1 => l_object_version_number
                ,p_status1                => 'D'
                ,p_description1 => substr(l_out_mesg || l_warn_mesg ||
                                          l_description, 1, 240)
                 );
              end if;
          end loop;
          close pay_process_events_ovn_cursor;
          if (l_out_mesg is null) then
              i := i + 1;
              hr_utility.set_location(l_proc, 320);
          else
              -- for wf notification consolidation
              if l_process_event_id is not null then
               l_err_count := l_err_count+1;

               t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
               t_error_tab(l_err_count).process_event_id   := l_process_event_id;
              end if;

              t_people_tab.delete(i) ;
              l_person_err_count := l_person_err_count + 1;
              l_out_mesg  := null;
              l_warn_mesg := null;
              hr_utility.set_location(l_proc, 330);

          end if;
      exception
          when others then
            hr_utility.set_location(l_proc, 340);
            l_person_id := t_people_tab(i).person_id;
            --
            if (t_people_tab.exists(i)) then
                t_people_tab.delete(i) ;
                l_person_err_count := l_person_err_count + 1;
            end if;
            --
            l_out_mesg := SUBSTR('Oralce Error ' || TO_CHAR(sqlcode) ||
                                  sqlerrm, 1, 240);
            if (pay_process_events_ovn_cursor%isopen = true) then
               close pay_process_events_ovn_cursor;
            end if;
            l_process_event_id := null;

            open pay_process_events_ovn_cursor(l_person_id     ,
                                               p_source_type   ,
                                               p_effective_date);
            loop
              fetch pay_process_events_ovn_cursor into
                   l_process_event_id      ,
                   l_object_version_number ,
                   l_assignment_id         ,
                   l_description           ;
              hr_utility.set_location(l_proc, 350);

              exit when pay_process_events_ovn_cursor%notfound;
                  pqp_process_events_errorlog
                  (
                      p_process_event_id1      => l_process_event_id       ,
                      p_object_version_number1 => l_object_version_number  ,
                      p_status1                => 'D'                      ,
                      p_description1           => l_out_mesg
                  );
            end loop;
            close pay_process_events_ovn_cursor;

            if l_process_event_id is not null then
               l_err_count := l_err_count+1;
               t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
               t_error_tab(l_err_count).process_event_id   := l_process_event_id;
            end if;

            l_out_mesg  := null;
            l_warn_mesg := null;
      end; -- exception

      end loop;

      close pay_process_events_cursor;

  else
  -- Executing the code for a particular National Identifier
     hr_utility.set_location(l_proc, 360);
/******
insert_pay_process_events procedure inserts into pay_process_events
table. the records are inserted in this table for the reconciliation purpose.
*****/
      insert_pay_process_events(p_selection_criterion ,
                                p_effective_date      );
      loop
      begin
          l_last_name             := null;
          l_first_name            := null;
          l_middle_names          := null;
          l_national_identifier   := null;
          l_employee_number       := null;
          l_date_of_birth         := null;
          l_title                 := null;
          l_suffix                := null;
          l_marital_status        := null;
          l_person_id             := null;
          l_work_home             := null;
          l_county                := null;
          l_state                 := null;
          l_city                  := null;
          l_address_line1         := null;
          l_address_line2         := null;
          l_address_line3         := null;
          l_telephone_number_1    := null;
          l_telephone_number_2    := null;
          l_telephone_number_3    := null;
          l_postal_code           := null;
          l_out_mesg              := null;

          fetch national_identifier_cursor into
              l_last_name            ,
              l_first_name           ,
              l_middle_names         ,
              l_national_identifier  ,
              l_employee_number      ,
              l_date_of_birth        ,
              l_title                ,
              l_suffix               ,
              l_marital_status       ,
              l_person_id            ;
          hr_utility.set_location(l_proc, 370);

          exit when national_identifier_cursor%notfound;
          l_person_read_count := l_person_read_count + 1;

          l_work_home := 'HOME';

          address_select(l_person_id          ,
                         p_effective_date     ,
                         l_work_home          ,
                         l_county             ,
                         l_state              ,
                         l_city               ,
                         l_address_line1      ,
                         l_address_line2      ,
                         l_address_line3      ,
                         l_telephone_number_1 ,
                         l_telephone_number_2 ,
                         l_telephone_number_3 ,
                         l_postal_code        );
          hr_utility.set_location(l_proc, 380);

          t_people_tab(i).last_name          := l_last_name           ;
          t_people_tab(i).first_name         := l_first_name          ;
          t_people_tab(i).middle_names       := l_middle_names        ;
          t_people_tab(i).national_identifier:= l_national_identifier ;
          t_people_tab(i).employee_number    := l_employee_number     ;
          t_people_tab(i).date_of_birth      := l_date_of_birth       ;
          t_people_tab(i).title              := l_title               ;
          t_people_tab(i).suffix             := l_suffix              ;
          t_people_tab(i).marital_status     := l_marital_status      ;
          t_people_tab(i).person_id          := l_person_id           ;
          t_people_tab(i).state              := l_state               ;
          t_people_tab(i).city               := l_city                ;
          t_people_tab(i).address_line1      := l_address_line1       ;
          t_people_tab(i).address_line2      := l_address_line2       ;
          t_people_tab(i).address_line3      := l_address_line3       ;
          t_people_tab(i).telephone_number_1 := format_tele(l_telephone_number_1)  ;
          t_people_tab(i).telephone_number_2 := format_tele(l_telephone_number_2)  ;
          t_people_tab(i).telephone_number_3 := format_tele(l_telephone_number_3)  ;
          t_people_tab(i).postal_code        := l_postal_code         ;
          t_people_tab(i).spouse_here        := spouse_here(l_person_id     ,
                                                            p_effective_date);

          for c_passport in c_person_passport_info(l_person_id) loop
              t_people_tab(i).passport_number := c_passport.passport_number;
          end loop;
          hr_utility.set_location(l_proc, 390);

          for c_additional in c_person_additional_info(l_person_id) loop
              t_people_tab(i).citizenship_c_code:=
                              c_additional.tax_res_country_code;
              for c1_lookup in c_lookup_values_cursor
                           (
                               p_effective_date                  ,
                               'PQP_US_DEPENDENTS_IN_USA'        ,
                               t_people_tab(i).citizenship_c_code
                           )
              loop
                  l_temp_count := c1_lookup.count ;
              end loop;

              if (l_temp_count > 0) then
                  t_people_tab(i).dependents :=
                                c_additional.dep_children_in_cntry;
              else
                  t_people_tab(i).dependents :=
                                c_additional.dep_children_total;
              end if;

              t_people_tab(i).date_first_entered_us :=
                  fnd_date.canonical_to_date(c_additional.first_entry_date);
          end loop;
          hr_utility.set_location(l_proc, 400);

/* Added the code to fetch the complete non us address - tmehra 15-OCT-2001 */

          for c_non_us_addr in c_non_us_address_cur(l_person_id     ,
                                                    p_effective_date)
          loop
            t_people_tab(i).non_us_address_line1  := c_non_us_addr.non_us_addr1;
            t_people_tab(i).non_us_address_line2  := c_non_us_addr.non_us_addr2;
            t_people_tab(i).non_us_address_line3  := c_non_us_addr.non_us_addr3;
            t_people_tab(i).non_us_city_postal_cd := c_non_us_addr.non_us_city_postal_cd;
            t_people_tab(i).non_us_city           := c_non_us_addr.non_us_city;
            t_people_tab(i).non_us_region         := c_non_us_addr.non_us_region;
            t_people_tab(i).non_us_country_code   := c_non_us_addr.non_us_cc;
          end loop;
          hr_utility.set_location(l_proc, 410);
/*****
after a row in PL/sql table t_people_tab is populated, we pass the just
filled row of PL/sql table to the validation proc pqp_windstar_person_validate
*****/
          pqp_windstar_person_validate
          (
               p_in_data_rec    => t_people_tab(i)  ,
               p_effective_date => p_effective_date ,
               p_out_mesg       => l_out_mesg
          );
          hr_utility.set_location(l_proc, 420);
/*****
t_people_tab PL/sql table cannot be modified in pqp_windstar_person_validate
procedure. c_country_code_xlat_cursor cursor will translate the Oracle
Application country code to a valid IRS country code
*****/
          if (t_people_tab(i).non_us_country_code is not null) then
              for c1_xlat in c_country_code_xlat_cursor
                             (
                                t_people_tab(i).non_us_country_code,
                                p_effective_date
                             )
              loop
                  -- t_people_tab(i).non_us_country_code := c1_xlat.meaning ;
                  -- changed the following to strip the 'IRS-' from the meaning
                  -- fix for the bug #2170501 - tmehra
                  t_people_tab(i).non_us_country_code := SUBSTR(c1_xlat.meaning,
                                                                5,
                                                                length(c1_xlat.meaning)) ;

              end loop;
          end if;
          hr_utility.set_location(l_proc, 430);
/*****
A warning message is appended to the description field of the pay_process_events
table, if the Non US Country code is not a valid tax country code
*****/
          l_country_validate_count := 0;
          l_warn_mesg              := null;
          open c_tax_country_code_cursor(t_people_tab(i).non_us_country_code ,
                                         p_effective_date                 );
          fetch c_tax_country_code_cursor
              into l_country_validate_count;
          close c_tax_country_code_cursor;
          if (l_country_validate_count = 0) then
              if (t_people_tab(i).non_us_country_code is null) then
                  l_warn_mesg :='| Warning ==> Non US Country Code is NULL |';
              else
              l_warn_mesg := '| Warning ==> Non US Country Code [' ||
                                    t_people_tab(i).non_us_country_code ||
                                         '] may be Invalid |';
              end if;
          end if;
          hr_utility.set_location(l_proc, 440);

/*****
 delete the current row in the PL/sql table. update the status in the
 pay_process_events table to reflect the status as DATA_VALIDATION_FAILED.
 the row is deleted as we do not want to insert the row containing an
 error/validation failure in indv_rev1_temp table.
*****/
          l_process_event_id := null;

          open pay_process_events_ovn_cursor(l_person_id     ,
                                             p_source_type   ,
                                             p_effective_date);
          loop

              l_description := null;
              fetch pay_process_events_ovn_cursor into
                   l_process_event_id      ,
                   l_object_version_number ,
                   l_assignment_id         ,
                   l_description           ;
              hr_utility.set_location(l_proc, 450);

              exit when pay_process_events_ovn_cursor%notfound;

              if (l_out_mesg is null) then
                  hr_utility.set_location(l_proc, 460);
/*****
 l_out_mesg = null means that there was no failure. increment the counter
 and proceed for fetching of the next row from the respective cursor.
 We therefore do not change the status. the status is changed from N to R
 after a row in inserted in ten42s_state_temp table
*****/

                  if (l_warn_mesg is not null) then
                      hr_utility.set_location(l_proc, 470);
                      pqp_process_events_errorlog
                      (
                          p_process_event_id1      => l_process_event_id     ,
                          p_object_version_number1 => l_object_version_number,
                          p_status1                => hr_api.g_varchar2      ,
                          p_description1           =>
                                  SUBSTR(l_description || l_warn_mesg, 1, 240)
                      );
                  end if;
              else
                  hr_utility.set_location(l_proc, 480);
/*****
Since l_out_mesg is not null, that means an error was detected. We therefore
change the status of the pay_process_events table to 'D' meaning
DATA_VALIDATION_FAILED
*****/
                  pqp_process_events_errorlog
                  (
                      p_process_event_id1      => l_process_event_id       ,
                      p_object_version_number1 => l_object_version_number  ,
                      p_status1                => 'D'                      ,
                      p_description1           =>
                                     SUBSTR(l_out_mesg || l_warn_mesg ||
                                                     l_description, 1, 240)
                  );
              end if;
          end loop;

          close pay_process_events_ovn_cursor;
          if (l_out_mesg is null) then
              i := i + 1;
              hr_utility.set_location(l_proc, 490);
          else
              /* Added by tmehra for wf notification consolidation */
              if l_process_event_id is not null then
               l_err_count := l_err_count+1;

               t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
               t_error_tab(l_err_count).process_event_id   := l_process_event_id;
              end if;
              /* Changes for wf notification consolidation ends */

              t_people_tab.delete(i) ;
              l_person_err_count := l_person_err_count + 1;
              l_out_mesg  := null;
              l_warn_mesg := null;
              hr_utility.set_location(l_proc, 500);
          end if;
      exception
          when OTHERS then
              hr_utility.set_location(l_proc, 510);
              l_person_id := t_people_tab(i).person_id;
              if (t_people_tab.exists(i)) then
                  t_people_tab.delete(i) ;
                  l_person_err_count := l_person_err_count + 1;
              end if;
              l_out_mesg := SUBSTR('Oracle Error ' || TO_CHAR(sqlcode) ||
                                sqlerrm, 1, 240);
          if (pay_process_events_ovn_cursor%isopen = true) then
              close pay_process_events_ovn_cursor;
          end if;

          l_process_event_id := null;

          open pay_process_events_ovn_cursor(l_person_id     ,
                                             p_source_type   ,
                                             p_effective_date);
          loop
              fetch pay_process_events_ovn_cursor into
                   l_process_event_id      ,
                   l_object_version_number ,
                   l_assignment_id         ,
                   l_description           ;
              hr_utility.set_location(l_proc, 520);

              exit when pay_process_events_ovn_cursor%notfound;
                  pqp_process_events_errorlog
                  (
                      p_process_event_id1      => l_process_event_id       ,
                      p_object_version_number1 => l_object_version_number  ,
                      p_status1                => 'D'                      ,
                      p_description1           => l_out_mesg
                  );
          end loop;
          close pay_process_events_ovn_cursor;
          /* Added by tmehra for wf notification consolidation */
              if l_process_event_id is not null then
              l_err_count := l_err_count+1;

              t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
              t_error_tab(l_err_count).process_event_id   := l_process_event_id;

              end if;
          /* Changes for wf notification consolidation ends */

          l_out_mesg  := null;
          l_warn_mesg := null;
      end;
      end loop;
      close national_identifier_cursor;
  end if;
  hr_utility.set_location(l_proc, 530);
  p_person_read_count := l_person_read_count ;
  p_person_err_count  := l_person_err_count ;
  hr_utility.set_location('Leaving '||l_proc, 540);
exception
when OTHERS then
   p_person_read_count := l_person_read_count ;
   p_person_err_count  := l_person_err_count ;
   hr_utility.set_location('Leaving '||l_proc, 550);
   hr_utility.set_message(800, 'DTU10_GENERAL_ORACLE_ERROR');
   hr_utility.set_message_token('2', 'Error in pqp_alien_expat_taxation_pkg.'
          || 'pqp_windstar_person_read. Error Code = ' || TO_CHAR(sqlcode) ||
          ' ' || sqlerrm);
   hr_utility.raise_error;
end pqp_windstar_person_read;
/***************************************************************************
  name      : pqp_windstar_balance_read
  Purpose   : the following procedure is called from the main procedure. This
              returns the balance details.
  Arguments :
    in
      t_people_tab             : PL/sql table contains the Personal details.
                                 This is passed a an I/P parameter as this
                                 procedure returns the balance details only
                                 for the assignments present in this table.
      p_source_type            : source type(Winstar or some other system.
                                 as of now it is Windstar.
      p_effective_date         : Effective date.
    out
      t_balance_tab            : PL/sql table contains the balance details.
     in out
      t_error_tab              : PL/sql table contains the error details.
    Notes                        : private
*****************************************************************************/
procedure pqp_windstar_balance_read
(
  t_people_tab      in out NOCOPY  t_people_tab_type ,
  t_error_tab       in out NOCOPY  t_error_tab_type  ,
  p_source_type     in      varchar2          ,
  p_effective_date  in      date              ,
  t_balance_tab        out NOCOPY  t_balance_tab_type
) is   --{
  l_flag                       varchar2(3)   ;
  l_sub_type                   varchar2(3)   ;
  l_income_code                varchar2(10)  ;
  l_c_income_code              varchar2(10)  ;     -- Added by tmehra oct02
  l_earning_ele_flag           boolean       ;     -- Added by tmehra oct02

  l_proc                       varchar2(72) :=
                                   g_package || 'pqp_windstar_balance_read';
  l_balance_name               pay_balance_types.balance_name%type ;
  l_dimension_name             pay_balance_dimensions.dimension_name%type ;
  l_state                      varchar2(100) ;
  l_last_name                  per_all_people_f.last_name%type ;
  l_first_name                 per_all_people_f.first_name%type;
  l_middle_names               per_all_people_f.middle_names%type ;
  l_national_identifier        per_all_people_f.national_identifier%type ;
  l_tax_residence_country_code varchar2(100) ;
  l_description                varchar2(250) ;

  l_out_mesg                   out_mesg_type ;

  l_balance                    number        ;
  l_year                       number        ;
  l_prev_year                  number        ;
  l_count                      number := 0   ;
  l_counter                    number := 0   ;
  l_counter1                   number := 0   ;
  l_temp_assignment_id         per_all_assignments_f.assignment_id%type ;
  l_assignment_id              per_all_assignments_f.assignment_id%type ;
  j                            number        ;
  i                            number        ;
  l_err_count                  number        ;
  l_person_id                  per_all_people_f.person_id%type ;
  l_income_code_count          number := 0   ;
  l_process_event_id           number        ;
  l_object_version_number      per_all_people_f.object_version_number%type ;
  l_prev_amount                number        ;

  l_year_start                 date          ;
  l_year_end                   date          ;
  l_effective_date             date          ;   -- Added by tmehra Oct02
  l_date_of_birth              date          ;
  l_sit_flag                   boolean       ;
  l_analyzed_data_details_id
                     pqp_analyzed_alien_details.analyzed_data_details_id%type;
  l_analyzed_data_id    pqp_analyzed_alien_data.analyzed_data_id%type ;
  l_exemption_code      pqp_analyzed_alien_details.exemption_code%type;
  l_withholding_rate
                        pqp_analyzed_alien_details.withholding_rate%type     ;
  l_wh_allowance
                     pqp_analyzed_alien_data.withldg_allow_eligible_flag%type;
  l_income_code_sub_type
                      pqp_analyzed_alien_details.income_code_sub_type%type   ;
  l_constant_addl_tax   pqp_analyzed_alien_details.constant_addl_tax%type    ;


  type t_temp_person_assgn_rec is record
  (
      person_id     number ,
      assgnment_id  number
  );

  type t_person_assign_table_type is table of t_temp_person_assgn_rec
                        index by binary_integer                              ;
  type t_lookup_table_type is table of varchar2(45) index by binary_integer  ;

  t_temp_assignment_table  t_person_assign_table_type                        ;
  t_lookup_table           t_lookup_table_type                               ;

/*****
the following cursor decides whether a row is present in the
pqp_analyzed_alien_details table for the given income code and given
assignment id
*****/

  cursor c_analyzed_data(p_income_code   in varchar2 ,
                         p_person_id     in number   ,
                         p_tax_year      in number   ) is
      select income_code             ,
             exemption_code          ,
             withholding_rate        ,
             income_code_sub_type    ,
             constant_addl_tax
      from   pqp_analyzed_alien_data     paadat ,
             pqp_analyzed_alien_details  paadet ,
             per_people_f                ppf    ,
             per_assignments_f           paf
      where  paadat.analyzed_data_id = paadet.analyzed_data_id
      and    paadet.income_code      = p_income_code
      and    ppf.person_id           = paf.person_id
      and    ppf.person_id           = p_person_id
      and    paadat.tax_year         = p_tax_year
      and    paf.assignment_id       = paadat.assignment_id
      and    rownum < 2;
--
-- The following cursor selects rows if the person has earning elements in the
-- calender year of the effective date.
--
    cursor c_income_code_cursor(p_person_id  in number
                               ,c_year_start in date
                               ,c_year_end   in date ) is
    select distinct
           nvl(pet.element_information1, ' ') income_code
      from per_all_assignments_f       paf
          ,per_all_people_f            ppf
          ,pay_element_entries_f       pee
          ,pay_element_links_f         pel
          ,pay_element_types_f         pet
          ,pay_element_classifications pec
     where paf.person_id = ppf.person_id
       and ppf.person_id = p_person_id
       and ((c_year_end between paf.effective_start_date
                            and paf.effective_end_date
            )
           or
           (paf.effective_end_date =
                 (select max(asx.effective_end_date)
                    from per_all_assignments_f asx
                   where asx.assignment_id = paf.assignment_id
                     and asx.business_group_id = paf.business_group_id
                     and asx.person_id         = paf.person_id
                     and asx.effective_end_date between c_year_start
                                                    and c_year_end)
             )
           )
       and paf.effective_end_date between ppf.effective_start_date
                                      and ppf.effective_end_date
       and paf.assignment_id       = pee.assignment_id
       and pee.element_link_id     = pel.element_link_id
       and pel.element_type_id     = pet.element_type_id
       and pet.classification_id   = pec.classification_id
       and pec.classification_name = 'Alien/Expat Earnings'
       and ((c_year_end between pee.effective_start_date
                            and pee.effective_end_date
            )
           or
           (pee.effective_end_date =
                 (select max(pex.effective_end_date)
                    from pay_element_entries_f pex
                   where pex.assignment_id = paf.assignment_id
                     and pex.effective_end_date between c_year_start
                                                    and c_year_end)
            )
           )
       and pee.effective_end_date between pel.effective_start_date
                                      and pel.effective_end_date;

/*****
the following cursor selects all the active assignments for the person
in the calender year of the effective date
****/

  cursor c_assignment_id(p_person_id      in number ,
                         p_effective_date in date   ) is
      select person_id    ,
             assignment_id
      from   per_assignments_f paf
      where  paf.person_id             = p_person_id
      and    paf.effective_start_date <= TO_DATE(('12/31/' ||
                        TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_end_date   >= TO_DATE(('01/01/' ||
                        TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_start_date = (select MAX(effective_start_date)
                                          from   per_assignments_f
                                          where  assignment_id =
                                                     paf.assignment_id
                                          and    effective_start_date <=
                                                         TO_DATE(('12/31/' ||
                           TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      order by person_id    ,
               assignment_id;

/*****
the following cursor selects all the details about the payroll information
about the person.
*****/

  cursor c_person_payroll_info(p_person_id   in number,
                               p_income_code in varchar2,
                               p_year        in varchar2) is
      select pei_information5      income_code            ,
             pei_information6      prev_er_treaty_ben_amt ,
             pei_information7      prev_er_treaty_ben_year
      from   (select *
      from   per_people_extra_info
      where  information_type  = 'PER_US_PAYROLL_DETAILS'
      and    person_id                 = p_person_id )
      where   pei_information7          = p_year
      and    pei_information5          = p_income_code;

/*****
the following cursor selects the primary assignment Id for the person
in the calender year of the effective date. This cursor should always
return 0 or 1 row as rownum < 2 has been yse
*****/
  cursor c_person_assignment(p_person_id in number) is
      select distinct assignment_id
      from   per_assignments_f paf,
             per_people_f      ppf
      where  ppf.person_id = paf.person_id
      and    ppf.person_id = p_person_id
      and    ppf.effective_start_date <= TO_DATE(('12/31/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_end_date   >= TO_DATE(('01/01/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    ppf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_people_f
                                         where  person_id = ppf.person_id
                                         and    effective_start_date <=
                                                         TO_DATE(('12/31/' ||
                            TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    paf.effective_start_date <= TO_DATE(('12/31/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_end_date   >= TO_DATE(('01/01/' ||
                             TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY')
      and    paf.effective_start_date = (select MAX(effective_start_date)
                                         from   per_assignments_f
                                         where  assignment_id =
                                                    paf.assignment_id
                                         and    effective_start_date <=
                                                         TO_DATE(('12/31/' ||
                           TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'))
      and    paf.primary_flag = 'Y'
      and    rownum < 2;

  --
  -- The following cursor selects the work state of ther person
  --
     cursor c_work_state_cur(p_assign_id in number) is
     select nvl(hrlock.loc_information17
               ,hrlock.region_2) state

       from hr_locations             hrlock
           ,hr_soft_coding_keyflex   hrsckf
           ,per_all_assignments_f    paf

      where paf.effective_start_date <=
            to_date(('12/31/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY')
        and paf.effective_end_date   >=
            to_date(('01/01/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY')
        and paf.effective_start_date =
             (select max(effective_start_date)
                from per_assignments_f
               where assignment_id = paf.assignment_id
                 and effective_start_date <=
                     to_date(('12/31/'||to_char(p_effective_date,'YYYY'))
                             ,'MM/DD/YYYY')
              )
        and paf.assignment_id          = p_assign_id
        and paf.soft_coding_keyflex_id = hrsckf.soft_coding_keyflex_id
        and nvl(hrsckf.segment18,paf.location_id) = hrlock.location_id
        and rownum < 2;
  --
  -- Select the date Paid (cycle date as per windstar nomenclature) and
  -- date Earned(Last date of earning as per windstar nomenclature).
  --
     cursor c_date_paid_earned(p_person_id      in number
                              ,p_effective_date in date   ) is
     select max(ppa.effective_date) date_paid ,
            max(ppa.date_earned)    date_earned
       from pay_payroll_actions    ppa
           ,pay_assignment_actions paa
           ,per_assignments_f      paf
      where ppa.payroll_action_id = paa.payroll_action_id
        and paa.assignment_id     = paf.assignment_id
        and ppa.action_status     = 'C'
        and paa.action_status     = 'C'
        and ppa.action_type       in ('R','Q','I','B','V')
        and paf.person_id         = p_person_id
        and paf.effective_start_date <= p_effective_date
        and  ppa.effective_date      <= p_effective_date;
  --
  -- Select the number of Days in a pay period (number of days in a pay
  -- cycle as per windstar nomenclature).
  --
    cursor c_days_in_cycle(p_person_id      in number
                          ,p_effective_date in date   ) is
    select min(trunc((52/ number_per_fiscal_year) * 7)) days_in_cycle
      from per_time_periods      ptp
          ,per_assignments_f     paf
          ,per_time_period_types ptt
     where ptp.payroll_id             = paf.payroll_id
       and ptp.period_type            = ptt.period_type
       and paf.person_id              = p_person_id
       and paf.effective_start_date  <= p_effective_date;

  --
  -- The following cursor selects the forecasted Income code for a given
  -- person_id and in a given year.
  --
     cursor c_forecasted_income_code(p_person_id      in number
                                    ,p_assignment_id  in number
                                    ,p_effective_date in date) is
     select pei_information5    income_code
       from per_people_extra_info
      where person_id        = p_person_id
        and information_type = 'PER_US_INCOME_FORECAST'
        and pei_information8 = to_char(p_effective_date, 'YYYY');

  --
  -- The following cursor selects the effective_end_date for all the assignments
  -- of a terminated employee.
  --
     cursor c_terminated_employee_asg(p_person_id in number) is
     select paf.effective_end_date
       from per_people_f           ppf
           ,per_person_types       ppt
           ,per_assignments_f      paf
      where ppf.person_id          = p_person_id
        and ppf.person_type_id     = ppt.person_type_id
        and ppt.system_person_type ='EX_EMP'
        and paf.person_id          = ppf.person_id ;

begin
   hr_utility.set_location('Entering '||l_proc, 5);
   l_dimension_name := 'Assignment within Government Reporting Entity Year to Date';

   l_year      := to_number(to_char(p_effective_date, 'YYYY'));
   l_year_start:= to_date('01/01/'||to_char(p_effective_date, 'YYYY'),'MM/DD/YYYY');
   l_year_end  := to_date('12/31/'||to_char(p_effective_date, 'YYYY'),'MM/DD/YYYY');
   l_prev_year := l_year - 1;

   l_count     := t_people_tab.count;
   l_err_count := t_error_tab.count ;

   j := 1;

   if l_count >= 1 then
      hr_utility.set_location(l_proc, 10);

      l_sit_flag :=  true;
      for i in 1..l_count
      loop
      begin
          hr_utility.set_location(l_proc, 20);
          if (NVL(t_people_tab(i).validation_flag, ' ') <> '0') then

              hr_utility.set_location(l_proc, 30);

              l_sit_flag           := true;
              l_person_id          := t_people_tab(i).person_id;
              l_last_name          := t_people_tab(i).last_name;
              l_first_name         := t_people_tab(i).first_name;
              l_middle_names       := t_people_tab(i).middle_names;
              l_national_identifier:= t_people_tab(i).national_identifier;
              l_date_of_birth      := t_people_tab(i).date_of_birth;

              for c_additional in c_person_additional_info(l_person_id)
              loop
                  l_tax_residence_country_code :=
                               c_additional.tax_res_country_code;
                  hr_utility.set_location(l_proc, 40);
              end loop;

              for c_ass in c_person_assignment(l_person_id)
              loop
                  l_assignment_id := c_ass.assignment_id;
                  hr_utility.set_location(l_proc, 50);
              end loop;

              for c_state in c_work_state_cur(l_assignment_id)
              loop
                  l_state := c_state.state;
                  hr_utility.set_location(l_proc, 60);
              end loop;

              open c_income_code_cursor( l_person_id,
                                         l_year_start,
                                         l_year_end
                                        );

              l_income_code_count := 0;

              loop

                fetch c_income_code_cursor
                 into l_c_income_code;

                if c_income_code_cursor%notfound then

                   if (c_forecasted_income_code%isopen <> true) then

                       open c_forecasted_income_code (l_person_id,
                                                      l_assignment_id,
                                                     p_effective_date);
                   end if;

                   fetch c_forecasted_income_code
                    into l_c_income_code;
                   -- Exclude this person if neither the
                   -- Element Entry is attached not the
                   -- Forecasted Income code is present
                 exit when c_forecasted_income_code%notfound;

                end if;

                l_income_code_count := 1;

                begin
                  hr_utility.set_location(l_proc, 70);
                  l_income_code := '';
                  --
                  -- The sql below decides if the respective earning entries
                  -- attached to the assignment. Decide if the request is for
                  -- the forecasted or the actual record. check here for
                  -- forecasted vs actual record. select the data from the
                  -- c_analyzed_data cursor. if a row is selected then it means
                  -- that a record already exists.
                  --

                  if (c_analyzed_data%isopen = true) then
                      close c_analyzed_data;
                  end if;

                  open c_analyzed_data(l_c_income_code
                                      ,l_person_id
                                      ,l_year);
                  fetch c_analyzed_data
                   into l_income_code
                       ,l_exemption_code
                       ,l_withholding_rate
                       ,l_income_code_sub_type
                       ,l_constant_addl_tax;

                  hr_utility.set_location(l_proc, 80);

                  l_balance                            := 0;

                  t_balance_tab(j).person_id           := l_person_id;
                  t_balance_tab(j).last_name           := l_last_name;
                  t_balance_tab(j).first_name          := l_first_name;
                  t_balance_tab(j).middle_names        := l_middle_names;
                  t_balance_tab(j).national_identifier :=l_national_identifier;
                  t_balance_tab(j).date_of_birth       := l_date_of_birth;

                  l_prev_amount := 0;

                  for c_payment in c_person_payroll_info
                                  (l_person_id    ,
                                   l_c_income_code ,
                                   to_char(l_year)
                                   )
                  loop
                      l_prev_amount := c_payment.prev_er_treaty_ben_amt;
                  end loop;

                  hr_utility.set_location(l_proc, 90);

                  if (length(l_c_income_code) > 2) then
                      l_sub_type := substr(l_c_income_code, 3, 1);
                  end if;
                  hr_utility.set_location(l_proc, 100);

                  if (IsPayrollRun
                      (l_person_id
                      ,TO_DATE('31/12/'|| TO_CHAR(l_year),'DD/MM/YYYY')
                      ,l_income_code) = false) then

                      hr_utility.set_location(l_proc, 110);

                      l_flag     := 'F';
                      l_balance  := pqp_forecasted_balance
                                   (l_person_id      ,
                                    l_c_income_code  ,
                                    p_effective_date );
                      t_balance_tab(j).gross_amount          := l_balance;
                      t_balance_tab(j).exemption_code        := 0;
                      t_balance_tab(j).withholding_allowance := 0;
                      t_balance_tab(j).withholding_rate      := 0;
                      t_balance_tab(j).withheld_amount       := 0;
                      t_balance_tab(j).income_code_sub_type  := l_sub_type;
                      t_balance_tab(j).country_code :=
                          l_tax_residence_country_code;
                      t_balance_tab(j).cycle_date            := null;
                      t_balance_tab(j).tax_year              := l_year;
                      t_balance_tab(j).state_withheld_amount := 0;
                      t_balance_tab(j).state_code            := l_state;
                      t_balance_tab(j).record_source         := null;
                      t_balance_tab(j).payment_type          := 'Y';
                      t_balance_tab(j).last_date_of_earnings := null;
                      t_balance_tab(j).record_status         := 'F';
                      --
                      -- How to calculate the last_date_of_earnings. This is the
                      -- last date of payment check
                      --
                      t_balance_tab(j).prev_er_treaty_benefit_amount :=
                                                       l_prev_amount        ;
                      t_balance_tab(j).person_id             := l_person_id ;
                      t_balance_tab(j).income_code           :=
                                                SUBSTR(l_c_income_code, 1, 2);
                      t_balance_tab(j).constant_addl_tax     := 0           ;
                      pqp_windstar_balance_validate
                      (    p_in_data_rec    => t_balance_tab(j) ,
                           p_effective_date => p_effective_date ,
                           p_out_mesg       => l_out_mesg       ,
                           p_forecasted     => true
                      );
                      hr_utility.set_location(l_proc, 120);
                  else
                      hr_utility.set_location(l_proc, 130);
                      l_flag     := 'A';

                      l_effective_date :=
                         to_date('31/12/'||to_char(l_year),'DD/MM/YYYY');

                      for c_rec in c_terminated_employee_asg(l_person_id)
                      loop

                        if c_rec.effective_end_date < l_effective_date then
                            l_effective_date := c_rec.effective_end_date;
                        end if;

                      end loop;

                      -- Gross Amount
                      l_balance  := 0;
                      l_balance  := pqp_balance
                                   (p_income_code     => l_c_income_code
                                   ,p_dimension_name  => null
                                   ,p_assignment_id   => l_assignment_id
                                   ,p_effective_date  => l_effective_date
                                   ,p_state_code      => null
                                   ,p_fit_wh_bal_flag => 'N'
                                   ,p_balance_name    => null)
                                    -
                                    pqp_balance
                                   (p_income_code     => l_c_income_code
                                   ,p_dimension_name  => null
                                   ,p_assignment_id   => l_assignment_id
                                   ,p_effective_date  => l_effective_date
                                   ,p_state_code      => null
                                   ,p_fit_wh_bal_flag => 'P'
                                   ,p_balance_name    => null
                                    );
                      t_balance_tab(j).gross_amount := l_balance;

                      if (l_exemption_code) = '9' then
                          l_exemption_code := '0';
                      end if;

                      t_balance_tab(j).exemption_code := l_exemption_code ;
                      t_balance_tab(j).withholding_allowance:= 0             ;
                      t_balance_tab(j).withholding_rate :=
                       lpad(to_char(nvl(l_withholding_rate, 0) * 10), 3, '0');
                      t_balance_tab(j).constant_addl_tax:= l_constant_addl_tax;

                      l_balance  := 0;
                      l_balance  := pqp_balance
                                   (p_income_code     => l_c_income_code
                                   ,p_dimension_name  => null
                                   ,p_assignment_id   => l_assignment_id
                                   ,p_effective_date  => l_effective_date
                                   ,p_state_code      => null
                                   ,p_fit_wh_bal_flag => 'Y'
                                   ,p_balance_name    => null
                                    );

                      t_balance_tab(j).withheld_amount      := l_balance;
                      t_balance_tab(j).income_code_sub_type := l_sub_type;
                      t_balance_tab(j).country_code :=
                         l_tax_residence_country_code;

                      for cdpe in c_date_paid_earned
                                 (l_person_id ,
                                  to_date('31/12/'||to_char(l_year),'DD/MM/YYYY')
                                  )
                      loop
                          t_balance_tab(j).cycle_date := cdpe.date_paid;
                          t_balance_tab(j).last_date_of_earnings :=
                              cdpe.date_earned ;
                      end loop;

                      hr_utility.set_location(l_proc, 140);

                      t_balance_tab(j).tax_year := l_year ;

                      if (l_sit_flag = true) then

                          hr_utility.set_location(l_proc, 150);

                          l_balance  := 0;
                          l_balance  := pqp_balance
                                       (p_income_code     => null
                                       ,p_dimension_name  =>'Person in JD within GRE Year to Date'
                                       ,p_assignment_id   => l_assignment_id
                                       ,p_effective_date  => l_effective_date
                                       ,p_state_code      => l_state
                                       ,p_fit_wh_bal_flag => 'N'
                                       ,p_balance_name    => 'SIT Alien Withheld'
                                        );
                          t_balance_tab(j).state_withheld_amount := l_balance;
                          l_sit_flag := false;

                      else
                          hr_utility.set_location(l_proc, 160);

                          t_balance_tab(j).state_withheld_amount := 0;
                      end if;

                      t_balance_tab(j).state_code    := l_state;
                      t_balance_tab(j).record_source := null;
                      t_balance_tab(j).payment_type  := 'Y';
                      t_balance_tab(j).record_status := 'A';

                      if t_balance_tab(j).last_date_of_earnings is null then
                         t_balance_tab(j).record_status := 'F';
                      end if;

                      t_balance_tab(j).prev_er_treaty_benefit_amount
                          := l_prev_amount   ;
                      t_balance_tab(j).person_id := l_person_id;
                      t_balance_tab(j).income_code
                          := substr(l_c_income_code, 1, 2);
                      for cdic in c_days_in_cycle
                                 (l_person_id,
                                  to_date('31/12/'||to_char(l_year),'DD/MM/YYYY')
                                 )
                      loop
                          t_balance_tab(j).no_of_days_in_cycle
                            := cdic.days_in_cycle;
                      end loop;

                      hr_utility.set_location(l_proc, 170);

                      pqp_windstar_balance_validate
                      (p_in_data_rec    => t_balance_tab(j)
                      ,p_effective_date => p_effective_date
                      ,p_out_mesg       => l_out_mesg
                      ,p_forecasted     => false
                      );

                      hr_utility.set_location(l_proc, 180);
                  end if;
                  if (l_out_mesg is null) then
                     --
                     -- l_out_mesg means there is no failure. increment the
                     -- counter and proceed for fetching of the next row from
                     -- the respective cursor
                     --
                     j := j + 1;
                     hr_utility.set_location(l_proc, 190);
                  else              --ELSE4}{
                     hr_utility.set_location(l_proc, 200);
                     -- Delete the current row in the PL/sql table. update the
                     -- status in the pay_process_events table to reflect the
                     -- status as DATA_VALIDATION_FAILED
                     --
                     if (pay_process_events_ovn_cursor%isopen = true) then
                         close pay_process_events_ovn_cursor;
                     end if;

                     l_process_event_id := null;

                     open pay_process_events_ovn_cursor(l_person_id      ,
                                                        p_source_type    ,
                                                        p_effective_date );
                     loop
                     fetch pay_process_events_ovn_cursor
                      into l_process_event_id
                          ,l_object_version_number
                          ,l_assignment_id
                          ,l_description;

                      hr_utility.set_location(l_proc, 210);

                      exit when pay_process_events_ovn_cursor%notfound;

                      pqp_process_events_errorlog
                             (
                              p_process_event_id1      => l_process_event_id       ,
                              p_object_version_number1 => l_object_version_number  ,
                              p_status1                => 'D'                      ,
                              p_description1           =>
                                                     SUBSTR(l_out_mesg ||
                                                           l_description, 1, 240)
                              );

                      end loop;

                      if (pay_process_events_ovn_cursor%isopen = true) then
                          close pay_process_events_ovn_cursor;
                      end if;

                      /* Added by tmehra for wf notification consolidation */
                      if l_process_event_id is not null then
                         l_err_count := l_err_count+1;

                         t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
                         t_error_tab(l_err_count).process_event_id   := l_process_event_id;

                      end if;
                      /* Changes for wf notification consolidation ends */

                      t_balance_tab.delete(j) ;
                      l_out_mesg := null;
                      t_people_tab(i).validation_flag := '0';
/* 0 indicates an Error */
                      exit;
                      hr_utility.set_location(l_proc, 260);
                  end if; --ENDIF4}
                  close c_analyzed_data;
              exception
                  when OTHERS then
                      hr_utility.set_location(l_proc, 270);
                      if (pay_process_events_ovn_cursor%isopen = true) then
                          close pay_process_events_ovn_cursor;
                      end if;
                      if (c_analyzed_data%isopen = true) then
                          close c_analyzed_data;
                      end if;
                      l_out_mesg := SUBSTR('Error while processing 1042s ' ||
                                        TO_CHAR(SQLCODE) || SQLERRM, 1, 240);

                      l_process_event_id := null;

                      open pay_process_events_ovn_cursor(l_person_id      ,
                                                         p_source_type    ,
                                                         p_effective_date );
                      loop  --LOOP3{
                          fetch pay_process_events_ovn_cursor into
                                  l_process_event_id      ,
                                  l_object_version_number ,
                                  l_assignment_id         ,
                                  l_description           ;
                          exit when pay_process_events_ovn_cursor%notfound;
                          hr_utility.set_location(l_proc, 280);

                  /* Update pay_process_events table with a status of 'D' */

                          pqp_process_events_errorlog
                          (
                            p_process_event_id1 =>l_process_event_id         ,
                            p_object_version_number1=>l_object_version_number,
                            p_status1        => 'D'                          ,
                            p_description1   => SUBSTR(l_out_mesg, 1, 240)
                          );

                      end loop;   --ENDLOOP3}
                      close pay_process_events_ovn_cursor;
                      if (t_balance_tab.exists(j)) then
                          t_balance_tab.delete(j) ;
                      end if;

                      /* Added by tmehra for wf notification consolidation */
                      if l_process_event_id is not null then
                         l_err_count := l_err_count+1;

                         t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
                         t_error_tab(l_err_count).process_event_id   := l_process_event_id;

                      end if;

                     /* Changes for wf notification consolidation ends */

                      l_out_mesg := null;
                      t_people_tab(i).validation_flag := '0';
                      t_people_tab(i).error_mesg :=
                             SUBSTR('Error while processing 1042s details' ||
                                 l_out_mesg, 1, 240);
                      l_out_mesg := null;
                      exit;
              end;  --END3}

              exit when (c_income_code_cursor%notfound
                    and  c_forecasted_income_code%notfound);

              end loop; --ENDLOOP2} c_income_code_cursor cursor

              close c_income_code_cursor;
              close c_forecasted_income_code;

              if l_income_code_count = 0 then

                 l_process_event_id := null;

                 open pay_process_events_ovn_cursor(l_person_id      ,
                                                     p_source_type    ,
                                                     p_effective_date );
                  loop
                          fetch pay_process_events_ovn_cursor into
                                  l_process_event_id      ,
                                  l_object_version_number ,
                                  l_assignment_id         ,
                                  l_description           ;
                          exit when pay_process_events_ovn_cursor%notfound;
                          hr_utility.set_location(l_proc, 280);

                  /* Update pay_process_events table with a status of 'D' */

                  pqp_process_events_errorlog
                  (p_process_event_id1 =>l_process_event_id         ,
                   p_object_version_number1=>l_object_version_number,
                   p_status1        => 'D'                          ,
                   p_description1   => 'No Alien Income or Forecast found'
                  );

                  end loop;

                 /* Added by tmehra for wf notification consolidation */
                 if l_process_event_id is not null then
                  l_err_count := l_err_count+1;

                  t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
                  t_error_tab(l_err_count).process_event_id   := l_process_event_id;

                 end if;
                  /* Changes for wf notification consolidation ends */
                  close pay_process_events_ovn_cursor;
                  l_out_mesg := null;
                  t_people_tab(i).validation_flag := '0';
                  t_people_tab(i).error_mesg :=
                             SUBSTR('No Alien Income or Forecast found' ||
                                 l_out_mesg, 1, 240);
                      l_out_mesg := null;

              end if;

              hr_utility.set_location(l_proc, 290);

          end if; --ENDIF2} validation_flag = 0


          exception
              when OTHERS then
                  hr_utility.set_location(l_proc, 300);
                  l_out_mesg :=  SUBSTR(TO_CHAR(SQLCODE) || SQLERRM, 1, 240);
                  t_people_tab(i).validation_flag := '0';
                  t_people_tab(i).error_mesg :=
                      SUBSTR('Error while processing 1042s details' ||
                         l_out_mesg, 1, 240);
                  l_out_mesg := null;
          end;  --END2}
      end loop; --ENDLOOP1}
  end if;   /* END IF # 1 */  --ENDIF}
  hr_utility.set_location('Leaving '||l_proc, 310);
exception  --EXC1}{
when OTHERS then
   hr_utility.set_location('Entering exc'||l_proc, 320);
   hr_utility.set_message(800, 'DTU10_GENERAL_ORACLE_ERROR');
   hr_utility.set_message_token('2', 'Error in pqp_alien_expat_taxation_pkg.'
          || 'pqp_windstar_balance_read. Error Code = ' || TO_CHAR(sqlcode) ||
          ' ' || sqlerrm);
   hr_utility.raise_error;
end pqp_windstar_balance_read; --END1}
/***************************************************************************
  name      : pqp_windstar_visa_read
  Purpose   : the following procedure is called from the main procedure. This
              returns the visa details.
  Arguments :
    in
      t_people_tab          : PL/sql table contains the Personal details.
                                 This is passed a an I/P parameter as this
                                 procedure returns the visa details only
                                 for the assignments present in this
                                 table.
      p_effective_date      : Effective date.
    out
      t_visa_tab            : PL/sql table contains the visa details.
    in out
      t_error_tab           : PL/sql table contains the error details.

  Notes                     : private
*****************************************************************************/

procedure pqp_windstar_visa_read
(
  t_people_tab             in  out NOCOPY t_people_tab_type ,
  t_error_tab              in  out NOCOPY t_error_tab_type  ,
  p_source_type            in  varchar2              ,
  p_effective_date         in  date                  ,
  t_visa_tab               out NOCOPY t_visa_tab_type
) is

  l_last_name                  per_all_people_f.last_name%type ;
  l_first_name                 per_all_people_f.first_name%type ;
  l_middle_names               per_all_people_f.middle_names%type ;
  l_national_identifier        per_all_people_f.national_identifier%type ;
  l_tax_residence_country_code varchar2(100) ;
  l_description                varchar2(250) ;
  l_proc               varchar2(72) := g_package||'pqp_windstar_visa_read'  ;
  l_primary_activity           varchar2(30)  ;
  l_visa_start_date            date          ;
  l_visa_end_date              date          ;
  l_date_of_birth              date          ;
  l_01jan_date                 date          ;
  l_31dec_date                 date          ;
  l_prev_end_date              date          ;
  l_out_mesg                   out_mesg_type ;
  l_person_id                  per_all_people_f.person_id%type ;
  l_process_event_id           number        ;
  l_object_version_number      per_all_people_f.object_version_number%type ;
  l_assignment_id              number        ;
  i                            number        ;
  j                            number := 1   ;
  l_err_count                  number        ;
  l_count                      number        ;
  l_visa_found                 varchar2(10) := 'NONE';
  l_visa_err_mesg              out_mesg_type ;

  l_visa_count                 number :=0    ;
  l_skip_person                boolean := false;
/*****
the following cursor selects all the visa details of a person. We are sending
the status of the current visa record only to Windstar.
*****/
  cursor c_person_visa_info(p_person_id        in number,
                            p_visa_no          in varchar2) is
      select pei_information5                             visa_type        ,
             SUBSTR(pei_information6, 1, 20)              visa_number      ,
             fnd_date.canonical_to_date(pei_information7) visa_issue_date  ,
             fnd_date.canonical_to_date(pei_information8) visa_expiry_date ,
             pei_information9                             visa_category    ,
             pei_information10                            current_status
      from   (select * from per_people_extra_info
              where  information_type  = 'PER_US_VISA_DETAILS' )
      where  person_id                         = p_person_id
      and    information_type          = 'PER_US_VISA_DETAILS'
      and    pei_information6                  = NVL(p_visa_no, pei_information6)
      order by 6 desc,  -- So that Y comes first
               3 asc,
               4 asc;
/*****
the cursor c_person_visit_visa_info gives the visa info of a particular
person id.
****/
  cursor c_person_visit_visa_info(p_person_id       in number ) is
      select pei_information5                             purpose    ,
             fnd_date.canonical_to_date(pei_information7) start_date ,
             fnd_date.canonical_to_date(pei_information8) end_date   ,
             pei_information11                            visa_number
      from   (select * from per_people_extra_info
              where  information_type  = 'PER_US_VISIT_HISTORY'
              and    person_id                 = p_person_id )
      order by 2 asc,
               3 asc;

/*****
the cursor c_get_visa_count gives the visa info of a particular
person id.
****/

   cursor c_visa_count(p_person_id       in number ) is
       select count(*) ct
         from
            (select *
               from per_people_extra_info
              where information_type  = 'PER_US_VISA_DETAILS') visa
        where visa.person_id = p_person_id;


/*****
the cursor c_validate_visa_number gives the visa info of a particular
person id.
****/
       cursor c_validate_visa_number(p_person_id       in number ) is
       select visa.visa_number
         from
             (select *
               from per_people_extra_info
              where information_type = 'PER_US_ADDITIONAL_DETAILS'
                and pei_information12        = 'WINDSTAR') pei,
            (select person_id,
                    SUBSTR(pei_information6, 1, 20)  visa_number
               from per_people_extra_info
              where information_type  = 'PER_US_VISA_DETAILS') visa
       where visa.person_id  = pei.person_id
         and pei.person_id   = p_person_id
         and not exists
            (select 'X'
               from per_people_extra_info
              where information_type  = 'PER_US_VISIT_HISTORY'
                and person_id = visa.person_id
                and SUBSTR(pei_information11, 1, 20) = visa.visa_number
            );

begin

  hr_utility.set_location('Entering '||l_proc, 5);
  l_count := t_people_tab.COUNT;
  l_err_count := t_error_tab.COUNT;
  l_01jan_date := TO_DATE('01/01/'|| TO_CHAR(p_effective_date, 'YYYY'),
                                                           'DD/MM/YYYY');
  l_31dec_date := TO_DATE('31/12/' || TO_CHAR(p_effective_date, 'YYYY'),
                                                           'DD/MM/YYYY');
  for i in 1..l_count
  loop --LOOP1{
  begin

  hr_utility.set_location(l_proc, 10);

  -- Get the errornous record count, Skip this person and raise the notification

  l_skip_person   := false;
  l_visa_err_mesg := '';

  for c_rec in c_visa_count(t_people_tab(i).person_id)
  loop

    l_visa_count := c_rec.ct;

  end loop;

  if l_visa_count > 1 then
     for c_rec in c_validate_visa_number(t_people_tab(i).person_id)
     loop
         l_visa_err_mesg := l_visa_err_mesg||' '||trim(c_rec.visa_number);
         l_skip_person := true;
     end loop;
  else
    l_skip_person := false;
  end if;

  hr_utility.set_location(l_proc, 20);

  if (NVL(t_people_tab(i).validation_flag, ' ') <> '0'
       and l_skip_person = false) then  --IF1{
      hr_utility.set_location(l_proc, 30);

      l_person_id           := ''  ;
      l_last_name           := ''  ;
      l_first_name          := ''  ;
      l_middle_names        := ''  ;
      l_national_identifier := ''  ;
      l_date_of_birth       := ''  ;

      l_person_id           := t_people_tab(i).person_id          ;
      l_last_name           := t_people_tab(i).last_name          ;
      l_first_name          := t_people_tab(i).first_name         ;
      l_middle_names        := t_people_tab(i).middle_names       ;
      l_national_identifier := t_people_tab(i).national_identifier;
      l_date_of_birth       := t_people_tab(i).date_of_birth      ;
      for c_additional in c_person_additional_info(l_person_id)
      loop
          l_tax_residence_country_code := c_additional.tax_res_country_code;
      end loop;
      hr_utility.set_location(l_proc, 40);
      l_prev_end_date := null;

      l_visa_found := 'NONE';

      for cpv in c_person_visit_visa_info(l_person_id )
      loop --LOOP2{

      -- means Visit details are available
      l_visa_found := 'VISIT';

      for c_person_visa in c_person_visa_info(t_people_tab(i).person_id ,
                                              cpv.visa_number )
      loop  --LOOP3{

      -- means Visa details are available
      l_visa_found := 'VISA';

      begin
          hr_utility.set_location(l_proc, 50);
          t_visa_tab(j).person_id           := l_person_id                ;
          t_visa_tab(j).last_name           := l_last_name                ;
          t_visa_tab(j).first_name          := l_first_name               ;
          t_visa_tab(j).middle_names        := l_middle_names             ;
          t_visa_tab(j).national_identifier := l_national_identifier      ;
          t_visa_tab(j).date_of_birth       := l_date_of_birth            ;
          t_visa_tab(j).tax_residence_country_code :=
                                        l_tax_residence_country_code      ;
          t_visa_tab(j).visa_type           := c_person_visa.visa_type    ;
          t_visa_tab(j).j_category_code     := c_person_visa.visa_category;
          t_visa_tab(j).visa_number           := c_person_visa.visa_number   ;
          t_visa_tab(j).primary_activity_code := cpv.purpose;

          t_visa_tab(j).visa_start_date := cpv.start_date;
          t_visa_tab(j).visa_end_date   :=
                         NVL(cpv.end_date, c_person_visa.visa_expiry_date);

          if (t_visa_tab(j).visa_end_date >
                          c_person_visa.visa_expiry_date) then
              t_visa_tab(j).visa_end_date := c_person_visa.visa_expiry_date;
          end if;

          pqp_windstar_visa_validate
          (    p_in_data_rec    => t_visa_tab(j)    ,
               p_effective_date => p_effective_date ,
               p_prev_end_date  => l_prev_end_date  ,
               p_out_mesg       => l_out_mesg
          );
          if (l_out_mesg is null) then  --IF3{
/* Means there was no failure. Increment the counter and proceed for
 fetching of the next row from the respective cursor */
              l_prev_end_date := t_visa_tab(j).visa_end_date;
              j := j + 1;
              hr_utility.set_location(l_proc, 60);
          else    --ELSE3}{
/* Delete the current row in the PL/SQL table. Update the status in the
 pay_process_events table to reflect the status as DATA_VALIDATION_FAILED
*/
              hr_utility.set_location(l_proc, 70);

              l_process_event_id := null;

              open pay_process_events_ovn_cursor(l_person_id      ,
                                                 p_source_type    ,
                                                 p_effective_date );
              loop
              fetch pay_process_events_ovn_cursor into
                   l_process_event_id      ,
                   l_object_version_number ,
                   l_assignment_id         ,
                   l_description           ;
              hr_utility.set_location(l_proc, 80);
              exit when pay_process_events_ovn_cursor%notfound;
                  /* Update pay_process_events table */
                  pqp_process_events_errorlog
                  (
                      p_process_event_id1      => l_process_event_id       ,
                      p_object_version_number1 => l_object_version_number  ,
                      p_status1                => 'D' ,
                      p_description1           => SUBSTR(l_out_mesg, 1, 240)
                  );
                  hr_utility.set_location(l_proc, 90);
                  hr_utility.set_location(l_proc, 100);
              end loop;
              close pay_process_events_ovn_cursor;
              if (t_visa_tab.exists(j)) then
                  t_visa_tab.delete(j) ;
              end if;
              /* Added by tmehra for wf notification consolidation */
              if l_process_event_id is not null then
                 l_err_count := l_err_count+1;

                 t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
                 t_error_tab(l_err_count).process_event_id   := l_process_event_id;

              end if;
             /* Changes for wf notification consolidation ends */

              l_out_mesg := null;
              t_people_tab(i).validation_flag := '0';
              exit;
/*** The above EXIT is to make sure that we just do not process any more
visa records of this person Id
***/
          end if; --ENDIF}
      exception
          when OTHERS then
              hr_utility.set_location(l_proc, 110);
              if (pay_process_events_ovn_cursor%isopen = true) then
                  close pay_process_events_ovn_cursor;
              end if;
              l_out_mesg := SUBSTR(TO_CHAR(SQLCODE) || SQLERRM, 1, 240);

              l_process_event_id := null;

              open pay_process_events_ovn_cursor(l_person_id      ,
                                                 p_source_type    ,
                                                 p_effective_date );
              loop
              fetch pay_process_events_ovn_cursor into
                   l_process_event_id      ,
                   l_object_version_number ,
                   l_assignment_id         ,
                   l_description           ;
              hr_utility.set_location(l_proc, 120);
              exit when pay_process_events_ovn_cursor%notfound;

                  /* Update pay_process_events table with a status of 'D' */

                  pqp_process_events_errorlog
                  (
                      p_process_event_id1      => l_process_event_id       ,
                      p_object_version_number1 => l_object_version_number  ,
                      p_status1                => 'D' ,
                      p_description1           => SUBSTR(l_out_mesg, 1, 240)
                  );
                  hr_utility.set_location(l_proc, 130);

              end loop;
              close pay_process_events_ovn_cursor;
              if (t_visa_tab.exists(j)) then
                  t_visa_tab.delete(j) ;
              end if;
              hr_utility.set_location(l_proc, 140);

              /* Added by tmehra for wf notification consolidation */
              if l_process_event_id is not null then
                 l_err_count := l_err_count+1;

                 t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
                 t_error_tab(l_err_count).process_event_id   := l_process_event_id;

              end if;

              /* Changes for wf notification consolidation ends */

              l_out_mesg := null;
              t_people_tab(i).validation_flag := '0';
              t_people_tab(i).error_mesg :=
                 SUBSTR('Error while processing visa details' || l_out_mesg,
                          1, 240);
              l_out_mesg := null;
              exit;
      end;
      exit;
      end loop; --LOOP3}
      end loop; --LOOP2}

              if   (l_visa_found = 'NONE'
                 or l_visa_found = 'VISIT')  then

                 if l_visa_found = 'NONE' then
                    l_visa_err_mesg := 'Employee visit history details not found';
                 else
                    l_visa_err_mesg := 'Employee VISA details not found';
                 end if;

                 l_process_event_id := null;

                 open pay_process_events_ovn_cursor(l_person_id      ,
                                                     p_source_type    ,
                                                     p_effective_date );
                  loop
                          fetch pay_process_events_ovn_cursor into
                                  l_process_event_id      ,
                                  l_object_version_number ,
                                  l_assignment_id         ,
                                  l_description           ;
                          exit when pay_process_events_ovn_cursor%notfound;
                          hr_utility.set_location(l_proc, 280);

                  /* Update pay_process_events table with a status of 'D' */

                  pqp_process_events_errorlog
                  (p_process_event_id1 =>l_process_event_id         ,
                   p_object_version_number1=>l_object_version_number,
                   p_status1        => 'D'                          ,
                   p_description1   => l_visa_err_mesg
                  );

                  end loop;

                  close pay_process_events_ovn_cursor;

                  /* Added by tmehra for wf notification consolidation */
                  if l_process_event_id is not null then
                     l_err_count := l_err_count+1;

                     t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
                     t_error_tab(l_err_count).process_event_id   := l_process_event_id;

                  end if;

                  /* Changes for wf notification consolidation ends */

                  l_out_mesg := null;
                  t_people_tab(i).validation_flag := '0';
                  t_people_tab(i).error_mesg :=
                             SUBSTR(l_visa_err_mesg ||
                                 l_out_mesg, 1, 240);
                      l_out_mesg := null;

           end if;

  else -- ENDIF1}

     if l_skip_person  = true then

        l_visa_err_mesg := 'Visa Visit/Purpose History missing for the VISA:'||
                           l_visa_err_mesg;

        l_process_event_id := null;

        open pay_process_events_ovn_cursor(l_person_id      ,
                                         p_source_type    ,
                                         p_effective_date );
                  loop
                          fetch pay_process_events_ovn_cursor into
                                  l_process_event_id      ,
                                  l_object_version_number ,
                                  l_assignment_id         ,
                                  l_description           ;
                          exit when pay_process_events_ovn_cursor%notfound;
                          hr_utility.set_location(l_proc, 280);

                  /* Update pay_process_events table with a status of 'D' */

                  pqp_process_events_errorlog
                  (p_process_event_id1 =>l_process_event_id         ,
                   p_object_version_number1=>l_object_version_number,
                   p_status1        => 'D'                          ,
                   p_description1   => SUBSTR(l_visa_err_mesg,1,240)
                  );

                  end loop;

                  close pay_process_events_ovn_cursor;

                  /* Added by tmehra for wf notification consolidation */
                  if l_process_event_id is not null then
                     l_err_count := l_err_count+1;

                     t_error_tab(l_err_count).person_id          := t_people_tab(i).person_id;
                     t_error_tab(l_err_count).process_event_id   := l_process_event_id;
                  end if;

                  /* Changes for wf notification consolidation ends */

                  l_out_mesg := null;
                  t_people_tab(i).validation_flag := '0';
                  t_people_tab(i).error_mesg :=
                             SUBSTR(l_visa_err_mesg ||
                                 l_out_mesg, 1, 240);
                      l_out_mesg := null;

      end if;

  end if; --ENDIF1}
  exception
      when OTHERS then
      hr_utility.set_location(l_proc, 150);
      l_out_mesg :=  SUBSTR(TO_CHAR(SQLCODE) || SQLERRM, 1, 240);
      t_people_tab(i).validation_flag := '0';
      t_people_tab(i).error_mesg :=
            SUBSTR('Error while processing visa details' || l_out_mesg,
                   1, 240);
      l_out_mesg := null;
  end;

  end loop; --LOOP1 }
  hr_utility.set_location('Leaving '||l_proc, 160);
exception
when OTHERS then
   hr_utility.set_location('Entering exc'||l_proc, 170);
   hr_utility.set_message(800, 'DTU10_GENERAL_ORACLE_ERROR');
   hr_utility.set_message_token('2', 'Error in pqp_alien_expat_taxation_pkg.'
          || 'pqp_windstar_visa_read. Error Code = ' || TO_CHAR(sqlcode) ||
          ' ' || sqlerrm);
   hr_utility.raise_error;
end pqp_windstar_visa_read;
/****************************************************************************
  name      : pqp_read_public
  Purpose   : the following is the main procedure that is called from a
              wrapper script. This procedure returns 3 tables.
  Arguments :
    in
      p_selection_criterion : if the user wants to select all records,
                              or the records in the PAY_PROCESS_EVENTS table,
                              or a specifice national_identifier.
      p_effective_date      : Effective date.
    out
      p_batch_size          : out NOCOPY  number gives the batch size
      t_people_tab          : PL/sql table contains personal_details
      t_balance_tab         : PL/sql table contains the balance details
      p_visa_tab            : PL/sql table contains the visa details
  Notes                     : public
****************************************************************************/

procedure pqp_read_public
(
  p_selection_criterion        in    varchar2                     ,
  p_effective_date             in    date                         ,
  p_batch_size                out NOCOPY    number                       ,
  t_people_tab                out NOCOPY    t_people_tab_type            ,
  t_balance_tab               out NOCOPY    t_balance_tab_type           ,
  t_visa_tab                  out NOCOPY    t_visa_tab_type              ,
  p_person_read_count         out NOCOPY    number                       ,
  p_person_err_count          out NOCOPY    number
)
is

  /*****
   This is the definition of the table of the t_error_rec_type record type
   the record and the table definition is being added to consolidate
   the wf (workflow) notification logic at one place.
   Added by tmehra 20-Oct-2003.
  *****/

  l_count             number := 0                                   ;

  l_proc              varchar2(72) := g_package||'pqp_read_public'  ;
  l_person_read_count number := 0                                   ;
  l_person_err_count  number := 0                                   ;

  -- added by tmehra for wf notification consolidation
  t_error_tab         t_error_tab_type                              ;

begin
  hr_utility.set_location('Entering:'||l_proc, 5);

/*****
raise error message as Selection Criterion cannot be null
******/

  if (p_selection_criterion is null) then
      hr_utility.set_message(800, 'HR_7207_API_MANDATORY_ARG');
      hr_utility.set_message_token('ARGUMENT', 'Selection Criterion');
      hr_utility.set_message_token('API_NAME',
                        'pqp_alien_expat_taxation_pkg.pqp_read_public');
      hr_utility.raise_error;
  end if;
  begin
      hr_utility.set_location(l_proc, 10);
/*****
call pqp_windstar_person_read procedure to read all the information about
the person into PL/sql t_people_tab table.
******/

      pqp_windstar_person_read(p_selection_criterion=> p_selection_criterion ,
                               p_source_type        =>'PQP_US_ALIEN_WINDSTAR',
                               p_effective_date     => p_effective_date      ,
                               t_people_tab         => t_people_tab          ,
                               t_error_tab          => t_error_tab           ,
                               p_person_read_count  => l_person_read_count   ,
                               p_person_err_count   => l_person_err_count   );
      hr_utility.set_location(l_proc, 20);

      p_person_read_count := l_person_read_count;
      p_person_err_count  := l_person_err_count;

/* Call the pqp_windstar_person_read and get all the visa details of the
 assignments selected in the first procedure*/

/*****
call pqp_windstar_visa_read procedure to read all the information about
the visa into PL/sql t_visa_tab table.
******/

      pqp_windstar_visa_read(t_people_tab            ,
                             t_error_tab             ,
                             'PQP_US_ALIEN_WINDSTAR' ,
                             p_effective_date        ,
                             t_visa_tab              );
      hr_utility.set_location(l_proc, 30);

/*****
call pqp_windstar_balance_read procedure to read all the information about
the balance into PL/sql t_balance_tab table.
******/
      pqp_windstar_balance_read(t_people_tab            ,
                                t_error_tab             ,
                                'PQP_US_ALIEN_WINDSTAR' ,
                                p_effective_date        ,
                                t_balance_tab           );
      hr_utility.set_location(l_proc, 40);

      l_count := t_error_tab.COUNT;

/*****
the following code has been added to consolidate the wf notifications.
tmehra 20-OCT-2003
******/

      for i in 1..l_count
      loop
                   pqp_alien_expat_wf_pkg.StartAlienExpatWFProcess
                      (p_process_event_id => t_error_tab(i).process_event_id,
                       p_tran_type        => 'READ'                 ,
                       p_tran_date        => SYSDATE                ,
                       p_itemtype         => 'PQPALNTF'             ,
                       p_process_name     => 'WIN_PRC'              ,
                       p_alien_transaction_id => null               ,
                       p_assignment_id        => null
                      ) ;
      end loop;

  exception
      when OTHERS then
          hr_utility.set_location('Entering exception:'||l_proc, 50);
          hr_utility.set_message(800, 'DTU10_GENERAL_ORACLE_ERROR');
          hr_utility.set_message_token('2', 'Error in '
              || 'pqp_alien_expat_taxation_pkg.pqp_read_public. Error '
              || 'Code = ' || TO_CHAR(Sqlcode) || ' ' || sqlerrm);
          hr_utility.raise_error;
  end;
  hr_utility.set_location(l_proc, 60);

  begin
  open c_pay_action_parameter;
  l_batch_size := null;
  loop
      fetch c_pay_action_parameter
          into l_batch_size;
      exit when c_pay_action_parameter%notfound;
  end loop;
  p_batch_size := l_batch_size;
  close c_pay_action_parameter;
  hr_utility.set_location('Leaving:'||l_proc, 70);
  exception
      when OTHERS then
      hr_utility.set_location(l_proc, 80);
      p_batch_size := null;
  end;
end pqp_read_public;
/********************************************************************
  name     : update_pay_process_events
  Purpose  : the following function is called from any wrapper script.
             This updates pay_process_events and changes the status.
  Arguments :
    in
      p_person_id           : Person Id
      p_effective_date      : Effective date.
      p_source_type         : source of Request. Normally Windstar
      p_status              : the final status of record being updated. read,
                              DATE_VALIDATION_FAILED etc.
      p_desc                : Description to be appended
    out NOCOPY                     : none
  Notes                     : public
exception HANDLING???
*************************************************************************/
procedure  update_pay_process_events
(
  p_person_id       in  number   ,
  p_effective_date  in  date     ,
  p_source_type     in  varchar2 ,
  p_status          in  varchar2 ,
  p_desc            in  varchar2
)
is
  l_process_event_id      number       ;
  l_object_version_number number       ;
  l_assignment_id         number       ;
  l_description           varchar2(250);
  l_proc              varchar2(72) := g_package||'update_pay_process_events' ;

begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if (pay_process_events_ovn_cursor%isopen = true) then
      close pay_process_events_ovn_cursor;
  end if;
  hr_utility.set_location(l_proc, 10);
  for ppeoc1 in pay_process_events_ovn_cursor(p_person_id     ,
                                              p_source_type   ,
                                              p_effective_date)
  loop
      hr_utility.set_location(l_proc, 20);
      l_process_event_id      := ppeoc1.process_event_id     ;
      l_object_version_number := ppeoc1.object_version_number;
      l_assignment_id         := ppeoc1.assignment_id        ;
      l_description           := ppeoc1.description          ;

      /* Update pay_process_events table */
      pay_ppe_api.update_process_event
      (    p_validate              => false                         ,
           p_status                => p_status                      ,
           p_description           =>
                   SUBSTR('Record Read | '|| p_desc || l_description, 1, 240),
           p_process_event_id      => l_process_event_id            ,
           p_object_version_number => l_object_version_number
      );
      hr_utility.set_location(l_proc, 30);
  end loop;
  hr_utility.set_location('Leaving:'||l_proc, 50);
end update_pay_process_events;
/****************************************************************************
 name      : pqp_windstar_reconcile
 Purpose   : This procedure reconciles data in pay_process_events table.
 Arguments : none
 Notes     : public
****************************************************************************/
procedure pqp_windstar_reconcile(p_assignment_id          in number  ,
                               p_effective_date         in date    ,
                               p_source_type            in varchar ,
                               p_process_event_id      out NOCOPY number  ,
                               p_object_version_number out NOCOPY number  ) is
  cursor c_pay_process_events(p_assignment_id  in number   ,
                              p_effective_date in date     ,
                              p_source_type    in varchar2 ) is
      select process_event_id,
             object_version_number
      from   pay_process_events
      where  assignment_id = p_assignment_id
      and    change_type   = p_source_type
      and    status        in ('R', 'C')
      order  by status asc;

/****
 This cursor will select all the rows for an assignment with a status of read
 or complete. order by asc has been used so that cursor selects all the rows
 with status 'C' first, and then selects all the rows with status = 'R'. in
 reconciliation, we will try to reconcile records with status with 'R' first,
 and then records with status = 'C'. Therefore if pa_process_events table has
 some rows with status = 'R' as well as 'C', then rows with the status = 'R'
 will be fetched in the end. We can this way return the process event Id
 with status 'R'. Otherwise we will return the process event id of a row with
 a status of 'C'.This cursor is to make sure that the assignment exists in
 pay_process_events table.

 Status in 'C' was added on Oct 13, 2000 after discussion with Subbu.
 This will ensure that reconciliation occurs properly.

 --- Nocopy changes. Added the exception block and Nullified the
     the process_event_id. Did not raise the exception since the
     the null process_event_id is being handled in the calling
     procedure and a proper notification is raised indicating
     that the Assignment is not reconciled.
****/

  l_process_event_id      number;
  l_object_version_number number;
  l_proc                varchar2(72) := g_package || 'pqp_windstar_reconcile';
begin
  hr_utility.set_location('Entering ' || l_proc, 10);
  l_process_event_id := null;
  for cppe in c_pay_process_events(p_assignment_id  ,
                                   p_effective_date ,
                                   p_source_type    )
  loop
      hr_utility.set_location(l_proc, 20);
      l_process_event_id      := cppe.process_event_id     ;
      l_object_version_number := cppe.object_version_number;
  end loop;
  hr_utility.set_location('Leaving ' || l_proc, 30);
  p_process_event_id      := l_process_event_id     ;
  p_object_version_number := l_object_version_number;

-- Added by tmehra for nocopy changes Feb'03

exception
  when OTHERS then
     hr_utility.set_location('Entering excep:'||l_proc, 35);
     p_process_event_id := null;
     p_object_version_number := null;

end pqp_windstar_reconcile;


/****************************************************************************
  name      : pqp_write_public
  Purpose   : the procedure write data into PQP_ANALYZED_ALIEN_DATA,
              PQP_ANALYZED_ALIEN_DETAILS, and PQP_ANALYZED_ALIEN_DATA tables.
  Arguments :
    in
  Notes     : public
****************************************************************************/
procedure pqp_write_public
         (p_id                            in number
         ,p_last_name                     in varchar2
         ,p_first_name                    in varchar2
         ,p_middle_names                  in varchar2
         ,p_system_id_number              in number
         ,p_social_security_number        in varchar2
         ,p_institution_indiv_id          in varchar2
         ,p_date_of_birth                 in date
         ,p_taxyear                       in number
         ,p_income_code                   in varchar2
         ,p_withholding_rate              in varchar2
         ,p_scholarship_type              in varchar2
         ,p_exemption_code                in varchar2
         ,p_maximum_benefit               in number
         ,p_retro_lose_on_amount          in number
         ,p_date_benefit_ends             in date
         ,p_retro_lose_on_date            in number
         ,p_residency_status              in varchar2
         ,p_date_becomes_ra               in date
         ,p_target_departure_date         in date
         ,p_date_record_created           in date
         ,p_tax_residence_country_code    in varchar2
         ,p_date_treaty_updated           in date
         ,p_exempt_fica                   in number
         ,p_exempt_student_fica           in number
         ,p_add_wh_for_nra_whennotreaty   in number
         ,p_amount_of_addl_withholding    in number
         ,p_personal_exemption            in varchar2
         ,p_add_exemptions_allowed        in number
         ,p_days_in_usa                   in number
         ,p_eligible_for_whallowance      in number
         ,p_treatybenefits_allowed        in number
         ,p_treatybenefit_startdate       in date
         ,p_ra_effective_date             in date
         ,p_state_code                    in varchar2
         ,p_state_honours_treaty          in number
         ,p_ytd_payments                  in number
         ,p_ytd_w2payments                in number
         ,p_ytd_withholding               in number
         ,p_ytd_whallowance               in number
         ,p_ytd_treaty_payments           in number
         ,p_ytd_treaty_withheld_amts      in number
         ,p_record_source                 in varchar2
         ,p_visa_type                     in varchar2
         ,p_jsub_type                     in varchar2
         ,p_primary_activity              in varchar2
         ,p_nus_countrycode               in varchar2
         ,p_citizenship                   in varchar2
         ,p_constant_additional_tax       in number
         ,p_out_of_system_treaty          in number
         ,p_amount_of_addl_wh_type        in varchar2
         ,p_error_indicator               in varchar2
         ,p_error_text                    in varchar2
         ,p_date_w4_signed                in date
         ,p_date_8233_signed              in date
         ,p_reconcile                     in boolean
         ,p_effective_date                in date
         ,p_current_analysis              in number
         ,p_forecast_income_code          in varchar2
         ,p_error_message                 out nocopy varchar2
          ) is

    t_balance_tab                pqp_alien_expat_taxation_pkg.t_balance_tab_type;
    l_retro_lose_ben_amt_mesg    pqp_alien_transaction_data.ERROR_TEXT%type;
    l_retro_lose_ben_date_mesg   pqp_alien_transaction_data.ERROR_TEXT%type;
    l_income_code_change_mesg    pqp_alien_transaction_data.ERROR_TEXT%type;
    l_current_analysis_mesg      pqp_alien_transaction_data.ERROR_TEXT%type;

    l_windstar_yes               number := -1;
    l_windstar_no                number := 0;
    l_alien_transaction_id       number;
    l_analyzed_data_details_id   number;
    l_assignment_id              number;
    l_object_version_number      number;
    l_analyzed_data_id           number;
    l_batch_size                 number;
    l_person_id                  number;
    l_fed_tax_id                 number;
    l_fed_tax_ovn                number;
    l_transaction_ovn            number;
    l_analyzed_data_ovn          number;
    l_analyzed_det_ovn           number;
    l_process_event_id           number;
    l_process_ovn                number;
    l_atd_ovn                    number;
    l_stat_trans_audit_id        number;
    l_cpa_assignment_id          number;
    l_pri_assgn                  number;
    l_maximum_benefit            number;
    l_withholding_rate           number;
    l_amount_of_addl_withholding number;

    l_personal_exemption         varchar2(1);
    l_treaty_ben_allowed_flag    varchar2(5);
    l_retro_lose_ben_amt_flag    varchar2(5);
    l_retro_lose_ben_date_flag   varchar2(5);
    l_nra_exempt_from_fica       varchar2(5);
    l_student_exempt_from_fica   varchar2(5);
    l_wthldg_allow_eligible_flag varchar2(5);
    l_addl_withholding_flag      varchar2(5);
    l_state_honors_treaty_flag   varchar2(5);
    l_assignment_exists          varchar2(5);
    l_error_indicator            varchar2(30) := 'ERROR';
    l_notification_sent          varchar2(1);
    l_current_analysis           varchar2(5);
    l_forecast_income_code       varchar2(30);

    l_period_type                varchar2(10);
    l_logic_state                varchar2(100);
    l_message                    varchar2(255);
    l_error_message              varchar2(4000);
    l_err_message                varchar2(4000);
    l_retro_lose_ben_amt_flag_old  varchar2(5);
    l_retro_lose_ben_date_flag_old varchar2(5);
    l_additional_amt             number;

    l_eff_w4_date                date;
    l_reco_flag                  boolean;

    l_date_8233_signed           date;

    l_retro_lost                 boolean;
    l_entry_end_date             date;
    l_ppe_status_n_recs          boolean  := false;
    l_proc    constant           varchar2(150) := g_package ||'pqp_write_public';

    cursor c_person_assgn(p_person_id      in number
                         ,p_effective_date in date
                         ,p_source_type    in varchar) is
      select distinct
             paf.assignment_id
        from per_assignments_f  paf,
             pay_process_events ppe
       where paf.person_id = p_person_id
         and paf.effective_start_date <=
             to_date(('12/31/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY')
         and paf.effective_end_date   >=
             to_date(('01/01/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY')
         and paf.effective_start_date =
               (select max(effective_start_date)
                  from per_assignments_f
                 where assignment_id = paf.assignment_id
                   and effective_start_date <=
                       to_date(('12/31/'||to_char(p_effective_date, 'YYYY'))
                               ,'MM/DD/YYYY'
                              )
                )
         and paf.assignment_id = ppe.assignment_id
         and ppe.status        in ( 'R','C')
         and ppe.change_type   = p_source_type;

  -- In the above sql statement (cursor c_person_assgn) the pay_process_events
  -- table is used due to the following reasons.
  --
  -- 1. It will select only those assignments that have a status of read. So if a new
  -- assignment is created for a person, and that assignment is with a status
  -- of NOT_READ, then no record is created in pqp_us_analyzed_data table for
  -- that assignment.
  --
  -- 2. Similarly if an assignment is deleted for a person, then still a record
  -- is created for that assignment in the pqp_us_analyzed_data table for the
  -- reconciliation purposes.
  -- Status = 'c' was added to make sure that we reconcile even those cases that
  -- have already been reconciled. This was added was discussion with Subbu on
  -- Oct 13, 2000. This way if someone reexports data in Windstar, we will not have
  -- any problem.
  --

  --
  -- The following cursor select the person_id for a given SSN
  --
     cursor c_person_ssn(p_social_security_number in varchar2) is
     select person_id
       from per_all_people_f
      where national_identifier = p_social_security_number
        and rownum =1;
  --
  -- The following cursor verifies whether an assignment exists in the given tax
  -- year in pqp_analyzed_alien_data table or not.
  --
     cursor c_assign_exists(p_assignment_id in number
                           ,p_tax_year      in number) is
     select analyzed_data_id
           ,object_version_number
       from pqp_analyzed_alien_data
      where assignment_id = p_assignment_id
        and tax_year      = p_tax_year;
  --
  -- The following cursor verifies whether an income_code exists in
  -- pqp_analyzed_alien_details table for a given analyzed_data_id. The
  -- assumption is that a single row will be present for an income code
  -- for an analyzed_data_id at a point in time.
  --
     cursor c_analyzed_det_exists(p_analyzed_data_id  in number
                                 ,p_income_code       in varchar2 ) is
     select analyzed_data_details_id
           ,object_version_number
           ,retro_lose_ben_amt_flag
           ,retro_lose_ben_date_flag
       from pqp_analyzed_alien_details
      where analyzed_data_id = p_analyzed_data_id
        and income_code      = p_income_code;
  --
  -- Converts Oracle Pay periods to Windstar Pay periods
  --
     cursor c_winstar_oracle_pay_period(p_lookup_code in varchar2) is
     select lookup_code,
            meaning
       from hr_lookups
      where lookup_type = 'PQP_US_WIND_ORA_PERIODS'
        and lookup_code = p_lookup_code ;
  --
  -- The following cursor selects OVN and PK from
  -- PQP_ALIEN_TRANSACTION_DATA table
  --
     cursor c_atd(p_alien_transaction_id in number) is
     select object_version_number
       from pqp_alien_transaction_data
      where alien_transaction_id = p_alien_transaction_id;
  --
  -- The following cursor finds the effective end date for a Person.
  --
     cursor c_person(p_person_id      in number
                    ,p_effective_date in date   ) is
     select MAX(effective_end_date) effective_end_date
       from per_people_f           ppf
           ,per_person_types       ppt
      where ppf.person_id          = p_person_id
        and ppf.person_type_id     = ppt.person_type_id
        and ppt.system_person_type in ('EMP', 'EX_EMP')         -- RLN 7039307
        and ppf.effective_start_date <=
             to_date(('12/31/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY')
        and ppf.effective_end_date   >=
             to_date(('01/01/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY');
  --
  -- The following cursor finds the primary assignment id for a person.
  --
     cursor c_pri_assgn(p_person_id      in number
                       ,p_effective_date in date    ) is
      select distinct
             paf.assignment_id
      from   per_assignments_f  paf
      where  paf.person_id             = p_person_id
      and    paf.effective_start_date <=
               to_date(('12/31/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY')
      and    paf.effective_end_date   >=
               to_date(('01/01/'||to_char(p_effective_date,'YYYY')),'MM/DD/YYYY')
      and    paf.effective_start_date = (select max(effective_start_date)
                                          from   per_assignments_f
                                          where  assignment_id =
                                                             paf.assignment_id
                                           and    effective_start_date <=
                                                         TO_DATE(('12/31/' ||
                           TO_CHAR(p_effective_date, 'YYYY')), 'MM/DD/YYYY'));

  --
  -- The following cursor fetches the latest transaction from
  -- PQP_ALIEN_TRANSACTION_DATA table
  --
   cursor c_get_per_trans(c_person_id number) is
   select patd.date_w4_signed
         ,patd.personal_exemption
         ,patd.addl_exemption_allowed
         ,patd.addl_withholding_amt
         ,patd.constant_addl_tax
         ,patd.current_residency_status
    from pqp_alien_transaction_data patd
   where person_id = c_person_id
     and alien_transaction_id =
        (select MAX(patd1.alien_transaction_id)
           from PQP_ALIEN_TRANSACTION_DATA patd1
          where patd.person_id=patd1.person_id
         having tax_year =max(tax_year)
          group by tax_year);

   l_get_per_trans c_get_per_trans%rowtype;


  --
  -- The following cursor fetches the latest element attached (element entry)
  -- to the person.
  --
   cursor c_get_element(p_person_id      in number
                       ,p_effective_date in date
                       ,p_income_code    in varchar2) is

   select pee.element_entry_id               element_entry_id,
          pet.element_name                   element_name,
          pee.effective_start_date           entry_start_date,
          nvl(pet.element_information1, ' ') element_income_code

     from per_all_assignments_f       paf,
          per_all_people_f            ppf,
          pay_element_entries_f       pee,
          pay_element_links_f         pel,
          pay_element_types_f         pet,
          pay_element_classifications pec

    where paf.person_id            = ppf.person_id
      and paf.business_group_id    = ppf.business_group_id
      and ppf.person_id            = p_person_id
      and pec.classification_name  = 'Alien/Expat Earnings'
      and pet.element_information1 = p_income_code
      and paf.assignment_id        = pee.assignment_id
      and pee.element_link_id      = pel.element_link_id
      and pel.business_group_id    = ppf.business_group_id
      and pel.element_type_id      = pet.element_type_id
      and pet.classification_id    = pec.classification_id
      and p_effective_date between ppf.effective_start_date
                               and ppf.effective_end_date
      and p_effective_date between paf.effective_start_date
                               and paf.effective_end_date
      and p_effective_date between pee.effective_start_date
                               and pee.effective_end_date
      and p_effective_date between pel.effective_start_date
                               and pel.effective_end_date
      and p_effective_Date between pet.effective_start_date
                               and pet.effective_end_date;

   /*
      cursor c_get_element(p_person_id      in number  ,
                        p_effective_date in date    ,
                        p_income_code    in varchar2  ) is
      select pee.element_entry_id element_entry_id,
             pet.element_name element_name,
             pee.effective_start_date entry_start_date,
             NVL(pet.element_information1, ' ') element_income_code
      from   per_assignments_f           paf,
             per_people_f                ppf,
             pay_element_entries_f       pee,
             pay_element_links_f         pel,
             pay_element_types_f         pet,
             pay_element_classifications pec
      where  paf.person_id          =   ppf.person_id
      and    ppf.person_id          =   p_person_id
      and    ppf.effective_start_date <= p_effective_date
      and    ppf.effective_end_date   >= p_effective_date
      and    paf.effective_start_date <= p_effective_date
      and    paf.effective_end_date   >= p_effective_date
      and    paf.assignment_id         = pee.assignment_id
      and   pee.element_link_id            = pel.element_link_id
      and   p_effective_date
                   between pee.effective_start_date
                       and pee.effective_end_date
      and   pel.element_type_id            = pet.element_type_id
      and   p_effective_date
                   between pel.effective_start_date
                       and pel.effective_end_date
      and   pet.classification_id          = pec.classification_id
      and   p_effective_Date
                   between pet.effective_start_date
                       and pet.effective_end_date
      and   pec.classification_name = 'Alien/Expat Earnings'
      and   pet.element_information1 = p_income_code;*/

  --
  -- The following cursor fetches the current residency status
  -- of the person.
  --
   cursor c_person_residency_status(p_person_id in number) is
   select pei_information5       residency_status
         ,person_extra_info_id
     from per_people_extra_info
    where information_type = 'PER_US_ADDITIONAL_DETAILS'
      and person_id = p_person_id;

  --
  -- The following cursor fetches the current pay_process_events records
  -- With status of 'N' or 'D'
  --
   cursor c_pay_process_events(p_assignment_id  in number
                              ,p_source_type    in varchar2) is
   select process_event_id
         ,object_version_number
     from pay_process_events
    where assignment_id = p_assignment_id
      and change_type   = p_source_type
      and status in ('N', 'D');

begin
   hr_utility.set_location('Entering:'||l_proc, 5);
   begin
     l_logic_state := ' while validating data selected from payment_export: ';
     --This loop selects Non read records from payment_export table
     l_error_message             := null;
     pqp_atd_bus.g_error_message := null;
     -- Initialize error message for each iteration.
     l_treaty_ben_allowed_flag    := 'N' ;
     l_retro_lose_ben_amt_flag    := 'N' ;
     l_retro_lose_ben_date_flag   := 'N' ;
     l_nra_exempt_from_fica       := 'N' ;
     l_student_exempt_from_fica   := 'N' ;
     l_wthldg_allow_eligible_flag := 'N' ;
     -- ====================================================
     --  TRANSLATION of FLAGS from -1/0 to Y/N respectively.
     --  ===================================================
     -- All these flags are defaulted to 'NO'. Assumption is that if the value
     -- present in these flags is something other than -1, then it is
     -- considered 0. for example, if a value of 2 is present in any of the
     -- flags then, the value will be treated as 0.
     --
     if (p_retro_lose_on_amount        = l_windstar_yes   ) then
          l_retro_lose_ben_amt_flag := 'Y';
     else
          l_retro_lose_ben_amt_flag := 'N';
     end if;

     if (p_retro_lose_on_date          = l_windstar_yes   ) then
          l_retro_lose_ben_date_flag := 'Y';
     else
          l_retro_lose_ben_date_flag := 'N';
     end if;

     if (p_exempt_fica                 = l_windstar_yes   ) then
          l_nra_exempt_from_fica     := 'Y';
     else
          l_nra_exempt_from_fica     := 'N';
     end if;

     if (p_exempt_student_fica         = l_windstar_yes   ) then
          l_student_exempt_from_fica  := 'Y';
     else
          l_student_exempt_from_fica  := 'N';
     end if;

     if (p_eligible_for_whallowance    = l_windstar_yes   ) then
          l_wthldg_allow_eligible_flag := 'Y';
     else
          l_wthldg_allow_eligible_flag := 'N';
     end if;

     if (p_treatybenefits_allowed      = l_windstar_yes   ) then
          l_treaty_ben_allowed_flag := 'Y';
     else
          l_treaty_ben_allowed_flag := 'N';
     end if;

     if (p_add_wh_for_nra_whennotreaty = l_windstar_yes   ) then
          l_addl_withholding_flag := 'Y';
     else
          l_addl_withholding_flag := 'N';
     end if;

     if (p_state_honours_treaty        = l_windstar_yes   ) then
          l_state_honors_treaty_flag := 'Y';
     else
          l_state_honors_treaty_flag := 'N';
     end if;

     if (p_current_analysis = l_windstar_yes   ) then
          l_current_analysis := 'Y';
     else
          l_current_analysis := 'N';
     end if;
     --
     -- Windstar sends back the forecast_income code only for the
     -- 17, 18 and 19. It sends a null for all other codes.
     --
     if p_forecast_income_code is not null  then
        l_forecast_income_code := p_forecast_income_code || p_scholarship_type;
     end if;

     -- =============================================================
     -- Determination of Person Id from SSN, if Person Id is null
     -- =============================================================
     -- if person_id (That is present in institution_indiv_id field) is present
     -- then, it is take for all computational purposes. But if the person_id
     -- is null, and social security is given, then the SSN is used to
     -- determine the person_id
     --

     l_person_id := null;

     if (p_institution_indiv_id is null) then
         hr_utility.set_location(l_proc, 10);
         if (p_social_security_number is not null) then
             for cps in c_person_ssn(p_social_security_number)
             loop
                l_person_id := cps.person_id ;
             end loop;
         end if;
     else
         l_person_id := p_institution_indiv_id;
     end if;

     if (l_person_id is null) then
         hr_utility.set_location(l_proc, 20);
         l_error_message := l_error_message ||
                                'Person Id could not be determined';
     end if;

     -- =========================================================
     -- Translation of Windstar Pay Periods to ORACLE pay periods
     -- =========================================================

     l_period_type := null;
     if (p_amount_of_addl_wh_type is not null) then
         hr_utility.set_location(l_proc, 30);
         for cwopp in
              c_winstar_oracle_pay_period(p_amount_of_addl_wh_type)
         loop
             l_period_type := cwopp.meaning;
         end loop;
         --
         -- The mapping of pay periond translation is as shown below
         -- +--------------+--------------+----------------+-----------------+
         -- |Windstar Code |  Meaning     | Oracle Payroll | Meaning         |
         -- +--------------+--------------+----------------+-----------------+
         -- | M            | Monthly      | CM             | Calendar Month  |
         -- | W            | Weekly       | W              | Week            |
         -- | S            | Semi Monthly | SM             | Semi-Month      |
         -- | B            | Bi weekly    | F              | Bi-Week         |
         -- | L            | Lump sump    | Y              | Year            |
         -- +--------------+--------------+----------------+-----------------+
         --
         if (l_period_type is null) then
             hr_utility.set_location(l_proc, 40);
             l_error_message := l_error_message || ' Pay Period is Invalid';
             --
             -- l_period_type will be null if the value in
             -- p_addtnl_wthldng_amt_period_type is not either of M, W, S, B, L.
             -- then just update the pqp_us_alien_transaction_data table with
             -- the warning message and still continue with posting in the
             -- pqp_us_analyzed_data and pqp_us_analyzed_details tables
             --
         end if;
      else
          l_error_message := l_error_message || ' Pay Period is NULL';
      end if;
      --
      -- ==========================
      -- Personal Exemption check.
      -- ==========================
      -- The personal exemption should be between 0 and 9 (both inclusive).
      -- ASCII(0) = 48 and ASCII(9) = 57. as per Sirisha the possible
      -- valid values in Personal Exemption field are 0 and 1.
      --
      l_personal_exemption := p_personal_exemption;

      if (ascii(p_personal_exemption)     < 48  or
              ascii(p_personal_exemption) > 49   ) then
          l_error_message := l_error_message || '(' || 'personal_exemption = '
                             || p_personal_exemption || ' is invalid.)';
          hr_utility.set_location(l_proc, 50);
      end if;

      for cpas in c_pri_assgn(l_person_id,
                       to_date('01/01'||to_char(p_taxyear),'DD/MM/YYYY'))
      loop
          hr_utility.set_location(l_proc, 60);
          l_pri_assgn := cpas.assignment_id;
      end loop;

      l_maximum_benefit := p_maximum_benefit;

      if p_date_8233_signed is null then
            l_date_8233_signed := TO_DATE('01/01'||TO_CHAR(p_taxyear),'DD/MM/YYYY');
      else
            l_date_8233_signed := p_date_8233_signed;
      end if;

      l_withholding_rate := nvl(p_withholding_rate,0) / 10;

      l_amount_of_addl_withholding := p_amount_of_addl_withholding / 100;
      --
      -- Required for W4 creation after the insert into the transaction table below
      --
      if (p_date_w4_signed is not null) then
          open c_get_per_trans(l_person_id);
          loop
             fetch c_get_per_trans into l_get_per_trans;
             exit when c_get_per_trans%notfound;
          end loop;
          close c_get_per_trans;
      end if;
      --
      -- Inserting into Alien_transaction_data table
      --
      l_logic_state := ' while inserting in PQP_ALIEN_TRANSACTION_DATA : ';

      pqp_alien_trans_data_api.create_alien_trans_data
      (p_validate                      => false
      ,p_alien_transaction_id          => l_alien_transaction_id
      ,p_data_source_type              => 'PQP_US_ALIEN_WINDSTAR'
      ,p_tax_year                      => p_taxyear
      ,p_income_code                   => p_income_code || p_scholarship_type
      ,p_withholding_rate              => l_withholding_rate
      ,p_income_code_sub_type          => p_scholarship_type
      ,p_forecast_income_code          => l_forecast_income_code
      ,p_exemption_code                => p_exemption_code
      ,p_maximum_benefit_amount        => l_maximum_benefit
      ,p_retro_lose_ben_amt_flag       => l_retro_lose_ben_amt_flag
      ,p_date_benefit_ends             => p_date_benefit_ends
      ,p_retro_lose_ben_date_flag      => l_retro_lose_ben_date_flag
      ,p_current_residency_status      => p_residency_status
      ,p_nra_to_ra_date                => p_date_becomes_ra
      ,p_target_departure_date         => p_target_departure_date
      ,p_tax_residence_country_code    => p_tax_residence_country_code
      ,p_treaty_info_update_date       => p_date_treaty_updated
      ,p_nra_exempt_from_fica          => l_nra_exempt_from_fica
      ,p_student_exempt_from_fica      => l_student_exempt_from_fica
      ,p_addl_withholding_flag         => l_addl_withholding_flag
      ,p_addl_withholding_amt          => p_amount_of_addl_withholding
      ,p_addl_wthldng_amt_period_type  => l_period_type
      ,p_personal_exemption            => l_personal_exemption
      ,p_addl_exemption_allowed        => p_add_exemptions_allowed
      ,p_number_of_days_in_usa         => p_days_in_usa
      ,p_current_analysis              => l_current_analysis
      ,p_wthldg_allow_eligible_flag    => l_wthldg_allow_eligible_flag
      ,p_treaty_ben_allowed_flag       => l_treaty_ben_allowed_flag
      ,p_treaty_benefits_start_date    => p_treatybenefit_startdate
      ,p_ra_effective_date             => p_ra_effective_date
      ,p_state_code                    => p_state_code
      ,p_state_honors_treaty_flag      => l_state_honors_treaty_flag
      ,p_ytd_payments                  => p_ytd_payments
      ,p_ytd_w2_payments               => p_ytd_w2payments
      ,p_ytd_w2_withholding            => p_ytd_withholding
      ,p_ytd_withholding_allowance     => p_ytd_whallowance
      ,p_ytd_treaty_payments           => p_ytd_treaty_payments
      ,p_ytd_treaty_withheld_amt       => p_ytd_treaty_withheld_amts
      ,p_record_source                 => p_record_source
      ,p_visa_type                     => p_visa_type
      ,p_j_sub_type                    => p_jsub_type
      ,p_primary_activity              => p_primary_activity
      ,p_non_us_country_code           => p_nus_countrycode
      ,p_citizenship_country_code      => p_citizenship
      ,p_constant_addl_tax             => p_constant_additional_tax
      ,p_date_8233_signed              => l_date_8233_signed
      ,p_date_w4_signed                => p_date_w4_signed
      ,p_error_indicator               => null
      ,p_prev_er_treaty_benefit_amt    => p_out_of_system_treaty
      ,p_error_text                    => l_error_message
      ,p_object_version_number         => l_transaction_ovn
      ,p_person_id                     => l_person_id
      ,p_effective_date                =>
                       TO_DATE('01/01' || TO_CHAR(p_taxyear), 'DD/MM/YYYY')
       );
      hr_utility.set_location(l_proc, 70);
      if (l_error_message is null and
          pqp_atd_bus.g_error_message is null) then

          hr_utility.set_location(l_proc, 80);
          -- ==============================================
          -- W4 record creation
          -- ==============================================
          -- A W4 record will be created under the following conditions.
          -- 1. no data is present in the PQP_ANALYZED_ALIEN_DATA (This happens
          -- for the first time only),
          -- 2. date_w4_signed field is not null in the
          --    PQP_ALIEN_TRANSACTION_DATA table.
          -- 3. Either of the following values is present
          --    a. personal_exemption is present
          --    b. addl_exemption_allowed
          --    c. addl_withholding_amt
          --    d. constant_addl_tax
          --    a + b is Allowance on Tax screen.
          --    c + d is Additional Tax Amount on screen.
          -- The following changes have been made to the above logic.If the
          -- date_w4_signed is not null the exemption/allowance and the
          -- additional witholding amt fields are updated in the W4 Record.
          -- The additional exemption i.e. (a + b) was not being considered
          -- while updating the exemptions allowed. This is being corrected.
          --
          l_logic_state := ' while updating W4 Info: ';

          if (p_date_w4_signed is not null) then
            --
            -- l_get_per_trans record is populated before the insert
            -- into the transaction table
            --
            if ( l_get_per_trans.date_w4_signed is null
                 or
                (l_get_per_trans.date_w4_signed is not null and
                 p_date_w4_signed <> l_get_per_trans.date_w4_signed)
                 or
                (p_personal_exemption         is not null
                 and p_personal_exemption<>l_get_per_trans.personal_exemption)
                 or
                (p_add_exemptions_allowed     is not null
                 and p_add_exemptions_allowed<>l_get_per_trans.addl_exemption_allowed)
                 or
                (l_amount_of_addl_withholding is not null
                 and l_amount_of_addl_withholding <> l_get_per_trans.addl_withholding_amt)
                 or
                (p_constant_additional_tax    is not null
                 and p_constant_additional_tax<>l_get_per_trans.constant_addl_tax)
                 or
                (p_residency_status = 'R'
		 and l_get_per_trans.addl_withholding_amt <> 0)
                ) then

                for c_person1 in c_person (l_person_id,
                         TO_DATE('01/01/'||TO_CHAR(p_taxyear),'DD/MM/YYYY'))
                loop
                   l_eff_w4_date := c_person1.effective_end_date;
                end loop;

                if (p_residency_status = 'R') then
		   l_additional_amt := 0;
		else
		   l_additional_amt := NVL(l_amount_of_addl_withholding, 0) +
                                       NVL(p_constant_additional_tax,0);
		end if;


                hr_utility.set_location(l_proc, 100);
                pay_us_web_w4.update_alien_tax_records
                -- pay_us_otf_util_web.update_tax_records
               (p_filing_status_code  =>  '01'
               ,p_allowances          => (nvl(p_add_exemptions_allowed, 0) +
                                          nvl(p_personal_exemption,0))
               ,p_additional_amount   => l_additional_amt
			   ,p_exempt_status_code  =>  'N'
               --,p_process           => 'PAY_FED_W4_NOTIFICATION_PRC'
               ,p_process             => 'PAY_OTF_NOTIFY_PRC'
               ,p_itemtype            => 'HRSSA'
               ,p_person_id           => l_person_id
               ,p_effective_date      => p_date_w4_signed
               ,p_source_name         => 'PQP_US_ALIEN_WINDSTAR'
                );

                hr_utility.set_location(l_proc, 110);

            end if;
          end if;
          --
          -- The following cursor gives the assignment_id's of a person. All
          -- the assignments that are active in the year of the effective
          -- date(Tax year) are reported. But that assignment should be present
          -- in pay_process_events table with a status of 'R'.
          --
          l_reco_flag := false;

          if (c_person_assgn%isopen = true) then
              close c_person_assgn;
          end if;

          open c_person_assgn
                  (l_person_id                                          ,
                   TO_DATE('01/01/' || TO_CHAR(p_taxyear), 'DD/MM/YYYY'),
                   'PQP_US_ALIEN_WINDSTAR'
                  );
          fetch c_person_assgn into l_cpa_assignment_id;

          hr_utility.set_location(l_proc, 120);

          if (c_person_assgn%found) then
          loop
            hr_utility.set_location(l_proc, 130);
            -- The following cursor checks whether an assignment exists in
            -- pqp_alien_data table for a given year or not
            --
            l_logic_state := ' while inserting in PQP_ANALYZED_ALIEN_DATA:';

            if (c_assign_exists%isopen = true) then
                close c_assign_exists;
            end if;

            if (c_assign_exists%isopen = true) then
                close c_assign_exists;
            end if;

            open c_assign_exists(l_cpa_assignment_id ,
                                 p_taxyear       );
            --
            -- c_assign_exists checks whether the given assignment exists in
            -- the pqp_analyzed_alien_data_api table for the given year or not
            --
            fetch c_assign_exists into l_analyzed_data_id  ,
                                       l_analyzed_data_ovn ;
            hr_utility.set_location(l_proc, 140);

            if (c_assign_exists%notfound) then

               hr_utility.set_location(l_proc, 150);
               --
               -- if the row does not exist then create a row in
               -- analyzed_alien_data table
               --
               if (c_assign_exists%isopen = true) then
                   close c_assign_exists;
               end if;

               pqp_analyzed_alien_data_api.create_analyzed_alien_data
              (p_validate                    => false
              ,p_analyzed_data_id            => l_analyzed_data_id
              ,p_assignment_id               => l_cpa_assignment_id
              ,p_data_source                 => 'PQP_US_ALIEN_WINDSTAR'
              ,p_tax_year                    => p_taxyear
              ,p_current_residency_status    => p_residency_status
              ,p_nra_to_ra_date              => p_date_becomes_ra
              ,p_target_departure_date       => p_target_departure_date
              ,p_tax_residence_country_code  => p_tax_residence_country_code
              ,p_treaty_info_update_date     => p_date_treaty_updated
              ,p_number_of_days_in_usa       => p_days_in_usa
              ,p_withldg_allow_eligible_flag => l_wthldg_allow_eligible_flag
              ,p_ra_effective_date           => p_ra_effective_date
              ,p_record_source               => p_record_source
              ,p_visa_type                   => p_visa_type
              ,p_j_sub_type                  => p_jsub_type
              ,p_primary_activity            => p_primary_activity
              ,p_non_us_country_code         => p_nus_countrycode
              ,p_citizenship_country_code    => p_citizenship
              ,p_object_version_number       => l_analyzed_data_ovn
              ,p_date_w4_signed              => p_date_w4_signed
              ,p_date_8233_signed            => l_date_8233_signed
              ,p_effective_date              => to_date('01/01/' ||
                                                        p_taxyear, 'DD/MM/YYYY')
               );
               hr_utility.set_location(l_proc, 160);

            else

               hr_utility.set_location(l_proc, 170);

               if (c_assign_exists%isopen = true) then
                      close c_assign_exists;
               end if;
               pqp_analyzed_alien_data_api.update_analyzed_alien_data
              (p_validate                    => false
              ,p_analyzed_data_id            => l_analyzed_data_id
              ,p_assignment_id               => l_cpa_assignment_id
              ,p_data_source                 => 'PQP_US_ALIEN_WINDSTAR'
              ,p_tax_year                    => p_taxyear
              ,p_current_residency_status    => p_residency_status
              ,p_nra_to_ra_date              => p_date_becomes_ra
              ,p_target_departure_date       => p_target_departure_date
              ,p_tax_residence_country_code  => p_tax_residence_country_code
              ,p_treaty_info_update_date     => p_date_treaty_updated
              ,p_number_of_days_in_usa       => p_days_in_usa
              ,p_withldg_allow_eligible_flag => l_wthldg_allow_eligible_flag
              ,p_ra_effective_date           => p_ra_effective_date
              ,p_record_source               => p_record_source
              ,p_visa_type                   => p_visa_type
              ,p_j_sub_type                  => p_jsub_type
              ,p_primary_activity            => p_primary_activity
              ,p_non_us_country_code         => p_nus_countrycode
              ,p_citizenship_country_code    => p_citizenship
              ,p_object_version_number       => l_analyzed_data_ovn
              ,p_date_w4_signed              => p_date_w4_signed
              ,p_date_8233_signed            => l_date_8233_signed
              ,p_effective_date              => to_date('01/01/' ||
                                                        p_taxyear, 'DD/MM/YYYY')
               );

               hr_utility.set_location(l_proc, 180);

            end if;
            --
            -- Alien Details
            --
            l_logic_state := ' while inserting in PQP_ANALYZED_ALIEN_DETAIL: ';

            if (c_analyzed_det_exists%isopen = true) then
               close c_analyzed_det_exists;
            end if;

            open c_analyzed_det_exists(l_analyzed_data_id ,
                                       p_income_code ||p_scholarship_type );
            fetch c_analyzed_det_exists
             into l_analyzed_data_details_id ,
                  l_analyzed_det_ovn,
                  l_retro_lose_ben_amt_flag_old,
                  l_retro_lose_ben_date_flag_old ;

            hr_utility.set_location(l_proc, 190);
            --
            -- The following code raises a notification if the actual income
            -- code is different from the forecast income code. The notification
            -- would be send only if no analyzed data is available for this
            -- income code to avoid sending the notification repeatedly.
            --

            if p_income_code <> p_forecast_income_code then

              if c_analyzed_det_exists%notfound then

                 pqp_alien_trans_data_api.update_alien_trans_data
                (p_validate              => false
                ,p_alien_transaction_id  => l_alien_transaction_id
                ,p_object_version_number => l_transaction_ovn
                ,p_error_indicator       => 'WARNING : CHANGED INCOME CODE'
                ,p_error_text            => 'Changed Income Code'
                ,p_effective_date        => TO_DATE('01/01/' ||
                                                    p_taxyear, 'DD/MM/YYYY')
                 );

                 pqp_alien_expat_wf_pkg.StartAlienExpatWFProcess
                (p_alien_transaction_id  => l_alien_transaction_id
                ,p_assignment_id         => l_pri_assgn
                ,p_tran_type             => 'WRITE'
                ,p_tran_date             =>  SYSDATE
                ,p_itemtype              => 'PQPALNTF'
                ,p_process_name          => 'WIN_PRC'
                ,p_process_event_id      => null
                 ) ;
              end if;

            end if;


            if (c_analyzed_det_exists%notfound) then

                hr_utility.set_location(l_proc, 200);
               if (c_analyzed_det_exists%isopen = true) then
                   close c_analyzed_det_exists;
               end if;

               pqp_analyzed_alien_det_api.create_analyzed_alien_det
              (p_validate                    => false
              ,p_analyzed_data_details_id    => l_analyzed_data_details_id
              ,p_analyzed_data_id            => l_analyzed_data_id
              ,p_income_code                 => p_income_code || p_scholarship_type
              ,p_current_analysis            => l_current_analysis
              ,p_forecast_income_code        => l_forecast_income_code
              ,p_withholding_rate            => l_withholding_rate
              ,p_income_code_sub_type        => p_scholarship_type
              ,p_exemption_code              => p_exemption_code
              ,p_maximum_benefit_amount      => l_maximum_benefit
              ,p_retro_lose_ben_amt_flag     => l_retro_lose_ben_amt_flag
              ,p_date_benefit_ends           => p_date_benefit_ends
              ,p_retro_lose_ben_date_flag    => l_retro_lose_ben_date_flag
              ,p_nra_exempt_from_ss          => l_nra_exempt_from_fica
              ,p_nra_exempt_from_medicare    => l_nra_exempt_from_fica
              ,p_student_exempt_from_ss      => l_student_exempt_from_fica
              ,p_student_exempt_from_medi    => l_student_exempt_from_fica
              ,p_addl_withholding_flag       => null
              ,p_constant_addl_tax           => p_constant_additional_tax
              ,p_addl_withholding_amt        => l_amount_of_addl_withholding
              ,p_addl_wthldng_amt_period_type => null
              ,p_personal_exemption          => p_personal_exemption
              ,p_addl_exemption_allowed      =>p_add_exemptions_allowed
              ,p_treaty_ben_allowed_flag     => l_treaty_ben_allowed_flag
              ,p_treaty_benefits_start_date  => p_treatybenefit_startdate
              ,p_object_version_number       => l_analyzed_det_ovn
              ,p_effective_date              => to_date('01/01/' ||
                                                p_taxyear, 'DD/MM/YYYY')
               );

               hr_utility.set_location(l_proc, 210);

            else

               hr_utility.set_location(l_proc, 220);

               if (c_analyzed_det_exists%isopen = true) then
                  close c_analyzed_det_exists;
               end if;
               --
               -- Changed the above logic on 10-SEP-01 Bug #1891026
               -- Windstar sets the loss_benefit_flag to Y once the
               -- person is analysed. So a new field was introduced
               -- to keep track of the notification sent.
               if (p_ytd_treaty_withheld_amts >= p_maximum_benefit and
                   p_maximum_benefit > 0 and
                   l_retro_lose_ben_amt_flag = 'Y')then
                   l_retro_lost := true;
               elsif trunc(p_date_benefit_ends) <= trunc(sysdate) and
                   l_retro_lose_ben_date_flag = 'Y' then
                   l_retro_lost := true;
               else
                   l_retro_lost := false;
               end if;

               pqp_analyzed_alien_det_api.update_analyzed_alien_det
              (p_validate                  => false                       ,
               p_analyzed_data_details_id  => l_analyzed_data_details_id  ,
               p_analyzed_data_id          => l_analyzed_data_id          ,
               p_income_code               => p_income_code|| p_scholarship_type   ,
               p_current_analysis          => l_current_analysis       ,          -- Oct02 changes
               p_forecast_income_code      => l_forecast_income_code    ,
               p_withholding_rate          => l_withholding_rate        ,
               p_income_code_sub_type      => p_scholarship_type        ,
               p_exemption_code            => p_exemption_code          ,
               p_maximum_benefit_amount    => l_maximum_benefit         ,
               p_retro_lose_ben_amt_flag   => l_retro_lose_ben_amt_flag   ,
               p_date_benefit_ends         => p_date_benefit_ends       ,
               p_retro_lose_ben_date_flag  => l_retro_lose_ben_date_flag  ,
               p_nra_exempt_from_ss        => l_nra_exempt_from_fica      ,
               p_nra_exempt_from_medicare  => l_nra_exempt_from_fica      ,
               p_student_exempt_from_ss    => l_student_exempt_from_fica  ,
               p_student_exempt_from_medi  => l_student_exempt_from_fica  ,
               p_addl_withholding_flag     => null                        ,
               p_constant_addl_tax         => p_constant_additional_tax ,
               p_addl_withholding_amt      => l_amount_of_addl_withholding  ,
               p_addl_wthldng_amt_period_type  => null                     ,
               p_personal_exemption        => p_personal_exemption   ,
               p_addl_exemption_allowed    => p_add_exemptions_allowed,
               p_treaty_ben_allowed_flag   => l_treaty_ben_allowed_flag   ,
               p_treaty_benefits_start_date => p_treatybenefit_startdate ,
               p_object_version_number     => l_analyzed_det_ovn          ,
               p_effective_date            => TO_DATE('01/01/' || p_taxyear, 'DD/MM/YYYY')
               );
               hr_utility.set_location(l_proc, 230);
            end if;

            if l_current_analysis = 'N'  then

               pqp_alien_trans_data_api.update_alien_trans_data
              (p_validate              => false                         ,
               p_alien_transaction_id  => l_alien_transaction_id        ,
               p_object_version_number => l_transaction_ovn             ,
               p_error_indicator       => 'WARNING : INVALID INCOME CODE',
               p_error_text            => 'Invalid Income Code',
               p_effective_date        => TO_DATE('01/01/' ||
                                          p_taxyear, 'DD/MM/YYYY')
               );

               pqp_alien_expat_wf_pkg.StartAlienExpatWFProcess
              (p_alien_transaction_id  => l_alien_transaction_id ,
               p_assignment_id         => l_pri_assgn            ,
               p_tran_type             => 'WRITE'                ,
               p_tran_date             =>  SYSDATE               ,
               p_itemtype              => 'PQPALNTF'             ,
               p_process_name          => 'WIN_PRC'              ,
               p_process_event_id      =>  null
               ) ;

            end if;

            -- Following code sets the residency status codein the person extra
            -- info as per the analysis. Made changes to the following logic
            -- So that no new pay_process_event is logged with the status 'N'.
            -- The code after changing Residency status would go and change the
            -- status from Not-Read to Read in the pay_process_events However if
            -- there is an existing record with a status of 'N' or 'D' the status
            -- would not be changed.

            l_ppe_status_n_recs := false;

            for c_rec in c_pay_process_events (l_cpa_assignment_id,
                                               'PQP_US_ALIEN_WINDSTAR')
            loop
              l_ppe_status_n_recs := true;
            end loop;

            for c_rec in c_person_residency_status(l_person_id)
            loop
              if p_residency_status <> c_rec.residency_status then
                 update per_people_extra_info
                    set pei_information5 = p_residency_status
                  where person_extra_info_id = c_rec.person_extra_info_id;
              end if;
            end loop;

           if l_ppe_status_n_recs = false then

              update pay_process_events
                 set status                = 'R',
                     description           = substr('Record Read | '|| description, 1, 240),
                     object_version_number = object_version_number + 1
               where assignment_id         = l_cpa_assignment_id
                 and status                = 'N'
                 and change_type           = 'PQP_US_ALIEN_WINDSTAR';

              end if;
              --
              -- l_process_event_id is not null if an assignment id exists in the
              -- pay_process_events table with change_type PQP_US_WINSTAR,
              -- staus = read or complete in the given year
              --
              l_process_event_id := null;
              l_process_ovn      := null;
              --
              --  RECONCILIATION STARTS
              --
              l_logic_state := ' while Reconciling: ';

              pqp_windstar_reconcile
             (p_assignment_id         => l_cpa_assignment_id             ,
              p_effective_date        => TO_DATE('01/01/' || p_taxyear,
                                                 'DD/MM/YYYY')   ,
              p_source_type           => 'PQP_US_ALIEN_WINDSTAR'         ,
              p_process_event_id      => l_process_event_id              ,
              p_object_version_number => l_process_ovn
              );
              hr_utility.set_location(l_proc, 240);

              if (l_process_event_id is null and
                  l_reco_flag = false) then

                  hr_utility.set_location(l_proc, 250);
                  -- l_process_event_id will be null if an assignment id does
                  -- not exist in the pay_process_events table for PQP_US_WINSTAR
                  -- or such an assignment exists in the pay_process_events
                  -- table, but the status of such record is not read
                  --
                  pqp_alien_trans_data_api.update_alien_trans_data
                 (p_validate              => false
                 ,p_alien_transaction_id  => l_alien_transaction_id
                 ,p_object_version_number => l_transaction_ovn
                 ,p_error_indicator       =>  'ERROR : NOT_RECONCILED 1'
                 ,p_error_text            => l_error_message ||
                                               'Assignment not Reconciled'
                 ,p_effective_date        => TO_DATE('01/01/' ||
                                                 p_taxyear, 'DD/MM/YYYY')
                  );
                  hr_utility.set_location(l_proc, 260);

                  p_error_message := ' Assignment not Reconciled ';

                  l_reco_flag := true;

                  pqp_alien_expat_wf_pkg.StartAlienExpatWFProcess
                 (p_alien_transaction_id  => l_alien_transaction_id
                 ,p_assignment_id         => l_pri_assgn
                 ,p_tran_type             => 'WRITE'
                 ,p_tran_date             => SYSDATE
                 ,p_itemtype              => 'PQPALNTF'
                 ,p_process_name          => 'WIN_PRC'
                 ,p_process_event_id      => null
                  ) ;

                  hr_utility.set_location(l_proc, 270);

              elsif(l_process_event_id is not null and p_reconcile = true)
                                 then    --ELSE7}{
                  hr_utility.set_location(l_proc, 280);

                  pay_ppe_api.update_process_event
                  (p_validate             => false
                  ,p_change_type          => 'PQP_US_ALIEN_WINDSTAR'
                  ,p_description          => 'Assignment has been Reconciled'
                  ,p_status               => 'C'
                  ,p_process_event_id     => l_process_event_id
                  ,p_object_version_number=> l_process_ovn
                  );
                  hr_utility.set_location(l_proc, 290);
                  --
                  -- There might be other open records with a status of 'R' for
                  -- the same assignment as windstar read process might have
                  -- read it twice. ie. there could be more than one record with
                  -- a status of 'R' and this reconcilation logic changes the
                  -- stauts of only one record to 'C'. Hence updating the
                  -- remaining records to a status of 'C'.
                  --
                  begin
                   update pay_process_events ppe

                      set ppe.status = 'C'
                         ,ppe.description = 'Assignment has been Reconciled'
                         ,ppe.object_version_number =
                              ppe.object_version_number + 1

                    where ppe.assignment_id = l_pri_assgn
                      and change_type = 'PQP_US_ALIEN_WINDSTAR'
                      and ppe.status  = 'R';
                     --
                     hr_utility.set_location(l_proc, 295);
                  end;

                  begin
                     select retro_loss_notification_sent
                       into l_notification_sent
                       from pqp_analyzed_alien_details
                      where analyzed_data_details_id = l_analyzed_data_details_id
                        and analyzed_data_id = l_analyzed_data_id;
                  exception
                   when NO_DATA_FOUND then
                    l_notification_sent := 'Y';
                  end;

                begin
                  if l_retro_lost = true  and
                     NVL(l_notification_sent,'N') = 'N' and
                     NVL(l_current_analysis,'Y' ) = 'Y' then

                    if l_retro_lose_ben_date_flag ='Y' then

                       l_retro_lose_ben_date_mesg
                         := 'This person has exceeded the treaty benefit end date of '
                             ||p_date_benefit_ends;
                       l_retro_lose_ben_date_mesg := l_retro_lose_ben_date_mesg
                        ||' and is now subject to taxes retroactively on all income associated with the code '
                        ||p_income_code||p_scholarship_type;
                       l_retro_lose_ben_date_mesg:= l_retro_lose_ben_date_mesg
                        ||' earned for '||p_taxyear||'.';
                       l_retro_lose_ben_amt_mesg := null;

                    elsif l_retro_lose_ben_amt_flag = 'Y' then


                      if (p_ytd_payments >= p_maximum_benefit) then

                       l_retro_lose_ben_amt_mesg :=
                         'This person has reached the maximum treaty benefit amount limit of '||l_maximum_benefit;
                       l_retro_lose_ben_amt_mesg := l_retro_lose_ben_amt_mesg||
                        ' and may be subject to taxes retroactively on all income associated with the code '
                        ||p_income_code||p_scholarship_type ;
                       l_retro_lose_ben_amt_mesg := l_retro_lose_ben_amt_mesg
                        ||' earned for '||p_taxyear||'.';
                       l_retro_lose_ben_date_mesg := null;
                      end if;

                    end if;

                    pqp_alien_trans_data_api.update_alien_trans_data
                   (p_validate              => false
                   ,p_alien_transaction_id  => l_alien_transaction_id
                   ,p_object_version_number => l_transaction_ovn
                   ,p_error_indicator       => 'WARNING : RETRO LOSS'
                   ,p_error_text            => NVL(l_retro_lose_ben_date_mesg
                                                  ,l_retro_lose_ben_amt_mesg)
                   ,p_effective_date        => TO_DATE('01/01/' ||
                                                        p_taxyear, 'DD/MM/YYYY')
                    );

                    pqp_alien_expat_wf_pkg.StartAlienExpatWFProcess
                   (p_alien_transaction_id  => l_alien_transaction_id
                   ,p_assignment_id         => l_pri_assgn
                   ,p_tran_type             => 'WRITE'
                   ,p_tran_date             =>  SYSDATE
                   ,p_itemtype              => 'PQPALNTF'
                   ,p_process_name          => 'WIN_PRC'
                   ,p_process_event_id      => null
                    ) ;
                    -- Update table to set the flag notification_sent = 'Y'
                    pqp_analyzed_alien_det_api.update_analyzed_alien_det
                   (p_validate                     => false
                   ,p_analyzed_data_details_id     => l_analyzed_data_details_id
                   ,p_analyzed_data_id             => l_analyzed_data_id
                   ,p_effective_date               => TO_DATE('01/01/' ||
                                                      p_taxyear, 'DD/MM/YYYY')
                   ,p_retro_loss_notification_sent => 'Y'
                   ,p_object_version_number        => l_transaction_ovn
                    );

                    hr_utility.set_location(l_proc, 296);
                end if;

               end;
               -- Workflow Notification: The control will come to this point
               -- only if no error was encountered above or the control will
               -- pass to Error block.
               -- RECONCILIATION ENDS

              end if;
              fetch c_person_assgn
               into l_cpa_assignment_id;

              exit when c_person_assgn%notfound;
          end loop;

          else
              hr_utility.set_location(l_proc, 300);
              -- Means no assignment with read/complete status was present in
              --  pay_process_events table
              pqp_alien_trans_data_api.update_alien_trans_data
             (p_validate              => false
             ,p_alien_transaction_id  => l_alien_transaction_id
             ,p_object_version_number => l_transaction_ovn
             ,p_error_indicator       =>  'ERROR : NOT_RECONCILED 2'
             ,p_error_text            => l_error_message||'Assignment not Reconciled'
             ,p_effective_date        => TO_DATE('01/01/'||p_taxyear, 'DD/MM/YYYY')
              );
              hr_utility.set_location(l_proc, 310);

              p_error_message := ' Assignment not Reconciled ';

              pqp_alien_expat_wf_pkg.StartAlienExpatWFProcess
             (p_alien_transaction_id  => l_alien_transaction_id ,
              p_assignment_id         => l_pri_assgn            ,
              p_tran_type             => 'WRITE'                ,
              p_tran_date             => SYSDATE                ,
              p_itemtype              => 'PQPALNTF'             ,
              p_process_name          => 'WIN_PRC'              ,
              p_process_event_id      => null
              ) ;
              hr_utility.set_location(l_proc, 320);

          end if;
          close c_person_assgn;
      else
          hr_utility.set_location(l_proc, 330);
          p_error_message := l_error_message ||pqp_atd_bus.g_error_message;

          pqp_alien_expat_wf_pkg.StartAlienExpatWFProcess
         (p_alien_transaction_id  => l_alien_transaction_id ,
          p_assignment_id         => l_pri_assgn            ,
          p_tran_type             => 'WRITE'                ,
          p_tran_date             => SYSDATE                ,
          p_itemtype              => 'PQPALNTF'             ,
          p_process_name          => 'WIN_PRC'              ,
          p_process_event_id      => null
          ) ;
          hr_utility.set_location(l_proc, 340);
      end if;
  exception
      when OTHERS then
       hr_utility.set_location(l_proc, 350);
       l_atd_ovn := null;
       l_error_message := l_error_message ||TO_CHAR(SQLCODE) ||
                          SQLERRM ||l_logic_state;
       p_error_message := p_error_message || l_error_message;

       for c1 in c_atd(l_alien_transaction_id)
       loop
         l_atd_ovn := c1.object_version_number;
       end loop;

       if (l_atd_ovn is not null) then

           hr_utility.set_location(l_proc, 360);

           pqp_alien_trans_data_api.update_alien_trans_data
          (p_validate              => false
          ,p_alien_transaction_id  => l_alien_transaction_id
          ,p_object_version_number => l_atd_ovn
          ,p_error_indicator       =>  'ERROR : ORACLE'
          ,p_error_text            => l_error_message
          ,p_effective_date        => to_date('01/01/' ||
                                              p_taxyear, 'DD/MM/YYYY')
           );

          hr_utility.set_location(l_proc, 370);

          pqp_alien_expat_wf_pkg.StartAlienExpatWFProcess
         (p_alien_transaction_id => l_alien_transaction_id
         ,p_assignment_id         => l_pri_assgn
         ,p_tran_type             => 'WRITE'
         ,p_tran_date             => sysdate
         ,p_itemtype              => 'PQPALNTF'
         ,p_process_name          => 'WIN_PRC'
         ,p_process_event_id      => null
          );

          hr_utility.set_location(l_proc, 380);
       end if;
  end;

  hr_utility.set_location('Leaving ' || l_proc, 390);

exception
  when others then
     hr_utility.set_location('Entering excep:'||l_proc, 395);
     p_error_message := p_error_message || sqlerrm;

end pqp_write_public;

-- =============================================================================
--  Name      : pqp_batch_size
--  Purpose   : the procedure returns the batch size.
--  Arguments :
--    Out     : p_batch_size
--  Notes     : private
-- =============================================================================
procedure pqp_batch_size
         (p_batch_size out NOCOPY number
          ) is

   l_batch_size    number;
   l_proc constant varchar2(72) := g_package || 'pqp_batch_size';

begin
   hr_utility.set_location('Entering :' || l_proc, 10);

   if (c_pay_action_parameter%isopen = true) then
      close c_pay_action_parameter;
   end if;

   open c_pay_action_parameter;
   l_batch_size := null;
   loop
       fetch c_pay_action_parameter
           into l_batch_size;
       exit when c_pay_action_parameter%notfound;
   end loop;
   close c_pay_action_parameter;

   hr_utility.set_location(l_proc, 20);

   p_batch_size := l_batch_size;

   if (l_batch_size is null) then
       p_batch_size := null;
   end if;

   hr_utility.set_location('Leaving : ' || l_proc, 30);

exception
  when OTHERS then
     hr_utility.set_location('Entering excep:'||l_proc, 35);
     p_batch_size := null;

end pqp_batch_size;

-- =============================================================================
--  Name      : ResetForReadAPI
--  Purpose   : This resets the status in pay_process_events table back to 'N'.
--  Arguments :
--    IN      : p_process_event_id
--  Notes     : public
-- =============================================================================
procedure ResetForReadAPI
         (p_process_event_id in number
          ) is

    l_ovn           number;
    l_proc constant varchar2(72) := g_package || 'ResetForReadAPI';

begin
    l_ovn  := -1;
    hr_utility.set_location('Entering:'||l_proc, 5);

    for cop in c_ovn_ppe(p_process_event_id)
    loop
        l_ovn := cop.object_version_number;
    end loop;
    if (l_ovn is not null and l_ovn <> -1) then

        hr_utility.set_location(l_proc, 10);

        pay_ppe_api.update_process_event
       (p_validate              => false
       ,p_status                => 'N'
       ,p_description           => null
       ,p_process_event_id      => p_process_event_id
       ,p_object_version_number => l_ovn
        );

    end if;

    hr_utility.set_location('Leaving:'||l_proc, 20);

end ResetForReadAPI;

-- =============================================================================
-- Name      : AbortReadAPI
-- Purpose   : This resets the status in pay_process_events table to 'C'.
-- Arguments :
--    IN     : p_process_event_id
-- Notes     : public
-- =============================================================================
procedure AbortReadAPI
         (p_process_event_id in number
          ) is

    l_ovn  number;
    l_proc constant varchar2(72) := g_package || 'AbortReadAPI';

begin

    hr_utility.set_location('Entering:'||l_proc, 5);

    for cop in c_ovn_ppe(p_process_event_id)
    loop
        l_ovn := cop.object_version_number;
    end loop;

    if (l_ovn is not null and l_ovn <> -1) then

        hr_utility.set_location(l_proc, 10);

        pay_ppe_api.update_process_event
       (p_validate              => false
       ,p_status                => 'C'
       ,p_description           => 'This record was forcibly ABORTED using workflow'
       ,p_process_event_id      => p_process_event_id
       ,p_object_version_number => l_ovn
        );

    end if;

    hr_utility.set_location('Leaving:' ||l_proc, 20);

end AbortReadAPI;


end pqp_alien_expat_taxation_pkg;

/
