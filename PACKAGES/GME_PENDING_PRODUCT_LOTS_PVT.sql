--------------------------------------------------------
--  DDL for Package GME_PENDING_PRODUCT_LOTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_PENDING_PRODUCT_LOTS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVPPLS.pls 120.9.12010000.2 2009/05/06 19:14:42 srpuri ship $ */

  g_sequence_increment       CONSTANT  NUMBER := 100;

  FUNCTION get_last_sequence
      (p_matl_dtl_id      IN NUMBER
      ,x_return_status    OUT NOCOPY VARCHAR2)
  RETURN NUMBER;

  PROCEDURE get_pending_lot
    (p_material_detail_id       IN  NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_pending_product_lot_tbl  OUT NOCOPY gme_common_pvt.pending_lots_tab);

  PROCEDURE relieve_pending_lot
    (p_pending_lot_id           IN  NUMBER
    ,p_quantity                 IN  NUMBER
    ,p_secondary_quantity       IN  NUMBER := NULL
    ,x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE create_product_lot
    (p_organization_id       IN              NUMBER
    ,p_inventory_item_id     IN              NUMBER
    ,p_parent_lot            IN              mtl_lot_numbers.lot_number%TYPE := NULL
    ,p_mmli_tbl              IN              gme_common_pvt.mtl_trans_lots_inter_tbl
    ,p_generate_lot          IN              VARCHAR2
    ,p_generate_parent_lot   IN              VARCHAR2
    /* nsinghi bug#4486074 Added the p_expiration_Date parameter. */
    ,p_expiration_date           IN mtl_lot_numbers.expiration_date%TYPE := NULL
    ,x_mmli_tbl              OUT NOCOPY      gme_common_pvt.mtl_trans_lots_inter_tbl
    ,x_return_status         OUT NOCOPY      VARCHAR2);

  PROCEDURE create_pending_product_lot
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_pending_product_lots_rec   OUT NOCOPY gme_pending_product_lots%ROWTYPE
    ,x_return_status              OUT NOCOPY VARCHAR2);

  PROCEDURE update_pending_product_lot
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_pending_product_lots_rec   OUT NOCOPY  gme_pending_product_lots%ROWTYPE
    ,x_return_status              OUT NOCOPY VARCHAR2);

  PROCEDURE delete_pending_product_lot
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_return_status              OUT NOCOPY VARCHAR2);

  --Bug#5078853 created the following over loaded procedure
  PROCEDURE delete_pending_product_lot
    (p_material_detail_id         IN  NUMBER
    ,x_return_status              OUT NOCOPY VARCHAR2);

  PROCEDURE validate_material_for_create
                        (p_batch_header_rec          IN gme_batch_header%ROWTYPE
                        ,p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE validate_record_for_create
                        (p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,p_pending_product_lots_rec  IN gme_pending_product_lots%ROWTYPE
                        ,p_create_lot                IN VARCHAR2
                        ,p_generate_lot              IN VARCHAR2
                        ,p_generate_parent_lot       IN VARCHAR2
                        ,p_parent_lot                IN mtl_lot_numbers.lot_number%TYPE := NULL
                        /* nsinghi bug#4486074 Added the p_expiration_Date parameter. */
                        ,p_expiration_date           IN mtl_lot_numbers.expiration_date%TYPE := NULL
                        ,x_pending_product_lots_rec  OUT NOCOPY gme_pending_product_lots%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE validate_material_for_update
                        (p_batch_header_rec          IN gme_batch_header%ROWTYPE
                        ,p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE validate_record_for_update
                        (p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,p_db_pending_product_lots_rec     IN gme_pending_product_lots%ROWTYPE
                        ,p_pending_product_lots_rec  IN gme_pending_product_lots%ROWTYPE
                        ,x_pending_product_lots_rec  OUT NOCOPY gme_pending_product_lots%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE validate_material_for_delete
                        (p_batch_header_rec          IN gme_batch_header%ROWTYPE
                        ,p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE validate_record_for_delete
                        (p_material_detail_rec       IN gme_material_details%ROWTYPE
                        ,p_db_pending_product_lots_rec     IN gme_pending_product_lots%ROWTYPE
                        ,p_pending_product_lots_rec  IN gme_pending_product_lots%ROWTYPE
                        ,x_pending_product_lots_rec  OUT NOCOPY gme_pending_product_lots%ROWTYPE
                        ,x_return_status             OUT NOCOPY VARCHAR2);

  FUNCTION validate_lot_number (p_inv_item_id   IN NUMBER
                               ,p_org_id        IN NUMBER
                               ,p_lot_number    IN VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  FUNCTION validate_sequence (p_matl_dtl_rec    IN gme_material_details%ROWTYPE
                             ,p_sequence        IN NUMBER
                             ,x_return_status   OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  FUNCTION validate_quantities
                        (p_matl_dtl_rec    IN gme_material_details%ROWTYPE
                        ,p_lot_number      IN VARCHAR2
                        ,p_revision        IN VARCHAR2
                        ,p_dtl_qty         IN OUT NOCOPY NUMBER
                        ,p_sec_qty         IN OUT NOCOPY NUMBER
                        ,x_return_status   OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  FUNCTION validate_revision (p_item_rec        IN mtl_system_items_b%ROWTYPE
                             ,p_revision        IN VARCHAR2
                             ,x_return_status   OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  FUNCTION validate_reason_id(p_reason_id       IN NUMBER
                             ,x_return_status   OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  FUNCTION pending_product_lot_exist
               (p_batch_id                IN NUMBER
               ,p_material_detail_id      IN NUMBER) RETURN BOOLEAN;

-- nsinghi bug#5689035. Added this procedure.
  PROCEDURE get_pnd_prod_lot_qty (
     p_mtl_dtl_id        IN              NUMBER
    ,x_pnd_prod_lot_qty  OUT NOCOPY      NUMBER
    ,x_return_status     OUT NOCOPY      VARCHAR2);

END gme_pending_product_lots_pvt;

/
