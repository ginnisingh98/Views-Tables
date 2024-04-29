--------------------------------------------------------
--  DDL for Package OE_VALIDATE_PRICE_BREAK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_PRICE_BREAK" AUTHID CURRENT_USER AS
/* $Header: OEXLDPBS.pls 115.0 99/07/15 19:24:11 porting shi $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT VARCHAR2
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT VARCHAR2
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT VARCHAR2
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
);

END OE_Validate_Price_Break;

 

/
