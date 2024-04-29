--------------------------------------------------------
--  DDL for Package GME_DELETE_BATCH_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_DELETE_BATCH_STEP_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVDBSS.pls 120.1 2005/06/03 13:45:04 appldev  $ */
   PROCEDURE delete_step (
      p_batch_step_rec   IN              gme_batch_steps%ROWTYPE
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,p_reroute_flag     IN              BOOLEAN := FALSE);

   PROCEDURE delete_activity (
      p_batch_step_activities_rec   IN              gme_batch_step_activities%ROWTYPE
     ,x_return_status               OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_resource (
      p_batch_step_resources_rec                gme_batch_step_resources%ROWTYPE
     ,x_return_status              OUT NOCOPY   VARCHAR2);

   PROCEDURE delete_resource_transactions (
      p_batch_step_resources_rec                gme_batch_step_resources%ROWTYPE
     ,x_return_status              OUT NOCOPY   VARCHAR2);
END gme_delete_batch_step_pvt;

 

/
