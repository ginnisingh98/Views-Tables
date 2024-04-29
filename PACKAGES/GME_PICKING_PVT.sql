--------------------------------------------------------
--  DDL for Package GME_PICKING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_PICKING_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVPCKS.pls 120.1.12010000.1 2008/07/25 10:31:15 appldev ship $ */
   TYPE mtl_req_rec IS RECORD (
      organization_id      NUMBER
     ,batch_id             NUMBER
     ,material_detail_id   NUMBER
     ,inventory_item_id    NUMBER
     ,revision             VARCHAR2 (3)
     ,subinventory         VARCHAR2 (10)
     ,locator_id           NUMBER
     ,open_qty             NUMBER
     ,dtl_um               VARCHAR2 (3)
     ,mtl_req_date         DATE
   );

   TYPE mtl_req_tab IS TABLE OF mtl_req_rec
      INDEX BY BINARY_INTEGER;

   PROCEDURE conc_picking (
      err_buf                OUT NOCOPY      VARCHAR2
     ,ret_code               OUT NOCOPY      VARCHAR2
     ,p_organization_id      IN              NUMBER
     ,p_all_batches          IN              VARCHAR2
     ,                                             -- 1 = All, 2 = Backordered
      p_include_pending      IN              VARCHAR2
     ,p_include_wip          IN              VARCHAR2
     ,p_from_batch           IN              VARCHAR2
     ,p_to_batch             IN              VARCHAR2
     ,p_oprn_no              IN              VARCHAR2
     ,p_oprn_vers            IN              NUMBER
     ,p_product_no           IN              VARCHAR2
     ,p_ingredient_no        IN              VARCHAR2
     ,p_days_forward         IN              NUMBER
     ,p_from_req_date        IN              VARCHAR2
     ,p_to_req_date          IN              VARCHAR2
     ,p_pick_grouping_rule   IN              VARCHAR2
     ,p_print_pick_slip      IN              VARCHAR2 DEFAULT 'N'
     ,p_plan_tasks           IN              VARCHAR2 DEFAULT 'N'
     ,p_sales_order          IN              VARCHAR2);

   /* Bug 5212556 Added inventory_item_id */
   FUNCTION get_open_qty (
      p_organization_id      IN   NUMBER
     ,p_batch_id             IN   NUMBER
     ,p_material_detail_id   IN   NUMBER
     ,p_inventory_item_id    IN   NUMBER
     ,p_subinventory         IN   VARCHAR2
     ,p_plan_qty             IN   NUMBER
     ,p_wip_plan_qty         IN   NUMBER
     ,p_actual_qty           IN   NUMBER
     ,p_backordered_qty      IN   NUMBER
     ,p_dtl_um               IN   VARCHAR2)
      RETURN NUMBER;

   PROCEDURE pick_material (
      p_mtl_req_tbl       IN              gme_picking_pvt.mtl_req_tab
     ,p_task_group_id     IN              NUMBER
     ,p_print_pick_slip   IN              VARCHAR2 DEFAULT 'N'
     ,p_plan_tasks        IN              VARCHAR2 DEFAULT 'N'
     ,x_return_status     OUT NOCOPY      VARCHAR2
     ,x_conc_request_id   OUT NOCOPY      NUMBER);

   PROCEDURE process_line (
      p_mo_line_rec        IN              inv_move_order_pub.trolin_rec_type
     ,p_grouping_rule_id   IN              NUMBER
     ,p_plan_tasks         IN              VARCHAR2 DEFAULT 'N'
     ,x_return_status      OUT NOCOPY      VARCHAR2);
END gme_picking_pvt;

/
