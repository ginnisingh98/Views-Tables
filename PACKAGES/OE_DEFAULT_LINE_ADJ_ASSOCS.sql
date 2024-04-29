--------------------------------------------------------
--  DDL for Package OE_DEFAULT_LINE_ADJ_ASSOCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_LINE_ADJ_ASSOCS" AUTHID CURRENT_USER AS
/* $Header: OEXDLASS.pls 120.0 2005/06/01 02:36:28 appldev noship $ */

--  Procedure Attributes

PROCEDURE Attributes
( p_x_Line_Adj_Assoc_rec		IN OUT NOCOPY	OE_Order_PUB.Line_Adj_Assoc_Rec_Type
--		:= OE_Order_PUB.G_MISS_Line_Adj_Assoc_REC
,   p_iteration               IN  NUMBER := 1
);

END OE_Default_Line_Adj_Assocs;

 

/
