--------------------------------------------------------
--  DDL for Package OE_CNCL_VALIDATE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_VALIDATE_LINE" AUTHID CURRENT_USER AS
/* $Header: OEXVCLNS.pls 120.0 2005/06/01 23:18:26 appldev noship $ */

-- Procedure Check_book_reqd_attributes.
PROCEDURE Check_Book_Reqd_Attributes
( p_line_rec        IN OE_Order_PUB.Line_Rec_Type
, x_return_status   IN OUT NOCOPY VARCHAR2 /* file.sql.39 change */
);

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_line_rec                    IN  OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_validation_level		      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
);

FUNCTION Get_Item_Type(p_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN VARCHAR2;

END OE_CNCL_Validate_Line;

 

/
