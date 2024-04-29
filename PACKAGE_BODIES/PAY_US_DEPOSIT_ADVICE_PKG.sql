--------------------------------------------------------
--  DDL for Package Body PAY_US_DEPOSIT_ADVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_DEPOSIT_ADVICE_PKG" AS
/* $Header: payuslivearchive.pkb 120.14.12010000.9 2009/09/25 16:55:20 rnestor ship $ */
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

    Name        : pay_us_deposit_advice_pkg.pkb

    Description : Package used for Deposit Advice Report.

    Change List
    -----------
    Date       Name        Vers	    Bug		 Description
    ---------- ----------  ------  --------	 -----------------------------------
    08-JUN-2004 RMONGE     115.0		 Created.
						 This package is a copy of the
						 pyusdar.pkb.

						 Please refer to the old package body
						 for a history of changes.

    25-JUN-2004 RMONGE     115.1		 Replace existing version of this package with the
						 version 115.33 from pyusdar.pkb as required.

    02-JUL-2004 schauhan   115.2   3512116       1.Changed the query for cursor c_paid_actions in
						 procedure archive_action_creation for better
						 performance.
						 2.Removed cursor c_actions_zero_pay in procedure
						 archive_action_creation and added its logic to
						 function check_if_assignment_paid.
						 3.Changed query for range_cursor for better
						 performance.
						 4.Removed function get_parameter and used function
						 pay_us_payroll_utils.get_parameter instead.
						 5.Added function get_payroll_action which returns
						 payroll_action data.
   04-AUG-2004 schauhan    115.3  3512116        Added assignment_set_id in the return list of
                                                 procedure get_payroll_action.
   18-OCT-2004 schauhan    115.4  3928576        Made changes to cursor c_actions_zero_pay to check
                                                 only if assignment_action_id for master action is
						 is there pay_pre_payments.
   14-MAR-2005 sackumar    115.5  4222032	Change in the Range Cursor removing redundant
						use of bind Variable (:payroll_action_id)
   29-MAR-2005 sackumar    115.6  4222032	Removing GSCC Errors
   29-APR-2005 sackumar    115.7  3812668       Merge the concept of Zero pay cursor into c_actions
                                                cursor and introduce a new cursor c_actions_assign_set
						and also introduce a Zero_pay_flag to process the
						Zero pay concept.
   31-may-2005 djoshi      115.10               Performance Fix for action creation based on
                                                city of Chicago tar. 4190348.996
   06-JUN-2005 rsethupa    115.11 4406538       Changed cursor c_paid_actions in
                                                archive_action_creation procedure to use the
						exact names TRANSFER_CONSOLIDATION_SET_ID and
						TRANSFER_PAYROLL_ID while calling
						pay_us_payroll_utils.get_parameter()
   29-Sep-2005 sackumar    115.12 4631914	Modified the payroll_id join condition in c_paid_actions
						query in action_creation procedure
   06-Oct-2005 sackumar    115.13 4636646	Modified the c_paid_actions cursor query in
						action_creation procedure for Zero Pay assignment.
   26-Nov-2005 sackumar    115.14 4742901	Modified the c_paid_actions cursor query in
						action_creation procedure to resolve the
						performance issues.
   16-Dec-2005 tclewis	   115.15		added code to check for the existance of data in the
			                        pay_action_information table.  thie is to fix a problem
						with the zero (gross, net) pay assignment being picked up
						by in the archive_action_creation procedure.
   23-Jan-2006 sackumar    115.18 4945604       Modified the C_action_asg_set Cursor in action_creation procedure
   24-May-2007 sudedas     115.21 5635335       Procedure archive_deinit has
                                                been added to be used by Archive
                                                Deposit Advice (PDF) Process.
   27-Jun-2007 sudedas     115.22               Added Qualifying Procedure and Function
                                                check_if_qualified_for_US. This is for
                                                Archive Deposit Advice producing XML
                                                using Global Payslip Printing Solution
   03-OCT-2008 rnestor    115.25              Modified the c_no_prepayments cursor to exclude Third Party Payments
   15-Jan-2009 sudedas    115.26   7583387   Added function get_DAxml_payroll_action
                                             ,DAxml_range_cursor and changed
                                             qualifying_proc.
   21-Jan-2009 sudedas    115.27   7583387   Changed Function DAxml_range_cursor
                                             to Procedure.
                          115.28   7583387   Added NOCOPY hint for OUT variable.
   17-feb-2009            115.29   8254078   <> NULL replaced with is not NULL
                                             in the c_no_prepayments cursor
   01-Apr-2009            115.30   7558310	Modified Cursor c_paid_actions to include all the
						assignment actions whose payroll archive falls
						between deposit advice's start date and end date.
   25-SEP-09  rnestor    115.31    8941027 	Removed source_id is null CURSOR csr_inc_asg
                                           and CURSOR csr_asg.
    **********************************************************************/

  /**********************************************************************
 ** PROCEDURE   : get_payroll_action
 ** Description: Bug 3512116
 **              This procedure returns the details for payroll action for
 **              deposit advice. This is called in the range cursor.
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

   ln_assignment_set_id := pay_us_payroll_utils.get_parameter(
                             'ASG_SET_ID',
                             lv_legislative_parameters);
   ln_payroll_id := pay_us_payroll_utils.get_parameter(
                             'PAYROLL_ID',
                             lv_legislative_parameters);
   ln_consolidation_set_id := pay_us_payroll_utils.get_parameter(
                                'CONSOLIDATION_SET_ID',
                               lv_legislative_parameters);

   p_deposit_start_date   := ld_deposit_start_date;
   p_deposit_end_date     := ld_deposit_end_date;
   p_payroll_id           := ln_payroll_id;
   p_assignment_set_id    := ln_assignment_set_id;
   p_consolidation_set_id := ln_consolidation_set_id;

 END get_payroll_action;

  /**********************************************************************
 ** PROCEDURE   : get_DAxml_payroll_action
 **              This procedure returns the details for payroll action for
 **              Deposit Advice(XML). This is called in the range cursor.
 **********************************************************************/
 PROCEDURE get_DAxml_payroll_action(p_payroll_action_id     in number
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
   hr_utility.trace('Entering get_DAxml_payroll_action');
   open c_get_payroll_action(p_payroll_action_id);
   fetch c_get_payroll_action into lv_legislative_parameters,
                                   ld_deposit_start_date,
                                   ld_deposit_end_date;
   hr_utility.trace('lv_legislative_parameters := ' || lv_legislative_parameters);
   hr_utility.trace('ld_deposit_start_date := ' || TO_CHAR(ld_deposit_start_date));
   hr_utility.trace('ld_deposit_end_date := ' || TO_CHAR(ld_deposit_end_date));

   close c_get_payroll_action;

   ln_assignment_set_id := pay_us_payroll_utils.get_parameter(
                             'ASSIGNMENT_SET_ID',
                             lv_legislative_parameters);
   ln_payroll_id := pay_us_payroll_utils.get_parameter(
                             'PAYROLL_ID',
                             lv_legislative_parameters);
   ln_consolidation_set_id := pay_us_payroll_utils.get_parameter(
                                'CONSOLIDATION_SET_ID',
                               lv_legislative_parameters);

   hr_utility.trace('ln_assignment_set_id := ' || ln_assignment_set_id);
   hr_utility.trace('ln_payroll_id := ' || ln_payroll_id);
   hr_utility.trace('ln_consolidation_set_id := ' || ln_consolidation_set_id);

   p_deposit_start_date   := ld_deposit_start_date;
   p_deposit_end_date     := ld_deposit_end_date;
   p_payroll_id           := ln_payroll_id;
   p_assignment_set_id    := ln_assignment_set_id;
   p_consolidation_set_id := ln_consolidation_set_id;

   hr_utility.trace('Leaving get_DAxml_payroll_action');

 END get_DAxml_payroll_action;

 /********************************************************************
 ** Procedure  : range_cursor
 ** Description: This is used for both Live and Archive Deposit
 **              advice reports.
 ********************************************************************/
 PROCEDURE range_cursor (pactid in number, sqlstr out NOCOPY varchar2)
 IS

   ln_assignment_set_id       NUMBER;
   ln_payroll_id              NUMBER;
   ln_consolidation_set_id    NUMBER;
   ld_deposit_start_date      DATE;
   ld_deposit_end_date        DATE;

   --Bug 3331028
   l_db_version varchar2(20);

 BEGIN
   get_payroll_action(p_payroll_action_id    => pactid
                     ,p_deposit_start_date   => ld_deposit_start_date
                     ,p_deposit_end_date     => ld_deposit_end_date
                     ,p_assignment_set_id    => ln_assignment_set_id
                     ,p_payroll_id           => ln_payroll_id
                     ,p_consolidation_set_id => ln_consolidation_set_id);

  --Database Version --Bug 3331028
  if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
     l_db_version := '/*+ RULE */';
  else
     l_db_version := '/* NO RULE*/';
  end if;

-- Query is modified for better performance Bug3512116--

  if ln_payroll_id is not null then
     sqlstr := 'select '||l_db_version||' distinct paa.assignment_id
                  from pay_assignment_actions paa,
                       pay_payroll_actions    ppa
                 where :payroll_action_id is not null
                   and ppa.action_type in (''R'',''Q'')
                   and ppa.consolidation_set_id = ' || ln_consolidation_set_id
              || ' and ppa.payroll_id = ' || ln_payroll_id
              || ' and ppa.effective_date between ''' || ld_deposit_start_date
              ||                            ''' and ''' || ld_deposit_end_date
              || ''' and paa.payroll_action_id = ppa.payroll_action_id
                order by paa.assignment_id';

  else
     sqlstr := 'select '||l_db_version||' distinct paa.assignment_id
                  from pay_assignment_actions paa,
                       pay_payroll_actions    ppa
                 where :payroll_action_id is not null
                   and ppa.action_type in (''R'',''Q'')
                   and ppa.consolidation_set_id = ' || ln_consolidation_set_id
              || ' and ppa.effective_date between ''' || ld_deposit_start_date
              ||                            ''' and ''' || ld_deposit_end_date
              || ''' and paa.payroll_action_id = ppa.payroll_action_id
                order by paa.assignment_id';
  end if;

 END RANGE_CURSOR;

 /**********************************************************************
 ** FUNCTION   : check_if_assignment_paid
 ** Parameters :
 ** Description: Bug 3512116
 **              Function call is added for eliminating the cursor
 **              c_actions_zero_pay. This is called in the archive
 **              action creation cursor
 **********************************************************************/
 FUNCTION check_if_assignment_paid(p_prepayment_action_id in number,
                                   p_deposit_start_date   in date,
                                   p_deposit_end_date     in date,
                                   p_consolidation_set_id in number)
 RETURN VARCHAR2
 IS

   cursor c_nacha_run
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
                    pay_payroll_actions    ppa_mag,
                    pay_org_payment_methods_f popm,
                    pay_pre_payments ppp,
                    pay_payment_types ppt
              where pai_mag.locked_action_id  = cp_prepayment_action_id
                and pai_mag.locking_Action_id = paa_mag.assignment_action_id
                and paa_mag.payroll_action_id = ppa_mag.payroll_action_id
                and ppa_mag.action_type       = 'M'

                and pai_mag.locked_action_id  = ppp.assignment_action_id
                and ppp.value > 0
                and  ppp.org_payment_method_id = popm.org_payment_method_id
                and ppa_mag.effective_date between popm.effective_start_date
                                               and popm.effective_end_date
                and popm.DEFINED_BALANCE_ID is not null
                and popm.payment_type_id       = ppt.payment_type_id
                and ppt.territory_code = 'US'
                and ppt.payment_type_name = 'NACHA'

                and ppa_mag.effective_date between cp_deposit_start_date
                                               and cp_deposit_end_date
                and ppa_mag.consolidation_set_id +0 = cp_consolidation_set_id
                and ppa_mag.ORG_PAYMENT_METHOD_ID   = popm.org_payment_method_id);

   cursor c_no_prepayments (cp_prepayment_action_id in number) is
     select 1
       from dual
      where not exists
                 (select 1
                   from pay_pre_payments ppp ,
                        pay_org_payment_methods_f popm
                   where ppp.assignment_action_id = cp_prepayment_action_id
                   and popm.ORG_PAYMENT_METHOD_ID = ppp.org_payment_method_id
                   and popm.defined_balance_id is not NULL );

   lc_nacha_flag         VARCHAR2(1);
   lc_no_prepayment_flag VARCHAR2(1);

   lc_return_flag        VARCHAR2(1);

 BEGIN
   hr_utility.trace(' p_prepayment_action_id '|| p_prepayment_action_id);
   hr_utility.trace(' p_deposit_start_date '  || to_char(p_deposit_start_date));
   hr_utility.trace(' p_deposit_end_date '    || to_char(p_deposit_end_date));
   hr_utility.trace(' p_consolidation_set_id '|| p_consolidation_set_id);

   lc_return_flag := 'N';
   open c_nacha_run(p_prepayment_action_id,
                    p_deposit_start_date,
                    p_deposit_end_date,
                    p_consolidation_set_id);
   fetch c_nacha_run into lc_nacha_flag;
   if c_nacha_run%found then
      lc_return_flag := 'Y';
   else
      open c_no_prepayments(p_prepayment_action_id);
      fetch c_no_prepayments into lc_no_prepayment_flag;
      if c_no_prepayments%found then
         lc_return_flag := 'Y';
      end if;
      close c_no_prepayments;
   end if;
   close c_nacha_run;

   return (lc_return_flag);

 END check_if_assignment_paid;
 --
 --
FUNCTION check_if_qualified_for_US(p_archive_action_id IN NUMBER
                                  ,p_assignment_id IN NUMBER
                                  ,p_deposit_start_date IN DATE
                                  ,p_deposit_end_date IN DATE
                                  ,p_consolidation_set_id IN NUMBER)
RETURN VARCHAR2
IS
/****************************************************************
** If archiver is locking the pre-payment assignment_action_id,
** we get it from interlocks.
****************************************************************/
    cursor c_prepay_arch_action(cp_assignment_action_id in number) is
      select paa.assignment_action_id
        from pay_action_interlocks paci,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       where paci.locking_action_id = cp_assignment_action_id
         and paa.assignment_action_id = paci.locked_action_id
         and ppa.payroll_action_id = paa.payroll_action_id
         and ppa.action_type in ('P', 'U');

/****************************************************************
** If archiver is locking the run assignment_action_id, we get
** the corresponding run assignment_action_id and then get
** the pre-payment assignemnt_action_id.
** This cursor is only required when there are child action which
** means there is a seperate check.
* ***************************************************************/
    cursor c_prepay_run_arch_action(cp_assignment_action_id in number) is
      select paa_pre.assignment_action_id
        from pay_action_interlocks pai_run,
             pay_action_interlocks pai_pre,
             pay_assignment_actions paa_pre,
             pay_payroll_actions ppa_pre
       where pai_run.locking_action_id = cp_assignment_action_id
         and pai_pre.locked_action_id = pai_run.locked_action_id
         and paa_pre.assignment_Action_id = pai_pre.locking_action_id
         and ppa_pre.payroll_action_id = paa_pre.payroll_action_id
         and ppa_pre.action_type in ('P', 'U');

     ln_prepay_action_id   NUMBER;
     lv_rev_run_exists     VARCHAR2(1);
  BEGIN
    --
    --
    hr_utility.trace('Entering check_if_qualified_for_US');

    OPEN c_prepay_arch_action(p_archive_action_id);
    FETCH c_prepay_arch_action INTO ln_prepay_action_id;
    IF c_prepay_arch_action%notfound THEN
       OPEN c_prepay_run_arch_action(p_archive_action_id);
       FETCH c_prepay_run_arch_action INTO ln_prepay_action_id;
       IF c_prepay_run_arch_action%notfound THEN
          RETURN('N');
       END IF;
       CLOSE c_prepay_run_arch_action;
    END IF;
    CLOSE c_prepay_arch_action;
    --
    --
    hr_utility.trace('ln_prepay_action_id :='||ln_prepay_action_id);

    IF  pay_us_employee_payslip_web.get_doc_eit(
                             'PAYSLIP'
                             ,'PRINT'
                             ,'ASSIGNMENT'
                             ,p_assignment_id
                             ,p_deposit_end_date) = 'Y'
        AND pay_us_deposit_advice_pkg.check_if_assignment_paid(
                               ln_prepay_action_id
                              ,p_deposit_start_date
                              ,p_deposit_end_date
                              ,p_consolidation_set_id) = 'Y' --Bug 3512116
     THEN

        lv_rev_run_exists := NULL;

        BEGIN
            SELECT '1'
            INTO   lv_rev_run_exists
            FROM   dual
            where exists
                   (Select  /*+ ORDERED */  1
                      from pay_action_interlocks   pai_run, --Pre > Run
                           pay_action_interlocks   pai_rev, --Run > Rev
                           pay_assignment_actions  paa_rev, --Rev
                           pay_payroll_actions     ppa_rev  --Rev
                     where pai_run.locking_action_id = ln_prepay_action_id
                       and pai_rev.locked_action_id = pai_run.locked_action_id
                       and paa_rev.assignment_action_id = pai_run.locking_action_id
                       and ppa_rev.payroll_action_id = paa_rev.payroll_action_id
                       and ppa_rev.action_type in ('V')
                    );
         EXCEPTION
         WHEN OTHERS THEN
              lv_rev_run_exists := NULL;
         END;

         IF lv_rev_run_exists = '1' then
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
    ELSE
       RETURN 'N';
    END IF;
END check_if_qualified_for_US;

 /*********************************************************************
 ** Name       : archive_action_creation
 ** Description: Archive Assignment Action for archive deposit advice report
 **
 *********************************************************************/
 PROCEDURE archive_action_creation(pactid    in number,
                                   stperson  in number,
                                   endperson in number,
                                   chunk     in number)
 IS

   -- Bug 3512116 -- Cursor changed to improve performance.
   cursor c_paid_actions
              (cp_start_person         in number,
               cp_end_person           in number,
               cp_payroll_id           in number,
               cp_consolidation_set_id in number,
               cp_deposit_start_date   in date,
               cp_deposit_end_date     in date) is
     select /*+ ORDERED */
        paa_xfr.assignment_action_id,
        paa_xfr.assignment_id,
        paa_xfr.tax_unit_id
       from
            pay_payroll_actions    ppa_xfr,
            pay_assignment_actions paa_xfr,
            pay_action_interlocks  pai_pre
      where ppa_xfr.report_type = 'XFR_INTERFACE'
        and ppa_xfr.report_category = 'RT'
        and ppa_xfr.report_qualifier = 'FED'
	/* Bug : 7558310
        and cp_deposit_end_date between ppa_xfr.start_date
                                    and ppa_xfr.effective_date */
	and ppa_xfr.effective_date between cp_deposit_start_date and cp_deposit_end_date
        and pay_us_payroll_utils.get_parameter('TRANSFER_CONSOLIDATION_SET_ID',
                                               ppa_xfr.legislative_parameters)
                 = cp_consolidation_set_id
        and paa_xfr.payroll_action_id = ppa_xfr.payroll_action_id
        -- the statement below will make sure only Pre Payment Archive Actions are picked up
        and substr(paa_xfr.serial_number,1,1) not in ('V', 'B')
        and pai_pre.locking_Action_id = paa_xfr.assignment_action_id
        and (cp_payroll_id is null
             or
             pay_us_payroll_utils.get_parameter('TRANSFER_PAYROLL_ID',
                                                ppa_xfr.legislative_parameters)
                  = cp_payroll_id
             )
        and paa_xfr.assignment_id between cp_start_person and cp_end_person
        and pay_us_employee_payslip_web.get_doc_eit(
                             'PAYSLIP','PRINT',
                             'ASSIGNMENT',paa_xfr.assignment_id,
                             cp_deposit_end_date) = 'Y'
        and pay_us_deposit_advice_pkg.check_if_assignment_paid(
                       pai_pre.locked_action_id,
                       cp_deposit_start_date,
                       cp_deposit_end_date,
                       cp_consolidation_set_id) = 'Y' --Bug 3512116
        and not exists
               (Select  /*+ ORDERED */  1
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
         and exists ( select 1
             from   pay_action_information pai
              where  pai.action_context_id = paa_xfr.assignment_action_id
              and rownum < 2
           )     order by  paa_xfr.assignment_id desc;

   /* cursor c_actions_zero_pay is now removed from here  Bug 3512116*/


   ln_assignment_id           NUMBER;
   ln_tax_unit_id             NUMBER;
   ln_nacha_action_id         NUMBER;
   ln_deposit_action_id       NUMBER;

   lv_legislative_parameters  VARCHAR2(2000);
   ln_assignment_set_id       NUMBER;
   ln_payroll_id              NUMBER;
   ln_consolidation_set_id    NUMBER;

   lc_asg_flag                VARCHAR2(1);

   -- Bug 3512116
   ld_deposit_start_date      DATE;
   ld_deposit_end_date        DATE;



  BEGIN

   get_payroll_action(p_payroll_action_id    => pactid
                     ,p_deposit_start_date   => ld_deposit_start_date
                     ,p_deposit_end_date     => ld_deposit_end_date
                     ,p_assignment_set_id    => ln_assignment_set_id
                     ,p_payroll_id           => ln_payroll_id
                     ,p_consolidation_set_id => ln_consolidation_set_id);

   hr_utility.set_location('procdar archive',1);
   hr_utility.trace('stperson:'||stperson||',endperson:'||endperson||',ln_payroll_id:'||ln_payroll_id||
		    ',ln_consolidation_set_id:'||ln_consolidation_set_id||',ld_deposit_start_date:'||
		    ld_deposit_start_date||',ld_deposit_end_date:'||ld_deposit_end_date);
   open c_paid_actions(stperson, endperson,
                       ln_payroll_id,
                       ln_consolidation_set_id,
                       ld_deposit_start_date,
                       ld_deposit_end_date);
   loop
      hr_utility.set_location('procdar archive',2);

      lc_asg_flag := 'N';

      fetch c_paid_actions into ln_nacha_action_id,
                                ln_assignment_id,
                                ln_tax_unit_id;
      exit WHEN c_paid_actions%NOTFOUND;

      lc_asg_flag :=  hr_assignment_set.assignment_in_set(
                                ln_assignment_set_id,
                                ln_assignment_id);

      IF lc_asg_flag = 'Y' THEN
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

  hr_utility.set_location('procdar archive',4);

 END archive_action_creation;

 /***********************************************************************
 ** Name       : sort_action
 ** Description: This cursor is used to sort the data in the report based
                 on the parameter entered by the user when submitting the
                 report.

                 This procedure is used by both Live and Archive Deposit
                 Advice Reports.
 **********************************************************************/
 PROCEDURE sort_action(procname   in     varchar2,
                       sqlstr     in out NOCOPY varchar2,
                       len        out    NOCOPY number)
 IS

   --Bug 3331028
   l_db_version varchar2(20);

 BEGIN
   -- Databse Version --Bug 3331028
   if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
      l_db_version := '/*+ RULE */';
   else
      l_db_version := '/* NO RULE*/';
   end if;

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
                 and hou.organization_id
                            = nvl(paf.organization_id, paf.business_group_id)
               order by hou.name,ppf.last_name,ppf.first_name
               for update of paa.assignment_id';

   len := length(sqlstr); -- return the length of the string.

 END sort_action;

--Bug 3812668
 -------------------------- action_creation ---------------------------------
 PROCEDURE action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is
--Bug 3331028
  l_db_version varchar2(20);
  l_paid_actions varchar2(5000);

  TYPE PaidActions is REF CURSOR;
  c_paid_actions PaidActions;

-------------------------------------------Assignment Set concept
  CURSOR c_actions_asg_set
      (
         pactid    number,
         stperson  number,
         endperson number,
         p_assignment_set_id number,
	 payid number,
	 consetid number
      ) is
      select distinct act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppa_mag.effective_date,
	     ppa_mag.action_type
      from   pay_assignment_actions         act,
             pay_payroll_actions            ppa_dar,
             pay_payroll_actions            ppa_mag,
    	     pay_org_payment_methods_f      popm,
	         pay_all_payrolls_f             ppf,
             per_all_assignments_f          paf2,
             hr_assignment_sets             has,
             hr_assignment_set_amendments   hasa
      where  ppa_dar.payroll_action_id   = pactid
       and   has.assignment_set_id = p_assignment_set_id
       and   ppa_mag.effective_date between
             ppa_dar.start_date and ppa_dar.effective_date
       and   ppa_mag.consolidation_set_id = consetid
       and  ((    has.payroll_id is null
              and nvl(ppa_mag.payroll_id,ppf.payroll_id)  =
                  nvl(payid, nvl(ppa_mag.payroll_id,ppf.payroll_id))
              ) or
              nvl(ppa_mag.payroll_id,has.payroll_id)  = has.payroll_id
            )
      and    ppa_mag.effective_date between
             ppf.effective_start_date and ppf.effective_end_date
      and    ppf.Payroll_id >= 0
      and    act.payroll_action_id          = ppa_mag.payroll_action_id
      and    act.action_status              = 'C'
      and    ppa_mag.action_type            in ('M','P','U')
      and    decode(ppa_mag.action_type,'M',
	            ppa_mag.org_payment_method_id,
		        popm.org_payment_method_id)  = popm.org_payment_method_id
      and    popm.defined_balance_id  is not null
      and    ppa_mag.effective_date between
             popm.effective_start_date and popm.effective_end_date
      and    hasa.assignment_set_id         = has.assignment_set_id
      and    hasa.assignment_id             = act.assignment_id
      and    hasa.include_or_exclude        = 'I'
      and    paf2.assignment_id              = act.assignment_id
      and    ppa_dar.effective_date between
             paf2.effective_start_date and paf2.effective_end_date
      and    paf2.payroll_id + 0             = ppf.payroll_id
      and    act.assignment_id between stperson and endperson
--  No run results.
      and   NOT EXISTS (SELECT ' '
                          FROM  pay_pre_payments ppp,
                                pay_org_payment_methods_f popm
                          WHERE ppp.assignment_action_id = decode(act.source_action_id,NULL
			                                          ,act.assignment_action_id,
								  act.source_action_id) --Bug 3928576.Check only for master actions.
                          and    ppp.org_payment_method_id = popm.org_payment_method_id
                          and    popm.defined_balance_id IS NOT NULL)
-- and is not a reversal.
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

-------------------------------------------

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

   l_asg_set_id hr_assignment_sets.assignment_set_id%TYPE;

   ld_deposit_start_date      DATE;
   ld_deposit_end_date        DATE;
   ln_payroll_id              NUMBER;
   ln_consolidation_set_id    NUMBER;
   lv_ass_set_on              VARCHAR2(10);
   Zero_Pay_Flag   Varchar2(1);
   ln_person_id number;
   lv_action_type varchar2(1);
  BEGIN
    hr_utility.set_location('procdar',1);

-- Database Version --Bug 3331028
	if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
		l_db_version := '/*+ RULE */';
	  else
		l_db_version := '/* NO RULE*/';
	end if;

--
      get_payroll_action(p_payroll_action_id => pactid
                     ,p_deposit_start_date   => ld_deposit_start_date
                     ,p_deposit_end_date     => ld_deposit_end_date
                     ,p_assignment_set_id    => l_asg_set_id
                     ,p_payroll_id           => ln_payroll_id
                     ,p_consolidation_set_id => ln_consolidation_set_id);

	hr_utility.trace('pactid='||pactid);
	hr_utility.trace('ln_payroll_id='||ln_payroll_id);
	hr_utility.trace('ln_consolidation_set_id='||ln_consolidation_set_id);

-- Query string for the reference cursor c_paid_actions
  l_paid_actions := 'select distinct '||l_db_version||' act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppa_mag.effective_date,
    	     ppa_mag.action_type
      from   pay_assignment_actions         act,
             pay_payroll_actions            ppa_dar,
             pay_payroll_actions            ppa_mag,
             per_all_assignments_f          paf2,
	         pay_org_payment_methods_f      popm, --Bug 3009643
             pay_payrolls_f                 pay   --Bug 3343621
      where  ppa_dar.payroll_action_id          = :pactid
      and    ppa_mag.consolidation_set_id +0    = '|| nvl(ln_consolidation_set_id,0) ||'
      and    ppa_mag.effective_date between
                   ppa_dar.start_date and ppa_dar.effective_date
      and    act.payroll_action_id          = ppa_mag.payroll_action_id
      and    act.action_status              = ''C''
      and    ppa_mag.action_type            in (''M'',''P'',''U'')
      and    decode(ppa_mag.action_type,''M'',
	            ppa_mag.org_payment_method_id,
		    popm.org_payment_method_id)  = popm.org_payment_method_id -- Bug 3009643
      and    popm.defined_balance_id  is not null                        -- Bug 3009643
      and    ppa_mag.effective_date between
             popm.effective_start_date and popm.effective_end_date --Bug 3009643
      and    nvl(ppa_mag.payroll_id,pay.payroll_id) = pay.payroll_id  --Bug 3343621
      and    ppa_mag.effective_date between
             pay.effective_start_date and pay.effective_end_date --Bug 3343621
      and    pay.payroll_id >= 0  --Bug 3343621
      and    paf2.assignment_id              = act.assignment_id
      and    ppa_dar.effective_date between
             paf2.effective_start_date and paf2.effective_end_date
      and    paf2.payroll_id = pay.payroll_id
      and    act.assignment_id between :stperson and :endperson
      and (' || NVL(ln_payroll_id,-99999) || ' = -99999
             or
             pay.payroll_id = ' || NVL(ln_payroll_id,-99999) ||'
             )

--  No run results.
      and   NOT EXISTS (SELECT '' ''
                          FROM  pay_pre_payments ppp,
                                pay_org_payment_methods_f popm
                          WHERE ppp.assignment_action_id = decode(act.source_action_id,NULL
			                                          ,act.assignment_action_id,
								  act.source_action_id) --Bug 3928576.Check only for master actions.
                          and    ppp.org_payment_method_id = popm.org_payment_method_id
                          and    popm.defined_balance_id IS NOT NULL)
-- and is not a reversal.
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
      order by  act.assignment_id DESC';

-- Reference cursor opened for the query string l_paid_actions --Bug 3331028
        if l_asg_set_id is not null then
           open c_actions_asg_set(pactid,stperson,endperson,l_asg_set_id,
	                          ln_payroll_id,ln_consolidation_set_id);
    	else
	   open c_paid_actions for l_paid_actions using pactid, stperson, endperson;
    	end if;
--
      loop
        hr_utility.set_location('procdar',2);
	if l_asg_set_id is not null then
	  fetch c_actions_asg_set into ln_nacha_action_id, ln_assignment_id,
                                       ln_tax_unit_id, ld_effective_date,
				       lv_action_type;
	  exit WHEN c_actions_asg_set%NOTFOUND;
	else
	  fetch c_paid_actions into ln_nacha_action_id, ln_assignment_id,
                                    ln_tax_unit_id, ld_effective_date,
                                    lv_action_type;
	  exit WHEN c_paid_actions%NOTFOUND;
         end if;

         if lv_action_type ='M' then
            Zero_Pay_Flag := 'N';
         else
            Zero_Pay_Flag := 'Y';
         end if;

         hr_utility.trace(' c_paid_actions.ln_nacha_action_id is'
                 ||to_char(ln_nacha_action_id));

     	 open c_pre_payments (ln_nacha_action_id);
         fetch c_pre_payments into ln_pre_pymt_action_id;
         close c_pre_payments;
         hr_utility.trace(' c_pre_payments.ln_pre_pymt_action_id is'
                           ||to_char(ln_pre_pymt_action_id));

        if Zero_Pay_Flag = 'N' then
             hr_utility.trace(' Not a Zero Pay Assignment');
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
                              where assignment_action_id = ln_deposit_action_id;
                         end if;
                        -- skip till next source action id
                        ln_prev_source_action_id := ln_source_action_id;
                   end if;
                end loop;
                close c_payments;
                ln_prev_pre_pymt_action_id := ln_pre_pymt_action_id;
             end if;
      elsif Zero_Pay_Flag = 'Y' then
        hr_utility.trace('Zero Pay Assignment');
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
           close c_payroll_run;

	   update pay_assignment_Actions
              set serial_number = 'M'||ln_master_action_id
            where assignment_action_id = ln_deposit_action_id;

	   hr_utility.trace(' NZ ln_master_action_id is'
                            ||to_char(ln_master_action_id));

           -- skip till next pre payment action id
           ln_prev_pre_pymt_action_id := ln_pre_pymt_action_id;
        end if;
      end if; -- ZERO PAY
     end loop;

     if l_asg_set_id is not null then
        close c_actions_asg_set;
     else
        close c_paid_actions;
     end if;
 END action_creation;

 -- Following Procedure has been added for de-initialization
 -- To be used by (Archive) Deposit Advice process generating
 -- PDF Output.

 procedure archive_deinit(pactid in number) is
 begin

 --pay_core_xdo_utils.archive_deinit(pactid) ;
 pay_archive.remove_report_actions(pactid) ;

 end archive_deinit ;
--
--------------------------------------------------------------------------------
-- QUALIFYING_PROC
--------------------------------------------------------------------------------
PROCEDURE qualifying_proc(p_assignment_id    IN         NUMBER
                         ,p_qualifier        OUT NOCOPY VARCHAR2 ) IS
    --
    l_actid                 NUMBER;
    l_rep_group             pay_report_groups.report_group_name%TYPE;
    l_rep_category          pay_report_categories.category_name%TYPE;
    l_effective_date        DATE;
    l_business_group_id     NUMBER;
    l_assignment_set_id     NUMBER;
    l_assignment_id         NUMBER;
    l_inc_exc               VARCHAR2(1);
    l_asg_inc_exc           VARCHAR2(1);
    --
    l_payroll_id            NUMBER;
    l_consolidation_set_id  NUMBER;
    l_start_date            VARCHAR2(20);
    l_end_date              VARCHAR2(20);
    l_legislation_code      VARCHAR2(10);
    l_start_dt              DATE;
    l_end_dt                DATE;
    l_qualifier             VARCHAR2(1);
    --
    ln_curr_payroll_act_id  NUMBER;
    k                       NUMBER;
    ln_assignment_id        NUMBER;
    ln_action_ctx_id        NUMBER;
    --
    sql_cur                 NUMBER;
    l_rows                  NUMBER;
    statem                  VARCHAR2(256);
    --
    CURSOR csr_asg(c_payroll_id       NUMBER
                  ,c_consolidation_set_id NUMBER
                  ,c_start_date       DATE
                  ,c_end_date         DATE
                  ,c_pa_token         VARCHAR2
                  ,c_cs_token         VARCHAR2
                  ,c_legislation_code VARCHAR2) IS
    SELECT /* 'Y' */
           distinct paa.assignment_id
                   ,pai.action_context_id
    FROM pay_assignment_actions paa
        ,pay_payroll_actions	ppa
        ,hr_lookups             hrl
        ,pay_action_information pai
        ,per_time_periods       ptp
    WHERE /* paa.assignment_id             = c_assignment_id */
          ppa.effective_Date   BETWEEN   c_start_date
                               AND       c_end_date
    AND      ppa.report_type                = hrl.meaning
    AND	 hrl.lookup_type                = 'PAYSLIP_REPORT_TYPES'
    AND	 hrl.lookup_code                = c_legislation_code
    AND	 NVL(c_payroll_id,NVL(pay_payslip_report.get_parameter(ppa.legislative_parameters,c_pa_token),-1))
                                        = NVL(pay_payslip_report.get_parameter(ppa.legislative_parameters,c_pa_token),-1)
    AND	 c_consolidation_set_id     = pay_payslip_report.get_parameter(ppa.legislative_parameters,c_cs_token)

    --
    --
    AND  ppa.payroll_action_id          = paa.payroll_action_id
   -- AND  paa.source_action_id           IS NULL            --RLN P1 8941027
    --
    --
    AND	 pai.assignment_id              = paa.assignment_id
    AND      pai.action_context_type        = 'AAP'
    AND      pai.action_information_category    = 'EMPLOYEE DETAILS'
    AND	 pai.action_context_id          = paa.assignment_action_id
    AND      ptp.time_period_id             = pai.ACTION_INFORMATION16;
    /*
    AND      check_if_qualified_for_US(pai.action_context_id
                                  ,paa.assignment_id
                                  ,c_start_date
                                  ,c_end_date
                                  ,c_consolidation_set_id) = 'Y';
    */
    --
    CURSOR csr_inc_asg(c_payroll_id           NUMBER
                      ,c_consolidation_set_id NUMBER
                      ,c_start_date           DATE
                      ,c_end_date             DATE
                      ,c_pa_token             VARCHAR2
                      ,c_cs_token             VARCHAR2
                      ,c_legislation_code     VARCHAR2
                      ,c_assignment_set_id    NUMBER  ) IS
    SELECT /* 'Y' */
         distinct paa.assignment_id
                 ,pai.action_context_id
    FROM pay_assignment_actions         paa
        ,pay_payroll_actions            ppa
        ,hr_lookups                     hrl
        ,hr_assignment_set_amendments   hasa
        ,pay_action_information         pai
        ,per_time_periods               ptp
    WHERE ppa.effective_Date   BETWEEN	    c_start_date
                              AND		    c_end_date
    AND      ppa.report_type 	   			    = hrl.meaning
    AND	 hrl.lookup_type                    = 'PAYSLIP_REPORT_TYPES'
    AND	 hrl.lookup_code                    = c_legislation_code
    AND	 NVL(c_payroll_id,NVL(pay_payslip_report.get_parameter(ppa.legislative_parameters,c_pa_token),-1))
                                            = NVL(pay_payslip_report.get_parameter(ppa.legislative_parameters,c_pa_token),-1)
    AND	 c_consolidation_set_id             = pay_payslip_report.get_parameter(ppa.legislative_parameters,c_cs_token)
    AND      ppa.payroll_action_id	            = paa.payroll_action_id
    --AND      paa.source_action_id               IS NULL   --RLN P1 894102
    AND	 paa.assignment_id                  = hasa.assignment_id
    AND	 hasa.assignment_set_id             = c_assignment_set_id
    AND	 hasa.include_or_exclude            = 'I'
    AND	 pai.assignment_id                  = paa.assignment_id
    AND      pai.action_context_type            = 'AAP'
    AND      pai.action_information_category    = 'EMPLOYEE DETAILS'
    AND	 pai.action_context_id          = paa.assignment_action_id
    AND  ptp.time_period_id                 = pai.ACTION_INFORMATION16;
    /*
    AND  check_if_qualified_for_US(pai.action_context_id
                                  ,paa.assignment_id
                                  ,c_start_date
                                  ,c_end_date
                                  ,c_consolidation_set_id) = 'Y';
    */
    --
    -- The Assignment Set Logic is handled only for either Include or Exclude
    -- and not for both. This doesn't handle the assignment_set_criteria.
    --
    CURSOR csr_inc_exc(c_assignment_set_id NUMBER
                      ,c_assignment_id     NUMBER) IS
    SELECT include_or_exclude
    FROM  hr_assignment_set_amendments
    WHERE assignment_set_id = c_assignment_set_id
    AND   assignment_id     = nvl(c_assignment_id,assignment_id);
    --
    --
    --

BEGIN
    hr_utility.trace('###### IN Qualifying Proc');
    --
    l_actid    := pay_proc_environment_pkg.get_pactid;
    --
    ln_curr_payroll_act_id := l_actid;
    hr_utility.trace('In QualProc l_actid := ' || l_actid);
    hr_utility.trace('p_assignment_id := ' || p_assignment_id);

    IF pay_us_deposit_advice_pkg.g_payroll_act_id <> ln_curr_payroll_act_id THEN
       pay_us_deposit_advice_pkg.g_payroll_act_id := ln_curr_payroll_act_id;

       pay_payslip_report.get_all_parameters(l_actid
                      ,l_payroll_id
                      ,l_consolidation_set_id
                      ,l_start_date
                      ,l_end_date
                      ,l_rep_group
                      ,l_rep_category
                      ,l_assignment_set_id
                      ,l_assignment_id
                      ,l_effective_date
                      ,l_business_group_id
                      ,l_legislation_code);

          --hr_utility.trace('l_payroll_id :='||l_payroll_id);
          --hr_utility.trace('l_consolidation_set_id :='||l_consolidation_set_id);
          --hr_utility.trace('l_start_date :='||l_start_date);
          --hr_utility.trace('l_end_date :='||l_end_date);
          --hr_utility.trace('l_rep_group :='||l_rep_group);
          --hr_utility.trace('l_rep_category :='||l_rep_category);
          --hr_utility.trace('l_assignment_set_id :='||l_assignment_set_id);
          --hr_utility.trace('l_assignment_id :='||l_assignment_id);
          --hr_utility.trace('l_effective_date :='||l_effective_date);
          --hr_utility.trace('l_business_group_id :='||l_business_group_id);
          --hr_utility.trace('l_legislation_code :='||l_legislation_code);

          --
          l_start_dt := TO_DATE(l_start_date,'YYYY/MM/DD');
          l_end_dt   := TO_DATE(l_end_date,'YYYY/MM/DD');
          --
          -- Fetching legislative prameters for the very first time
          -- And caching them into global variables.

          pay_us_deposit_advice_pkg.g_payroll_id := l_payroll_id;
          pay_us_deposit_advice_pkg.g_consolidation_set_id := l_consolidation_set_id;
          pay_us_deposit_advice_pkg.g_start_dt := l_start_dt;
          pay_us_deposit_advice_pkg.g_end_dt := l_end_dt;
          pay_us_deposit_advice_pkg.g_rep_group := l_rep_group;
          pay_us_deposit_advice_pkg.g_rep_category := l_rep_category;
          pay_us_deposit_advice_pkg.g_assignment_set_id := l_assignment_set_id;
          pay_us_deposit_advice_pkg.g_assignment_id := l_assignment_id;
          pay_us_deposit_advice_pkg.g_effective_date := l_effective_date;
          pay_us_deposit_advice_pkg.g_business_group_id := l_business_group_id;
          pay_us_deposit_advice_pkg.g_legislation_code := l_legislation_code;

    --
            DECLARE
            BEGIN
              statem := 'BEGIN pay_'||l_legislation_code||'_rules.get_token_names(:p_pa_token, :p_cs_token); END;';
              --hr_utility.trace(statem);
              sql_cur := dbms_sql.open_cursor;
              dbms_sql.parse(sql_cur
                            ,statem
                            ,dbms_sql.v7);
              dbms_sql.bind_variable(sql_cur, 'p_pa_token', pay_payslip_report.g_pa_token, 50);
              dbms_sql.bind_variable(sql_cur, 'p_cs_token', pay_payslip_report.g_cs_token, 50);
              l_rows := dbms_sql.execute(sql_cur);
              dbms_sql.variable_value(sql_cur, 'p_pa_token', pay_payslip_report.g_pa_token);
              dbms_sql.variable_value(sql_cur, 'p_cs_token', pay_payslip_report.g_cs_token);
              dbms_sql.close_cursor(sql_cur);
            Exception
              WHEN OTHERS THEN
                  pay_payslip_report.g_pa_token := NVL(pay_payslip_report.g_pa_token,'PAYROLL_ID');
                  pay_payslip_report.g_cs_token := NVL(pay_payslip_report.g_cs_token,'CONSOLIDATION_SET_ID');
                  --
                  IF dbms_sql.IS_OPEN(sql_cur) THEN
                     dbms_sql.close_cursor(sql_cur);
                  END IF;
            END;
    --
    --
    --hr_utility.trace('pay_payslip_report.g_pa_token :='||pay_payslip_report.g_pa_token);
    --hr_utility.trace('pay_payslip_report.g_cs_token :='||pay_payslip_report.g_cs_token);

         IF pay_us_deposit_advice_pkg.g_assignment_set_id IS NULL THEN
            OPEN csr_asg(pay_us_deposit_advice_pkg.g_payroll_id
                        ,pay_us_deposit_advice_pkg.g_consolidation_set_id
                        ,pay_us_deposit_advice_pkg.g_start_dt
                        ,pay_us_deposit_advice_pkg.g_end_dt
                        ,pay_payslip_report.g_pa_token
                        ,pay_payslip_report.g_cs_token
                        ,pay_us_deposit_advice_pkg.g_legislation_code);
            LOOP

            ln_assignment_id := -1;
            ln_action_ctx_id := -1;

            FETCH csr_asg INTO ln_assignment_id, ln_action_ctx_id;

            IF csr_asg%NOTFOUND THEN
               EXIT;
            ELSE
               IF check_if_qualified_for_US(ln_action_ctx_id
                                           ,ln_assignment_id
                                           ,pay_us_deposit_advice_pkg.g_start_dt
                                           ,pay_us_deposit_advice_pkg.g_end_dt
                                           ,pay_us_deposit_advice_pkg.g_consolidation_set_id) = 'Y' THEN

                  g_tmp_tbl(ln_assignment_id) := ln_assignment_id;
                  hr_utility.trace('g_tmp_tbl(' || ln_assignment_id || ') := ' || ln_assignment_id);

               END IF;
            END IF;

            END LOOP;
            CLOSE csr_asg;
            --
         ELSE
            OPEN csr_inc_asg(pay_us_deposit_advice_pkg.g_payroll_id
                        ,pay_us_deposit_advice_pkg.g_consolidation_set_id
                        ,pay_us_deposit_advice_pkg.g_start_dt
                        ,pay_us_deposit_advice_pkg.g_end_dt
                        ,pay_payslip_report.g_pa_token
                        ,pay_payslip_report.g_cs_token
                        ,pay_us_deposit_advice_pkg.g_legislation_code
                        ,pay_us_deposit_advice_pkg.g_assignment_set_id);
            LOOP

            ln_assignment_id := -1;
            ln_action_ctx_id := -1;

            FETCH csr_inc_asg INTO ln_assignment_id, ln_action_ctx_id;

            IF csr_inc_asg%NOTFOUND THEN
               EXIT;
            ELSE
               IF check_if_qualified_for_US(ln_action_ctx_id
                                           ,ln_assignment_id
                                           ,pay_us_deposit_advice_pkg.g_start_dt
                                           ,pay_us_deposit_advice_pkg.g_end_dt
                                           ,pay_us_deposit_advice_pkg.g_consolidation_set_id) = 'Y' THEN

                  g_tmp_tbl(ln_assignment_id) := ln_assignment_id;
                  hr_utility.trace('g_tmp_tbl(' || ln_assignment_id || ') := ' || ln_assignment_id);
               END IF;
            END IF;

            END LOOP;
            CLOSE csr_inc_asg;

         END IF;
    END IF;

    l_qualifier := 'N';
    k := 1;

    hr_utility.trace('g_tmp_tbl.COUNT := ' || g_tmp_tbl.COUNT);

    IF g_tmp_tbl.EXISTS(p_assignment_id) THEN
       l_qualifier := 'Y';
    END IF;

    hr_utility.trace('B4 Return l_qualifier := ' || l_qualifier);


    IF l_qualifier = 'Y' THEN
       p_qualifier := 'Y' ;
    END IF;

  END qualifying_proc;
--
--
 /********************************************************************
 ** Procedure  : DAxml_range_cursor
 ** Description: This is used for DA (XML) program
 **
 ********************************************************************/
 PROCEDURE DAxml_range_cursor(pactid in number
                             ,psqlstr out NOCOPY varchar2)
 IS

   ln_assignment_set_id       NUMBER;
   ln_payroll_id              NUMBER;
   ln_consolidation_set_id    NUMBER;
   ld_deposit_start_date      DATE;
   ld_deposit_end_date        DATE;

   --Bug 3331028
   l_db_version varchar2(20);
   --
   lv_rep_group               pay_report_groups.report_group_name%TYPE;
   lv_rep_category            pay_report_categories.category_name%TYPE;
   l_assignment_id            NUMBER;
   ld_effective_date          DATE;
   ln_business_group_id       NUMBER;
   lv_legislation_code        VARCHAR2(10);
   lv_sqlstr                  VARCHAR2(32000);

 BEGIN
   hr_utility.trace('Entering into Func DAxml_range_cursor');
   get_DAxml_payroll_action(p_payroll_action_id    => pactid
                     ,p_deposit_start_date   => ld_deposit_start_date
                     ,p_deposit_end_date     => ld_deposit_end_date
                     ,p_assignment_set_id    => ln_assignment_set_id
                     ,p_payroll_id           => ln_payroll_id
                     ,p_consolidation_set_id => ln_consolidation_set_id);

          hr_utility.trace('ln_payroll_id :='||ln_payroll_id);
          hr_utility.trace('ln_consolidation_set_id :='||ln_consolidation_set_id);
          hr_utility.trace('ld_deposit_start_date :='||ld_deposit_start_date);
          hr_utility.trace('ld_deposit_end_date :='||ld_deposit_end_date);
          hr_utility.trace('ln_assignment_set_id :='||ln_assignment_set_id);
          --
          --

  --Database Version --Bug 3331028
  if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
     l_db_version := '/*+ RULE */';
  else
     l_db_version := '/* NO RULE*/';
  end if;

  if ln_payroll_id is not null then
     if ln_assignment_set_id is not null then

           lv_sqlstr := 'select '||l_db_version||' distinct paf.person_id
                        from pay_assignment_actions paa,
                             pay_payroll_actions    ppa,
                             per_assignments_f paf,
                             hr_assignment_set_amendments hasa
                       where :payroll_action_id is not null
                         and ppa.action_type in (''R'',''Q'')
                         and paa.assignment_id = paf.assignment_id
                         and ppa.consolidation_set_id = ' || ln_consolidation_set_id
                    || ' and ppa.payroll_id = ' || ln_payroll_id
                    || ' and ppa.effective_date between ''' || ld_deposit_start_date
                    ||                            ''' and ''' || ld_deposit_end_date
                    || ''' and paa.payroll_action_id = ppa.payroll_action_id'
                    || ' and paa.assignment_id = hasa.assignment_id'
                    || ' and hasa.assignment_set_id = ' || ln_assignment_set_id
                    || ' and hasa.include_or_exclude = ''I'''
                    || ' order by paf.person_id';
     else
           lv_sqlstr := 'select '||l_db_version||' distinct paf.person_id
                        from pay_assignment_actions paa,
                             pay_payroll_actions    ppa,
                             per_assignments_f paf
                       where :payroll_action_id is not null
                         and ppa.action_type in (''R'',''Q'')
                         and paa.assignment_id = paf.assignment_id
                         and ppa.consolidation_set_id = ' || ln_consolidation_set_id
                    || ' and ppa.payroll_id = ' || ln_payroll_id
                    || ' and ppa.effective_date between ''' || ld_deposit_start_date
                    ||                            ''' and ''' || ld_deposit_end_date
                    || ''' and paa.payroll_action_id = ppa.payroll_action_id
                      order by paf.person_id';
     end if; -- ln_assignment_set_id NOT NULL

  else
     if ln_assignment_set_id is not null then
           lv_sqlstr := 'select '||l_db_version||' distinct paf.person_id
                        from pay_assignment_actions paa,
                             pay_payroll_actions    ppa,
                             per_assignments_f paf,
                             hr_assignment_set_amendments hasa
                       where :payroll_action_id is not null
                         and ppa.action_type in (''R'',''Q'')
                         and paa.assignment_id = paf.assignment_id
                         and ppa.consolidation_set_id = ' || ln_consolidation_set_id
                    || ' and ppa.effective_date between ''' || ld_deposit_start_date
                    ||                            ''' and ''' || ld_deposit_end_date
                    || ''' and paa.payroll_action_id = ppa.payroll_action_id'
                    || ' and paa.assignment_id = hasa.assignment_id'
                    || ' and hasa.assignment_set_id = ' || ln_assignment_set_id
                    || ' and hasa.include_or_exclude = ''I'''
                    || ' order by paf.person_id';

      else
           lv_sqlstr := 'select '||l_db_version||' distinct paf.person_id
                        from pay_assignment_actions paa,
                             pay_payroll_actions    ppa,
                             per_assignments_f paf
                       where :payroll_action_id is not null
                         and ppa.action_type in (''R'',''Q'')
                         and paa.assignment_id = paf.assignment_id
                         and ppa.consolidation_set_id = ' || ln_consolidation_set_id
                    || ' and ppa.effective_date between ''' || ld_deposit_start_date
                    ||                            ''' and ''' || ld_deposit_end_date
                    || ''' and paa.payroll_action_id = ppa.payroll_action_id
                      order by paf.person_id';
     end if; -- ln_assignment_set_id NOT NULL

  end if;

  hr_utility.trace('lv_sqlstr := ' || lv_sqlstr);

  psqlstr := lv_sqlstr;

 end DAxml_range_cursor;
--
--
end pay_us_deposit_advice_pkg;

/
