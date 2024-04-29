--------------------------------------------------------
--  DDL for Package HR_CA_FF_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CA_FF_UDFS" AUTHID CURRENT_USER as
/* $Header: pycaudfs.pkh 120.1.12000000.3 2007/02/20 01:20:21 ssouresr noship $ */
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Date           Name        	Vers    Bug No	Description
    ----           ----        	----	------	-----------
    05-MAY-1999    mmukherj     110.0           Created
                                                The file is Canadian
                                                version of pyusudfs.pkh
    14-FEB-2000    SSattineni   110.1           Changed the datatype
                                                of date_earned from
                                                varchar2 to date.
    19-SEP-2001    SSattineni   110.3           Changed the default values
                                                from 'NULL' to 'NOT ENTERED'
                                                for parameters
                                                P_ASST_WORK_SCHEDULE,
                                                P_FROM_FREQ, P_TO_FREQ
                                                to maintain consistency in
                                                pkg header and pkg body.
    10-Jan-2002    vpandya      115.4           Added dbdrv lines for gscc
    22-Jan-2003    vpandya      115.5           Added nocopy with out parameter
    28-OCT-2005    mmukherj     115.6           Added extra parameters in
                                                calculate_period_earnings
                                                and convert_period_type
    21-NOV-2006    saikrish     115.7   5097793 Added get_earnings_and_type

--- See below for old history --

 The History for pyusudfs is below
    Name        : chained_element_exists
    Filename	: pychaind.sql
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    16-NOV-93   hparicha  	1.0             Created
    07-JAN-94	jmychale	40.7	G491	Removed actual hours worked
						param from Calculate_Period_
						Earnings.
    13-JAN-94	hparicha	40.8	G497	Reverted to version 40.6
						NEED actual hours worked for
						Statement of Earnings report.
    02-FEB-94	hparicha	40.9	G542	Added Dedn_Freq_Factor.
    06-JUN-94	hparicha	40.10	G815	Added Arrearage function.
    15-JUL-94	hparicha	40.2	G907	Beta I freeze (new version
						numbers b/c now in UK arcs)
    26-OCT-94	hparicha	40.3	G1342	Included as part of this STU
						bug.  Added "addr_val" for
						use by VERTEX formulae and
						"get_geocode".
    04-JAN-95	hparicha	40.4	G1565	Vacation/Sick correlation
						to Regular Pay - changes to
						Calc Period Earns.
   40.5 ???
   40.6 ???
   40.7 ???

   12-JUL-96	hparicha	40.8	366215	Removed consumed_entry fn
                                                because package body too
                                                large...moved into
                                                pay_consumed_entry pckg
					        pyconsum.pkh, pkb.
--
   08-Dec-97	kmundair      40.9(110.1)  509120 overloaded addr_val function.
*/
--
FUNCTION Calculate_Period_Earnings (
			p_bus_grp_id		in NUMBER,
			p_asst_id		in NUMBER,
			p_assignment_action_id	in NUMBER,
			p_payroll_id		in NUMBER,
			p_ele_entry_id		in NUMBER,
			p_tax_unit_id		in NUMBER,
			p_date_earned		in DATE,
			p_pay_basis 		in VARCHAR2	default NULL,
			p_inpval_name		in VARCHAR2	default NULL,
			p_ass_hrly_figure	in NUMBER,
			p_period_start 		in DATE,
			p_period_end 		in DATE,
			p_work_schedule		in VARCHAR2	default NULL,
			p_asst_std_hrs		in NUMBER	default NULL,
			p_actual_hours_worked	in out nocopy NUMBER,
			p_prorate 		in VARCHAR2	default 'Y',
			p_asst_std_freq		in VARCHAR2	default NULL)
RETURN NUMBER;
--
FUNCTION standard_hours_worked(
				p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER;
--
FUNCTION Convert_Period_Type(
			p_bus_grp_id		in NUMBER,
			p_payroll_id		in NUMBER,
                p_assignment_action_id  in NUMBER,
                p_assignment_id  in NUMBER,
                p_element_entry_id  in NUMBER,
                p_date_earned  in DATE,
			p_asst_work_schedule	in VARCHAR2 default 'NOT ENTERED',
			p_asst_std_hours	in NUMBER default NULL,
			p_figure		in NUMBER,
			p_from_freq		in VARCHAR2 default 'NOT ENTERED',
			p_to_freq		in VARCHAR2 default 'NOT ENTERED',
			p_period_start_date	in DATE default NULL,
			p_period_end_date	in DATE default NULL,
			p_asst_std_freq		in VARCHAR2 default NULL)
RETURN NUMBER;
--
FUNCTION work_schedule_total_hours(
			p_bg_id		in NUMBER,
			p_ws_name	in VARCHAR2,
			p_range_start	in DATE default NULL,
			p_range_end	in DATE default NULL) RETURN NUMBER;
--
FUNCTION chained_element_exists(p_bg_id		in NUMBER,
				p_asst_id	in NUMBER,
				p_payroll_id	in NUMBER,
				p_date_earned	in DATE,
				p_ele_name	IN VARCHAR2) RETURN VARCHAR2;
--
FUNCTION us_jurisdiction_val (p_jurisdiction_code in VARCHAR2) RETURN VARCHAR2;
--
FUNCTION get_process_run_flag (	p_date_earned	IN DATE,
				p_ele_type_id	IN NUMBER) RETURN VARCHAR2;
--
FUNCTION check_dedn_freq (	p_payroll_id	IN NUMBER,
				p_bg_id		IN NUMBER,
				p_pay_action_id	IN NUMBER,
				p_date_earned	IN DATE,
				p_ele_type_id	IN NUMBER) RETURN VARCHAR2;
--
FUNCTION Separate_Check_Skip (
		p_bg_id			in NUMBER,
		p_element_type_id	in NUMBER,
		p_assact_id		in NUMBER,
		p_payroll_id		in NUMBER,
		p_date_earned		in DATE) RETURN VARCHAR2;
--
FUNCTION Other_Non_Separate_Check (
		p_date_earned		IN DATE,
		p_ass_id		IN NUMBER) RETURN VARCHAR2;
--
FUNCTION OT_Base_Rate (	p_bg_id			in NUMBER,
			p_pay_id		in NUMBER,
			p_ass_id		in NUMBER,
			p_ass_action_id		in NUMBER,
		   	p_date_earned		in DATE,
			p_work_sched		in VARCHAR2 default NULL,
			p_std_hours		in NUMBER default NULL,
			p_ass_salary		in NUMBER,
			p_ass_sal_basis		in VARCHAR2,
			p_std_freq		in VARCHAR2 default NULL)
RETURN NUMBER;
--
FUNCTION Dedn_Freq_Factor (
			p_payroll_id		in NUMBER,
		   	p_element_type_id	in NUMBER,
			p_date_earned		in DATE,
			p_ele_period_type	in VARCHAR2	default NULL)
RETURN NUMBER;
--
FUNCTION Arrearage (	p_eletype_id		IN NUMBER,
			p_date_earned		IN DATE,
			p_partial_flag		IN VARCHAR2 DEFAULT 'N',
			p_net_asg_run		IN NUMBER,
			p_arrears_itd		IN NUMBER,
			p_guaranteed_net	IN NUMBER,
			p_dedn_amt		IN NUMBER,
			p_to_arrears		IN OUT NOCOPY NUMBER,
			p_not_taken		IN OUT NOCOPY NUMBER)
RETURN NUMBER;
--
FUNCTION addr_val (	p_state_abbrev	IN VARCHAR2 DEFAULT NULL,
			p_county_name	IN VARCHAR2 DEFAULT NULL,
			p_city_name	IN VARCHAR2 DEFAULT NULL,
			p_zip_code	IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
--
FUNCTION addr_val (	p_state_abbrev	IN VARCHAR2 DEFAULT NULL,
			p_county_name	IN VARCHAR2 DEFAULT NULL,
			p_city_name	IN VARCHAR2 DEFAULT NULL,
			p_zip_code	IN VARCHAR2 DEFAULT NULL,
			p_skip_rule     IN VARCHAR2 )
RETURN VARCHAR2;
--
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
RETURN NUMBER;
--
END hr_ca_ff_udfs;

 

/
