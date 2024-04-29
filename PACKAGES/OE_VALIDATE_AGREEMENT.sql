--------------------------------------------------------
--  DDL for Package OE_VALIDATE_AGREEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_AGREEMENT" AUTHID CURRENT_USER AS
/* $Header: OEXLAGRS.pls 120.1 2005/06/09 03:06:40 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
);

END OE_Validate_Agreement;

 

/
