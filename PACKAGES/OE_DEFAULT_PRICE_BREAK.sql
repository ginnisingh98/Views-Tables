--------------------------------------------------------
--  DDL for Package OE_DEFAULT_PRICE_BREAK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_PRICE_BREAK" AUTHID CURRENT_USER AS
/* $Header: OEXDDPBS.pls 115.0 99/07/15 19:20:45 porting shi $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Price_Break_rec               OUT OE_Pricing_Cont_PUB.Price_Break_Rec_Type
);

END OE_Default_Price_Break;

 

/
