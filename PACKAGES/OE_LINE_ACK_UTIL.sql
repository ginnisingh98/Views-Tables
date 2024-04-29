--------------------------------------------------------
--  DDL for Package OE_LINE_ACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_ACK_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXULAKS.pls 120.0.12000000.1 2007/01/16 22:03:37 appldev ship $ */

PROCEDURE Insert_Row
(   p_line_tbl            IN  OE_Order_Pub.Line_Tbl_Type
,   p_line_val_tbl        IN  OE_Order_Pub.Line_Val_Tbl_Type
,   p_old_line_tbl        IN  OE_Order_Pub.Line_Tbl_Type
,   p_old_line_val_tbl    IN  OE_Order_Pub.Line_Val_Tbl_Type
,   p_buyer_seller_flag   IN  VARCHAR2 DEFAULT 'B'
,   p_reject_order        IN  VARCHAR2
,   p_ack_type            IN  VARCHAR2 := NULL
,   x_return_status	  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

Procedure Insert_Row
(  p_line_tbl             In  OE_Order_Pub.Line_Tbl_Type,
   p_old_line_tbl         In  OE_Order_Pub.Line_Tbl_Type,
   x_return_status        Out NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE Delete_Row
(   p_line_id         	  IN  NUMBER,
    p_ack_type            In  Varchar2,
    p_orig_sys_document_ref In Varchar2 := NULL,
    p_orig_sys_line_ref   In Varchar2 := NULL,
    p_orig_sys_shipment_ref In Varchar2 := NULL,
    p_sold_to_org_id      In   Number   := NULL,
    p_sold_to_org         In   Varchar2 := NULL,
    p_change_sequence     In   Varchar2 := NULL,
    p_request_id          In   Number   := NULL,
    p_header_id           In   Number   := NULL
);

END OE_Line_Ack_Util;

 

/
