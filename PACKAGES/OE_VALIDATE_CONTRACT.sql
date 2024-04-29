--------------------------------------------------------
--  DDL for Package OE_VALIDATE_CONTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_CONTRACT" AUTHID CURRENT_USER AS
/* $Header: OEXLPCTS.pls 115.0 99/07/15 19:24:41 porting shi $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT VARCHAR2
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT VARCHAR2
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT VARCHAR2
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
);

END OE_Validate_Contract;

 

/
