--------------------------------------------------------
--  DDL for Package MSC_HORIZONTAL_PLAN_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_HORIZONTAL_PLAN_SC" AUTHID CURRENT_USER AS
/* $Header: MSCPHOPS.pls 120.0 2005/05/25 17:43:57 appldev noship $ */
PROCEDURE populate_horizontal_plan (p_agg_hzp IN NUMBER,
                          item_list_id IN NUMBER,
			  arg_query_id IN NUMBER,
			  arg_plan_id IN NUMBER,
                          arg_plan_organization_id IN NUMBER,
                          arg_plan_instance_id IN NUMBER,
			  arg_bucket_type IN NUMBER,
			  arg_cutoff_date IN DATE,
			  arg_current_data IN NUMBER DEFAULT 2,
			  arg_ind_demand_type IN NUMBER DEFAULT NULL,
                          arg_source_list_name IN VARCHAR2 DEFAULT NULL,
                          enterprize_view IN BOOLEAN := FALSE,
		          arg_res_level IN NUMBER DEFAULT 1,
			  arg_resval1 IN VARCHAR2 DEFAULT NULL,
			  arg_resval2 IN NUMBER DEFAULT NULL,
                          arg_category_name IN VARCHAR2 DEFAULT NULL,
                          arg_ep_view_also IN BOOLEAN DEFAULT FALSE);

PROCEDURE query_list(p_agg_hzp IN NUMBER,
                p_query_id IN NUMBER,
		p_plan_id IN NUMBER,
                p_instance_id IN NUMBER,
		p_org_list IN VARCHAR2,
                p_pf IN NUMBER,
 		p_item_list IN VARCHAR2,
                p_category_set IN NUMBER DEFAULT NULL,
                p_category_name IN VARCHAR2 DEFAULT NULL,
                p_display_pf_details IN BOOLEAN DEFAULT true);

PROCEDURE get_detail_records(p_node_type IN NUMBER,
		p_plan_id IN NUMBER,
                p_org_id IN NUMBER,
                p_inst_id IN NUMBER,
                p_item_id IN NUMBER,
                p_supplier_id IN NUMBER,
                p_supplier_site_id IN NUMBER,
                p_dept_id IN NUMBER,
                p_res_id IN NUMBER,
                p_start_date IN DATE,
                p_end_date IN DATE,
                p_rowtype IN NUMBER,
                p_item_query_id IN NUMBER,
                x_trans_list OUT NOCOPY VARCHAR2,
                x_error OUT NOCOPY NUMBER,
                x_err_message OUT NOCOPY VARCHAR2,
                p_plan_type IN NUMBER DEFAULT 2,
                p_consumed_row_filter   IN VARCHAR2 DEFAULT NULL,
                p_res_instance_id IN NUMBER DEFAULT 0,
                p_serial_number IN VARCHAR2 DEFAULT NULL);

FUNCTION      compute_daily_rate_t
                    (var_calendar_code varchar2,
                     var_exception_set_id number,
                     var_daily_production_rate number,
                     var_quantity_completed number,
                     fucd date,
                     var_date date) return number  ;

FUNCTION     update_ss
             (p_plan_id number,
              p_sr_instance_id number,
              p_organization_id number,
              p_item_id number,
              p_from_date date,
              p_to_date date,
              p_new_qty number ) return number ;


END MSC_HORIZONTAL_PLAN_SC;

 

/
