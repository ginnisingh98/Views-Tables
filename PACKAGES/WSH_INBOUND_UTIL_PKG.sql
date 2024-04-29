--------------------------------------------------------
--  DDL for Package WSH_INBOUND_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INBOUND_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: WSHIBUTS.pls 120.1 2005/07/04 23:32:35 ragarg noship $ */

-- HW OPMCONV no need for OPM variable
--LIMITED_PRECISION_OPM CONSTANT NUMBER := 9;

-- { IB-Phase-2
-- This global variable will determine whether a ASN / Receipt being matched,
-- is being matched Automatically or manually from the Inbound Reconcillation UI.
-- This information will be used to determine whether inline or asynchronous
-- rating of Trips will be done.
G_ASN_RECEIPT_MATCH_TYPE VARCHAR2(30);
-- } IB-Phase-2

--========================================================================
-- PROCEDURE : get_po_rcv_attributes    This procedure derives the
--                                      x_line_rec based on the inputs
--                                      p_po_line_location_id and
--                                      p_rcv_shipment_line_id.
--
-- PARAMETERS:  p_po_line_location_id   po_line_location_id of
--                                      po_line_locations_all
--		p_rcv_shipment_line_id  shipment_line_id of rcv_shipment_lines
--		x_line_rec              Out parameter of type
--                                      OE_WSH_BULK_GRP.line_rec_type
--		x_return_status         Return status of the API.
--
-- COMMENT   : This procedure derives the x_line_rec based on the inputs
--             p_po_line_location_id and p_rcv_shipment_line_id
--========================================================================
  PROCEDURE get_po_rcv_attributes(
              p_po_line_location_id IN NUMBER,
              p_rcv_shipment_line_id IN NUMBER DEFAULT NULL,
              x_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
              x_return_status OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : get_drop_ship_info
--
-- PARAMETERS:  p_line_rec      IN  OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
--		p_index 	IN 	NUMBER
--		x_return_status         return status
--
-- COMMENT   : This API derives the value for all the drop ship fields
--	       and populates the same into the p_line_rec sructure.
--========================================================================
PROCEDURE  get_drop_ship_info(
         p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
         p_index     IN	NUMBER,
         x_return_status OUT NOCOPY VARCHAR2
         );

--========================================================================

PROCEDURE split_inbound_delivery
    (
        p_delivery_detail_id_tbl IN wsh_util_core.id_tab_type,
        p_delivery_id            IN NUMBER,
        x_delivery_id            IN OUT NOCOPY NUMBER,
        x_return_status      OUT NOCOPY     VARCHAR2,
        p_caller                   IN VARCHAR2 DEFAULT 'WSH_ASN_RECEIPT'
    ) ;
PROCEDURE reRateDeliveries
    (
        p_delivery_id_tab     IN          wsh_util_core.id_tab_type,
        x_return_status       OUT NOCOPY  VARCHAR2
    );

PROCEDURE setTripStopStatus
    (
        p_transaction_code    IN          VARCHAR2 DEFAULT 'RECEIPT',
        p_action_code         IN          VARCHAR2 DEFAULT 'APPLY',
        p_delivery_id_tab     IN          wsh_util_core.id_tab_type,
        x_return_status       OUT NOCOPY  VARCHAR2
    );

--========================================================================
-- PROCEDURE : convert_quantity
--
-- PARAMETERS: p_inv_item_id IN NUMBER DEFAULT NULL
--	       p_organization_id IN NUMBER
--	       p_primary_uom_code IN OUT NOCOPY VARCHAR2
--	       p_quantity IN  NUMBER
--	       p_qty_uom_code  IN  VARCHAR2
--	       x_conv_qty  OUT NOCOPY NUMBER
--	       x_return_status IN OUT NOCOPY VARCHAR2
--
-- COMMENT   : This API is used to convert the quantity of an item
--	       from one UOM code to another.Like 'DOZ' to 'EA'.
--             p_primary_uom_code is the uom code into which the quantity has to be
--	       converted.
--	       p_quantity is the quantity to be converted.
--             p_qty_uom_code is the code which represents the curent uom code
--             of the input p_quantity.
--             x_conv_qty will have the converted quantity in case of successfull
--	       conversion.
--========================================================================

PROCEDURE  convert_quantity
   (
        p_inv_item_id	    IN NUMBER DEFAULT NULL,
	p_organization_id   IN NUMBER,
	p_primary_uom_code  IN OUT NOCOPY VARCHAR2,
	p_quantity	    IN  NUMBER ,
	p_qty_uom_code	    IN  VARCHAR2,
	x_conv_qty	    OUT NOCOPY NUMBER,
	x_return_status	    IN OUT NOCOPY VARCHAR2
   );

--=============================================================================
--      API name        : GET_OUTERMOST_LPN
--      Type            : Public.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			  p_lpn_id IN NUMBER
--			  p_shipment_header_id IN NUMBER
--			  p_lpn_context IN NUMBER
--			  x_outermost_lpn OUT NOCOPY NUMBER
--			  x_return_status OUT NOCOPY VARCHAR2
-- ============================================================================
PROCEDURE GET_OUTERMOST_LPN(
  p_lpn_id IN NUMBER,
  p_shipment_header_id IN NUMBER,
  p_lpn_context IN NUMBER,
  x_outermost_lpn OUT NOCOPY NUMBER,
  x_outermost_lpn_name OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2);


--=============================================================================
--      API name        : Is_Routing_Response_Send
--      Type            : Public.
--      Function        : Determine if routing response has been send for detail line.
--      Pre-reqs        : None.
--=============================================================================
--HACMS {
FUNCTION Is_Routing_Response_Send(p_delivery_detail_id  NUMBER,
                                  x_routing_response_id OUT NOCOPY NUMBER) RETURN boolean;

--HACMS }

END WSH_INBOUND_UTIL_PKG;

 

/
