--------------------------------------------------------
--  DDL for Package GME_BATCHSTEP_RSRC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCHSTEP_RSRC_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVRSRS.pls 120.1 2005/06/03 14:16:02 appldev  $
 *****************************************************************
 *                                                               *
 * Package  GME_BATCHSTEP_RSRC_PVT                               *
 *                                                               *
 * Contents INSERT RESOURCE                                      *
 *          UPDATE RESOURCE                                      *
 *          DELETE RESOURCE                                      *
 *                                                               *
 * Use      This is the private layer of the                     *
 *          GME Batch Step Resource                              *
 *          Process.                                             *
 *                                                               *
 * History                                                       *
 *         Adapted for Inventory Convergence March 2005          *
 *                                                               *
 *****************************************************************
*/
   PROCEDURE validate_param (
      p_org_code          IN              VARCHAR2 := NULL
     ,p_batch_no          IN              VARCHAR2 := NULL
     ,p_batchstep_no      IN              NUMBER := NULL
     ,p_activity          IN              VARCHAR2 := NULL
     ,p_resource          IN              VARCHAR2 := NULL
     ,x_organization_id   OUT NOCOPY      NUMBER
     ,x_batch_id          OUT NOCOPY      NUMBER
     ,x_batchstep_id      OUT NOCOPY      NUMBER
     ,x_activity_id       OUT NOCOPY      NUMBER
     ,x_rsrc_id           OUT NOCOPY      NUMBER
     ,x_step_status       OUT NOCOPY      NUMBER
     ,x_return_status     OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_rsrc_param (
      p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_activity_id              IN              NUMBER
     ,p_ignore_qty_below_cap     IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,p_validate_flexfield       IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,p_action                   IN              VARCHAR2
     ,x_batchstep_resource_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_step_status              OUT NOCOPY      NUMBER
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE insert_batchstep_rsrc (
      p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_batchstep_resource_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE update_batchstep_rsrc (
      p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_batchstep_resource_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_batchstep_rsrc (
      p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   FUNCTION date_within_activity_dates (
      p_batchstep_activity_id   NUMBER
     ,p_step_status             NUMBER
     ,p_date                    DATE)
      RETURN BOOLEAN;

   FUNCTION lookup_code_valid (p_lookup_type VARCHAR2, p_lookup_code VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE consolidate_flexfields (
      p_new_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_old_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_validate_flexfield           IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,x_batchstep_resource_rec       OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_return_status                OUT NOCOPY      VARCHAR2);
END gme_batchstep_rsrc_pvt;

 

/
