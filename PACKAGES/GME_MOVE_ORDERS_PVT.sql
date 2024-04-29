--------------------------------------------------------
--  DDL for Package GME_MOVE_ORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_MOVE_ORDERS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVMOVS.pls 120.0 2005/06/17 14:32:19 snene noship $ */
   PROCEDURE create_move_order_hdr (
      p_organization_id        IN              NUMBER
     ,p_move_order_type        IN              NUMBER
     ,x_move_order_header_id   OUT NOCOPY      NUMBER
     ,x_return_status          OUT NOCOPY      VARCHAR2);

   PROCEDURE create_move_order_lines (
      p_move_order_header_id   IN              NUMBER
     ,p_move_order_type        IN              NUMBER
     ,p_material_details_tbl   IN              gme_common_pvt.material_details_tab
     ,x_material_details_tbl   OUT NOCOPY      gme_common_pvt.material_details_tab
     ,x_trolin_tbl             OUT NOCOPY      inv_move_order_pub.trolin_tbl_type
     ,x_return_status          OUT NOCOPY      VARCHAR2);

   PROCEDURE create_batch_move_order (
      p_batch_header_rec       IN              gme_batch_header%ROWTYPE
     ,p_material_details_tbl   IN              gme_common_pvt.material_details_tab
     ,x_return_status          OUT NOCOPY      VARCHAR2);

   PROCEDURE get_move_order_lines (
      p_organization_id      IN              NUMBER
     ,p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER
     ,x_mo_line_tbl          OUT NOCOPY      gme_common_pvt.mo_lines_tab
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_move_order_lines (
      p_organization_id        IN              NUMBER
     ,p_batch_id               IN              NUMBER
     ,p_material_detail_id     IN              NUMBER
     ,p_invis_move_line_id     IN              NUMBER DEFAULT NULL
     ,p_invis_move_header_id   IN              NUMBER DEFAULT NULL
     ,x_return_status          OUT NOCOPY      VARCHAR2);

   PROCEDURE update_move_order_lines (
      p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER
     ,p_new_qty              IN              NUMBER := NULL
     ,p_new_date             IN              DATE := NULL
     ,p_invis_move_line_id   IN              NUMBER DEFAULT NULL
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   FUNCTION pending_move_orders_exist (
      p_organization_id      IN   NUMBER
     ,p_batch_id             IN   NUMBER
     ,p_material_detail_id   IN   NUMBER)
      RETURN BOOLEAN;

   PROCEDURE get_pending_move_order_qty (
      p_mtl_dtl_rec     IN              gme_material_details%ROWTYPE
     ,x_pending_qty     OUT NOCOPY      NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_batch_move_orders (
      p_organization_id   IN              NUMBER
     ,p_batch_id          IN              NUMBER
     ,p_delete_invis      IN              VARCHAR2 := 'F'
     ,x_return_status     OUT NOCOPY      VARCHAR2);
END gme_move_orders_pvt;

 

/
