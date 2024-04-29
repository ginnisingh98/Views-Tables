--------------------------------------------------------
--  DDL for Package QP_DEFAULT_PLL_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_PLL_PRICING_ATTR" AUTHID CURRENT_USER AS
/* $Header: QPXDPLAS.pls 120.1 2005/06/10 03:24:47 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Rec_Type
);

FUNCTION Get_Product_Attribute_Datatype( prod_attribute_context  IN VARCHAR2,
                                         prod_attribute  IN VARCHAR2,
                                         prod_attr_value   IN VARCHAR2)
RETURN VARCHAR2;

END QP_Default_pll_pricing_attr;

 

/
