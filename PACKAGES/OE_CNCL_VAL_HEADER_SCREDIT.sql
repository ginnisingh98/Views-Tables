--------------------------------------------------------
--  DDL for Package OE_CNCL_VAL_HEADER_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_VAL_HEADER_SCREDIT" AUTHID CURRENT_USER AS
/* $Header: OEXVCHCS.pls 120.0 2005/06/01 00:35:25 appldev noship $ */

-- Procedure to validate quota percent total
G_Create_Auto_Sales_Credit varchar2(1) := 'Y';


--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Scredit_rec            IN  OE_Order_PUB.Header_Scredit_Rec_Type
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Scredit_rec            IN  OE_Order_PUB.Header_Scredit_Rec_Type
);


END OE_CNCL_Val_Header_Scredit;

 

/
