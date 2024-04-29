--------------------------------------------------------
--  DDL for Package PAY_MULTIASG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MULTIASG" AUTHID CURRENT_USER as
/* $Header: pycaearn.pkh 120.1 2007/01/07 17:28:47 ssouresr noship $ */
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Date           Name        	Vers    Bug No	Description
    ----           ----        	----	------	-----------
    12-MAR-2002    ssouresr     115.0           Created
*/
--
FUNCTION Multi_Asg_Proration_Regular (
			p_bus_grp_id		in NUMBER,
			p_asst_id		in NUMBER,
			p_payroll_id		in NUMBER,
			p_ele_entry_id		in NUMBER,
			p_tax_unit_id		in NUMBER,
			p_date_earned		in DATE,
			p_period_start 		in DATE,
			p_period_end 		in DATE,
                        p_run_type              in VARCHAR2)
RETURN NUMBER;
--
END pay_multiasg;

/
