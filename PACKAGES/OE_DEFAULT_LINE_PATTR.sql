--------------------------------------------------------
--  DDL for Package OE_DEFAULT_LINE_PATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_LINE_PATTR" AUTHID CURRENT_USER AS
/* $Header: OEXDLPAS.pls 120.0 2005/06/01 01:03:24 appldev noship $ */

--  Procedure Attributes

PROCEDURE Attributes
( p_x_Line_Price_Att_rec		IN OUT NOCOPY	OE_Order_PUB.Line_Price_Att_Rec_Type
,   p_iteration               IN  NUMBER := 1
);

END OE_Default_Line_PAttr;

 

/
