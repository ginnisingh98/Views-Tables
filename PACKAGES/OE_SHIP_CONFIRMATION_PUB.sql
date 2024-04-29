--------------------------------------------------------
--  DDL for Package OE_SHIP_CONFIRMATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SHIP_CONFIRMATION_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPSHCS.pls 120.1.12010000.5 2008/10/17 06:05:20 zsingh ship $ */
/*#
* This public package contains methods related to ship confirmation
* Of order lines in Order Management
* @rep:scope public
* @rep:product ONT
* @rep:lifecycle active
* @rep:displayname Ship Conformation
* @rep:category BUSINESS_ENTITY ONT_SALES_ORDER
*/

TYPE Req_Quantity_Rec_Type	IS RECORD
(
	line_id			NUMBER := FND_API.G_MISS_NUM
,	requested_quantity	NUMBER := FND_API.G_MISS_NUM
,	requested_quantity2	NUMBER := FND_API.G_MISS_NUM
,	shipping_quantity	NUMBER := FND_API.G_MISS_NUM
,	shipping_quantity_uom	VARCHAR2(3) := FND_API.G_MISS_CHAR
,	shipping_quantity2	NUMBER := FND_API.G_MISS_NUM
,	shipping_quantity_uom2	VARCHAR2(3) := FND_API.G_MISS_CHAR
,	pending_quantity	NUMBER := FND_API.G_MISS_NUM
,	pending_quantity2	NUMBER := FND_API.G_MISS_NUM
,	pending_requested_flag	VARCHAR2(1) := FND_API.G_MISS_CHAR
);

TYPE Req_Quantity_Tbl_Type IS TABLE OF Req_Quantity_Rec_Type
	INDEX BY BINARY_INTEGER;


PROCEDURE Ship_Confirm
(
    p_api_version_number         IN   NUMBER
,   p_line_tbl                   IN   OE_Order_PUB.Line_Tbl_Type
,   p_line_adj_tbl               IN   OE_ORDER_PUB.Line_adj_Tbl_Type
,   p_req_qty_tbl                IN   Req_Quantity_Tbl_Type
,   x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER
,   x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


/*-----------------------------------------------------------------
pack J : OM interface (bulk) API and Record Types
------------------------------------------------------------------*/
TYPE Ship_Line_Rec_Type IS RECORD
( error_flag            OE_WSH_BULK_GRP.T_V1   := OE_WSH_BULK_GRP.T_V1()
 ,fulfilled_flag        OE_WSH_BULK_GRP.T_V1   := OE_WSH_BULK_GRP.T_V1()
 ,actual_shipment_date  OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
 ,shipping_quantity2    OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,shipping_quantity     OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,shipping_quantity_uom2 OE_WSH_BULK_GRP.T_V3   := OE_WSH_BULK_GRP.T_V3()
 ,shipping_quantity_uom OE_WSH_BULK_GRP.T_V3   := OE_WSH_BULK_GRP.T_V3()
 ,line_id               OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,header_id             OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,top_model_line_id     OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,ato_line_id           OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,ship_set_id           OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,arrival_set_id        OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,inventory_item_id     OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,ship_from_org_id      OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,line_set_id           OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,smc_flag              OE_WSH_BULK_GRP.T_V1   := OE_WSH_BULK_GRP.T_V1()
 ,over_ship_reason_code OE_WSH_BULK_GRP.T_V30  := OE_WSH_BULK_GRP.T_V30()
 ,requested_quantity    OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,requested_quantity2   OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,pending_quantity      OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,pending_quantity2     OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,pending_requested_flag OE_WSH_BULK_GRP.T_V1   := OE_WSH_BULK_GRP.T_V1()
 ,order_quantity_uom    OE_WSH_BULK_GRP.T_V3   := OE_WSH_BULK_GRP.T_V3()
 ,order_quantity_uom2   OE_WSH_BULK_GRP.T_V3   := OE_WSH_BULK_GRP.T_V3()
 ,shipped_quantity      OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,shipped_quantity2     OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,model_remnant_flag    OE_WSH_BULK_GRP.T_V1   := OE_WSH_BULK_GRP.T_V1()
 ,ordered_quantity      OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,ordered_quantity2     OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,item_type_code        OE_WSH_BULK_GRP.T_V30  := OE_WSH_BULK_GRP.T_V30()
 ,calculate_price_flag  OE_WSH_BULK_GRP.T_V1   := OE_WSH_BULK_GRP.T_V1()
 ,flow_status_code      OE_WSH_BULK_GRP.T_V30  := OE_WSH_BULK_GRP.T_V30()
 ,type                  OE_WSH_BULK_GRP.T_V30  := OE_WSH_BULK_GRP.T_V30()
 ,org_id                OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,ship_tolerance_below  OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,ship_tolerance_above  OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,shippable_flag        OE_WSH_BULK_GRP.T_V1   := OE_WSH_BULK_GRP.T_V1()
 ,source_type_code      OE_WSH_BULK_GRP.T_V30  := OE_WSH_BULK_GRP.T_V30()); -- Added for bug 6877315

/*-----------------------------------------------------------------
Record used for ITS
------------------------------------------------------------------*/
TYPE Ship_Adj_Rec_Type IS RECORD
( cost_id               OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,automatic_flag        OE_WSH_BULK_GRP.T_V1   := OE_WSH_BULK_GRP.T_V1()
 ,list_line_type_code   OE_WSH_BULK_GRP.T_V30  := OE_WSH_BULK_GRP.T_V30()
 ,charge_type_code      OE_WSH_BULK_GRP.T_V30  := OE_WSH_BULK_GRP.T_V30()
 ,header_id             OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,line_id               OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,adjusted_amount       OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM()
 ,arithmetic_operator   OE_WSH_BULK_GRP.T_V30  := OE_WSH_BULK_GRP.T_V30()
 ,operation             OE_WSH_BULK_GRP.T_V30  := OE_WSH_BULK_GRP.T_V30()
 ,price_adjustment_id   OE_WSH_BULK_GRP.T_NUM  := OE_WSH_BULK_GRP.T_NUM());

/*-----------------------------------------------------------------
PROCEDURE Ship_Confirm_New

This procedure is called by WSH at the time of ITS for HV.
------------------------------------------------------------------*/
PROCEDURE Ship_Confirm_New
( p_ship_line_rec      IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_requested_line_rec IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_line_adj_rec       IN OUT NOCOPY Ship_Adj_Rec_Type
 ,p_bulk_mode          IN            VARCHAR2
 ,p_start_index        IN            NUMBER
 ,p_end_index          IN            NUMBER
 ,x_msg_count          OUT NOCOPY /* file.sql.39 change */           NUMBER
 ,x_msg_data           OUT NOCOPY    VARCHAR2
 ,x_return_status      OUT NOCOPY    VARCHAR2);

PROCEDURE Call_Notification_Framework
( p_ship_line_rec  IN  Ship_Line_Rec_Type
 ,p_index          IN  NUMBER := NULL
 ,p_start_index    IN  NUMBER := NULL
 ,p_end_index      IN  NUMBER := NULL
 ,p_caller         IN  VARCHAR2);

/*#
* This API ship confirms a line with zero shipped quantity and completes the
* SHIP_LINE (Ship) workflow activity, provided that tolerances across the line
* set for the input line are met. Parameter x_return_status reports API success
* or failure, and x_result_out narrows down the cause of failure.
* @param p_line_id      Input value of line id to be shipped with zero quantity
* @param x_result_out   Returns reason for failure (W = Workflow not at Ship:Notified,T = Tolerances not met, D = Delivery details already shipped)
* @param x_return_status   Return status (S = Success, E = Error, U = Unexpected Error)
* @param x_msg_count  Returns number of mesages generated while executing the API
* @param x_msg_data  Returns text of messages generated
* @rep:scope               public
* @rep:lifecycle           active
* @rep:displayname         Ship Confirm with Zero Quantity
*/
 PROCEDURE Ship_Zero
( p_line_id  	   IN		NUMBER,
  x_result_out	   OUT		NOCOPY VARCHAR2,
  x_return_status  IN OUT	NOCOPY VARCHAR2,
  x_msg_count      OUT          NOCOPY NUMBER,
  x_msg_data       OUT          NOCOPY VARCHAR2);

END OE_Ship_Confirmation_Pub;

/
