--------------------------------------------------------
--  DDL for Package GME_COMPLETE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_COMPLETE_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVCMBS.pls 120.4 2005/10/12 14:33:44 anewbury noship $ */

  PROCEDURE complete_batch
              (p_batch_header_rec           IN         gme_batch_header%ROWTYPE
              ,x_exception_material_tbl     IN  OUT NOCOPY  gme_common_pvt.exceptions_tab
              ,x_batch_header_rec           OUT NOCOPY gme_batch_header%ROWTYPE
              ,x_return_status              OUT NOCOPY VARCHAR2);

  PROCEDURE process_material
              (p_material_detail_rec        IN         gme_material_details%ROWTYPE
              ,p_yield                      IN         BOOLEAN
              ,p_trans_date                 IN         DATE
              ,p_update_inv_ind             IN         VARCHAR2
              ,x_exception_material_tbl     IN  OUT NOCOPY  gme_common_pvt.exceptions_tab
              ,x_return_status              OUT NOCOPY      VARCHAR2);

  PROCEDURE yield_material(p_material_dtl_rec  IN gme_material_details%ROWTYPE
                            ,p_yield_qty       IN NUMBER
                            ,p_trans_date      IN DATE
                            ,p_item_rec        IN mtl_system_items_b%ROWTYPE
                            ,p_force_unconsumed IN VARCHAR2
                            ,x_exception_material_tbl    IN OUT NOCOPY gme_common_pvt.exceptions_tab
                            ,x_actual_qty      OUT NOCOPY NUMBER
                            ,x_return_status   OUT NOCOPY VARCHAR2);

  PROCEDURE build_and_create_transaction
              (p_mtl_dtl_rec           IN gme_material_details%ROWTYPE
              ,p_pp_lot_rec            IN gme_pending_product_lots%ROWTYPE
              ,p_subinv                IN VARCHAR2
              ,p_locator_id            IN NUMBER
              ,p_trans_date            IN DATE
              ,p_yield_qty             IN NUMBER
              ,p_revision              IN VARCHAR2 DEFAULT NULL
              ,p_sec_uom_code          IN VARCHAR2 DEFAULT NULL
              ,x_actual_qty            IN OUT NOCOPY NUMBER
              ,x_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE constr_mmti
    (p_mtl_dtl_rec              IN   gme_material_details%ROWTYPE
    ,p_yield_qty                IN   NUMBER
    ,p_subinv                   IN   VARCHAR2
    ,p_locator_id               IN   NUMBER
    ,p_revision                 IN   VARCHAR2
    ,p_pp_lot_rec               IN   gme_pending_product_lots%ROWTYPE
    ,x_mmti_rec                 OUT  NOCOPY mtl_transactions_interface%ROWTYPE
    ,x_mmli_tbl                 OUT  NOCOPY gme_common_pvt.mtl_trans_lots_inter_tbl
    ,x_sec_qty                  OUT  NOCOPY NUMBER
    ,x_dtl_qty                  OUT  NOCOPY NUMBER
    ,x_return_status            OUT  NOCOPY VARCHAR2);

  PROCEDURE validate_batch_for_complete
    (p_batch_header_rec     IN gme_batch_header%ROWTYPE
    ,x_batch_header_rec     OUT NOCOPY gme_batch_header%ROWTYPE
    ,x_return_status        OUT NOCOPY VARCHAR2);


END gme_complete_batch_pvt;

 

/
