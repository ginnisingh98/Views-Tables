--------------------------------------------------------
--  DDL for Package OE_DEFAULT_HEADER_ADJ_ASSOCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_HEADER_ADJ_ASSOCS" AUTHID CURRENT_USER AS
/* $Header: OEXDHASS.pls 120.0 2005/06/01 00:30:18 appldev noship $ */

--  Procedure Attributes

PROCEDURE Attributes
( p_x_Header_Adj_Assoc_rec		IN OUT NOCOPY	OE_Order_PUB.Header_Adj_Assoc_Rec_Type
--		:= OE_Order_PUB.G_MISS_Header_Adj_Assoc_REC
,   p_iteration               IN  NUMBER := 1
);

END OE_Default_Header_Adj_Assocs;

 

/
