--------------------------------------------------------
--  DDL for Package INV_RCV_MOBILE_PROCESS_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_MOBILE_PROCESS_TXN" AUTHID CURRENT_USER AS
/* $Header: INVRCVPS.pls 120.1.12010000.2 2009/06/24 07:09:44 aditshar ship $*/


PROCEDURE rcv_process_receive_txn(x_return_status OUT nocopy VARCHAR2,
				  x_msg_data      OUT nocopy VARCHAR2);

-- procedure  check_existing_parent_lot and create_lot_uom_conversion added as part of bug# 8539263
Procedure lot_uom_conversion(
				    p_org_id              IN  NUMBER
   ,  p_itemid                IN   NUMBER
   ,  p_from_uom_code         IN  VARCHAR2
   ,  p_to_uom_code           IN  VARCHAR2
   ,  p_lot_number            IN  VARCHAR2
   ,  p_user_response         IN  NUMBER
   ,  p_create_lot_uom_conv   IN NUMBER
   ,  p_conversion_rate       IN NUMBER
    , x_return_status OUT nocopy VARCHAR2,
				   x_msg_data       OUT nocopy VARCHAR2

   ) ;
   PROCEDURE check_existing_lot
 (  p_org_id      IN NUMBER
  , p_item_id     IN NUMBER
  , p_lot_number  IN VARCHAR2
  , x_lot_exist   OUT NOCOPY NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  , x_msg_data OUT NOCOPY VARCHAR2
);
END INV_RCV_MOBILE_PROCESS_TXN;

/
