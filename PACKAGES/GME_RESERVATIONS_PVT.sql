--------------------------------------------------------
--  DDL for Package GME_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_RESERVATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVRSVS.pls 120.2.12010000.2 2009/04/28 00:36:00 srpuri ship $ */
   TYPE g_msca_resvns IS REF CURSOR;

   PROCEDURE get_reservations_msca (
      p_organization_id      IN              NUMBER
     ,p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER
     ,p_subinventory_code    IN              VARCHAR2
     ,p_locator_id           IN              NUMBER
     ,p_lot_number           IN              VARCHAR2
     ,x_return_status        OUT NOCOPY      VARCHAR2
     ,x_error_msg            OUT NOCOPY      VARCHAR2
     ,x_rsrv_cursor          OUT NOCOPY      g_msca_resvns);

   PROCEDURE create_batch_reservations (
      p_batch_id        IN              NUMBER
     ,p_timefence       IN              NUMBER DEFAULT 1000
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   -- Bug 6437252
   -- Added lpn_id parameter.
   PROCEDURE create_material_reservation (
      p_matl_dtl_rec    IN              gme_material_details%ROWTYPE
     ,p_resv_qty        IN              NUMBER DEFAULT NULL
     ,p_sec_resv_qty    IN              NUMBER DEFAULT NULL
     ,p_resv_um         IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory    IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id      IN              NUMBER DEFAULT NULL
     ,p_lpn_id          IN              NUMBER DEFAULT NULL
     ,p_lot_number      IN              VARCHAR2 DEFAULT NULL
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE get_material_reservations (
      p_organization_id      IN              NUMBER
     ,p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER
     ,p_dispense_ind         IN              VARCHAR2 DEFAULT 'N'
     ,x_return_status        OUT NOCOPY      VARCHAR2
     ,x_reservations_tbl     OUT NOCOPY      gme_common_pvt.reservations_tab);

   FUNCTION reservation_fully_specified (
      p_reservation_rec          IN   mtl_reservations%ROWTYPE
     ,p_item_location_control    IN   NUMBER
     ,p_item_restrict_locators   IN   NUMBER)
      RETURN NUMBER;

   PROCEDURE convert_partial_to_dlr (
      p_reservation_rec    IN              mtl_reservations%ROWTYPE
     ,p_material_dtl_rec   IN              gme_material_details%ROWTYPE
     ,p_item_rec           IN              mtl_system_items%ROWTYPE
     ,p_qty_check          IN              VARCHAR2 := fnd_api.g_false
     ,x_reservation_rec    OUT NOCOPY      mtl_reservations%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_batch_reservations (
      p_organization_id   IN              NUMBER
     ,p_batch_id          IN              NUMBER
     ,x_return_status     OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_material_reservations (
      p_organization_id      IN              NUMBER
     ,p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_reservation (
      p_reservation_id   IN              NUMBER
     ,x_return_status    OUT NOCOPY      VARCHAR2);

   PROCEDURE get_reservation_dtl_qty (
      p_reservation_rec   IN              mtl_reservations%ROWTYPE
     ,p_uom_code          IN              VARCHAR2
     ,x_qty               OUT NOCOPY      NUMBER
     ,x_return_status     OUT NOCOPY      VARCHAR2);

   PROCEDURE get_reserved_qty (
      p_mtl_dtl_rec       IN              gme_material_details%ROWTYPE
     ,p_supply_sub_only   IN              VARCHAR2 DEFAULT 'F'
     ,x_reserved_qty      OUT NOCOPY      NUMBER
     ,x_return_status     OUT NOCOPY      VARCHAR2);

   PROCEDURE relieve_reservation (
      p_reservation_id     IN              NUMBER
     ,p_prim_relieve_qty   IN              NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   PROCEDURE update_reservation (
      p_reservation_id   IN              NUMBER
     ,p_revision         IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory     IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id       IN              NUMBER DEFAULT NULL
     ,p_lot_number       IN              VARCHAR2 DEFAULT NULL
     ,p_new_qty          IN              NUMBER DEFAULT NULL
     ,p_new_sec_qty      IN              NUMBER DEFAULT NULL
     ,p_new_uom          IN              VARCHAR2 DEFAULT NULL
     ,p_new_date         IN              DATE DEFAULT NULL
     ,x_return_status    OUT NOCOPY      VARCHAR2);

   PROCEDURE query_reservation (
      p_reservation_id    IN              NUMBER
     ,x_reservation_rec   OUT NOCOPY      inv_reservation_global.mtl_reservation_rec_type
     ,x_return_status     OUT NOCOPY      VARCHAR2);

   FUNCTION pending_reservations_exist (
      p_organization_id      IN   NUMBER
     ,p_batch_id             IN   NUMBER
     ,p_material_detail_id   IN   NUMBER)
      RETURN BOOLEAN;

   PROCEDURE convert_dtl_reservation (
      p_reservation_rec        IN              mtl_reservations%ROWTYPE
     ,p_material_details_rec   IN              gme_material_details%ROWTYPE
     ,p_qty_convert            IN              NUMBER := NULL
     ,x_message_count          OUT NOCOPY      NUMBER
     ,x_message_list           OUT NOCOPY      VARCHAR2
     ,x_return_status          OUT NOCOPY      VARCHAR2);

   PROCEDURE auto_detail_line (
      p_material_details_rec   IN              gme_material_details%ROWTYPE
     ,x_return_status          OUT NOCOPY      VARCHAR2);

   PROCEDURE auto_detail_batch(
      p_batch_rec              IN              GME_BATCH_HEADER%ROWTYPE,
      p_timefence              IN              NUMBER DEFAULT 100000,
      x_return_status          OUT NOCOPY      VARCHAR2);

   --Bug#4604943 created  new procedure to take care of validations
   PROCEDURE validate_mtl_for_reservation(
      p_material_detail_rec    IN              GME_MATERIAL_DETAILS%ROWTYPE,
      x_return_status          OUT NOCOPY      VARCHAR2);
END gme_reservations_pvt;

/
