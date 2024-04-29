--------------------------------------------------------
--  DDL for Package QP_VALIDATE_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_PRICING_ATTR" AUTHID CURRENT_USER AS
/* $Header: QPXLPRAS.pls 120.1 2005/06/08 23:55:38 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
);

-- start bug2091362
/* Function to check duplicates in Modifier Lines */

FUNCTION MOD_DUP(p_Start_Date_Active IN DATE
                                   , p_End_Date_Active IN DATE
                                           , p_List_Line_ID IN NUMBER
                                           , p_List_Header_ID IN NUMBER
                                           , p_product_attribute_context IN VARCHAR2
                                           , p_product_attribute IN VARCHAR2
                                           , p_product_attr_value IN VARCHAR2
                                           , p_x_rows OUT NOCOPY /* file.sql.39 change */ NUMBER
                                           , p_x_effdates OUT NOCOPY /* file.sql.39 change */ BOOLEAN
                                           )RETURN BOOLEAN;
-- end 2091362


END QP_Validate_Pricing_Attr;

 

/
