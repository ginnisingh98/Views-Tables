--------------------------------------------------------
--  DDL for Package Body HR_CA_FF_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CA_FF_UDFS" AS
/* $Header: pycaudfs.pkb 120.3.12000000.4 2007/05/15 09:48:36 amigarg noship $ */
/*
+======================================================================+
|                Copyright (c) 1994 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : hr_ca_ff_udfs
    Filename	: pycaudfs.pkb
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    05-MAY-1999  mmukherj                       Created
                                                This file has been copied
                                                from pyusudfs.pkb
    14-FEB-2000  SSattineni                     Done Flexible Dates and Multi
						radix conversion compatible to
						11.5 version
    21-JUN-2000  MMukherj                       Changed the Meanings to Codes
                                                for Bug No: 1081235
                                                v_pay_basis_code,
                                                v_asst_std_freq_code
    17-SEP-2001  SSouresr                       Changed the insert into the
                                                table fnd_sessions to use the
                                                function set_effective_date
                                                instead.
    10-Jan-2002  vpandya                        Converted p_tax_unit_id to
                                                character while comparing it
                                                to segment1 in
                                                hr_soft_coding_keyflex table
                                                to overcome 'invali number' &
                                                also added dbdrv lines for gscc
    30-OCT-2002  pganguly            2647412    Changed Convert_Period_Type.
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
   18-NOV-2002 tclewis                2666118   Changed convert_period_type
                                                where we are querring number per
                                                fiscal year.  to change
                                                where sysdate between ...
                                                to nvl(p_period_start_date,
                                                sysdate).
   19-NOV-2002 tclewis                          changed nvl(p_period_start_date
                                                ,sysdate) to use session date.
   02-JAN-2003 mmukherj  115.9        2710358   get_flat_amounts,get_rates and
                                                get_percentage cursors have
                                                been changed to improve the
                                                performance.
   22-Jan-2003 vpandya   115.10                 For Multi GRE functionality,
                                                tax unit id will be stored in
                                                segment1, segment11 and
                                                segment12 of
                                                hr_soft_coding_keyflex
                                                depending on the gre type.
                                                Changed all conditions wherever
                                                segment1 is used for tax unit
                                                id.
   22-Jan-2003 vpandya   115.11                 Added nocopy with out parameter.
   09-JAN-2003 pganguly  115.12                 Changed the select statements
                                                in OT_Base_Rate which was
                                                flagged in the Perf Repository
                                                with cost more than 150. This
                                                fixes bug# 3358735.
   12-JUN-2004 trugless  115.13       3650170   Changed format of
                                                v_from_annualizing_factor and
                                                v_to_annualizing_factor from
                                                number(10) to number(30,7) in
                                                the Convert_Period_Type
                                                function.
   21-FEB-2005 pganguly  115.14       4118082   Added OR Condition in the select
                                                which sets 1 to
                                                l_eev_info_changes in the
                                                calculate_period_earnings
                                                procedure.
   28-OCT-2005    mmukherj     115.15          Added extra parameters in
                                                calculate_period_earnings
                                                and convert_period_type
                                                These parameters are coming
                                                from contexts and will be used
                                              to use the new core work schedule.
   31-OCT-2005    mmukherj     115.16          Added calls to the core function
                                               to calculate the actual hours
                                               worked. This will make sure that
                                               while calculating the hours it
                                               looks into the core work pattern
                                               information.
   12-APR-2006    meshah       115.17  5155854 changed the select for the
                                               condition UPPER(p_freq) <> 'HOURLY'
                                               also changed the exception
   21-NOV-2006    saikrish     115.18  5097793 Added get_earnings_and_type
   14-DEC-2006    ssouresr     115.19          Corrected main cursor in
                                               get_earnings_and_type to remove dups
*/
--
-- **********************************************************************
-- CALCULATE_PERIOD_EARNINGS
-- Description: This function performs proration for the startup elements
-- Regular Salary and Regular Wages.  Proration occurs in the following
-- scenarios:
-- 1. Change of assignment status to a status which is unpaid
--    ie. unpaid leave, termination;
-- 2. Change of regular rate of pay
--    ie. could be a change in annual salary or hourly rate.
--
-- This function also calculates and returns the actual hours worked in the
-- period, vacation pay, sick pay, vacation hours, and sick hours.

FUNCTION Calculate_Period_Earnings (
			p_bus_grp_id		in NUMBER,
			p_asst_id		in NUMBER,
			p_assignment_action_id	in NUMBER,
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
			p_prorate 		in VARCHAR2,
			p_asst_std_freq		in VARCHAR2)
RETURN NUMBER IS
--
-- local vars
--
l_asg_info_changes	NUMBER(1);
l_eev_info_changes	NUMBER(1);
v_earnings_entry        NUMBER(27,7);
v_inpval_id		NUMBER(9);
v_pay_basis		VARCHAR2(80);
v_pay_basis_code	VARCHAR2(80);
v_pay_periods_per_year	NUMBER(3);
v_period_earn		NUMBER(27,7) := 0; -- Pay Period earnings.
v_hourly_earn		NUMBER(27,7);	-- Hourly Rate (earnings).
v_prorated_earnings	NUMBER(27,7) := 0; -- Calc'd thru proration loops.
v_curr_day		VARCHAR2(3);	-- Currday while summing hrs for range of dates.
v_hrs_per_wk		NUMBER(15,7);
v_hrs_per_range	        NUMBER(15,7);
v_asst_std_hrs		NUMBER(15,7);
v_asst_std_freq		VARCHAR2(30);
v_asst_std_freq_code    VARCHAR2(30);
v_asg_status		VARCHAR2(30);
v_hours_in_range	NUMBER(15,7);
v_curr_hrly_rate	NUMBER(27,7) := 0;
v_range_start		DATE;		-- range start of ASST rec
v_range_end		DATE;		-- range end of ASST rec
v_entry_start		DATE;		-- start date of ELE ENTRY rec
v_entry_end		DATE;		-- end date of ELE ENTRY rec
v_entrange_start		DATE;		-- max of entry or asst range start
v_entrange_end		DATE;		-- min of entry or asst range end
v_work_schedule		VARCHAR2(60);	-- Work Schedule ID (stored as varchar2
					--  in HR_SOFT_CODING_KEYFLEX; convert
					--  to_number when calling wshours fn.
v_work_sched_name	VARCHAR2(80);
v_ws_id			NUMBER(9);

b_entries_done		BOOLEAN;	-- flags no more entry changes in paypd
b_asst_changed		BOOLEAN;	-- flags if asst changes at least once.
b_on_work_schedule	BOOLEAN;	-- use wrk scheds or std hours
l_mid_period_asg_change BOOLEAN := FALSE;

lv_gre_type             varchar2(80) := NULL;
v_return_status              NUMBER;
v_return_message             VARCHAR2(500);
v_schedule_source          varchar2(100);
v_schedule                 varchar2(200);
v_total_hours	NUMBER(15,7) 	;

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
	NVL(HRL.lookup_code, 'NOT ENTERED'),
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
AND	decode(lv_gre_type, 'T4A/RL1', segment11, 'T4A/RL2', SCL.segment12,
                       SCL.segment1) = to_char(p_tax_unit_id)
AND	SCL.enabled_flag		= 'Y'
AND	HRL.lookup_code(+)		= ASG.frequency
AND	HRL.lookup_type(+)		= 'FREQUENCY';
--
-- 25 May 1994:
-- Changing ASG status check to be for Payroll Status of 'Process'
-- AND	AST.per_system_status 		= 'ACTIVE_ASSIGN'
-- AND	AST.pay_system_status 		= 'P'
-- 12 Jul 1994: Now changing back!
-- Here's the deal:
-- 1) PAY_SYSTEM_STATUS needs to be 'P' in order for the payroll run to
--    pick up the asg for processing.
-- 2) The Proration function will look at 'ACTIVE_ASSIGN' *PER_SYSTEM_STATUS*
--    asgs for purposes of "paying" someone - ie. just b/c the "Pay Status"
--    is process for the asg status DOES NOT mean the person is to be paid!
-- ISSUE: How else can we determine whether or not to pay someone via
--        assignment status types?  Ron doesn't like the fact that a user
--        status name of "Leave with Pay" has to have a PER_SYSTEM_STATUS of
--        'ACTIVE_ASSIGN'...and a PAY_SYSTEM_STATUS of 'Process'.
-- So it currently comes down to this - all assignment statuses must have a payroll system
-- status of 'P' in order to be processed by Oracle Payroll.  If the status is to be "with pay", then
-- the personnel system status MUST BE 'ACTIVE_ASSIGN'; an asg status "without pay" will
-- have a per system status of "SUSP_ASSIGN" or "TERM_ASSIGN".
--

FUNCTION Prorate_Earnings (
		p_bg_id			IN NUMBER,
                p_assignment_id         IN NUMBER,
                p_assignment_action_id  IN NUMBER,
                p_element_entry_id      IN NUMBER,
                p_date_earned           IN DATE,
		p_asg_hrly_rate		IN NUMBER,
		p_wsched		IN VARCHAR2 DEFAULT 'NOT ENTERED' ,
		p_asg_std_hours		IN NUMBER,
		p_asg_std_freq		IN VARCHAR2,
		p_range_start_date	IN DATE,
		p_range_end_date	IN DATE,
		p_act_hrs_worked	IN OUT NOCOPY NUMBER) RETURN NUMBER IS

v_prorated_earn	NUMBER(27,7)	:= 0; -- RETURN var
v_hours_in_range	NUMBER(15,7);
v_ws_id		NUMBER(9);
v_ws_name		VARCHAR2(80);

v_return_status              NUMBER;
v_return_message             VARCHAR2(500);
v_schedule_source          varchar2(100);
v_schedule                 varchar2(200);
v_total_hours	NUMBER(15,7) 	;

BEGIN

hr_utility.set_location('Pro_Earn: actual hours worked IN = ', p_act_hrs_worked);
  --
  -- Prorate using hourly rate passed in as param:
  --
/*
  IF UPPER(p_wsched) = 'NOT ENTERED' THEN

    hr_utility.set_location('Prorate_Earnings', 7);
    v_hours_in_range := Standard_Hours_Worked(		p_asg_std_hours,
							p_range_start_date,
							p_range_end_date,
							p_asg_std_freq);

    -- Keep running total of ACTUAL hours worked.

    hr_utility.set_location('Prorate_Earnings', 11);
    p_act_hrs_worked := p_act_hrs_worked + v_hours_in_range;
    hr_utility.set_location('actual_hours_worked = ', p_act_hrs_worked);

  ELSE

    hr_utility.set_location('Prorate_Earnings', 17);

    -- Get work schedule name:
--    v_ws_id := to_number(p_wsched);
    v_ws_id := fnd_number.canonical_to_number(p_wsched);

    SELECT	user_column_name
    INTO	v_ws_name
    FROM	pay_user_columns
    WHERE	user_column_id 			= v_ws_id
    AND         NVL(legislation_code,'CA') 	= 'CA';

    hr_utility.set_location('p_range_start_date='||to_char(p_range_start_date), 19);
    hr_utility.set_location('p_range_end_date='||to_char(p_range_end_date), 19);

hr_utility.set_location('calling core udfs', 44);
*/
    v_hours_in_range := PAY_CORE_FF_UDFS.calculate_actual_hours_worked (
                                   p_assignment_action_id
                                  ,p_assignment_id
                                  ,p_bg_id
                                  ,p_element_entry_id
                                  ,p_date_earned
                                  ,p_range_start_date
                                  ,p_range_end_date
                                  ,NULL
                                  ,'Y'
                                  ,'BUSY'
                                  ,'CA'--p_legislation_code
                                  ,v_schedule_source
                                  ,v_schedule
                                  ,v_return_status
                                  ,v_return_message);

    p_act_hrs_worked := p_act_hrs_worked + v_hours_in_range;
    hr_utility.set_location('actual_hours_worked = ', p_act_hrs_worked);

-- Hours in date range via work schedule or std hours.
 /* END IF;*/

  v_prorated_earn := v_prorated_earn + (p_asg_hrly_rate * v_hours_in_range);
  hr_utility.set_location('v_prorated_earnings = ', v_prorated_earn);
  hr_utility.set_location('Prorate_Earnings', 97);
  p_act_hrs_worked := ROUND(p_act_hrs_worked, 3);
  hr_utility.set_location('Pro_Earn: actual hours worked OUT = ', p_act_hrs_worked);
  RETURN v_prorated_earn;

END Prorate_Earnings;

FUNCTION Prorate_EEV (	p_bus_group_id		IN NUMBER,
                p_assignment_id         IN NUMBER,
                p_assignment_action_id  IN NUMBER,
                p_date_earned           IN DATE,
			p_pay_id		IN NUMBER,
			p_work_sched		IN VARCHAR2 DEFAULT 'NOT ENTERED',
			p_asg_std_hrs		IN NUMBER,
			p_asg_std_freq		IN VARCHAR2,
			p_pay_basis		IN VARCHAR2,
			p_hrly_rate 		IN OUT NOCOPY NUMBER,
			p_range_start_date	IN DATE,
			p_range_end_date	IN DATE,
			p_actual_hrs_worked	IN OUT NOCOPY NUMBER,
			p_element_entry_id	IN NUMBER,
			p_inpval_id		IN NUMBER) RETURN NUMBER IS
--
-- local vars
--
v_eev_prorated_earnings	NUMBER(27,7) := 0; -- Calc'd thru proration loops.
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
--
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
  --
  hr_utility.set_location('Prorate_EEV', 105);
  hr_utility.set_location('p_asg_std_hrs=', p_asg_std_hrs);
  hr_utility.set_location('p_pay_basis='||p_pay_basis, 105);
  hr_utility.set_location('v_earnings_entry='||v_earnings_entry, 105);

hr_utility.set_location('calling core udfs', 45);
  v_curr_hrly_rate := PAY_CORE_FF_UDFS.get_hourly_rate(
                                           p_bus_group_id
                                          ,p_assignment_id
                                          ,p_pay_id
                                          ,p_element_entry_id
                                          ,p_date_earned
                                          ,p_assignment_action_id );
  --
  hr_utility.set_location('v_curr_hrly_rate = ', v_curr_hrly_rate);
  --
  hr_utility.set_location('Prorate_EEV', 107);
  hr_utility.set_location('v_entry_start='||to_char(v_entry_start), 107);
  hr_utility.set_location('v_entry_end='||to_char(v_entry_end), 107);

  v_eev_prorated_earnings := v_eev_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_group_id,
                p_assignment_id    => p_assignment_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_element_entry_id      => p_element_entry_id,
                p_date_earned           => p_date_earned,
				p_asg_hrly_rate 		=> v_curr_hrly_rate,
				p_wsched		=> p_work_sched,
				p_asg_std_hours		=> p_asg_std_hrs,
				p_asg_std_freq		=> p_asg_std_freq,
				p_range_start_date	=> v_entry_start,
				p_range_end_date	=> v_entry_end,
				p_act_hrs_worked       	=> p_actual_hrs_worked);
  --
  hr_utility.set_location('Prorate_EEV.v_eev_prorated_earnings = ', v_eev_prorated_earnings);
  --
  -- SELECT (EEV2):
  OPEN get_entry_chgs (p_range_start_date, p_range_end_date);
    LOOP
    --
    FETCH get_entry_chgs
    INTO  v_earnings_entry,
	  v_entry_start,
	  v_entry_end;
    EXIT WHEN get_entry_chgs%NOTFOUND;
    --
    hr_utility.set_location('Prorate_EEV', 115);
    --
    -- For each range of dates found, add to running prorated earnings total.
    --
    hr_utility.set_location('Prorate_EEV', 117);

hr_utility.set_location('calling core udfs', 46);
  v_curr_hrly_rate := PAY_CORE_FF_UDFS.get_hourly_rate(
                                           p_bus_group_id
                                          ,p_assignment_id
                                          ,p_pay_id
                                          ,p_element_entry_id
                                          ,p_date_earned
                                          ,p_assignment_action_id );

    hr_utility.set_location('v_curr_hrly_rate = ', v_curr_hrly_rate);
    hr_utility.set_location('Prorate_EEV', 119);
    --
    v_eev_prorated_earnings := v_eev_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_group_id,
                p_assignment_id    => p_assignment_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_element_entry_id      => p_element_entry_id,
                p_date_earned           => p_date_earned,
				p_asg_hrly_rate 		=> v_curr_hrly_rate,
				p_wsched		=> p_work_sched,
				p_asg_std_hours		=> p_asg_std_hrs,
				p_asg_std_freq		=> p_asg_std_freq,
				p_range_start_date	=> v_entry_start,
				p_range_end_date	=> v_entry_end,
				p_act_hrs_worked       	=> p_actual_hrs_worked);
    --
    hr_utility.set_location('Prorate_EEV.v_eev_prorated_earnings = ', v_eev_prorated_earnings);
  --
  END LOOP;
  --
  CLOSE get_entry_chgs;
  --
  -- SELECT (EEV3)
  -- Select for SINGLE record that exists across Period End Date:
  -- NOTE: Will only return a row if select (2) does not return a row where
  -- 	   Effective End Date = Period End Date !
  --
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
  --
  hr_utility.set_location('Prorate_EEV', 147);
hr_utility.set_location('calling core udfs', 47);
  v_curr_hrly_rate := PAY_CORE_FF_UDFS.get_hourly_rate(
                                           p_bus_group_id
                                          ,p_assignment_id
                                          ,p_pay_id
                                          ,p_element_entry_id
                                          ,p_date_earned
                                          ,p_assignment_action_id );

  hr_utility.set_location('v_curr_hrly_rate = ', v_curr_hrly_rate);
  hr_utility.set_location('Prorate_EEV', 151);

  v_eev_prorated_earnings := v_eev_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_group_id,
                p_assignment_id    => p_assignment_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_element_entry_id      => p_element_entry_id,
                p_date_earned           => p_date_earned,
				p_asg_hrly_rate 		=> v_curr_hrly_rate,
				p_wsched		=> p_work_sched,
				p_asg_std_hours		=> p_asg_std_hrs,
				p_asg_std_freq		=> p_asg_std_freq,
				p_range_start_date	=> v_entry_start,
				p_range_end_date	=> v_entry_end,
				p_act_hrs_worked       	=> p_actual_hrs_worked);

  hr_utility.set_location('Prorate_EEV.v_eev_prorated_earnings = ', v_eev_prorated_earnings);
  -- We're Done!
  hr_utility.set_location('Prorate_EEV', 167);
  p_actual_hrs_worked := ROUND(p_actual_hrs_worked, 3);
  p_hrly_rate := v_curr_hrly_rate;
  RETURN v_eev_prorated_earnings;

EXCEPTION WHEN NO_DATA_FOUND THEN

  hr_utility.set_location('Prorate_EEV', 177);
  p_actual_hrs_worked := ROUND(p_actual_hrs_worked, 3);
  p_hrly_rate := v_curr_hrly_rate;
  RETURN v_eev_prorated_earnings;

END Prorate_EEV;

FUNCTION	vacation_pay (	p_vac_hours 	IN OUT NOCOPY NUMBER,
				p_asg_id 	IN NUMBER,
				p_eff_date	IN DATE,
				p_curr_rate	IN NUMBER) RETURN NUMBER IS

l_vac_pay	NUMBER(27,7)	DEFAULT 0;
l_vac_hours	NUMBER(10,7);

CURSOR get_vac_hours (	v_asg_id NUMBER,
			v_eff_date DATE) IS
select	pev.screen_entry_value
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

-- The "vacation_pay" function looks for hours entered against absence types
-- in the current period.  The number of hours are summed and multiplied by
-- the current rate of Regular Pay..
-- Return immediately when no vacation time has been taken.
-- Need to loop thru all "Vacation Plans" and check for entries in the current
-- period for this assignment.

BEGIN
hr_utility.set_location('get_vac_pay', 11);
OPEN get_vac_hours (p_asg_id, p_eff_date);
LOOP

  hr_utility.set_location('get_vac_pay', 13);
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

RETURN l_vac_pay;

END vacation_pay;

FUNCTION	sick_pay (	p_sick_hours 	IN OUT NOCOPY NUMBER,
				p_asg_id 	IN NUMBER,
				p_eff_date	IN DATE,
				p_curr_rate	IN NUMBER) RETURN NUMBER IS

l_sick_pay	NUMBER(27,7)	DEFAULT 0;
l_sick_hours	NUMBER(10,7);

CURSOR get_sick_hours (	v_asg_id NUMBER,
			v_eff_date DATE) IS
select	pev.screen_entry_value
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

-- The "sick_pay" function looks for hours entered against Sick absence types in
-- the current period.  The number of hours are summed and multiplied by the
-- current rate of Regular Pay.
-- Return immediately when no sick time has been taken.

BEGIN

hr_utility.set_location('get_sick_pay', 11);
OPEN get_sick_hours (p_asg_id, p_eff_date);
LOOP

  hr_utility.set_location('get_sick_pay', 13);
  FETCH get_sick_hours
  INTO	l_sick_hours;
  EXIT WHEN get_sick_hours%NOTFOUND;

  p_sick_hours := p_sick_hours + l_sick_hours;

END LOOP;
CLOSE get_sick_hours;
hr_utility.set_location('get_sick_pay', 15);

IF p_sick_hours <> 0 THEN

  l_sick_pay := p_sick_hours * p_curr_rate;

END IF;

RETURN l_sick_pay;

END sick_pay;

BEGIN	-- Calculate_Period_Earnings

  /* Getting GRE Type of tax unit for Multi GRE functionality
     Based on the gre type, the segment will be used in where clause.

     T4/RL1    -  Segment1
     T4A/RL1   -  Segment11
     T4A/RL2   -  Segment12
  */

  begin
     select org_information5
     into   lv_gre_type
     from   hr_organization_information hoi
     where  hoi.org_information_context = 'Canada Employer Identification'
     and    hoi.organization_id = p_tax_unit_id;

     exception
     when others then
     null;

   end;

-- init out param
p_actual_hours_worked := 0;

-- Step (1): Find earnings element input value.
-- Get input value and pay basis according to salary admin (if exists).
-- If not using salary admin, then get "Rate", "Rate Code", or "Monthly Salary"
-- input value id as appropriate (according to ele name).

IF p_pay_basis IS NOT NULL THEN
  begin
  hr_utility.set_location('calculate_period_earnings', 10);
  SELECT	PYB.input_value_id,
  		FCL.meaning,
  		FCL.lookup_code
  INTO		v_inpval_id,
 		v_pay_basis,
 		v_pay_basis_code
  FROM		per_assignments_f	ASG,
		per_pay_bases 		PYB,
		hr_lookups		FCL
  WHERE	FCL.lookup_code	= PYB.pay_basis
  AND		FCL.lookup_type 	= 'PAY_BASIS'
  AND		FCL.application_id	= 800
  AND		PYB.pay_basis_id 	= ASG.pay_basis_id
  AND		ASG.assignment_id 	= p_asst_id
  AND		p_date_earned
 			   BETWEEN ASG.effective_start_date
				AND ASG.effective_end_date;

  EXCEPTION WHEN NO_DATA_FOUND THEN

    hr_utility.set_location('calculate_period_earnings', 11);
    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN  v_period_earn;

--    hr_utility.set_message(801, 'PAY_xxxx_NO_ASST_IN_PERIOD');
--    hr_utility.raise_error;

  END;

ELSIF UPPER(p_inpval_name) = 'RATE' THEN
  begin
  hr_utility.set_location('calculate_period_earnings', 13);
  SELECT 	IPV.input_value_id
  INTO		v_inpval_id
  FROM		pay_input_values_f	IPV,
		pay_element_types_f	ELT
  WHERE	UPPER(ELT.element_name)	= 'REGULAR WAGES'
  AND		ELT.element_type_id		= IPV.element_type_id
  AND		p_period_start	  BETWEEN IPV.effective_start_date
				      AND IPV.effective_end_date
  AND		UPPER(IPV.name)		= 'RATE';
  --
  v_pay_basis := 'HOURLY';
  --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 14);
    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN  v_period_earn;
--    hr_utility.set_message(801, 'PAY_xxx_REGWAGE_RATE_NOTFOUND');
--    hr_utility.raise_error;
  end;
  --
ELSIF UPPER(p_inpval_name) = 'RATE CODE' THEN
  begin
  hr_utility.set_location('calculate_period_earnings', 15);
  SELECT 	IPV.input_value_id
  INTO		v_inpval_id
  FROM		pay_input_values_f	IPV,
		pay_element_types_f	ELT
  WHERE	UPPER(ELT.element_name)	= 'REGULAR WAGES'
  AND		ELT.element_type_id		= IPV.element_type_id
  AND		p_period_start	  BETWEEN IPV.effective_start_date
				      AND IPV.effective_end_date
  AND		UPPER(IPV.name)		= 'RATE CODE';
  --
  v_pay_basis := 'HOURLY';
  --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 16);
    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN  v_period_earn;
--    hr_utility.set_message(801, 'PAY_xxx_REGWAGE_RATECODE_NOTFOUND');
--    hr_utility.raise_error;
  end;
  --
ELSIF UPPER(p_inpval_name) = 'MONTHLY SALARY' THEN
  begin
  hr_utility.set_location('calculate_period_earnings', 17);
  SELECT 	IPV.input_value_id
  INTO		v_inpval_id
  FROM		pay_input_values_f	IPV,
		pay_element_types_f	ELT
  WHERE	UPPER(ELT.element_name)	= 'REGULAR SALARY'
  AND		ELT.element_type_id		= IPV.element_type_id
  AND		p_period_start	  BETWEEN IPV.effective_start_date
				      AND IPV.effective_end_date
  AND		UPPER(IPV.name)		= 'MONTHLY SALARY';

  v_pay_basis := 'MONTHLY';

  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 18);
    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN  v_period_earn;
--    hr_utility.set_message(801, 'PAY_xxx_REGSAL_NOTFOUND');
--    hr_utility.raise_error;
  END;

END IF;

/*
-- Now know the pay basis for this assignment (v_pay_basis).
-- Want to convert entered earnings to pay period earnings.
-- For pay basis of Annual, Monthly, Bi-Weekly, Semi-Monthly, or Period (ie. anything
-- other than Hourly):
-- 	Annualize entered earnings according to pay basis;
--	then divide by number of payroll periods per fiscal yr for pay period earnings.
-- 02 Dec 1993:
-- Actually, passing in an "Hourly" figure from formula alleviates
-- having to convert in here --> we have Convert_Period_Type function
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

exception when NO_DATA_FOUND then

  hr_utility.set_location('calculate_period_earnings', 41);
  v_period_earn := 0;
  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN  v_period_earn;
--  hr_utility.set_message(801, 'PAY_xxxx_NUM_PER_FY_NOT_FOUND');
--  hr_utility.raise_error;

end;

/*
     -- Pay basis is hourly,
     -- 	Get hours scheduled for the current period either from:
     --	1. ASG work schedule
     --	2. ORG default work schedule
     --	3. ASG standard hours and frequency
     -- Do we pass in Work Schedule from asst scl db item?  Yes
     -- 10-JAN-1996 hparicha : We no longer assume "standard hours" represent
     -- a weekly figure.  We also no longer use a week as the basis for annualization,
     -- even when using work schedule - ie. need to find ACTUAL scheduled hours, not
     -- actual hours for a week, converted to a period figure.
*/
--
hr_utility.set_location('calculate_period_earnings', 45);
/* IF p_work_schedule <> 'NOT ENTERED' THEN
  --
  -- Find hours worked between period start and end dates.
  --

--  v_ws_id := to_number(p_work_schedule);
  v_ws_id := fnd_number.canonical_to_number(p_work_schedule);

  --
  SELECT	user_column_name
  INTO		v_work_sched_name
  FROM		pay_user_columns
  WHERE		user_column_id 				= v_ws_id
  AND		NVL(business_group_id, p_bus_grp_id)	= p_bus_grp_id
  AND           NVL(legislation_code,'CA') 		= 'CA';
  --
*/
hr_utility.set_location('calling core udfs', 45);
  v_hrs_per_range := PAY_CORE_FF_UDFS.calculate_actual_hours_worked (
                                   p_assignment_action_id
                                  ,p_asst_id
                                  ,p_bus_grp_id
                                  ,p_ele_entry_id
                                  ,p_date_earned
                                  ,p_period_start
                                  ,p_period_end
                                  ,NULL
                                  ,'Y'
                                  ,'BUSY'
                                  ,'CA'--p_legislation_code
                                  ,v_schedule_source
                                  ,v_schedule
                                  ,v_return_status
                                  ,v_return_message);
/*
ELSE

   v_hrs_per_range := Standard_Hours_Worked(	p_asst_std_hrs,
						p_period_start,
						p_period_end,
						p_asst_std_freq);

END IF;
*/

-- Compute earnings and actual hours PER PAY PERIOD.
-- Convert HOURLY earnings to PERIOD earnings.
-- Passing "NULL" freq to Convert_Period_Type will convert
-- to/from the payroll time period type.

hr_utility.set_location('calculate_period_earnings', 46);
v_period_earn := Convert_Period_Type(	p_bus_grp_id,
					p_payroll_id,
                p_assignment_action_id,
                p_asst_id  ,
                p_ele_entry_id,
                p_date_earned ,
					p_work_schedule,
					p_asst_std_hrs,
					p_ass_hrly_figure,
					'HOURLY',
					NULL,
					p_period_start,
					p_period_end,
					p_asst_std_freq);

hr_utility.set_location('calculate_period_earnings', 47);

p_actual_hours_worked := v_hrs_per_range;
hr_utility.set_location('Calc_PE actual_hours_worked = ', p_actual_hours_worked);

-- Check that Pro-rate = 'Y' before continuing.

IF p_prorate = 'N' THEN

  -- Done!!! No pro-ration...
  hr_utility.set_location('calculate_period_earnings', 49);
  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

  RETURN v_period_earn;

END IF;

-- Before going into proration, check for ASG and EEV changes within
-- period dates -> if none are found then return v_period_earn and we're done!
-- This is the 80-90% case so we want to get out as quickly as possible.

-- (ASG1) Select for SINGLE record that includes Period Start Date but does not
--        span entire period.  If no row returned, then ASG record spans period
--        and there is no need to run selects (ASG2) or (ASG3).

hr_utility.set_location('calculate_period_earnings', 51);

/* ************************************************************** */

begin

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
  AND		decode(lv_gre_type, 'T4A/RL1', segment11, 'T4A/RL2', segment12,
                       SCL.segment1) = to_char(p_tax_unit_id)
  AND		SCL.enabled_flag		= 'Y');

  -- l_asg_info_changes := 1;

  -- 25 May 1994:
  -- Changing ASG status check to be for Payroll Status of 'Process'
  -- AND	AST.per_system_status 		= 'ACTIVE_ASSIGN'
  -- AND	AST.pay_system_status 		= 'P'

  -- Need to prorate b/c of ASG changes, but let's look for EEV changes
  -- for future reference:

  l_mid_period_asg_change := TRUE;

  hr_utility.set_location('calculate_period_earnings', 56);

  begin

  select 1 INTO l_eev_info_changes
    from dual
  where exists (
    SELECT	1
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND 	EEV.input_value_id+0 		= v_inpval_id
    AND  (
         (EEV.effective_start_date     <= p_period_start
           AND EEV.effective_end_date  >= p_period_start
           AND EEV.effective_end_date  < p_period_end)
          OR (EEV.effective_start_date between p_period_start and p_period_end)
         )
    );

    -- Prorate: l_asg_info_changes EXIST,
    --		l_eev_info_changes EXIST

  exception

    WHEN NO_DATA_FOUND THEN
      l_eev_info_changes := 0;

      -- Prorate: l_asg_info_changes EXIST,
      --          l_eev_info_changes DO NOT EXIST

  end;

exception

  WHEN NO_DATA_FOUND THEN

    l_asg_info_changes := 0;

end;

IF l_asg_info_changes = 0 THEN

  -- (ASG1.1)
  --      Actually need to select for ASG record that STARTS within period
  --	  ie. becomes active on a date later than start date!

  hr_utility.set_location('calculate_period_earnings', 52);

  begin

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
    AND  decode(lv_gre_type, 'T4A/RL1', SCL.segment11, 'T4A/RL2', SCL.segment12,
                 SCL.segment1) = to_char(p_tax_unit_id)
    AND		SCL.enabled_flag		= 'Y');

    l_mid_period_asg_change := TRUE;

    -- Need to prorate b/c of mid period ASG changes, but let's look for
    -- EEV changes for future reference:

    hr_utility.set_location('calculate_period_earnings', 55);

    begin

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

    -- Prorate: l_asg_info_changes EXIST,
    --		l_eev_info_changes EXIST

    exception

      WHEN NO_DATA_FOUND THEN
        l_eev_info_changes := 0;

        -- Prorate: l_asg_info_changes EXIST,
        --          l_eev_info_changes DO NOT EXIST

    end;

  exception

    WHEN NO_DATA_FOUND THEN
      l_asg_info_changes := 0;

  end;

END IF;

IF l_asg_info_changes = 0 THEN -- Still

  -- Check for EEV changes, if also none -> return v_period_earn and done:
  -- (EEV1) Select for SINGLE record that includes Period Start Date but
  --   	    does not span entire period.  If no row returned, then EEV record
  --	    spans period and there is no need to run selects (EEV2) or (EEV3)
  --        and we can stop now!

  begin

    hr_utility.set_location('calculate_period_earnings', 53);

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

    -- Proration will occur for l_asg_info_changes DO NOT EXIST and
    --				l_eev_info_changes EXIST

  exception

    WHEN NO_DATA_FOUND THEN
      -- This is mainline fallthru point.
      -- l_asg_info_changes AND l_eev_info_changes DO NOT EXIST.
      -- Done!!! No pro-ration required b/c no ASG or EEV changes exist
      -- this period!
      -- Either there are no changes to an Active Assignment OR
      -- the assignment was not active at all this period.
      -- Check assignment status of current asg record.

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
      AND decode(lv_gre_type, 'T4A/RL1', segment11, 'T4A/RL2', SCL.segment12,
                       SCL.segment1) = to_char(p_tax_unit_id)
      AND	SCL.enabled_flag		= 'Y';

      IF v_asg_status <> 'ACTIVE_ASSIGN' THEN

        v_period_earn := 0;
        p_actual_hours_worked := 0;

      END IF;

      p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
      RETURN v_period_earn;

  end;

END IF;

/* ************************************************************** */

-- If code reaches here, then we're prorating for one reason or the other.
-- We can check l_asg_info_changes and l_eev_info_changes to see what needs
-- to be done.
-- We'll use these flags in the interest of efficiency:
-- 	l_asg_info_changes = 0 ==> No ASG changes
--	l_eev_info_changes = 0 ==> No EEV changes
--
-- *********************************************************************
-- Step (2): is Work_Schedule_Total_Hours(ws, from, to) code or fn call.
-- *********************************************************************
--
-- *********************************************************************
-- Step (3): Find pay period salary as hourly rate.
-- 02 Dec 1993: We're passing in an hourly figure already!!!
-- *********************************************************************
/*
-- Step (4): Perform any necessary pro-ration.
-- In declaration we have:
-- Need to check if cursor sql w/max and min works; otherwise do check after
-- fetch.  This cursor *FAILS* to retreive a rec if NO CHANGES occur in period.
-- This is the 90% case where we want to just fall thru asap.  Same will apply
-- for element entry change cursor.
-- Remember, we need asst recs in the same tax unit as that passed in.
-- So the start date of the work info record w/the same tax unit must be less
-- than or equal to the start date of the asst rec.  That's all we have to
-- check since a change to tax unit will cause date-effective update to asst.
-- ^^^ Need to verify that tax-unit changes are date-effective and that they
-- **are reflected in per_assignments_f**.  Also need to know what other
-- changes result in date-effective update to work_info tab and whether
-- or not all changes date-effectively affect assignment.  They SHOULD be
-- reflected in asst since this would be consistent w/SCL keyflex behaviour.
-- A: Yes they are. (13 May 1994 HParicha)
-- Remember, need to check work schedule before each call to
-- Work_Schedule_Total_Hours.
-- OK so to pro-rate earnings, determine exactly what needs to be done up
-- front in order of expected frequency:
-- 	1. Assignment Info Changes Only
--	2. Element Entry Info Changes Only
--	3. Both ASG and EEV info changes

*/
IF (l_asg_info_changes > 0) AND (l_eev_info_changes = 0) THEN

  -- Use hourly rate passed in (p_ass_hrly_figure) and use this to prorate
  -- thru all ASG changes.  No need to check for change in hourly rate.

  -- SELECT (ASG1):
  -- Select for SINGLE record that includes Period Start Date but does not
  -- span entire period.
  -- We know this select will return a row, otherwise there would be no
  -- ASG changes to detect.
  -- Actually it might NOT return a row - the mid period change may have
  -- been a mid period hire or return from leave of absence, in which case
  -- you would not have an assignment record to 'Process' that spans the
  -- Start Date of the period!

  p_actual_hours_worked := 0;
  hr_utility.set_location('calculate_period_earnings', 70);
  --  IF NOT l_mid_period_asg_change THEN

  begin

    hr_utility.set_location('calculate_period_earnings', 71);
    SELECT	GREATEST(ASG.effective_start_date, p_period_start),
		ASG.effective_end_date,
		NVL(ASG.NORMAL_HOURS, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(HRL.lookup_code, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
    INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_asst_std_freq_code,
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
    AND	decode(lv_gre_type, 'T4A/RL1', segment11, 'T4A/RL2', SCL.segment12,
                       SCL.segment1) = to_char(p_tax_unit_id)
    AND		SCL.enabled_flag		= 'Y'
    AND		HRL.lookup_code(+)		= ASG.frequency
    AND		HRL.lookup_type(+)		= 'FREQUENCY';

-- 25 May 1994:
-- Changing ASG status check to be for Payroll Status of 'Process'
-- AND	AST.per_system_status 		= 'ACTIVE_ASSIGN'
-- AND	AST.pay_system_status 		= 'P'

    -- Prorate using hourly rate passed in as param:
    -- Should this become a function from here...

    hr_utility.set_location('calculate_period_earnings', 72);
    v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
                p_assignment_id    => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_element_entry_id      => p_ele_entry_id,
                p_date_earned           => p_date_earned,
				p_asg_hrly_rate 		=> p_ass_hrly_figure,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq_code,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked      	 => p_actual_hours_worked);

    hr_utility.set_location('Calculate_Period_Earnings.v_prorated_earnings = ', v_prorated_earnings);

  -- Just in case mid period change does not span Start of Period!

  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;

  end;

--  END IF;

  -- SELECT (ASG2)
  -- Select for ALL records that are WITHIN Period Start and End Dates
  -- including Period End Date.
  -- Not BETWEEN Period Start/End since we already found a record including
  -- Start Date in select (1) above.

  hr_utility.set_location('calculate_period_earnings', 77);
  OPEN get_asst_chgs;	-- SELECT (ASG2)
  LOOP

    FETCH get_asst_chgs
    INTO  v_range_start,
	  v_range_end,
	  v_asst_std_hrs,
	  v_asst_std_freq,
	  v_asst_std_freq_code,
	  v_work_schedule;
    EXIT WHEN get_asst_chgs%NOTFOUND;

    hr_utility.set_location('calculate_period_earnings', 79);

    -- For each range of dates found, add to running prorated earnings total.

    hr_utility.set_location('calculate_period_earnings', 81);
    v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
                p_assignment_id    => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_element_entry_id      => p_ele_entry_id,
                p_date_earned           => p_date_earned,
				p_asg_hrly_rate	 	=> p_ass_hrly_figure,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq_code,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked	=> p_actual_hours_worked);

    hr_utility.set_location('Calculate_Period_Earnings.v_prorated_earnings = ', v_prorated_earnings);

  END LOOP;

  CLOSE get_asst_chgs;

  -- SELECT (ASG3)
  -- Select for SINGLE record that exists across Period End Date:
  -- NOTE: Will only return a row if select (2) does not return a row where
  -- 	     Effective End Date = Period End Date !

  begin

  hr_utility.set_location('calculate_period_earnings', 89);
  SELECT	ASG.effective_start_date,
 		LEAST(ASG.effective_end_date, p_period_end),
		NVL(ASG.normal_hours, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(HRL.lookup_code, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
  INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_asst_std_freq_code,
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
  AND decode(lv_gre_type, 'T4A/RL1', segment11, 'T4A/RL2', SCL.segment12,
                       SCL.segment1) = to_char(p_tax_unit_id)
  AND		SCL.enabled_flag		= 'Y'
  AND		HRL.lookup_code(+)		= ASG.frequency
  AND		HRL.lookup_type(+)		= 'FREQUENCY';

-- 25 May 1994:
-- Changing ASG status check to be for Payroll Status of 'Process'
-- AND	AST.per_system_status 		= 'ACTIVE_ASSIGN'
-- AND	AST.pay_system_status		= 'P'

  hr_utility.set_location('calculate_period_earnings', 91);
  v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
                p_assignment_id  => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_element_entry_id      => p_ele_entry_id,
                p_date_earned           => p_date_earned,
				p_asg_hrly_rate 	=> p_ass_hrly_figure,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq_code,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked       	=> p_actual_hours_worked);

  hr_utility.set_location('Calculate_Period_Earnings.v_prorated_earnings = ', v_prorated_earnings);

  -- We're done!

  hr_utility.set_location('calculate_period_earnings', 101);

  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN v_prorated_earnings;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    -- (ASG3) returned no rows, but we're done anyway!
    hr_utility.set_location('calculate_period_earnings', 102);

    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN v_prorated_earnings;

  END;

ELSIF (l_asg_info_changes = 0) AND (l_eev_info_changes > 0) THEN

  hr_utility.set_location('calculate_period_earnings', 103);
  p_actual_hours_worked := 0;
  v_prorated_earnings := v_prorated_earnings +
		         Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
                p_assignment_id  => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_date_earned           => p_date_earned,
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

  -- We're Done!
  hr_utility.set_location('calculate_period_earnings', 127);

  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN v_prorated_earnings;

ELSE

  -- We assume both l_asg_info_changes and l_eev_info_changes > 0 since
  -- we wouldn't have reached this section of code if they both = 0 !
  -- So cycle thru ASG changes; for each range found for ASG change,
  -- check for EEV changes IN THAT RANGE!  If none are found, then
  -- prorate with current (latest) hourly rate figure.  If EEV changes
  -- are found, then call EEV proration and continue when complete.

  -- SELECT (ASG1.2):
  -- Select for SINGLE record that includes Period Start Date but does not
  -- span entire period.
  -- We know this select will return a row, otherwise there would be no
  -- ASG changes to detect.

  p_actual_hours_worked := 0;

  -- Since we KNOW both asg and eev changes occur, then we want current
  -- (latest) hourly rate to be figure AS OF BEGINNING OF PERIOD for starters.
  -- NOT! v_curr_hrly_rate := p_ass_hrly_figure;

 begin

  hr_utility.set_location('calculate_period_earnings', 128);
  SELECT	EEV.screen_entry_value
  INTO		v_earnings_entry
  FROM		pay_element_entry_values_f	EEV
  WHERE		EEV.element_entry_id 		= p_ele_entry_id
  AND 		EEV.input_value_id 		= v_inpval_id
  --bug 5617540 starts
  AND		p_period_start between EEV.effective_start_date
                               AND EEV.effective_end_date;
  /* --
  AND		EEV.effective_start_date       <= p_period_start
  AND  		EEV.effective_end_date 	       >= p_period_start
  AND  		EEV.effective_end_date 	        < p_period_end;*/
--bug 5617540 ends

  SELECT	GREATEST(ASG.effective_start_date, p_period_start),
		ASG.effective_end_date,
		NVL(ASG.NORMAL_HOURS, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(HRL.lookup_code, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
  INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_asst_std_freq_code,
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
    AND	decode(lv_gre_type, 'T4A/RL1', segment11, 'T4A/RL2', SCL.segment12,
                       SCL.segment1) 			= to_char(p_tax_unit_id)
    AND		SCL.enabled_flag		= 'Y'
    AND		HRL.lookup_code(+)		= ASG.frequency
    AND		HRL.lookup_type(+)		= 'FREQUENCY';

  hr_utility.set_location('v_earnings_entry='||v_earnings_entry, 129);
  hr_utility.set_location('v_asst_std_hrs=', v_asst_std_hrs);
hr_utility.set_location('calling core udfs', 48);
  v_curr_hrly_rate := PAY_CORE_FF_UDFS.get_hourly_rate(
                                           p_bus_grp_id
                                          ,p_asst_id
                                          ,p_payroll_id
                                          ,p_ele_entry_id
                                          ,p_date_earned
                                          ,p_assignment_action_id );

  hr_utility.set_location('v_curr_hrly_rate = ', v_curr_hrly_rate);
  hr_utility.set_location('calculate_period_earnings', 130);
--  IF NOT l_mid_period_asg_change THEN

    -- Do not have to do this first bit if Mid period hire/active asg occurs:

-- 25 May 1994:
-- Changing ASG status check to be for Payroll Status of 'Process'
-- AND	AST.per_system_status 		= 'ACTIVE_ASSIGN'
-- AND	AST.pay_system_status 		= 'P'

    -- (EEV1) Select for SINGLE record that includes Period Start Date but
    --        does not span entire period.

    hr_utility.set_location('calculate_period_earnings', 132);
    SELECT	COUNT(EEV.element_entry_value_id)
    INTO	l_eev_info_changes
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND		EEV.input_value_id 		= v_inpval_id
    AND		EEV.effective_start_date       <= v_range_start
    AND		EEV.effective_end_date 	       >= v_range_start
    AND		EEV.effective_end_date 	        < v_range_end;

    IF l_eev_info_changes = 0 THEN
      -- Prorate using latest hourly rate:
      hr_utility.set_location('calculate_period_earnings', 128);
      SELECT		EEV.screen_entry_value
      INTO		v_earnings_entry
      FROM		pay_element_entry_values_f	EEV
      WHERE		EEV.element_entry_id 		= p_ele_entry_id
      AND 		EEV.input_value_id 		= v_inpval_id
      AND		v_range_end 	BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date;

      hr_utility.set_location('v_earnings_entry='||v_earnings_entry, 129);
      hr_utility.set_location('v_asst_std_hrs=', v_asst_std_hrs);
hr_utility.set_location('calling core udfs', 49);
  v_curr_hrly_rate := PAY_CORE_FF_UDFS.get_hourly_rate(
                                           p_bus_grp_id
                                          ,p_asst_id
                                          ,p_payroll_id
                                          ,p_ele_entry_id
                                          ,p_date_earned
                                          ,p_assignment_action_id );

      hr_utility.set_location('v_curr_hrly_rate = ', v_curr_hrly_rate);
      -- Should this become a function from here...
      hr_utility.set_location('calculate_period_earnings', 133);
      v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
                p_assignment_id  => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_element_entry_id      => p_ele_entry_id,
                p_date_earned           => p_date_earned,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq_code,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked      	=> p_actual_hours_worked);

      hr_utility.set_location('Calculate_Period_Earnings.v_prorated_earnings = ', v_prorated_earnings);

    ELSE
      -- Do proration for this ASG range by EEV !

      hr_utility.set_location('calculate_period_earnings', 134);
      v_prorated_earnings := v_prorated_earnings +
			   Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
                p_assignment_id  => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_date_earned           => p_date_earned,
				p_pay_id		=> p_payroll_id,
				p_work_sched		=> v_work_schedule,
				p_asg_std_hrs		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq_code,
				p_pay_basis		=> v_pay_basis_code,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> v_range_start,
				p_range_end_date    	=> v_range_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);

    END IF; -- EEV info changes

  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;

 end;

--  END IF; -- Mid Period Active ASG.

  -- SELECT (ASG2.2)
  -- Select for ALL records that are WITHIN Period Start and End Dates
  -- including Period End Date.
  -- Not BETWEEN Period Start/End since we already found a record including
  -- Start Date in select (1) above.

  hr_utility.set_location('calculate_period_earnings', 135);
  OPEN get_asst_chgs;	-- SELECT (ASG2)
  LOOP

    FETCH get_asst_chgs
    INTO  v_range_start,
	  v_range_end,
	  v_asst_std_hrs,
	  v_asst_std_freq,
	  v_asst_std_freq_code,
	  v_work_schedule;
    EXIT WHEN get_asst_chgs%NOTFOUND;

    hr_utility.set_location('calculate_period_earnings', 79);

    -- For each range of dates found, add to running prorated earnings total.

    -- Check for EEV changes, if also none -> return v_period_earn and done:
    -- (EEV1) Select for SINGLE record that includes Period Start Date but
    -- 	    does not span entire period.  If no row returned, then EEV record
    --	    spans period and there is no need to run selects (EEV2) or (EEV3)
    --      and we can stop now!

    hr_utility.set_location('calculate_period_earnings', 133);
    SELECT	COUNT(EEV.element_entry_value_id)
    INTO	l_eev_info_changes
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND 	EEV.input_value_id 		= v_inpval_id
    AND		EEV.effective_start_date       <= v_range_start
    AND  	EEV.effective_end_date 	       >= v_range_start
    AND  	EEV.effective_end_date 	        < v_range_end;

    IF l_eev_info_changes = 0 THEN
      -- Prorate using latest hourly rate:
      hr_utility.set_location('calculate_period_earnings', 128);
      SELECT		EEV.screen_entry_value
      INTO		v_earnings_entry
      FROM		pay_element_entry_values_f	EEV
      WHERE		EEV.element_entry_id 		= p_ele_entry_id
      AND 		EEV.input_value_id 		= v_inpval_id
      AND		v_range_end 	BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date;
      --
      hr_utility.set_location('v_earnings_entry='||v_earnings_entry, 129);
      hr_utility.set_location('v_asst_std_hrs=', v_asst_std_hrs);

hr_utility.set_location('calling core udfs', 50);
  v_curr_hrly_rate := PAY_CORE_FF_UDFS.get_hourly_rate(
                                           p_bus_grp_id
                                          ,p_asst_id
                                          ,p_payroll_id
                                          ,p_ele_entry_id
                                          ,p_date_earned
                                          ,p_assignment_action_id );
      --
      hr_utility.set_location('v_curr_hrly_rate = ', v_curr_hrly_rate);
      hr_utility.set_location('calculate_period_earnings', 91);
      v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
                p_assignment_id    => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_element_entry_id      => p_ele_entry_id,
                p_date_earned           => p_date_earned,
				p_asg_hrly_rate 		=> v_curr_hrly_rate,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq_code,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked       	=> p_actual_hours_worked);
      --
      hr_utility.set_location('Calculate_Period_Earnings.v_prorated_earnings = ', v_prorated_earnings);
      --
    ELSE
      -- Do proration for this ASG range by EEV !
      --
      v_prorated_earnings := v_prorated_earnings +
	  		     Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
                p_assignment_id  => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_date_earned           => p_date_earned,
				p_pay_id		=> p_payroll_id,
				p_work_sched		=> v_work_schedule,
				p_asg_std_hrs		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq_code,
				p_pay_basis		=> v_pay_basis_code,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> v_range_start,
				p_range_end_date    	=> v_range_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);

    END IF;

  END LOOP;

  CLOSE get_asst_chgs;

  -- SELECT (ASG3.2)
  -- Select for SINGLE record that exists across Period End Date:
  -- NOTE: Will only return a row if select (2) does not return a row where
  -- 	     Effective End Date = Period End Date !

  begin

  hr_utility.set_location('calculate_period_earnings', 129);
  SELECT	ASG.effective_start_date,
 		LEAST(ASG.effective_end_date, p_period_end),
		NVL(ASG.normal_hours, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(HRL.lookup_code, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
  INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_asst_std_freq_code,
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
  AND	decode(lv_gre_type, 'T4A/RL1', segment11, 'T4A/RL2', SCL.segment12,
                       SCL.segment1) = to_char(p_tax_unit_id)
  AND		SCL.enabled_flag		= 'Y'
  AND		HRL.lookup_code(+)		= ASG.frequency
  AND		HRL.lookup_type(+)		= 'FREQUENCY';

-- 25 May 1994:
-- Changing ASG status check to be for Payroll Status of 'Process'
-- AND	AST.per_system_status 		= 'ACTIVE_ASSIGN'
-- AND		AST.pay_system_status		= 'P'

  -- Check for EEV changes, if also none -> return v_period_earn and done:
  -- (EEV1) Select for SINGLE record that includes Period Start Date but
  -- 	    does not span entire period.  If no row returned, then EEV record
  --	    spans period and there is no need to run selects (EEV2) or (EEV3)
  --        and we can stop now!  Remember, if eev spans period then get
  --        eev.screen_entry_value that spans period (ie latest hrly rate).

  hr_utility.set_location('calculate_period_earnings', 133);
  SELECT	COUNT(EEV.element_entry_value_id)
  INTO		l_eev_info_changes
  FROM		pay_element_entry_values_f	EEV
  WHERE		EEV.element_entry_id 		= p_ele_entry_id
  AND 		EEV.input_value_id 		= v_inpval_id
  AND		EEV.effective_start_date       <= v_range_start
  AND  		EEV.effective_end_date 	       >= v_range_start
  AND  		EEV.effective_end_date 	        < v_range_end;

  IF l_eev_info_changes = 0 THEN
    -- Prorate using latest hourly rate (ie. rate as of end of period):
    hr_utility.set_location('calculate_period_earnings', 128);
    SELECT	EEV.screen_entry_value
    INTO		v_earnings_entry
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND 		EEV.input_value_id 		= v_inpval_id
    AND		v_range_end 		BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date;

    hr_utility.set_location('v_earnings_entry='||v_earnings_entry, 129);
hr_utility.set_location('calling core udfs', 51);
  v_curr_hrly_rate := PAY_CORE_FF_UDFS.get_hourly_rate(
                                           p_bus_grp_id
                                          ,p_asst_id
                                          ,p_payroll_id
                                          ,p_ele_entry_id
                                          ,p_date_earned
                                          ,p_assignment_action_id );

    hr_utility.set_location('v_curr_hrly_rate = ', v_curr_hrly_rate);
    hr_utility.set_location('calculate_period_earnings', 130);

    hr_utility.set_location('calculate_period_earnings', 137);
    v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
                p_assignment_id    => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_element_entry_id      => p_ele_entry_id,
                p_date_earned           => p_date_earned,
				p_asg_hrly_rate 		=> v_curr_hrly_rate,
				p_wsched		=> v_work_schedule,
				p_asg_std_hours		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq_code,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked       	=> p_actual_hours_worked);

    hr_utility.set_location('Calculate_Period_Earnings.v_prorated_earnings = ', v_prorated_earnings);

  ELSE
    -- Do proration for this ASG range by EEV !

    hr_utility.set_location('calculate_period_earnings', 139);
    v_prorated_earnings := v_prorated_earnings +
	  		     Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
                p_assignment_id  => p_asst_id,
                p_assignment_action_id  => p_assignment_action_id,
                p_date_earned           => p_date_earned,
				p_pay_id		=> p_payroll_id,
				p_work_sched		=> v_work_schedule,
				p_asg_std_hrs		=> v_asst_std_hrs,
				p_asg_std_freq		=> v_asst_std_freq_code,
				p_pay_basis		=> v_pay_basis_code,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> v_range_start,
				p_range_end_date    	=> v_range_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);

  END IF;

  -- We're done!

  hr_utility.set_location('calculate_period_earnings', 141);

  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN v_prorated_earnings;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    -- (ASG3.2) returned no rows, but we're done anyway!
    hr_utility.set_location('calculate_period_earnings', 142);

    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN v_prorated_earnings;

  END;

END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 190);

    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

    RETURN v_prorated_earnings;

END Calculate_Period_Earnings;

-- **********************************************************************

FUNCTION standard_hours_worked(
				p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER IS

c_wkdays_per_week	NUMBER(5,2)		:= 5;
c_wkdays_per_month	NUMBER(5,2)		:= 20;
c_wkdays_per_year	NUMBER(5,2)		:= 250;

/* 353434, 368242 : Fixed number width for total hours */
v_total_hours	NUMBER(15,7) 	:= 0;
v_wrkday_hours	NUMBER(15,7) 	:= 0;	 -- std hrs/wk divided by 5 workdays/wk
v_curr_date	DATE			:= NULL;
v_curr_day	VARCHAR2(3)		:= NULL; -- 3 char abbrev for day of wk.
v_day_no        NUMBER;

BEGIN -- standard_hours_worked

-- Check for valid range
hr_utility.set_location('standard_hours_worked', 5);
IF p_range_start > p_range_end THEN
  hr_utility.set_location('standard_hours_worked', 7);
  RETURN v_total_hours;
--  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
--  hr_utility.raise_error;
END IF;
--

IF UPPER(p_std_freq) = 'W' THEN
  v_wrkday_hours := p_std_hrs / c_wkdays_per_week;
ELSIF UPPER(p_std_freq) = 'M' THEN
  v_wrkday_hours := p_std_hrs / c_wkdays_per_month;
ELSIF UPPER(p_std_freq) = 'Y' THEN
  v_wrkday_hours := p_std_hrs / c_wkdays_per_year;
ELSE
  v_wrkday_hours := p_std_hrs;
END IF;

v_curr_date := p_range_start;

hr_utility.set_location('standard_hours_worked', 10);

         hr_utility.trace('p_range_start is'|| to_char(p_range_start));
         hr_utility.trace('p_range_end is'|| to_char(p_range_end));
LOOP

  v_day_no := TO_CHAR(v_curr_date, 'D');

  hr_utility.set_location('standard_hours_worked', 15);

  IF v_day_no > 1 and v_day_no < 7 then

    v_total_hours := v_total_hours + v_wrkday_hours;
    hr_utility.set_location('standard_hours_worked v_total_hours = ', v_total_hours);
  END IF;
  v_curr_date := v_curr_date + 1;
  EXIT WHEN v_curr_date > p_range_end;
END LOOP;
--
         hr_utility.set_location('v_total_hours is', to_number(v_total_hours));
RETURN v_total_hours;
--
END standard_hours_worked;
--
-- **********************************************************************
--
FUNCTION Convert_Period_Type(
		p_bus_grp_id		in NUMBER,
		p_payroll_id		in NUMBER,
                p_assignment_action_id  in NUMBER,
                p_assignment_id  in NUMBER,
                p_element_entry_id  in NUMBER,
                p_date_earned  in DATE,
		p_asst_work_schedule	in VARCHAR2,
		p_asst_std_hours	in NUMBER ,
		p_figure		in NUMBER,
		p_from_freq		in VARCHAR2,
		p_to_freq		in VARCHAR2,
		p_period_start_date	in DATE ,
		p_period_end_date	in DATE ,
		p_asst_std_freq		in VARCHAR2 )
RETURN NUMBER IS

-- local vars

v_converted_figure		NUMBER(27,7);
v_from_annualizing_factor	NUMBER(30,7);  --Fix for bug 3650170
v_to_annualizing_factor		NUMBER(30,7);  --Fix for bug 3650170
--v_from_annualizing_factor	NUMBER(10);
--v_to_annualizing_factor       NUMBER(10);

-- local function

FUNCTION Get_Annualizing_Factor(p_bg			in NUMBER,
				p_payroll		in NUMBER,
				p_freq			in VARCHAR2,
				p_asg_work_sched	in VARCHAR2,
				p_asg_std_hrs		in NUMBER,
				p_asg_std_freq		in VARCHAR2)
RETURN NUMBER IS

-- local constants

c_weeks_per_year	NUMBER(3)	:= 52;
c_days_per_year	        NUMBER(3)	:= 200;
c_months_per_year	NUMBER(3)	:= 12;

-- local vars
/* 353434, 368242 : Fixed number width for total hours variables */
v_annualizing_factor	NUMBER(30,7);
v_periods_per_fiscal_yr	NUMBER(5);
v_hrs_per_wk		NUMBER(15,7);
v_hrs_per_range		NUMBER(15,7);
v_use_pay_basis	NUMBER(1)	:= 0;
v_pay_basis		VARCHAR2(80);
v_range_start		DATE;
v_range_end		DATE;
v_work_sched_name	VARCHAR2(80);
v_ws_id			NUMBER(9);
v_period_hours		BOOLEAN;

v_return_status              NUMBER;
v_return_message             VARCHAR2(500);
v_schedule_source          varchar2(100);
v_schedule                 varchar2(200);
v_total_hours	NUMBER(15,7) 	;
BEGIN -- Get_Annualizing_Factor

--
-- Check for use of salary admin (ie. pay basis) as frequency.
-- Selecting "count" because we want to continue processing even if
-- the from_freq is not a pay basis.
--

 --hr_utility.trace_on('Y', 'ORACLE');
 hr_utility.set_location('Get_Annualizing_Factor', 1);

 begin	-- Is Freq pay basis?

  --
  -- Decode pay basis and set v_annualizing_factor accordingly.
  -- PAY_BASIS "Meaning" is passed from FF !
  --

  hr_utility.set_location('Get_Annualizing_Factor', 13);

  SELECT	lookup_code
  INTO		v_pay_basis
  FROM		hr_lookups	 	lkp
  WHERE 	lkp.application_id	= 800
  AND		lkp.lookup_type		= 'PAY_BASIS'
  AND		lkp.lookup_code		= p_freq;

 v_pay_basis := p_freq;

         hr_utility.trace('v_pay_basis is'|| v_pay_basis);
  hr_utility.set_location('Get_Annualizing_Factor', 15);
  v_use_pay_basis := 1;

  IF v_pay_basis = 'MONTHLY' THEN

    hr_utility.set_location('Get_Annualizing_Factor', 17);
    v_annualizing_factor := 12;

  ELSIF v_pay_basis = 'HOURLY' THEN

      hr_utility.set_location('Get_Annualizing_Factor', 19);

      IF p_period_start_date IS NOT NULL THEN
        v_range_start 	:= p_period_start_date;
        v_range_end	:= p_period_end_date;
        v_period_hours	:= TRUE;
      ELSE
        v_range_start 	:= sysdate;
        v_range_end	:= sysdate + 6;
        v_period_hours 	:= FALSE;
      END IF;

/*      IF UPPER(p_asg_work_sched) <> 'NOT ENTERED' THEN

      -- Hourly employee using work schedule.
      -- Get work schedule name

--         v_ws_id := to_number(p_asg_work_sched);
         v_ws_id := fnd_number.canonical_to_number(p_asg_work_sched);

        SELECT	user_column_name
        INTO	v_work_sched_name
        FROM	pay_user_columns
        WHERE	user_column_id 			= v_ws_id
        AND	NVL(business_group_id, p_bg) 	= p_bg
  	AND     NVL(legislation_code,'CA') 	= 'CA';

         hr_utility.set_location('Get_Annualizing_Factor', 21);
*/

hr_utility.set_location('calling core udfs', 52);
         v_hrs_per_range := PAY_CORE_FF_UDFS.calculate_actual_hours_worked (
                                   p_assignment_action_id
                                  ,p_assignment_id
                                  ,p_bg
                                  ,p_element_entry_id
                                  ,p_date_earned
                                  ,p_period_start_date
                                  ,p_period_end_date
                                  ,NULL
                                  ,'Y'
                                  ,'BUSY'
                                  ,'CA'--p_legislation_code
                                  ,v_schedule_source
                                  ,v_schedule
                                  ,v_return_status
                                  ,v_return_message);

 /*     ELSE-- Hourly emp using Standard Hours on asg.

         hr_utility.set_location('Get_Annualizing_Factor', 23);


         v_hrs_per_range := Standard_Hours_Worked(	p_asg_std_hrs,
						v_range_start,
						v_range_end,
						p_asg_std_freq);

      END IF;

*/
      IF v_period_hours THEN

         select TPT.number_per_fiscal_year
          into    v_periods_per_fiscal_yr
          from   pay_payrolls_f  PPF,
                 per_time_period_types TPT,
                 fnd_sessions fs
         where  PPF.payroll_id = p_payroll
           and  fs.session_id = USERENV('SESSIONID')
           and  fs.effective_date between PPF.effective_start_date and PPF.effective_end_date
           and   TPT.period_type = PPF.period_type;

         v_annualizing_factor := v_hrs_per_range * v_periods_per_fiscal_yr;

      ELSE

         hr_utility.set_location('Get_Annualizing_Factor', 230000);
         v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;

      END IF;

  ELSIF v_pay_basis = 'PERIOD' THEN

    hr_utility.set_location('Get_Annualizing_Factor', 25);

    SELECT 	TPT.number_per_fiscal_year
    INTO	v_annualizing_factor
    FROM	pay_payrolls_f 			PRL,
 		    per_time_period_types   TPT,
            fnd_sessions fs
    WHERE	TPT.period_type 		= PRL.period_type
    and     fs.session_id = USERENV('SESSIONID')
    and     fs.effective_date BETWEEN PRL.effective_start_date
					      AND PRL.effective_end_date
    AND		PRL.payroll_id			= p_payroll
    AND		PRL.business_group_id + 0	= p_bg;

    hr_utility.set_location('Get_Annualizing_Factor', 27);

  ELSIF v_pay_basis = 'ANNUAL' THEN

    hr_utility.set_location('Get_Annualizing_Factor', 97);

    v_annualizing_factor := 1;

  ELSE

    -- Did not recognize "pay basis", return -999 as annualizing factor.
    -- Remember this for debugging when zeroes come out as results!!!

    hr_utility.set_location('Get_Annualizing_Factor', 99);

    v_annualizing_factor := 0;
    RETURN v_annualizing_factor;

  END IF;

 exception

  WHEN NO_DATA_FOUND THEN

    hr_utility.set_location('Get_Annualizing_Factor', 101);
    v_use_pay_basis := 0;

 end;

IF v_use_pay_basis = 0 THEN

  -- Not using pay basis as frequency...

  IF (p_freq IS NULL) 			OR
     (UPPER(p_freq) = 'PERIOD') 		OR
     (UPPER(p_freq) = 'NOT ENTERED') 	THEN

    -- Get "annuallizing factor" from period type of the payroll.

    hr_utility.set_location('Get_Annualizing_Factor', 20);

    SELECT 	TPT.number_per_fiscal_year
    INTO	v_annualizing_factor
    FROM	pay_payrolls_f 			PRL,
		    per_time_period_types 	TPT,
            fnd_sessions            fs
    WHERE	TPT.period_type 		= PRL.period_type
    and     fs.session_id = USERENV('SESSIONID')
    and     fs.effective_date BETWEEN PRL.effective_start_date
					      AND PRL.effective_end_date
    AND		PRL.payroll_id			= p_payroll
    AND		PRL.business_group_id + 0	= p_bg;

    hr_utility.set_location('Get_Annualizing_Factor', 22);

  ELSIF UPPER(p_freq) <> 'HOURLY' THEN

    -- Not hourly, an actual time period type!

   begin

    hr_utility.set_location('Get_Annualizing_Factor',24);

    SELECT	PT.number_per_fiscal_year
    INTO		v_annualizing_factor
    FROM	per_time_period_types 	PT
    WHERE	UPPER(PT.period_type) 	= UPPER(p_freq);

    /* changed for bug 5155854
       decode(UPPER(p_freq),'W','WEEK','M','MONTH','D','DAY','Y','YEAR','H','HOUR');
    */

    hr_utility.set_location('Get_Annualizing_Factor',26);

   exception when NO_DATA_FOUND then

     -- Added as part of SALLY CLEANUP.
     -- Could have been passed in an ASG_FREQ dbi which might have the values of
     -- 'Day' or 'Month' which do not map to a time period type.  So we'll do these by hand.

      hr_utility.set_location('Get_Annualizing_Factor',27);
      IF UPPER(p_freq) = 'DAY' THEN  /* changed D to DAY and M to Month for bug 5155854 */
        v_annualizing_factor := c_days_per_year;
      ELSIF UPPER(p_freq) = 'MONTH' THEN
        v_annualizing_factor := c_months_per_year;
      END IF;

    end;

  ELSE  -- Hourly employee...

     hr_utility.set_location('Get_Annualizing_Factor', 28);

     IF p_period_start_date IS NOT NULL THEN
        v_range_start 	:= p_period_start_date;
        v_range_end	:= p_period_end_date;
        v_period_hours	:= TRUE;
     ELSE
        v_range_start 	:= sysdate;
        v_range_end	:= sysdate + 6;
        v_period_hours 	:= FALSE;
     END IF;

/*     IF UPPER(p_asg_work_sched) <> 'NOT ENTERED' THEN

    -- Hourly emp using work schedule.
    -- Get work schedule name:

--        v_ws_id := to_number(p_asg_work_sched);
        v_ws_id := fnd_number.canonical_to_number(p_asg_work_sched);

        SELECT	user_column_name
        INTO	v_work_sched_name
        FROM	pay_user_columns
        WHERE	user_column_id 			= v_ws_id
        AND	NVL(business_group_id, p_bg) 	= p_bg
  	AND     NVL(legislation_code,'CA') 	= 'CA';

        hr_utility.set_location('Get_Annualizing_Factor',30);

hr_utility.set_location('calling core udfs', 53);
*/
         v_hrs_per_range := PAY_CORE_FF_UDFS.calculate_actual_hours_worked (
                                   p_assignment_action_id
                                  ,p_assignment_id
                                  ,p_bg
                                  ,p_element_entry_id
                                  ,p_date_earned
                                  ,p_period_start_date
                                  ,p_period_end_date
                                  ,NULL
                                  ,'Y'
                                  ,'BUSY'
                                  ,'CA'--p_legislation_code
                                  ,v_schedule_source
                                  ,v_schedule
                                  ,v_return_status
                                  ,v_return_message);

 /*    ELSE-- Hourly emp using Standard Hours on asg.

         hr_utility.set_location('Get_Annualizing_Factor', 23);


         v_hrs_per_range := Standard_Hours_Worked(	p_asg_std_hrs,
						v_range_start,
						v_range_end,
						p_asg_std_freq);

     END IF; */


      IF v_period_hours THEN

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

  END IF;

END IF;	-- (v_use_pay_basis = 0)

         hr_utility.set_location('v_annualizing_factor is', to_number(v_annualizing_factor));
RETURN v_annualizing_factor;

END Get_Annualizing_Factor;


BEGIN		 -- Convert Figure

  --hr_utility.trace_on('Y', 'ORACLE');
  hr_utility.set_location('Convert_Period_Type', 10);

  --
  -- If From_Freq and To_Freq are the same, then we're done.
  --

  IF NVL(p_from_freq, 'NOT ENTERED') = NVL(p_to_freq, 'NOT ENTERED') THEN

    RETURN p_figure;

  END IF;

         hr_utility.set_location('Mita a trace1 ',30000);

         hr_utility.trace('v_from_freq is'|| p_from_freq);
         hr_utility.trace('v_to_freq is'|| p_to_freq);

  v_from_annualizing_factor := Get_Annualizing_Factor(
			p_bg			=> p_bus_grp_id,
			p_payroll		=> p_payroll_id,
			p_freq			=> p_from_freq,
			p_asg_work_sched	=> p_asst_work_schedule,
			p_asg_std_hrs		=> p_asst_std_hours,
			p_asg_std_freq		=> p_asst_std_freq);

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

         hr_utility.set_location('v_from_annualizing_factor is', to_number(v_from_annualizing_factor));
         hr_utility.set_location('v_to_annualizing_factor is', to_number(v_to_annualizing_factor));
  hr_utility.set_location('Convert_Period_Type', 170);

  IF v_to_annualizing_factor = 0 	OR
     v_to_annualizing_factor = -999	OR
     v_from_annualizing_factor = -999	THEN

    hr_utility.set_location('Convert_Period_Type', 175);

    v_converted_figure := 0;
    RETURN v_converted_figure;

  ELSE

    hr_utility.set_location('Convert_Period_Type', 180);
/* hard coded values are for testing */

--    v_from_annualizing_factor  := 12;
--    v_to_annualizing_factor  := 1040;

    v_converted_figure := (p_figure * v_from_annualizing_factor) / v_to_annualizing_factor;

  END IF;

-- Done

RETURN v_converted_figure;

END Convert_Period_Type;

--
-- **********************************************************************
--
FUNCTION work_schedule_total_hours(
				p_bg_id		in NUMBER,
				p_ws_name	in VARCHAR2,
				p_range_start	in DATE ,
				p_range_end	in DATE )
RETURN NUMBER IS

-- local constants

c_ws_tab_name	VARCHAR2(80)	:= 'COMPANY WORK SCHEDULES';

-- local variables

/* 353434, 368242 : Fixed number width for total hours */
v_total_hours	NUMBER(15,7) 	:= 0;
v_range_start	DATE;
v_range_end	DATE;
v_curr_date	DATE;
v_curr_day	VARCHAR2(3);	-- 3 char abbrev for day of wk.
v_ws_name	VARCHAR2(80);	-- Work Schedule Name.
v_gtv_hours	VARCHAR2(80);	-- get_table_value returns varchar2
				-- Remember to TO_NUMBER result.
v_fnd_sess_row	VARCHAR2(1);
l_exists	VARCHAR2(1);
v_day_no        NUMBER;

BEGIN -- work_schedule_total_hours

-- Set range to a single week if no dates are entered:
-- IF (p_range_start IS NULL) AND (p_range_end IS NULL) THEN
--
  hr_utility.set_location('work_schedule_total_hours setting dates', 3);
  v_range_start := NVL(p_range_start, sysdate);
  v_range_end	:= NVL(p_range_end, sysdate + 6);
--
-- END IF;
-- Check for valid range
hr_utility.set_location('work_schedule_total_hours', 5);
IF v_range_start > v_range_end THEN
--
  hr_utility.set_location('work_schedule_total_hours', 7);
  RETURN v_total_hours;
--  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
--  hr_utility.raise_error;
--
END IF;
--
-- Get_Table_Value requires row in FND_SESSIONS.  We must insert this
-- record if one doe not already exist.
--
SELECT	DECODE(COUNT(session_id), 0, 'N', 'Y')
INTO	v_fnd_sess_row
FROM	fnd_sessions
WHERE	session_id	= userenv('sessionid');
--
IF v_fnd_sess_row = 'N' THEN
--
dt_fndate.set_effective_date (p_effective_date => sysdate);
--  INSERT INTO	fnd_sessions
--  SELECT 	userenv('sessionid'),
--		sysdate
--  FROM		sys.dual;
--
END IF;
--
hr_utility.set_location('work_schedule_total_hours', 10);
-- Track range dates:
hr_utility.set_location('range start = '||to_char(v_range_start), 5);
hr_utility.set_location('range end = '||to_char(v_range_end), 6);
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
and    PUC.user_table_id = PUT.user_table_id
and    PUT.user_table_name = c_ws_tab_name
and    NVL(PUC.business_group_id, p_bg_id) 	= p_bg_id
and    NVL(PUC.legislation_code,'CA') 	= 'CA';

EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
END;

if l_exists = 'Y' then
   v_ws_name := p_ws_name;
else
   BEGIN
   select PUC.USER_COLUMN_NAME
   into   v_ws_name
   from   pay_user_tables PUT,
	 pay_user_columns PUC
   where  PUC.USER_COLUMN_ID = p_ws_name
   and    PUT.user_table_name = c_ws_tab_name
   and    PUC.user_table_id = PUT.user_table_id
   and    NVL(PUC.business_group_id, p_bg_id) 	= p_bg_id
   and    NVL(PUC.legislation_code,'CA') 		= 'CA';

   EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN v_total_hours;
   END;
end if;
--
v_curr_date := v_range_start;
--
hr_utility.set_location('work_schedule_total_hours curr_date = '||to_char(v_curr_date), 20);
--
LOOP
  v_day_no := TO_CHAR(v_curr_date, 'D');

  hr_utility.set_location('curr_day_no = '||to_char(v_day_no), 20);

  SELECT decode(v_day_no,1,'SUN',2,'MON',3,'TUE',
                               4,'WED',5,'THU',6,'FRI',7,'SAT')
  INTO v_curr_day
  FROM DUAL;

--
  hr_utility.set_location('curr_day = '||v_curr_day, 20);

--
  hr_utility.set_location('work_schedule_total_hours.gettabval', 25);
  v_total_hours := v_total_hours +
       fnd_number.canonical_to_number(hruserdt.get_table_value(p_bg_id,
			c_ws_tab_name,
			v_ws_name,
                        v_curr_day));
  v_curr_date := v_curr_date + 1;
--
  hr_utility.set_location('curr_date = '||to_char(v_curr_date), 20);
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
  SELECT 	DECODE(COUNT(0), 0, 'N', 'Y')
  INTO		v_ele_exists
  FROM		PAY_ELEMENT_ENTRIES_F	ELE,
		PAY_ELEMENT_LINKS_F	ELI,
		PAY_ELEMENT_TYPES_F	ELT
  WHERE		p_date_earned
			 BETWEEN ELE.effective_start_date
                         AND ELE.effective_end_date
  AND		ELE.assignment_id			= p_asst_id
  AND		ELE.element_link_id 			= ELI.element_link_id
  AND		ELI.business_group_id + 0		= p_bg_id
  AND		ELI.element_type_id			= ELT.element_type_id
  AND		NVL(ELT.business_group_id, p_bg_id)	= p_bg_id
  AND		UPPER(ELT.element_name)			= UPPER(p_ele_name);

  RETURN v_ele_exists;

END chained_element_exists;

--
-- **********************************************************************
--

FUNCTION us_jurisdiction_val (p_jurisdiction_code in VARCHAR2)
  RETURN VARCHAR2 IS

v_valid_jurisdiction	VARCHAR2(1)	:= 'E'; -- RETURN var.

BEGIN

hr_utility.set_location('Jurisdiction_Validation', 01);

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
  AND           PRIMARY_FLAG    ='Y';

END IF;

RETURN v_valid_jurisdiction;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

    hr_utility.set_location('Jurisdiction_Validation', 03);
    v_valid_jurisdiction := 'E';
    RETURN v_valid_jurisdiction;

END us_jurisdiction_val;


--
-- **********************************************************************
--
FUNCTION get_process_run_flag (	p_date_earned	IN DATE,
				p_ele_type_id	IN NUMBER) RETURN VARCHAR2 IS
--
v_proc_run_type		VARCHAR2(3)	:= 'REG';
--
BEGIN
--
--
-- GET <ELE_NAME>_PROCESSING_RUN_TYPE.  IF = 'ALL' then SKIP='N'.
-- This DDF info is held in ELEMENT_INFORMATION3.
--
hr_utility.set_location('get_process_run_flag', 10);
--
begin
SELECT	element_information3
INTO	v_proc_run_type
FROM	pay_element_types_f
WHERE	p_date_earned
	BETWEEN effective_start_date
	    AND effective_end_date
AND	element_type_id = p_ele_type_id;
--
hr_utility.set_location('get_process_run_flag', 20);
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

v_skip_element		VARCHAR2(1)	:= 'N';
v_number_per_fy		NUMBER(3);
v_run_number		NUMBER(3);
v_proc_run_type		VARCHAR2(3);
v_freq_rule_exists	NUMBER(3);
v_period_end_date	DATE;

BEGIN

-- Check that <ELE_NAME>_PROCESSING_RUN_TYPE = 'ALL', meaning SKIP='N'.
-- This DDF info is held in ELEMENT_INFORMATION3.

hr_utility.set_location('check_dedn_freq', 10);

begin
SELECT	element_information3
INTO	v_proc_run_type
FROM	pay_element_types_f
WHERE	p_date_earned
	BETWEEN effective_start_date
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
hr_utility.set_location('check_dedn_freq', 45);
SELECT 	COUNT(0)
INTO	v_freq_rule_exists
FROM	pay_ele_payroll_freq_rules 	EPF
WHERE	element_type_id 		= p_ele_type_id
AND	payroll_id			= p_payroll_id
AND	business_group_id + 0		= p_bg_id;

IF v_freq_rule_exists = 0 THEN
  RETURN v_skip_element;
END IF;
--
-- If we're here, then maybe freq rule will affect processing...
-- Get payroll period type.number per fiscal year.
--
SELECT	end_date
INTO	v_period_end_date
FROM	per_time_periods
WHERE	p_date_earned BETWEEN start_date AND end_date
AND	payroll_id	= p_payroll_id;

SELECT	TPT.number_per_fiscal_year
INTO	v_number_per_fy
FROM 	per_time_period_types	TPT,
	pay_payrolls_f		PRL
WHERE	TPT.period_type		= PRL.period_type
AND	PRL.business_group_id + 0	= p_bg_id
AND	PRL.payroll_id		= p_payroll_id;
--
-- Get period number in Month or Year according to number per fiscal year.
-- ...into v_run_number...
-- What we NEED is the actual PERIOD # w/in Month or Year.
--
IF v_number_per_fy < 12 THEN
  hr_utility.set_location('check_dedn_freq', 20);

  SELECT 	COUNT(0)
  INTO		v_run_number
  FROM		per_time_periods	PTP
  WHERE		PTP.end_date
		BETWEEN	TRUNC(p_date_earned,'YEAR')
		AND	v_period_end_date
  AND		PTP.payroll_id	 		= p_payroll_id;

ELSIF v_number_per_fy > 12 THEN
  hr_utility.set_location('check_dedn_freq', 30);

  SELECT 	COUNT(0)
  INTO		v_run_number
  FROM		per_time_periods	PTP
  WHERE		PTP.end_date
		BETWEEN	TRUNC(p_date_earned,'MONTH')
		AND	v_period_end_date
  AND		PTP.payroll_id	 		= p_payroll_id;

ELSIF v_number_per_fy = 12 THEN
  hr_utility.set_location('check_dedn_freq', 40);
  v_skip_element := 'N';
  RETURN v_skip_element;
END IF;

--
-- Check frequency rule:
-- If none exists, then process!
--

hr_utility.set_location('check_dedn_freq', 50);
SELECT	'N'
INTO		v_skip_element
FROM		pay_ele_payroll_freq_rules 	EPF,
		pay_freq_rule_periods		FRP
WHERE		FRP.period_no_in_reset_period	= v_run_number
AND		FRP.ele_payroll_freq_rule_id	= EPF.ele_payroll_freq_rule_id
AND		EPF.business_group_id + 0	= p_bg_id
AND		EPF.payroll_id 			= p_payroll_id
AND		EPF.element_type_id		= p_ele_type_id;

RETURN v_skip_element;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('check_dedn_freq', 60);
    v_skip_element	:= 'Y';
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

-- This function is called from skip rules attached to Deductions.
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
v_skip_element		VARCHAR2(1) 	:= 'N';

--
BEGIN		 -- Separate_Check_Skip
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
AND    	p_date_earned
		BETWEEN IPV.effective_start_date
                AND IPV.effective_end_date
AND	UPPER(IPV.name)			= 'DEDUCTION PROCESSING'
AND	IPV.business_group_id + 0	= p_bg_id;

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
AND	p_date_earned
	  BETWEEN ELT.effective_start_date
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
sepcheck_flag		VARCHAR2(1)	:= 'N';
--

BEGIN

hr_utility.set_location('Other_Non_Separate_Check', 10);

SELECT	DECODE(COUNT(IPV.input_value_id), 0, 'N', 'Y')
INTO	sepcheck_flag
FROM	pay_element_entry_values_f	EEV,
	pay_element_entries_f		ELE,
	pay_input_values_f		IPV
WHERE	ELE.assignment_id		= p_ass_id
AND     p_date_earned
          BETWEEN ELE.effective_start_date AND ELE.effective_end_date
AND	ELE.element_entry_id 		= EEV.element_entry_id
AND	p_date_earned
	  BETWEEN EEV.effective_start_date AND EEV.effective_end_date
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
AND     p_date_earned BETWEEN
             ELE.effective_start_date and ELE.effective_end_date
AND     ELE.element_link_id 		= ELL.element_link_id
AND     p_date_earned BETWEEN
             ELL.effective_start_date and ELL.effective_end_date
AND	ELL.element_type_id 		= ELT.element_type_id
AND     p_date_earned BETWEEN
             ELT.effective_start_date and ELT.effective_end_date
AND     ECL.classification_id           = ELT.classification_id
AND     UPPER(ECL.classification_name)  IN (    'EARNINGS',
                                                'SUPPLEMENTAL EARNINGS',
                                                'IMPUTED EARNINGS',
                                                'NON-PAYROLL PAYMENTS')
AND     NOT EXISTS
       (SELECT 'X'
	FROM   pay_input_values_f              IPV
	WHERE  IPV.element_type_id = ELT.element_type_id
        AND    p_date_earned BETWEEN
                 IPV.effective_start_date and IPV.effective_end_date
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
				p_work_sched		in VARCHAR2 ,
				p_std_hours		in NUMBER ,
				p_ass_salary		in NUMBER,
				p_ass_sal_basis	in VARCHAR2,
				p_std_freq		in VARCHAR2 )
RETURN NUMBER IS
--
-- local constants
--
c_ot_scale		VARCHAR2(80)	:= 'Hourly';
c_rate_table_name	VARCHAR2(80)	:= 'WAGE RATES';
c_rate_table_column	VARCHAR2(80)	:= 'Wage Rate';
--
-- local vars
--
v_entry_id		NUMBER(9);
v_ot_base_rate		NUMBER(27,7)	:= 0;
v_tew_rate		NUMBER(27,7)	:= 0;
v_regwage_rate		NUMBER(27,7)	:= 0;
v_regsal_rate		NUMBER(27,7)	:= 0;
v_regsal_mosal		NUMBER(27,7)	:= 0;
v_tew_rcode		VARCHAR2(80);
v_regwage_rcode		VARCHAR2(80);
v_use_regwage		NUMBER(2);
v_use_regsal		NUMBER(2);
v_ele_type_id		NUMBER(9);
v_ele_class_id		NUMBER(9);
v_include_in_ot		VARCHAR2(1);
v_equiv_hrly_rate	VARCHAR2(80)	:= 'No OT';
v_chk_sal		VARCHAR2(1)	:= 'N';
v_eletype_id		NUMBER(9);
v_ele_name		VARCHAR2(80);
v_ff_name		VARCHAR2(80);
v_flat_amount		NUMBER(27,7)	:= 0;
v_flat_total		NUMBER(27,7)	:= 0;
v_flat_count		NUMBER(3)	:= 0;
v_percentage		NUMBER(27,7)	:= 0;
v_pct_sal		NUMBER(27,7)	:= 0;
v_pct_total		NUMBER(27,7)	:= 0;
v_pct_count		NUMBER(3)	:= 0;
v_rate			NUMBER(27,7)	:= 0;
v_rate_total		NUMBER(27,7)	:= 0;
v_rate_count		NUMBER(3)	:= 0;
v_rate_rcode		VARCHAR2(80);
v_rate_multiple		NUMBER(27,7)	:= 0;
v_rate_mult_count	NUMBER(3)	:= 0;
v_gross_results		NUMBER(3)	:= 0;
v_gross_amount		NUMBER(27,7)	:= 0;
v_gross_total		NUMBER(27,7)	:= 0;
v_gross_count		NUMBER(3)	:= 0;
v_tew_count		NUMBER(3)	:= 0;
v_tew_total_rate	NUMBER(27,7)	:= 0;
v_pay_basis_rate	NUMBER(27,7)	:= 0;
v_work_sched_name	VARCHAR2(80);
v_ws_id			NUMBER(9);
v_range_start		DATE;
v_range_end		DATE;

--
--
--
    CURSOR cur_element_type_id(p_element_name varchar2) IS
    SELECT element_type_id
    FROM   pay_element_types_f
    WHERE  element_name = p_element_name
    AND    legislation_code = 'CA';

    l_reg_sal_ele_id      pay_element_types_f.element_type_id%TYPE;
    l_reg_wages_ele_id    pay_element_types_f.element_type_id%TYPE;
    l_time_entry_ele_id   pay_element_types_f.element_type_id%TYPE;

--
-- local cursors
--
CURSOR	get_tew_rate IS
SELECT	NVL(fnd_number.canonical_to_number(EEV.screen_entry_value), 0),
	EEV.element_entry_id
FROM	pay_element_entry_values_f	EEV,
	pay_element_entries_f		ELE,
	pay_input_values_f		IPV
WHERE	ELE.assignment_id		= p_ass_id
AND	ELE.element_entry_id		= EEV.element_entry_id
AND	p_date_earned
		BETWEEN EEV.effective_start_date
	    AND EEV.effective_end_date
AND	EEV.input_value_id 		= IPV.input_value_id
AND	IPV.element_type_id             = l_time_entry_ele_id
AND	UPPER(IPV.name)			= 'RATE';
--
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
AND	p_date_earned
		BETWEEN	SPR.effective_start_date
	    AND	SPR.effective_end_date
AND	SPR.assignment_status_type_id	IS NULL
AND	SPR.element_type_id		= ELT.element_type_id
AND	p_date_earned
		BETWEEN	ELE.effective_start_date
		    AND	ELE.effective_end_date
AND	ELE.assignment_id		= p_ass_id
AND	ELE.element_link_id		= ELI.element_link_id
AND	p_date_earned
		BETWEEN	ELI.effective_start_date
		    AND	ELI.effective_end_date
AND	ELI.element_type_id		= ELT.element_type_id
AND	p_date_earned
		BETWEEN	ELT.effective_start_date
		    AND	ELT.effective_end_date
AND	ELT.element_information8	= 'Y'
AND	ELT.element_information_category IN (	'CA_EARNINGS',
						'CA_SUPPLEMENTAL EARNINGS');
--
-- These cursors get ALL entries of a particular element type during
-- the period:
/* Cursors get_flat_amounts, get_rates and get_percentage have been changed
to improve performance.
*/
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
    SELECT	RRV.result_value
    FROM	pay_run_result_values	RRV,
		pay_run_results		RRS,
		pay_input_values_f	IPV,
		pay_element_types_f	ELT
    WHERE	RRV.input_value_id		= IPV.input_value_id
    AND		RRV.run_result_id		= RRS.run_result_id
    AND		RRS.element_type_id		= ELT.element_type_id
    AND		RRS.assignment_action_id	= p_ass_action_id
    AND 	p_date_earned
			BETWEEN IPV.effective_start_date
		    AND IPV.effective_end_date
    AND		IPV.name			= 'Pay Value'
    AND		IPV.element_type_id		= ELT.element_type_id
    AND 	p_date_earned
			BETWEEN ELT.effective_start_date
			    AND ELT.effective_end_date
    AND		ELT.element_name 	= 'Vertex ' || v_ele_name || ' Gross';
    --
    -- Check with Roy on "<ELE_NAME> Gross" element being created for grossups.
    --
--
--
--
BEGIN		 -- OT_Base_Rate
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

OPEN cur_element_type_id('Regular Salary');
FETCH cur_element_type_id
INTO l_reg_sal_ele_id;
CLOSE cur_element_type_id;

OPEN cur_element_type_id('Regular Wages');
FETCH cur_element_type_id
INTO l_reg_wages_ele_id;
CLOSE cur_element_type_id;

OPEN cur_element_type_id('Times Entry Wages');
FETCH cur_element_type_id
INTO l_time_entry_ele_id;
CLOSE cur_element_type_id;

v_pay_basis_rate := fnd_number.canonical_to_number(hr_ca_ff_udfs.convert_period_type(
				p_bus_grp_id		=> p_bg_id,
				p_payroll_id		=> p_pay_id,
                p_assignment_action_id => p_ass_action_id,
                p_assignment_id => p_ass_id ,
                p_element_entry_id => v_entry_id,
                p_date_earned => p_date_earned,
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
    SELECT	NVL(EEV.screen_entry_value, 'NOT ENTERED')
    INTO		v_tew_rcode
    FROM	pay_element_entry_values_f	EEV,
		pay_element_entries_f		ELE,
		pay_element_types_f		ELT,
		pay_input_values_f		IPV
    WHERE	ELE.assignment_id		= p_ass_id
    AND		ELE.element_entry_id		= EEV.element_entry_id
    AND		p_date_earned
			BETWEEN EEV.effective_start_date
			    AND EEV.effective_end_date
    AND		EEV.element_entry_id		= v_entry_id
    AND		EEV.input_value_id 		= IPV.input_value_id
    AND		UPPER(ELT.element_name)		= 'TIME ENTRY WAGES'
    AND		ELT.element_type_id		= IPV.element_type_id
    AND		UPPER(IPV.name)			= 'RATE CODE';
    --
    IF v_tew_rcode = 'NOT ENTERED' THEN
    -- Use pay basis salary converted to hourly rate.
      v_tew_total_rate := v_tew_total_rate + v_pay_basis_rate;
    ELSE
    -- Find rate from rate table.
      hr_utility.set_location('OT_Base_Rate', 17);
      v_tew_total_rate := v_tew_total_rate +
				fnd_number.canonical_to_number(hruserdt.get_table_value(
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
  SELECT COUNT(IPV.input_value_id)
  INTO	v_use_regwage
  FROM	pay_element_entry_values_f	EEV,
	pay_element_entries_f		ELE,
	pay_input_values_f		IPV
  WHERE	ELE.assignment_id		= p_ass_id
  AND	ELE.element_entry_id		= EEV.element_entry_id
  AND	p_date_earned
		BETWEEN EEV.effective_start_date
		    AND EEV.effective_end_date
  AND	EEV.input_value_id 		= IPV.input_value_id
  AND	IPV.element_type_id             = l_reg_wages_ele_id
  AND	UPPER(IPV.name)			= 'RATE';
--
  IF v_use_regwage <> 0 THEN
    hr_utility.set_location('OT_Base_Rate', 30);
    SELECT 	NVL(fnd_number.canonical_to_number(EEV.screen_entry_value), 0),
	   	EEV.element_entry_id
    INTO	v_regwage_rate,
		v_entry_id
    FROM	pay_element_entry_values_f	EEV,
		pay_element_entries_f		ELE,
		pay_input_values_f		IPV
    WHERE	ELE.assignment_id		= p_ass_id
    AND		ELE.element_entry_id		= EEV.element_entry_id
    AND		p_date_earned
			BETWEEN EEV.effective_start_date
		    AND EEV.effective_end_date
    AND		EEV.input_value_id 		= IPV.input_value_id
    AND		IPV.element_type_id             = l_reg_wages_ele_id
    AND		UPPER(IPV.name)			= 'RATE';
--
    IF v_regwage_rate = 0 THEN
      hr_utility.set_location('OT_Base_Rate', 40);
      SELECT 	NVL(EEV.screen_entry_value, 'NOT ENTERED')
      INTO	v_regwage_rcode
      FROM	pay_element_entry_values_f	EEV,
 		pay_element_entries_f		ELE,
		pay_element_types_f		ELT,
		pay_input_values_f		IPV
      WHERE	ELE.assignment_id		= p_ass_id
      AND	ELE.element_entry_id		= EEV.element_entry_id
      AND	p_date_earned
			BETWEEN EEV.effective_start_date
			    AND EEV.effective_end_date
      AND	EEV.element_entry_id		= v_entry_id
      AND	EEV.input_value_id 		= IPV.input_value_id
      AND	UPPER(ELT.element_name)		= 'REGULAR WAGES'
      AND	ELT.element_type_id		= IPV.element_type_id
      AND	UPPER(IPV.name)			= 'RATE CODE';
    --
      hr_utility.set_location('OT_Base_Rate', 41);
      v_regwage_rate := fnd_number.canonical_to_number(hruserdt.get_table_value(
					p_bus_group_id	=> p_bg_id,
					p_table_name	=> c_rate_table_name,
					p_col_name	=> c_rate_table_column,
					p_row_value	=> v_regwage_rcode));
    END IF;
    v_ot_base_rate := v_ot_base_rate + v_regwage_rate;
--
  ELSE
    hr_utility.set_location('OT_Base_Rate', 50);
    SELECT 	COUNT(IPV.input_value_id)
    INTO	v_use_regsal
    FROM	pay_element_entry_values_f	EEV,
		pay_element_entries_f		ELE,
		pay_input_values_f		IPV
    WHERE	ELE.assignment_id		= p_ass_id
    AND		ELE.element_entry_id		= EEV.element_entry_id
    AND		p_date_earned
			BETWEEN EEV.effective_start_date
			    AND EEV.effective_end_date
    AND		EEV.input_value_id 		= IPV.input_value_id
    AND		IPV.element_type_id             = l_reg_sal_ele_id
    AND		UPPER(IPV.name)			= 'MONTHLY SALARY';
  --
    IF v_use_regsal <> 0 THEN
      hr_utility.set_location('OT_Base_Rate', 51);
      SELECT 	NVL(fnd_number.canonical_to_number(EEV.screen_entry_value), 0)
      INTO	v_regsal_mosal
      FROM	pay_element_entry_values_f	EEV,
		pay_element_entries_f		ELE,
		pay_input_values_f		IPV
      WHERE	ELE.assignment_id		= p_ass_id
      AND	ELE.element_entry_id		= EEV.element_entry_id
      AND	p_date_earned
			BETWEEN EEV.effective_start_date
			    AND EEV.effective_end_date
      AND	EEV.input_value_id 		= IPV.input_value_id
      AND	IPV.element_type_id             = l_reg_sal_ele_id
      AND	UPPER(IPV.name)			= 'MONTHLY SALARY';
  --
      hr_utility.set_location('OT_Base_Rate', 60);

      v_regsal_rate := hr_ca_ff_udfs.Convert_Period_Type(
				p_bus_grp_id		=> p_bg_id,
				p_payroll_id		=> p_pay_id,
                p_assignment_action_id => p_ass_action_id,
                p_assignment_id => p_ass_id ,
                p_element_entry_id => v_entry_id,
                p_date_earned => p_date_earned,
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

       v_flat_total := v_flat_total + hr_ca_ff_udfs.Convert_Period_Type(
				p_bus_grp_id		=> p_bg_id,
				p_payroll_id		=> p_pay_id,
                p_assignment_action_id => p_ass_action_id,
                p_assignment_id => p_ass_id ,
                p_element_entry_id => v_entry_id,
                p_date_earned => p_date_earned,
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
        AND	p_date_earned
			BETWEEN EEV.effective_start_date
			    AND EEV.effective_end_date
	AND	EEV.element_entry_id		= v_entry_id
        AND	EEV.input_value_id 		= IPV.input_value_id
        AND	UPPER(ELT.element_name)		= UPPER(v_ele_name)
        AND	ELT.element_type_id		= IPV.element_type_id
        AND	UPPER(IPV.name)			= 'RATE CODE';
        --
        IF v_rate_rcode <> 'NOT ENTERED' THEN
          hr_utility.set_location('OT_Base_Rate', 130);
	  v_rate := fnd_number.canonical_to_number(hruserdt.get_table_value(
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
        AND	p_date_earned
			BETWEEN EEV.effective_start_date
		    AND EEV.effective_end_date
	AND	EEV.element_entry_id		= v_entry_id
        AND	EEV.input_value_id 		= IPV.input_value_id
        AND	UPPER(ELT.element_name)		= UPPER(v_ele_name)
        AND	ELT.element_type_id		= IPV.element_type_id
        AND	UPPER(IPV.name)			= 'MULTIPLE';
        --
        IF v_rate_mult_count <> 0 THEN
          hr_utility.set_location('OT_Base_Rate', 140);
          SELECT	NVL(EEV.screen_entry_value, 0)
          INTO		v_rate_multiple
          FROM		pay_element_entry_values_f	EEV,
			pay_element_entries_f		ELE,
			pay_element_types_f		ELT,
			pay_input_values_f		IPV
          WHERE		ELE.assignment_id		= p_ass_id
          AND		ELE.element_entry_id		= EEV.element_entry_id
          AND		p_date_earned
				BETWEEN EEV.effective_start_date
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

        v_gross_total := v_gross_total + hr_ca_ff_udfs.Convert_Period_Type(
				p_bus_grp_id		=> p_bg_id,
				p_payroll_id		=> p_pay_id,
                p_assignment_action_id => p_ass_action_id,
                p_assignment_id => p_ass_id ,
                p_element_entry_id => v_entry_id,
                p_date_earned => p_date_earned,
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

This function computes the "Deduction Frequency Factor" for deductions
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
FUNCTION TEXT:
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
c_months_per_fy		NUMBER(2)	:= 12;
c_years_per_fy		NUMBER(1)	:= 1;
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
  AND		p_date_earned
		  BETWEEN PPF.effective_start_date
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
  AND	 p_date_earned
		BETWEEN	PPF.effective_start_date
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
		BETWEEN TRUNC(p_date_earned,'YEAR')
		AND	LAST_DAY(ADD_MONTHS(TRUNC(p_date_earned,'YEAR'), 11))
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
			p_partial_flag		IN VARCHAR2,
			p_net_asg_run		IN NUMBER,
			p_arrears_itd		IN NUMBER,
			p_guaranteed_net	IN NUMBER,
			p_dedn_amt		IN NUMBER,
			p_to_arrears		IN OUT NOCOPY NUMBER,
			p_not_taken		IN OUT NOCOPY NUMBER)
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

--
BEGIN
--
p_to_arrears := 0;
p_not_taken := 0;

hr_utility.set_location('hr_ca_ff_udfs.arrearage', 1);

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
  and	p_date_earned BETWEEN ipv.effective_start_date
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
--  hr_utility.set_location('pycaudfs.arrearage.to_arrears = ', p_to_arrears);
    hr_utility.set_location('pycaudfs.arrearage.dedn_amt = ', p_dedn_amt);
--  hr_utility.set_location('pycaudfs.arrearage.not_taken = ', p_not_taken);

  ELSIF p_net_asg_run <= p_guaranteed_net THEN
    -- Don't take anything, no arrears contr either.
    p_to_arrears := 0;
    p_not_taken := p_dedn_amt;
    l_dedn_amt := 0;
--  hr_utility.set_location('pycaudfs.arrearage.to_arrears = ', p_to_arrears);
    hr_utility.set_location('pycaudfs.arrearage.dedn_amt = ', l_dedn_amt);
--  hr_utility.set_location('pycaudfs.arrearage.not_taken = ', p_not_taken);

  ELSIF p_net_asg_run - p_dedn_amt < p_guaranteed_net THEN

    IF p_partial_flag = 'Y' THEN
      --
      p_to_arrears := 0;
      p_not_taken := p_dedn_amt - (p_net_asg_run - p_guaranteed_net);
      l_dedn_amt := p_net_asg_run - p_guaranteed_net;
--   hr_utility.set_location('pycaudfs.arrearage.to_arrears = ', p_to_arrears);
--   hr_utility.set_location('pycaudfs.arrearage.not_taken = ', p_not_taken);
      hr_utility.set_location('pycaudfs.arrearage.dedn_amt = ', l_dedn_amt);

    ELSE

      p_to_arrears := 0;
      p_not_taken := p_dedn_amt;
      l_dedn_amt := 0;
--   hr_utility.set_location('pycaudfs.arrearage.to_arrears = ', p_to_arrears);
--   hr_utility.set_location('pycaudfs.arrearage.not_taken = ', p_not_taken);
      hr_utility.set_location('pycaudfs.arrearage.dedn_amt = ', l_dedn_amt);

    END IF;

  END IF;

ELSE -- Arrearage is on, try and clear any balance currently in arrears.

  IF p_net_asg_run <= p_guaranteed_net THEN

    -- Don't take anything, put it all in arrears.
    p_to_arrears := p_dedn_amt;
    p_not_taken := p_dedn_amt;
    l_dedn_amt := 0;
--  hr_utility.set_location('pycaudfs.arrearage.to_arrears = ', p_to_arrears);
    hr_utility.set_location('pycaudfs.arrearage.dedn_amt = ', l_dedn_amt);
--  hr_utility.set_location('pycaudfs.arrearage.not_taken = ', p_not_taken);

  ELSE

    l_total_dedn := p_dedn_amt + p_arrears_itd;

    -- Attempt to clear any arrears bal:

    IF p_net_asg_run - p_guaranteed_net >= l_total_dedn THEN

      -- there's enough net to take it all, clear arrears:
      p_to_arrears := -1 * p_arrears_itd;
      l_dedn_amt := l_total_dedn;
      p_not_taken := 0;
--   hr_utility.set_location('pycaudfs.arrearage.to_arrears = ', p_to_arrears);
      hr_utility.set_location('pycaudfs.arrearage.dedn_amt = ', l_dedn_amt);
--   hr_utility.set_location('pycaudfs.arrearage.not_taken = ', p_not_taken);

/*  Deleted a load of code above to fix 504970.  If partial_flag = Y, then
    try and take as much of the total deduction amount (current dedn +
    arrears) and leave the rest in arrears.  */

    ELSIF p_partial_flag = 'Y' THEN

      -- Going into arrears, not enough Net to take curr p_dedn_amt
      --
      p_to_arrears := (l_total_dedn - (p_net_asg_run - p_guaranteed_net)) +
                      (-1 * p_arrears_itd);
      IF (p_net_asg_run - p_guaranteed_net) >= p_dedn_amt THEN
        p_not_taken := 0;
      ELSE
        p_not_taken := p_dedn_amt - (p_net_asg_run - p_guaranteed_net);
      END IF;
      l_dedn_amt := p_net_asg_run - p_guaranteed_net;
--   hr_utility.set_location('pycaudfs.arrearage.to_arrears = ', p_to_arrears);
      hr_utility.set_location('pycaudfs.arrearage.dedn_amt = ', l_dedn_amt);
--   hr_utility.set_location('pycaudfs.arrearage.not_taken = ', p_not_taken);

    ELSE -- p_partial_flag = 'N'
      IF (p_net_asg_run - p_guaranteed_net) >= p_dedn_amt THEN
        -- Take the whole deduction amount.
        l_dedn_amt := p_dedn_amt;
        p_to_arrears := 0;
        p_not_taken := 0;
      ELSE
        -- Don't take anything, partial dedn = 'N'
        p_to_arrears := p_dedn_amt;
        p_not_taken := p_dedn_amt;
        l_dedn_amt := 0;
      END IF;
--   hr_utility.set_location('pycaudfs.arrearage.to_arrears = ', p_to_arrears);
      hr_utility.set_location('pycaudfs.arrearage.dedn_amt = ', l_dedn_amt);
--   hr_utility.set_location('pycaudfs.arrearage.not_taken = ', p_not_taken);

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
--	  performance.  In the event city/zip are not supplied, this function
--        still works.
--
-- Optimization issues:
-- 1. In order to get the BEST performance possible, we need to add a "mode"
--    parameter in order to this function so that majority cases can be checked
--    in the optimal order.  The high volume users of this fn are MIX batch
--    val and the payroll run (VERTEX formulae).  Since we KNOW that MIX will
--    only provide State and City params, we can quickly check this and return
--    without going thru any of the gyrations needed for more general cases.
--    The validation required for the VERTEX formulae will be the "general"
--    case, tuned to succeed in the shortest possible time.
-- Resolution: Make all params mandatory, make the calling modules take care
-- of this requirement.
--
FUNCTION addr_val (     p_state_abbrev  IN VARCHAR2 ,
                        p_county_name   IN VARCHAR2 ,
                        p_city_name     IN VARCHAR2 ,
                        p_zip_code      IN VARCHAR2 )
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
   hr_utility.set_location('hr_ca_ff_udfs.addr_val', 20);
   l_geocode := '00-000-0000';
   RETURN l_geocode;
 --
END addr_val;   -- addr_val

FUNCTION addr_val (	p_state_abbrev	IN VARCHAR2 ,
			p_county_name	IN VARCHAR2 ,
			p_city_name	IN VARCHAR2 ,
			p_zip_code	IN VARCHAR2 ,
			p_skip_rule     IN VARCHAR2 )
RETURN VARCHAR2 IS
--
l_geocode		VARCHAR2(11); -- Output var in "12-345-6789" format.
l_state_code		VARCHAR2(2);
l_state_name		VARCHAR2(25);
l_county_code		VARCHAR2(3);
l_county_name		VARCHAR2(20);
l_city_code		VARCHAR2(4);
l_city_name		VARCHAR2(25);
l_zip_code		VARCHAR2(5);
--
BEGIN		-- Main addr_val
 l_zip_code	:= substr(p_zip_code, 1, 5);
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

  hr_utility.set_location('hr_ca_ff_udfs.addr_val', 1);

  SELECT	a.state_code||'-'||a.county_code||'-'||a.city_code
  INTO		l_geocode
  FROM		pay_us_zip_codes z,
		pay_us_city_names a
  WHERE		a.city_name		= INITCAP(p_city_name)
  AND
  		z.state_code	= a.state_code	AND
		z.county_code	= a.county_code	AND
		z.city_code	= a.city_code	AND
		l_zip_code BETWEEN z.zip_start AND z.zip_end;
  --
  EXCEPTION 	-- (2)
  --
    WHEN NO_DATA_FOUND THEN		-- Invalid city/zip combo
      hr_utility.set_location('hr_ca_ff_udfs.addr_val', 3);
      l_geocode := '00-000-0000';
      RETURN l_geocode;
    --
    WHEN TOO_MANY_ROWS THEN		-- city/zip does not uniquely defn geo
       -- same county name can exists in many states
       SELECT   state_code
       INTO     l_state_code
       FROM     pay_us_states
       WHERE    state_abbrev = p_state_abbrev;

      hr_utility.set_location('hr_ca_ff_udfs.addr_val', 5);
      SELECT	a.state_code||'-'||a.county_code||'-'||a.city_code
      INTO	l_geocode
      FROM	pay_us_zip_codes z,
		pay_us_city_names a,
		pay_us_counties	b
      WHERE	a.city_name		= INITCAP(p_city_name)
      AND	a.county_code		= b.county_code
      AND	b.county_name		= INITCAP(p_county_name)
      AND       b.state_code		= l_state_code
      AND	z.state_code	= a.state_code	AND
		z.county_code	= a.county_code	AND
		z.city_code	= a.city_code	AND
		l_zip_code BETWEEN z.zip_start AND z.zip_end;
  --
  end;		-- (2)
  --
 EXCEPTION	-- (1)
 --
 -- Fallout from (2) ie. county/city/zip combo invalid or does not
 -- uniquely define geocode.
 WHEN NO_DATA_FOUND THEN
   hr_utility.set_location('hr_ca_ff_udfs.addr_val', 7);
   l_geocode := '00-000-0000';
   RETURN l_geocode;
 --
 WHEN TOO_MANY_ROWS THEN
   hr_utility.set_location('hr_ca_ff_udfs.addr_val', 9);
   SELECT	a.state_code||'-'||a.county_code||'-'||a.city_code
   INTO		l_geocode
   FROM		pay_us_zip_codes z,
		pay_us_city_names a,
		pay_us_counties	b,
		pay_us_states	c
   WHERE	c.state_code 		= a.state_code	AND
   		c.state_abbrev		= UPPER(p_state_abbrev)
   AND
   		b.county_name		= INITCAP(p_county_name)AND
   		b.state_code		= c.state_code
   AND
   		a.city_name		= INITCAP(p_city_name)	AND
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
hr_utility.set_location('hr_ca_ff_udfs.addr_val', 11);
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
   hr_utility.set_location('hr_ca_ff_udfs.addr_val', 13);
   l_geocode := '00-000-0000';
   RETURN l_geocode;
 --
 WHEN TOO_MANY_ROWS THEN
   hr_utility.set_location('hr_ca_ff_udfs.addr_val', 15);
   l_geocode := '00-000-0000';
   RETURN l_geocode;
--
END addr_val;	-- Main addr_val
--

/*
Created for Bug 5097793.
1] Fetch the regular earnings in the current period based on the salary basis code.

*/
FUNCTION get_earnings_and_type( p_bus_grp_id		IN NUMBER,
                                p_asst_id               IN NUMBER,
                                p_assignment_action_id	IN NUMBER,
                                p_payroll_id		IN NUMBER,
                                p_ele_entry_id		IN NUMBER,
                                p_tax_unit_id		IN NUMBER,
                                p_date_earned		IN DATE,
                                p_pay_basis 		IN VARCHAR2	DEFAULT NULL,
				p_period_start          IN DATE,
                                p_period_end            IN DATE,
				p_element_type          IN OUT NOCOPY VARCHAR2,
				p_value                 IN OUT NOCOPY NUMBER,
                                p_input_value_name      IN OUT NOCOPY VARCHAR2)
RETURN NUMBER AS

CURSOR csr_reg_earnings(p_assignment_id NUMBER,
                        p_bus_grp_id    NUMBER,
			p_date_earned   DATE) IS
SELECT  peev.screen_entry_value
       ,piv.name
  FROM  pay_element_entry_values_f peev
       ,pay_element_entries_f      pee
       ,pay_element_links_f        pel
       ,pay_element_types_f        pet
       ,pay_input_values_f         piv
       ,per_pay_bases              ppb
       ,per_all_assignments_f      paa
WHERE   paa.assignment_id     =  p_assignment_id
  AND   paa.business_group_id =  p_bus_grp_id
  AND   p_date_earned BETWEEN paa.effective_start_date AND paa.effective_end_date
  AND   paa.pay_basis_id   = ppb.pay_basis_id
  AND   ppb.input_value_id = piv.input_value_id
  AND   p_date_earned BETWEEN piv.effective_start_date AND piv.effective_end_date
  AND   piv.element_type_id = pet.element_type_id
  AND   p_date_earned BETWEEN pet.effective_start_date AND pet.effective_end_date
  AND   pet.element_type_id  = pel.element_type_id
  AND   p_date_earned BETWEEN pel.effective_start_date AND pel.effective_end_date
  AND   pel.element_link_id  = pee.element_link_id
  AND   pee.assignment_id    = p_assignment_id
  AND   p_date_earned BETWEEN pee.effective_start_date AND pee.effective_end_date
  AND   pee.element_entry_id  = peev.element_entry_id
  AND   p_date_earned BETWEEN peev.effective_start_date AND peev.effective_end_date
  AND   pee.element_type_id  = pet.element_type_id
  AND   peev.input_value_id   = ppb.input_value_id;

l_value   NUMBER;
l_input_value_name  VARCHAR2(200);

BEGIN
hr_utility.set_location('in get_earnings_and_type',10);
hr_utility.set_location('p_bus_grp_id -> '|| p_bus_grp_id ,10);
hr_utility.set_location(' p_asst_id -> '|| p_asst_id ,10);
hr_utility.set_location(' p_assignment_action_id -> '|| p_assignment_action_id,10);
hr_utility.set_location(' p_date_earned -> '|| p_date_earned ,10);
hr_utility.set_location(' p_period_start -> '|| to_char(p_period_start) ,10);
hr_utility.set_location(' p_period_end -> '|| to_char(p_period_end),10);
hr_utility.set_location(' p_pay_basis -> '|| p_pay_basis,10);

   l_value := 0;

      OPEN csr_reg_earnings(p_asst_id, p_bus_grp_id, p_date_earned);
      FETCH csr_reg_earnings INTO l_value,l_input_value_name;
        IF csr_reg_earnings%NOTFOUND THEN
           p_value := 0;
	   p_element_type := 'DUMMY';
	   p_input_value_name := 'DUMMY';
	ELSE
           p_value := l_value;
           p_element_type := 'REGULAR_SALARY';
           p_input_value_name := l_input_value_name;
	END IF;
      CLOSE csr_reg_earnings;

	 hr_utility.set_location('returning p_value '|| p_value,10);
         hr_utility.set_location('returning p_element_type '|| p_element_type,10);
         hr_utility.set_location('returning p_input_value_name '|| p_input_value_name,10);

         RETURN 0;


END get_earnings_and_type;


END hr_ca_ff_udfs;

/
