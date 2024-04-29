--------------------------------------------------------
--  DDL for Package Body PAY_CA_PAYRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_PAYRG_PKG" as
/* $Header: pycapreg.pkb 120.4.12010000.4 2009/11/05 06:29:18 sneelapa ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package defines the cursors needed to run Payroll Register Multi-Threaded
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   05-NOV-2009  sneelapa    115.25 Modified sort_action query.  Added outer join
                                   organization_id, location_id columns.
                                   This cursor was not fetching all the
                                   ASSIGNMENT_ACTION_IDs created by
                                   ACTION_CREATION procedure.
   07-OCT-2007  amigarg     115.20 changed the cursor c_actions to add the ro
                                   ws for which tax_unit_id is not stamped
   22-JUN-2005  ssouresr    115.19 Changed the cursor c_actions to not select
                                   assignment actions with blank tax_unit_ids
                                   also changed c_actions to break dependency
                                   between payroll and consolidation set
   01-SEP-2004 mmukherj     115.18 Added action_status check when joining
                                   to pay_payment_information_v. This is done
                                   due to changes to view for bug 3826732.
   13-APR-2004  ssouresr    115.17 Corrected version 115.15 by changing the
                                   cursors.
   13-APR-2004  ssouresr    115.15 The function action_creation is changed
                                   so that assignment actions are not created
                                   twice for any reversals locked by any
                                   prepayments.
   25-MAR-2004  ssattini    115.14 Changed c_actions cursor to fix
                                   11510 bug#3534182, to validate the
                                   parameter values correctly.
   12-JAN-2004  ssattini    115.13 Changed c_actions cursor to fix
                                   11510 performance fix bug#3356268.
   23-MAY-2003  vpandya     115.10 Changed for Multi GRE functionality:
                                   action_creation is changed. Please do diff
                                   with previous version to see changes.
   06-MAR-2003  ssattini    115.7  Changed Sort Action query to consider
                                   the terminated employees. Fix#2780747.
   20-NOV-2002  ssouresr    115.6  Changed Organization and Location to caps,
                                   because the these two parameters  will not
                                   be in lower case anymore.
   29-OCT-2002  tclewis     115.4  Modified the action_creation procedure
                                   specifically modifing c_payroll_run cursor
                                   to return the max master assignment action id.
   18-OCT-2002  tclewis     115.3  Modified the action_creation cursor removing
                                   the for update of . . . added a for update
                                   on the lock the created assignment_action_id.
   28-AUG-2002  tclewis    115.2   Modified the action creation cursor
                                   for the umbrella process and for
                                   multiple assignment processing.
   30-MAR-2001  jgoswami    115.1  Changed package name from
                                   pay_payrg_pkg to pay_ca_payrg_pkg
                                   as it was conflicting with pypayreg.pkb
   29-OCT-1999  jgoswami    110.0  Created based on pypayreg.pkb 110.1 99/08/04 rthakur
   Original file pypayreg.pkb info
   09-MAR-1999  meshah      40.0   created
   04-AUG-1999  rmonge     110.1   Made package body adchkdrv compliant.

--
*/
----------------------------------- range_cursor ----------------------------------
--
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
  l_payroll_id number;
  leg_param    pay_payroll_actions.legislative_parameters%type;
--
begin
   select legislative_parameters
     into leg_param
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;


/* pay reg code */

   sqlstr := 'select distinct asg.person_id
                from    pay_assignment_actions act,
                        per_assignments_f      asg,
			pay_payroll_actions    ppa2, /* run and quickpay payroll actions */
			pay_assignment_actions act2, /* run and quickpay assignment actions */
			pay_action_interlocks  pai,  /* interlocks table */
                        pay_payroll_actions    ppa,  /* PYUGEN information */
			pay_payroll_actions    pa1   /* Payroll Register information */
                 where  ppa.payroll_action_id    = :payroll_action_id
                 and    pa1.consolidation_set_id =
                          nvl(pay_payrg_pkg.get_parameter(''C_ST_ID'',ppa.legislative_parameters),pa1.consolidation_set_id)
                 and    pa1.payroll_id           =
                          nvl(pay_payrg_pkg.get_parameter(''PY_ID'',ppa.legislative_parameters),pa1.payroll_id)
  		 and    pa1.effective_date between          /* date join btwn payreg and pyugen ppa */
	                ppa.start_date and ppa.effective_date
                 and    pa1.payroll_action_id = act.payroll_action_id
                 and    asg.assignment_id        = act.assignment_id
                 and    pa1.effective_date between          /* date join btwn payreg and asg */
                        asg.effective_start_date and asg.effective_end_date
 		 and    pa1.action_type in (''P'',''U'',''V'')
  		 and    act.action_status = ''C''
		 and    act.assignment_action_id = pai.locking_action_id
      		 and    act2.assignment_action_id = pai.locked_action_id
                 and    act2.payroll_action_id = ppa2.payroll_action_id
                 and    ppa2.action_type in (''R'',''Q'')
                 and    act2.action_status = ''C''
 		 and    act2.tax_unit_id =
			 nvl(pay_payrg_pkg.get_parameter(''T_U_ID'',ppa.legislative_parameters), act2.tax_unit_id)
                 and    asg.organization_id =
			 nvl(pay_payrg_pkg.get_parameter(''O_ID'',ppa.legislative_parameters), asg.organization_id)
  		 and    asg.location_id =
			 nvl(pay_payrg_pkg.get_parameter(''L_ID'',ppa.legislative_parameters), asg.location_id)
		 and    asg.person_id =
			 nvl(pay_payrg_pkg.get_parameter(''P_ID'',ppa.legislative_parameters), asg.person_id)
		and     asg.business_group_id +0 =
			 pay_payrg_pkg.get_parameter(''B_G_ID'',ppa.legislative_parameters)
		 order by asg.person_id';


end range_cursor;
---------------------------------- action_creation ----------------------------------
--
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

      cursor c_actions(pactid    number,
                       stperson  number,
                       endperson number,
                       cp_cons_set_id number,
                       cp_payroll_id  number,
                       cp_bg_id       number,
                       cp_tax_unit_id number,
                       cp_org_id      number,
                       cp_loc_id      number,
                       cp_person_id   number) is
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             ppa.action_type,
             ppa.effective_date,
             act.source_action_id
      from   pay_assignment_actions act,
             per_assignments_f      paf,
             pay_payroll_actions    ppa,  /* pre-payments and reversals
                                             payroll action id */
             pay_payroll_actions    ppa1, /* PYUGEN payroll action id */
             pay_all_payrolls_f     ppf
      where ppa1.payroll_action_id = pactid
        and ((ppf.payroll_id = cp_payroll_id) OR
                 (cp_payroll_id is null))
        and paf.business_group_id = cp_bg_id
        and paf.payroll_id = ppf.payroll_id
        and paf.person_id between stperson and endperson
        and ((paf.organization_id = cp_org_id) OR
              (cp_org_id is null))
        and ((paf.location_id = cp_loc_id) OR
              (cp_loc_id is null ))
        and ((paf.person_id = cp_person_id) OR
              (cp_person_id is null))
        and ppa.payroll_id = ppf.payroll_id
        and ppa.consolidation_set_id  = cp_cons_set_id
        and ppa.effective_date between
            ppa1.start_date and ppa1.effective_date
        and ppa.effective_date between paf.effective_start_date
                                   and paf.effective_end_date
        and ppa.business_group_id = ppa1.business_group_id
        and ppa.effective_date between ppf.effective_start_date
                                   and ppf.effective_end_date
        and act.payroll_action_id = ppa.payroll_action_id
        and paf.assignment_id = act.assignment_id
        and act.action_status = 'C'
        and act.source_action_id is null
        --and ((act.tax_unit_id = cp_tax_unit_id) OR
        --    (cp_tax_unit_id is null) OR
        --    (act.tax_unit_id is null))
        and (   ((act.tax_unit_id = cp_tax_unit_id) and (cp_tax_unit_id is not null))
             or ((act.tax_unit_id is not null) and (cp_tax_unit_id is null))
                 --changes started for bug 5152897
	     	or (act.tax_unit_id is null)
             -- changes ended for bug 5152897
            )
        and ( ( ppa.action_type in ('P','U') and
               ( exists ( select 1
                     from pay_action_interlocks pai1
                         ,pay_assignment_actions paa1
                         ,pay_payroll_actions ppa2
                     where pai1.locking_action_id  = act.assignment_action_id
                     and paa1.assignment_action_id = pai1.locked_action_id
                     and ppa2.payroll_action_id    = paa1.payroll_action_id
                     and ppa2.action_type <> 'V' ))) OR
              ( ppa.action_type = 'V' ) )
        order by act.assignment_id;

   cursor c_arch_lvl(cp_busi_grp_id number) is
     select org_information1
     from   hr_organization_information
     where  organization_id = cp_busi_grp_id
     and    org_information_context = 'Payroll Archiver Level';

   cursor c_payment_info(cp_prepay_action_id number) is
     select assignment_id,
            tax_unit_id,
            nvl(source_action_id,-999)
     from  pay_payment_information_v
     where assignment_action_id = cp_prepay_action_id
     and   action_status = 'C'
     order by 3,1,2;

   cursor c_sepchk_run_type is
     select run_type_id
     from   pay_run_types_f
     where  legislation_code = 'CA'
     and    run_method = 'S'
     and    shortname  = 'SEP_PAY';

   cursor c_get_map_flag(cp_prepay_action_id number) is
     select ppf.multi_assignments_flag
     from pay_assignment_actions paa,
          pay_payroll_actions ppa,
          pay_all_payrolls_f ppf
     where assignment_action_id = cp_prepay_action_id
     and ppa.payroll_action_id = paa.payroll_action_id
     and ppf.payroll_id = ppa.payroll_id
     and ppa.effective_date between ppf.effective_start_date
                                and ppf.effective_end_date;

   cursor c_child_pp_aaid(cp_prepay_action_id number
                         ,cp_assignment_id    number
                         ,cp_tax_unit_id      number) is
     select paa.assignment_action_id
     from   pay_assignment_actions paa
     where  paa.source_action_id = cp_prepay_action_id
     and    paa.assignment_id    = cp_assignment_id
     and    paa.tax_unit_id      = cp_tax_unit_id;

   cursor c_pp_aaid_for_sepchk(cp_source_action_id number) is
     select paa.assignment_action_id
     from   pay_action_interlocks pai
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
     where pai.locked_action_id = cp_source_action_id
     and   paa.assignment_action_id = pai.locking_action_id
     and   paa.source_action_id is not null
     and   ppa.payroll_action_id = paa.payroll_action_id
     and   ppa.action_type in ( 'P', 'U' );

   cursor c_max_run_aaid(cp_prepay_action_id number,
                         cp_assignment_id    number,
                         cp_tax_unit_id      number,
                         cp_sepchk_run_tp_id number) is
     select max(paa.assignment_action_id)
     from pay_assignment_actions paa,
          pay_action_interlocks pai,
          pay_run_types_f prt,
          pay_payroll_actions ppa
     where pai.locking_action_id = cp_prepay_action_id
     and   paa.assignment_action_id = pai.locked_action_id
     and   paa.assignment_id = cp_assignment_id
     and   paa.tax_unit_id = cp_tax_unit_id
     and   paa.run_type_id <> cp_sepchk_run_tp_id
     and   prt.legislation_code = 'CA'
     and   prt.run_type_id = paa.run_type_id
     and   paa.payroll_action_id = ppa.payroll_action_id
     and   ppa.action_type <> 'V'
     and   prt.run_method <> 'C';

   cursor c_taxgrp_max_run_aaid(cp_prepay_action_id number,
                                cp_assignment_id    number,
                                cp_sepchk_run_tp_id number) is
     select max(paa.assignment_action_id)
     from pay_assignment_actions paa,
          pay_action_interlocks pai,
          pay_run_types_f prt,
          pay_payroll_actions ppa
     where pai.locking_action_id = cp_prepay_action_id
     and   paa.assignment_action_id = pai.locked_action_id
     and   paa.assignment_id = cp_assignment_id
     and   paa.run_type_id <> cp_sepchk_run_tp_id
     and   prt.legislation_code = 'CA'
     and   prt.run_type_id = paa.run_type_id
     and   paa.payroll_action_id = ppa.payroll_action_id
     and   ppa.action_type <> 'V'
     and   prt.run_method <> 'C';

   /****************************************************************
   ** Getting all other elements of different assignments which are
   ** needed to be printed for
   ** separate payment when Multi Assignment is enabled.
   ****************************************************************/

   cursor c_sepchk_act_seq(cp_assignment_action_id number) is
     select paa.action_sequence
     from   pay_assignment_actions paa
     where  paa.assignment_action_id = cp_assignment_action_id;

   cursor c_other_asg_for_sepchk(cp_prepay_asg_act_id number
                                ,cp_assignment_id     number) is
     select distinct ppi.assignment_id
     from   pay_payment_information_v ppi
     where  ppi.assignment_action_id = cp_prepay_asg_act_id
     and    ppi.assignment_id       <> cp_assignment_id
     and    ppi.action_status = 'C'
     and    ppi.source_action_id is null;

   cursor c_multi_asg_max_aaid(cp_prepay_asg_act_id number
                              ,cp_assignment_id     number
                              ,cp_action_sequence   number) is
     select paa_run.action_sequence, paa_run.assignment_action_id
     from pay_action_interlocks pai,
          pay_assignment_actions paa_run,
          pay_payroll_actions ppa_run,
          pay_run_types_f prt
     where pai.locking_action_id = cp_prepay_asg_act_id
     and   paa_run.assignment_action_id = pai.locked_action_id
     and   paa_run.assignment_id = cp_assignment_id
     and   ppa_run.payroll_action_id = paa_run.payroll_action_id
     and   ppa_run.action_type in ( 'R', 'Q' )
     and   prt.legislation_code = 'CA'
     and   prt.run_type_id = paa_run.run_type_id
     and   prt.run_method  <> 'C'
     and   ( ( prt.shortname <> 'SEP_PAY' ) OR
             ( prt.shortname = 'SEP_PAY' and
               paa_run.action_sequence <= cp_action_sequence )
           )
     order by paa_run.action_sequence desc;

   lockingactid  number;
   lockedactid   number;
   assignid      number;
   greid         number;
   num           number;
   runactid      number;
   actiontype    VARCHAR2(1);
   serialno      VARCHAR2(30);

   l_leg_param   VARCHAR2(300);
   l_asg_set_id  number;
   l_asg_flag    VARCHAR2(10);
   l_effective_date date;
   l_multi_asg_flag VARCHAR(1);
   l_source_action_id NUMBER;

   ln_pre_pymt_action_id      NUMBER;

   ln_master_action_id        NUMBER;
   lv_run_action_type         VARCHAR2(1);
   lv_sep_check               VARCHAR2(1);
   lv_multi_asg_flag          VARCHAR2(1);
   ln_source_action_id        NUMBER;

   l_asg_act_id               number;
   l_action_insert            varchar2(1);
   l_void_action              varchar2(1);

   ln_busi_grp_id             number;
   lv_pyrl_arch_lvl           varchar2(240);
   ln_pp_tax_unit_id          number;
   ln_pp_aaid                 number;

   ln_assignment_id           number;
   ln_tax_unit_id             number;
   ln_sepchk_run_tp_id        number;
   ln_max_run_aa_id           number;

   prev_assignment_id         NUMBER;
   prev_tax_unit_id           NUMBER;
   prev_source_action_id      NUMBER;

   ln_sepchk_act_seq          NUMBER;
   ln_action_sequence         NUMBER;
   ln_map_max_aaid            NUMBER;

   ln_leg_payroll_id          number(30);
   ln_leg_cons_set_id         number(30);
   ln_leg_tax_unit_id         number(30);
   ln_leg_org_id              number(30);
   ln_leg_loc_id              number(30);
   ln_leg_person_id           number(30);
   ln_leg_bg_id               number(30);

    -- algorithm is quite similar to the other process cases,
    -- but we have to take into account assignments and
    -- personal payment methods.
 BEGIN
    --hr_utility.trace_on(null,'PAYREG');
    hr_utility.set_location('procpyr',1);

    prev_assignment_id    := 0;
    prev_tax_unit_id      := 0;
    prev_source_action_id := 0;

    select legislative_parameters, business_group_id,
      to_number(pay_payrg_pkg.get_parameter('PY_ID', ppa.legislative_parameters)),
      to_number(pay_payrg_pkg.get_parameter('C_ST_ID', ppa.legislative_parameters)),
      to_number(pay_payrg_pkg.get_parameter('T_U_ID', ppa.legislative_parameters)),
      to_number(pay_payrg_pkg.get_parameter('O_ID', ppa.legislative_parameters)),
      to_number(pay_payrg_pkg.get_parameter('L_ID', ppa.legislative_parameters)),
      to_number(pay_payrg_pkg.get_parameter('P_ID', ppa.legislative_parameters)),
      to_number(pay_payrg_pkg.get_parameter('B_G_ID', ppa.legislative_parameters))
    into l_leg_param, ln_busi_grp_id,
         ln_leg_payroll_id,
         ln_leg_cons_set_id,
         ln_leg_tax_unit_id,
         ln_leg_org_id,
         ln_leg_loc_id,
         ln_leg_person_id,
         ln_leg_bg_id
    from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

    open  c_arch_lvl(ln_busi_grp_id);
    fetch c_arch_lvl into lv_pyrl_arch_lvl;
    if c_arch_lvl%notfound then
       lv_pyrl_arch_lvl := 'GRE';
    end if;
    close c_arch_lvl;

    hr_utility.trace('lv_pyrl_arch_lvl = '||lv_pyrl_arch_lvl);

    open  c_sepchk_run_type;
    fetch c_sepchk_run_type into ln_sepchk_run_tp_id;
    close c_sepchk_run_type;

    hr_utility.trace('ln_sepchk_run_tp_id = '||ln_sepchk_run_tp_id);

    open c_actions(pactid,stperson,endperson,
                   ln_leg_cons_set_id,
                   ln_leg_payroll_id,
                   ln_leg_bg_id,
                   ln_leg_tax_unit_id,
                   ln_leg_org_id,
                   ln_leg_loc_id,
                   ln_leg_person_id);

    l_asg_set_id := pay_payrg_pkg.get_parameter('PASID',l_leg_param);

    num := 0;
    loop
       hr_utility.set_location('procpyr',2);

       fetch c_actions into  lockedactid
                            ,assignid
                            ,greid
                            ,actiontype
                            ,l_effective_date
                            ,l_source_action_id;
       if c_actions%found then num := num + 1; end if;
       exit when c_actions%notfound;

       l_asg_flag := 'N';
       l_action_insert := 'N';

       if l_asg_set_id is not null then
          l_asg_flag := hr_assignment_set.assignment_in_set(l_asg_set_id,
                                                            assignid);
       else  -- l_asg_set_id is null
          l_asg_flag := 'Y';
       end if;

       ln_pp_aaid := lockedactid;

       prev_assignment_id    := 0;
       prev_tax_unit_id      := 0;
       prev_source_action_id := 0;

       open  c_get_map_flag(lockedactid);
       fetch c_get_map_flag into lv_multi_asg_flag;
       close c_get_map_flag;

       hr_utility.trace('lv_multi_asg_flag = '||lv_multi_asg_flag);

     --if l_asg_flag = 'Y' then removed as no parameter for assignment set

       if actiontype in ( 'P', 'U' ) then

          open  c_payment_info(lockedactid);
          loop
             fetch c_payment_info into ln_assignment_id
                                      ,ln_tax_unit_id
                                      ,ln_source_action_id;
             exit when c_payment_info%notfound;

             if ln_source_action_id <> -999 then  -- Separate Cheque

                lv_sep_check := 'Y';

                open  c_pp_aaid_for_sepchk(ln_source_action_id);
                fetch c_pp_aaid_for_sepchk into ln_pp_aaid;
                if c_pp_aaid_for_sepchk%notfound then
                   ln_pp_aaid := lockedactid;
                end if;
                close c_pp_aaid_for_sepchk;

                ln_max_run_aa_id := ln_source_action_id;

             else -- Normal Cheques

                lv_sep_check := 'N';

                if lv_pyrl_arch_lvl = 'TAXGRP' then

                   prev_tax_unit_id      := ln_tax_unit_id;

                   if prev_assignment_id <> ln_assignment_id then

                      -- Get Max Asg Act Id for each assignment of Run

                      open c_taxgrp_max_run_aaid(lockedactid,
                                                 ln_assignment_id,
                                                 ln_sepchk_run_tp_id);
                      fetch c_taxgrp_max_run_aaid into ln_max_run_aa_id;
                      close c_taxgrp_max_run_aaid;

                      if prev_assignment_id <> 0 then

                         insert into pay_us_rpt_totals
                               (session_id,
                                tax_unit_id,
                                location_id,
                                value1,
                                value2)
                         values(pactid,
                                pactid,
                                lockingactid,
                                ln_max_run_aa_id,
                                ln_assignment_id);

                      end if;

                   end if;

                else

                   if lv_multi_asg_flag = 'N' then
                      open  c_child_pp_aaid(lockedactid,
                                            ln_assignment_id,
                                            ln_tax_unit_id);
                      fetch c_child_pp_aaid into ln_pp_aaid;
                      if c_child_pp_aaid%notfound then
                         ln_pp_aaid := lockedactid;
                      end if;
                      close c_child_pp_aaid;
                   end if;

                   -- Get Max Asg Act Id for each assignment and Tax Unit of Run

                   open c_max_run_aaid(lockedactid,
                                       ln_assignment_id,
                                       ln_tax_unit_id,
                                       ln_sepchk_run_tp_id);
                   fetch c_max_run_aaid into ln_max_run_aa_id;
                   close c_max_run_aaid;

                end if;

             end if;

            hr_utility.trace('lockedactid = '||lockedactid);
            hr_utility.trace('ln_assignment_id = '||ln_assignment_id);
            hr_utility.trace('ln_pp_aaid = '||ln_pp_aaid);
            hr_utility.trace('lv_run_action_type = '||lv_run_action_type);
            hr_utility.trace('lv_sep_check = '||lv_sep_check);

            hr_utility.trace('----------------------------------');
            hr_utility.trace('prev_tax_unit_id = '||prev_tax_unit_id);
            hr_utility.trace('ln_tax_unit_id = '||ln_tax_unit_id);
            hr_utility.trace('prev_source_action_id = '||prev_source_action_id);
            hr_utility.trace('ln_source_action_id = '||ln_source_action_id);
            hr_utility.trace('----------------------------------');

             if ( ( ln_source_action_id <> prev_source_action_id ) or
                  ( ln_tax_unit_id <> prev_tax_unit_id ) ) then

                select pay_assignment_actions_s.nextval
                  into lockingactid
                  from dual;

                  -- insert the action record.
                  hr_nonrun_asact.insact(lockingactid,
                                         ln_assignment_id,
                                         pactid,
                                         chunk,
                                         ln_tax_unit_id);

                -- insert an interlock to this action.
                hr_nonrun_asact.insint(lockingactid,ln_pp_aaid);

                begin

                  serialno := nvl(lv_run_action_type,'R') ||
                              lv_sep_check ||
                              nvl(lv_multi_asg_flag,'N') ||
                              to_char(ln_max_run_aa_id);

                  -- update pay_assignment_actions serial_number with
                  -- runactid.

                  update pay_assignment_actions
                  set serial_number = serialno
                  where assignment_action_id = lockingactid
                  and  tax_unit_id = ln_tax_unit_id;

                  exception when others then
                  null;
                end;

                insert into pay_us_rpt_totals
                      (session_id,
                       tax_unit_id,
                       location_id,
                       value1,
                       value2)
                values(pactid,
                       pactid,
                       lockingactid,
                       ln_max_run_aa_id,
                       ln_assignment_id);

                hr_utility.trace('if lockingactid = '||lockingactid);
                hr_utility.trace('if ln_max_run_aa_id= '||ln_max_run_aa_id);

                /*************************************************************
                ** Getting all other elements of different assignments which
                ** are needed to be printed for
                ** separate payment when Multi Assignment is enabled.
                *************************************************************/

                if nvl(lv_multi_asg_flag,'N') = 'Y' then

                   if ln_source_action_id <> -999 then
                      open  c_sepchk_act_seq(ln_max_run_aa_id);
                      fetch c_sepchk_act_seq into ln_sepchk_act_seq;
                      close c_sepchk_act_seq;

                hr_utility.trace('ln_sepchk_act_seq= '||ln_sepchk_act_seq);
                      for c_asg in  c_other_asg_for_sepchk(lockedactid
                                                          ,ln_assignment_id)
                      loop
                hr_utility.trace('c_asg.assignment_id= '||c_asg.assignment_id);
                         open  c_multi_asg_max_aaid(lockedactid
                                                   ,c_asg.assignment_id
                                                   ,ln_sepchk_act_seq);
                         fetch c_multi_asg_max_aaid into ln_action_sequence
                                                        ,ln_map_max_aaid;
                         close c_multi_asg_max_aaid;

                hr_utility.trace('ln_action_sequence= '||ln_action_sequence);
                hr_utility.trace('ln_map_max_aaid= '||ln_map_max_aaid);

                         insert into pay_us_rpt_totals
                               (session_id,
                                tax_unit_id,
                                location_id,
                                value1,
                                value2)
                         values(pactid,
                                pactid,
                                lockingactid,
                                ln_map_max_aaid,
                                c_asg.assignment_id);
                      end loop;

                   end if; -- ln_source_action_id

                end if; -- lv_multi_asg_flag

             else

                if lv_pyrl_arch_lvl = 'GRE' then

                   -- Insert a row in pay_us_rpt_totals which includes
                   -- payroll_action_id,
                   -- report created assignment_action_id (lockingactid)
                   -- and "payroll run" assignment_action id.

                   insert into pay_us_rpt_totals
                         (session_id,
                          tax_unit_id,
                          location_id,
                          value1,
                          value2)
                   values(pactid,
                          pactid,
                          lockingactid,
                          ln_max_run_aa_id,
                          ln_assignment_id);

                  hr_utility.trace('else lockingactid = '||lockingactid);
                  hr_utility.trace('else ln_max_run_aa_id= '||ln_max_run_aa_id);

                else
                   null;
                end if;

             end if;

             prev_source_action_id := ln_source_action_id;
             prev_tax_unit_id      := ln_tax_unit_id;
             prev_assignment_id    := ln_assignment_id;

          end loop;  -- c_payment_info
          close c_payment_info;
       else

          select pay_assignment_actions_s.nextval
          into   lockingactid
          from   dual;

          hr_utility.trace('B4 insact'||to_char(lockingactid) ||','||
                     to_char(greid)||','||actiontype||','||to_char(runactid) );

          -- insert the action record.
          hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);
          hr_utility.trace('A4 insact'||to_char(lockingactid) ||','||
                     to_char(greid)||','||actiontype||','||to_char(runactid) );

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

       end if;   -- if action_type in ('P', 'U')

      --end if;   -- if l_asg_flag = 'Y'

    end loop;
    close c_actions;

end action_creation;
   ---------------------------------- sort_action --------------------------
procedure sort_action
(
   payactid   in     varchar2,     /* payroll action id */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out nocopy    number        /* length of the sql string */
) is
   begin
      sqlstr :=  'select paa1.rowid   /* we need the row id of the assignment actions that are created by PYUGEN */
                   from hr_all_organization_units  hou,
			hr_all_organization_units  hou1,
                        hr_locations_all  	   loc,
			per_all_people_f           ppf,
                        per_all_assignments_f      paf,
                        pay_assignment_actions     paa1, /* PYUGEN assignment action */
                        pay_payroll_actions        ppa1  /* PYUGEN payroll action id */
		   where ppa1.payroll_action_id = :pactid
		   and   paa1.payroll_action_id = ppa1.payroll_action_id
		   and   paa1.assignment_id = paf.assignment_id
                   and   paf.effective_start_date =
                          ( select max(paf1.effective_start_date)
                            from per_all_assignments_f paf1
                            where paf1.assignment_id = paf.assignment_id
                            and paf1.effective_start_date <= ppa1.effective_date
                            and paf1.effective_end_date >= ppa1.start_date
                           )
  		   and    hou1.organization_id (+) = paa1.tax_unit_id
 		   and    hou.organization_id = paf.organization_id
		   and    loc.location_id (+) = paf.location_id
		   and    ppf.person_id = paf.person_id
		   and    ppa1.effective_date between
		          ppf.effective_start_date and ppf.effective_end_date
                   order by
 			   decode(pay_payrg_pkg.get_parameter(''P_S1'',ppa1.legislative_parameters),
					''GRE'',hou1.name,
					''ORGANIZATION'',hou.name,
					''LOCATION'',loc.location_code,null),
	                   decode(pay_payrg_pkg.get_parameter(''P_S2'',ppa1.legislative_parameters),
                                        ''GRE'',hou1.name,
                                        ''ORGANIZATION'',hou.name,
                                        ''LOCATION'',loc.location_code,null),
                           decode(pay_payrg_pkg.get_parameter(''P_S3'',ppa1.legislative_parameters),
                                        ''GRE'',hou1.name,
                                        ''ORGANIZATION'',hou.name,
                                        ''LOCATION'',loc.location_code,null),
                           hou.name,ppf.full_name
		   for update of paa1.assignment_action_id';

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

FUNCTION hours_bal_name (p_hours_balance  IN NUMBER)
RETURN VARCHAR2 IS

V_BALANCE_NAME     VARCHAR2(80);
BEGIN

     V_BALANCE_NAME := NULL;

     SELECT balance_name
     INTO v_balance_name
     FROM pay_balance_types
     WHERE balance_type_id = p_hours_balance;

     RETURN v_balance_name;

END hours_bal_name;

end pay_ca_payrg_pkg;

/
