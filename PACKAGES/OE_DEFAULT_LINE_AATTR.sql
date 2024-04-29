--------------------------------------------------------
--  DDL for Package OE_DEFAULT_LINE_AATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_LINE_AATTR" AUTHID CURRENT_USER AS
/* $Header: OEXDLAAS.pls 120.0 2005/06/01 23:15:01 appldev noship $ */

--  Procedure Attributes

PROCEDURE Attributes
( p_Line_Adj_Att_rec		IN 	out nocopy OE_Order_PUB.Line_Adj_Att_Rec_Type
,   p_iteration               IN  NUMBER := 1
--, x_Line_Adj_Att_rec	OUT 	OE_Order_PUB.Line_Adj_Att_Rec_Type
);

END OE_Default_Line_Aattr;

 

/
