--------------------------------------------------------
--  DDL for Package Body PYCADAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYCADAR_PKG" as
/* $Header: pycadar.pkb 120.1.12000000.1 2007/01/17 16:51:37 appldev noship $ */
/*
--
rem +======================================================================+
rem |                Copyright (c) 1993 Oracle Corporation                 |
rem |                   Redwood Shores, California, USA                    |
rem |                        All rights reserved.                          |
rem +======================================================================+
   Name        :pycadar
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   03-JUN-1999  mmukherj    110.0  Created
   07-AUG-2000  mmukherj    115.1  Taken out serveroutput on and dbms_output
   23-MAR-2001  vpandya     115.2  Added get_labels function with three
                                   input parameters.
   09-MAY-2002  vpandya     115.4  Both Regular Salary and an element set up as
                                   separate check like Bonus were printing only
                                   one deposit advice.
                                   Modified action creation cursor to
                                   achieve this functonality.
   12-JUN-2002  vpandya     115.5  For Multiple Assignment Payment functionality
                                   Added procedure archive_action_creation that
                                   will create assignment action when Canadian
                                   Deposit Advice is run for Archiver.
   17-JUL-2002  vpandya     115.6  Changed archive_action_creation and replaced
                                   pay.multi_assignments_flag with
                                   nvl(pay.multi_assignments_flag,'N') in SQL.
   20-SEP-2002  pganguly    115.7  Changed the cursor c_actions, added
                                   pay_payrolls_f in the from list. Added a NVL
                                   in the where clause so if the payroll is not
                                   passed then join to the ppa_mag.payroll_id.
                                   Also joined the consolidation id passed with
                                   consolidation_id of the pay_payrolls_f.
   21-SEP-2002  pganguly    115.8  Added whenever oserror ...
   04-NOV-2002  pganguly    115.9  Fixed Bug# 2579614. Added code in the range
                                   cursor/assignment_action_creation so that
                                   if assignment set is passed then it prints
                                   'Deposit Advice' for those assignments only.
   27-Jan-2003  vpandya     115.10 Fixed Bug# 2763252. Modified action_creation
                                   and added condtion to check payroll id of
                                   pay_payrolls_f if payroll id is null for
                                   Direct Deposit(when Direct Deposit is run by
                                   consolidation set only), so Deposit advice
                                   should work for consolidation set only or
                                   consolidation set along with payroll.
   27-Jan-2003  vpandya     115.11 Added nocopy with out parameter as per gscc.
   25-Feb-2003  vpandya     115.12 Changed archive_action_creation, checking
                                   fetch only those assignment action for that
                                   archiver has been run.
   24-Mar-2003  vpandya     115.13 Bug 2862554: Changed archive_action_creation,
                                   added distinct and person id in cursor.
   03-Apr-2003  vpandya     115.14 Bug 2882568: Changed archive_action_creation,
                                   commented line paa_run.source_action_id is
                                   null to create assignment action for all GREs
   13-May-2003  vpandya     115.15 Bug 2942093: Changed action_creation for live
                                   Deposit Advice. Added distinct in select
                                   clause and assignment_action_id in order by
                                   clause in c_action cursor to get uniq deposit
                                   advice.
   22-Jul-2003  vpandya     115.16 Bug 3046204: Changed action_creation for live
                                   Deposit Advice to print zero net pay deposit
                                   advice.
   24-Mar-2004  ssattini    115.17 Bug 3331023: 11510 changes done in
                                   range_cursor and action_creation procedures
                                   by removing rule hint and tuning them. Still
                                   changes need to be done for archive_action_
                                   creation procedure.
   27-Jul-2004  ssattini    115.20 Bug 3438254: 11510 Performance changes done.
                                   Changed the cursors and logic in
                                   archive_action_creation procedure, also
                                   added get_payroll_action procedure and
                                   check_if_assignment_paid function. Tuned
                                   c_actions_asg_set cursor in action_creation
                                   procedure. Used the get_payroll_action
                                   in range_cursor, action_creation procedures.
                                   Added assignment_set validation logic for
                                   c_actions_zero_pay records in
                                   action_creation procedure.
  15-Mar-2005  ssouresr     115.21 The condition that the consolidation set
                                   should be linked to a payroll has been
                                   removed from the range cursor and the
                                   action creation functions
  27-Apr-2005   sackumar   115.22  Bug 3800169. Modification in the logic of
				   action_creation_procedure. Merge the Zero pay
				   cursor in the c_action and c_actions_asg_set
				   cursor and introduce a flag_variable for zero pay
				   in the cursor fetch loop.
 16-JUN-2005    mmukherj           Removed the changes mentioned in 115.22.
                                   in 115.22 the changes has been done by
                                   merging the two cursors c_actions_zero_pay
                                   and c_actions_asg_set. So what was happening
                                   is that the cursoe c_actions_asg_set was
                                   being called only if the assignment_set has
                                   been passed , so the zero pay actions was not
                                   checked if the Deposit Advice was not run
                                   with assignment set. That was not the intention
                                   of this fix.
--
--

*/

---------------------------------- get_payroll_action -------------------
/**********************************************************************
 ** PROCEDURE   : get_payroll_action
 ** Description: Bug 3438254
 **              This procedure returns the details for payroll action for
 **              deposit advice. This is called in the range cursor,
 **              action_creation and archive_action_creation procedures.
 **********************************************************************/
 PROCEDURE get_payroll_action(p_payroll_action_id     in number
                             ,p_deposit_start_date   out nocopy date
                             ,p_deposit_end_date     out nocopy date
                             ,p_assignment_set_id    out nocopy number
                             ,p_payroll_id           out nocopy number
                             ,p_consolidation_set_id out nocopy number
                             )
 IS
 cursor c_get_payroll_action
                 (cp_payroll_action_id in number) is
     select legislative_parameters,
            start_date,
            effective_date
       from pay_payroll_actions
      where payroll_action_id = cp_payroll_action_id;

   lv_legislative_parameters  VARCHAR2(2000);

   ln_assignment_set_id       NUMBER;
   ln_payroll_id              NUMBER;
   ln_consolidation_set_id    NUMBER;
   ld_deposit_start_date      DATE;
   ld_deposit_end_date        DATE;

 BEGIN
   open c_get_payroll_action(p_payroll_action_id);
   fetch c_get_payroll_action into lv_legislative_parameters,
                                   ld_deposit_start_date,
                                   ld_deposit_end_date;
   close c_get_payroll_action;

   ln_assignment_set_id := pycadar_pkg.get_parameter(
                             'ASG_SET_ID',
                             lv_legislative_parameters);
   ln_payroll_id := pycadar_pkg.get_parameter(
                             'PAYROLL_ID',
                             lv_legislative_parameters);
   ln_consolidation_set_id := pycadar_pkg.get_parameter(
                                'CONSOLIDATION_SET_ID',
                               lv_legislative_parameters);

   p_deposit_start_date   := ld_deposit_start_date;
   p_deposit_end_date     := ld_deposit_end_date;
   p_payroll_id           := ln_payroll_id;
   p_assignment_set_id    := ln_assignment_set_id;
   p_consolidation_set_id := ln_consolidation_set_id;

 END get_payroll_action;

----------------------------------- range_cursor ------------------------------
--
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
  l_payroll_id number;
--  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_asg_set_id hr_assignment_sets.assignment_set_id%TYPE;

  --Bug 3331023
  l_db_version varchar2(20);
  -- Bug#4338254
   ld_deposit_start_date      DATE;
   ld_deposit_end_date        DATE;
   ln_consolidation_set_id    NUMBER;
--
begin

   get_payroll_action(p_payroll_action_id    => pactid
                     ,p_deposit_start_date   => ld_deposit_start_date
                     ,p_deposit_end_date     => ld_deposit_end_date
                     ,p_assignment_set_id    => l_asg_set_id
                     ,p_payroll_id           => l_payroll_id
                     ,p_consolidation_set_id => ln_consolidation_set_id);

   /* Removed old code to use get_payroll_action bug#3438254 */

   hr_utility.trace('l_payroll_id = ' || to_char(l_payroll_id));
   hr_utility.trace('l_asg_set_id = ' || to_char(l_asg_set_id));

  --Database Version --Bug 3331023

  if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
        l_db_version := '/*+ RULE */';
  else
        l_db_version := '/* NO RULE*/';
  end if;

--
  if l_asg_set_id is NOT NULL then

  sqlstr := 'select
    distinct paf.person_id
  from
    hr_assignment_set_amendments hasa,
    per_all_assignments_f paf,
    pay_payroll_actions ppa
  where
    ppa.payroll_action_id = :PACTID and
    hasa.assignment_set_id =  ' || to_char(l_asg_set_id) ||
    ' and hasa.assignment_id = paf.assignment_id and
    ppa.effective_date between
      paf.effective_start_date and
      paf.effective_end_date';

  else

    if l_payroll_id is not null then
       --Bug 3331023-- Rule hint is used only for database version < 10.0
       sqlstr := 'select '||l_db_version||' distinct pos.person_id
                from    pay_assignment_actions act,
                        per_all_assignments_f  asg,
                        per_periods_of_service pos,
                        pay_payroll_actions    pa2,
                        pay_payroll_actions    pa1,
                        pay_all_payrolls_f     ppf
                 where  pa1.payroll_action_id = :payroll_action_id
                 and    ppf.payroll_id = pycadar_pkg.get_parameter(''PAYROLL_ID'',
                                  pa1.legislative_parameters)
                 and    pa2.consolidation_set_id =
                           pycadar_pkg.get_parameter(''CONSOLIDATION_SET_ID'',
                                 pa1.legislative_parameters)
                 and    pa2.payroll_id   = ppf.payroll_id
                 and    pa2.effective_date between
                        pa1.start_date and pa1.effective_date
                 and    pa2.effective_date between
                        ppf.effective_start_date and ppf.effective_end_date
                 and    pa2.payroll_action_id= act.payroll_action_id
                 and    asg.assignment_id    = act.assignment_id
                 and    pa2.effective_date between
                        asg.effective_start_date and asg.effective_end_date
                 and    pos.period_of_service_id = asg.period_of_service_id
                 order by pos.person_id';

--
    else
     --Bug 3331023-- Rule hint is used only for database version < 10.0
      sqlstr :=      'select '||l_db_version||' distinct pos.person_id
                     from      pay_assignment_actions act,
                               per_all_assignments_f  asg,
                               per_periods_of_service pos,
                               pay_payroll_actions    pa2,
                               pay_payroll_actions    pa1,
                               pay_all_payrolls_f     ppf
                        where  pa1.payroll_action_id    = :payroll_action_id
                        and    pa2.consolidation_set_id =
                                         pycadar_pkg.get_parameter(''CONSOLIDATION_SET_ID'',
                                         pa1.legislative_parameters)
                        and    pa2.payroll_id   = ppf.payroll_id
                        and    pa2.effective_date between
                               pa1.start_date and pa1.effective_date
                        and    pa2.effective_date between
                               ppf.effective_start_date and ppf.effective_end_date
                        and    act.payroll_action_id    = pa2.payroll_action_id
                        and    asg.assignment_id        = act.assignment_id
                        and    pa2.effective_date between
                               asg.effective_start_date and asg.effective_end_date
                        and    pos.period_of_service_id = asg.period_of_service_id
                        order by pos.person_id';

--
    end if; -- l_payroll_id validation

  end if; -- End if Assignment Set ID

end range_cursor;


---------------------------------- check_if_assignment_paid -------------------
 /**********************************************************************
 ** FUNCTION   : check_if_assignment_paid
 ** Parameters :
 ** Description: Bug#3438254
 **              Function call is added for eliminating the cursor
 **              c_actions_zero_pay. This is called in the archive
 **              action creation procedure.
 **********************************************************************/
 FUNCTION check_if_assignment_paid(p_prepayment_action_id in number,
                                   p_deposit_start_date   in date,
                                   p_deposit_end_date     in date,
                                   p_consolidation_set_id in number)
 RETURN VARCHAR2
 IS
   cursor c_direct_deposit_run
             (cp_prepayment_action_id in number,
              cp_deposit_start_date   in date,
              cp_deposit_end_date     in date,
              cp_consolidation_set_id in number
             ) is
     select 1
       from dual
      where exists
            (select 1
               from pay_action_interlocks pai_mag,
                    pay_assignment_actions paa_mag,
                    pay_payroll_actions    ppa_mag
              where pai_mag.locked_action_id  = cp_prepayment_action_id
                and pai_mag.locking_Action_id = paa_mag.assignment_action_id
                and paa_mag.payroll_action_id = ppa_mag.payroll_action_id
                and ppa_mag.action_type       = 'M'
                and ppa_mag.effective_date between cp_deposit_start_date
                                               and cp_deposit_end_date
                and ppa_mag.consolidation_set_id +0 = cp_consolidation_set_id
             );

   cursor c_no_prepayments (cp_prepayment_action_id in number) is
     select 1
       from dual
      where not exists
                 (select 1
                    from pay_pre_payments ppp
                   where ppp.assignment_action_id = cp_prepayment_action_id
                 );

   lc_dd_flag         VARCHAR2(1);
   lc_no_prepayment_flag VARCHAR2(1);

   lc_return_flag        VARCHAR2(1);

  BEGIN
   hr_utility.trace(' p_prepayment_action_id '|| to_char(p_prepayment_action_id));
   hr_utility.trace(' p_deposit_start_date '  || to_char(p_deposit_start_date));   hr_utility.trace(' p_deposit_end_date '    || to_char(p_deposit_end_date));
   hr_utility.trace(' p_consolidation_set_id '|| to_char(p_consolidation_set_id));

   lc_return_flag := 'N';
   open c_direct_deposit_run(p_prepayment_action_id,
                    p_deposit_start_date,
                    p_deposit_end_date,
                    p_consolidation_set_id);
   fetch c_direct_deposit_run into lc_dd_flag;
   if c_direct_deposit_run%found then
      lc_return_flag := 'Y';
      hr_utility.trace('c_direct_deposit_run%found lc_return_flag: '|| lc_return_flag);

   else
      open c_no_prepayments(p_prepayment_action_id);
      fetch c_no_prepayments into lc_no_prepayment_flag;
      if c_no_prepayments%found then
         lc_return_flag := 'Y';
         hr_utility.trace('c_no_prepayments%found lc_return_flag: '|| lc_return_flag);
      end if;
      close c_no_prepayments;
   end if;
   close c_direct_deposit_run;

   return (lc_return_flag);

 END check_if_assignment_paid;
---------------------------------- action_creation -----------------------------
--
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

--Bug 3331023
  l_db_version varchar2(20);
  l_actions varchar2(4000);

  TYPE PaidActions is REF CURSOR;
  c_actions PaidActions;
--
--
      -- Bug#3331023 removed rule hint for c_actions_zero_pay cursor and
      -- added pay_all_payrolls_f table in the main query to use  correct indexes

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
             per_periods_of_service         pos,
             pay_payroll_actions            ppa_dar,
             pay_payroll_actions            ppa_mag_pmts,
             pay_all_payrolls_f             ppf
      where (   ppa_dar.payroll_action_id   = pactid
         and    ppa_mag_pmts.consolidation_set_id =
                pycadar_pkg.get_parameter('CONSOLIDATION_SET_ID',
                                          ppa_dar.legislative_parameters)
         and    ppa_mag_pmts.payroll_id = ppf.payroll_id
         and    ppa_mag_pmts.effective_date between ppa_dar.start_date
                                                and ppa_dar.effective_date
         and    ppa_mag_pmts.effective_date between ppf.effective_start_date
                                                and ppf.effective_end_date
         and    act.payroll_action_id          = ppa_mag_pmts.payroll_action_id
         and    act.action_status              = 'C'
         and    ppa_mag_pmts.action_type       in ('P', 'U')
         and    paf1.assignment_id              = act.assignment_id
         and    ppa_mag_pmts.effective_date between
                paf1.effective_start_date and paf1.effective_end_date
         and    pos.period_of_service_id       = paf1.period_of_service_id
         and    pos.person_id between stperson and endperson
         and   (paf1.payroll_id =
                     pycadar_pkg.get_parameter('PAYROLL_ID',
                                               ppa_dar.legislative_parameters)
              or pycadar_pkg.get_parameter('PAYROLL_ID',
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
          (        Select  ' '
                    from pay_action_interlocks   int2,
                         pay_action_interlocks   int4,
                         pay_assignment_actions  paa4,
                         pay_payroll_actions     ppa_run,  --- RUN
                         pay_payroll_actions     pact4,  --- Reversal
                         pay_assignment_actions  paa_run  --- RUN
                   where int2.locking_action_id   = act.assignment_action_id  -- prepayment action
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


  --
  -- if assignment_set is passed then the cursor ignores
  -- consolidation set and payroll passed a takes the payroll
  -- considation set of the assignment set.
  --
  CURSOR c_actions_asg_set
      (
         pactid    number,
         stperson  number,
         endperson number,
         p_assignment_set_id number
      ) is
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions         act,
             per_all_assignments_f          paf1,
             per_all_assignments_f          paf2,
             per_periods_of_service         pos,
             pay_payroll_actions            ppa_dar,
             pay_payroll_actions            ppa_mag,
             pay_all_payrolls_f             ppf,
             hr_assignment_sets             has,
             hr_assignment_set_amendments   hasa
      where  ppa_dar.payroll_action_id   = pactid
       and   has.assignment_set_id = p_assignment_set_id
       and   ppa_mag.effective_date between
             ppa_dar.start_date and ppa_dar.effective_date
       and   ppa_mag.consolidation_set_id =
             pycadar_pkg.get_parameter('CONSOLIDATION_SET_ID',ppa_dar.legislative_parameters)

       and  ((    has.payroll_id is null
              and nvl(ppa_mag.payroll_id,ppf.payroll_id)  =
                  nvl(pycadar_pkg.get_parameter('PAYROLL_ID',ppa_dar.legislative_parameters),
                      nvl(ppa_mag.payroll_id,ppf.payroll_id))
              ) or

              nvl(ppa_mag.payroll_id,has.payroll_id)  = has.payroll_id
            )
       and   ppa_mag.effective_date between
             ppf.effective_start_date and ppf.effective_end_date
      and    act.payroll_action_id          = ppa_mag.payroll_action_id
      and    act.action_status              = 'C'
      and    ppa_mag.action_type            = 'M'
      and    hasa.assignment_set_id         = has.assignment_set_id
      and    hasa.assignment_id             = act.assignment_id
      and    hasa.include_or_exclude        = 'I'
      and    paf1.assignment_id             = act.assignment_id
      and    ppa_mag.effective_date between
             paf1.effective_start_date and paf1.effective_end_date
      and    paf2.assignment_id              = act.assignment_id
      and    ppa_dar.effective_date between
             paf2.effective_start_date and paf2.effective_end_date
      and    paf2.payroll_id + 0             = paf1.payroll_id + 0
      and    pos.period_of_service_id       = paf1.period_of_service_id
      and    pos.person_id between stperson and endperson
      and   (paf1.payroll_id = ppa_dar.payroll_id or ppa_dar.payroll_id is null)
      and  not exists
             ( select  ''
                 from pay_action_interlocks   int2,
                      pay_action_interlocks   int3,
                      pay_assignment_actions  paa4,
                      pay_payroll_actions     ppa_run,  --- RUN
                      pay_payroll_actions     pact4,  --- Reversal
                      pay_assignment_actions  paa_run,  --- RUN
                      pay_assignment_actions  paa_pp   --- PREPAY
                where int3.locked_action_id   = act.assignment_action_id
                and   int3.locking_action_id  = paa_pp.assignment_action_id
                and   int2.locked_action_id   = paa_pp.assignment_action_id
                and   int2.locking_action_id   = paa_run.assignment_action_id
                and   paa_run.payroll_action_id = ppa_run.payroll_action_id
                and   ppa_run.action_type in ('R', 'Q')
                and   paa_run.assignment_action_id = int3.locked_action_id
                and   int3.locking_action_id = paa4.assignment_action_id
                and   pact4.payroll_action_id = paa4.payroll_action_id
                and   pact4.action_type       = 'V'
              )
      order by act.assignment_id;
--
   /*****************************************************************
   ** This cursor solves problem when there are multiple pre-payments
   ** and multiple assignment actions , in this case we only want 1
   ** assignment action for each pre-payment.
   *****************************************************************/
   cursor c_pre_payments (cp_dd_action_id in number) is
     select locked_action_id
       from pay_action_interlocks pai
      where pai.locking_action_id = cp_dd_action_id; --Direct Deposit dd

   /*****************************************************************
   ** This cursor will get all the source actions for which the
   ** assignment should get a deposit advice.
   ** assignment action for each pre-payment (bug 890222) i.e.
   ** Seperate Depsoit Advice for Seperate Check and Regular Run
   *****************************************************************/
   cursor c_payments (cp_pre_pymt_action_id in number) is
     select distinct ppp.source_action_id
       from pay_pre_payments ppp
      where ppp.assignment_action_id = cp_pre_pymt_action_id
      order by ppp.source_action_id;

   cursor c_payroll_run (cp_pre_pymt_action_id in number) is
     select assignment_action_id
       from pay_action_interlocks pai,
            pay_assignment_actions paa
      where pai.locking_action_id = cp_pre_pymt_action_id
        and paa.assignment_Action_id = pai.locked_action_id
        and paa.run_type_id is null
     order by action_sequence desc;

      lockingactid  number;
      lockedactid   number;
      assignid      number;
      greid         number;
      num           number;
--
   ln_pre_pymt_action_id      NUMBER;
   ln_prev_pre_pymt_action_id NUMBER;

   ln_source_action_id        NUMBER;
   ln_prev_source_action_id   NUMBER;

   ln_master_action_id        NUMBER;

   ln_prev_asg_act_id         NUMBER;
--
   ln_direct_dep_act_id       NUMBER;
   ln_deposit_action_id       NUMBER;
   ln_assignment_id           NUMBER;
   ln_tax_unit_id             NUMBER;
--
   l_asg_set_id hr_assignment_sets.assignment_set_id%TYPE;
--
/* Removed cur_leg_param cursor to use get_payroll_action bug#3438254 */

    -- Bug#4338254
   ld_deposit_start_date      DATE;
   ld_deposit_end_date        DATE;
   ln_payroll_id              NUMBER;
   ln_consolidation_set_id    NUMBER;
   lv_ass_set_on              VARCHAR2(10);
   --
   -- algorithm is quite similar to the other process cases,
   -- but we have to take into account assignments and
   -- personal payment methods.
   begin
 --      hr_utility.trace_on('Y','CAASGSET');
      hr_utility.set_location('pycadar.action_creation',1);
      -- Initialising local variables here to avoid GSCC warnings
      ln_prev_pre_pymt_action_id := null;
      ln_prev_source_action_id   := null;
      ln_prev_asg_act_id         := -999999;

      -- checking Database Version Bug 3331023
        if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
                l_db_version := '/*+ RULE */';
          else
                l_db_version := '/* NO RULE*/';
        end if;
      --

      -- Bug 3331023 Query string for the reference cursor c_actions used rule hint
      -- if db_version is < 10 Bug 3331023
      l_actions := 'select '||l_db_version||' distinct act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions         act,
             per_all_assignments_f          paf1,
             per_all_assignments_f          paf2,
             per_periods_of_service         pos,
             pay_payroll_actions            ppa_dar,
             pay_payroll_actions            ppa_mag,
             pay_all_payrolls_f             ppf
      where  ppa_dar.payroll_action_id          = :pactid
       and  nvl(ppa_mag.payroll_id,ppf.payroll_id)        =
                NVL(pycadar_pkg.get_parameter(''PAYROLL_ID'',
                ppa_dar.legislative_parameters),
                nvl(ppa_mag.payroll_id,ppf.payroll_id))
        and  nvl(ppa_mag.payroll_id,ppf.payroll_id) = ppf.payroll_id
        and  ppa_mag.effective_date between
                   ppf.effective_start_date and ppf.effective_end_date
        and  nvl(ppf.multi_assignments_flag,''N'') = ''N''
        and  ppa_mag.consolidation_set_id + 0   =
                 pycadar_pkg.get_parameter(''CONSOLIDATION_SET_ID'',
                 ppa_dar.legislative_parameters)
      and    ppa_mag.effective_date between
                   ppa_dar.start_date and ppa_dar.effective_date
      and    act.payroll_action_id          = ppa_mag.payroll_action_id
      and    act.action_status              = ''C''
      and    ppa_mag.action_type            = ''M''
      and    paf1.assignment_id              = act.assignment_id
      and    ppa_mag.effective_date between
             paf1.effective_start_date and paf1.effective_end_date
      and    paf2.assignment_id              = act.assignment_id
      and    ppa_dar.effective_date between
             paf2.effective_start_date and paf2.effective_end_date
      and    paf2.payroll_id + 0             = paf1.payroll_id + 0
      and    pos.period_of_service_id       = paf1.period_of_service_id
      and    pos.person_id between :stperson and :endperson
      and    (( paf1.payroll_id = pycadar_pkg.get_parameter(''PAYROLL_ID'',
                                  ppa_dar.legislative_parameters) )
             or
              ( pycadar_pkg.get_parameter(''PAYROLL_ID'',
                ppa_dar.legislative_parameters) is null )
             )
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
                where int3.locked_action_id   = act.assignment_action_id
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
      order by act.assignment_id, act.assignment_action_id';

      get_payroll_action(p_payroll_action_id => pactid
                     ,p_deposit_start_date   => ld_deposit_start_date
                     ,p_deposit_end_date     => ld_deposit_end_date
                     ,p_assignment_set_id    => l_asg_set_id
                     ,p_payroll_id           => ln_payroll_id
                     ,p_consolidation_set_id => ln_consolidation_set_id);

     /* removed old code to use get_payroll_action bug#3438254 */

      hr_utility.set_location('pycadar.action_creation l_asg_set_id = '
                                                      ,l_asg_set_id);

      IF l_asg_set_id IS NOT NULL THEN
        open c_actions_asg_set(pactid,stperson,endperson,l_asg_set_id);
      ELSE

      -- Reference cursor opened for the query string l_paid_actions Bug 3331023
         open c_actions for l_actions using pactid, stperson, endperson;
      END IF;

      num := 0;
      loop
         hr_utility.set_location('pycadar.action_creation',2);
         IF l_asg_set_id IS NOT NULL THEN
           fetch c_actions_asg_set into lockedactid,assignid,greid;
           if c_actions_asg_set%found then num := num + 1; end if;
           exit when c_actions_asg_set%notfound;
         ELSE
           fetch c_actions into lockedactid,assignid,greid;
           if c_actions%found then
             num := num + 1;
           end if;
           exit when c_actions%notfound;
         END IF;
--
        IF lockedactid <> ln_prev_asg_act_id THEN

        hr_utility.trace(' c_actions.lockedactid is '||to_char(lockedactid));
        open c_pre_payments (lockedactid);
        fetch c_pre_payments into ln_pre_pymt_action_id;
        hr_utility.trace(' c_pre_payments.ln_pre_pymt_action_id is'
                 ||to_char(ln_pre_pymt_action_id));
        close c_pre_payments;

        -- we need to insert one action for each of the
        -- rows that we return from the cursor (i.e. one
        -- for each assignment/pre-payment).

        hr_utility.trace(' ln_prev_pre_pymt_action_id is'
                 ||to_char(ln_prev_pre_pymt_action_id));
        if (ln_prev_pre_pymt_action_id is null or
            ln_prev_pre_pymt_action_id <> ln_pre_pymt_action_id) then
           open c_payments (ln_pre_pymt_action_id);
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
              ** return from the cursor (i.e. one for each
              ** assignment/pre-payment source).
              **************************************************************/
                hr_utility.trace(' ln_prev_source_action_id is'
                 ||to_char(ln_prev_source_action_id));
              if (ln_prev_source_action_id is null or
                  ln_source_action_id <> ln_prev_source_action_id or
                  ln_source_action_id is null) then

                 hr_utility.set_location('procdar',3);
                 select pay_assignment_actions_s.nextval
                   into lockingactid
                   from dual;

                 -- insert the action record.
                 hr_nonrun_asact.insact(lockingactid,assignid,
                                        pactid,chunk,greid);
                     hr_utility.trace('Inserted into paa');
                    hr_utility.trace(' assignment_id is ' ||to_char(assignid));
                 -- insert an interlock to this action.
                    hr_nonrun_asact.insint(lockingactid,lockedactid);
                    hr_utility.trace('Inserted into interlock');

                 if ln_source_action_id is not null then

                    hr_utility.trace('serial number updated if loop ');
                    hr_utility.trace('serial number is '||ln_source_action_id);
                    update pay_assignment_Actions
                       set serial_number = 'P'||ln_source_action_id
                       --set serial_number = ln_source_action_id
                     where assignment_action_id = lockingactid;
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
                     where assignment_action_id = lockingactid;
                 end if;

                 -- skip till next source action id
                 ln_prev_source_action_id := ln_source_action_id;
              end if;
           end loop;
           close c_payments;

           ln_prev_pre_pymt_action_id := ln_pre_pymt_action_id;

        end if;

        ln_prev_asg_act_id := lockedactid;

        END IF;
     end loop;
     if l_asg_set_id is not null then
       close c_actions_asg_set;
     else
       close c_actions;
     end if;

       /* removed the commented code bug#3438254 */

     hr_utility.set_location('procdar',4);
     ln_prev_pre_pymt_action_id := null;
     open c_actions_zero_pay(pactid,stperson,endperson);

     loop
        hr_utility.set_location('procdar',5);
        lv_ass_set_on := 'N';
        hr_utility.trace('Start of c_actions_zero_pay ');
        fetch c_actions_zero_pay INTO ln_direct_dep_act_id, --gives P,U
                                      ln_assignment_id,
                                      ln_tax_unit_id;
        exit WHEN c_actions_zero_pay%NOTFOUND;
        hr_utility.trace(' NZ PrePayment Id is' ||ln_direct_dep_act_id);

        /* Added this code for Assignment set validation bug#3438254,
           Otherwise it was displaying all the assignments that are
           not in the given Assignment Set.
        */
        lv_ass_set_on :=  hr_assignment_set.assignment_in_set(
                                l_asg_set_id,
                                ln_assignment_id);
        hr_utility.trace('lv_ass_set_on : '||lv_ass_set_on);

        If lv_ass_set_on = 'Y' then

          open c_pre_payments (ln_direct_dep_act_id); --gives me R,Q
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
             hr_nonrun_asact.insint(ln_deposit_action_id,ln_direct_dep_act_id);
             hr_utility.trace(' NZ Inserted into paa');
             hr_utility.trace(' Asg id: '||to_char(ln_assignment_id));

             /* removed the commented code bug#3438254 */

              update pay_assignment_Actions
              set serial_number = 'Z'||ln_direct_dep_act_id
              where assignment_action_id = ln_deposit_action_id;

              -- skip till next pre payment action id
              ln_prev_pre_pymt_action_id := ln_pre_pymt_action_id;

          end if;

       End if; -- lv_ass_set_on = 'Y'

     end loop;
     close c_actions_zero_pay;
--     hr_utility.trace_off;

      commit;
end action_creation;
 --------------------- archive_action_creation ----------------------------
 PROCEDURE archive_action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

  -- Bug#3438254 -- Cursor definition changed to improve performance.
       cursor c_paid_actions
              (cp_start_person         in number,
               cp_end_person           in number,
               cp_payroll_id           in number,
               cp_consolidation_set_id in number,
               cp_deposit_start_date   in date,
               cp_deposit_end_date     in date) is
       select paa_pyarch.assignment_action_id,
              paa_pyarch.assignment_id,
              paa_pyarch.tax_unit_id
       from pay_payroll_actions    ppa_pyarch,
            pay_assignment_actions paa_pyarch,
            per_assignments_f      paf,
            pay_action_interlocks  pai_pre
       where ppa_pyarch.report_type = 'PY_ARCHIVER'
        and ppa_pyarch.report_category = 'RT'
        and ppa_pyarch.report_qualifier = 'PYCAPYAR'
        and cp_deposit_end_date between ppa_pyarch.start_date
                                    and ppa_pyarch.effective_date
        and cp_deposit_end_date between paf.effective_start_date
                                     and paf.effective_end_date
        and pycadar_pkg.get_parameter('CONSOLIDATION_SET_ID',
                                       ppa_pyarch.legislative_parameters)
                 = cp_consolidation_set_id
        and paa_pyarch.payroll_action_id = ppa_pyarch.payroll_action_id
        -- the statement below will make sure only Pre Payment Archive
        -- Actions are picked up
        and substr(paa_pyarch.serial_number,1,1) not in ('V', 'B')
        and paa_pyarch.assignment_id = paf.assignment_id
        and ppa_pyarch.effective_date between paf.effective_start_date
                                       and paf.effective_end_date
        and pai_pre.locking_Action_id = paa_pyarch.assignment_action_id
        and (cp_payroll_id is null
             or
             pycadar_pkg.get_parameter('PAYROLL_ID',
                                        ppa_pyarch.legislative_parameters)
                  = cp_payroll_id
             )
        and paf.person_id between cp_start_person and cp_end_person
        and pay_us_employee_payslip_web.get_doc_eit(
                             'PAYSLIP','PRINT',
                             'ASSIGNMENT',paf.assignment_id,
                             cp_deposit_end_date
                             ) = 'Y'
        and pycadar_pkg.check_if_assignment_paid(
                       pai_pre.locked_action_id,
                       cp_deposit_start_date,
                       cp_deposit_end_date,
                       cp_consolidation_set_id) = 'Y'
        and not exists
               (Select  1
                  from pay_action_interlocks   pai_run, --Pre > Run
                       pay_action_interlocks   pai_rev, --Run > Rev
                       pay_assignment_actions  paa_rev, --Rev
                       pay_payroll_actions     ppa_rev  --Rev
                 where pai_run.locking_action_id = pai_pre.locked_action_id
                   and pai_rev.locked_action_id = pai_run.locked_action_id
                   and paa_rev.assignment_action_id = pai_run.locking_action_id
                   and ppa_rev.payroll_action_id = paa_rev.payroll_action_id
                   and ppa_rev.action_type in ('V')
                )
          and exists (select 1
                from  pay_action_information pai
                where pai.action_context_id = paa_pyarch.assignment_action_id)
     order by paf.person_id, paf.assignment_id desc;


   ln_dd_action_id            NUMBER;
   ln_deposit_action_id       NUMBER;

   ln_person_id               NUMBER;
   ln_assignment_id           NUMBER;
   ln_tax_unit_id             NUMBER;
   ld_effective_date          DATE;


   ln_asg_set_id              NUMBER;
   lv_ass_set_on              VARCHAR2(10);

   -- Bug#4338254
   ld_deposit_start_date      DATE;
   ld_deposit_end_date        DATE;
   ln_payroll_id              NUMBER;
   ln_consolidation_set_id    NUMBER;

  BEGIN

     get_payroll_action(p_payroll_action_id    => pactid
                     ,p_deposit_start_date   => ld_deposit_start_date
                     ,p_deposit_end_date     => ld_deposit_end_date
                     ,p_assignment_set_id    => ln_asg_set_id
                     ,p_payroll_id           => ln_payroll_id
                     ,p_consolidation_set_id => ln_consolidation_set_id);

--     hr_utility.trace_on(null, 'ARCH_DEPADV');
     hr_utility.set_location('pycadar archive_action_creation',1);
   open c_paid_actions(stperson, endperson,
                       ln_payroll_id,
                       ln_consolidation_set_id,
                       ld_deposit_start_date,
                       ld_deposit_end_date);
   loop
      hr_utility.set_location('pycadar archive_action_creation',2);

      lv_ass_set_on := 'N';

      fetch c_paid_actions into ln_dd_action_id,
                                ln_assignment_id,
                                ln_tax_unit_id;
      exit WHEN c_paid_actions%NOTFOUND;

      lv_ass_set_on :=  hr_assignment_set.assignment_in_set(
                                ln_asg_set_id,
                                ln_assignment_id);
      hr_utility.trace('lv_ass_set_on : '||lv_ass_set_on);

      IF lv_ass_set_on = 'Y' THEN
        hr_utility.trace('c_paid_actions.ln_dd_action_id is' ||to_char(ln_dd_action_id));
        hr_utility.trace(' ln_assignment_id is' ||to_char(ln_assignment_id));
        hr_utility.trace(' ln_tax_unit_id is' ||to_char(ln_tax_unit_id));

         hr_utility.set_location('pycadar archive_action_creation',3);
         select pay_assignment_actions_s.nextval
         into ln_deposit_action_id
         from dual;

         -- insert the action record.
         hr_nonrun_asact.insact(ln_deposit_action_id,
                                ln_assignment_id,
                                pactid, chunk, ln_tax_unit_id);
         hr_utility.trace('Inserted into paa, New Asg_act_id:'||to_char(ln_deposit_action_id));
         -- insert an interlock to this action.
         hr_nonrun_asact.insint(ln_deposit_action_id, ln_dd_action_id);

         update pay_assignment_Actions
         set serial_number = ln_dd_action_id
         where assignment_action_id = ln_deposit_action_id;

      END IF;

   end loop;
   close c_paid_actions;

  hr_utility.set_location('pycadar archive_action_creation',4);

 END archive_action_creation;

 ---------------------------------- sort_action -------------------------------
procedure sort_action
(
   procname   in     varchar2,     /* name of the select statement to use */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out nocopy   number        /* length of the sql string */
) is
begin
      -- go through each of the sql sub strings and see if
      -- they are needed.
         sqlstr := 'select paa.rowid
                      from hr_organization_units  hou,
                           per_people_f           ppf,
                           per_assignments_f      paf,
                           pay_assignment_actions paa,
                           pay_payroll_actions    ppa
                     where ppa.payroll_action_id = :pactid
                       and paa.payroll_action_id = ppa.payroll_action_id
                       and paa.assignment_id     = paf.assignment_id
                       and ppa.effective_date between
                                   paf.effective_start_date and paf.effective_end_date
                       and paf.person_id         = ppf.person_id
                       and ppa.effective_date between
                                   ppf.effective_start_date and ppf.effective_end_date
                       and paf.organization_id   = hou.organization_id
                     order by hou.name,ppf.last_name,ppf.first_name
                       for update of paf.assignment_id';
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

function get_labels(p_lookup_type in VARCHAR2,
                    p_lookup_code in VARCHAR2)
return VARCHAR2 is
cursor csr_label_meaning is
select meaning
from hr_lookups
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code;

  l_label_meaning  varchar2(80);
begin
open csr_label_meaning;

fetch csr_label_meaning into l_label_meaning;
if csr_label_meaning%NOTFOUND then
  l_label_meaning       := NULL;
end if;
close csr_label_meaning;

 return l_label_meaning;
end get_labels;

--
function get_labels(p_lookup_type in VARCHAR2,
                    p_lookup_code in VARCHAR2,
                    p_person_language in varchar2)
return VARCHAR2 is
cursor csr_label_meaning is
select 1 ord, meaning
from  fnd_lookup_values
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code
and ( ( p_person_language is null and language = 'US' ) or
      ( p_person_language is not null and language = p_person_language ) )
union all
select 2 ord, meaning
from  fnd_lookup_values
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code
and ( language = 'US' and p_person_language is not null
      and language <> p_person_language )
order by 1;

  l_order number;
  l_label_meaning  varchar2(80);
begin
open csr_label_meaning;

fetch csr_label_meaning into l_order, l_label_meaning;
if csr_label_meaning%NOTFOUND then
  l_label_meaning       := NULL;
end if;
close csr_label_meaning;

 return l_label_meaning;
end get_labels;

end pycadar_pkg;

/
