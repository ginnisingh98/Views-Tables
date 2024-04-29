--------------------------------------------------------
--  DDL for Package WSH_CONTAINER_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CONTAINER_ACTIONS" AUTHID CURRENT_USER as
/* $Header: WSHCMACS.pls 120.3.12000000.1 2007/01/16 05:42:46 appldev ship $ */


--lpn conv

/*
   procedure Create_Multiple_Cont_name will be deleted, once WMS
   provides functionality for container name generation.
*/
PROCEDURE Create_Multiple_Cont_name (
  p_cont_name IN VARCHAR2,
  p_cont_name_pre IN VARCHAR2,
  p_cont_name_suf IN VARCHAR2,
  p_cont_name_num IN NUMBER,
  p_cont_name_dig IN NUMBER,
  p_quantity IN NUMBER,
  x_cont_names OUT NOCOPY  WSH_GLBL_VAR_STRCT_GRP.v50_Tbl_Type,
  x_return_status OUT NOCOPY  VARCHAR2);


/* ------------------------------------------------------------------

   PROCEDURE   default_container_attr
   This procedure is called from Create_Cont_Instance_Multi to default the
   neccessary atributes for the container to be created.

   ------------------------------------------------------------------- */

   PROCEDURE default_container_attr (
        P_container_rec  IN  OUT NOCOPY
                              wsh_glbl_var_strct_grp.Delivery_Details_Rec_Type,
        p_additional_cont_attr IN wsh_glbl_var_strct_grp.LPNRecordType,
        p_caller               IN VARCHAR2,
        x_return_status OUT NOCOPY  VARCHAR2);

/*
-----------------------------------------------------------------------------
  RECORD TYPE  : line_cont_info
  DESCRIPTION  : This record type stores some of the delivery detail attributes
		 of the delivery details that need to be autopacked.  If a
		 number of lines are selected for autopack, the line attributes
		 are retrieved and stored in a table of line_cont_info records.
------------------------------------------------------------------------------
*/

  TYPE line_cont_info IS RECORD (
        group_id NUMBER,
        organization_id WSH_DELIVERY_DETAILS.organization_id%TYPE,
        fill_pc_basis WSH_SHIPPING_PARAMETERS.percent_fill_basis_flag%TYPE,
        process_flag VARCHAR2(1),
        inventory_item_id WSH_DELIVERY_DETAILS.inventory_item_id%TYPE,
        indivisible_flag MTL_SYSTEM_ITEMS.indivisible_flag%TYPE,
        delivery_detail_id WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE,
        shp_qty WSH_DELIVERY_DETAILS.shipped_quantity%TYPE,
        req_qty WSH_DELIVERY_DETAILS.requested_quantity%TYPE,
        shp_qty2 WSH_DELIVERY_DETAILS.shipped_quantity%TYPE,
        req_qty2 WSH_DELIVERY_DETAILS.requested_quantity%TYPE,
        req_qty_uom WSH_DELIVERY_DETAILS.requested_quantity_uom%TYPE,
        detail_cont_item_id WSH_DELIVERY_DETAILS.detail_container_item_id%TYPE,
        master_cont_item_id WSH_DELIVERY_DETAILS.master_container_item_id%TYPE,
        gross_weight  WSH_DELIVERY_DETAILS.gross_weight%TYPE,
        net_weight  WSH_DELIVERY_DETAILS.net_weight%TYPE,
        converted_wt WSH_DELIVERY_DETAILS.net_weight%TYPE,
        weight_uom  WSH_DELIVERY_DETAILS.weight_uom_code%TYPE,
        volume  WSH_DELIVERY_DETAILS.volume%TYPE,
        converted_vol WSH_DELIVERY_DETAILS.volume%TYPE,
        volume_uom  WSH_DELIVERY_DETAILS.volume_uom_code%TYPE,
        det_cont_qty WSH_DELIVERY_DETAILS.requested_quantity%TYPE,
        mast_max_load_qty WSH_CONTAINER_ITEMS.max_load_quantity%TYPE,
        source_line_id WSH_DELIVERY_DETAILS.source_line_id%TYPE,
        source_code WSH_DELIVERY_DETAILS.source_code%TYPE,
        preferred_container WSH_CONTAINER_ITEMS.container_item_id%TYPE,
        max_load_qty NUMBER,
        cont_wt WSH_DELIVERY_DETAILS.net_weight%TYPE,
        delivery_id wsh_delivery_assignments_v.DELIVERY_ID%TYPE, -- anxsharm
-- HW OPMCONV - Change variable name from opm_lot_ind to lot_divisible_flag
        lot_divisible_flag MTL_SYSTEM_ITEMS.lot_divisible_flag%TYPE,
        cont_vol WSH_DELIVERY_DETAILS.volume%TYPE);

  -- table of line_cont_info records that stores delivery line information
  -- of the lines that are selected for autopacking

  TYPE line_cont_info_tab IS TABLE OF line_cont_info INDEX BY BINARY_INTEGER;


 TYPE cont_inst_rec IS RECORD (
   cont_name        WSH_DELIVERY_DETAILS.container_name%TYPE,
   cont_instance_id NUMBER,
   delivery_detail_id NUMBER,
   delivery_assignment_id NUMBER, --added for WDA
   gross_weight     NUMBER,
   net_weight       NUMBER,
   volume           NUMBER,
   cont_fill_pc     NUMBER,
   row_id           VARCHAR2(20)
   );

  -- table of cont_info records that stores delivery line information
  -- of the containers that are created for autopacking

  TYPE cont_inst_tab IS TABLE OF cont_inst_rec INDEX BY BINARY_INTEGER;


/*
-----------------------------------------------------------------------------
  RECORD TYPE  : empty_cont_info
  DESCRIPTION  : This record type stores some of the container attributes
		 of the containers that remain partially empty during the
		 packing of a delivery detail line. If a container still has
		 some space remaining to be packed, the container item id,
		 container instance id and percent empty is stored in a
		 empty_cont_info record.
------------------------------------------------------------------------------
*/

  TYPE empty_cont_info IS RECORD (
       container_instance_id NUMBER,
       container_item_id     NUMBER);

  -- table of empty_cont_info records that stores all the containers that
  -- remain partially empty during autopacking of multiple lines.

  TYPE empty_cont_info_tab IS TABLE OF empty_cont_info INDEX BY BINARY_INTEGER;

  TYPE cont_info IS RECORD (
        group_id NUMBER,
        organization_id WSH_DELIVERY_DETAILS.organization_id%TYPE,
        fill_pc_basis WSH_SHIPPING_PARAMETERS.percent_fill_basis_flag%TYPE,
        inventory_item_id WSH_DELIVERY_DETAILS.inventory_item_id%TYPE,
        delivery_detail_id WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE,
        shp_qty WSH_DELIVERY_DETAILS.shipped_quantity%TYPE,
        req_qty WSH_DELIVERY_DETAILS.requested_quantity%TYPE,
        gross_weight  WSH_DELIVERY_DETAILS.net_weight%TYPE,
        converted_wt WSH_DELIVERY_DETAILS.net_weight%TYPE,
        weight_uom  WSH_DELIVERY_DETAILS.weight_uom_code%TYPE,
        volume  WSH_DELIVERY_DETAILS.volume%TYPE,
        converted_vol WSH_DELIVERY_DETAILS.volume%TYPE,
        volume_uom  WSH_DELIVERY_DETAILS.volume_uom_code%TYPE,
        preferred_container WSH_CONTAINER_ITEMS.container_item_id%TYPE,
        max_load_qty NUMBER,
        cont_wt WSH_DELIVERY_DETAILS.net_weight%TYPE,
        cont_vol WSH_DELIVERY_DETAILS.volume%TYPE);

  TYPE cont_info_tab IS TABLE OF cont_info INDEX BY BINARY_INTEGER;



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Container_Instance
   PARAMETERS : p_cont_name - name for the container
		p_cont_item_id - container item id (containers inv item id)
		x_cont_instance_id - delivery_detail_id for new container - if
		null then it will return a new id
		p_par_detail_id - the parent detail id (parent container)
		p_organization_id - organization id
		p_container_type_code - the container type code of container
		x_row_id - rowid of the new container record
		x_return_status - return status of API
  DESCRIPTION : This procedure creates a new container and defaults some of the
		container item attributes. The container item id of the
		container that is being created is required. If	the container
		name is not specified it defaults the name to be equal to the
		delivery detail id.
------------------------------------------------------------------------------
*/


PROCEDURE Create_Container_Instance (
  x_cont_name IN OUT NOCOPY  VARCHAR2,
  p_cont_item_id IN NUMBER,
  x_cont_instance_id IN OUT NOCOPY  NUMBER,
  p_par_detail_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_container_type_code IN VARCHAR2,
  x_row_id OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2);

-- anxsharm
-- This API has been called for
-- Creating Multiple Containers of single type
-- during Auto Pack

PROCEDURE Create_Cont_Instance_Multi (
  x_cont_name IN OUT NOCOPY  VARCHAR2,
  p_cont_item_id IN NUMBER,
  x_cont_instance_id IN OUT NOCOPY  NUMBER,
  p_par_detail_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_container_type_code IN VARCHAR2,
  p_num_of_containers IN NUMBER,
  x_row_id OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_cont_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  -- J: W/V Changes
  x_unit_weight OUT NOCOPY NUMBER,
  x_unit_volume OUT NOCOPY NUMBER,
  x_weight_uom_code OUT NOCOPY VARCHAR2,
  x_volume_uom_code OUT NOCOPY VARCHAR2,
  p_lpn_id          IN NUMBER DEFAULT NULL,
  p_ignore_for_planning IN VARCHAR2 DEFAULT 'N',
  p_caller            IN VARCHAR2 DEFAULT 'WSH'
  );


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Multiple_Containers
   PARAMETERS : p_cont_item_id - container item id (containers inv item id)
		p_organization_id - organization id
		p_container_type_code - the container type code of container
		p_cont_name - name for the container if qty is 1 (mainly used
				by public APIs)
		p_cont_name_pre - prefix for container name
		p_cont_name_suf - suffix for container name
		p_cont_name_num - starting number for number part of container
				  name
		p_cont_name_dig - number of digits to use for the number part
				  of the container name
		p_quantity - number of containers to create
		x_cont_instance_tab - table of delivery_detail_ids for new
				  containers - if null then it will return a
				  table with new ids
		x_return_status - return status of API
  DESCRIPTION : This procedure creates a new container and defaults some of the
		container item attributes. The container item id of the
		container that is being created is required. If	the container
		name is not specified it defaults the name to be equal to the
		delivery detail id.
------------------------------------------------------------------------------
*/


PROCEDURE Create_Multiple_Containers (
  p_cont_item_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_container_type_code IN VARCHAR2,
  p_cont_name IN VARCHAR2,
  p_cont_name_pre IN VARCHAR2,
  p_cont_name_suf IN VARCHAR2,
  p_cont_name_num IN NUMBER,
  p_cont_name_dig IN NUMBER,
  p_quantity IN NUMBER,
  x_cont_instance_tab IN OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Assign_Detail
   PARAMETERS : p_container_instance_id - container instance id of container
		p_del_detail_tab - table of delivery detail ids
		x_pack_status - status of container after packing the lines
			into it : underpacked or overpacked
		x_return_status - return status of API
  DESCRIPTION : This procedure assigns a number of lines to the specified
		container instance and returns a pack status of underpacked
		or overpacked or success.
------------------------------------------------------------------------------
*/



PROCEDURE Assign_Detail(
  p_container_instance_id IN NUMBER,
  p_del_detail_tab IN WSH_UTIL_CORE.id_tab_type,
  x_pack_status OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2,
  p_check_credit_holds IN BOOLEAN DEFAULT TRUE );


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Unassign_Detail
   PARAMETERS : p_container_instance_id - container instance id of container
		p_delivery_id - delivery id from which detail needs to be
		unassigned
		p_del_detail_tab - table of delivery detail ids
		p_cont_unassign - flag to determine whether to unassign from
		container or not.
		p_del_unassign - flag to determine whether to unassign from
		delivery or not
		x_pack_status - status of container after packing the lines
			into it : underpacked or overpacked
		x_return_status - return status of API
  DESCRIPTION : This procedure unassigns a number of lines from the specified
		container instance or delivery and returns a pack status of
		underpacked or overpacked or success. The unassigning is
		determined using the two unassign flags or by specific ids.
------------------------------------------------------------------------------
*/



PROCEDURE Unassign_Detail(
  p_container_instance_id IN NUMBER DEFAULT NULL,
  p_delivery_id IN NUMBER DEFAULT NULL,
  p_del_detail_tab IN WSH_UTIL_CORE.id_tab_type,
  p_cont_unassign IN VARCHAR2,
  p_del_unassign IN VARCHAR2,
  x_pack_status OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2,
  p_action_prms IN wsh_glbl_var_strct_grp.dd_action_parameters_rec_type
  );

  /*
  -----------------------------------------------------------------------------
     PROCEDURE  : Unassign_Detail
     PARAMETERS : p_container_instance_id - container instance id of container
        p_delivery_id - delivery id from which detail needs to be
        unassigned
        p_del_detail_tab - table of delivery detail ids
        p_cont_unassign - flag to determine whether to unassign from
        container or not.
        p_del_unassign - flag to determine whether to unassign from
        delivery or not
        x_pack_status - status of container after packing the lines
            into it : underpacked or overpacked
        x_return_status - return status of API
    DESCRIPTION : This procedure is for backward compatibility only. Do not use this.
  ------------------------------------------------------------------------------
*/

PROCEDURE Unassign_Detail(
  p_container_instance_id IN NUMBER DEFAULT NULL,
  p_delivery_id IN NUMBER DEFAULT NULL,
  p_del_detail_tab IN WSH_UTIL_CORE.id_tab_type,
  p_cont_unassign IN VARCHAR2,
  p_del_unassign IN VARCHAR2,
  x_pack_status OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2);
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Assign_To_Delivery
   PARAMETERS : p_container_instance_id - container instance id of container
		p_delivery_id - delivery id
		x_return_status - return status of API
  DESCRIPTION : This procedure checks to see if a container can be assigned to
		the specified delivery and returns a success or failure.
------------------------------------------------------------------------------
*/

PROCEDURE Assign_To_Delivery(
  p_container_instance_id IN NUMBER,
  p_delivery_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
 x_dlvy_has_lines          IN OUT NOCOPY VARCHAR2,    -- J-IB-NPARIKH
 x_dlvy_freight_terms_code IN OUT NOCOPY VARCHAR2     -- J-IB-NPARIKH
  );

-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------

PROCEDURE Assign_To_Delivery(
 p_container_instance_id IN NUMBER,
 p_delivery_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2
    ) ;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Delivery_Assignment
   PARAMETERS : p_container_instance_id - container instance id of container
		p_delivery_id - delivery id
		x_return_status - return status of API.
  DESCRIPTION : This procedure assigns a container to the specified delivery.
------------------------------------------------------------------------------
*/

PROCEDURE Create_Delivery_Assignment (
 p_container_instance_id IN NUMBER,
 p_delivery_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2,
 x_dlvy_has_lines          IN OUT NOCOPY VARCHAR2,    -- J-IB-NPARIKH
 x_dlvy_freight_terms_code IN OUT NOCOPY VARCHAR2     -- J-IB-NPARIKH
 );

-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------
PROCEDURE Create_Delivery_Assignment (
 p_container_instance_id IN NUMBER,
 p_delivery_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Unassign_Delivery
   PARAMETERS : p_container_instance_id - container instance id of container
		p_delivery_id - delivery id
		x_return_status - return status of API
  DESCRIPTION : This procedure checks unassigns a container from the specified
		delivery and returns a success or failure.
------------------------------------------------------------------------------
*/

PROCEDURE Unassign_Delivery(
  p_container_instance_id IN NUMBER,
  p_delivery_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Assign_To_Container
   PARAMETERS : p_det_cont_inst_id - container instance id of child container
		p_par_cont_inst_id - container instance id of parent container
		x_return_status - return status of API
  DESCRIPTION : This procedure checks to see if a container can be assigned to
		a specified parent container and returns a success or failure.
------------------------------------------------------------------------------
*/


PROCEDURE Assign_To_Container(
  p_det_cont_inst_id IN NUMBER,
  p_par_cont_inst_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Auto_Pack_Lines
   PARAMETERS : p_group_id_tab_id - table of group ids for lines that need to
			be autopacked.
		p_del_detail_tab - table of delivery detail ids
		p_pack_cont_flag - 'Y' or 'N' to determine whether to try and
			autopack the detail containers into master containers.
		x_cont_instance_tab - table of container instance ids that were
			created during the autopacking.
		x_return_status - return status of API.
  DESCRIPTION : This procedure takes the number of lines and groups them by
		common grouping attributes - similar to grouping attributes of
		delivery.  If a group id table is specified it uses the
		group ids in the table to decided which lines can be grouped
		into the same container. If a group id table is not specified,
		it creates the group id table before autopacking. It creates
		the required number and type of containers per line and keeps
		track of all partially filled containers in the empty
		containers table. Before creating new container instances, it
		searches for available space using the empty container table
		and after filling up a container, it creates a new one if
		there are no empty containers of the same type.
------------------------------------------------------------------------------
*/


PROCEDURE Auto_Pack_Lines (
  p_group_id_tab IN WSH_UTIL_CORE.id_tab_type,
  p_del_detail_tab IN WSH_UTIL_CORE.id_tab_type,
  p_pack_cont_flag IN VARCHAR2,
  x_cont_instance_tab IN OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Auto_Pack_Delivery
   PARAMETERS : p_delivery_tab - table of delivery ids that need to be
			autopacked.
		p_pack_cont_flag - 'Y' or 'N' to determine whether to try and
			autopack the detail containers into master containers.
		x_cont_instance_tab - table of container instance ids that were
			created during the autopacking.
		x_return_status - return status of API.
  DESCRIPTION : This procedure takes a table of deliveries that need to be
		autopacked and checks for all unpacked lines in each of the
		deliveries. After fetching all unpacked lines in each delivery,
		it calls the Auto_Pack_Lines with the table of unpacked lines.
		After autopacking the lines, it recalculates the weight and
		volume of the delivery.
------------------------------------------------------------------------------
*/


PROCEDURE Auto_Pack_Delivery (
  p_delivery_tab IN WSH_UTIL_CORE.id_tab_type,
  p_pack_cont_flag IN VARCHAR2,
  x_cont_instance_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Pack_Multi
   PARAMETERS : p_cont_tab - table of container instance ids that are being
		packed.
		p_del_detail_tab - table of unpacked delivery detail ids.
		p_pack_mode  - indicates whether containers are packed in
		equal/proportional mode ('E') or in full/sequential mode ('F')
		p_split_pc - the percentage by which each line is going to be
		split in the case of equal packing mode.
		x_pack_status - the packed status of containers after the multi
		pack is performed - indicates whether any underpacked or
		overpacked containers.
		x_return_status - return status of API.
  DESCRIPTION : This procedure takes the specified delivery detail ids and
		packs them into the selected containers in either the full mode
		or equal mode. In the full mode, it packs the first container
		fully before packing the next. In the equal mode, all lines
		are split equally between all the containers and packed
		equally between them.
------------------------------------------------------------------------------
*/


PROCEDURE Pack_Multi (
 p_cont_tab IN WSH_UTIL_CORE.id_tab_type,
 p_del_detail_tab IN WSH_UTIL_CORE.id_tab_type,
 p_pack_mode IN VARCHAR2,
 p_split_pc IN NUMBER,
 x_pack_status OUT NOCOPY  VARCHAR2,
 x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Shipped_Qty
   PARAMETERS : p_delivery_detail_id - delivery detail id of the original line
		that was split
		p_split_detail_id - delivery detail id of the newly created
		split line
		p_split_qty - quantity used to split original delivery line
		x_return_status - return status of API
  DESCRIPTION : This procedure updates the shipped quantities of the original
		delivery line that was split and the new line that was created
		due to the split.  The shipped quantity of the original line is
		decremented by split qty and that of the new line is increased
		to be equal to the split qty.  The updating is done only if the
		original shipped quantity is not null.
------------------------------------------------------------------------------
*/

PROCEDURE Update_Shipped_Qty(
  p_delivery_detail_id IN NUMBER,
  p_split_detail_id IN NUMBER,
  p_split_qty IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Auto_Pack_Conts
   PARAMETERS : p_group_id_tab_id - table of group ids for containers that need
		to be autopacked.
  		p_cont_info_tab - table of detail containers created during the
		autopack process consisting of container instances, master
		container item ids and percentage empty.
		p_cont_detail_tab - table of container delivery detail ids that
		were created during the autopacking of lines.
		x_cont_instance_id - table of container instance ids that were
			created during the autopacking.
		x_return_status - return status of API.
  DESCRIPTION : This procedure takes the number of containers and groups them
		by common grouping attributes - similar to grouping attributes
		of delivery.  If a group id table is specified it uses the
		group ids in the table to decided which container can be
		grouped	into the same parent container. If a group id table is
		not specified, it creates the group id table before autopacking
		It creates the required number and type of parent containers
		per detail container and keeps track of all partially filled
		containers in the empty containers table. Before creating new
		container instances, it	searches for available space using the
		empty container table and after filling up a container, it
		creates a new one if there are no empty containers of the same
		type. The difference between this API and the autopack lines is
		that this API does not split containers if they don't fit
		entirely into a parent container.
------------------------------------------------------------------------------
*/


PROCEDURE Auto_Pack_Conts (
  p_group_id_tab IN WSH_UTIL_CORE.id_tab_type,
  p_cont_info_tab IN wsh_container_actions.empty_cont_info_tab,
  p_cont_detail_tab IN WSH_UTIL_CORE.id_tab_type,
  x_cont_instance_tab IN OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Cont_Attributes
   PARAMETERS : p_delivery_detail_id - delivery detail id
		p_delivery_id - delivery id if container assigned to delivery
		p_container_instance_id - delivery detail id for the container
		x_return_status - return status of API
  DESCRIPTION : This procedure updates the grouping attribute columns of the
		container with the grouping attribute values derived from the
		delivery line that is input.
------------------------------------------------------------------------------
*/

PROCEDURE Update_Cont_Attributes (
 p_delivery_detail_id IN NUMBER,
 p_delivery_id IN NUMBER DEFAULT NULL,
 p_container_instance_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Check_Cont_Attributes
   PARAMETERS : p_container_instance_id - delivery detail id for the container
		x_attr_flag - 'Y' or 'N' to determine if any of the grouping
		attributes other than org id and ship from has been populated.
		x_return_status - return status of API
  DESCRIPTION : This procedure fetched the grouping attribute columns of the
		container and checks to see if the columns are null or if they
		are populated. If any of the values are not null, then the API
		returns a x_attr_flag of 'Y' else it returns a 'N'.
------------------------------------------------------------------------------
*/

PROCEDURE Check_Cont_Attributes (
 p_container_instance_id IN NUMBER,
 x_attr_flag OUT NOCOPY  VARCHAR2,
 x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Cont_Hierarchy
   PARAMETERS : p_delivery_detail_id - delivery detail id
		p_delivery_id - delivery id if container assigned to delivery
		p_container_instance_id - delivery detail id for the container
		x_return_status - return status of API
  DESCRIPTION : This procedure updates the grouping attribute columns of the
		the entire container hierarchy for the specified container
		with the grouping attribute values derived from the
		delivery line that is input.
------------------------------------------------------------------------------
*/

PROCEDURE Update_Cont_Hierarchy (
 p_del_detail_id IN NUMBER,
 p_delivery_id IN NUMBER DEFAULT NULL,
 p_container_instance_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Last_Assigned_Line
   PARAMETERS : p_delivery_detail_id - delivery detail id
		p_container_instance_id - delivery detail id for the container
		x_last_line_flag - 'Y' or 'N' depending on whether it is the
		last line in the container hierarchy or not.
		x_return_status - return status of API
  DESCRIPTION : This procedure checks to see if the delivery detail id is the
		last assigned line in the container hierarchy for the input
		container. If it is, x_last_line_flag is set to 'Y' else it is
		set to 'N'.
------------------------------------------------------------------------------
*/

PROCEDURE Last_Assigned_Line (
 p_del_detail_id IN NUMBER,
 p_container_instance_id IN NUMBER,
 x_last_line_flag OUT NOCOPY  VARCHAR2,
 x_return_status OUT NOCOPY  VARCHAR2);

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Delete_Containers
   PARAMETERS : p_container_id - container instance to be deleted.
		x_return_status - return status of API
  DESCRIPTION : This procedure takes in a table of container instances and
		deletes the containers.  If the containers are not empty or
		they are assigned to deliveries that are not open, they will
		not be deleted. Also, if the containers are either assigned to
		or container other containers packed into it, they will not be
		deleted.
------------------------------------------------------------------------------
*/


PROCEDURE Delete_Containers (
  p_container_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Container
   PARAMETERS : p_container_name - new container name that needs to be assigned
		to the existing container.
		p_container_instance_id - the delivery detail id for the
		container that needs to be updated.
		p_old_cont_name - exisiting container name for the container,
		to be used only if container instance id in the input parameter
		is null.
		x_return_status - return status of API
  DESCRIPTION : This procedure takes in a new container name and existing
		container information like the delivery detail id and existing
		container name that needs to be updated. The API checks to see
		if the container that is being updated is assigned to a closed,
		confirmed or in-transit delivery. If it is, no update is
		allowed - if not, only the container name can be updated.
------------------------------------------------------------------------------
*/


PROCEDURE Update_Container (
  p_container_name IN VARCHAR2,
  p_container_instance_id IN NUMBER,
  p_old_cont_name IN VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2);


PROCEDURE unpack_inbound_delivery
            (
               p_delivery_id        IN          NUMBER,
               x_return_status      OUT NOCOPY  VARCHAR2
            ) ;

PROCEDURE pack_inbound_lines
            (
               p_lines_tbl          IN          WSH_UTIL_CORE.id_tab_type,
               p_lpn_id             IN          NUMBER,
               p_lpn_name           IN        VARCHAR2,
               p_delivery_id        IN          NUMBER,
               p_transactionType    IN          VARCHAR2 DEFAULT 'ASN',
               x_return_status      OUT NOCOPY  VARCHAR2,
	       p_waybill_number     IN          VARCHAR2 DEFAULT NULL,
               p_caller             IN          VARCHAR2 DEFAULT NULL
            ) ;

--lpn conv
PROCEDURE Update_child_inv_info(p_container_id  IN NUMBER,
			P_locator_id IN NUMBER,
			P_subinventory IN VARCHAR2,
			X_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Assign_Container_to_Consol(
             p_child_container_id   IN NUMBER,
             p_parent_container_id  IN NUMBER,
             p_caller               IN VARCHAR2,
             x_return_status        OUT NOCOPY VARCHAR2);

PROCEDURE Unpack_Details_from_Consol
               (p_delivery_details_tab IN WSH_UTIL_CORE.ID_TAB_TYPE,
                p_caller               IN VARCHAR2,
                x_return_status       OUT NOCOPY VARCHAR2);

END wsh_container_actions;

 

/
