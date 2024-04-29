--------------------------------------------------------
--  DDL for Package GME_VALIDATE_FLEX_FLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_VALIDATE_FLEX_FLD_PVT" AUTHID CURRENT_USER AS
   /* $Header: GMEVVFFS.pls 120.3 2006/03/09 05:33:53 svgonugu noship $ */
   pkg_application_short_name   VARCHAR2 (10)  DEFAULT '*';
   pkg_application_id           NUMBER;
   pkg_flex_field_name          VARCHAR2 (200) DEFAULT '*';
   pkg_flex_enabled             VARCHAR2 (1);
   pkg_context_column_name      VARCHAR2 (200);
   pkg_context_required         VARCHAR2 (1);

   /*BUG#3406639 -- Added following 5 Procedures for the Flex field Validations.*/
   PROCEDURE validate_flex_batch_header (
      p_batch_header    IN              gme_batch_header%ROWTYPE
     ,x_batch_header    IN OUT NOCOPY   gme_batch_header%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_flex_batch_step (
      p_batch_step      IN              gme_batch_steps%ROWTYPE
     ,x_batch_step      IN OUT NOCOPY   gme_batch_steps%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_flex_step_activities (
      p_step_activities   IN              gme_batch_step_activities%ROWTYPE
     ,x_step_activities   IN OUT NOCOPY   gme_batch_step_activities%ROWTYPE
     ,x_return_status     OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_flex_step_resources (
      p_step_resources   IN              gme_batch_step_resources%ROWTYPE
     ,x_step_resources   IN OUT NOCOPY   gme_batch_step_resources%ROWTYPE
     ,x_return_status    OUT NOCOPY      VARCHAR2);

   /* start , Punit Kumar */
   PROCEDURE validate_rsrc_txn_flex (
      p_resource_txn_rec   IN              gme_resource_txns%ROWTYPE
     ,x_resource_txn_rec   IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   /*end */

   --Bug#5078853 rewritten the following procedure
   PROCEDURE validate_flex_material_details (
      p_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,x_material_detail_rec   IN OUT NOCOPY   gme_material_details%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2);

   /* Nsinha added p_validate_flexfields in param as part of GME_Process_Parameter_APIs_TD */
   PROCEDURE validate_flex_process_param (
      p_process_param_rec     IN              gme_process_parameters%ROWTYPE
     ,p_validate_flexfields   IN              VARCHAR2 := fnd_api.g_false
     ,x_process_param_rec     IN OUT NOCOPY   gme_process_parameters%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2);

  --siva  Bug#4395561 Start
   PROCEDURE create_flex_batch_header (
       p_batch_header    IN              gme_batch_header%ROWTYPE,
      x_batch_header     IN OUT NOCOPY      gme_batch_header%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
   );
   PROCEDURE create_flex_material_details (
      p_material_detail   IN              gme_material_details%ROWTYPE,
      x_material_detail   IN OUT NOCOPY   gme_material_details%ROWTYPE,
      x_return_status    OUT NOCOPY      VARCHAR2
   );
   PROCEDURE create_flex_batch_step (
      p_batch_step      IN              gme_batch_steps%ROWTYPE,
      x_batch_step      IN OUT NOCOPY   gme_batch_steps%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
   );
   PROCEDURE create_flex_step_activities (
      p_step_activities   IN              gme_batch_step_activities%ROWTYPE,
      x_step_activities   IN OUT NOCOPY   gme_batch_step_activities%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
   );
   PROCEDURE create_flex_step_resources (
      p_step_resources   IN              gme_batch_step_resources%ROWTYPE,
      x_step_resources   IN OUT NOCOPY   gme_batch_step_resources%ROWTYPE,
      x_return_status    OUT NOCOPY      VARCHAR2
   );
   PROCEDURE create_flex_process_param (
      p_process_param_rec   IN              gme_process_parameters%ROWTYPE,
      x_process_param_rec   IN OUT NOCOPY   gme_process_parameters%ROWTYPE,
      x_return_status    OUT NOCOPY      VARCHAR2
   );
   PROCEDURE create_flex_resource_txns (
      p_resource_txns   IN              gme_resource_txns%ROWTYPE,
      x_resource_txns   IN OUT NOCOPY   gme_resource_txns%ROWTYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
   );
  --siva Bug#4395561 End
   CURSOR cur_get_appl_id
   IS
      SELECT application_id
        FROM fnd_application
       WHERE application_short_name = 'GME';
END gme_validate_flex_fld_pvt;

 

/
