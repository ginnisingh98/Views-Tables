--------------------------------------------------------
--  DDL for Package OE_VALIDATE_HEADER_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_HEADER_SCREDIT" AUTHID CURRENT_USER AS
/* $Header: OEXLHSCS.pls 120.0 2005/05/31 23:55:26 appldev noship $ */

-- Procedure to validate quota percent total
G_Create_Auto_Sales_Credit varchar2(1) := 'Y';

Procedure Validate_HSC_QUOTA_TOTAL
( x_return_status OUT NOCOPY VARCHAR2

, p_header_id     IN  NUMBER);

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Scredit_rec            IN  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
);

--  Procedure Attributes

/* changed the p_Header_Scredit_rec to IN OUT NOCOPY in the following procedure  to fix the bug 3006018 */

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Scredit_rec            IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Scredit_rec            IN  OE_Order_PUB.Header_Scredit_Rec_Type
);

Procedure Validate_HSC_TOTAL_FOR_BK
( x_return_status OUT NOCOPY VARCHAR2

  , p_header_id          IN  NUMBER
  ) ;

END OE_Validate_Header_Scredit;

 

/
