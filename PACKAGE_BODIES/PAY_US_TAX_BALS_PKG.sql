--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_BALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_BALS_PKG" as
/* $Header: pyustxbl.pkb 120.3.12010000.4 2008/12/22 21:20:50 tclewis ship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyustxbl.pkb
--
   DESCRIPTION
      API to get US tax balance figures.
--
  MODIFIED (DD-MON-YYYY)
  S Panwar   1-FEB-1995      Created
  S Panwar   ?-???-????      Various changes
  S Panwar  13-JUL-1995      Improved error handling/reporting, added code
                             to catch unsupported EIC balances.
  H Parichabutr 24-JUL-1995	Updated to handle "PAYMENTS" and "PAYMENTS_JD"
				time types - required for displaying tax bals
				on SOE.
  S Desai   27-Nov-1995	     Added PYDATE time dimension.
  gpaytonm  09-JAN-1995     333594 payments_jd dimension is defunct
  gpaytonm  01-FEB-1996     337641 performance fixes to SQL statements (two)
			    and more control over calling bal user exit.
  S Desai   18-Mar-1996     Ensure that get_dummy_asg_id returns an assignment
                            with a payroll_id and is effective on the virtual
                            date in order to pass the core.
  T Grisco  23-Apr-1996     360669 put PAYMENTS_JD back.
  S Desai   20-Aug-1996	    371351: Head Tax mis-classified as an employer
                            liability.
  L Thompson30-SEP-1996	40.15    395029: Must execute db item if dimension is
                                 _PAYMENTS
  L Thompson03-NOV-1996 40.16    378594: WC_EE previously not accessible.

  nbristow 08-NOV-1996  40.17    420465:  Added several performance fixes.
                                          Major changes to improve
                                          the handling of latest balances.
                                          arcsed in by lwthomps.
  nbristow 14-NOV-1996  40.18    Removed hard coded path, no longer forced
                                 to use latest balances.
  nbristow 20-NOV-1996  40.19    Created overload functions and
                                 us_tax_balance_rep functions.
  nbristow 06-DEC-1996  40.20    Fixed get_virtual_date, now also checks
                                 the payroll as well as the assignment.
  nbristow 18-DEC-1996  40.21    Changed calls to get_value (date mode) to
                                 get_value_lock.
  lwthomps 27-May-1997  40.22    489769, WC2_EE previously not accessible.
                                 Similiar to change for 40.16.
  tbattoo  16-JAN-1998  40.23(110.0)    changed date format to DD-MON-YYYY -
                                 bug 612696.
  tbattoo  11-MAY-1998  40.24(110.1)    dual mantained changes in view so
				 GRE PYDATE routes work over a range
  djoshi   08-APR-1999           Verfied and converted for Canonical
                                 Complience of Date
  skutteti 14-SEP-1999  115.4    Pre-tax enhancements. Added categories 403B
                                 and 457 wherever required.
  hzhao    10-DEC-1999  115.5    Added support of pre-tax for EIC
  JARTHURT 24-JUL-2000  115.6    Added legislation_code check in
                                 get_defined_balance
  skutteti 15-SEP-2000  115.8    Currently there is no balance for FIT gross,
                                 instead 'Gross Earnings' is used. Changed code
                                 to subtract Alien earnings from FIT Gross.
  skutteti 23-NOV-2000  115.9    Pre tax for Alien expat earnings has to be
                                 reported in 1042s. Added code to subtract the
                                 Alien portion of Pre-tax for SIT/FIT purposes.
  tmehra   16-AUG-2001  115.10   Removed above code to subtract Non W2 protion
                                 of Pre-Tax for SIT as new balance feeds have
                                 been added to achive this.
  kthirmiy 01-OCT-2001  115.11   Added code for balance extract with the
                                 tax_balance_category of 'OTHER_PRETAX_REDNS'
                                 to show in the Pretax Details block for
                                 other pre-tax enhancements
  meshah   13-JUN-2002  115.18   changed the function call_balance_user_exit
                                 to remove the call to get_grp_value because
                                 from July 2002 we should be using the Balance
                                 Reporting Arch. and that does not require the
                                 call.
                                 for new TRR checking REDUCED_SUBJ_WHABLE and
                                 session_var of W2.
  meshah   11-FEB-2003  115.21  Now checking for a session var of PAYUSNFR
                                to set the assignment_action_id before making
                                the balance call.
  meshah   13-FEB-2003  115.22  nocopy.
  meshah   17-APR-2003  115.23  changed the name of the session var from
                                PAYUSNFR to GROUP_RB_REPORT and added a new
                                cursor c_get_max_aaid.
  meshah   29-MAY-2003  115.24  changed cursor c_get_max_aaid to c_get_min_aaid
                                GRE Totals, 940 and 941 reports are now
                                setting GROUP_RB_SDATE and GROUP_RB_EDATE
                                session variables to get the minimum
                                assignment_action_id. In c_get_min_aaid we
                                are using nvl in the select to return a -1
                                for cases where there are no runs.
  meshah   04-JUN-2003  115.25  changed cursor c_get_min_aaid to work with
                                business_group_id and added a new cursor
                                c_get_bg_id.
  sdahiya  12-JAN-2004  115.26  Modified query for performance enhancement
                                (Bug 3343974).
  kvsankar 16-JAN-2004  115.27  Modified query for performance enhancement
                                (Bug 3290396).
  tlcewis  17-MAR-2004  115.28  added coding for STEIC.
  fusman   10-JAN-2005  115.29  Added JD_dimension String for NY FUTA Taxable.
  fusman   12-JAN-2005  115.30  Changed the l_test value to 0 to make FUTA a state tax.
  pragupta 14-APR-2005  115.31  Increased the size of l_tax_type
  sackumar 13-SEP-2005  115.32  (Bug 4347453) Modified the g_dim_tbl_crs(3) query.
				Introduced Index Hint in the query.
  rdhingra 23-SEP-2005  115.33  Bug 4583560: Performance changes done
  rdhingra 27-SEP-2005  115.34  Bug 4583560: Performance changes done
                                Reverting changes of ver 32 as it was putting a full index scan
  tclewis  04-DEC-2008  115.35  Added validaton for SUI1 EE and SDI1 EE

*/

-- Global declarations
type num_array  is table of number(15) index by binary_integer;
type char80_array  is table of varchar2(80) index by binary_integer;
type char_array  is table of varchar2(1) index by binary_integer;
type char2000_array  is table of varchar2(2000) index by binary_integer;
--
-- Assignment Id Cache
g_asgid_tbl_id num_array;
g_asgid_tbl_bgid num_array;
g_nxt_free_asgid binary_integer := 0;
--
-- Group Dimension Cache.
g_dim_tbl_grp char80_array;
g_dim_tbl_asg char80_array;
g_dim_tbl_crs char2000_array;
g_dim_tbl_vtd char2000_array;
g_dim_tbl_jdr char_array;
g_dim_tbl_btt char_array;
g_nxt_free_dim binary_integer;
--
-------------------------------------------------------------------------------
--
--  Quick procedure to raise an error
--
-------------------------------------------------------------------------------
PROCEDURE local_error(p_procedure varchar2,
                      p_step      number) IS
BEGIN
--
  hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token('PROCEDURE',
                               'pay_us_tax_bals_pkg.'||p_procedure);
  hr_utility.set_message_token('STEP',p_step);
  hr_utility.raise_error;
--
END local_error;
--
--
----------------------------------------------------------------------------
-- Get the assignment level equivilent of the group balance, plus a cursor
-- that returns all the assignments contributing to the group level balance.
----------------------------------------------------------------------------
procedure get_asg_for_grp_lvl(p_grp_dvl_dimension  in      varchar2,
                              p_asg_lvl_dimension     out nocopy varchar2,
                              p_asg_cursor            out nocopy varchar2,
                              p_asg_jd_required       out nocopy boolean,
                              p_asg_vdate_cursor      out nocopy varchar2,
                              p_asg_balance_time      out nocopy varchar2,
                              p_found                 out nocopy boolean)
is
  l_count number;
  l_found boolean;
begin
  --   Look to see if the group level balance is in our cache.
  --
  hr_utility.set_location('pay_us_tax_bals_pkg.get_asg_for_grp_lvl', 10);
  --
  l_count := 0;
  l_found := FALSE;
  while ((l_count < g_nxt_free_dim) AND (l_found = FALSE)) loop
    if (p_grp_dvl_dimension = g_dim_tbl_grp(l_count)) then
        hr_utility.set_location('pay_us_tax_bals_pkg.get_asg_for_grp_lvl', 20);
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
    end if;
    l_count := l_count + 1;
  end loop;
  --
  hr_utility.set_location('pay_us_tax_bals_pkg.get_asg_for_grp_lvl', 30);
  p_found := l_found;
  --
end;
--
----------------------------------------------------------------------------
-- Get the defined balance id given the balance name and database item
-- suffix.
----------------------------------------------------------------------------
function get_defined_balance (p_balance_name     varchar2,
                              p_dimension_suffix  varchar2) return number is
l_defined_balance_id number;
--
begin
    hr_utility.set_location('pay_us_tax_bals_pkg.get_defined_balance', 10);
    --

    SELECT  creator_id
      INTO  l_defined_balance_id
      FROM  ff_user_entities
     WHERE  user_entity_name like
                translate(p_balance_name||'_'||p_dimension_suffix,' ','_')
       AND  legislation_code = 'US';
    --
    hr_utility.set_location('pay_us_tax_bals_pkg.get_defined_balance', 20);
    return l_defined_balance_id;
end;
--
------------------------------------------------------------------------------
-- This ensures that the assignment is on a payroll on the effective date,
-- if not a valid date is found. If no valid date can be found an error is
-- raised.
------------------------------------------------------------------------------
function get_virtual_date (p_assignment_id     number,
                           p_virtual_date      date,
                           p_balance_time      varchar2,
                           p_asg_vdate_cursor  varchar2) return date is
l_dummy         varchar2(1);
l_virtual_date  date;
l_virtual_date2 date;
l_res_date      date;
begin
   begin
      --
      -- Is the assignment on a payroll.
      --
      hr_utility.set_location('pay_us_tax_bals_pkg.get_virtual_date', 10);
      select ''
        into l_dummy
        from per_assignments_f paf
       where paf.assignment_id = p_assignment_id
         and p_virtual_date between paf.effective_start_date
                                and paf.effective_end_date
         and paf.payroll_id is not null;

       --
       hr_utility.set_location('pay_us_tax_bals_pkg.get_virtual_date', 20);
       return p_virtual_date;
   exception
       when no_data_found then
           --
           -- Find a valid date for the assignment.
           --
           declare
              sql_cursor number;
              l_rows     number;
           begin
              hr_utility.set_location('pay_us_tax_bals_pkg.get_virtual_date',
                                      30);
              sql_cursor := dbms_sql.open_cursor;
              dbms_sql.parse(sql_cursor, p_asg_vdate_cursor, dbms_sql.v7);
              dbms_sql.bind_variable (sql_cursor, 'ASSIGNMENT_ID',
                                      p_assignment_id);
              dbms_sql.bind_variable (sql_cursor, 'DATE_EARNED',
                                      p_virtual_date);
              dbms_sql.bind_variable (sql_cursor, 'DATE2_EARNED',
                                      p_virtual_date);
              dbms_sql.define_column (sql_cursor, 1, l_virtual_date);
              l_rows := dbms_sql.execute(sql_cursor);
              l_rows := dbms_sql.fetch_rows (sql_cursor);
              if l_rows > 0 then
                  hr_utility.set_location(
                           'pay_us_tax_bals_pkg.get_virtual_date', 40);
                  dbms_sql.column_value (sql_cursor,  1, l_virtual_date);
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
                          hr_utility.set_location(
                           'pay_us_tax_bals_pkg.get_virtual_date', 60);
                        local_error('get_virtual_date', 2);
                     else
                        hr_utility.set_location(
                          'pay_us_tax_bals_pkg.get_virtual_date', 70);
                        l_res_date := l_virtual_date2;
                     end if;
                  else
                     if l_virtual_date2 is null then
                        hr_utility.set_location(
                           'pay_us_tax_bals_pkg.get_virtual_date', 80);
                        l_res_date := l_virtual_date;
                     else
                        hr_utility.set_location(
                            'pay_us_tax_bals_pkg.get_virtual_date', 90);
                        l_res_date := least(l_virtual_date, l_virtual_date2);
                     end if;
                  end if;
                  --
              else
                  hr_utility.set_location(
                           'pay_us_tax_bals_pkg.get_virtual_date', 50);
                  local_error('get_virtual_date', 1);
              end if;
              --
              dbms_sql.close_cursor(sql_cursor);
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
                            p_jurisdiction_code    varchar2,
                            p_asg_lock             varchar2)
                            return number is
l_dummy varchar2(5);
l_lat_balances boolean;
l_asg_data_suffix varchar2(80);
l_asg_data_cursor varchar2(2000);
l_asg_vdate_cursor varchar2(2000);
l_asg_balance_time varchar2(10);
l_asg_jd_required boolean;
l_grp_lat_exist boolean;
l_defined_balance_id number;
sql_cursor number;
l_rows number;
l_asg_id number;
l_balance_value number;
cnt number;
l_virtual_date date;
l_balance_type_id number;
l_run_route  varchar2(5);
l_run_route_bool boolean;

begin

  -- check for the 'RUN_ROUTE' parameter_name in the pay_action_parameters
  -- table to determine if we want to call the run_result route instead of
  -- the run_balance route.
  begin

      select parameter_value
      into   l_run_route
      from   PAY_ACTION_PARAMETERS
      where  parameter_name = 'RUN_ROUTE';

  exception
     WHEN others then
     l_run_route := 'FALSE';
  end;

  IF l_run_route <> 'TRUE' THEN
     l_run_route_bool := false;
  ELSE
     l_run_route_bool := true;
  END IF;

   l_balance_value := 0;
   hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_asg_value', 10);
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
   if l_grp_lat_exist then
      --
      -- Are there latest balances available.
      --
      hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_asg_value', 20);
      l_defined_balance_id := get_defined_balance(p_balance_name,
                                                  l_asg_data_suffix);
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
                        and   ppa.action_type in ('R','Q','I','B','V')
                        and   p_virtual_date           >= ppa.effective_date);
         --
         l_lat_balances := TRUE;
         --
      exception
         when no_data_found then
            l_lat_balances := FALSE;
      end;
      --
      if (l_lat_balances = TRUE) then
         --
         -- OK, we can sum the values of the assignment balances to get the
         -- group balance.
         --
         hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_asg_value', 30);
         begin
            --
            sql_cursor := dbms_sql.open_cursor;
            dbms_sql.parse(sql_cursor, l_asg_data_cursor, dbms_sql.v7);
            dbms_sql.bind_variable (sql_cursor, 'TAX_UNIT_ID', p_gre_id);
            dbms_sql.bind_variable (sql_cursor, 'DATE_EARNED', p_virtual_date);
            dbms_sql.bind_variable (sql_cursor, 'DATE2_EARNED', p_virtual_date);
            dbms_sql.define_column (sql_cursor, 1, l_asg_id);
            --
            -- Does the cursor require the jurisdiction code. Hence balance
            -- type.
            --
            if l_asg_jd_required then
               select balance_type_id
                 into l_balance_type_id
                 from pay_defined_balances
                where defined_balance_id = l_defined_balance_id;
               --
               dbms_sql.bind_variable (sql_cursor, 'BALANCE_TYPE_ID',
                                       l_balance_type_id);
               dbms_sql.bind_variable (sql_cursor, 'JURISDICTION_CODE',
                                       p_jurisdiction_code);
            end if;
            l_rows := dbms_sql.execute(sql_cursor);
            l_rows := 1;
            cnt := 0;
            --
            -- Loop through all the contributing assignments, go get there
            -- balance value and add onto the running total.
            --
            while (l_rows <> 0) loop
               l_rows := dbms_sql.fetch_rows (sql_cursor);
               cnt := cnt + 1;
               if l_rows > 0 then
                  hr_utility.set_location(
                           'pay_us_tax_bals_pkg.get_grp_asg_value', 40);
                  dbms_sql.column_value (sql_cursor, 1, l_asg_id);
                  --
                  l_virtual_date := get_virtual_date(l_asg_id, p_virtual_date,
                                                     l_asg_balance_time,
                                                     l_asg_vdate_cursor);
                  --
                  l_balance_value := l_balance_value +
                               pay_balance_pkg.get_value_lock
                                                    (l_defined_balance_id,
                                                     l_asg_id,
                                                     l_virtual_date,
                                                     l_run_route_bool,
                                                     p_asg_lock
                                                    );
               end if;
            end loop;
            --
            dbms_sql.close_cursor(sql_cursor);
         end;
      else
         --
         -- No latets balances available. Run the route.
         --
         hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_asg_value', 50);
         l_defined_balance_id := get_defined_balance(p_balance_name,
                                                     p_database_suffix);
         l_balance_value := pay_balance_pkg.get_value_lock
                                                 (l_defined_balance_id,
                                                  p_assignment_id,
                                                  p_virtual_date,
                                                  l_run_route_bool,
                                                  p_asg_lock
                                                 );
      end if;
   else
      --
      -- Can not sum the assignment level balances, thus run group
      -- level route.
      --
      hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_asg_value', 60);
      l_defined_balance_id := get_defined_balance(p_balance_name,
                                                  p_database_suffix);
      l_balance_value := pay_balance_pkg.get_value_lock
                                              (l_defined_balance_id,
                                               p_assignment_id,
                                               p_virtual_date,
                                               l_run_route_bool,
                                               p_asg_lock
                                              );
   end if;
   --
   hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_asg_value', 70);
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
l_run_route     varchar2(5);
l_run_route_bool boolean;

begin

  -- check for the 'RUN_ROUTE' parameter_name in the pay_action_parameters
  -- table to determine if we want to call the run_result route instead of
  -- the run_balance route.
  begin

      select parameter_value
      into l_run_route
      from PAY_ACTION_PARAMETERS
      where parameter_name = 'RUN_ROUTE';

  exception
     WHEN others then
     l_run_route := 'FALSE';
  end;

  IF l_run_route <> 'TRUE' THEN
     l_run_route_bool := false;
  ELSE
     l_run_route_bool := true;
  END IF;

   l_balance_value := 0;
   hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_act_value', 10);
   --
   l_defined_balance_id := get_defined_balance(p_balance_name,
                                               p_database_suffix);
   l_balance_value := pay_balance_pkg.get_value (l_defined_balance_id,
                                                 p_assignment_action_id,
                                                 l_run_route_bool,
                                                 FALSE
                                                 );
   --
   hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_act_value', 20);
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
                        p_assignment_action_id number default null,
                        p_asg_lock             varchar2)
                        return number is
begin
   hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_value', 10);
   if p_assignment_action_id is null then
       hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_value', 20);
       return get_grp_asg_value(p_assignment_id,
                                p_virtual_date,
                                p_balance_name,
                                p_database_suffix,
                                p_gre_id,
                                p_jurisdiction_code,
                                p_asg_lock);
   else
       hr_utility.set_location('pay_us_tax_bals_pkg.get_grp_value', 30);
       return get_grp_act_value(p_assignment_action_id,
                                p_virtual_date,
                                p_balance_name,
                                p_database_suffix,
                                p_gre_id);
   end if;
end;
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
                          p_jurisdiction_code     varchar2  DEFAULT NULL,
                          p_asg_lock              varchar2  DEFAULT 'Y')
RETURN number IS
--
l_defined_balance_id  number;
l_balance_type_id     number;
l_dimension_id        number;
l_session             VARCHAR2(15);
l_run_route           varchar2(5);
l_run_route_bool      boolean;
--
BEGIN
--

  hr_utility.set_location('pay_us_tax_bals_pkg.balance_name'||p_balance_name, 9);
  hr_utility.trace('p_dimension_suffix = '||p_dimension_suffix);
  hr_utility.trace('p_balance_name = '||p_balance_name);
  hr_utility.trace('p_asg_type = '||p_asg_type);
  hr_utility.set_location('pay_us_tax_bals_pkg.call_balance_user_exit', 10);

  -- check for the 'RUN_ROUTE' parameter_name in the pay_action_parameters
  -- table to determine if we want to call the run_result route instead of
  -- the run_balance route.
  begin

      select parameter_value
      into l_run_route
      from PAY_ACTION_PARAMETERS
      where parameter_name = 'RUN_ROUTE';

  exception
     WHEN others then
     l_run_route := 'FALSE';
  end;

  IF l_run_route <> 'TRUE' THEN
     l_run_route_bool := false;
  ELSE
     l_run_route_bool := true;
  END IF;

  IF p_assignment_action_id IS NOT NULL  THEN
   -- If group level balance, call the group level balance code.

   /* commenting of the following code. From now on we will be using
      the Balance Reporting Arch */
/*
   if p_asg_type = 'GRE' then
       hr_utility.set_location('pay_us_tax_bals_pkg.call_balance_user_exit',
                               20);
       return get_grp_value(p_assignment_id,
                                    p_virtual_date,
                                    p_balance_name,
                                    p_dimension_suffix,
                                    p_gre_id,
                                    p_jurisdiction_code,
                                    p_assignment_action_id,
                                    p_asg_lock
                                    );
   else
*/
    l_defined_balance_id := get_defined_balance(p_balance_name,
                                               p_dimension_suffix);
    IF p_dimension_suffix not like '%PAY%' THEN
     hr_utility.set_location('pay_us_tax_bals_pkg.call_balance_user_exit', 30);
     return pay_balance_pkg.get_value (l_defined_balance_id,
                                       p_assignment_action_id,
                                       l_run_route_bool,
                                       FALSE
                                       );
    ELSE /* If payments dimension then must execute DB item 395029 */
     hr_utility.set_location('pay_us_tax_bals_pkg.call_balance_user_exit', 40);
     return pay_balance_pkg.get_value (l_defined_balance_id,
                                       p_assignment_action_id,
                                       true );
--    END IF;
   end if;
   --
  ELSE
    -- If group level balance, call the group level balance code.
   /* commenting of the following code. From now on we will be using
      the Balance Reporting Arch */
/*
    if p_asg_type = 'GRE' then
       hr_utility.set_location('pay_us_tax_bals_pkg.call_balance_user_exit',
                               50);
       return get_grp_value(p_assignment_id,
                                    p_virtual_date,
                                    p_balance_name,
                                    p_dimension_suffix,
                                    p_gre_id,
                                    p_jurisdiction_code,
                                    null,
                                    p_asg_lock
                                    );
    else
*/
       l_defined_balance_id := get_defined_balance(p_balance_name,
                                                   p_dimension_suffix);
       hr_utility.set_location('pay_us_tax_bals_pkg.call_balance_user_exit',
                               60);
       return pay_balance_pkg.get_value_lock
                                        (l_defined_balance_id,
                                         p_assignment_id,
                                         p_virtual_date,
                                         l_run_route_bool,
                                         p_asg_lock
                                         );
--    end if;
  END IF;
--
END call_balance_user_exit;
--
-------------------------------------------------------------------------------
--
-- An overloaded version without the payroll_action_id param to prevent calls
-- from forms from breaking
--
-------------------------------------------------------------------------------
FUNCTION us_tax_balance_rep (p_asg_lock              in boolean  DEFAULT TRUE,
                             p_tax_balance_category  in varchar2,
                             p_tax_type              in varchar2,
                             p_ee_or_er              in varchar2,
                             p_time_type             in varchar2,
                             p_asg_type              in varchar2,
                             p_gre_id_context        in number,
                             p_jd_context            in varchar2  DEFAULT NULL,
                             p_assignment_action_id  in number    DEFAULT NULL,
                             p_assignment_id         in number    DEFAULT NULL,
                             p_virtual_date          in date      DEFAULT NULL,
                             p_payroll_action_id     in number)
RETURN number IS
--
BEGIN
--
  return us_tax_balance(p_tax_balance_category => p_tax_balance_category,
                        p_tax_type => p_tax_type,
                        p_ee_or_er => p_ee_or_er,
                        p_time_type => p_time_type,
                        p_asg_type => p_asg_type,
                        p_gre_id_context => p_gre_id_context,
                        p_jd_context => p_jd_context,
                        p_assignment_action_id => p_assignment_action_id,
                        p_assignment_id => p_assignment_id,
                        p_virtual_date => p_virtual_date,
                        p_payroll_action_id => p_payroll_action_id,
                        p_asg_lock => p_asg_lock);
--
END us_tax_balance_rep;
--
FUNCTION us_tax_balance_rep (p_asg_lock              in boolean  DEFAULT TRUE,
                             p_tax_balance_category  in varchar2,
                             p_tax_type              in varchar2,
                             p_ee_or_er              in varchar2,
                             p_time_type             in varchar2,
                             p_asg_type              in varchar2,
                             p_gre_id_context        in number,
                             p_jd_context            in varchar2  DEFAULT NULL,
                             p_assignment_action_id  in number    DEFAULT NULL,
                             p_assignment_id         in number    DEFAULT NULL,
                             p_virtual_date          in date      DEFAULT NULL
                             )
RETURN number IS
--
BEGIN
--
  return us_tax_balance(p_tax_balance_category => p_tax_balance_category,
                        p_tax_type => p_tax_type,
                        p_ee_or_er => p_ee_or_er,
                        p_time_type => p_time_type,
                        p_asg_type => p_asg_type,
                        p_gre_id_context => p_gre_id_context,
                        p_jd_context => p_jd_context,
                        p_assignment_action_id => p_assignment_action_id,
                        p_assignment_id => p_assignment_id,
                        p_virtual_date => p_virtual_date,
                        p_payroll_action_id => NULL,
                        p_asg_lock => p_asg_lock);
--
END us_tax_balance_rep;
--
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL)
RETURN number IS
--
BEGIN
--
  return us_tax_balance(p_tax_balance_category => p_tax_balance_category,
                        p_tax_type => p_tax_type,
                        p_ee_or_er => p_ee_or_er,
                        p_time_type => p_time_type,
                        p_asg_type => p_asg_type,
                        p_gre_id_context => p_gre_id_context,
                        p_jd_context => p_jd_context,
                        p_assignment_action_id => p_assignment_action_id,
                        p_assignment_id => p_assignment_id,
                        p_virtual_date => p_virtual_date,
                        p_payroll_action_id => NULL,
                        p_asg_lock => TRUE);
--
END us_tax_balance;
--
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL,
                          p_payroll_action_id     in number)
RETURN number IS
--
BEGIN
--
  return us_tax_balance(p_tax_balance_category => p_tax_balance_category,
                        p_tax_type => p_tax_type,
                        p_ee_or_er => p_ee_or_er,
                        p_time_type => p_time_type,
                        p_asg_type => p_asg_type,
                        p_gre_id_context => p_gre_id_context,
                        p_jd_context => p_jd_context,
                        p_assignment_action_id => p_assignment_action_id,
                        p_assignment_id => p_assignment_id,
                        p_virtual_date => p_virtual_date,
                        p_payroll_action_id => p_payroll_action_id,
                        p_asg_lock => TRUE);
--
END us_tax_balance;
--
-------------------------------------------------------------------------------
--
--
--
--
-------------------------------------------------------------------------------
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL,
                          p_payroll_action_id     in number,
                          p_asg_lock              in boolean)
RETURN number IS
--
-- 337641 - cursor rather than ful blown select
--	    doing group function (min)
--
CURSOR get_pay_action_id IS
    select assignment_action_id
    from pay_assignment_actions
    where payroll_action_id = p_payroll_action_id;

/* we need to get the max assignment_action_id for the core
   balance package. from the max aaid they find the business group
   id to see if the balances are valid for that business group only. */

/*
CURSOR c_get_min_aaid(p_start_date date , p_end_date date) is
    select nvl(min(assignment_action_id),-1)
    from pay_assignment_actions paa,pay_payroll_actions ppa
    where paa.tax_unit_id  = p_gre_id_context
    and ppa.payroll_action_id = paa.payroll_action_id
    and ppa.effective_date between p_start_date and p_end_date
    and ppa.action_type in ('R','Q','I','B','V') ;
*/

CURSOR c_get_min_aaid(p_start_date date , p_end_date date,p_bg_id number) is
    select nvl(min(assignment_action_id),-1)
    from pay_assignment_actions paa,pay_payroll_actions ppa,pay_payrolls_f ppf
    where ppa.business_group_id +0 = p_bg_id
    and ppa.payroll_action_id = paa.payroll_action_id
    and ppa.effective_date between p_start_date and p_end_date
    and ppa.action_type in ('R','Q','I','B','V')
    and ppf.payroll_id = ppa.payroll_id
    and ppa.business_group_id +0 = ppf.business_group_id;

 CURSOR c_get_bg_id is
    select business_group_id
    from hr_organization_units
    where organization_id = p_gre_id_context;

--
l_return_value   number;
l_test           number;
l_tax_balance_category  varchar2(30);
l_tax_type       varchar2(30);
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
l_asg_lock       varchar2(2);
l_non_w2_cat     varchar2(60);

l_group_rb_report varchar2(50);
l_grp_aaid        varchar2(50);
l_session_aaid    number;
l_group_rb_sdate  date;
l_group_rb_edate  date;
l_temp_bg_id      number;

l_end_of_time   date default to_date('31-12-4712','DD-MM-YYYY');
--
BEGIN
--
-- Set the locking flag.
--
l_asg_lock := 'N';
if (p_asg_lock) then
   l_asg_lock := 'Y';
end if;
--
-- Check that inputs based on lookups are valid
--
if p_tax_balance_category <> 'NONE' then

	SELECT count(0)
	INTO   l_valid
	FROM   hr_lookups
	WHERE  lookup_type = 'US_TAX_BALANCE_CATEGORY'
	AND    lookup_code = p_tax_balance_category;
--
	IF l_valid = 0 THEN
   	   hr_utility.trace('Error:  Invalid tax balance category');
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
   	   hr_utility.trace('Error:  Invalid tax type');
   	   local_error('us_tax_balance',2);
	END IF;
--
end if; /* p_tax_balance_category is NONE */

SELECT count(0)
INTO   l_valid
FROM   dual
WHERE  p_asg_type in ('ASG','PER','GRE');
--
IF l_valid = 0 THEN
   hr_utility.trace('Error:  Invalid asg_type parameter');
   local_error('us_tax_balance',3);
END IF;
--
SELECT count(0)
INTO   l_valid
FROM   dual
WHERE  p_time_type in ('RUN','PTD','MONTH','QTD','YTD', 'PAYMENTS', 'PYDATE');
--
IF l_valid = 0 THEN
   hr_utility.trace('Error:  Invalid time_type parameter');
   local_error('us_tax_balance',4);
END IF;
--
-- Set the contexts used in the bal user exit.  Same throughout, so set
-- them up front
--
 hr_utility.set_location('pay_tax_bals_pkg',30);
--
pay_balance_pkg.set_context('TAX_UNIT_ID',p_gre_id_context);
IF p_jd_context IS NOT NULL THEN
  IF (p_tax_type = 'SCHOOL' and length(p_jd_context) > 11) THEN
    pay_balance_pkg.set_context('JURISDICTION_CODE',substr(p_jd_context,1,2)||
                                              '-'||substr(p_jd_context,13,5));
  ELSE
    pay_balance_pkg.set_context('JURISDICTION_CODE',p_jd_context);
  END IF;
END IF;
--
 hr_utility.set_location('pay_tax_bals_pkg',40);
--
l_assignment_id := p_assignment_id;

l_group_rb_report := NVL(pay_us_balance_view_pkg.get_session_var('GROUP_RB_REPORT'),'NA');

If l_group_rb_report <> 'NA' then

  l_grp_aaid := nvl(pay_us_balance_view_pkg.get_session_var('GRP_AAID'),'NA');

  l_group_rb_sdate :=
      nvl(pay_us_balance_view_pkg.get_session_var('GROUP_RB_SDATE'),sysdate);
  l_group_rb_edate :=
      nvl(pay_us_balance_view_pkg.get_session_var('GROUP_RB_EDATE'),l_end_of_time);



  if l_grp_aaid = 'NA' then

    open c_get_bg_id;
    fetch c_get_bg_id into l_temp_bg_id;
    close c_get_bg_id;

    open c_get_min_aaid(l_group_rb_sdate,l_group_rb_edate,l_temp_bg_id);
    fetch c_get_min_aaid into l_session_aaid;
    close c_get_min_aaid;

    pay_us_balance_view_pkg.set_session_var('GRP_AAID',to_char(l_session_aaid));

    l_grp_aaid := to_char(l_session_aaid);

  end if;

   l_assignment_action_id := to_number(l_grp_aaid);

else
   l_assignment_action_id := p_assignment_action_id;

end if;

l_tax_type := p_tax_type;
l_tax_balance_category := p_tax_balance_category;
--
-- Check if assignment exists at l_virtual_date, if using date mode
-- Changed date format to DD-MON-YYYY, bug 612696
l_virtual_date :=fnd_date.canonical_to_date(fnd_date.date_to_canonical(p_virtual_date));
--
 hr_utility.set_location('pay_tax_bals_pkg',50);
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
 hr_utility.set_location('pay_tax_bals_pkg',60);
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
 hr_utility.set_location('pay_tax_bals_pkg',70);
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
    hr_utility.trace('Assignment was terminated on : ' || l_max_date);
    hr_utility.trace('Time period in question begins on : ' ||
                       l_bal_start_date);
--
    IF l_max_date < l_bal_start_date THEN
      return 0;
    ELSE
      l_virtual_date := l_max_date;
    END IF;
--
    hr_utility.trace('Using new virtual date : ' || l_virtual_date);
--
  END IF;
END IF;
--
-- Convert "WITHHELD" to proper balance categories;
--
 hr_utility.set_location('pay_tax_bals_pkg',80);
--
IF l_tax_balance_category = 'WITHHELD' THEN
  IF p_ee_or_er = 'ER' or l_tax_type = 'FUTA' THEN
    l_tax_balance_category := 'LIABILITY';
  ELSIF (l_tax_type = 'EIC'
        OR l_tax_type = 'STEIC') THEN
    l_tax_balance_category := 'ADVANCE';
  END IF;
END IF;
IF l_tax_balance_category = 'ADVANCED' THEN
    l_tax_balance_category := 'ADVANCE';
END IF;
--
--  Check if illegal tax combo (FIT and TAXABLE, FUTA and SUBJ_NWHABLE, etc.)
--
 hr_utility.set_location('pay_tax_bals_pkg',90);
--
IF (l_tax_type = 'FIT' or l_tax_type = 'SIT' or l_tax_type = 'COUNTY' or
    l_tax_type = 'CITY' or l_tax_type = 'EIC' or l_tax_type = 'HT' or
    l_tax_type = 'SCHOOL' or l_tax_type = 'STEIC' ) THEN    -- income tax
  IF (l_tax_balance_category = 'TAXABLE' or
      l_tax_balance_category = 'EXCESS')  THEN
     hr_utility.trace('Error:  Illegal tax category for tax type');
     local_error('us_tax_balance',5);
  END IF;
--
-- return 0 for currently unsupported EIC balances.
--
-- 403b, 457 and Pre_Tax was added by skutteti for the pre-tax enhancements
--
  IF l_tax_type = 'EIC' and (l_tax_balance_category = 'SUBJ_NWHABLE' -- or
                             --l_tax_balance_category = '401_REDNS' or
                             --l_tax_balance_category = '125_REDNS' or
                             --l_tax_balance_category = '403_REDNS' or
                             --l_tax_balance_category = '457_REDNS' or
                             --l_tax_balance_category = 'PRE_TAX_REDNS' or
                             --l_tax_balance_category = 'DEP_CARE_REDNS'
			    ) THEN
    return 0;
  END IF;
ELSE       -- limit tax
  IF l_tax_balance_category = 'SUBJ_NWHABLE' THEN
    return 0;
  END IF;
END IF;
--
 hr_utility.set_location('pay_tax_bals_pkg',100);
--
l_ee_or_er := ltrim(rtrim(p_ee_or_er));
--
--------------- Some Error Checking -------------
--
--
if (l_tax_type = 'FIT' or l_tax_type = 'SIT' or l_tax_type = 'CITY' or
    l_tax_type = 'COUNTY' or l_tax_type = 'EIC' or l_tax_type = 'SCHOOL'
     or l_tax_type = 'HT' or l_tax_type = 'WC' or l_tax_type = 'WC2' or
     l_tax_type = 'STEIC' ) THEN
  if l_ee_or_er = 'ER' THEN
     hr_utility.trace('Error:  ER not allowed for tax type');
     local_error('us_tax_balance',6);
  else
    l_ee_or_er := NULL;
  end if;
elsif (l_tax_type = 'FUTA') THEN
  if l_ee_or_er = 'EE' THEN
     hr_utility.trace('Error:  EE not allowed for tax type');
     local_error('us_tax_balance',7);
  else
    l_ee_or_er := NULL;
  end if;
elsif (l_tax_type = 'SS' or l_tax_type = 'MEDICARE' or l_tax_type = 'SDI' or
       l_tax_type = 'SUI' ) THEN
  if (l_ee_or_er <> 'EE' and l_ee_or_er <> 'ER') THEN
     hr_utility.trace('Error:  EE or ER required for tax type');
     local_error('us_tax_balance',8);
  end if;
elsif (l_tax_type = 'SUI1') or  (l_tax_type = 'SDI1')THEN
  if (l_ee_or_er <> 'EE' ) THEN
     hr_utility.trace('Error:  EE required for tax type');
     local_error('us_tax_balance',9);
  end if;
end if;

-- As of implementation of the SUI1 EE Tax, we only maintain
-- a WIthheld balance.   As the SUI1 tax type should match
-- balances with SUI We will return the SUI balances.

IF (l_tax_type = 'SUI1')  and (l_tax_balance_category <> 'WITHHELD'
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
 hr_utility.set_location('pay_tax_bals_pkg',110);
--
-- Force space at end of this parameter if necessary
--
 hr_utility.set_location('pay_tax_bals_pkg',120);
--
IF l_ee_or_er IS NOT NULL THEN
  l_ee_or_er := rtrim(l_ee_or_er)||' ';
END IF;
--
--  Set up dimension strings
--
IF p_asg_type <> 'GRE' THEN
  l_dimension_string := p_asg_type||'_GRE_'||p_time_type;
  l_jd_dimension_string := p_asg_type||'_JD_GRE_'||p_time_type;
ELSE
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
    begin
	OPEN  get_pay_action_id;
	FETCH get_pay_action_id INTO l_assignment_action_id;
	CLOSE get_pay_action_id;
    end;
  else
    if (p_assignment_action_id is null) then
       --
       -- Get a dummy assignment id to call the balance user exit in date mode.
       --
        declare
          l_bg_id number;
          l_count number;
          l_found boolean;
          check_asg number;
        begin
          pay_balance_pkg.set_context('DATE_EARNED',
                                       fnd_date.date_to_canonical(l_virtual_date));
          pay_balance_pkg.set_context('BALANCE_DATE',
                                       fnd_date.date_to_canonical(l_virtual_date));
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
              --
              --     OK, now check that the assignment is valid as of the
              --     virtual date.
              --
              begin
                select 1
                into check_asg
                from per_assignments_f paf
                where paf.assignment_id = g_asgid_tbl_id(l_count)
                and l_virtual_date between paf.effective_start_date
                                       and paf.effective_end_date;
                --
                l_assignment_id := g_asgid_tbl_id(l_count);
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
            begin
              /* Modified query for performance enhancement (Bug 3343974). */
              select min(paa.assignment_id)
              into l_assignment_id
              from  pay_assignment_actions paa,
                    pay_payroll_actions pact,
                    pay_payrolls_f ppf
              where pact.effective_date <= l_virtual_date
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
                hr_utility.trace('Error:  Failure to find defined balance');
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
IF p_time_type = 'PAYMENTS' THEN
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


IF ((p_jd_context IS NOT NULL) and
    (substr(p_jd_context,1,2) <> '00')) THEN

    l_test := 0;

END IF;

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
                                             p_jd_context,
                                             l_asg_lock);
    --
    -- The if condition was added by subbu on 15-sep-2000
    --
    IF l_tax_type = 'FIT' AND l_return_value > 0 THEN
       l_return_value := l_return_value -
                     call_balance_user_exit ('ALIEN_EXPAT_EARNINGS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock) ;
    END IF;
--
  ELSIF l_tax_balance_category = 'SUBJ_WHABLE' THEN
    l_return_value := call_balance_user_exit ('REGULAR_EARNINGS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock)
                   + call_balance_user_exit (
                                   'SUPPLEMENTAL_EARNINGS_FOR_'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock);
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
                                             p_jd_context,
                                             l_asg_lock);
--
  ELSIF l_tax_balance_category = '401_REDNS' THEN
  l_return_value :=   call_balance_user_exit ('DEF_COMP_401K',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock);
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
                                             p_jd_context,
                                             l_asg_lock);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value -
                              call_balance_user_exit(
                                     'FIT_NON_W2_DEF_COMP_401',
                                     l_dimension_string,
                                     l_assignment_action_id,
                                     l_assignment_id,
                                     l_virtual_date,
                                     p_asg_type,
                                     p_gre_id_context,
                                     p_jd_context,
                                     l_asg_lock);
         END IF;
	END IF;
  --
  -- 403b, 457 and Pre_Tax was added by skutteti for the pre-tax enhancements
  --
  ELSIF l_tax_balance_category = '403_REDNS' THEN
        l_return_value :=   call_balance_user_exit (
                                             'DEF_COMP_403B',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock);
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
                                             p_jd_context,
                                             l_asg_lock);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value -
                              call_balance_user_exit(
                                         'FIT_NON_W2_DEF_COMP_403',
                                         l_dimension_string,
                                         l_assignment_action_id,
                                         l_assignment_id,
                                         l_virtual_date,
                                         p_asg_type,
                                         p_gre_id_context,
                                         p_jd_context,
                                         l_asg_lock);
         END IF;
	END IF;
  --
  -- Other Pretax was added by kthirmiy for the pre-tax enhancements
  --
  ELSIF l_tax_balance_category = 'OTHER_PRETAX_REDNS' THEN
        l_return_value :=   call_balance_user_exit (
                                             'OTHER_PRETAX',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock);
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value - call_balance_user_exit (
                                             'OTHER_PRETAX_FOR_'||l_tax_type,
                                             'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value -
                              call_balance_user_exit(
                                         'FIT_NON_W2_OTHER_PRETAX',
                                         l_dimension_string,
                                         l_assignment_action_id,
                                         l_assignment_id,
                                         l_virtual_date,
                                         p_asg_type,
                                         p_gre_id_context,
                                         p_jd_context,
                                         l_asg_lock);
         END IF;
	END IF;

  ELSIF l_tax_balance_category = '457_REDNS' THEN
        l_return_value :=   call_balance_user_exit (
                                             'DEF_COMP_457',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock);
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
                                             p_jd_context,
                                             l_asg_lock);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value -
                              call_balance_user_exit(
                                         'FIT_NON_W2_DEF_COMP_457',
                                         l_dimension_string,
                                         l_assignment_action_id,
                                         l_assignment_id,
                                         l_virtual_date,
                                         p_asg_type,
                                         p_gre_id_context,
                                         p_jd_context,
                                         l_asg_lock);
         END IF;
      END IF;
  ELSIF l_tax_balance_category = 'PRE_TAX_REDNS' THEN
        l_return_value :=   call_balance_user_exit (
                                             'PRE_TAX_DEDUCTIONS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock);
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
                                               p_jd_context,
                                               l_asg_lock);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value -
                              call_balance_user_exit(
                                          'FIT_NON_W2_PRE_TAX_DEDNS',
                                          l_dimension_string,
                                          l_assignment_action_id,
                                          l_assignment_id,
                                          l_virtual_date,
                                          p_asg_type,
                                          p_gre_id_context,
                                          p_jd_context,
                                          l_asg_lock);
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
                                             p_jd_context,
                                             l_asg_lock);
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
                                             p_jd_context,
                                             l_asg_lock);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit(
                                             'FIT_NON_W2_SECTION_125',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock);
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
                                             p_jd_context,
                                             l_asg_lock);
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
                                             p_jd_context,
                                             l_asg_lock);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value -
                              call_balance_user_exit(
                                     'FIT_NON_W2_DEPENDENT_CARE',
                                     l_dimension_string,
                                     l_assignment_action_id,
                                     l_assignment_id,
                                     l_virtual_date,
                                     p_asg_type,
                                     p_gre_id_context,
                                     p_jd_context,
                                     l_asg_lock);
         END IF;
	END IF;
--
  ELSIF l_tax_balance_category = 'TAXABLE' THEN

    hr_utility.trace('balance name sent = '||l_tax_type||'_'||
                                              l_ee_or_er||'TAXABLE');
        hr_utility.trace('  l_dimension_string = '||l_dimension_string);

    l_return_value := call_balance_user_exit (l_tax_type||'_'||
                                              l_ee_or_er||'TAXABLE',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             l_assignment_id,
                                             l_virtual_date,
                                             p_asg_type,
                                             p_gre_id_context,
                                             p_jd_context,
                                             l_asg_lock);
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
                                           p_jd_context,
                                           l_asg_lock);
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

    hr_utility.trace ('The category is : '|| l_tax_balance_category);
    if l_tax_balance_category = 'NONE'  then

         l_return_value := call_balance_user_exit (
                                           l_tax_type,
                                           l_dimension_string,
                                           l_assignment_action_id,
                                           l_assignment_id,
                                           l_virtual_date,
                                           p_asg_type,
                                           p_gre_id_context,
                                           p_jd_context,
                                           l_asg_lock);
    else
        l_return_value := call_balance_user_exit (
                    l_tax_type||'_'||l_ee_or_er||l_tax_balance_category,
                                           l_jd_dimension_string,
                                           l_assignment_action_id,
                                           l_assignment_id,
                                           l_virtual_date,
                                           p_asg_type,
                                           p_gre_id_context,
                                           p_jd_context,
                                           l_asg_lock);

    end if;

    --
    -- added by skutteti to remove the non w2 portion for pre tax REDNS
    --
    /*
    IF (l_return_value <> 0                   AND
       l_tax_type      = 'SIT'                AND
       l_tax_balance_category like '%REDNS' ) THEN
       IF l_tax_balance_category = 'PRE_TAX_REDNS' THEN
          l_non_w2_cat := 'NON_W2_PRE_TAX_DEDNS';
       ELSIF l_tax_balance_category = '401_REDNS' THEN
          l_non_w2_cat := 'NON_W2_DEF_COMP_401';
       ELSIF l_tax_balance_category = '403_REDNS' THEN
          l_non_w2_cat := 'NON_W2_DEF_COMP_403';
       ELSIF l_tax_balance_category = '457_REDNS' THEN
          l_non_w2_cat := 'NON_W2_DEF_COMP_457';
       ELSIF l_tax_balance_category = '125_REDNS' THEN
          l_non_w2_cat := 'NON_W2_SECTION_125';
       ELSIF l_tax_balance_category = 'DEP_CARE_REDNS' THEN
          l_non_w2_cat := 'NON_W2_DEPENDENT_CARE';
       END IF;
       l_return_value := l_return_value - call_balance_user_exit (
                                          'SIT_'||l_non_w2_cat,
                                          l_jd_dimension_string,
                                          l_assignment_action_id,
                                          l_assignment_id,
                                          l_virtual_date,
                                          p_asg_type,
                                          p_gre_id_context,
                                          p_jd_context,
                                          l_asg_lock);
    END IF; -- end of Non W2 portion
    */
    -- tmehra 10-AUG-2001
    -- Above code has been commented out
    -- as it has become redundant due to
    -- the addition of the new -ve feeds
    -- to the SIT Redns
    -- Balances.

  END IF;
END IF;
--
IF l_tax_balance_category = 'SUBJECT' THEN
  l_return_value := us_tax_balance_rep(p_asg_lock,
                                  'SUBJ_WHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date)
                 + us_tax_balance_rep(p_asg_lock,
                                  'SUBJ_NWHABLE',
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
  l_return_value := us_tax_balance_rep(p_asg_lock,
                                  'GROSS',
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
                 - us_tax_balance_rep(p_asg_lock,
                                  'SUBJECT',
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
-- Adding the following code for the NEW TRR which goes of the
-- Balance Reporting Arch.

ELSIF (l_tax_balance_category = 'REDUCED_SUBJ_WHABLE') AND
      NVL(pay_us_balance_view_pkg.get_session_var('REPORT_TYPE'),'NOT_DEFINED') = 'W2' THEN

        l_return_value := us_tax_balance_rep(p_asg_lock,
                                  'SUBJ_WHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date)
                          + us_tax_balance_rep(p_asg_lock,
                                  'SUBJ_NWHABLE',
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
        IF ( l_return_value <> 0 ) THEN

          l_return_value := l_return_value
                 - us_tax_balance_rep(p_asg_lock,
                                  'PRE_TAX_REDNS',
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
  l_return_value := us_tax_balance_rep(p_asg_lock,
                                  'SUBJ_WHABLE',
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
      --
      -- skutteti commented the following and added a new pre tax redns
      --
      --
      --         - us_tax_balance_rep(p_asg_lock,
      --                          '401_REDNS',
      --                          l_tax_type,
      --                          p_ee_or_er,
      --                          p_time_type,
      --                          p_asg_type,
      --                          p_gre_id_context,
      --                          p_jd_context,
      --                          l_assignment_action_id,
      --                          l_assignment_id,
      --                          l_virtual_date)
      --         - us_tax_balance_rep(p_asg_lock,
      --                          '125_REDNS',
      --                          l_tax_type,
      --                          p_ee_or_er,
      --                          p_time_type,
      --                          p_asg_type,
      --                          p_gre_id_context,
      --                          p_jd_context,
      --                          l_assignment_action_id,
      --                          l_assignment_id,
      --                          l_virtual_date)
      --         - us_tax_balance_rep(p_asg_lock,
      --                          'DEP_CARE_REDNS',
      --                          l_tax_type,
      --                          p_ee_or_er,
      --                          p_time_type,
      --                          p_asg_type,
      --                          p_gre_id_context,
      --                          p_jd_context,
      --                          l_assignment_action_id,
      --                          l_assignment_id,
      --                          l_virtual_date)
      ---------------------------------
      -- skutteti added the following
      ---------------------------------
                 - us_tax_balance_rep(p_asg_lock,
                                  'PRE_TAX_REDNS',
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
  l_return_value := us_tax_balance_rep(p_asg_lock,
                                  'REDUCED_SUBJ_WHABLE',
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
                 - us_tax_balance_rep(p_asg_lock,
                                  'TAXABLE',
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
hr_utility.trace('Returning : ' || l_return_value);
--
return l_return_value;
--
END us_tax_balance;
--
BEGIN
  --
  -- Setup the Quarter To Date dimensions in the Cache.
  --
  g_dim_tbl_grp(0) := 'GRE_QTD';
  g_dim_tbl_asg(0) := 'ASG_GRE_QTD';
  g_dim_tbl_jdr(0) := 'N';
  g_dim_tbl_crs(0) := 'select distinct PAA.assignment_id '                 ||
                      'from   pay_assignment_actions PAA, '                ||
                      '       pay_payroll_actions    PPA '                 ||
                      'where  PAA.tax_unit_id = :TAX_UNIT_ID '             ||
                      'and    PPA.payroll_action_id =  '                   ||
                      '                   PAA.payroll_action_id '          ||
                      'and    PPA.effective_date >= '                      ||
             'trunc(:DATE_EARNED,''Q'') '                                  ||
                      'and    PPA.effective_date <= '                      ||
                      ':DATE2_EARNED '                                     ||
                      'and PPA.action_type in (''R'',''Q'',''I'',''B'',''V'') ';
  g_dim_tbl_vtd(0) := 'select max(PAF.effective_end_date) '                ||
                      'from   per_assignments_f PAF '                      ||
                      'where  PAF.assignment_id = :ASSIGNMENT_ID '         ||
                      'and    PAF.payroll_id is not null  '                ||
                      'and    PAF.effective_end_date between '             ||
                      '                 trunc(:DATE_EARNED,''Q'') and '    ||
                      '                 :DATE2_EARNED';
  g_dim_tbl_btt(0) := 'Q';
  --
  -- Setup the Year To Date dimensions in the Cache.
  --
  g_dim_tbl_grp(1) := 'GRE_YTD';
  g_dim_tbl_asg(1) := 'ASG_GRE_YTD';
  g_dim_tbl_jdr(1) := 'N';
  g_dim_tbl_crs(1) := 'select distinct PAA.assignment_id '                 ||
                      'from   pay_assignment_actions PAA, '                ||
                      '       pay_payroll_actions    PPA '                 ||
                      'where  PAA.tax_unit_id = :TAX_UNIT_ID '             ||
                      'and    PPA.payroll_action_id =  '                   ||
                      '                   PAA.payroll_action_id '          ||
                      'and    PPA.effective_date >= '                      ||
                      'trunc(:DATE_EARNED,''Y'') '                         ||
                      'and    PPA.effective_date <= '                      ||
                      ':DATE2_EARNED '                                     ||
                      'and PPA.action_type in (''R'',''Q'',''I'',''B'',''V'') ';
  g_dim_tbl_vtd(1) := 'select max(PAF.effective_end_date) '                ||
                      'from   per_assignments_f PAF '                      ||
                      'where  PAF.assignment_id = :ASSIGNMENT_ID '         ||
                      'and    PAF.payroll_id is not null  '                ||
                      'and    PAF.effective_end_date between '             ||
                      '                 trunc(:DATE_EARNED,''Y'') and '    ||
                      '                 :DATE2_EARNED';
  g_dim_tbl_btt(1) := 'Y';
  --
  -- Setup the Subject to Tax Year To Date dimensions in the Cache.
  --
  g_dim_tbl_grp(2) := 'SUBJECT_TO_TAX_GRE_YTD';
  g_dim_tbl_asg(2) := 'SUBJECT_TO_TAX_ASG_GRE_YTD';
  g_dim_tbl_jdr(2) := 'N';
  g_dim_tbl_crs(2) := 'select distinct PAA.assignment_id '                 ||
                      'from   pay_assignment_actions PAA, '                ||
                      '       pay_payroll_actions    PPA '                 ||
                      'where  PAA.tax_unit_id = :TAX_UNIT_ID '             ||
                      'and    PPA.payroll_action_id =  '                   ||
                      '                   PAA.payroll_action_id '          ||
                      'and    PPA.effective_date >= '                      ||
                      'trunc(:DATE_EARNED,''Y'') '                         ||
                      'and    PPA.effective_date <= '                      ||
                      ':DATE2_EARNED '                                     ||
                      'and PPA.action_type in (''R'',''Q'',''I'',''B'',''V'') ';
  g_dim_tbl_vtd(2) := 'select max(PAF.effective_end_date) '                ||
                      'from   per_assignments_f PAF '                      ||
                      'where  PAF.assignment_id = :ASSIGNMENT_ID '         ||
                      'and    PAF.payroll_id is not null  '                ||
                      'and    PAF.effective_end_date between '             ||
                      '                 trunc(:DATE_EARNED,''Y'') and '    ||
                      '                 :DATE2_EARNED';
  g_dim_tbl_btt(2) := 'Y';
  --
  -- Setup the Year To Date in Jurisdiction dimensions in the Cache.
  --
  g_dim_tbl_grp(3) := 'GRE_JD_YTD';
  g_dim_tbl_asg(3) := 'ASG_JD_GRE_YTD';
  g_dim_tbl_jdr(3) := 'Y';
  g_dim_tbl_crs(3) := 'select distinct PAR.assignment_id '                 ||
                      'from pay_balance_types      PBT, '                  ||
                      '     pay_us_asg_reporting   PAR '                   ||
                      'where PAR.tax_unit_id = :TAX_UNIT_ID '              ||
                      'and   PBT.balance_type_id = :BALANCE_TYPE_ID '      ||
                      'and   PBT.jurisdiction_level <> 0 '                 ||
                      'and   substr(PAR.jurisdiction_code, 1, '            ||
                            'PBT.jurisdiction_level) = '                   ||
                            'substr(:JURISDICTION_CODE, 1, '               ||
                            'PBT.jurisdiction_level) '                     ||
                      'and   exists (select 1 '                            ||
                      '              from pay_payroll_actions    PPA, '    ||
                      '                   pay_assignment_actions PAA '     ||
                      '              where PAA.assignment_id = '           ||
                                            'PAR.assignment_id '           ||
                      '               and  PAA.tax_unit_id = '             ||
                                            'PAR.tax_unit_id '             ||
                      '               and  PPA.payroll_action_id = '       ||
                                            'PAA.payroll_action_id '       ||
                      '               and  PPA.effective_date >= '         ||
                                            'trunc(:DATE_EARNED,''Y'') '   ||
                      '               and  PPA.effective_date <= '         ||
                                            ':DATE2_EARNED  '              ||
                      '                and PPA.action_type in (''R'',''Q'',''I'',''B'',''V'') )';
  g_dim_tbl_vtd(3) := 'select max(PAF.effective_end_date) '                ||
                      'from   per_assignments_f PAF '                      ||
                      'where  PAF.assignment_id = :ASSIGNMENT_ID '         ||
                      'and    PAF.payroll_id is not null  '                ||
                      'and    PAF.effective_end_date between '             ||
                      '                 trunc(:DATE_EARNED,''Y'') and '    ||
                      '                 :DATE2_EARNED';
  g_dim_tbl_btt(3) := 'Y';
  -- Set the next free cache space.
  g_nxt_free_dim := 4;


--  hr_utility.trace_on(null,'tx');
end pay_us_tax_bals_pkg;

/
