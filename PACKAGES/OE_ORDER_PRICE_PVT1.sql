--------------------------------------------------------
--  DDL for Package OE_ORDER_PRICE_PVT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_PRICE_PVT1" AUTHID CURRENT_USER AS
/* $Header: OEXVPRCS.pls 115.4 2003/10/20 07:25:32 appldev noship $ */

G_STMT_NO			Varchar2(2000);

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_ORDER_PRICE_PVT1';

-- Pricing Integration Control Record is to communicate with Caller and Pricing Engine
-- It can be expanded without making change to the signature of Price_Line
/*
Type Control_Rec_Type is Record
(p_Request_Type_Code               VARCHAR2(3)    DEFAULT 'ONT'
,p_write_to_db                     BOOLEAN        DEFAULT TRUE
,p_honor_price_flag                VARCHAR2(1)    DEFAULT 'Y'
,p_multiple_events                 VARCHAR2(1)    DEFAULT 'N'
,p_use_current_header              BOOLEAN        DEFAULT FALSE
);

-- Price_Line is the main Pricing Integration API
-- It can be used to Price an order, an order line, or multiple lines
Procedure Price_line(
		 p_Header_id        	IN NUMBER	DEFAULT NULL
		,p_Line_id          	IN NUMBER	DEFAULT NULL
		,px_line_Tbl	        IN OUT NOCOPY   oe_Order_Pub.Line_Tbl_Type
		,p_Control_Rec		IN OE_ORDER_PRICE_PVT.control_rec_type
                ,p_Pricing_Events       IN VARCHAR2
,x_Return_Status OUT NOCOPY VARCHAR2

                );
*/
end OE_ORDER_PRICE_PVT1;

 

/
