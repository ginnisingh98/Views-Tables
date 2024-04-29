--------------------------------------------------------
--  DDL for Package OE_DEFAULT_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_PRICE_LIST_LINE" AUTHID CURRENT_USER AS
/* $Header: OEXDPRLS.pls 120.1 2005/06/15 23:16:05 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Rec_Type
);

END OE_Default_Price_List_Line;

 

/
