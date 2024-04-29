--------------------------------------------------------
--  DDL for Package MRP_HORIZONTAL_PLAN_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_HORIZONTAL_PLAN_SC" AUTHID CURRENT_USER AS
/* $Header: MRPPHOPS.pls 115.1 2002/11/27 22:50:33 svaidyan ship $ */

/* 2663505 - Removed defaulting of arg_current_data, enterprize_view, arg_res_level according to PL/SQL stds. since we always pass these parameters */

PROCEDURE populate_horizontal_plan (item_list_id IN NUMBER,
			  arg_plan_id IN NUMBER,
			  arg_organization_id IN NUMBER,
			  arg_compile_designator IN VARCHAR2,
              arg_plan_organization_id IN NUMBER,
			  arg_bucket_type IN NUMBER,
			  arg_cutoff_date IN DATE,
			  arg_current_data IN NUMBER,
			  arg_ind_demand_type IN NUMBER DEFAULT NULL,
              arg_source_list_name IN VARCHAR2 DEFAULT NULL,
              enterprize_view IN BOOLEAN,
		      arg_res_level IN NUMBER,
			  arg_resval1 IN VARCHAR2 DEFAULT NULL,
			  arg_resval2 IN NUMBER DEFAULT NULL);

FUNCTION      compute_daily_rate_t
                    (var_calendar_code varchar2,
                     var_exception_set_id number,
                     var_daily_production_rate number,
                     var_quantity_completed number,
                     fucd date,
                     var_date date) return number  ;

    PRAGMA RESTRICT_REFERENCES (compute_daily_rate_t, WNDS,WNPS);

END MRP_HORIZONTAL_PLAN_SC;

 

/
