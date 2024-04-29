--------------------------------------------------------
--  DDL for Package GME_CREATE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_CREATE_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVCRBS.pls 120.4.12010000.4 2009/04/27 09:46:35 apmishra ship $ */

   /***********************************************************/
/* Oracle Process Manufacturing Process Execution APIs     */
/*                                                         */
/* File Name: GMEVCRBS.pls                                 */
/* Contents:  Private layer for batch creation API         */
/* History                                                 */
/* =======                                                 */
/* 10-JAN-2008 Rajesh Patangya Bug # 6752637               */
/* MTQ Quantity should be calculated based on product in   */
/* place of just copy from the routing, This is required   */
/* by PS engine, New Function UPDATE_STEP_MTQ added        */

/* 18-NOV-2008 G. Muratore     Bug 7565054                                */
/*     Added parameter p_sum_all_prod_lines to the procedure create_batch */
/**************************************************************************/
   /* Bug 5512352 Added new global */
   g_no_phant_short_check   NUMBER := 0;
   FUNCTION construct_batch_header (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE)
      RETURN BOOLEAN;

   PROCEDURE validate_wip_entity (p_organization_id  IN   NUMBER,
                                  p_batch_no         IN   VARCHAR2,
                                  x_return_status    OUT NOCOPY VARCHAR2);

   PROCEDURE create_batch (
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_batch_size               IN              NUMBER
     ,p_batch_size_uom           IN              VARCHAR2
     ,p_creation_mode            IN              VARCHAR2
     ,p_ignore_qty_below_cap     IN              VARCHAR2
            DEFAULT fnd_api.g_true
     ,p_use_workday_cal          IN              VARCHAR2
     ,p_contiguity_override      IN              VARCHAR2
     ,p_is_phantom               IN              VARCHAR2 DEFAULT 'N'
     ,p_sum_all_prod_lines       IN              VARCHAR2 DEFAULT 'A'
     ,p_use_least_cost_validity_rule     IN      VARCHAR2 := fnd_api.g_false
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2);

/* 10-JAN-2008 Rajesh Patangya Bug # 6752637               */
   FUNCTION update_step_mtq (p_batch_id IN NUMBER)
                   RETURN BOOLEAN ;

END gme_create_batch_pvt;

/
