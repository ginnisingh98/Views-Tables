--------------------------------------------------------
--  DDL for Package OE_LINE_ADJ_ASSOCS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_ADJ_ASSOCS_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXULASS.pls 120.0 2005/05/31 23:53:21 appldev noship $ */

PROCEDURE Query_Row
(   p_price_adj_assoc_id           IN  NUMBER
,   x_Line_Adj_Assoc_Rec			IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Rec_Type
);

PROCEDURE Query_Rows
(   p_price_adj_Assoc_id           IN  NUMBER :=
							    FND_API.G_MISS_NUM
,   p_price_adjustment_id          IN  NUMBER :=
							    FND_API.G_MISS_NUM
,   x_Line_Adj_Assoc_Tbl			IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
);

PROCEDURE Insert_Row
( p_Line_Adj_Assoc_Rec			IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Rec_Type
);

PROCEDURE Update_Row
( p_Line_Adj_Assoc_Rec			IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Rec_Type
);


PROCEDURE Delete_Row
( p_price_adj_Assoc_id     NUMBER := FND_API.G_MISS_NUM
,   p_price_adjustment_id     NUMBER := FND_API.G_MISS_NUM
)
;
--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_Line_Adj_Assoc_rec      IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Assoc_Rec_Type
,   p_old_Line_Adj_Assoc_rec    IN  OE_Order_PUB.Line_Adj_Assoc_Rec_Type
);


--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Adj_Assoc_rec        IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Rec_Type
);


--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Line_Adj_Assoc_rec      IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Rec_Type
,   p_old_Line_Adj_Assoc_rec    IN  OE_Order_PUB.Line_Adj_Assoc_Rec_Type := OE_Order_PUB.G_MISS_Line_Adj_Assoc_REC
-- ,   x_Line_Adj_Assoc_rec     OUT OE_Order_PUB.Line_Adj_Assoc_Rec_Type
);

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_Line_Adj_Assoc_rec       	IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Assoc_Rec_Type
,   p_price_adj_assoc_id			IN NUMBER := FND_API.G_MISS_NUM
-- ,   x_Line_Adj_Assoc_rec      	OUT OE_Order_PUB.Line_Adj_Assoc_Rec_Type
);

PROCEDURE Lock_Rows
(   p_price_adj_assoc_id		  IN NUMBER
							:= FND_API.G_MISS_NUM
,   p_price_adjustment_id	  IN NUMBER
							:= FND_API.G_MISS_NUM
,   x_Line_Adj_Assoc_tbl        OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

END OE_Line_Adj_Assocs_Util;

 

/
