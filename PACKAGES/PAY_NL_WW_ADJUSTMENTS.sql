--------------------------------------------------------
--  DDL for Package PAY_NL_WW_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_WW_ADJUSTMENTS" AUTHID CURRENT_USER AS
/* $Header: pynlsicp.pkh 120.1 2006/09/22 13:33:32 niljain noship $ */

--------------------------------------------------------------
-- Global PL/SQL table to hold SI Providers information
--------------------------------------------------------------

TYPE r_si_provider IS RECORD
		      (asg_act_id NUMBER,
		       si_type VARCHAR2(10),
		       si_provider_id NUMBER,
		       processed_flag VARCHAR2(10));

TYPE t_si_provider IS TABLE OF r_si_provider INDEX BY BINARY_INTEGER;
t1 t_si_provider;

last_asg_action_id NUMBER; /*Version 115.1 change */
--------------------------------------------------------------
-- Function for getting contribution percentages. Returns
-- SI Provider for next execution of Adjustment formula
--------------------------------------------------------------

FUNCTION Get_Adjustment_details
	(p_assignment_action_id IN NUMBER,
        p_date_earned IN DATE,
        p_source_text IN VARCHAR2,
        p_source_text2 IN VARCHAR2,
        p_age IN NUMBER,
        p_ee_cont_perc IN OUT NOCOPY NUMBER,
        p_er_cont_perc  IN OUT NOCOPY NUMBER,
        p_si_type_name OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

--------------------------------------------------------------
-- Procedure to Populate PL/SQL table
--------------------------------------------------------------

PROCEDURE populate_pl_sql_table
	(p_assignment_action_id IN NUMBER,
	 p_date_earned IN DATE,
	 p_si_type IN VARCHAR2,
	 p_si_provider IN VARCHAR2)  ;

--------------------------------------------------------------
--Function for getting Basis Calculation Rule
--------------------------------------------------------------
FUNCTION Get_Basis_calc_Rule
	( p_source_text IN VARCHAR2,
	  p_source_text2 IN VARCHAR2,
	  p_date_earned IN DATE)
RETURN NUMBER;

--------------------------------------------------------------
--Function for getting Whether EE cont. is Gross or Net
--------------------------------------------------------------
FUNCTION Get_EE_Cont_Gross_Net
	(p_source_text IN VARCHAR2 ,
	 p_source_text2 IN VARCHAR2,
	 p_date_earned IN DATE)
RETURN VARCHAR2;

--------------------------------------------------------------
--Function for getting number of processed SI Providers
--------------------------------------------------------------
FUNCTION get_si_prov_count
         (p_assignment_id IN NUMBER,
          p_assignment_action_id IN NUMBER)
RETURN NUMBER;

END;

/
