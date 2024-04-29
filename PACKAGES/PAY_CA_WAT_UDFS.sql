--------------------------------------------------------
--  DDL for Package PAY_CA_WAT_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_WAT_UDFS" AUTHID CURRENT_USER AS
/* $Header: pycagudf.pkh 120.0 2005/05/29 03:33:51 appldev noship $ */
FUNCTION ca_garn_subpriority(	p_bus_grp_id		in NUMBER,
					p_assignment_id		in NUMBER,
					p_element_entry_id 	in NUMBER,
					p_earned_date		in DATE)
RETURN NUMBER;
--
FUNCTION ca_garn_bc_exempt(     p_bus_grp_id		in NUMBER,
					p_element_entry_id	in NUMBER,
					p_pay_periods_per_year	in NUMBER,
					p_protected_basis	in VARCHAR2,
					p_gross_di_subject	in NUMBER)
RETURN NUMBER;
--
END PAY_CA_WAT_UDFS;

 

/
