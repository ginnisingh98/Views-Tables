--------------------------------------------------------
--  DDL for Package OE_VALIDATE_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_PRICE_LIST_LINE" AUTHID CURRENT_USER AS
/* $Header: OEXLPRLS.pls 115.2 99/10/14 22:17:05 porting ship  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
);


---- New Added
PROCEDURE Check_PLL_Duplicates
(   x_return_status                 OUT VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
);


--- Geresh
--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
);

END OE_Validate_Price_List_Line;

 

/
