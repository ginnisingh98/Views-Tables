--------------------------------------------------------
--  DDL for Package EAM_WORKORDER_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKORDER_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: EAMWOUTS.pls 120.7 2006/09/07 11:17:49 amourya noship $ */

TYPE t_bom_record IS RECORD (
  component_sequence_id NUMBER,
  component_item_id	NUMBER,
  component_item	VARCHAR2(80),
  description		VARCHAR2(240),
  component_quantity	NUMBER,
  component_yield	NUMBER,
  uom			VARCHAR2(3),
  wip_supply_type	NUMBER,
  wip_supply_type_disp	VARCHAR2(30)
);


TYPE t_component_record IS RECORD (
  component_item	VARCHAR2(81),
  component_item_id	NUMBER,
  start_effective_date	DATE,
  operation_sequence_number	NUMBER,
  quantity_per_assembly	NUMBER,
  wip_supply_type	NUMBER,
  supply_subinventory	VARCHAR2(30),
  supply_locator_id	NUMBER,
  supply_locator_name	VARCHAR2(81)
);


TYPE t_optime_record	IS RECORD (
  operation_seq_num	NUMBER,
  time_shift		NUMBER
);

TYPE t_workflow_record IS RECORD (
seq_no		  NUMBER,
approver	  VARCHAR2(360),
status		  VARCHAR2(50),
status_date	  DATE,
email		  VARCHAR2(240),
telephone	  VARCHAR2(60)
);


TYPE t_bom_table IS TABLE OF t_bom_record
  INDEX BY BINARY_INTEGER;
TYPE t_component_table IS TABLE OF t_component_record
  INDEX BY BINARY_INTEGER;
TYPE t_optime_table IS TABLE OF t_optime_record
  INDEX BY BINARY_INTEGER;
TYPE t_workflow_table IS TABLE OF t_workflow_record
  INDEX BY BINARY_INTEGER;


PROCEDURE retrieve_asset_bom(
		i_organization_id	IN 	NUMBER,
		i_asset_number		IN	VARCHAR2,
		i_asset_group_id	IN	NUMBER,
		p_context			IN VARCHAR2, -- stocked inventory or non-stocked inventory
 		o_bom_table		OUT NOCOPY	t_bom_table,
		o_error_code		OUT NOCOPY	NUMBER);


/* o_error_code:	0	success
			1	partial success(some comp exist)
			2 	failure
*/
PROCEDURE copy_to_bom(
		i_organization_id	IN	NUMBER,
		i_organization_code	IN	VARCHAR2,
		i_asset_number		IN	VARCHAR2,
		i_asset_group_id	IN	NUMBER,
		i_component_table	IN	t_component_table,
		o_error_code		OUT NOCOPY	NUMBER);


/* Adjust Times
   Different Level
*/
PROCEDURE adjust_resources(i_wip_entity_id	IN	NUMBER);

PROCEDURE adjust_operations(
		i_wip_entity_id		IN	NUMBER,
		i_operation_table	IN	t_optime_table);

PROCEDURE adjust_workorder(
		i_wip_entity_id		IN	NUMBER,
		i_shift			IN	NUMBER);


FUNCTION dependency_violated( i_wip_entity_id		IN	NUMBER)
	RETURN BOOLEAN;

/**
 * This function should be called when turning the status of a work order to
 * released or on-hold. It will make sure that there is only one such job for
 * a given asset number(rebuild item)/asset activity association.
 * For the parameter p_rebuild_flag, you should pass in 'Y' for rebuild job and
 * 'N' or NULL for normal work orders.
 * It returns: 0 -- ok
 *             1 -- there is already one such job so the user can't do it
 */
FUNCTION check_released_onhold_allowed(
             p_rebuild_flag    in varchar2,
             p_org_id          in number,
             p_item_id         in number,
             p_serial_number   in varchar2,
             p_activity_id     in number) RETURN NUMBER;

/**
  * For getting responsibility id
  *
  */
FUNCTION menu_has_function (
   		p_menu_id IN NUMBER,
		p_function_id IN NUMBER
	) RETURN NUMBER;

FUNCTION get_ip_resp_id (
		p_user_id IN NUMBER
	) RETURN NUMBER;

--Function to return Responsibility Id for Maint. Super User.
--This returns -1 if resp. is not assigned to current user
FUNCTION Get_Eam_Resp_Id
RETURN NUMBER;


FUNCTION Resource_Schedulable(X_Hour_UOM_Code VARCHAR2,
			        X_Unit_Of_Measure VARCHAR2) RETURN NUMBER ;


PROCEDURE UNRELEASE(x_org_id        IN NUMBER,
                    x_wip_id        IN NUMBER,
                    x_rep_id        IN NUMBER DEFAULT -1,
                    x_line_id       IN NUMBER DEFAULT -1,
                    x_ent_type      IN NUMBER);


procedure create_default_operation
  (  p_organization_id             IN    NUMBER
    ,p_wip_entity_id               IN    NUMBER
  );

/* bug no 3349197 */
PROCEDURE CK_MATERIAL_ALLOC_ON_HOLD(
	x_org_id        IN NUMBER,
        x_wip_id        IN NUMBER,
        x_rep_id        IN NUMBER,
        x_line_id       IN NUMBER,
        x_ent_type      IN NUMBER,
	x_return_status OUT NOCOPY   VARCHAR2
);

--Fix for 3360801.Added the following procedure to show the messages from the api
        /********************************************************************
        * Procedure     : show_mesg
        * Purpose       : Procedure will concatenate all the messages
	                  from the workorder api and return 1 string
        *********************************************************************/
	PROCEDURE show_mesg;

--Fix for 3360801.the following procedure will return a directory to get the log directory path
        PROCEDURE log_path(
	    x_output_dir   OUT NOCOPY VARCHAR2
	);

-- Fix for Bug 3489907
/*
*  Procedure    :- Check_open_txns
*  Purpose      :- For a given work order,it will return(l_return_status)
*                0 for No pending txns
*                1 for Open PO/requisitions
*                2 for Pending Material Txns
*                3 for Pending Operation Txns
*/
Procedure Check_open_txns(p_org_id        IN NUMBER,
                         p_wip_id        IN NUMBER,
                         p_ent_type      IN NUMBER,
			 p_return_status OUT NOCOPY NUMBER,
			 p_return_string OUT NOCOPY VARCHAR2 /* Added for bug#5335940 */);
/*
*  Procedure    :- Cancel
*  Specification:- For a given work order,it will show  error
*                  if there are some open po/reqs
*
*Note:- Unlike Unrelease process, there is no check on prior transactions
*       i.e. transactions already happened.
*/
PROCEDURE CANCEL(p_org_id        IN NUMBER,
                 p_wip_id        IN NUMBER,
		 x_return_status OUT NOCOPY NUMBER,
		 x_return_string OUT NOCOPY VARCHAR2 /* Added for bug#5335940 */);

/* Function to get rebuild description in eam_work_orders_v*/

FUNCTION get_rebuild_description( p_rebuild_item_id NUMBER, p_organization_id NUMBER)
                             return VARCHAR2;

PROCEDURE get_workflow_details( p_item_type	 IN STRING,
				p_item_key	 IN STRING,
				x_workflow_table OUT NOCOPY t_workflow_table);

PROCEDURE callCostEstimatorSS(
							p_api_version		IN	NUMBER		:= 1.0,
							p_init_msg_list		IN	VARCHAR2		:= FND_API.G_FALSE,
							p_commit			IN	VARCHAR2		:= FND_API.G_FALSE,
							p_validation_level	IN	NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
							p_wip_entity_id		IN	NUMBER,
							p_organization_id	IN	NUMBER,
							x_return_status		OUT NOCOPY VARCHAR2,
							x_msg_count		OUT NOCOPY NUMBER,
							x_msg_data		OUT NOCOPY VARCHAR2
						) ;
TYPE REPLACE_REBUILD_REC_TYPE IS RECORD
(
	p_instance_id	NUMBER := NULL
);
TYPE REPLACE_REBUILD_TBL_TYPE IS TABLE OF REPLACE_REBUILD_REC_TYPE INDEX BY BINARY_INTEGER;

PROCEDURE GET_REPLACED_REBUILDS(
		p_wip_entity_id   IN            NUMBER,
		p_organization_id IN            NUMBER,
		x_replaced_rebuild_tbl 		OUT NOCOPY REPLACE_REBUILD_TBL_TYPE,
		x_return_status			OUT NOCOPY VARCHAR2,
		x_error_message			OUT NOCOPY VARCHAR2
);


FUNCTION get_msu_resp_id( p_user_id IN NUMBER) RETURN NUMBER;


END EAM_WORKORDER_UTIL_PKG;

 

/
