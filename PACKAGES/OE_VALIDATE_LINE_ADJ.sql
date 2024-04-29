--------------------------------------------------------
--  DDL for Package OE_VALIDATE_LINE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_LINE_ADJ" AUTHID CURRENT_USER AS
/* $Header: OEXLLADS.pls 120.0 2005/06/01 00:22:41 appldev noship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_REC
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
);

END OE_Validate_Line_Adj;

 

/
