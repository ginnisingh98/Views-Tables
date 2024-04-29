--------------------------------------------------------
--  DDL for Package OE_DEFAULT_PRICE_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_PRICE_LIST" AUTHID CURRENT_USER AS
/* $Header: OEXDPRHS.pls 115.2 1999/11/11 21:54:07 pkm ship      $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICE_LIST_rec                OUT OE_Price_List_PUB.Price_List_Rec_Type
);

END OE_Default_Price_List;

 

/
