--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_DETAILS_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_DETAILS_ACTIONS" AUTHID CURRENT_USER as
/* $Header: WSHDDACS.pls 120.4.12010000.2 2009/12/03 14:25:23 mvudugul ship $ */


  -- for splitting records
  CURSOR c_split_detail_info(x_delivery_detail_id NUMBER) IS
    SELECT wdd.delivery_detail_id,
           wdd.requested_quantity,
           wdd.picked_quantity,
           wdd.shipped_quantity,
           wdd.cycle_count_quantity,
           wdd.requested_quantity_uom,
           wdd.requested_quantity2,
           wdd.picked_quantity2,
           wdd.shipped_quantity2,
           wdd.cycle_count_quantity2,
           wdd.requested_quantity_uom2,
           wdd.organization_id,
           wdd.inventory_item_id,
           wdd.subinventory,
           wdd.lot_number,
-- HW OPMCONV. No need for sublot anymore
--         wdd.sublot_number,
           wdd.locator_id,
           wdd.source_line_id,
           wdd.net_weight,
           wdd.volume,
           wdd.weight_uom_code,
           wdd.volume_uom_code,
           wdd.cancelled_quantity,
           wdd.cancelled_quantity2,
           wdd.serial_number,
           wdd.to_serial_number,
           wdd.transaction_temp_id,
           wdd.container_flag,
           wdd.released_status,
           wda.delivery_id,
           wda.parent_delivery_detail_id,
           -- Bug 2419301
           wdd.oe_interfaced_flag,
           wdd.source_line_set_id,   -- anxsharm bug 2181132
           wdd.received_quantity,   -- J-IB-NPARIKH
           wdd.received_quantity2,  -- J-IB-NPARIKH
           wdd.returned_quantity,   -- J-IB-NPARIKH
           wdd.returned_quantity2,  -- J-IB-NPARIKH
           nvl(line_direction,'O') line_direction,      -- J-IB-NPARIKH
           -- J: W/V Changes
           wdd.gross_weight,
           NVL(wv_frozen_flag,'Y'),
           wda.parent_delivery_id,
           NVL(wda.type, 'S'),
           replenishment_status     --bug# 6689448 (replenishment project)
    FROM wsh_delivery_details     wdd,
         wsh_delivery_assignments wda
    WHERE wdd.delivery_detail_id = x_delivery_detail_id
    AND   wda.delivery_detail_id = wdd.delivery_detail_id
    AND   NVL(wda.type, 'S') in ('S', 'C');


TYPE SplitDetailRecType IS RECORD (
       delivery_detail_id       WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE,
       requested_quantity       WSH_DELIVERY_DETAILS.requested_quantity%TYPE,
       picked_quantity          WSH_DELIVERY_DETAILS.picked_quantity%TYPE,
       shipped_quantity         WSH_DELIVERY_DETAILS.shipped_quantity%TYPE,
       cycle_count_quantity     WSH_DELIVERY_DETAILS.cycle_count_quantity%TYPE,
       requested_quantity_uom   WSH_DELIVERY_DETAILS.requested_quantity_uom%TYPE,
       requested_quantity2      WSH_DELIVERY_DETAILS.requested_quantity2%TYPE,
       picked_quantity2         WSH_DELIVERY_DETAILS.picked_quantity2%TYPE,
       shipped_quantity2        WSH_DELIVERY_DETAILS.shipped_quantity2%TYPE,
       cycle_count_quantity2    WSH_DELIVERY_DETAILS.cycle_count_quantity2%TYPE,
       requested_quantity_uom2  WSH_DELIVERY_DETAILS.requested_quantity_uom2%TYPE,
       organization_id          WSH_DELIVERY_DETAILS.organization_id%TYPE,
       inventory_item_id        WSH_DELIVERY_DETAILS.inventory_item_id%TYPE,
       subinventory             WSH_DELIVERY_DETAILS.subinventory%TYPE,
       lot_number               WSH_DELIVERY_DETAILS.lot_number%TYPE,
-- HW OPMCONV. No need for sublot anymore
--     sublot_number            WSH_DELIVERY_DETAILS.sublot_number%TYPE,
       locator_id               WSH_DELIVERY_DETAILS.locator_id%TYPE,
       source_line_id           WSH_DELIVERY_DETAILS.source_line_id%TYPE,
       net_weight               WSH_DELIVERY_DETAILS.net_weight%TYPE,
       volume                   WSH_DELIVERY_DETAILS.volume%TYPE,
       weight_uom_code          WSH_DELIVERY_DETAILS.weight_uom_code%TYPE,
       volume_uom_code          WSH_DELIVERY_DETAILS.volume_uom_code%TYPE,
       cancelled_quantity       WSH_DELIVERY_DETAILS.cancelled_quantity%TYPE,
       cancelled_quantity2      WSH_DELIVERY_DETAILS.cancelled_quantity2%TYPE,
       serial_number            WSH_DELIVERY_DETAILS.serial_number%TYPE,
       to_serial_number         WSH_DELIVERY_DETAILS.to_serial_number%TYPE,
       transaction_temp_id      WSH_DELIVERY_DETAILS.transaction_temp_id%TYPE,
       container_flag           WSH_DELIVERY_DETAILS.container_flag%TYPE,
       released_status          WSH_DELIVERY_DETAILS.released_status%TYPE,
       delivery_id              wsh_delivery_assignments_v.delivery_id%TYPE,
       parent_delivery_detail_id  wsh_delivery_assignments_v.parent_delivery_detail_id%TYPE,
       -- Bug 2419301
       oe_interfaced_flag       WSH_DELIVERY_DETAILS.oe_interfaced_flag%TYPE,
       -- anxsharm bug 2181132
       source_line_set_id       WSH_DELIVERY_DETAILS.source_line_set_id%TYPE,
       received_quantity        WSH_DELIVERY_DETAILS.received_quantity%TYPE,-- J-IB-NPARIKH
       received_quantity2       WSH_DELIVERY_DETAILS.received_quantity2%TYPE,-- J-IB-NPARIKH
       returned_quantity        WSH_DELIVERY_DETAILS.returned_quantity%TYPE,-- J-IB-NPARIKH
       returned_quantity2       WSH_DELIVERY_DETAILS.returned_quantity2%TYPE,-- J-IB-NPARIKH
       line_direction           WSH_DELIVERY_DETAILS.line_direction%TYPE,-- J-IB-NPARIKH
       -- J: W/V Changes
       gross_weight             WSH_DELIVERY_DETAILS.gross_weight%TYPE,
       wv_frozen_flag           WSH_DELIVERY_DETAILS.wv_frozen_flag%TYPE,
       parent_delivery_id       WSH_DELIVERY_ASSIGNMENTS_V.parent_delivery_id%TYPE,
       wda_type                 WSH_DELIVERY_ASSIGNMENTS_V.type%TYPE,
       replenishment_status     WSH_DELIVERY_DETAILS.replenishment_status%TYPE  --bug# 6689448 (replenishment project)
);

-- anxsharm
-- for Split Serial Number
TYPE SerialRecType IS RECORD (
       serial_number            WSH_DELIVERY_DETAILS.serial_number%TYPE,
       to_serial_number         WSH_DELIVERY_DETAILS.to_serial_number%TYPE,
       transaction_temp_id      WSH_DELIVERY_DETAILS.transaction_temp_id%TYPE,
       delivery_detail_id       WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE);

TYPE Serial_tab is TABLE of SerialRecType INDEX BY BINARY_INTEGER;
--
-- PACKAGE VARIABLES
--
/** Bug 1571143
   Instead of Using 2 cursors just use One Cursor with a UNION
*/
--
-- LPN CONV. rv
--Based on assumption that we are using wsh_delivery_assignments_v,
--delivery and its contents will belong to same organization.
--Similarly, container and its contents will belong to same organization.
--Hence, we are checking for WMS org or non-WMS org. at the parent level (i.e. delivery/container)
--rather than at line-level for performance reasons.

--If this assumptions were to be violated in anyway
-- i.e Query was changed to refer to base table wsh_delivery_assignments instead of
--     wsh_delivery_assignments_v
-- or
--     if existing query were to somehow return/fetch records where
--     delivery and its contents may belong to diff. org.
--     container and its contents may belong to diff. org.
--     then
--       Calls to check_wms_org needs to be re-adjusted at
--       appropriate level (line/delivery/container).
-- LPN CONV. rv
--
CURSOR C_INSIDE_OUTSIDE_OF_CONTAINER (c_detail_id number) is
     SELECT delivery_detail_id,
            parent_delivery_detail_id,
            delivery_id
       FROM wsh_delivery_assignments_v
     START WITH delivery_detail_id = c_detail_id
     CONNECT BY prior delivery_detail_id = parent_delivery_detail_id
     UNION
     SELECT delivery_detail_id,
            parent_delivery_detail_id,
            delivery_id
       FROM wsh_delivery_assignments_v
     START WITH delivery_detail_id = c_detail_id
     CONNECT BY prior parent_delivery_detail_id = delivery_detail_id;

/** Variable Declaration for Fetching the Cursor */
l_inside_outside_of_container c_inside_outside_of_container%ROWTYPE;
l_inside_outside_of_container2 c_inside_outside_of_container%ROWTYPE;

CURSOR C_DEL_ID_FOR_CONT_OR_DETAIL(c_detail_id number) is
	SELECT  wda.delivery_id	,
                wdd.organization_id,
                wdd.ship_from_location_id,
                wdd.customer_id,
                wdd.intmed_ship_to_location_id,
                wdd.fob_code,
                wdd.freight_terms_code,
                wdd.ship_method_code ,
                wda.parent_delivery_detail_id,
                NVL(wdd.line_direction,'O') line_direction,   -- J-IB-NPARIKH
                -- J: W/V Changes
                wdd.released_status,
                wdd.gross_weight,
                wdd.net_weight,
                wdd.volume,
                wdd.container_flag,
                NVL(wdd.ignore_for_planning,'N') ignore_for_planning, --J TP Release
                wdd.mode_of_transport,
                wdd.service_level,
                wdd.carrier_id,
                wdd.weight_uom_code,
                wdd.volume_uom_code,
                wdd.inventory_item_id,
                wda.type wda_type,
                wdd.client_id  -- LSP PROJECT
	FROM	wsh_delivery_assignments_v wda,
                wsh_delivery_details wdd
	WHERE	wdd.delivery_detail_id = wda.delivery_detail_id
          AND   wda.delivery_detail_id = c_detail_id;

-- Consolidation of Back Order Delivery Details Enhancement
--
-- PACKAGE VARIABLES
--
-- HW OPM BUG#:3121616- Added qty2s
TYPE Cons_Source_Line_Rec_Typ IS RECORD(
DELIVERY_DETAIL_ID               NUMBER,
DELIVERY_ID                      NUMBER,
SOURCE_LINE_ID                   NUMBER,
REQ_QTY                          NUMBER,
BO_QTY                           NUMBER,
OVERPICK_QTY                     NUMBER,	-- Bug#3263952
REQ_QTY2                         NUMBER,
BO_QTY2                          NUMBER
);

TYPE Cons_Source_Line_Rec_Tab is TABLE of Cons_Source_Line_Rec_Typ INDEX BY BINARY_INTEGER;

/*---------------------------------------------------------------------
Procedure Name : Unreserve_delivery_detail
Description    : This API calls Inventory's APIs to Unreserve. It first
                 queries the reservation records, and then calls
                 delete_reservations until the p_quantity_to_unreserve
                 is satisfied.
--------------------------------------------------------------------- */
-- HW OPM BUG#:3121616 Added p_quantity2_to_unreserve
Procedure Unreserve_delivery_detail
( p_delivery_detail_id            IN NUMBER
, p_quantity_to_unreserve         IN  NUMBER
, p_quantity2_to_unreserve    IN NUMBER default NULL
, p_unreserve_mode                IN  VARCHAR2
, p_override_retain_ato_rsv       IN  VARCHAR2 DEFAULT NULL    -- 2747520
, x_return_status                 OUT NOCOPY  VARCHAR2) ;

--
--Procedure:        Assign_Detail_to_Delivery
--Parameters:       p_detail_id,
--                  p_delivery_id,
--                  x_return_status
-- x_dlvy_has_lines : 'Y' :delivery has non-container lines.
--                    'N' : delivery does not have non-container lines
--Description:      This procedure will assign the specified
--                  delivery_detail to the specified delivery
--                  and return the status

PROCEDURE Assign_Detail_to_Delivery(
	P_DETAIL_ID	IN NUMBER,
	P_DELIVERY_ID	IN NUMBER,
	X_RETURN_STATUS	OUT NOCOPY  VARCHAR2,
        x_dlvy_has_lines          IN OUT NOCOPY VARCHAR2 ,    -- J-IB-NPARIKH
        x_dlvy_freight_terms_code IN OUT NOCOPY VARCHAR2 ,-- J-IB-NPARIKH
        P_CALLER             IN VARCHAR2 DEFAULT NULL
    );

-------------------------------------------------------------------
-- This procedure is only for backward compatibility.
-------------------------------------------------------------------

PROCEDURE Assign_Detail_to_Delivery(
    P_DETAIL_ID     IN NUMBER,
    P_DELIVERY_ID   IN NUMBER,
    X_RETURN_STATUS OUT NOCOPY  VARCHAR2,
    P_CALLER             IN VARCHAR2 DEFAULT NULL
    );

--
--Procedure:        Assign_Detail_to_Cont
--Parameters:       p_detail_id,
--                  p_parent_detail_id,
--                  x_return_status
--Description:      This procedure will assign the specified
--                  delivery_detail to the specified container
--                  and return the status

--                  If container is already assigned to a delivery,
--                  its parent containers and child containers must
--                  be also assigned to the same delivery already.
--                  So all it needs to do is just get the delivery_id
--                  from the current container and assign it to the detail also.

--                  If the detail is already assigned to a delivery,
--                  then drill up and down to update the delivery id for all the
--                  parent and chile containers

PROCEDURE Assign_Detail_to_Cont(
	P_DETAIL_ID	IN NUMBER,
	P_PARENT_DETAIL_ID IN NUMBER,
	X_RETURN_STATUS OUT NOCOPY  VARCHAR2);
--
--Procedure:        Unssign_Detail_from_Cont
--Parameters:       p_detail_id,
--                  p_parent_detail_id,
--                  x_return_status
--Description:
--  if detail is already assigned to a delivery which means the container must
--  be assigned to the same delivery too, in this case even though the detail
--  is getting removed from the container, it will still stay assigned to the delivery
-- if the container is already assigned to a delivery, the detail must also be a
-- ssigned to the same delivery
PROCEDURE Unassign_Detail_from_Cont(
	P_DETAIL_ID			IN NUMBER,
	X_RETURN_STATUS 	OUT NOCOPY  VARCHAR2,
	p_validate_flag 	IN VARCHAR2 DEFAULT NULL);

PROCEDURE Assign_Cont_To_Delivery(
	P_DETAIL_ID	IN NUMBER,
	P_DELIVERY_ID	IN NUMBER,
	X_RETURN_STATUS OUT NOCOPY  VARCHAR2);

-------------------------------------------------------------------
--Assign_Top_Detail_To_Delivery should only be called for the topmost
--container in a hierarchy/detail (if it is a loose detail) assigns
--all the details below (including containers) to delivery
-- x_dlvy_has_lines : 'Y' :delivery has non-container lines.
--                    'N' : delivery does not have non-container lines
-------------------------------------------------------------------

PROCEDURE Assign_Top_Detail_To_Delivery(
	P_DETAIL_ID	IN NUMBER,
	P_DELIVERY_ID	IN NUMBER,
	X_RETURN_STATUS OUT NOCOPY  VARCHAR2,
    x_dlvy_has_lines          IN OUT NOCOPY VARCHAR2,    -- J-IB-NPARIKH
    x_dlvy_freight_terms_code IN OUT NOCOPY VARCHAR2,     -- J-IB-NPARIKH
    P_CALLER             IN VARCHAR2 DEFAULT NULL
    );


-------------------------------------------------------------------
-- This procedure is only for backward compatibility.
-------------------------------------------------------------------

PROCEDURE Assign_Top_Detail_To_Delivery(
    P_DETAIL_ID     IN NUMBER,
    P_DELIVERY_ID   IN NUMBER,
    X_RETURN_STATUS OUT NOCOPY  VARCHAR2
    );



PROCEDURE Unassign_Cont_from_Delivery(
	P_DETAIL_ID			IN NUMBER,
	X_RETURN_STATUS 	OUT NOCOPY  VARCHAR2,
	p_validate_flag 	IN VARCHAR2 DEFAULT NULL);

PROCEDURE Assign_Cont_To_Cont(
	P_DETAIL_ID1	IN NUMBER,
	P_DETAIL_ID2	IN NUMBER,
	X_RETURN_STATUS OUT NOCOPY  VARCHAR2);

PROCEDURE Unassign_Cont_from_Cont(
	P_DETAIL_ID	IN NUMBER,
	X_RETURN_STATUS OUT NOCOPY  VARCHAR2);

PROCEDURE Assign_Multiple_Details(
	p_rec_of_detail_ids	IN WSH_UTIL_CORE.ID_TAB_TYPE,
	p_delivery_id	IN NUMBER,
	p_cont_ins_id	IN NUMBER,
	x_return_status	OUT NOCOPY  VARCHAR2);



PROCEDURE Unassign_Detail_from_Delivery(
	p_detail_id			IN NUMBER,
	x_return_status	OUT NOCOPY  VARCHAR2,
	p_validate_flag 	IN VARCHAR2 DEFAULT NULL,
    p_action_prms  IN WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type   -- J-IB-NPARIKH
	);

--This procedure is for backward compatibility only. Do not use this.
PROCEDURE Unassign_Detail_from_Delivery(
    p_detail_id         IN NUMBER,
    x_return_status OUT NOCOPY  VARCHAR2,
    p_validate_flag     IN VARCHAR2 DEFAULT NULL
    );

PROCEDURE Unassign_Multiple_Details(
    p_rec_of_detail_ids IN WSH_UTIL_CORE.ID_TAB_TYPE,
    p_from_delivery     IN VARCHAR2,
    p_from_container        IN VARCHAR2,
    x_return_status        OUT NOCOPY   VARCHAR2,
    p_validate_flag         IN VARCHAR2 DEFAULT NULL,
    p_action_prms  IN WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type   -- J-IB-NPARIKH
    );

--This procedure is for backward compatibility only. Do not use this.
PROCEDURE Unassign_Multiple_Details(
	p_rec_of_detail_ids	IN WSH_UTIL_CORE.ID_TAB_TYPE,
	p_from_delivery		IN VARCHAR2,
	p_from_container		IN VARCHAR2,
	x_return_status		   OUT NOCOPY 	VARCHAR2,
	p_validate_flag 		IN VARCHAR2 DEFAULT NULL
	);

/********* anxsharm *********************/
/********* ADDED FOR AUTOPACK *********************/
-- anxsharm
-- This API has been added to bulkalize
-- call from Auto Packing
PROCEDURE Split_Delivery_Details_Bulk(
	p_from_detail_id	NUMBER,
	p_req_quantity		IN OUT NOCOPY  NUMBER ,
	p_unassign_flag     IN VARCHAR2 DEFAULT 'N',
	p_req_quantity2   IN NUMBER DEFAULT NULL,
        p_converted_flag IN VARCHAR2 DEFAULT NULL ,
        p_manual_split   IN VARCHAR2 DEFAULT NULL ,
        p_num_of_split   IN NUMBER DEFAULT NULL,
	x_new_detail_id	OUT NOCOPY 	NUMBER,
        x_dd_id_tab      OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
	x_return_status	OUT NOCOPY 	VARCHAR2
	);

-- anxsharm
-- This API has been added to bulkalize
-- call from Auto Packing
-- HW OPMCONV - Removed parameter p_process_flag
PROCEDURE Split_Detail_INT_Bulk(
               p_old_delivery_detail_rec      IN  SplitDetailRecType,
               p_new_source_line_id  IN  NUMBER   DEFAULT NULL,
               p_quantity_to_split   IN  NUMBER,
               p_quantity_to_split2  IN  NUMBER   DEFAULT NULL,
               p_unassign_flag       IN  VARCHAR2 DEFAULT 'N',
               p_converted_flag      IN  VARCHAR2 DEFAULT NULL,
--             p_process_flag        IN  VARCHAR2,
               p_manual_split        IN  VARCHAR2 DEFAULT NULL,
               p_split_sn            IN  VARCHAR2 DEFAULT 'Y',
               p_num_of_split   IN NUMBER,
               x_split_detail_id     OUT NOCOPY  NUMBER,
               x_return_status       OUT NOCOPY  VARCHAR2,
               x_dd_id_tab      OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
               );
/********* End of anxsharm *********************/
-- fabdi : Begin of OPM Changes (Pick_Confirm)
-- added a new parameter called p_req_quantity2
-- fabdi : End of OPM Changes (Pick_Confirm)

-- HW BUG#:1636578 - added a new paramter p_converted_flag
PROCEDURE Split_Delivery_Details(
	p_from_detail_id	NUMBER,
	p_req_quantity		IN OUT NOCOPY  NUMBER ,
	x_new_detail_id	OUT NOCOPY 	NUMBER,
	x_return_status	OUT NOCOPY 	VARCHAR2,
	p_unassign_flag     IN VARCHAR2 DEFAULT 'N',
	p_req_quantity2   IN NUMBER DEFAULT NULL,
        p_converted_flag IN VARCHAR2 DEFAULT NULL ,
        p_manual_split   IN VARCHAR2 DEFAULT NULL
	);

--  Procedure:      Split_Detail_INT
--
--  Description:    This is an internal API.
--                  Copies the delivery detail and update their quantites
--                  and serial numbers
--                  in order to split the delivery line and serial numbers.
--
-- HW OPMCONV - Removed parameter p_process_flag
PROCEDURE Split_Detail_INT(
               p_old_delivery_detail_rec      IN  SplitDetailRecType,
               p_new_source_line_id  IN  NUMBER   DEFAULT NULL,
               p_quantity_to_split   IN  NUMBER,
               p_quantity_to_split2  IN  NUMBER   DEFAULT NULL,
               p_unassign_flag       IN  VARCHAR2 DEFAULT 'N',
               p_converted_flag      IN  VARCHAR2 DEFAULT NULL,
--             p_process_flag        IN  VARCHAR2,
               p_manual_split        IN  VARCHAR2 DEFAULT NULL,
               p_split_sn            IN  VARCHAR2 DEFAULT 'Y',
               x_split_detail_id     OUT NOCOPY  NUMBER,
               x_return_status       OUT NOCOPY  VARCHAR2);


PROCEDURE Explode_Delivery_Details(
	p_delivery_detail_id NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE unassign_unpack_empty_cont (
      p_ids_tobe_unassigned IN wsh_util_core.id_tab_type,
      p_validate_flag   IN VARCHAR2,
      x_return_status   OUT NOCOPY  VARCHAR2
);

-- ******** Added for Consolidation of Back Order delivery details enhancement

--  Procedure:      Consolidate_Source_Line
--
--  Parameters: p_Cons_Source_Line_Rec_Tab  -> List of delivery details and its corresponding req qtys,
--                                        bo qtys, source line ids and delivery ids.
--              x_consolidate_ids     ->  Contains the list of existing BO dd_ids, into which the dd_ids passed
--                                        in the parameter p_Cons_Source_Line_Rec_Tab got consolidated.
--
--  Description:    This is an internal API.
--                  Consolidates all the unpacked and unassigned back order delivery detail lines
--                  into one delivery detail id for the given source line id
--
--
PROCEDURE Consolidate_Source_Line(
        p_Cons_Source_Line_Rec_Tab  IN           WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab,
        x_consolidate_ids           OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
        x_return_status             OUT NOCOPY VARCHAR2 );


--  Procedure:      Consolidate_Delivery_Details
--
--  Parameters: p_delivery_details_tab  -> list of delivery details and its corresponding req qtys, bo qtys,
--		 			   source line ids and delivery ids
--              p_bo_mode		-> Either  'UNRESERVE'  or 'CYCLE_COUNT'
--		x_cons_delivery_details_tab -> Contains the list of dds into which the dds passed in the
--					   parameter p_delivery_details_tab get consolidated.
--					   This also contains the corresponding req qtys, bo qyts and
--					   source line ids.
--		x_remain_bo_qtys	-> Contains the sum of backorder quantities of delivery details (except
--					   for the dd_id in x_cons_delivery_details_tab) for each source line.
--					   x_remain_bo_qtys has a quantity for each dd_id in
--					   x_cons_delivery_details_tab.
--  Description:    This API is Internally used by ShipConfirm to
--		    consolidate the delivery details going to be BackOrdered.
--                  This Procedure takes the list of delivery details
--		    under a Delivery and consolidates them into one
--		    delivery detail for each source line id.
--
-- HW OPM BUG#:3121616 Added x_remain_bo_qty2s
PROCEDURE Consolidate_Delivery_Details(
	 	p_delivery_details_tab  IN     WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab,
		p_bo_mode	        IN     VARCHAR2,
	 	x_cons_delivery_details_tab  OUT NOCOPY  WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab,
		x_remain_bo_qtys	OUT NOCOPY       WSH_UTIL_CORE.Id_Tab_Type,
                x_remain_bo_qty2s	OUT NOCOPY       WSH_UTIL_CORE.Id_Tab_Type,
		x_return_status		OUT NOCOPY       VARCHAR2
		);


PROCEDURE Create_Consol_Record(
                    p_detail_id_tab IN  wsh_util_core.id_tab_type,
                    x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Delete_Consol_Record(
                       p_detail_id_tab IN  wsh_util_core.id_tab_type,
                       x_return_status OUT NOCOPY VARCHAR2);

END WSH_DELIVERY_DETAILS_ACTIONS;


/
