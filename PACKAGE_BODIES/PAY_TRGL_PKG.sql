--------------------------------------------------------
--  DDL for Package Body PAY_TRGL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TRGL_PKG" AS
/* $Header: pytrangl.pkb 120.15.12010000.3 2009/02/26 06:36:56 pparate ship $ */
--
/*
 * ***************************************************************************
--
  Copyright (c) Oracle Corporation (UK) Ltd 1993,1994. All Rights Reserved.
--
  PRODUCT
    Oracle*Payroll
--
  NAME
    PAY_TRGL_PKG  - Procedure to transfer pay costs to General Ledger.
--
--
  DESCRIPTION
    The procedure sums are costs for each cost centre for all payroll runs
    which occurr within the tansfer period. The costs are summed across
    assignments but distinct entries are created for debit and credit for
    each currency.
--
  MODIFIED          DD-MON-YYYY
 115.49  pparate    26-FEB-2009  Added change to query in procedure
                                 trans_pay_costs_mt for better perf.
                                 Bug 8278294
 115.48  pparate    16-SEP-2008  Added an OR condition for binding sql
                                 variables in case of costing of payments.
				 (Fix for bug 7401269).
 115.47  pkagrawa   06-FEB-2008  Added ledger_id column for insert into
                                 gl_interface for R12
 115.46  alogue     04-JUL-2007  Avoid Payment Costings populating
                                 gl_interface.segment columns.
                                 Bug 6169000.
 115.45  alogue     04-MAY-2007  Avoid double postings for consolidation
                                 set payment costs. Bug 6027376.
 115.44  alogue     30-JAN-2007  Avoid double posting for tax_unit_id
                                 balance adjustments. Bug 5854583.
 115.43  alogue     04-JAN-2007  Avoid gscc error in last change.
 115.42  alogue     04-JAN-2007  Avoid gscc error in last change.
 115.41  alogue     03-JAN-2007  Re-implement Bug 5606113 as string
                                 concatenation to avoid needless
                                 performance loss.
 115.40  alogue     20-NOV-2006  Performance fixes (hints) to gl_interface
                                 insert statement. Bug 5671609.
 115.39  alogue     03-NOV-2006  Avoid double postings for consolidation
                                 set estimate costs. Bug 5606113.
 115.38  alogue     06-JUN-2006  Performance fixes (hints) to cursor
                                 transfer_payrolls. Bug 5243949.
 115.37  alogue     15-MAY-2006  Handle External Manual Payments to be
                                 excluded (not transferred). Bug 5208522.
 115.36  alogue     14-MAR-2006  Accounting Date in gl_interface should
                                 have null time fields. Bug 5089908.
 115.35  alogue     02-NOV-2005  Post Estimate Reversals on period end
                                 date if TGL_DATE_USED set to 'EVE'.
                                 Bug 4709735.
 115.34  alogue     07-OCT-2005  Support of Sub Ledger Accouting (SLA).
 115.33  alogue     22-AUG-2005  Support of Payment Costs.
 115.32  alogue     15-NOV-2004  Use of transfer_to_gl_flag in pay_costs.
                                 Bug 4013881.
 115.31  alogue     03-NOV-2004  Always get transfer_to_gl_flag from
                                 distributed element for distributed
                                 costs.  Bug 3972448.
 115.30  alogue     05-OCT-2004  Support of original entry id balance
                                 adjustments. Bug 3911521.
 115.29  alogue     09-DEC-2003  Populate gl_interface.reference25
                                 with Runs' payroll_action_id.
                                 Bug 3306461.
 115.28  alogue     30-OCT-2003  Use per_all_assignments_f,
                                 pay_all_payrolls and
                                 per_business_groups_perf.
 115.27  alogue     23-JUL-2003  Enhance to process run actions for the
                                 specified payroll regardless of
                                 whether assignment is still on that
                                 payroll. Bug 2396819.
 115.26  alogue     02-JUN-2003  Support of TGL_REVB_ACC_DATE action
                                 parameter.  Population of reference24
                                 in gl_interface.  Bug 2987235.
 115.25  alogue     24-APR-2003  Hints in gl_interface insert statement
                                 in trans_pay_costs_mt. Bug 2919000.
 115.24  alogue     10-FEB-2003  Support of Estimate Cost Process.
                                 Bug 2794030.
 115.23  alogue     21-NOV-2002  Support of grandchild (and further)
                                 Run child actions.
 115.22  alogue     20-NOV-2002  Hints for Performance Improvements.
                                 Bug 2676232.
 115.21  alogue     20-SEP-2002  dbdrv lines.
 115.20  alogue     20-SEP-2002  Support of transfer of prorated
                                 elements.  Corresponding fix for
                                 changes to Costing under bug 2437171.
                                 Bug 2574990.
 115.19  alogue     16-NOV-2001  Fix to last change to multi-threaded
                                 solution.  Bug 2110560.
 115.17  alogue     24-AUG-2001  Performance enhancement : use of hint
                                 in single-threaded solution. Iterative
                                 Engine support whereby TGL aa only
                                 interlocks master aas from run.
 115.16  alogue     26-APR-2001  Performance enhancement : use of hints
                                 in multi-threaded solution.
 115.15  alogue     26-APR-2001  Performance enhancement : use of hints
                                 in single-threaded solution.
 115.14  alogue     18-JAN-2001  Enhanced Multi-threaded version to
                                 include all latest enhancements.
                                 Bug 1561507.
 115.13  alogue     17-NOV-2000  Handle non existant Conversion Rate Type
                                 Bug 1504406.
 115.12  alogue     10-OCT-2000  Population of gl_interface.group_id
                                 with tgl payroll_action_id if
                                 TGL_GROUP_ID pay_action_parameter
                                 is set to Y. Bug 1073147.
 115.11  alogue     21-SEP-2000  Join to per_assignments_f at runs
                                 effective_date in main cursor to
                                 ensure assignments costs are transferred
                                 when assignemnt has changed payroll
                                 between runs date_earned and
                                 effective_date. Bug 1322332.
 115.10  alogue     04-SEP-2000  EFC support : foreign currency
                                 handling by population of
                                 user_currency_conversion_type
                                 and currency_conversion_date in
                                 gl_interface. These columns are
                                 ignored if GL is in the same currency.
 115.9   alogue     29-JUN-2000  Support of TGL_DATE_USED
                                 pay_action_parameter to switch to
                                 using date_earned for accounting_date.
                                 Bug 1343096.
 115.8   alogue     01-FEB-2000  Transferal of retrocosting results
                                 performance enhancement.
 115.7   alogue     24-JAN-2000  Transferal of retrocosting results.
 115.6   alogue     10-NOV-1999  Get user_je_source_name from
                                 gl_je_sources_vl and user_je_category_name
                                 from gl_je_categories_vl instead of
                                 using PAY_PAYROLL lookup. Bug 1066820.
 115.5   alogue     25-OCT-1999  Use of PAY_PAYROLL lookup to avoid
                                 entering of hard-coded untranslated
                                 values into user_je_source_name and
                                 user_je_category_name of gl_interface.
                                 Bug 893879.
 110.9   alogue     25-AUG-1998  Multi-threaded Implementation.
 110.8   alogue     09-JUL-1998  Performance improvement of the main
                                 insert statement, disabled business
                                 group index on element link.
 110.7   alogue     14-MAY-1998  Performance improvement of the
                                 aa update statement, disabled
                                 payroll index.
 110.6   alogue     10-FEB-1998  Performance Enhancement. Bug 633879.
 110.5   alogue     10-FEB-1998  Performance Enhancement. Bug 625189.
 110.4   alogue     02-JAN-1998  Support for transferal of balance
                                 adjustments.
 110.3   alogue     26-NOV-1997  Bug 589335.  Now handles legislative
                                 indirect element entries with links set to
                                 link_to_all_payrolls.
 110.2   alogue     18-NOV-1997  Bug 587439 transferring non-default
                                 consolidation set fix.
  40.9   alogue     25-JUN-1997  Bug 486556 reverse backport change.
  40.8   alogue     25-JUN-1997  Bug 486556 prod-14 backport. Add
                                 pay_basis_id and employment_category to
                                 link qualification in element deleted part
                                 of 'INSERT INTO gl_interface' cursor.
  40.7   alogue     19-JUN-1997  Catered for pay_run_results source_id
                                 is reversed run_result_id in case of
                                 a reversal. (Result of bug 507602 fix.)
  40.6   jalloun    30-JUL-1996  Added error handling.
  40.5   nbristow   19-JUL-1996  Bug 368244. The costing process, thus
                                 the transfer to gl process has had to be
                                 changed to cost as of date earned.
  40.4   nbristow   14-JUN-1996  The UNION in the sql to insert into the
                                 gl_interface table was incorrectly
                                 returning indirects on both sides of the
                                 union.
  40.3   nbristow   14-JUN-1996  Bug 374389. Run results for reversal of
                                 indirect results now have a source type
                                 of V.
  40.1   mwcallag   16-Jun-1995  The select for insert into the GL interface
                                 table has been modified to check
                                 the transfer to GL flag held on the element
                                 link table, and also to deal with costed
                                 hours correctly.  More details are given
                                 in the notes below.
  40.0   A.Frith    14-May-1994	 Created.
--
--
  DESCRIPTION
    Transfer to GL procedure.
--
  NOTES
    Transfer to GL flag
    -------------------
    The Transfer to GL flag is a check box on the element link screen, and
    held on the table pay_element_links_f.  In release 9 this flag used to be
    copied down to the costing table.  However, this creates problems if the
    user subsequently goes back and  modifies the flag.  So, for release 10,
    it is only held on the link table.  The SQL needed to track back to the
    element link table from pay_run_results is very similar to the SQL for the
    costing process (file pycos.lpc).  The SQL consists of a union, with one
    half reaching the element link table via the element entry table.  The
    other half is needed for when the element entry has been deleted following
    a run.  In this case the element link table is reached via the element
    type table using the partial matching code.
--
    Costed Hours
    ------------
    The costing process will only cost run results whose unit of measure are
    either money or hours.  For money, the currency code value is used for the
    currency code column in the GL interface table.  For costed hours, we
    enter 'STAT' in the currency code column (statistical information).  This
    ensures the entries are kept separate, otherwise it would be possible for
    a money value of 100 pounds and a time of 10:15 which both have the same
    cost flex to be added together as 110.25.
--
    Retrocosting Results.
    ---------------------
    Correction results created by the Retrocosting process populate reference23
    with the date of the original entry that was in error and is being corrected.
--
    Foreign Currency Units.
    ------------------------
    The GL may be working in a different currency than Payroll and hence we
    always populate user_currency_conversion_type and currency_conversion_date
    in gl_interface so that GL takes care of currency coversion if necessary.
    These columns are ignored if GL is in the same currency.
--
    Populating Group_id.
    --------------------
    The group_Id column is populated with the TGL payroll_action_id only if
    the TGL_GROUP_ID pay_action_parameter is defined with a value of 'Y'.
--
    Populating Reference25.
    -----------------------
    The reference25 column is populated with the Run payroll_action_id so that
    an audit trail exists from GL all the way back to element entry, assignment,
    etc.
*/
--
-- date used cache for value of TGL_DATE_USED pay_action_parameter
g_date_used  VARCHAR2(80) := null;

/* SINGLE-THREADED SOLUTION */
--
PROCEDURE trans_pay_costs
	(i_payroll_action_id NUMBER)
IS
--
--
--  	Cursor to get the payroll run actions which are processed by this
--	transfer to general ledger action. An assignment action will exist
--	for each assignment action in a payroll run payroll action which
--	has been costed for this transfer to general ledger payroll action.
--
CURSOR transfer_payrolls (i_action_id           NUMBER)
IS
SELECT  DISTINCT ppa2.payroll_action_id,
        ppa1.payroll_action_id,
        pp.payroll_id,
        pp.gl_set_of_books_id
FROM    pay_payroll_actions      ppa1,  -- Cost pay actions
        pay_assignment_actions   pa1,   -- Cost asg actions.
        pay_action_interlocks    pi3,   -- Cost - Run
        pay_action_interlocks    pi1,   -- Cost - Trans GL
        pay_all_payrolls_f           pp,
        pay_action_classifications pac,
        pay_payroll_actions      ppa2,  -- Payroll run actions.
        pay_assignment_actions   pa2,   -- Payroll run asg actions.
        pay_action_interlocks    pi2,   -- Run - Trans GL
        pay_assignment_actions   pa,    -- Trans GL asg actions
        pay_payroll_actions      ppa    -- Trans GL pay actions
WHERE   ppa.payroll_action_id    = i_action_id
AND     pa.payroll_action_id     = ppa.payroll_action_id
AND     pa.action_status         <> 'C'
AND     pi2.locking_action_id    = pa.assignment_action_id
AND     pa2.assignment_action_id = pi2.locked_action_id
AND     ppa2.payroll_action_id   = pa2.payroll_action_id
AND     ppa2.consolidation_set_id +0 = ppa.consolidation_set_id
AND     pac.action_type          = ppa2.action_type
AND     pac.classification_name  = 'COSTED'
AND     pp.payroll_id            = ppa2.payroll_id
AND     pi1.locking_action_id    = pa.assignment_action_id
AND     pa1.assignment_action_id = pi1.locked_action_id
AND     pa1.assignment_action_id <> pa2.assignment_action_id
AND     pi3.locking_action_id    = pa1.assignment_action_id
AND     pa2.assignment_action_id = pi3.locked_action_id
AND     ppa1.payroll_action_id   = pa1.payroll_action_id
AND     ppa.effective_date
        BETWEEN pp.effective_start_date
        AND     pp.effective_end_date
ORDER by pp.payroll_id;
--
--
--	Cursor to get the map of pay cost segments to gl account segments
--	for the payroll. The set of books for the payroll may be date
--	effectively changed so the set of books id is the one which is
--	date effective at the effective run date.
--
CURSOR flex_segments (i_payroll_id NUMBER,
                      i_gl_sets_of_books_id NUMBER)
IS
SELECT  gl_account_segment,
        payroll_cost_segment
FROM    pay_payroll_gl_flex_maps
WHERE   payroll_id = i_payroll_id
AND     gl_set_of_books_id = i_gl_sets_of_books_id;
--
--
pay_segment_list   	VARCHAR2(1200);	-- Dynamically built varchar
					-- used in the select statement.
gl_segment_list    	VARCHAR2(930);	-- Dynamically built varchar
					-- for insert statement.
sql_curs 		NUMBER;		-- For dynamic sql statement.
rows_processed 		INTEGER;
prev_payroll_id         NUMBER := 0;
prev_sob_id             NUMBER := 0;
l_currency_type         VARCHAR2(30);
c_run_action_id   	NUMBER;
c_cost_action_id        NUMBER;
c_payroll_id		NUMBER;
c_accounting_date       DATE;
c_conversion_date       DATE;
c_run_date              DATE;
c_run_date_earned       DATE;
l_bus_grp_id            NUMBER;
c_set_of_books_id	NUMBER;
l_source_name           VARCHAR2(25);
l_category_name         VARCHAR2(25);
l_date_used             VARCHAR2(80);
l_rvb_acc_date          VARCHAR2(80);
l_group_id              VARCHAR2(80);
--
BEGIN
--
      hr_utility.set_location('pytrgl.trans_pay_costs',10);
--
      sql_curs :=dbms_sql.open_cursor;
--
      OPEN transfer_payrolls (i_payroll_action_id);
--
      hr_utility.set_location('pytrgl.trans_pay_costs',20);
--
--    Bug 1066820 avoid passing in hard coded strings.
--
      select user_je_source_name
      into l_source_name
      from gl_je_sources_vl
      where je_source_name = 'Payroll';
--
      hr_utility.set_location('pytrgl.trans_pay_costs',25);
--
      select user_je_category_name
      into l_category_name
      from gl_je_categories_vl
      where je_category_name = 'Payroll';
--
      hr_utility.set_location('pytrgl.trans_pay_costs',27);
--
--    Find if use an accouting date of date_earned
--    (default is effective_date)
--
      begin
        select parameter_value
        into  l_date_used
        from pay_action_parameters
        where parameter_name = 'TGL_DATE_USED';
      exception
        when others then
           l_date_used := 'P';
      end;
--
      hr_utility.set_location('pytrgl.trans_pay_costs',28);
--
--    Find if use an accouting date of date_earned
--    (default is effective_date)
--
      begin
        select parameter_value
        into  l_rvb_acc_date
        from pay_action_parameters
        where parameter_name = 'TGL_REVB_ACC_DATE';
      exception
        when others then
           l_rvb_acc_date := 'P';
      end;
--
      hr_utility.set_location('pytrgl.trans_pay_costs',29);
--
--    Find if should populate gl_interface.group_id
--    (default is to leave this column blank)
--    If so we populate it with the TGL payroll_action_id
--
      begin
        select parameter_value
        into  l_group_id
        from pay_action_parameters
        where parameter_name = 'TGL_GROUP_ID';
      exception
        when others then
           l_group_id := 'N';
      end;
--
      hr_utility.set_location('pytrgl.trans_pay_costs',30);
--
--    Process each run action in turn. Each run action may be for
--    several payrolls. Each payroll will be processed separately.
      LOOP
--
        FETCH transfer_payrolls INTO
          c_run_action_id,		-- payroll run action
          c_cost_action_id,             -- cost action
	  c_payroll_id,
          c_set_of_books_id;
--
        hr_utility.set_location('pytrgl.trans_pay_costs',31);
--
        EXIT WHEN transfer_payrolls%NOTFOUND;
--
        hr_utility.set_location('pytrgl.trans_pay_costs',32);
--
        select decode(ppa1.action_type, 'S', ppa1.effective_date,
           decode(ppa2.action_type, 'B', decode(l_rvb_acc_date, 'C', ppa1.effective_date,
                                                                     ppa2.effective_date),
                                    'V', decode(l_rvb_acc_date, 'C', ppa1.effective_date,
                                                                     ppa2.effective_date),
                                    decode(l_date_used, 'E', ppa2.date_earned,
                                                             ppa2.effective_date))),
               ppa2.effective_date,
               ppa2.date_earned,
               ppa2.business_group_id
        into   c_accounting_date,
               c_run_date,
               c_run_date_earned,
               l_bus_grp_id
        from   pay_payroll_actions ppa1,  -- Cost pay actions
               pay_payroll_actions ppa2   -- Payroll run action
        where  ppa1.payroll_action_id = c_cost_action_id
        and    ppa2.payroll_action_id = c_run_action_id;
--
        hr_utility.set_location('pytrgl.trans_pay_costs',35);
--
--      Get payrolls currency conversion rate type
--      handle fact that it may be null
--
        begin
           l_currency_type := hruserdt.get_table_value(l_bus_grp_id,
                           'EXCHANGE_RATE_TYPES', 'Conversion Rate Type',
                           'PAY',c_accounting_date);
           c_conversion_date := c_accounting_date;

        exception
           when no_data_found then
              hr_utility.set_location('pytrgl.trans_pay_costs',37);
              l_currency_type := null;
              c_conversion_date := null;
        end;
--
--      Only bother to rebuild segment lists if they are different from
--      previous iteration.  This avoids rebuilding when a run has been costed
--      and then retrocosted.
--
        if (c_payroll_id <> prev_payroll_id or
            c_set_of_books_id <> prev_sob_id) then
--
           pay_segment_list := NULL;
           gl_segment_list := NULL;
--
           hr_utility.set_location('pytrgl.trans_pay_costs',40);
--
--   	   Dynamically build up the segment lists for the payroll.
           FOR flex_segs IN flex_segments ( c_payroll_id, c_set_of_books_id )
	   LOOP
--
             hr_utility.set_location('pytrgl.trans_pay_costs',50);
--
	     gl_segment_list := gl_segment_list ||
		   flex_segs.gl_account_segment ||',';
--
             hr_utility.set_location('pytrgl.trans_pay_costs',60);
--
--	     Payroll segment list needs to MIN() function as not grouped
--	     by each segment.
--
	     pay_segment_list := pay_segment_list || 'MIN(caf.' ||
	   	flex_segs.payroll_cost_segment||'),';
--
	   END LOOP;
--
        end if;
--
        prev_payroll_id := c_payroll_id;
        prev_sob_id := c_set_of_books_id;
--
	hr_utility.set_location('pytrgl.trans_pay_costs',70);
--
--	Put the statement into the cursor and parse. Don't know how long
--	the segment list is so we cannot bind to variables.
--

-- For Post 11i
if (PAY_ADHOC_UTILS_PKG.chk_post_r11i = 'Y') then
	dbms_sql.parse(sql_curs,
        'INSERT INTO gl_interface
            (status,
	     ledger_id,
             set_of_books_id,
             user_je_source_name,
             user_je_category_name,
             accounting_date,
             currency_code,
             group_id,
             date_created,
             created_by,
             actual_flag,'||
    	     gl_segment_list||'
             reference21,
             reference22,
             reference23,
             reference24,
             reference25,
             user_currency_conversion_type,
             currency_conversion_date,
             entered_dr,
             entered_cr)
        SELECT  /*+ ORDERED */
              ''NEW'',
    	      :c_set_of_books_id,
    	      :c_set_of_books_id,
              :l_source_name,
              :l_category_name,
	      :c_accounting_date,
    	      decode (IV.uom, ''M'', et.output_currency_code, ''STAT''),
              decode (:l_group_id, ''Y'', :i_payroll_action_id),
 	      trunc(sysdate),
    	      801,
              ''A'','||
    	      pay_segment_list||'
              :i_payroll_action_id,
              cst.cost_allocation_keyflex_id,
              :c_run_date,
              :c_run_date_earned,
              :c_run_action_id,
              :l_currency_type,
              :c_conversion_date,
              SUM(DECODE(cst.debit_or_credit,''D'',cst.costed_value,0)),
              SUM(DECODE(cst.debit_or_credit,''C'',cst.costed_value,0))
        FROM   pay_payroll_actions      ppa,  -- Run payroll action
               pay_payroll_actions      ppa1, -- Cost payroll action
               per_all_assignments_f    per,
               pay_assignment_actions   pa,   -- TGL assignment action
               pay_action_interlocks    pi,   -- interlock to costing
               pay_assignment_actions   pa1,  -- Cost assignment action
               pay_action_interlocks    pi2,  -- interlock to run
               pay_assignment_actions   pa3,  -- run master assignment action
               pay_assignment_actions   pa2,  -- run assignment action
               pay_costs                cst,
               pay_cost_allocation_keyflex caf,
               pay_run_results          rr,
               pay_input_values_f       IV,
               pay_element_types_f      et
        WHERE  pa.payroll_action_id     = :i_payroll_action_id
        AND    pa.assignment_id         = per.assignment_id
        AND    per.payroll_id           = :c_payroll_id
        AND    pi.locking_action_id     = pa.assignment_action_id
        AND    pa1.assignment_action_id = pi.locked_action_id
        AND    ppa1.payroll_action_id   = pa1.payroll_action_id
        AND    ppa1.payroll_action_id   = :c_cost_action_id
        AND    cst.assignment_action_id = pa1.assignment_action_id
        AND    pa2.payroll_action_id    = :c_run_action_id
        AND    ppa.payroll_action_id    = :c_run_action_id
        AND    pa3.payroll_action_id    = :c_run_action_id
        AND    pi2.locking_action_id    = pa.assignment_action_id
        AND    pa2.assignment_id        = pa.assignment_id
        AND    pa3.assignment_id        = pa.assignment_id
        and    pa3.source_action_id is null
        AND    pa3.assignment_action_id = pi2.locked_action_id
        AND    rr.assignment_action_id  = pa2.assignment_action_id
        AND    cst.run_result_id        = rr.run_result_id
        and    RR.element_type_id       = IV.element_type_id
        AND    IV.input_value_id        = CST.input_value_id
        and    ppa.date_earned    between IV.effective_start_date
                                      and IV.effective_end_date
        AND    EXISTS
              (select RR1.run_result_id
               from   pay_run_results         RR1
               ,      pay_run_results         RR2
               ,      pay_element_entries_f   EE1
               ,      pay_element_links_f     EL1
               where  RR1.assignment_action_id  = pa2.assignment_action_id
               and    RR1.source_id             = RR2.run_result_id
               and    RR1.source_type      NOT IN (''E'', ''I'', ''V'')
               and    RR2.source_id             = EE1.element_entry_id
               and    least(nvl(RR2.end_date, ppa.date_earned), ppa.date_earned)
                                          between EE1.effective_start_date
                                              and EE1.effective_end_date
               and    EL1.element_link_id       = EE1.element_link_id
               and    ppa.date_earned     between EL1.effective_start_date
                                              and EL1.effective_end_date
               and    EL1.transfer_to_gl_flag   = ''Y''
               and    RR1.run_result_id         = nvl(CST.distributed_run_result_id,
                                                      CST.run_result_id)
               UNION ALL
              select RR1.run_result_id
               from   pay_run_results         RR1
               ,      pay_element_entries_f   EE1
               ,      pay_element_links_f     EL1
               where  RR1.assignment_action_id  = pa2.assignment_action_id
               and    RR1.source_id             = EE1.element_entry_id
               and    RR1.source_type      NOT IN (''R'', ''I'', ''V'')
               and    least(nvl(RR1.end_date, ppa.date_earned), ppa.date_earned)
                                          between EE1.effective_start_date
                                              and EE1.effective_end_date
               and    EL1.element_link_id       = EE1.element_link_id
               and    ppa.date_earned     between EL1.effective_start_date
                                              and EL1.effective_end_date
               and    EL1.transfer_to_gl_flag   = ''Y''
               and    RR1.run_result_id         = nvl(CST.distributed_run_result_id,
                                                      CST.run_result_id)
               UNION ALL
               select RR1.run_result_id
         FROM     pay_run_results                  RR1,
                  per_all_assignments_f            PERA,
                  pay_element_types_f              ET1,
                  pay_element_classifications      EC,
                  pay_element_links_f              EL1
         WHERE    RR1.assignment_action_id  = pa2.assignment_action_id
         AND      RR1.run_result_id         = nvl(CST.distributed_run_result_id,
                                                  CST.run_result_id)
         AND (
            (NOT EXISTS           /* look for deleted element entries */
           (SELECT  null
            FROM    pay_element_entries_f            EE1
            WHERE   RR1.source_id                   = EE1.element_entry_id
            AND     RR1.source_type                IN (''E'', ''I'')
            AND     least(nvl(RR1.end_date, ppa.date_earned), ppa.date_earned)
                                              BETWEEN EE1.effective_start_date
                                                  AND EE1.effective_end_date
           )
           AND NOT EXISTS
           (SELECT  null
            FROM    pay_run_results                  RR2,
                    pay_element_entries_f            EE1
            WHERE   RR2.source_id                   = EE1.element_entry_id
            AND     RR1.source_type                IN (''R'', ''V'')
            AND     RR1.source_id                   = RR2.run_result_id
            AND     least(nvl(RR2.end_date, ppa.date_earned), ppa.date_earned)
                                              BETWEEN EE1.effective_start_date
                                                  AND EE1.effective_end_date
           ))
                  OR   RR1.source_type          IN (''I'', ''V'')
             )
         AND      RR1.assignment_action_id        = pa2.assignment_action_id
         AND      RR1.element_type_id             = ET1.element_type_id
         AND      ppa.date_earned           BETWEEN ET1.effective_start_date
                                               AND ET1.effective_end_date
         AND      ET1.classification_id           = EC.classification_id
         AND      ET1.element_type_id             = EL1.element_type_id
         AND      ppa.date_earned          BETWEEN EL1.effective_start_date
                                               AND EL1.effective_end_date
         AND      EL1.costable_type              <> ''N''
         and      EL1.transfer_to_gl_flag         = ''Y''
         AND      PERA.assignment_id             = pa2.assignment_id
         AND      PERA.business_group_id         = EL1.business_group_id +0
         AND      ppa.date_earned          BETWEEN PERA.effective_start_date
                                               AND PERA.effective_end_date
         AND      ((EL1.payroll_id               IS NOT NULL
         AND        EL1.payroll_id                = PERA.payroll_id)
         OR        (EL1.link_to_all_payrolls_flag = ''Y''
         AND        PERA.payroll_id             IS NOT NULL)
         OR       EL1.payroll_id                 IS NULL)
         AND     (EL1.organization_id             = PERA.organization_id
         OR       EL1.organization_id            IS NULL)
         AND     (EL1.position_id                 = PERA.position_id
         OR       EL1.position_id                IS NULL)
         AND     (EL1.job_id                      = PERA.job_id
         OR       EL1.job_id                     IS NULL)
         AND     (EL1.grade_id                    = PERA.grade_id
         OR       EL1.grade_id                   IS NULL)
         AND     (EL1.location_id                 = PERA.location_id
         OR       EL1.location_id                IS NULL)
         AND     (EL1.pay_basis_id                = PERA.pay_basis_id
         OR       EL1.pay_basis_id               IS NULL)
         AND     (EL1.employment_category         = PERA.employment_category
         OR       EL1.employment_category        IS NULL)
         AND      (EL1.people_group_id           IS NULL
         OR       EXISTS
            (SELECT  1
            FROM    pay_assignment_link_usages_f    PAL
            WHERE   PAL.assignment_id             = PERA.assignment_id
            AND     PAL.element_link_id           = EL1.element_link_id
           AND     ppa.date_earned          BETWEEN PAL.effective_start_date
                                                AND PAL.effective_end_date))
        )
        AND    et.element_type_id	= rr.element_type_id
	AND    caf.cost_allocation_keyflex_id = cst.cost_allocation_keyflex_id
        AND    ppa.effective_date
		BETWEEN per.effective_start_date
		AND	per.effective_end_date
        AND    ppa.date_earned
		BETWEEN et.effective_start_date
		AND 	et.effective_end_date
        GROUP BY cst.cost_allocation_keyflex_id,
 	 	 cst.debit_or_credit,
		 decode (IV.uom, ''M'', et.output_currency_code, ''STAT'')',
	dbms_sql.v7);

else
	dbms_sql.parse(sql_curs,
        'INSERT INTO gl_interface
            (status,
             set_of_books_id,
             user_je_source_name,
             user_je_category_name,
             accounting_date,
             currency_code,
             group_id,
             date_created,
             created_by,
             actual_flag,'||
    	     gl_segment_list||'
             reference21,
             reference22,
             reference23,
             reference24,
             reference25,
             user_currency_conversion_type,
             currency_conversion_date,
             entered_dr,
             entered_cr)
        SELECT  /*+ ORDERED */
              ''NEW'',
    	      :c_set_of_books_id,
              :l_source_name,
              :l_category_name,
	      :c_accounting_date,
    	      decode (IV.uom, ''M'', et.output_currency_code, ''STAT''),
              decode (:l_group_id, ''Y'', :i_payroll_action_id),
 	      trunc(sysdate),
    	      801,
              ''A'','||
    	      pay_segment_list||'
              :i_payroll_action_id,
              cst.cost_allocation_keyflex_id,
              :c_run_date,
              :c_run_date_earned,
              :c_run_action_id,
              :l_currency_type,
              :c_conversion_date,
              SUM(DECODE(cst.debit_or_credit,''D'',cst.costed_value,0)),
              SUM(DECODE(cst.debit_or_credit,''C'',cst.costed_value,0))
        FROM   pay_payroll_actions      ppa,  -- Run payroll action
               pay_payroll_actions      ppa1, -- Cost payroll action
               per_all_assignments_f    per,
               pay_assignment_actions   pa,   -- TGL assignment action
               pay_action_interlocks    pi,   -- interlock to costing
               pay_assignment_actions   pa1,  -- Cost assignment action
               pay_action_interlocks    pi2,  -- interlock to run
               pay_assignment_actions   pa3,  -- run master assignment action
               pay_assignment_actions   pa2,  -- run assignment action
               pay_costs                cst,
               pay_cost_allocation_keyflex caf,
               pay_run_results          rr,
               pay_input_values_f       IV,
               pay_element_types_f      et
        WHERE  pa.payroll_action_id     = :i_payroll_action_id
        AND    pa.assignment_id         = per.assignment_id
        AND    per.payroll_id           = :c_payroll_id
        AND    pi.locking_action_id     = pa.assignment_action_id
        AND    pa1.assignment_action_id = pi.locked_action_id
        AND    ppa1.payroll_action_id   = pa1.payroll_action_id
        AND    ppa1.payroll_action_id   = :c_cost_action_id
        AND    cst.assignment_action_id = pa1.assignment_action_id
        AND    pa2.payroll_action_id    = :c_run_action_id
        AND    ppa.payroll_action_id    = :c_run_action_id
        AND    pa3.payroll_action_id    = :c_run_action_id
        AND    pi2.locking_action_id    = pa.assignment_action_id
        AND    pa2.assignment_id        = pa.assignment_id
        AND    pa3.assignment_id        = pa.assignment_id
        and    pa3.source_action_id is null
        AND    pa3.assignment_action_id = pi2.locked_action_id
        AND    rr.assignment_action_id  = pa2.assignment_action_id
        AND    cst.run_result_id        = rr.run_result_id
        and    RR.element_type_id       = IV.element_type_id
        AND    IV.input_value_id        = CST.input_value_id
        and    ppa.date_earned    between IV.effective_start_date
                                      and IV.effective_end_date
        AND    EXISTS
              (select RR1.run_result_id
               from   pay_run_results         RR1
               ,      pay_run_results         RR2
               ,      pay_element_entries_f   EE1
               ,      pay_element_links_f     EL1
               where  RR1.assignment_action_id  = pa2.assignment_action_id
               and    RR1.source_id             = RR2.run_result_id
               and    RR1.source_type      NOT IN (''E'', ''I'', ''V'')
               and    RR2.source_id             = EE1.element_entry_id
               and    least(nvl(RR2.end_date, ppa.date_earned), ppa.date_earned)
                                          between EE1.effective_start_date
                                              and EE1.effective_end_date
               and    EL1.element_link_id       = EE1.element_link_id
               and    ppa.date_earned     between EL1.effective_start_date
                                              and EL1.effective_end_date
               and    EL1.transfer_to_gl_flag   = ''Y''
               and    RR1.run_result_id         = nvl(CST.distributed_run_result_id,
                                                      CST.run_result_id)
               UNION ALL
              select RR1.run_result_id
               from   pay_run_results         RR1
               ,      pay_element_entries_f   EE1
               ,      pay_element_links_f     EL1
               where  RR1.assignment_action_id  = pa2.assignment_action_id
               and    RR1.source_id             = EE1.element_entry_id
               and    RR1.source_type      NOT IN (''R'', ''I'', ''V'')
               and    least(nvl(RR1.end_date, ppa.date_earned), ppa.date_earned)
                                          between EE1.effective_start_date
                                              and EE1.effective_end_date
               and    EL1.element_link_id       = EE1.element_link_id
               and    ppa.date_earned     between EL1.effective_start_date
                                              and EL1.effective_end_date
               and    EL1.transfer_to_gl_flag   = ''Y''
               and    RR1.run_result_id         = nvl(CST.distributed_run_result_id,
                                                      CST.run_result_id)
               UNION ALL
               select RR1.run_result_id
         FROM     pay_run_results                  RR1,
                  per_all_assignments_f            PERA,
                  pay_element_types_f              ET1,
                  pay_element_classifications      EC,
                  pay_element_links_f              EL1
         WHERE    RR1.assignment_action_id  = pa2.assignment_action_id
         AND      RR1.run_result_id         = nvl(CST.distributed_run_result_id,
                                                  CST.run_result_id)
         AND (
            (NOT EXISTS           /* look for deleted element entries */
           (SELECT  null
            FROM    pay_element_entries_f            EE1
            WHERE   RR1.source_id                   = EE1.element_entry_id
            AND     RR1.source_type                IN (''E'', ''I'')
            AND     least(nvl(RR1.end_date, ppa.date_earned), ppa.date_earned)
                                              BETWEEN EE1.effective_start_date
                                                  AND EE1.effective_end_date
           )
           AND NOT EXISTS
           (SELECT  null
            FROM    pay_run_results                  RR2,
                    pay_element_entries_f            EE1
            WHERE   RR2.source_id                   = EE1.element_entry_id
            AND     RR1.source_type                IN (''R'', ''V'')
            AND     RR1.source_id                   = RR2.run_result_id
            AND     least(nvl(RR2.end_date, ppa.date_earned), ppa.date_earned)
                                              BETWEEN EE1.effective_start_date
                                                  AND EE1.effective_end_date
           ))
                  OR   RR1.source_type          IN (''I'', ''V'')
             )
         AND      RR1.assignment_action_id        = pa2.assignment_action_id
         AND      RR1.element_type_id             = ET1.element_type_id
         AND      ppa.date_earned           BETWEEN ET1.effective_start_date
                                               AND ET1.effective_end_date
         AND      ET1.classification_id           = EC.classification_id
         AND      ET1.element_type_id             = EL1.element_type_id
         AND      ppa.date_earned          BETWEEN EL1.effective_start_date
                                               AND EL1.effective_end_date
         AND      EL1.costable_type              <> ''N''
         and      EL1.transfer_to_gl_flag         = ''Y''
         AND      PERA.assignment_id             = pa2.assignment_id
         AND      PERA.business_group_id         = EL1.business_group_id +0
         AND      ppa.date_earned          BETWEEN PERA.effective_start_date
                                               AND PERA.effective_end_date
         AND      ((EL1.payroll_id               IS NOT NULL
         AND        EL1.payroll_id                = PERA.payroll_id)
         OR        (EL1.link_to_all_payrolls_flag = ''Y''
         AND        PERA.payroll_id             IS NOT NULL)
         OR       EL1.payroll_id                 IS NULL)
         AND     (EL1.organization_id             = PERA.organization_id
         OR       EL1.organization_id            IS NULL)
         AND     (EL1.position_id                 = PERA.position_id
         OR       EL1.position_id                IS NULL)
         AND     (EL1.job_id                      = PERA.job_id
         OR       EL1.job_id                     IS NULL)
         AND     (EL1.grade_id                    = PERA.grade_id
         OR       EL1.grade_id                   IS NULL)
         AND     (EL1.location_id                 = PERA.location_id
         OR       EL1.location_id                IS NULL)
         AND     (EL1.pay_basis_id                = PERA.pay_basis_id
         OR       EL1.pay_basis_id               IS NULL)
         AND     (EL1.employment_category         = PERA.employment_category
         OR       EL1.employment_category        IS NULL)
         AND      (EL1.people_group_id           IS NULL
         OR       EXISTS
            (SELECT  1
            FROM    pay_assignment_link_usages_f    PAL
            WHERE   PAL.assignment_id             = PERA.assignment_id
            AND     PAL.element_link_id           = EL1.element_link_id
           AND     ppa.date_earned          BETWEEN PAL.effective_start_date
                                                AND PAL.effective_end_date))
        )
        AND    et.element_type_id	= rr.element_type_id
	AND    caf.cost_allocation_keyflex_id = cst.cost_allocation_keyflex_id
        AND    ppa.effective_date
		BETWEEN per.effective_start_date
		AND	per.effective_end_date
        AND    ppa.date_earned
		BETWEEN et.effective_start_date
		AND 	et.effective_end_date
        GROUP BY cst.cost_allocation_keyflex_id,
 	 	 cst.debit_or_credit,
		 decode (IV.uom, ''M'', et.output_currency_code, ''STAT'')',
	dbms_sql.v7);
end if;
--
        hr_utility.set_location('pytrgl.trans_pay_costs',80);
--
--	Bind the variable values to the cursor values.
--
	dbms_sql.bind_variable(sql_curs,'c_run_action_id',
		c_run_action_id);
	dbms_sql.bind_variable(sql_curs,'c_cost_action_id',
		c_cost_action_id);
	dbms_sql.bind_variable(sql_curs,'c_payroll_id',	c_payroll_id);
	dbms_sql.bind_variable(sql_curs,'l_currency_type', l_currency_type);
        dbms_sql.bind_variable(sql_curs,'c_conversion_date',
                c_conversion_date);
        dbms_sql.bind_variable(sql_curs,'c_accounting_date',
                c_accounting_date);
        dbms_sql.bind_variable(sql_curs,'c_run_date',
                c_run_date);
        dbms_sql.bind_variable(sql_curs,'c_run_date_earned',
                c_run_date_earned);
	dbms_sql.bind_variable(sql_curs,'c_set_of_books_id',
		c_set_of_books_id);
	dbms_sql.bind_variable(sql_curs,'i_payroll_action_id',
		i_payroll_action_id);
        dbms_sql.bind_variable(sql_curs,'l_source_name',
                l_source_name);
        dbms_sql.bind_variable(sql_curs,'l_category_name',
                l_category_name);
        dbms_sql.bind_variable(sql_curs,'l_group_id',
                l_group_id);
--
--	Execute the insert statment.
--
	rows_processed := dbms_sql.execute(sql_curs);
--
	hr_utility.set_location('pytrgl.trans_pay_costs',90);
--
--	Update the assignment actions. Mark as processed.
--
	UPDATE  pay_assignment_actions   pa
	SET	pa.action_status = 'C'
	WHERE   pa.action_status <> 'C'
	AND	pa.payroll_action_id   = i_payroll_action_id
	AND     EXISTS
       (SELECT  /*+ ORDERED
                    USE_NL (ppa pi2 pa2 per) */
                NULL
	FROM
		pay_payroll_actions	 ppa,
	        pay_action_interlocks    pi2,  -- Run - Trans GL
		pay_assignment_actions   pa2,  -- Payroll run actions.
                pay_payroll_actions      ppa2,
           	per_all_assignments_f	 per
	WHERE	pi2.locking_action_id    = pa.assignment_action_id
	AND	pa.assignment_id	 = per.assignment_id
	AND     per.payroll_id	+0	 = c_payroll_id
	AND	pa2.assignment_action_id = pi2.locked_action_id
	AND	pa2.payroll_action_id    = c_run_action_id
	AND	ppa2.payroll_action_id   = c_run_action_id
	AND	ppa.payroll_action_id    = pa.payroll_action_id
	AND	ppa2.effective_date
		BETWEEN per.effective_start_date
		AND	per.effective_end_date);
--
        hr_utility.set_location('pytrgl.trans_pay_costs', 100);
--
	COMMIT;
--
      END LOOP;
--
      hr_utility.set_location('pytrgl.trans_pay_costs',110);
--
      CLOSE transfer_payrolls;
--
      dbms_sql.close_cursor(sql_curs);
--
      hr_utility.set_location('pytrgl.trans_pay_costs',120);
--
  END trans_pay_costs;

--
/* MULTI-THREADED SOLUTION */
--
PROCEDURE trans_pay_costs_mt
	(i_payroll_action_id NUMBER)
IS
--
--
--  	Cursor to get the payroll run actions which are processed by this
--	transfer to general ledger action. An assignment action will exist
--	for each assignment action in a payroll run payroll action which
--	has been costed for this transfer to general ledger payroll action.
--
CURSOR transfer_payrolls (i_action_id   	NUMBER)
IS
SELECT  /*+ ORDERED*/
        DISTINCT ppa2.payroll_action_id,
        ppa1.payroll_action_id,
        ppa1.action_type,
        pp.payroll_id,
        pp.gl_set_of_books_id,
        ppa1.payroll_id
FROM    pay_payroll_actions      ppa,   -- Trans GL pay actions
        pay_assignment_actions   pa,    -- Trans GL asg actions
        pay_action_interlocks    pi2,   -- Run - Trans GL
        pay_assignment_actions   pa2,   -- Payroll run asg actions.
        pay_payroll_actions      ppa2,  -- Payroll run actions.
        pay_action_classifications pac,
        pay_all_payrolls_f       pp,
        pay_action_interlocks    pi1,   -- Cost - Trans GL
        pay_assignment_actions   pa1,   -- Cost asg actions.
        pay_action_interlocks    pi3,   -- Cost - Run
        pay_payroll_actions      ppa1,  -- Cost pay actions
        (select distinct
                gl.assignment_action_id,
                run_payroll_action_id
         from pay_gl_interface gl,
              pay_assignment_actions aa
         where gl.assignment_action_id = aa.assignment_action_id
           and aa.payroll_action_id = i_action_id) gl
                                        -- Checking with GL 6848762*/
WHERE   ppa.payroll_action_id    = i_action_id
-- 6848762
and gl.assignment_action_id  = pa.assignment_action_id
and gl.run_payroll_action_id = ppa2.payroll_action_id
-- 6848762
AND     pa.payroll_action_id     = ppa.payroll_action_id
--AND     pa.action_status         <> 'C'
AND     pi2.locking_action_id    = pa.assignment_action_id
AND     pa2.assignment_action_id = pi2.locked_action_id
AND     ppa2.payroll_action_id   = pa2.payroll_action_id
AND     ppa2.consolidation_set_id +0 = ppa.consolidation_set_id
AND     pac.action_type          = ppa2.action_type
AND     pac.classification_name  = 'COSTED'
AND     pp.payroll_id            = ppa2.payroll_id
AND     pi1.locking_action_id    = pa.assignment_action_id
AND     pa1.assignment_action_id = pi1.locked_action_id
AND     pa1.assignment_action_id <> pa2.assignment_action_id
AND     pi3.locking_action_id    = pa1.assignment_action_id
AND     pa2.assignment_action_id = pi3.locked_action_id
AND     ppa1.payroll_action_id   = pa1.payroll_action_id
AND     ppa1.action_type         IN ('C', 'S')
AND     ppa.effective_date
        BETWEEN pp.effective_start_date
        AND     pp.effective_end_date
UNION ALL
SELECT  /*+ ORDERED*/
        DISTINCT ppa1.payroll_action_id,
        ppa1.payroll_action_id,
        ppa1.action_type,
        pp.payroll_id,
        pp.gl_set_of_books_id,
        ppa1.payroll_id
FROM    pay_payroll_actions      ppa,   -- Trans GL pay actions
        pay_assignment_actions   pa,    -- Trans GL asg actions
        pay_action_interlocks    pi1,   -- Cost - Trans GL
        pay_assignment_actions   pa1,   -- Cost asg actions
        pay_payroll_actions      ppa1,  -- Cost pay actions
        per_all_assignments_f    pera,
        pay_all_payrolls_f       pp
WHERE   ppa.payroll_action_id    = i_action_id
AND     pa.payroll_action_id     = ppa.payroll_action_id
AND     pi1.locking_action_id    = pa.assignment_action_id
AND     pa1.assignment_action_id = pi1.locked_action_id
AND     ppa1.payroll_action_id   = pa1.payroll_action_id
AND     ppa1.action_type         in ('EC', 'CP')
AND     pera.assignment_id       = pa.assignment_id
AND     ppa1.effective_date
        BETWEEN pera.effective_start_date
        AND     pera.effective_end_date
AND     pp.payroll_id            = pera.payroll_id
AND     ppa.effective_date
        BETWEEN pp.effective_start_date
        AND     pp.effective_end_date
ORDER by 4; -- pp.payroll_id
--
--
--	Cursor to get the map of pay cost segments to gl account segments
--	for the payroll. The set of books for the payroll may be date
--	effectively changed so the set of books id is the one which is
--	date effective at the effective run date.
--
CURSOR flex_segments (i_payroll_id NUMBER,
                      i_gl_sets_of_books_id NUMBER)
IS
SELECT  gl_account_segment,
        payroll_cost_segment
FROM    pay_payroll_gl_flex_maps
WHERE   payroll_id = i_payroll_id
AND     gl_set_of_books_id = i_gl_sets_of_books_id;
--
--
pay_segment_list   	VARCHAR2(1200);	-- Dynamically built varchar
					-- used in the select statement.
l_pay_segment_list   	VARCHAR2(1200);
gl_segment_list    	VARCHAR2(930);	-- Dynamically built varchar
					-- for insert statement.
l_gl_segment_list    	VARCHAR2(930);
sql_curs 		NUMBER;		-- For dynamic sql statement.
rows_processed 		INTEGER;
prev_payroll_id         NUMBER := 0;
prev_sob_id             NUMBER := 0;
l_currency_type         VARCHAR2(30);
c_run_action_id   	NUMBER;
c_cost_action_id        NUMBER;
c_action_type           pay_payroll_actions.action_type%TYPE;
c_payroll_id		NUMBER;
c_pay_id		NUMBER;
c_accounting_date       DATE;
c_conversion_date       DATE;
c_run_date              DATE;
c_run_date_earned       DATE;
l_bus_grp_id            NUMBER;
c_set_of_books_id	NUMBER;
l_source_name           VARCHAR2(25);
l_category_name         VARCHAR2(25);
l_bus_currency_code     VARCHAR2(150);
l_date_used             VARCHAR2(80);
l_rvb_acc_date          VARCHAR2(80);
l_group_id              VARCHAR2(80);
l_asg_tab               VARCHAR2(100);
l_asg_join              VARCHAR2(500);
--
BEGIN
--
      hr_utility.set_location('pytrgl.trans_pay_costs_mt',10);
--
      sql_curs := dbms_sql.open_cursor;
--
      OPEN transfer_payrolls (i_payroll_action_id);
--
      hr_utility.set_location('pytrgl.trans_pay_costs_mt',20);
--
--    Bug 1066820 avoid passing in hard coded strings.
--
      select user_je_source_name
      into l_source_name
      from gl_je_sources_vl
      where je_source_name = 'Payroll';
--
      hr_utility.set_location('pytrgl.trans_pay_costs_mt',25);
--
      select user_je_category_name
      into l_category_name
      from gl_je_categories_vl
      where je_category_name = 'Payroll';
--
      hr_utility.set_location('pytrgl.trans_pay_costs_mt',27);
--
      select bus.currency_code, bus.business_group_id
      into l_bus_currency_code, l_bus_grp_id
      from per_business_groups_perf bus,
           pay_payroll_actions      ppa
      where ppa.payroll_action_id  = i_payroll_action_id
      and   bus.business_group_id  = ppa.business_group_id;
--
      hr_utility.set_location('pytrgl.trans_pay_costs',28);
--
--    Find if use an accouting date of date_earned
--    (default is effective_date)
--
      begin
        select parameter_value
        into  l_date_used
        from pay_action_parameters
        where parameter_name = 'TGL_DATE_USED';
      exception
        when others then
           l_date_used := 'P';
      end;
--
--    Find if use an accouting date of date_earned
--    (default is effective_date)
--
      begin
        select parameter_value
        into  l_rvb_acc_date
        from pay_action_parameters
        where parameter_name = 'TGL_REVB_ACC_DATE';
      exception
        when others then
           l_rvb_acc_date := 'P';
      end;
--
      hr_utility.set_location('pytrgl.trans_pay_costs',29);
--
--    Find if should populate gl_interface.group_id
--    (default is to leave this column blank)
--    If so we populate it with the TGL payroll_action_id
--
      begin
        select parameter_value
        into  l_group_id
        from pay_action_parameters
        where parameter_name = 'TGL_GROUP_ID';
      exception
        when others then
           l_group_id := 'N';
      end;
--
--    Process each run action in turn. Each run action may be for
--    several payrolls. Each payroll will be processed separately.
      LOOP
--
        FETCH transfer_payrolls INTO
          c_run_action_id,		-- payroll run action
          c_cost_action_id,             -- cost action
          c_action_type,                -- cost action_type 'C', 'S or 'EC'
	  c_payroll_id,
          c_set_of_books_id,
          c_pay_id;
--
        hr_utility.set_location('pytrgl.trans_pay_costs_mt',30);
--
        EXIT WHEN transfer_payrolls%NOTFOUND;
--
        hr_utility.set_location('pytrgl.trans_pay_costs_mt',32);
--
        if (c_action_type in ('C', 'S')) then

           select decode(ppa1.action_type, 'S', ppa1.effective_date,
                 decode(ppa2.action_type, 'B', decode(l_rvb_acc_date, 'C', ppa1.effective_date,
                                                                           ppa2.effective_date),
                                          'V', decode(l_rvb_acc_date, 'C', ppa1.effective_date,
                                                                           ppa2.effective_date),
                                          decode(l_date_used, 'E', ppa2.date_earned,
                                                                   ppa2.effective_date))),
                  ppa2.effective_date,
                  ppa2.date_earned
           into   c_accounting_date,
                  c_run_date,
                  c_run_date_earned
           from   pay_payroll_actions ppa1,  -- Cost pay actions
                  pay_payroll_actions ppa2   -- Payroll run action
           where  ppa1.payroll_action_id = c_cost_action_id
           and    ppa2.payroll_action_id = c_run_action_id;

        else
           -- estimate costs : nb accounting_date for reversal
           -- costs overriden by contents of pay_gl_interface.accouting_date
           --
           select ppa1.effective_date, ppa1.effective_date
           into   c_accounting_date, c_run_date
           from   pay_payroll_actions ppa1   -- Estimate Cost pay action
           where  ppa1.payroll_action_id = c_cost_action_id;
        end if;

        --  Avoid double postings for consolidation set estimate costs. Bug 5606113.
        --  Join to per_all_assignments_f on Effective date confirming on
        --  required payroll. Use string concatenation method to avoid performance hit
        --  ie only join to per_all_assignments_f if have to.
        if ((c_action_type = 'EC' or c_action_type = 'CP') and
            c_pay_id is null) then
           hr_utility.set_location('pytrgl.trans_pay_costs_mt',33);
           l_asg_tab  := 'per_all_assignments_f       paf,';
           l_asg_join :=
       'AND    paf.assignment_id              = '||'p'||'a.assignment_id
        AND    :c_run_date between paf.effective_start_date
                               and paf.effective_end_date
        AND    paf.payroll_id                 = :c_payroll_id';
        else
           hr_utility.set_location('pytrgl.trans_pay_costs_mt',34);
           l_asg_tab  := '';
           l_asg_join := '';
        end if;

--
        hr_utility.set_location('pytrgl.trans_pay_costs_mt',35);
--
--      Get payrolls currency conversion rate type
--      handle fact that it may be null
--
        begin
           l_currency_type := hruserdt.get_table_value(l_bus_grp_id,
                           'EXCHANGE_RATE_TYPES', 'Conversion Rate Type',
                           'PAY',c_accounting_date);
           c_conversion_date := c_accounting_date;

        exception
           when no_data_found then
              hr_utility.set_location('pytrgl.trans_pay_costs',37);
              l_currency_type := null;
              c_conversion_date := null;
        end;
--
--      Only bother to rebuild segment lists if they are different from
--      previous iteration.  This avoids rebuilding when a run has been costed
--      and then retrocosted.
--
        if (c_payroll_id <> prev_payroll_id or
            c_set_of_books_id <> prev_sob_id) then
--
           pay_segment_list := NULL;
           gl_segment_list := NULL;
--
           hr_utility.set_location('pytrgl.trans_pay_costs_mt',40);
--
--	   Dynamically build up the segment lists for the payroll.
           FOR flex_segs IN flex_segments ( c_payroll_id, c_set_of_books_id )
	   LOOP
--
             hr_utility.set_location('pytrgl.trans_pay_costs_mt',50);
--
	     gl_segment_list := gl_segment_list ||
		   flex_segs.gl_account_segment ||',';
--
             hr_utility.set_location('pytrgl.trans_pay_costs_mt',60);
--
--	     Payroll segment list needs to MIN() function as not grouped
--	     by each segment.
--
	     pay_segment_list := pay_segment_list || 'MIN(caf.' ||
		   flex_segs.payroll_cost_segment||'),';
--
	   END LOOP;
--
        end if;
--
        prev_payroll_id := c_payroll_id;
        prev_sob_id := c_set_of_books_id;
--
	hr_utility.set_location('pytrgl.trans_pay_costs_mt',65);
--
--      For Payment Costs should not populate segment columns
--      in gl_interface : bug 6169000
--
        if (c_action_type = 'CP') then
           l_pay_segment_list := null;
           l_gl_segment_list := null;
        else
           l_pay_segment_list := pay_segment_list;
           l_gl_segment_list := gl_segment_list;
        end if;
--
	hr_utility.set_location('pytrgl.trans_pay_costs_mt',70);
--
--	Put the statement into the cursor and parse. Don't know how long
--	the segment list is so we cannot bind to variables.
--
-- For post 11i
if (PAY_ADHOC_UTILS_PKG.chk_post_r11i = 'Y') then
	dbms_sql.parse(sql_curs,
        'INSERT INTO gl_interface
            (status,
	     ledger_id,
             set_of_books_id,
             user_je_source_name,
             user_je_category_name,
             accounting_date,
             currency_code,
             group_id,
             date_created,
             created_by,
             actual_flag,'||
             l_gl_segment_list||'
             code_combination_id,
             reference21,
             reference22,
             reference23,
             reference24,
             reference25,
             user_currency_conversion_type,
             currency_conversion_date,
             entered_dr,
             entered_cr)
        SELECT /*+ ORDERED
                   INDEX(paf PER_ASSIGNMENTS_F_PK)
                   INDEX(int PAY_ACTION_INTERLOCKS_PK)
                   INDEX(pgl PAY_GL_INTERFACE_N1)
                   USE_NL(pgl int pa pa2 paf) */
              ''NEW'',
    	      :c_set_of_books_id,
    	      :c_set_of_books_id,
              :l_source_name,
              :l_category_name,
              trunc(nvl(pgl.accounting_date, :c_accounting_date)),
    	      pgl.currency_code,
              decode (:l_group_id, ''Y'', :i_payroll_action_id),
 	      trunc(sysdate),
    	      801,
              ''A'','||
              l_pay_segment_list||'
              decode(:c_action_type, ''CP'', pgl.cost_allocation_keyflex_id),
              :i_payroll_action_id,
              pgl.cost_allocation_keyflex_id,
              :c_run_date,
              :c_run_date_earned,
              :c_run_action_id,
              :l_currency_type,
              :c_conversion_date,
              SUM(pgl.entered_dr),
              SUM(pgl.entered_cr)
        FROM   pay_assignment_actions      pa,
               '|| l_asg_tab ||'
               pay_action_interlocks       int,
               pay_assignment_actions      pa2,
               pay_gl_interface            pgl,
               pay_cost_allocation_keyflex caf
	WHERE  pgl.run_payroll_action_id      = :c_run_action_id
        '|| l_asg_join ||'
        AND    caf.cost_allocation_keyflex_id (+) = pgl.cost_allocation_keyflex_id
        AND    pa.assignment_action_id        = pgl.assignment_action_id
        AND    pa.payroll_action_id           = :i_payroll_action_id
        AND    int.locking_action_id          = pa.assignment_action_id
        AND    int.locked_action_id           = pa2.assignment_action_id
        AND    pa2.payroll_action_id          = :c_cost_action_id
        GROUP BY pgl.cost_allocation_keyflex_id,
                 decode(pgl.entered_dr, 0, 0, 1),
                 nvl(pgl.accounting_date, :c_accounting_date),
                 pgl.currency_code',
        dbms_sql.v7);
else
	dbms_sql.parse(sql_curs,
        'INSERT INTO gl_interface
            (status,
             set_of_books_id,
             user_je_source_name,
             user_je_category_name,
             accounting_date,
             currency_code,
             group_id,
             date_created,
             created_by,
             actual_flag,'||
             l_gl_segment_list||'
             code_combination_id,
             reference21,
             reference22,
             reference23,
             reference24,
             reference25,
             user_currency_conversion_type,
             currency_conversion_date,
             entered_dr,
             entered_cr)
        SELECT /*+ ORDERED
                   INDEX(paf PER_ASSIGNMENTS_F_PK)
                   INDEX(int PAY_ACTION_INTERLOCKS_PK)
                   INDEX(pgl PAY_GL_INTERFACE_N1)
                   USE_NL(pgl int pa pa2 paf) */
              ''NEW'',
    	      :c_set_of_books_id,
              :l_source_name,
              :l_category_name,
              trunc(nvl(pgl.accounting_date, :c_accounting_date)),
    	      pgl.currency_code,
              decode (:l_group_id, ''Y'', :i_payroll_action_id),
 	      trunc(sysdate),
    	      801,
              ''A'','||
              l_pay_segment_list||'
              decode(:c_action_type, ''CP'', pgl.cost_allocation_keyflex_id),
              :i_payroll_action_id,
              pgl.cost_allocation_keyflex_id,
              :c_run_date,
              :c_run_date_earned,
              :c_run_action_id,
              :l_currency_type,
              :c_conversion_date,
              SUM(pgl.entered_dr),
              SUM(pgl.entered_cr)
        FROM   pay_assignment_actions      pa,
               '|| l_asg_tab ||'
               pay_action_interlocks       int,
               pay_assignment_actions      pa2,
               pay_gl_interface            pgl,
               pay_cost_allocation_keyflex caf
	WHERE  pgl.run_payroll_action_id      = :c_run_action_id
        '|| l_asg_join ||'
        AND    caf.cost_allocation_keyflex_id (+) = pgl.cost_allocation_keyflex_id
        AND    pa.assignment_action_id        = pgl.assignment_action_id
        AND    pa.payroll_action_id           = :i_payroll_action_id
        AND    int.locking_action_id          = pa.assignment_action_id
        AND    int.locked_action_id           = pa2.assignment_action_id
        AND    pa2.payroll_action_id          = :c_cost_action_id
        GROUP BY pgl.cost_allocation_keyflex_id,
                 decode(pgl.entered_dr, 0, 0, 1),
                 nvl(pgl.accounting_date, :c_accounting_date),
                 pgl.currency_code',
        dbms_sql.v7);
end if;
--
        hr_utility.set_location('pytrgl.trans_pay_costs_mt',80);
--
--	Bind the variable values to the cursor values.
--
	dbms_sql.bind_variable(sql_curs,'c_run_action_id',
		c_run_action_id);
        dbms_sql.bind_variable(sql_curs,'c_cost_action_id',
                c_cost_action_id);
        dbms_sql.bind_variable(sql_curs,'c_action_type',
                c_action_type);
        dbms_sql.bind_variable(sql_curs,'c_accounting_date',
                c_accounting_date);
        dbms_sql.bind_variable(sql_curs,'c_run_date',
                c_run_date);
        dbms_sql.bind_variable(sql_curs,'c_run_date_earned',
                c_run_date_earned);
        dbms_sql.bind_variable(sql_curs,'c_set_of_books_id',
                c_set_of_books_id);
	dbms_sql.bind_variable(sql_curs,'i_payroll_action_id',
		i_payroll_action_id);
        dbms_sql.bind_variable(sql_curs,'l_source_name',
                l_source_name);
        dbms_sql.bind_variable(sql_curs,'l_category_name',
                l_category_name);
        dbms_sql.bind_variable(sql_curs,'l_group_id',
                l_group_id);
	dbms_sql.bind_variable(sql_curs,'l_currency_type', l_currency_type);
        dbms_sql.bind_variable(sql_curs,'c_conversion_date',
                c_conversion_date);

        /* Bug 7401269: Variable wasn't bound for costing of payments.
	   Added an OR condition for binding variable in case of
	   costing of payment run before transfer to GL */

        if ((c_action_type = 'EC'  or c_action_type = 'CP') and
            c_pay_id is null) then
           dbms_sql.bind_variable(sql_curs,'c_payroll_id',
                   c_payroll_id);
        end if;
--
--	Execute the insert statment.
--
	rows_processed := dbms_sql.execute(sql_curs);
--
	hr_utility.set_location('pytrgl.trans_pay_costs_mt',90);
--
      END LOOP;
--
      hr_utility.set_location('pytrgl.trans_pay_costs_mt',100);
--
      CLOSE transfer_payrolls;
--
      dbms_sql.close_cursor(sql_curs);
--
      hr_utility.set_location('pytrgl.trans_pay_costs_mt',110);
--
      COMMIT;
--
      hr_utility.set_location('pytrgl.trans_pay_costs_mt',120);
--
  END trans_pay_costs_mt;
--
PROCEDURE trans_ass_costs
	(i_assignment_action_id NUMBER,
         sla_mode               NUMBER)
IS
t_payroll_action_id        NUMBER;
c_assignment_action_id     NUMBER;
r_assignment_action_id     NUMBER;
c_payroll_action_id        NUMBER;
r_payroll_action_id        NUMBER;
r_action_type              pay_payroll_actions.action_type%TYPE;
r_assignment_id            NUMBER;
r_tax_unit_id              pay_assignment_actions.tax_unit_id%TYPE;
c_action_type              pay_payroll_actions.action_type%TYPE;
l_date_used                VARCHAR2(80);
l_accounting_date          DATE;
BEGIN
--
  hr_utility.set_location('pytrgl.trans_ass_costs',10);
--
  if (sla_mode = 1) then
--
    hr_utility.set_location('pytrgl.trans_ass_costs',14);
--
    pay_sla_pkg.trans_asg_costs(i_assignment_action_id);
--
    hr_utility.set_location('pytrgl.trans_ass_costs',16);
--
  else
--
    hr_utility.set_location('pytrgl.trans_ass_costs',18);
--
    SELECT pa.payroll_action_id,
           pa1.assignment_id,
           pa1.assignment_action_id,
           ppa1.payroll_action_id,
           ppa1.action_type
    INTO   t_payroll_action_id,
           r_assignment_id,
           c_assignment_action_id,
           c_payroll_action_id,
           c_action_type
    FROM   pay_assignment_actions   pa,  -- TGL assignment action
           pay_action_interlocks    pi,  -- interlock to cost
           pay_assignment_actions   pa1, -- cost assignment action
           pay_payroll_actions      ppa1 -- cost payroll action
    WHERE  pa.assignment_action_id  = i_assignment_action_id
    AND    pi.locking_action_id     = pa.assignment_action_id
    AND    pa1.assignment_action_id = pi.locked_action_id
    AND    ppa1.payroll_action_id   = pa1.payroll_action_id
    AND    ppa1.action_type         IN ('C', 'S', 'EC', 'CP');
--
    if (c_action_type IN ('C', 'S')) then
--
      -- Costing or Retrocostong hence know run result populated
      -- in pay_costs.
--
      hr_utility.set_location('pytrgl.trans_ass_costs',20);
--
      SELECT pa2.assignment_action_id,
             ppa2.payroll_action_id,
             ppa2.action_type,
             pa2.tax_unit_id
      INTO   r_assignment_action_id,
             r_payroll_action_id,
             r_action_type,
             r_tax_unit_id
      FROM   pay_assignment_actions   pa,  -- TGL assignment action
             pay_action_interlocks    pi2, -- interlock to run
             pay_assignment_actions   pa2, -- run assignment action
             pay_payroll_actions      ppa2 -- run payroll action
      WHERE  pa.assignment_action_id  = i_assignment_action_id
      AND    pi2.locking_action_id    = pa.assignment_action_id
      AND    pa2.assignment_action_id = pi2.locked_action_id
      AND    ppa2.payroll_action_id   = pa2.payroll_action_id
      AND    ppa2.action_type         NOT IN ('C', 'S', 'EC');
--
      hr_utility.set_location('pytrgl.trans_ass_costs',30);
--
      INSERT INTO pay_gl_interface
           ( assignment_action_id,
             run_payroll_action_id,
             cost_allocation_keyflex_id,
             currency_code,
             entered_dr,
             entered_cr)
      SELECT /*+ ORDERED USE_NL(cst rr) */
             i_assignment_action_id,
             r_payroll_action_id,
             cst.cost_allocation_keyflex_id,
             decode (IV.uom, 'M', et.output_currency_code, 'STAT'),
             SUM(DECODE(cst.debit_or_credit,'D',cst.costed_value,0)),
             SUM(DECODE(cst.debit_or_credit,'C',cst.costed_value,0))
      FROM   pay_payroll_actions      ppa, -- run payroll action
             pay_assignment_actions   raa,
             pay_costs                cst,
             pay_run_results          rr,
             pay_element_types_f      et,
             pay_input_values_f       IV
      WHERE  cst.assignment_action_id = c_assignment_action_id
      AND    raa.payroll_action_id    = r_payroll_action_id
      AND    raa.assignment_id        = r_assignment_id
      AND    decode(r_action_type, 'B', nvl(raa.tax_unit_id, -999),
                                        -999) =
             decode(r_action_type, 'B', nvl(r_tax_unit_id, -999),
                                        -999)
      AND    rr.assignment_action_id  = raa.assignment_action_id
      AND    ppa.payroll_action_id    = r_payroll_action_id
      AND    cst.run_result_id        = rr.run_result_id
      AND    RR.element_type_id       = IV.element_type_id
      AND    ET.element_type_id       = RR.element_type_id
      AND    ppa.date_earned    between et.effective_start_date
                                    and et.effective_end_date
      AND    IV.input_value_id        = CST.input_value_id
      AND    ppa.date_earned    between IV.effective_start_date
                                    and IV.effective_end_date
      AND   ((CST.transfer_to_gl_flag is not null
          AND CST.transfer_to_gl_flag  = 'Y')
      OR
             (CST.transfer_to_gl_flag is null
         AND  EXISTS
            (select RR1.run_result_id
             from   pay_run_results         RR1
             ,      pay_run_results         RR2
             ,      pay_element_entries_f   EE1
             ,      pay_element_links_f     EL1
             where  RR1.assignment_action_id  = raa.assignment_action_id
             and    RR1.source_id             = RR2.run_result_id
             and    RR1.source_type           = 'R'
             and    RR2.source_id             = EE1.element_entry_id
             and    RR2.source_type           = 'E'
             and    least(nvl(RR2.end_date, ppa.date_earned), ppa.date_earned)
                                        between EE1.effective_start_date
                                            and EE1.effective_end_date
             and    EL1.element_link_id       = EE1.element_link_id
             and    ppa.date_earned     between EL1.effective_start_date
                                            and EL1.effective_end_date
             and    EL1.transfer_to_gl_flag   = 'Y'
             and    RR1.run_result_id         = nvl(CST.distributed_run_result_id,
                                                    CST.run_result_id)
             UNION ALL
             select RR1.run_result_id
             from   pay_run_results         RR1
             ,      pay_element_entries_f   EE1
             ,      pay_element_links_f     EL1
             where  RR1.assignment_action_id  = raa.assignment_action_id
             and    decode(r_action_type, 'B', nvl(RR1.element_entry_id, RR1.source_id),
                                               RR1.source_id)
                                              = EE1.element_entry_id
             and    RR1.source_type           = 'E'
             and    least(nvl(RR1.end_date, ppa.date_earned), ppa.date_earned)
                                        between EE1.effective_start_date
                                            and EE1.effective_end_date
             and    EL1.element_link_id       = EE1.element_link_id
             and    ppa.date_earned     between EL1.effective_start_date
                                            and EL1.effective_end_date
             and    EL1.transfer_to_gl_flag   = 'Y'
             and    RR1.run_result_id         = nvl(CST.distributed_run_result_id,
                                                    CST.run_result_id)
             UNION ALL
             select /*+ ORDERED */
                    RR1.run_result_id
             FROM   pay_run_results                  RR1,
                    pay_element_types_f              ET1,
                    pay_element_links_f              EL1,
                    per_all_assignments_f            PERA
             WHERE    RR1.assignment_action_id  = raa.assignment_action_id
             AND      RR1.run_result_id         = nvl(CST.distributed_run_result_id,
                                                      CST.run_result_id)
             AND (
               (NOT EXISTS           /* look for deleted element entries */
                 (SELECT  null
                  FROM    pay_element_entries_f            EE1
                  WHERE   RR1.source_id                   = EE1.element_entry_id
                  AND     RR1.source_type                IN ('E', 'I')
                  AND     least(nvl(RR1.end_date, ppa.date_earned), ppa.date_earned)
                                                    BETWEEN EE1.effective_start_date
                                                        AND EE1.effective_end_date
                 )
               AND NOT EXISTS
                 (SELECT  null
                  FROM    pay_element_entries_f            EE1,
                          pay_run_results                  RR2
                  WHERE   RR2.source_id                   = EE1.element_entry_id
                  AND     RR1.source_type                IN ('R', 'V')
                  AND     RR1.source_id                   = RR2.run_result_id
                  AND     least(nvl(RR2.end_date, ppa.date_earned), ppa.date_earned)
                                                    BETWEEN EE1.effective_start_date
                                                        AND EE1.effective_end_date
                 ))
               OR   RR1.source_type          IN ('I', 'V')
             )
             AND      RR1.assignment_action_id        = raa.assignment_action_id
             AND      RR1.element_type_id             = ET1.element_type_id
             AND      ppa.date_earned           BETWEEN ET1.effective_start_date
                                                    AND ET1.effective_end_date
             AND      ET1.element_type_id             = EL1.element_type_id
             AND      ppa.effective_date        BETWEEN EL1.effective_start_date
                                                    AND EL1.effective_end_date
             AND      EL1.costable_type              <> 'N'
             AND      EL1.transfer_to_gl_flag         = 'Y'
             AND      PERA.assignment_id             = r_assignment_id
             AND      PERA.business_group_id         = EL1.business_group_id +0
             AND      ppa.date_earned           BETWEEN PERA.effective_start_date
                                                    AND PERA.effective_end_date
             AND      ((EL1.payroll_id               IS NOT NULL
             AND        EL1.payroll_id                = PERA.payroll_id)
             OR        (EL1.link_to_all_payrolls_flag = 'Y'
             AND        PERA.payroll_id             IS NOT NULL)
             OR       EL1.payroll_id                 IS NULL)
             AND     (EL1.organization_id             = PERA.organization_id
             OR       EL1.organization_id            IS NULL)
             AND     (EL1.position_id                 = PERA.position_id
             OR       EL1.position_id                IS NULL)
             AND     (EL1.job_id                      = PERA.job_id
             OR       EL1.job_id                     IS NULL)
             AND     (EL1.grade_id                    = PERA.grade_id
             OR       EL1.grade_id                   IS NULL)
             AND     (EL1.location_id                 = PERA.location_id
             OR       EL1.location_id                IS NULL)
             AND     (EL1.pay_basis_id                = PERA.pay_basis_id
             OR       EL1.pay_basis_id               IS NULL)
             AND     (EL1.employment_category         = PERA.employment_category
             OR       EL1.employment_category        IS NULL)
             AND      (EL1.people_group_id           IS NULL
             OR       EXISTS
                (SELECT  1
                 FROM    pay_assignment_link_usages_f    PAL
                 WHERE   PAL.assignment_id             = PERA.assignment_id
                 AND     PAL.element_link_id           = EL1.element_link_id
                 AND     ppa.date_earned          BETWEEN PAL.effective_start_date
                                                      AND PAL.effective_end_date))
             )))
      GROUP BY cst.cost_allocation_keyflex_id,
               cst.debit_or_credit,
               decode (IV.uom, 'M', et.output_currency_code, 'STAT');
      --
      hr_utility.set_location('pytrgl.trans_ass_costs',40);
    --
    elsif (c_action_type = 'EC') then
--
      -- Estimate Costing hence run result not populated
      -- in pay_costs.
--
      hr_utility.set_location('pytrgl.trans_ass_costs',50);
--
      --
      -- Find if use an accouting date of date_earned
      -- (default is effective_date)
      --
      if (g_date_used is null) then
      begin
        select parameter_value
        into  g_date_used
        from pay_action_parameters
        where parameter_name = 'TGL_DATE_USED';
      exception
        when others then
           g_date_used := 'P';
      end;
      end if;
      l_date_used := g_date_used;
--
      hr_utility.set_location('pytrgl.trans_pay_costs',29);
      --
      -- get accounting_date according to TGL_DATE_USED
      -- for use with the reversal costs
      --
      SELECT /*+ ORDERED */
             decode(l_date_used, 'E', ptp.end_date,
                               'EVE', ptp.end_date,
                    ptp.pay_advice_date + pay.pay_date_offset)
      INTO   l_accounting_date
      FROM   pay_payroll_actions     ppa,
             per_all_assignments_f   pera,
             pay_all_payrolls_f          pay,
             per_time_periods        ptp
      WHERE  ppa.payroll_action_id = c_payroll_action_id
      AND    pera.assignment_id    = r_assignment_id
      AND    ppa.effective_date BETWEEN pera.effective_start_date
                                    AND pera.effective_end_date
      AND    pay.payroll_id        = pera.payroll_id
      AND    ppa.effective_date BETWEEN pay.effective_start_date
                                    AND pay.effective_end_date
      AND    ptp.payroll_id        = pera.payroll_id
      AND    ppa.effective_date BETWEEN ptp.start_date
                                    AND ptp.end_date;
--
      hr_utility.set_location('pytrgl.trans_ass_costs',50);
--
      INSERT INTO pay_gl_interface
           ( assignment_action_id,
             run_payroll_action_id,
             cost_allocation_keyflex_id,
             currency_code,
             entered_dr,
             entered_cr,
             accounting_date)
      SELECT /*+ ORDERED USE_NL(cst) */
             i_assignment_action_id,
             c_payroll_action_id,
             cst.cost_allocation_keyflex_id,
             decode (IV.uom, 'M', et.output_currency_code, 'STAT'),
             SUM(DECODE(cst.debit_or_credit,'D',cst.costed_value,0)),
             SUM(DECODE(cst.debit_or_credit,'C',cst.costed_value,0)),
             decode (CST.source_id, null, null, l_accounting_date)
      FROM   pay_payroll_actions      ppa, -- TGL payroll action
             pay_costs                cst,
             pay_input_values_f       IV,
             pay_element_types_f      et
      WHERE  ppa.payroll_action_id    = t_payroll_action_id
      AND    cst.assignment_action_id = c_assignment_action_id
      AND    IV.input_value_id        = nvl(CST.distributed_input_value_id,
                                            CST.input_value_id)
      AND    ppa.effective_date BETWEEN IV.effective_start_date
                                    AND IV.effective_end_date
      AND    ET.element_type_id       = IV.element_type_id
      AND    ppa.effective_date BETWEEN ET.effective_start_date
                                    AND ET.effective_end_date
      AND   ((CST.transfer_to_gl_flag is not null
          AND CST.transfer_to_gl_flag  = 'Y')
      OR
             (CST.transfer_to_gl_flag is null
         AND  EXISTS
            (select /*+ ORDERED */
                    1
             FROM   per_all_assignments_f            PERA,
                    pay_element_links_f              EL1
             WHERE    EL1.element_type_id             = ET.element_type_id
             AND      ppa.effective_date        BETWEEN EL1.effective_start_date
                                                    AND EL1.effective_end_date
             AND      EL1.costable_type              <> 'N'
             AND      EL1.transfer_to_gl_flag         = 'Y'
             AND      PERA.assignment_id             = r_assignment_id
             AND      PERA.business_group_id         = EL1.business_group_id +0
             AND      ppa.effective_date        BETWEEN PERA.effective_start_date
                                                    AND PERA.effective_end_date
             AND      ((EL1.payroll_id               IS NOT NULL
             AND        EL1.payroll_id                = PERA.payroll_id)
             OR        (EL1.link_to_all_payrolls_flag = 'Y'
             AND        PERA.payroll_id             IS NOT NULL)
             OR       EL1.payroll_id                 IS NULL)
             AND     (EL1.organization_id             = PERA.organization_id
             OR       EL1.organization_id            IS NULL)
             AND     (EL1.position_id                 = PERA.position_id
             OR       EL1.position_id                IS NULL)
             AND     (EL1.job_id                      = PERA.job_id
             OR       EL1.job_id                     IS NULL)
             AND     (EL1.grade_id                    = PERA.grade_id
             OR       EL1.grade_id                   IS NULL)
             AND     (EL1.location_id                 = PERA.location_id
             OR       EL1.location_id                IS NULL)
             AND     (EL1.pay_basis_id                = PERA.pay_basis_id
             OR       EL1.pay_basis_id               IS NULL)
             AND     (EL1.employment_category         = PERA.employment_category
             OR       EL1.employment_category        IS NULL)
             AND      (EL1.people_group_id           IS NULL
             OR       EXISTS
                (SELECT  1
                 FROM    pay_assignment_link_usages_f    PAL
                 WHERE   PAL.assignment_id             = PERA.assignment_id
                 AND     PAL.element_link_id           = EL1.element_link_id
                 AND     ppa.effective_date       BETWEEN PAL.effective_start_date
                                                      AND PAL.effective_end_date))
             )))
      GROUP BY cst.cost_allocation_keyflex_id,
               cst.debit_or_credit,
               decode (IV.uom, 'M', et.output_currency_code, 'STAT'),
               decode (CST.source_id, null, null, l_accounting_date);
--
      hr_utility.set_location('pytrgl.trans_ass_costs',60);
--
    else
--
        -- Payment Costing processes
--
      INSERT INTO pay_gl_interface
           ( assignment_action_id,
             run_payroll_action_id,
             cost_allocation_keyflex_id,
             currency_code,
             entered_dr,
             entered_cr,
             accounting_date)
      SELECT i_assignment_action_id,
             c_payroll_action_id,
             ppc.account_id,
             ppc.currency_code,
             SUM(DECODE(ppc.debit_or_credit,'D',ppc.value,0)),
             SUM(DECODE(ppc.debit_or_credit,'C',ppc.value,0)),
             ppc.accounting_date
      FROM   pay_payment_costs        ppc
      WHERE  ppc.assignment_action_id = c_assignment_action_id
      AND    ppc.transfer_to_gl_flag  = 'Y'
      AND   (ppc.source_type not in ('P', 'U')
         OR (ppc.source_type in ('P', 'U')
             AND NOT EXISTS
                 (SELECT 1
                  FROM   pay_assignment_actions aa,
                         pay_payroll_actions pa,
                         pay_pre_payments ppp,
                         pay_org_payment_methods_f pom
                  WHERE  aa.pre_payment_id = ppc.pre_payment_id
                  AND    pa.payroll_action_id = aa.payroll_action_id
                  AND    pa.action_type = 'E'
                  AND    ppp.pre_payment_id = ppc.pre_payment_id
                  AND    pom.org_payment_method_id = ppp.org_payment_method_id
                  AND    pa.effective_date BETWEEN pom.effective_start_date
                                               AND pom.effective_end_date
                  AND    pom.exclude_manual_payment = 'Y')))
      GROUP BY ppc.accounting_date,
               ppc.account_id,
               ppc.debit_or_credit,
               ppc.currency_code;
--
     hr_utility.set_location('pytrgl.trans_ass_costs',70);
--
    end if;
--
  end if;
--
END trans_ass_costs;
--
END pay_trgl_pkg;

/
