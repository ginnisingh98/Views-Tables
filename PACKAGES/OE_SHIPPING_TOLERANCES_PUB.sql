--------------------------------------------------------
--  DDL for Package OE_SHIPPING_TOLERANCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SHIPPING_TOLERANCES_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPTOLS.pls 120.0 2005/05/31 22:27:41 appldev noship $ */

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

PROCEDURE Get_Min_Max_quantity_Uom
(
     p_api_version_number	IN  NUMBER
,    p_line_id			IN  NUMBER
,    x_min_remaining_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_max_remaining_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_quantity_uom             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,    x_min_remaining_quantity2	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_max_remaining_quantity2	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_quantity_uom2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,    x_return_status		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,    x_msg_count		OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_msg_data			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);
END OE_Shipping_Tolerances_PUB;


 

/
