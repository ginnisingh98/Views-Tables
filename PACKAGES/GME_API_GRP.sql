--------------------------------------------------------
--  DDL for Package GME_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_API_GRP" AUTHID CURRENT_USER AS
/* $Header: GMEGAPIS.pls 120.19.12010000.2 2009/04/28 16:18:57 srpuri ship $ */
   TYPE g_gmo_resvns   IS REF CURSOR;
   TYPE g_gmo_pplots   IS REF CURSOR;
   TYPE g_gmo_txns     IS REF CURSOR;
   TYPE g_gmo_lot_txns IS REF CURSOR;

   PROCEDURE gme_pre_process_txns (
      p_header_id       IN              NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE gme_post_process_txns (
      p_transaction_id   IN              NUMBER
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_message_data     OUT NOCOPY      VARCHAR2);

   PROCEDURE update_material_date (
      p_material_detail_id   IN              NUMBER
     ,p_material_date        IN              DATE
     ,x_return_status        OUT NOCOPY      VARCHAR2);

  /*Bug#6778968 Added the new parameter. p_called_by */
   PROCEDURE validate_supply_demand
     (  x_return_status             OUT NOCOPY VARCHAR2
     ,  x_msg_count                 OUT NOCOPY NUMBER
     ,  x_msg_data                  OUT NOCOPY VARCHAR2
     ,  x_valid_status              OUT NOCOPY VARCHAR2
     ,  p_organization_id           IN         NUMBER
     ,  p_item_id                   IN         NUMBER
     ,  p_supply_demand_code        IN         NUMBER
     ,  p_supply_demand_type_id     IN         NUMBER
     ,  p_supply_demand_header_id   IN         NUMBER
     ,  p_supply_demand_line_id     IN         NUMBER
     ,  p_supply_demand_line_detail IN         NUMBER DEFAULT FND_API.G_MISS_NUM
     ,  p_demand_ship_date          IN         DATE
     ,  p_expected_receipt_date     IN         DATE
      ,  p_called_by                IN         VARCHAR2 DEFAULT 'VAL'
     ,  p_api_version_number        IN         NUMBER DEFAULT 1.0
     ,  p_init_msg_lst              IN         VARCHAR2 DEFAULT FND_API.G_FALSE
     );

   PROCEDURE get_available_supply_demand
     (  x_return_status             OUT NOCOPY VARCHAR2
     ,  x_msg_count                 OUT NOCOPY NUMBER
     ,  x_msg_data                  OUT NOCOPY VARCHAR2
     ,  x_available_quantity        OUT NOCOPY NUMBER
     ,  x_source_uom_code           OUT NOCOPY VARCHAR2
     ,  x_source_primary_uom_code   OUT NOCOPY VARCHAR2
     ,  p_organization_id           IN         NUMBER DEFAULT NULL
     ,  p_item_id                   IN         NUMBER DEFAULT NULL
     ,  p_revision                  IN         VARCHAR2 DEFAULT NULL
     ,  p_lot_number                IN         VARCHAR2 DEFAULT NULL
     ,  p_subinventory_code         IN         VARCHAR2 DEFAULT NULL
     ,  p_locator_id                IN         NUMBER DEFAULT NULL
     ,  p_supply_demand_code        IN         NUMBER
     ,  p_supply_demand_type_id     IN         NUMBER
     ,  p_supply_demand_header_id   IN         NUMBER
     ,  p_supply_demand_line_id     IN         NUMBER
     ,  p_supply_demand_line_detail IN         NUMBER DEFAULT FND_API.G_MISS_NUM
     ,  p_lpn_id                    IN         NUMBER DEFAULT FND_API.G_MISS_NUM
     ,  p_project_id                IN         NUMBER DEFAULT NULL
     ,  p_task_id                   IN         NUMBER DEFAULT NULL
     ,  p_api_version_number        IN         NUMBER DEFAULT 1.0
     ,  p_init_msg_lst              IN         VARCHAR2 DEFAULT FND_API.G_FALSE
     );


   PROCEDURE update_step_quality_status (
      p_batchstep_id     IN              NUMBER
     ,p_org_id           IN              NUMBER
     ,p_quality_status   IN              NUMBER
     ,x_return_status    OUT NOCOPY      VARCHAR2);




      PROCEDURE get_batch_shortages (
      p_api_version_number     IN      	  NUMBER DEFAULT 1.0
     ,p_init_msg_list          IN         VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2
     ,p_organization_id        IN         NUMBER
     ,p_batch_id               IN         NUMBER
     ,p_invoke_mode            IN         VARCHAR2
     ,p_tree_mode              IN         NUMBER
     ,x_return_status          OUT NOCOPY VARCHAR2
     ,x_exception_tbl          OUT NOCOPY gme_common_pvt.exceptions_tab);

      PROCEDURE get_material_reservations (
      p_api_version_number     IN         NUMBER DEFAULT 1.0
     ,p_init_msg_list          IN         VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2
     ,p_organization_id        IN         NUMBER
     ,p_batch_id               IN         NUMBER
     ,p_material_detail_id     IN         NUMBER
     ,x_return_status          OUT NOCOPY VARCHAR2
     ,x_reservations_tbl       OUT NOCOPY gme_common_pvt.reservations_tab);

     PROCEDURE CREATE_LCF_BATCH (
      p_api_version            IN      	  NUMBER DEFAULT 1.0
     ,p_init_msg_list          IN         VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit                 IN         VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_message_count          OUT NOCOPY NUMBER
     ,x_message_list           OUT NOCOPY VARCHAR2
     ,x_return_status          OUT NOCOPY VARCHAR2
     ,p_batch_header_rec       IN         gme_batch_header%rowtype
     ,p_formula_dtl_tbl        IN         gmdfmval_pub.formula_detail_tbl
     ,p_recipe_rout_tbl        IN         gmd_recipe_fetch_pub.recipe_rout_tbl
     ,p_recipe_step_tbl        IN         gmd_recipe_fetch_pub.recipe_step_tbl
     ,p_routing_depd_tbl       IN         gmd_recipe_fetch_pub.routing_depd_tbl
     ,p_oprn_act_tbl           IN         gmd_recipe_fetch_pub.oprn_act_tbl
     ,p_oprn_resc_tbl          IN         gmd_recipe_fetch_pub.oprn_resc_tbl
     ,p_proc_param_tbl         IN         gmd_recipe_fetch_pub.recp_resc_proc_param_tbl
     ,p_use_workday_cal        IN         VARCHAR2 DEFAULT FND_API.G_TRUE
     ,p_contiguity_override    IN         VARCHAR2 DEFAULT FND_API.G_TRUE
     ,x_batch_header_rec       OUT NOCOPY gme_batch_header%rowtype
     ,x_exception_material_tbl OUT NOCOPY gme_common_pvt.exceptions_tab
      );

   FUNCTION get_planning_open_qty (
      p_organization_id      IN   NUMBER
     ,p_batch_id             IN   NUMBER
     ,p_material_detail_id   IN   NUMBER
     ,p_prim_plan_qty        IN   NUMBER
     ,p_prim_wip_plan_qty    IN   NUMBER
     ,p_prim_actual_qty      IN   NUMBER
     ,p_prim_uom             IN   VARCHAR2)
      RETURN NUMBER;


    FUNCTION IS_RESERVATION_FULLY_SPECIFIED(p_reservation_id 	IN  	NUMBER)
     RETURN NUMBER;

/*======================================================================
--  PROCEDURE:
--    substitute_ingredients
--
--  DESCRIPTION:
--      Procedure to substitute ingredients for the passed item_no,
--      org_id, from and to batch_no, start and end dates.
--
--  HISTORY:
======================================================================*/
   PROCEDURE substitute_ingredients (
      errbuf          OUT NOCOPY      VARCHAR2,
      retcode         OUT NOCOPY      VARCHAR2,
      p_org_id        IN              NUMBER,
      p_from_batch_no IN              VARCHAR2,
      p_to_batch_no   IN              VARCHAR2,
      p_item_id       IN              NUMBER,
      p_start_date    IN              VARCHAR2,
      p_end_date      IN              VARCHAR2
   );

/*======================================================================
--  PROCEDURE:
--    get_total_qty
--
--  DESCRIPTION:
--      Procedure to sum up all product quantities
--
--  HISTORY:
---     SivakumarG FPBug#4684029 Created.
---     SivakumarG Bug#5111078 Added x_total_wip_plan_qty parameter
======================================================================*/
  PROCEDURE get_total_qty(
	 p_batch_id           IN NUMBER,
	 p_line_type          IN NUMBER,
	 p_uom                IN VARCHAR2,
	 x_total_plan_qty     OUT NOCOPY NUMBER,
         x_total_wip_plan_qty OUT NOCOPY NUMBER,
	 x_total_actual_qty   OUT NOCOPY NUMBER,
	 x_uom                OUT NOCOPY VARCHAR2,
	 x_return_status      OUT NOCOPY VARCHAR2
   );
 /*======================================================================
  --  PROCEDURE:
  --    check_inv_negative
  --
  --  DESCRIPTION:
  --      Procedure to check whether inventory will be driven negative.
  --      RETURNS TRUE WHEN
  --        Org does not allow negative and transaction will drive qty -ve
  --        OR
  --        Org allows negative but reservations exist and transaction
  --        will drive qty -ve
  --
  --  HISTORY:
  --    Jalaj Srivastava Created for Bug 5021522
  ======================================================================*/
  PROCEDURE check_inv_negative
    ( p_transaction_id IN NUMBER
     ,p_item_no        IN VARCHAR2
     ,x_msg_count      OUT NOCOPY NUMBER
     ,x_msg_data       OUT NOCOPY VARCHAR2
     ,x_return_status    OUT NOCOPY VARCHAR2
    );

--nsinghi bug#5674398 Added following API
/*======================================================================
--  FUNCTION:
--    get_ingred_sub_date
--
--  DESCRIPTION:
--      Function to return the substitution effective date.
--  HISTORY:
--      Namit S. 27-NOV-2006   bug#5674398
======================================================================*/

  FUNCTION get_ingr_sub_date
     ( p_batch_id  IN gme_batch_header.batch_id%TYPE,
       p_material_detail_id  IN gme_material_details.material_detail_id%TYPE
     ) RETURN DATE;

  /* Bug 5597385 Added below procedures */
  PROCEDURE get_mat_resvns(p_organization_id IN         NUMBER,
                           p_mat_det_id      IN         NUMBER,
                           p_batch_id        IN         NUMBER,
                           x_resvns_cur      OUT NOCOPY g_gmo_resvns,
                           x_return_status   OUT NOCOPY VARCHAR2);
  PROCEDURE get_mat_pplots(p_mat_det_id      IN         NUMBER,
                           x_pplot_cur       OUT NOCOPY g_gmo_pplots,
                           x_return_status   OUT NOCOPY VARCHAR2);
  PROCEDURE get_mat_trans(p_organization_id IN         NUMBER,
                          p_mat_det_id      IN         NUMBER,
                          p_batch_id        IN         NUMBER,
                          x_txns_cur        OUT NOCOPY g_gmo_txns,
                          x_return_status   OUT NOCOPY VARCHAR2);
  PROCEDURE get_lot_trans(p_transaction_id  IN  NUMBER,
                          x_lot_txns_cur    OUT NOCOPY g_gmo_lot_txns,
                          x_return_status   OUT NOCOPY VARCHAR2);
  PROCEDURE create_material_txn(p_mmti_rec        IN         mtl_transactions_interface%ROWTYPE,
                                p_mmli_tbl        IN         gme_common_pvt.mtl_trans_lots_inter_tbl,
                                x_return_status   OUT NOCOPY VARCHAR2);
  PROCEDURE update_material_txn(p_transaction_id  IN         NUMBER,
                                p_mmti_rec        IN         mtl_transactions_interface%ROWTYPE,
                                p_mmli_tbl        IN         gme_common_pvt.mtl_trans_lots_inter_tbl,
                                x_return_status   OUT NOCOPY VARCHAR2);
  PROCEDURE delete_material_txn(p_organization_id IN         NUMBER,
                                p_transaction_id  IN         NUMBER,
                                x_return_status   OUT NOCOPY VARCHAR2);
  PROCEDURE create_resource_txn(p_rsrc_txn_gtmp_rec IN gme_resource_txns_gtmp%ROWTYPE,
                                x_rsrc_txn_gtmp_rec OUT NOCOPY gme_resource_txns_gtmp%ROWTYPE,
                                x_return_status     OUT NOCOPY VARCHAR2);
  PROCEDURE update_resource_txn(p_rsrc_txn_gtmp_rec IN gme_resource_txns_gtmp%ROWTYPE,
                                x_return_status     OUT NOCOPY VARCHAR2);
  PROCEDURE delete_resource_txn(p_rsrc_txn_gtmp_rec IN gme_resource_txns_gtmp%ROWTYPE,
                                x_return_status     OUT NOCOPY VARCHAR2);
END gme_api_grp;

/
