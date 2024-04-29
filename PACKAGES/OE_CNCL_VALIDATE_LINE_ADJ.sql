--------------------------------------------------------
--  DDL for Package OE_CNCL_VALIDATE_LINE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_VALIDATE_LINE_ADJ" AUTHID CURRENT_USER AS
/* $Header: OEXVCLAS.pls 120.0 2005/06/01 22:54:47 appldev noship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
);



END OE_CNCL_Validate_Line_Adj;

 

/
