--------------------------------------------------------
--  DDL for Package OE_EDI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_EDI_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVEDIS.pls 115.6 2003/10/20 07:22:56 appldev ship $ */

--  Start of Comments
--  API name    EDI
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_EDI_PVT';


PROCEDURE PRE_PROCESS(
   p_header_rec		IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
  ,p_header_adj_tbl     IN OUT NOCOPY OE_Order_Pub.Header_Adj_Tbl_Type
  ,p_header_scredit_tbl IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_line_tbl		IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,p_line_adj_tbl	IN OUT NOCOPY OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_line_scredit_tbl   IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_lot_serial_tbl     IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type
  ,p_header_val_rec     IN OUT NOCOPY OE_Order_Pub.Header_Val_Rec_Type
  ,p_header_adj_val_tbl IN OUT NOCOPY OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_header_scredit_val_tbl IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_line_val_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,p_line_adj_val_tbl   IN OUT NOCOPY OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_line_scredit_val_tbl IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_lot_serial_val_tbl IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Val_Tbl_Type
,p_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE POST_PROCESS(
   p_header_rec			IN  	OE_Order_Pub.Header_Rec_Type
  ,p_header_adj_tbl             IN	OE_Order_Pub.Header_Adj_Tbl_Type
  ,p_header_scredit_tbl         IN	OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_line_tbl			IN  	OE_Order_Pub.Line_Tbl_Type
  ,p_line_adj_tbl		IN	OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_line_scredit_tbl           IN	OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_lot_serial_tbl             IN	OE_Order_Pub.Lot_Serial_Tbl_Type

  ,p_header_val_rec             IN	OE_Order_Pub.Header_Val_Rec_Type
  ,p_header_adj_val_tbl         IN	OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_header_scredit_val_tbl     IN	OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_line_val_tbl               IN	OE_Order_Pub.Line_Val_Tbl_Type
  ,p_line_adj_val_tbl           IN	OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_line_scredit_val_tbl       IN	OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_lot_serial_val_tbl         IN	OE_Order_Pub.Lot_Serial_Val_Tbl_Type

,p_return_status OUT NOCOPY VARCHAR2

);

END OE_EDI_PVT;

 

/
