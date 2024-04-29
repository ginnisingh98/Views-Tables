--------------------------------------------------------
--  DDL for Package Body PAY_US_TAXBAL_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAXBAL_VIEW_PKG" as
/* $Header: pyustxbv.pkb 120.5.12010000.8 2009/05/14 10:39:30 sudedas ship $ */
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

   Name        : pyustxbv.pkb

   Description : API to get US tax balance figures.

   Change History

  Name      Date        Ver.   Description
  --------- ----------- ------ ------------------------------------------------
  B Homan   12-JAN-1998        Created based on ARASHID code
  tbattoo   11-MAY-1998        changed so GRE PYDATE routes work over a range
  mmukherj  26-MAY-1998        changed us_tax_balance_function to use
                               REPORT_TYPE session variable
  lwthomps  19-JUN-1998 40.5   Created 'Current' time type for check writer
                               when a payment is made of multiple runs.
  lwthomps  30-JUN-1998 40.6   cleaned up current in named balance
  lwthomps  30-JUN-1998 40.7   Business group id not set in named_balance
  meshah    23-DEC-1998        checking session variable QTD or YTD
  tbattoo   06-JAN-1999 40.9   Fxed bug 788693, changed so YTD cursor in
                               run_asg_vdate_cursor, references YTD instead
			       of QTD
  meshah    10-FEB-1999 40.10  added in new functions for the payroll
                               register report to handle reversals.
                               the function names are get_prepayment_aaid,
                               reversal_exists_check, reversal_exists_check_tax.
  rthakur   11-FEB-1999 40.11  uncommented out nocopy the exit command
  sdoshi    06-APR-1999 115.3  Flexible Dates Conversion
  sdoshi    06-APR-1999 115.4  Corrections - closing brackets added
                               to fnd_date statements
  djoshi    08-apr-1999        Verfied and converted for Canonical
                               Complience of Date
  AMills    28-Jul-1999 115.7  Added us_gp_multiple_gre_ytd,
                               us_gp_subject_to_tax_gre_ytd
                               and us_gp_gre_jd_ytd for Report
                               Tuning, for PAYUSTOT
                               and PAYUS940.
  skutteti  14-Sep-1999 115.8  Pre-tax enhancements
  ssarma    31-dec-1999 115.9  Tuning of us_gp_multiple_gre_ytd,
                               us_gp_subject_to_tax_gre_ytd,
                               us_gp_gre_jd_ytd for 1086239 -
                               Performance of PAYUSTOT and PAYUS940.
  ahanda    07-FEB-2000 115.10 Checking session variable for RUN, PYDATE
                               MONTH, QTD before getting balance.
  ekim      15-may-2000 115.11 Added legislation check
                               for get_balance_type
  JARTHURT  24-JUL-2000 115.12 Added legislation check
                               for get_defined_balance
  JARTHURT  25-JUL-2000 115.13 Corrected legislation check for
                               get_defined_balance
  irgonzal  13-DEC-2000 115.16 Modified SELECT statements due to poor
                               performance on GRE Totals Report (1542061).
                               Added rule-based hint.
  irgonzal  15-DEC-2000 115.19 Added rule-based hint to SELECT stmt. in
                               us_gp_subject_to_tax_gre_ytd procedure.
  ahanda    27-DEC-2000 115.20 Did the change done in 115.19 version of
                               package to 115.16 ver. 115.17 and 115.19
                               should not be send to clients as it has
                               the Winstar Changes.
  tclewis   6-SEP-2001  115.22 Modified the PAYMENTS_BALANCE_REQUIRED
                               function to work correctly with the umbrella
                               process
  tclewis   7-SEP-2001  115.24 Added check for session variable PTD in the
                               procedure US_NAMED_BALANCE_VM.  Now if the
                               session variable PTD is FALSE the procedure
                               will return null and not attempt to calculate
                               the value.
  tclewis  11-27-2001  115.25 Added dbdrv command.
  tclewis  12-05-2001  115.27 Added the following procedures
                                us_gp_multiple_gre_mtd
                                us_gp_multiple_gre_ctd
                                us_gp_subject_to_tax_gre_mtd
                                us_gp_subject_to_tax_gre_ctd
                                us_gp_gre_jd_mtd
                                us_gp_gre_jd_ctd
  meshah   12-05-2001  115.28 Added set verify off
  tmehra   12-16-2001  115.29 Currently there is no balance for FIT gross,
                              instead 'Gross Earnings' is used. Changed code
                              to subtract Alien earnings from FIT Gross.
  ahanda   05-JAN-2002 115.31 Changed the following function to work with
                              umbrella process:
                                 get_prepayment_aaid
                                 reversal_exists_check
                                 reversal_exists_check_tax
                                 us_named_balance_vm
  ahanda   08-JAN-2002 115.32 Changed function reversal_exists_check
                              to pass the business_group_id so that
                              it is set properly. Also changed the
                              default for BG ID to -1 from 0 (2175134).
  meshah   22-JAN-2002 115.34 added checkfile command. leap frogged 115.33
  ahanda   23-APR-2002 115.35 Checking session variable for CURRENT
                              in us_named_balance_vm and CURRENT, RUN, PTD,
                              PYDATE, MONTH in us_tax_balance_vm.
  tclewis  1-may-2002  115.36 Modified the cursors c_run_actions in the
                              procedures
                                 reversal_exists_check
                                 reversal_exists_check_tax
                              to return data for only the assignment_id
                              processed in the run payroll actions.
                              Eliminate a second join to pay_action_interlocks
                              in the procedure get_prepayment_aaid, as it
                              was not needed.
  ekim     25-Nov-2002 115.38 Changed like to = in function get_defined_balance
                              in query that gets l_defined_balance_id.

  ekim     25-Nov-2002 115.39 GSCC warning fix for default value.
  ekim     02-Dec-2002 115.40 GSCC warning fix for nocopy.
  tclewis  13-MAR-2003 115.41 Modified US_NAMED_BALANCE_VM and US_TAX_BALANCE_VM
                              with respect to the CURRENT Dimension, removed the
                              REV_CHK work around and implemented the ASG_PAYMENTS
                              balance dimension.  I also modified US_TAX_BALANCE
                              to accept ASG_PAYMENTS as a vaild time_type.
  kaverma  19-NOV-2003 115.43 Added status <> 'D' for pay_taxability_rules
  kaverma  21-NOV-2003 115.44 Corrected join for pay_taxability_rules as
                              nvl(status,'X') <> 'D'
  sdahiya  12-JAN-2004 115.45 Modified query for performance (Bug 3343982).
  tclewis  14-JAN-2004 115.46 Added STEIC to check of Taxable and excess bal.
  djoshi   29-JAN-2004 115.47 Changed the function payments_balance_required
                              to make sure asg_payments route is executed
                              when current ...
  sdahiya  17-FEB-2004 115.48 Removed RULE hint from queries. Bug 3331031.
  pragupta 14-APR-2005 115.50 The us_gp_multiple_gre_qtd changed to support 12
                              instead of 10 balance calls.
  pragupta 20-APR-2005 115.51 us_gp_multiple_gre_qtd procedure overloaded to
                              support 12 instead of 10 balances
  sackumar 15-SEP-2005 115.53 Revert back the changes done in 115.52.
  rdhingra 23-SEP-2005 115.54 Bug 4583566: Performance changes done
  rdhingra 23-SEP-2005 115.55 Bug 4583566: Performance changes done
  rdhingra 27-SEP-2005 115.56 Bug 4583566: Performance changes done
  rnestor 09-SEP-2008 115.58  Bug 6989549: TAX SUMMARY  TAX BALANCE SCREEN SHOWS
                                              DIFFERENT VALUES FOR EIC SUBJECT
  tclewis 04-DEC-2008  115.59 Added validation for SUI1 EE and SDI1.
  sudedas 03-APR-2009  115.62 Bug 7586556: Changed us_named_balance_vm and
                              introduced procedure us_entry_itd_balance.
  sudedas 14-MAY-2009  115.63 Bug 8515904 : Changed us_named_balance_vm and
                              us_entry_itd_balance. Added optional parameter
                              p_ele_typ_id.

*/

-- Global declarations
type num_array  is table of number(15) index by binary_integer;
type char80_array  is table of varchar2(80) index by binary_integer;
type char_array  is table of varchar2(1) index by binary_integer;
--
-- Assignment Id Cache
g_asgid_tbl_id num_array;
g_asgid_tbl_bgid num_array;
g_nxt_free_asgid binary_integer := 0;
--
-- Group Dimension Cache.
g_dim_tbl_grp char80_array;
g_dim_tbl_asg char80_array;
g_dim_tbl_crs num_array;
g_dim_tbl_vtd num_array;
g_dim_tbl_jdr char_array;
g_dim_tbl_btt char_array;
g_nxt_free_dim binary_integer;
--
-- 'Current' balance dimension info for
-- prepayments related to many payroll runs
g_run_action_id NUMBER;
g_prepay_action_id NUMBER;

-- Constants for assignment cursors.
--
ASG_CURSOR0 constant number := 0;
ASG_CURSOR1 constant number := 1;
ASG_CURSOR2 constant number := 2;
--
-- Constants for assignment vrtual date cursors.
--
ASG_VDATE_QTD0 constant number := 0;
ASG_VDATE_YTD0 constant number := 1;

-- BHOMAN
bh_workaround_local_error EXCEPTION;

-------------------------------------------------------------------------------
--
--  Quick procedure to raise an error
--
-------------------------------------------------------------------------------
PROCEDURE local_error(p_procedure varchar2,
                      p_step      number) IS
BEGIN
--
  FND_MESSAGE.SET_NAME(801,'HR_6153_ALL_PROCEDURE_FAIL');
  FND_MESSAGE.SET_TOKEN('PROCEDURE', 'bh_taxbal.'||p_procedure, FALSE);
  FND_MESSAGE.SET_TOKEN('STEP',p_step, FALSE);
  --FND_MESSAGE.RAISE_ERROR;
	-- BHOMAN - todo have to raise some error
	-- RAISE_APPLICATION_ERROR(-20001, 'local_error called');
	pay_us_balance_view_pkg.debug_err('local error exception raised from proc: ' ||
									p_procedure);
	raise bh_workaround_local_error;
--
END local_error;
--
--
-------------------------------------------------------------------------------
-- run_asg_vdate_cursor
-------------------------------------------------------------------------------
FUNCTION run_asg_vdate_cursor
(
p_curno         in  number,
p_assignment_id in  number,
p_date_earned   in  date,
p_date2_earned  in  date,
p_asg_vdate     out nocopy date
)
RETURN NUMBER
IS
  n_rows number;
  --
  cursor asg_vdate_qtd_cursor0( c_assignment_id in number,
                                c_date_earned   in date,
                                c_date2_earned  in date )
  is
  select max(PAF.effective_end_date)
  from   per_assignments_f PAF
  where  PAF.assignment_id = c_assignment_id
  and    PAF.payroll_id is not null
  and    PAF.effective_end_date
         between trunc(c_date_earned,'Q') and c_date2_earned;
  --
  cursor asg_vdate_ytd_cursor0( c_assignment_id in number,
                                c_date_earned   in date,
                                c_date2_earned  in date )
  is
  select max(PAF.effective_end_date)
  from   per_assignments_f PAF
  where  PAF.assignment_id = c_assignment_id
  and    PAF.payroll_id is not null
  and    PAF.effective_end_date
         between trunc(c_date_earned,'Y') and c_date2_earned;
BEGIN
  --
  if p_curno = ASG_VDATE_QTD0 then
    open asg_vdate_qtd_cursor0(p_assignment_id, p_date_earned, p_date2_earned);
    fetch asg_vdate_qtd_cursor0 into p_asg_vdate;
    n_rows := asg_vdate_qtd_cursor0%rowcount;
    close asg_vdate_qtd_cursor0;
    return n_rows;
  end if;
  --
  if p_curno = ASG_VDATE_YTD0 then
    open asg_vdate_ytd_cursor0(p_assignment_id, p_date_earned, p_date2_earned);
    fetch asg_vdate_ytd_cursor0 into p_asg_vdate;
    n_rows := asg_vdate_ytd_cursor0%rowcount;
    close asg_vdate_ytd_cursor0;
    return n_rows;
  end if;
  --
  p_asg_vdate := null;
  local_error( 'run_asg_vdate_cursor', '1' );
  return 0;
EXCEPTION
  when others then
    --
    if asg_vdate_qtd_cursor0%isopen then
      close asg_vdate_qtd_cursor0;
    elsif asg_vdate_ytd_cursor0%isopen then
      close asg_vdate_ytd_cursor0;
    end if;
    raise;
END run_asg_vdate_cursor;

---------------------------------------------------------------------------
-- FUNCTION: Payments_Balance_Required
--  This function caches information related to an assignment action
--  for a payroll run related to a pre-payment composed of multiple
--  runs.  This is to support the 'CURRENT' balance value displayed
--  on checkwriter and related reports(PAYRPCHK, PAYRPPST, PAYRPREG)
--
--  Returns:
--  TRUE if multiple runs exists and sets global prepayment id
--  FALSE if a single run exists and clears global prepayment id
--------------------------------------------------------------------------

FUNCTION payments_balance_required(p_assignment_action_id NUMBER) RETURN boolean IS

cursor  c_prepay_action (cp_run_action_id number) is
  select paa.assignment_action_id
  from   pay_action_interlocks pai,
         pay_assignment_actions paa,
         pay_payroll_actions ppa
  where  pai.locked_action_id = cp_run_action_id
  and    paa.assignment_action_id = pai.locking_action_id
  and    ppa.payroll_action_id  = paa.payroll_action_id
  and    ppa.action_type in ('P', 'U');

cursor c_payments (cp_pre_pymt_action_id  number,
                  cp_assignment_action_id number) is
 select ppp.source_action_id
 from pay_pre_payments ppp
 where ppp.assignment_action_id = cp_pre_pymt_action_id
 and   ppp.source_action_id = cp_assignment_action_id;
/*
CURSOR c_count_runs(cp_pre_pymt_action_id NUMBER ) IS
select count(pai.locked_action_id)
from pay_action_interlocks  pai,
     pay_pre_payments       ppp,
     pay_assignment_actions  paa
where ppp.assignment_action_id = cp_pre_pymt_action_id
and  nvl(ppp.source_action_id,0) <> pai.locked_action_id
and   pai.locking_action_id = ppp.assignment_action_id
and   pai.locked_action_id = paa.assignment_action_id
and   paa.source_action_id is not null;
*/


CURSOR c_count_runs(cp_pre_pymt_action_id NUMBER , cp_run_type_id NUMBER) IS
select count(pai.locked_action_id)
from pay_action_interlocks  pai,
     pay_assignment_actions  paa
where pai.locking_action_id = cp_pre_pymt_action_id
and   pai.locked_action_id = paa.assignment_action_id
and   nvl(paa.run_type_id,cp_run_type_id) <> cp_run_type_id
and   paa.source_action_id is not null;


cursor c_run_type_id is
select prt.run_type_id
  from pay_run_types_f prt
where prt.shortname = 'SEPCHECK'
  and prt.legislation_code = 'US';

l_count_runs NUMBER;
l_prepay_action_id NUMBER;
l_source_action_id NUMBER;
l_run_type_id NUMBER  := -9999;

BEGIN

/* fetch the runtype id for sepcheck*/

open c_run_type_id;
fetch c_run_type_id into l_run_type_id;
close c_run_type_id;


IF g_run_action_id = p_assignment_action_id
   AND g_prepay_action_id IS NOT NULL THEN  /* Have processed this assignment and*/
   RETURN TRUE;                             /* it does have multiple RUNS */
ELSIF  g_run_action_id = p_assignment_action_id
   AND g_prepay_action_id IS NULL THEN      /* Have processed this assignment and*/
   RETURN FALSE;                            /* it does not have multiple RUNS */
ELSE
    g_run_action_id := p_assignment_action_id;  /* set Run action id */
    open c_prepay_action (p_assignment_action_id);
    fetch c_prepay_action into g_prepay_action_id;
    if c_prepay_action%FOUND then
       close c_prepay_action;
       open c_payments (g_prepay_action_id, p_assignment_action_id);
       fetch c_payments into l_source_action_id;
       if  c_payments%NOTFOUND then
           close c_payments;
           open c_count_runs (g_prepay_action_id,l_run_type_id);
           fetch c_count_runs into l_count_runs;
           if c_count_runs%NOTFOUND or l_count_runs < 2 then
              close c_count_runs;
              g_prepay_action_id := NULL;     /* Clear asg_act_ids if they do not */
              RETURN FALSE;
           else
              close c_count_runs;
              g_run_action_id := p_assignment_action_id; /* Set asg_act_ids if multple runs */
              RETURN TRUE;
           end if;
       else
           close c_payments;
           g_prepay_action_id := NULL;     /* Clear asg_act_ids if they do not */
           RETURN FALSE;
       end if;
    else
       close c_prepay_action;
           g_prepay_action_id := NULL;     /* Clear asg_act_ids if they do not */
           RETURN FALSE;
    end if;
END IF;

END; /* payments_balance_required */
--
----------------------------------------------------------------------------
-- Get the assignment level equivalent of the group balance, plus a cursor
-- that returns all the assignments contributing to the group level balance.
----------------------------------------------------------------------------
procedure get_asg_for_grp_lvl(p_grp_dvl_dimension  in      varchar2,
                              p_asg_lvl_dimension     out nocopy  varchar2,
                              p_asg_cursor            out nocopy  varchar2,
                              p_asg_jd_required       out nocopy  boolean,
                              p_asg_vdate_cursor      out nocopy  number,
                              p_asg_balance_time      out nocopy  varchar2,
                              p_found                 out nocopy  boolean)
is
  l_count number;
  l_found boolean;
begin
  --   Look to see if the group level balance is in our cache.
  --
  --hr_utility.set_location('bh_taxbal.get_asg_for_grp_lvl', 10);
   pay_us_balance_view_pkg.debug_msg( '===========================================');
	pay_us_balance_view_pkg.debug_msg('get_asg_for_grp_lvl entry:');
	pay_us_balance_view_pkg.debug_msg('  p_grp_dvl_dimension: ' || p_grp_dvl_dimension);
  --
  l_count := 0;
  l_found := FALSE;
  while ((l_count < g_nxt_free_dim) AND (l_found = FALSE)) loop
	 pay_us_balance_view_pkg.debug_msg('  checking internal dim tables, count: '
																|| l_count);
    if (p_grp_dvl_dimension = g_dim_tbl_grp(l_count)) then
        --hr_utility.set_location('bh_taxbal.get_asg_for_grp_lvl', 20);
        --
        p_asg_lvl_dimension := g_dim_tbl_asg(l_count);
        p_asg_cursor := g_dim_tbl_crs(l_count);
        p_asg_vdate_cursor := g_dim_tbl_vtd(l_count);
        p_asg_balance_time := g_dim_tbl_btt(l_count);
        --
        -- Does the cursor require the jurisdiction_code.
        --
        if g_dim_tbl_jdr(l_count) = 'Y' then
           p_asg_jd_required := TRUE;
        else
           p_asg_jd_required := FALSE;
        end if;
        l_found := TRUE;
		  pay_us_balance_view_pkg.debug_msg(' FOUND asg level');
        --
    end if;
    l_count := l_count + 1;
  end loop;
  --
  --hr_utility.set_location('bh_taxbal.get_asg_for_grp_lvl', 30);
  p_found := l_found;
  --
end;
--
-----------------------------------------------------------------------------
FUNCTION get_balance_type (p_balance_name in varchar2) RETURN NUMBER
--
IS
l_balance_type_id number;
--
cursor get_balance_type_id (c_balance_name in varchar2) is
     select balance_type_id
     from pay_balance_types
     where balance_name = c_balance_name
       and legislation_code = 'US';
--
BEGIN
--
   if p_balance_name is not null then
   --
      open get_balance_type_id(p_balance_name);
      fetch get_balance_type_id into l_balance_type_id;
      close get_balance_type_id;
   --
      if l_balance_type_id is NULL then
         RAISE NO_DATA_FOUND;
      end if;
   --
   end if;
--
RETURN l_balance_type_id;
--
END get_balance_type;
--
----------------------------------------------------------------------------
-- Get the defined balance id given the balance name and database item
-- suffix.
----------------------------------------------------------------------------
function get_defined_balance (p_balance_name     varchar2,
                              p_dimension_suffix  varchar2) return number is
l_defined_balance_id number;
l_business_group_id number;
--
begin
  --
  l_business_group_id := pay_us_balance_view_pkg.get_context('BUSINESS_GROUP_ID');
  --
  begin
    SELECT  creator_id
      INTO  l_defined_balance_id
      FROM  ff_user_entities
     WHERE  user_entity_name = translate(p_balance_name||'_'||p_dimension_suffix,' ','_')
       AND (legislation_code = 'US'
        OR business_group_id = l_business_group_id);
    --
    return l_defined_balance_id;
  exception
    when others then
	-- BHOMAN - added this exception to fix issues with testing
	--     we must revisit this!!
      pay_us_balance_view_pkg.debug_err('get_defined_balance failed:  ');
      pay_us_balance_view_pkg.debug_err('   bal_name: ' || p_balance_name);
      pay_us_balance_view_pkg.debug_err('   p_dimension_suffix: '|| p_dimension_suffix);
      pay_us_balance_view_pkg.debug_err('   user_entity_name like: ' ||
          translate(p_balance_name ||'_' ||p_dimension_suffix, ' ', '_'));
      local_error( 'get_defined_balance', '1' );
  end;
  return l_defined_balance_id;
end;
--
--
------------------------------------------------------------------------------
-- This ensures that the assignment is on a payroll on the effective date,
-- if not a valid date is found. If no valid date can be found an error is
-- raised.
------------------------------------------------------------------------------
function get_virtual_date (p_assignment_id     number,
                           p_virtual_date      date,
                           p_balance_time      varchar2,
                           p_asg_vdate_cursor  number) return date is
l_dummy         varchar2(1);
l_virtual_date  date;
l_virtual_date2 date;
l_res_date      date;
begin
   begin
      --
      -- Is the assignment on a payroll.
      --
      --hr_utility.set_location('bh_taxbal.get_virtual_date', 10);
      select ''
        into l_dummy
        from per_assignments_f paf
       where paf.assignment_id = p_assignment_id
         and p_virtual_date between paf.effective_start_date
                                and paf.effective_end_date
         and paf.payroll_id is not null;

       --
       --hr_utility.set_location('bh_taxbal.get_virtual_date', 20);
       return p_virtual_date;
   exception
       when no_data_found then
           --
           -- Find a valid date for the assignment.
           --
           declare
              l_rows     number;
           begin
              --hr_utility.set_location('bh_taxbal.get_virtual_date', 30);
              l_rows := run_asg_vdate_cursor( p_asg_vdate_cursor,
                                              p_assignment_id,
                                              p_virtual_date,
                                              p_virtual_date,
                                              l_virtual_date );
              if l_rows > 0 then
                  --hr_utility.set_location( 'bh_taxbal.get_virtual_date', 40);
                  --
                  select max(ppf.effective_end_date)
                    into l_virtual_date2
                    from per_assignments_f paf,
                         pay_payrolls_f    ppf
                   where paf.assignment_id = p_assignment_id
                     and paf.payroll_id = ppf.payroll_id
                     and ppf.effective_end_date between
                               trunc(p_virtual_date, p_balance_time)
                                   and p_virtual_date;
                  --
                  -- Now work out which date is needed
                  --
                  if l_virtual_date is null then
                     if l_virtual_date2 is null then
                          --hr_utility.set_location( 'bh_taxbal.get_virtual_date', 60);
                        local_error('get_virtual_date', 2);
                     else
                        --hr_utility.set_location( 'bh_taxbal.get_virtual_date', 70);
                        l_res_date := l_virtual_date2;
                     end if;
                  else
                     if l_virtual_date2 is null then
                        --hr_utility.set_location( 'bh_taxbal.get_virtual_date', 80);
                        l_res_date := l_virtual_date;
                     else
                        --hr_utility.set_location( 'bh_taxbal.get_virtual_date', 90);
                        l_res_date := least(l_virtual_date, l_virtual_date2);
                     end if;
                  end if;
                  --
              else
                  --hr_utility.set_location( 'bh_taxbal.get_virtual_date', 50);
                  local_error('get_virtual_date', 1);
              end if;
              --
           end;
           --
           return l_res_date;
   end;
end;
--
--
------------------------------------------------------------------------------
-- Get the balance value of a group level balance given the assignment id.
------------------------------------------------------------------------------
function get_grp_asg_value (p_assignment_id        number,
                            p_virtual_date         date,
                            p_balance_name         varchar2,
                            p_database_suffix      varchar2,
                            p_gre_id               number,
                            p_jurisdiction_code    varchar2)
                            return number is
--
-- Cursors for getting assignments.
--
  cursor asg_cur0( c_tax_unit_id in  number,
                   c_date_earned in  date,
                   c_date2_earned in date )
  is
  select distinct PAA.assignment_id
  from   pay_assignment_actions PAA,
         pay_payroll_actions    PPA
  where  PAA.tax_unit_id = c_tax_unit_id
  and    PPA.payroll_action_id =  PAA.payroll_action_id
  and    PPA.effective_date >= trunc(c_date_earned,'Q')
  and    PPA.effective_date <= c_date2_earned
  and    PPA.action_type in ('R','Q','I','B','V');
--
  cursor asg_cur1( c_tax_unit_id in  number,
                   c_date_earned in  date,
                   c_date2_earned in date )
  is
  select distinct PAA.assignment_id
  from   pay_assignment_actions PAA,
         pay_payroll_actions    PPA
  where  PAA.tax_unit_id = c_tax_unit_id
  and    PPA.payroll_action_id =  PAA.payroll_action_id
  and    PPA.effective_date >= trunc(c_date_earned,'Y')
  and    PPA.effective_date <= c_date2_earned
  and    PPA.action_type in ('R','Q','I','B','V');
--
  cursor asg_cur2( c_tax_unit_id       in number,
                   c_balance_type_id   in number,
                   c_jurisdiction_code in varchar2,
                   c_date_earned       in date,
                   c_date2_earned      in date )
  is
  select distinct PAR.assignment_id
  from pay_balance_types      PBT,
       pay_us_asg_reporting   PAR
  where PAR.tax_unit_id = c_tax_unit_id
  and   PBT.balance_type_id = c_balance_type_id
  and   PBT.jurisdiction_level <> 0
  and   substr(PAR.jurisdiction_code, 1, PBT.jurisdiction_level) =
        substr(c_jurisdiction_code, 1, PBT.jurisdiction_level)
  and   exists
  (select 1
   from  pay_payroll_actions    PPA,
         pay_assignment_actions PAA
   where PAA.assignment_id = PAR.assignment_id
   and   PAA.tax_unit_id = PAR.tax_unit_id
   and   PPA.payroll_action_id = PAA.payroll_action_id
   and   PPA.effective_date >= trunc(c_date_earned,'Y')
   and   PPA.effective_date <= c_date2_earned
   and   PPA.action_type in ('R','Q','I','B','V'));
--
l_dummy varchar2(5);
l_lat_balances boolean;
l_asg_data_suffix varchar2(80);
l_asg_data_cursor number;
l_asg_vdate_cursor number;
l_asg_balance_time varchar2(10);
l_asg_jd_required boolean;
l_grp_lat_exist boolean;
l_defined_balance_id number;
l_asg_id number;
l_balance_value number;
l_virtual_date date;
l_balance_type_id number;
begin
	--
   pay_us_balance_view_pkg.debug_msg( '===========================================');
	pay_us_balance_view_pkg.debug_msg('get_grp_asg_value entry:');
	pay_us_balance_view_pkg.debug_msg('  p_assignment_id:         ' || p_assignment_id);
	pay_us_balance_view_pkg.debug_msg('  p_virtual_date:          ' || p_virtual_date);
	pay_us_balance_view_pkg.debug_msg('  p_balance_name:          ' || p_balance_name);
	pay_us_balance_view_pkg.debug_msg('  p_database_suffix:       ' || p_database_suffix);
	pay_us_balance_view_pkg.debug_msg('  p_gre_id:                ' || p_gre_id);
	pay_us_balance_view_pkg.debug_msg('  p_jurisdiction_code:     ' || p_jurisdiction_code);
	--
   l_balance_value := 0;
   --hr_utility.set_location('bh_taxbal.get_grp_asg_value', 10);
   --
   -- Get the assignment level version.
   --
   get_asg_for_grp_lvl(p_database_suffix,
                       l_asg_data_suffix,
                       l_asg_data_cursor,
                       l_asg_jd_required,
                       l_asg_vdate_cursor,
                       l_asg_balance_time,
                       l_grp_lat_exist);
	--
   --
   if l_grp_lat_exist then
		pay_us_balance_view_pkg.debug_msg('   l_grp_lat_exist TRUE');
		pay_us_balance_view_pkg.debug_msg('    l_asg_data_suffix: '
														|| l_asg_data_suffix);
		pay_us_balance_view_pkg.debug_msg('    l_asg_data_cursor: '
														|| l_asg_data_cursor);
		pay_us_balance_view_pkg.debug_msg('    l_asg_vdate_cursor: '
														|| to_char(l_asg_vdate_cursor));
		pay_us_balance_view_pkg.debug_msg('    l_asg_balance_time: '
														|| l_asg_balance_time);
		if l_asg_jd_required = TRUE then
			pay_us_balance_view_pkg.debug_msg('    l_asg_jd_required: TRUE');
		else
			pay_us_balance_view_pkg.debug_msg('    l_asg_jd_required: FALSE');
		end if;
      --
      -- Are there latest balances available.
      --
      --hr_utility.set_location('bh_taxbal.get_grp_asg_value', 20);
      l_defined_balance_id := get_defined_balance(p_balance_name,
                                                  l_asg_data_suffix);
		pay_us_balance_view_pkg.debug_msg('   got defbalid: '
													|| l_defined_balance_id
													|| ' from balname: '
													|| p_balance_name
													|| ' and asg data suffix: '
													|| l_asg_data_suffix);
		pay_us_balance_view_pkg.debug_msg('   looking for latest bals ');
      --
      begin
         select ''
         into l_dummy
         from dual
         where exists (
                        select ''
                        from pay_payroll_actions            ppa,
                             pay_assignment_actions         paa,
                             pay_assignment_latest_balances palb
                        where palb.assignment_id        = p_assignment_id
                        and   palb.defined_balance_id   = l_defined_balance_id
                        and   palb.assignment_action_id =
                                             paa.assignment_action_id
                        and   paa.payroll_action_id     = ppa.payroll_action_id
                        and   p_virtual_date           >= ppa.effective_date
                        and   ppa.action_type in ('R','Q','I','B','V'));
         --
         l_lat_balances := TRUE;
         --
      exception
         when no_data_found then
            l_lat_balances := FALSE;
		   pay_us_balance_view_pkg.debug_msg('  latest balances found');
      end;
      --
      if (l_lat_balances = TRUE) then
         --
         -- OK, we can sum the values of the assignment balances to get the
         -- group balance.
         --
		   pay_us_balance_view_pkg.debug_msg('  summing latest balance values');
         --hr_utility.set_location('bh_taxbal.get_grp_asg_value', 30);
         begin
            --
            -- Does the cursor require the jurisdiction code. Hence balance
            -- type.
            --
            if l_asg_jd_required then
               select balance_type_id
                 into l_balance_type_id
                 from pay_defined_balances
                where defined_balance_id = l_defined_balance_id;
					pay_us_balance_view_pkg.debug_msg('  since jd req, retrieved bal type id of: '
													|| l_balance_type_id);
               --
            end if;

            if l_asg_data_cursor = ASG_CURSOR0 then
              open asg_cur0( p_gre_id, p_virtual_date, p_virtual_date );
            elsif l_asg_data_cursor = ASG_CURSOR1 then
              open asg_cur1( p_gre_id, p_virtual_date, p_virtual_date );
            elsif l_asg_data_cursor = ASG_CURSOR2 then
              open asg_cur2( p_gre_id, l_balance_type_id, p_jurisdiction_code,
                             p_virtual_date, p_virtual_date );
            else
              local_error( 'get_grp_asg_value', 1 );
              return null;
            end if;

            --
            -- Loop through all the contributing assignments, go get there
            -- balance value and add onto the running total.
            --
            loop
				  pay_us_balance_view_pkg.debug_msg('  loop thru latest balances cursor');
              if l_asg_data_cursor = ASG_CURSOR0 then
                fetch asg_cur0 into l_asg_id;
                exit  when asg_cur0%notfound;
              elsif l_asg_data_cursor = ASG_CURSOR1 then
                fetch asg_cur1 into l_asg_id;
                exit  when asg_cur1%notfound;
              elsif l_asg_data_cursor = ASG_CURSOR2 then
                fetch asg_cur2 into l_asg_id;
                exit  when asg_cur2%notfound;
              end if;

              --hr_utility.set_location( 'bh_taxbal.get_grp_asg_value', 40);
              l_virtual_date := get_virtual_date(l_asg_id, p_virtual_date,
                                                 l_asg_balance_time,
                                                 l_asg_vdate_cursor);
				  pay_us_balance_view_pkg.debug_msg('  got l_virtual_date: '
                                       || fnd_date.date_to_canonical(p_virtual_date));
              --
              -- Dont cache on this get_value call because assignment_id
              -- is changing.
              --
              l_balance_value := l_balance_value +
					-- BHOMAN - fixed param order ....
              pay_us_balance_view_pkg.get_value(l_asg_id,
												l_defined_balance_id,
                                    l_virtual_date, 1);
				  pay_us_balance_view_pkg.debug_msg('  running sum l_balance_value: '
														|| l_balance_value);
            end loop;

            --
            if l_asg_data_cursor = ASG_CURSOR0 then
              close asg_cur0;
            elsif l_asg_data_cursor = ASG_CURSOR1 then
              close asg_cur1;
            elsif l_asg_data_cursor = ASG_CURSOR2 then
              close asg_cur2;
            end if;
         exception
           when others then
             if l_asg_data_cursor = ASG_CURSOR0 and asg_cur0%isopen then
              close asg_cur0;
            elsif l_asg_data_cursor = ASG_CURSOR1 and asg_cur1%isopen then
              close asg_cur1;
            elsif l_asg_data_cursor = ASG_CURSOR2 and asg_cur2%isopen then
              close asg_cur2;
            end if;
            raise;
         end;
      else
         --
         -- No latest balances available. Run the route.
         --
		   pay_us_balance_view_pkg.debug_msg('  no latest bals, running route');
         --hr_utility.set_location('bh_taxbal.get_grp_asg_value', 50);
         l_defined_balance_id := get_defined_balance(p_balance_name,
                                                     p_database_suffix);
		   pay_us_balance_view_pkg.debug_msg('  def bal id: ' || l_defined_balance_id);
         l_balance_value := pay_us_balance_view_pkg.get_value(	p_assignment_id,
																	l_defined_balance_id,
                                                  	p_virtual_date
                                                 );
      end if;
   else
      --
      -- Can not sum the assignment level balances, thus run group
      -- level route.
		pay_us_balance_view_pkg.debug_msg('  Can not sum the assignment level balances, running route');
      --
      --hr_utility.set_location('bh_taxbal.get_grp_asg_value', 60);
      l_defined_balance_id := get_defined_balance(p_balance_name,
                                                  p_database_suffix);
		pay_us_balance_view_pkg.debug_msg('  def bal id: ' || l_defined_balance_id);
      l_balance_value := pay_us_balance_view_pkg.get_value
                                              (
                                               	p_assignment_id,
																l_defined_balance_id,
                                               	p_virtual_date
                                              );
   end if;
   --
   --hr_utility.set_location('bh_taxbal.get_grp_asg_value', 70);
	pay_us_balance_view_pkg.debug_msg('  *** get_grp_asg_value returning l_balance_value: '
														|| l_balance_value);
   return l_balance_value;
   --
end;
--
------------------------------------------------------------------------------
-- Get the balance value of a group level balance given the assignment action
-- id.
------------------------------------------------------------------------------
function get_grp_act_value (p_assignment_action_id        number,
                            p_virtual_date                date,
                            p_balance_name                varchar2,
                            p_database_suffix             varchar2,
                            p_gre_id                      number)
                            return number is
l_defined_balance_id number;
l_balance_value number;
begin
   --hr_utility.set_location('bh_taxbal.get_grp_act_value', 10);
	--
   pay_us_balance_view_pkg.debug_msg( '===========================================');
	pay_us_balance_view_pkg.debug_msg('get_grp_act_value entry:');
	pay_us_balance_view_pkg.debug_msg('  p_assignment_action_id:  ' || p_assignment_action_id);
	pay_us_balance_view_pkg.debug_msg('  p_virtual_date:          ' || p_virtual_date);
	pay_us_balance_view_pkg.debug_msg('  p_balance_name:          ' || p_balance_name);
	pay_us_balance_view_pkg.debug_msg('  p_database_suffix:       ' || p_database_suffix);
	pay_us_balance_view_pkg.debug_msg('  p_gre_id:                ' || p_gre_id);
	--
   l_balance_value := 0;
   --
   l_defined_balance_id := get_defined_balance(p_balance_name,
                                               p_database_suffix);
   l_balance_value := pay_us_balance_view_pkg.get_value (
                                         		p_assignment_action_id,
															l_defined_balance_id
                                             );
   --
   --hr_utility.set_location('bh_taxbal.get_grp_act_value', 20);
   return l_balance_value;
   --
end;
--
-------------------------------------------------------------------------------
-- Get the value of the group level balance.
-------------------------------------------------------------------------------
function get_grp_value (p_assignment_id        number,
                        p_virtual_date         date,
                        p_balance_name         varchar2,
                        p_database_suffix      varchar2,
                        p_gre_id               number,
                        p_jurisdiction_code    varchar2,
                        p_assignment_action_id number default null)
                        return number is
begin
   --hr_utility.set_location('bh_taxbal.get_grp_value', 10);
   pay_us_balance_view_pkg.debug_msg( '===========================================');
	pay_us_balance_view_pkg.debug_msg('get_grp_value entry:');
	pay_us_balance_view_pkg.debug_msg('  p_assignment_id:         ' || p_assignment_id);
	pay_us_balance_view_pkg.debug_msg('  p_virtual_date:          ' || p_virtual_date);
	pay_us_balance_view_pkg.debug_msg('  p_balance_name:          ' || p_balance_name);
	pay_us_balance_view_pkg.debug_msg('  p_database_suffix:       ' || p_database_suffix);
	pay_us_balance_view_pkg.debug_msg('  p_gre_id:                ' || p_gre_id);
	pay_us_balance_view_pkg.debug_msg('  p_jurisdiction_code:     ' || p_jurisdiction_code);
	pay_us_balance_view_pkg.debug_msg('  p_assignment_action_id:  ' || p_assignment_action_id);

   if p_assignment_action_id is null then
       --hr_utility.set_location('bh_taxbal.get_grp_value', 20);
       return get_grp_asg_value(p_assignment_id,
                                p_virtual_date,
                                p_balance_name,
                                p_database_suffix,
                                p_gre_id,
                                p_jurisdiction_code);
   else
       --hr_utility.set_location('bh_taxbal.get_grp_value', 30);
       return get_grp_act_value(p_assignment_action_id,
                                p_virtual_date,
                                p_balance_name,
                                p_database_suffix,
                                p_gre_id);
   end if;
end;
--
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--
FUNCTION us_entry_itd_balance(p_balance_name               varchar2
                             ,p_dimension_suffix           varchar2
                             ,p_assignment_action_id       number
                             ,p_source_id                  number
                             ,p_business_group_id          number)
RETURN NUMBER IS

  CURSOR csr_get_def_balance(p_balance_name      varchar2
                            ,p_dimension_suffix  varchar2
                            ,p_business_group_id number) IS
      SELECT pdb.defined_balance_id
        FROM pay_balance_types pbt
            ,pay_balance_dimensions pbd
            ,pay_defined_balances pdb
       WHERE upper(pbt.balance_name) = p_balance_name
         AND ((pbt.business_group_id = p_business_group_id)
             OR
              (pbt.business_group_id IS NULL AND
               pbt.legislation_code = 'US'))
         AND pbd.database_item_suffix = '_' || p_dimension_suffix
         AND pbd.legislation_code = 'US'
         AND pbt.balance_type_id = pdb.balance_type_id
         AND pbd.balance_dimension_id = pdb.balance_dimension_id;

    ln_defined_balance_id      pay_defined_balances.defined_balance_id%TYPE;

BEGIN
     hr_utility.trace('Entered into us_entry_itd_balance');
     hr_utility.trace('p_balance_name := ' || p_balance_name);
     hr_utility.trace('p_dimension_suffix := ' || p_dimension_suffix);
     hr_utility.trace('p_assignment_action_id := ' || p_assignment_action_id);
     hr_utility.trace('p_source_id := ' || p_source_id);
     hr_utility.trace('p_business_group_id := ' || p_business_group_id);

     open csr_get_def_balance(p_balance_name
                             ,p_dimension_suffix
                             ,p_business_group_id);
     fetch csr_get_def_balance into ln_defined_balance_id;
     close csr_get_def_balance;

     hr_utility.trace('ln_defined_balance_id := ' || ln_defined_balance_id);
     hr_utility.trace('Before calling pay_balance_pkg.get_value');

     IF NVL(ln_defined_balance_id, -9999) = -9999 THEN
        RETURN 0;

     ELSE
       RETURN  pay_balance_pkg.get_value(p_defined_balance_id => ln_defined_balance_id
                                      ,p_assignment_action_id => p_assignment_action_id
                                      ,p_tax_unit_id => NULL
                                      ,p_jurisdiction_code => NULL
                                      ,p_source_id => p_source_id
                                      ,p_source_text => NULL
                                      ,p_tax_group => NULL
                                      ,p_original_entry_id => p_source_id
                                      ,p_date_earned => NULL
                                      );
     END IF;

END us_entry_itd_balance;
-------------------------------------------------------------------------------
--
--  Wrapper around the core bal user exit
--
-------------------------------------------------------------------------------
FUNCTION call_balance_user_exit
                         (p_balance_name          varchar2,
                          p_dimension_suffix      varchar2,
                          p_assignment_action_id  number    DEFAULT NULL,
                          p_assignment_id         number    DEFAULT NULL,
                          p_virtual_date          date      DEFAULT NULL,
                          p_asg_type              varchar2  DEFAULT NULL,
                          p_gre_id                number    DEFAULT NULL,
                          p_jurisdiction_code     varchar2  DEFAULT NULL)
RETURN number IS
--
l_defined_balance_id  number;
l_balance_type_id     number;
l_dimension_id        number;
l_session             VARCHAR2(15);
--
BEGIN
--
   pay_us_balance_view_pkg.debug_msg( '===========================================');
	pay_us_balance_view_pkg.debug_msg('call_balance_user_exit entry:');
	pay_us_balance_view_pkg.debug_msg('  p_balance_name:         ' || p_balance_name);
	pay_us_balance_view_pkg.debug_msg('  p_dimension_suffix:     ' || p_dimension_suffix);
	pay_us_balance_view_pkg.debug_msg('  p_assignment_action_id: ' || p_assignment_action_id);
	pay_us_balance_view_pkg.debug_msg('  p_assignment_id:        ' || p_assignment_id);
	pay_us_balance_view_pkg.debug_msg('  p_virtual_date:         ' || p_virtual_date);
	pay_us_balance_view_pkg.debug_msg('  p_asg_type:             ' || p_asg_type);
	pay_us_balance_view_pkg.debug_msg('  p_gre_id:               ' || p_gre_id);
	pay_us_balance_view_pkg.debug_msg('  p_jurisdiction_code:    ' || p_jurisdiction_code);

  --hr_utility.set_location('bh_taxbal.balance_name'||p_balance_name, 9);

  --hr_utility.set_location('bh_taxbal.call_balance_user_exit', 10);
  IF p_assignment_action_id IS NOT NULL  THEN
   -- If group level balance, call the group level balance code.
	pay_us_balance_view_pkg.debug_msg('    assignment_action_id not NULL: '
																								|| p_assignment_action_id);
   if p_asg_type = 'GRE' then
		 pay_us_balance_view_pkg.debug_msg(', p_asg_type GRE, calling get_grp_value');
       --hr_utility.set_location('bh_taxbal.call_balance_user_exit', 20);
       return get_grp_value(p_assignment_id,
                                    p_virtual_date,
                                    p_balance_name,
                                    p_dimension_suffix,
                                    p_gre_id,
                                    p_jurisdiction_code,
                                    p_assignment_action_id
                                    );
   else
	 pay_us_balance_view_pkg.debug_msg('   p_asg_type *not* GRE, calling get_defined_balance and get_value');
    l_defined_balance_id := get_defined_balance(p_balance_name,
                                               p_dimension_suffix);
    IF p_dimension_suffix not like '%PAY%' THEN
     --hr_utility.set_location('bh_taxbal.call_balance_user_exit', 30);
		-- BHOMAN -- this is where pmadore's test case calls get_value
		-- if asg_type = PER, def_bal_id is 3167; if ASG then 3157,
		-- if GRE then doesn't call here
		-- assact_id is fathful to whatever we pass
		-- if TRUE then
		-- 	return p_assignment_action_id;
		-- end if;
     	--
		--
		-- return pay_us_balance_view_pkg.get_value (l_defined_balance_id,
		--                               p_assignment_action_id
		--                               );
	 	pay_us_balance_view_pkg.debug_msg('   dimension not like PAY, calling get_value in default mode');
		return pay_us_balance_view_pkg.get_value (p_assignment_action_id,
		                              l_defined_balance_id
		                              );
    ELSE /* If payments dimension then must execute DB item 395029 */
     --hr_utility.set_location('bh_taxbal.call_balance_user_exit', 40);
	  pay_us_balance_view_pkg.debug_msg('   dimension *is* like PAY, calling get_value with *NO* caching');
     return pay_us_balance_view_pkg.get_value (
                                   	p_assignment_action_id,
												l_defined_balance_id,
												0,
												1 );
    END IF;
   end if;
   --
  ELSE
    -- If group level balance, call the group level balance code.
	 pay_us_balance_view_pkg.debug_msg('    assignment_action_id *is* NULL: ');
    if p_asg_type = 'GRE' then
	    pay_us_balance_view_pkg.debug_msg('    p_asg_type is GRE, calling get_grp_value');
       --hr_utility.set_location('bh_taxbal.call_balance_user_exit', 50);
       return get_grp_value(p_assignment_id,
                                    p_virtual_date,
                                    p_balance_name,
                                    p_dimension_suffix,
                                    p_gre_id,
                                    p_jurisdiction_code,
                                    null
                                    );
    else
	    pay_us_balance_view_pkg.debug_msg('    p_asg_type is *not* GRE, calling get_defined_balance and get_value');
       l_defined_balance_id := get_defined_balance(p_balance_name,
                                                   p_dimension_suffix);
       --hr_utility.set_location('bh_taxbal.call_balance_user_exit', 60);
       return pay_us_balance_view_pkg.get_value (
                                    	p_assignment_id,
													l_defined_balance_id,
                                    	p_virtual_date
                                     );
    end if;
  END IF;
--
END call_balance_user_exit;
--
-------------------------------------------------------------------------------
--
--  Wrapper around the call_balance_user_exit - this wrapper sets
--  tax_unit_id and/or jd context from parameters.
--
-------------------------------------------------------------------------------
FUNCTION us_named_balance
                         (p_balance_name          varchar2,
                          p_dimension_suffix      varchar2,
                          p_assignment_action_id  number ,
                          p_assignment_id         number ,
                          p_virtual_date          date   ,
                          p_asg_type              varchar2 ,
                          p_gre_id                number   ,
                          p_business_group_id     number   ,
                          p_jurisdiction_code     varchar2 )
RETURN number IS
	l_balance  number;
BEGIN
	pay_us_balance_view_pkg.debug_msg( '===========================================');
	pay_us_balance_view_pkg.debug_msg('Enter US_NAMED_BALANCE:');
	pay_us_balance_view_pkg.debug_msg(' balance_name:         ' || p_balance_name);
	pay_us_balance_view_pkg.debug_msg(' dimension_suffix:     ' || p_dimension_suffix);
	pay_us_balance_view_pkg.debug_msg(' assignment_action_id: ' || p_assignment_action_id);
	pay_us_balance_view_pkg.debug_msg(' assignment_id:        ' || p_assignment_id);
	pay_us_balance_view_pkg.debug_msg(' virtual_date:         ' || p_virtual_date);
	pay_us_balance_view_pkg.debug_msg(' asg_type:             ' || p_asg_type);
	pay_us_balance_view_pkg.debug_msg(' gre_id:               ' || p_gre_id);
	pay_us_balance_view_pkg.debug_msg(' business_group_id:    ' || p_business_group_id);
	pay_us_balance_view_pkg.debug_msg(' jurisdiction_code:    ' || p_jurisdiction_code);
	--
	pay_us_balance_view_pkg.set_context('TAX_UNIT_ID',p_gre_id);
	IF p_jurisdiction_code IS NOT NULL THEN
		-- BHOMAN - review this twisted logic with LWTHOMPS:
		-- should I use 'SCHOOL%', or '%SCHOOL%', or shoud I just
		-- pass a tax type
  		IF (p_balance_name like ('SCHOOL%') and
									length(p_jurisdiction_code) > 11) THEN
    		pay_us_balance_view_pkg.set_context('JURISDICTION_CODE',
											substr(p_jurisdiction_code,1,2)||
                                       '-'||substr(p_jurisdiction_code,13,5));
  		ELSE
    		pay_us_balance_view_pkg.set_context('JURISDICTION_CODE',p_jurisdiction_code);
  		END IF;
	END IF;
	--
    	pay_us_balance_view_pkg.set_context('BUSINESS_GROUP_ID',
                  NVL(p_business_group_id,-1) );

	BEGIN
  		l_balance :=  call_balance_user_exit (
                         	p_balance_name,
                          	p_dimension_suffix,
                          	p_assignment_action_id,
                          	p_assignment_id,
                          	p_virtual_date,
                          	p_asg_type,
                          	p_gre_id,
                          	p_jurisdiction_code);
	EXCEPTION
  	when others then
    	--
		pay_us_balance_view_pkg.debug_err(
						'us_named_balance: call_balance_user_exit raised exception');
		pay_us_balance_view_pkg.debug_err(
						'    RETURNING NULL.');
		return NULL;
	END run_asg_vdate_cursor;
	--
	pay_us_balance_view_pkg.debug_err(
						'us_named_balance: return balance: ' || l_balance);
	return l_balance;
	--
END;

----------------------------------------------------------------------------------------
--
--This function gets the pre-payments assignment_action_id for the run or quick pay
--assignment_action_id. This is used in the payroll register report (PAYRPREG.rdf) when
--reversal exists. Here check is done that for a assignment_action_id any reversal exists.
--
-----------------------------------------------------------------------------------------
FUNCTION get_prepayment_aaid (p_assignment_action_id  number    DEFAULT NULL)
RETURN number is
    cursor prepayment_aaid(param_aaid  number) is
                        select pai.locking_action_id
                        from pay_assignment_actions paa2,
                             pay_payroll_actions ppa2,
                             pay_action_interlocks  pai,
                             pay_assignment_actions paa,
                             pay_payroll_actions ppa
                        where pai.locked_Action_id =  param_aaid
                        and   pai.locking_action_id = pai.locking_action_id
                        and   pai.locking_action_id = paa.assignment_action_id
                        and   paa.payroll_Action_id = ppa.payroll_action_id
                        and   ppa.action_type in ('P','U')
                        and   pai.locked_action_id = paa2.assignment_action_id
                        and   paa2.payroll_Action_id = ppa2.payroll_Action_id
                        and   ppa2.action_type in ('R','Q')
/*
                        and   exists (  select locked_action_id,locking_action_id
                                        from pay_action_interlocks  paie,
                                             pay_assignment_Actions paae,
                                             pay_payroll_Actions ppae
                                        where paie.locked_action_id = pai2.locked_action_id
                                        and  paie.locking_action_id = paae.assignment_action_id
                                        and  paae.payroll_Action_id = ppae.payroll_Action_id
                                        and  ppae.action_type = 'V'  )
*/;
    temp_aaid   number;
begin
    open prepayment_aaid(p_assignment_action_id);
    fetch prepayment_aaid into temp_aaid;
    close prepayment_aaid;
    return(temp_aaid);
end;

--------------------------------------------------------------------------------------
--
--This function adds up the amount of all the assignment_action_ids  if a reversal exists.
--We do not use the payments balance because it fails when a reversal exists. This function
--is used for Earnings and Deductions.We use ASG_GRE_RUN because we want to add the amounts
--for the run not taking into consideration if a reversal exists.
--
--------------------------------------------------------------------------------------
FUNCTION reversal_exists_check(p_balance_name        varchar2,
                          p_assignment_action_id     number    DEFAULT NULL,
                          p_assignment_id            number    DEFAULT NULL,
                          p_gre_id                   number    DEFAULT NULL,
                          p_run_assignment_action_id number    DEFAULT NULL,
                          p_business_group_id        number    DEFAULT NULL)
RETURN number is
    cursor c_run_type_id is
      select prt.run_type_id
        from pay_run_types_f prt
       where prt.shortname = 'SEPCHECK'
         and prt.legislation_code = 'US';

    cursor c_run_action_info
             (cp_assignment_action_id in number) is
      select run_type_id,
             assignment_id
        from pay_assignment_actions paa
       where paa.assignment_action_id = cp_assignment_action_id;

    cursor c_run_actions (cp_pre_pay_action_id     in number,
                          cp_sep_check_run_type_id in number,
                          cp_run_assignment_id     in number) is
        select pai.locked_action_id
          from pay_payroll_actions  ppa,
               pay_assignment_actions paa,
               pay_action_interlocks  pai
         where pai.locking_action_id = cp_pre_pay_action_id
           and pai.locked_action_id = paa.assignment_action_id
           and paa.assignment_id    = cp_run_assignment_id
           and paa.payroll_action_id = ppa.payroll_action_id
           and ppa.action_type in ('R','Q')
           /* The condition below is to take care of Payroll Processes
              which have been run with Umbrella process and before that.
              Run Type Id will be not null in case of umbrella process
              and Source action ID will be not null for Child Actions
           */
           and ((paa.source_action_id is not null and ppa.run_type_id is not null
                 and paa.run_type_id <> cp_sep_check_run_type_id) or
                (paa.source_action_id is null and ppa.run_type_id is null));

    balance_aaid   number := 0;
    temp_aaid   number;

    ln_run_type_id            NUMBER;
    ln_run_action_run_type_id NUMBER;
    ln_run_assignment_id      number;
begin
    open c_run_type_id;
    fetch c_run_type_id into ln_run_type_id;
    close c_run_type_id;

    open c_run_action_info(p_run_assignment_action_id);
    fetch c_run_action_info into
        ln_run_action_run_type_id,
        ln_run_assignment_id;
    close c_run_action_info;

    if ln_run_type_id = ln_run_action_run_type_id then
       balance_aaid :=  us_named_balance(
                             p_balance_name,
                             'ASG_GRE_RUN',
                             p_run_assignment_action_id,
                             null,
                             null,
                             null,
                             p_gre_id,
                             p_business_group_id,
                             null);
    else

       open c_run_actions(p_assignment_action_id,
                          ln_run_type_id,
                          ln_run_assignment_id);
       loop
          fetch c_run_actions into temp_aaid;
          exit when c_run_actions%notfound;
          balance_aaid :=  balance_aaid +
                            us_named_balance(
                                p_balance_name,
                                'ASG_GRE_RUN',
                                temp_aaid,
                                null,
                                null,
                                null,
                                p_gre_id,
                                p_business_group_id,
                                null);
       end loop;
       close c_run_actions;
    end if;
    return(balance_aaid);
end;
-------------------------------------------------------------------------------
--
--This function adds up the amount of all the assignment_action_ids  if a reversal exists.
--We do not use the payments balance because it fails when a reversal exists. This function
--is used for Taxes.We use ASG_GRE_RUN because we want to add the amounts for the run not
--taking into consideration if a reversal exists.
--
------------------------------------------------------------------------------------
FUNCTION reversal_exists_check_tax(p_tax_balance_category   in varchar2,
                                   p_tax_type               in varchar2,
                                   p_ee_or_er               in varchar2,
                                   p_time_type              in varchar2,
                                   p_gre_id_context         in number,
                                   p_jd_context             in varchar2  default  null,
                                   p_assignment_action_id   in number    default  null,
                                   p_assignment_id          in number    default  null,
                                   p_virtual_date           in date      default  null,
                                   p_payroll_action_id      in number,
                                   p_run_assignment_action_id  number    DEFAULT NULL)
RETURN number is

    cursor c_run_type_id is
      select prt.run_type_id
        from pay_run_types_f prt
       where prt.shortname = 'SEPCHECK'
         and prt.legislation_code = 'US';

    cursor c_run_action_info
             (cp_assignment_action_id in number) is
      select run_type_id,
             assignment_id
        from pay_assignment_actions paa
       where paa.assignment_action_id = cp_assignment_action_id;

    cursor c_run_actions (cp_pre_pay_action_id     in number,
                          cp_sep_check_run_type_id in number,
                          cp_run_assignment_id     in number) is
        select pai.locked_action_id
          from pay_payroll_actions  ppa,
               pay_assignment_actions paa,
               pay_action_interlocks  pai
         where pai.locking_action_id = cp_pre_pay_action_id
           and pai.locked_action_id = paa.assignment_action_id
           and paa.assignment_id    = cp_run_assignment_id
           and paa.payroll_action_id = ppa.payroll_action_id
           and ppa.action_type in ('R','Q')
           /* The condition below is to take care of Payroll Processes
              which have been run with Umbrella process and before that.
              Run Type Id will be not null in case of umbrella process
              and Source action ID will be not null for Child Actions
           */
           and ((paa.source_action_id is not null and ppa.run_type_id is not null
                 and paa.run_type_id <> cp_sep_check_run_type_id) or
                (paa.source_action_id is null and ppa.run_type_id is null));

    balance_aaid   number := 0;
    temp_aaid   number;

    ln_run_type_id            NUMBER;
    ln_run_action_run_type_id NUMBER;
    ln_run_assignment_id      number;

begin
    open c_run_type_id;
    fetch c_run_type_id into ln_run_type_id;
    close c_run_type_id;

    open c_run_action_info(p_run_assignment_action_id);
    fetch c_run_action_info into
        ln_run_action_run_type_id,
        ln_run_assignment_id;
    close c_run_action_info;

    if ln_run_type_id = ln_run_action_run_type_id then
       balance_aaid :=  us_tax_balance(p_tax_balance_category,
                                       p_tax_type,
                                       p_ee_or_er,
                                       'RUN',
                                       'ASG',
                                       p_gre_id_context,
                                       p_jd_context,
                                       p_run_assignment_action_id,
                                       p_assignment_id,
                                       p_virtual_date,
                                       NULL );
    else

       open c_run_actions(p_assignment_action_id,
                          ln_run_type_id,
                          ln_run_assignment_id);
       loop
          fetch c_run_actions into temp_aaid;
          exit when c_run_actions%notfound;
              balance_aaid :=  balance_aaid +
                          us_tax_balance(p_tax_balance_category,
                                       p_tax_type,
                                       p_ee_or_er,
                                       'RUN',
                                       'ASG',
                                       p_gre_id_context,
                                       p_jd_context,
                                       temp_aaid,
                                       p_assignment_id,
                                       p_virtual_date,
                                       NULL );
       end loop;
       close c_run_actions;
    end if;

    return(balance_aaid);
end;
-------------------------------------------------------------------------------
--
-- us_named_balance_vm
-- A "view mode" version of us_named_balance with no param for asg_type.
-- Looks in pkg context set by set_view_mode.   Also, if p_dimension_suffix
-- like '%PYDATE%' or '%MONTH%', we check whether bal pkg BOOLEAN flag
-- CalcAllTimeTypes is set to TRUE.  If CalcAllTimeTypes is TRUE, call
-- us_named_balance; but if CalcAllTimeTypes is FALSE, return NULL for
-- PYDATE and MONTH bals.
-- We always call us_named_balance for other dimensions.
--
FUNCTION us_named_balance_vm
                         (p_balance_name          varchar2,
                          p_dimension_suffix      varchar2,
                          p_assignment_action_id  number    ,
                          p_assignment_id         number    ,
                          p_virtual_date          date      ,
                          p_gre_id                number    ,
                          p_business_group_id     number    ,
                          p_jurisdiction_code     varchar2  ,
                          p_classification_name   varchar2 DEFAULT NULL,
                          p_accrued_dimension     varchar2 DEFAULT NULL,
                          p_source_id             number   DEFAULT NULL,
                          p_ele_typ_id            number    DEFAULT NULL)
RETURN number IS

CURSOR C_GET_MASTER_AAID (cp_prepay_action_id in number,
                          cp_assignment_id    in number) is
     select max(paa.assignment_action_id)
     from   pay_assignment_actions paa,  -- assignment_action for master payroll run
            pay_action_interlocks pai
     where  pai.locking_action_id = cp_prepay_action_id
     and    pai.locked_action_id = paa.assignment_action_id
     and    paa.assignment_id    = cp_assignment_id
     and    paa.source_action_id is null -- master assignment_action
     group by assignment_id;

     CURSOR c_get_source_id(cp_asg_act_id number
                           ,cp_ele_typ_id number) is
     select distinct prr.source_id
       from pay_run_results prr
      where prr.assignment_action_id = cp_asg_act_id
        and prr.element_type_id = cp_ele_typ_id;

    l_asg_type         VARCHAR(32);
    l_calc_all         NUMBER;
    l_dimension_suffix VARCHAR2(40);
    l_assignment_action_id NUMBER;
    pp_aaid                NUMBER;
    l_sep_check            VARCHAR2(1) := 'N';
    l_pre_pay_aaid         NUMBER;
    l_assignment_id        NUMBER;
    ln_source_id           NUMBER;
    ln_accrued_bal_val     NUMBER;

BEGIN


       l_dimension_suffix := p_dimension_suffix;
       l_assignment_action_id := p_assignment_action_id;

	--
	-- check time part of dimension, and calc_all_timetype_flag
	--
----------------
        if pay_us_balance_view_pkg.get_session_var('CURRENT') = 'FALSE' and
           p_dimension_suffix like '%CURRENT%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('RUN') = 'FALSE' and
           p_dimension_suffix like '%RUN%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('PYDATE') = 'FALSE' and
           p_dimension_suffix like '%PYDATE%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('PTD') = 'FALSE' and
           p_dimension_suffix like '%PTD%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('MONTH') = 'FALSE' and
           p_dimension_suffix like '%MONTH%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('QTD') = 'FALSE' and
           p_dimension_suffix like '%QTD%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('YTD') = 'FALSE' and
           p_dimension_suffix like '%YTD%' THEN
             return NULL;
        end if;

---------------
	if p_dimension_suffix like ('%MONTH%') OR
			p_dimension_suffix like ('%PYDATE%') then
		l_calc_all := pay_us_balance_view_pkg.get_calc_all_timetypes_flag;
		if l_calc_all = 0 then
			pay_us_balance_view_pkg.debug_msg(
						'us_named_balance_vm: dimension '
						|| p_dimension_suffix
						|| ' disabled, returning NULL');
			return NULL;
		end if;
        -- The 'CURRENT' Dimension is for the current payment method amount.
        -- This is needed for checks, deposit advice, and the payroll register
        elsif   l_dimension_suffix = 'CURRENT' THEN
               if pay_us_taxbal_view_pkg.payments_balance_required(l_assignment_action_id) THEN

                  l_assignment_action_id := p_assignment_action_id;

                  BEGIN

                    SELECT DECODE(prt.shortname,'SEPCHECK','Y','N'),
                           paa.assignment_id
                    INTO   l_sep_check,
                           l_assignment_id
                    FROM   pay_assignment_actions paa
                          ,pay_run_types_f        prt
                    WHERE  paa.assignment_action_id = l_assignment_action_id
                    AND    prt.run_type_id          = paa.run_type_id
                    AND    prt.legislation_code     = 'US';

                  EXCEPTION

                    WHEN NO_DATA_FOUND THEN
                      l_sep_check := 'N';
                  END;

                  IF l_sep_check <> 'Y' THEN

                     select paa.assignment_action_id
                     into   l_pre_pay_aaid
                     from   pay_action_interlocks pai,
                            pay_assignment_actions paa,
                            pay_payroll_actions ppa
                     where  pai.locked_action_id = l_assignment_action_id
                     and    paa.assignment_action_id = pai.locking_action_id
                     and    paa.source_action_id is NULL -- master pre-payment action.
                     and    ppa.payroll_action_id  = paa.payroll_action_id
                     and    ppa.action_type in ('P', 'U');

                      OPEN C_GET_MASTER_AAID (l_pre_pay_aaid,
                                              l_assignment_id);

                      FETCH C_GET_MASTER_AAID
                      INTO  l_assignment_action_id;

                      CLOSE C_GET_MASTER_AAID;

                      l_dimension_suffix := 'ASG_PAYMENTS';
                  else  --  l_sep_check <> 'Y'
                      l_dimension_suffix := 'ASG_GRE_RUN';
                  END IF;
               else    -- payment_balance_required
                    l_dimension_suffix := 'ASG_GRE_RUN';
               end if;  -- payment_balance_required

	end if;   -- dimension suffix
	--
	-- get asg_type/view_mode
	--
	l_asg_type := pay_us_balance_view_pkg.get_view_mode;
	pay_us_balance_view_pkg.debug_msg(
			'us_named_balance_vm called, view_mode: ' || l_asg_type);
	--
	-- if GRE mode, set DATE_EARNED context from p_virutal_date
	-- TODO - verify non-null p_gre_id and p_virtual_date??
	--
	if l_asg_type = 'GRE' then
        	pay_us_balance_view_pkg.set_context('DATE_EARNED',
                                       fnd_date.date_to_canonical(p_virtual_date));
               if (pay_us_balance_view_pkg.get_context('BALANCE_DATE') is NULL)
               then
        	  pay_us_balance_view_pkg.set_context('BALANCE_DATE',
                                           fnd_date.date_to_canonical(p_virtual_date));
               end if;
		pay_us_balance_view_pkg.debug_msg(
        		'us_named_balance_vm GRE mode, set DATE_EARNED context to '
			|| fnd_date.date_to_canonical(p_virtual_date));
	end if;

	--
      -- Additional processing for ' Accrued' balances for 2 Deduction
      -- classifications : 'Voluntary Deductions', 'Involuntary Deductions'
      -- Additional 4 parameters will be passed for ' Accrued' balance
      -- from view pay_us_deductions_report_v, pay_us_deductions_report_rbr_v
      -- dimension suffix : 'ENTRY_ITD'
      -- Additional 4 parameters : p_classification_name, p_accrued_dimension
      --                           p_source_id, p_ele_typ_id
      --
      -- Pre-Tax deduction is not yet changed.
      --

      IF p_classification_name IS NOT NULL
         AND p_accrued_dimension IS NOT NULL THEN

         hr_utility.trace('Within us_named_balance_vm. p_classification_name := ' || p_classification_name);
         hr_utility.trace('p_accrued_dimension := ' || p_accrued_dimension);
         hr_utility.trace('p_source_id := ' || p_source_id);

         IF p_classification_name IN ('Voluntary Deductions', 'Involuntary Deductions')
            AND instr(upper(p_balance_name), ' ACCRUED') <> 0 THEN

               hr_utility.trace('p_assignment_action_id := ' || p_assignment_action_id);
               hr_utility.trace('p_ele_typ_id := ' || p_ele_typ_id);

               IF p_source_id IS NULL THEN

                  OPEN c_get_source_id(cp_asg_act_id => p_assignment_action_id
                                      ,cp_ele_typ_id => p_ele_typ_id);
                  FETCH c_get_source_id INTO ln_source_id;
                  CLOSE c_get_source_id;
                  hr_utility.trace('ln_source_id := ' || ln_source_id);

               END IF;

               l_dimension_suffix := p_accrued_dimension;

               ln_accrued_bal_val := us_entry_itd_balance(p_balance_name => p_balance_name
                                          ,p_dimension_suffix => l_dimension_suffix
                                          ,p_assignment_action_id => l_assignment_action_id
                                          ,p_source_id => NVL(p_source_id, ln_source_id)
                                          ,p_business_group_id => p_business_group_id);

               hr_utility.trace('ln_accrued_bal_val := ' || ln_accrued_bal_val);

               IF NVL(ln_accrued_bal_val,0) = 0 THEN
                  -- ENTRY_ITD dimension is not attached to Accrued balance

            	RETURN us_named_balance(p_balance_name,
                          	l_dimension_suffix,
                          	l_assignment_action_id,
                          	p_assignment_id,
                          	p_virtual_date,
                          	l_asg_type,
                          	p_gre_id,
                          	p_business_group_id,
                          	p_jurisdiction_code);
               ELSE
                  RETURN ln_accrued_bal_val;

               END IF;

         END IF;
      END IF;

	-- now we can finally call the balance!
	--
  	RETURN  us_named_balance(p_balance_name,
                          	l_dimension_suffix,
                          	l_assignment_action_id,
                          	p_assignment_id,
                          	p_virtual_date,
                          	l_asg_type,
                          	p_gre_id,
                          	p_business_group_id,
                          	p_jurisdiction_code);
END;
-------------------------------------------------------------------------------
--
-- us_tax_balance_vm
-- A "view mode" version of us_tax_balance with no param for asg_type.
-- Looks in pkg context set by set_view_mode.   Also, if p_time_type in
-- ('PYDATE', 'MONTH'), we check whether bal pkg BOOLEAN flag "CalcAllTimeTypes"
-- is set to TRUE.  If CalcAllTimeTypes is TRUE, call us_tax_balance; but
-- if CalcAllTimeTypes is FALSE, just return NULL for PYDATE and MONTH.
-- We always call us_tax_balance for other time types.
--
-------------------------------------------------------------------------------
FUNCTION  us_tax_balance_vm (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  ,
                          p_assignment_action_id  in number    ,
                          p_assignment_id         in number    ,
                          p_virtual_date          in date      ,
                          p_payroll_action_id     in number)
RETURN number IS

CURSOR C_GET_MASTER_AAID (cp_prepay_action_id in number,
                          cp_assignment_id    in number) is
     select max(paa.assignment_action_id)
     from   pay_assignment_actions paa,  -- assignment_action for master payroll run
            pay_action_interlocks pai
     where  pai.locking_action_id = cp_prepay_action_id
     and    pai.locked_action_id = paa.assignment_action_id
     and    paa.assignment_id    = cp_assignment_id
     and    paa.source_action_id is null -- master assignment_action
     group by assignment_id;

	l_asg_type VARCHAR(32);
	l_calc_all NUMBER;
    l_time_type VARCHAR2(32);
    l_count_runs NUMBER;
    l_assignment_action_id NUMBER;
    pp_aaid   NUMBER;
    l_sep_check         VARCHAR2(1) := 'N';
    l_pre_pay_aaid          NUMBER;
    l_assignment_id         number;

BEGIN
             l_time_type := p_time_type;
             l_assignment_action_id := p_assignment_action_id;

	--
	-- check time_type, and CalcAllTimeTypes flag
	--
--------------------
        if pay_us_balance_view_pkg.get_session_var('CURRENT') = 'FALSE' and
           p_time_type like '%CURRENT%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('RUN') = 'FALSE' and
           p_time_type like '%RUN%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('PYDATE') = 'FALSE' and
           p_time_type like '%PYDATE%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('PTD') = 'FALSE' and
           p_time_type like '%PTD%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('MONTH') = 'FALSE' and
           p_time_type like '%MONTH%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('QTD') = 'FALSE' and
           p_time_type like '%QTD%' THEN
             return NULL;
        end if;

        if pay_us_balance_view_pkg.get_session_var('YTD') = 'FALSE' and
           p_time_type like '%YTD%' THEN
             return NULL;
        end if;

---------------------
	if p_time_type in ('MONTH', 'PYDATE') then
		l_calc_all := pay_us_balance_view_pkg.get_calc_all_timetypes_flag;
		if l_calc_all = 0 then
			pay_us_balance_view_pkg.debug_msg(
						'us_tax_balance_vm, timetype '
						|| p_time_type
						|| ' disabled, returning NULL');
			return NULL;
		end if;
        -- The 'CURRENT' Dimension is for the current payment method amount.
        -- This is needed for checks, deposit advice, and the payroll register
        elsif   p_time_type = 'CURRENT' THEN
               if pay_us_taxbal_view_pkg.payments_balance_required(l_assignment_action_id) THEN

                  l_assignment_action_id := p_assignment_action_id;

                  BEGIN

                    SELECT DECODE(prt.shortname,'SEPCHECK','Y','N'),
                           paa.assignment_id
                    INTO   l_sep_check,
                           l_assignment_id
                    FROM   pay_assignment_actions paa
                          ,pay_run_types_f        prt
                    WHERE  paa.assignment_action_id = l_assignment_action_id
                    AND    prt.run_type_id          = paa.run_type_id
                    AND    prt.legislation_code     = 'US';

                  EXCEPTION

                    WHEN NO_DATA_FOUND THEN
                      l_sep_check := 'N';
                  END;

                  IF l_sep_check <> 'Y' THEN

                     select paa.assignment_action_id
                     into   l_pre_pay_aaid
                     from   pay_action_interlocks pai,
                            pay_assignment_actions paa,
                            pay_payroll_actions ppa
                     where  pai.locked_action_id = l_assignment_action_id
                     and    paa.assignment_action_id = pai.locking_action_id
                     and    paa.source_action_id is NULL -- master pre-payment action.
                     and    ppa.payroll_action_id  = paa.payroll_action_id
                     and    ppa.action_type in ('P', 'U');

                      OPEN C_GET_MASTER_AAID (l_pre_pay_aaid,
                                              l_assignment_id);

                      FETCH C_GET_MASTER_AAID
                      INTO  l_assignment_action_id;

                      CLOSE C_GET_MASTER_AAID;

                      l_time_type := 'ASG_PAYMENTS';
                  else  --  l_sep_check <> 'Y'
                      l_time_type := 'RUN';
                  END IF;
               else   -- payments_balance_required
                    l_time_type := 'RUN';
               end if;   -- payments_balance_required

	end if;
	--
	-- get asg_type
	--
        l_asg_type := pay_us_balance_view_pkg.get_view_mode;

	pay_us_balance_view_pkg.debug_msg(
				'us_tax_balance_vm called, view_mode: ' || l_asg_type);
	--
	-- if GRE mode, set DATE_EARNED context from p_virutal_date
	-- TODO - verify non-null p_gre_id and p_virtual_date??
	--
	if l_asg_type = 'GRE' then
   	      pay_us_balance_view_pkg.set_context('DATE_EARNED',
                                          fnd_date.date_to_canonical(p_virtual_date));
              if (pay_us_balance_view_pkg.get_context('BALANCE_DATE') is NULL)
              then
                  pay_us_balance_view_pkg.set_context('BALANCE_DATE',
                                           fnd_date.date_to_canonical(p_virtual_date));
              end if;
		pay_us_balance_view_pkg.debug_msg(
			'us_named_balance_vm GRE mode, set DATE_EARNED context to '
			|| fnd_date.date_to_canonical(p_virtual_date));
	end if;
	--
	-- now we can get the balance!
	--
  	RETURN  us_tax_balance (p_tax_balance_category,
                          p_tax_type,
                          p_ee_or_er,
                          l_time_type,
                          l_asg_type,
                          p_gre_id_context,
                          p_jd_context,
                          l_assignment_action_id,
                          p_assignment_id,
                          p_virtual_date,
                          NULL );
END;
-------------------------------------------------------------------------------
--
-- An overloaded version without the payroll_action_id param to prevent calls
-- from forms from breaking
--
-------------------------------------------------------------------------------
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  ,
                          p_assignment_action_id  in number    ,
                          p_assignment_id         in number    ,
                          p_virtual_date          in date      )
RETURN number IS
BEGIN
  RETURN  us_tax_balance (p_tax_balance_category,
                          p_tax_type,
                          p_ee_or_er,
                          p_time_type,
                          p_asg_type,
                          p_gre_id_context,
                          p_jd_context,
                          p_assignment_action_id,
                          p_assignment_id,
                          p_virtual_date,
                          null );
END;

FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  ,
                          p_assignment_action_id  in number    ,
                          p_assignment_id         in number    ,
                          p_virtual_date          in date      ,
                          p_payroll_action_id     in number)
RETURN number IS
--
-- 337641 - cursor rather than ful blown select
--	    doing group function (min)
--
CURSOR get_pay_action_id IS
    select assignment_action_id
    from pay_assignment_actions
    where payroll_action_id = p_payroll_action_id;
--
l_return_value   number;
l_test           number;
l_tax_balance_category  varchar2(30);
l_tax_type       varchar2(15);
l_ee_or_er       varchar2(5);
l_dimension_string  varchar2(80);
l_jd_dimension_string varchar2(80);
l_assignment_id  number;
l_assignment_action_id number;
l_asg_exists     number;
l_max_date       date;
l_bal_start_date date;
l_virtual_date   date;
l_valid          number;
--
BEGIN
--
-- Check that inputs based on lookups are valid
--
pay_us_balance_view_pkg.debug_msg( '===========================================');
pay_us_balance_view_pkg.debug_msg('Enter US_TAX_BALANCE:');
pay_us_balance_view_pkg.debug_msg('  p_tax_balance_category: ' || p_tax_balance_category);
pay_us_balance_view_pkg.debug_msg('  p_tax_type:             ' || p_tax_type);
pay_us_balance_view_pkg.debug_msg('  p_ee_or_er:             ' || p_ee_or_er);
pay_us_balance_view_pkg.debug_msg('  p_time_type:            ' || p_time_type);
pay_us_balance_view_pkg.debug_msg('  p_asg_type:             ' || p_asg_type);
pay_us_balance_view_pkg.debug_msg('  p_gre_id_context:       ' || p_gre_id_context);
pay_us_balance_view_pkg.debug_msg('  p_jd_context:           ' || p_jd_context);
pay_us_balance_view_pkg.debug_msg('  p_assignment_action_id: ' || p_assignment_action_id);
pay_us_balance_view_pkg.debug_msg('  p_assignment_id:        ' || p_assignment_id);
pay_us_balance_view_pkg.debug_msg('  p_virtual_date:         ' || p_virtual_date);
pay_us_balance_view_pkg.debug_msg('  p_payroll_action_id:    ' || p_payroll_action_id);
--
--
SELECT count(0)
INTO   l_valid
FROM   hr_lookups
WHERE  lookup_type = 'US_TAX_BALANCE_CATEGORY'
AND    lookup_code = p_tax_balance_category;
--
IF l_valid = 0 THEN
   pay_us_balance_view_pkg.debug_err('us_tax_balance: Invalid tax bal category:' ||
								p_tax_balance_category);
   local_error('us_tax_balance',1);
END IF;
--
SELECT count(0)
INTO   l_valid
FROM   hr_lookups
WHERE  lookup_type = 'US_TAX_TYPE'
AND    lookup_code = p_tax_type;
--
IF l_valid = 0 THEN
   pay_us_balance_view_pkg.debug_err('us_tax_balance: Invalid tax type: '
										|| p_tax_type);
   local_error('us_tax_balance',2);
END IF;
--
SELECT count(0)
INTO   l_valid
FROM   dual
WHERE  p_asg_type in ('ASG','PER','GRE');
--
IF l_valid = 0 THEN
   pay_us_balance_view_pkg.debug_err('us_tax_balance: Invalid asg_type: '
										|| p_asg_type);
   local_error('us_tax_balance',3);
END IF;
--
SELECT count(0)
INTO   l_valid
FROM   dual
WHERE  p_time_type in ('RUN','PTD','MONTH','QTD','YTD', 'PAYMENTS', 'PYDATE', 'ASG_PAYMENTS');
--
IF l_valid = 0 THEN
   pay_us_balance_view_pkg.debug_err('us_tax_balance:  Invalid time_type: '
										|| p_time_type);
   local_error('us_tax_balance',4);
END IF;
--
-- Set the contexts used in the bal user exit.  Same throughout, so set
-- them up front
--
 --hr_utility.set_location('pay_tax_bals_pkg',30);
--
pay_us_balance_view_pkg.set_context('TAX_UNIT_ID',p_gre_id_context);
IF p_jd_context IS NOT NULL THEN
  IF (p_tax_type = 'SCHOOL' and length(p_jd_context) > 11) THEN
    pay_us_balance_view_pkg.set_context('JURISDICTION_CODE',substr(p_jd_context,1,2)||
                                              '-'||substr(p_jd_context,13,5));
  ELSE
    pay_us_balance_view_pkg.set_context('JURISDICTION_CODE',p_jd_context);
  END IF;
END IF;
--
 --hr_utility.set_location('pay_tax_bals_pkg',40);
--
l_assignment_id := p_assignment_id;
l_assignment_action_id := p_assignment_action_id;
l_tax_type := p_tax_type;
l_tax_balance_category := p_tax_balance_category;
l_virtual_date := p_virtual_date;
--
-- Check if assignment exists at l_virtual_date, if using date mode
--
 --hr_utility.set_location('pay_tax_bals_pkg',50);
--
IF (l_assignment_id is not null and l_virtual_date is not null) THEN
--
  select count(0)
  into   l_asg_exists
  from   per_assignments_f
  where  assignment_id = l_assignment_id
  and    l_virtual_date between effective_start_date and effective_end_date;
--
-- if assignment doesn't exist ...
--
 --hr_utility.set_location('pay_tax_bals_pkg',60);
--
  IF l_asg_exists = 0 THEN
--
--  get the termination date ...
--
    select max(effective_end_date)
    into   l_max_date
    from   per_assignments_f
    where  assignment_id = l_assignment_id;
--
--  get the date of the start of the time period in question
--
 --hr_utility.set_location('pay_tax_bals_pkg',70);
--
    IF p_time_type = 'QTD' THEN
      l_bal_start_date := trunc(l_virtual_date,'Q');
    ELSIF p_time_type = 'MONTH' THEN
      l_bal_start_date := trunc(l_virtual_date,'MM');
    ELSIF p_time_type = 'YTD' THEN
      l_bal_start_date := trunc(l_virtual_date,'Y');
    ELSIF p_time_type = 'PTD' THEN
      select tp.start_date
      into   l_bal_start_date
      from   per_time_periods tp,
             per_assignments_f asg
      where  asg.assignment_id = l_assignment_id
      and    l_max_date between asg.effective_start_date and effective_end_date
      and    asg.payroll_id = tp.payroll_id
      and    l_virtual_date between tp.start_date and tp.end_date;
    END IF;
--
--  set the virtual date to termination date, or return 0 if terminated
--  before the time period.
--
    pay_us_balance_view_pkg.debug_msg('Assignment was terminated on : ' || l_max_date);
    pay_us_balance_view_pkg.debug_msg('Time period in question begins on : ' ||
                      l_bal_start_date);
--
    IF l_max_date < l_bal_start_date THEN
      return 0;
    ELSE
      l_virtual_date := l_max_date;
    END IF;
--
    pay_us_balance_view_pkg.debug_msg('Using new virtual date : ' || l_virtual_date);
--
  END IF;
END IF;
--
-- Convert "WITHHELD" to proper balance categories;
--
 --hr_utility.set_location('pay_tax_bals_pkg',80);
--
IF l_tax_balance_category = 'WITHHELD' THEN
  IF p_ee_or_er = 'ER' or l_tax_type = 'FUTA' THEN
    l_tax_balance_category := 'LIABILITY';
  ELSIF l_tax_type = 'EIC' OR
        l_tax_type = 'STEIC' THEN
    l_tax_balance_category := 'ADVANCE';
  END IF;
END IF;
IF l_tax_balance_category = 'ADVANCED' THEN
    l_tax_balance_category := 'ADVANCE';
END IF;
--
--  Check if illegal tax combo (FIT and TAXABLE, FUTA and SUBJ_NWHABLE, etc.)
--
 --hr_utility.set_location('pay_tax_bals_pkg',90);
--
IF (l_tax_type = 'FIT' or l_tax_type = 'SIT' or l_tax_type = 'COUNTY' or
    l_tax_type = 'CITY' or l_tax_type = 'EIC' or l_tax_type = 'HT' or
    l_tax_type = 'SCHOOL' or l_tax_type = 'STEIC' ) THEN    -- income tax
  IF (l_tax_balance_category = 'TAXABLE' or
      l_tax_balance_category = 'EXCESS')  THEN
     pay_us_balance_view_pkg.debug_err('us_tax_balance: Invalid tax cat for tax type');
     pay_us_balance_view_pkg.debug_err('   cat:  ' || l_tax_balance_category);
     pay_us_balance_view_pkg.debug_err('   type: ' || l_tax_type);
     local_error('us_tax_balance',5);
  END IF;
--
-- return 0 for currently unsupported EIC balances.
--
-- skutteti added 403,457 and PRE_TAX for the pre-tax enhancements.
--   RLNBug 6989549 Need to hit pre-tax enhancements  RLN 05/13/08
--
  IF l_tax_type = 'EIC' and (l_tax_balance_category = 'SUBJ_NWHABLE' --  or
                            --   l_tax_balance_category = '401_REDNS'      or
 --  RLNBug 6989549         --   l_tax_balance_category = '125_REDNS'      or
 --  Need to hit            --   l_tax_balance_category = 'DEP_CARE_REDNS' or
--  pre-tax enhancements    --   l_tax_balance_category = '403_REDNS'      or
                            --   l_tax_balance_category = '457_REDNS'      or
                            --  l_tax_balance_category = 'PRE_TAX_REDNS'
							  ) THEN
    return 0;
  END IF;
ELSE       -- limit tax
  IF l_tax_balance_category = 'SUBJ_NWHABLE' THEN
    return 0;
  END IF;
END IF;
--
 --hr_utility.set_location('pay_tax_bals_pkg',100);
--
l_ee_or_er := ltrim(rtrim(p_ee_or_er));
--
--------------- Some Error Checking -------------
--
--
if (l_tax_type = 'FIT' or l_tax_type = 'SIT' or l_tax_type = 'CITY' or
    l_tax_type = 'COUNTY' or l_tax_type = 'EIC' or l_tax_type = 'SCHOOL' or l_tax_type = 'HT' or l_tax_type = 'WC' or l_tax_type = 'WC2'
    or l_tax_type = 'STEIC' ) THEN
  if l_ee_or_er = 'ER' THEN
     pay_us_balance_view_pkg.debug_err('us_tax_balance:  ER not valid for tax type: '
											|| l_tax_type);
     local_error('us_tax_balance',6);
  else
    l_ee_or_er := NULL;
  end if;
elsif (l_tax_type = 'FUTA') THEN
  if l_ee_or_er = 'EE' THEN
     pay_us_balance_view_pkg.debug_err('us_tax_balance:  EE not valid for tax type: '
											|| l_tax_type);
     local_error('us_tax_balance',7);
  else
    l_ee_or_er := NULL;
  end if;
elsif (l_tax_type = 'SS' or l_tax_type = 'MEDICARE' or l_tax_type = 'SDI' or
       l_tax_type = 'SUI') THEN
  if (l_ee_or_er <> 'EE' and l_ee_or_er <> 'ER') THEN
     pay_us_balance_view_pkg.debug_err('Error:  EE or ER required for tax type: '
										|| l_tax_type);
     local_error('us_tax_balance',8);
  end if;
elsif (l_tax_type = 'SUI1') OR  (l_tax_type = 'SDI1')THEN
  if (l_ee_or_er <> 'EE' ) THEN
     pay_us_balance_view_pkg.debug_err('Error:  EE required for tax type: '
										|| l_tax_type);
     local_error('us_tax_balance',9);
  end if;
end if;

-- As of implementation of the SUI1 EE Tax, we only maintain
-- a WIthheld balance.   As the SUI1 tax type should match
-- balances with SUI We will return the SUI balances.

IF l_tax_type = 'SUI1' and (l_tax_balance_category <> 'WITHHELD'
			    ) THEN
    l_tax_type := 'SUI';

END IF;

IF l_tax_type = 'SDI1' and
         (l_tax_balance_category <> 'WITHHELD' AND
          l_tax_balance_category <> 'TAXABLE'
			    ) THEN
    return 0;
 END IF;
--
 --hr_utility.set_location('pay_tax_bals_pkg',110);
--
-- Force space at end of this parameter if necessary
--
 --hr_utility.set_location('pay_tax_bals_pkg',120);
--
IF l_ee_or_er IS NOT NULL THEN
  l_ee_or_er := rtrim(l_ee_or_er)||' ';
END IF;
--
--  Set up dimension strings
--
IF p_asg_type <> 'GRE' THEN
  pay_us_balance_view_pkg.debug_msg('  p_asg_type is not GRE');
  l_dimension_string := p_asg_type||'_GRE_'||p_time_type;
  l_jd_dimension_string := p_asg_type||'_JD_GRE_'||p_time_type;
ELSE
  pay_us_balance_view_pkg.debug_msg('  p_asg_type is GRE');
--
  l_dimension_string := 'GRE_'||p_time_type;
  l_jd_dimension_string := 'GRE_JD_'||p_time_type;
--
--
--
-- If given payroll action id, get an asg action id from it to use.  Else
-- use the assignment_id and virtual date, since the get balance routine
-- will be called in date mode.
--
--
-- bug # gaz
--
  IF (p_payroll_action_id is not null) THEN
    pay_us_balance_view_pkg.debug_msg('  payroll_action_id is not NULL, getting assignment_action_id from cursor');
    begin
	OPEN  get_pay_action_id;
	FETCH get_pay_action_id INTO l_assignment_action_id;
	CLOSE get_pay_action_id;
    end;
  else
    pay_us_balance_view_pkg.debug_msg('  payroll_action_id is NULL, cannot use it to get assignment_action_id');
    if (p_assignment_action_id is null) then
		 pay_us_balance_view_pkg.debug_msg('  assignment_action_id is NULL, getting dummy for date mode');
       --
       -- Get a dummy assignment id to call the balance user exit in date mode.
       --
        declare
          l_bg_id number;
          l_count number;
          l_found boolean;
          check_asg number;
        begin
          pay_us_balance_view_pkg.set_context('DATE_EARNED',
                                       fnd_date.date_to_canonical(l_virtual_date));
          if (pay_us_balance_view_pkg.get_context('BALANCE_DATE') is NULL)
          then
                  pay_us_balance_view_pkg.set_context('BALANCE_DATE',
                                         fnd_date.date_to_canonical(p_virtual_date));
          end if;

          select business_group_id
          into   l_bg_id
          from   hr_organization_units
          where  organization_id = p_gre_id_context;
          --
          --   Look to see if theres an assignment in the cache for
          --   this business group
          --
          l_count := 0;
          l_found := FALSE;
          while ((l_count < g_nxt_free_asgid) AND (l_found = FALSE)) loop
            if (l_bg_id = g_asgid_tbl_bgid(l_count)) then
              pay_us_balance_view_pkg.debug_msg('  found candidate assignment_action_id in cache');
              --
              --     OK, now check that the assignment is valid as of the
              --     virtual date.
              --
              begin
                select 1
                into check_asg
                from per_assignments_f paf
                where paf.assignment_id = g_asgid_tbl_id(l_count)
                and p_virtual_date between paf.effective_start_date
                                       and paf.effective_end_date;
                --
                l_assignment_id := g_asgid_tbl_id(l_count);
                pay_us_balance_view_pkg.debug_msg('  candidate assignment_action_id '
																|| l_assignment_id
																|| ' is valid as of vdate');
                l_found := TRUE;
                --
              exception
                 when no_data_found then null;
              end;
            end if; ---- (l_bg_id = g_asgid_tbl_bgid(l_count))
            l_count := l_count + 1;
          end loop;
          --
          if (l_found = FALSE) then
            --
            --  OK, need to get an assignment from the database.
            --
            pay_us_balance_view_pkg.debug_msg('  assignment_action_id not found in cache, going to DB');
            begin  /* Modified the query for performance (Bug 3343982)*/

              select min(paa.assignment_id)
              into l_assignment_id
              from  pay_assignment_actions paa,
                    pay_payroll_actions pact,
                    pay_payrolls_f ppf
              where pact.effective_date <= p_virtual_date
                and pact.payroll_action_id=paa.payroll_action_id
                and pact.action_type in ('R', 'Q', 'I', 'V', 'B')
                and paa.tax_unit_id = p_gre_id_context
                and ppf.payroll_id = pact.payroll_id
                and ppf.business_group_id = l_bg_id;

              --
              -- Place the defined balance in cache.
              --
              g_asgid_tbl_bgid(g_nxt_free_asgid) := ltrim(rtrim(l_bg_id));
              g_asgid_tbl_id  (g_nxt_free_asgid) :=
                                             ltrim(rtrim(l_assignment_id));
              g_nxt_free_asgid := g_nxt_free_asgid + 1;
              --
            exception when no_data_found then
              begin
                pay_us_balance_view_pkg.debug_err('us_tax_balance: Failed find asg id');
                local_error('us_tax_balance',1);
                --
              end;
            end;
          end if; ---- (l_found = FALSE)
       end;
    end if; ---- (p_assignment_action_id is null)
  END IF; ---- (p_payroll_action_id is not null)
END IF;
--
--  3-12-2003 added ASG_PAYMENTS
--
IF p_time_type in ('PAYMENTS', 'ASG_PAYMENTS') THEN
--
-- 360669 put PAYMENTS_JD back
--
  l_jd_dimension_string := p_time_type||'_JD';
  l_dimension_string := p_time_type;
--
END IF;
--
--
--  Check if the tax is federal or not.
--
SELECT count(0)
INTO   l_test
FROM   sys.dual
WHERE  l_tax_type in ('FIT','FUTA','MEDICARE','SS','EIC');
--
IF l_test <> 0 THEN   -- yes, the tax is federal
--
  IF l_tax_balance_category = 'GROSS' THEN
    l_return_value := call_balance_user_exit ('GROSS_EARNINGS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
--
  ELSIF l_tax_balance_category = 'SUBJ_WHABLE' THEN
    l_return_value := call_balance_user_exit ('REGULAR_EARNINGS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context)
                   + call_balance_user_exit (
                                   'SUPPLEMENTAL_EARNINGS_FOR_'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
--
  ELSIF l_tax_balance_category = 'SUBJ_NWHABLE' THEN
    l_return_value := call_balance_user_exit (
                                'SUPPLEMENTAL_EARNINGS_FOR_NW'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
--
  ELSIF l_tax_balance_category = '401_REDNS' THEN
  l_return_value :=   call_balance_user_exit ('DEF_COMP_401K',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
                    - call_balance_user_exit ('DEF_COMP_401K_FOR_'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

         --
         -- added by tmehra in Dec 2001, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                           ('FIT_NON_W2_DEF_COMP_401',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

        END IF;

	END IF;
--
  ELSIF l_tax_balance_category = '125_REDNS' THEN
    l_return_value := call_balance_user_exit ('SECTION_125',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
                    - call_balance_user_exit ('SECTION_125_FOR_'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

         --
         -- added by tmehra in Dec 2001, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                           ('FIT_NON_W2_SECTION_125',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

        END IF;

	END IF;
--
  ELSIF l_tax_balance_category = 'DEP_CARE_REDNS' THEN
    l_return_value := call_balance_user_exit ('DEPENDENT_CARE',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
               - call_balance_user_exit ('DEPENDENT_CARE_FOR_'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

         --
         -- added by tmehra in Dec 2001, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                           ('FIT_NON_W2_DEPENDENT_CARE',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
        END IF;

	END IF;
  /***************************************************************************
  ** 403b, 457 and Pre_Tax added by skutteti for the pre-tax enhancements, as
  ** new categories has been added and all the deduction categories feed the
  ** generic pretax.
  ****************************************************************************/
  ELSIF l_tax_balance_category = '403_REDNS' THEN
    l_return_value := call_balance_user_exit ('DEF_COMP_403B',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value - call_balance_user_exit (
                                             'DEF_COMP_403B_FOR_'||l_tax_type,
                                             'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

         --
         -- added by tmehra in Dec 2001, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                           ('FIT_NON_W2_DEF_COMP_403',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
        END IF;


	END IF;
      --
  ELSIF l_tax_balance_category = '457_REDNS' THEN
    l_return_value := call_balance_user_exit ('DEF_COMP_457',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value - call_balance_user_exit (
                                             'DEF_COMP_457_FOR_'||l_tax_type,
                                             'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

         --
         -- added by tmehra in Dec 2001, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                           ('FIT_NON_W2_DEF_COMP_457',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

        END IF;

	END IF;
      --
  ELSIF l_tax_balance_category = 'PRE_TAX_REDNS' THEN
    l_return_value := call_balance_user_exit ('PRE_TAX_DEDUCTIONS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value - call_balance_user_exit (
                                             'PRE_TAX_DEDUCTIONS_FOR_'||l_tax_type,
                                             'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

         --
         -- added by tmehra in Dec 2001, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                           ('FIT_NON_W2_PRE_TAX_DEDNS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);

        END IF;


      --
	END IF;
      --
  ELSIF l_tax_balance_category = 'TAXABLE' THEN
    l_return_value := call_balance_user_exit (l_tax_type||'_'||
                                              l_ee_or_er||'TAXABLE',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context);
--
  ELSIF (l_tax_balance_category = 'WITHHELD' or
         l_tax_balance_category = 'LIABILITY' or
         l_tax_balance_category = 'ADVANCE') THEN
    l_return_value := call_balance_user_exit (
                           l_tax_type||'_'||l_ee_or_er||l_tax_balance_category,
                                           l_dimension_string,
                                           l_assignment_action_id,
                                           l_assignment_id,
                                           l_virtual_date,
                                           p_asg_type,
                                           p_gre_id_context,
                                           p_jd_context);
  END IF;
ELSE   -- the tax is non-federal
--
-- if the tax balance is not derived, get it here.
  IF (l_tax_balance_category <> 'SUBJECT' and
      l_tax_balance_category <> 'EXEMPT' and
      l_tax_balance_category <> 'EXCESS' and
      l_tax_balance_category <> 'REDUCED_SUBJ_WHABLE') THEN
--
-- Use the CITY balances for HT if we don't want to see LIABILITY
--
    IF (l_tax_type = 'HT') THEN
      IF (l_tax_balance_category <> 'WITHHELD') THEN
        l_tax_type := 'CITY';
      ELSE
        l_tax_type := 'HEAD TAX';
      END IF;
    END IF;
--
--  Added for workers comp
    If (l_tax_type = 'WC' ) THEN
      l_tax_type := 'WORKERS COMP';
    END IF;
    If (l_tax_type =  'WC2') THEN
      l_tax_type := 'WORKERS COMP2';
    END IF;
    --
    l_return_value := call_balance_user_exit (
                    l_tax_type||'_'||l_ee_or_er||l_tax_balance_category,
                                           l_jd_dimension_string,
                                           l_assignment_action_id,
                                           l_assignment_id,
                                           l_virtual_date,
                                           p_asg_type,
                                           p_gre_id_context,
                                           p_jd_context);
  END IF;
END IF;
--  Some Reports Require Reporting of W2 Wages instead of
--  subject.  Properly this should be done with an additional
--  balance type
IF l_tax_balance_category = 'SUBJECT' and
   NVL(pay_us_balance_view_pkg.get_session_var('REPORT_TYPE'),'NOT_DEFINED') <> 'W2' THEN
	pay_us_balance_view_pkg.debug_msg('US_TAX_BALANCE summing SUBJ_WHABLE and SUBJ_NWHABLE');
  l_return_value := us_tax_balance('SUBJ_WHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date)
                 + us_tax_balance('SUBJ_NWHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date);

--
-- Note: Below is equivalent to reduced subject withholdable.
--
ELSIF l_tax_balance_category = 'SUBJECT' and NVL(pay_us_balance_view_pkg.get_session_var('REPORT_TYPE'),'NOT_DEFINED') = 'W2' THEN

	pay_us_balance_view_pkg.debug_msg('US_TAX_BALANCE summing SUBJ_WHABLE and SUBJ_NWHABLE FOR W2');
  l_return_value := us_tax_balance('SUBJ_WHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date)
                 + us_tax_balance('SUBJ_NWHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date)
             /**************************************************************
              * Replaced the following(401K, 125 and Dependent care) with
              * the Pre_tax Redns as all the above three feeds into this
              * along with the new ones like 403B and 457
              **************************************************************/
              --   - us_tax_balance('401_REDNS',
              --                    l_tax_type,
              --                    p_ee_or_er,
              --                    p_time_type,
              --                    p_asg_type,
              --                    p_gre_id_context,
              --                    p_jd_context,
              --                    l_assignment_action_id,
              --                    l_assignment_id,
              --                    l_virtual_date)
              --   - us_tax_balance('125_REDNS',
              --                    l_tax_type,
              --                    p_ee_or_er,
              --                    p_time_type,
              --                    p_asg_type,
              --                    p_gre_id_context,
              --                    p_jd_context,
              --                    l_assignment_action_id,
              --                    l_assignment_id,
              --                    l_virtual_date)
              --   - us_tax_balance('DEP_CARE_REDNS',
              --                    l_tax_type,
              --                    p_ee_or_er,
              --                    p_time_type,
              --                    p_asg_type,
              --                    p_gre_id_context,
              --                    p_jd_context,
              --                    l_assignment_action_id,
              --                    l_assignment_id,
              --                    l_virtual_date);
              /************************************************
              **    Added the Pre_tax Redns instead
              ************************************************/
                 - us_tax_balance('PRE_TAX_REDNS',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date);
--
ELSIF l_tax_balance_category = 'EXEMPT' THEN
  l_return_value := us_tax_balance('GROSS',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
                 - us_tax_balance('SUBJECT',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date);
	END IF;
--
ELSIF l_tax_balance_category = 'REDUCED_SUBJ_WHABLE' THEN
  l_return_value := us_tax_balance('SUBJ_WHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
               /**********************************************************
                *  Skutteti commented the following and replaced it by
                *  Pre_tax redns as all the three along with the
                *  new categories (403B and 457) feeds the Pre Tax Redns
                **********************************************************
                -- - us_tax_balance('401_REDNS',
                --                  l_tax_type,
                --                  p_ee_or_er,
                --                  p_time_type,
                --                  p_asg_type,
                --                  p_gre_id_context,
                --                  p_jd_context,
                --                  l_assignment_action_id,
                --                  l_assignment_id,
                --                  l_virtual_date)
                -- - us_tax_balance('125_REDNS',
                --                  l_tax_type,
                --                  p_ee_or_er,
                --                  p_time_type,
                --                  p_asg_type,
                --                  p_gre_id_context,
                --                  p_jd_context,
                --                  l_assignment_action_id,
                --                  l_assignment_id,
                --                  l_virtual_date)
                -- - us_tax_balance('DEP_CARE_REDNS',
                --                  l_tax_type,
                --                  p_ee_or_er,
                --                  p_time_type,
                --                  p_asg_type,
                --                  p_gre_id_context,
                --                  p_jd_context,
                --                  l_assignment_action_id,
                --                  l_assignment_id,
                --                  l_virtual_date);
                 /*************************************************
                 *  replaced by PRE_TAX_REDNS below
                 **************************************************/
                 - us_tax_balance('PRE_TAX_REDNS',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date);
	END IF;
--
ELSIF l_tax_balance_category = 'EXCESS' THEN
  l_return_value := us_tax_balance('REDUCED_SUBJ_WHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
                 - us_tax_balance('TAXABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date);
	END IF;
END IF;
--
pay_us_balance_view_pkg.debug_msg('US_TAX_BALANCE Returning : ' || l_return_value);
--
return l_return_value;
--
END us_tax_balance;
--
---------------------------------------------------------------------------------------
-- PROCEDURE us_gp_multiple_gre_ytd
--
-- Description: This procedure is passed up to ten balances (using balance name).
--              It calculates the GRE_YTD dimension figure of the balance(s) at
--              GROUP LEVEL only, as at the effective date (also passed in).
--              The route code for GRE_YTD is copied from the correspoding
--              row in FF_ROUTES, plus the PAY_BALANCE_TYPES table is added
--              so that balance names can be used to match on balance feeds
--              for this balance. This method of multiple-decode select means
--              that selecting 10 balances takes the same amount of time as selecting
--              a single balance in the previous implementation.
--
--              Written primarily for GRE Totals report, but can be used by other
--              processes due to the slightly more generic interface. The normal
--              balance retrieval mechanism bypassed as assignment-level route
--              (and latest balances) always used which is not performant for
--              this purpose.
--
-- Maintenance: The cursor should be dual maintained with the row for GRE_YTD in
--              FF_ROUTES.
---------------------------------------------------------------------------------------
procedure us_gp_multiple_gre_ytd (p_tax_unit_id    IN  NUMBER,
                                  p_effective_date IN  DATE,
                                  p_balance_name1  IN  VARCHAR2 ,
                                  p_balance_name2  IN  VARCHAR2 ,
                                  p_balance_name3  IN  VARCHAR2 ,
                                  p_balance_name4  IN  VARCHAR2 ,
                                  p_balance_name5  IN  VARCHAR2 ,
                                  p_balance_name6  IN  VARCHAR2 ,
                                  p_balance_name7  IN  VARCHAR2 ,
                                  p_balance_name8  IN  VARCHAR2 ,
                                  p_balance_name9  IN  VARCHAR2 ,
                                  p_balance_name10 IN  VARCHAR2 ,
                                  p_value1         OUT NOCOPY NUMBER,
                                  p_value2         OUT NOCOPY NUMBER,
                                  p_value3         OUT NOCOPY NUMBER,
                                  p_value4         OUT NOCOPY NUMBER,
                                  p_value5         OUT NOCOPY NUMBER,
                                  p_value6         OUT NOCOPY NUMBER,
                                  p_value7         OUT NOCOPY NUMBER,
                                  p_value8         OUT NOCOPY NUMBER,
                                  p_value9         OUT NOCOPY NUMBER,
                                  p_value10        OUT NOCOPY NUMBER)
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
l_balance_type_id6 number;
l_balance_type_id7 number;
l_balance_type_id8 number;
l_balance_type_id9 number;
l_balance_type_id10 number;

cursor get_values (c_balance_type_id1 in number,
                   c_balance_type_id2 in number,
                   c_balance_type_id3 in number,
                   c_balance_type_id4 in number,
                   c_balance_type_id5 in number,
                   c_balance_type_id6 in number,
                   c_balance_type_id7 in number,
                   c_balance_type_id8 in number,
                   c_balance_type_id9 in number,
                   c_balance_type_id10 in number) is
SELECT /* Removed RULE hint. Bug 3331031 */
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id6,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id7,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id8,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id9,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id10,TARGET.result_value * FEED.scale,0)),0)
             FROM    pay_balance_feeds_f     FEED
              ,      pay_run_result_values   TARGET
              ,      pay_run_results         RR
              ,      pay_assignment_actions  ASSACT
              ,      pay_payroll_actions     PACT
            where    PACT.effective_date between trunc(p_effective_date,'Y')
                                            and p_effective_date
              and    PACT.action_type           in ('R','Q','I','B','V')
/*
              and    PACT.action_status =  'C'
*/
              and    ASSACT.payroll_action_id   = PACT.payroll_action_id
              and    ASSACT.action_status = 'C'
              and    ASSACT.tax_unit_id = p_tax_unit_id
              and    RR.assignment_action_id = ASSACT.assignment_action_id
              and    RR.status                  in ('P','PA')
              and    TARGET.run_result_id       = RR.run_result_id
              and    nvl(TARGET.result_value,'0') <> '0'
              and    FEED.input_value_id        = TARGET.input_value_id
              and    FEED.balance_type_id in (c_balance_type_id1,c_balance_type_id2,
                                              c_balance_type_id3,c_balance_type_id4,
                                              c_balance_type_id5,c_balance_type_id6,
                                              c_balance_type_id7,c_balance_type_id8,
                                              c_balance_type_id9,c_balance_type_id10)
              and    PACT.effective_date        between FEED.effective_start_date
                                                    and FEED.effective_end_date;
--
BEGIN -- us_multiple_gre_ytd
--
-- Get Multiple balance type values for this dimension
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
   l_balance_type_id6 := get_balance_type(p_balance_name6);
   l_balance_type_id7 := get_balance_type(p_balance_name7);
   l_balance_type_id8 := get_balance_type(p_balance_name8);
   l_balance_type_id9 := get_balance_type(p_balance_name9);
   l_balance_type_id10:= get_balance_type(p_balance_name10);

  open get_values (l_balance_type_id1,
                   l_balance_type_id2,
                   l_balance_type_id3,
                   l_balance_type_id4,
                   l_balance_type_id5,
                   l_balance_type_id6,
                   l_balance_type_id7,
                   l_balance_type_id8,
                   l_balance_type_id9,
                   l_balance_type_id10);

  fetch get_values into p_value1 ,
                        p_value2 ,
                        p_value3 ,
                        p_value4 ,
                        p_value5 ,
                        p_value6 ,
                        p_value7 ,
                        p_value8 ,
                        p_value9 ,
                        p_value10;
  close get_values;
--
END us_gp_multiple_gre_ytd;
--
---------------------------------------------------------------------------------------
-- PROCEDURE us_gp_multiple_gre_qtd
--
-- Description: This procedure is passed up to ten balances (using balance name).
--              It calculates the GRE_QTD dimension figure of the balance(s) at
--              GROUP LEVEL only, as at the effective date (also passed in).
--              The route code for GRE_QTD is copied from the correspoding
--              row in FF_ROUTES, plus the PAY_BALANCE_TYPES table is added
--              so that balance names can be used to match on balance feeds
--              for this balance. This method of multiple-decode select means
--              that selecting 10 balances takes the same amount of time as selecting
--              a single balance in the previous implementation.
--
--              Written primarily for GRE Totals report, but can be used by other
--              processes due to the slightly more generic interface. The normal
--              balance retrieval mechanism bypassed as assignment-level route
--              (and latest balances) always used which is not performant for
--              this purpose.
--
-- Maintenance: The cursor should be dual maintained with the row for GRE_YTD in
--              FF_ROUTES.
---------------------------------------------------------------------------------------
procedure us_gp_multiple_gre_qtd (p_tax_unit_id    IN  NUMBER,
                                  p_effective_date IN  DATE,
                                  p_balance_name1  IN  VARCHAR2 ,
                                  p_balance_name2  IN  VARCHAR2 ,
                                  p_balance_name3  IN  VARCHAR2 ,
                                  p_balance_name4  IN  VARCHAR2 ,
                                  p_balance_name5  IN  VARCHAR2 ,
                                  p_balance_name6  IN  VARCHAR2 ,
                                  p_balance_name7  IN  VARCHAR2 ,
                                  p_balance_name8  IN  VARCHAR2 ,
                                  p_balance_name9  IN  VARCHAR2 ,
                                  p_balance_name10 IN  VARCHAR2 ,
                                  p_value1         OUT NOCOPY NUMBER,
                                  p_value2         OUT NOCOPY NUMBER,
                                  p_value3         OUT NOCOPY NUMBER,
                                  p_value4         OUT NOCOPY NUMBER,
                                  p_value5         OUT NOCOPY NUMBER,
                                  p_value6         OUT NOCOPY NUMBER,
                                  p_value7         OUT NOCOPY NUMBER,
                                  p_value8         OUT NOCOPY NUMBER,
                                  p_value9         OUT NOCOPY NUMBER,
                                  p_value10        OUT NOCOPY NUMBER)
IS
 l_dummy NUMBER;
BEGIN
          us_gp_multiple_gre_qtd (p_tax_unit_id    => p_tax_unit_id
                                 ,p_effective_date => p_effective_date
                                 ,p_balance_name1  => p_balance_name1
                                 ,p_balance_name2  => p_balance_name2
                                 ,p_balance_name3  => p_balance_name3
                                 ,p_balance_name4  => p_balance_name4
                                 ,p_balance_name5  => p_balance_name5
                                 ,p_balance_name6  => p_balance_name6
                                 ,p_balance_name7  => p_balance_name7
                                 ,p_balance_name8  => p_balance_name8
                                 ,p_balance_name9  => p_balance_name9
                                 ,p_balance_name10 => p_balance_name10
                                 ,p_balance_name11 => null
                                 ,p_balance_name12 => null
                                 ,p_value1         => p_value1
                                 ,p_value2         => p_value2
                                 ,p_value3         => p_value3
                                 ,p_value4         => p_value4
                                 ,p_value5         => p_value5
                                 ,p_value6         => p_value6
                                 ,p_value7         => p_value7
                                 ,p_value8         => p_value8
                                 ,p_value9         => p_value9
                                 ,p_value10        => p_value10
                                 ,p_value11        => l_dummy
                                 ,p_value12        => l_dummy);

END us_gp_multiple_gre_qtd;

procedure us_gp_multiple_gre_qtd (p_tax_unit_id    IN  NUMBER,
                                  p_effective_date IN  DATE,
                                  p_balance_name1  IN  VARCHAR2 ,
                                  p_balance_name2  IN  VARCHAR2 ,
                                  p_balance_name3  IN  VARCHAR2 ,
                                  p_balance_name4  IN  VARCHAR2 ,
                                  p_balance_name5  IN  VARCHAR2 ,
                                  p_balance_name6  IN  VARCHAR2 ,
                                  p_balance_name7  IN  VARCHAR2 ,
                                  p_balance_name8  IN  VARCHAR2 ,
                                  p_balance_name9  IN  VARCHAR2 ,
                                  p_balance_name10 IN  VARCHAR2 ,
                                  p_balance_name11 IN  VARCHAR2 ,
                                  p_balance_name12 IN  VARCHAR2 ,
                                  p_value1         OUT NOCOPY NUMBER,
                                  p_value2         OUT NOCOPY NUMBER,
                                  p_value3         OUT NOCOPY NUMBER,
                                  p_value4         OUT NOCOPY NUMBER,
                                  p_value5         OUT NOCOPY NUMBER,
                                  p_value6         OUT NOCOPY NUMBER,
                                  p_value7         OUT NOCOPY NUMBER,
                                  p_value8         OUT NOCOPY NUMBER,
                                  p_value9         OUT NOCOPY NUMBER,
                                  p_value10        OUT NOCOPY NUMBER,
                                  p_value11        OUT NOCOPY NUMBER,
                                  p_value12        OUT NOCOPY NUMBER)
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
l_balance_type_id6 number;
l_balance_type_id7 number;
l_balance_type_id8 number;
l_balance_type_id9 number;
l_balance_type_id10 number;
l_balance_type_id11 number;
l_balance_type_id12 number;

cursor get_values (c_balance_type_id1 in number,
                   c_balance_type_id2 in number,
                   c_balance_type_id3 in number,
                   c_balance_type_id4 in number,
                   c_balance_type_id5 in number,
                   c_balance_type_id6 in number,
                   c_balance_type_id7 in number,
                   c_balance_type_id8 in number,
                   c_balance_type_id9 in number,
                   c_balance_type_id10 in number,
                   c_balance_type_id11 in number,
                   c_balance_type_id12 in number) is
SELECT /* Removed RULE hint. Bug 3331031 */
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id6,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id7,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id8,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id9,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id10,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id11,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id12,TARGET.result_value * FEED.scale,0)),0)
             FROM    pay_balance_feeds_f     FEED
              ,      pay_run_result_values   TARGET
              ,      pay_run_results         RR
              ,      pay_assignment_actions  ASSACT
              ,      pay_payroll_actions     PACT
            where    PACT.effective_date between trunc(p_effective_date,'Q')
                                            and p_effective_date
              and    PACT.action_type           in ('R','Q','I','B','V')
/*
              and    PACT.action_status =  'C'
*/
              and    ASSACT.payroll_action_id   = PACT.payroll_action_id
              and    ASSACT.action_status = 'C'
              and    ASSACT.tax_unit_id = p_tax_unit_id
              and    RR.assignment_action_id = ASSACT.assignment_action_id
              and    RR.status                  in ('P','PA')
              and    TARGET.run_result_id       = RR.run_result_id
              and    nvl(TARGET.result_value,'0') <> '0'
              and    FEED.input_value_id        = TARGET.input_value_id
              and    FEED.balance_type_id    in (c_balance_type_id1,c_balance_type_id2,
                                              c_balance_type_id3,c_balance_type_id4,
                                              c_balance_type_id5,c_balance_type_id6,
                                              c_balance_type_id7,c_balance_type_id8,
                                              c_balance_type_id9,c_balance_type_id10,
                                              c_balance_type_id11, c_balance_type_id12)
              and    PACT.effective_date        between FEED.effective_start_date
                                                    and FEED.effective_end_date;
--
BEGIN -- us_multiple_gre_qtd
--
-- Get Multiple balance type values for this dimension
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
   l_balance_type_id6 := get_balance_type(p_balance_name6);
   l_balance_type_id7 := get_balance_type(p_balance_name7);
   l_balance_type_id8 := get_balance_type(p_balance_name8);
   l_balance_type_id9 := get_balance_type(p_balance_name9);
   l_balance_type_id10:= get_balance_type(p_balance_name10);
   l_balance_type_id11:= get_balance_type(p_balance_name11);
   l_balance_type_id12:= get_balance_type(p_balance_name12);
  open get_values (l_balance_type_id1,
                   l_balance_type_id2,
                   l_balance_type_id3,
                   l_balance_type_id4,
                   l_balance_type_id5,
                   l_balance_type_id6,
                   l_balance_type_id7,
                   l_balance_type_id8,
                   l_balance_type_id9,
                   l_balance_type_id10,
                   l_balance_type_id11,
                   l_balance_type_id12);

  fetch get_values into p_value1 ,
                        p_value2 ,
                        p_value3 ,
                        p_value4 ,
                        p_value5 ,
                        p_value6 ,
                        p_value7 ,
                        p_value8 ,
                        p_value9 ,
                        p_value10,
                        p_value11,
                        p_value12;
  close get_values;
--
END us_gp_multiple_gre_qtd;
--
----------------------------------------------------------------------------------
-- PROCEDURE us_gp_subject_to_tax_gre_ytd
--
-- Description: This procedure returns values for given balance name using
--              the route code for SUBJECT_TO_TAX_GRE_YTD. This is written
--              primarily for The GRE Totals report, in order that group level
--              (By Tax Unit ID) balances are always returned as were found to
--              be much more performant than assignment-level (inc latest balances)
--
-- Maintenance: This procedure must be maintained along with the row in FF_ROUTES for
--              The dimension SUBJECT_TO_TAX_GRE_YTD.
----------------------------------------------------------------------------------
--
--
PROCEDURE us_gp_subject_to_tax_gre_ytd (p_balance_name1   IN VARCHAR2 ,
                                        p_balance_name2   IN     VARCHAR2 ,
                                        p_balance_name3   IN     VARCHAR2 ,
                                        p_balance_name4   IN     VARCHAR2 ,
                                        p_balance_name5   IN     VARCHAR2 ,
                                        p_effective_date  IN DATE,
                                        p_tax_unit_id     IN NUMBER,
                                        p_value1          OUT NOCOPY NUMBER,
                                        p_value2          OUT NOCOPY NUMBER,
                                        p_value3          OUT NOCOPY NUMBER,
                                        p_value4          OUT NOCOPY NUMBER,
                                        p_value5          OUT NOCOPY NUMBER)
--
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
--
   cursor get_value (c_balance_type_id1 in number,
                     c_balance_type_id2 in number,
                     c_balance_type_id3 in number,
                     c_balance_type_id4 in number,
                     c_balance_type_id5 in number,
                     c_effective_date in date,
                     c_tax_unit_id in number)
     IS
   SELECT /* Removed RULE hint. Bug 3331031 */
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0)
     FROM
            pay_balance_feeds_f     FEED
      ,     pay_run_result_values   TARGET
      ,     pay_run_results         RR
      ,     pay_assignment_actions  ASSACT
      ,     pay_payroll_actions     PACT
   where    PACT.effective_date between trunc(c_effective_date,'Y')
                                    and c_effective_date
     and    PACT.action_type in ('R','Q','I','B','V')
/*
     and    PACT.action_status = 'C'
*/
     and    ASSACT.payroll_action_id = PACT.payroll_action_id
     and    ASSACT.tax_unit_id = c_tax_unit_id /* Subject to Tax */
     and    ASSACT.action_status = 'C'
     and    RR.assignment_action_id = ASSACT.assignment_action_id
     and    RR.status in ('P','PA')
     and    TARGET.run_result_id    = RR.run_result_id
     and    FEED.input_value_id     = TARGET.input_value_id
     and    nvl(TARGET.result_value,'0') <> '0'
     and    FEED.balance_type_id in (c_balance_type_id1,c_balance_type_id2,
                                     c_balance_type_id3,c_balance_type_id4,
                                     c_balance_type_id5)
     and    PACT.effective_date between FEED.effective_start_date
                                    and FEED.effective_end_date
     and    EXISTS ( select 'x'
                       from pay_taxability_rules    TR,
                            pay_element_types_f     ET
                      where ET.element_type_id       = RR.element_type_id
                        and PACT.date_earned between ET.effective_start_date
                                                 and ET.effective_end_date
                        and    TR.classification_id  = ET.classification_id + 0
                        and    TR.tax_category       = ET.element_information1
                        and    TR.tax_type           = (select bt.tax_type from pay_balance_types bt
                                                         where bt.balance_type_id = FEED.balance_type_id)
                        and    TR.jurisdiction_code     = '00-000-0000'||decode(RR.run_result_id,null,', ')
                        and    nvl(TR.status,'X')               <>'D'); -- Bug 3251672


--
BEGIN
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
--
      open get_value(l_balance_type_id1,l_balance_type_id2,
                     l_balance_type_id3,l_balance_type_id4,
                     l_balance_type_id5,p_effective_date,
                     p_tax_unit_id);
      fetch get_value into p_value1,p_value2,p_value3,p_value4,p_value5;
      close get_value;
--
END us_gp_subject_to_tax_gre_ytd;
--
--
----------------------------------------------------------------------------------
-- PROCEDURE us_gp_subject_to_tax_gre_qtd
--
-- Description: This procedure returns values for given balance name using
--              the route code for SUBJECT_TO_TAX_GRE_QTD. This is written
--              primarily for The GRE Totals report, in order that group level
--              (By Tax Unit ID) balances are always returned as were found to
--              be much more performant than assignment-level (inc latest balances)
--
-- Maintenance: This procedure must be maintained along with the row in FF_ROUTES for
--              The dimension SUBJECT_TO_TAX_GRE_QTD.
----------------------------------------------------------------------------------
--

PROCEDURE us_gp_subject_to_tax_gre_qtd (p_balance_name1   IN VARCHAR2 ,
                                        p_balance_name2   IN     VARCHAR2 ,
                                        p_balance_name3   IN     VARCHAR2 ,
                                        p_balance_name4   IN     VARCHAR2 ,
                                        p_balance_name5   IN     VARCHAR2 ,
                                        p_effective_date  IN DATE,
                                        p_tax_unit_id     IN NUMBER,
                                        p_value1          OUT NOCOPY NUMBER,
                                        p_value2          OUT NOCOPY NUMBER,
                                        p_value3          OUT NOCOPY NUMBER,
                                        p_value4          OUT NOCOPY NUMBER,
                                        p_value5          OUT NOCOPY NUMBER)
--
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
--
   cursor get_value (c_balance_type_id1 in number,
                     c_balance_type_id2 in number,
                     c_balance_type_id3 in number,
                     c_balance_type_id4 in number,
                     c_balance_type_id5 in number,
                     c_effective_date in date,
                     c_tax_unit_id in number)
     IS
   SELECT /* Removed RULE hint. Bug 3331031 */
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0)
     FROM
            pay_balance_feeds_f     FEED
      ,     pay_run_result_values   TARGET
      ,     pay_run_results         RR
      ,     pay_assignment_actions  ASSACT
      ,     pay_payroll_actions     PACT
   where    PACT.effective_date between trunc(c_effective_date,'Q')
                                    and c_effective_date
     and    PACT.action_type in ('R','Q','I','B','V')
/*
     and    PACT.action_status = 'C'
*/
     and    ASSACT.payroll_action_id = PACT.payroll_action_id
     and    ASSACT.tax_unit_id = c_tax_unit_id /* Subject to Tax */
     and    ASSACT.action_status = 'C'
     and    RR.assignment_action_id = ASSACT.assignment_action_id
     and    RR.status in ('P','PA')
     and    TARGET.run_result_id    = RR.run_result_id
     and    FEED.input_value_id     = TARGET.input_value_id
     and    nvl(TARGET.result_value,'0') <> '0'
     and    FEED.balance_type_id in (c_balance_type_id1,c_balance_type_id2,
                                     c_balance_type_id3,c_balance_type_id4,
                                     c_balance_type_id5)
     and    PACT.effective_date between FEED.effective_start_date
                                    and FEED.effective_end_date
     and    EXISTS ( select 'x'
                       from pay_taxability_rules    TR,
                            pay_element_types_f     ET
                      where ET.element_type_id       = RR.element_type_id
                        and PACT.date_earned between ET.effective_start_date
                                                 and ET.effective_end_date
                        and    TR.classification_id  = ET.classification_id + 0
                        and    TR.tax_category       = ET.element_information1
                        and    TR.tax_type           = (select bt.tax_type from pay_balance_types bt
                                                         where bt.balance_type_id = FEED.balance_type_id)
                        and    TR.jurisdiction_code     = '00-000-0000'||decode(RR.run_result_id,null,', ')
                        and    nvl(TR.status,'X')               <>'D');  -- Bug 3251672

--
BEGIN
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
--
      open get_value(l_balance_type_id1,l_balance_type_id2,
                     l_balance_type_id3,l_balance_type_id4,
                     l_balance_type_id5,p_effective_date,
                     p_tax_unit_id);
      fetch get_value into p_value1,p_value2,p_value3,p_value4,p_value5;
      close get_value;
--
END us_gp_subject_to_tax_gre_qtd;

-----------------------------------------------------------------------------------------
-- PROCEDURE us_gp_gre_jd_ytd
--
-- DESCRIPTION: This procedure performs a multiple balance-type decode fetch
--              from the GRE_JD_YTD route, which is used for State-Level balance
--              reporting. It can return up to 7 balance values. This was coded
--              originally for performance fixing to the GRE Totals Report.
--
-- Maintenance: This should be dual-maintained with the row in FF_ROUTES for
--              GRE_JD_YTD dimension, although note slight changes to main where
--              clause to allow for multiple-decoding.
--
-----------------------------------------------------------------------------------------
PROCEDURE us_gp_gre_jd_ytd (p_balance_name1   IN     VARCHAR2 ,
                            p_balance_name2   IN     VARCHAR2 ,
                            p_balance_name3   IN     VARCHAR2 ,
                            p_balance_name4   IN     VARCHAR2 ,
                            p_balance_name5   IN     VARCHAR2 ,
                            p_balance_name6   IN     VARCHAR2 ,
                            p_balance_name7   IN     VARCHAR2 ,
                            p_effective_date  IN     DATE,
                            p_tax_unit_id     IN     NUMBER,
                            p_state_code      IN     VARCHAR2,
                            p_value1             OUT NOCOPY NUMBER,
                            p_value2             OUT NOCOPY NUMBER,
                            p_value3             OUT NOCOPY NUMBER,
                            p_value4             OUT NOCOPY NUMBER,
                            p_value5             OUT NOCOPY NUMBER,
                            p_value6             OUT NOCOPY NUMBER,
                            p_value7             OUT NOCOPY NUMBER)
--
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
l_balance_type_id6 number;
l_balance_type_id7 number;
--
cursor get_state_level_value (c_balance_type_id1 in number,
                              c_balance_type_id2 in number,
                              c_balance_type_id3 in number,
                              c_balance_type_id4 in number,
                              c_balance_type_id5 in number,
                              c_balance_type_id6 in number,
                              c_balance_type_id7 in number,
                              c_effective_date in date,
                              c_tax_unit_id in number,
                              c_state_code in varchar2)
is
SELECT /* Removed RULE hint. Bug 3331031 */
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id6,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id7,TARGET.result_value * FEED.scale,0)),0)
FROM
       pay_balance_feeds_f     FEED
,      pay_run_result_values   TARGET
,      pay_run_results         RR
,      pay_assignment_actions  ASSACT
,      pay_payroll_actions     PACT
,      (select distinct puar.assignment_id assignment_id
        from pay_us_asg_reporting puar
        where puar.tax_unit_id = c_tax_unit_id
        and puar.jurisdiction_code like substr(c_state_code,1,2)||'%') ASGRPT
--
where  PACT.effective_date between  trunc(c_effective_date,'Y')
                               and   c_effective_date
and    PACT.action_type in ('R','Q','I','B','V')
/*
and    PACT.action_status = 'C'
*/
and    FEED.balance_type_id in ( c_balance_type_id1 ,  c_balance_type_id2 ,
                                 c_balance_type_id3 ,  c_balance_type_id4 ,
                                 c_balance_type_id5 ,  c_balance_type_id6 ,
                                 c_balance_type_id7 )
and    PACT.effective_date between FEED.effective_start_date
                               and FEED.effective_end_date
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    ASSACT.assignment_id = ASGRPT.assignment_id
and    ASSACT.tax_unit_id = c_tax_unit_id
and    ASSACT.action_status = 'C'
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    RR.status in ('P','PA')
and    RR.jurisdiction_code like substr ( c_state_code, 1, 2)||'%'
and    TARGET.run_result_id    = RR.run_result_id
and    FEED.input_value_id     = TARGET.input_value_id
and    nvl(TARGET.result_value,'0') <> '0';
--
BEGIN --us_gp_gre_jd_ytd
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
   l_balance_type_id6 := get_balance_type(p_balance_name6);
   l_balance_type_id7 := get_balance_type(p_balance_name7);

   --
   open get_state_level_value(l_balance_type_id1,l_balance_type_id2,
                              l_balance_type_id3,l_balance_type_id4,
                              l_balance_type_id5,l_balance_type_id6,
                              l_balance_type_id7,p_effective_date, p_tax_unit_id, p_state_code);
   fetch get_state_level_value into p_value1,p_value2,p_value3,p_value4,p_value5,p_value6,p_value7;
   close get_state_level_value;
   --
--
END us_gp_gre_jd_ytd;
-----------------------------------------------------------------------------------------
-- PROCEDURE us_gp_gre_jd_qtd
--
-- DESCRIPTION: This procedure performs a multiple balance-type decode fetch
--              from the GRE_JD_QTD route, which is used for State-Level balance
--              reporting. It can return up to 7 balance values. This was coded
--              originally for performance fixing to the GRE Totals Report.
--
-- Maintenance: This should be dual-maintained with the row in FF_ROUTES for
--              GRE_JD_QTD dimension, although note slight changes to main where
--              clause to allow for multiple-decoding.
--
-----------------------------------------------------------------------------------------
PROCEDURE us_gp_gre_jd_qtd (p_balance_name1   IN     VARCHAR2 ,
                            p_balance_name2   IN     VARCHAR2 ,
                            p_balance_name3   IN     VARCHAR2 ,
                            p_balance_name4   IN     VARCHAR2 ,
                            p_balance_name5   IN     VARCHAR2 ,
                            p_balance_name6   IN     VARCHAR2 ,
                            p_balance_name7   IN     VARCHAR2 ,
                            p_effective_date  IN     DATE,
                            p_tax_unit_id     IN     NUMBER,
                            p_state_code      IN     VARCHAR2,
                            p_value1             OUT NOCOPY NUMBER,
                            p_value2             OUT NOCOPY NUMBER,
                            p_value3             OUT NOCOPY NUMBER,
                            p_value4             OUT NOCOPY NUMBER,
                            p_value5             OUT NOCOPY NUMBER,
                            p_value6             OUT NOCOPY NUMBER,
                            p_value7             OUT NOCOPY NUMBER)
--
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
l_balance_type_id6 number;
l_balance_type_id7 number;
--
cursor get_state_level_value (c_balance_type_id1 in number,
                              c_balance_type_id2 in number,
                              c_balance_type_id3 in number,
                              c_balance_type_id4 in number,
                              c_balance_type_id5 in number,
                              c_balance_type_id6 in number,
                              c_balance_type_id7 in number,
                              c_effective_date in date,
                              c_tax_unit_id in number,
                              c_state_code in varchar2)
is
SELECT /* Removed RULE hint. Bug 3331031 */
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id6,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id7,TARGET.result_value * FEED.scale,0)),0)
FROM
       pay_balance_feeds_f     FEED
,      pay_run_result_values   TARGET
,      pay_run_results         RR
,      pay_assignment_actions  ASSACT
,      pay_payroll_actions     PACT
,      (select distinct puar.assignment_id assignment_id
        from pay_us_asg_reporting puar
        where puar.tax_unit_id = c_tax_unit_id
        and puar.jurisdiction_code like substr(c_state_code,1,2)||'%') ASGRPT
--
where  PACT.effective_date between trunc(c_effective_date,'Q')
                               and   c_effective_date
and    PACT.action_type in ('R','Q','I','B','V')
/*
and    PACT.action_status = 'C'
*/
and    FEED.balance_type_id in ( c_balance_type_id1 ,  c_balance_type_id2 ,
                                 c_balance_type_id3 ,  c_balance_type_id4 ,
                                 c_balance_type_id5 ,  c_balance_type_id6 ,
                                 c_balance_type_id7 )
and    PACT.effective_date between FEED.effective_start_date
                               and FEED.effective_end_date
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    ASSACT.assignment_id = ASGRPT.assignment_id
and    ASSACT.tax_unit_id = c_tax_unit_id
and    ASSACT.action_status = 'C'
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    RR.status in ('P','PA')
and    RR.jurisdiction_code like substr ( c_state_code, 1, 2)||'%'
and    TARGET.run_result_id    = RR.run_result_id
and    FEED.input_value_id     = TARGET.input_value_id
and    nvl(TARGET.result_value,'0') <> '0';
--
BEGIN --us_gp_gre_jd_qtd
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
   l_balance_type_id6 := get_balance_type(p_balance_name6);
   l_balance_type_id7 := get_balance_type(p_balance_name7);

   --
   open get_state_level_value(l_balance_type_id1,l_balance_type_id2,
                              l_balance_type_id3,l_balance_type_id4,
                              l_balance_type_id5,l_balance_type_id6,
                              l_balance_type_id7,p_effective_date, p_tax_unit_id, p_state_code);
   fetch get_state_level_value into p_value1,p_value2,p_value3,p_value4,p_value5,p_value6,p_value7;
   close get_state_level_value;
   --
--
END us_gp_gre_jd_qtd;
--
---------------------------------------------------------------------------------------
-- PROCEDURE us_gp_multiple_gre_mtd
--
-- Description: This procedure is passed up to ten balances (using balance name).
--              It calculates the GRE_MTD dimension figure of the balance(s) at
--              GROUP LEVEL only, as at the effective date (also passed in).
--              The route code for GRE_MTD is copied from the correspoding
--              row in FF_ROUTES, plus the PAY_BALANCE_TYPES table is added
--              so that balance names can be used to match on balance feeds
--              for this balance. This method of multiple-decode select means
--              that selecting 10 balances takes the same amount of time as selecting
--              a single balance in the previous implementation.
--
--              Written primarily for GRE Totals report, but can be used by other
--              processes due to the slightly more generic interface. The normal
--              balance retrieval mechanism bypassed as assignment-level route
--              (and latest balances) always used which is not performant for
--              this purpose.
--
-- Maintenance: The cursor should be dual maintained with the row for GRE_MTD in
--              FF_ROUTES.
---------------------------------------------------------------------------------------
procedure us_gp_multiple_gre_mtd (p_tax_unit_id    IN  NUMBER,
                                  p_effective_date IN  DATE,
                                  p_balance_name1  IN  VARCHAR2 ,
                                  p_balance_name2  IN  VARCHAR2 ,
                                  p_balance_name3  IN  VARCHAR2 ,
                                  p_balance_name4  IN  VARCHAR2 ,
                                  p_balance_name5  IN  VARCHAR2 ,
                                  p_balance_name6  IN  VARCHAR2 ,
                                  p_balance_name7  IN  VARCHAR2 ,
                                  p_balance_name8  IN  VARCHAR2 ,
                                  p_balance_name9  IN  VARCHAR2 ,
                                  p_balance_name10 IN  VARCHAR2 ,
                                  p_value1         OUT NOCOPY NUMBER,
                                  p_value2         OUT NOCOPY NUMBER,
                                  p_value3         OUT NOCOPY NUMBER,
                                  p_value4         OUT NOCOPY NUMBER,
                                  p_value5         OUT NOCOPY NUMBER,
                                  p_value6         OUT NOCOPY NUMBER,
                                  p_value7         OUT NOCOPY NUMBER,
                                  p_value8         OUT NOCOPY NUMBER,
                                  p_value9         OUT NOCOPY NUMBER,
                                  p_value10        OUT NOCOPY NUMBER)
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
l_balance_type_id6 number;
l_balance_type_id7 number;
l_balance_type_id8 number;
l_balance_type_id9 number;
l_balance_type_id10 number;

cursor get_values (c_balance_type_id1 in number,
                   c_balance_type_id2 in number,
                   c_balance_type_id3 in number,
                   c_balance_type_id4 in number,
                   c_balance_type_id5 in number,
                   c_balance_type_id6 in number,
                   c_balance_type_id7 in number,
                   c_balance_type_id8 in number,
                   c_balance_type_id9 in number,
                   c_balance_type_id10 in number) is
SELECT /* Removed RULE hint. Bug 3331031 */
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id6,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id7,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id8,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id9,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id10,TARGET.result_value * FEED.scale,0)),0)
             FROM    pay_balance_feeds_f     FEED
              ,      pay_run_result_values   TARGET
              ,      pay_run_results         RR
              ,      pay_assignment_actions  ASSACT
              ,      pay_payroll_actions     PACT
            where    PACT.effective_date between trunc(p_effective_date,'MON')
                                            and p_effective_date
              and    PACT.action_type           in ('R','Q','I','B','V')
/*
              and    PACT.action_status =  'C'
*/
              and    ASSACT.payroll_action_id   = PACT.payroll_action_id
              and    ASSACT.action_status = 'C'
              and    ASSACT.tax_unit_id = p_tax_unit_id
              and    RR.assignment_action_id = ASSACT.assignment_action_id
              and    RR.status                  in ('P','PA')
              and    TARGET.run_result_id       = RR.run_result_id
              and    nvl(TARGET.result_value,'0') <> '0'
              and    FEED.input_value_id        = TARGET.input_value_id
              and    FEED.balance_type_id in (c_balance_type_id1,c_balance_type_id2,
                                              c_balance_type_id3,c_balance_type_id4,
                                              c_balance_type_id5,c_balance_type_id6,
                                              c_balance_type_id7,c_balance_type_id8,
                                              c_balance_type_id9,c_balance_type_id10)
              and    PACT.effective_date        between FEED.effective_start_date
                                                    and FEED.effective_end_date;
--
BEGIN -- us_multiple_gre_mtd
--
-- Get Multiple balance type values for this dimension
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
   l_balance_type_id6 := get_balance_type(p_balance_name6);
   l_balance_type_id7 := get_balance_type(p_balance_name7);
   l_balance_type_id8 := get_balance_type(p_balance_name8);
   l_balance_type_id9 := get_balance_type(p_balance_name9);
   l_balance_type_id10:= get_balance_type(p_balance_name10);

  open get_values (l_balance_type_id1,
                   l_balance_type_id2,
                   l_balance_type_id3,
                   l_balance_type_id4,
                   l_balance_type_id5,
                   l_balance_type_id6,
                   l_balance_type_id7,
                   l_balance_type_id8,
                   l_balance_type_id9,
                   l_balance_type_id10);

  fetch get_values into p_value1 ,
                        p_value2 ,
                        p_value3 ,
                        p_value4 ,
                        p_value5 ,
                        p_value6 ,
                        p_value7 ,
                        p_value8 ,
                        p_value9 ,
                        p_value10;
  close get_values;
--
END us_gp_multiple_gre_mtd;
--
---------------------------------------------------------------------------------------
-- PROCEDURE us_gp_multiple_gre_ctd
--
-- Description: This procedure is passed up to ten balances (using balance name).
--              It calculates the GRE_CTD dimension figure of the balance(s) at
--              GROUP LEVEL only, as at the effective date (also passed in).
--              The route code for GRE_CTD is copied from the correspoding
--              row in FF_ROUTES, plus the PAY_BALANCE_TYPES table is added
--              so that balance names can be used to match on balance feeds
--              for this balance. This method of multiple-decode select means
--              that selecting 10 balances takes the same amount of time as selecting
--              a single balance in the previous implementation.
--
--              Written primarily for GRE Totals report, but can be used by other
--              processes due to the slightly more generic interface. The normal
--              balance retrieval mechanism bypassed as assignment-level route
--              (and latest balances) always used which is not performant for
--              this purpose.
--
-- Maintenance: The cursor should be dual maintained with the row for GRE_CTD in
--              FF_ROUTES.
---------------------------------------------------------------------------------------
procedure us_gp_multiple_gre_ctd (p_tax_unit_id    IN  NUMBER,
                                  p_start_date     IN  DATE,
                                  p_effective_date IN  DATE,
                                  p_balance_name1  IN  VARCHAR2 ,
                                  p_balance_name2  IN  VARCHAR2 ,
                                  p_balance_name3  IN  VARCHAR2 ,
                                  p_balance_name4  IN  VARCHAR2 ,
                                  p_balance_name5  IN  VARCHAR2 ,
                                  p_balance_name6  IN  VARCHAR2 ,
                                  p_balance_name7  IN  VARCHAR2 ,
                                  p_balance_name8  IN  VARCHAR2 ,
                                  p_balance_name9  IN  VARCHAR2 ,
                                  p_balance_name10 IN  VARCHAR2 ,
                                  p_value1         OUT NOCOPY NUMBER,
                                  p_value2         OUT NOCOPY NUMBER,
                                  p_value3         OUT NOCOPY NUMBER,
                                  p_value4         OUT NOCOPY NUMBER,
                                  p_value5         OUT NOCOPY NUMBER,
                                  p_value6         OUT NOCOPY NUMBER,
                                  p_value7         OUT NOCOPY NUMBER,
                                  p_value8         OUT NOCOPY NUMBER,
                                  p_value9         OUT NOCOPY NUMBER,
                                  p_value10        OUT NOCOPY NUMBER)
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
l_balance_type_id6 number;
l_balance_type_id7 number;
l_balance_type_id8 number;
l_balance_type_id9 number;
l_balance_type_id10 number;

cursor get_values (c_balance_type_id1 in number,
                   c_balance_type_id2 in number,
                   c_balance_type_id3 in number,
                   c_balance_type_id4 in number,
                   c_balance_type_id5 in number,
                   c_balance_type_id6 in number,
                   c_balance_type_id7 in number,
                   c_balance_type_id8 in number,
                   c_balance_type_id9 in number,
                   c_balance_type_id10 in number) is
SELECT /* Removed RULE hint. Bug 3331031 */
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0) ,
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id6,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id7,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id8,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id9,TARGET.result_value * FEED.scale,0)),0),
nvl(sum(decode(FEED.balance_type_id,c_balance_type_id10,TARGET.result_value * FEED.scale,0)),0)
             FROM    pay_balance_feeds_f     FEED
              ,      pay_run_result_values   TARGET
              ,      pay_run_results         RR
              ,      pay_assignment_actions  ASSACT
              ,      pay_payroll_actions     PACT
            where    PACT.effective_date between p_start_date
                                            and p_effective_date
              and    PACT.action_type           in ('R','Q','I','B','V')
/*
              and    PACT.action_status =  'C'
*/
              and    ASSACT.payroll_action_id   = PACT.payroll_action_id
              and    ASSACT.action_status = 'C'
              and    ASSACT.tax_unit_id = p_tax_unit_id
              and    RR.assignment_action_id = ASSACT.assignment_action_id
              and    RR.status                  in ('P','PA')
              and    TARGET.run_result_id       = RR.run_result_id
              and    nvl(TARGET.result_value,'0') <> '0'
              and    FEED.input_value_id        = TARGET.input_value_id
              and    FEED.balance_type_id in (c_balance_type_id1,c_balance_type_id2,
                                              c_balance_type_id3,c_balance_type_id4,
                                              c_balance_type_id5,c_balance_type_id6,
                                              c_balance_type_id7,c_balance_type_id8,
                                              c_balance_type_id9,c_balance_type_id10)
              and    PACT.effective_date        between FEED.effective_start_date
                                                    and FEED.effective_end_date;
--
BEGIN -- us_multiple_gre_ctd
--
-- Get Multiple balance type values for this dimension
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
   l_balance_type_id6 := get_balance_type(p_balance_name6);
   l_balance_type_id7 := get_balance_type(p_balance_name7);
   l_balance_type_id8 := get_balance_type(p_balance_name8);
   l_balance_type_id9 := get_balance_type(p_balance_name9);
   l_balance_type_id10:= get_balance_type(p_balance_name10);

  open get_values (l_balance_type_id1,
                   l_balance_type_id2,
                   l_balance_type_id3,
                   l_balance_type_id4,
                   l_balance_type_id5,
                   l_balance_type_id6,
                   l_balance_type_id7,
                   l_balance_type_id8,
                   l_balance_type_id9,
                   l_balance_type_id10);

  fetch get_values into p_value1 ,
                        p_value2 ,
                        p_value3 ,
                        p_value4 ,
                        p_value5 ,
                        p_value6 ,
                        p_value7 ,
                        p_value8 ,
                        p_value9 ,
                        p_value10;
  close get_values;
--
END us_gp_multiple_gre_ctd;
--
----------------------------------------------------------------------------------
-- PROCEDURE us_gp_subject_to_tax_gre_mtd
--
-- Description: This procedure returns values for given balance name using
--              the route code for SUBJECT_TO_TAX_GRE_MTD. This is written
--              primarily for The GRE Totals report, in order that group level
--              (By Tax Unit ID) balances are always returned as were found to
--              be much more performant than assignment-level (inc latest balances)
--
-- Maintenance: This procedure must be maintained along with the row in FF_ROUTES for
--              The dimension SUBJECT_TO_TAX_GRE_MTD.
----------------------------------------------------------------------------------
--

PROCEDURE us_gp_subject_to_tax_gre_mtd (p_balance_name1   IN VARCHAR2 ,
                                        p_balance_name2   IN     VARCHAR2 ,
                                        p_balance_name3   IN     VARCHAR2 ,
                                        p_balance_name4   IN     VARCHAR2 ,
                                        p_balance_name5   IN     VARCHAR2 ,
                                        p_effective_date  IN DATE,
                                        p_tax_unit_id     IN NUMBER,
                                        p_value1          OUT NOCOPY NUMBER,
                                        p_value2          OUT NOCOPY NUMBER,
                                        p_value3          OUT NOCOPY NUMBER,
                                        p_value4          OUT NOCOPY NUMBER,
                                        p_value5          OUT NOCOPY NUMBER)
--
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
--
   cursor get_value (c_balance_type_id1 in number,
                     c_balance_type_id2 in number,
                     c_balance_type_id3 in number,
                     c_balance_type_id4 in number,
                     c_balance_type_id5 in number,
                     c_effective_date in date,
                     c_tax_unit_id in number)
     IS
   SELECT /* Removed RULE hint. Bug 3331031 */
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0)
     FROM
            pay_balance_feeds_f     FEED
      ,     pay_run_result_values   TARGET
      ,     pay_run_results         RR
      ,     pay_assignment_actions  ASSACT
      ,     pay_payroll_actions     PACT
   where    PACT.effective_date between trunc(c_effective_date,'MON')
                                    and c_effective_date
     and    PACT.action_type in ('R','Q','I','B','V')
/*
     and    PACT.action_status = 'C'
*/
     and    ASSACT.payroll_action_id = PACT.payroll_action_id
     and    ASSACT.tax_unit_id = c_tax_unit_id /* Subject to Tax */
     and    ASSACT.action_status = 'C'
     and    RR.assignment_action_id = ASSACT.assignment_action_id
     and    RR.status in ('P','PA')
     and    TARGET.run_result_id    = RR.run_result_id
     and    FEED.input_value_id     = TARGET.input_value_id
     and    nvl(TARGET.result_value,'0') <> '0'
     and    FEED.balance_type_id in (c_balance_type_id1,c_balance_type_id2,
                                     c_balance_type_id3,c_balance_type_id4,
                                     c_balance_type_id5)
     and    PACT.effective_date between FEED.effective_start_date
                                    and FEED.effective_end_date
     and    EXISTS ( select 'x'
                       from pay_taxability_rules    TR,
                            pay_element_types_f     ET
                      where ET.element_type_id       = RR.element_type_id
                        and PACT.date_earned between ET.effective_start_date
                                                 and ET.effective_end_date
                        and    TR.classification_id  = ET.classification_id + 0
                        and    TR.tax_category       = ET.element_information1
                        and    TR.tax_type           = (select bt.tax_type from pay_balance_types bt
                                                         where bt.balance_type_id = FEED.balance_type_id)
                        and    TR.jurisdiction_code     = '00-000-0000'||decode(RR.run_result_id,null,', ')
                        and    nvl(TR.status,'X')                <>'D') ;  -- Bug 3251672


--
BEGIN
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
--
      open get_value(l_balance_type_id1,l_balance_type_id2,
                     l_balance_type_id3,l_balance_type_id4,
                     l_balance_type_id5,p_effective_date,
                     p_tax_unit_id);
      fetch get_value into p_value1,p_value2,p_value3,p_value4,p_value5;
      close get_value;
--
END us_gp_subject_to_tax_gre_mtd;
--
----------------------------------------------------------------------------------
-- PROCEDURE us_gp_subject_to_tax_gre_ctd
--
-- Description: This procedure returns values for given balance name using
--              the route code for SUBJECT_TO_TAX_GRE_CTD. This is written
--              primarily for The GRE Totals report, in order that group level
--              (By Tax Unit ID) balances are always returned as were found to
--              be much more performant than assignment-level (inc latest balances)
--
-- Maintenance: This procedure must be maintained along with the row in FF_ROUTES for
--              The dimension SUBJECT_TO_TAX_GRE_CTD.
----------------------------------------------------------------------------------
--

PROCEDURE us_gp_subject_to_tax_gre_ctd (p_balance_name1   IN VARCHAR2 ,
                                        p_balance_name2   IN     VARCHAR2 ,
                                        p_balance_name3   IN     VARCHAR2 ,
                                        p_balance_name4   IN     VARCHAR2 ,
                                        p_balance_name5   IN     VARCHAR2 ,
                                        p_start_date      IN DATE,
                                        p_effective_date  IN DATE,
                                        p_tax_unit_id     IN NUMBER,
                                        p_value1          OUT NOCOPY NUMBER,
                                        p_value2          OUT NOCOPY NUMBER,
                                        p_value3          OUT NOCOPY NUMBER,
                                        p_value4          OUT NOCOPY NUMBER,
                                        p_value5          OUT NOCOPY NUMBER)
--
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
--
   cursor get_value (c_balance_type_id1 in number,
                     c_balance_type_id2 in number,
                     c_balance_type_id3 in number,
                     c_balance_type_id4 in number,
                     c_balance_type_id5 in number,
                     c_start_date     in date,
                     c_effective_date in date,
                     c_tax_unit_id in number)
     IS
   SELECT /* Removed RULE hint. Bug 3331031 */
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0),
        nvl(sum(decode(feed.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0)
     FROM
            pay_balance_feeds_f     FEED
      ,     pay_run_result_values   TARGET
      ,     pay_run_results         RR
      ,     pay_assignment_actions  ASSACT
      ,     pay_payroll_actions     PACT
   where    PACT.effective_date between c_start_date
                                    and c_effective_date
     and    PACT.action_type in ('R','Q','I','B','V')
/*
     and    PACT.action_status = 'C'
*/
     and    ASSACT.payroll_action_id = PACT.payroll_action_id
     and    ASSACT.tax_unit_id = c_tax_unit_id /* Subject to Tax */
     and    ASSACT.action_status = 'C'
     and    RR.assignment_action_id = ASSACT.assignment_action_id
     and    RR.status in ('P','PA')
     and    TARGET.run_result_id    = RR.run_result_id
     and    FEED.input_value_id     = TARGET.input_value_id
     and    nvl(TARGET.result_value,'0') <> '0'
     and    FEED.balance_type_id in (c_balance_type_id1,c_balance_type_id2,
                                     c_balance_type_id3,c_balance_type_id4,
                                     c_balance_type_id5)
     and    PACT.effective_date between FEED.effective_start_date
                                    and FEED.effective_end_date
     and    EXISTS ( select 'x'
                       from pay_taxability_rules    TR,
                            pay_element_types_f     ET
                      where ET.element_type_id       = RR.element_type_id
                        and PACT.date_earned between ET.effective_start_date
                                                 and ET.effective_end_date
                        and    TR.classification_id  = ET.classification_id + 0
                        and    TR.tax_category       = ET.element_information1
                        and    TR.tax_type           = (select bt.tax_type from pay_balance_types bt
                                                         where bt.balance_type_id = FEED.balance_type_id)
                        and    TR.jurisdiction_code     = '00-000-0000'||decode(RR.run_result_id,null,', ')
                        and    nvl(TR.status,'X')                <>'D') ;  -- Bug 3251672


--
BEGIN
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
--
      open get_value(l_balance_type_id1,l_balance_type_id2,
                     l_balance_type_id3,l_balance_type_id4,
                     l_balance_type_id5,p_start_date,
                     p_effective_date,p_tax_unit_id);
      fetch get_value into p_value1,p_value2,p_value3,p_value4,p_value5;
      close get_value;
--
END us_gp_subject_to_tax_gre_ctd;
--
-----------------------------------------------------------------------------------------
-- PROCEDURE us_gp_gre_jd_mtd
--
-- DESCRIPTION: This procedure performs a multiple balance-type decode fetch
--              from the GRE_JD_QTD route, which is used for State-Level balance
--              reporting. It can return up to 7 balance values. This was coded
--              originally for performance fixing to the GRE Totals Report.
--
-- Maintenance: This should be dual-maintained with the row in FF_ROUTES for
--              GRE_JD_MTD dimension, although note slight changes to main where
--              clause to allow for multiple-decoding.
--
-----------------------------------------------------------------------------------------
PROCEDURE us_gp_gre_jd_mtd (p_balance_name1   IN     VARCHAR2 ,
                            p_balance_name2   IN     VARCHAR2 ,
                            p_balance_name3   IN     VARCHAR2 ,
                            p_balance_name4   IN     VARCHAR2 ,
                            p_balance_name5   IN     VARCHAR2 ,
                            p_balance_name6   IN     VARCHAR2 ,
                            p_balance_name7   IN     VARCHAR2 ,
                            p_effective_date  IN     DATE,
                            p_tax_unit_id     IN     NUMBER,
                            p_state_code      IN     VARCHAR2,
                            p_value1             OUT NOCOPY NUMBER,
                            p_value2             OUT NOCOPY NUMBER,
                            p_value3             OUT NOCOPY NUMBER,
                            p_value4             OUT NOCOPY NUMBER,
                            p_value5             OUT NOCOPY NUMBER,
                            p_value6             OUT NOCOPY NUMBER,
                            p_value7             OUT NOCOPY NUMBER)
--
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
l_balance_type_id6 number;
l_balance_type_id7 number;
--
cursor get_state_level_value (c_balance_type_id1 in number,
                              c_balance_type_id2 in number,
                              c_balance_type_id3 in number,
                              c_balance_type_id4 in number,
                              c_balance_type_id5 in number,
                              c_balance_type_id6 in number,
                              c_balance_type_id7 in number,
                              c_effective_date in date,
                              c_tax_unit_id in number,
                              c_state_code in varchar2)
is
SELECT /* Removed RULE hint. Bug 3331031 */
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id6,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id7,TARGET.result_value * FEED.scale,0)),0)
FROM
       pay_balance_feeds_f     FEED
,      pay_run_result_values   TARGET
,      pay_run_results         RR
,      pay_assignment_actions  ASSACT
,      pay_payroll_actions     PACT
,      (select distinct puar.assignment_id assignment_id
        from pay_us_asg_reporting puar
        where puar.tax_unit_id = c_tax_unit_id
        and puar.jurisdiction_code like substr(c_state_code,1,2)||'%') ASGRPT
--
where  PACT.effective_date between trunc(c_effective_date,'MON')
                               and   c_effective_date
and    PACT.action_type in ('R','Q','I','B','V')
/*
and    PACT.action_status = 'C'
*/
and    FEED.balance_type_id in ( c_balance_type_id1 ,  c_balance_type_id2 ,
                                 c_balance_type_id3 ,  c_balance_type_id4 ,
                                 c_balance_type_id5 ,  c_balance_type_id6 ,
                                 c_balance_type_id7 )
and    PACT.effective_date between FEED.effective_start_date
                               and FEED.effective_end_date
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    ASSACT.assignment_id = ASGRPT.assignment_id
and    ASSACT.tax_unit_id = c_tax_unit_id
and    ASSACT.action_status = 'C'
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    RR.status in ('P','PA')
and    RR.jurisdiction_code like substr ( c_state_code, 1, 2)||'%'
and    TARGET.run_result_id    = RR.run_result_id
and    FEED.input_value_id     = TARGET.input_value_id
and    nvl(TARGET.result_value,'0') <> '0';
--
BEGIN --us_gp_gre_jd_mtd
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
   l_balance_type_id6 := get_balance_type(p_balance_name6);
   l_balance_type_id7 := get_balance_type(p_balance_name7);

   --
   open get_state_level_value(l_balance_type_id1,l_balance_type_id2,
                              l_balance_type_id3,l_balance_type_id4,
                              l_balance_type_id5,l_balance_type_id6,
                              l_balance_type_id7,p_effective_date, p_tax_unit_id, p_state_code);
   fetch get_state_level_value into p_value1,p_value2,p_value3,p_value4,p_value5,p_value6,p_value7;
   close get_state_level_value;
   --
--
END us_gp_gre_jd_mtd;
--
-----------------------------------------------------------------------------------------
-- PROCEDURE us_gp_gre_jd_ctd
--
-- DESCRIPTION: This procedure performs a multiple balance-type decode fetch
--              from the GRE_JD_CTD route, which is used for State-Level balance
--              reporting. It can return up to 7 balance values. This was coded
--              originally for performance fixing to the GRE Totals Report.
--
-- Maintenance: This should be dual-maintained with the row in FF_ROUTES for
--              GRE_JD_CTD dimension, although note slight changes to main where
--              clause to allow for multiple-decoding.
--
-----------------------------------------------------------------------------------------
PROCEDURE us_gp_gre_jd_ctd (p_balance_name1   IN     VARCHAR2 ,
                            p_balance_name2   IN     VARCHAR2 ,
                            p_balance_name3   IN     VARCHAR2 ,
                            p_balance_name4   IN     VARCHAR2 ,
                            p_balance_name5   IN     VARCHAR2 ,
                            p_balance_name6   IN     VARCHAR2 ,
                            p_balance_name7   IN     VARCHAR2 ,
                            p_start_date      IN     DATE,
                            p_effective_date  IN     DATE,
                            p_tax_unit_id     IN     NUMBER,
                            p_state_code      IN     VARCHAR2,
                            p_value1             OUT NOCOPY NUMBER,
                            p_value2             OUT NOCOPY NUMBER,
                            p_value3             OUT NOCOPY NUMBER,
                            p_value4             OUT NOCOPY NUMBER,
                            p_value5             OUT NOCOPY NUMBER,
                            p_value6             OUT NOCOPY NUMBER,
                            p_value7             OUT NOCOPY NUMBER)
--
IS
--
l_balance_type_id1 number;
l_balance_type_id2 number;
l_balance_type_id3 number;
l_balance_type_id4 number;
l_balance_type_id5 number;
l_balance_type_id6 number;
l_balance_type_id7 number;
--
cursor get_state_level_value (c_balance_type_id1 in number,
                              c_balance_type_id2 in number,
                              c_balance_type_id3 in number,
                              c_balance_type_id4 in number,
                              c_balance_type_id5 in number,
                              c_balance_type_id6 in number,
                              c_balance_type_id7 in number,
                              c_start_date     in date,
                              c_effective_date in date,
                              c_tax_unit_id in number,
                              c_state_code in varchar2)
is
SELECT /* Removed RULE hint. Bug 3331031 */
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id1,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id2,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id3,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id4,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id5,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id6,TARGET.result_value * FEED.scale,0)),0) ,
  nvl(sum(decode(FEED.balance_type_id,c_balance_type_id7,TARGET.result_value * FEED.scale,0)),0)
FROM
       pay_balance_feeds_f     FEED
,      pay_run_result_values   TARGET
,      pay_run_results         RR
,      pay_assignment_actions  ASSACT
,      pay_payroll_actions     PACT
,      (select distinct puar.assignment_id assignment_id
        from pay_us_asg_reporting puar
        where puar.tax_unit_id = c_tax_unit_id
        and puar.jurisdiction_code like substr(c_state_code,1,2)||'%') ASGRPT
--
where  PACT.effective_date between c_start_date
                               and  c_effective_date
and    PACT.action_type in ('R','Q','I','B','V')
/*
and    PACT.action_status = 'C'
*/
and    FEED.balance_type_id in ( c_balance_type_id1 ,  c_balance_type_id2 ,
                                 c_balance_type_id3 ,  c_balance_type_id4 ,
                                 c_balance_type_id5 ,  c_balance_type_id6 ,
                                 c_balance_type_id7 )
and    PACT.effective_date between FEED.effective_start_date
                               and FEED.effective_end_date
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    ASSACT.assignment_id = ASGRPT.assignment_id
and    ASSACT.tax_unit_id = c_tax_unit_id
and    ASSACT.action_status = 'C'
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    RR.status in ('P','PA')
and    RR.jurisdiction_code like substr ( c_state_code, 1, 2)||'%'
and    TARGET.run_result_id    = RR.run_result_id
and    FEED.input_value_id     = TARGET.input_value_id
and    nvl(TARGET.result_value,'0') <> '0';
--
BEGIN --us_gp_gre_jd_ctd
--
   l_balance_type_id1 := get_balance_type(p_balance_name1);
   l_balance_type_id2 := get_balance_type(p_balance_name2);
   l_balance_type_id3 := get_balance_type(p_balance_name3);
   l_balance_type_id4 := get_balance_type(p_balance_name4);
   l_balance_type_id5 := get_balance_type(p_balance_name5);
   l_balance_type_id6 := get_balance_type(p_balance_name6);
   l_balance_type_id7 := get_balance_type(p_balance_name7);

   --
   open get_state_level_value(l_balance_type_id1,l_balance_type_id2,
                              l_balance_type_id3,l_balance_type_id4,
                              l_balance_type_id5,l_balance_type_id6,
                              l_balance_type_id7,p_start_date,
                              p_effective_date, p_tax_unit_id,
                              p_state_code);
   fetch get_state_level_value into p_value1,p_value2,p_value3,p_value4,p_value5,p_value6,p_value7;
   close get_state_level_value;
   --
--
END us_gp_gre_jd_ctd;
--
---------------------------------------------------------------------------------------
BEGIN
  --
  -- Setup the Quarter To Date dimensions in the Cache.
  --
  g_dim_tbl_grp(0) := 'GRE_QTD';
  g_dim_tbl_asg(0) := 'ASG_GRE_QTD';
  g_dim_tbl_jdr(0) := 'N';
  g_dim_tbl_crs(0) := ASG_CURSOR0;
  g_dim_tbl_vtd(0) := ASG_VDATE_QTD0;
  g_dim_tbl_btt(0) := 'Q';
  --
  -- Setup the Year To Date dimensions in the Cache.
  --
  g_dim_tbl_grp(1) := 'GRE_YTD';
  g_dim_tbl_asg(1) := 'ASG_GRE_YTD';
  g_dim_tbl_jdr(1) := 'N';
  g_dim_tbl_crs(1) := ASG_CURSOR1;
  g_dim_tbl_vtd(1) := ASG_VDATE_YTD0;
  g_dim_tbl_btt(1) := 'Y';
  --
  -- Setup the Subject to Tax Year To Date dimensions in the Cache.
  --
  g_dim_tbl_grp(2) := 'SUBJECT_TO_TAX_GRE_YTD';
  g_dim_tbl_asg(2) := 'SUBJECT_TO_TAX_ASG_GRE_YTD';
  g_dim_tbl_jdr(2) := 'N';
  g_dim_tbl_crs(2) := ASG_CURSOR1;
  g_dim_tbl_vtd(2) := ASG_VDATE_YTD0;
  g_dim_tbl_btt(2) := 'Y';
  --
  -- Setup the Year To Date in Jurisdiction dimensions in the Cache.
  --
  g_dim_tbl_grp(3) := 'GRE_JD_YTD';
  g_dim_tbl_asg(3) := 'ASG_JD_GRE_YTD';
  g_dim_tbl_jdr(3) := 'Y';
  g_dim_tbl_crs(3) := ASG_CURSOR2;
  g_dim_tbl_vtd(3) := ASG_VDATE_YTD0;
  g_dim_tbl_btt(3) := 'Y';
  -- Set the next free cache space.
  g_nxt_free_dim := 4;

end pay_us_taxbal_view_pkg;

/
