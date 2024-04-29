--------------------------------------------------------
--  DDL for Package OE_ORDER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUORDS.pls 120.1.12010000.2 2010/10/06 11:06:44 srsunkar ship $ */

-- GET_ATTRIBUTE_NAME
-- Returns the translated display name of the attribute from the AK
-- dictionary based on the attribute code
-- Use this function to resolve message tokens that display attribute
-- names.
FUNCTION GET_ATTRIBUTE_NAME
        ( p_attribute_code               IN VARCHAR2
        )
RETURN VARCHAR2;

-- LOCK_ORDER_OBJECT
-- Locks the order object: order header, lines, sales credits and
-- price adjustments belonging to that order
PROCEDURE LOCK_ORDER_OBJECT
	(p_header_id			IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

	);

-- Globals for Notification Framework
-- Global to track Recursion since the regular recursion has some exceptions
-- to calls made out of workflow activities and treat them as independent as
--oppose to recursive.

G_Recursion_Without_Exception Varchar2(1) := 'N';

G_Header_Rec                 OE_Order_Pub.Header_Rec_Type :=
                                      OE_ORDER_PUB.G_MISS_HEADER_REC;
G_old_Header_Rec             OE_Order_Pub.Header_Rec_Type :=
                                      OE_ORDER_PUB.G_MISS_HEADER_REC;

G_line_tbl                   OE_Order_PUB.Line_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_LINE_TBL;
G_old_line_tbl                   OE_Order_PUB.Line_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_LINE_TBL;
G_Header_Scredit_tbl         OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL;

G_Old_Header_Scredit_tbl         OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL;

G_Old_Line_Scredit_tbl           OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL;

G_Line_Scredit_tbl           OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL;

G_old_Header_Adj_tbl         OE_Order_PUB.Header_Adj_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_HEADER_ADJ_TBL;

G_Header_Adj_tbl             OE_Order_PUB.Header_Adj_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_HEADER_ADJ_TBL;
G_old_Line_Adj_tbl           OE_Order_PUB.Line_Adj_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_LINE_ADJ_TBL;
G_Line_Adj_tbl               OE_Order_PUB.Line_Adj_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_LINE_ADJ_TBL;

G_old_Lot_Serial_tbl         OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_LOT_SERIAL_TBL;

G_Lot_Serial_tbl             OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                      OE_Order_PUB.G_MISS_LOT_SERIAL_TBL;

PROCEDURE Update_Global_Picture
(   p_Upd_New_Rec_If_Exists   IN BOOLEAN := TRUE
,   p_Header_Rec              IN OE_Order_Pub.Header_Rec_Type := NULL
,   p_Line_Rec                IN OE_Order_Pub.Line_Rec_Type := NULL
,   p_Hdr_Scr_Rec             IN OE_Order_Pub.Header_Scredit_Rec_Type := NULL
,   p_Hdr_Adj_Rec             IN OE_Order_Pub.Header_Adj_Rec_Type := NULL
,   p_Line_Adj_Rec            IN OE_Order_Pub.Line_Adj_Rec_Type := NULL
,   p_Line_Scr_Rec            IN OE_Order_Pub.Line_Scredit_Rec_Type := NULL
,   p_Lot_Serial_Rec          IN OE_Order_Pub.Lot_Serial_Rec_Type := NULL
,   p_old_Header_Rec          IN OE_Order_Pub.Header_Rec_Type := NULL
,   p_old_Line_Rec            IN OE_Order_Pub.Line_Rec_Type := NULL
,   p_old_Hdr_Scr_Rec         IN OE_Order_Pub.Header_Scredit_Rec_Type := NULL
,   p_old_Hdr_Adj_Rec         IN OE_Order_Pub.Header_Adj_Rec_Type := NULL
,   p_old_Line_Adj_Rec        IN OE_Order_Pub.Line_Adj_Rec_Type := NULL
,   p_old_Line_Scr_Rec        IN OE_Order_Pub.Line_Scredit_Rec_Type := NULL
,   p_old_Lot_Serial_Rec      IN OE_Order_Pub.Lot_Serial_Rec_Type := NULL
,   p_header_id               IN NUMBER := NULL
,   p_line_id                 IN NUMBER := NULL
,   p_hdr_scr_id              IN NUMBER := NULL
,   p_line_scr_id             IN NUMBER := NULL
,   p_hdr_adj_id              IN NUMBER := NULL
,   p_line_adj_id             IN NUMBER := NULL
,   p_lot_serial_id           IN NUMBER := NULL
, x_index OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

);



PROCEDURE Return_Glb_Ent_Index
(  p_entity_code    IN  VARCHAR2
,  p_entity_id      IN  NUMBER
, x_index OUT NOCOPY NUMBER

, x_result OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

);

/* Use this procedure to initialize the global pl/sql tables */


PROCEDURE Clear_Global_Picture( x_return_status OUT NOCOPY VARCHAR2);



PROCEDURE Initialize_Access_List;

PROCEDURE Add_Access
                  (Function_Name IN VARCHAR2);

FUNCTION IS_ACTION_IN_ACCESS_LIST
          (Action_code IN varchar2) RETURN BOOLEAN;

G_Access_List_Initialized Varchar2(1);

PROCEDURE Get_Access_List
                (
p_access_List OUT NOCOPY OE_GLOBALS.ACCESS_LIST);



G_Curr_Code Varchar2(80);

G_Header_Id Number;

G_Line_Id Number;

G_precision Number;

Function Get_Precision(
                         p_currency_code IN Varchar2 Default Null,
                         p_header_id     IN Number Default Null,
                         p_line_id       IN Number Default Null
                        )
RETURN BOOLEAN;

--OIP SUN ER CHANGES
PROCEDURE RAISE_BUSINESS_EVENT(
                               p_header_id IN Number Default Null,
                               p_line_id   IN Number Default Null,
                               p_status    IN Varchar2 Default Null
                               );
--End of OIP SUN ER CHANGES

END OE_ORDER_UTIL;

/
