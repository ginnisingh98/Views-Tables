--------------------------------------------------------
--  DDL for Package Body PAY_PAYRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYRG_PKG" AS
/* $Header: pypayreg.pkb 120.3 2007/07/05 05:33:27 vmkulkar noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Name:    This package defines the cursors needed to run
            Payroll Register Multi-Threaded

   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   09-MAR-1999  meshah      40.0   created
   14-AUG-2000  SRAVURI	   115.1   modified (addred the assignment
                                   set funtionality)
   16-AUG-2000  ahanda 	   115.2   Uncommented exit statement and
                                   added commit
   13-APR-2001  ahanda 	   115.3   Changed sort cursor and formated
                                   the file. Changed HR_LOCATIONS to
                                   HR_LOCATIONS_ALL.
   26-apr-2001  tclewis    115.4   modified the cursor(s) in the range_cursor
                                   and action creation to use secure views.
                                   modified the sql query in the sort_code
                                   routine to use base tables.
   22-AUG-2001  tclewis    115.5   modifed the action creation cursor to
                                   work the umbrella process.
   21-DEC-2001  meshah     115.6   adding dbdrv.
   24-DEC-2001  meshah     115.7   changed the cursor c_payroll_run to
                                   work with the employees that were created
                                   before the umbralle process. Also making
                                    the action as dynamic.
   27-DEC-2001  tclewis    115.8   modified the c_payroll_run cursor
                                   removing the descending on the order by
                                   clause as we want to return the minimum
                                   Assignment_action_id first.
   05-JAN-2002  ahanda     115.9   Modified the action creation cursor to
                                   update serial numner with whether it is
                                   master or child (sep check) action.
   20-MAR-2002  tclewis    115.10  Added code to the action creation to
                                   handle multi-assignment processing.
   13-JUN-2002  tclewis    115.14  Modified the actions_creation cursro
                                   non multiple assigmnet payroll register
                                   to set a temporary flab l_action_insert
                                   := 'Y' as to not insert an extra record
                                   when the payment cursor returns no data.
   13-JUN-2002  tclewis    115.15  fixed a bug where we are not exiting the
                                   c_payments loop correctly.

   07-AUG-2002  rmonge     115.16  Increase size of action_type to varchar2(30)
   21-oct-2002 tclewis     115.17  removed the "for Update... " in the action_creation
                                   code.  Changed the "for update" clause
                                   in the sort_cursor to paa.assignment_id from
                                   paf.assignment_id
   19-DEC-2002 tclewis      115.18 added nocopy.
   27-DEC-2002 meshah       115.19 fixed gscc warning.
   17-SEP-2003 ardsouza     115.20 modified sort_action procedure to sort based on
                                   date paid of 'P','U'& 'V' process(Bug 2641972).
   26-jan-2004 djoshi       115.22 modified action_creation for bug 3385676
                                   We will insert multiple rows for when
                                   pre-payment is locking multiple rows.
   27-jan-2004 djoshi       115.23 Corrected missing exit statement
   29-jan-2004 djoshi       115.24 the action creation cursor has been
                                   changed to make sure we have
                                   missing assignment actions
                                   also Created

   05-feb-2004 ssmukher     115.25 Bug 3372747: 11.5.10 Performance Changes
   09-Feb-2004 ssmukher     115.26 Bug 3372747 - Corrected dec for
                                   leg_param.
   16-Feb-2004 djoshi       115.27 Bug  3423464. Regular Not showing up
   15-Mar-2005 schauhan     115.37 Added Logic for showing Balance Adjustments on report.
                                   Bug 4074976.
   09-May-2006 ppanda       115.38 Bug # 5204333 Fixed
                                   lv_max_run_flag which was used in action_creation
				   procedure was not re-initialized after processing
				   the Actions for Balance Adjustments.
				   This variable is initialized with default value N
				   after processing actions in the loop
   20-Sep-2006 sjawid       115.39 Bug 	5366862 fixed
                                   i.added date effective join  to c_payroll_def.
				   ii.changed the c_payroll_def Open statement to
				   use the EFFECTIVE_DATE from the
				   PRE_PAYMENTS PAYROLL ACTION,
				   not the effective date from the
				   payroll register payroll action.
   28-jun-2007 vmkulkar     115.40 Created a new cursor c_actions_1
				   Bug 5502369

*/

 --------------------------- range_cursor ---------------------------------
PROCEDURE range_cursor (pactid in number,
                         sqlstr out nocopy varchar2) is

   leg_param    pay_payroll_actions.legislative_parameters%type;

  l_consolidation_set_id number;
  l_payroll_id number;
  l_organization_id number;
  l_location_id number;
  l_person_id number;
  l_leg_start_date date;
  l_leg_end_date   date;

  l_business_group_id number;

  l_payroll_text   varchar2(70);
  l_consolidation_set_text varchar2(50);

 BEGIN
   select legislative_parameters
     into leg_param
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

  select ppa.legislative_parameters,
          pay_payrg_pkg.get_parameter('C_ST_ID', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('PY_ID', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('O_ID', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('L_ID', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('P_ID', ppa.legislative_parameters),
          ppa.start_date,
          ppa.effective_date,
          ppa.business_group_id
     into leg_param,
          l_consolidation_set_id,
          l_payroll_id,
          l_organization_id,
          l_location_id,
          l_person_id,
          l_leg_start_date,
          l_leg_end_date,
          l_business_group_id
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

    IF l_consolidation_set_id is not null THEN

       l_consolidation_set_text := 'and pa1.consolidation_set_id = ' || to_char(l_consolidation_set_id) ;


    ELSE

        l_consolidation_set_text := NULL;

    END IF;

    IF l_payroll_id is not null THEN

       l_payroll_text := 'and pa1.payroll_id = ' || to_char(l_payroll_id) ;

    ELSE

         l_payroll_text := null;

/*      if l_consolidation_set_id is not null then
         l_payroll_text := null;
      else
         l_payroll_text := 'and pa1.payroll_id in (select payroll_id from pay_payrolls_f)';
      end if;
*/
    END IF;




    sqlstr :=
      'select distinct asg.person_id
         from pay_payroll_actions    ppa,
              pay_payroll_actions    pa1,
              pay_assignment_actions act,
              per_assignments_f      asg,
              pay_payrolls_f         ppf
         where ppa.payroll_action_id    = :payroll_action_id
                '||l_consolidation_set_text||'
                '||l_payroll_text||'
                and pa1.effective_date between ppa.start_date
                                           and ppa.effective_date
                and pa1.effective_date between asg.effective_start_date
                                           and asg.effective_end_date
                and pa1.action_type in (''P'',''U'',''V'')
                and pa1.payroll_action_id = act.payroll_action_id
                and asg.assignment_id = act.assignment_id
                and act.action_status = ''C''
                and asg.organization_id = nvl('''||l_organization_id||''',
                                                    asg.organization_id)
                and asg.location_id     = nvl('''||l_location_id||''',
                                                    asg.location_id)
                and asg.person_id       = nvl('''||l_person_id||''',
                                                    asg.person_id)
                and asg.business_group_id +0 = ppa.business_group_id
                and asg.payroll_id = ppf.payroll_id
                and ppa.effective_date between ppf.effective_start_date and ppf.effective_end_date
                and ppf.payroll_id >=0
              order by asg.person_id';


 END range_cursor;


 ----------------------------- action_creation --------------------------------
PROCEDURE action_creation( pactid    in number,
                            stperson  in number,
                            endperson in number,
                            chunk     in number)
 IS

  cursor c_inputs(pactid     number) is  -- Bug 3372747
       select pay_payrg_pkg.get_parameter('PY_ID',ppa.legislative_parameters) payroll_id,
	      pay_payrg_pkg.get_parameter('C_ST_ID',ppa.legislative_parameters) consolidation_set_id,
	      pay_payrg_pkg.get_parameter('T_U_ID',ppa.legislative_parameters) tax_unit_id,
	      pay_payrg_pkg.get_parameter('L_ID',ppa.legislative_parameters) location_id,
	      pay_payrg_pkg.get_parameter('O_ID',ppa.legislative_parameters) organization_id,
	      pay_payrg_pkg.get_parameter('P_ID',ppa.legislative_parameters) person_id,
	      pay_payrg_pkg.get_parameter('B_G_ID',ppa.legislative_parameters) business_group_id,
   	      pay_payrg_pkg.get_parameter('PASID',ppa.legislative_parameters) assignment_set_id,
	      ppa.start_date start_date,
	      ppa.effective_date effective_date
       from   pay_payroll_actions  ppa
       where  ppa.payroll_action_id = pactid;

  cursor c_actions(
                   c_stperson             number,
                   c_endperson            number ,
		   c_payroll_id           number,
		   c_consolidation_set_id number,
		   c_tax_unit_id          number,
                   c_location_id          number,
		   c_organization_id      number,
		   c_person_id            number,
		   c_business_group_id    number,
		   c_start_date           date,
		   c_effective_date       date
                  ) is   -- Bug 3372747
      select /*+ ORDERED */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppa.action_type,
             ppa.effective_date,
             act.source_action_id,
             nvl(ppa.start_date,ppa.effective_date)
      from   pay_payrolls_f ppf,  -- Bug 3372747
             pay_payroll_actions     ppa,  /* pre-payments and reversals
                                              payroll action id */
             pay_assignment_actions  act,
             per_assignments_f       paf
      where (c_payroll_id is NULL
             or ppa.payroll_id = c_payroll_id)
        and ppa.consolidation_set_id +0    = nvl(c_consolidation_set_id,
                                                  ppa.consolidation_set_id)
        and ppa.effective_date >= c_start_date
        and nvl(ppa.start_date,ppa.effective_date) <= c_effective_date
--                        decode (ppa.action_type,'P', add_months(c_effective_date,12),
--                                                'U', add_months(c_effective_date,12),
--                                                'V', c_effective_date)
--        c_effective_date
        and ppa.action_type in ('P','U','V')
        and act.action_status = 'C'
        and act.payroll_action_id = ppa.payroll_action_id
        and ppa.business_group_id +0 = c_business_group_id
        and paf.assignment_id = act.assignment_id
        and (c_tax_unit_id is NULL
            or act.tax_unit_id = c_tax_unit_id)
        and (c_organization_id is NULL
            or paf.organization_id = c_organization_id)
        and (c_location_id is NULL
            or paf.location_id = c_location_id)
        and (c_person_id is NULL
            or paf.person_id = c_person_id)
        and paf.person_id between c_stperson and c_endperson
        and paf.business_group_id +0 = c_business_group_id
        and ppa.effective_date between paf.effective_start_date
                                   and paf.effective_end_date
        and ppa.payroll_id = ppf.payroll_id  -- Bug 3372747
        and ppa.effective_date between ppf.effective_start_date and ppf.effective_end_date
        and ppf.payroll_id >= 0
        order by act.assignment_id;

-- This cursor will take care of the assignment set id parameter.
  cursor c_actions_1(
                   c_stperson             number,
                   c_endperson            number ,
		           c_payroll_id           number,
		           c_consolidation_set_id number,
		           c_tax_unit_id          number,
                   c_location_id          number,
		           c_organization_id      number,
		           c_person_id            number,
		           c_business_group_id    number,
                   c_assignment_set_id    number,
                   c_start_date           date,
		           c_effective_date       date
                  ) is   -- Bug 3372747
      select /*+ ORDERED */
             act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppa.action_type,
             ppa.effective_date,
             act.source_action_id,
             nvl(ppa.start_date,ppa.effective_date)
      from
     HR_ASSIGNMENT_SET_AMENDMENTS HASA ,
     PER_ASSIGNMENTS_F PAF ,
     PAY_ASSIGNMENT_ACTIONS ACT ,
     PAY_PAYROLL_ACTIONS PPA ,
     PAY_PAYROLLS_F PPF
      where (c_payroll_id is NULL
             or ppa.payroll_id = c_payroll_id)

	and ppa.consolidation_set_id +0    = nvl(c_consolidation_set_id,
                                                  ppa.consolidation_set_id)
        and ppa.effective_date >= c_start_date
        and nvl(ppa.start_date,ppa.effective_date) <= c_effective_date
--                        decode (ppa.action_type,'P', add_months(c_effective_date,12),
--                                                'U', add_months(c_effective_date,12),
--                                                'V', c_effective_date)
--        c_effective_date
        and ppa.action_type in ('P','U','V')
        and act.action_status = 'C'
        and act.payroll_action_id = ppa.payroll_action_id
        and ppa.business_group_id +0 = c_business_group_id
        and paf.assignment_id = act.assignment_id
        and (c_tax_unit_id is NULL
            or act.tax_unit_id = c_tax_unit_id)
        and (c_organization_id is NULL
            or paf.organization_id = c_organization_id)
        and (c_location_id is NULL
            or paf.location_id = c_location_id)
        and (c_person_id is NULL
            or paf.person_id = c_person_id)
        and hasa.assignment_set_id = c_assignment_set_id
        and hasa.assignment_id = paf.assignment_id
        and paf.person_id between c_stperson and c_endperson
        and paf.business_group_id +0 = c_business_group_id
        and ppa.effective_date between paf.effective_start_date
                                   and paf.effective_end_date
        and ppa.payroll_id = ppf.payroll_id  -- Bug 3372747
        and ppa.effective_date between ppf.effective_start_date and ppf.effective_end_date
        and ppf.payroll_id >= 0
        order by act.assignment_id;


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

   cursor c_payment_info (cp_pre_pymt_action_id in number) is
     select distinct nvl(ppp.source_action_id,-999)
       from pay_payment_information_v ppp
      where ppp.assignment_action_id = cp_pre_pymt_action_id
        and ppp.action_status = 'C'
      order by 1;

   cursor c_run_eff_date (cp_pre_pymt_action_id in number) is
     select ppa.effective_date,
            ppa.action_type
       from pay_action_interlocks pai,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
      where pai.locking_action_id = cp_pre_pymt_action_id
        and paa.assignment_action_id = pai.locked_action_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and ppa.action_type in ('R', 'Q', 'B');

   cursor c_payroll_run (cp_pre_pymt_action_id in number) is
     select assignment_action_id, ppa.action_type
       from pay_action_interlocks pai,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
      where pai.locking_action_id = cp_pre_pymt_action_id
        and paa.assignment_action_id = pai.locked_action_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and ((paa.run_type_id is null and paa.source_action_id is null) or
             (paa.run_type_id is not null and paa.source_action_id is not null
              and paa.run_type_id in
                       (select prt.run_type_id
                          from pay_run_types_f prt
                         where prt.shortname <> 'SEPCHECK'
                           and prt.legislation_code = 'US'
                           and ppa.effective_date between prt.effective_start_date
                                                      and prt.effective_end_date)
             )
            )
       order by assignment_action_id desc;

 -- Bug 4074976 -- Added a new cursor for Balance Adjustments for multiple assignment payroll.
   cursor c_multi_ba_acts(cp_pre_pymt_action_id in number) is
     select assignment_action_id, ppa.action_type
       from pay_action_interlocks pai,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
      where pai.locking_action_id = cp_pre_pymt_action_id
        and paa.assignment_action_id = pai.locked_action_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and ((paa.run_type_id is null and paa.source_action_id is null) or
             (paa.run_type_id is not null and paa.source_action_id is not null
              and paa.run_type_id in
                       (select prt.run_type_id
                          from pay_run_types_f prt
                         where prt.shortname <> 'SEPCHECK'
                           and prt.legislation_code = 'US'
                           and ppa.effective_date between prt.effective_start_date
                                                      and prt.effective_end_date)
             )
            )
	 and ppa.action_type = 'B'
       order by assignment_action_id desc;

   cursor c_payroll_def (cp_assignment_id in number,
                         cp_effective_date in date) is
          select multi_assignments_flag
          from   pay_payrolls_f ppf,
                 per_assignments_f paf
          where  paf.payroll_id = ppf.payroll_id
          and    cp_effective_date between paf.effective_start_date
                                   and     paf.effective_end_date
	  and    cp_effective_date between ppf.effective_start_date --bug5366862
                                   and     ppf.effective_end_date
          and    paf.assignment_id = cp_assignment_id;


-- May need to add fetch of paa2.tax_unit_id and group by
-- this will corectly create the appropiate number of assignment
-- actions for the report.  Also, pass tax_unit_id to this query
-- to only return the specific tu assignment actions.


   cursor c_multi_asg_acts (cp_pre_pymt_action_id in number) is
     select max(paa2.assignment_action_id)
     from   pay_assignment_actions paa2,  -- assignment_actions for slave payroll runs.
            pay_assignment_actions paa1,  -- assignment_action for master payroll run
            pay_run_Types_f prt,
            pay_payroll_actions ppa,
            pay_action_interlocks pai
     where  pai.locking_action_id = cp_pre_pymt_action_id
     and    pai.locked_action_id = paa1.assignment_action_id
     and    paa1.source_action_id is null -- master assignment_action
     and    paa1.assignment_action_id = paa2.source_action_id
     and    paa1.payroll_action_id = paa2.payroll_action_id
     and    paa2.run_type_id = prt.run_type_id
     and    prt.shortname <> 'SEPCHECK'
     and    prt.legislation_code = 'US'
     and    paa2.payroll_action_id = ppa.payroll_action_id
     and    ppa.effective_date between prt.effective_start_date
                              and prt.effective_end_date;



-- May need to add fetch of paa2.tax_unit_id and group by
-- this will corectly create the appropiate number of assignment
-- actions for the report.  Also, pass tax_unit_id to this query
-- to only return the specific tu assignment actions.

cursor c_multi_asg_rpt_acts (cp_pre_pymt_action_id in number) is
     select distinct max(paa2.assignment_action_id)
     from   pay_assignment_actions paa2,
              -- assignment_actions for slave payroll runs.
            pay_assignment_actions paa1,
              -- assignment_action for master payroll run
            pay_run_Types_f prt,
            pay_payroll_actions ppa,
            pay_action_interlocks pai
     where  pai.locking_action_id = cp_pre_pymt_action_id
     and    pai.locked_action_id = paa1.assignment_action_id
     and    paa1.source_action_id is null -- master assignment_action
     and    paa1.assignment_action_id = paa2.source_action_id
     and    paa1.payroll_action_id = paa2.payroll_action_id
     and    paa2.run_type_id = prt.run_type_id
     and    prt.shortname <> 'SEPCHECK'
     and    prt.legislation_code = 'US'
     and    paa2.payroll_action_id = ppa.payroll_action_id
     and    ppa.effective_date between prt.effective_start_date
                              and prt.effective_end_date
     group by paa1.assignment_action_id;

cursor c_check_for_void (cp_pre_pymt_action_id in number) is
      select 'Y'
      from   pay_action_interlocks pai,
             pay_assignment_actions paa,
             pay_payroll_actions   ppa
      where  pai.locking_action_id = cp_pre_pymt_action_id
      and    paa.assignment_action_id = pai.locked_action_id
      and    ppa.payroll_action_id = paa.payroll_action_id
      and    action_type = 'V';

    lockingactid  number;
    lockedactid   number;
    assignid      number;
    greid         number;
    num           number;
    runactid      number;
    actiontype    VARCHAR2(1);
    serialno      VARCHAR2(30);

    -- Bug 3372747
    l_leg_param   pay_payroll_actions.legislative_parameters%TYPE;
    l_asg_set_id  number;
    l_asg_flag    VARCHAR2(10);
    l_effective_date date;
    l_start_date     date;
    l_multi_asg_flag VARCHAR(1);
    l_source_action_id NUMBER;

   ln_pre_pymt_action_id      NUMBER;

   ln_source_action_id        NUMBER;
   ln_prev_source_action_id   NUMBER := null;

   ln_master_action_id        NUMBER;
   lv_run_action_type         VARCHAR2(30);
   lv_sep_check               VARCHAR2(1);
   lv_multi_asg_flag          VARCHAR2(1);
   lv_source_action_id        NUMBER;

   l_asg_act_id               number;
   l_action_insert            varchar2(1);
   l_void_action              varchar2(1);

   l_payroll_id	           pay_payroll_actions.payroll_id%TYPE;
   l_location_id           per_all_assignments_f.location_id%TYPE;
   l_consolidation_set_id  pay_payroll_actions.consolidation_set_id%TYPE;
   l_tax_unit_id           pay_assignment_actions.tax_unit_id%TYPE;
   l_person_id             per_all_assignments_f.person_id%TYPE;
   l_business_group_id     per_all_assignments_f.business_group_id%TYPE;
   l_organization_id       per_all_assignments_f.organization_id%TYPE;
   l_assignment_set_id     hr_assignment_set_amendments.assignment_set_id%TYPE;
   cp_start_date           pay_payroll_actions.effective_date%TYPE;
   cp_effective_date       pay_payroll_actions.effective_date%TYPE;

   l_run_eff_date          date;
   run_action_type         VARCHAR2(30);

   lv_max_run_flag          VARCHAR2(1) := 'N' ;
   lv_max_run_id            number;

    -- algorithm is quite similar to the other process cases,
    -- but we have to take into account assignments and
    -- personal payment methods.
 BEGIN
    hr_utility.set_location('procpyr',1);

    select legislative_parameters
    into l_leg_param
    from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

 --   hr_utility.trace('Payroll Action ID = '||pactid);

    open c_inputs( pactid);

         fetch c_inputs into l_payroll_id,
                             l_consolidation_set_id ,
                             l_tax_unit_id,
                             l_location_id,
    			     l_organization_id ,
                             l_person_id,
			     l_business_group_id,
  			     l_assignment_set_id,
 			     cp_start_date,
 			     cp_effective_date ;

    close c_inputs;

 -- hr_utility.trace('stperson '||stperson);
 -- hr_utility.trace('endperson '||endperson);
 -- hr_utility.trace('l_payroll_id '||l_payroll_id);
 -- hr_utility.trace('l_consolidation_set_id '||l_consolidation_set_id);
 -- hr_utility.trace('l_tax_unit_id '||l_tax_unit_id);
 -- hr_utility.trace('l_location_id '||l_location_id);
 -- hr_utility.trace('l_organization_id '||l_organization_id);
 -- hr_utility.trace('l_person_id '||l_person_id);
 -- hr_utility.trace('l_business_group_id '||l_business_group_id);
 -- hr_utility.trace('l_assignment_set_id '||l_assignment_set_id);
 -- hr_utility.trace('cp_start_date '||cp_start_date);
 -- hr_utility.trace('cp_effective_date '||cp_effective_date);

    if l_assignment_set_id is NULL then

    open c_actions( stperson
                   ,endperson
                   ,l_payroll_id
                   ,l_consolidation_set_id
                   ,l_tax_unit_id
                   ,l_location_id
                   ,l_organization_id
                   ,l_person_id
                   ,l_business_group_id
                   ,cp_start_date
                   ,cp_effective_date);



    else

    open c_actions_1( stperson
                   ,endperson
                   ,l_payroll_id
                   ,l_consolidation_set_id
                   ,l_tax_unit_id
                   ,l_location_id
                   ,l_organization_id
                   ,l_person_id
                   ,l_business_group_id
                   ,l_assignment_set_id
                   ,cp_start_date
                   ,cp_effective_date);

    end if;



    l_asg_set_id := pay_payrg_pkg.get_parameter('PASID',l_leg_param);

    num := 0;
    loop
       hr_utility.set_location('procpyr',2);

       if l_assignment_set_id is NULL then

       hr_utility.trace('in c_actions num= '||num);
       fetch c_actions into  lockedactid
                            ,assignid
                            ,greid
                            ,actiontype
                            ,l_effective_date
                            ,l_source_action_id
                            ,l_start_date;
       if c_actions%found then num := num + 1; end if;
       exit when c_actions%notfound;

       else

       hr_utility.trace('in c_actions_1 num= '||num);
       fetch c_actions_1 into  lockedactid
                            ,assignid
                            ,greid
                            ,actiontype
                            ,l_effective_date
                            ,l_source_action_id
                            ,l_start_date;
       if c_actions_1%found then num := num + 1; end if;
       exit when c_actions_1%notfound;
       end if;

       l_asg_flag := 'N';
       l_action_insert := 'N';

       if l_asg_set_id is not null then
          l_asg_flag := hr_assignment_set.assignment_in_set(l_asg_set_id, assignid);
       else  -- l_asg_set_id is null
          l_asg_flag := 'Y';
       end if;

       --  Checking if the payroll_run effective date is in the range
       --  of c_start date and c_end date as the report must now run
       --  on RUN effective_dates not Pre_payments effective_date
/*       if     l_start_date between cp_start_date and cp_effective_date
          and l_effective_date between cp_start_date and cp_effective_date then

              NULL;
       ELSE
*/
               if (actiontype = 'P'
                  or actiontype =  'U') THEN
                  open c_run_eff_date (lockedactid) ;

                  fetch c_run_eff_date into l_run_eff_date,
                                            run_action_type;
                  if c_run_eff_date%NOTFOUND THEN
                     l_asg_flag := 'N';
                  end if;
                  close c_run_eff_date;

                  if l_run_eff_date between cp_start_date and cp_effective_date then
                      NULL;
                  else
                      l_asg_flag := 'N';
                  end if;
               end if;

/*       end if;
*/

       if l_asg_flag = 'Y' then

          -- check to see if the payroll on this assignment is
          -- multi-assignmnet payroll enabled.

           open  c_payroll_def(assignid, l_effective_date); --bug5366862
           fetch c_payroll_def into l_multi_asg_flag;
           if    c_payroll_def%NOTFOUND then
                 l_multi_asg_flag := 'N';
           end if;
           close c_payroll_def;

           if l_multi_asg_flag = 'Y' then

               IF actiontype in ('P', 'U') THEN

                   if l_source_action_id is not null then
                   -- this is a multi assignment payroll, however
                   -- we will treat separate check assignments as
                   -- no multi assignment as only one run action
                   -- will be returned.

                      lv_sep_check := 'Y';
                      lv_multi_asg_flag := 'N';
                      lv_source_action_id := NULL;

                      open c_payments (lockedactid) ;

                      loop

                       --  if there a multiple separate check elements for
                       --  this assignment we must create 1 payroll register
                       --  assignment action for each payment.

                          fetch c_payments into runactid;
                          exit when c_payments%NOTFOUND;
                            if runactid is not null then   -- Bug 3928632

                          select pay_assignment_actions_s.nextval
                            into lockingactid
                            from dual;

                          -- insert the action record.
                          hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                          -- insert an interlock to this action.
                          hr_nonrun_asact.insint(lockingactid,lockedactid);

                          begin

                          serialno := nvl(lv_run_action_type,'R') ||
                                      lv_sep_check ||
                                      lv_multi_asg_flag ||
                                      to_char(runactid);

                          -- update pay_assignment_actions serial_number with runactid.

                          update pay_assignment_actions
                          set serial_number = serialno
                          where assignment_action_id = lockingactid
                          and  tax_unit_id = greid;

                          exception when others then
                            null;
                          end;

                          -- Insert a row in pay_us_rpt_totals which includes
                          -- payroll_action_id,
                          -- report created assignment_action_id (lockingactid)
                          -- and "payroll run" assignment_action id.

                          insert into pay_us_rpt_totals
                          (session_id,
                           tax_unit_id,
                           location_id,
                           value1)
                           values(pactid,
                           pactid,
                           lockingactid,
                           runactid);
                             end if;
                       end loop;
                      close c_payments;

                   else  -- this is a multi assignment payroll so we must
                         -- create only on assignment action for the Pre-payment
                         -- action returned in the query above.

                      lv_sep_check := 'N';
                      lv_multi_asg_flag := 'Y';
                      lv_source_action_id := lockedactid;
                      l_void_action := 'N';

                      open c_check_for_void ( lockedactid);

                      fetch c_check_for_void into l_void_action;

                      if   c_check_for_void%NOTFOUND then
                           l_void_action := 'N';
                      end if;

                      close c_check_for_void;

                      if l_void_action = 'N' then

                          -- get the maximum runact for all assignments to be
                          -- included in this register row, as it will be used
                          -- for person level balance calls in the report.

                          open c_multi_asg_acts (lockedactid) ;

                          fetch c_multi_asg_acts into runactid;

                          close c_multi_asg_acts;

                          select pay_assignment_actions_s.nextval
                            into lockingactid
                            from dual;

                          -- insert the action record.
                          hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                          -- insert an interlock to this action.
                          hr_nonrun_asact.insint(lockingactid,lockedactid);

--Bug 4074976 for MAP showning Balance Adjustment.

                         open c_multi_ba_acts (lockedactid);
			   loop
                             fetch c_multi_ba_acts into  l_asg_act_id,run_action_type;
			     exit when c_multi_ba_acts%notfound;

			     insert into pay_us_rpt_totals
                               (session_id,
                                tax_unit_id,
                                location_id,
                                value1)
                              values(pactid,
                                     pactid,
                                     lockingactid,
                                     l_asg_act_id);

                              if lv_max_run_flag = 'N' then
                                begin
	          		     serialno := nvl(run_action_type,'R') ||   -- Serial number updated for MAX BA only.
					             lv_sep_check ||
						     lv_multi_asg_flag ||
						     to_char(l_asg_act_id);

				    -- update pay_assignment_actions serial_number with runactid.

				     update pay_assignment_actions
				        set serial_number = serialno
				      where assignment_action_id = lockingactid
				        and tax_unit_id = greid;
				   lv_max_run_flag := 'Y' ;
				 exception when others then
				     null;
				 end;
			       end if;
                            end loop;
			 close c_multi_ba_acts;
                         lv_max_run_flag := 'N'; -- This is addded to Fix Bug # 5204333
 -- pay_us_rpt_totals is populated for all Balance Adjustments.

                          begin
                          if runactid is not NULL then
                             serialno := nvl(lv_run_action_type,'R') ||
                                         lv_sep_check ||
                                         lv_multi_asg_flag ||
                                         to_char(runactid);

                            -- update pay_assignment_actions serial_number with runactid.

                             update pay_assignment_actions
                             set serial_number = serialno
                             where assignment_action_id = lockingactid
                             and  tax_unit_id = greid;
			   end if;
                          exception when others then
                             null;
                          end;

                          -- loop through and fetch all assignment actions
                          -- that were created.

                          open c_multi_asg_rpt_acts (lockedactid); -- This is for RUN.
                              loop

                                 fetch c_multi_asg_rpt_acts into l_asg_act_id;

                                 exit when c_multi_asg_rpt_acts%NOTFOUND;
                                  -- Insert a row in pay_us_rpt_totals which includes
                                  -- payroll_action_id,
                                  -- report created assignment_action_id (lockingactid)
                                  -- and "payroll run" assignment_action id.

                                  insert into pay_us_rpt_totals
                                  (session_id,
                                   tax_unit_id,
                                   location_id,
                                   value1)
                                   values(pactid,
                                   pactid,
                                   lockingactid,
                                   l_asg_act_id);

                               end loop;

                          close c_multi_asg_rpt_acts;

                     end if;  -- l_void_action = 'N'

                   end if;  -- source action id is null

               ELSE  -- This is a void action.

                   select pay_assignment_actions_s.nextval
                   into lockingactid
                   from dual;

                   hr_utility.trace('B4 insact'||to_char(lockingactid) ||','||to_char(greid)||','||actiontype||','||to_char(runactid) );

                   -- insert the action record.
                   hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);
                   hr_utility.trace('A4 insact'||to_char(lockingactid) ||','||to_char(greid)||','||actiontype||','||to_char(runactid) );

                   -- insert an interlock to this action.
                   hr_nonrun_asact.insint(lockingactid,lockedactid);

                   begin
                      --serialno := 'V'||to_char(runactid);
                      serialno := actiontype || 'NN' || to_char(lockedactid);
                   -- update pay_assignment_actions serial_number with runactid.
                      update pay_assignment_actions
                      set serial_number = serialno
                      where assignment_action_id = lockingactid
                       and  tax_unit_id = greid;
                   exception when others then
                            null;
                   end;

                   -- Insert a row in pay_us_rpt_totals which includes
                   -- payroll_action_id,
                   -- report created assignment_action_id (lockingactid)
                   -- and "payroll run" assignment_action id.

                   insert into pay_us_rpt_totals
                   (session_id,
                    tax_unit_id,
                    location_id,
                    value1)
                    values(pactid,
                    pactid,
                    lockingactid,
                    lockedactid);

               END IF; -- IF actiontype in ('P', 'U')

           else  -- THIS IS NOT A MULTI ASSIGNMENT PAYROLL

               -- we need to insert one action for each of the
               -- rows that we return from the cursor (i.e. one
               -- for each assignment/pre-payment/reversal).
               hr_utility.set_location('procpyr',3);

               IF actiontype in ('P', 'U') THEN

                   open c_payment_info (lockedactid);
                   loop
                      fetch c_payment_info into ln_source_action_id;

                      if c_payment_info%notfound then

                       if l_action_insert = 'N' then


                           -- We need to make sure that the pre_pay assignment
                           -- action is not locking a void action as the void)
                           -- is handled else where

                          l_void_action := 'N';

                          open c_check_for_void ( lockedactid);

                          fetch c_check_for_void into l_void_action;

                          if   c_check_for_void%NOTFOUND then
                               l_void_action := 'N';
                          end if;

                          close c_check_for_void;

                             if l_void_action = 'N' then

                               -- we have a zero net pay pre-pay assignment_action
                               -- insert one row for the action creation.
                               -- insert the action record.

                               select pay_assignment_actions_s.nextval
                                 into lockingactid
                                 from dual;

                               -- insert the action record.
                               hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                               -- insert an interlock to this action.
                               hr_nonrun_asact.insint(lockingactid,lockedactid);

                               open c_payroll_run (lockedactid);
                            /* Pre-payment can lock more then one run so this should loop
                               commented out following two lines - bug 3385676
                                - insert multiple rows in pay_us_rpt_totals

                               fetch c_payroll_run into ln_master_action_id,lv_run_action_type;
                               close c_payroll_run;
                               */

                                  fetch c_payroll_run into ln_master_action_id,lv_run_action_type;
                                  close c_payroll_run;
                                  runactid :=  ln_master_action_id;
                                  lv_sep_check := 'N';

                               begin
                                 /* we no longer user the serial number so there should
                                    no be any impact  of looping */

                                  serialno := nvl(lv_run_action_type,'R') ||
                                              lv_sep_check ||
                                                 'N' || -- multi_asg_flag
                                                 to_char(runactid);

                                   -- update pay_assignment_actions serial_number with runactid.

                                   update pay_assignment_actions
                                   set serial_number = serialno
                                   where assignment_action_id = lockingactid
                                   and  tax_unit_id = greid;

                                exception when others then
                                   null;
                                end;

                                -- Insert a row in pay_us_rpt_totals which includes
                                -- payroll_action_id,
                                -- report created assignment_action_id (lockingactid)
                                -- and "payroll run" assignment_action id.

                                insert into pay_us_rpt_totals
                                (session_id,
                                 tax_unit_id,
                                 location_id,
                                 value1)
                                 values(pactid,
                                 pactid,
                                 lockingactid,
                                 runactid);

                             end if;  --l_void_action = 'N'

                             exit;

                          else  -- l_action_insert = 'N'

                              exit;

                          end if;   -- l_action_insert = 'N'

                       else --   if c_payment_info%notfound

                          /**************************************************************
                          ** we need to insert one action for each of the rows that we
                          ** return from the cursor (i.e. one for each assignment/pre-payment source).
                          **************************************************************/
                          if (ln_prev_source_action_id is null or
                              ln_source_action_id <> ln_prev_source_action_id or
                              ln_source_action_id = -999) then

                             -- insert the action record.
                             select pay_assignment_actions_s.nextval
                               into lockingactid
                               from dual;

                             l_action_insert := 'Y';
                             -- insert the action record.
                             hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                             -- insert an interlock to this action.
                             hr_nonrun_asact.insint(lockingactid,lockedactid);

                             if ln_source_action_id <> -999 then
                                runactid :=  ln_source_action_id;
                                lv_sep_check := 'Y';
				begin
                                serialno := nvl(lv_run_action_type,'R') ||
                                            lv_sep_check ||
                                            'N' || -- multi_asg_flag
                                            to_char(runactid);

                                -- update pay_assignment_actions serial_number with runactid.

                                update pay_assignment_actions
                                set serial_number = serialno
                                where assignment_action_id = lockingactid
                                and  tax_unit_id = greid;

                             exception when others then
                                      null;
                             end;

                              -- Insert a row in pay_us_rpt_totals which includes
                              -- payroll_action_id,
                              -- report created assignment_action_id (lockingactid)
                              -- and "payroll run" assignment_action id.

                              insert into pay_us_rpt_totals
                              (session_id,
                               tax_unit_id,
                               location_id,
                               value1)
                               values(pactid,
                               pactid,
                               lockingactid,
                               runactid);

                             -- skip till next source action id

                             ln_prev_source_action_id := ln_source_action_id;
-- Bug 4074976 Begin-- We will loop the cursor c_payroll_run and insert rows in pay_us_rpt_totals for max(run) action
                    -- id and all the balance id's which the prepayment locks.
                             else
			      lv_max_run_flag          := 'N' ; -- Initialise the variables.

                                open c_payroll_run (lockedactid);
				loop
                                fetch c_payroll_run into ln_master_action_id,lv_run_action_type;
				exit when c_payroll_run%notfound;

				if (lv_max_run_flag = 'N' and lv_run_action_type in ('R','Q')) OR
				   (lv_run_action_type = 'B') then -- Max run and all balance adjustments
                                   runactid :=  ln_master_action_id;
                                   lv_sep_check := 'N';

				   if lv_run_action_type in ('R','Q') then -- makes sure that run is inserted just once.
				      lv_max_run_flag := 'Y';
				   end if;

                                   begin
			              serialno := nvl(lv_run_action_type,'R') ||
                                                  lv_sep_check ||
                                                  'N' || -- multi_asg_flag
                                                  to_char(runactid);

                                   -- update pay_assignment_actions serial_number with runactid.

                                      update pay_assignment_actions
                                      set serial_number = serialno
                                      where assignment_action_id = lockingactid
                                      and  tax_unit_id = greid;

                                   exception when others then
                                      null;
                                   end;

                                   -- Insert a row in pay_us_rpt_totals which includes
                                   -- payroll_action_id,
                                   -- report created assignment_action_id (lockingactid)
                                   -- and "payroll run" assignment_action id.

                                   insert into pay_us_rpt_totals
                                   (session_id,
                                    tax_unit_id,
                                    location_id,
                                    value1)
                                   values(pactid,
                                    pactid,
                                    lockingactid,
                                    runactid);

                                 -- skip till next source action id
                                 ln_prev_source_action_id := ln_source_action_id;
			     end if; -- (lv_max_run_flag = 'N' and lv_run_action_type = 'R') OR (lv_run_action_type = 'B')
			     end loop;
			     close c_payroll_run;
-- Bug 4074976 -- End
			    end if; -- ln_source_action_id <> -9999
                          end if; -- (ln_prev_source_action_id is null or ...

                      end if;  -- if c_payment_info%notfound

                   end loop;

                 close c_payment_info;

               ELSE  -- This is a void action.

                   select pay_assignment_actions_s.nextval
                   into lockingactid
                   from dual;

                   hr_utility.trace('B4 insact'||to_char(lockingactid) ||','||to_char(greid)||','||actiontype||','||to_char(runactid) );

                   -- insert the action record.
                   hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);
                   hr_utility.trace('A4 insact'||to_char(lockingactid) ||','||to_char(greid)||','||actiontype||','||to_char(runactid) );

                   -- insert an interlock to this action.
                   hr_nonrun_asact.insint(lockingactid,lockedactid);

                   begin
                      --serialno := 'V'||to_char(runactid);
                      serialno := actiontype || 'NN' || to_char(lockedactid);
                   -- update pay_assignment_actions serial_number with runactid.
                      update pay_assignment_actions
                      set serial_number = serialno
                      where assignment_action_id = lockingactid
                       and  tax_unit_id = greid;
                   exception when others then
                            null;
                   end;

                   -- Insert a row in pay_us_rpt_totals which includes
                   -- payroll_action_id,
                   -- report created assignment_action_id (lockingactid)
                   -- and "payroll run" assignment_action id.

                   insert into pay_us_rpt_totals
                   (session_id,
                    tax_unit_id,
                    location_id,
                    value1)
                    values(pactid,
                    pactid,
                    lockingactid,
                    lockedactid);


                END IF;  -- if action_type in ('P', 'U');

           end if; -- l_multi_asg_flag = 'Y'

         end if;   -- if l_asg_flag = 'Y'

    end loop;

    if l_assignment_set_id is NULL then
 --   hr_utility.trace('Closing c_actions');
    close c_actions;
    else
 --   hr_utility.trace('Closing c_actions_1');
    close c_actions_1;
    end if;

 END action_creation;

 ---------------------------------- sort_action ----------------------------------
PROCEDURE sort_action(
               payactid   in     varchar2, /* payroll action id */
               sqlstr     in out nocopy varchar2, /* string holding the sql statement */
               len        out    nocopy number    /* length of the sql string */
               ) is

    l_sort_1   varchar2(30);
    l_sort_2   varchar2(30);
    l_sort_3   varchar2(30);


  BEGIN

   select pay_payrg_pkg.get_parameter('P_S1', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('P_S2', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('P_S3', ppa.legislative_parameters)
     into l_sort_1,
          l_sort_2,
          l_sort_3
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = payactid;


      sqlstr :=
        'select paa.rowid
           from pay_assignment_actions paa,
                pay_payroll_actions ppa
          where ppa.payroll_action_id = :payactid
            and paa.payroll_action_id = ppa.payroll_action_id
           order by
             (decode('''||l_sort_1||''',
                     null, null,
                     pay_payrg_pkg.sort_option  (
                        '''||l_sort_1||''',
                        paa.assignment_id,
                        ppa.effective_date,
                        paa.tax_unit_id))),
             (decode('''||l_sort_2||''',
                     null, null,
                     pay_payrg_pkg.sort_option  (
                        '''||l_sort_2||''',
                        paa.assignment_id,
                        ppa.effective_date,
                        paa.tax_unit_id))),
             (decode('''||l_sort_3||''',
                     null, null,
                     pay_payrg_pkg.sort_option  (
                        '''||l_sort_3||''',
                        paa.assignment_id,
                        ppa.effective_date,
                        paa.tax_unit_id))),
             (select hou.name
               from hr_all_organization_units  hou, /* Assignment Org */
                    per_assignments_f      paf
              where paf.assignment_id = paa.assignment_id
                and ppa.effective_date between
                         paf.effective_start_date and paf.effective_end_date
                and hou.organization_id = paf.organization_id
                and rownum = 1),
             (select distinct ppf.full_name
                   from per_all_people_f ppf,
                        per_all_assignments_f paf
                  where paf.assignment_id = paa.assignment_id
                    and ppf.person_id = paf.person_id
                and ppa.effective_date between
                         paf.effective_start_date and paf.effective_end_date
                and ppa.effective_date between
                         ppf.effective_start_date and ppf.effective_end_date
                                    ),
                (select ppa2.effective_date
                   from pay_payroll_actions ppa2,
                        pay_assignment_actions paa2
                  where paa2.assignment_action_id = to_number(substr(paa.serial_number,4))
                    and paa2.payroll_action_id = ppa2.payroll_action_id
                    and ppa2.action_type in (''R'', ''Q'', ''V'', ''B'')
                )
        for update of paa.assignment_id';

      len := length(sqlstr); -- return the length of the string.

 END sort_action;



 ----------------------------- get_parameter -------------------------------
 FUNCTION get_parameter(name in varchar2,
                        parameter_list varchar2)
 RETURN VARCHAR2
 IS
   start_ptr number;
   end_ptr   number;
   token_val pay_payroll_actions.legislative_parameters%type;
   par_value pay_payroll_actions.legislative_parameters%type;
 BEGIN

     token_val := name || '=';

     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);

     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list) + 1;
     end if;

     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;

     return par_value;

 END get_parameter;

 FUNCTION sort_option  (c_option_name    in varchar2,
                        c_assignment_id  in number,
                        c_effective_date in date,
                        c_tax_unit_id    in number)
 RETURN VARCHAR2
 IS

   return_val   varchar2(240);

 BEGIN

       if c_option_name = 'GRE' Then

         select hou1.name
           into return_val
           from hr_all_organization_units  hou1   /* Tax Unit */
          where hou1.organization_id = c_tax_unit_id
            and rownum = 1;

       else

           select decode(c_option_name,
                        'Organization',hou.name,
                        'Location',loc.location_code,
                        null)
           into return_val
           from hr_all_organization_units  hou, /* Assignment Org */
                hr_locations_all       loc,
                per_assignments_f      paf
          where paf.assignment_id = c_assignment_id
            and c_effective_date between
                     paf.effective_start_date and paf.effective_end_date
            and hou.organization_id = paf.organization_id
            and loc.location_id  = paf.location_id
            and rownum = 1;

      end if;

      return return_val;

   EXCEPTION
     when others then
        return '1';

 END sort_option;


end pay_payrg_pkg;

/
