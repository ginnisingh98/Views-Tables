--------------------------------------------------------
--  DDL for Package MRP_EXP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_EXP_WF" AUTHID CURRENT_USER AS
/*$Header: MRPEXWFS.pls 115.8 2002/11/22 19:15:23 ichoudhu ship $ */

PROCEDURE launch_workflow(errbuf             OUT NOCOPY VARCHAR2,
			  retcode            OUT NOCOPY NUMBER,
			  p_owning_org_id    IN NUMBER,
                          p_designator       IN VARCHAR2);

PROCEDURE StartWFProcess ( item_type            in varchar2 default null,
		           item_key	        in varchar2,
			   compile_designator   in varchar2,
			   organization_id      in number,
			   inventory_item_id    in number,
			   exception_type	in number,
			   organization_code    in varchar2,
			   item_segments        in varchar2,
			   exception_type_text  in varchar2,
			   project_number       in varchar2,
			   to_project_number    in varchar2,
			   task_number	        in varchar2,
			   to_task_number       in varchar2,
			   planning_group       in varchar2,
		  	   due_date		in date,
			   from_date	        in date,
			   to_date	        in date,
			   days_compressed      in number,
			   quantity	        in varchar2,
			   lot_number	        in varchar2,
			   order_number	        in varchar2,
		           order_type_code	in number,
			   supply_type	        in varchar2,
			   end_item_segments    in varchar2,
			   end_order_number	in varchar2,
			   department_line_code in varchar2,
			   resource_code        in varchar2,
			   utilization_rate     in number,
			   supplier_id		in number,
			   supplier_name	in varchar2,
			   supplier_site_id	in number,
			   supplier_site_code   in varchar2,
			   customer_id		in number,
			   customer_name	in varchar2,
                           workbench_function   in varchar2,
			   workflow_process     in varchar2 default null);

PROCEDURE DetermineProceed( itemtype  in varchar2,
			    itemkey   in varchar2,
			    actid     in number,
			    funcmode  in varchar2,
			    resultout out NOCOPY varchar2 );


PROCEDURE SelectPlanner( itemtype  in varchar2,
			 itemkey   in varchar2,
			 actid     in number,
			 funcmode  in varchar2,
			 resultout out NOCOPY varchar2 );

PROCEDURE SelectBuyer( itemtype  in varchar2,
		       itemkey   in varchar2,
		       actid     in number,
		       funcmode  in varchar2,
		       resultout out NOCOPY varchar2);

PROCEDURE SelectSupplierCnt( itemtype  in varchar2,
		             itemkey   in varchar2,
		             actid     in number,
		             funcmode  in varchar2,
		             resultout out NOCOPY varchar2);

PROCEDURE SelectSalesRep(  itemtype  in varchar2,
		           itemkey   in varchar2,
		           actid     in number,
		           funcmode  in varchar2,
		           resultout out NOCOPY varchar2);

PROCEDURE SelectCustomerCnt( itemtype  in varchar2,
			     itemkey   in varchar2,
			     actid     in number,
			     funcmode  in varchar2,
			     resultout out NOCOPY varchar2);

PROCEDURE SelectTaskMgr( itemtype  in varchar2,
		         itemkey   in varchar2,
		         actid     in number,
		         funcmode  in varchar2,
		         resultout out NOCOPY varchar2);

FUNCTION GetMessageName(p_exception_type in number,
			p_order_type     in number,
		  	p_recipient	 in varchar2) RETURN varchar2;

PROCEDURE DetermineExceptionType( itemtype  in varchar2,
				  itemkey   in varchar2,
				  actid     in number,
				  funcmode  in varchar2,
			          resultout out NOCOPY varchar2);

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

PROCEDURE IsType19( itemtype  in varchar2,
		    itemkey   in varchar2,
		    actid     in number,
                    funcmode  in varchar2,
		    resultout out NOCOPY varchar2);

PROCEDURE DeleteActivities( arg_compile_desig   in varchar2,
			    arg_organization_id in number);

END mrp_exp_wf;

 

/
