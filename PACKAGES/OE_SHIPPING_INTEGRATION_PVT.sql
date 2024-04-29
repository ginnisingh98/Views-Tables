--------------------------------------------------------
--  DDL for Package OE_SHIPPING_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SHIPPING_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVSHPS.pls 120.2.12010000.1 2008/07/25 08:07:32 appldev ship $ */

--  Start of Comments
--  API name    OE_Shipping_Integration_PVT
--  Type        Private
--  Version     Current version = 1.0
--              Initial version = 1.0

-- Record definition to be used to determine the shipped quantity for a model
-- and class in case of PTO, SMC PTO and KIT.

G_DEBUG_MSG  VARCHAR2(2000);
G_DEBUG_CALL NUMBER;
G_BULK_WSH_INTERFACE_CALLED  BOOLEAN := FALSE; -- ADDED FOR BUG 4070931


TYPE Shipment_Rec_Type IS RECORD
(	line_id				NUMBER	:= FND_API.G_MISS_NUM
,	ordered_quantity	NUMBER	:= FND_API.G_MISS_NUM
,	shipped_quantity	NUMBER	:= FND_API.G_MISS_NUM
,	ratio_to_top_model	NUMBER	:= FND_API.G_MISS_NUM
,	ratio_to_parent		NUMBER	:= FND_API.G_MISS_NUM
,	link_to_line_id		NUMBER	:= FND_API.G_MISS_NUM
,	top_model_line_id	NUMBER	:= FND_API.G_MISS_NUM
,	shippable_flag		VARCHAR2(1) := FND_API.G_MISS_CHAR
);

TYPE Shipment_Tbl_Type IS TABLE OF Shipment_Rec_Type
	INDEX BY BINARY_INTEGER;

PROCEDURE Call_Process_Order
(p_line_tbl		IN	OE_Order_PUB.Line_Tbl_Type
,p_control_rec		IN	OE_GLOBALS.Control_Rec_Type DEFAULT OE_GLOBALS.G_MISS_CONTROL_REC
,p_process_requests     IN BOOLEAN := FALSE
,x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Validate_Release_Status
(
	p_application_id		IN	NUMBER
,	p_entity_short_name		IN	VARCHAR2
,	p_validation_entity_short_name	IN	VARCHAR2
,	p_validation_tmplt_short_name	IN	VARCHAR2
,	p_record_set_short_name	        IN	VARCHAR2
,	p_scope				IN	VARCHAR2
, x_result_out OUT NOCOPY NUMBER

);

PROCEDURE Validate_Pick
(
	p_application_id		IN	NUMBER
,	p_entity_short_name		IN	VARCHAR2
,	p_validation_entity_short_name	IN	VARCHAR2
,	p_validation_tmplt_short_name	IN	VARCHAR2
,	p_record_set_short_name		IN	VARCHAR2
,	p_scope				IN	VARCHAR2
, x_result_out OUT NOCOPY NUMBER

);

--	Start of Comments
--	API name    :	Get_PTO_Shipped_Quantity
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure is to calculate the shipped quantities for
--					the non shippable component of a model/kit.
--	Parameters	:	p_top_model_line_id		IN NUMBER 	Optional
--						The top_model_line_id of the model/kit for which the
--						shipped quantity calculation is required. If this passed
--						the procedure will get the shipped quantities for
--						shippable components from the database.
--					p_line_tbl				IN Table of line records Optional
--						A table of records of lines for a top model/kit. This
--						needs to be passed when the calculation is required
--						and the shipped quantities for shippable components are
--						not in tha database.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Get_PTO_Shipped_Quantity
(
	p_top_model_line_id		IN	NUMBER DEFAULT FND_API.G_MISS_NUM
,	p_x_line_tbl			IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
, x_ratio_status OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	Update_Shipping_PVT
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure is a cover for Update_Shipping_From_OE and
--					will be used when a line reaches to SHIP_LINE work flow
--					activity or a hold is applied or released, to inform
--					shipping about these.
--	Parameters	:	p_line_id				IN NUMBER 	Required
--						The line_id of the line for which shipping update needs
--						to be called.
--					p_hold_type				IN VARCHAR2
--						The hold type if a hold is applied on the line or
--						'RELEASED' if a hold has been released.
--					p_shipping_activity		IN VARCHAR2
--						It should be FND_API.G_TRUE if a line has reached
--						SHIP_LINE workflow activity.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Update_Shipping_PVT
(
	p_line_id			IN	NUMBER
,	p_hold_type			IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR
,	p_shipping_activity	IN	VARCHAR2 	DEFAULT FND_API.G_MISS_CHAR
, x_return_status OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	Update_Shipping_From_OE
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure will get the line records for each line
--					passed in the table from the database. Will do the credit
--					and hold check if the line has reached to SHIP_LINE work
--					activity and will call
--					WSH_INTERFACE.Update_Shipping_Attributes API to inform
--					Shipping about any changes which have taken place in OE.
--	Parameters	: 	p_update_lines_tb IN OE_Order_Pub.Request_Tbl_Type Required
--						A table of record with line_id's for which shipping
--						update API needs to be called.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Update_Shipping_From_OE
(
	p_update_lines_tbl	IN	OE_ORDER_PUB.Request_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	Check_Shipment_Line
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure will check the shipment status of a line
--					and will return the result(e.g. 'Fully Shipped', 'Shipped
--					within tolerance below').
--	Parameters	:	p_line_rec				IN Record 	Required
--						The line record of a line for which the shipment status
--						is required.
--					p_shipped_quantity		IN NUMBER   Optional
--						Shipped quantity of the line. This is required if the
--						check is required with a shipped quantity which is yet
--						not in the database.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Check_Shipment_Line
(
	p_line_rec				IN	OE_Order_Pub.Line_Rec_Type
,	p_shipped_quantity		IN	NUMBER DEFAULT 0
, x_result_out OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	Ship_Confirm_Ship_Set
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure does the ship confirmation procesing for the
--					Ship set.
--	Parameters	:	p_ship_set_id				IN NUMBER 	Required
--						The ship set id for which ship confirmation needs to
--						be performed.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Ship_Confirm_Ship_Set
(
	p_ship_set_id		IN	NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	Ship_Confirm_PTO_KIT
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure will perform the ship confirm process for
--					a SMC PTO, PTO or a KIT.
--	Parameters	:	p_top_model_line_id		IN NUMBER 	Required
--						The top_model_line_id for the PTO for which ship
--						confirmation process needs to be performed.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Ship_Confirm_PTO_KIT
(
	p_top_model_line_id		IN	NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	Ship_Confirm_Standard_Line
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure performs the ship confirmation processing
--					for a standard line. It wil complete the SHIP_LINE work
--					flow activity for the ship confirmed line, it may split
--					the line if the line has been shipped partially.
--	Parameters	:	p_line_id				IN NUMBER
--						The line_id of the line for which ship confirmation
--						needs to be performed.
--					p_line_rec				IN OE_order_Pub.line_rec_type
--						The line record for the line for which ship confirmation
--						needs to be performed.
--					p_shipment_status		IN VARCHAR2
--						The shipment status of the line if known.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

PROCEDURE Ship_Confirm_Standard_Line
(p_line_id	IN	NUMBER DEFAULT FND_API.G_MISS_NUM
,p_line_rec	IN	OE_ORDER_PUB.line_rec_type
                        DEFAULT OE_ORDER_PUB.G_MISS_LINE_REC
,p_shipment_status	IN	VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
,p_check_line_set  IN  VARCHAR2 := 'Y'
, x_return_status  OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	Process_Ship_Conform
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure is called from the delayed request process
--					whenever there is a ship confirmation from shipping. This
--					call different procedures to perform the ship confirmation
--					process for standard line, PTO, ATO or ship set.
--	Parameters	:	p_process_id		IN NUMBER	Required
--						The id of the item for which the ship confirmation
--						process need to be performed, for example it should be
--						top_model_line_id if the ship confirmation is for a PTO
--						or a kit, it should be ship set id if the ship
--						confirmation is for a shipset.
--					p_process_type		IN NUMBER 	Required
--						The type of the item for which the ship confirmation
--						to be performed.It could be 'SHIP_SET', 'STANDARD',
--						'PTO_KIT' etc..
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Process_Ship_Confirm
(
	p_process_id		IN	NUMBER
,	p_process_type		IN	VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	Process_Shipping_Activity
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure is called when ever a line reaches SHIP_LINE
--					work flow activity. This prcedure will check if the line is
--					shippable it will call shipping update to inform that the
--					line is ready for pick, if the line is a non shippable line
--					it will complete the SHIP_LINE work flow activity with
--					result 'NON_SHIPPABLE'. If a SMC PTO or a MODEL/CLASS
--					reaches the SHIP_LINE work flow activity and the explosion
--					for included item has not taken place the SMC PTO, MODEL or
--					CLASS will be exploded at this point.
--	Parameters	:	p_api_version_number	IN NUMBER	Required
--					p_line_id				IN NUMBER 	Required
--						The line_id of the line which has reached SHIP_LINE work
--						flow activity.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Process_Shipping_Activity
(
	p_api_version_number	IN	NUMBER
, 	p_line_id				IN	NUMBER
, x_result_out OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY VARCHAR2

, x_msg_data OUT NOCOPY VARCHAR2

);

PROCEDURE Process_SMC_Shipping
( p_line_id                IN  NUMBER
 ,p_top_model_line_id      IN  NUMBER
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE OM_To_WSH_Interface
( p_line_rec      IN  OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
 ,p_header_rec    IN  OE_BULK_ORDER_PVT.HEADER_REC_TYPE
 ,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Handle_Config_Parent
( p_ato_line_id   IN  NUMBER);


/* Added for bug 6021460 */
PROCEDURE ship_complete
(
  p_application_id    IN  NUMBER
, p_entity_short_name   IN  VARCHAR2
, p_validation_entity_short_name  IN  VARCHAR2
, p_validation_tmplt_short_name IN  VARCHAR2
, p_record_set_short_name     IN  VARCHAR2
, p_scope             IN  VARCHAR2
, x_result_out OUT NOCOPY NUMBER

);



END OE_Shipping_Integration_PVT;

/
