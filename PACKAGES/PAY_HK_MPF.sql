--------------------------------------------------------
--  DDL for Package PAY_HK_MPF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_MPF" AUTHID CURRENT_USER AS
/* $Header: pyhkudfs.pkh 120.0.12010000.1 2008/07/27 22:49:05 appldev ship $ */
FUNCTION get_retro_mpf(p_bus_grp_id            in NUMBER,
		       p_assignment_id         in NUMBER,
		       p_date_from             in DATE,
		       p_date_to               in DATE,
		       p_pay_basis             in VARCHAR2,
		       p_percentage            in NUMBER,
		       p_calc_method           in VARCHAR2,
                       p_hire_date             in DATE,
                       p_min_birthday          in DATE,
                       p_ER_Liability_Start_Date in DATE,
                       p_EE_Deductions_Start_Date in DATE,
                       p_Contributions_End_Date in DATE)
RETURN NUMBER;
--
FUNCTION hk_scheme_val(p_bus_grp_id            in NUMBER,
		       p_assignment_id         in NUMBER,
		       p_entry_value           in VARCHAR2)
RETURN VARCHAR2;
--
FUNCTION hk_quarters_val(p_bus_grp_id            in NUMBER,
                         p_assignment_id         in NUMBER,
		         p_entry_value           in VARCHAR2)
RETURN VARCHAR2;
--
/* Bug:3333006. Added the following function */
FUNCTION get_act_termination_date
          (p_assignment_id in per_all_assignments_f.assignment_id%type,
           p_date in date)
RETURN DATE;
--
END pay_hk_mpf;

/
