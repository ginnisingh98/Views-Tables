--------------------------------------------------------
--  DDL for Package OE_REJECTED_LINES_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_REJECTED_LINES_ACK" AUTHID CURRENT_USER AS
/* $Header: OEXVRAKS.pls 115.8 2003/10/31 01:51:12 jjmcfarl ship $ */

G_PKG_NAME         VARCHAR2(30) := 'OE_Rejected_Lines_Ack';

PROCEDURE Get_Rejected_Lines(
   p_request_id			IN  NUMBER
  ,p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref  	IN  VARCHAR2
  ,p_change_sequence            IN  VARCHAR2
  ,x_rejected_line_tbl          IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,x_rejected_line_val_tbl     OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,x_rejected_lot_serial_tbl    IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type
  ,x_return_status             OUT NOCOPY VARCHAR2
  ,p_header_id                  IN NUMBER
  ,p_sold_to_org		IN VARCHAR2    := NULL
  ,p_sold_to_org_id             IN NUMBER      := NULL
);

END OE_Rejected_Lines_Ack;

 

/
