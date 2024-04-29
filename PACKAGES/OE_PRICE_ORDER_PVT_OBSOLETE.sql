--------------------------------------------------------
--  DDL for Package OE_PRICE_ORDER_PVT_OBSOLETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PRICE_ORDER_PVT_OBSOLETE" AUTHID CURRENT_USER AS
/* $Header: OEXVPROS.pls 115.1 2004/05/18 22:00:44 aycui noship $ */

G_STMT_NO			Varchar2(2000);

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_PRICE_ORDER_PVT';

TYPE Price_Att_Rec_Type IS RECORD
(       header_id		number
,	line_id			number
, 	flex_title		varchar2(60)
,	pricing_context	        varchar2(30)
,	pricing_attribute	varchar2(30)
,	pricing_attr_value	varchar2(240)
,       Override_Flag		varchar2(1)
);

TYPE Price_Att_Tbl_Type is table of Price_Att_Rec_Type INDEX BY BINARY_INTEGER;

-- Price_Order is to simulate a OM pricing call to get the pricing information
-- It assumes the caller will pass all the information of the order to the call
-- For example,if your order has two lines and you only call with one line,
-- the call will price as if there is only one line
-- You can pass a line but not to reprice it by setting operation code to G_OPR_NONE
-- You can pass a line but freeze its price by setting calculate price flag to 'N'
-- This API assumes  the following setting:
--           Request_Type_Code: 'ONT'
--           Write_To_DB:       FALSE
--           Honor_Price_FLag:  'Y'
--           Calculate_flag:    'Y'
--           Simulation_Flag:   'Y'
--           Get_Freight_FLag:  'N'
Procedure Price_Order(
	         px_Header_rec          IN OUT NOCOPY   OE_ORDER_PUB.Header_Rec_Type
                ,px_line_Rec            IN OUT NOCOPY   OE_ORDER_PUB.Line_Rec_Type
--	        ,px_Line_Tbl	          IN OUT NOCOPY   OE_ORDER_PUB.Line_Tbl_Type
                ,px_Line_Adj_Tbl        IN OUT NOCOPY   OE_ORDER_PUB.Line_Adj_Tbl_Type
                ,p_Line_Price_Att_Tbl   IN              Price_Att_Tbl_Type
                ,p_action_code          IN VARCHAR2 DEFAULT 'NONE'
                ,p_Pricing_Events       IN VARCHAR2
                ,p_Simulation_Flag      IN VARCHAR2
                ,p_Get_Freight_Flag     IN VARCHAR2
                ,x_Return_Status        OUT NOCOPY VARCHAR2
                );

end OE_PRICE_ORDER_PVT_OBSOLETE;

 

/
