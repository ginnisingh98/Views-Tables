--------------------------------------------------------
--  DDL for Package GME_UNRELEASE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_UNRELEASE_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVURBS.pls 120.8.12010000.2 2009/04/28 00:38:24 srpuri ship $ */
   PROCEDURE unrelease_batch (
      p_batch_header_rec        IN              gme_batch_header%ROWTYPE
     ,p_create_resv_pend_lots   IN              NUMBER
     ,x_batch_header_rec        OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status           OUT NOCOPY      VARCHAR2);

   PROCEDURE revert_material_full (
      p_material_detail_rec     IN            gme_material_details%ROWTYPE
     ,p_create_resv_pend_lots   IN            NUMBER
     ,p_ignore_transactable     IN            BOOLEAN DEFAULT FALSE
     ,x_actual_qty              OUT NOCOPY    NUMBER
     ,x_exception_material_tbl  IN OUT NOCOPY gme_common_pvt.exceptions_tab
     ,x_return_status           OUT NOCOPY    VARCHAR2);

   PROCEDURE unrelease_material (
      p_material_detail_rec     IN       gme_material_details%ROWTYPE
     ,p_update_inventory_ind    IN       VARCHAR2
     ,p_create_resv_pend_lots   IN       NUMBER
     ,p_from_batch              IN       BOOLEAN
     ,x_return_status           OUT NOCOPY VARCHAR2);

   PROCEDURE validate_batch_for_unrelease
               (p_batch_hdr_rec  IN gme_batch_header%ROWTYPE
               ,x_return_status  OUT NOCOPY VARCHAR2);

-- nsinghi Bug5176319. Added the proc.
   PROCEDURE create_matl_resv_pplot (
                p_material_dtl_id IN NUMBER,
                p_transaction_id  IN NUMBER, -- Bug 6997483
                x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE create_resv_pplot (
      p_material_detail_rec     IN       gme_material_details%ROWTYPE
     ,p_mmt_rec                 IN       mtl_material_transactions%ROWTYPE
     ,p_mmln_tbl                IN       gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2);

   /* Bug 5021522 added function RETURNS TRUE if inv will go negative and org control does not allow it */
   FUNCTION check_inv_negative(p_mmt_rec            IN mtl_material_transactions%ROWTYPE,
                               p_mmln_tbl           IN gme_common_pvt.mtl_trans_lots_num_tbl,
                               p_org_neg_control    IN NUMBER DEFAULT gme_common_pvt.g_allow_neg_inv,
                               p_item_no            IN VARCHAR2) RETURN BOOLEAN;
END gme_unrelease_batch_pvt;

/
