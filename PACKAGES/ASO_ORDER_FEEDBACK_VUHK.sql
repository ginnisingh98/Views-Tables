--------------------------------------------------------
--  DDL for Package ASO_ORDER_FEEDBACK_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_ORDER_FEEDBACK_VUHK" AUTHID CURRENT_USER as
/* $Header: asohomfs.pls 120.1 2005/06/29 12:31:52 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_ORDER_FEEDBACK_VUHK
-- Purpose          :
-- This package is the spec required for customer user hooks needed to
-- simplify the customization process. It consists of both the pre and
-- post processing APIs.

PROCEDURE Update_Notice_PRE(
  p_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type,
  p_old_header_rec              IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type,
  p_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type,
  p_old_Header_Adj_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type,
  p_Header_price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type,
  p_old_Header_Price_Att_tbl    IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type,
  p_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type,
  p_old_Header_Adj_Att_tbl      IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type,
  p_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
  p_old_Header_Adj_Assoc_tbl    IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
  p_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type,
  p_old_Header_Scredit_tbl      IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type,
  p_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type,
  p_old_line_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type,
  p_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type,
  p_old_Line_Adj_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type,
  p_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type,
  p_old_Line_Price_Att_tbl      IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type,
  p_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type,
  p_old_Line_Adj_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type,
  p_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
  p_old_Line_Adj_Assoc_tbl      IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
  p_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type,
  p_old_Line_Scredit_tbl        IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type,
  p_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type,
  p_old_Lot_Serial_tbl          IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type,
  p_action_request_tbl          IN OUT NOCOPY OE_Order_PUB.Request_Tbl_Type,
  X_Return_Status               OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
  X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */           NUMBER,
  X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */           VARCHAR2
);



PROCEDURE Update_Notice_Post(
  p_header_rec                  IN  OE_Order_PUB.Header_Rec_Type,
  p_old_header_rec              IN  OE_Order_PUB.Header_Rec_Type,
  p_Header_Adj_tbl              IN  OE_Order_PUB.Header_Adj_Tbl_Type,
  p_old_Header_Adj_tbl          IN  OE_Order_PUB.Header_Adj_Tbl_Type,
  p_Header_price_Att_tbl        IN  OE_Order_PUB.Header_Price_Att_Tbl_Type,
  p_old_Header_Price_Att_tbl    IN  OE_Order_PUB.Header_Price_Att_Tbl_Type,
  p_Header_Adj_Att_tbl          IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type,
  p_old_Header_Adj_Att_tbl      IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type,
  p_Header_Adj_Assoc_tbl        IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
  p_old_Header_Adj_Assoc_tbl    IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
  p_Header_Scredit_tbl          IN  OE_Order_PUB.Header_Scredit_Tbl_Type,
  p_old_Header_Scredit_tbl      IN  OE_Order_PUB.Header_Scredit_Tbl_Type,
  p_line_tbl                    IN  OE_Order_PUB.Line_Tbl_Type,
  p_old_line_tbl                IN  OE_Order_PUB.Line_Tbl_Type,
  p_Line_Adj_tbl                IN  OE_Order_PUB.Line_Adj_Tbl_Type,
  p_old_Line_Adj_tbl            IN  OE_Order_PUB.Line_Adj_Tbl_Type,
  p_Line_Price_Att_tbl          IN  OE_Order_PUB.Line_Price_Att_Tbl_Type,
  p_old_Line_Price_Att_tbl      IN  OE_Order_PUB.Line_Price_Att_Tbl_Type,
  p_Line_Adj_Att_tbl            IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type,
  p_old_Line_Adj_Att_tbl        IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type,
  p_Line_Adj_Assoc_tbl          IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
  p_old_Line_Adj_Assoc_tbl      IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
  p_Line_Scredit_tbl            IN  OE_Order_PUB.Line_Scredit_Tbl_Type,
  p_old_Line_Scredit_tbl        IN  OE_Order_PUB.Line_Scredit_Tbl_Type,
  p_Lot_Serial_tbl              IN  OE_Order_PUB.Lot_Serial_Tbl_Type,
  p_old_Lot_Serial_tbl          IN  OE_Order_PUB.Lot_Serial_Tbl_Type,
  p_action_request_tbl          IN  OE_Order_PUB.Request_Tbl_Type,
  X_Return_Status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */ NUMBER,
  X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

End ASO_ORDER_FEEDBACK_VUHK;

 

/
