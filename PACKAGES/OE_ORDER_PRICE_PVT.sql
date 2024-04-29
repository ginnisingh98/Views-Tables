--------------------------------------------------------
--  DDL for Package OE_ORDER_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_PRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVOPRS.pls 120.1.12010000.1 2008/07/25 08:06:00 appldev ship $ */

G_STMT_NO			Varchar2(2000);

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_ORDER_PRICE_PVT';
G_SEEDED_PRICE_ERROR_HOLD_ID  CONSTANT NUMBER := 50;

-- Pricing Integration Control Record is to communicate with Caller and Pricing Engine
-- It can be expanded without making change to the signature of Price_Line
Type Control_Rec_Type is Record
(p_Request_Type_Code               VARCHAR2(3)    DEFAULT 'ONT'
,p_write_to_db                     BOOLEAN        DEFAULT TRUE
,p_honor_price_flag                VARCHAR2(1)    DEFAULT 'Y'
,p_multiple_events                 VARCHAR2(1)    DEFAULT 'N'
,p_use_current_header              BOOLEAN        DEFAULT FALSE
,p_calculate_flag                  VARCHAR2(30)   DEFAULT 'Y'
,p_simulation_flag                 VARCHAR2(1)    DEFAULT 'N'
,p_get_freight_flag                VARCHAR2(1)    DEFAULT 'N'
);

-- Price_Line is the main Pricing Integration API
-- It can be used to Price an order, an order line, or multiple lines
Procedure Price_line(
		 p_Header_id        	IN NUMBER	DEFAULT NULL
		,p_Line_id          	IN NUMBER	DEFAULT NULL
		,px_line_Tbl	        IN OUT NOCOPY   oe_Order_Pub.Line_Tbl_Type
		,p_Control_Rec		IN OE_ORDER_PRICE_PVT.control_rec_type
                ,p_action_code          IN VARCHAR2 DEFAULT 'NONE'
                ,p_Pricing_Events       IN VARCHAR2
--RT{
                ,p_request_rec          OE_Order_PUB.request_rec_type default oe_order_pub.G_MISS_REQUEST_REC
--RT}
,x_Return_Status OUT NOCOPY VARCHAR2
                );

--bucket man
procedure copy_Line_to_request(
 p_Line_rec                     OE_Order_PUB.Line_Rec_Type
,px_req_line_tbl                in out nocopy   QP_PREQ_GRP.LINE_TBL_TYPE
,p_pricing_events               varchar2
,p_request_type_code            varchar2
,p_honor_price_flag             varchar2
,px_line_index in out NOCOPY NUMBER
);

procedure copy_Header_to_request(
 p_header_rec           OE_Order_PUB.Header_Rec_Type
,px_req_line_tbl   in out NOCOPY QP_PREQ_GRP.LINE_TBL_TYPE
--,p_pricing_event      varchar2
,p_Request_Type_Code    varchar2
,p_calculate_price_flag varchar2
,px_line_index in out NOCOPY NUMBER
);

procedure Populate_Temp_Table;

procedure Append_asked_for(
        p_header_id             number
        ,p_Line_id                      number
        ,p_line_index                           number
        ,px_line_attr_index   in out NOCOPY number
);

PROCEDURE Reset_All_Tbls;

end OE_ORDER_PRICE_PVT;

/
