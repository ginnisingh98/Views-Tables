--------------------------------------------------------
--  DDL for Package OE_VALIDATE_LINE_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_LINE_SCREDIT" AUTHID CURRENT_USER AS
/* $Header: OEXLLSCS.pls 120.0 2005/06/01 00:30:05 appldev noship $ */

Procedure Validate_LSC_QUOTA_TOTAL
( x_return_status OUT NOCOPY VARCHAR2

  , p_line_id        IN NUMBER
  );

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Scredit_rec              IN  OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
);

--  Procedure Attributes

/* changed p_Line_Scredit_rec in the following procedure to p_Line_Scredit_rec to fix the bug 3006018 */

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Scredit_rec              IN  OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Scredit_rec              IN  OE_Order_PUB.Line_Scredit_Rec_Type
);

END OE_Validate_Line_Scredit;

 

/
