--------------------------------------------------------
--  DDL for Package OE_CNCL_VALIDATE_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_VALIDATE_HEADER" AUTHID CURRENT_USER AS
/* $Header: OEXVCHDS.pls 120.0 2005/06/01 01:17:39 appldev noship $ */

--  Procedure Check_Book_Reqd_Attributes.

PROCEDURE Check_Book_Reqd_Attributes
( p_header_rec            IN OE_Order_PUB.Header_Rec_Type
, x_return_status         IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- FUNCTION Is_Duplicate_PO_Number
-- Is_Duplicate_PO_Number: Returns TRUE if the PO number is
-- referenced on another order for this customer

FUNCTION Is_Duplicate_PO_Number
( p_cust_po_number                  IN VARCHAR2
, p_sold_to_org_id                  IN NUMBER
, p_header_id                       IN NUMBER
) RETURN BOOLEAN;


--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
);


--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_header_rec           IN  OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_validation_level	    IN NUMBER := FND_API.G_VALID_LEVEL_FULL

);





END OE_CNCL_Validate_Header;

 

/
