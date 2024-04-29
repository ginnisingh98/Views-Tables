--------------------------------------------------------
--  DDL for Package OE_LINE_UTIL_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_UTIL_EXT" AUTHID CURRENT_USER AS
/* $Header: OEXULXTS.pls 120.0 2005/06/04 11:11:59 appldev noship $ */


FUNCTION G_Miss_OE_AK_Line_Rec
RETURN OE_AK_ORDER_LINES_V%ROWTYPE;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_LINE_rec                      IN  OE_Order_PUB.LINE_Rec_Type
,    x_rowtype_rec                  IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Order_PUB.LINE_Rec_Type
);

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_initial_line_rec              IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   p_old_line_rec                  IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   p_x_line_rec                    IN  OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_line_rec                    IN  OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
);

PROCEDURE Clear_Dep_And_Default
(   p_src_attr_tbl                  IN  OE_GLOBALS.Number_Tbl_Type
,   p_x_line_rec                    IN  OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type
);

END OE_Line_Util_Ext;

 

/
