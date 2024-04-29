--------------------------------------------------------
--  DDL for Package Body PAY_GBATGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GBATGN" as
/* $Header: pygbatgn.pkb 115.1 99/07/17 06:07:32 porting sh $ */
   procedure insert_gb_dimensions is
      x number;
      procedure my_dimension_insert ( p_route_id             number,
                                      p_payments_flag        varchar2,
                                      p_database_item_suffix varchar2,
                                      p_dimension_name       varchar2,
                                      p_dimension_type       varchar2,
                                      p_description          varchar2,
                                      p_feed_checking_code   varchar2,
                                      p_expiry_checking_level varchar2,
                                      p_expiry_checking_code varchar2) is
      begin
         hr_utility.trace('p_dimension_name is ' || p_dimension_name);
         x := pay_db_balances_pkg.create_balance_dimension
                     (p_legislation_code => 'GB',
                      p_route_id => p_route_id,
                      p_database_item_suffix => p_database_item_suffix,
                      p_dimension_name  => p_dimension_name,
                      p_dimension_type  => p_dimension_type,
                      p_description => p_description,
                      p_feed_checking_code => p_feed_checking_code,
                      p_payments_flag => p_payments_flag,
                      p_expiry_checking_code => p_expiry_checking_code,
                      p_expiry_checking_level => p_expiry_checking_level);
      end my_dimension_insert;
      function do_child_inserts return number is
         x number;
      begin
      --
      --  insert row into ff_route_context_usages
      --
         hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',20);
         insert into ff_route_context_usages
         (route_id,
          context_id,
          sequence_no)
         select ff_routes_s.currval,
                CON.context_id,
                1
         from   ff_contexts CON
         where  CON.context_name = 'ASSIGNMENT_ACTION_ID';
      --
      --    insert row into ff_route_parameters
      --
         hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',30);
         insert into ff_route_parameters
         (route_parameter_id,
          route_id,
          sequence_no,
          parameter_name,
          data_type)
         values
         (ff_route_parameters_s.nextval,
          ff_routes_s.currval,
          1,
          'Balance Type ID',
          'N');
         hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',40);
         select ff_routes_s.currval into x from dual;
      --
         return x;
      --
      end do_child_inserts;
   begin
--    Insert row in FF_ROUTES for this dimension
hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',1);
insert into ff_routes
(route_id,
 user_defined_flag,
 route_name,
 description,
 text)
values
(ff_routes_s.nextval,
 'N',
 'GB Person-level Tax Year to Date Balance Dimension',
 'Summed data for the PERSON-LEVEL GB TAX YEAR TO DATE balance dimension',
'        pay_balance_feeds_f     FEED
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      BACT
       ,pay_assignment_actions   BAL_ASSACT
       ,per_assignments_f         ASS
       ,per_assignments_f         START_ASS
where  BAL_ASSACT.assignment_action_id = &B1
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = &U1
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in (''P'',''PA'')
and    PACT.effective_date >=
          (select to_date(''06-04-'' || to_char( fnd_number.canonical_to_number(
                  to_char( BACT.effective_date,''YYYY''))
           +  decode(sign( BACT.effective_date - to_date(''06-04-''
               || to_char(BACT.effective_date,''YYYY''),''DD-MM-YYYY'')),
	   -1,-1,0)),''DD-MM-YYYY'')
           from dual)
and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
and    START_ASS.assignment_id = BAL_ASSACT.assignment_id
and    ASS.period_of_service_id = START_ASS.period_of_service_id
and    ASSACT.assignment_id = ASS.assignment_id
and    BACT.effective_date between
          ASS.effective_start_date and ASS.effective_end_date
and    PACT.effective_date between
          START_ASS.effective_start_date and START_ASS.effective_end_date');
--
--  now insert rows into ff_route_context_usages and ff_route_parameters
--  and load variable with the current route_id
--
   x := do_child_inserts;
--
--    now insert row into pay_balance_dimensions
--
   my_dimension_insert(x,
    'N',
    '_YTD',
    'Person-level GB Tax Year to Date',
    'P',
    'Summed data for all a person''s assignments in the GB tax year',
    'l_feed_flag = 1;',   -- always feed
    'P',                  -- expiry check at payroll action level
    'declare
   l_tax_year_start  date;
begin
   --   get start of the current tax year
   select to_date(''06-04-'' || to_char( fnd_number.canonical_to_number(
          to_char( l_user_effective_date,''YYYY''))
             +  decode(sign( l_user_effective_date - to_date(''06-04-''
                 || to_char(l_user_effective_date,''YYYY''),''DD-MM-YYYY'')),
	   -1,-1,0)),''DD-MM-YYYY'')
   into l_tax_year_start
   from dual;
   --   see if balance was written in this tax year. If not, it''s expired.
   if l_owner_effective_date >= l_tax_year_start then
      l_dimension_expired := 0;
   else
      l_dimension_expired := 1;
   end if;
end;'
   );
--    Insert row in FF_ROUTES for this dimension
hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',2);
insert into ff_routes
(route_id,
 user_defined_flag,
 route_name,
 description,
 text)
values
(ff_routes_s.nextval,
 'N',
 'GB Assignment-level Tax Year to Date Balance Dimension',
 'Summed data for the ASSIGNMENT-LEVEL GB TAX YEAR TO DATE balance dimension',
'        pay_balance_feeds_f     FEED
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      BACT
       ,pay_assignment_actions   BAL_ASSACT
where  BAL_ASSACT.assignment_action_id = &B1
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = &U1
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in (''P'',''PA'')
and    PACT.effective_date >=
          (select to_date(''06-04-'' || to_char( fnd_number.canonical_to_number(
                  to_char( BACT.effective_date,''YYYY''))
           +  decode(sign( BACT.effective_date - to_date(''06-04-''
               || to_char(BACT.effective_date,''YYYY''),''DD-MM-YYYY'')),
	   -1,-1,0)),''DD-MM-YYYY'')
           from dual)
and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
and    ASSACT.assignment_id = BAL_ASSACT.assignment_id');
--
--  now insert rows into ff_route_context_usages and ff_route_parameters
--  and load variable with the current route_id
--
   x := do_child_inserts;
--
--    now insert row into pay_balance_dimensions
--
   my_dimension_insert(x,
    'N',
    '_AYTD',
    'Assignment-level GB Tax Year to Date',
    'A',
    'Summed data for a single assignment in the GB tax year',
    null,                 --  always feed (no code)
    'P',
    'declare
   l_tax_year_start  date;
begin
   --   get start of the current tax year
   select to_date(''06-04-'' || to_char( fnd_number.canonical_to_number(
          to_char( l_user_effective_date,''YYYY''))
             +  decode(sign( l_user_effective_date - to_date(''06-04-''
                 || to_char(l_user_effective_date,''YYYY''),''DD-MM-YYYY'')),
	   -1,-1,0)),''DD-MM-YYYY'')
   into l_tax_year_start
   from dual;
   --   see if balance was written in this tax year. If not, it''s expired.
   if l_owner_effective_date >= l_tax_year_start then
      l_dimension_expired := 0;
   else
      l_dimension_expired := 1;
   end if;
end;'
   );
--    Insert row in FF_ROUTES for this dimension
hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',3);
insert into ff_routes
(route_id,
 user_defined_flag,
 route_name,
 description,
 text)
values
(ff_routes_s.nextval,
 'N',
 'GB Person-level Period to Date Balance Dimension',
 'Summed data for the PERSON-LEVEL PERIOD TO DATE balance dimension',
'        pay_balance_feeds_f     FEED
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      BACT
       ,pay_assignment_actions   BAL_ASSACT
       ,per_assignments_f         ASS
       ,per_assignments_f         START_ASS
where  BAL_ASSACT.assignment_action_id = &B1
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = &U1
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in (''P'',''PA'')
and    PACT.effective_date >=
          (select start_date from per_time_periods PTP
           where BACT.effective_date
              between PTP.start_date and PTP.end_date
          )
and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
and    START_ASS.assignment_id = BAL_ASSACT.assignment_id
and    ASS.period_of_service_id = START_ASS.period_of_service_id
and    ASSACT.assignment_id = ASS.assignment_id
and    BACT.effective_date between
          ASS.effective_start_date and ASS.effective_end_date
and    PACT.effective_date between
          START_ASS.effective_start_date and START_ASS.effective_end_date');
--
--  now insert rows into ff_route_context_usages and ff_route_parameters
--  and load variable with the current route_id
--
   x := do_child_inserts;
--
--    now insert row into pay_balance_dimensions
--
   my_dimension_insert(x,
    'N',
    '_PTD',
    'Person-level Period to Date',
    'P',
   'Summed data for all a person''s assignments in the current earnings period',
    null,    -- always feed
    'P',     -- expiry check at Payroll Action level
    'declare
   l_period_start_date date;
begin
   --  find start date of the current period
   select start_date
   into   l_period_start_date
   from   per_time_periods TP,
          pay_payroll_actions PACT
   where  PACT.payroll_action_id = l_user_payroll_action_id
   and    PACT.payroll_id = TP.payroll_id
   and    l_user_effective_date between TP.start_date and TP.end_date;
   --   see if balance was written in this tax year. If not, it''s expired.
   if l_owner_effective_date >= l_period_start_date then
      l_dimension_expired := 0;
   else
      l_dimension_expired := 1;
   end if;
end;'
   );
--    Insert row in FF_ROUTES for this dimension
hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',4);
insert into ff_routes
(route_id,
 user_defined_flag,
 route_name,
 description,
 text)
values
(ff_routes_s.nextval,
 'N',
 'GB Assignment-level Period to Date Balance Dimension',
 'Summed data for the ASSIGNMENT-LEVEL PERIOD TO DATE balance dimension',
'        pay_balance_feeds_f     FEED
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      BACT
       ,pay_assignment_actions   BAL_ASSACT
where  BAL_ASSACT.assignment_action_id = &B1
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = &U1
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in (''P'',''PA'')
and    PACT.effective_date >=
          (select start_date from per_time_periods PTP
           where BACT.effective_date
              between PTP.start_date and PTP.end_date
          )
and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
and    ASSACT.assignment_id = BAL_ASSACT.assignment_id');
--
--  now insert rows into ff_route_context_usages and ff_route_parameters
--  and load variable with the current route_id
--
   x := do_child_inserts;
--
--    now insert row into pay_balance_dimensions
--
   my_dimension_insert(x,
    'N',
    '_APTD',
    'Assignment-level Period to Date',
    'A',
    'Summed data for a single assignment in the current earnings period',
    null,    -- always feed
    'P',     -- expiry check at Payroll Action level
    'declare
   l_period_start_date date;
begin
   --  find start date of the current period
   select start_date
   into   l_period_start_date
   from   per_time_periods TP,
          pay_payroll_actions PACT
   where  PACT.payroll_action_id = l_user_payroll_action_id
   and    PACT.payroll_id = TP.payroll_id
   and    l_user_effective_date between TP.start_date and TP.end_date;
   --   see if balance was written in this tax year. If not, it''s expired.
   if l_owner_effective_date >= l_period_start_date then
      l_dimension_expired := 0;
   else
      l_dimension_expired := 1;
   end if;
end;'
   );
--    Insert row in FF_ROUTES for this dimension
hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',5);
insert into ff_routes
(route_id,
 user_defined_flag,
 route_name,
 description,
 text)
values
(ff_routes_s.nextval,
 'N',
 'GB Person-level User Cleared Balance Dimension',
 'Summed data for the PERSON-LEVEL USER CLEARED balance dimension',
'        pay_balance_feeds_f     FEED
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      BACT
       ,pay_assignment_actions   BAL_ASSACT
       ,per_assignments_f         ASS
       ,per_assignments_f         START_ASS
where  BAL_ASSACT.assignment_action_id = &B1
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = &U1
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in (''P'',''PA'')
and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
and    START_ASS.assignment_id = BAL_ASSACT.assignment_id
and    ASS.period_of_service_id = START_ASS.period_of_service_id
and    ASSACT.assignment_id = ASS.assignment_id
and    BACT.effective_date between
          ASS.effective_start_date and ASS.effective_end_date
and    PACT.effective_date between
          START_ASS.effective_start_date and START_ASS.effective_end_date');
--
--  now insert rows into ff_route_context_usages and ff_route_parameters
--  and load variable with the current route_id
--
   x := do_child_inserts;
--
--    now insert row into pay_balance_dimensions
--
   my_dimension_insert(x,
    'N',
    '_USER',
    'Person-level User Cleared',
    'P',
    'Summed data for all a person''s assignments since last cleared down',
    null,   -- always feed
    'P',    -- expiry check at Payroll Action level
    'l_dimension_expired := 0;'    --  never expires
   );
--    Insert row in FF_ROUTES for this dimension
hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',6);
insert into ff_routes
(route_id,
 user_defined_flag,
 route_name,
 description,
 text)
values
(ff_routes_s.nextval,
 'N',
 'GB Assignment-level User Cleared Balance Dimension',
 'Summed data for the ASSIGNMENT-LEVEL USER CLEARED balance dimension',
'        pay_balance_feeds_f     FEED
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      BACT
       ,pay_assignment_actions   BAL_ASSACT
where  BAL_ASSACT.assignment_action_id = &B1
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = &U1
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in (''P'',''PA'')
and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
and    ASSACT.assignment_id = BAL_ASSACT.assignment_id');
--
--  now insert rows into ff_route_context_usages and ff_route_parameters
--  and load variable with the current route_id
--
   x := do_child_inserts;
--
--    now insert row into pay_balance_dimensions
--
   my_dimension_insert(x,
    'N',
    '_AUSER',
    'Assignment-level User Cleared',
    'P',
    'Summed data for a single assignment since last cleared down',
    null,   -- always feed
    'P',    -- expiry check at Payroll Action level
    'l_dimension_expired := 0;'    --  never expires
   );
--    Insert row in FF_ROUTES for this dimension
hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',7);
insert into ff_routes
(route_id,
 user_defined_flag,
 route_name,
 description,
 text)
values
(ff_routes_s.nextval,
 'N',
 'GB Assignment-level Current Run Balance Dimension',
 'Summed data for the ASSIGNMENT-LEVEL CURRENT RUN balance dimension',
'        pay_balance_feeds_f     FEED
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
where  ASSACT.assignment_action_id = &B1
and    FEED.balance_type_id    = &U1
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in (''P'',''PA'')
and    ASSACT.assignment_id = BAL_ASSACT.assignment_id');
--
--  now insert rows into ff_route_context_usages and ff_route_parameters
--  and load variable with the current route_id
--
   x := do_child_inserts;
--
--    now insert row into pay_balance_dimensions
--
   my_dimension_insert(x,
    'N',
    '_RUN',
    'Assignment-level Current Run',
    'F',
    'Summed data for an assignment within a run',
    null,   --  always feed
    null,   --  never stored, no expiry details needed
    null   --  never stored, no expiry details needed
   );
--    Insert row in FF_ROUTES for this dimension
hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',8);
insert into ff_routes
(route_id,
 user_defined_flag,
 route_name,
 description,
 text)
values
(ff_routes_s.nextval,
 'N',
 'GB Person-level Contracted In YTD Balance Dimension',
 'Summed data for the PERSON-LEVEL CONTRACTED IN YTD balance dimension',
'        pay_balance_feeds_f     FEED
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      BACT
       ,pay_assignment_actions   BAL_ASSACT
       ,per_assignments_f         ASS
       ,per_assignments_f         START_ASS
where  BAL_ASSACT.assignment_action_id = &B1
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = &U1
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in (''P'',''PA'')
and    START_ASS.assignment_id = BAL_ASSACT.assignment_id
and    ASS.period_of_service_id = START_ASS.period_of_service_id
and    ASSACT.assignment_id = ASS.assignment_id
and    nvl(ASS.ass_attribute1, ''CI'') = ''CI''
and    BACT.effective_date between
          ASS.effective_start_date and ASS.effective_end_date
and    PACT.effective_date between
          START_ASS.effective_start_date and START_ASS.effective_end_date');
--
--  now insert rows into ff_route_context_usages and ff_route_parameters
--  and load variable with the current route_id
--
   x := do_child_inserts;
--
--    now insert row into pay_balance_dimensions
--
   my_dimension_insert(x,
    'N',
    '_CI_YTD',
    'Person-level Contracted In YTD',
    'P',
  'Summed data for all a person''s contracted-in assignments (in GB tax year)',
  'declare
ni_status varchar2;
begin
   --   by default, assignments without a category are considered CI
   select nvl(ass_attribute1, ''CI'')
   into   ni_status
   from   per_assignments_f
   where  assignment_id = l_assignment_id
   and    l_effective_date between
                effective_start_date and effective_end_date;
   if ni_status = ''CI'' then
      l_feed_flag := 1;
   else
      l_feed_flag := 0;
   end if;
end;',
    'P',
    'declare
   l_tax_year_start  date;
begin
   --   get start of the current tax year
   select to_date(''06-04-'' || to_char( fnd_number.canonical_to_number(
          to_char( l_user_effective_date,''YYYY''))
             +  decode(sign( l_user_effective_date - to_date(''06-04-''
                 || to_char(l_user_effective_date,''YYYY''),''DD-MM-YYYY'')),
	   -1,-1,0)),''DD-MM-YYYY'')
   into l_tax_year_start
   from dual;
   --   see if balance was written in this tax year. If not, it''s expired.
   if l_owner_effective_date >= l_tax_year_start then
      l_dimension_expired := 0;
   else
      l_dimension_expired := 1;
   end if;
end;'
   );
--    Insert row in FF_ROUTES for this dimension
hr_utility.set_location('pay_gbatgn.insert_gb_dimensions',9);
insert into ff_routes
(route_id,
 user_defined_flag,
 route_name,
 description,
 text)
values
(ff_routes_s.nextval,
 'N',
 'GB Payments Balance Dimension',
 'Summed data for the PAYMENTS balance dimension',
'        pay_balance_feeds_f     FEED
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
       ,pay_action_interlocks     INTLK
       ,pay_payroll_actions      BACT
       ,pay_assignment_actions   BAL_ASSACT
where  BAL_ASSACT.assignment_action_id = &B1
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = &U1
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in (''P'',''PA'')
and    ASSACT.assignment_action_id = INTLK.locked_action_id
and    INTLK.locking_action_id = BAL_ASSACT.assignment_action_id
and    BACT.action_type = ''P''
and    ASSACT.assignment_id = BAL_ASSACT.assignment_id');
--
--  now insert rows into ff_route_context_usages and ff_route_parameters
--  and load variable with the current route_id
--
   x := do_child_inserts;
--
--    now insert row into pay_balance_dimensions
--
   my_dimension_insert(x,
    'Y',
    '_PAYMENTS',
    'Payments',
    'N',
  'Summed data for all an assignments runs being handled within a payment run',
    null,     --  never held or stored
    null,     --  never held or stored
    null      --  never held or stored
   );
   end insert_gb_dimensions;
end pay_gbatgn;

/
