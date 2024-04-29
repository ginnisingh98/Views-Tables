--------------------------------------------------------
--  DDL for Package QP_VALIDATE_PLL_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_PLL_PRICING_ATTR" AUTHID CURRENT_USER AS
/* $Header: QPXLPLAS.pls 120.1.12010000.1 2008/07/28 11:54:10 appldev ship $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
);

/* New Procedure to check duplicates in Lines */

FUNCTION Check_Dup_Pra (   p_Start_Date_Active IN DATE
  					   , p_End_Date_Active IN DATE
					   , p_Revision IN VARCHAR2
					   , p_List_Line_ID IN NUMBER
					   , p_List_Header_ID IN NUMBER
					   , p_x_rows OUT NOCOPY NUMBER
					   , p_x_revision OUT NOCOPY BOOLEAN
					   , p_x_effdates OUT NOCOPY BOOLEAN
					   , p_x_dup_sdate OUT NOCOPY DATE
					   , p_x_dup_edate OUT NOCOPY DATE
					 )
RETURN BOOLEAN;


/* Added new From Jan18 */
FUNCTION Check_Line_Revision(   p_Revision IN VARCHAR2
					   , p_List_Line_ID IN NUMBER
					   , p_List_Header_ID IN NUMBER
					   , p_x_rows OUT NOCOPY /* file.sql.39 change */ NUMBER
					 )
RETURN BOOLEAN;

FUNCTION Check_Line_EffDates(    p_Start_Date_Active IN DATE
  					   , p_End_Date_Active IN DATE
					   , p_Revision IN VARCHAR2
					   , p_List_Line_ID IN NUMBER
					   , p_List_Header_ID IN NUMBER
					   , p_x_rows OUT NOCOPY /* file.sql.39 change */ NUMBER
					 )
RETURN BOOLEAN;

END QP_Validate_pll_pricing_attr;

/
