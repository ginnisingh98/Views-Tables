--------------------------------------------------------
--  DDL for Package GME_UPDATE_STEP_QTY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_UPDATE_STEP_QTY_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVUSQS.pls 120.4.12010000.2 2010/03/22 15:40:38 gmurator ship $ */
--Bug#5606246 Added a new variable p_material_step_id to update_step_qty procedure.
   PROCEDURE update_step_qty (
      p_batch_step_rec         IN              gme_batch_steps%ROWTYPE
     ,x_message_count          OUT NOCOPY      NUMBER
     ,x_message_list           OUT NOCOPY      VARCHAR2
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,x_batch_step_rec         OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,p_routing_scale_factor   IN              NUMBER DEFAULT NULL
     ,p_backflush_factor       IN              NUMBER DEFAULT NULL
     ,p_dependency_type        IN              NUMBER DEFAULT NULL
     ,p_material_step_id       IN              NUMBER DEFAULT NULL);

   PROCEDURE calculate_mass_vol_qty (
      p_batch_step_rec   IN OUT NOCOPY   gme_batch_steps%ROWTYPE);

   PROCEDURE calculate_quantities (
      p_batch_hdr_rec          IN              gme_batch_header%ROWTYPE
     ,p_batch_step_rec         IN OUT NOCOPY   gme_batch_steps%ROWTYPE
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,p_routing_scale_factor   IN              NUMBER DEFAULT NULL
     ,p_backflush_factor       IN              NUMBER DEFAULT NULL
     ,p_dependency_type        IN              NUMBER DEFAULT NULL);

   PROCEDURE calc_charge (
      p_step_id         IN              gme_batch_steps.batchstep_id%TYPE
     ,p_resources       IN              gme_batch_step_resources.resources%TYPE
            DEFAULT NULL
     ,p_mass_qty        IN              gme_batch_steps.plan_mass_qty%TYPE
     ,p_vol_qty         IN              gme_batch_steps.plan_volume_qty%TYPE
     ,p_step_qty        IN              NUMBER DEFAULT NULL       --Bug#5231180
     ,p_max_capacity    IN              NUMBER DEFAULT NULL       --Bug#5231180
     ,x_charge          OUT NOCOPY      gme_batch_steps.plan_charges%TYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE update_activities (
      p_batch_hdr_rec          IN              gme_batch_header%ROWTYPE
     ,p_batch_step_rec         IN              gme_batch_steps%ROWTYPE
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,p_routing_scale_factor   IN              NUMBER DEFAULT NULL
     ,p_backflush_factor       IN              NUMBER DEFAULT NULL
     ,p_charge_diff            IN              NUMBER
     ,p_dependency_type        IN              NUMBER DEFAULT NULL);

   PROCEDURE update_resources (
      p_batch_hdr_rec              IN              gme_batch_header%ROWTYPE
     ,p_batch_step_rec             IN              gme_batch_steps%ROWTYPE
     ,p_batchstep_activities_rec   IN              gme_batch_step_activities%ROWTYPE
     ,x_return_status              OUT NOCOPY      VARCHAR2
     ,p_routing_scale_factor       IN              NUMBER DEFAULT NULL
     ,p_backflush_factor           IN              NUMBER DEFAULT NULL
     ,p_charge_diff                IN              NUMBER DEFAULT NULL
     ,p_dependency_type            IN              NUMBER DEFAULT NULL);

   -- Bug 8751983 - Add trans_date parameter.
   PROCEDURE build_insert_resource_txn (
      p_batch_hdr_rec        IN              gme_batch_header%ROWTYPE
     ,p_batchstep_resource   IN              gme_batch_step_resources%ROWTYPE
     ,p_usage                IN              NUMBER
     ,p_completed            IN              NUMBER DEFAULT 1
     ,p_trans_date           IN              DATE DEFAULT NULL
     ,x_return_status        OUT NOCOPY      VARCHAR2);

   PROCEDURE adjust_pending_usage (
      p_batch_step_resources_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_return_status              OUT NOCOPY      VARCHAR2);

   PROCEDURE adjust_actual_usage (
      p_batch_step_resources_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_return_status              OUT NOCOPY      VARCHAR2);

   PROCEDURE reduce_pending_usage (
      p_batch_step_resources_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_return_status              OUT NOCOPY      VARCHAR2);

   --Bug#5231180 added the following new procedure to calculate charges
   PROCEDURE recalculate_charges(
      p_batchstep_rec IN  gme_batch_steps%ROWTYPE
     ,p_cal_type      IN  VARCHAR2
     ,x_batchstep_rec OUT NOCOPY gme_batch_steps%ROWTYPE
     ,x_return_status OUT NOCOPY VARCHAR2);

END gme_update_step_qty_pvt;

/
