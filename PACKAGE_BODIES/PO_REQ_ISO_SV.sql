--------------------------------------------------------
--  DDL for Package Body PO_REQ_ISO_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_ISO_SV" AS
/* $Header: POXISOCB.pls 115.2 2002/11/23 03:28:39 sbull noship $ */

PROCEDURE Call_Process_Order(x_oe_header_id   IN  NUMBER,
                             x_oe_line_id     IN  NUMBER,
                             x_oe_line_qty    IN  NUMBER,
                             x_cancel_reason IN VARCHAR2,
                             x_msg_data    OUT NOCOPY VARCHAR2,
                             x_msg_count   OUT NOCOPY NUMBER,
                             l_return_status    OUT NOCOPY  VARCHAR2) IS

l_Header_price_Att_tbl		OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl		OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl		OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl			OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl		OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_hdr_rec                     OE_Order_PUB.Header_Rec_Type;
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_line_adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_line_adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_lot_serial_tbl	      OE_Order_PUB.lot_serial_tbl_type;
l_header_val_rec         OE_Order_PUB.header_val_rec_type;
l_line_val_tbl           OE_Order_PUB.line_val_tbl_type;
l_line_adj_val_tbl         OE_Order_PUB.line_adj_val_tbl_type;
l_line_scredit_val_tbl      OE_Order_PUB.line_scredit_val_tbl_type;
l_header_scredit_val_tbl   OE_Order_PUB.header_scredit_val_tbl_type;
l_header_adj_val_tbl       OE_Order_PUB.header_adj_val_tbl_type;
l_lot_serial_val_tbl      OE_Order_PUB.lot_serial_val_tbl_type;

x_progress             varchar2(3);

BEGIN

x_progress := '000';
/* dreddy-iso : set the line_id,cancel reason and quantity .
   This is for line level cancellation */

IF x_oe_line_id is not null THEN
  l_line_rec := OE_Order_PUB.G_MISS_LINE_REC;

  l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
  l_line_rec.line_id := x_oe_line_id;
  l_line_rec.ordered_quantity := x_oe_line_qty;
  l_line_rec.change_reason := x_cancel_reason;
  l_line_tbl(1) := l_line_rec;
END IF;

x_progress := '010';
/* dreddy-iso : set the header id and cancel reason.
   this is for header level cancellation */

IF x_oe_header_id is not null THEN
  l_hdr_rec := OE_Order_PUB.G_MISS_HEADER_REC;

  l_hdr_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
  l_hdr_rec.header_id := x_oe_header_id;
  l_hdr_rec.change_reason := x_cancel_reason;
  l_x_header_rec := l_hdr_rec;
END IF;

x_progress := '020';

/* dreddy-iso : call OM's process order API */
OE_Order_GRP.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_line_tbl	              => l_line_tbl
    ,   x_header_rec                  => l_x_header_rec
    ,   x_Header_Adj_tbl              => l_x_Header_Adj_tbl
    ,   x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
    ,   x_line_tbl                    => l_x_line_tbl
    ,   x_Line_Adj_tbl                => l_x_Line_Adj_tbl
    ,   x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
    ,   x_action_request_tbl          => l_x_action_request_tbl
    ,   x_Lot_Serial_tbl	      => l_x_lot_serial_tbl
    ,   x_Header_price_Att_tbl	      => l_Header_price_Att_tbl
    ,   x_Header_Adj_Att_tbl	      => l_Header_Adj_Att_tbl
    ,   x_Header_Adj_Assoc_tbl	      => l_Header_Adj_Assoc_tbl
    ,   x_Line_price_Att_tbl	      => l_Line_price_Att_tbl
    ,   x_Line_Adj_Att_tbl	      => l_Line_Adj_Att_tbl
    ,   x_Line_Adj_Assoc_tbl	      => l_Line_Adj_Assoc_tbl
    ,   x_header_val_rec	      => l_header_val_rec
    ,   x_Header_Adj_val_tbl	      => l_header_adj_val_tbl
    ,   x_Header_Scredit_val_tbl      => l_header_scredit_val_tbl
    ,   x_line_val_tbl                => l_line_val_tbl
    ,   x_Line_Adj_val_tbl            => l_line_adj_val_tbl
    ,   x_Line_Scredit_val_tbl        => l_line_scredit_val_tbl
    ,   x_Lot_Serial_val_tbl          => l_lot_serial_val_tbl
    );

    x_progress := '030';

 EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('po_req_iso_sv.call_process_order', x_progress,sqlcode);
   RAISE;

END;

/*==============================================================
 * dreddy-iso : function to get the return status
 * get_return_code()
 *=============================================================*/
FUNCTION get_return_code(x_status IN varchar2) return VARCHAR2 IS
BEGIN

  if x_status = FND_API.G_RET_STS_SUCCESS then
     return ('TRUE');
  else
     return ('FALSE');
  end if;

EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('po_req_iso_sv.get_return_code','000',sqlcode);
   RAISE;
END;

END PO_REQ_ISO_SV;

/
