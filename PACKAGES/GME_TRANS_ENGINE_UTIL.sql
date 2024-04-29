--------------------------------------------------------
--  DDL for Package GME_TRANS_ENGINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_TRANS_ENGINE_UTIL" AUTHID CURRENT_USER AS
/*  $Header: GMEUTXNS.pls 120.1 2005/06/03 10:57:03 appldev  $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMEUTXNS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For              |
 |     GME Material And Resource Transaction Load Routines                 |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-FEB-2001  H.Verdding                                             |
 |     15-APR-2004  Vipul Vaish  BUG#3528006                               |
 |     Added the set_default_lot_for_new_batch procedure for performance   |
 |     enhancement.                                                        |
 +=========================================================================+
  API Name  : GME_TRANS_ENGINE_UTIL
  Type      : Public
  Function  : This package contains public procedures used to create
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/
   PROCEDURE load_mat_and_rsc_trans (
      p_batch_row       IN              gme_batch_header%ROWTYPE
     ,x_mat_row_count   OUT NOCOPY      NUMBER
     ,x_rsc_row_count   OUT NOCOPY      NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   FUNCTION build_trans_rec (
      p_tran_row   IN              gme_inventory_txns_gtmp%ROWTYPE
     ,x_tran_rec   OUT NOCOPY      gmi_trans_engine_pub.ictran_rec)
      RETURN BOOLEAN;

   PROCEDURE load_rsrc_trans (
      p_batch_row       IN              gme_batch_header%ROWTYPE
     ,x_rsc_row_count   OUT NOCOPY      NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE set_default_lot_for_batch (
      p_batch_row       IN              gme_batch_header%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE set_default_lot_for_new_batch (
      x_return_status   OUT NOCOPY   VARCHAR2);

   PROCEDURE deduce_transaction_warehouse (
      p_transaction     IN              ic_tran_pnd%ROWTYPE
     ,p_item_master     IN              ic_item_mst%ROWTYPE
     ,x_whse_code       OUT NOCOPY      ps_whse_eff.whse_code%TYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE get_default_lot (
      p_line_id         IN              gme_material_details.material_detail_id%TYPE
     ,x_def_trans_id    OUT NOCOPY      ic_tran_pnd.trans_id%TYPE
     ,x_is_plain        OUT NOCOPY      BOOLEAN
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   p_default_loct   VARCHAR2 (80) := fnd_profile.VALUE ('IC$DEFAULT_LOCT');
END gme_trans_engine_util;

 

/
