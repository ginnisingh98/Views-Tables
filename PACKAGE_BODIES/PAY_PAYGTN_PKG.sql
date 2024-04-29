--------------------------------------------------------
--  DDL for Package Body PAY_PAYGTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYGTN_PKG" AS
/* $Header: pypaygtn.pkb 120.10.12010000.7 2009/03/04 09:44:27 skpatil ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package defines the cursors needed for GTN to run Multi-Threaded
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   21-NOV-1999  ssarma      40.0   created
--
   15-JUN-2000  tclewis     115.1  Modified the action_cursor to use the
                                   gross_earnings_asg_gre_run balance instead
                                   or the payment_asg_gre_run balance.  Reason
                                   payroll runs with 0 net earnings were not showing
                                   up on the report.  Added code to check the
                                   paymest_asg_gre_run balance if the balance for
                                   gross_earnings_asg_gre_run is 0.  This is to
                                   fix a problem where non payroll payments
                                   are not picked up if that is the only element
                                   processed in the payroll run.

   15-JUN-2000  tclewis     115.1  Changed the checks for gross earnings and net pay
                                   to look for a non zero run result instead.  This is
                                   a fix for bug 2327399, in which the report is missing
                                   0 earnings payroll actions.

   03-JUL-2002 tclewis      115.4  Changed the check for non zero run results for
                                   earnings elements to check no non zero run results
                                   for element type.
   06-AUG-2002 rmonge      115.5  Modified the Action_type to varchar2(30).
                                  bug 2447123
   21-oct-2002 tclewis     115.7   removed the "for Update... " in the action_creation
                                   code.
   04-Feb-2004 schauhan    115.8  Modified the query for the cursors c_actions and
                                  c_parameters to reduce the cost of the cursor query
                                  c_actions.Bug 3364759
   04-May-2004 irgonzal    115.9  Bug fix 3270485. Added logic to range_cursor
                                  procedure to ensure the "header information" gets
                                  inserted into pay_us_rpt_totals.
   01-Oct-2004 saurgupt    115.10 Bug 3679305: Modified the procedure range_cursor. Changed the sqlstr
                                  to improve performance.
   05-Oct-2004 saurgupt    115.11 Bug 3679305: Modified the procedure range_cursor. Changed the sqlstr.
                                  Added the new variable l_payroll_test to improve performance.
   09-Dec-2004 sgajula     115.12 Added action_create_bra,archive_init,archive_code,archive_deinit
                                  for implementing BRA.
   15-MAR-2005 sdhole      115.13 Bug No.4237962,  Removed ppa_run.action_status = 'C'
                                  from range_cursor, action_creation and action_create_bra.
   26-Aug-2005 sackumar    115.14 Bug No.4344971, Introduced a new condition in sql present in
                                  action_create_bra and action_create functions to remove
                                  the Merge Cartesian join .
   30-Aug-2005 sackumar    115.15 Introduced Index Hint in get_futa_def_bal_id cursor in
                                  ARCHIVE_INIT procedure.
   12-SEP-2005 pragupta    115.16 Bug 453407: Added an extra condition in the p_er_liab_where
                                  variable to avoid duplication of rows in the procedure
                                  load_er_liab of pay_gtnlod_pkg.
   15-SEP-2005 meshah      115.17 removed the index hint from the range cursor.
                                  bug 4591091.
   07-APR-2006 rdhingra    115.18 Bug 5148084: Added procedure create_gtn_xml_data
                                  Modified ARCHIVE_DEINIT to submit XML Report Publisher
   24-APR-2006 rdhingra    115.19 Bug 5148084: Modified Cursor get_application_detais
                                  to reflect changes of parameters to XML Report Publisher
                                  concurrent program
   30-Aug-2006 kvsankar    115.20 Bug 5478638 : Passed Application ID instead of
                                  Application Name to the concurrent program
                                  "XML Report Publisher"
   16-Oct-2006 jdevasah    114.21 Bug 4942114 : changed the parameters to
                                  pay_gtnlod_pkg.load_data procedure in ARCHIVE_CODE.
				  Commented assignment statements in ARCHVIE_INIT.
				  Created global variables which are input paramenters
				  to pay_gtnlod_pkg.load_data procedure.
   21-jan-2007 asgugupt    114.22 Bug 6365474 : changed the parameters to
                                  fnd_request.submit_request in ARCHIVE_DEINIT.

   06-Mar-2008	skameswa   115.25 Bug 6799553 : Modified the procedure ARCHIVE_DEINIT to include
				  a new cursor get_printer_details and a call to
				  fnd_request.set_print_options whose parameters were retrieved by
				  the above mentioned cursor
   10-Apr-2008  priupadh   115.26 Bug 6670508 Added delete statment for pay_us_rpt_totals table
                                  in archive_deinit,deleting for the current run as payroll act id gets
                                  stored in column tax_unit_id .
   21-Apr-2008  priupadh   115.27 Bug 6670508 Moved delete statment outside if clause , to delete the data
                                  in 11i and R12 .
   04-Aug-2008  kagangul   115.28 Bug 7297300. Changed Cursor (get_printer_details) Parameter Name
				  from request_id to c_request_id.
   04-Mar-2009  skpatil    115.29  Bug 8216159: Changed action_creation_bra cursor to include balance
                                   adjustments('B') action_type
*/
----------------------------------- range_cursor ----------------------------------
--
  g_proc_name             VARCHAR2(240);
  p_ded_bal_status1       VARCHAR2(1);
  p_ded_bal_status2       VARCHAR2(1);
  p_earn_bal_status       VARCHAR2(1);
  p_fed_bal_status        VARCHAR2(1);
  p_state_bal_status      VARCHAR2(1);
  p_local_bal_status      VARCHAR2(1);
  p_fed_liab_bal_status   VARCHAR2(1);
  p_state_liab_bal_status VARCHAR2(1);
/*-- Bug#4942114 starts -- */
/* p_ded_view_name         VARCHAR2(30);
  p_earn_view_name        VARCHAR2(30);
  p_fed_view_name         VARCHAR2(30);
  p_state_view_name       VARCHAR2(30);
  p_local_view_name       VARCHAR2(30);
  p_fed_liab_view_name    VARCHAR2(30);
  p_state_liab_view_name  VARCHAR2(30);*/
/*-- Bug#4942114 ends -- */
  p_asg_flag              VARCHAR2(5);
/*-- Bug#4942114 starts -- */
/* p_futa_where            VARCHAR2(2000);
  p_futa_from             VARCHAR2(200);
  p_er_liab_where         VARCHAR2(2000);
  p_er_liab_from          VARCHAR2(2000);
  p_wc_er_liab_where      VARCHAR2(2000);
  p_wc_er_liab_from       VARCHAR2(2000);*/
/*-- Bug#4942114 ends -- */

  p_ppa_finder            VARCHAR2(20);
  g_payroll_action_id     NUMBER;
  l_arch_count            NUMBER := 0;
  p_template_code         xdo_templates_tl.template_code%TYPE;
  /*-- Bug#4942114 starts -- */
  p_futa_status_count     number :=0;
  p_futa_def_bal_id number;
  p_wc_er_liab_status_count number :=0;
  p_er_liab_status varchar2(1);
  /*-- Bug#4942114 ends -- */

procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_consolidation_set_id number;
  l_payroll_id number;
  l_tax_unit_id number;
  l_ppa_finder  number;
  l_leg_start_date date;
  l_leg_end_date   date;
  l_business_group_id number;

  l_payroll_text   varchar2(70);
--
begin

    -- hr_utility.trace_on('Y','GTN');
     hr_utility.trace('reached range_cursor');


   select ppa.legislative_parameters,
          pay_paygtn_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
          pay_paygtn_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
          pay_paygtn_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters),
          pay_paygtn_pkg.get_parameter('PPA_FINDER',ppa.legislative_parameters),
          ppa.start_date,
          ppa.effective_date,
          ppa.business_group_id
     into leg_param,
          l_consolidation_set_id,
          l_payroll_id,
          l_tax_unit_id,
          l_ppa_finder,
          l_leg_start_date,
          l_leg_end_date,
          l_business_group_id
     from pay_payroll_actions ppa
     where ppa.payroll_action_id = pactid;

    IF l_payroll_id is not null THEN  -- added to improve the performance
       l_payroll_text := 'and ppa_run.payroll_id = ' || to_char(l_payroll_id) ;
    ELSE
         l_payroll_text := null;
    END IF;

    insert into pay_us_rpt_totals (tax_unit_id,attribute1,organization_id,
                                      attribute2,attribute3,attribute4,attribute5)
                              values (pactid,'GTN',l_ppa_finder,
                                      leg_param, l_business_group_id,
                                      to_char(l_leg_start_date,'MM/DD/YYYY'),
                                      to_char(l_leg_end_date,'MM/DD/YYYY'));

/* pay gtn code */

   sqlstr := 'select distinct asg.person_id
                from per_assignments_f      asg,
                     pay_assignment_actions act_run, /* run and quickpay assignment actions */
                     pay_payroll_actions    ppa_run, /* run and quickpay payroll actions */
                     pay_payroll_actions    ppa_gen  /* PYUGEN information */
               where ppa_gen.payroll_action_id    = :payroll_action_id
                 and ppa_run.effective_date between  /* date join btwn run and pyugen ppa */
                                            ppa_gen.start_date and ppa_gen.effective_date
                 and ppa_run.action_type         in (''R'',''Q'',''V'')
                 and ppa_run.consolidation_set_id = '''||l_consolidation_set_id||''''||l_payroll_text||'
                 and ppa_run.payroll_action_id    = act_run.payroll_action_id
                 and act_run.action_status        = ''C''
                 and asg.assignment_id            = act_run.assignment_id
                 and ppa_run.effective_date between  /* date join btwn run and asg */
                                            asg.effective_start_date and asg.effective_end_date
                and asg.business_group_id +0    = ppa_gen.business_group_id
           order by asg.person_id';

     hr_utility.trace('leaving range_cursor');

end range_cursor;
---------------------------------- action_creation ----------------------------------
--
procedure action_create_bra(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_consolidation_set_id number;
  l_payroll_id number;
  l_tax_unit_id number;

--Bug 3364759 --Declared these local variables which will be populated by  the cursor c_parameters.
  l_business_group_id number;
  l_start_date date;
  l_effective_date date;

--
-- Bug 3364759 --Added business_group_id,start_date and effective_date in the select statement
               -- of the cursor c_parameters.
  cursor c_parameters ( pactid number) is
   select ppa.legislative_parameters,
          ppa.business_group_id,
          ppa.start_date,
          ppa.effective_date,
          pay_paygtn_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
          pay_paygtn_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
          pay_paygtn_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters)
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

--Bug 3364759 --Used the local variables l_business_group_id,l_start_date,l_effective_date in the
              -- cursor query to reduce its cost.Also removed the forced index  PAY_PAYROLL_ACTIONS_N5.
  CURSOR c_actions
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is
              select /*+ ORDERED
                         INDEX (ppa_gen PAY_PAYROLL_ACTIONS_PK)
                         INDEX (act_run PAY_ASSIGNMENT_ACTIONS_N50)
                         INDEX (asg     PER_ASSIGNMENTS_F_PK) */
                     ppa_run.action_type,
                     act_run.assignment_action_id,
                     asg.assignment_id,
                     act_run.tax_unit_id
                     from pay_payroll_actions    ppa_run, /* run and quickpay payroll actions */
                          pay_assignment_actions act_run, /* run and quickpay assignment actions */
                          per_assignments_f      asg
  		 where ppa_run.effective_date between
	                                            l_start_date
                                                and l_effective_date
                 and ppa_run.action_type         in ('R','Q','V','B')  /* 8216159 */
                 and ppa_run.consolidation_set_id = l_consolidation_set_id
                 AND (l_payroll_id IS NULL
                      OR  PPA_RUN.PAYROLL_ID  = l_payroll_id)
                 and ppa_run.payroll_action_id    = act_run.payroll_action_id
                 and act_run.action_status        = 'C'
 		 and act_run.tax_unit_id          = nvl(l_tax_unit_id,
                                                        act_run.tax_unit_id)
                 and asg.assignment_id            = act_run.assignment_id
                 and ppa_run.effective_date between  /* date join btwn run and asg */
                                                    asg.effective_start_date
                                                and asg.effective_end_date
		 and asg.business_group_id +0     = l_business_group_id
                 and asg.person_id          between stperson and endperson;
--                       for update of asg.assignment_id;


--
      lockingactid    number;
      lockedactid     number;
      assignid        number;
      greid           number;
      num             number;
      action_type     varchar2(30);
      l_payments_bal  number;
      l_gross_defined_balance_id number;
      l_payments_defined_balance_id number;
      l_create_act    varchar2(1);

--
   -- algorithm is quite similar to the other process cases,
   -- but we have to take into account assignments and
   -- personal payment methods.
   begin
      --hr_utility.trace_on('Y','ORACLE');
      hr_utility.trace('entering action_creation');
      hr_utility.set_location('procpyr',1);
      open c_parameters(pactid);

--Bug 3364759 -- Fetced the values of the cursors in the variables  l_business_group_id, l_start_date, l_effective_date
              -- as well.
      fetch c_parameters into leg_param,
                              l_business_group_id,
                              l_start_date,
                              l_effective_date,
                              l_consolidation_set_id,
                              l_payroll_id,
                              l_tax_unit_id;
      close c_parameters;
/*      begin
        select to_number(ue.creator_id)
          into l_gross_defined_balance_id
          from ff_user_entities ue,
               ff_database_items di
--         where di.user_name = 'PAYMENTS_ASG_GRE_RUN'
          where di.user_name = 'GROSS_EARNINGS_ASG_GRE_RUN'
           and ue.user_entity_id = di.user_entity_id
           and ue.creator_type = 'B'
           and nvl(ue.legislation_code,'US') = 'US';
      exception when others then
           hr_utility.trace('Error getting defined balance id');
           raise;
      end;

      begin
        select to_number(ue.creator_id)
          into l_payments_defined_balance_id
          from ff_user_entities ue,
               ff_database_items di
          where di.user_name = 'PAYMENTS_ASG_GRE_RUN'
           and ue.user_entity_id = di.user_entity_id
           and ue.creator_type = 'B'
           and nvl(ue.legislation_code,'US') = 'US';
      exception when others then
           hr_utility.trace('Error getting defined balance id');
           raise;
      end;
*/

      hr_utility.set_location('procpyr',1);
      open c_actions(pactid,stperson,endperson);
      num := 0;
      loop
         hr_utility.set_location('procpyr',2);
         fetch c_actions into action_type,lockedactid,assignid,greid;
         if c_actions%found then num := num + 1; end if;
         exit when c_actions%notfound;
--
        begin

          select 'Y'
          into l_create_act
          from dual
          where exists (
              select 'Y'
              from   pay_run_result_values rrv,
                     pay_input_values_F    iv,
                     pay_run_results       rr
              where  nvl(rrv.result_value,0) <> to_char(0)
              and    iv.input_value_id = rrv.input_value_id
	      and    iv.element_type_id = rr.element_type_id
	      and    iv.name = 'Pay Value'
              and    rr.run_result_id = rrv.run_result_id
              and    rr.assignment_action_id = lockedactid);

        exception
           when NO_DATA_FOUND THEN
             l_create_act := 'N';
        end;


/*        pay_balance_pkg.set_context('TAX_UNIT_ID',greid);
        l_payments_bal := nvl(pay_balance_pkg.get_value(p_defined_balance_id => l_gross_defined_balance_id,
                                                        p_assignment_action_id => lockedactid),0);

        if l_payments_bal = 0 and action_type in ('R','Q') then
--
-- Check the Payments_asg_gre_run balance incase Gross earnings is 0
-- and we have a non payroll payment (only element processed) action.
--
-- Not going to set the context again as
           l_payments_bal := nvl(pay_balance_pkg.get_value(p_defined_balance_id => l_payments_defined_balance_id,
                                                       p_assignment_action_id => lockedactid),0);
        end if;
*/
/*        if l_payments_bal = 0 and action_type in ('R','Q') then */

          if l_create_act = 'N' then


           null;
        else
        	hr_utility.set_location('procpyr',3);
        	select pay_assignment_actions_s.nextval
        	into   lockingactid
        	from   dual;
--
        	-- insert the action record.
        	hr_nonrun_asact.insact(lockingactid =>lockingactid,
        			        object_id   =>lockedactid,
        			        pactid      =>pactid,
        			        chunk       =>chunk,
        			        greid       =>greid);
--
         	-- insert an interlock to this action.
    --     	hr_nonrun_asact.insint(lockingactid,lockedactid);
        end if;
--
      end loop;
      close c_actions;
      hr_utility.trace('leaving action_creation');
end action_create_bra;

---------------------------------- action_creation ----------------------------------
--
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_consolidation_set_id number;
  l_payroll_id number;
  l_tax_unit_id number;

--Bug 3364759 --Declared these local variables which will be populated by  the cursor c_parameters.
  l_business_group_id number;
  l_start_date date;
  l_effective_date date;

--
-- Bug 3364759 --Added business_group_id,start_date and effective_date in the select statement
               -- of the cursor c_parameters.
  cursor c_parameters ( pactid number) is
   select ppa.legislative_parameters,
          ppa.business_group_id,
          ppa.start_date,
          ppa.effective_date,
          pay_paygtn_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
          pay_paygtn_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
          pay_paygtn_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters)
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

--Bug 3364759 --Used the local variables l_business_group_id,l_start_date,l_effective_date in the
              -- cursor query to reduce its cost.Also removed the forced index  PAY_PAYROLL_ACTIONS_N5.
  CURSOR c_actions
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is
              select /*+ ORDERED
                         INDEX (ppa_gen PAY_PAYROLL_ACTIONS_PK)
                         INDEX (act_run PAY_ASSIGNMENT_ACTIONS_N50)
                         INDEX (asg     PER_ASSIGNMENTS_F_PK) */
                     ppa_run.action_type,
                     act_run.assignment_action_id,
                     asg.assignment_id,
                     act_run.tax_unit_id
                     from pay_payroll_actions    ppa_run, /* run and quickpay payroll actions */
                          pay_assignment_actions act_run, /* run and quickpay assignment actions */
                          per_assignments_f      asg
  		 where ppa_run.effective_date between
	                                            l_start_date
                                                and l_effective_date
                 and ppa_run.action_type         in ('R','Q','V')
                 and ppa_run.consolidation_set_id = l_consolidation_set_id
                 AND (l_payroll_id IS NULL
                      OR  PPA_RUN.PAYROLL_ID  = l_payroll_id)
                 and ppa_run.payroll_action_id    = act_run.payroll_action_id
                 and act_run.action_status        = 'C'
 		 and act_run.tax_unit_id          = nvl(l_tax_unit_id,
                                                        act_run.tax_unit_id)
                 and asg.assignment_id            = act_run.assignment_id
                 and ppa_run.effective_date between  /* date join btwn run and asg */
                                                    asg.effective_start_date
                                                and asg.effective_end_date
		 and asg.business_group_id +0     = l_business_group_id
                 and asg.person_id          between stperson and endperson;
--                       for update of asg.assignment_id;


--
      lockingactid    number;
      lockedactid     number;
      assignid        number;
      greid           number;
      num             number;
      action_type     varchar2(30);
      l_payments_bal  number;
      l_gross_defined_balance_id number;
      l_payments_defined_balance_id number;
      l_create_act    varchar2(1);

--
   -- algorithm is quite similar to the other process cases,
   -- but we have to take into account assignments and
   -- personal payment methods.
   begin
      --hr_utility.trace_on('Y','ORACLE');
      hr_utility.trace('entering action_creation');
      hr_utility.set_location('procpyr',1);
      open c_parameters(pactid);

--Bug 3364759 -- Fetced the values of the cursors in the variables  l_business_group_id, l_start_date, l_effective_date
              -- as well.
      fetch c_parameters into leg_param,
                              l_business_group_id,
                              l_start_date,
                              l_effective_date,
                              l_consolidation_set_id,
                              l_payroll_id,
                              l_tax_unit_id;
      close c_parameters;
/*      begin
        select to_number(ue.creator_id)
          into l_gross_defined_balance_id
          from ff_user_entities ue,
               ff_database_items di
--         where di.user_name = 'PAYMENTS_ASG_GRE_RUN'
          where di.user_name = 'GROSS_EARNINGS_ASG_GRE_RUN'
           and ue.user_entity_id = di.user_entity_id
           and ue.creator_type = 'B'
           and nvl(ue.legislation_code,'US') = 'US';
      exception when others then
           hr_utility.trace('Error getting defined balance id');
           raise;
      end;

      begin
        select to_number(ue.creator_id)
          into l_payments_defined_balance_id
          from ff_user_entities ue,
               ff_database_items di
          where di.user_name = 'PAYMENTS_ASG_GRE_RUN'
           and ue.user_entity_id = di.user_entity_id
           and ue.creator_type = 'B'
           and nvl(ue.legislation_code,'US') = 'US';
      exception when others then
           hr_utility.trace('Error getting defined balance id');
           raise;
      end;
*/

      hr_utility.set_location('procpyr',1);
      open c_actions(pactid,stperson,endperson);
      num := 0;
      loop
         hr_utility.set_location('procpyr',2);
         fetch c_actions into action_type,lockedactid,assignid,greid;
         if c_actions%found then num := num + 1; end if;
         exit when c_actions%notfound;
--
        begin

          select 'Y'
          into l_create_act
          from dual
          where exists (
              select 'Y'
              from   pay_run_result_values rrv,
                     pay_input_values_F    iv,
                     pay_run_results       rr
              where  nvl(rrv.result_value,0) <> to_char(0)
              and    iv.input_value_id = rrv.input_value_id
              and    iv.name = 'Pay Value'
	      and    iv.element_type_id = rr.element_type_id
	      and    rr.run_result_id = rrv.run_result_id
              and    rr.assignment_action_id = lockedactid);

        exception
           when NO_DATA_FOUND THEN
             l_create_act := 'N';
        end;


/*        pay_balance_pkg.set_context('TAX_UNIT_ID',greid);
        l_payments_bal := nvl(pay_balance_pkg.get_value(p_defined_balance_id => l_gross_defined_balance_id,
                                                        p_assignment_action_id => lockedactid),0);

        if l_payments_bal = 0 and action_type in ('R','Q') then
--
-- Check the Payments_asg_gre_run balance incase Gross earnings is 0
-- and we have a non payroll payment (only element processed) action.
--
-- Not going to set the context again as
           l_payments_bal := nvl(pay_balance_pkg.get_value(p_defined_balance_id => l_payments_defined_balance_id,
                                                       p_assignment_action_id => lockedactid),0);
        end if;
*/
/*        if l_payments_bal = 0 and action_type in ('R','Q') then */

          if l_create_act = 'N' then


           null;
        else
        	hr_utility.set_location('procpyr',3);
        	select pay_assignment_actions_s.nextval
        	into   lockingactid
        	from   dual;
--
        	-- insert the action record.
        	hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);
--
         	-- insert an interlock to this action.
         	hr_nonrun_asact.insint(lockingactid,lockedactid);
        end if;
--
      end loop;
      close c_actions;
      hr_utility.trace('leaving action_creation');
end action_creation;
---------------------------------- sort_action ----------------------------------
procedure sort_action
(
   payactid   in     varchar2,     /* payroll action id */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out  nocopy  number        /* length of the sql string */
) is
begin

      sqlstr :=  'select paa1.rowid
                    from pay_assignment_actions paa1,   -- PYUGEN assignment action
                         pay_payroll_actions    ppa1    -- PYUGEN payroll action id
                   where ppa1.payroll_action_id = :pactid
                     and paa1.payroll_action_id = ppa1.payroll_action_id
                   order by paa1.assignment_action_id
                   for update of paa1.assignment_id';

      len := length(sqlstr); -- return the length of the string.
   end sort_action;
------------------------------ get_parameter -------------------------------
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER) IS

l_param varchar2(240);
p_business_group_id number;
p_start_date date;
p_end_date date;
p_consolidation_set_id number;
p_payroll_id number;
p_gre_id number;
p_sort1  varchar2(20);
p_sort2  varchar2(20);
p_sort3  varchar2(20);
l_trunc_date date;
/*-- Bug#4942114 starts -- */
/* l_futa_def_bal_id number;
l_temp_count number;
l_er_liab_status varchar2(1); */
/*-- Bug#4942114 ends -- */

cursor get_futa_def_bal_id(cp_business_group_id number) is
SELECT /*+ index(pbd PAY_BALANCE_DIMENSIONS_PK)*/ pdb.defined_balance_id
  FROM pay_defined_balances pdb,
       pay_balance_types pbt,
       pay_balance_dimensions pbd
 WHERE pdb.balance_dimension_id = pbd.balance_dimension_id
   AND pdb.balance_type_id = pbt.balance_type_id
   AND (   pdb.business_group_id = cp_business_group_id
        OR pdb.legislation_code = 'US'
       )
   AND pbt.legislation_code = 'US'
   AND pbd.legislation_code = 'US'
   AND pbd.database_item_suffix = '_ASG_GRE_RUN'
   AND pbt.balance_name = 'FUTA CREDIT';

 cursor chk_futa_status(cp_business_group_id number,cp_start_date date,cp_defined_balance_id number) IS
 select count(*)
 from  pay_balance_validation pbv
 where pbv.business_group_id = cp_business_group_id
 and   pbv.defined_balance_id = cp_defined_balance_id
 AND   NVL (pbv.run_balance_status, 'I') = 'V'
 and NVL(pbv.balance_load_date, cp_start_date) <= cp_start_date;

cursor c_wc_er_liab_valid_count(cp_business_group_id number,cp_start_date date) IS
select count(*)
 from  pay_balance_validation pbv,
       pay_defined_balances pdb,
       pay_balance_types pbt,
       pay_balance_dimensions pbd
 where (pbv.business_group_id = cp_business_group_id)
 and   pbv.defined_balance_id = pdb.defined_balance_id
 and   pdb.balance_dimension_id = pbd.balance_dimension_id
 and   pdb.balance_type_id = pbt.balance_type_id
 and   (pdb.business_group_id = cp_business_group_id or
        pdb.legislation_code = 'US')
 and pbt.legislation_code = 'US'
 and pbd.legislation_code = 'US'
 and   pbd.database_item_suffix = '_ASG_JD_GRE_RUN'
 and pbt.balance_name in ('Workers Compensation',
                          'Workers Compensation2 ER',
                          'Workers Compensation3 ER')
 AND   NVL (pbv.run_balance_status, 'I') = 'V'
 and NVL(pbv.balance_load_date, cp_start_date) <= cp_start_date;
begin

begin
--
  --   hr_utility.trace_on (null,'1');
      hr_utility.trace('entering archive_init');
 select
        ppa.legislative_parameters,
        ppa.business_group_id,
        ppa.start_date,
        ppa.effective_date
   into l_param,
        p_business_group_id,
        p_start_date,
        p_end_date
   from pay_payroll_actions ppa
  where ppa.payroll_action_id = p_payroll_action_id;

  g_payroll_action_id    := p_payroll_action_id;
  p_consolidation_set_id := pay_paygtn_pkg.get_parameter('TRANSFER_CONC_SET',l_param);
  p_payroll_id           := pay_paygtn_pkg.get_parameter('TRANSFER_PAYROLL',l_param);
  p_gre_id               := pay_paygtn_pkg.get_parameter('TRANSFER_GRE',l_param);
  p_sort1                := pay_paygtn_pkg.get_parameter('TRANSFER_SORT1',l_param);
  p_sort2                := pay_paygtn_pkg.get_parameter('TRANSFER_SORT2',l_param);
  p_sort3                := pay_paygtn_pkg.get_parameter('TRANSFER_SORT3',l_param);
  p_ppa_finder           := pay_paygtn_pkg.get_parameter('TRANSFER_PPA_FINDER',l_param);
  p_template_code        := pay_paygtn_pkg.get_parameter('TRANSFER_TEMPLATE',l_param);
  p_asg_flag             := nvl(pay_paygtn_pkg.get_parameter('TRANSFER_EMP_INFO',l_param),'N');

  hr_utility.trace('p_asg_flag in archive_init='||p_asg_flag);
       p_ded_bal_status1 := pay_us_payroll_utils.check_balance_status(p_start_date
                                                          ,p_business_group_id
                                                         ,'PAY_US_PRE_TAX_DEDUCTIONS','US');
       p_ded_bal_status2 := pay_us_payroll_utils.check_balance_status(p_start_date
                                                          ,p_business_group_id
                                                         ,'PAY_US_AFTER_TAX_DEDUCTIONS','US');
   /*-- Bug#4942114 starts -- */
     /* if p_ded_bal_status1 = 'Y' AND p_ded_bal_status2 = 'Y' THEN
           p_ded_view_name := 'PAY_US_ASG_RUN_DED_RBR_V';
      else
           p_ded_view_name := 'PAY_US_GTN_DEDUCT_V';
      end if; */
      /*-- Bug#4942114 ends -- */
     p_earn_bal_status := pay_us_payroll_utils.check_balance_status(p_start_date
                                   ,p_business_group_id
                                   ,'PAY_US_EARNINGS_AMTS','US');
   /*-- Bug#4942114 starts -- */
     /* if p_earn_bal_status = 'Y' THEN
           p_earn_view_name := 'PAY_US_ASG_RUN_EARN_AMT_RBR_V';
      else
           p_earn_view_name := 'PAY_US_GTN_EARNINGS_V';
      end if; */
  /*-- Bug#4942114 ends -- */
 p_fed_bal_status := pay_us_payroll_utils.check_balance_status(p_start_date
                                                         ,p_business_group_id
                                                        ,'PAY_US_TAX_DEDN_FED','US');
 p_state_bal_status := pay_us_payroll_utils.check_balance_status(p_start_date
                                                         ,p_business_group_id
                                                        ,'PAY_US_TAX_DEDN_STATE','US');
 p_local_bal_status := pay_us_payroll_utils.check_balance_status(p_start_date
                                                         ,p_business_group_id
                                                        ,'PAY_US_TAX_DEDN_LOCAL','US');
   /*-- Bug#4942114 starts -- */
   /*  if p_fed_bal_status = 'Y'  THEN
          p_fed_view_name := 'PAY_US_ASG_RUN_FED_TAX_RBR_V';
     else
          p_fed_view_name := 'PAY_US_FED_TAXES_V';
     end if;

     if p_state_bal_status = 'Y'  THEN
          p_state_view_name := 'PAY_US_ASG_RUN_STATE_TAX_RBR_V';
     else
          p_state_view_name := 'PAY_US_STATE_TAXES_V';
     end if;

     if p_local_bal_status = 'Y'  THEN
          p_local_view_name := 'PAY_US_ASG_RUN_LOCAL_TAX_RBR_V';
     else
          p_local_view_name := 'PAY_US_LOCAL_TAXES_V';
     end if; */
   /*-- Bug#4942114 ends -- */

 p_fed_liab_bal_status := pay_us_payroll_utils.check_balance_status(p_start_date
                                                         ,p_business_group_id
                                                        ,'PAY_US_FED_LIABILITIES','US');
 p_state_liab_bal_status := pay_us_payroll_utils.check_balance_status(p_start_date
                                                         ,p_business_group_id
                                                        ,'PAY_US_STATE_LIABILITIES','US');
 /*-- Bug#4942114 starts -- */
    /* if p_fed_liab_bal_status = 'Y'  THEN
          p_fed_liab_view_name := 'PAY_US_ASG_RUN_FED_LIAB_RBR_V';
     else
          p_fed_liab_view_name := 'PAY_US_FED_LIABILITIES_V';
     end if;

     if p_state_liab_bal_status = 'Y'  THEN
          p_state_liab_view_name := 'PAY_US_ASG_RUN_ST_LIAB_RBR_V';
     else
          p_state_liab_view_name := 'PAY_US_STATE_LIABILITIES_V';
     end if; */
     /*-- Bug#4942114 ends -- */

   l_trunc_date := trunc(p_start_date,'Y');
 --  l_temp_count :=0; -- Bug#4942114
open get_futa_def_bal_id(p_business_group_id);
-- fetch get_futa_def_bal_id into l_futa_def_bal_id; /*-- Bug#4942114--*/
   fetch get_futa_def_bal_id into p_futa_def_bal_id; /*-- Bug#4942114--*/
close get_futa_def_bal_id;

/*-- Bug#4942114 starts --*/
/* if l_futa_def_bal_id is not NULL then
     open chk_futa_status(p_business_group_id,p_start_date,l_futa_def_bal_id);
     fetch chk_futa_status into l_temp_count; */
if p_futa_def_bal_id is not NULL then
   open chk_futa_status(p_business_group_id,p_start_date,p_futa_def_bal_id);
   fetch chk_futa_status into p_futa_status_count;
 /*-- Bug#4942114 ends --*/
   close chk_futa_status;
end if;
/*-- Bug#4942114 starts --*/
  /* if l_temp_count = 1 then
      p_futa_where := ' prb.defined_balance_id = '|| l_futa_def_bal_id
                     ||' AND prb.assignment_action_id = ';
      p_futa_from := ' pay_run_balances prb ';
   else
     p_futa_where := ' prr.status in ('||'''P'''||','||'''PA'''||')
                and pet.element_type_id      = prr.element_type_id
            	and prr.assignment_action_id = ';
      p_futa_from := ' pay_run_results prr ';
   end if; */
  /* -- Bug#4942114 ends --*/
p_er_liab_status := pay_us_payroll_utils.check_balance_status(p_start_date
                                                         ,p_business_group_id
                                                         ,'PAY_US_EMPLOYER_LIABILITY','US'); -- Bug#4942114
/* -- Bug#4942114 starts --*/
/*l_er_liab_status := pay_us_payroll_utils.check_balance_status(p_start_date
                                                         ,p_business_group_id
                                                         ,'PAY_US_EMPLOYER_LIABILITY','US');
if l_er_liab_status = 'Y' THEN
  p_er_liab_where := ' prb.defined_balance_id = pdb.defined_balance_id
              and   (pdb.business_group_id ='||p_business_group_id||
                 ' or pbd.legislation_code ='|| '''US'''||')
              and  pdb.balance_type_id = pbt.balance_type_id
              and pdb.balance_dimension_id = pbd.balance_dimension_id
              and pbd.legislation_code = '||'''US'''||
            ' and pbd.database_item_suffix ='||'''_ASG_GRE_RUN'''||
           ' and   prb.assignment_action_id = ';
p_er_liab_from := 'pay_run_balances prb,
		   pay_defined_balances pdb,
		   pay_balance_dimensions pbd ';

else
 p_er_liab_where := ' prr.element_type_id +0 = pet.element_type_id
             and   prr.status in (' || '''P''' || ', ' || '''PA''' || ')
             and   prr.assignment_action_id = ';
p_er_liab_from  := ' pay_run_results prr ';
end if; */
/*-- Bug#4942114 ends --*/

   open c_wc_er_liab_valid_count(p_business_group_id,l_trunc_date);
     fetch c_wc_er_liab_valid_count into p_wc_er_liab_status_count; -- Bug#4942114
   --fetch c_wc_er_liab_valid_count into l_temp_count; -- Bug#4942114
   close c_wc_er_liab_valid_count;

 /*-- Bug#4942114 starts --*/
   /* if l_temp_count = 3 then
      p_wc_er_liab_where := ' prb.defined_balance_id = pdb.defined_balance_id
                         AND pdb.balance_type_id = pbt.balance_type_id
                         AND pdb.balance_dimension_id = pbd.balance_dimension_id
                         AND pbd.legislation_code = '||'''US'''
                     ||'  AND pbd.database_item_suffix ='||'''_ASG_JD_GRE_RUN'''
                     ||' AND (pdb.legislation_code ='||'''US'''
                              ||' OR pdb.business_group_id ='||p_business_group_id||')
                          and    prb.assignment_action_id = paa.assignment_action_id
                          and    prb.tax_unit_id = paa.tax_unit_id
                          and    prb.jurisdiction_code = pst.state_code
                          and    prb.tax_unit_id  = paa.tax_unit_id';
    p_wc_er_liab_from :=' pay_run_balances prb,
    			pay_balance_dimensions pbd,
    			pay_defined_balances pdb ';

   else
     p_wc_er_liab_where := ' prr.element_type_id +0   = pet.element_type_id
                           and prr.assignment_action_id = paa.assignment_action_id';
     p_wc_er_liab_from := ' pay_run_results prr ';
   end if; */
  /*-- Bug#4942114 ends --*/

 exception
 when no_data_found then
null;
end;
      hr_utility.trace('leaving archive_init');
end ARCHIVE_INIT;


Procedure ARCHIVE_CODE (p_payroll_action_id                 IN NUMBER
	     	       ,p_chunk_number                       IN NUMBER)  IS
begin
      hr_utility.trace('entering archive_code');
      hr_utility.trace('l_arch_count ='||l_arch_count);
 /*-- Bug#4942114 starts --*/
  /* pay_gtnlod_pkg.load_data(p_payroll_action_id => p_payroll_action_id,
    			    p_chunk => p_chunk_number,
                            ppa_finder => p_ppa_finder,
                            p_ded_view_name =>  p_ded_view_name,
		       	    p_earn_view_name => p_earn_view_name,
		            p_fed_view_name  => p_fed_view_name,
			    p_state_view_name  => p_state_view_name,
			    p_local_view_name => p_local_view_name,
			    p_fed_liab_view_name => p_fed_liab_view_name,
			    p_state_liab_view_name => p_state_liab_view_name,
			    p_futa_where => p_futa_where,
			    p_futa_from  => p_futa_from,
			    p_er_liab_where => p_er_liab_where,
			    p_er_liab_from  => p_er_liab_from,
			    p_wc_er_liab_where => p_wc_er_liab_where,
			    p_wc_er_liab_from  => p_wc_er_liab_from,
			    p_asg_flag => p_asg_flag);
	l_arch_count := l_arch_count +1;
   */

      pay_gtnlod_pkg.load_data(p_payroll_action_id => p_payroll_action_id,
    			    p_chunk => p_chunk_number,
                            ppa_finder => p_ppa_finder,
			    p_ded_bal_status1 => p_ded_bal_status1,
			    p_ded_bal_status2 => p_ded_bal_status2,
			    p_earn_bal_status => p_earn_bal_status,
			    p_fed_bal_status  => p_fed_bal_status,
			    p_state_bal_status=> p_state_bal_status,
			    p_local_bal_status=> p_local_bal_status,
			    p_fed_liab_bal_status => p_fed_liab_bal_status,
			    p_state_liab_bal_status => p_state_liab_bal_status,
			    p_futa_status_count => p_futa_status_count,
			    p_futa_def_bal_id => p_futa_def_bal_id,
			    p_er_liab_status => p_er_liab_status,
			    p_wc_er_liab_status_count => p_wc_er_liab_status_count,
			    p_asg_flag => p_asg_flag);
 /*-- Bug#4942114 ends --*/
      hr_utility.trace('leaving archive_code');
end ARCHIVE_CODE;

PROCEDURE CREATE_GTN_XML_DATA
IS
    lb_xml_blob     BLOB;
    lv_proc_name    VARCHAR2(100);

BEGIN

   lv_proc_name := g_proc_name || 'CREATE_GTN_XML_DATA';
   hr_utility.trace ('Entering '|| lv_proc_name);

   pay_us_xdo_report.populate_gtn_report_data(p_ppa_finder => p_ppa_finder
                                                ,p_xfdf_blob  => lb_xml_blob);
   pay_core_files.write_to_magtape_lob(lb_xml_blob);

   hr_utility.trace ('Leaving '|| lv_proc_name);

EXCEPTION WHEN OTHERS THEN
   HR_UTILITY.TRACE('Inside Exception WHEN OTHERS of Procedure' || lv_proc_name);
END CREATE_GTN_XML_DATA;


Procedure ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER) IS

   -- Get request_id
   CURSOR get_request_id (c_pact_id NUMBER)IS
   SELECT request_id
     FROM pay_payroll_actions
    WHERE payroll_action_id = c_pact_id;

   -- Get Application Short Name and Application ID
   CURSOR get_application_detais(c_request_id NUMBER) IS
   SELECT app.application_short_name, fcp.application_id
     FROM fnd_application_vl app,
          fnd_concurrent_programs fcp,
          fnd_concurrent_requests r
    WHERE fcp.concurrent_program_id = r.concurrent_program_id
      AND r.request_id = c_request_id
      and app.application_id = fcp.application_id;


    -- Get template type
    CURSOR get_template_type(c_templ_code xdo_templates_tl.template_code%TYPE) IS
    SELECT template_type_code
      FROM xdo_templates_vl
     WHERE template_code = c_templ_code;
--bug 6365474
  cursor csr_release is
  select      to_number(substr(PRODUCT_VERSION,1,2))
    from FND_PRODUCT_INSTALLATIONS
   where APPLICATION_ID = 800;
   l_release       number;
--bug 6365474

-- bug 6799553
-- Get printer details
   /*CURSOR get_printer_details(request_id NUMBER) IS
   SELECT printer, print_style, number_of_copies, save_output_flag, print_group
   FROM fnd_concurrent_requests
   WHERE request_id = request_id ;*/
-- bug 7297300
   /* Changing the Parameter Name from request_id to c_request_id */
   CURSOR get_printer_details(c_request_id NUMBER) IS
   SELECT printer, print_style, number_of_copies, save_output_flag, print_group
   FROM fnd_concurrent_requests
   WHERE request_id = c_request_id ;

   printer                 fnd_concurrent_requests.printer%TYPE;
   print_style             fnd_concurrent_requests.print_style%TYPE;
   number_of_copies        fnd_concurrent_requests.number_of_copies%TYPE;
   save_output_flag        fnd_concurrent_requests.save_output_flag%TYPE;
   save_output             BOOLEAN;
   print_group             fnd_concurrent_requests.print_group%TYPE;
   result                  BOOLEAN;
-- bug 6799553

   ln_req_id               NUMBER;
   ln_current_request_id   NUMBER;
   ln_application_id       NUMBER;
   lv_proc_name            VARCHAR2(100);
   lv_template_type        xdo_templates_b.template_type_code%TYPE;
   lv_template_code        xdo_templates_tl.template_code%TYPE;
   lv_app_short_name       fnd_application_vl.application_short_name%TYPE;


BEGIN

   lv_proc_name := g_proc_name || 'CREATE_GTN_XML_DATA';
   hr_utility.trace ('Entering '|| lv_proc_name);
   hr_utility.trace ('p_payroll_action_id '|| p_payroll_action_id);
   hr_utility.trace ('p_template_code '|| p_template_code);
--bug 6365474
   OPEN csr_release;
   FETCH csr_release INTO l_release;
   CLOSE csr_release;
--bug 6365474
   lv_template_code := p_template_code;

   OPEN get_request_id(p_payroll_action_id);
   FETCH get_request_id INTO ln_current_request_id;
   CLOSE get_request_id;

   OPEN get_application_detais(ln_current_request_id);
   FETCH get_application_detais INTO lv_app_short_name
                                    ,ln_application_id;
   CLOSE get_application_detais;

   OPEN get_template_type(lv_template_code);
   FETCH get_template_type INTO lv_template_type;
   CLOSE get_template_type;

 -- bug 6799553
   OPEN get_printer_details(ln_current_request_id);
   FETCH get_printer_details INTO printer,print_style,number_of_copies,save_output_flag,print_group;
   CLOSE get_printer_details ;

   if(save_output_flag is not NULL ) then
	if(save_output_flag = 'Y') then
	save_output := true;
	elsif(save_output_flag = 'N') then
	save_output := false;
	end if;
   end if;
   result := fnd_request.set_print_options
            (
                printer => printer,
                style => print_style,
                copies => number_of_copies,
                save_output => save_output,
                print_together => print_group
            );
 -- bug 6799553

   pay_archive.remove_report_actions(p_payroll_action_id);

   hr_utility.trace ('ln_current_request_id '|| ln_current_request_id);
   hr_utility.trace ('lv_template_code '|| lv_template_code);
   hr_utility.trace ('ln_application_id '|| ln_application_id);
   hr_utility.trace ('lv_template_type '|| lv_template_type);
--bug 6365474
if(l_release = 12) then

   ln_req_id := fnd_request.submit_request
                            (
                               application    => 'XDO',
                               program        => 'XDOREPPB',
                               argument1      => 'N',
                               argument2      => ln_current_request_id,
                               argument3      => ln_application_id,
                               argument4      => lv_template_code,
                               argument5      => NULL,
                               argument6      => 'N',
                               argument7      => lv_template_type,
                               argument8      => 'PDF'
			     );
   hr_utility.trace ('Leaving 12'|| lv_proc_name);
else
--bug 6365474
   ln_req_id := fnd_request.submit_request
                            (
                               application    => 'XDO',
                               program        => 'XDOREPPB',
                               argument1      => ln_current_request_id,
                               argument2      => ln_application_id,
                               argument3      => lv_template_code,
                               argument4      => NULL,
                               argument5      => 'N',
                               argument6      => lv_template_type,
                               argument7      => 'PDF'
			     );



   hr_utility.trace ('Leaving 11i'|| lv_proc_name);
--bug 6365474
end if;
--bug 6365474

--bug 6670508
delete from pay_us_rpt_totals where tax_unit_id = p_payroll_action_id;
--bug 6670508

end ARCHIVE_DEINIT;

BEGIN
--        hr_utility.trace_on(NULL,'trc_pypaygtn');
        g_proc_name := 'PAY_PAYGTN_PKG.';

END PAY_PAYGTN_PKG;

/
