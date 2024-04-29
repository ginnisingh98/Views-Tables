--------------------------------------------------------
--  DDL for Package OE_DEFAULT_CONTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_CONTRACT" AUTHID CURRENT_USER AS
/* $Header: OEXDPCTS.pls 115.0 99/07/15 19:21:10 porting shi $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Contract_rec                  OUT OE_Pricing_Cont_PUB.Contract_Rec_Type
);

END OE_Default_Contract;

 

/
