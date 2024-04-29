--------------------------------------------------------
--  DDL for Package PA_BILL_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILL_SCHEDULE" AUTHID CURRENT_USER AS
/*$Header: PAXBILAS.pls 120.1 2005/08/19 17:09:12 mwasowic noship $ */

-- Table type definitions to hold host array that will be passed from Pro *c
--

 PROCEDURE get_computed_bill_rate  (
	 p_array_size                       IN     NUMBER,
	 p_bill_rate_sch_id                 IN     pa_plsql_datatypes.IdTabTyp,
	 p_expenditure_item_id              IN     pa_plsql_datatypes.IdTabTyp,
	 p_exp_sys_linkage                  IN     pa_plsql_datatypes.Char30TabTyp,
 	 p_expenditure_type		    IN     pa_plsql_datatypes.Char30TabTyp,
	 p_expenditure_item_date	    IN     pa_plsql_datatypes.DateTabTyp,
	 p_fixed_date			    IN     pa_plsql_datatypes.DateTabTyp,
	 p_quantity                         IN     pa_plsql_datatypes.NumTabTyp,
	 p_incurred_by_person_id            IN     pa_plsql_datatypes.IdTabTyp,
	 p_non_labor_resource 	            IN     pa_plsql_datatypes.Char20TabTyp,
	 p_base_curr			    IN     pa_plsql_datatypes.Char15TabTyp,
	 p_base_amt			    IN     pa_plsql_datatypes.NumTabTyp,
	 p_exp_uom    	                    IN     pa_plsql_datatypes.Char30TabTyp,
	 p_compute_flag                     IN OUT  NOCOPY pa_plsql_datatypes.Char1TabTyp,
	 x_error_code                       IN OUT  NOCOPY pa_plsql_datatypes.Char30TabTyp,
	 x_reject_cnt		    	    OUT   NOCOPY number, --File.Sql.39 bug 4440895
	 x_computed_rate                    OUT     NOCOPY pa_plsql_datatypes.NumTabTyp,
	 x_computed_markup                  OUT    NOCOPY  pa_plsql_datatypes.NumTabTyp,
	 x_computed_currency	    	    OUT     NOCOPY pa_plsql_datatypes.Char15TabTyp,
	 x_computed_amount                  OUT     NOCOPY pa_plsql_datatypes.NumTabTyp,
         x_tp_job_id                        OUT     NOCOPY pa_plsql_datatypes.IdTabTyp,
	 x_error_stage                      OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
  );


END pa_bill_schedule;

 

/
