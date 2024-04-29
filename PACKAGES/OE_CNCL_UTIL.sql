--------------------------------------------------------
--  DDL for Package OE_CNCL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXVCGIS.pls 120.0.12000000.1 2007/01/16 22:07:51 appldev ship $ */

--  Function Get_Header_Ids

PROCEDURE Get_Header_Ids

(   p_x_header_rec   IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type
) ;

PROCEDURE Get_Line_Ids
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_line_val_rec                  IN  OE_Order_PUB.Line_Val_Rec_Type
) ;


PROCEDURE Get_Header_Scredit_Ids
(   p_x_Header_Scredit_rec  IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_Header_Scredit_val_rec   IN  OE_Order_PUB.Header_Scredit_Val_Rec_Type
) ;


PROCEDURE Get_Line_Scredit_Ids
(   p_x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_Line_Scredit_val_rec          IN  OE_Order_PUB.Line_Scredit_Val_Rec_Type
);


PROCEDURE Get_Header_Adj_Ids
(   p_x_Header_Adj_rec              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
,   p_Header_Adj_val_rec            IN  OE_Order_PUB.Header_Adj_Val_Rec_Type
);


PROCEDURE Get_Line_Adj_Ids
(   p_x_Line_Adj_rec                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
,   p_Line_Adj_val_rec              IN  OE_Order_PUB.Line_Adj_Val_Rec_Type
);

PROCEDURE Convert_Miss_To_Null
( p_x_header_rec        IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type);

PROCEDURE Convert_Miss_To_Null
(p_x_line_rec           IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type);

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Scredit_rec              IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Rec_Type
);

PROCEDURE Convert_Miss_To_Null
(   p_x_Header_Adj_rec                IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
);

PROCEDURE Convert_Miss_To_Null
(   p_x_Header_Scredit_rec  IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
);

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Adj_rec                  IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
);

END OE_CNCL_Util;

 

/
