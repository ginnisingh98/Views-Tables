--------------------------------------------------------
--  DDL for Package GME_RELEASE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_RELEASE_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVRLBS.pls 120.9.12010000.2 2009/04/28 00:33:48 srpuri ship $ */

  g_bypass_txn_creation            NUMBER                           := 0;

  PROCEDURE release_batch
              (p_batch_header_rec           IN         gme_batch_header%ROWTYPE
              ,p_phantom_product_id         IN         NUMBER DEFAULT NULL
              ,p_yield                      IN         BOOLEAN DEFAULT NULL
              ,x_exception_material_tbl     IN  OUT NOCOPY   gme_common_pvt.exceptions_tab
              ,x_batch_header_rec           OUT NOCOPY gme_batch_header%ROWTYPE
              ,x_return_status              OUT NOCOPY VARCHAR2);

  PROCEDURE process_ingredient
              (p_material_detail_rec        IN         gme_material_details%ROWTYPE
              ,p_consume                    IN         BOOLEAN
              ,p_trans_date                 IN         DATE
              ,p_update_inv_ind             IN         VARCHAR2
              ,x_exception_material_tbl     IN  OUT NOCOPY   gme_common_pvt.exceptions_tab
              ,x_return_status              OUT NOCOPY       VARCHAR2);

  PROCEDURE consume_material(p_material_dtl_rec  IN gme_material_details%ROWTYPE
                            ,p_consume_qty       IN NUMBER := NULL
                            ,p_trans_date        IN DATE := NULL
                            ,p_item_rec          IN mtl_system_items_b%ROWTYPE
                            ,x_exception_material_tbl    IN OUT NOCOPY gme_common_pvt.exceptions_tab
                            ,x_actual_qty        OUT NOCOPY NUMBER
                            ,x_return_status     OUT NOCOPY VARCHAR2);
  PROCEDURE build_and_create_transaction
              (p_rsrv_rec              IN mtl_reservations%ROWTYPE
              ,p_lot_divisible_flag    IN VARCHAR2 DEFAULT NULL  -- required for lot non divisible
              ,p_dispense_ind          IN VARCHAR2 DEFAULT NULL
              ,p_subinv                IN VARCHAR2 DEFAULT NULL
              ,p_locator_id            IN NUMBER DEFAULT NULL
              ,p_att                   IN NUMBER DEFAULT NULL
              ,p_satt                  IN NUMBER DEFAULT NULL
              ,p_primary_uom_code      IN VARCHAR2 DEFAULT NULL
              ,p_mtl_dtl_rec           IN gme_material_details%ROWTYPE
              ,p_trans_date            IN DATE
              ,p_consume_qty           IN NUMBER
              ,p_called_by             IN VARCHAR2 DEFAULT 'REL' --Bug 6778968
              ,p_revision              IN VARCHAR2 DEFAULT NULL
              ,p_secondary_uom_code    IN VARCHAR2 DEFAULT NULL
              ,x_actual_qty            IN OUT NOCOPY NUMBER
              ,x_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE  constr_mmti_from_reservation
    (p_rsrv_rec              IN   mtl_reservations%ROWTYPE
    ,x_mmti_rec              OUT  NOCOPY mtl_transactions_interface%ROWTYPE
    ,x_mmli_tbl              OUT  NOCOPY gme_common_pvt.mtl_trans_lots_inter_tbl
    ,x_return_status         OUT  NOCOPY VARCHAR2);

  PROCEDURE constr_mmti_from_qty_tree
        (p_mtl_dtl_rec            IN gme_material_details%ROWTYPE
        ,p_subinv                 IN VARCHAR2
        ,p_locator_id             IN NUMBER
        ,x_mmti_rec               OUT  NOCOPY mtl_transactions_interface%ROWTYPE
        ,x_return_status          OUT  NOCOPY VARCHAR2);

  PROCEDURE create_batch_exception
              (p_material_dtl_rec         IN gme_material_details%ROWTYPE
              ,p_pending_move_order_ind   IN BOOLEAN := NULL
              ,p_pending_rsrv_ind         IN BOOLEAN := NULL
              ,p_transacted_qty           IN NUMBER := NULL
              ,p_exception_qty            IN NUMBER := NULL
              ,p_force_unconsumed         IN VARCHAR2 := fnd_api.g_true
              ,x_exception_material_tbl   IN OUT NOCOPY gme_common_pvt.exceptions_tab
              ,x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE check_unexploded_phantom(p_batch_id              IN  NUMBER
                                    ,p_auto_by_step          IN  NUMBER
                                    ,p_batchstep_id          IN  NUMBER
                                    ,x_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE validate_batch_for_release  (p_batch_header_rec     IN gme_batch_header%ROWTYPE
                                        ,x_batch_header_rec     OUT NOCOPY gme_batch_header%ROWTYPE
                                        ,x_return_status        OUT NOCOPY VARCHAR2);


END gme_release_batch_pvt;

/
