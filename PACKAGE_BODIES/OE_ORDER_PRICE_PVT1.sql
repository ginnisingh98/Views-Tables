--------------------------------------------------------
--  DDL for Package Body OE_ORDER_PRICE_PVT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_PRICE_PVT1" AS
/* $Header: OEXVPRCB.pls 115.10 2003/10/20 07:25:30 appldev ship $ */

/*
-- Price_Line is the main Pricing Integration API
-- It can be used to Price an order, an order line, or multiple lines
Procedure Price_line(
		 p_Header_id        	IN NUMBER	DEFAULT NULL
		,p_Line_id          	IN NUMBER	DEFAULT NULL
		,px_line_Tbl	        IN OUT NOCOPY   oe_Order_Pub.Line_Tbl_Type
		,p_Control_Rec		IN OE_ORDER_PRICE_PVT.control_rec_type
                ,p_Pricing_Events       IN VARCHAR2
		,x_Return_Status        OUT VARCHAR2
                )
is
Begin
    NULL;
End Price_Line;
*/
end OE_ORDER_PRICE_PVT1;

/
