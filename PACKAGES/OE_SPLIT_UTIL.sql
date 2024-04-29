--------------------------------------------------------
--  DDL for Package OE_SPLIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SPLIT_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUSPLS.pls 120.1.12010000.1 2008/07/25 07:57:45 appldev ship $ */

g_sch_recursion varchar2(30) := 'FALSE';
g_non_prop_split boolean := FALSE;
g_split_action boolean := FALSE;

Type Split_qty_rec IS RECORD
(
Original_Quantity number := FND_api.g_miss_num,
Split_quantity  number := FND_Api.g_miss_num);

/* Defer Split ER Changes Start */
TYPE Split_Line_Rec_Type IS RECORD
( LINE_ID                                  NUMBER
, SPLIT_INDEX                              NUMBER
, REQUEST_ID                               NUMBER
, ORDERED_QUANTITY                         NUMBER
, ORDERED_QUANTITY2                        NUMBER
, REQUEST_DATE                             DATE
, SHIP_TO_ORG_ID                           NUMBER
, SHIP_FROM_ORG_ID                         NUMBER
, SPLIT_BY                                 VARCHAR2(30)
, CHANGE_REASON_CODE                       VARCHAR2(30)
, CHANGE_REASON_COMMENT                    VARCHAR2(2000)
);

Type Split_Line_Tbl_Type IS TABLE OF Split_Line_Rec_Type
INDEX BY BINARY_INTEGER;

/* Defer Split ER Changes End */

Type Split_line_rec IS RECORD
(
Line_id number := FND_api.g_miss_num,
Split_from_line_id  number := FND_Api.g_miss_num,
Quantity Number := Fnd_Api.g_miss_num);

Type Model_Map_rec IS RECORD
(
Line_id number := FND_api.g_miss_num,
link_to_line_id  number := FND_Api.g_miss_num,
ato_line_id Number := Fnd_Api.g_miss_num,
lindex number := Fnd_Api.g_miss_num);

Type Model_Map_Tbl IS TABLE OF Model_Map_Rec
index by binary_integer;

Type Split_line_Tbl IS TABLE OF split_line_rec
index by binary_integer;

Type Split_Qty_Tbl IS TABLE OF split_qty_rec
index by binary_integer;

Type Split_Lines IS TABLE OF NUMBER
index by binary_integer;

G_Split_Qty_Tbl split_qty_tbl;
G_Split_Line_Adj OE_ORDER_PUB.Line_Adj_Tbl_Type;
G_Split_line_Scredit OE_ORDER_PUB.Line_Scredit_Tbl_Type;
g_split_lines Split_lines;
g_split_insert_lines split_line_tbl;
g_split_line_tbl split_line_tbl;
g_split_tbl_index number := 0;
g_split_index number := 0;



--  Procedure Default_Attributes
Procedure Default_Attributes
	    (   p_x_line_rec      IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
            ,   p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type
            );

PROCEDURE Split_Line
(   p_x_line_rec                      IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
   , p_old_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
);


PROCEDURE Check_Split_Course(p_x_line_tbl IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type,
	       p_x_line_adj_tbl IN OUT NOCOPY OE_Order_Pub.Line_Adj_Tbl_Type,
            p_x_line_scredit_tbl IN OUT NOCOPY OE_Order_Pub.Line_scredit_Tbl_type
);

Procedure Cascade_non_proportional_Split(
					p_x_line_tbl IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type,
                         x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2) ;

PROCEDURE Record_line_History
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
);

Procedure Add_To_Fulfillment_Set(p_line_rec IN oe_order_pub.line_rec_type);


/* Defer Split ER Changes Start */

PROCEDURE Defer_Split
(  Errbuf	      OUT NOCOPY VARCHAR2
,  retcode	      OUT NOCOPY VARCHAR2
,  P_line_id      IN VARCHAR DEFAULT NULL
);


PROCEDURE Bulk_Insert (p_line_conc_tbl IN Split_Line_Tbl_Type);
/* Defer Split ER Changes End*/


END OE_Split_Util;

/
