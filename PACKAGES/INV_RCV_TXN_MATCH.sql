--------------------------------------------------------
--  DDL for Package INV_RCV_TXN_MATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_TXN_MATCH" AUTHID CURRENT_USER AS
/* $Header: INVRCVMS.pls 120.0.12000000.1 2007/01/17 16:28:28 appldev ship $*/

PROCEDURE matching_logic
  (x_return_status       	     OUT NOCOPY VARCHAR2,
   x_msg_count                       OUT NOCOPY NUMBER,
   x_msg_data                        OUT NOCOPY VARCHAR2,
   x_cascaded_table	          IN OUT  NOCOPY INV_RCV_COMMON_APIS.cascaded_trans_tab_type,
   n			          IN OUT  NOCOPY binary_integer,
   temp_cascaded_table            IN OUT  NOCOPY INV_RCV_COMMON_APIS.cascaded_trans_tab_type,
   p_receipt_num                     IN VARCHAR2,
   p_match_type                      IN VARCHAR2,
   p_lpn_id                          IN NUMBER
   );

END INV_RCV_TXN_MATCH;

 

/
