--------------------------------------------------------
--  DDL for Package OE_ORDER_IMPORT_RESERVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_IMPORT_RESERVE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVIMRS.pls 120.0.12010000.1 2008/07/25 08:04:11 appldev ship $ */

--  Start of Comments
--  API name    OE_ORDER_IMPORT_RESERVE_PVT
--  Type        Private
--  Purpose  	Inventory Reservation
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_ORDER_IMPORT_RESERVE_PVT';

PROCEDURE Reserve_Inventory(
   p_header_rec                 IN  OE_Order_Pub.Header_Rec_Type
  ,p_line_tbl                   IN  OE_Order_Pub.Line_Tbl_Type
  ,p_reservation_tbl		IN  OE_Order_Pub.Reservation_Tbl_Type
  ,p_header_val_rec             IN  OE_Order_Pub.Header_Val_Rec_Type
  ,p_line_val_tbl               IN  OE_Order_Pub.Line_Val_Tbl_Type
  ,p_reservation_val_tbl	IN  OE_Order_Pub.Reservation_Val_Tbl_Type
,p_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Create_Reservation(
   p_rsv       		IN  INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE
,p_rsv_id OUT NOCOPY NUMBER

,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY VARCHAR2

,p_return_status OUT NOCOPY VARCHAR2

);

END OE_ORDER_IMPORT_RESERVE_PVT;

/
