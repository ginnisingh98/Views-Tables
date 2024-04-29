--------------------------------------------------------
--  DDL for Package GML_BATCH_OM_RES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_BATCH_OM_RES_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMLORESS.pls 115.4 2004/01/29 22:44:04 nchekuri noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIURSVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     Aug-18-2003  Liping Gao Created                                     |
 +=========================================================================+
  API Name  : GML_BATCH_OM_RES_PVT
  Type      : Private
  Function  : This package contains Private Utilities procedures used to
              OPM reservation for a batch.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/


 PROCEDURE create_reservation_from_FPO
 (
    P_FPO_batch_id           IN    NUMBER
  , P_New_batch_id           IN    NUMBER
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE create_allocations
 (
    P_batch_line_rec         IN    GML_BATCH_OM_UTIL.batch_line_rec
  , P_gme_om_rule_rec        IN    GML_BATCH_OM_UTIL.gme_om_rule_rec
  , P_Gme_trans_row          IN    ic_tran_pnd%rowtype
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE cancel_alloc_for_trans
 (
    P_Batch_trans_id         IN    NUMBER Default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE cancel_alloc_for_batch
 (
    P_Batch_id               IN    NUMBER Default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE cancel_alloc_for_batch_line
 (
    P_Batch_line_id          IN    NUMBER Default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE cancel_res_for_batch_line
 (
    P_Batch_line_id          IN    NUMBER default null
  , P_whse_code              IN    VARCHAR2 default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) ;
 PROCEDURE cancel_res_for_so_line
 (
    P_so_line_id             IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) ;
 PROCEDURE cancel_res_for_batch
 (
    P_Batch_id               IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) ;
 PROCEDURE cancel_batch
 (
    P_Batch_id               IN    NUMBER
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE notify_CSR
 (
    P_Batch_id               IN    NUMBER default null
  , P_Batch_line_id          IN    NUMBER default null
  , P_So_line_id             IN    NUMBER default null
  , P_batch_trans_id         IN    NUMBER default null
  , P_whse_code		     IN    VARCHAR2 default null
  , P_action_code	     IN    VARCHAR2
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );
 PROCEDURE regenerate_alloc
 (
    P_alloc_history_rec      IN  GML_BATCH_OM_UTIL.alloc_history_rec
  , x_return_status          OUT NOCOPY VARCHAR2
 );
 PROCEDURE process_om_reservations
 (
    P_from_batch_id          IN  NUMBER default null
  , P_batch_line_rec         IN  GML_BATCH_OM_UTIL.batch_line_rec
  , P_Gme_trans_row          IN  ic_tran_pnd%rowtype
  , P_batch_action           IN  VARCHAR2
  , x_return_status          OUT NOCOPY VARCHAR2
 );
PROCEDURE split_reservations
(    p_old_delivery_detail_id  IN  NUMBER
  ,  p_new_delivery_detail_id  IN  NUMBER
  ,  p_old_source_line_id      IN  NUMBER
  ,  p_new_source_line_id      IN  NUMBER
  ,  p_qty_to_split            IN  NUMBER
  ,  p_qty2_to_split           IN  NUMBER
  ,  p_orig_qty                IN  NUMBER
  ,  p_orig_qty2               IN  NUMBER
  ,  p_action                  IN  VARCHAR2
  ,  x_return_status           OUT NOCOPY VARCHAR2
  ,  x_msg_count               OUT NOCOPY NUMBER
  ,  x_msg_data                OUT NOCOPY VARCHAR2
 ) ;

 PROCEDURE split_reservations_from_om
 (   p_old_source_line_id      IN  NUMBER
  ,  p_new_source_line_id      IN  NUMBER
  ,  p_qty_to_split            IN  NUMBER    -- remaining qty to the old line_id
  ,  p_qty2_to_split           IN  NUMBER    -- remaining qty2 to the old line_id
  ,  p_orig_qty                IN  NUMBER
  ,  p_orig_qty2               IN  NUMBER
  ,  x_return_status           OUT NOCOPY VARCHAR2
  ,  x_msg_count               OUT NOCOPY NUMBER
  ,  x_msg_data                OUT NOCOPY VARCHAR2
 );

 PROCEDURE check_gmeres_for_so_line
 (   p_so_line_id          IN NUMBER
   , p_delivery_detail_id  IN NUMBER
   , x_return_status       OUT NOCOPY VARCHAR2
 );

 PROCEDURE pick_confirm
 (
    P_batch_line_rec         IN    GML_BATCH_OM_UTIL.batch_line_rec
  , P_Gme_trans_row          IN    ic_tran_pnd%rowtype
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );

END GML_BATCH_OM_RES_PVT;

 

/
