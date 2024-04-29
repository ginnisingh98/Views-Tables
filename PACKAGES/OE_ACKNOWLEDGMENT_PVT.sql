--------------------------------------------------------
--  DDL for Package OE_ACKNOWLEDGMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ACKNOWLEDGMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVACKS.pls 120.0.12010000.1 2008/07/25 07:58:06 appldev ship $ */

/* -------------------------------------------------------------------
--  Start of Comments
--  API name    OE_Acknowledgment_Pvt
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
--  ------------------------------------------------------------------
*/

PROCEDURE Process_Acknowledgment
(p_api_version_number            IN  NUMBER
,p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE

,p_header_rec                    IN  OE_Order_Pub.Header_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_REC
,p_header_val_rec                IN  OE_Order_Pub.Header_Val_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_VAL_REC
,p_Header_Adj_tbl                IN  OE_Order_Pub.Header_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_TBL
,p_Header_Adj_val_tbl            IN  OE_Order_Pub.Header_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL
,p_Header_Scredit_tbl            IN  OE_Order_Pub.Header_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL
,p_Header_Scredit_val_tbl        IN  OE_Order_Pub.Header_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL
,p_line_tbl                      IN  OE_Order_Pub.Line_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_TBL
,p_line_val_tbl                  IN  OE_Order_Pub.Line_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_VAL_TBL
,p_Line_Adj_tbl                  IN  OE_Order_Pub.Line_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_TBL
,p_Line_Adj_val_tbl              IN  OE_Order_Pub.Line_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL
,p_Line_Scredit_tbl              IN  OE_Order_Pub.Line_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL
,p_Line_Scredit_val_tbl          IN  OE_Order_Pub.Line_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL
,p_Lot_Serial_tbl                IN  OE_Order_Pub.Lot_Serial_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_TBL
,p_Lot_Serial_val_tbl            IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_VAL_TBL
,p_action_request_tbl	    	 IN  OE_Order_Pub.Request_Tbl_Type :=
 				     OE_Order_Pub.G_MISS_REQUEST_TBL

,p_old_header_rec                IN  OE_Order_Pub.Header_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_REC
,p_old_header_val_rec            IN  OE_Order_Pub.Header_Val_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_VAL_REC
,p_old_Header_Adj_tbl            IN  OE_Order_Pub.Header_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_TBL
,p_old_Header_Adj_val_tbl        IN  OE_Order_Pub.Header_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL
,p_old_Header_Scredit_tbl        IN  OE_Order_Pub.Header_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL
,p_old_Header_Scredit_val_tbl    IN  OE_Order_Pub.Header_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL
,p_old_line_tbl                  IN  OE_Order_Pub.Line_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_TBL
,p_old_line_val_tbl              IN  OE_Order_Pub.Line_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_VAL_TBL
,p_old_Line_Adj_tbl              IN  OE_Order_Pub.Line_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_TBL
,p_old_Line_Adj_val_tbl          IN  OE_Order_Pub.Line_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL
,p_old_Line_Scredit_tbl          IN  OE_Order_Pub.Line_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL
,p_old_Line_Scredit_val_tbl      IN  OE_Order_Pub.Line_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL
,p_old_Lot_Serial_tbl            IN  OE_Order_Pub.Lot_Serial_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_TBL
,p_old_Lot_Serial_val_tbl        IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_VAL_TBL

,p_buyer_seller_flag             IN  VARCHAR2 DEFAULT 'B'
,p_reject_order                  IN  VARCHAR2 DEFAULT 'N'

,x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


Procedure Process_Acknowledgment
 (p_header_rec                   In   OE_Order_Pub.Header_Rec_Type,
  p_line_tbl                     In   OE_Order_Pub.Line_Tbl_Type,
  p_old_header_rec               In   OE_Order_Pub.Header_Rec_Type,
  p_old_line_tbl                 In   OE_Order_Pub.Line_Tbl_Type,
  x_return_status                Out NOCOPY /* file.sql.39 change */  VARCHAR2
 );

END OE_Acknowledgment_Pvt;


/
