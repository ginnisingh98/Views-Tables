--------------------------------------------------------
--  DDL for Package OE_VALIDATE_HEADER_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_HEADER_ADJ" AUTHID CURRENT_USER AS
/* $Header: OEXLHADS.pls 120.0 2005/06/01 00:24:13 appldev noship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
);

END OE_Validate_Header_Adj;

 

/
