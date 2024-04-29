--------------------------------------------------------
--  DDL for Package PSP_MATRIX_DRIVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_MATRIX_DRIVER_PKG" AUTHID CURRENT_USER as
/* $Header: PSPLSMTS.pls 120.1.12000000.1 2007/01/18 12:24:14 appldev noship $ */

	procedure load_org_schedule(			p_return_status  	OUT NOCOPY	NUMBER,
							p_log_message		OUT NOCOPY	VARCHAR2,
		    			    		p_list_organization_id  IN 	VARCHAR2,
			 				p_period_from 		IN	VARCHAR2,
			 				p_period_to	       	IN	VARCHAR2,
			 				p_report_type		IN	VARCHAR2,
							p_business_group_id	IN	NUMBER,
						        p_set_of_books_id	IN	NUMBER
	            			);
	procedure load_table_schedule(  sch_id  		IN	NUMBER,
					p_business_group_id	IN	NUMBER,
					p_set_of_books_id	IN	NUMBER
	            			);
	procedure load_table(sch_id  number);
	procedure purge_table;
	procedure set_start_period(n NUMBER);
	procedure set_runid;
	procedure clear_table(event VARCHAR2);

	procedure load_organizations	(retcode		OUT NOCOPY NUMBER,
					p_organization_id	IN VARCHAR2,
					p_period_from		IN DATE,
					p_period_to		IN DATE,
					p_report_type		IN VARCHAR2,
					p_business_group_id	IN NUMBER,
					p_set_of_books_id	IN NUMBER);

--	FUNCTION check_exceedence       (p_payroll_id		IN  NUMBER) RETURN BOOLEAN; Commneted for Bug 4511249
	FUNCTION check_exceedence       (p_assignment_id	IN  NUMBER) RETURN BOOLEAN;
	FUNCTION get_max_periods RETURN NUMBER;
	FUNCTION get_start_period(n NUMBER) RETURN DATE;
	pragma RESTRICT_REFERENCES  ( get_start_period, WNDS, WNPS );
	FUNCTION get_end_period(n NUMBER) RETURN DATE;
	pragma RESTRICT_REFERENCES  ( get_end_period, WNDS, WNPS );
	FUNCTION get_run_id RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( get_run_id, WNDS, WNPS );
	FUNCTION get_dynamic_prompt(n NUMBER, s_id number) RETURN VARCHAR2;
	FUNCTION get_dynamic_totals(n NUMBER) RETURN NUMBER;
        FUNCTION check_exceedence_sc_copy RETURN BOOLEAN;
        PROCEDURE check_sch_hierarchy(p_assignment_id	 IN NUMBER,
            			     p_payroll_id	 IN NUMBER,
				     p_hierarchy_id	 OUT NOCOPY	NUMBER,
				     p_invalid_count     OUT NOCOPY	NUMBER);
end psp_matrix_driver_pkg;

 

/
