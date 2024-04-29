--------------------------------------------------------
--  DDL for Package OE_DEFAULT_AGREEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_AGREEMENT" AUTHID CURRENT_USER AS
/* $Header: OEXDAGRS.pls 120.1 2005/06/08 03:54:14 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
);

END OE_Default_Agreement;

 

/
