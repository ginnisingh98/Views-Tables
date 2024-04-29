--------------------------------------------------------
--  DDL for Package OE_VALIDATE_LINE_PATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_LINE_PATTR" AUTHID CURRENT_USER AS
/* $Header: OEXLLPAS.pls 120.0 2005/06/04 11:12:46 appldev noship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Price_Attr_rec        IN  OE_Order_PUB.Line_Price_Att_Rec_Type
,   p_old_Line_Price_Attr_rec    IN  OE_Order_PUB.Line_Price_Att_Rec_Type := OE_Order_PUB.G_MISS_LINE_PRICE_ATT_REC
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Price_Attr_rec        IN  OE_Order_PUB.Line_Price_Att_Rec_Type
,   p_old_Line_Price_Attr_rec    IN  OE_Order_PUB.Line_Price_Att_Rec_Type := OE_Order_PUB.G_MISS_LINE_PRICE_ATT_REC
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Price_Attr_rec        IN  OE_Order_PUB.Line_Price_Att_Rec_Type
);

END OE_Validate_Line_PAttr;

 

/
