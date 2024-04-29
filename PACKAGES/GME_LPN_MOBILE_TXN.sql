--------------------------------------------------------
--  DDL for Package GME_LPN_MOBILE_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_LPN_MOBILE_TXN" AUTHID CURRENT_USER AS
/*  $Header: GMELMTXS.pls 120.1 2005/11/11 08:35 nsinghi noship $   */
/*===========================================================================+
 |      Copyright (c) 2005 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 |===========================================================================|
 |                                                                           |
 | PL/SQL Package to support the (Java) GME Mobile Application.              |
 | Contains PL/SQL procedures used by mobile to transact material.           |
 |                                                                           |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 | Date          Who               What                                      |
 | ====          ===               ====                                      |
 | 21-Jul-05     Navin Sinha       First version                             |
 |                                                                           |
 +===========================================================================*/

  /* Transaction types for GME defined in MaterialTransaction.java */
  g_txn_source_type        NUMBER := 5;
  g_ing_issue              NUMBER := 35;
  g_ing_return             NUMBER := 43;
  g_prod_completion        NUMBER := 44;
  g_prod_return            NUMBER := 17;
  g_byprod_completion      NUMBER := 1002;
  g_byprod_return          NUMBER := 1003;


  TYPE t_genref IS REF CURSOR;

/*
PROCEDURE NAVIN_DEBUG (p_message   VARCHAR2);

  FUNCTION IS_MMTT_RECORD_PRESENT (p_lpn_id   IN NUMBER,
                                    txn_header_id OUT NUMBER,
                                    txn_temp_id    OUT NUMBER)
  RETURN BOOLEAN;
*/

 PROCEDURE Lpn_LoV
  (  x_line_cursor     OUT NOCOPY t_genref
  ,  p_org_id          IN  NUMBER
  ,  p_lpn_no          IN  VARCHAR2
  );

PROCEDURE Update_MO_Line
  (p_lpn_id 				  IN NUMBER,
   p_wms_process_flag 			  IN NUMBER,
   x_return_status                        OUT   NOCOPY VARCHAR2);

  PROCEDURE Create_Material_Txn(p_organization_id        IN NUMBER,
                                p_batch_id               IN NUMBER,
                                p_material_detail_id     IN NUMBER,
                                p_item_id                IN NUMBER,
                                p_revision               IN VARCHAR2,
                                p_subinventory_code      IN VARCHAR2,
                                p_locator_id             IN NUMBER,
                                p_txn_qty                IN NUMBER,
                                p_txn_uom_code           IN VARCHAR2,
                                p_sec_txn_qty            IN NUMBER,
                                p_sec_uom_code           IN VARCHAR2,
                                p_primary_uom_code       IN VARCHAR2,
                                p_txn_primary_qty        IN NUMBER,
                                p_reason_id              IN NUMBER,
                                p_txn_date               IN DATE,
                                p_txn_type_id            IN NUMBER,
                                p_phantom_type           IN NUMBER,
                                p_user_id                IN NUMBER,
                                p_login_id               IN NUMBER,
                                p_dispense_id            IN NUMBER,
--                                p_phantom_line_id        IN NUMBER,
                                p_lpn_id                 IN NUMBER,
                                x_txn_id                 OUT NOCOPY NUMBER,
                                x_txn_type_id            OUT NOCOPY NUMBER,
                                x_txn_header_id          OUT NOCOPY NUMBER,
                                x_return_status          OUT NOCOPY VARCHAR2,
                                x_error_msg              OUT NOCOPY VARCHAR2);

  PROCEDURE Process_Interface_Txn( p_txn_header_id IN NUMBER,
                                   p_user_id       IN NUMBER,
                                   p_login_id      IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_error_msg     OUT NOCOPY VARCHAR2);

  PROCEDURE get_prod_count (p_batch_id       IN NUMBER,
                            p_org_id         IN NUMBER,
                            x_prod_count     OUT NOCOPY NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2);


  PROCEDURE get_subinv_loc(p_batch_id           IN NUMBER
                           , p_org_id           IN NUMBER
                           , p_material_dtl_id  IN NUMBER
                           , x_subinventory     OUT NOCOPY VARCHAR2
                           , x_locator          OUT NOCOPY VARCHAR2
                           , x_locator_id       OUT NOCOPY NUMBER
                           , x_return_status    OUT NOCOPY VARCHAR2
                           , x_msg_data         OUT NOCOPY VARCHAR2);

END GME_LPN_MOBILE_TXN;

 

/
