--------------------------------------------------------
--  DDL for Package OE_SHIPPING_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SHIPPING_INTEGRATION_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPSHPS.pls 120.0 2005/06/01 01:07:38 appldev noship $ */

TYPE Cal_Tolerance_Rec_Type IS RECORD
(	line_id					NUMBER	:= FND_API.G_MISS_NUM
,	shipping_uom			VARCHAR2(3) := FND_API.G_MISS_CHAR
,	quantity_to_be_shipped	NUMBER	:= FND_API.G_MISS_NUM
,	planned_quantity		NUMBER	:= FND_API.G_MISS_NUM
);

TYPE Cal_Tolerance_Tbl_Type IS TABLE OF Cal_Tolerance_Rec_Type
	INDEX BY BINARY_INTEGER;


-- Setsmc_Input_Rec_Type  was included for bug 3623149
TYPE Setsmc_Input_Rec_Type IS RECORD
(    header_id         NUMBER,
     top_model_line_id NUMBER,
     ship_set_id       NUMBER
);

TYPE Setsmc_Output_Rec_Type IS RECORD
(    x_interface_status  VARCHAR2(1));


PROCEDURE Get_SetSMC_Interface_Status
(p_setsmc_input_rec    IN Setsmc_Input_Rec_Type
,p_setsmc_output_rec  OUT NOCOPY /* file.sql.39 change */ Setsmc_Output_Rec_Type
,x_return_status      OUT NOCOPY VARCHAR2);


--	Start of Comments
--	API name    :	Is_Activity_Shipping
--	Type        :	Public
--	Pre-reqs	:	None.
--	Function	:	Checks if the current activity for a line is SHIP_LINE in
--					work flow. Returns FND_API.G_TRUE if line is at SHIP_LINE
--					work flow activity else return FND_API.G_FALSE.
--	Parameters	:	p_api_version_number	IN NUMBER	Required
--					p_line_id				IN NUMBER 	Required
--						The line_id of the line for which the check is required.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

FUNCTION Is_Activity_Shipping
(
	p_api_version_number  		IN	NUMBER
,	p_line_id					IN	NUMBER
) return VARCHAR2;

--	Start of Comments
--	API name    :	Complete_Ship_Line_Activity
--	Type        :	Public
--	Pre-reqs	:	The line for which the SHIP_LINE work flow activity is to
--					be completed should be at SHIP_LINE work flow activity.
--	Function	:	Checks if the current activity for a line is SHIP_LINE in
--					work flow. Returns FND_API.G_TRUE if line is at SHIP_LINE
--					work flow activity else return FND_API.G_FALSE.
--	Parameters	:	p_api_version_number	IN NUMBER	Required
--					p_line_id				IN NUMBER 	Required
--						The line_id of the line for which the SHIP_LINE work
--						flow activity will be completed.
--					p_result_code			IN VARCHAR2 Required
--						The result code with which the SHIP_LINE work flow
--						activity will be completed. It could be 'SHIP_CONFIRM'
--						or 'NON_SHIPPABLE'.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Complete_Ship_Line_Activity
(   p_api_version_number        IN	NUMBER
,   p_line_id                   IN	NUMBER
,	p_result_code				IN	VARCHAR2
,   x_return_status             OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   x_msg_count                 OUT NOCOPY /* file.sql.39 change */	NUMBER
,   x_msg_data                  OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);

--	Start of Comments
--	API name    :	Credit_Check
--	Type        :	Public
--	Pre-reqs	:	None.
--	Function	:	This function performs the credit check for the passed
--					header and line id and returns the result of credit check.
--	Parameters	:	p_api_version_number	IN NUMBER	Required
--					p_header_id				IN NUMBER 	Required
--						The header_id of the order for which the check is
--						required.
--					p_line_id				IN NUMBER
--						The line_id of the line for which the check is required.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
FUNCTION Credit_Check
(
	p_api_version_number		IN	NUMBER
,	p_header_id					IN	NUMBER
,	p_line_id					IN	NUMBER	DEFAULT NULL
) return VARCHAR2;

FUNCTION Check_Holds_For_SC
(
	p_api_version_number		IN	NUMBER
,	p_header_id					IN	NUMBER		DEFAULT NULL
,	p_line_id					IN	NUMBER
) return VARCHAR2;

--	Start of Comments
--	API name    :	Get_Tolerance
--	Type        :	Public
--	Pre-reqs	:	None.
--	Function	:	This procedure will be called by shipping to find out NOCOPY /* file.sql.39 change */ if
--					the value of tolerance needs to be updated if a partial
--					shipment is being done and there are some planned shipments
--					or if the shipment is beyond over shipment tolerance.
--					tolerances for the passed line_id.
--	Parameters	:	p_api_version_number	IN NUMBER	Required
--					p_cal_tolerance_tbl		IN Table of records	Required
--						It is a table of records with each records having the
--						line_id, quantity being shipepd and planned quantity.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Get_Tolerance
(
	 p_api_version_number		IN	NUMBER
,    p_cal_tolerance_tbl		IN	Cal_Tolerance_Tbl_Type
,	 x_update_tolerance_flag	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_ship_tolerance			OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_ship_beyond_tolerance	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,	 x_shipped_within_tolerance	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_config_broken			OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,    x_return_status			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_msg_count				OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_msg_data					OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--	Start of Comments
--	API name    :	Get_Quantity
--	Type        :	Public
--	Pre-reqs	:	None.
--	Function	:	This procedure gets the ordered and shipped quantities for
--					the passed line_id. It will cumulate the ordered and shipped
--					quantities across the split lines for the passed line_id.
--	Parameters	:	p_api_version_number	IN NUMBER	Required
--					p_line_id				IN NUMBER 	Required
--						The line_id of the line for which the ordered and
--						shipped quantities are required.
--					p_line_set_id			IN NUMBER	Required
--						The line_set_id of the line for which the ordered and
--						shipped quantities are required.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Get_Quantity
(
	 p_api_version_number		IN	NUMBER
,    p_line_id					IN	NUMBER
,	 p_line_set_id				IN	NUMBER
,	 x_ordered_quantity    		OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_shipped_quantity    		OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_shipping_quantity    		OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_return_status			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_msg_count				OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_msg_data					OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--	Start of Comments
--	API name    :	Update_Shipping_Interface
--	Type        :	Public
--	Pre-reqs	:	None.
--	Function	:	This procedure will be called by shipping to update the
--					shipping_interface_flag on a line.
--	Parameters	:	p_api_version_number	IN NUMBER	Required
--					p_line_id				IN NUMBER 	Required
--						line id of the line which needs to be updated.
--					p_shipping_interfaced_flag	IN VARCHAR2 	Required
--						Value of the shipping interface flag.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Update_Shipping_Interface
(
	 p_api_version_number		IN	NUMBER
,    p_line_id					IN	NUMBER
,	 p_shipping_interfaced_flag	IN 	VARCHAR2
,    x_return_status			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_msg_count				OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_msg_data					OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--	Start of Comments
--	API name    :	Get_Max_Quantity_Remaining
--	Type        :	Public
--	Pre-reqs	:	None.
--	Function	:	This procedure will be called by to get the min and max quantity
--					remaining to be shipped for a line.
--	Parameters	:	p_api_version_number	IN NUMBER	Required
--					p_line_id				IN NUMBER 	Required
--						line id of the line for which the remaining quantity
--                      is requested.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
-- HW Added Qty2 for OPM
PROCEDURE Get_Min_Max_Tolerance_Quantity
(
     p_api_version_number	IN  NUMBER
,    p_line_id			IN  NUMBER
,    x_min_remaining_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_max_remaining_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_min_remaining_quantity2	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_max_remaining_quantity2	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_return_status		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,    x_msg_count		OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_msg_data			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

FUNCTION  Check_Import_Pending_Lines
( p_header_id              IN    NUMBER
 ,p_ship_set_id            IN    NUMBER
 ,p_top_model_line_id      IN    NUMBER
 ,p_transactable_flag      IN    VARCHAR2
 ,x_return_status          OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

PROCEDURE ATO_Config_Line_Ship_Notified( p_application_id               IN NUMBER,
                                 p_entity_short_name            in VARCHAR2,
                                 p_validation_entity_short_name in VARCHAR2,
                                 p_validation_tmplt_short_name  in VARCHAR2,
                                 p_record_set_tmplt_short_name  in VARCHAR2,
                                 p_scope                        in VARCHAR2,
                                 p_result                       OUT NOCOPY NUMBER );

END OE_Shipping_Integration_PUB;

 

/
