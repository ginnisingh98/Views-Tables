--------------------------------------------------------
--  DDL for Package OE_DEFAULT_HEADER_PATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_HEADER_PATTR" AUTHID CURRENT_USER AS
/* $Header: OEXDHPAS.pls 120.0.12000000.1 2007/01/16 21:48:59 appldev ship $ */

--  Procedure Attributes

PROCEDURE Attributes
( p_x_Header_Price_Att_rec		IN OUT NOCOPY	OE_Order_PUB.Header_Price_Att_Rec_Type
,   p_iteration               IN  NUMBER := 1
);

END OE_Default_Header_PAttr;

 

/
