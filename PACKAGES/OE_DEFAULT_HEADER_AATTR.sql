--------------------------------------------------------
--  DDL for Package OE_DEFAULT_HEADER_AATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_HEADER_AATTR" AUTHID CURRENT_USER AS
/* $Header: OEXDHAAS.pls 120.0 2005/05/31 23:27:57 appldev noship $ */

--  Procedure Attributes

PROCEDURE Attributes
( p_Header_Adj_Att_rec		IN 	out nocopy OE_Order_PUB.Header_Adj_Att_Rec_Type
,   p_iteration               IN  NUMBER := 1
--, x_Header_Adj_Att_rec	OUT 	OE_Order_PUB.Header_Adj_Att_Rec_Type
);

END OE_Default_Header_Aattr;

 

/
