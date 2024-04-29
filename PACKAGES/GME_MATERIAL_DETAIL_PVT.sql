--------------------------------------------------------
--  DDL for Package GME_MATERIAL_DETAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_MATERIAL_DETAIL_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVMTLS.pls 120.6 2006/04/18 08:48:28 sudoddap noship $ */

   g_date_fmt                 CONSTANT VARCHAR2(25)      := 'YYYY-MON-DD HH24:MI:SS';

   PROCEDURE insert_material_line
     (p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,p_batch_step_rec        IN              gme_batch_steps%ROWTYPE
     ,p_trans_id              IN              NUMBER
     ,x_transacted            OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_material_detail_rec   OUT NOCOPY      gme_material_details%ROWTYPE);

   PROCEDURE validate_batch_for_matl_ins
        (p_batch_header_rec         IN gme_batch_header%ROWTYPE
        ,p_batch_step_rec           IN gme_batch_steps%ROWTYPE
        ,x_return_status            OUT NOCOPY VARCHAR2);

   PROCEDURE validate_material_for_ins (
      p_batch_header_rec      IN       gme_batch_header%ROWTYPE
     ,p_material_detail_rec   IN       gme_material_details%ROWTYPE
     ,p_batch_step_rec        IN       gme_batch_steps%ROWTYPE
     ,x_material_detail_rec   OUT NOCOPY     gme_material_details%ROWTYPE
     ,x_return_status         OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_actual_qty (
      p_actual_qty      IN             NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE open_and_process_actual_qty (
      p_batch_header_rec      IN       gme_batch_header%ROWTYPE
     ,p_material_detail_rec   IN       gme_material_details%ROWTYPE
     ,p_batch_step_rec        IN       gme_batch_steps%ROWTYPE DEFAULT NULL
     ,p_trans_id              IN       NUMBER
     ,p_insert                IN       VARCHAR2
     ,x_transacted            OUT NOCOPY     VARCHAR2
     ,x_return_status         OUT NOCOPY     VARCHAR2);

   FUNCTION open_actual_qty (
      p_material_detail_rec   IN   gme_material_details%ROWTYPE
     ,p_batch_status          IN   NUMBER
     ,p_update_inventory_ind  IN   VARCHAR2
     ,p_batchstep_id          IN   NUMBER DEFAULT NULL
     ,p_step_status           IN   NUMBER DEFAULT NULL
     ,p_lot_control_code      IN   NUMBER DEFAULT NULL
     ,p_location_control_code IN   NUMBER DEFAULT NULL
     ,p_restrict_locators_code IN  NUMBER DEFAULT NULL
     ,p_insert                IN   VARCHAR2)
      RETURN NUMBER;

   PROCEDURE process_actual_qty (
      p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,p_batch_step_rec        IN              gme_batch_steps%ROWTYPE
            DEFAULT NULL
     ,p_trans_id              IN              NUMBER
     ,p_item_rec              IN              mtl_system_items_b%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2);

   PROCEDURE construct_trans_row (
      p_matl_dtl_rec          IN       gme_material_details%ROWTYPE
     ,p_item_rec              IN       mtl_system_items_b%ROWTYPE
     ,p_batch_hdr_rec         IN       gme_batch_header%ROWTYPE
     ,p_batch_step_rec        IN       gme_batch_steps%ROWTYPE
     ,x_mmti_rec              OUT NOCOPY     mtl_transactions_interface%ROWTYPE
     ,x_return_status         OUT NOCOPY     VARCHAR2);

   PROCEDURE get_converted_qty (
      p_org_id                    IN NUMBER
     ,p_item_id                   IN NUMBER
     ,p_lot_number                IN VARCHAR2 DEFAULT NULL
     ,p_qty                       IN NUMBER
     ,p_from_um                   IN VARCHAR2
     ,p_to_um                     IN VARCHAR2
     ,x_conv_qty                  OUT NOCOPY NUMBER
     ,x_return_status             OUT NOCOPY VARCHAR2);

   PROCEDURE get_item_rec (
      p_org_id          IN       NUMBER
     ,p_item_id         IN       NUMBER
     ,x_item_rec        OUT NOCOPY     mtl_system_items_b%ROWTYPE
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_item_id (
      p_org_id          IN       NUMBER
     ,p_item_id         IN       NUMBER
     ,x_item_rec        OUT NOCOPY     mtl_system_items_b%ROWTYPE
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_revision (
      p_revision        IN       VARCHAR2
     ,p_item_rec        IN       mtl_system_items_b%ROWTYPE
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_line_type (
      p_line_type       IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);
--Bug#5129153 Changed the data type of 'p_byproduct_type' to VARCHAR2.
   PROCEDURE validate_byproduct_type (
      p_byproduct_type   IN       VARCHAR2
     ,x_return_status    OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_line_no (
      p_line_no            IN    NUMBER
     ,p_line_type          IN    NUMBER
     ,p_batch_id           IN    NUMBER
     ,x_line_no            OUT NOCOPY     NUMBER
     ,x_return_status      OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_dtl_um (
      p_dtl_um          IN       VARCHAR2
     ,p_primary_uom     IN       VARCHAR2
     ,p_item_id         IN       NUMBER
     ,p_org_id          IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_plan_qty (
      p_plan_qty        IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_wip_plan_qty (
      p_wip_plan_qty    IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_release_type (
      p_material_detail_rec   IN       gme_material_details%ROWTYPE
     ,p_release_type          IN       NUMBER
     ,x_return_status         OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_scrap_factor (
      p_scrap           IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_scale_multiple (
      p_scale_mult      IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_scale_round_var (
      p_scale_var       IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_rounding_direction (
      p_round_dir       IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_scale_type (
      p_scale_type            IN       NUMBER
     ,x_return_status         OUT NOCOPY     VARCHAR2);

  --FPBug#4524232 changed parameter to material detail record
  PROCEDURE validate_cost_alloc(
      p_material_detail_rec    IN gme_material_details%ROWTYPE
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_phantom_type (
      p_phantom_type    IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_contr_yield_ind (
      p_contr_yield_ind   IN       VARCHAR2 --FPBug#5040865
     ,x_return_status     OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_contr_step_qty_ind (
      p_contr_step_qty_ind   IN       VARCHAR2 --FPBug#5040865
     ,x_return_status        OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_subinventory (
      p_subinv          IN       VARCHAR2
     ,p_item_rec        IN       mtl_system_items_b%ROWTYPE
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_locator (
      p_subinv          IN       VARCHAR2
     ,p_locator_id      IN       NUMBER
     ,p_item_rec        IN       mtl_system_items_b%ROWTYPE
     ,p_line_type       IN       NUMBER
     ,x_return_status   OUT NOCOPY     VARCHAR2);

   PROCEDURE update_material_line (
      p_batch_header_rec             IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec          IN              gme_material_details%ROWTYPE
     ,p_stored_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,p_batch_step_rec               IN              gme_batch_steps%ROWTYPE
     ,p_scale_phantom                IN              VARCHAR2
            := fnd_api.g_false
     ,p_trans_id                     IN              NUMBER
     ,x_transacted                   OUT NOCOPY      VARCHAR2
     ,x_return_status                OUT NOCOPY      VARCHAR2
     ,x_material_detail_rec          OUT NOCOPY      gme_material_details%ROWTYPE);

   --Bug#5078853 removed p_validate_flexfields parameter
   PROCEDURE val_and_pop_material_for_upd (
      p_batch_header_rec             IN       gme_batch_header%ROWTYPE
     ,p_material_detail_rec          IN       gme_material_details%ROWTYPE
     ,p_stored_material_detail_rec   IN       gme_material_details%ROWTYPE
     ,p_batch_step_rec               IN       gme_batch_steps%ROWTYPE
     ,x_material_detail_rec          OUT NOCOPY     gme_material_details%ROWTYPE
     ,x_return_status                OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_material_for_del (
      p_batch_header_rec             IN       gme_batch_header%ROWTYPE
     ,p_material_detail_rec          IN       gme_material_details%ROWTYPE
     ,p_batch_step_rec               IN       gme_batch_steps%ROWTYPE
     ,x_return_status                OUT NOCOPY     VARCHAR2);

   PROCEDURE validate_phantom_type_change (
      p_material_detail_rec    IN gme_material_details%ROWTYPE
     ,x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE delete_material_line (
      p_batch_header_rec      IN       gme_batch_header%ROWTYPE
     ,p_material_detail_rec   IN       gme_material_details%ROWTYPE
     ,p_batch_step_rec        IN       gme_batch_steps%ROWTYPE
     ,x_transacted            OUT NOCOPY     VARCHAR2
     ,x_return_status         OUT NOCOPY     VARCHAR2);

END gme_material_detail_pvt;

 

/
