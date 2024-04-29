--------------------------------------------------------
--  DDL for Package OE_CHARGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CHARGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVCHRS.pls 120.0 2005/06/01 02:53:55 appldev noship $ */

-- Procedure to get charge totals at Order Line or Order Header level
-- If the header_id is passed and line_id is NULL then total for charges at
-- Order Header level is returned
-- If header_id and line_id is passed then total for charges at Order line
-- level is returned.

 PROCEDURE Get_Charge_Amount
 (   p_api_version_number            IN  NUMBER
 ,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
 ,   p_header_id                     IN  NUMBER
 ,   p_line_id                       IN  NUMBER
 ,   p_all_charges                   IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

, x_charge_amount OUT NOCOPY NUMBER

 );

-- Function to source the Qualifier Attribute FREIGHT_COST_TYPE
-- If the Order line is Shippable and shipping has transferred all costs for
-- this line, then this function finds and returns all cost_type_codes from
-- OE_PRICE_ADJUSTMENTS table where costs are maintained. It returns a table of
-- VARCHAR2 as output.

 FUNCTION Get_Cost_Types
 RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

-- Function to source the Pricing Attributes for COST_AMOUNTS.
-- If the Order line is Shippable and shipping has transferred all costs for
-- this line, then this function takes the cost_type_code as an input and finds
-- the cost amount for this cost_type_code from OE_PRICE_ADJUSTMENTS table.

 FUNCTION Get_Cost_Amount
 (   p_cost_type_code                IN  VARCHAR2
 )RETURN VARCHAR2;

-- This function will be used to source the Qualifier Attribute "SHIPPED_FLAG"
-- It will be calling the OE_.Get_Ship_Status to get the line status.

 FUNCTION Get_Shipped_status
 RETURN VARCHAR2;

-- This procedure will be used by the Pricing Request before applying the
-- charges to the Order. It will check for duplicate charges of same
-- charge_type and charge_subtyp. If more that one found then it will select
-- the charge with maximum amount.

PROCEDURE Check_Duplicate_Line_Charges
(
   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
 , p_x_line_adj_tbl                  IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
 , p_x_line_adj_att_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
);

-- This procedure will be used by the Pricing Request before applying the
-- charges to the Order. It will check for duplicate charges of same
-- charge_type and charge_subtype. If more that one found then it will select
-- the charge with maximum amount.

PROCEDURE Check_Duplicate_Header_Charges
(
   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
 , p_x_Header_adj_tbl                IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
 , p_x_Header_adj_att_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
);

-- This procedure will be used in Process Order API to check if any duplicate
-- charges exists on a Order Header or a Line before applying any charge.

PROCEDURE Check_Duplicate_Charges
(
   p_Header_id              IN  NUMBER
 , p_line_id                IN  NUMBER
 , p_charge_type_code       IN  VARCHAR2
 , p_charge_subtype_code    IN  VARCHAR2
, x_duplicate_flag OUT NOCOPY VARCHAR2

);

-- This function will be used to source the qualifier attributes LINE_WEIGHT
-- and LINE_VOLUME. It will lookup at the following profile options to get the
-- target UOM for weight and volume. QP: Line Volume UOM Code and
-- QP: Line Weight UOM Code. Then the procedure will call the conversion
-- routine to get the values.

FUNCTION Get_Line_Weight_Or_Volume
 (   p_uom_class        IN  VARCHAR2
 )RETURN VARCHAR2;


--This procedure is to debug charges.
--incomplete...
Procedure Freight_Debug(p_header_name  In Varchar2 default null,
                                          p_list_line_id In Number   default null,
                                          p_line_id      In Number,
                                          p_org_id       In Number);

--Recurring Charges
PROCEDURE Get_Rec_Charge_Amount
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_header_id                     IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_all_charges                   IN  VARCHAR2 := FND_API.G_FALSE
,   p_charge_periodicity_code       IN  VARCHAR2
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   x_charge_amount                 OUT NOCOPY NUMBER
);
--Recurring Charges

END OE_Charge_PVT;

 

/
