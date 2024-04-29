--------------------------------------------------------
--  DDL for Package MSC_X_WFNOTIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_WFNOTIFY_PKG" AUTHID CURRENT_USER AS
/*$Header: MSCXNFPS.pls 115.30 2004/04/15 21:47:34 yptang ship $ */

TYPE NUM_TBL_TYPE IS TABLE OF number;
TYPE number_arr 	IS TABLE OF NUMBER;
TYPE date_arr       	IS TABLE of DATE;
TYPE designatorList	IS TABLE OF	msc_sup_dem_entries.designator%TYPE;

PROCEDURE Launch_WF (p_errbuf OUT NOCOPY Varchar2,
                        p_retcode OUT NOCOPY Number);

PROCEDURE wfStart(p_wf_type IN Varchar2,
               p_wf_key IN Varchar2,
               p_wf_process IN Varchar2,
               p_user_performer IN Varchar2,
               p_user_name IN Varchar2,
               p_message_name IN Varchar2,
               p_exception_type In Number,
               p_exception_type_name IN Varchar2,
               p_item_id In Number,
               p_item_name IN Varchar2,
               p_item_description IN varchar2,
      p_company_id In Number,
            p_company_name IN Varchar2,
            p_company_site_id IN Number,
            p_company_site_name In varchar2,
            p_supplier_id IN Number,
            p_supplier_name IN Varchar2,
            p_supplier_site_id IN Number,
            p_supplier_site_name In varchar2,
            p_supplier_item_name In varchar2,
            p_customer_id IN Number,
               p_customer_name IN Varchar2,
               p_customer_site_id IN Number,
               p_customer_site_name In Varchar2,
      p_customer_item_name In varchar2,
               p_transaction_id1 IN Number,
               p_transaction_id2 IN Number,
               p_quantity  In Number,
               p_quantity1 IN Number,
               p_quantity2 IN Number,
               p_threshold IN Number,
               p_lead_time In Number,
               p_item_min_qty In Number,
               p_item_max_qty In Number,
               p_date1 IN Date,
               p_date2 IN Date,
               p_date3 IN Date,
               p_date4 IN Date,
               p_date5 IN Date,
               p_exception_basis IN Varchar2,
               p_order_creation_date1 IN Date,
               p_order_creation_date2 IN Date,
               p_order_number IN Varchar2,
               p_release_number IN Varchar2,
               p_line_number IN Varchar2,
               p_end_order_number IN Varchar2,
               p_end_order_rel_number IN Varchar2,
               p_end_order_line_number IN Varchar2);


FUNCTION getMessage(p_exception_code in Number) RETURN Varchar2;

PROCEDURE Launch_Publish_WF (p_errbuf 		OUT NOCOPY Varchar2,
                        p_retcode 		OUT NOCOPY Number,
                        p_designator 		IN Varchar2,
                        p_version  		In Number,
                        p_horizon_start 	IN date,
                        p_horizon_end 		IN date,
                        p_plan_id		IN Number,
                        p_sr_instance_id 	IN Number,
                        p_org_id		IN Number,
                        p_item_id		IN Number,
                  	p_supplier_id		IN Number,
                        p_supplier_site_id	IN Number,
                        p_customer_id		IN Number,
                        p_customer_site_id	IN Number,
  			p_planner_code          IN Varchar2,
  			p_abc_class             IN Varchar2,
  			p_planning_gp           IN Varchar2,
  			p_project_id            IN Number,
  			p_task_id               IN Number,
  			p_publish_program_type	IN Number);

END msc_x_wfnotify_pkg;

 

/
