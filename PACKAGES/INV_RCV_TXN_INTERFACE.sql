--------------------------------------------------------
--  DDL for Package INV_RCV_TXN_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_TXN_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: INVTISVS.pls 120.0.12000000.1 2007/01/17 16:31:50 appldev ship $*/

PROCEDURE matching_logic
  (x_return_status       	     OUT nocopy VARCHAR2,
   x_msg_count                       OUT nocopy NUMBER,
   x_msg_data                        OUT nocopy VARCHAR2,
   x_cascaded_table	          IN OUT nocopy INV_RCV_COMMON_APIS.cascaded_trans_tab_type,
   n			          IN OUT nocopy  binary_integer,
   temp_cascaded_table            IN OUT nocopy INV_RCV_COMMON_APIS.cascaded_trans_tab_type,
   p_receipt_num                     IN   VARCHAR2,
   p_shipment_header_id              IN   NUMBER,  -- this parameter is for ASN only, should leave it NULL for PO receipt
   p_lpn_id                          IN   NUMBER -- this parameter is for ASN only, should leave it NULL for PO receipt
   );

END INV_RCV_TXN_INTERFACE;

 

/
