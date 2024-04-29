--------------------------------------------------------
--  DDL for Package MSC_EXP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_EXP_WF" AUTHID CURRENT_USER AS
/*$Header: MSCEXWFS.pls 115.10 2004/04/27 06:23:20 pragarwa ship $ */

PROCEDURE launch_workflow(errbuf             OUT NOCOPY VARCHAR2,
		          retcode            OUT NOCOPY NUMBER,
                          p_plan_id 	     IN  NUMBER,
                          p_exception_id     IN  NUMBER DEFAULT NULL,
                          p_query_id         IN  NUMBER DEFAULT NULL);

PROCEDURE StartWFProcess ( item_type            in varchar2 default null,
		           item_key	        in varchar2,
                           l_exception_id       in number,
			   organization_id      in number,
			   instance_id          in number,
			   inventory_item_id    in number,
			   exception_type	in number,
			   organization_code    in varchar2,
			   item_segments        in varchar2,
                           item_description     in varchar2,
			   exception_type_text  in varchar2,
			   project_number       in varchar2,
			   to_project_number    in varchar2,
			   task_number	        in varchar2,
			   to_task_number       in varchar2,
			   planning_group       in varchar2,
		  	   due_date		in date,
			   from_date	        in date,
			   p_to_date	        in date,
			   days_compressed      in number,
			   quantity	        in varchar2,
			   lot_number	        in varchar2,
			   order_number	        in varchar2,
			   order_type_code	in number,
			   supply_type	        in varchar2,
			   end_item_segments	in varchar2,
                           end_item_description in varchar2,
			   end_order_number	in varchar2,
			   department_line_code in varchar2,
			   resource_code        in varchar2,
			   utilization_rate     in number,
			   supplier_id		in number,
			   supplier_name	in varchar2,
			   supplier_site_id     in number,
			   supplier_site_code   in varchar2,
			   customer_id		in number,
			   customer_name	in varchar2,
                           workbench_function   in varchar2,
			   workflow_process     in varchar2 default null,
			   planner_code	        in varchar2,
			   p_plan_id            in number,
			   db_link		in varchar2,
                           l_a2m_db_link        in varchar2,
                           transaction_id       in number,
                           qty_related_values   in number,
			   sup_project_id	in number,
			   sup_task_id	        in number);

PROCEDURE SelectPlanner( itemtype  in varchar2,
                         itemkey   in varchar2,
                         actid     in number,
                         funcmode  in varchar2,
                         resultout out NOCOPY varchar2 );

FUNCTION GetPlannerMsgName(p_exception_type in number,
			p_order_type     in number,
		  	p_stage  	 in number,
                        p_result         in varchar2)
RETURN varchar2;


PROCEDURE DetermineOrderType( itemtype  in varchar2,
		              itemkey   in varchar2,
		              actid     in number,
		              funcmode  in varchar2,
		              resultout out NOCOPY varchar2);

PROCEDURE Reschedule( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      resultout out NOCOPY varchar2);

PROCEDURE Reschedule_program(
                      errbuf OUT NOCOPY VARCHAR2,
                      retcode OUT NOCOPY NUMBER,
                      l_plan_id in number,
                      l_transaction_id in number,
                      l_exception_type in number);

PROCEDURE DeleteActivities( arg_plan_id in number);

FUNCTION SupplierCapacity(arg_plan_id in number,
                          arg_exception_id in number)
return number;

PROCEDURE IsCallback(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE SelectSrUsers(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE CheckBuyer(itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout out NOCOPY varchar2);

PROCEDURE StartSrWF(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2);

TYPE number_arr IS TABLE OF number;
TYPE SupplierToleranceRecord is RECORD(
  fence number_arr,
  tolerance  number_arr);

Procedure launch_background_program(p_planner in varchar2,
                                    p_item_type in varchar2,
                                    p_item_key in varchar2,
                                    p_request_id out NOCOPY number);

Procedure start_deferred_activity(
                           errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                           p_item_type varchar2,
                           p_item_key varchar2);

 FUNCTION demand_order_type (p_plan_id number,
                           p_inst_id number,
                           p_demand_id NUMBER) return number;

 FUNCTION demand_order_date (p_plan_id number,
                           p_inst_id number,
                           p_demand_id NUMBER) return date;

 FUNCTION substitute_supply_date (p_plan_id number,
                           p_inst_id number,
                           p_demand_id NUMBER) return date;

END msc_exp_wf;

 

/
