--------------------------------------------------------
--  DDL for Package OE_VALIDATE_HEADER_PATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_HEADER_PATTR" AUTHID CURRENT_USER AS
/* $Header: OEXLHPAS.pls 120.0.12000000.1 2007/01/16 21:53:27 appldev ship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Price_Attr_rec        IN  OE_Order_PUB.Header_Price_Att_Rec_Type
,   p_old_Header_Price_Attr_rec    IN  OE_Order_PUB.Header_Price_Att_Rec_Type
                                       := OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_REC
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Price_Attr_rec        IN  OE_Order_PUB.Header_Price_Att_Rec_Type
,   p_old_Header_Price_Attr_rec    IN  OE_Order_PUB.Header_Price_Att_Rec_Type
                                       := OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_REC
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Price_Attr_rec        IN  OE_Order_PUB.Header_Price_Att_Rec_Type
);

END OE_Validate_Header_PAttr;

 

/
