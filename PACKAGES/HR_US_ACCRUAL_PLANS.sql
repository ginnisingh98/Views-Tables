--------------------------------------------------------
--  DDL for Package HR_US_ACCRUAL_PLANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_ACCRUAL_PLANS" AUTHID CURRENT_USER as
/* $Header: pyusaccr.pkh 120.2 2006/07/31 07:34:24 risgupta noship $ */
/*
+======================================================================+
|                Copyright (c) 1994 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : hr_us_accrual_plans
    Filename	: pyusaccr.pkh
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    26-JAN-95	hparicha	40.0	G1565	Vacation/Sick correlation
						to Regular Pay - changes to
						Calc Period Earns.
						Also need separate fn to calc
						Vac/Sick Pay as well as a fn
						to check for entry of Vac/Sick
						Hours against an accrual plan.
    09-JUL-95	hparicha	40.1	282299	Determine when an asg is not
						yet eligible to take time
						against an accrual.
    26-Feb-02   Rmonge          115.2           Added dbdrv commands, and
                                                made the file gscc compliant.
    03-Sep-03   Rmonge          115.5           Remove NOCOPY from IN arguments
    Description: Functions and Procedures required for US implementation
		 of Accruals.
    20-Sep-05  ghshanka         115.6           bug 4123194 deleted the functions calc_accrual_pay and
                                                accrual_time_taken .
    31-AUG-06  risgupta         115.7  5405255 obsoleted functions being re-added on request of US payroll
*/



PROCEDURE get_accrual_ineligibility(	p_iv_id   IN  NUMBER,
				      	p_bg_id   IN  NUMBER,
					p_asg_id  IN  NUMBER,
					p_sess_date	IN  DATE,
					p_eligible   	OUT NOCOPY VARCHAR2);
FUNCTION calc_accrual_pay (	p_bg_id		IN  NUMBER,
				p_asg_id 	IN  NUMBER,
				p_eff_date	IN  DATE,
				p_hours_taken 	IN  NUMBER,
				p_curr_rate	IN  NUMBER,
				p_mode		IN  VARCHAR2) RETURN NUMBER;


FUNCTION accrual_time_taken (	p_bg_id		IN NUMBER,
				p_asg_id 	IN NUMBER,
				p_eff_date	IN DATE,
				p_mode		IN  VARCHAR2) RETURN NUMBER;


END hr_us_accrual_plans;

 

/
