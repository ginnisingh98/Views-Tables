--------------------------------------------------------
--  DDL for Package Body HR_US_FF_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_FF_UDFS" as
/* $Header: pyusudfs.pkb 120.8.12010000.4 2009/05/15 15:45:35 svannian ship $ */
/*
+======================================================================+
|                Copyright (c) 1994 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : hr_us_ff_udfs
    Filename	: pyusudfs.sql
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    16-NOV-93   hparicha  	1.0             Created
    04-JAN-94   jmychale       40.8     G479    Corrected Other_Non_Separate_
						Check processing
    07-JAN-94	jmychale       40.9     G491    Removed actual hrs worked
						param from Calculate_Period_
						Earnings.
    13-JAN-94	hparicha       40.11	G497	Reverted to version 40.8
						NEED actual_hours_worked for
						Statement of Earnings report.
    02-FEB-94	hparicha	40.12	G542	Added Dedn_Freq_Factor.
    25-FEB-94	hparicha	40.13	G555	Added salary basis comparison
						to "to_freq" in Convert_Period_
						Type.  Also, make check
						for Processing Run Type = 'ALL'
						in Check_Dedn_Freq.
    18-MAR-94	hparicha	40.14	G605	Return 'E' or 'S' for Jurisd
						val.

    24-APR-94	hparicha	40.15	G___	Changes to work sched tot hrs;
						Changes to Calc Per Earnings
						and Convert Period Type to
						accept Work Schedule ID!
    15-JUN-94	hparicha	40.     G907	New implementation, fixes
						to Arrearage.
    01-AUG-94	hparicha	40.4	G1185	Updated Check_Dedn_Freq to
						check PERIOD num in month/year
						instead of Run in month/year.
    05-AUG-94	hparicha	40.5	G1188	Updated Separate_Check_Skip to
						verify when a not-null 'Dedn
						Proc' RRV is found that 'Sep
						Check' or 'Tax Separately'
						is also in fact marked as 'Y'.
						Ie. the scenario could exist
						where Dedn Proc is 'PTT' but
						Tax Sep/Sep Check both = 'N' -
						in which case the deduction
						should process as normal.
    26-OCT-94	hparicha	40.6	G1342	Included as part of this STU
						bug.  Added "addr_val" for
						use by VERTEX formulae and
						"get_geocode".
    14-NOV-94	hparicha	40.7	G1668	Optimization of addr_val.
    15-NOV-94	hparicha	40.8	G1679	More optimization of fns -
						proration, arrearage, period
						type conversion.
    24-NOV-94	rfine   	40.9	G1725	Suppressed index on
						business_group_id
    01-DEC-94	hparicha	40.10	G1529	We longer require TaxSep earns
					G1601	to be paid on sepchecks.
						This is a reversal of G1188.
						Dedn Proc is now independant
						of Sep Check and Tax Sep
						processing.
    09-DEC-94	hparicha	40.11	G1530	Fixup of us_jurisdiction_val.
    04-JAN-95	hparicha	40.12	G1565	Vacation/Sick correlation
						to Regular Pay - changes to
						Calc Period Earns.
						Also need separate fn to calc
						Vac/Sick Pay as well as a fn
						to check for entry of Vac/Sick
						Hours against an accrual plan.
    25-APR-95	hparicha	40.13		Fixed addr_val -aka GET_GEOCODE
						such that INITCAP is used
						instead of UPPER when comparing
						City/County/State names.
						Latest Vertex data has been
						converted to initcaps.
						Actually, just UPPER both sides
						of compare to remove any doubt.
						Also needed
                                                FND_NUMBER.CANONICAL_TO_NUMBER
                                                on zip code for "between"
                                                comparisons.
						- not sure why this is needed,
						- but the sql would not work
						- otherwise.
    26-APR-95	hparicha	40.14		No, idiot, UPPER on both sides
						trashes the index...back to
						INITCAP on literal in addr_val.
    01-MAY-95	gpaytonm	40.15		addr_val select only doesn't
                                                look at canada a.state_code
                                                != 70. This fixes the invalid
                                                number error
    01-MAY-95   gpaytonm	40.16		Removed prior fix and removed
                                                FND_NUMBER.CANONICAL_TO_NUMBER
						from addr_val select instead
    09-MAY-95   gpaytonm	40.17		Removed remaining
                                                FND_NUMBER.CANONICAL_TO_NUMBER's                                                from addr_Val
    15-MAY-95	hparicha	40.18		Added UPPER to PERIOD_TYPE
						comparison in Convert_Period_
						Type.
    23-JUN-95   gpaytonm        40.19           Changed references to
                                                pay_us_cities to
						pay_us_city_names and
                                                pay_us_zip_codes where
						appropriate
    29-JUN-95   spanwar         40.20           Changed addr_val to convert
                                                'UNKN' city codes to '0000'

    07-JUL-95	hparicha	40.21	290249	Fixed arrearage function to
						correctly handle partial dedns
						when clearing arrears.

    08-JUL-95	hparicha	40.22	264781	Proration function needs mod
						to algo for semi-monthly and
						monthly employees.

    14-AUG-95	tgrisco		40.23		Changed addr_val to convert
						'U' city codes to '0000'.

    22-Nov-95	ssdesai		40.24		substr zipcode to 5 chars
						in addr_val allowing for
						zip code extension.

    10-JAN-96	hparicha	40.27		Cleaned up all references to
                                                specific period types
						and pay bases in relation to
                                                proration, regular salary,
						regular wages, calculations of
                                                hourly rates.  Affected
						functions: calculate_period_earn
						convert_period_type,
                                                ot_base_rate.
						Bug 334245 - Add check for
                                                primary flag
						on pay_us_city_names select.

???		???		40.28	???	???

4th July 1996	hparicha	40.29	360549, 366215, 378753
						Removed consumed_entry fn.
						Package too large.
						Moved into pay_consumed_entry
						package.  Replaced by function
						of same name in new package.
					353434, 368242
						Fixed number width for
                                                total hours variables in
						convert_period_type,
                                                work_schedule_total_hours,
						and standard_hours_worked.

25-Jul-96	P Jones		40.30		Removed user_errors

1st Nov 1996	hparicha	40.31	408507	Removing vacation and sick
						accrual pay and hours
						calculation from regular
						salary and wages proration
						calc - ie.
						Calculate_Period_Earnings

14th Nov 1996	hparicha	40.32	408507	Undoing 40.31 - see README
                                                for 408507 for explanation.

8th Dec 1997	kmundair     40.33(110.1)  509120  Overloaded addr_val.
24th Feb 1998	tbattoo      40.33         572081  Changed date rng prorate EEV.
26th Feb 1998   arashid      40.35       504970  Fix unhandled divide-by-zero
                                                 exception. The change made
                                                 is to consolidate processing
                                                 if arrearage is on, but the
                                                 whole amount cannot be cleared.
3rd  Mar 1998   arashid      40.36       504970  Fixed the 504970 fix to take
                                                 the current deduction if
                                                 PARTIAL_FLAG = 'N' and (net -
                                                 guaranteed) >= current
                                                 deduction.
4th  Jun 1998   jarthurt     110.2       408507  Alter the Vacation and Sick Pay
                                                 cursors to pick up absences not
                                                 tied to an accrual plan as well
                                                 as those that are.
17-AUG-1998     ekim         110.4       716066  Length has been changed
                                                 from (10,7) to (15,7)
                                                 for v_hrs_per_wk,
                                                 v_hrs_per_range
                                                 v_asst_std_hrs,
                                                 v_hours_in_range.
23-NOV-1998 	tbattoo                          Added frequency rules
                                                 functionality to core

10-MAR-1999     ahanda       115.5       803662  Modified function
                                                 Calculate_Period_Earnings.
                                                 Modified select statments
                                                 which checks for mid
                                                 change in asgn to use Exists,
                                                 as it
                                                 will return multiple records
                                                 if the assgn id
                                                 has been changed more than
                                                 once in a Pay Period.
21-Apr-1999     scgrant      115.6               Multi-radix changes.

                                                 Description: User-Defined
                                                 Functions required for US
                                                 implementations.
19-MAY-99      gpaytonm      115.12              Removed hr_utility.trace
20-MAY-99      VMehta        115.13              Converted p_tax_unit_id to
                                                 character while comparing it to                                                 segment1 in hr_soft_coding_
                                                 keyflex table to overcome
                                                 'invali number' error.
                                                 Bug 894503.
25-MAY-1999    mmukherj      115.14      868824   Changes made to include
                                                 legislation code in selecting
                                                 elements, otherwise it might
                                                 fetch multiple row, because of
                                                 same element present for canada
28-Sep-1999    djoshi                            added function for
                                                 pay_us_country
28-OCT-1999    mreid         115.17              Changed territory short name
                                                 retrieve to come from VL view.
09-may-2000    vmehta        115.18      863771  Modified function
                                                 work_schedule_total_hours to
                                                 check for business_group_id and
                                                 user_table_id while obtaining
                                                 user_column_name from
                                                 pay_user_columns
01-JUL-2000     vmehta     115.19       Added a check of the last 3 characters
                                        in the city name. This is to fix a
                                        problem where Air Force Bases (in the
                                        City_name would error during processing
                                        of a payroll run.  Example "Elgin AFB",
                                        this is how the name appears in the
                                        pay_us_city_names table. however the
                                        addr_val function would perform an
                                        initcap to the p_city_name parameter.
                                        This caused no data found.  Now if the
                                        last 3 characters are "AFB" do not
                                        perform the Initcap.  Bug 1266054
21-DEC-2000     ekim       115.22       ******* LEAP FROGGED *******
                                        DO NOT USED v115.21.
                                        This is leap frogged from 115.19.
                                        Bug 1541873. Moved city_name check
                                        right after the main begin of addr_val
                                        as when skip_flag of 'Y' is passed
                                        the city_name check is skipped.
23-JAN-2001     ahanda     115.23       Added the Calculation Type functoinality
                                        to Package. The Hourly Calculation will
                                        be done depending on the calculation
                                        rule given on the payroll define screen.
                                        The default calculation rule is
                                        Annulization, and the other available
                                        rule is Standard.
                                        Also added ORDERED hint in function
                                        addr_val(Bug 1484707).
09-MAR-2001     ssarma     115.24       Added a new parameter
         				p_hour_calc_override to
					convert_period_type function.
17-SEP-2001     ptitoren   115.25       Changed insert_session_row procedures
                                        to call dt_fndate.set_effective_date
                                        to shield our code from future
                                        FND_SESSION table changes.
07-FEB-2002     tclewis   115.26        Modified the code around dt_fndate
                                        above to first check for the
                                        existence of a row in the FND_Sessions
                                        table before making the call.
13-FEB-2002     rsirigir  115.27        Bug 2196352
                                        changed datatype/datalengths
                                        for three variables
                                        from FUNCTION Convert_Period_Type,from
                                        v_from_stnd_factor          NUMBER(10)
                                        v_from_annualizing_factor    NUMBER(10)
                                        v_to_annualizing_factor     NUMBER(10)
                                        to
                                        v_from_stnd_factor          NUMBER(30,7)
                                        v_from_annualizing_factor   NUMBER(30,7)
                                        v_to_annualizing_factor     NUMBER(30,7)

05-APR-2001    rsirigir  115.28         Bug 1877889
                                        changed to select the work
                                        schedule defined
                                        at the business group level instead of
                                        hardcoding the default work schedule
                                        (COMPANY WORK SCHEDULES ) to the
                                        variable  c_ws_tab_name
13-AUG-2002    ahanda    115.30         Changed get_flat_amounts, get_rates and
                                        get_percentages for performance.
13-NOV-2002    tclewis   115.31 2666118 Changed work_schedule_total_hours
                                        Previously it used to get the
                                        day of the week via 'DT' and
                                        used to pass this value to get
                                        the value from
                                        hruserdt.get_table_value. But
                                        this was not working in the
                                        Psedo translated env as
                                        user_tables/row/columns are
                                        not translated. Now it is
                                        getting the day number and then
                                        based upon the number it deter
                                        mines the day. Also changed
                                        standard_hours_worked to do the
                                        same.
18-NOV-2002 tclewis     115.31 2666118  Changed convert_period_type
                                        where we are querring number per
                                        fiscal year.  to change
                                        where sysdate between ...
                                        to nvl(p_period_start_date, sysdate).
19-NOV-2002 tclewis     115.32          Fixed GSCC compliance warning with
                                        default parameter values.
19-nov-2002 tclewis     115.33          changed nvl(p_period_start_date, sysdate)
                                        to use fnd_sessions.
07-Jan-2003 ekim        115.35          Made performance change in function
                                        OT_Base_Rate as :
                                        Added date joins and business_group_id
                                        and legislation_code join. Also added
                                        + ORDERED  to avoid merge join.
                                        Did no change to the queries which gets
                                        the following variables since the cost
                                        is already low (cost=9)
                                        v_rate_multiple, v_rate_mult_count,
                                        v_rate_code
                                        Added element_type_id join in a query
                                        which gets v_dedn_proc for function
                                        separate_check_skip.
09-Jan-2003 ekim        115.36          GSCC warning fix for nocopy.
09-Jan-2003 meshah      115.37          changed the sql for Rate, Rate Code and
                                        Monthly Salary in
                                        Calculate_Period_Earnings.
25-MAR-2003 tclewis     115.38          Modified the query at the
                                        beginning of the
                                        Calculate_Period_earnings which
                                        looks for
                                        l_eev_info_changes (element entry value)
                                        change for the salary element.
                                        It now also
                                        looks for a salary element starting
                                        in the
                                        middle of the pay period.
25-Jul-2003 vmehta      115.39          Modified get_annulization_factor (within
                                        convert_period_type) to use fnd_sessions
                                        to get the effective date instead of
                                        using p_effecive_end_date. (Bug 3067262)
07-JAN-2004 trugless    115.40          Commented out the following code for bug
                                        3271413 in the SELECT (ASG1.2) section
                                        "AND EEV.effective_end_date
                                        < p_period_end;"
                                        Employees who had salary adjustments
                                        done on the first day of a payroll
                                        and were terminated
                                        during the same payroll period were
                                        showing zero
                                        salary for the payroll run.

22-MAR-2004 asasthan    115.41          Fix for Bug 3521706
                                        The where clause has been modified.
                                        Additional checking between period dates                                        removed and added to another query
                                        so that 2594138 is not broken
30-MAR-2004 asasthan    115.42          Uncommented changes made for 3271413
01-APR-2004 asasthan    115.43          gscc warnings fixed
07-MAY-2004 asasthan    115.44          Reverting to 115.40
10-MAY-2004 asasthan    115.45          gscc warnings fixed
18-JUN-2004 sodhingr    115.46          changed the procedure addr_val to use the
                                        ordered hint only for database prior to 9i
                                        Fixed bug 3685724.
10-AUG-2004 schauhan    115.47 3783309  Changed INITCAP to UPPER in query of function
                                        addr_val for county name.
11-AUG-2004 schauhan    115.48 3703863  Commented out the primary flag condition in the query
					in function us_jurisdiction_val as this flag is N for
					user defined cities.Also added rownum to handle multiple
					rows if returned by this query.
04-MAR-2003 rmonge      115.49          Geocode change for JEDD jurisdictions.
06-DEC-2005 sackumar    115.51 4750302  Modified a Select statement in Calculate_Period_Earnings.
30-DEC-2005 schauhan    115.52 4868637  Modified the query.
21-AUG-2006 rpasumar    115.54 5343679 Modified the query.
31-OCT-2006 rpasumar    115.55 5629688 Removed the ORDERED hint.
13-NOV-2007 svannian    115.56 6319565 Modified the deduction amt
				       calculation during Negative Net Salary.
*/

--
-- **********************************************************************
-- CALCULATE_PERIOD_EARNINGS
-- Description: This fn performs proration for the startup elements
-- Regular Salary and
-- Regular Wages.
-- Proration occurs in the following scenarios:
-- 1. Change of assignment status to
-- a status which is unpaid - ie. unpaid leave, termination;
-- 2. Change of regular rate of pay - ie. could --
-- be a change in annual salary or hourly rate.
-- This fn also calculates and returns the actual hours worked in the period,
-- vacation pay, sick pay,
-- vacation hours, and sick hours.

FUNCTION Calculate_Period_Earnings (
			p_bus_grp_id		in NUMBER,
			p_asst_id		in NUMBER,
			p_payroll_id		in NUMBER,
			p_ele_entry_id		in NUMBER,
			p_tax_unit_id		in NUMBER,
			p_date_earned		in DATE,
			p_pay_basis 		in VARCHAR2,
			p_inpval_name		in VARCHAR2,
			p_ass_hrly_figure	in NUMBER,
			p_period_start 		in DATE,
			p_period_end 		in DATE,
			p_work_schedule	in VARCHAR2,
			p_asst_std_hrs		in NUMBER,
			p_actual_hours_worked	in out nocopy NUMBER,
			p_vac_hours_worked	in out nocopy NUMBER,
			p_vac_pay		in out nocopy NUMBER,
			p_sick_hours_worked	in out nocopy NUMBER,
			p_sick_pay		in out nocopy NUMBER,
			p_prorate 		in VARCHAR2,
			p_asst_std_freq		in VARCHAR2)
RETURN NUMBER IS

l_asg_info_changes	NUMBER(1);
l_eev_info_changes	NUMBER(1);
v_earnings_entry		NUMBER(27,7);
v_inpval_id		NUMBER(9);
v_pay_basis		VARCHAR2(80);
v_pay_periods_per_year	NUMBER(3);
v_period_earn		NUMBER(27,7) ; -- Pay Period earnings.
v_hourly_earn		NUMBER(27,7);	-- Hourly Rate (earnings).
v_prorated_earnings	NUMBER(27,7) ; -- Calc'd thru proration loops.
v_curr_day		VARCHAR2(3);	-- Currday while summing hrs for range of dates.
v_hrs_per_wk		NUMBER(15,7);
v_hrs_per_range	        NUMBER(15,7);
v_asst_std_hrs		NUMBER(15,7);
v_asst_std_freq		VARCHAR2(30);
v_asg_status		VARCHAR2(30);
v_hours_in_range	NUMBER(15,7);
v_curr_hrly_rate	NUMBER(27,7) ;
v_range_start		DATE;		-- range start of ASST rec
v_range_end		DATE;		-- range end of ASST rec
v_entry_start		DATE;		-- start date of ELE ENTRY rec
v_entry_end		DATE;		-- end date of ELE ENTRY rec
v_entrange_start	DATE;		-- max of entry or asst range start
v_entrange_end		DATE;		-- min of entry or asst range end
v_work_schedule		VARCHAR2(60);	-- Work Schedule ID (stored as varchar2
					--  in HR_SOFT_CODING_KEYFLEX; convert
					--  fnd_number.canonical_to_number when calling wshours fn.
v_work_sched_name	VARCHAR2(80);
v_ws_id			NUMBER(9);

b_entries_done		BOOLEAN;	-- flags no more entry changes in paypd
b_asst_changed		BOOLEAN;	-- flags if asst changes at least once.
b_on_work_schedule	BOOLEAN;	-- use wrk scheds or std hours
l_mid_period_asg_change BOOLEAN ;

/*
-- ************************************************************************
--
-- The following cursor "get_asst_chgs" looks for *changes* to or from
-- 'ACTIVE' per_assignment
-- records within the supplied range of dates, *WITHIN THE SAME TAX UNIT*
-- (ie. the tax unit as of the end of the period specified).
-- If no "changes" are found, then assignment information is consistent
-- over entire period specified.
-- Before calling this cursor, will need to select tax_unit_name
-- according to p_tax_unit_id.
--
-- ************************************************************************
*/

--
-- This cursor finds ALL ASG records that are WITHIN Period Start and End Dates
-- including Period End Date - NOT BETWEEN since the ASG record existing across
-- Period Start date has already been retrieved in SELECT (ASG1).
-- Work Schedule segment is segment4 on assignment DDF
--

CURSOR 	get_asst_chgs IS
SELECT	ASG.effective_start_date,
	ASG.effective_end_date,
	NVL(ASG.normal_hours, 0),
	NVL(HRL.meaning, 'NOT ENTERED'),
	NVL(SCL.segment4, 'NOT ENTERED')
FROM	per_assignments_f 		ASG,
	per_assignment_status_types 	AST,
	hr_soft_coding_keyflex		SCL,
	hr_lookups			HRL
WHERE	ASG.assignment_id	= p_asst_id
AND	ASG.business_group_id + 0	= p_bus_grp_id
AND  	ASG.effective_start_date        	> p_period_start
AND   	ASG.effective_end_date 	<= p_period_end
AND	AST.assignment_status_type_id = ASG.assignment_status_type_id
AND	AST.per_system_status 	= 'ACTIVE_ASSIGN'
AND	SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
AND	SCL.segment1			= TO_CHAR(p_tax_unit_id)
AND	SCL.enabled_flag		= 'Y'
AND	HRL.lookup_code(+)		= ASG.frequency
AND	HRL.lookup_type(+)		= 'FREQUENCY';

FUNCTION Prorate_Earnings (
		p_bg_id			IN NUMBER,
		p_asg_hrly_rate		IN NUMBER,
		p_wsched		IN VARCHAR2 DEFAULT 'NOT ENTERED',
		p_asg_std_hours		IN NUMBER,
		p_asg_std_freq		IN VARCHAR2,
		p_range_start_date	IN DATE,
		p_range_end_date	IN DATE,
		p_act_hrs_worked	IN OUT nocopy NUMBER) RETURN NUMBER IS

v_prorated_earn	NUMBER(27,7)	; -- RETURN var
v_hours_in_range	NUMBER(15,7);
v_ws_id		NUMBER(9);
v_ws_name		VARCHAR2(80);

BEGIN

  /* Init */

 --p_wsched := 'NOT ENTERED';
 v_prorated_earn := 0;

  hr_utility.trace('UDFS Entered Prorate Earnings');
  hr_utility.trace('p_bg_id ='||to_char(p_bg_id));
  hr_utility.trace('p_asg_hrly_rate ='||to_char(p_asg_hrly_rate));
  hr_utility.trace('p_wsched ='||p_wsched);
  hr_utility.trace('p_asg_std_hours ='||to_char(p_asg_std_hours));
  hr_utility.trace('p_asg_std_freq ='||p_asg_std_freq);
  hr_utility.trace('UDFS p_range_start_date ='||to_char(p_range_start_date));
  hr_utility.trace('UDFS p_range_end_date ='||to_char(p_range_end_date));
  hr_utility.trace('p_act_hrs_worked ='||to_char(p_act_hrs_worked));

  -- Prorate using hourly rate passed in as param:


  IF UPPER(p_wsched) = 'NOT ENTERED' THEN

    hr_utility.set_location('Prorate_Earnings', 7);
    hr_utility.trace('p_wsched NOT ENTERED');
    hr_utility.trace('Calling Standard Hours Worked');

    v_hours_in_range := Standard_Hours_Worked(		p_asg_std_hours,
							p_range_start_date,
							p_range_end_date,
							p_asg_std_freq);

    -- Keep running total of ACTUAL hours worked.
    hr_utility.set_location('Prorate_Earnings', 11);

    hr_utility.trace('Keep running total of ACTUAL hours worked');

    hr_utility.trace('actual_hours_worked before call= '||
                      to_char(p_act_hrs_worked));
    hr_utility.trace('v_hours_in_range in current call= '||
                      to_char(v_hours_in_range));

    p_act_hrs_worked := p_act_hrs_worked + v_hours_in_range;

    hr_utility.trace('UDFS actual_hours_worked after call = '||
                      to_char(p_act_hrs_worked));

  ELSE

    hr_utility.set_location('Prorate_Earnings', 17);
    hr_utility.trace('Entered WORK SCHEDULE');

    hr_utility.trace('Getting WORK SCHEDULE Name');

    -- Get work schedule name:

    v_ws_id := fnd_number.canonical_to_number(p_wsched);

    hr_utility.trace('v_ws_id ='||to_char(v_ws_id));

    SELECT	user_column_name
    INTO	v_ws_name
    FROM	pay_user_columns
    WHERE	user_column_id 			= v_ws_id
    AND		NVL(business_group_id, p_bg_id) = p_bg_id
    AND         NVL(legislation_code,'US')      = 'US';

    hr_utility.trace('v_ws_name ='||v_ws_name );
    hr_utility.trace('Calling Work_Schedule_Total_Hours');

    v_hours_in_range := Work_Schedule_Total_Hours(
				p_bg_id,
				v_ws_name,
				p_range_start_date,
				p_range_end_date);

    p_act_hrs_worked := p_act_hrs_worked + v_hours_in_range;
    hr_utility.trace('v_hours_in_range = '||to_char(v_hours_in_range));

  END IF; -- Hours in date range via work schedule or std hours.

  hr_utility.trace('v_prorated_earnings = p_asg_hrly_rate * v_hours_in_range');

  v_prorated_earn := v_prorated_earn + (p_asg_hrly_rate * v_hours_in_range);

  hr_utility.trace('UDFS final v_prorated_earnings = '||to_char(v_prorated_earn));
  hr_utility.set_location('Prorate_Earnings', 97);
  p_act_hrs_worked := ROUND(p_act_hrs_worked, 3);
  hr_utility.trace('p_act_hrs_worked ='||to_char(p_act_hrs_worked));
  hr_utility.trace('UDFS Leaving Prorated Earnings');

  RETURN v_prorated_earn;

END Prorate_Earnings;

FUNCTION Prorate_EEV (	p_bus_group_id		IN NUMBER,
			p_pay_id		IN NUMBER,
			p_work_sched	IN VARCHAR2 DEFAULT 'NOT ENTERED',
			p_asg_std_hrs		IN NUMBER,
			p_asg_std_freq		IN VARCHAR2,
			p_pay_basis		IN VARCHAR2,
			p_hrly_rate 		IN OUT nocopy NUMBER,
			p_range_start_date	IN DATE,
			p_range_end_date	IN DATE,
			p_actual_hrs_worked	IN OUT nocopy NUMBER,
			p_element_entry_id	IN NUMBER,
			p_inpval_id		IN NUMBER) RETURN NUMBER IS
--
-- local vars
--
v_eev_prorated_earnings	NUMBER(27,7) ; -- Calc'd thru proration loops.
v_earnings_entry		VARCHAR2(60);
v_entry_start		DATE;
v_entry_end		DATE;
v_hours_in_range	NUMBER(15,7);
v_curr_hrly_rate		NUMBER(27,7);
v_ws_id			NUMBER(9);
v_ws_name		VARCHAR2(80);
--
-- Select for ALL records that are WITHIN Range Start and End Dates
-- including Range End Date - NOT BETWEEN since the EEV record existing across
-- Range Start date has already been retrieved and dealt with in SELECT (EEV1).
-- A new EEV record results in a change of the current hourly rate being used
-- in proration calculation.
--
CURSOR	get_entry_chgs (	p_range_start 	date,
				p_range_end	date) IS
SELECT	EEV.screen_entry_value,
	EEV.effective_start_date,
	EEV.effective_end_date
FROM	pay_element_entry_values_f	EEV
WHERE	EEV.element_entry_id 		= p_element_entry_id
AND 	EEV.input_value_id 		= p_inpval_id
AND	EEV.effective_start_date		> p_range_start
AND  	EEV.effective_end_date 	       	<= p_range_end
ORDER BY EEV.effective_start_date;
--
BEGIN


 /* Init */
 --p_work_sched := 'NOT ENTERED';
 v_eev_prorated_earnings := 0;


  hr_utility.trace('UDFS Entering PRORATE_EEV');
  hr_utility.trace('p_bus_group_id ='||to_char(p_bus_group_id));
  hr_utility.trace('p_pay_id ='||to_char(p_pay_id));
  hr_utility.trace('p_work_sched ='||p_work_sched);
  hr_utility.trace('p_asg_std_hrs ='||to_char(p_asg_std_hrs));
  hr_utility.trace('p_asg_std_freq ='||p_asg_std_freq);
  hr_utility.trace('p_pay_basis ='||p_pay_basis);
  hr_utility.trace('p_hrly_rate ='||to_char(p_hrly_rate));
  hr_utility.trace('UDFS p_range_start_date ='||to_char(p_range_start_date));
  hr_utility.trace('UDFS p_range_end_date ='||to_char(p_range_end_date));
  hr_utility.trace('p_actual_hrs_worked ='||to_char(p_actual_hrs_worked));
  hr_utility.trace('p_element_entry_id ='||to_char(p_element_entry_id));
  hr_utility.trace('p_inpval_id ='||to_char(p_inpval_id));
  --
  -- Find all EEV changes, calculate new hourly rate, prorate:
  -- SELECT (EEV1):
  -- Select for SINGLE record that includes Period Start Date but does not
  -- span entire period.
  -- We know this select will return a row, otherwise there would be no
  -- EEV changes to detect.
  --
  hr_utility.set_location('Prorate_EEV', 103);
  SELECT	EEV.screen_entry_value,
		GREATEST(EEV.effective_start_date, p_range_start_date),
		EEV.effective_end_date
  INTO		v_earnings_entry,
		v_entry_start,
		v_entry_end
  FROM		pay_element_entry_values_f	EEV
  WHERE	EEV.element_entry_id 		= p_element_entry_id
  AND 		EEV.input_value_id 		= p_inpval_id
  AND		EEV.effective_start_date       <= p_range_start_date
  AND  		EEV.effective_end_date 	       >= p_range_start_date
  AND  		EEV.effective_end_date 	        < p_range_end_date;


  hr_utility.trace('screen_entry_value ='||v_earnings_entry);
  hr_utility.trace('v_entry_start ='||to_char(v_entry_start));
  hr_utility.trace('v_entry_end ='||to_char(v_entry_end));
  hr_utility.trace('Calling Convert_Period_Type ');
  hr_utility.set_location('Prorate_EEV', 105);

  v_curr_hrly_rate := Convert_Period_Type(	p_bus_group_id,
						p_pay_id,
						p_work_sched,
						p_asg_std_hrs,
						v_earnings_entry,
						p_pay_basis,
						'HOURLY',
          	          	                p_period_start,
				                p_period_end,
						p_asg_std_freq);
  hr_utility.trace('v_curr_hrly_rate ='||to_char(v_curr_hrly_rate));
  hr_utility.set_location('Prorate_EEV', 107);

  v_eev_prorated_earnings := v_eev_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_group_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_wsched		=> p_work_sched,
				p_asg_std_hours		=> p_asg_std_hrs,
				p_asg_std_freq		=> p_asg_std_freq,
				p_range_start_date	=> v_entry_start,
				p_range_end_date	=> v_entry_end,
				p_act_hrs_worked       	=> p_actual_hrs_worked);

  hr_utility.trace('v_eev_prorated_earnings ='||
                      to_char(v_eev_prorated_earnings));
  -- SELECT (EEV2):
  hr_utility.trace('Opening get_entry_chgs cursor EEV2');

  OPEN get_entry_chgs (p_range_start_date, p_range_end_date);
    LOOP
    --
    FETCH get_entry_chgs
    INTO  v_earnings_entry,
	  v_entry_start,
	  v_entry_end;
    EXIT WHEN get_entry_chgs%NOTFOUND;
    --
  hr_utility.trace('v_earnings_entry ='||v_earnings_entry);
  hr_utility.trace('v_entry_start ='||to_char(v_entry_start));
  hr_utility.trace('v_entry_end ='||to_char(v_entry_end));
  hr_utility.set_location('Prorate_EEV', 115);
    --
    -- For each range of dates found, add to running prorated earnings total.
    --
  hr_utility.trace('Calling Convert_Period_Type ');

    v_curr_hrly_rate := Convert_Period_Type(	p_bus_group_id,
						p_pay_id,
						p_work_sched,
						p_asg_std_hrs,
						v_earnings_entry,
						p_pay_basis,
						'HOURLY',
          	          	                p_period_start,
				                p_period_end,
						p_asg_std_freq);


  hr_utility.trace('v_curr_hrly_rate ='||to_char(v_curr_hrly_rate));
    hr_utility.set_location('Prorate_EEV', 119);
    v_eev_prorated_earnings := v_eev_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_group_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_wsched		=> p_work_sched,
				p_asg_std_hours		=> p_asg_std_hrs,
				p_asg_std_freq		=> p_asg_std_freq,
				p_range_start_date	=> v_entry_start,
				p_range_end_date	=> v_entry_end,
				p_act_hrs_worked       	=> p_actual_hrs_worked);

  hr_utility.trace('v_eev_prorated_earnings ='||to_char(v_eev_prorated_earnings));

  END LOOP;
  --
  CLOSE get_entry_chgs;
  --
  -- SELECT (EEV3)
  -- Select for SINGLE record that exists across Period End Date:
  -- NOTE: Will only return a row if select (2) does not return a row where
  -- 	   Effective End Date = Period End Date !

 hr_utility.trace('Select EEV3');
  hr_utility.set_location('Prorate_EEV', 141);
  SELECT	EEV.screen_entry_value,
		EEV.effective_start_date,
		LEAST(EEV.effective_end_date, p_range_end_date)
  INTO		v_earnings_entry,
		v_entry_start,
		v_entry_end
  FROM		pay_element_entry_values_f	EEV
  WHERE		EEV.element_entry_id 		= p_element_entry_id
  AND 		EEV.input_value_id 		= p_inpval_id
  AND		EEV.effective_start_date        > p_range_start_date
  AND		EEV.effective_start_date       <= p_range_end_date
  AND  		EEV.effective_end_date 	        > p_range_end_date;
  hr_utility.set_location('Prorate_EEV', 147);
  hr_utility.trace('screen_entry_value ='||v_earnings_entry);
  hr_utility.trace('v_entry_start ='||to_char(v_entry_start));
  hr_utility.trace('v_entry_end ='||to_char(v_entry_end));

  hr_utility.trace('Calling Convert_Period_Type ');

  v_curr_hrly_rate := Convert_Period_Type(	p_bus_group_id,
						p_pay_id,
						p_work_sched,
						p_asg_std_hrs,
						v_earnings_entry,
						p_pay_basis,
						'HOURLY',
          	          	                p_period_start,
				                p_period_end,
						p_asg_std_freq);
  hr_utility.set_location('Prorate_EEV', 151);
  hr_utility.trace('After Call v_curr_hrly_rate ='||to_char(v_curr_hrly_rate));

  v_eev_prorated_earnings := v_eev_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_group_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_wsched		=> p_work_sched,
				p_asg_std_hours		=> p_asg_std_hrs,
				p_asg_std_freq		=> p_asg_std_freq,
				p_range_start_date	=> v_entry_start,
				p_range_end_date	=> v_entry_end,
				p_act_hrs_worked       	=> p_actual_hrs_worked);

  -- We're Done!
     hr_utility.trace('v_eev_prorated_earnings ='||
     to_char(v_eev_prorated_earnings));
  hr_utility.set_location('Prorate_EEV', 167);
  p_actual_hrs_worked := ROUND(p_actual_hrs_worked, 3);
  p_hrly_rate := v_curr_hrly_rate;

  hr_utility.trace('p_actual_hrs_worked ='||to_char(p_actual_hrs_worked));
  hr_utility.trace('p_hrly_rate ='||to_char(p_hrly_rate));

  hr_utility.trace('UDFS Leaving Prorated EEV');

  RETURN v_eev_prorated_earnings;

EXCEPTION WHEN NO_DATA_FOUND THEN
  hr_utility.set_location('Prorate_EEV', 177);
  hr_utility.trace('Into exception of Prorate_EEV');

  p_actual_hrs_worked := ROUND(p_actual_hrs_worked, 3);
  p_hrly_rate := v_curr_hrly_rate;

  hr_utility.trace('p_actual_hrs_worked ='||to_char(p_actual_hrs_worked));
  hr_utility.trace('p_hrly_rate ='||to_char(p_hrly_rate));

  RETURN v_eev_prorated_earnings;

END Prorate_EEV;

FUNCTION	vacation_pay (	p_vac_hours 	IN OUT nocopy NUMBER,
				p_asg_id 	IN NUMBER,
				p_eff_date	IN DATE,
				p_curr_rate	IN NUMBER) RETURN NUMBER IS

l_vac_pay	NUMBER(27,7) ;
l_vac_hours	NUMBER(10,7);

CURSOR get_vac_hours (	v_asg_id NUMBER,
			v_eff_date DATE) IS
select	fnd_number.canonical_to_number(pev.screen_entry_value)
from	per_absence_attendance_types 	abt,
	pay_element_entries_f 		pee,
	pay_element_entry_values_f	pev
where   pev.input_value_id	= abt.input_value_id
and     abt.absence_category    = 'V'
and	v_eff_date		between pev.effective_start_date
			    	    and pev.effective_end_date
and	pee.element_entry_id	= pev.element_entry_id
and	pee.assignment_id	= v_asg_id
and	v_eff_date		between pee.effective_start_date
			    	    and pee.effective_end_date;

-- The "vacation_pay" fn looks for hours entered against absence types
-- in the current period.  The number of hours are summed and multiplied by
-- the current rate of Regular Pay..
-- Return immediately when no vacation time has been taken.
-- Need to loop thru all "Vacation Plans" and check for entries in the current
-- period for this assignment.

BEGIN

  /* Init */
  l_vac_pay := 0;

  hr_utility.set_location('get_vac_pay', 11);
  hr_utility.trace('Entered Vacation Pay');

OPEN get_vac_hours (p_asg_id, p_eff_date);
LOOP

  hr_utility.set_location('get_vac_pay', 13);
  hr_utility.trace('Opened get_vac_hours');

  FETCH get_vac_hours
  INTO	l_vac_hours;
  EXIT WHEN get_vac_hours%NOTFOUND;

  p_vac_hours := p_vac_hours + l_vac_hours;

END LOOP;
CLOSE get_vac_hours;

hr_utility.set_location('get_vac_pay', 15);

IF p_vac_hours <> 0 THEN

  l_vac_pay := p_vac_hours * p_curr_rate;

END IF;

  hr_utility.trace('Leaving Vacation Pay');
RETURN l_vac_pay;

END vacation_pay;

FUNCTION	sick_pay (	p_sick_hours 	IN OUT nocopy NUMBER,
				p_asg_id 	IN NUMBER,
				p_eff_date	IN DATE,
				p_curr_rate	IN NUMBER) RETURN NUMBER IS

l_sick_pay	NUMBER(27,7)	;
l_sick_hours	NUMBER(10,7);

CURSOR get_sick_hours (	v_asg_id NUMBER,
			v_eff_date DATE) IS
select	fnd_number.canonical_to_number(pev.screen_entry_value)
from	per_absence_attendance_types	abt,
	pay_element_entries_f 		pee,
	pay_element_entry_values_f	pev
where	pev.input_value_id	= abt.input_value_id
and     abt.absence_category    = 'S'
and	v_eff_date		between pev.effective_start_date
			    	    and pev.effective_end_date
and	pee.element_entry_id	= pev.element_entry_id
and	pee.assignment_id	= v_asg_id
and	v_eff_date		between pee.effective_start_date
			    	    and pee.effective_end_date;

-- The "sick_pay" looks for hours entered against Sick absence types in
-- the current period.  The number of hours are summed and multiplied by the
-- current rate of Regular Pay.
-- Return immediately when no sick time has been taken.

BEGIN

  /* Init */
  l_sick_pay :=0;

  hr_utility.set_location('get_sick_pay', 11);
  hr_utility.trace('Entered Sick Pay');

OPEN get_sick_hours (p_asg_id, p_eff_date);
LOOP

  hr_utility.trace('get_sick_pay');
  hr_utility.set_location('get_sick_pay', 13);

  FETCH get_sick_hours
  INTO	l_sick_hours;
  EXIT WHEN get_sick_hours%NOTFOUND;

  p_sick_hours := p_sick_hours + l_sick_hours;

END LOOP;
CLOSE get_sick_hours;

  hr_utility.set_location('get_sick_pay', 15);
  hr_utility.trace('get_sick_pay');

IF p_sick_hours <> 0 THEN

  l_sick_pay := p_sick_hours * p_curr_rate;

END IF;

  hr_utility.trace('Leaving get_sick_pay');
RETURN l_sick_pay;

END sick_pay;

BEGIN	-- Calculate_Period_Earnings
        --BEGINCALC

 /* Init */
v_period_earn           := 0;
v_prorated_earnings     := 0;
v_curr_hrly_rate        := 0;
l_mid_period_asg_change := FALSE;

 hr_utility.trace('UDFS Entered Calculate_Period_Earnings');
 hr_utility.trace('p_asst_id ='||to_char(p_asst_id));
 hr_utility.trace('p_payroll_id ='||to_char(p_payroll_id));
 hr_utility.trace('p_ele_entry_id ='||to_char(p_ele_entry_id));
 hr_utility.trace('p_tax_unit_id ='||to_char(p_tax_unit_id));
 hr_utility.trace('p_date_earned ='||to_char(p_date_earned));
 hr_utility.trace('p_pay_basis ='||p_pay_basis);
 hr_utility.trace('p_inpval_name ='||p_inpval_name);
 hr_utility.trace('p_ass_hrly_figure ='||to_char(p_ass_hrly_figure));
 hr_utility.trace('UDFS p_period_start ='||to_char(p_period_start));
 hr_utility.trace('UDFS p_period_end ='||to_char(p_period_end));
 hr_utility.trace('p_work_schedule ='||p_work_schedule);
 hr_utility.trace('p_asst_std_hrs ='||to_char(p_asst_std_hrs));
 hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));
 hr_utility.trace('p_vac_hours_worked ='||to_char(p_vac_hours_worked));
 hr_utility.trace('p_vac_pay ='||to_char(p_vac_pay));
 hr_utility.trace('p_sick_hours_worked ='||to_char(p_sick_hours_worked));
 hr_utility.trace('p_sick_pay ='||to_char(p_sick_pay));
 hr_utility.trace('UDFS p_prorate ='||p_prorate);
 hr_utility.trace('p_asst_std_freq ='||p_asst_std_freq);

 hr_utility.trace('Find earnings element input value id');

p_actual_hours_worked := 0;

-- Step (1): Find earnings element input value.
-- Get input value and pay basis according to salary admin (if exists).
-- If not using salary admin, then get "Rate", "Rate Code", or "Monthly Salary"
-- input value id as appropriate (according to ele name).

IF p_pay_basis IS NOT NULL THEN

  BEGIN

  hr_utility.trace('  p_pay_basis IS NOT NULL');
  hr_utility.set_location('calculate_period_earnings', 10);

  SELECT	PYB.input_value_id,
  		FCL.meaning
  INTO		v_inpval_id,
 		v_pay_basis
  FROM		per_assignments_f	ASG,
		per_pay_bases 		PYB,
		hr_lookups		FCL
  WHERE	FCL.lookup_code	= PYB.pay_basis
  AND		FCL.lookup_type 	= 'PAY_BASIS'
  AND		FCL.application_id	= 800
  AND		PYB.pay_basis_id 	= ASG.pay_basis_id
  AND		ASG.assignment_id 	= p_asst_id
  AND		p_date_earned  BETWEEN ASG.effective_start_date
				AND ASG.effective_end_date;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 11);
    hr_utility.trace(' In EXCEPTION p_pay_basis IS NOT NULL');

    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

    hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

    RETURN  v_period_earn;


  END;

hr_utility.trace('p_inpval_name = '||p_inpval_name);

ELSIF UPPER(p_inpval_name) = 'RATE' THEN

   hr_utility.trace('  p_pay_basis IS NULL');
   hr_utility.trace('In p_inpval_name = RATE');
/* Changed the element_name and name to init case and added
   the date join for pay_element_types_f */

  begin
       SELECT 	IPV.input_value_id
           INTO v_inpval_id
       FROM	pay_input_values_f	IPV,
		pay_element_types_f	ELT
       WHERE	ELT.element_name = 'Regular Wages'
            and p_period_start    BETWEEN ELT.effective_start_date
                                      AND ELT.effective_end_date
            and ELT.element_type_id = IPV.element_type_id
            and	p_period_start	  BETWEEN IPV.effective_start_date
				      AND IPV.effective_end_date
            and	IPV.name = 'Rate'
            and ELT.legislation_code = 'US';
  --
       v_pay_basis := 'HOURLY';
  --
  EXCEPTION WHEN NO_DATA_FOUND THEN

    hr_utility.trace('Exception of RATE ');

    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

    hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

    RETURN  v_period_earn;
  end;
  --
ELSIF UPPER(p_inpval_name) = 'RATE CODE' THEN
    /* Changed the element_name and name to init case and added
       the date join for pay_element_types_f */

  begin
        hr_utility.trace('In RATE CODE');

       SELECT 	IPV.input_value_id
           INTO	v_inpval_id
       FROM	pay_input_values_f	IPV,
		pay_element_types_f	ELT
       WHERE	ELT.element_name = 'Regular Wages'
            and p_period_start    BETWEEN ELT.effective_start_date
                                      AND ELT.effective_end_date
            and	ELT.element_type_id = IPV.element_type_id
            and	p_period_start	  BETWEEN IPV.effective_start_date
				      AND IPV.effective_end_date
            and	IPV.name = 'Rate Code'
            and ELT.legislation_code = 'US';
  --
       v_pay_basis := 'HOURLY';
  --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.trace('Exception of Rate Code');

    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

    hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

    RETURN  v_period_earn;

  end;
  --
ELSIF UPPER(p_inpval_name) = 'MONTHLY SALARY' THEN

  /* Changed the element_name and name to init case and added
   the date join for pay_element_types_f */

  begin
       hr_utility.trace('in MONTHLY SALARY');

       SELECT	IPV.input_value_id
           INTO	v_inpval_id
       FROM	pay_input_values_f	IPV,
		pay_element_types_f	ELT
       WHERE	ELT.element_name = 'Regular Salary'
            and p_period_start    BETWEEN ELT.effective_start_date
                                      AND ELT.effective_end_date
            and	ELT.element_type_id = IPV.element_type_id
            and	p_period_start	  BETWEEN IPV.effective_start_date
				      AND IPV.effective_end_date
            and	IPV.name = 'Monthly Salary'
            and ELT.legislation_code = 'US';

       v_pay_basis := 'MONTHLY';

  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 18);
    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));
    RETURN  v_period_earn;
  END;

END IF;

hr_utility.trace('Now know the pay basis for this assignment');
hr_utility.trace('v_inpval_id ='||to_char(v_inpval_id));
hr_utility.trace('v_pay_basis ='||v_pay_basis);
/*
-- Now know the pay basis for this assignment (v_pay_basis).
-- Want to convert entered earnings to pay period earnings.
-- For pay basis of Annual, Monthly, Bi-Weekly, Semi-Monthly,
-- or Period (ie. anything
-- other than Hourly):
-- Annualize entered earnings according to pay basis;
-- then divide by number of payroll periods per fiscal
-- yr for pay period earnings.
-- 02 Dec 1993:
-- Actually, passing in an "Hourly" figure from formula alleviates
-- having to convert in here --> we have Convert_Period_Type fn
-- available to formulae, so a Monthly Salary can be converted before
-- calling this fn.  Then we just find the hours scheduled for current period as
-- per the Hourly pay basis algorithm below.
--
-- For Hourly pay basis:
-- 	Get hours scheduled for the current period either from:
--	1. ASG work schedule
--	2. ORG default work schedule
--	3. ASG standard hours and frequency
--	Multiply the hours scheduled for period by normal Hourly Rate (ie. from
--	pre-defined earnings, REGULAR_WAGES_RATE) pay period earnings.
--
-- In either case, need to find the payroll period type, let's do it upfront:
--	Assignment.payroll_id --> Payroll.period_type
--	--> Per_time_period_types.number_per_fiscal_year.
-- Actually, the number per fiscal year could be found in more than one way:
--	Could also go to per_time_period_rules, but would mean decoding the
--	payroll period type to an appropriate proc_period_type code.
--
*/

-- Find # of payroll period types per fiscal year:

begin

hr_utility.trace('Find # of payroll period types per fiscal year');
hr_utility.set_location('calculate_period_earnings', 40);

SELECT 	TPT.number_per_fiscal_year
INTO		v_pay_periods_per_year
FROM		pay_payrolls_f 		PRL,
		per_time_period_types 	TPT
WHERE	TPT.period_type 		= PRL.period_type
AND		p_period_end      between PRL.effective_start_date
				      and PRL.effective_end_date
AND		PRL.payroll_id			= p_payroll_id
AND		PRL.business_group_id + 0	= p_bus_grp_id;

hr_utility.trace('v_pay_periods_per_year ='||to_char(v_pay_periods_per_year));

exception when NO_DATA_FOUND then

  hr_utility.set_location('calculate_period_earnings', 41);
  hr_utility.trace('Exception Find # of payroll period');
  v_period_earn := 0;
  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

  RETURN  v_period_earn;

end;

/*
     -- Pay basis is hourly,
     -- 	Get hours scheduled for the current period either from:
     --	1. ASG work schedule
     --	2. ORG default work schedule
     --	3. ASG standard hours and frequency
     -- Do we pass in Work Schedule from asst scl db item?  Yes
     -- 10-JAN-1996 hparicha : We no longer assume "standard hours" represent
     -- a weekly figure.  We also no longer use a week as
     -- the basis for annualization,
     -- even when using work schedule - ie. need to find ACTUAL
     -- scheduled hours, not
     -- actual hours for a week, converted to a period figure.
*/
--
hr_utility.set_location('calculate_period_earnings', 45);
hr_utility.trace('Get hours scheduled for the current period');

IF p_work_schedule <> 'NOT ENTERED' THEN
  --
  -- Find hours worked between period start and end dates.
  --
  hr_utility.trace('Asg has Work Schedule');
  hr_utility.trace('p_work_schedule ='||p_work_schedule);

  v_ws_id := fnd_number.canonical_to_number(p_work_schedule);
  hr_utility.trace('v_ws_id ='||to_char(v_ws_id));
  --
  SELECT	user_column_name
  INTO		v_work_sched_name
  FROM		pay_user_columns
  WHERE		user_column_id 				= v_ws_id
  AND		NVL(business_group_id, p_bus_grp_id)	= p_bus_grp_id
  AND         	NVL(legislation_code,'US')      	= 'US';

  hr_utility.trace('v_work_sched_name ='||v_work_sched_name);
  hr_utility.trace('Calling Work_Schedule_Total_Hours');

  v_hrs_per_range := Work_Schedule_Total_Hours(	p_bus_grp_id,
							v_work_sched_name,
							p_period_start,
							p_period_end);
  hr_utility.trace('v_hrs_per_range ='||to_char(v_hrs_per_range));
ELSE

  hr_utility.trace('Asg has No Work Schedule');
  hr_utility.trace('Calling  Standard_Hours_Worked');

   v_hrs_per_range := Standard_Hours_Worked(	p_asst_std_hrs,
						p_period_start,
						p_period_end,
						p_asst_std_freq);
  hr_utility.trace('v_hrs_per_range ='||to_char(v_hrs_per_range));

END IF;


hr_utility.trace('Compute earnings and actual hours');
hr_utility.trace('calling convert_period_type from calculate_period_earnings');
hr_utility.set_location('calculate_period_earnings', 46);

v_period_earn := Convert_Period_Type(	p_bus_grp_id,
					p_payroll_id,
					p_work_schedule,
					p_asst_std_hrs,
					p_ass_hrly_figure,
					'HOURLY',
					NULL,
					p_period_start,
					p_period_end,
					p_asst_std_freq);

hr_utility.trace('v_period_earn ='||to_char(v_period_earn));
hr_utility.set_location('calculate_period_earnings', 47);

p_actual_hours_worked := v_hrs_per_range;

hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

IF p_prorate = 'N' THEN

  hr_utility.trace('No proration');
  hr_utility.trace('Calling p_vac_pay');
  hr_utility.set_location('calculate_period_earnings', 49);

  p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

  hr_utility.trace('p_vac_pay ='||to_char(p_vac_pay));

  hr_utility.trace('Calling sick Pay');
  p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


  hr_utility.trace('p_sick_pay ='||to_char(p_sick_pay));

  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

  hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));
  hr_utility.trace('UDFS v_period_earn ='||to_char(v_period_earn));

  RETURN v_period_earn;

END IF; /* IF  p_prorate = 'N' */


hr_utility.trace('UDFS check for ASGMPE changes');
hr_utility.set_location('calculate_period_earnings', 51);
/* ************************************************************** */

BEGIN /* Check ASGMPE */

  select 1 INTO l_asg_info_changes
    from dual
  where exists (
  SELECT	1
  FROM		per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL
  WHERE		ASG.assignment_id		= p_asst_id
  AND  		ASG.effective_start_date       <= p_period_start
  AND   	ASG.effective_end_date 	       >= p_period_start
  AND   	ASG.effective_end_date 		< p_period_end
  AND		AST.assignment_status_type_id 	= ASG.assignment_status_type_id
  AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
  AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
  AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
  AND		SCL.enabled_flag		= 'Y' );

     hr_utility.trace('ASGMPE Changes found');
     hr_utility.trace('Need to prorate b/c of ASGMPE');
     hr_utility.trace('Set l_mid_period_asg_change to TRUE I');

     l_mid_period_asg_change := TRUE;

     hr_utility.set_location('calculate_period_earnings', 56);
     hr_utility.trace('Look for EEVMPE changes');

  BEGIN /* EEVMPE check - maybe pick*/

  select 1 INTO l_eev_info_changes
    from dual
   where exists (
    SELECT	1
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND 	EEV.input_value_id+0 		= v_inpval_id
    AND ( ( 	EEV.effective_start_date       <= p_period_start
        AND 	EEV.effective_end_date 	       >= p_period_start
        AND 	EEV.effective_end_date 	        < p_period_end)
    OR (   EEV.effective_start_date between p_period_start and p_period_end)
    ) );



     hr_utility.trace('EEVMPE changes found after ASGMPE');

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      l_eev_info_changes := 0;

     hr_utility.trace('From EXCEPTION  ASGMPE changes found No EEVMPE changes');

  END; /* EEV1 check*/

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    l_asg_info_changes := 0;
    hr_utility.trace('From EXCEPTION No ASGMPE changes, nor EEVMPE changes');

END;  /* ASGMPE check*/

/* ************************************************ */

IF l_asg_info_changes = 0 THEN /* Check ASGMPS */

  hr_utility.trace(' Into l_asg_info_changes = 0');
  hr_utility.trace('UDFS looking for ASGMPS changes');
  hr_utility.set_location('calculate_period_earnings', 56);

  BEGIN /*  ASGMPS changes */

   select 1 INTO l_asg_info_changes
     from dual
    where exists (
    SELECT	1
    FROM	per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL
    WHERE	ASG.assignment_id		= p_asst_id
    AND 	ASG.effective_start_date        > p_period_start
    AND   	ASG.effective_start_date       <= p_period_end
    AND		AST.assignment_status_type_id 	= ASG.assignment_status_type_id
    AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
    AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
    AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
    AND		SCL.enabled_flag		= 'Y');

    l_mid_period_asg_change := TRUE;

    hr_utility.trace('Need to prorate for ASGMPS changes');
    hr_utility.set_location('calculate_period_earnings', 57);

    BEGIN /* EEVMPE changes ASGMPS */

  select 1 INTO l_eev_info_changes
    from dual
   where exists (
    SELECT      1
    FROM        pay_element_entry_values_f      EEV
    WHERE       EEV.element_entry_id            = p_ele_entry_id
    AND         EEV.input_value_id+0            = v_inpval_id
    AND ( (     EEV.effective_start_date       <= p_period_start
        AND     EEV.effective_end_date         >= p_period_start
        AND     EEV.effective_end_date          < p_period_end)
    --OR (   EEV.effective_start_date between p_period_start and p_period_end)
     ) );


       hr_utility.trace('Need to prorate EEVMPS changes after ASGMPS ');

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

        l_eev_info_changes := 0;

        hr_utility.trace('From EXCEPTIION No EEVMPE changes');

    END; /* EEVMPE changes */

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      l_asg_info_changes := 0;

      hr_utility.trace('From EXCEPTION no changes due to ASGMPS or EEVMPE');

  END; /* ASGMPS changes */

END IF; /* Check ASGMPS */

/* *************************************************** */

IF l_asg_info_changes = 0 THEN  /* ASGMPE=0 and ASGMPS=0 */

  BEGIN /* Check for EEVMPE changes */

    hr_utility.set_location('calculate_period_earnings', 58);
    hr_utility.trace('Check for EEVMPE changes nevertheless');

   select 1 INTO l_eev_info_changes
     from dual
    where exists (
      SELECT	1
      FROM	pay_element_entry_values_f	EEV
      WHERE	EEV.element_entry_id 		= p_ele_entry_id
      AND	EEV.input_value_id+0 		= v_inpval_id
      AND	EEV.effective_start_date       <= p_period_start
      AND	EEV.effective_end_date 	       >= p_period_start
      AND	EEV.effective_end_date 	        < p_period_end);

     hr_utility.trace('Proration due to  EEVMPE changes');


  EXCEPTION

    WHEN NO_DATA_FOUND THEN

         hr_utility.trace('ASG AND EEV changes DO NOT EXIST EXCEPT ');

      -- Either there are no changes to an Active Assignment OR
      -- the assignment was not active at all this period.
      -- Check assignment status of current asg record.

     hr_utility.trace(' Check assignment status of current asg record');

      SELECT	AST.per_system_status
      INTO	v_asg_status
      FROM	per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL
      WHERE	ASG.assignment_id		= p_asst_id
      AND  	p_period_start		BETWEEN ASG.effective_start_date
      					AND   	ASG.effective_end_date
      AND	AST.assignment_status_type_id 	= ASG.assignment_status_type_id
      AND	SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
      AND	SCL.segment1			= TO_CHAR(p_tax_unit_id)
      AND	SCL.enabled_flag		= 'Y';

      IF v_asg_status <> 'ACTIVE_ASSIGN' THEN

        hr_utility.trace(' Asg not active');
        v_period_earn := 0;
        p_actual_hours_worked := 0;

      END IF;

       hr_utility.trace('Chk for vac pay since no ASG EEV changes to prorate' );

       p_vac_pay := vacation_pay(p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

       hr_utility.trace('p_vac_pay ='||p_vac_pay);
       p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


      hr_utility.trace('p_sick_pay ='||p_sick_pay);

      p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
      RETURN v_period_earn;

  END;  /* Check for EEVMPE changes */

END IF; /* ASGMPE=0 ASGMPS =0 */

/* **************************************************************
 If code reaches here, then we're prorating for one reason or the other.
***************************************************************** */


IF (l_asg_info_changes > 0) AND (l_eev_info_changes = 0) THEN /*ASG =1 EEV =0*/


/* ************** ONLY ASG CHANGES START ****  */

  p_actual_hours_worked := 0;
  hr_utility.set_location('calculate_period_earnings', 70);
  hr_utility.trace('UDFS ONLY ASG CHANGES START');

  BEGIN /* Get Asg Details ASGMPE */

    hr_utility.trace('Get Asg details - ASGMPE');
    hr_utility.set_location('calculate_period_earnings', 71);

    SELECT	GREATEST(ASG.effective_start_date, p_period_start),
		ASG.effective_end_date,
		NVL(ASG.NORMAL_HOURS, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
    INTO	v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_work_schedule
    FROM	per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL,
		hr_lookups			HRL
    WHERE	ASG.assignment_id		= p_asst_id
    AND		ASG.business_group_id + 0	= p_bus_grp_id
    AND  	ASG.effective_start_date       <= p_period_start
    AND   	ASG.effective_end_date 	       >= p_period_start
    AND   	ASG.effective_end_date 		< p_period_end
    AND		AST.assignment_status_type_id 	= ASG.assignment_status_type_id
    AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
    AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
    AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
    AND		SCL.enabled_flag		= 'Y'
    AND		HRL.lookup_code(+)		= ASG.frequency
    AND		HRL.lookup_type(+)		= 'FREQUENCY';


    hr_utility.trace('If ASGMPE Details succ. then Calling Prorate_Earnings');
    hr_utility.set_location('calculate_period_earnings', 72);
    v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate 	=> p_ass_hrly_figure,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked      	=> p_actual_hours_worked);

    hr_utility.trace('After Calling Prorate_Earnings');

  EXCEPTION WHEN NO_DATA_FOUND THEN

    NULL;

  END; /* Get Asg Details */


  hr_utility.trace('ONLY ASG , select MULTIASG');
  hr_utility.set_location('calculate_period_earnings', 77);

  OPEN get_asst_chgs;	-- SELECT (ASG2 MULTIASG)
  LOOP

    FETCH get_asst_chgs
    INTO  v_range_start,
	  v_range_end,
	  v_asst_std_hrs,
	  v_asst_std_freq,
	  v_work_schedule;
    EXIT WHEN get_asst_chgs%NOTFOUND;
    hr_utility.set_location('calculate_period_earnings', 79);


    hr_utility.trace('ONLY ASG Calling Prorate_Earning as MULTIASG successful');

    v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate	 	=> p_ass_hrly_figure,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
         		        p_act_hrs_worked     => p_actual_hours_worked);


    hr_utility.trace('After calling  Prorate_Earnings from MULTIASG');

  END LOOP;

  CLOSE get_asst_chgs;

  BEGIN /* END_SPAN_RECORD */

  hr_utility.set_location('calculate_period_earnings', 89);
  hr_utility.trace('ONLY ASG , select END_SPAN_RECORD');

  SELECT	ASG.effective_start_date,
 		LEAST(ASG.effective_end_date, p_period_end),
		NVL(ASG.normal_hours, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
  INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_work_schedule
  FROM		hr_soft_coding_keyflex		SCL,
		per_assignment_status_types 	AST,
		per_assignments_f 		ASG,
		hr_lookups			HRL
  WHERE		ASG.assignment_id		= p_asst_id
  AND		ASG.business_group_id + 0	= p_bus_grp_id
  AND  		ASG.effective_start_date 	> p_period_start
  AND  		ASG.effective_start_date       <= p_period_end
  AND   	ASG.effective_end_date 		> p_period_end
  AND		AST.assignment_status_type_id	= ASG.assignment_status_type_id
  AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
  AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
  AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
  AND		SCL.enabled_flag		= 'Y'
  AND		HRL.lookup_code(+)		= ASG.frequency
  AND		HRL.lookup_type(+)		= 'FREQUENCY';

  hr_utility.trace('Calling Prorate_Earnings for ONLY ASG END_SPAN_RECORD');
  hr_utility.set_location('calculate_period_earnings', 91);
  v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate 	=> p_ass_hrly_figure,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked     => p_actual_hours_worked);


  hr_utility.trace('Calling Vacation Pay as END_SPAN succ');
  hr_utility.set_location('calculate_period_earnings', 101);

  p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

  hr_utility.trace('Calling Sick Pay as ASG3 succ');

  p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN v_prorated_earnings;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 102);
    hr_utility.trace('Exception of ASG_MID_START_LAST_SPAN_END_DT');

    p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

    hr_utility.trace('Calling Sick Pay as ASG3 not succ');
    p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN v_prorated_earnings;

  END; /* ASG_MID_START_LAST_SPAN_END_DT */

/* ************** ONLY ASG CHANGES END  ****  */


ELSIF (l_asg_info_changes = 0) AND (l_eev_info_changes > 0) THEN

/* ******************* ONLY EEV CHANGES START ****** */

  hr_utility.trace(' Only EEV changes exist');
  hr_utility.set_location('calculate_period_earnings', 103);
  p_actual_hours_worked := 0;


  hr_utility.trace('Calling Prorate_EEV');

  v_prorated_earnings := v_prorated_earnings +
		         Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
				p_pay_id		=> p_payroll_id,
				p_work_sched		=> p_work_schedule,
				p_asg_std_hrs		=> p_asst_std_hrs,
				p_asg_std_freq		=> p_asst_std_freq,
				p_pay_basis		=> p_pay_basis,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> p_period_start,
				p_range_end_date    	=> p_period_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);

  hr_utility.trace('After Calling Prorate_EEV');
  hr_utility.set_location('calculate_period_earnings', 127);

  hr_utility.trace('Calling vacation_pay');

  p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

  hr_utility.trace('Calling sick_pay');

  p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN v_prorated_earnings;

/* ******************* ONLY EEV CHANGES END ****** */

ELSE  /*BOTH ASG AND EEV CHANGES =0*/

/* ******************* BOTH ASG AND EEV CHANGES START ************ */


  hr_utility.trace('UDFS BOTH ASG and EEV chages exist');


  p_actual_hours_worked := 0;


 BEGIN /* Latest Screen Entry Value */

    hr_utility.trace('BOTH ASG Get latest screen entry value for EEVMPE');
    hr_utility.set_location('calculate_period_earnings', 128);

  SELECT	fnd_number.canonical_to_number(EEV.screen_entry_value)
  INTO		v_earnings_entry
  FROM		pay_element_entry_values_f	EEV
  WHERE		EEV.element_entry_id 		= p_ele_entry_id
  AND 		EEV.input_value_id 		= v_inpval_id
  AND		p_period_start between EEV.effective_start_date
                               AND EEV.effective_end_date;
/*4750302
  AND		EEV.effective_start_date       <= p_period_start
  AND  		EEV.effective_end_date 	       >  p_period_start;
*/
  --AND 	EEV.effective_end_date 	      <  p_period_end

  hr_utility.trace('BOTH ASG Get ASGMPE ');

  SELECT	GREATEST(ASG.effective_start_date, p_period_start),
		ASG.effective_end_date,
		NVL(ASG.NORMAL_HOURS, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
  INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_work_schedule
  FROM		per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL,
		hr_lookups			HRL
  WHERE	ASG.assignment_id		= p_asst_id
  AND		ASG.business_group_id + 0	= p_bus_grp_id
  AND  		ASG.effective_start_date       	<= p_period_start
    AND   	ASG.effective_end_date 	       	>= p_period_start
    AND   	ASG.effective_end_date 		< p_period_end
    AND		AST.assignment_status_type_id 	= ASG.assignment_status_type_id
    AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
    AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
    AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
    AND		SCL.enabled_flag		= 'Y'
    AND		HRL.lookup_code(+)		= ASG.frequency
    AND		HRL.lookup_type(+)		= 'FREQUENCY';

  hr_utility.trace('Calling Convert_Period_Type from ASGMPE');
  hr_utility.set_location('v_earnings_entry='||v_earnings_entry, 129);

  v_curr_hrly_rate := Convert_Period_Type(	p_bus_grp_id,
						p_payroll_id,
						v_work_schedule,
						v_asst_std_hrs,
						v_earnings_entry,
						v_pay_basis,
						'HOURLY',
						p_period_start,
						p_period_end,
						v_asst_std_freq);

    hr_utility.trace('Select app. EEVMPE again after range is determined');
    hr_utility.set_location('calculate_period_earnings', 130);

    SELECT	COUNT(EEV.element_entry_value_id)
    INTO	l_eev_info_changes
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND		EEV.input_value_id 		= v_inpval_id
    AND		EEV.effective_start_date       <= v_range_start
    AND		EEV.effective_end_date 	       >= v_range_start
    AND		EEV.effective_end_date 	        < v_range_end;

    IF l_eev_info_changes = 0 THEN


      hr_utility.trace('NO EEVMPE changes');
      hr_utility.set_location('calculate_period_earnings', 132);

      SELECT		fnd_number.canonical_to_number(EEV.screen_entry_value)
      INTO		v_earnings_entry
      FROM		pay_element_entry_values_f	EEV
      WHERE		EEV.element_entry_id 		= p_ele_entry_id
      AND 		EEV.input_value_id 		= v_inpval_id
      AND		v_range_end 	BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date;

      hr_utility.trace('Calling Convert_Period_Type');
      hr_utility.set_location('calculate_period_earnings', 134);

      v_curr_hrly_rate := Convert_Period_Type(	p_bus_grp_id,
						p_payroll_id,
						v_work_schedule,
						v_asst_std_hrs,
						v_earnings_entry,
						v_pay_basis,
						'HOURLY',
						p_period_start,
						p_period_end,
						v_asst_std_freq);

      hr_utility.trace('Calling Prorate_Earnings');
      hr_utility.set_location('calculate_period_earnings', 135);

      v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked      	=> p_actual_hours_worked);

    hr_utility.set_location('calculate_period_earnings', 137);

    ELSE
      -- Do proration for this ASG range by EEV !

      hr_utility.trace('EEVMPE True');
      hr_utility.trace('Do proration for this ASG range by EEV');
      hr_utility.set_location('calculate_period_earnings', 139);

      hr_utility.trace('Calling Prorate_EEV');

      v_prorated_earnings := v_prorated_earnings +
			   Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
				p_pay_id		=> p_payroll_id,
				p_work_sched		=> v_work_schedule,
				p_asg_std_hrs		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq,
				p_pay_basis		=> v_pay_basis,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> v_range_start,
				p_range_end_date    	=> v_range_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);
     hr_utility.set_location('calculate_period_earnings', 140);

    END IF; -- EEV info changes

  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;

 END; /* Latest Screen Entry Value */

  hr_utility.trace(' BOTH ASG - SELECT ASG_MULTI_WITHIN');
  hr_utility.set_location('calculate_period_earnings', 141);

  OPEN get_asst_chgs;	-- SELECT ( ASG_MULTI_WITHIN)
  LOOP

    FETCH get_asst_chgs
    INTO  v_range_start,
	  v_range_end,
	  v_asst_std_hrs,
	  v_asst_std_freq,
	  v_work_schedule;
    EXIT WHEN get_asst_chgs%NOTFOUND;

    --EEV_BEFORE_RANGE_END
    hr_utility.trace('BOTH ASG MULTI select app. EEVMPE again after range det.');
    hr_utility.set_location('calculate_period_earnings', 145);

    SELECT	COUNT(EEV.element_entry_value_id)
    INTO	l_eev_info_changes
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND 	EEV.input_value_id 		= v_inpval_id
    AND		EEV.effective_start_date       <= v_range_start
    AND  	EEV.effective_end_date 	       >= v_range_start
    AND  	EEV.effective_end_date 	        < v_range_end;

    IF l_eev_info_changes = 0 THEN /* IF l_eev_info_changes = 0 */

      -- EEV_FOR_CURR_RANGE_END

      hr_utility.trace('BOTH ASG - EEV false');
      SELECT		fnd_number.canonical_to_number(EEV.screen_entry_value)
      INTO		v_earnings_entry
      FROM		pay_element_entry_values_f	EEV
      WHERE		EEV.element_entry_id 		= p_ele_entry_id
      AND 		EEV.input_value_id 		= v_inpval_id
      AND		v_range_end 	BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date;
      hr_utility.set_location('calculate_period_earnings', 150);
      v_curr_hrly_rate := Convert_Period_Type(	p_bus_grp_id,
						p_payroll_id,
						v_work_schedule,
						v_asst_std_hrs,
						v_earnings_entry,
						v_pay_basis,
						'HOURLY',
						p_period_start,
						p_period_end,
						v_asst_std_freq);

      v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked       	=> p_actual_hours_worked);

     hr_utility.set_location('calculate_period_earnings', 155);
    ELSE
      hr_utility.trace('BOTH ASG - EEV true');
      v_prorated_earnings := v_prorated_earnings +
	  		     Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
				p_pay_id		=> p_payroll_id,
				p_work_sched		=> v_work_schedule,
				p_asg_std_hrs		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq,
				p_pay_basis		=> v_pay_basis,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> v_range_start,
				p_range_end_date    	=> v_range_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);

    END IF; /* IF l_eev_info_changes = 0 */

  END LOOP;

  CLOSE get_asst_chgs;


  BEGIN /*  SPAN_RECORD */

  hr_utility.trace('BOTH ASG SELECT END_SPAN_RECORD');
  hr_utility.set_location('calculate_period_earnings', 160);

  SELECT	ASG.effective_start_date,
 		LEAST(ASG.effective_end_date, p_period_end),
		NVL(ASG.normal_hours, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
  INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_work_schedule
  FROM		hr_soft_coding_keyflex		SCL,
		per_assignment_status_types 	AST,
		per_assignments_f 		ASG,
		hr_lookups			HRL
  WHERE	ASG.assignment_id		= p_asst_id
  AND		ASG.business_group_id + 0	= p_bus_grp_id
  AND  		ASG.effective_start_date 	> p_period_start
  AND  		ASG.effective_start_date	<= p_period_end
  AND   		ASG.effective_end_date 	> p_period_end
  AND		AST.assignment_status_type_id	= ASG.assignment_status_type_id
  AND		AST.per_system_status 	= 'ACTIVE_ASSIGN'
  AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
  AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
  AND		SCL.enabled_flag		= 'Y'
  AND		HRL.lookup_code(+)		= ASG.frequency
  AND		HRL.lookup_type(+)		= 'FREQUENCY';



  hr_utility.trace('SELECT EEVMPE');

  SELECT	COUNT(EEV.element_entry_value_id)
  INTO		l_eev_info_changes
  FROM		pay_element_entry_values_f	EEV
  WHERE		EEV.element_entry_id 		= p_ele_entry_id
  AND 		EEV.input_value_id 		= v_inpval_id
  AND		EEV.effective_start_date       <= v_range_start
  AND  		EEV.effective_end_date 	       >= v_range_start
  AND  		EEV.effective_end_date 	        < v_range_end;

  IF l_eev_info_changes = 0 THEN

     hr_utility.trace('BOTH ASG SPAN - SELECT EEV_FOR_CURR_RANGE_END');
     hr_utility.set_location('calculate_period_earnings', 165);

    SELECT	fnd_number.canonical_to_number(EEV.screen_entry_value)
    INTO	v_earnings_entry
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND 	EEV.input_value_id 		= v_inpval_id
    AND		v_range_end BETWEEN EEV.effective_start_date
			        AND EEV.effective_end_date;

    v_curr_hrly_rate := Convert_Period_Type(	p_bus_grp_id,
						p_payroll_id,
						p_work_schedule,
						p_asst_std_hrs,
						v_earnings_entry,
						v_pay_basis,
						'HOURLY',
						p_period_start,
						p_period_end,
						v_asst_std_freq);

    v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked       	=> p_actual_hours_worked);

  hr_utility.set_location('calculate_period_earnings', 170);
  ELSE /* EEV succ */

    hr_utility.trace('BOTH ASG END_SPAN - EEV true');
    v_prorated_earnings := v_prorated_earnings +
	  		     Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
				p_pay_id		=> p_payroll_id,
				p_work_sched		=> v_work_schedule,
				p_asg_std_hrs		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq,
				p_pay_basis		=> v_pay_basis,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> v_range_start,
				p_range_end_date    	=> v_range_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);
  hr_utility.set_location('calculate_period_earnings', 175);
  END IF;


  p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);
  hr_utility.set_location('calculate_period_earnings', 180);

  p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);
  hr_utility.set_location('calculate_period_earnings', 185);

  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN v_prorated_earnings;

  EXCEPTION WHEN NO_DATA_FOUND THEN

    p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

    p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN v_prorated_earnings;

  END;


/* ******************* BOTH ASG AND EEV CHANGES ENDS ************ */

END IF; /*END IF OF BOTH ASG AND EEV CHANGES */

EXCEPTION
  WHEN NO_DATA_FOUND THEN

    p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

    p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

    RETURN v_prorated_earnings;

END Calculate_Period_Earnings;

-- **********************************************************************

FUNCTION standard_hours_worked(
				p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER IS

c_wkdays_per_week	NUMBER(5,2)		;
c_wkdays_per_month	NUMBER(5,2)		;
c_wkdays_per_year	NUMBER(5,2)		;

/* 353434, 368242 : Fixed number width for total hours */
v_total_hours	NUMBER(15,7)	;
v_wrkday_hours	NUMBER(15,7) 	;	 -- std hrs/wk divided by 5 workdays/wk
v_curr_date	DATE;
v_curr_day	VARCHAR2(3); -- 3 char abbrev for day of wk.
v_day_no        NUMBER;

BEGIN -- standard_hours_worked

 /* Init */
c_wkdays_per_week := 5;
c_wkdays_per_month := 20;
c_wkdays_per_year := 250;
v_total_hours := 0;
v_wrkday_hours :=0;
v_curr_date := NULL;
v_curr_day :=NULL;

-- Check for valid range
hr_utility.trace('Entered standard_hours_worked');

IF p_range_start > p_range_end THEN
  hr_utility.trace('p_range_start greater than p_range_end');
  RETURN v_total_hours;
--  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
--  hr_utility.raise_error;
END IF;
--

IF UPPER(p_std_freq) = 'WEEK' THEN
  hr_utility.trace('p_std_freq = WEEK ');

  v_wrkday_hours := p_std_hrs / c_wkdays_per_week;

 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_week ='||to_number(c_wkdays_per_week));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSIF UPPER(p_std_freq) = 'MONTH' THEN

  hr_utility.trace('p_std_freq = MONTH ');

  v_wrkday_hours := p_std_hrs / c_wkdays_per_month;


 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_month ='||to_number(c_wkdays_per_month));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSIF UPPER(p_std_freq) = 'YEAR' THEN

  hr_utility.trace('p_std_freq = YEAR ');
  v_wrkday_hours := p_std_hrs / c_wkdays_per_year;

 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_year ='||to_number(c_wkdays_per_year));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSE
hr_utility.trace('p_std_freq in ELSE ');
  v_wrkday_hours := p_std_hrs;
END IF;

v_curr_date := p_range_start;

hr_utility.trace('v_curr_date is range start'||to_char(v_curr_date));


LOOP

  v_day_no := TO_CHAR(v_curr_date, 'D');


  IF v_day_no > 1 and v_day_no < 7 then


    v_total_hours := nvl(v_total_hours,0) + v_wrkday_hours;

   hr_utility.trace('  v_day_no  = '||to_char(v_day_no));
   hr_utility.trace('  v_total_hours  = '||to_char(v_total_hours));
  END IF;

  v_curr_date := v_curr_date + 1;
  EXIT WHEN v_curr_date > p_range_end;
END LOOP;
hr_utility.trace('  Final v_total_hours  = '||to_char(v_total_hours));
hr_utility.trace('  Leaving standard_hours_worked' );
--
RETURN v_total_hours;
--
END standard_hours_worked;
--
-- **********************************************************************
FUNCTION Convert_Period_Type(
		p_bus_grp_id		in NUMBER,
		p_payroll_id		in NUMBER,
		p_asst_work_schedule	in VARCHAR2,
		p_asst_std_hours	in NUMBER,
		p_figure		in NUMBER,
		p_from_freq		in VARCHAR2,
		p_to_freq		in VARCHAR2,
		p_period_start_date	in DATE,
		p_period_end_date	in DATE,
		p_asst_std_freq		in VARCHAR2,
          p_rate_calc_override    in VARCHAR2)
RETURN NUMBER IS

-- local vars
v_calc_type                  VARCHAR2(50);
v_from_stnd_factor           NUMBER(30,7);
v_stnd_start_date            DATE;

v_converted_figure           NUMBER(27,7);
v_from_annualizing_factor    NUMBER(30,7);
v_to_annualizing_factor	     NUMBER(30,7);

-- local fun

FUNCTION Get_Annualizing_Factor(p_bg			in NUMBER,
				p_payroll		in NUMBER,
				p_freq			in VARCHAR2,
				p_asg_work_sched	in VARCHAR2,
				p_asg_std_hrs		in NUMBER,
				p_asg_std_freq		in VARCHAR2)
RETURN NUMBER IS

-- local constants

c_weeks_per_year	NUMBER(3);
c_days_per_year	NUMBER(3);
c_months_per_year	NUMBER(3);

-- local vars
/* 353434, 368242 : Fixed number width for total hours variables */
v_annualizing_factor	NUMBER(30,7);
v_periods_per_fiscal_yr	NUMBER(5);
v_hrs_per_wk		NUMBER(15,7);
v_hrs_per_range		NUMBER(15,7);
v_use_pay_basis	NUMBER(1);
v_pay_basis		VARCHAR2(80);
v_range_start		DATE;
v_range_end		DATE;
v_work_sched_name	VARCHAR2(80);
v_ws_id			NUMBER(9);
v_period_hours		BOOLEAN;

BEGIN -- Get_Annualizing_Factor

  /* Init */

c_weeks_per_year   := 52;
c_days_per_year    := 200;
c_months_per_year  := 12;
v_use_pay_basis	   := 0;
--
-- Check for use of salary admin (ie. pay basis) as frequency.
-- Selecting "count" because we want to continue processing even if
-- the from_freq is not a pay basis.
--

 hr_utility.trace('  Entered  Get_Annualizing_Factor ');

 BEGIN	-- Is Freq pay basis?

  --
  -- Decode pay basis and set v_annualizing_factor accordingly.
  -- PAY_BASIS "Meaning" is passed from FF !
  --

  hr_utility.trace('  Getting lookup code for lookup_type = PAY_BASIS');
  hr_utility.trace('  p_freq ='||p_freq);

  SELECT	lookup_code
  INTO		v_pay_basis
  FROM		hr_lookups	 	lkp
  WHERE 	lkp.application_id	= 800
  AND		lkp.lookup_type		= 'PAY_BASIS'
  AND		lkp.meaning		= p_freq;

  hr_utility.trace('  Lookup_code ie v_pay_basis ='||v_pay_basis);
  v_use_pay_basis := 1;

  IF v_pay_basis = 'MONTHLY' THEN

    hr_utility.trace('  Entered for MONTHLY v_pay_basis');

    v_annualizing_factor := 12;

    hr_utility.trace(' v_annualizing_factor = 12 ');
  ELSIF v_pay_basis = 'HOURLY' THEN

      hr_utility.trace('  Entered for HOURLY v_pay_basis');

      IF p_period_start_date IS NOT NULL THEN

      hr_utility.trace('  p_period_start_date IS NOT NULL v_period_hours=T');
        v_range_start 	:= p_period_start_date;
        v_range_end	:= p_period_end_date;
        v_period_hours	:= TRUE;
      ELSE

      hr_utility.trace('  p_period_start_date IS NULL');

        v_range_start 	:= sysdate;
        v_range_end	:= sysdate + 6;
        v_period_hours 	:= FALSE;
      END IF;

      IF UPPER(p_asg_work_sched) <> 'NOT ENTERED' THEN

      -- Hourly employee using work schedule.
      -- Get work schedule name

      hr_utility.trace('  Hourly employee using work schedule');
      hr_utility.trace('  Get work schedule name');

         v_ws_id := fnd_number.canonical_to_number(p_asg_work_sched);

      hr_utility.trace('  v_ws_id ='||to_number(v_ws_id));


        SELECT	user_column_name
        INTO	v_work_sched_name
        FROM	pay_user_columns
        WHERE	user_column_id 			= v_ws_id
        AND	NVL(business_group_id, p_bg) 	= p_bg
  	AND     NVL(legislation_code,'US')      = 'US';

         hr_utility.trace('  v_work_sched_name ='||v_work_sched_name);
         hr_utility.trace('  Calling Work_Schedule_Total_Hours');

         v_hrs_per_range := Work_Schedule_Total_Hours(	p_bg,
							v_work_sched_name,
							v_range_start,
							v_range_end);

      ELSE-- Hourly emp using Standard Hours on asg.

         hr_utility.trace('  Hourly emp using Standard Hours on asg');


         hr_utility.trace('  calling Standard_Hours_Worked');
         v_hrs_per_range := Standard_Hours_Worked(	p_asg_std_hrs,
						v_range_start,
						v_range_end,
						p_asg_std_freq);

      END IF;

      IF v_period_hours THEN

         hr_utility.trace('  v_period_hours is TRUE');

         select TPT.number_per_fiscal_year
          into    v_periods_per_fiscal_yr
          from   pay_payrolls_f  PPF,
                 per_time_period_types TPT,
                 fnd_sessions fs
         where  PPF.payroll_id = p_payroll
         and    fs.session_id = USERENV('SESSIONID')
         and    fs.effective_date between PPF.effective_start_date and PPF.effective_end_date
            and   TPT.period_type = PPF.period_type;

         v_annualizing_factor := v_hrs_per_range * v_periods_per_fiscal_yr;

      ELSE

         v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;

      END IF;

  ELSIF v_pay_basis = 'PERIOD' THEN

    hr_utility.trace('  v_pay_basis = PERIOD');

    SELECT  TPT.number_per_fiscal_year
    INTO        v_annualizing_factor
    FROM    pay_payrolls_f          PRL,
            per_time_period_types   TPT,
            fnd_sessions            fs
    WHERE   TPT.period_type         = PRL.period_type
    and     fs.session_id = USERENV('SESSIONID')
    and     fs.effective_date  BETWEEN PRL.effective_start_date
                          AND PRL.effective_end_date
    AND     PRL.payroll_id          = p_payroll
    AND     PRL.business_group_id + 0   = p_bg;


  ELSIF v_pay_basis = 'ANNUAL' THEN


    hr_utility.trace('  v_pay_basis = ANNUAL');
    v_annualizing_factor := 1;

  ELSE

    -- Did not recognize "pay basis", return -999 as annualizing factor.
    -- Remember this for debugging when zeroes come out as results!!!

    hr_utility.trace('  Did not recognize pay basis');

    v_annualizing_factor := 0;
    RETURN v_annualizing_factor;

  END IF;

 EXCEPTION

  WHEN NO_DATA_FOUND THEN

    hr_utility.trace('  When no data found' );
    v_use_pay_basis := 0;

 END; /* SELECT LOOKUP CODE */

IF v_use_pay_basis = 0 THEN

    hr_utility.trace('  Not using pay basis as frequency');

  -- Not using pay basis as frequency...

  IF (p_freq IS NULL) 			OR
     (UPPER(p_freq) = 'PERIOD') 		OR
     (UPPER(p_freq) = 'NOT ENTERED') 	THEN

    -- Get "annuallizing factor" from period type of the payroll.

    hr_utility.trace('Get annuallizing factor from period type of the payroll');

    SELECT  TPT.number_per_fiscal_year
    INTO    v_annualizing_factor
    FROM    pay_payrolls_f          PRL,
            per_time_period_types   TPT,
            fnd_sessions            fs
    WHERE   TPT.period_type         = PRL.period_type
    and     fs.session_id = USERENV('SESSIONID')
    and     fs.effective_date  BETWEEN PRL.effective_start_date
                          AND PRL.effective_end_date
    AND     PRL.payroll_id          = p_payroll
    AND     PRL.business_group_id + 0   = p_bg;

    hr_utility.trace('v_annualizing_factor ='||to_number(v_annualizing_factor));

  ELSIF UPPER(p_freq) <> 'HOURLY' THEN

    -- Not hourly, an actual time period type!
   hr_utility.trace('Not hourly - an actual time period type');

   BEGIN

    hr_utility.trace(' selecting from per_time_period_types');

    SELECT	PT.number_per_fiscal_year
    INTO		v_annualizing_factor
    FROM	per_time_period_types 	PT
    WHERE	UPPER(PT.period_type) 	= UPPER(p_freq);

    hr_utility.trace('v_annualizing_factor ='||to_number(v_annualizing_factor));

   EXCEPTION when NO_DATA_FOUND then

     -- Added as part of SALLY CLEANUP.
     -- Could have been passed in an ASG_FREQ dbi which might have the values of
     -- 'Day' or 'Month' which do not map to a time period type.  So we'll do these by hand.

      IF UPPER(p_freq) = 'DAY' THEN
        hr_utility.trace('  p_freq = DAY');
        v_annualizing_factor := c_days_per_year;
      ELSIF UPPER(p_freq) = 'MONTH' THEN
        v_annualizing_factor := c_months_per_year;
        hr_utility.trace('  p_freq = MONTH');
      END IF;

    END;

  ELSE  -- Hourly employee...
     hr_utility.trace('  Hourly Employee');

     IF p_period_start_date IS NOT NULL THEN
        v_range_start 	:= p_period_start_date;
        v_range_end	:= p_period_end_date;
        v_period_hours	:= TRUE;
     ELSE
        v_range_start 	:= sysdate;
        v_range_end	:= sysdate + 6;
        v_period_hours 	:= FALSE;
     END IF;

     IF UPPER(p_asg_work_sched) <> 'NOT ENTERED' THEN

    -- Hourly emp using work schedule.
    -- Get work schedule name:

        v_ws_id := fnd_number.canonical_to_number(p_asg_work_sched);

        SELECT	user_column_name
        INTO	v_work_sched_name
        FROM	pay_user_columns
        WHERE	user_column_id 			= v_ws_id
        AND	NVL(business_group_id, p_bg) 	= p_bg
  	AND     NVL(legislation_code,'US')      = 'US';


        v_hrs_per_range := Work_Schedule_Total_Hours(	p_bg,
							v_work_sched_name,
							v_range_start,
							v_range_end);

     ELSE-- Hourly emp using Standard Hours on asg.

         hr_utility.trace('  Hourly emp using Standard Hours on asg');

         hr_utility.trace('calling Standard_Hours_Worked');

         v_hrs_per_range := Standard_Hours_Worked(p_asg_std_hrs,
						v_range_start,
						v_range_end,
						p_asg_std_freq);

         hr_utility.trace('returned Standard_Hours_Worked');
     END IF;


      IF v_period_hours THEN

         hr_utility.trace('v_period_hours = TRUE');

         select TPT.number_per_fiscal_year
          into    v_periods_per_fiscal_yr
          from   pay_payrolls_f        PPF,
                 per_time_period_types TPT,
                 fnd_sessions          fs
         where  PPF.payroll_id = p_payroll
         and    fs.session_id = USERENV('SESSIONID')
         and    fs.effective_date  between PPF.effective_start_date and PPF.effective_end_date
         and   TPT.period_type = PPF.period_type;

         v_annualizing_factor := v_hrs_per_range * v_periods_per_fiscal_yr;
         hr_utility.trace('v_hrs_per_range ='||to_number(v_hrs_per_range));
         hr_utility.trace('v_periods_per_fiscal_yr ='||to_number(v_periods_per_fiscal_yr));
         hr_utility.trace('v_annualizing_factor ='||to_number(v_annualizing_factor));

      ELSE

         hr_utility.trace('v_period_hours = FALSE');

         v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;

         hr_utility.trace('v_hrs_per_range ='||to_number(v_hrs_per_range));
         hr_utility.trace('c_weeks_per_year ='||to_number(c_weeks_per_year));
         hr_utility.trace('v_annualizing_factor ='||to_number(v_annualizing_factor));

      END IF;

  END IF;

END IF;	-- (v_use_pay_basis = 0)


    hr_utility.trace('  Getting out of Get_Annualizing_Factor for '||v_pay_basis);
RETURN v_annualizing_factor;

END Get_Annualizing_Factor;


BEGIN		 -- Convert Figure
--begin_convert_period_type

  --hr_utility.trace_on(null,'UDFS');

  hr_utility.trace('UDFS Entered Convert_Period_Type');

hr_utility.trace('  p_bus_grp_id: '|| p_bus_grp_id);
hr_utility.trace('  p_payroll_id: '||p_payroll_id);
hr_utility.trace('  p_asst_work_schedule: '||p_asst_work_schedule);
hr_utility.trace('  p_asst_std_hours: '||p_asst_std_hours);
hr_utility.trace('  p_figure: '||p_figure);
hr_utility.trace('  p_from_freq : '||p_from_freq);
hr_utility.trace('  p_to_freq: '||p_to_freq);
hr_utility.trace('  p_period_start_date: '||to_char(p_period_start_date));

hr_utility.trace('  p_period_end_date: '||to_char(p_period_end_date));
hr_utility.trace('  p_asst_std_freq: '||p_asst_std_freq);


  --
  -- If From_Freq and To_Freq are the same, then we're done.
  --

  IF NVL(p_from_freq, 'NOT ENTERED') = NVL(p_to_freq, 'NOT ENTERED') THEN

    RETURN p_figure;

  END IF;
  hr_utility.trace('Calling Get_Annualizing_Factor for FROM case');
  v_from_annualizing_factor := Get_Annualizing_Factor(
			p_bg			=> p_bus_grp_id,
			p_payroll		=> p_payroll_id,
			p_freq			=> p_from_freq,
			p_asg_work_sched	=> p_asst_work_schedule,
			p_asg_std_hrs		=> p_asst_std_hours,
			p_asg_std_freq		=> p_asst_std_freq);

  hr_utility.trace('Calling Get_Annualizing_Factor for TO case');

  v_to_annualizing_factor := Get_Annualizing_Factor(
			p_bg			=> p_bus_grp_id,
			p_payroll		=> p_payroll_id,
			p_freq			=> p_to_freq,
			p_asg_work_sched	=> p_asst_work_schedule,
			p_asg_std_hrs		=> p_asst_std_hours,
			p_asg_std_freq		=> p_asst_std_freq);

  --
  -- Annualize "Figure" and convert to To_Freq.
  --
 hr_utility.trace('v_from_annualizing_factor ='||to_char(v_from_annualizing_factor));
 hr_utility.trace('v_to_annualizing_factor ='||to_char(v_to_annualizing_factor));

  IF v_to_annualizing_factor = 0 	OR
     v_to_annualizing_factor = -999	OR
     v_from_annualizing_factor = -999	THEN

    hr_utility.trace(' v_to_ann =0 or -999 or v_from = -999');

    v_converted_figure := 0;
    RETURN v_converted_figure;

  ELSE

    hr_utility.trace(' v_to_ann NOT 0 or -999 or v_from = -999');

    hr_utility.trace('p_figure Monthly Salary = '||p_figure);
    hr_utility.trace('v_from_annualizing_factor = '||v_from_annualizing_factor);
    hr_utility.trace('v_to_annualizing_factor   = '||v_to_annualizing_factor);

    v_converted_figure := (p_figure * v_from_annualizing_factor) / v_to_annualizing_factor;
    hr_utility.trace('conv figure is monthly_sal * ann_from div by ann to');

    hr_utility.trace('UDFS v_converted_figure := '||v_converted_figure);

  END IF;

-- Done

  /***********************************************************
   The is wrapper is added to check the caluclation rule given
   at the payroll level. Depending upon the Rule we  will the
   Get_Annualizing_Factor fun calls. If the rule is
   standard it goes to Standard Caluclation type. If the rule
   is Annual then it goes to ANNU rule
  **************************************************************/
  IF p_period_start_date IS  NULL THEN
     v_stnd_start_date := sysdate;
  ELSE
     v_stnd_start_date := p_period_start_date ;
  END IF;

  begin
       select nvl(ppf.prl_information2,'NOT ENTERED')
         into v_calc_type
         from pay_payrolls_f ppf
        where payroll_id = p_payroll_id
          and v_stnd_start_date between ppf.effective_start_date
                                    and ppf.effective_end_Date;
  exception
    when others then
       v_calc_type := null;
  end;

  IF
    (v_calc_type = 'STND'  and p_to_freq <> 'NOT ENTERED'
     and p_rate_calc_override = 'FIXED') OR
    (v_calc_type = 'NOT ENTERED' and p_to_freq <> 'NOT ENTERED'
     and p_rate_calc_override = 'FIXED') OR
    (v_calc_type = 'STND' and p_to_freq <> 'NOT ENTERED'
     and p_rate_calc_override = 'NOT ENTERED') OR
    (v_calc_type = 'ANNU' and p_to_freq <> 'NOT ENTERED'
     and p_rate_calc_override = 'FIXED')
 THEN

     v_from_stnd_factor := Get_Annualizing_Factor(
                              p_bg             => p_bus_grp_id,
                              p_payroll        => p_payroll_id,
                              p_freq           => p_from_freq,
                              p_asg_work_sched => p_asst_work_schedule,
                              p_asg_std_hrs    => p_asst_std_hours,
                              p_asg_std_freq   => p_asst_std_freq);

     v_converted_figure :=(p_figure * v_from_stnd_factor/(52 * p_asst_std_hours));

  END IF;


RETURN v_converted_figure;

END Convert_Period_Type;

--
-- **********************************************************************
--
FUNCTION work_schedule_total_hours(
				p_bg_id		in NUMBER,
				p_ws_name	in VARCHAR2,
				p_range_start	in DATE,
				p_range_end	in DATE)
RETURN NUMBER IS

-- local constants

c_ws_tab_name	VARCHAR2(80)	;

-- local variables

/* 353434, 368242 : Fixed number width for total hours */
v_total_hours	NUMBER(15,7);
v_range_start	DATE;
v_range_end	DATE;
v_curr_date	DATE;
v_curr_day	VARCHAR2(3);	-- 3 char abbrev for day of wk.
v_ws_name	VARCHAR2(80);	-- Work Schedule Name.
v_gtv_hours	VARCHAR2(80);	-- get_table_value returns varchar2
		-- Remember to FND_NUMBER.CANONICAL_TO_NUMBER result.
v_fnd_sess_row	VARCHAR2(1);
l_exists	VARCHAR2(1);
v_day_no        NUMBER;

BEGIN -- work_schedule_total_hours

 /* Init */
v_total_hours  := 0;
c_ws_tab_name  := 'COMPANY WORK SCHEDULES';

--Bug 1877889 start
--changed to select the work schedule defined
--at the business group level instead of
--hardcoding the default work schedule
--(COMPANY WORK SCHEDULES ) to the
--variable  c_ws_tab_name

begin
select put.user_table_name
  into c_ws_tab_name
  from hr_organization_information hoi
       ,pay_user_tables put
 where  hoi.organization_id = p_bg_id
   and hoi.org_information_context ='Work Schedule'
   and hoi.org_information1 = put.user_table_id ;

EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
end;

--Bug 1877889 end


-- Set range to a single week if no dates are entered:
-- IF (p_range_start IS NULL) AND (p_range_end IS NULL) THEN
--
  v_range_start := NVL(p_range_start, sysdate);
  v_range_end	:= NVL(p_range_end, sysdate + 6);
--
-- END IF;
-- Check for valid range
IF v_range_start > v_range_end THEN
--
  RETURN v_total_hours;
--  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
--  hr_utility.raise_error;
--
END IF;
--
-- Get_Table_Value requires row in FND_SESSIONS.  We must insert this
-- record if one doe not already exist.
--
SELECT  DECODE(COUNT(session_id), 0, 'N', 'Y')
INTO    v_fnd_sess_row
FROM    fnd_sessions
WHERE   session_id      = userenv('sessionid');
--
IF v_fnd_sess_row = 'N' THEN

   dt_fndate.set_effective_date(trunc(sysdate));

END IF;

--
-- Track range dates:
--
-- Check if the work schedule is an id or a name.  If the work
-- schedule does not exist, then return 0.
--
BEGIN
select 'Y'
into   l_exists
from   pay_user_tables PUT,
       pay_user_columns PUC
where  PUC.USER_COLUMN_NAME 		= p_ws_name
and    NVL(PUC.business_group_id, p_bg_id)  = p_bg_id
and    NVL(PUC.legislation_code,'US')       = 'US'
and PUC.user_table_id = PUT.user_table_id
and PUT.user_table_name = c_ws_tab_name;


EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
END;

if l_exists = 'Y' then
   v_ws_name := p_ws_name;
else
   BEGIN
   select PUC.USER_COLUMN_NAME
   into v_ws_name
   from  pay_user_tables PUT,
         pay_user_columns PUC
   where PUC.USER_COLUMN_ID = p_ws_name
   and    NVL(PUC.business_group_id, p_bg_id)       = p_bg_id
   and    NVL(PUC.legislation_code,'US')            = 'US'
   and PUC.user_table_id = PUT.user_table_id
   and PUT.user_table_name = c_ws_tab_name;


   EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN v_total_hours;
   END;
end if;
--
v_curr_date := v_range_start;
--
--
LOOP

  v_day_no := TO_CHAR(v_curr_date, 'D');


  SELECT decode(v_day_no,1,'SUN',2,'MON',3,'TUE',
                               4,'WED',5,'THU',6,'FRI',7,'SAT')
  INTO v_curr_day
  FROM DUAL;

--
--
  v_total_hours := v_total_hours + FND_NUMBER.CANONICAL_TO_NUMBER(hruserdt.get_table_value(p_bg_id,
								c_ws_tab_name,
								v_ws_name,
								v_curr_day));
  v_curr_date := v_curr_date + 1;
--
--
  EXIT WHEN v_curr_date > v_range_end;
--
END LOOP;
--
RETURN v_total_hours;
--
END work_schedule_total_hours;
--
-- **********************************************************************
--
FUNCTION chained_element_exists(p_bg_id		in NUMBER,
				p_asst_id	in NUMBER,
				p_payroll_id	in NUMBER,
				p_date_earned	in DATE,
				p_ele_name	IN VARCHAR2) RETURN VARCHAR2 IS
-- local vars
v_ele_exists	VARCHAR2(1);
--
BEGIN
--
-- Get formula context values: bg, payroll, asst ids; date earned.
--
-- ...
--
  hr_utility.trace('UDFS Entered chained_element_exists');

  SELECT 	DECODE(COUNT(0), 0, 'N', 'Y')
  INTO		v_ele_exists
  FROM		PAY_ELEMENT_ENTRIES_F	ELE,
		PAY_ELEMENT_LINKS_F	ELI,
		PAY_ELEMENT_TYPES_F	ELT
  WHERE		p_date_earned BETWEEN ELE.effective_start_date
                                  AND ELE.effective_end_date
  AND		ELE.assignment_id			= p_asst_id
  AND		ELE.element_link_id 			= ELI.element_link_id
  AND		ELI.business_group_id + 0		= p_bg_id
  AND		ELI.element_type_id			= ELT.element_type_id
  AND		NVL(ELT.business_group_id, p_bg_id)	= p_bg_id
  AND		UPPER(ELT.element_name)			= UPPER(p_ele_name);

  hr_utility.trace('UDFS Leaving chained_element_exists');
  RETURN v_ele_exists;

END chained_element_exists;

--
-- **********************************************************************
--

FUNCTION us_jurisdiction_val (p_jurisdiction_code in VARCHAR2)
  RETURN VARCHAR2 IS

v_valid_jurisdiction	VARCHAR2(1)	; -- RETURN var.

BEGIN
/* Init */
v_valid_jurisdiction := 'E';


IF substr(p_jurisdiction_code, 8,4) = '0000' THEN

  IF substr(p_jurisdiction_code, 4,3) = '000' THEN

    -- Only entered a state geo, check against PAY_US_STATES.

    SELECT 	'S'
    INTO	v_valid_jurisdiction
    FROM	PAY_US_STATES
    WHERE 	STATE_CODE 	= substr(p_jurisdiction_code, 1,2);

  ELSE

    -- State/County entered

    SELECT 	'S'
    INTO	v_valid_jurisdiction
    FROM	PAY_US_COUNTIES
    WHERE 	STATE_CODE 	= substr(p_jurisdiction_code, 1,2)
    AND		COUNTY_CODE 	= substr(p_jurisdiction_code, 4,3);

  END IF;

ELSE

  -- State/County/City entered

  SELECT 	'S'
  INTO		v_valid_jurisdiction
  FROM		PAY_US_CITY_NAMES
  WHERE 	STATE_CODE 	= substr(p_jurisdiction_code, 1,2)
  AND		COUNTY_CODE 	= substr(p_jurisdiction_code, 4,3)
  AND		CITY_CODE 	= substr(p_jurisdiction_code, 8,4)
  --AND           PRIMARY_FLAG    ='Y' -- Bug 3703863-- Commented out as this flag is 'N' for user defined cities.
  AND           ROWNUM < 2;

END IF;

RETURN v_valid_jurisdiction;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

    v_valid_jurisdiction := 'E';
    RETURN v_valid_jurisdiction;

END us_jurisdiction_val;


--
-- **********************************************************************
--
FUNCTION get_process_run_flag (	p_date_earned	IN DATE,
				p_ele_type_id	IN NUMBER) RETURN VARCHAR2 IS
--
v_proc_run_type		VARCHAR2(3)	;
--
BEGIN

  /* Init */
v_proc_run_type := 'REG';
--
--
-- GET <ELE_NAME>_PROCESSING_RUN_TYPE.  IF = 'ALL' then SKIP='N'.
-- This DDF info is held in ELEMENT_INFORMATION3.
--
--
begin
SELECT	element_information3
INTO	v_proc_run_type
FROM	pay_element_types_f
WHERE	p_date_earned BETWEEN effective_start_date
	                  AND effective_end_date
AND	element_type_id = p_ele_type_id;
--
RETURN v_proc_run_type;
--
exception when NO_DATA_FOUND then
  hr_utility.set_location('get_process_run_flag', 30);
  RETURN v_proc_run_type;
end;
--
END get_process_run_flag;
--
-- **********************************************************************
--
FUNCTION check_dedn_freq (	p_payroll_id	IN NUMBER,
				p_bg_id		IN NUMBER,
				p_pay_action_id	IN NUMBER,
				p_date_earned	IN DATE,
				p_ele_type_id	IN NUMBER) RETURN VARCHAR2 IS

v_skip_element		VARCHAR2(1)	;
v_number_per_fy		NUMBER(3);
v_run_number		NUMBER(3);
v_proc_run_type		VARCHAR2(3);
v_freq_rule_exists	NUMBER(3);
v_period_end_date	DATE;

BEGIN
 /* Init */
v_skip_element :='N';


-- Check that <ELE_NAME>_PROCESSING_RUN_TYPE = 'ALL', meaning SKIP='N'.
-- This DDF info is held in ELEMENT_INFORMATION3.

hr_utility.set_location('check_dedn_freq', 10);

begin
SELECT	element_information3
INTO	v_proc_run_type
FROM	pay_element_types_f
WHERE	p_date_earned BETWEEN effective_start_date
	                  AND effective_end_date
AND	element_type_id = p_ele_type_id;

IF v_proc_run_type = 'ALL' THEN
  RETURN v_skip_element;
END IF;

exception when NO_DATA_FOUND then
  RETURN v_skip_element;
end;
--
-- See if freq rule even comes into play here:
--
hr_elements.check_element_freq (p_payroll_id,
		 p_bg_id,
		 p_pay_action_id,
		 p_date_earned,
		 p_ele_type_id,
		 v_skip_element);

hr_utility.set_location('check_dedn_freq', 45);

RETURN v_skip_element;

END check_dedn_freq;

--
-- **********************************************************************
--
FUNCTION Separate_Check_Skip (
		p_bg_id			in NUMBER,
		p_element_type_id	in NUMBER,
		p_assact_id		in NUMBER,
		p_payroll_id		in NUMBER,
		p_date_earned		in DATE) RETURN VARCHAR2 IS

-- This fun is called from skip rules attached to Deductions.
-- Purpose is to check if an earnings requires special "Deduction Processing"
-- ie. take only Pretax and/or Tax deductions.
-- Algorithm:
-- 1. Check for run results where "Deduction Processing" inpval is something
--    other than 'A' for All.
-- 2. If there is, then check classification of current deduction against
--    the deduction processing requirement - ie. skip any deductions that
--    are not pre-tax or tax deductions; further, if dedn proc is 'Tax Only'
--    then skip pre-tax dedns as well - easy!

-- local constants

-- local vars
v_dedn_proc		VARCHAR2(3);
v_dedn_proc_value	VARCHAR2(80);
v_ele_class_name	VARCHAR2(80);
v_skip_element		VARCHAR2(1) 	;

--
BEGIN		 -- Separate_Check_Skip
 /* Init */
v_skip_element := 'N';
--

hr_utility.set_location('Separate_Check_Skip', 7);

SELECT 	RRV.result_value
INTO	v_dedn_proc
FROM	pay_run_result_values 		RRV,
	pay_run_results			PRR,
	pay_input_values_f 		IPV
WHERE  	PRR.assignment_action_id	= p_assact_id
AND	RRV.result_value		<> 'A'
AND 	RRV.run_result_id		= PRR.run_result_id
AND	IPV.input_value_id	     	= RRV.input_value_id
AND    	p_date_earned           BETWEEN IPV.effective_start_date
                                    AND IPV.effective_end_date
and ipv.element_type_id = p_element_type_id
AND	UPPER(IPV.name)			= 'DEDUCTION PROCESSING'
AND	IPV.business_group_id + 0	= p_bg_id
AND prr.element_type_id  = ipv.element_type_id;

  --
  -- We now assume there is a value in Deduction Processing input value of
  -- either 'T' ("Tax Only") or 'PTT' ("Pre-Tax and Tax Only).
  --

v_skip_element := 'Y';

hr_utility.set_location('Separate_Check_Skip', 9);

begin

SELECT	ECL.classification_name
INTO	v_ele_class_name
FROM	pay_element_types_f		ELT,
	pay_element_classifications	ECL
WHERE	ECL.classification_id		= ELT.classification_id
AND	ELT.business_group_id + 0	= p_bg_id
AND	p_date_earned             BETWEEN ELT.effective_start_date
				      AND ELT.effective_end_date
AND	ELT.element_type_id		= p_element_type_id;

IF UPPER(v_ele_class_name) = 'TAX DEDUCTIONS' THEN

  -- Change v_skip_element back to 'N' if this a tax deduction.
  -- ie. we know DEDN PROC inpval is not null, meaning it's either TAX ONLY
  -- or PRETAX AND TAX ONLY.

  hr_utility.set_location('Separate_Check_Skip', 10);
  v_skip_element := 'N';
  RETURN v_skip_element;

ELSIF UPPER(v_ele_class_name) = 'PRE-TAX DEDUCTIONS' AND
      v_dedn_proc = 'PTT' THEN

  -- Change v_skip_element back to 'N' if dedn proc = 'PTT'

  hr_utility.set_location('Separate_Check_Skip', 11);
  v_skip_element := 'N';
  RETURN v_skip_element;

END IF;

exception WHEN NO_DATA_FOUND THEN
  hr_utility.set_location('Separate_Check_Skip - Error EleClass NOTFOUND', 12);
  v_skip_element := 'Y';
  --  hr_utility.set_message(801, 'PAY_ELE_CLASS_NOTFOUND');
  --  hr_utility.raise_error;
end;

RETURN v_skip_element;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('Separate_Check_Skip', 21);
    RETURN v_skip_element;
    -- Special Dedn Proc not required. SKIP_FLAG = 'N'.
--
END Separate_Check_Skip;
--
-- **********************************************************************
--
/* ( ) OTHER_NON_SEPARATE_CHECK
  Desc: Returns 'Y' if other ELEMENT ENTRIES exist where
  Separate_Check = 'N' or null ;
  OR
  Earnings element entries exist with no "Separate Check" input
  value at all.
*/
FUNCTION Other_Non_Separate_Check (
			p_date_earned	IN DATE,
			p_ass_id	IN NUMBER) RETURN VARCHAR2 IS

-- local vars
sepcheck_flag		VARCHAR2(1)	;
--

BEGIN

  /* Init */
  sepcheck_flag :='N';


hr_utility.set_location('Other_Non_Separate_Check', 10);

SELECT	DECODE(COUNT(IPV.input_value_id), 0, 'N', 'Y')
INTO	sepcheck_flag
FROM	pay_element_entry_values_f	EEV,
	pay_element_entries_f		ELE,
	pay_input_values_f		IPV
WHERE	ELE.assignment_id		= p_ass_id
AND     p_date_earned                   BETWEEN ELE.effective_start_date
                                            AND ELE.effective_end_date
AND	ELE.element_entry_id 		= EEV.element_entry_id
AND	p_date_earned                   BETWEEN EEV.effective_start_date
                                            AND EEV.effective_end_date
AND	nvl(EEV.screen_entry_value,'N')	= 'N'
AND	EEV.input_value_id		= IPV.input_value_id
AND	UPPER(IPV.name)			= 'SEPARATE CHECK';
--
IF sepcheck_flag = 'Y' THEN
  hr_utility.set_location('Other_Non_Separate_Check', 15);
  RETURN sepcheck_flag;
END IF;
--
hr_utility.set_location('Other_Non_Separate_Check', 20);

SELECT	DECODE(COUNT(ELE.element_entry_id), 0, 'N', 'Y')
INTO	sepcheck_flag
FROM	pay_element_entries_f      		ELE,
	pay_element_links_f			ELL,
        pay_element_types_f 			ELT,
	pay_element_classifications		ECL
WHERE	ELE.assignment_id               = p_ass_id
AND     p_date_earned                   BETWEEN ELE.effective_start_date
                                            and ELE.effective_end_date
AND     ELE.element_link_id 		= ELL.element_link_id
AND     p_date_earned                   BETWEEN ELL.effective_start_date
                                            and ELL.effective_end_date
AND	ELL.element_type_id 		= ELT.element_type_id
AND     p_date_earned                   BETWEEN ELT.effective_start_date
                                            and ELT.effective_end_date
AND     ECL.classification_id           = ELT.classification_id
AND     UPPER(ECL.classification_name)  IN (    'EARNINGS',
                                                'SUPPLEMENTAL EARNINGS',
                                                'IMPUTED EARNINGS',
                                                'NON-PAYROLL PAYMENTS')
AND     NOT EXISTS
       (SELECT 'X'
	FROM   pay_input_values_f              IPV
	WHERE  IPV.element_type_id = ELT.element_type_id
        AND    p_date_earned       BETWEEN IPV.effective_start_date
                                       and IPV.effective_end_date
        AND    UPPER(IPV.name)     = 'SEPARATE CHECK');
--

RETURN sepcheck_flag;

--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('Other_Non_Separate_Check', 30);
    RETURN sepcheck_flag;
--
END Other_Non_Separate_Check;
--
/*
*****************************************************
FUNCTION NAME:
*****************************************************
OT_Base_Rate
Inputs: p_ass_id,		-- Context from formula, pass TO Convert_Figure
   	p_date_earned		-- Context
	p_work_sched		-- Pass to Convert_Figure
	p_std_hours		-- Pass to Convert_Figure

Outputs:	v_ot_base_rate	-- Hourly Rate for use by OT

12 Dec 1993	hparicha	Created.

*****************************************************
DESCRIPTION:
*****************************************************
	1) Add hourly Rate from Regular Wages, Time Entry Wages,
	 or equivalent hourly rate from Regular Salary to v_ot_base_rate;
	2) Get elements and formula names where "Include in OT Base" = 'Y'
	3) Get hourly rate from either input values or run result values
	- based on calculation method (ie. formula name).
--
Calc Rule		Include in OT Base
==============		====================================
Flat Amount		Amount input value converted to hourly rate.
Hours * Rate		Rate input value.
Hours * Rate * Multiple Rate input value.
Percentage of Reg Sal	Percentage input value * Monthly Salary, converted to
			hourly rate.
Gross Up		Gross Amount run result value converted to hourly rate.
*****************************************************
FUNCTION TEXT:
*****************************************************
*/
FUNCTION OT_Base_Rate (	p_bg_id			in NUMBER,
				p_pay_id		in NUMBER,
				p_ass_id		in NUMBER,
				p_ass_action_id	in NUMBER,
		   		p_date_earned		in DATE,
				p_work_sched		in VARCHAR2,
				p_std_hours		in NUMBER,
				p_ass_salary		in NUMBER,
				p_ass_sal_basis	in VARCHAR2,
				p_std_freq		in VARCHAR2)
RETURN NUMBER IS
--
-- local constants
--
c_ot_scale		VARCHAR2(80)	;
c_rate_table_name	VARCHAR2(80)	;
c_rate_table_column	VARCHAR2(80)	;
--
-- local vars
--
v_entry_id		NUMBER(9);
v_ot_base_rate		NUMBER(27,7)	;
v_tew_rate		NUMBER(27,7)	;
v_regwage_rate		NUMBER(27,7)	;
v_regsal_rate		NUMBER(27,7)	;
v_regsal_mosal		NUMBER(27,7)	;
v_tew_rcode		VARCHAR2(80);
v_regwage_rcode		VARCHAR2(80);
v_use_regwage		NUMBER(2);
v_use_regsal		NUMBER(2);
v_ele_type_id		NUMBER(9);
v_ele_class_id		NUMBER(9);
v_include_in_ot		VARCHAR2(1);
v_equiv_hrly_rate	VARCHAR2(80)	;
v_chk_sal		VARCHAR2(1)	;
v_eletype_id		NUMBER(9);
v_ele_name		VARCHAR2(80);
v_ff_name		VARCHAR2(80);
v_flat_amount		NUMBER(27,7)	;
v_flat_total		NUMBER(27,7)	;
v_flat_count		NUMBER(3)	;
v_percentage		NUMBER(27,7)	;
v_pct_sal		NUMBER(27,7)	;
v_pct_total		NUMBER(27,7)	;
v_pct_count		NUMBER(3)	;
v_rate			NUMBER(27,7)	;
v_rate_total		NUMBER(27,7)	;
v_rate_count		NUMBER(3)	;
v_rate_rcode		VARCHAR2(80);
v_rate_multiple		NUMBER(27,7)	;
v_rate_mult_count	NUMBER(3)	;
v_gross_results		NUMBER(3)	;
v_gross_amount		NUMBER(27,7)	;
v_gross_total		NUMBER(27,7)	;
v_gross_count		NUMBER(3)	;
v_tew_count		NUMBER(3)	;
v_tew_total_rate	NUMBER(27,7)	;
v_pay_basis_rate	NUMBER(27,7)	;
v_work_sched_name	VARCHAR2(80);
v_ws_id			NUMBER(9);
v_range_start		DATE;
v_range_end		DATE;
--
-- local cursors
--
CURSOR	get_tew_rate IS
SELECT  /*+ ORDERED */ NVL(fnd_number.canonical_to_number(EEV.screen_entry_value), 0),
    EEV.element_entry_id
FROM  pay_element_entries_f       ELE,
      pay_element_entry_values_f  EEV,
      pay_input_values_f      IPV,
      pay_element_types_f     ELT
WHERE   ELE.assignment_id       = p_ass_id
AND p_date_earned  BETWEEN ELE.effective_start_date
                       AND ELE.effective_end_date
AND ELE.element_entry_id        = EEV.element_entry_id
AND p_date_earned  BETWEEN EEV.effective_start_date
                       AND EEV.effective_end_date
AND EEV.input_value_id = IPV.input_value_id
AND p_date_earned  BETWEEN IPV.effective_start_date
                       AND IPV.effective_end_date
AND IPV.element_type_id = ELT.element_type_id
AND p_date_earned  BETWEEN ELT.effective_start_date
                       AND ElT.effective_end_date
and ipv.business_group_id = elt.business_group_id
and ipv.legislation_code = elt.legislation_code
AND ELT.element_name    = 'Time Entry Wages'
AND IPV.name        = 'Rate';
--
/* CURSOR	get_tew_rcode IS
SELECT  NVL(EEV.screen_entry_value, 'NOT ENTERED')
FROM    pay_element_entry_values_f  EEV,
    pay_element_entries_f       ELE,
    pay_element_types_f     ELT,
    pay_input_values_f      IPV
WHERE   ELE.assignment_id       = p_ass_id
AND p_date_earned  BETWEEN ELE.effective_start_date
                       AND ELE.effective_end_date
AND ELE.element_entry_id        = EEV.element_entry_id
AND p_date_earned  BETWEEN EEV.effective_start_date
                       AND EEV.effective_end_date
AND EEV.input_value_id      = IPV.input_value_id
AND p_date_earned  BETWEEN IPV.effective_start_date
                       AND IPV.effective_end_date
AND ELT.element_name   = 'Time Entry Wages'
AND p_date_earned  BETWEEN ELT.effective_start_date
                       AND ElT.effective_end_date
AND ELT.element_type_id     = IPV.element_type_id
AND ipv.business_group_id = elt.business_group_id
AND ipv.legislation_code = elt.legislation_code
AND IPV.name        = 'Rate Code';

--
*/
--
CURSOR	get_include_in_ot IS
SELECT	ELT.element_type_id,
	ELT.element_name,
	FRA.formula_name
FROM	pay_element_entries_f		ELE,
	pay_element_links_f		ELI,
	pay_element_types_f		ELT,
	pay_status_processing_rules_f	SPR,
	ff_formulas_f			FRA
WHERE	FRA.formula_id			= SPR.formula_id
AND	p_date_earned     BETWEEN	SPR.effective_start_date
				    AND	SPR.effective_end_date
AND	SPR.assignment_status_type_id	IS NULL
AND	SPR.element_type_id		= ELT.element_type_id
AND	p_date_earned    BETWEEN	ELE.effective_start_date
				    AND	ELE.effective_end_date
AND	ELE.assignment_id		= p_ass_id
AND	ELE.element_link_id		= ELI.element_link_id
AND	p_date_earned    BETWEEN	ELI.effective_start_date
				    AND	ELI.effective_end_date
AND	ELI.element_type_id		= ELT.element_type_id
AND	p_date_earned     BETWEEN	ELT.effective_start_date
				    AND	ELT.effective_end_date
AND	ELT.element_information8	= 'Y'
AND	ELT.element_information_category IN (	'US_EARNINGS',
						'US_SUPPLEMENTAL EARNINGS');
--
-- These cursors get ALL entries of a particular element type during
-- the period:
CURSOR get_flat_amounts IS
    SELECT fnd_number.canonical_to_number(EEV.screen_entry_value)
      FROM pay_element_links_f        pel,
           pay_element_entries_f      ele,
           pay_element_entry_values_f eev,
           pay_input_values_f         ipv
     WHERE pel.element_type_id = v_eletype_id
       AND p_date_earned BETWEEN pel.effective_start_date
                             AND pel.effective_end_date
       AND ele.element_link_id = pel.element_link_id
       AND ele.assignment_id = p_ass_id
       AND ele.element_entry_id	= eev.element_entry_id
       AND p_date_earned BETWEEN eev.effective_start_date
                             AND eev.effective_end_date
       AND EEV.input_value_id = ipv.input_value_id
       AND IPV.element_type_id = pel.element_type_id --v_eletype_id
       AND IPV.name = 'Amount';
--
CURSOR get_rates IS
    SELECT fnd_number.canonical_to_number(EEV.screen_entry_value),
           EEV.element_entry_id
    FROM pay_element_links_f        pel,
         pay_element_entries_f      ele,
         pay_element_entry_values_f eev,
         pay_input_values_f         ipv
    WHERE pel.element_type_id = v_eletype_id
      AND p_date_earned BETWEEN pel.effective_start_date
                            AND pel.effective_end_date
      AND ele.element_link_id = pel.element_link_id
      AND ELE.assignment_id = p_ass_id
      AND ELE.element_entry_id = EEV.element_entry_id
      AND p_date_earned BETWEEN EEV.effective_start_date
	                    AND EEV.effective_end_date
      AND EEV.input_value_id = IPV.input_value_id
      AND IPV.element_type_id = pel.element_type_id --v_eletype_id
      AND IPV.name = 'Rate';
--
CURSOR get_percentages IS
    SELECT fnd_number.canonical_to_number(EEV.screen_entry_value)
      FROM pay_element_links_f        pel,
           pay_element_entries_f      ele,
           pay_element_entry_values_f eev,
           pay_input_values_f         ipv
     WHERE pel.element_type_id = v_eletype_id
        AND p_date_earned BETWEEN pel.effective_start_date
                              AND pel.effective_end_date
        AND ele.element_link_id = pel.element_link_id
        AND ele.assignment_id = p_ass_id
        AND ele.element_entry_id = EEV.element_entry_id
        AND p_date_earned BETWEEN EEV.effective_start_date
                              AND EEV.effective_end_date
        AND eev.input_value_id = IPV.input_value_id
        AND ipv.element_type_id	= pel.element_type_id --v_eletype_id
        AND ipv.name = 'Percentage';
--
CURSOR get_grosses IS
    SELECT	fnd_number.canonical_to_number(RRV.result_value)
    FROM	pay_run_result_values	RRV,
		pay_run_results		RRS,
		pay_input_values_f	IPV,
		pay_element_types_f	ELT
    WHERE	RRV.input_value_id		= IPV.input_value_id
    AND		RRV.run_result_id		= RRS.run_result_id
    AND		RRS.element_type_id		= ELT.element_type_id
    AND		RRS.assignment_action_id	= p_ass_action_id
    AND 	p_date_earned           BETWEEN IPV.effective_start_date
					    AND IPV.effective_end_date
    AND		IPV.name			= 'Pay Value'
    AND		IPV.element_type_id		= ELT.element_type_id
    AND 	p_date_earned           BETWEEN ELT.effective_start_date
					    AND ELT.effective_end_date
    AND		ELT.element_name 	= 'Vertex ' || v_ele_name || ' Gross';
    --
    -- Check with Roy on "<ELE_NAME> Gross" element being created for grossups.
    --
--
BEGIN		 -- OT_Base_Rate

  /* Init */
c_ot_scale              := 'Hourly';
c_rate_table_name       := 'WAGE RATES';
c_rate_table_column     := 'Wage Rate';
v_ot_base_rate          := 0;
v_tew_rate              := 0;
v_regwage_rate          := 0;
v_regsal_rate           := 0;
v_regsal_mosal          := 0;
v_equiv_hrly_rate       := 'No OT';
v_chk_sal               := 'N';
v_flat_amount           := 0;
v_flat_total            := 0;
v_flat_count            := 0;
v_percentage            := 0;
v_pct_sal               := 0;
v_pct_total             := 0;
v_pct_count             := 0;
v_rate                  := 0;
v_rate_total            := 0;
v_rate_count            := 0;
v_rate_multiple         := 0;
v_rate_mult_count       := 0;
v_gross_results         := 0;
v_gross_amount          := 0;
v_gross_total           := 0;
v_gross_count           := 0;
v_tew_count             := 0;
v_tew_total_rate        := 0;
v_pay_basis_rate        := 0;
--

--
-- Get "Regular" rate from either Time Entry Wages, Regular Wages,
-- or Regular Salary.  For Time Entry rate, we need to take an average
-- of all Rates entered via Time Entry Wages.
-- Remember to check for a rate via Rate Code!
--
-- Go ahead and set pay_basis_rate now - will most likely be used somewhere.
--
hr_utility.set_location('OT_Base_Rate', 5);

select 	start_date,
	end_date
into	v_range_start,
	v_range_end
from	per_time_periods
where	payroll_id = p_pay_id
and	p_date_earned between start_date and end_date;

v_pay_basis_rate := FND_NUMBER.CANONICAL_TO_NUMBER(hr_us_ff_udfs.convert_period_type(
				p_bus_grp_id		=> p_bg_id,
				p_payroll_id		=> p_pay_id,
				p_asst_work_schedule 	=> p_work_sched,
				p_asst_std_hours		=> p_std_hours,
				p_figure			=> p_ass_salary,
				p_from_freq		=> p_ass_sal_basis,
				p_to_freq		=> 'HOURLY',
				p_period_start_date	=> v_range_start,
				p_period_end_date	=> v_range_end,
				p_asst_std_freq		=> p_std_freq));
--
OPEN get_tew_rate;
--
LOOP
  hr_utility.set_location('OT_Base_Rate', 10);
  FETCH get_tew_rate
  INTO	v_tew_rate, v_entry_id;
  EXIT WHEN get_tew_rate%NOTFOUND;
  --
  v_tew_count := v_tew_count + 1;
  IF v_tew_rate <> 0 THEN
    v_tew_total_rate := v_tew_total_rate + v_tew_rate;
  ELSE -- no Rate entered, check Rate Code
    hr_utility.set_location('OT_Base_Rate', 15);
    SELECT /*+ ORDERED */ NVL(EEV.screen_entry_value, 'NOT ENTERED')
    INTO        v_tew_rcode
    FROM    pay_element_entries_f       ELE,
            pay_element_entry_values_f  EEV,
            pay_input_values_f IPV,
            pay_element_types_f     ELT
    WHERE   ELE.assignment_id       = p_ass_id
    AND     EEV.element_entry_id        = v_entry_id
    AND     ELE.element_entry_id        = EEV.element_entry_id
    AND     p_date_earned           BETWEEN EEV.effective_start_date
                        AND EEV.effective_end_date
    AND     EEV.input_value_id      = IPV.input_value_id
    AND     p_date_earned           BETWEEN IPV.effective_start_date
                        AND IPV.effective_end_date
    AND     ELT.element_name    = 'Time Entry Wages'
    and     p_date_earned           BETWEEN elt.effective_start_date
                        AND elt.effective_end_date
    AND     ELT.element_type_id     = IPV.element_type_id
    AND     ipv.business_group_id = elt.business_group_id
    AND     ipv.legislation_code = elt.legislation_code
    AND     IPV.name         = 'Rate Code';

    --
    IF v_tew_rcode = 'NOT ENTERED' THEN
    -- Use pay basis salary converted to hourly rate.
      v_tew_total_rate := v_tew_total_rate + v_pay_basis_rate;
    ELSE
    -- Find rate from rate table.
      hr_utility.set_location('OT_Base_Rate', 17);
      v_tew_total_rate := v_tew_total_rate +
				FND_NUMBER.CANONICAL_TO_NUMBER(hruserdt.get_table_value(
						p_bg_id,
						c_rate_table_name,
						c_rate_table_column,
						v_tew_rcode));
    END IF;
--
  END IF;
--
END LOOP;
--
CLOSE get_tew_rate;
--
IF v_tew_count = 0 THEN     -- ie. only use "Regular" rates if TEW not entered.
  hr_utility.set_location('OT_Base_Rate', 20);
  SELECT /*+ ORDERED */ COUNT(IPV.input_value_id)
  INTO  v_use_regwage
  FROM  pay_element_entries_f       ELE,
        pay_element_entry_values_f  EEV,
        pay_input_values_f      IPV,
        pay_element_types_f     ELT
  WHERE ELE.assignment_id       = p_ass_id
    AND p_date_earned  BETWEEN ELE.effective_start_date
                           AND ELE.effective_end_date
  AND   ELE.element_entry_id        = EEV.element_entry_id
  AND   p_date_earned           BETWEEN EEV.effective_start_date
                                    AND EEV.effective_end_date
  AND   EEV.input_value_id      = IPV.input_value_id
  AND   p_date_earned           BETWEEN IPV.effective_start_date
                                    AND ipv.effective_end_date
  AND   ELT.element_name     = 'Regular Wages'
  AND   p_date_earned           BETWEEN elt.effective_start_date
                                    AND elt.effective_end_date
  AND   ELT.element_type_id     = IPV.element_type_id
  AND   IPV.business_group_id  = ELT.business_group_id
  AND   IPV.legislation_code = ELT.legislation_code
  AND   IPV.name         = 'Rate';

--
  IF v_use_regwage <> 0 THEN
    hr_utility.set_location('OT_Base_Rate', 30);
    SELECT  /*+ ORDERED */ NVL(fnd_number.canonical_to_number(EEV.screen_entry_value), 0),
        EEV.element_entry_id
    INTO    v_regwage_rate,
        v_entry_id
    FROM  pay_element_entries_f       ELE,
          pay_element_entry_values_f  EEV,
          pay_input_values_f      IPV,
          pay_element_types_f     ELT
    WHERE   ELE.assignment_id       = p_ass_id
    AND   p_date_earned           BETWEEN ele.effective_start_date
                                  AND ele.effective_end_date
    AND   ELE.element_entry_id        = EEV.element_entry_id
    AND   p_date_earned           BETWEEN EEV.effective_start_date
                                AND EEV.effective_end_date
    AND   EEV.input_value_id      = IPV.input_value_id
    AND   p_date_earned           BETWEEN ipv.effective_start_date
                                AND ipv.effective_end_date
    AND   ELT.element_name     = 'Regular Wages'
    AND   p_date_earned           BETWEEN elt.effective_start_date
                                AND elt.effective_end_date
    AND   ELT.element_type_id     = IPV.element_type_id
    AND   IPV.name         = 'Rate'
    AND   IPV.business_group_id = ELT.business_group_id
    AND   IPV.legislation_code = ELT.legislation_code;

--
    IF v_regwage_rate = 0 THEN
      hr_utility.set_location('OT_Base_Rate', 40);
      SELECT /*+ ORDERED */ NVL(EEV.screen_entry_value, 'NOT ENTERED')
      INTO	v_regwage_rcode
      FROM  pay_element_entries_f       ELE,
          pay_element_entry_values_f  EEV,
          pay_input_values_f      IPV,
          pay_element_types_f     ELT
      WHERE ELE.assignment_id       = p_ass_id
      AND p_date_earned between ELE.effective_start_date
                        AND ELE.effective_end_date
      AND   ELE.element_entry_id        = EEV.element_entry_id
      AND   p_date_earned         BETWEEN EEV.effective_start_date
                        AND EEV.effective_end_date
      AND   EEV.element_entry_id        = v_entry_id
      AND   EEV.input_value_id      = IPV.input_value_id
      AND   p_date_earned BETWEEN IPV.effective_start_date
                              AND IPV.effective_end_date
      AND   ELT.element_name        = 'Regular Wages'
      ANd   p_date_earned BETWEEN ELT.effective_start_date
                              AND ELT.effective_end_date
      AND   ELT.element_type_id     = IPV.element_type_id
      AND   IPV.name        = 'Rate Code'
      AND   IPV.business_group_id = ELT.business_group_id
      AND   IPV.legislation_code = ELT.legislation_code;

    --
      hr_utility.set_location('OT_Base_Rate', 41);
      v_regwage_rate := FND_NUMBER.CANONICAL_TO_NUMBER(hruserdt.get_table_value(
					p_bus_group_id	=> p_bg_id,
					p_table_name	=> c_rate_table_name,
					p_col_name	=> c_rate_table_column,
					p_row_value	=> v_regwage_rcode));
    END IF;
    v_ot_base_rate := v_ot_base_rate + v_regwage_rate;
--
  ELSE
    hr_utility.set_location('OT_Base_Rate', 50);
    SELECT 	/*+ ORDERED */ COUNT(IPV.input_value_id)
    INTO	v_use_regsal
    FROM  pay_element_entries_f       ELE,
          pay_element_entry_values_f  EEV,
          pay_input_values_f      IPV,
          pay_element_types_f     ELT
    WHERE   ELE.assignment_id       = p_ass_id
    AND     p_date_earned   BETWEEN ELE.effective_start_date
                    AND ELE.effective_end_date
    AND     ELE.element_entry_id        = EEV.element_entry_id
    AND     p_date_earned   BETWEEN EEV.effective_start_date
                    AND EEV.effective_end_date
    AND     EEV.input_value_id      = IPV.input_value_id
    AND     p_date_earned   BETWEEN IPV.effective_start_date
                    AND IPV.effective_end_date
    AND     ELT.element_name     = 'Regular Salary'
    AND     p_date_earned   BETWEEN ELT.effective_start_date
                    AND ELT.effective_end_date
    AND     ELT.element_type_id     = IPV.element_type_id
    AND     IPV.name         = 'Monthly Salary'
    AND     IPV.business_group_id = ELT.business_group_id
    AND     IPV.legislation_code = ELT.legislation_code;

  --
    IF v_use_regsal <> 0 THEN
      hr_utility.set_location('OT_Base_Rate', 51);
      SELECT /*+ ORDERED */ NVL(fnd_number.canonical_to_number(EEV.screen_entry_value), 0)
      INTO	v_regsal_mosal
      FROM  pay_element_entries_f       ELE,
          pay_element_entry_values_f  EEV,
          pay_input_values_f      IPV,
          pay_element_types_f     ELT
      WHERE   ELE.assignment_id       = p_ass_id
      AND     p_date_earned   BETWEEN ELE.effective_start_date
                      AND ELE.effective_end_date
      AND     ELE.element_entry_id        = EEV.element_entry_id
      AND     p_date_earned   BETWEEN EEV.effective_start_date
                      AND EEV.effective_end_date
      AND     EEV.input_value_id      = IPV.input_value_id
      AND     p_date_earned   BETWEEN IPV.effective_start_date
                      AND IPV.effective_end_date
      AND     ELT.element_name     = 'Regular Salary'
      AND     p_date_earned   BETWEEN ELT.effective_start_date
                      AND ELT.effective_end_date
      AND     ELT.element_type_id     = IPV.element_type_id
      AND     IPV.name         = 'Monthly Salary'
      AND     IPV.business_group_id = ELT.business_group_id
      AND     IPV.legislation_code = ELT.legislation_code;

  --
      hr_utility.set_location('OT_Base_Rate', 60);

      v_regsal_rate := hr_us_ff_udfs.Convert_Period_Type(
				p_bus_grp_id		=> p_bg_id,
				p_payroll_id		=> p_pay_id,
				p_asst_work_schedule 	=> p_work_sched,
				p_asst_std_hours		=> p_std_hours,
				p_figure			=> v_regsal_mosal,
				p_from_freq		=> p_ass_sal_basis,
				p_to_freq		=> 'HOURLY',
				p_period_start_date	=> v_range_start,
				p_period_end_date	=> v_range_end,
				p_asst_std_freq		=> p_std_freq);
  --
    END IF;
--
  END IF;  -- "Regular" rate done.
--
ELSE
-- TEW entered, so take average:
  v_ot_base_rate := v_ot_base_rate + (v_tew_total_rate / v_tew_count);
--
END IF;	-- TEW entered.
--
-- Now add all other "Include in OT Base" = 'Y' values.
--
OPEN get_include_in_ot;
LOOP
--
  hr_utility.set_location('OT_Base_Rate', 70);
  FETCH get_include_in_ot
  INTO	v_eletype_id,
	v_ele_name,
	v_ff_name;
  EXIT WHEN get_include_in_ot%NOTFOUND;
--
  IF SUBSTR(v_ff_name,1,11) = 'FLAT_AMOUNT' THEN
    -- Find "Amount" entered, convert to hourly figure.
    hr_utility.set_location('OT_Base_Rate', 80);
    OPEN get_flat_amounts;
    LOOP
      FETCH get_flat_amounts
      INTO  v_flat_amount;
      EXIT WHEN get_flat_amounts%NOTFOUND;
      v_flat_count := v_flat_count + 1;
      hr_utility.set_location('OT_Base_Rate', 90);

       v_flat_total := v_flat_total + hr_us_ff_udfs.Convert_Period_Type(
				p_bus_grp_id		=> p_bg_id,
				p_payroll_id		=> p_pay_id,
				p_asst_work_schedule 	=> p_work_sched,
				p_asst_std_hours		=> p_std_hours,
				p_figure			=> v_flat_amount,
				p_from_freq		=> 'PERIOD',
				p_to_freq		=> 'HOURLY',
				p_period_start_date	=> v_range_start,
				p_period_end_date	=> v_range_end,
				p_asst_std_freq		=> p_std_freq);
    --
    END LOOP;
    CLOSE get_flat_amounts;
    --
    hr_utility.set_location('OT_Base_Rate', 100);
    v_ot_base_rate := v_ot_base_rate + (v_flat_total / v_flat_count);
  --
  ELSIF SUBSTR(v_ff_name,1,10) = 'PERCENTAGE' THEN
    hr_utility.set_location('OT_Base_Rate', 110);
    OPEN get_percentages;
    LOOP
      FETCH 	get_percentages
      INTO	v_percentage;
      EXIT WHEN get_percentages%NOTFOUND;
      v_pct_count := v_pct_count + 1;
      --
      IF v_regsal_rate <> 0 THEN
        hr_utility.set_location('OT_Base_Rate', 105);
        v_pct_total := v_percentage * v_regsal_rate;
      END IF;
    --
    END LOOP;
    --
    CLOSE get_percentages;
    --
    hr_utility.set_location('OT_Base_Rate', 110);
    v_ot_base_rate := v_ot_base_rate + (v_pct_total / v_pct_count);
    --
  ELSIF SUBSTR(v_ff_name,1,12) = 'HOURS_X_RATE' THEN
    --
    -- Remember to look for "Rate Code" if necessary and "Multiple" always.
    --
    hr_utility.set_location('OT_Base_Rate', 115);
    OPEN get_rates;
    LOOP
      FETCH	get_rates
      INTO	v_rate, v_entry_id;
      EXIT WHEN get_rates%NOTFOUND;
      hr_utility.set_location('OT_Base_Rate', 120);
      v_rate_count := v_rate_count + 1;
      IF v_rate = 0 THEN
        hr_utility.set_location('OT_Base_Rate', 125);
        SELECT	NVL(EEV.screen_entry_value, 'NOT ENTERED')
        INTO	v_rate_rcode
        FROM	pay_element_entry_values_f	EEV,
		pay_element_entries_f		ELE,
		pay_element_types_f		ELT,
		pay_input_values_f		IPV
        WHERE	ELE.assignment_id		= p_ass_id
        AND	ELE.element_entry_id		= EEV.element_entry_id
        AND	p_date_earned           BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date
	AND	EEV.element_entry_id		= v_entry_id
        AND	EEV.input_value_id 		= IPV.input_value_id
        AND	UPPER(ELT.element_name)		= UPPER(v_ele_name)
        AND	ELT.element_type_id		= IPV.element_type_id
        AND	UPPER(IPV.name)			= 'RATE CODE';
        --
        IF v_rate_rcode <> 'NOT ENTERED' THEN
          hr_utility.set_location('OT_Base_Rate', 130);
	  v_rate := FND_NUMBER.CANONICAL_TO_NUMBER(hruserdt.get_table_value(
						p_bg_id,
						c_rate_table_name,
						c_rate_table_column,
						v_rate_rcode));
	END IF;
      --
      END IF;
      -- Now get "Multiple" on this entry, if any.
      IF v_rate <> 0 THEN
        hr_utility.set_location('OT_Base_Rate', 135);
        SELECT	COUNT(0)
        INTO	v_rate_mult_count
        FROM	pay_element_entry_values_f	EEV,
		pay_element_entries_f		ELE,
		pay_element_types_f		ELT,
		pay_input_values_f		IPV
        WHERE	ELE.assignment_id		= p_ass_id
        AND	ELE.element_entry_id		= EEV.element_entry_id
        AND	p_date_earned           BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date
	AND	EEV.element_entry_id		= v_entry_id
        AND	EEV.input_value_id 		= IPV.input_value_id
        AND	UPPER(ELT.element_name)		= UPPER(v_ele_name)
        AND	ELT.element_type_id		= IPV.element_type_id
        AND	UPPER(IPV.name)			= 'MULTIPLE';
        --
        IF v_rate_mult_count <> 0 THEN
          hr_utility.set_location('OT_Base_Rate', 140);
          SELECT NVL(fnd_number.canonical_to_number(EEV.screen_entry_value), 0)
          INTO	v_rate_multiple
          FROM	pay_element_entry_values_f	EEV,
			pay_element_entries_f		ELE,
			pay_element_types_f		ELT,
			pay_input_values_f		IPV
          WHERE		ELE.assignment_id		= p_ass_id
          AND		ELE.element_entry_id		= EEV.element_entry_id
          AND		p_date_earned   BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date
	      AND		EEV.element_entry_id		= v_entry_id
          AND		EEV.input_value_id 		= IPV.input_value_id
          AND		UPPER(ELT.element_name)		= UPPER(v_ele_name)
          AND		ELT.element_type_id		= IPV.element_type_id
          AND		UPPER(IPV.name)			= 'MULTIPLE';
        --
          IF v_rate_multiple <> 0 THEN
            v_rate := v_rate * v_rate_multiple;
          END IF;
        --
        END IF;
      --
      END IF;
      --
      v_rate_total := v_rate_total + v_rate;
      --
    END LOOP;
    CLOSE get_rates;
    --
    v_ot_base_rate := v_ot_base_rate + (v_rate_total / v_rate_count);
    --
  ELSIF SUBSTR(v_ff_name,1,8) = 'GROSS_UP' THEN
    hr_utility.set_location('OT_Base_Rate', 150);
    OPEN get_grosses;
    LOOP
      FETCH 	get_grosses
      INTO	v_gross_results;
      EXIT WHEN get_grosses%NOTFOUND;
      v_gross_count := v_gross_count + 1;
      IF v_gross_results <> 0 THEN
        -- Convert gross result to hourly figure.
        hr_utility.set_location('OT_Base_Rate', 160);

        v_gross_total := v_gross_total + hr_us_ff_udfs.Convert_Period_Type(
				p_bus_grp_id		=> p_bg_id,
				p_payroll_id		=> p_pay_id,
				p_asst_work_schedule 	=> p_work_sched,
				p_asst_std_hours		=> p_std_hours,
				p_figure			=> v_gross_amount,
				p_from_freq		=> NULL,
				p_to_freq		=> 'HOURLY',
				p_period_start_date	=> v_range_start,
				p_period_end_date	=> v_range_end,
				p_asst_std_freq		=> p_std_freq);
      --
      END IF;
    --
    END LOOP;
    CLOSE get_grosses;
    --
    v_ot_base_rate := v_ot_base_rate + (v_gross_total / v_gross_count);
  --
  END IF; -- Calc Method
--
END LOOP;
--
CLOSE get_include_in_ot;
--
RETURN v_ot_base_rate;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('OT_Base_Rate', 170);
    RETURN v_ot_base_rate;
--    hr_utility.set_message(801, 'PAY_SCL_SEG_NOTFOUND');
--    hr_utility.raise_error;
--
END OT_Base_Rate;
--
/*
*****************************************************
FUNCTION NAME:
*****************************************************
Dedn_Freq_Factor
Inputs: p_payroll_id		-- Context
	p_element_type_id	-- Context
	p_date_earned		-- Context
	p_ele_period_type	-- DBI param

Outputs:	v_dedn_freq_factor

28 JAN 1994	hparicha	Created.

*****************************************************
DESCRIPTION:

This fun computes the "Deduction Frequency Factor" for deductions
that have frequency rules and/or processing period type.

Algorithm:

IF period type IS NULL and frequency rules DO NOT exist THEN

  dedn_freq_factor = 1 -- The deduction is assumed to be for the pay period.

ELSIF period type IS NULL and frequency rules EXIST THEN

  dedn_freq_factor = 1 / (# pay periods in reset period)

ELSIF period type IS NOT NULL and frequency rules DO NOT exist THEN

  dedn_freq_factor = (# per FY, eletype period type) /
			(# per FY, payroll period type)

ELSIF period type IS NOT NULL and frequency rules EXIST THEN

  dedn_freq_factor = (# per FY, eletype period type) /
			(# per FY, reset period type) /
			   (# pay periods in reset period)

END IF
-- NOTE: "Reset Period" is either Month or Year.
	 "# pay periods in reset period" means the number of deduction
	 frequency rules for the ele/payroll that exist AND have a
	 PERIOD_NO_IN_RESET_PERIOD less than the number of pay periods
	 that will actually process.
	 For example: if 2 bi-week pay periods will process in a month and the
	 frequency rules say to process in the 1st and 3rd bi-wks of the month,
         then we need to process the deduction "in full" on the 1st run of the
	 month.  PERIOD_NO_IN_RESET_PERIOD = 1 and 3, so only one of these
	 records has a column value less than the # pay periods that will
	 actually process this month.
	--
	 IF payroll period type is one of:
		Bi-Week,
		Calendar Month,
		Lunar Month,
		Semi-Month,
		Week
	 THEN "reset period" = Month, number per fiscal year = 12.
	--
	 IF payroll period type is one of:
		Bi-Month,
		Quarter,
		Semi-Year,
		Year
	 THEN "reset period" = Year, number per fiscal year = 1.

*****************************************************
fun TEXT:
*****************************************************
*/
FUNCTION Dedn_Freq_Factor (
			p_payroll_id		in NUMBER,
		   	p_element_type_id	in NUMBER,
			p_date_earned		in DATE,
			p_ele_period_type	in VARCHAR2)
RETURN NUMBER IS
--
-- local constants
--
c_months_per_fy		NUMBER(2)	;
c_years_per_fy		NUMBER(1)	;
--
-- local vars
--
v_date_earned		DATE;
v_dedn_freq_factor	NUMBER(11,5);
v_ele_period_num_per_fy	NUMBER(3);
v_pay_period_num_per_fy	NUMBER(3);
v_reset_periods_per_fy	NUMBER(3);
v_pay_periods_in_reset	NUMBER(3);
v_pay_periods_in_month	NUMBER(3);
v_pay_periods_in_year	NUMBER(3);
v_freq_rule_count	NUMBER(3);
v_freq_rules_exist	VARCHAR2(1);
v_pay_period_type	VARCHAR2(30);
--
--
BEGIN		 -- Dedn_Freq_Factor
--
-- v_date_earned	:= p_date_earned;
--
  /* Init */
c_months_per_fy := 12;
c_years_per_fy := 1;


hr_utility.set_location('Dedn_Freq_Factor', 10);
SELECT	DECODE(COUNT(FRP.freq_rule_period_id), 0, 'N', 'Y')
INTO	v_freq_rules_exist
FROM	pay_freq_rule_periods		FRP,
	pay_ele_payroll_freq_rules	EPF
WHERE 	FRP.ele_payroll_freq_rule_id 	= EPF.ele_payroll_freq_rule_id
AND	EPF.element_type_id 		= p_element_type_id
AND	EPF.payroll_id			= p_payroll_id
AND	EPF.start_date     	       <= p_date_earned;
--
IF p_ele_period_type = 'NOT ENTERED' THEN
-- AND v_freq_rules_exist = 'N' (I say if ele period type is null, then
-- dedn freq factor is 1 whether freq rules exist or not!  Right, the
-- freq rule will tell us WHEN to process the given Deduction amount.
-- If there is no period type on the Dedn, then we take the FULL AMOUNT
-- every time it is processed - according to freq rule.)
--
  v_dedn_freq_factor := 1;
--
ELSIF p_ele_period_type = 'NOT ENTERED' AND v_freq_rules_exist = 'Y' THEN
--
  hr_utility.set_location('Dedn_Freq_Factor', 15);
  SELECT TPT.number_per_fiscal_year
  INTO	 v_pay_period_num_per_fy
  FROM	 pay_payrolls_f 	PPF,
	 per_time_period_types 	TPT
  WHERE  TPT.period_type 	= PPF.period_type
  AND	 p_date_earned BETWEEN	PPF.effective_start_date
		     	AND	PPF.effective_end_date
  AND	 PPF.payroll_id 	= p_payroll_id;
  --
  IF v_pay_period_num_per_fy >= 12 THEN
    IF v_pay_period_num_per_fy = 12 THEN
      v_dedn_freq_factor := 1;
    ELSE
      hr_utility.set_location('Dedn_Freq_Factor', 20);
      SELECT 	COUNT(0)
      INTO   	v_pay_periods_in_month
      FROM   	per_time_periods		PTP
      WHERE	PTP.end_date
		BETWEEN TRUNC(p_date_earned, 'MONTH')
		AND	LAST_DAY(p_date_earned)
      AND	PTP.payroll_id = p_payroll_id;
      hr_utility.set_location('v_pay_periods_in_month', v_pay_periods_in_month);
      --
      -- Frequency rules exist, so this select should never return 0.
      -- Just in case, we'll decode for 0 and set v_pay_periods_in_reset to 1.
      -- ie. so v_dedn_freq_factor will also equal 1.
      --
      hr_utility.set_location('Dedn_Freq_Factor', 25);
      SELECT 	DECODE(COUNT(0), 0, 1, COUNT(0))
      INTO	v_pay_periods_in_reset
      FROM	pay_ele_payroll_freq_rules	EPF,
     		pay_freq_rule_periods		FRP
      WHERE	FRP.period_no_in_reset_period  <= v_pay_periods_in_month
      AND	FRP.ele_payroll_freq_rule_id	= EPF.ele_payroll_freq_rule_id
      AND	EPF.payroll_id			= p_payroll_id
      AND	EPF.element_type_id		= p_element_type_id;
      --
      hr_utility.set_location('v_pay_periods_in_reset = ', v_pay_periods_in_reset);
      v_dedn_freq_factor := 1 / v_pay_periods_in_reset;
      --
    END IF;
  ELSE
    hr_utility.set_location('Dedn_Freq_Factor', 30);
    SELECT 	COUNT(0)
    INTO   	v_pay_periods_in_year
    FROM   	per_time_periods		PTP
    WHERE	PTP.end_date
		BETWEEN TRUNC(p_date_earned, 'YEAR')
		AND	LAST_DAY(ADD_MONTHS(TRUNC(p_date_earned, 'YEAR'), 11))
    AND		PTP.payroll_id = p_payroll_id;
    --
    -- Frequency rules exist, so this select should never return 0.
    -- Just in case, we'll decode for 0 and set v_pay_periods_in_reset to 1.
    -- ie. so v_dedn_freq_factor will also equal 1.
    --
    hr_utility.set_location('Dedn_Freq_Factor', 35);
    SELECT 	DECODE(COUNT(0), 0, 1, COUNT(0))
    INTO	v_pay_periods_in_reset
    FROM	pay_ele_payroll_freq_rules	EPF,
     		pay_freq_rule_periods		FRP
    WHERE	FRP.period_no_in_reset_period  <= v_pay_periods_in_year
    AND		FRP.ele_payroll_freq_rule_id	= EPF.ele_payroll_freq_rule_id
    AND		EPF.payroll_id			= p_payroll_id
    AND		EPF.element_type_id		= p_element_type_id;
    --
    hr_utility.set_location('v_pay_periods_in_reset = ', v_pay_periods_in_reset);
    v_dedn_freq_factor := 1 / v_pay_periods_in_reset;
    --
  END IF;
--
ELSIF p_ele_period_type <> 'NOT ENTERED' AND v_freq_rules_exist = 'N' THEN
--
  hr_utility.set_location('Dedn_Freq_Factor', 40);
  SELECT 	number_per_fiscal_year
  INTO		v_ele_period_num_per_fy
  FROM		per_time_period_types	TPT
  WHERE		UPPER(period_type)	= UPPER(p_ele_period_type);
  --
  hr_utility.set_location('Dedn_Freq_Factor', 45);
  SELECT 	TPT.number_per_fiscal_year
  INTO		v_pay_period_num_per_fy
  FROM		per_time_period_types	TPT,
		pay_payrolls_f		PPF
  WHERE		TPT.period_type		= PPF.period_type
  AND		p_date_earned     BETWEEN PPF.effective_start_date
  				      AND PPF.effective_end_date
  AND		PPF.payroll_id 		= p_payroll_id;
--
  v_dedn_freq_factor := v_ele_period_num_per_fy / v_pay_period_num_per_fy;
--
ELSIF p_ele_period_type <> 'NOT ENTERED' AND v_freq_rules_exist = 'Y' THEN
--
  hr_utility.set_location('Dedn_Freq_Factor', 50);
  SELECT 	number_per_fiscal_year
  INTO		v_ele_period_num_per_fy
  FROM		per_time_period_types	TPT
  WHERE		UPPER(period_type)	= UPPER(p_ele_period_type);
  --
  hr_utility.set_location('Dedn_Freq_Factor', 55);
  SELECT TPT.number_per_fiscal_year
  INTO	 v_pay_period_num_per_fy
  FROM	 pay_payrolls_f 	PPF,
	 per_time_period_types 	TPT
  WHERE  TPT.period_type 	= PPF.period_type
  AND	 PPF.payroll_id 	= p_payroll_id
  AND	 p_date_earned BETWEEN	PPF.effective_start_date
		        AND	PPF.effective_end_date;
  --
  IF v_pay_period_num_per_fy >= 12 THEN
    hr_utility.set_location('Dedn_Freq_Factor', 60);
    SELECT 	COUNT(0)
    INTO   	v_pay_periods_in_month
    FROM   	per_time_periods		PTP
    WHERE	PTP.end_date
		BETWEEN TRUNC(p_date_earned, 'MONTH')
		AND	LAST_DAY(p_date_earned)
    AND		PTP.payroll_id = p_payroll_id;
    --
    -- Frequency rules exist, so this select should never return 0.
    -- Just in case, we'll decode for 0 and set v_pay_periods_in_reset to 1.
    -- ie. so v_dedn_freq_factor will also equal 1.
    --
    hr_utility.set_location('Dedn_Freq_Factor', 65);
    SELECT 	COUNT(0)
    INTO	v_pay_periods_in_reset
    FROM	pay_ele_payroll_freq_rules	EPF,
     		pay_freq_rule_periods		FRP
    WHERE	FRP.period_no_in_reset_period  <= v_pay_periods_in_month
    AND		FRP.ele_payroll_freq_rule_id	= EPF.ele_payroll_freq_rule_id
    AND		EPF.payroll_id			= p_payroll_id
    AND		EPF.element_type_id		= p_element_type_id;
    hr_utility.set_location('v_pay_periods_in_reset = ', v_pay_periods_in_reset);
    --
    IF v_ele_period_num_per_fy = v_pay_period_num_per_fy THEN
      v_dedn_freq_factor := 1;
    ELSIF v_pay_periods_in_reset = 0 THEN
      v_dedn_freq_factor := 0;
      -- Freq rules exist, but will not be processed enough this reset period.
      -- Ie. freq rule says process in 3rd bi-wk when only 2 will process in
      -- the current month, so NOTHING is taken for deduction (factor = 0).
    ELSE
      v_dedn_freq_factor := v_ele_period_num_per_fy / c_months_per_fy / v_pay_periods_in_reset;
    END IF;
    --
  ELSE
    hr_utility.set_location('Dedn_Freq_Factor', 70);
    SELECT 	COUNT(0)
    INTO   	v_pay_periods_in_year
    FROM   	per_time_periods		PTP
    WHERE	PTP.end_date
		BETWEEN TRUNC(p_date_earned, 'YEAR')
		AND	LAST_DAY(ADD_MONTHS(TRUNC(p_date_earned, 'YEAR'), 11))
    AND		PTP.payroll_id = p_payroll_id;
    --
    -- Frequency rules exist, so this select should never return 0.
    -- Just in case, we'll decode for 0 and set v_pay_periods_in_reset to 1.
    -- ie. so v_dedn_freq_factor will also equal 1.
    --
    hr_utility.set_location('Dedn_Freq_Factor', 75);
    SELECT 	DECODE(COUNT(0), 0, 1, COUNT(0))
    INTO	v_pay_periods_in_reset
    FROM	pay_ele_payroll_freq_rules	EPF,
     		pay_freq_rule_periods		FRP
    WHERE	FRP.period_no_in_reset_period  <= v_pay_periods_in_year
    AND		FRP.ele_payroll_freq_rule_id	= EPF.ele_payroll_freq_rule_id
    AND		EPF.payroll_id			= p_payroll_id
    AND		EPF.element_type_id		= p_element_type_id;
    --
    hr_utility.set_location('v_pay_periods_in_reset = ', v_pay_periods_in_reset);
    IF v_ele_period_num_per_fy = v_pay_period_num_per_fy THEN
      v_dedn_freq_factor := 1;
    ELSE
      v_dedn_freq_factor := v_ele_period_num_per_fy / c_months_per_fy / v_pay_periods_in_reset;
    END IF;
    --
  END IF;
--
END IF;
--
hr_utility.set_location('Dedn_Freq_Factor', 80);
RETURN v_dedn_freq_factor;
--
END Dedn_Freq_Factor;
--
FUNCTION Arrearage (	p_eletype_id		IN NUMBER,
			p_date_earned		IN DATE,
			p_assignment_id     IN NUMBER,
			p_ele_entry_id      IN NUMBER,
			p_partial_flag		IN VARCHAR2,
			p_net_asg_run		IN NUMBER,
			p_arrears_itd		IN NUMBER,
			p_guaranteed_net	IN NUMBER,
			p_dedn_amt		IN NUMBER,
			p_to_arrears		IN OUT nocopy NUMBER,
			p_not_taken		IN OUT nocopy NUMBER)
RETURN NUMBER IS
--
-- Call from fast formulae as:
-- dedn_amt = arrearage (	<ELE_NAME>_PARTIAL_EE_CONTRIBUTIONS,
--				NET_ASG_RUN,
--				<ELE_NAME>_ARREARS_ASG_GRE_ITD,
--				Guaranteed_Net,
--				dedn_amt,
--				to_arrears,
--				not_taken)
--
-- Test cases need to be run where:
--	1. p_net_asg_run > p_guaranteed_net
--	2. p_net_asg_run < p_guaranteed_net
--	3. p_net_asg_run = 0

l_total_dedn		NUMBER(27,7);			-- local var
l_dedn_amt		NUMBER(27,7);			-- local var
v_dedn_multiple		NUMBER(9);
v_arrears_flag		VARCHAR2(1);
v_shadow_ele_name	VARCHAR2(80);
v_shadow_ele_id		NUMBER(9);
v_bg_id			NUMBER(9);
l_arr_eletype_id number ;
l_arrear_contr_value number;
l_rule_mode varchar2(5);
l_retro_arr_eletype_id number ;

--
BEGIN
--
p_to_arrears := 0;
p_not_taken := 0;
l_arrear_contr_value := 0 ;

hr_utility.set_location('hr_us_ff_udfs.arrearage', 1);

-- Determine if Arrears = 'Y' for this dedn
-- Can do this by checking for "Clear Arrears" input value on base ele.
-- This input value is only created when Arrears is marked Yes on Deductions
-- screen.

begin

  hr_utility.set_location('Shadow elename = '||v_shadow_ele_name, 38 );

  select  'Y'
  into	  v_arrears_flag
  from	  pay_input_values_f ipv
  where   ipv.name 				= 'Clear Arrears'
  and	p_date_earned                         BETWEEN ipv.effective_start_date
						  AND ipv.effective_end_date
  and	  ipv.element_type_id 			= p_eletype_id;

exception

  WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('Arrearage is NOT ON for this ele.', 99);
    v_arrears_flag := 'N';

  WHEN TOO_MANY_ROWS THEN
    hr_utility.set_location('Too many rows returned for Clear Arrears inpval.', 99);
    v_arrears_flag := 'N';

end;

IF v_arrears_flag = 'N' THEN

  IF p_net_asg_run - p_dedn_amt >= p_guaranteed_net THEN

    p_to_arrears := 0;
    p_not_taken := 0;
    l_dedn_amt := p_dedn_amt;
--  hr_utility.set_location('pyusudfs.arrearage.to_arrears = ', p_to_arrears);
    hr_utility.set_location('pyusudfs.arrearage.dedn_amt = ', p_dedn_amt);
--  hr_utility.set_location('pyusudfs.arrearage.not_taken = ', p_not_taken);

  ELSIF p_net_asg_run <= p_guaranteed_net THEN
    -- Don't take anything, no arrears contr either.
    p_to_arrears := 0;
    p_not_taken := p_dedn_amt;
    l_dedn_amt := 0;
--  hr_utility.set_location('pyusudfs.arrearage.to_arrears = ', p_to_arrears);
    hr_utility.set_location('pyusudfs.arrearage.dedn_amt = ', l_dedn_amt);
--  hr_utility.set_location('pyusudfs.arrearage.not_taken = ', p_not_taken);

  ELSIF p_net_asg_run - p_dedn_amt < p_guaranteed_net THEN

    IF p_partial_flag = 'Y' THEN
      --
      p_to_arrears := 0;
      p_not_taken := p_dedn_amt - (p_net_asg_run - p_guaranteed_net);
      /* 6319565 */
      IF p_net_asg_run < 0 THEN
      l_dedn_amt := 0 ;
      ELSE
      l_dedn_amt := p_net_asg_run - p_guaranteed_net;
      END IF;
--   hr_utility.set_location('pyusudfs.arrearage.to_arrears = ', p_to_arrears);
--   hr_utility.set_location('pyusudfs.arrearage.not_taken = ', p_not_taken);
      hr_utility.set_location('pyusudfs.arrearage.dedn_amt = ', l_dedn_amt);

    ELSE

      p_to_arrears := 0;
      p_not_taken := p_dedn_amt;
      l_dedn_amt := 0;
--   hr_utility.set_location('pyusudfs.arrearage.to_arrears = ', p_to_arrears);
--   hr_utility.set_location('pyusudfs.arrearage.not_taken = ', p_not_taken);
      hr_utility.set_location('pyusudfs.arrearage.dedn_amt = ', l_dedn_amt);

    END IF;

  END IF;

ELSE -- Arrearage is on, try and clear any balance currently in arrears.

  /* Changes done for bug # 6970340 starts */
    begin
    select to_number(nvl(element_information19,0)) into l_arr_eletype_id /*Element Type id of Spl features */
    from pay_element_types_f
    where element_type_id = p_eletype_id ;
    exception when others then null ;
    end;

     begin
    select nvl(rule_mode,'N') into l_rule_mode  from pay_legislation_rules where
    rule_type = 'ADVANCED_RETRO' AND
    legislation_code = 'US';
    exception when others then null ;
    end ;

    if l_rule_mode = 'Y' then
    begin

  /*  select  pes.retro_element_type_id into l_retro_arr_eletype_id
    from pay_retro_component_usages rcu , pay_element_span_usages pes
    where rcu.creator_id = l_arr_eletype_id
    and rcu.creator_type = 'ET'
    and rcu.retro_component_usage_id = pes.retro_component_usage_id
    and pes.legislation_code is null ; */

    select (sum(to_number(nvl(screen_entry_value,'0')))) into l_arrear_contr_value
    from PAY_ELEMENT_ENTRY_VALUES_F eev , PAY_INPUT_VALUES_F ip
    where eev.input_value_id = ip.input_value_id
    and ip.name  like 'Arrears Contr'
    and element_entry_id in   ( select element_entry_id -- element entry for arrear contr
                            from pay_element_entries_f
                            where assignment_id = p_assignment_id
                            and p_date_earned between effective_start_date and effective_end_date
                            and element_type_id = l_arr_eletype_id );


    exception when others then null ;
    end ;
    end if ;


  l_arrear_contr_value := nvl(l_arrear_contr_value ,0);


  /* Changes done for bug # 6970340 ends */

  IF p_net_asg_run <= p_guaranteed_net THEN

    -- Don't take anything, put it all in arrears.
    p_to_arrears := p_dedn_amt + l_arrear_contr_value ;
    p_not_taken := p_dedn_amt + l_arrear_contr_value ;
    l_dedn_amt := 0;
--  hr_utility.set_location('pyusudfs.arrearage.to_arrears = ', p_to_arrears);
    hr_utility.set_location('pyusudfs.arrearage.dedn_amt = ', l_dedn_amt);
--  hr_utility.set_location('pyusudfs.arrearage.not_taken = ', p_not_taken);

  ELSE

    l_total_dedn := p_dedn_amt + p_arrears_itd + l_arrear_contr_value ;

    -- Attempt to clear any arrears bal:

    IF p_net_asg_run - p_guaranteed_net  >= l_total_dedn THEN

      -- there's enough net to take it all, clear arrears:
      p_to_arrears := -1 * ( p_arrears_itd + l_arrear_contr_value ) ;
      l_dedn_amt := l_total_dedn;
      p_not_taken := 0;
--   hr_utility.set_location('pyusudfs.arrearage.to_arrears = ', p_to_arrears);
      hr_utility.set_location('pyusudfs.arrearage.dedn_amt = ', l_dedn_amt);
--   hr_utility.set_location('pyusudfs.arrearage.not_taken = ', p_not_taken);

/*  Deleted a load of code above to fix 504970.  If partial_flag = Y, then
    try and take as much of the total deduction amount (current dedn +
    arrears) and leave the rest in arrears.  */

    ELSIF p_partial_flag = 'Y' THEN

      -- Going into arrears, not enough Net to take curr p_dedn_amt
      --
      p_to_arrears := (l_total_dedn - l_arrear_contr_value - (p_net_asg_run - p_guaranteed_net)) +
                      (-1 * (p_arrears_itd   + l_arrear_contr_value )) ;
      IF (p_net_asg_run - p_guaranteed_net + l_arrear_contr_value ) >= p_dedn_amt  THEN
        p_not_taken := 0;
      ELSE
        p_not_taken := p_dedn_amt  - (p_net_asg_run - p_guaranteed_net + l_arrear_contr_value);
      END IF;
      /* 6319565 */
      IF p_net_asg_run < 0 THEN
	l_dedn_amt := 0 ;
      ELSE
      l_dedn_amt := p_net_asg_run - p_guaranteed_net + l_arrear_contr_value ;
      END IF;

--   hr_utility.set_location('pyusudfs.arrearage.to_arrears = ', p_to_arrears);
      hr_utility.set_location('pyusudfs.arrearage.dedn_amt = ', l_dedn_amt);
--   hr_utility.set_location('pyusudfs.arrearage.not_taken = ', p_not_taken);

    ELSE -- p_partial_flag = 'N'
      IF (p_net_asg_run - p_guaranteed_net +  l_arrear_contr_value ) >= p_dedn_amt   THEN
        -- Take the whole deduction amount.
        l_dedn_amt := p_dedn_amt;
        p_to_arrears := l_arrear_contr_value;
        p_not_taken := l_arrear_contr_value ;
      ELSE
        -- Don't take anything, partial dedn = 'N'
        p_to_arrears := p_dedn_amt  ;
        p_not_taken := p_dedn_amt  ;
        l_dedn_amt := 0;
      END IF;
--   hr_utility.set_location('pyusudfs.arrearage.to_arrears = ', p_to_arrears);
      hr_utility.set_location('pyusudfs.arrearage.dedn_amt = ', l_dedn_amt);
--   hr_utility.set_location('pyusudfs.arrearage.not_taken = ', p_not_taken);

    END IF;

  END IF;

END IF;
--
-- p_to_arrears and p_not_taken are set and sent out as well.
--
RETURN l_dedn_amt;
--
END Arrearage;
--
-- G1668: Addr_Val optimization.  We tune for the majority case of city/zip
-- 	  uniquely identifying a geocode and handle the exception cases
--	  as appropriate.  The exceptions will be raise VERY RARELY.
--	  Part of the optimization assumes that the code which calls this fn
--	  verify that city/zip params are populated before making the call
--	  which essentially means city/zip are required params for optimal
--	  performance.  In the event city/zip are not supplied, this fun
--        still works.
--
-- Optimization issues:
-- 1. In order to get the BEST performance possible, we need to add a "mode"
--    parameter in order to this fun so that majority cases can be checked
--    in the optimal order.  The high volume users of this fn are MIX batch
--    val and the payroll run (VERTEX formulae).  Since we KNOW that MIX will
--    only provide State and City params, we can quickly check this and return
--    without going thru any of the gyrations needed for more general cases.
--    The validation required for the VERTEX formulae will be the "general"
--    case, tuned to succeed in the shortest possible time.
-- Resolution: Make all params mandatory, make the calling modules take care
-- of this requirement.
--
FUNCTION addr_val (     p_state_abbrev  IN VARCHAR2,
                        p_county_name   IN VARCHAR2,
                        p_city_name     IN VARCHAR2,
                        p_zip_code      IN VARCHAR2)
RETURN VARCHAR2 IS
--
l_geocode               VARCHAR2(11); -- Output var in "12-345-6789" format.
--
BEGIN           -- Call main addr_val

l_geocode := addr_val(p_state_abbrev,
		      p_county_name,
		      p_city_name,
		      p_zip_code,
		      'N');

RETURN l_geocode;
--
EXCEPTION
 WHEN OTHERS THEN
   hr_utility.set_location('hr_us_ff_udfs.addr_val', 20);
   l_geocode := '00-000-0000';
   RETURN l_geocode;
 --
END addr_val;   -- addr_val

FUNCTION addr_val (	p_state_abbrev	IN VARCHAR2,
			p_county_name	IN VARCHAR2,
			p_city_name	IN VARCHAR2,
			p_zip_code	IN VARCHAR2,
			p_skip_rule     IN VARCHAR2 )
RETURN VARCHAR2 IS
--
l_geocode		VARCHAR2(11); -- Output var in "12-345-6789" format.
l_state_code		VARCHAR2(2);
l_state_name		VARCHAR2(25);
l_county_code		VARCHAR2(3);
l_county_name		VARCHAR2(20);
l_city_code		VARCHAR2(4);
l_city_name		VARCHAR2(30);   --bug 4652178
--l_city_name		VARCHAR2(25);
l_zip_code		VARCHAR2(5);
l_query_city_name       VARCHAR2(30);   --bug 4652178
--l_query_city_name     VARCHAR2(25);

--
BEGIN		-- Main addr_val
-- rmonge commented out this code.
-- See new code below to handle JEDD also.
/*
 l_zip_code	:= substr(p_zip_code, 1, 5);
  -- Checking the name of the city in the P_CITY_NAME is and air force base
  -- IE: The last three characters are 'AFB' then we will not INITCAP the
  -- cityname.
  IF upper(ltrim(rtrim(substr(rtrim(p_city_name),length(rtrim(p_city_name)) - 3,
         length(rtrim(p_city_name)) )))) = 'AFB' THEN
     l_query_city_name := p_city_name;
  ELSE
     l_query_city_name := INITCAP(p_city_name);
  END IF;
*/

 l_zip_code	:= substr(p_zip_code, 1, 5);
  -- Checking the name of the city in the P_CITY_NAME is and air force base
  -- IE: The last three characters are 'AFB' then we will not INITCAP the
  -- cityname.

/*  Start - VMKULKAR Bug 5985902
  IF upper(ltrim(rtrim(substr(rtrim(p_city_name),length(rtrim(p_city_name)) - 3,
         length(rtrim(p_city_name)) )))) = 'AFB'  OR
         upper(ltrim(rtrim(substr(rtrim(p_city_name),
         length(rtrim(p_city_name)) - 4,
         length(rtrim(p_city_name)) )))) = 'JEDD' THEN
     l_query_city_name := p_city_name;
  ELSE
     l_query_city_name := INITCAP(p_city_name);
  END IF;
  End - VMKULKAR Bug 5985902 */
IF instr(p_city_name,' JEDD') > 0 OR instr(p_city_name,' AFB') > 0 THEN
	l_query_city_name := p_city_name;
ELSE
     l_query_city_name := INITCAP(p_city_name);
END IF;

--
 begin		-- (1)
 --
  begin		-- (2)
  -- We're going 3-deep here in order to handle multiple raising
  -- of the same exception...will this work?
  -- 90% case, geo determined by city/zip combo:

  IF (p_skip_rule = 'Y') THEN
    RAISE TOO_MANY_ROWS;
  END IF;

  hr_utility.set_location('hr_us_ff_udfs.addr_val', 1);

  IF (nvl(hr_general2.get_oracle_db_version, 0) < 9.0) THEN
      SELECT /*+ ORDERED */ a.state_code||'-'||a.county_code||'-'||a.city_code
      INTO  l_geocode
      FROM  pay_us_city_names a,
            pay_us_zip_codes  z
      WHERE  a.city_name		= l_query_city_name
      AND   z.state_code	= a.state_code	AND
	    z.county_code	= a.county_code	AND
	    z.city_code	= a.city_code	AND
	    l_zip_code BETWEEN z.zip_start AND z.zip_end;
  ELSE
      -- Bug# 5343679.
      -- Removed the ORDERED hint for the Bug# 5629688.
      SELECT a.state_code||'-'||a.county_code||'-'||a.city_code
      INTO  l_geocode
      FROM  pay_us_city_names a,
            pay_us_zip_codes  z
      WHERE  a.city_name         = l_query_city_name
      AND   z.state_code        = a.state_code  AND
            z.county_code       = a.county_code AND
            z.city_code = a.city_code   AND
            l_zip_code BETWEEN z.zip_start AND z.zip_end;
  END IF;

  --
  EXCEPTION 	-- (2)
  --
    WHEN NO_DATA_FOUND THEN		-- Invalid city/zip combo
      hr_utility.set_location('hr_us_ff_udfs.addr_val', 3);
      l_geocode := '00-000-0000';
      RETURN l_geocode;
    --

    WHEN TOO_MANY_ROWS THEN		-- city/zip does not uniquely defn geo
        -- same county name can exists in many states
        SELECT   state_code
        INTO     l_state_code
        FROM     pay_us_states
        WHERE    state_abbrev = p_state_abbrev;

      hr_utility.set_location('hr_us_ff_udfs.addr_val', 5);
      SELECT	a.state_code||'-'||a.county_code||'-'||a.city_code
      INTO	l_geocode
      FROM	pay_us_zip_codes z,
		pay_us_city_names a,
		pay_us_counties	b
      WHERE	a.city_name		= l_query_city_name
      AND	a.county_code		= b.county_code
      AND	UPPER(b.county_name)		= UPPER(p_county_name)   --Bug3783309-Changed Initcap to Upper.
      AND       b.state_code            = l_state_code
      AND	z.state_code	= a.state_code	AND
		z.county_code	= a.county_code	AND
		z.city_code	= a.city_code	AND
		l_zip_code BETWEEN z.zip_start||''  AND z.zip_end||'' ; --Bug 4868637
  --
  end;		-- (2)
  --
 EXCEPTION	-- (1)
 --
 -- Fallout from (2) ie. county/city/zip combo invalid or does not
 -- uniquely define geocode.
 WHEN NO_DATA_FOUND THEN
   hr_utility.set_location('hr_us_ff_udfs.addr_val', 7);
   l_geocode := '00-000-0000';
   RETURN l_geocode;
 --
 WHEN TOO_MANY_ROWS THEN
   hr_utility.set_location('hr_us_ff_udfs.addr_val', 9);
   SELECT	a.state_code||'-'||a.county_code||'-'||a.city_code
   INTO		l_geocode
   FROM		pay_us_zip_codes z,
		pay_us_city_names a,
		pay_us_counties	b,
		pay_us_states	c
   WHERE	c.state_code 		= a.state_code	AND
   		c.state_abbrev		= UPPER(p_state_abbrev)
   AND
   		UPPER(b.county_name)		= UPPER(p_county_name)AND   --Bug3783309-Changed Initcap to Upper.
   		b.state_code		= c.state_code
   AND
   		a.city_name		= l_query_city_name	AND
   		a.state_code		= c.state_code	AND
  		a.county_code		= b.county_code
   AND
  		z.state_code	= c.state_code	AND
		z.county_code	= b.county_code	AND
		z.city_code	= a.city_code	AND
		l_zip_code BETWEEN z.zip_start AND z.zip_end;
  --
 end;		-- (1)
--
-- We're in Main
--
hr_utility.set_location('hr_us_ff_udfs.addr_val', 11);
--
if (substr(l_geocode,8,1) = 'U') THEN
  l_geocode := substr(l_geocode,1,7)||'0000';
END IF;
--
RETURN l_geocode;
--
EXCEPTION	-- Main addr_val
-- Fallout from (1) state/county/city/zip does not uniquely define a geo.
-- Return failure geocode.
 WHEN NO_DATA_FOUND THEN
   hr_utility.set_location('hr_us_ff_udfs.addr_val', 13);
   l_geocode := '00-000-0000';
   RETURN l_geocode;
 --
 WHEN TOO_MANY_ROWS THEN
   hr_utility.set_location('hr_us_ff_udfs.addr_val', 15);
   l_geocode := '00-000-0000';
   RETURN l_geocode;
--
END addr_val;  -- Main addr_val

--createed for returning the country name for
-- courty code in Fast formula of mag. W2
-- with record type A,B,E
-- it returns the value in upper case

FUNCTION  PAY_US_COUNTRY (p_territory_code IN varchar2)
  RETURN  varchar2 IS
   r_territory_short_name    fnd_territories_tl.territory_short_name%type;
BEGIN

hr_utility.set_location('Pay us country territory code :  ', p_territory_code);
   IF p_territory_code IS NOT NULL THEN


        SELECT  territory_short_name
          INTO  r_territory_short_name
          FROM  FND_TERRITORIES_VL
         WHERE  territory_code = p_territory_code;

	RETURN  upper(r_territory_short_name);
   ELSE

        RETURN(NULL);

   END IF;

--
-- EXCEPTION handling routine
--
EXCEPTION
     WHEN others THEN
          RETURN NULL ;
END;  -- pay_us_country


--

END hr_us_ff_udfs;

/
