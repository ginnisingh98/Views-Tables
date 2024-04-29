--------------------------------------------------------
--  DDL for Package OE_VALIDATE_PRICE_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_PRICE_LIST" AUTHID CURRENT_USER AS
/* $Header: OEXLPRHS.pls 120.1 2005/06/13 04:40:49 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
);

END OE_Validate_Price_List;

 

/
