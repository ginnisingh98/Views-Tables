--------------------------------------------------------
--  DDL for Package PJI_COMPLETION_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_COMPLETION_GRAPH" AUTHID CURRENT_USER as
/*  $Header: PJIATCGS.pls 120.0 2005/05/29 12:20:11 appldev noship $  */

procedure get_bgt_ver_period(
			 p_budget_cost_plan_id IN Number default null,
			 p_budget_rev_plan_id IN Number default null,
			 p_forecast_cost_plan_id IN Number default null,
			 p_forecast_rev_plan_id IN Number default null,
                         p_project_id IN Number,
			 p_table_identifier Varchar,
			 p_calendar_id  IN Number default null);

procedure Bud_period_version_ins (p_ins_version_id      PA_PLSQL_DATATYPES.IdTabTyp,
                                  p_ins_name              PA_PLSQL_DATATYPES.Char30TabTyp,
				  p_ins_period_id        PA_PLSQL_DATATYPES.NumTabTyp,
                                  p_ins_start_date       PA_PLSQL_DATATYPES.DateTabTyp,
                                  p_ins_end_date         PA_PLSQL_DATATYPES.DateTabTyp,
                                  p_ins_cst_rev_flag    PA_PLSQL_DATATYPES.Char1TabTyp,
                                  p_ins_budget_forecast_flag  PA_PLSQL_DATATYPES.Char1TabTyp);

end PJI_COMPLETION_GRAPH;

 

/
