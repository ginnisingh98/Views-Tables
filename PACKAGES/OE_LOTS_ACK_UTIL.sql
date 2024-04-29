--------------------------------------------------------
--  DDL for Package OE_LOTS_ACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LOTS_ACK_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUSAKS.pls 120.0 2005/06/01 00:59:31 appldev noship $ */

PROCEDURE Insert_Row
(   p_line_tbl                 IN  OE_Order_Pub.Line_Tbl_Type
,   p_lot_serial_tbl           IN  OE_Order_Pub.Lot_Serial_Tbl_Type
,   p_lot_serial_val_tbl       IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type
,   p_old_line_tbl             IN  OE_Order_Pub.Line_Tbl_type
,   p_old_lot_serial_tbl       IN  OE_Order_Pub.Lot_Serial_Tbl_Type
,   p_old_lot_serial_val_tbl   IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type
,   p_reject_order             IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Delete_Row
(   p_orig_sys_document_ref         IN  VARCHAR2
,   p_change_sequence               IN  VARCHAR2
,   p_change_date                   IN  DATE
,   p_orig_sys_line_ref             IN  VARCHAR2
,   p_orig_sys_shipment_ref         IN  VARCHAR2
,   p_orig_sys_lot_serial_ref       IN  VARCHAR2
);

END OE_Lots_Ack_Util;

 

/
