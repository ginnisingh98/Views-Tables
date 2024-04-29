--------------------------------------------------------
--  DDL for Package QP_DEFAULT_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_PRICING_ATTR" AUTHID CURRENT_USER AS
/* $Header: QPXDPRAS.pls 120.1 2005/06/10 06:00:25 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Rec_Type
);

END QP_Default_Pricing_Attr;

 

/
