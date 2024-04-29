--------------------------------------------------------
--  DDL for Package OE_CNCL_VALIDATE_HEADER_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_VALIDATE_HEADER_ADJ" AUTHID CURRENT_USER AS
/* $Header: OEXVCHAS.pls 120.0 2005/06/01 00:26:11 appldev noship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
);



END OE_CNCL_Validate_Header_Adj;

 

/
