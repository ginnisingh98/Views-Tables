--------------------------------------------------------
--  DDL for Package Body PYUSDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYUSDAR_PKG" AS
/* $Header: pyusdar.pkb 115.40 2004/06/08 13:21:41 rmonge ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pyusdar.pkb

    Description : Package used for Deposit Advice Report.

    Change List
    -----------
    Date       Name        Vers    Description
    ---------- ----------  ------  -----------------------------------
   08-JUN-04  rmonge       115.40  Changed the name back to pyusdar_pkg for
                                   compatibility reasons in case customers have code
                                   that reference the old name (pyusdar_pkg).
                                   All new changes need to be done to the package
                                   pay_us_deposit_advice_pkg delivered in the file
                                   payuslivearchive.pkh/pkb
                                   DO NOT ADD CHANGES TO THIS FILE.
   20-APR-04  schauhan     115.39  Added date effective join condition to c_paid_actions
                                   Bug 3009643
   20-APR-04  schauhan     115.38  Changed the query for the ref cursor c_paid_actions
                                   in the procedure action_creation and added table
				   pay_org_payment_methods_f to the join condition.
				   Bug 3009643.
   25-FEB-04  schauhan     115.37  Changed the cursor c_paid_actions and
                                   made it a reference cursor.Also used a
				   variable l_db_version to get database version
				   and used this variable in the procedures
				   range_cursor,action_creation,sort_action
				   Bug3331028

   24-FEB-04  schauhan     115.36  Added Comments for the Bug 3331028.
   24-FEB-04  schauhan     115.35  1.Modified the procedures range_cursor,
				     and sort_action to use rule hint only
				     database version<10.0.Bug 3331028
				   2.Added cursor c_paid_actions_no_rule to
				     be used instead of c_paid_actions for DB>=10.0
				     Bug 3331028
   16-JAN-04 rmonge        115.34       Changed the package name to
                                         pay_us_deposit_advice_pkg
   21-JAN_2004 rsethupa    115.33  Bug 3343621 : 11.5.10 Performance changes
   22-OCT-2003 rmonge      115.32  Added the following line to range_cursor
                                   and    pa2.action_type in ('R', 'Q')
                                   Fix for bug 3180193.
   06-Aug-2003 vpandya     115.31  Added exists clause in archive_action_crea..
                                   procedure.
   08-JUL-2003 ahanda      115.30  Fixes bug 3023174.
                                   Changed date track join in action creation.
   17-FEB-2003 tclewis     115.29  Added NOCOPY Directive.
   10-feb-2002 tclewis     115.28  Modified the archive_action_creation code
                                   removing the restriction on assignment_sets
                                   where the payroll_run must also be run by
                                   assignment set. Now all eligible assignments
                                   in assignment_set will be processed in run.
   21-oct-2002 tclewis     115.27  removed the "for Update... " in the
                                   action_creation code and archive action
                                   creation code. Modified the "for update"
                                   clause in the sort code to
                                   paa.assignment_id from paf.assignment_id.
    17-JUL-2002 ahanda     115.26  Added nvl for multi_assignments_flag as
                                   the value will be run for existing payrolls.
   19-mar-2002  irgonzal    115.23 Bug 2264358: Modified archive_action_creation
                                   procedure. Added condition that checks for
                                   multi-assignment flag.
   22-mar-2002  irgonzal    115.24 Added condition to action creation cursor
                                   to ensure it checks if deposit advice needs
                                   to be generated.Added pay_us_employee_payslip
                                   _web.get_doc_eit function.
   23-apr-2002  tclewis     115.25 Modified the arcive_action_creation action_cursor
                                   joined the OR condition to XFR --> PRE  to pay_payrolls_f
    17-JAN-2002 TCLEWIS    115.19  ADDED PROCEDURE AND CODE for procedure
                                   ARCHIVE_ACTION_CREATION for the new
                                   additional deposit advice report that
                                   runs off the external process archive
                                   data.
    12-DEC-2001 asasthan   115.18  Aded dbdrv
    30-NOV-2001 asasthan   115.17  Changed  c_actions_zero_pay
                                   Added Join of payroll_id and
                                   consolidation set id to fix
                                   BUG 2122721
    03-AUG-2001 ahanda     115.16  Changed Sort cursor to take care of
                                   terminated assignments.
                                   Bug 1918164.
    24-JUL-2001 asasthan   115.15  Till 115.14 both regular salary
                                   and an element set up as separate check
                                   were printing only one deposit advice.
                                   Modified action creation cursor to
                                   achieve this functonality.
                                   This version of package will
                                   be in sync with report version
                                   115.28 onwards.
    02-JAN-2001 ahanda     115.14  Uncommented whenever sqlerror
    02-JAN-2001 ahanda     115.13  Added RULE Hint.
    31-OCT-2000 tclewis    115.11  Modifed the c_actions_zero_pay
                                   cursor changing the following code.
                                   and    ppa_mag_pmts.payroll_id =
                                    NVL(pyusdar_pkg.get_parameter('PAYROLL_ID',
                                          ppa_dar.legislative_parameters),
                                          ppa_mag_pmts.payroll_id)
                                   To:
                                    and    (ppa_mag_pmts.payroll_id =
                                        pyusdar_pkg.get_parameter('PAYROLL_ID',
                                            ppa_dar.legislative_parameters)
                                    or pyusdar_pkg.get_parameter('PAYROLL_ID',
                                            ppa_dar.legislative_parameters)
                                            is null)

   31-AUG-2000  tclewis     115.8  Added a second cursor to the Action_creation
                                   procedure to pick up assignments with
                                   zero net pay.
   15-OCT-1999  mreid       115.7  Changed not equal usage for compliance.
   25-JUL-1999  nbristow    40.6   Changed c_actions cursor to retrive
                                   assignments to be processed when a
                                   payroll is not specified.
   24-JUN-1999  mcpham      115.5  Modified c_actions cursor, added
                                   c_get_locked_action cursor and some
                                   codes in prodedure action_creation.
   18-jun-1999  achauhan    115.4  replaced dbms-output with hr_utility.trace
   18-MAR-1999  kkawol      110.1  Added get_parameter.
   05-JAN-1999  kkawol      110.0  Created
*/
----------------------------------- range_cursor ----------------------------------
--
procedure range_cursor (pactid in number, sqlstr out NOCOPY varchar2) is
  l_payroll_id number;
  leg_param    pay_payroll_actions.legislative_parameters%type;

  --Bug 3331028
  l_db_version varchar2(20);
--

begin
   select legislative_parameters
     into leg_param
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;
--
   l_payroll_id :=    pyusdar_pkg.get_parameter('PAYROLL_ID', leg_param);
--
--Database Version --Bug 3331028

  if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
	l_db_version := '/*+ RULE */';
  else
	l_db_version := '/* NO RULE*/';
  end if;
--
   if l_payroll_id is not null then
--Bug 3331028-- Rule hint is used only for database version < 10.0
   	      sqlstr := 'select '||l_db_version||' distinct pos.person_id
			from    pay_assignment_actions act,
				per_assignments_f      asg,
				per_periods_of_service pos,
				pay_payroll_actions    pa2,
				pay_payroll_actions    pa1
			 where  pa1.payroll_action_id    = :payroll_action_id
			 and    pa2.action_type in (''R'',''Q'')
			 and    pa2.consolidation_set_id =
				  pyusdar_pkg.get_parameter(''CONSOLIDATION_SET_ID'',
					 pa1.legislative_parameters)
			 and    pa2.payroll_id           =
				  pyusdar_pkg.get_parameter(''PAYROLL_ID'',
					  pa1.legislative_parameters)
			 and    pa2.effective_date between
				pa1.start_date and pa1.effective_date
			 and    act.payroll_action_id    = pa2.payroll_action_id
			 and    asg.assignment_id        = act.assignment_id
			 and    pa2.effective_date between
				asg.effective_start_date and asg.effective_end_date
			 and    pos.period_of_service_id = asg.period_of_service_id
			order by pos.person_id';

--
   else
--
      --Bug 3331028-- Rule hint is used only for database version < 10.0
	     sqlstr := 'select '||l_db_version||' distinct pos.person_id
		     from    pay_assignment_actions act,
			       per_assignments_f      asg,
			       per_periods_of_service pos,
			       pay_payroll_actions    pa2,
			       pay_payroll_actions    pa1
			where  pa1.payroll_action_id    = :payroll_action_id
			and    pa2.consolidation_set_id =
				  pyusdar_pkg.get_parameter(''CONSOLIDATION_SET_ID'',
					 pa1.legislative_parameters)
			and    pa2.effective_date between
			       pa1.start_date and pa1.effective_date
			and    act.payroll_action_id    = pa2.payroll_action_id
			and    asg.assignment_id        = act.assignment_id
			and    pa2.effective_date between
			       asg.effective_start_date and asg.effective_end_date
			and    pos.period_of_service_id = asg.period_of_service_id
			order by pos.person_id';
--
  end if;
end range_cursor;


 -------------------------- action_creation ---------------------------------
 PROCEDURE action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is
--Bug 3331028
  l_db_version varchar2(20);
  l_paid_actions varchar2(4000);

  TYPE PaidActions is REF CURSOR;
  c_paid_actions PaidActions;
--

 CURSOR c_actions_zero_pay
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions         act,
             per_all_assignments_f          paf1,
             per_all_assignments_f          paf2,
             per_periods_of_service         pos,
             pay_payroll_actions            ppa_dar,
             pay_payroll_actions            ppa_mag_pmts,
             pay_payrolls_f                 pay  --Bug 3343621
      where ( ppa_dar.payroll_action_id          = pactid
      and     ppa_mag_pmts.consolidation_set_id +0
              = pyusdar_pkg.get_parameter('CONSOLIDATION_SET_ID',
                ppa_dar.legislative_parameters)
         and    ppa_mag_pmts.effective_date between ppa_dar.start_date
                                                and ppa_dar.effective_date
         and    act.payroll_action_id          = ppa_mag_pmts.payroll_action_id
         and    act.action_status              = 'C'
         and    ppa_mag_pmts.action_type            in ('P', 'U')
         and    ppa_mag_pmts.payroll_id  = pay.payroll_id  --Bug 3343621
         and    ppa_mag_pmts.effective_date between
                pay.effective_start_date and pay.effective_end_date --Bug 3343621
         and    pay.payroll_id >= 0  --Bug 3343621
         and    paf1.assignment_id              = act.assignment_id
         and    ppa_mag_pmts.effective_date between
                paf1.effective_start_date and paf1.effective_end_date
         and    paf2.assignment_id              = act.assignment_id
         and    ppa_mag_pmts.effective_date between
                paf2.effective_start_date and paf2.effective_end_date
         and    paf2.payroll_id + 0             = paf1.payroll_id + 0
         and    pos.period_of_service_id       = paf1.period_of_service_id
         and    pos.person_id between stperson and endperson
         and   (paf1.payroll_id =
                     pyusdar_pkg.get_parameter('PAYROLL_ID',
                                               ppa_dar.legislative_parameters)
              or pyusdar_pkg.get_parameter('PAYROLL_ID',
                                             ppa_dar.legislative_parameters)
                 is null)
--  No run results.
         AND   NOT EXISTS (SELECT ' '
                          FROM  pay_pre_payments ppp,
                                pay_org_payment_methods_f popm
                          WHERE ppp.assignment_action_id = act.assignment_action_id
                          and    ppp.org_payment_method_id = popm.org_payment_method_id
                          and    popm.defined_balance_id IS NOT NULL)
-- and is not a reversal.
         AND NOT EXISTS
          (
                  Select  ''
                    from pay_action_interlocks   int2,
                         pay_action_interlocks   int4,
                         pay_assignment_actions  paa4,
                         pay_payroll_actions     ppa_run,  --- RUN
                         pay_payroll_actions     pact4,  --- Reversal
                         pay_assignment_actions  paa_run  --- RUN
                   where
                         int2.locking_action_id   = act.assignment_action_id  -- prepayment action
                   and   int2.locked_action_id  = paa_run.assignment_action_id
                   and   paa_run.payroll_action_id = ppa_run.payroll_action_id
                   and   ppa_run.action_type in ('R', 'Q')
                   and   paa_run.assignment_action_id = int4.locked_action_id
                   and   int4.locking_action_id = paa4.assignment_action_id
                   and   pact4.payroll_action_id = paa4.payroll_action_id
                   and   pact4.action_type       = 'V'
              )
              )
      order by pos.person_id, act.assignment_id DESC;
--      for update of paf1.assignment_id, pos.period_of_service_id;

   /*****************************************************************
   ** This cursor solves problem when there are multiple pre-payments
   ** and multiple assignment actions , in this case we only want 1
   ** assignment action for each pre-payment (bug 890222)
   *****************************************************************/
   cursor c_pre_payments (cp_nacha_action_id in number) is
     select locked_action_id
       from pay_action_interlocks pai
      where pai.locking_action_id = cp_nacha_action_id;

   cursor c_payroll_run (cp_pre_pymt_action_id in number) is
     select assignment_action_id
       from pay_action_interlocks pai,
            pay_assignment_actions paa
      where pai.locking_action_id = cp_pre_pymt_action_id
        and paa.assignment_Action_id = pai.locked_action_id
        and paa.run_type_id is null
     order by action_sequence desc;

   /*****************************************************************
   ** This cursor will get all the source actions for which the
   ** assignment should get a deposit advice.
   ** assignment action for each pre-payment (bug 890222) i.e.
   ** Seperate Depsoit Advice for Seperate Check and Regular Run
   *****************************************************************/
   cursor c_payments (cp_pre_pymt_action_id in number,
                      cp_effective_date     in date) is
     select distinct ppp.source_action_id
       from pay_pre_payments ppp,
            pay_personal_payment_methods_f pppm
      where ppp.assignment_action_id = cp_pre_pymt_action_id
        and pppm.personal_payment_method_id = ppp.personal_payment_method_id
        and pppm.external_account_id is not null
        and cp_effective_date between pppm.effective_start_date
                                  and pppm.effective_end_date
        and nvl(ppp.value,0) <> 0
      order by ppp.source_action_id;

   ln_nacha_action_id         NUMBER;
   ln_deposit_action_id       NUMBER;

   ln_assignment_id           NUMBER;
   ln_tax_unit_id             NUMBER;
   ld_effective_date          DATE;

   ln_pre_pymt_action_id      NUMBER;
   ln_prev_pre_pymt_action_id NUMBER := null;

   ln_source_action_id        NUMBER;
   ln_prev_source_action_id   NUMBER := null;

   ln_master_action_id        NUMBER;

  BEGIN

     --hr_utility.trace_on(null, 'DAR');
     hr_utility.set_location('procdar',1);

-- Database Version --Bug 3331028
	if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
		l_db_version := '/*+ RULE */';
	  else
		l_db_version := '/* NO RULE*/';
	end if;
--

-- Query string for the reference cursor c_paid_actions --Bug 3331028
  l_paid_actions := 'select '||l_db_version||' act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppa_mag.effective_date
      from   pay_assignment_actions         act,
             per_all_assignments_f          paf1,
             per_all_assignments_f          paf2,
             per_periods_of_service         pos,
             pay_payroll_actions            ppa_dar,
             pay_payroll_actions            ppa_mag,
	     pay_org_payment_methods_f      popm                        --Bug 3009643
      where  ppa_dar.payroll_action_id          = :pactid
      and    ppa_mag.consolidation_set_id +0    =
                          pyusdar_pkg.get_parameter(''CONSOLIDATION_SET_ID'',
                                 ppa_dar.legislative_parameters)
      and    ppa_mag.effective_date between
                   ppa_dar.start_date and ppa_dar.effective_date
      and    act.payroll_action_id          = ppa_mag.payroll_action_id
      and    act.action_status              = ''C''
      and    ppa_mag.action_type            = ''M''
      and    ppa_mag.org_payment_method_id  = popm.org_payment_method_id -- Bug 3009643
      and    popm.defined_balance_id  is not null                        -- Bug 3009643
      and    ppa_mag.effective_date between
             popm.effective_start_date and popm.effective_end_date --Bug 3009643
      and    paf1.assignment_id              = act.assignment_id
      and    ppa_mag.effective_date between
             paf1.effective_start_date and paf1.effective_end_date
      and    paf2.assignment_id              = act.assignment_id
      and    ppa_dar.effective_date between
             paf2.effective_start_date and paf2.effective_end_date
      and    paf2.payroll_id + 0             = paf1.payroll_id + 0
      and    pos.period_of_service_id       = paf1.period_of_service_id
      and    pos.person_id between :stperson and :endperson
      and   (paf1.payroll_id =
                     pyusdar_pkg.get_parameter(''PAYROLL_ID'',
                                               ppa_dar.legislative_parameters)
              or pyusdar_pkg.get_parameter(''PAYROLL_ID'',
                                             ppa_dar.legislative_parameters)
                 is null)
      and    not exists
             (
               Select  ''''
                 from pay_action_interlocks   int2,
                      pay_action_interlocks   int3,
                      pay_assignment_actions  paa4,
                      pay_payroll_actions     ppa_run,  --- RUN
                      pay_payroll_actions     pact4,  --- Reversal
                      pay_assignment_actions  paa_run,  --- RUN
                      pay_assignment_actions  paa_pp   --- PREPAY
                where
                      int3.locked_action_id   = act.assignment_action_id
                and   int3.locking_action_id  = paa_pp.assignment_action_id
                and   int2.locked_action_id   = paa_pp.assignment_action_id
                and   int2.locking_action_id   = paa_run.assignment_action_id
                and   paa_run.payroll_action_id = ppa_run.payroll_action_id
                and   ppa_run.action_type in (''R'', ''Q'')
                and   paa_run.assignment_action_id = int3.locked_action_id
                and   int3.locking_action_id = paa4.assignment_action_id
                and   pact4.payroll_action_id = paa4.payroll_action_id
                and   pact4.action_type       = ''V''
              )
      order by pos.person_id, act.assignment_id DESC';
--      for update of paf1.assignment_id, pos.period_of_service_id;
--

-- Reference cursor opened for the query string l_paid_actions --Bug 3331028
	     open c_paid_actions for  l_paid_actions using pactid, stperson, endperson;
--
	     loop
        hr_utility.set_location('procdar',2);
        fetch c_paid_actions into ln_nacha_action_id, ln_assignment_id,
                                  ln_tax_unit_id, ld_effective_date;
        exit WHEN c_paid_actions%NOTFOUND;
        hr_utility.trace(' c_paid_actions.ln_nacha_action_id is'
                 ||to_char(ln_nacha_action_id));
        open c_pre_payments (ln_nacha_action_id);
        fetch c_pre_payments into ln_pre_pymt_action_id;
        hr_utility.trace(' c_pre_payments.ln_pre_pymt_action_id is'
                 ||to_char(ln_pre_pymt_action_id));
        close c_pre_payments;

        /**************************************************************************
        ** we need to insert atleast one action for each of the rows that we
        ** return from the cursor (i.e. one for each assignment/pre-payment action).
        **************************************************************************/
        hr_utility.trace(' ln_prev_pre_pymt_action_id is'
                 ||to_char(ln_prev_pre_pymt_action_id));
        if (ln_prev_pre_pymt_action_id is null or
            ln_prev_pre_pymt_action_id <> ln_pre_pymt_action_id) then
           open c_payments (ln_pre_pymt_action_id, ld_effective_date);
           loop
              hr_utility.set_location('procdar',99);
              fetch c_payments into ln_source_action_id;
                hr_utility.trace(' ln_source_action_id is'
                 ||to_char(ln_source_action_id));

              hr_utility.set_location('procdar',98);
              if c_payments%notfound then
                 exit;
              end if;
              hr_utility.set_location('procdar',97);

              /**************************************************************
              ** we need to insert one action for each of the rows that we
              ** return from the cursor (i.e. one for each assignment/pre-payment source).
              **************************************************************/
                hr_utility.trace(' ln_prev_source_action_id is'
                 ||to_char(ln_prev_source_action_id));
              if (ln_prev_source_action_id is null or
                  ln_source_action_id <> ln_prev_source_action_id or
                  ln_source_action_id is null) then

                 hr_utility.set_location('procdar',3);
                 select pay_assignment_actions_s.nextval
                   into ln_deposit_action_id
                   from dual;

                 -- insert the action record.
                 hr_nonrun_asact.insact(ln_deposit_action_id,
                                        ln_assignment_id,
                                        pactid, chunk, ln_tax_unit_id);
                     hr_utility.trace('Inserted into paa');
                 -- insert an interlock to this action.
                 hr_nonrun_asact.insint(ln_deposit_action_id, ln_nacha_action_id);

                     hr_utility.trace('Inserted into interlock');
                 if ln_source_action_id is not null then
                    hr_utility.trace('serial number updated if loop ');
                    hr_utility.trace('serial number is '||to_char(ln_source_action_id));
                    update pay_assignment_Actions
                       set serial_number = 'P'||ln_source_action_id
                       --set serial_number = ln_source_action_id
                     where assignment_action_id = ln_deposit_action_id;
                 else
                    hr_utility.trace('serial number else ');
                    open c_payroll_run (ln_pre_pymt_action_id);
                    fetch c_payroll_run into ln_master_action_id;
                    close c_payroll_run;
                  hr_utility.trace(' ln_master_action_id is'
                 ||to_char(ln_master_action_id));

                    update pay_assignment_Actions
                       set serial_number = 'M'||ln_master_action_id
                       --set serial_number = ln_master_action_id
                     where assignment_action_id = ln_deposit_action_id;
                 end if;

                 -- skip till next source action id
                 ln_prev_source_action_id := ln_source_action_id;
              end if;
           end loop;
           close c_payments;
           ln_prev_pre_pymt_action_id := ln_pre_pymt_action_id;

        end if;
     end loop;
     close c_paid_actions;

     hr_utility.set_location('procdar',4);
     ln_prev_pre_pymt_action_id := null;
     open c_actions_zero_pay(pactid,stperson,endperson);

     loop
        hr_utility.set_location('procdar',5);
        fetch c_actions_zero_pay INTO ln_nacha_action_id, --gives P,U
                                      ln_assignment_id,
                                      ln_tax_unit_id;
        exit WHEN c_actions_zero_pay%NOTFOUND;
        hr_utility.trace(' NZ PrePayment Id is' ||to_char(ln_nacha_action_id));

        open c_pre_payments (ln_nacha_action_id); --gives me R,Q
        fetch c_pre_payments into ln_pre_pymt_action_id;
        close c_pre_payments;

        hr_utility.trace(' NZ Run ActionId is' ||to_char(ln_pre_pymt_action_id));
        hr_utility.trace(' NZ ln_prev_pre_pymt_action_id is' ||to_char(ln_prev_pre_pymt_action_id));

        if (ln_prev_pre_pymt_action_id is null or
            ln_prev_pre_pymt_action_id <> ln_pre_pymt_action_id) then

           hr_utility.set_location('procdar',6);
           select pay_assignment_actions_s.nextval
             into ln_deposit_action_id
             from dual;

           -- insert the action record.
           hr_nonrun_asact.insact(ln_deposit_action_id,
                                  ln_assignment_id,
                                  pactid, chunk, ln_tax_unit_id);

           -- insert an interlock to this action.
           hr_nonrun_asact.insint(ln_deposit_action_id, ln_nacha_action_id);
           hr_utility.trace(' NZ Inserted into paa');

           open c_payroll_run (ln_nacha_action_id);
           fetch c_payroll_run into ln_master_action_id;
           hr_utility.trace(' NZ ln_master_action_id is'
                 ||to_char(ln_master_action_id));
           close c_payroll_run;

           update pay_assignment_Actions
              set serial_number = 'M'||ln_master_action_id
            where assignment_action_id = ln_deposit_action_id;

           -- skip till next pre payment action id
           ln_prev_pre_pymt_action_id := ln_pre_pymt_action_id;

        end if;

     end loop;
     close c_actions_zero_pay;

 END action_creation;


 -------------------------- action_creation ---------------------------------
 PROCEDURE archive_action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is
  CURSOR c_paid_actions
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is
   select
           paa_xfr.assignment_action_id,
           paa_xfr.assignment_id,
           paa_xfr.tax_unit_id
   from per_assignments_f paf,
        pay_payroll_actions ppa_dar,
        pay_payroll_actions ppa_run,
        pay_assignment_actions paa_run,
        pay_action_interlocks pai_pre,
        pay_action_interlocks pai_run,
        pay_assignment_actions paa_xfr,
        pay_payroll_actions ppa_xfr
      , pay_payrolls_f      pay -- #2264358
  where ppa_dar.payroll_action_id = pactid
    and ppa_xfr.report_type = 'XFR_INTERFACE'
    and ppa_dar.effective_date between ppa_xfr.start_date
                                   and ppa_xfr.effective_date
    and pyusdar_pkg.get_parameter('CONSOLIDATION_SET_ID',
                 ppa_dar.legislative_parameters) =
           pyusdar_pkg.get_parameter('CONSOLIDATION_SET_ID',
                     ppa_xfr.legislative_parameters)
    and paa_xfr.payroll_action_id = ppa_xfr.payroll_action_id
    and pai_pre.locking_action_id = paa_xfr.assignment_action_id
    /* PRE => RUN */
    and (      paa_xfr.source_action_id is null
           and pai_run.locking_action_id = pai_pre.locked_action_id
           and paa_run.assignment_action_id = pai_run.locked_action_id
           and paa_run.source_action_id is null
           and ppa_run.payroll_action_id = paa_run.payroll_action_id
           and ppa_run.action_type in ('R', 'Q')
           -- *****************************************************************
           -- #2264358
           and ppa_run.payroll_id = pay.payroll_id
           and ppa_dar.effective_date between pay.effective_start_date
                                          and pay.effective_end_date
           and pay.payroll_id >= 0   --Bug 3343621
           and ((pay.multi_assignments_flag = 'Y' and
                 paa_run.assignment_action_id =
                  (select min(paa.assignment_action_id)
                    from pay_assignment_actions paa
                    where paa.assignment_action_id in (
                                   select locked_action_id
                                     from pay_action_interlocks
                                    where locking_action_id = pai_run.locking_action_id)
                      and paa.source_action_id is null
                  )
                 )
               OR
                 (nvl(pay.multi_assignments_flag, 'N') = 'N')
               )
           -- ***************************************************************
         OR
               paa_xfr.source_action_id is not null
           and substr(paa_xfr.serial_number,3,length(paa_xfr.serial_number)) =
                    paa_run.assignment_action_id
           and pai_run.locking_action_id = pai_pre.locked_action_id
           and paa_run.assignment_action_id = pai_run.locked_action_id
           and ppa_run.payroll_action_id = paa_run.payroll_action_id
           and ppa_run.action_type in ('R', 'Q')
           and ppa_run.payroll_id = pay.payroll_id
           and ppa_run.effective_date between pay.effective_start_date
                                      and pay.effective_end_date
           and pay.payroll_id >= 0   --Bug 3343621
         )
    /* XFR => PRE */
    and exists ( select 'Y'
                 from pay_action_interlocks pai_mag,
                      pay_assignment_actions paa_mag,
                      pay_payroll_actions    ppa_mag
                 where pai_mag.locked_action_id  = pai_pre.locked_action_id
                 and   pai_mag.locking_Action_id = paa_mag.assignment_action_id
                 and   paa_mag.payroll_action_id = ppa_mag.payroll_action_id
                 and   ppa_mag.action_type       = 'M'
                 and   ppa_mag.effective_date between ppa_dar.start_date
                        and ppa_dar.effective_date
                 and ppa_mag.consolidation_set_id +0    =
                        pyusdar_pkg.get_parameter('CONSOLIDATION_SET_ID',
                                   ppa_dar.legislative_parameters)
                )
    and paa_xfr.assignment_id = paf.assignment_id
    and    ppa_dar.effective_date between
                paf.effective_start_date and paf.effective_end_date
    and (
          paf.payroll_id = pyusdar_pkg.get_parameter('PAYROLL_ID',
                           ppa_dar.legislative_parameters)
    or    pyusdar_pkg.get_parameter('PAYROLL_ID',
                    ppa_dar.legislative_parameters)   is null
        )

and paf.person_id between stperson and endperson
  and  not exists
             (
               Select  ''
                 from pay_action_interlocks   int2,
                      pay_action_interlocks   int3,
                      pay_assignment_actions  paa4,
                      pay_payroll_actions     ppa_run,  --- RUN
                      pay_payroll_actions     pact4,  --- Reversal
                      pay_assignment_actions  paa_run  --- RUN
                where int2.locked_action_id   = pai_pre.locked_action_id
                and   int2.locking_action_id   = paa_run.assignment_action_id
                and   paa_run.payroll_action_id = ppa_run.payroll_action_id
                and   ppa_run.action_type in ('R', 'Q')
                and   paa_run.assignment_action_id = int3.locked_action_id
                and   int3.locking_action_id = paa4.assignment_action_id
                and   pact4.payroll_action_id = paa4.payroll_action_id
                and   pact4.action_type       = 'V'
              )
/* ONLINE or PRINT ? */
and pay_us_employee_payslip_web.get_doc_eit('PAYSLIP','PRINT'
                        ,'ASSIGNMENT',paf.assignment_id,ppa_dar.effective_date) = 'Y'
   and exists ( select 1
                from   pay_action_information pai
                where  pai.action_context_id = paa_xfr.assignment_action_id
                  and  rownum < 2 ) --Bug 3343621
 order by paf.person_id, paf.assignment_id DESC;
-- for update of paf.assignment_id;

  CURSOR c_actions_zero_pay
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is
   select
           paa_xfr.assignment_action_id,
           paa_xfr.assignment_id,
           paa_xfr.tax_unit_id
   from per_assignments_f paf,
        pay_payroll_actions ppa_dar,
        pay_payroll_actions ppa_run,
        pay_payroll_actions ppa_pre,
        pay_action_interlocks pai_pre,
        pay_action_interlocks pai_run,
        pay_assignment_actions paa_xfr,
        pay_assignment_actions paa_pre,
        pay_assignment_actions paa_run,
        pay_payroll_actions ppa_xfr
      , pay_payrolls_f      pay -- #2264358
   where ppa_dar.payroll_action_id          = pactid
    and pyusdar_pkg.get_parameter('CONSOLIDATION_SET_ID',
                 ppa_dar.legislative_parameters) =
           pyusdar_pkg.get_parameter('CONSOLIDATION_SET_ID',
                     ppa_xfr.legislative_parameters)
    and ppa_xfr.report_type = 'XFR_INTERFACE'
    and ppa_dar.effective_date between ppa_xfr.start_date
                                   and ppa_xfr.effective_date
    and paa_xfr.payroll_action_id = ppa_xfr.payroll_action_id
    and pai_pre.locking_action_id = paa_xfr.assignment_action_id
    and paa_pre.assignment_action_id = pai_pre.locked_action_id
    and ppa_pre.payroll_action_id = paa_pre.payroll_action_id
    and ppa_pre.action_type in ('P', 'U')
    and ppa_pre.consolidation_set_id +0 =
                    pyusdar_pkg.get_parameter('CONSOLIDATION_SET_ID',
                            ppa_dar.legislative_parameters)
    /* PRE => RUN */
    and pai_run.locking_action_id = pai_pre.locked_action_id
    and paa_run.assignment_action_id = pai_run.locked_action_id
    and paa_run.source_action_id is null
    and ppa_run.payroll_action_id = paa_run.payroll_action_id
    and ppa_run.action_type in ('R', 'Q')
    -- **********************************************************************
    -- #2264358
    and ppa_run.payroll_id = pay.payroll_id
    and ppa_dar.effective_date between pay.effective_start_date
                                   and pay.effective_end_date
    and pay.payroll_id >= 0   --Bug 3343621
    and ((pay.multi_assignments_flag = 'Y' and
          paa_run.assignment_action_id =
                  (select min(paa.assignment_action_id)
                    from pay_assignment_actions paa
                    where paa.assignment_action_id in (select locked_action_id
                                                     from pay_action_interlocks
                                                     where locking_action_id = pai_run.locking_action_id)
                    and paa.source_action_id is null
                  )
          )
        OR
          (nvl(pay.multi_assignments_flag, 'N') = 'N')
        )
    -- **********************************************************************
    and not exists (select ' '
                    from pay_pre_payments ppp
                    where ppp.assignment_action_id = pai_pre.locked_action_id
                   )

    /* XFR => PRE */
    and paa_xfr.assignment_id = paf.assignment_id
    and    ppa_dar.effective_date between
                paf.effective_start_date and paf.effective_end_date
    and (
          paf.payroll_id = pyusdar_pkg.get_parameter('PAYROLL_ID',
                           ppa_dar.legislative_parameters)
    or    pyusdar_pkg.get_parameter('PAYROLL_ID',
                    ppa_dar.legislative_parameters)   is null
        )

  and paf.person_id between stperson and endperson
  and  not exists
             (
               Select  ''
                 from pay_action_interlocks   int2,
                      pay_action_interlocks   int3,
                      pay_assignment_actions  paa4,
                      pay_payroll_actions     ppa_run,  --- RUN
                      pay_payroll_actions     pact4,  --- Reversal
                      pay_assignment_actions  paa_run  --- RUN
                where int2.locking_action_id   = pai_pre.locked_action_id
                and   int2.locked_action_id   = paa_run.assignment_action_id
                and   paa_run.payroll_action_id = ppa_run.payroll_action_id
                and   ppa_run.action_type in ('R', 'Q')
                and   paa_run.assignment_action_id = int3.locked_action_id
                and   int3.locking_action_id = paa4.assignment_action_id
                and   pact4.payroll_action_id = paa4.payroll_action_id
                and   pact4.action_type       = 'V'
              )
/* ONLINE or PRINT ? */
and pay_us_employee_payslip_web.get_doc_eit('PAYSLIP','PRINT'
                        ,'ASSIGNMENT',paf.assignment_id,ppa_dar.effective_date) = 'Y'
and exists ( select 1
             from   pay_action_information pai
              where  pai.action_context_id = paa_xfr.assignment_action_id
                and  pai.action_context_type not in ('AAP')
                and  pai.action_information_category not in ('EMPLOYEE NET PAY DISTRIBUTION')
           )
 order by paf.person_id, paa_xfr.assignment_id DESC;
-- for update of paf.assignment_id;


   ln_nacha_action_id         NUMBER;
   ln_deposit_action_id       NUMBER;

   ln_assignment_id           NUMBER;
   ln_tax_unit_id             NUMBER;
   ld_effective_date          DATE;

   ln_pre_pymt_action_id      NUMBER;
   ln_prev_pre_pymt_action_id NUMBER := null;

   ln_source_action_id        NUMBER;
   ln_prev_source_action_id   NUMBER := null;

   ln_master_action_id        NUMBER;

   ass_set_id                 NUMBER;
   ass_flag                   VARCHAR2(1);

   l_legislative_parameters   varchar2(2000);


  BEGIN
     select legislative_parameters
     into l_legislative_parameters
     from pay_payroll_actions
     where payroll_action_id = pactid;

     ass_set_id := pyusdar_pkg.get_parameter('ASG_SET_ID',
                         l_legislative_parameters);

     --hr_utility.trace_on(null, 'DAR');
     hr_utility.set_location('procdar archive',1);
     open c_paid_actions(pactid, stperson, endperson);
     loop
        hr_utility.set_location('procdar archive',2);

        ass_flag := 'N';

        fetch c_paid_actions into ln_nacha_action_id, ln_assignment_id,
                                  ln_tax_unit_id;
        exit WHEN c_paid_actions%NOTFOUND;

        ass_flag :=  hr_assignment_set.assignment_in_set(ass_set_id,ln_assignment_id);

        IF ass_flag = 'Y' THEN
              hr_utility.trace(' c_paid_actions.ln_nacha_action_id is'
                 ||to_char(ln_nacha_action_id));

               hr_utility.set_location('procdar archive',3);
               select pay_assignment_actions_s.nextval
               into ln_deposit_action_id
               from dual;

               -- insert the action record.
               hr_nonrun_asact.insact(ln_deposit_action_id,
                                      ln_assignment_id,
                                      pactid, chunk, ln_tax_unit_id);
               hr_utility.trace('Inserted into paa');
               -- insert an interlock to this action.
               hr_nonrun_asact.insint(ln_deposit_action_id, ln_nacha_action_id);

               update pay_assignment_Actions
               set serial_number = ln_nacha_action_id
               where assignment_action_id = ln_deposit_action_id;

         END IF;

     end loop;
     close c_paid_actions;

    --
      hr_utility.set_location('procdar archive',4);
     ln_prev_pre_pymt_action_id := null;
     open c_actions_zero_pay(pactid,stperson,endperson);

     loop
        hr_utility.set_location('procdar archive',5);

        ass_flag := 'N';

        fetch c_actions_zero_pay INTO ln_nacha_action_id, --gives P,U
                                      ln_assignment_id,
                                      ln_tax_unit_id;
        exit WHEN c_actions_zero_pay%NOTFOUND;
        hr_utility.trace(' NZ PrePayment Id is' ||to_char(ln_nacha_action_id));

          hr_utility.set_location('procdar archive',3);

          ass_flag :=  hr_assignment_set.assignment_in_set(ass_set_id,ln_assignment_id);

          IF ass_flag = 'Y' THEN

              select pay_assignment_actions_s.nextval
              into ln_deposit_action_id
              from dual;

              -- insert the action record.
              hr_nonrun_asact.insact(ln_deposit_action_id,
                                     ln_assignment_id,
                                     pactid, chunk, ln_tax_unit_id);

               -- insert an interlock to this action.
               hr_nonrun_asact.insint(ln_deposit_action_id, ln_nacha_action_id);
               hr_utility.trace(' NZ Inserted into paa');

                update pay_assignment_Actions
                  set serial_number = ln_nacha_action_id
                where assignment_action_id = ln_deposit_action_id;
           END IF;

     end loop;
     close c_actions_zero_pay;


 END archive_action_creation;


---------------------------------- sort_action ----------------------------------
procedure sort_action
(
   procname   in     varchar2,     /* name of the select statement to use */
   sqlstr     in out NOCOPY varchar2,     /* string holding the sql statement */
   len        out    NOCOPY number        /* length of the sql string */
) is

--Bug 3331028
l_db_version varchar2(20);
--

begin
      -- go through each of the sql sub strings and see if
      -- they are needed.
-- Databse Version --Bug 3331028
  if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
	l_db_version := '/*+ RULE */';
  else
	l_db_version := '/* NO RULE*/';
  end if;
--
--Bug 3331028-- Rule hint is used only for database version < 10.0
		 sqlstr := 'select '||l_db_version||' paa.rowid
			     from hr_all_organization_units  hou,
				   per_all_people_f           ppf,
				   per_all_assignments_f      paf,
				   pay_assignment_actions paa,
				   pay_payroll_actions    ppa
			     where ppa.payroll_action_id = :pactid
			       and paa.payroll_action_id = ppa.payroll_action_id
			       and paa.assignment_id     = paf.assignment_id
			       and paf.effective_start_date =
				     (select max(paf1.effective_start_date)
					from per_all_assignments_f paf1
				       where paf1.assignment_id = paf.assignment_id
					 and paf1.effective_start_date <= ppa.effective_date
					 and paf1.effective_end_date >= ppa.start_date
				      )
			       and paf.person_id = ppf.person_id
			       and ppa.effective_date between ppf.effective_start_date
							  and ppf.effective_end_date
			       and hou.organization_id = nvl(paf.organization_id, paf.business_group_id)
			    order by hou.name,ppf.last_name,ppf.first_name
			   for update of paa.assignment_id';
          len := length(sqlstr); -- return the length of the string.
end sort_action;
--
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
     end_ptr := instr(parameter_list, ' ', start_ptr);
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
--
end pyusdar_pkg;

/
