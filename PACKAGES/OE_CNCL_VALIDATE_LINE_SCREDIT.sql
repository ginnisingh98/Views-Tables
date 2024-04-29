--------------------------------------------------------
--  DDL for Package OE_CNCL_VALIDATE_LINE_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_VALIDATE_LINE_SCREDIT" AUTHID CURRENT_USER AS
/* $Header: OEXVCLCS.pls 120.0 2005/05/31 23:53:04 appldev noship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Scredit_rec              IN  OE_Order_PUB.Line_Scredit_Rec_Type
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Line_Scredit_rec              IN  OE_Order_PUB.Line_Scredit_Rec_Type
);



END OE_CNCL_Validate_Line_Scredit;

 

/
