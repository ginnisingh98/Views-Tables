--------------------------------------------------------
--  DDL for Package GME_SCALE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_SCALE_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVSCBS.pls 120.1 2005/06/03 13:53:21 appldev  $ */

   /***********************************************************/
/* Oracle Process Manufacturing Process Execution APIs     */
/*                                                         */
/* File Name: GMEVSCBS.pls                                 */
/* Contents:  Private layer for Scale batch API            */
/* Author:    Oracle                                       */
/* Date:      January 2001                                 */
/*                                                         */
/* History                                                 */
/* =======                                                 */
/***********************************************************/
   PROCEDURE scale_batch (
      p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_scale_factor             IN              NUMBER
     ,p_primaries                IN              VARCHAR2
     ,p_qty_type                 IN              NUMBER
     ,p_validity_rule_id         IN              NUMBER := NULL
     ,p_enforce_vldt_check       IN              VARCHAR2 := 'T'
     ,p_recalc_dates             IN              VARCHAR2
     ,p_use_workday_cal          IN              VARCHAR2
     ,p_contiguity_override      IN              VARCHAR2
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE scale_batch (
      p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_material_tbl             IN              gme_common_pvt.material_details_tab
     ,p_scale_factor             IN              NUMBER
     ,p_primaries                IN              VARCHAR2
     ,p_qty_type                 IN              NUMBER DEFAULT 1
     ,p_validity_rule_id         IN              NUMBER DEFAULT NULL
     ,p_enforce_vldt_check       IN              VARCHAR2
     ,p_recalc_dates             IN              VARCHAR2
     ,p_use_workday_cal          IN              VARCHAR2
     ,p_contiguity_override      IN              VARCHAR2
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,                                                               -- Navin
      x_material_tbl             OUT NOCOPY      gme_common_pvt.material_details_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE theoretical_yield_batch (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_scale_factor       IN              NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   FUNCTION get_total_qty (
      p_material_tab       IN   gme_common_pvt.material_details_tab
     ,p_batch_header_rec   IN   gme_batch_header%ROWTYPE)
      RETURN NUMBER;

   PROCEDURE scale_step_and_rsrc (
      p_batch_id               IN              gme_batch_header.batch_id%TYPE
     ,p_routing_scale_factor   IN              NUMBER
     ,x_return_status          OUT NOCOPY      VARCHAR2);
END gme_scale_batch_pvt;

 

/
