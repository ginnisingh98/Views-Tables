--------------------------------------------------------
--  DDL for Package WSH_DLVB_COMMON_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DLVB_COMMON_ACTIONS" AUTHID CURRENT_USER as
/* $Header: WSHDDCMS.pls 120.0 2005/05/26 17:09:08 appldev noship $ */


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Assign_Details
   PARAMETERS : p_detail_tab - table of ids for assigning; could be delivery
		lines or containers
		p_parent_detail_id -  parent delivery detail id that details
		need to be assigned to
		p_delivery_id - delivery_id for assignment of details
		x_pack_status - status of container after assignment - whether
		underpacked, overpacked or success.
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and creates an assignment to a parent
		detail (container) and/or a delivery.  The API loops through
		all input ids and creates the assignment by calling the
		appropriate delivery detail or container API. This API serves
		as the wrapper API to handle a multi-selection of both lines
		and containers.

------------------------------------------------------------------------------
*/


PROCEDURE Assign_Details (
		p_detail_tab IN WSH_UTIL_CORE.id_tab_type,
		p_parent_detail_id IN NUMBER,
		p_delivery_id IN NUMBER,
                p_group_api_flag IN VARCHAR2 DEFAULT NULL,
		x_pack_status OUT NOCOPY  VARCHAR2,
		x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Unassign_Details
   PARAMETERS : p_detail_tab - table of ids for unassigning; could be delivery
		lines or containers
		p_parent_detail_flag -  'Y' or 'N' to indicate whether to
		unassign from parent delivery detail id
		p_delivery_flag - 'Y' or 'N' to indicate whether to unassign
		from delivery
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and unassigns the details from either
		containers or deliveries or both.  The API loops through
		all input ids and unassigns the details based on the two input
		flags. If the flags are set to 'Y' then the unassigning is
		done from that entity. If both the flags are set to 'N' then
		detail is unassigned from both the container and the delivery.
		The container and delivery weight volumes are re-calculated
		after the unassigning.

------------------------------------------------------------------------------
*/


PROCEDURE Unassign_Details (
		p_detail_tab IN WSH_UTIL_CORE.id_tab_type,
		p_parent_detail_flag IN VARCHAR2,
		p_delivery_flag IN VARCHAR2,
                p_group_api_flag IN VARCHAR2 DEFAULT NULL,
		x_return_status OUT NOCOPY  VARCHAR2,
        p_action_prms  IN wsh_glbl_var_strct_grp.dd_action_parameters_rec_type   -- J-IB-NPARIKH
       );


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Unassign_Details
   PARAMETERS : p_detail_tab - table of ids for unassigning; could be delivery
        lines or containers
        p_parent_detail_flag -  'Y' or 'N' to indicate whether to
        unassign from parent delivery detail id
        p_delivery_flag - 'Y' or 'N' to indicate whether to unassign
        from delivery
        x_return_status - return status of API
  DESCRIPTION : This procedure is for backward compatibility only. Do not use this.

------------------------------------------------------------------------------
*/


PROCEDURE Unassign_Details (
        p_detail_tab IN WSH_UTIL_CORE.id_tab_type,
        p_parent_detail_flag IN VARCHAR2,
        p_delivery_flag IN VARCHAR2,
                p_group_api_flag IN VARCHAR2 DEFAULT NULL,
        x_return_status OUT NOCOPY  VARCHAR2);

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Auto_Pack_Lines
   PARAMETERS :	p_group_id_tab - table of group ids if the grouping for the
		lines are already known.
		p_detail_tab - table of ids for assigning; could be delivery
		lines or containers
		p_pack_cont_flag - 'Y' or 'N' to determine whether to autopack
		detail containers into master containers while autopacking
		x_cont_inst_tab - table of delivery detail ids (containers)
		that were created due to the autopack.
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and eliminates all container ids and
		with the remaining delivery lines, it calls the auto pack API
		in the container actions package. This API serves as the
		wrapper API to handle a multi-selection of both lines and
		containers.

------------------------------------------------------------------------------
*/


PROCEDURE Auto_Pack_Lines (
		p_group_id_tab IN WSH_UTIL_CORE.id_tab_type,
		p_detail_tab IN WSH_UTIL_CORE.id_tab_type,
		p_pack_cont_flag IN VARCHAR2,
                p_group_api_flag IN VARCHAR2 DEFAULT NULL,
		x_cont_inst_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
		x_return_status OUT NOCOPY  VARCHAR2);



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Separate_Details
   PARAMETERS :	p_input_tab - table of ids in input; could be delivery
		lines or containers
		x_cont_inst_tab - table of delivery detail ids that are
		containers
		x_detail_tab - table of delivery_details that are lines.
		x_error_tab - table of any ids that are erroneous
		x_return_status - return status of API
		p_wms_filter_flag - Y = do not include records in WMS orgs.
				    N = include all records.
				    Default = N
				    Bug 1678527: disable packing actions
				 	for delivery details in WMS orgs.
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and separates all container ids and
		delivery lines. It returns three tables - one for containers,
		one for delivery lines and one for any erroroneous ids.

------------------------------------------------------------------------------
*/


PROCEDURE Separate_Details (
		p_input_tab IN WSH_UTIL_CORE.id_tab_type,
		x_cont_inst_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
		x_detail_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
		x_error_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
		x_return_status OUT NOCOPY  VARCHAR2,
		p_wms_filter_flag IN VARCHAR2 DEFAULT 'N');



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Calc_Cont_Avail
   PARAMETERS :	p_container_instance_id - delivery detail id of container
		x_avail_wt - available weight capacity of container
		x_avail_vol - available volume capacity of container
		x_wt_uom - weight uom code for above weights
		x_vol_uom - volume uom code for above volumes
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a container (delivery detail id)
		and returns the	available weight and volume capacity for the
		container.

------------------------------------------------------------------------------
*/


PROCEDURE Calc_Cont_Avail (
			p_container_instance_id IN NUMBER,
			x_avail_wt OUT NOCOPY  NUMBER,
			x_avail_vol OUT NOCOPY  NUMBER,
			x_wt_uom OUT NOCOPY  VARCHAR2,
			x_vol_uom OUT NOCOPY  VARCHAR2,
			x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Calc_Item_Total
   PARAMETERS :	p_delivery_detail_id - delivery detail id of line
		x_item_wt - weight of line
		x_item_vol - volume of line
		x_wt_uom - weight uom code for above weights
		x_vol_uom - volume uom code for above volumes
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a delivery detail id and
		returns the total item weight and volume for the line.

------------------------------------------------------------------------------
*/


PROCEDURE Calc_Item_Total (
			p_delivery_detail_id IN NUMBER,
			x_item_wt OUT NOCOPY  NUMBER,
			x_item_vol OUT NOCOPY  NUMBER,
			x_wt_uom OUT NOCOPY  VARCHAR2,
			x_vol_uom OUT NOCOPY  VARCHAR2,
			x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Calculate_Total_Capacities
   PARAMETERS :	p_detail_input_tab - table of ids in input; could be delivery
		lines or containers
		x_cont_wt_avail - total available weight capacity of all
		containers in the selection of input ids
		x_cont_vol_avail - total available volume capacity of all
		containers in the selection of input ids.
		x_item_wt_total - total weight of all lines in the input
		selection of ids.
		x_item_vol_total - total volume of all lines in the input
		selection of ids.
		x_wt_uom - weight uom code for above weights
		x_vol_uom - volume uom code for above volumes
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and separates all container ids and
		delivery lines. It returns the available container weight and
		volume capacities and total weight and volume of lines.

------------------------------------------------------------------------------
*/


PROCEDURE Calculate_Total_Capacities (
			p_detail_input_tab IN WSH_UTIL_CORE.id_tab_type,
			x_cont_wt_avail OUT NOCOPY  NUMBER,
			x_cont_vol_avail OUT NOCOPY  NUMBER,
			x_item_wt_total OUT NOCOPY  NUMBER,
			x_item_vol_total OUT NOCOPY  NUMBER,
			x_wt_uom OUT NOCOPY  VARCHAR2,
			x_vol_uom OUT NOCOPY  VARCHAR2,
			x_return_status OUT NOCOPY  VARCHAR2);



END WSH_DLVB_COMMON_ACTIONS;

 

/
