--------------------------------------------------------
--  DDL for Package GME_CREATE_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_CREATE_STEP_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVCRSS.pls 120.1.12010000.2 2008/11/24 19:18:05 gmurator ship $ */
   TYPE gme_batch_steps_tab IS TABLE OF gme_batch_steps%ROWTYPE;

   TYPE gme_batch_step_activities_tab IS TABLE OF gme_batch_step_activities%ROWTYPE;

   TYPE gme_batch_step_resources_tab IS TABLE OF gme_batch_step_resources%ROWTYPE;

   TYPE gme_batch_step_dep_tab IS TABLE OF gme_batch_step_dependencies%ROWTYPE;

   TYPE gme_batch_step_items_tab IS TABLE OF gme_batch_step_items%ROWTYPE;

   TYPE gme_resource_txns_tab IS TABLE OF gme_resource_txns%ROWTYPE;

   TYPE gme_process_parameters_tab IS TABLE OF gme_process_parameters%ROWTYPE;

   TYPE step_duration_tab IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE step_tab IS TABLE OF gme_batch_steps.batchstep_id%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE activities_tab IS TABLE OF gme_batch_step_activities%ROWTYPE
      INDEX BY BINARY_INTEGER;

   TYPE resources_tab IS TABLE OF gme_batch_step_resources%ROWTYPE
      INDEX BY BINARY_INTEGER;

   TYPE rsrc_txns_tab IS TABLE OF gme_resource_txns%ROWTYPE
      INDEX BY BINARY_INTEGER;

   TYPE step_charge_rec IS RECORD (
      step_id   gme_batch_steps.batchstep_id%TYPE
     ,charge    gme_batch_steps.plan_charges%TYPE
   );

   TYPE charge_tab IS TABLE OF step_charge_rec
      INDEX BY BINARY_INTEGER;

   TYPE step_charge_rsrc_rec IS RECORD (
      resources   gme_batch_step_resources.resources%TYPE
   );

   TYPE step_charge_rsrc_tab IS TABLE OF step_charge_rsrc_rec
      INDEX BY BINARY_INTEGER;

   PROCEDURE create_batch_steps (
      p_recipe_rout_step_tbl   IN              gmd_recipe_fetch_pub.recipe_step_tbl
     ,p_recipe_rout_act_tbl    IN              gmd_recipe_fetch_pub.oprn_act_tbl
     ,p_recipe_rout_resc_tbl   IN              gmd_recipe_fetch_pub.oprn_resc_tbl
     ,p_resc_parameters_tbl    IN              gmd_recipe_fetch_pub.recp_resc_proc_param_tbl
     ,p_recipe_rout_matl_tbl   IN              gmd_recipe_fetch_pub.recipe_rout_matl_tbl
     ,p_routing_depd_tbl       IN              gmd_recipe_fetch_pub.routing_depd_tbl
     ,p_gme_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_use_workday_cal        IN              VARCHAR2
     ,p_contiguity_override    IN              VARCHAR2
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,p_ignore_qty_below_cap   IN              VARCHAR2 DEFAULT fnd_api.g_true
     ,p_step_start_date        IN              DATE := NULL
     ,p_step_cmplt_date        IN              DATE := NULL
     ,p_step_due_date          IN              DATE := NULL);

   PROCEDURE calc_dates (
      p_gme_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_use_workday_cal        IN              VARCHAR2
     ,p_contiguity_override    IN              VARCHAR2
     ,p_return_status          OUT NOCOPY      VARCHAR2
     ,p_step_id                IN              gme_batch_steps.batchstep_id%TYPE
            DEFAULT NULL
     ,p_plan_start_date        IN              DATE DEFAULT NULL
     ,p_plan_cmplt_date        IN              DATE DEFAULT NULL);

   PROCEDURE update_charges (
      p_batch_id               IN              NUMBER
     ,p_step_charge_rsrc_tab   IN              gme_create_step_pvt.step_charge_rsrc_tab
     ,x_return_status          OUT NOCOPY      VARCHAR2);

   PROCEDURE calc_step_qty (
      p_parent_id           IN              NUMBER
     ,p_step_tbl            OUT NOCOPY      gmd_auto_step_calc.step_rec_tbl
     ,p_return_status       OUT NOCOPY      VARCHAR2
     ,p_called_from_batch   IN              NUMBER DEFAULT 1);

   PROCEDURE copy_and_create_text (
      p_gmd_text_code   IN              NUMBER
     ,p_text_string     IN              gme_text_table.text%TYPE
     ,x_gme_text_code   OUT NOCOPY      NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);

    -- G. Muratore Bug 7341534 - Frontport of 6774660/5618732
    --    Keeping original r 12 reworked code for now.Added new function
   PROCEDURE calc_longest_time_orig (
      l_batch_id            IN              gme_batch_header.batch_id%TYPE
     ,l_step_duration_tab   IN              step_duration_tab
     ,x_batch_duration      OUT NOCOPY      NUMBER
     ,x_return_status       OUT NOCOPY      VARCHAR2);

   PROCEDURE get_usage_in_hours (
      p_plan_rsrc_usage   IN              gme_batch_step_resources.plan_rsrc_usage%TYPE
     ,p_usage_um          IN              gme_batch_step_resources.usage_um%TYPE
     ,x_usage_hrs         OUT NOCOPY      gme_batch_step_resources.plan_rsrc_usage%TYPE
     ,x_return_status     OUT NOCOPY      VARCHAR2);

   FUNCTION get_max_duration (v_step_id IN NUMBER, v_batch_id IN NUMBER)
      RETURN NUMBER;

   PROCEDURE insert_resource_txns (
      p_gme_batch_header_rec       IN              gme_batch_header%ROWTYPE
     ,p_doc_type                   IN              VARCHAR2
     ,p_batch_step_resources_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_return_status              OUT NOCOPY      VARCHAR2);

   FUNCTION get_max_step_date (
      p_use_workday_cal    IN   VARCHAR2
     ,p_calendar_code      IN   VARCHAR2
     ,p_batchstep_id       IN   NUMBER
     ,p_batch_id           IN   NUMBER
     ,p_batch_start_date   IN   DATE)
      RETURN DATE;

   FUNCTION get_working_start_time (
      p_start_date      IN   DATE
     ,p_offset          IN   NUMBER
     ,p_calendar_code   IN   VARCHAR2)
      RETURN DATE;

   -- G. Muratore Bug 7341534 - Frontport of 6774660/5618732 Reinstate rewritten 11i function
   PROCEDURE calc_longest_time (
      l_batch_id            IN              gme_batch_header.batch_id%TYPE
     ,l_step_duration_tab   IN              step_duration_tab
     ,x_batch_duration      OUT NOCOPY      NUMBER
     ,x_return_status       OUT NOCOPY      VARCHAR2);

   -- G. Muratore Bug 7341534 - Frontport of 6774660/5618732 Added new function
   FUNCTION get_longest_in_branch (
      node            IN NUMBER,
      l_step_duration_tab   IN step_duration_tab)
      RETURN NUMBER;

END gme_create_step_pvt;

/
