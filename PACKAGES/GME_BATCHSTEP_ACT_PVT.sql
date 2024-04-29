--------------------------------------------------------
--  DDL for Package GME_BATCHSTEP_ACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCHSTEP_ACT_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVACTS.pls 120.1 2005/06/06 12:03:36 appldev  $ */

   PROCEDURE validate_param (
      p_org_code        IN              VARCHAR2 := NULL,
      p_batch_no        IN              VARCHAR2 := NULL,
      p_batchstep_no    IN              NUMBER := NULL,
      p_activity        IN              VARCHAR2 := NULL,
      x_batch_id        OUT NOCOPY      NUMBER,
      x_batchstep_id    OUT NOCOPY      NUMBER,
      x_activity_id     OUT NOCOPY      NUMBER,
      x_batch_status    OUT NOCOPY      NUMBER,
      x_step_status     OUT NOCOPY      NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE validate_activity_param (
      p_batchstep_activity_rec   IN              gme_batch_step_activities%ROWTYPE,
      p_step_id                  IN              NUMBER,
      p_validate_flexfield       IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_action                   IN              VARCHAR2,
      x_batchstep_activity_rec   OUT NOCOPY      gme_batch_step_activities%ROWTYPE,
      x_step_status              OUT NOCOPY      NUMBER,
      x_return_status            OUT NOCOPY      VARCHAR2
   );

   PROCEDURE insert_batchstep_activity (
      p_batchstep_activity_rec   IN              gme_batch_step_activities%ROWTYPE,
      p_batchstep_resource_tbl   IN              gme_create_step_pvt.resources_tab,
      p_org_code                 IN              VARCHAR2 := NULL,
      p_batch_no                 IN              VARCHAR2 := NULL,
      p_batchstep_no             IN              NUMBER := NULL,
      p_ignore_qty_below_cap     IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_validate_flexfield       IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      x_batchstep_activity_rec   OUT NOCOPY      gme_batch_step_activities%ROWTYPE,
      x_return_status            OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_batchstep_activity (
      p_batchstep_activity_rec   IN              gme_batch_step_activities%ROWTYPE,
      p_org_code                 IN              VARCHAR2 := NULL,
      p_batch_no                 IN              VARCHAR2 := NULL,
      p_batchstep_no             IN              NUMBER := NULL,
      p_validate_flexfield       IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      x_batchstep_activity_rec   OUT NOCOPY      gme_batch_step_activities%ROWTYPE,
      x_return_status            OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_batchstep_activity (
      p_batchstep_activity_id   IN              NUMBER := NULL,
      p_org_code                IN              VARCHAR2 := NULL,
      p_batch_no                IN              VARCHAR2 := NULL,
      p_batchstep_no            IN              NUMBER := NULL,
      p_activity                IN              VARCHAR2 := NULL,
      x_return_status           OUT NOCOPY      VARCHAR2
   );
END gme_batchstep_act_pvt;

 

/
