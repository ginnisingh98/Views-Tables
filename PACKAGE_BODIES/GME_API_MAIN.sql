--------------------------------------------------------
--  DDL for Package Body GME_API_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_API_MAIN" AS
/*  $Header: GMEMAPIB.pls 120.33.12010000.4 2010/03/22 15:07:34 gmurator ship $    */
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'gme_api_main';

/*************************************************************************/
   PROCEDURE create_batch (
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,p_batch_size               IN              NUMBER
     ,p_batch_size_uom           IN              VARCHAR2
     ,p_creation_mode            IN              VARCHAR2
     ,p_recipe_id                IN              NUMBER := NULL
     ,p_recipe_no                IN              VARCHAR2 := NULL
     ,p_recipe_version           IN              NUMBER := NULL
     ,p_product_no               IN              VARCHAR2 := NULL
     ,p_product_id               IN              NUMBER := NULL
     ,p_sum_all_prod_lines       IN              VARCHAR2 := 'A'
     ,p_ignore_qty_below_cap     IN              VARCHAR2 := fnd_api.g_true
     ,p_use_workday_cal          IN              VARCHAR2 := fnd_api.g_true
     ,p_contiguity_override      IN              VARCHAR2 := fnd_api.g_false
     ,p_use_least_cost_validity_rule     IN      VARCHAR2 := fnd_api.g_false
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab)
   IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'CREATE_BATCH';
      setup_failure            EXCEPTION;
      batch_creation_failure   EXCEPTION;
      invalid_batch            EXCEPTION;
   BEGIN
      SAVEPOINT create_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CreateBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_create_batch_pvt.create_batch
                        (p_validation_level             => p_validation_level
                        ,p_batch_header_rec             => p_batch_header_rec
                        ,p_batch_size                   => p_batch_size
                        ,p_batch_size_uom               => p_batch_size_uom
                        ,p_creation_mode                => p_creation_mode
                        ,p_ignore_qty_below_cap         => p_ignore_qty_below_cap
                        ,p_use_workday_cal              => p_use_workday_cal
                        ,p_contiguity_override          => p_contiguity_override
                        ,p_sum_all_prod_lines           => p_sum_all_prod_lines
                        ,p_use_least_cost_validity_rule => p_use_least_cost_validity_rule
                        ,x_batch_header_rec             => x_batch_header_rec
                        ,x_exception_material_tbl       => x_exception_material_tbl
                        ,x_return_status                => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE batch_creation_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

      IF x_message_count = 0 THEN
         gme_common_pvt.log_message ('GME_API_BATCH_CREATED');
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN batch_creation_failure THEN
         IF x_return_status NOT IN (gme_common_pvt.g_inv_short_err) THEN
            ROLLBACK TO SAVEPOINT create_batch;
            x_batch_header_rec := NULL;
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT create_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT create_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END create_batch;

/*************************************************************************/
   PROCEDURE create_phantom (
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_material_detail_rec      IN              gme_material_details%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE --Bug#6738476
     ,p_batch_no                 IN              VARCHAR2 DEFAULT NULL
     ,x_material_detail_rec      OUT NOCOPY      gme_material_details%ROWTYPE
     ,p_validity_rule_id         IN              NUMBER
     ,p_use_workday_cal          IN              VARCHAR2 := fnd_api.g_true
     ,p_contiguity_override      IN              VARCHAR2 := fnd_api.g_true
     ,p_use_least_cost_validity_rule     IN      VARCHAR2 := fnd_api.g_false
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab)
   IS
      l_api_name        CONSTANT VARCHAR2 (30)            := 'CREATE_PHANTOM';
      setup_failure              EXCEPTION;
      phantom_creation_failure   EXCEPTION;
      l_batch_header             gme_batch_header%ROWTYPE;
   BEGIN
      /* Set the save point initially */
      SAVEPOINT create_phantom;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CreatePhantom');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                 gme_common_pvt.setup (p_material_detail_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;
      gme_common_pvt.set_timestamp;
      gme_phantom_pvt.create_phantom
                        (p_material_detail_rec         => p_material_detail_rec
                        ,p_batch_header_rec             => p_batch_header_rec --Bug#6738476
                        ,p_batch_no                    => p_batch_no
                        ,x_material_detail_rec         => x_material_detail_rec
                        ,p_validity_rule_id            => p_validity_rule_id
                        ,p_use_workday_cal             => p_use_workday_cal
                        ,p_contiguity_override         => p_contiguity_override
                        ,p_use_least_cost_validity_rule => p_use_least_cost_validity_rule
                        ,x_exception_material_tbl      => x_exception_material_tbl
                        ,x_return_status               => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE phantom_creation_failure;
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN phantom_creation_failure OR setup_failure THEN
         ROLLBACK TO SAVEPOINT create_phantom;
         x_material_detail_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT create_phantom;
         x_material_detail_rec := NULL;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END create_phantom;

   PROCEDURE scale_batch (
      p_validation_level         IN              NUMBER
     ,p_init_msg_list            IN              VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_scale_factor             IN              NUMBER
     ,p_primaries                IN              VARCHAR2
     ,p_qty_type                 IN              NUMBER
     ,p_recalc_dates             IN              VARCHAR2
     ,p_use_workday_cal          IN              VARCHAR2
     ,p_contiguity_override      IN              VARCHAR2
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'SCALE_BATCH';
      scale_batch_failed    EXCEPTION;
      batch_save_failed     EXCEPTION;
      batch_fetch_error     EXCEPTION;
      setup_failure         EXCEPTION;
   BEGIN
      /* Set the savepoint before proceeding */
      SAVEPOINT scale_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('ScaleBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Setup the common constants used accross the apis */
      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;


      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      x_batch_header_rec := p_batch_header_rec;
      gme_common_pvt.set_timestamp;

      gme_scale_batch_pvt.scale_batch
                        (p_batch_header_rec            => p_batch_header_rec
                        ,p_scale_factor                => p_scale_factor
                        ,p_primaries                   => p_primaries
                        ,p_qty_type                    => p_qty_type
                        ,p_recalc_dates                => p_recalc_dates
                        ,p_use_workday_cal             => p_use_workday_cal
                        ,p_contiguity_override         => p_contiguity_override
                        ,x_exception_material_tbl      => x_exception_material_tbl
                        ,x_batch_header_rec            => x_batch_header_rec
                        ,x_return_status               => x_return_status);
      x_message_count := 0;
      -- pawan kumar bug 5358705 add condition for different return status  'c' and 'w'
      IF x_return_status NOT IN (fnd_api.g_ret_sts_success, 'C', 'W') THEN
         RAISE scale_batch_failed;
      END IF;
       gme_common_pvt.log_message ('GME_SCALE_SUCCESS');
      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT scale_batch;
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN scale_batch_failed THEN
         ROLLBACK TO SAVEPOINT scale_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN batch_save_failed OR batch_fetch_error THEN
         ROLLBACK TO SAVEPOINT scale_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT scale_batch;
         x_batch_header_rec := NULL;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END scale_batch;

/*************************************************************************/
   PROCEDURE theoretical_yield_batch (
      p_validation_level   IN              NUMBER
     ,p_init_msg_list      IN              VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_scale_factor       IN              NUMBER
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      l_api_name        CONSTANT VARCHAR2 (30) := 'THEORETICAL_YIELD_BATCH';
      theoretical_yield_failed   EXCEPTION;
      setup_failure              EXCEPTION;
      batch_fetch_error          EXCEPTION;
      batch_save_failed          EXCEPTION;
   BEGIN
      /* Set the savepoint before proceeding */
      SAVEPOINT theoretical_yield_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('TheoreticalYieldBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Setup the common constants used accross the apis */
      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
            gme_common_pvt.setup
                              (p_org_id      => p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            RAISE setup_failure;
         END IF;
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_scale_batch_pvt.theoretical_yield_batch
                                    (p_batch_header_rec      => p_batch_header_rec
                                    ,p_scale_factor          => p_scale_factor
                                    ,x_return_status         => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE theoretical_yield_failed;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT theoretical_yield_batch;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN theoretical_yield_failed OR batch_save_failed THEN
         ROLLBACK TO SAVEPOINT theoretical_yield_batch;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT theoretical_yield_batch;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END theoretical_yield_batch;

/*************************************************************************/
   PROCEDURE insert_material_line (
      p_validation_level      IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,p_batch_step_id         IN              NUMBER := NULL
     ,p_trans_id              IN              NUMBER
     ,x_transacted            OUT NOCOPY      VARCHAR2
     ,x_material_detail_rec   OUT NOCOPY      gme_material_details%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'insert_material_line_form';

      l_batch_step_rec       gme_batch_steps%ROWTYPE;
      setup_failure          EXCEPTION;
      ins_mtl_line_failure   EXCEPTION;

      -- Bug 5903208
      gmf_cost_failure         EXCEPTION;
      l_message_count		   NUMBER;
      l_message_list		   VARCHAR2(2000);
   BEGIN

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      SAVEPOINT insert_material_line1;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('InsertMaterialLineForm');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF p_batch_step_id IS NOT NULL THEN
        l_batch_step_rec.batchstep_id := p_batch_step_id;

        IF NOT gme_batch_steps_dbl.fetch_row(l_batch_step_rec, l_batch_step_rec) THEN
           RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      insert_material_line    (p_validation_level         => p_validation_level
                              ,p_init_msg_list            => p_init_msg_list
                              ,x_message_count            => x_message_count
                              ,x_message_list             => x_message_list
                              ,x_return_status            => x_return_status
                              ,p_batch_header_rec         => p_batch_header_rec
                              ,p_material_detail_rec      => p_material_detail_rec
                              ,p_batch_step_rec           => l_batch_step_rec
                              ,p_trans_id                 => p_trans_id
                              ,x_transacted               => x_transacted
                              ,x_material_detail_rec      => x_material_detail_rec);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE ins_mtl_line_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

      --
      -- Bug 5903208 -- call to GMF
      GMF_VIB.Update_Batch_Requirements
      ( p_api_version   =>    1.0,
        p_init_msg_list =>    FND_API.G_FALSE,
        p_batch_id      =>    p_batch_header_rec.batch_id,
        x_return_status =>    x_return_status,
        x_msg_count     =>    l_message_count,
        x_msg_data      =>    l_message_list);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
         RAISE gmf_cost_failure;
      END IF;
      -- NEW
      GME_ERES_PKG.INSERT_EVENT(P_EVENT_NAME              => gme_common_pvt.G_BATCHMTL_ADDED
                               ,P_EVENT_KEY               => x_material_detail_rec.batch_id||'-'||x_material_detail_rec.material_detail_id
                               ,P_USER_KEY_LABEL          => FND_MESSAGE.GET_STRING('GME','GME_PSIG_BATCH_MATL_LABEL')
                               ,P_USER_KEY_VALUE          => gme_common_pvt.g_organization_code ||
                                                             '-'||p_batch_header_rec.batch_no||'-'|| x_material_detail_rec.Line_no
                                                             ||'-'||GME_ERES_PKG.GET_ITEM_NUMBER(x_material_detail_rec.organization_id,x_material_detail_rec.inventory_item_id)
                               ,P_POST_OP_API             => 'NONE'
                               ,P_PARENT_EVENT            => NULL
                               ,P_PARENT_EVENT_KEY        => NULL
                               ,P_PARENT_ERECORD_ID       => NULL
                               ,X_STATUS                  => x_return_status);
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE ins_mtl_line_failure;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
      IF (x_return_status IS NULL) THEN
        x_return_status := fnd_api.g_ret_sts_success;
      END IF;
   EXCEPTION
      WHEN   gmf_cost_failure THEN
        -- Bug 5903208
        x_return_status := FND_API.G_RET_STS_ERROR;

      WHEN ins_mtl_line_failure THEN
         IF x_return_status NOT IN (gme_common_pvt.g_inv_short_err) THEN
            ROLLBACK TO SAVEPOINT insert_material_line1;
            x_material_detail_rec := NULL;
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT insert_material_line1;
         x_material_detail_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT insert_material_line1;
         x_material_detail_rec := NULL;

         IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'When others exception:'
                                || SQLERRM);
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END insert_material_line;

/*************************************************************************/
   PROCEDURE insert_material_line (
      p_validation_level      IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,p_batch_step_rec        IN              gme_batch_steps%ROWTYPE
     ,p_trans_id              IN              NUMBER
     ,x_transacted            OUT NOCOPY      VARCHAR2
     ,x_material_detail_rec   OUT NOCOPY      gme_material_details%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'insert_material_line';
      setup_failure          EXCEPTION;
      ins_mtl_line_failure   EXCEPTION;
   BEGIN

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      SAVEPOINT insert_material_line;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('InsertMaterialLine');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      gme_material_detail_pvt.insert_material_line
                              (p_batch_header_rec         => p_batch_header_rec
                              ,p_material_detail_rec      => p_material_detail_rec
                              ,p_batch_step_rec           => p_batch_step_rec
                              ,p_trans_id                 => p_trans_id
                              ,x_transacted               => x_transacted
                              ,x_material_detail_rec      => x_material_detail_rec
                              ,x_return_status            => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE ins_mtl_line_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

      gme_common_pvt.log_message ('GME_MTL_LINE_INSERTED');


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
      IF (x_return_status IS NULL) THEN
        x_return_status := fnd_api.g_ret_sts_success;
      END IF;
   EXCEPTION
      WHEN ins_mtl_line_failure THEN
         IF x_return_status NOT IN (gme_common_pvt.g_inv_short_err) THEN
            ROLLBACK TO SAVEPOINT insert_material_line;
            x_material_detail_rec := NULL;
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT insert_material_line;
         x_material_detail_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT insert_material_line;
         x_material_detail_rec := NULL;

         IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'When others exception:'
                                || SQLERRM);
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END insert_material_line;

/*************************************************************************/
   PROCEDURE update_material_line (
      p_validation_level             IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list                IN              VARCHAR2
            := fnd_api.g_false
     ,x_message_count                OUT NOCOPY      NUMBER
     ,x_message_list                 OUT NOCOPY      VARCHAR2
     ,x_return_status                OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec             IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec          IN              gme_material_details%ROWTYPE
     ,p_batch_step_id                IN              NUMBER := NULL
     ,p_scale_phantom                IN              VARCHAR2 := fnd_api.g_false
     ,p_trans_id                     IN              NUMBER
     ,x_transacted                   OUT NOCOPY      VARCHAR2
     ,x_material_detail_rec          OUT NOCOPY      gme_material_details%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'update_material_line_form';

      l_stored_material_detail_rec   gme_material_details%ROWTYPE;
      l_in_batch_step_rec            gme_batch_steps%ROWTYPE;
      l_batch_step_rec               gme_batch_steps%ROWTYPE;
      upd_mtl_line_failure   EXCEPTION;
      setup_failure          EXCEPTION;
   BEGIN

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      SAVEPOINT update_material_line1;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('UpdateMaterialLineForm');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF p_batch_step_id IS NOT NULL THEN
        l_batch_step_rec.batchstep_id := p_batch_step_id;

        IF NOT gme_batch_steps_dbl.fetch_row(l_batch_step_rec, l_batch_step_rec) THEN
           RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      l_stored_material_detail_rec.material_detail_id := p_material_detail_rec.material_detail_id;

      IF NOT gme_material_details_dbl.fetch_row
                (l_stored_material_detail_rec,l_stored_material_detail_rec) THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      update_material_line
                (p_validation_level                => p_validation_level
                ,p_init_msg_list                   => p_init_msg_list
                ,x_message_count                   => x_message_count
                ,x_message_list                    => x_message_list
                ,x_return_status                   => x_return_status
                ,p_batch_header_rec                => p_batch_header_rec
                ,p_material_detail_rec             => p_material_detail_rec
                ,p_stored_material_detail_rec      => l_stored_material_detail_rec
                ,p_batch_step_rec                  => l_batch_step_rec
                ,p_scale_phantom                   => p_scale_phantom
                ,p_trans_id                        => p_trans_id
                ,x_transacted                      => x_transacted
                ,x_material_detail_rec             => x_material_detail_rec);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE upd_mtl_line_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

      -- NEW
      GME_ERES_PKG.INSERT_EVENT(P_EVENT_NAME              => gme_common_pvt.G_BATCHMTL_UPDATED
                               ,P_EVENT_KEY               => p_material_detail_rec.batch_id||'-'||p_material_detail_rec.material_detail_id
                               ,P_USER_KEY_LABEL          => FND_MESSAGE.GET_STRING('GME','GME_PSIG_BATCH_MATL_LABEL')
                               ,P_USER_KEY_VALUE          => gme_common_pvt.g_organization_code ||
                                                             '-'||p_batch_header_rec.batch_no||'-'|| p_material_detail_rec.Line_no
                                                             ||'-'||GME_ERES_PKG.GET_ITEM_NUMBER(p_material_detail_rec.organization_id,p_material_detail_rec.inventory_item_id)
                               ,P_POST_OP_API             => 'NONE'
                               ,P_PARENT_EVENT            => NULL
                               ,P_PARENT_EVENT_KEY        => NULL
                               ,P_PARENT_ERECORD_ID       => NULL
                               ,X_STATUS                  => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE upd_mtl_line_failure;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
      IF (x_return_status IS NULL) THEN
        x_return_status := fnd_api.g_ret_sts_success;
      END IF;
   EXCEPTION
      WHEN upd_mtl_line_failure THEN
         IF x_return_status NOT IN (gme_common_pvt.g_inv_short_err) THEN
            ROLLBACK TO SAVEPOINT update_material_line1;
            x_material_detail_rec := NULL;
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT update_material_line1;
         x_material_detail_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_material_line1;
         x_material_detail_rec := NULL;

         IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'When others exception:'
                                || SQLERRM);
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END update_material_line;

/*************************************************************************/
   PROCEDURE update_material_line (
      p_validation_level             IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list                IN              VARCHAR2
            := fnd_api.g_false
     ,x_message_count                OUT NOCOPY      NUMBER
     ,x_message_list                 OUT NOCOPY      VARCHAR2
     ,x_return_status                OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec             IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec          IN              gme_material_details%ROWTYPE
     ,p_stored_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,p_batch_step_rec               IN              gme_batch_steps%ROWTYPE
     ,p_scale_phantom                IN              VARCHAR2
            := fnd_api.g_false
     ,p_trans_id                     IN              NUMBER
     ,x_transacted                   OUT NOCOPY      VARCHAR2
     ,x_material_detail_rec          OUT NOCOPY      gme_material_details%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'update_material_line';
      upd_mtl_line_failure   EXCEPTION;
      setup_failure          EXCEPTION;
   BEGIN
      SAVEPOINT update_material_line;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('UpdateMaterialLine');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_material_detail_pvt.update_material_line
                (p_batch_header_rec                => p_batch_header_rec
                ,p_material_detail_rec             => p_material_detail_rec
                ,p_stored_material_detail_rec      => p_stored_material_detail_rec
                ,p_batch_step_rec                  => p_batch_step_rec
                ,p_scale_phantom                   => p_scale_phantom
                ,p_trans_id                        => p_trans_id
                ,x_transacted                      => x_transacted
                ,x_return_status                   => x_return_status
                ,x_material_detail_rec             => x_material_detail_rec);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE upd_mtl_line_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

      gme_common_pvt.log_message ('GME_MTL_LINE_UPDATED');


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
      IF (x_return_status IS NULL) THEN
        x_return_status := fnd_api.g_ret_sts_success;
      END IF;
   EXCEPTION
      WHEN upd_mtl_line_failure THEN
         IF x_return_status NOT IN (gme_common_pvt.g_inv_short_err) THEN
            ROLLBACK TO SAVEPOINT update_material_line;
            x_material_detail_rec := NULL;
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT update_material_line;
         x_material_detail_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_material_line;
         x_material_detail_rec := NULL;

         IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'When others exception:'
                                || SQLERRM);
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END update_material_line;

/*************************************************************************/
   PROCEDURE delete_material_line (
      p_validation_level      IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,p_batch_step_id         IN              NUMBER := NULL
     ,x_transacted            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'delete_material_line_form';

      l_batch_step_rec       gme_batch_steps%ROWTYPE;

      del_mtl_line_failure   EXCEPTION;
      setup_failure          EXCEPTION;

      -- Bug 5903208
      gmf_cost_failure         EXCEPTION;
      l_message_count		   NUMBER;
      l_message_list		   VARCHAR2(2000);

   BEGIN

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      SAVEPOINT delete_material_line1;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('DeleteMaterialLineForm');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF p_batch_step_id IS NOT NULL THEN
        l_batch_step_rec.batchstep_id := p_batch_step_id;

        IF NOT gme_batch_steps_dbl.fetch_row(l_batch_step_rec, l_batch_step_rec) THEN
           RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      delete_material_line (
          p_validation_level       => p_validation_level
         ,p_init_msg_list          => p_init_msg_list
         ,x_message_count          => x_message_count
         ,x_message_list           => x_message_list
         ,x_return_status          => x_return_status
         ,p_batch_header_rec       => p_batch_header_rec
         ,p_material_detail_rec    => p_material_detail_rec
         ,p_batch_step_rec         => l_batch_step_rec
         ,x_transacted             => x_transacted);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE del_mtl_line_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

      --
      -- Bug 5903208 -- call to GMF
      --
      GMF_VIB.Update_Batch_Requirements
      ( p_api_version   =>    1.0,
        p_init_msg_list =>    FND_API.G_FALSE,
        p_batch_id      =>    p_batch_header_rec.batch_id,
        x_return_status =>    x_return_status,
        x_msg_count     =>    l_message_count,
        x_msg_data      =>    l_message_list);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
         RAISE gmf_cost_failure;
      END IF;
      -- End Bug 5903208

      -- NEW
      GME_ERES_PKG.INSERT_EVENT(P_EVENT_NAME              => gme_common_pvt.G_BATCHMTL_REMOVED
                               ,P_EVENT_KEY               => p_material_detail_rec.batch_id||'-'||p_material_detail_rec.material_detail_id
                               ,P_USER_KEY_LABEL          => FND_MESSAGE.GET_STRING('GME','GME_PSIG_BATCH_MATL_LABEL')
                               ,P_USER_KEY_VALUE          => gme_common_pvt.g_organization_code ||
                                                             '-'||p_batch_header_rec.batch_no||'-'|| p_material_detail_rec.Line_no
                                                             ||'-'||GME_ERES_PKG.GET_ITEM_NUMBER(p_material_detail_rec.organization_id,p_material_detail_rec.inventory_item_id)
                               ,P_POST_OP_API             => 'NONE'
                               ,P_PARENT_EVENT            => NULL
                               ,P_PARENT_EVENT_KEY        => NULL
                               ,P_PARENT_ERECORD_ID       => NULL
                               ,X_STATUS                  => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE del_mtl_line_failure;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
      IF (x_return_status IS NULL) THEN
        x_return_status := fnd_api.g_ret_sts_success;
      END IF;
   EXCEPTION
      WHEN   gmf_cost_failure THEN
        -- Bug 5903208
        x_return_status := FND_API.G_RET_STS_ERROR;

      WHEN del_mtl_line_failure THEN
         IF x_return_status NOT IN (gme_common_pvt.g_inv_short_err) THEN
            ROLLBACK TO SAVEPOINT delete_material_line1;
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT delete_material_line1;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_material_line1;

         IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'When others exception:'
                                || SQLERRM);
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END delete_material_line;

/*************************************************************************/
   PROCEDURE delete_material_line (
      p_validation_level      IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec   IN              gme_material_details%ROWTYPE
     ,p_batch_step_rec        IN              gme_batch_steps%ROWTYPE
     ,x_transacted            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'delete_material_line';
      del_mtl_line_failure   EXCEPTION;
      setup_failure          EXCEPTION;
   BEGIN

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      SAVEPOINT delete_material_line;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('DeleteMaterialLine');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_material_detail_pvt.delete_material_line
                              (p_batch_header_rec         => p_batch_header_rec
                              ,p_material_detail_rec      => p_material_detail_rec
                              ,p_batch_step_rec           => p_batch_step_rec
                              ,x_transacted               => x_transacted
                              ,x_return_status            => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE del_mtl_line_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

      gme_common_pvt.log_message ('GME_MTL_LINE_DELETED');

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
      IF (x_return_status IS NULL) THEN
        x_return_status := fnd_api.g_ret_sts_success;
      END IF;
   EXCEPTION
      WHEN del_mtl_line_failure THEN
         IF x_return_status NOT IN (gme_common_pvt.g_inv_short_err) THEN
            ROLLBACK TO SAVEPOINT delete_material_line;
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT delete_material_line;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_material_line;

         IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'When others exception:'
                                || SQLERRM);
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END delete_material_line;

/*************************************************************************/
   PROCEDURE reschedule_batch (
      p_validation_level      IN              NUMBER
     ,p_init_msg_list         IN              VARCHAR2
     ,p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_use_workday_cal       IN              VARCHAR2
     ,p_contiguity_override   IN              VARCHAR2
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_batch_header_rec      OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name       CONSTANT VARCHAR2 (30) := 'RESCHEDULE_BATCH';
      reschedule_batch_failed   EXCEPTION;
      setup_failure             EXCEPTION;
   BEGIN
      /* Set the savepoint before proceeding */
      SAVEPOINT reschedule_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('RescheduleBatch');
      END IF;

      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Calling Pvt Reschedule Batch');
      END IF;

      gme_reschedule_batch_pvt.reschedule_batch
                              (p_batch_header_rec         => p_batch_header_rec
                              ,p_use_workday_cal          => p_use_workday_cal
                              ,p_contiguity_override      => p_contiguity_override
                              ,x_batch_header_rec         => x_batch_header_rec
                              ,x_return_status            => x_return_status);

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
                       (   'Came back from Pvt Reschedule Batch with status '
                        || x_return_status);
      END IF;
      IF x_return_status NOT IN (fnd_api.g_ret_sts_success, 'C') THEN
         RAISE reschedule_batch_failed;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT reschedule_batch;
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN reschedule_batch_failed THEN
         ROLLBACK TO SAVEPOINT reschedule_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT reschedule_batch;
         x_batch_header_rec := NULL;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END reschedule_batch;

/*************************************************************************/
   PROCEDURE reschedule_step (
      p_validation_level        IN              NUMBER
     ,p_init_msg_list           IN              VARCHAR2
     ,p_batch_header_rec        IN              gme_batch_header%ROWTYPE
     ,p_batch_step_rec          IN              gme_batch_steps%ROWTYPE
     ,p_reschedule_preceding    IN              VARCHAR2
     ,p_reschedule_succeeding   IN              VARCHAR2
     ,p_use_workday_cal         IN              VARCHAR2
     ,p_contiguity_override     IN              VARCHAR2
     ,x_message_count           OUT NOCOPY      NUMBER
     ,x_message_list            OUT NOCOPY      VARCHAR2
     ,x_return_status           OUT NOCOPY      VARCHAR2
     ,x_batch_step_rec          OUT NOCOPY      gme_batch_steps%ROWTYPE)
   IS
      l_api_name      CONSTANT VARCHAR2 (30)             := 'RESCHEDULE_STEP';
      l_diff                   NUMBER                           := 0;
      l_diff_cmplt             NUMBER                           := 0;
      l_batch_step             gme_batch_steps%ROWTYPE;
      l_step_tbl               gme_reschedule_step_pvt.step_tab;
      setup_failure            EXCEPTION;
      reschedule_step_failed   EXCEPTION;
      expected_error           EXCEPTION;
   BEGIN
      /* Set the savepoint before proceeding */
      SAVEPOINT reschedule_batch_step;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('RescheduleStep');
      END IF;

      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Calling Pvt Reschedule Step');
      END IF;

      gme_reschedule_step_pvt.reschedule_step
                          (p_batch_step_rec             => p_batch_step_rec
                          ,p_source_step_id_tbl         => l_step_tbl
                          ,p_contiguity_override        => p_contiguity_override
                          ,p_reschedule_preceding       => p_reschedule_preceding
                          ,p_reschedule_succeeding      => p_reschedule_succeeding
                          ,p_use_workday_cal            => p_use_workday_cal
                          ,x_batch_step_rec             => x_batch_step_rec
                          ,x_return_status              => x_return_status);

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
                        (   'Came back from Pvt Reschedule Step with status '
                         || x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         -- OM-GME integration - call in private layer at the end
         -- need to retrieve batch header record here... it's already retrieved in pvt.
         NULL;
      ELSE
         RAISE reschedule_step_failed;
      END IF;

         gme_common_pvt.log_message ('GME_API_STEP_RESCH');


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN reschedule_step_failed OR setup_failure THEN
         ROLLBACK TO SAVEPOINT reschedule_batch_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN expected_error THEN
         ROLLBACK TO SAVEPOINT reschedule_batch_step;
         x_batch_step_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT reschedule_batch_step;
         x_batch_step_rec := NULL;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END reschedule_step;

/*************************************************************************/
   PROCEDURE create_batch_reservations (
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      l_api_name          CONSTANT VARCHAR2 (30)
                                               := 'CREATE_BATCH_RESERVATIONS';
      setup_failure                EXCEPTION;
      batch_reservations_failure   EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT create_batch_reservations;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CreateBatchReservations');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_reservations_pvt.create_batch_reservations
                                   (p_batch_id           => p_batch_header_rec.batch_id
                                   ,p_timefence          => 1000000
                                   ,x_return_status      => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         gme_common_pvt.log_message ('GME_BATCH_HL_RESERVATION_FAIL');
         RAISE batch_reservations_failure;
      END IF;

      gme_common_pvt.log_message ('GME_BATCH_HI_RESR_CREATED');

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN batch_reservations_failure THEN
         ROLLBACK TO SAVEPOINT create_batch_reservations;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT create_batch_reservations;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END create_batch_reservations;

   PROCEDURE create_line_reservations (
      p_init_msg_list   IN              VARCHAR2 := fnd_api.g_false
     ,p_matl_dtl_rec    IN              gme_material_details%ROWTYPE
     ,x_message_count   OUT NOCOPY      NUMBER
     ,x_message_list    OUT NOCOPY      VARCHAR2
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_api_name        CONSTANT VARCHAR2 (30) := 'CREATE_LINE_RESERVATIONS';
      l_location_control_code    NUMBER;
      l_restrict_locators_code   NUMBER;
      l_open_qty                 NUMBER;
      /* Bug 5441643 Added NVL condition for location control code*/
      CURSOR cur_get_item (v_org_id NUMBER, v_inventory_item_id NUMBER)
      IS
         SELECT NVL(location_control_code,1) location_control_code, restrict_locators_code
           FROM mtl_system_items_kfv
          WHERE organization_id = v_org_id
            AND inventory_item_id = v_inventory_item_id;

      setup_failure              EXCEPTION;
      get_open_qty_failure       EXCEPTION;
      line_reservation_failure   EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT create_line_reservations;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CreateLineReservations');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                        gme_common_pvt.setup (p_matl_dtl_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      OPEN cur_get_item (p_matl_dtl_rec.organization_id
                        ,p_matl_dtl_rec.inventory_item_id);

      FETCH cur_get_item
       INTO l_location_control_code, l_restrict_locators_code;

      CLOSE cur_get_item;

      -- Use Suggestions mode (S) in the called by param to assess the total
      -- unreserved quantity
      /* Bug 5441643 Added NVL condition for location control code*/
      gme_common_pvt.get_open_qty
                        (p_mtl_dtl_rec                 => p_matl_dtl_rec
                        ,p_called_by                   => 'S'
                        ,p_item_location_control       => NVL(l_location_control_code,1)
                        ,p_item_restrict_locators      => l_restrict_locators_code
                        ,x_open_qty                    => l_open_qty
                        ,x_return_status               => x_return_status);

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'get_open_qty returns status: '
                             || x_return_status
                             || 'get_open_qty returns open_qty: '
                             || l_open_qty);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE get_open_qty_failure;
      END IF;

      /* Create a high level reservation (at organization level) for the outstanding qty */
      gme_reservations_pvt.create_material_reservation
                                           (p_matl_dtl_rec       => p_matl_dtl_rec
                                           ,p_resv_qty           => l_open_qty
                                           ,x_return_status      => x_return_status);

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'create_material_reservations returns status: '
                             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         -- Bug 7261728
         -- Commented the line below so message - INV_INVALID_RESERVATION_QTY
         -- from inv_reservation_pub will be displayedd.
         --gme_common_pvt.log_message ('GME_LINE_HL_RESERVATION_FAIL');
         RAISE line_reservation_failure;
      END IF;

      gme_common_pvt.log_message ('GME_LINE_HI_RESR_CREATED');
      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN setup_failure OR get_open_qty_failure OR line_reservation_failure THEN
         ROLLBACK TO SAVEPOINT create_line_reservations;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT create_line_reservations;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END create_line_reservations;

/*************************************************************************/
   PROCEDURE release_batch (
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,p_ignore_exception         IN              VARCHAR2 := NULL) --Bug#5186328
   IS
      l_api_name     CONSTANT VARCHAR2 (30) := 'RELEASE_BATCH';
      setup_failure           EXCEPTION;
      batch_release_failure   EXCEPTION;
      batch_release_exception  EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT release_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('ReleaseBatch');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_release_batch_pvt.release_batch
                         (p_batch_header_rec            => p_batch_header_rec
                         ,p_phantom_product_id          => NULL
                         ,x_batch_header_rec            => x_batch_header_rec
                         ,x_return_status               => x_return_status
                         ,x_exception_material_tbl      => x_exception_material_tbl);

      IF x_return_status NOT IN (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
         RAISE batch_release_failure;
      END IF;            /* IF x_return_status NOT IN */

      /*Bug#5186328 rework if return status is X then log message saying batch has exceptions*/
      IF NVL(p_ignore_exception,fnd_api.g_false) = fnd_api.g_false AND
         x_return_status = gme_common_pvt.g_exceptions_err THEN
         gme_common_pvt.log_message('GME_MATERIAL_EXCEPTIONS');
      ELSE
       gme_common_pvt.log_message ('GME_API_BATCH_RELEASED');
      END IF;


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN batch_release_failure THEN
         ROLLBACK TO SAVEPOINT release_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT release_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT release_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END release_batch;

/*************************************************************************/
   PROCEDURE release_step (
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,p_ignore_exception         IN              VARCHAR2 := NULL) --Bug#5186328
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'RELEASE_STEP';
      setup_failure          EXCEPTION;
      step_release_failure   EXCEPTION;
      step_release_exception EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT release_step;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('ReleaseStep');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_release_batch_step_pvt.release_step
                        (p_batch_step_rec              => p_batch_step_rec
                        ,p_batch_header_rec            => p_batch_header_rec
                        ,x_batch_step_rec              => x_batch_step_rec
                        ,x_exception_material_tbl      => x_exception_material_tbl
                        ,x_return_status               => x_return_status);

      IF x_return_status NOT IN (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
         RAISE step_release_failure;
      END IF;            /* IF x_return_status NOT IN */

      /*Bug#5186328 rework if return status is X then log message saying batch has exceptions*/
      IF NVL(p_ignore_exception,fnd_api.g_false) = fnd_api.g_false AND
         x_return_status = gme_common_pvt.g_exceptions_err THEN
         gme_common_pvt.log_message('GME_MATERIAL_EXCEPTIONS');
      ELSE
         gme_common_pvt.log_message ('GME_API_STEP_RELEASED');
      END IF;


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN step_release_failure THEN
         ROLLBACK TO SAVEPOINT release_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT release_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT release_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END release_step;

/*************************************************************************/
   PROCEDURE complete_batch (
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,p_ignore_exception         IN              VARCHAR2 := NULL) --Bug#5186328
   IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'COMPLETE_BATCH';
      setup_failure            EXCEPTION;
      batch_complete_failure   EXCEPTION;
      batch_complete_exception EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT complete_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CompleteBatch');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_complete_batch_pvt.complete_batch
                        (p_batch_header_rec            => p_batch_header_rec
                        ,x_exception_material_tbl      => x_exception_material_tbl
                        ,x_batch_header_rec            => x_batch_header_rec
                        ,x_return_status               => x_return_status);

      IF x_return_status NOT IN(fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
         RAISE batch_complete_failure;
      END IF;            /* IF x_return_status NOT IN */

      /*Bug#5186328 rework if return status is X then log message saying batch has exceptions*/
      IF NVL(p_ignore_exception,fnd_api.g_false) = fnd_api.g_false AND
         x_return_status = gme_common_pvt.g_exceptions_err THEN
         gme_common_pvt.log_message('GME_MATERIAL_EXCEPTIONS');
      ELSE
         gme_common_pvt.log_message ('GME_API_BATCH_COMPLETED');
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN batch_complete_failure THEN
         ROLLBACK TO SAVEPOINT complete_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT complete_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT complete_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END complete_batch;

/*************************************************************************/
   PROCEDURE complete_step (
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,p_ignore_exception         IN              VARCHAR2 := NULL)  --Bug#5186328
   IS
      l_api_name     CONSTANT VARCHAR2 (30) := 'COMPLETE_STEP';
      setup_failure           EXCEPTION;
      step_complete_failure   EXCEPTION;
      step_complete_exception EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT complete_step;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CompleteStep');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_complete_batch_step_pvt.complete_step
                        (p_batch_step_rec              => p_batch_step_rec
                        ,p_batch_header_rec            => p_batch_header_rec
                        ,x_batch_step_rec              => x_batch_step_rec
                        ,x_exception_material_tbl      => x_exception_material_tbl
                        ,x_return_status               => x_return_status);

      IF x_return_status NOT IN (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
         RAISE step_complete_failure;
      END IF;            /* IF x_return_status NOT IN */


      /*Bug#5186328 rework if return status is X then log message saying batch has exceptions*/
      IF NVL(p_ignore_exception,fnd_api.g_false) = fnd_api.g_false AND
         x_return_status = gme_common_pvt.g_exceptions_err THEN
         gme_common_pvt.log_message('GME_MATERIAL_EXCEPTIONS');
      ELSE
         gme_common_pvt.log_message ('GME_API_STEP_COMPLETED');
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN step_complete_failure THEN
         ROLLBACK TO SAVEPOINT complete_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT complete_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT complete_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END complete_step;

/*************************************************************************/
   PROCEDURE delete_step (
      p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec     IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'DELETE_STEP';
      delete_step_failed    EXCEPTION;
      batch_save_failed     EXCEPTION;
      setup_failure         EXCEPTION;
   BEGIN
      /* Set the savepoint before proceeding */
      SAVEPOINT delete_step;

      /* Setup the common constants used accross the apis */
      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('DeleteStep');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;
      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Punit Kumar */
      gme_common_pvt.set_timestamp;
      gme_delete_batch_step_pvt.delete_step
                                        (x_return_status       => x_return_status
                                        ,p_batch_step_rec      => p_batch_step_rec
                                        ,p_reroute_flag        => FALSE);

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         NULL;
      ELSE
         RAISE delete_step_failed;
      END IF;
            -- NEW
            GME_ERES_PKG.INSERT_EVENT(P_EVENT_NAME        => gme_common_pvt.G_BATCHSTEP_REMOVED
                               ,P_EVENT_KEY               => p_batch_step_rec.batch_id||'-'||p_batch_step_rec.BATCHSTEP_id
                               ,P_USER_KEY_LABEL          => FND_MESSAGE.GET_STRING('GME','GME_PSIG_BATCH_STEP_LABEL')
                               ,P_USER_KEY_VALUE          => gme_common_pvt.g_organization_code ||
                                                             '-'||p_batch_header_rec.batch_no||'-'|| p_batch_step_rec.BATCHSTEP_NO
                                                             ||'-'||GME_ERES_PKG.GET_OPRN_NO(p_batch_step_rec.OPRN_ID)
                               ,P_POST_OP_API             => 'NONE'
                               ,P_PARENT_EVENT            => NULL
                               ,P_PARENT_EVENT_KEY        => NULL
                               ,P_PARENT_ERECORD_ID       => NULL
                               ,X_STATUS                  => x_return_status);
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE delete_step_failed;
      END IF;



         gme_common_pvt.log_message ('GME_API_STEP_DELETE');


      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);
   EXCEPTION
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT delete_step;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN delete_step_failed OR batch_save_failed THEN
         ROLLBACK TO SAVEPOINT delete_step;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_step;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END delete_step;

/*************************************************************************
  Procedure: insert_step

   Modification History :
   Punit Kumar 07-Apr-2005 Convergence Changes
/*************************************************************************/
   PROCEDURE insert_step (
      p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_batch_step_rec     IN              gme_batch_steps%ROWTYPE
     ,x_batch_step         OUT NOCOPY      gme_batch_steps%ROWTYPE)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)              := 'INSERT_STEP';
      l_batch_header        gme_batch_header%ROWTYPE;
      insert_step_failed    EXCEPTION;
      batch_save_failed     EXCEPTION;
      setup_failure         EXCEPTION;

      -- Bug 5903208
      gmf_cost_failure         EXCEPTION;
      l_message_count		   NUMBER;
      l_message_list		   VARCHAR2(2000);

   BEGIN
      /* Set the savepoint before proceeding */
      SAVEPOINT insert_step;

      /* Initialize message list and count if needed */
      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('InsertStep');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Punit Kumar */
      gme_common_pvt.set_timestamp;
      gme_insert_step_pvt.insert_batch_step
                                    (p_gme_batch_header      => p_batch_header_rec
                                    ,p_gme_batch_step        => p_batch_step_rec
                                    ,x_gme_batch_step        => x_batch_step
                                    ,x_return_status         => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE insert_step_failed;
      END IF;

      --
      -- Bug 5903208 -- call to GMF
      --
      GMF_VIB.Update_Batch_Requirements
      ( p_api_version   =>    1.0,
        p_init_msg_list =>    FND_API.G_FALSE,
        p_batch_id      =>    p_batch_header_rec.batch_id,
        x_return_status =>    x_return_status,
        x_msg_count     =>    l_message_count,
        x_msg_data      =>    l_message_list);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
         RAISE gmf_cost_failure;
      END IF;
      -- End Bug 5903208

      -- NEW
      GME_ERES_PKG.INSERT_EVENT(P_EVENT_NAME              => gme_common_pvt.G_BATCHSTEP_ADDED
                               ,P_EVENT_KEY               => x_batch_step.batch_id||'-'||x_batch_step.BATCHSTEP_id
                               ,P_USER_KEY_LABEL          => FND_MESSAGE.GET_STRING('GME','GME_PSIG_BATCH_STEP_LABEL')
                               ,P_USER_KEY_VALUE          => gme_common_pvt.g_organization_code ||
                                                             '-'||p_batch_header_rec.batch_no||'-'|| x_batch_step.BATCHSTEP_NO
                                                             ||'-'||GME_ERES_PKG.GET_OPRN_NO(x_batch_step.OPRN_ID)
                               ,P_POST_OP_API             => 'NONE'
                               ,P_PARENT_EVENT            => NULL
                               ,P_PARENT_EVENT_KEY        => NULL
                               ,P_PARENT_ERECORD_ID       => NULL
                               ,X_STATUS                  => x_return_status);
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE insert_step_failed;
      END IF;
      gme_common_pvt.log_message ('GME_INSERT_STEP');
      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN   gmf_cost_failure THEN
        -- Bug 5903208
        x_return_status := FND_API.G_RET_STS_ERROR;

      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT insert_step;
         x_batch_step := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN insert_step_failed OR batch_save_failed THEN
         ROLLBACK TO SAVEPOINT insert_step;
         x_batch_step := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT insert_step;
         x_batch_step := NULL;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END insert_step;


      PROCEDURE revert_batch (
      p_validation_level       	IN              NUMBER := gme_common_pvt.g_max_errors
     ,p_init_msg_list          	IN              VARCHAR2 := FND_API.G_FALSE
     ,x_message_count          	OUT NOCOPY      NUMBER
     ,x_message_list           	OUT NOCOPY      VARCHAR2
     ,x_return_status          	OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec       	IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec      	OUT NOCOPY 	gme_batch_header%ROWTYPE)
     IS

      l_api_name      CONSTANT VARCHAR2 (30) := 'REVERT_BATCH';
      setup_failure            	EXCEPTION;
      batch_revert_failure	EXCEPTION;

     BEGIN

     SAVEPOINT revert_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('RevertBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'calling revert batch pvt');
      END IF;

      gme_revert_batch_pvt.revert_batch
                                    (p_batch_header_rec      => p_batch_header_rec,
                                     x_batch_header_rec      => x_batch_header_rec,
                                     x_return_status         => x_return_status);

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'x_return_status='
                             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE batch_revert_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */


      gme_common_pvt.log_message ('GME_API_BATCH_UNCERTIFIED');


      gme_common_pvt.count_and_get (x_count        => x_message_count,
                                    p_encoded      => fnd_api.g_false,
                                    x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Exiting api '
                             || g_pkg_name
                             || '.'
                             || l_api_name
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN batch_revert_failure THEN
         ROLLBACK TO SAVEPOINT revert_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT revert_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT revert_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error ;


 END revert_batch;

PROCEDURE revert_step (
      p_validation_level       	IN              NUMBER := gme_common_pvt.g_max_errors
     ,p_init_msg_list          	IN              VARCHAR2 := FND_API.G_FALSE
     ,x_message_count          	OUT NOCOPY      NUMBER
     ,x_message_list           	OUT NOCOPY      VARCHAR2
     ,x_return_status          	OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec        	IN         gme_batch_steps%ROWTYPE
     ,p_batch_header_rec        IN 	   gme_batch_header%ROWTYPE
     ,x_batch_step_rec        	OUT NOCOPY gme_batch_steps%ROWTYPE)IS


      l_api_name      CONSTANT VARCHAR2 (30) := 'REVERT_STEP';
      setup_failure            	EXCEPTION;
      step_revert_failure	EXCEPTION;

     BEGIN

     SAVEPOINT revert_step;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('RevertStep');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'calling revert step pvt');
      END IF;

      gme_revert_step_pvt.revert_step
                                    (p_batch_step_rec      	=> p_batch_step_rec,
                                     p_batch_header_rec      	=> p_batch_header_rec,
                                     x_batch_step_rec      	=> x_batch_step_rec,
                                     x_return_status         	=> x_return_status);

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'x_return_status='
                             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE step_revert_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */


         gme_common_pvt.log_message ('GME_BATCH_STEP_UNCERTIFIED');


      gme_common_pvt.count_and_get (x_count        => x_message_count,
                                    p_encoded      => fnd_api.g_false,
                                    x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Exiting api '
                             || g_pkg_name
                             || '.'
                             || l_api_name
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN step_revert_failure THEN
         ROLLBACK TO SAVEPOINT revert_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT revert_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT revert_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END revert_step;
/*************************************************************************/
   PROCEDURE close_batch (
      p_validation_level   IN              NUMBER
     ,p_init_msg_list      IN              VARCHAR2
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'CLOSE_BATCH';
      setup_failure         EXCEPTION;
      batch_close_failure   EXCEPTION;
      batch_save_failed     EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the savepoint before proceeding */
      SAVEPOINT close_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CloseBatch');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Calling gme_close_batch_pvt.close_batch.');
      END IF;

      gme_close_batch_pvt.close_batch
                                    (p_batch_header_rec      => p_batch_header_rec
                                    ,x_batch_header_rec      => x_batch_header_rec
                                    ,x_return_status         => x_return_status);

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Came back from Pvt Close Batch with status '
                             || x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         /* This comment has to be removed after this api  becomes available.
         GME_TRANS_ENGINE_PVT.inform_OM
                   ( p_action              => 'DELETE'
                   , p_trans_id            => NULL
                   , p_trans_id_reversed   => NULL
                   , p_gme_batch_hdr       => x_batch_header
                   , p_gme_matl_dtl        => NULL
                   );
         */
         NULL;
      ELSE
         RAISE batch_close_failure;
      END IF;


       gme_common_pvt.log_message ('GME_API_BATCH_CLOSED');


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN setup_failure OR batch_close_failure OR batch_save_failed THEN
         ROLLBACK TO SAVEPOINT close_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT close_batch;
         x_batch_header_rec := NULL;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END close_batch;

/*************************************************************************/
   PROCEDURE close_step (
      p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,                                                       /* Punit Kumar */
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_batch_step_rec     IN              gme_batch_steps%ROWTYPE
     ,p_delete_pending     IN              VARCHAR2 := fnd_api.g_false
     ,x_batch_step_rec     OUT NOCOPY      gme_batch_steps%ROWTYPE)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)              := 'CLOSE_STEP';
      setup_failure         EXCEPTION;
      batch_save_failed     EXCEPTION;
      step_close_failed     EXCEPTION;
      l_batch_hdr           gme_batch_header%ROWTYPE;
   BEGIN
      /* Set the savepoint before proceeding */
      SAVEPOINT close_batch_step;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CloseStep');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;
      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      gme_close_step_pvt.close_step (p_batch_step_rec      => p_batch_step_rec
                                    ,p_delete_pending      => p_delete_pending
                                    ,x_batch_step_rec      => x_batch_step_rec
                                    ,x_return_status       => x_return_status);

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         NULL;
      ELSE
         RAISE step_close_failed;
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;


      gme_common_pvt.log_message ('GME_BATCH_STEP_CLOSED');


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);
   EXCEPTION
      WHEN setup_failure OR step_close_failed OR batch_save_failed THEN
         ROLLBACK TO SAVEPOINT close_batch_step;
         x_batch_step_rec := NULL;
         /*N Punit Kumar */
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT close_batch_step;
         x_batch_step_rec := NULL;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         /*N Punit Kumar */
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END close_step;

/*************************************************************************/
   PROCEDURE reopen_batch (
      p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_reopen_steps       IN              VARCHAR2 := fnd_api.g_false
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'REOPEN_BATCH';
      setup_failure          EXCEPTION;
      batch_save_failed      EXCEPTION;
      batch_reopen_failure   EXCEPTION;
   BEGIN
      /* Set the save point before processing */
      SAVEPOINT reopen_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('ReopenBatch');
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Initialize message list and count if needed*/
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Set the success staus to success inititally*/
      x_return_status := fnd_api.g_ret_sts_success;

      -- Pawan kumar added for bug 4956087
      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;
      gme_common_pvt.set_timestamp;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
        gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'calling private layer');
      END IF;

      gme_reopen_batch_pvt.reopen_batch
                                    (p_batch_header_rec      => p_batch_header_rec
                                    ,p_reopen_steps          => p_reopen_steps
                                    ,x_batch_header_rec      => x_batch_header_rec
                                    ,x_return_status         => x_return_status);

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'after private layer with sts'||x_return_status);
      END IF;

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
         NULL;
      ELSE
         RAISE batch_reopen_failure;
      END IF;

         gme_common_pvt.log_message ('GME_API_BATCH_REOPENED');


      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);


   EXCEPTION
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT reopen_batch;
         x_batch_header_rec := NULL;

         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
             ||'reopen_batch error : SETUP_FAILURE'
                               );
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         /*N Punit Kumar */
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN batch_reopen_failure OR batch_save_failed THEN
         ROLLBACK TO SAVEPOINT reopen_batch;
         x_batch_header_rec := NULL;

         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
               || 'reopen_batch error : BATCH_REOPEN_FAILURE OR BATCH_SAVE_FAILED OR ERROR_CHECK_PHANT.'
              );
         END IF;

         /*N Punit Kumar */
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT reopen_batch;
         x_batch_header_rec := NULL;

         IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
            ||'reopen_batch error : OTHERS.' || SQLCODE
                               );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END reopen_batch;

/*************************************************************************/
   PROCEDURE reopen_step (
      p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,                                                       /* Punit Kumar */
      p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_batch_step_rec     IN              gme_batch_steps%ROWTYPE
     ,x_batch_step_rec     OUT NOCOPY      gme_batch_steps%ROWTYPE)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)              := 'REOPEN_STEP';
      setup_failure         EXCEPTION;
      step_save_failed      EXCEPTION;
      step_reopen_failure   EXCEPTION;
      l_batch_header        gme_batch_header%ROWTYPE;
   BEGIN
      -- Set the save point before proceeding
      SAVEPOINT reopen_batch_step;

      /* Initialize message list and count if needed*/
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;                 /* Punit Kumar */
      END IF;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('ReopenStep');
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
        gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'entering');
      END IF;
      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;
      /* Set the success staus to success inititally*/
      x_return_status := fnd_api.g_ret_sts_success;
      /* Punit Kumar */
      gme_common_pvt.set_timestamp;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
        gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'calling private layer');
      END IF;

      gme_reopen_step_pvt.reopen_step (p_batch_step_rec      => p_batch_step_rec
                                      ,x_batch_step_rec      => x_batch_step_rec
                                      ,x_return_status       => x_return_status);

      IF (g_debug <= gme_debug.g_log_procedure) THEN
        gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'existing private layer with status'||x_return_status );
      END IF;

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
         NULL;
      ELSE
         RAISE step_reopen_failure;
      END IF;


         gme_common_pvt.log_message ('GME_API_STEP_REOPENED');


      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line ('Normal end of Public Reopen_Step.'
                            ,gme_debug.g_log_procedure
                            ,'reopen_batch');
      END IF;
   EXCEPTION
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT reopen_batch_step;
         x_batch_step_rec := NULL;

         IF (g_debug <= gme_debug.g_log_procedure) THEN
             gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             ||'reopen_step error : SETUP_FAILURE.'
                               );
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         /* Punit Kumar */
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN step_reopen_failure OR step_save_failed THEN
         ROLLBACK TO SAVEPOINT reopen_batch_step;
         x_batch_step_rec := NULL;

         IF (g_debug <= gme_debug.g_log_procedure) THEN
             gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             ||
               'reopen_step error : STEP_REOPEN_FAILURE OR STEP_SAVE_FAILED.'
              );
         END IF;

         /* Punit Kumar */
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT reopen_batch_step;
         x_batch_step_rec := NULL;

        IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
            ||'reopen_step error : OTHERS.' || SQLCODE
                               );
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         /* Punit Kumar */
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END reopen_step;

/*================================================================================
    Procedure
      incremental_backflush
    Description
      This procedure is used to incrementally backflush the qty to the material line.

    Parameters
      p_batch_header_rec (R)    The batch header record
      p_material_detail_rec (R) The material detail record
      p_qty (R)                 The quantity to apply incrementally as follows:
      p_qty_type (R)            0 - By increment qty
                                1 - New actual qty
                                2 - % of Plan
      p_trans_date              Transaction date to record for the incremental backflush
      x_exception_material_tab  Table of materials that could not be consumed or yielded
                                for the calculated incremental quantity
      x_return_status           result of the API call
                                S - Success
                                E - Error
                                U - Unexpected Error
                                X - Batch Exception

   HISTORY


      05-AUG-2009   G. Muratore   Bug 8639523
        Clear the cache just in case any transactions hit the tree.
        A blank error message appeared and/or inventory was driven negative upon
        clicking ok a second time. This was due to the qty tree not being accurate.

      24-Nov-2009   G. Muratore   Bug 8751983
        Set the IB specific globals to potentially be used for negative IB.
  ================================================================================*/
   PROCEDURE incremental_backflush (
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_material_detail_rec      IN              gme_material_details%ROWTYPE
     ,p_qty                      IN              NUMBER
     ,p_qty_type                 IN              NUMBER
     ,p_trans_date               IN              DATE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab )
   IS
      l_api_name            CONSTANT VARCHAR2 (30) := 'INCREMENTAL_BACKFLUSH';
      l_trans_date                   DATE;

      l_backflush_rsrc_usg_ind       NUMBER;

      incremental_backflush_failed   EXCEPTION;
      setup_failure                  EXCEPTION;
   BEGIN
      /* Set the savepoint */
      SAVEPOINT incremental_backflush;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('IncrementalBackflush');
      END IF;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Setup the common constants used across the apis */
     IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      l_trans_date := p_trans_date;

      -- 8751983 - Set IB globals to be used later for resource trans reversals during negative IB.
      IF l_trans_date IS NOT NULL THEN
         gme_common_pvt.g_ib_timestamp_set := 1;
         gme_common_pvt.g_ib_timestamp_date := l_trans_date;
      ELSE
         l_trans_date := gme_common_pvt.g_timestamp;
         gme_common_pvt.g_ib_timestamp_set := 0;
         gme_common_pvt.g_ib_timestamp_date := NULL;
      END IF;


      IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
          gme_debug.put_line('l_trans_date is '||to_char(l_trans_date, 'DD-MON-YYYY HH24:MI:SS'));
          gme_debug.put_line('gme_common_pvt.g_ib_timestamp_set is '||gme_common_pvt.g_ib_timestamp_set);
      END IF;

      -- does backflush resource usage need to be performed?
      IF (p_batch_header_rec.batch_status = gme_common_pvt.g_step_wip AND
           p_material_detail_rec.line_type = gme_common_pvt.g_line_type_prod AND
           gme_common_pvt.g_backflush_rsrc_usg_ind = 1) THEN
        l_backflush_rsrc_usg_ind := 1;
      ELSE
        l_backflush_rsrc_usg_ind := 0;
      END IF;

      gme_incremental_backflush_pvt.incremental_backflush
                        (p_batch_header_rec            => p_batch_header_rec
                        ,p_material_detail_rec         => p_material_detail_rec
                        ,p_qty                         => p_qty
                        ,p_qty_type                    => p_qty_type
                        ,p_trans_date                  => l_trans_date
                        ,p_backflush_rsrc_usg_ind      => l_backflush_rsrc_usg_ind
                        ,x_exception_material_tbl      => x_exception_material_tbl
                        ,x_return_status               => x_return_status);

      IF x_return_status NOT IN
                 (fnd_api.g_ret_sts_success, gme_common_pvt.g_exceptions_err) THEN
         IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||' after gme_incremental_backflush_pvt.incremental_backflush; x_return_status= '||x_return_status);
         END IF;
         RAISE incremental_backflush_failed;
      END IF;    /* IF x_return_status NOT IN */

     /*Bug#5277982 if there are any exceptions then we give message saying IB done with exceptions*/
      IF x_exception_material_tbl.COUNT > 0  THEN
       gme_common_pvt.log_message('GME_IB_EXCEPTIONS');
      ELSE
       gme_common_pvt.log_message ('GME_API_PARTIAL_CERTIFIED');
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'gme_api_main: Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);
   EXCEPTION
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT incremental_backflush;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN incremental_backflush_failed THEN
         ROLLBACK TO SAVEPOINT incremental_backflush;
         -- Bug 8639523 - Clear the cache just in case any transactions hit the tree.
         inv_quantity_tree_pub.clear_quantity_cache;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||' in exception block; x_return_status= '||x_return_status);
         END IF;
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT incremental_backflush;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END incremental_backflush;

    /*================================================================================
     Procedure
       reroute_batch
     Description
       This procedure reroutes batch (typically change the route associated with the batch).

     Parameters
       p_batch_header_rec (R)    The batch header row to identify the batch
                                 Following columns are used from this row.
                                 batch_id  (R)
       p_validity_rule_id (R)    Recipe validity rule id for the new recipe.

       x_batch_header_rec        The batch header that is returned, with all the data
       x_return_status           outcome of the API call
                                 S - Success
                                 E - Error
                                 U - Unexpected Error
                                 C - No continous periods found
   ================================================================================*/
   PROCEDURE reroute_batch (
      p_validation_level      IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 DEFAULT fnd_api.g_false
     ,p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_validity_rule_id      IN              NUMBER
     ,p_use_workday_cal       IN              VARCHAR2 DEFAULT fnd_api.g_false
     ,p_contiguity_override   IN              VARCHAR2 DEFAULT fnd_api.g_false
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_batch_header_rec      OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'REROUTE_BATCH';
      no_continous_periods   EXCEPTION;
      setup_failure          EXCEPTION;
   BEGIN
      /* Set savepoint here */
      SAVEPOINT reroute_batch_main;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('RerouteBatch');
      END IF;

      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      IF (fnd_api.to_boolean (p_init_msg_list) ) THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_reroute_batch_pvt.reroute_batch
                              (p_batch_header_rec         => p_batch_header_rec
                              ,p_validity_rule_id         => p_validity_rule_id
                              ,p_use_workday_cal          => p_use_workday_cal
                              ,p_contiguity_override      => p_contiguity_override
                              ,x_return_status            => x_return_status
                              ,x_batch_header_rec         => x_batch_header_rec);

      IF (x_return_status = 'C') THEN
         RAISE no_continous_periods;
      ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSE
         --FPBug#5040865 Begin
         IF x_batch_header_rec.batch_type = 0 THEN
           FND_MESSAGE.SET_NAME('GME','GME_BATCH');
         ELSE
           FND_MESSAGE.SET_NAME('GME','GME_FIRM_PLAN_ORDER');
         END IF;
         gme_common_pvt.log_message ('GME_API_BATCH_REROUTED','DOC',FND_MESSAGE.GET);
        --FPBug#5040865 End
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT reroute_batch_main;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN no_continous_periods THEN
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT reroute_batch_main;
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO SAVEPOINT reroute_batch_main;
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'UNEXPECTED:'
                                || SQLERRM);
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT reroute_batch_main;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'OTHERS:'
                                || SQLERRM);
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
   END reroute_batch;

   /*================================================================================
     Procedure
       cancel_batch
     Description
       This procedure cancels batch and all the phantom batches.
        It also cancels all the steps.

     Parameters
       p_batch_header (R)        The batch header row to identify the batch
                                 Following columns are used from this row.
                                 batch_id  (R)
       x_batch_header            The batch header that is returned, with all the data
       x_return_status           outcome of the API call
                                 S - Success
                                 E - Error
                                 U - Unexpected Error
   ================================================================================*/
   PROCEDURE cancel_batch (
      p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'CANCEL_BATCH';
      setup_failure          EXCEPTION;
      batch_cancel_failure   EXCEPTION;
   BEGIN
      SAVEPOINT cancel_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CancelBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'calling pvt cancel');
      END IF;

      gme_cancel_batch_pvt.cancel_batch
                                    (p_batch_header_rec      => p_batch_header_rec
                                    ,x_batch_header_rec      => x_batch_header_rec
                                    ,x_return_status         => x_return_status);

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'x_return_status='
                             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE batch_cancel_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

      --FPBug#5040865 Begin
      IF x_batch_header_rec.batch_type = 0 THEN
       FND_MESSAGE.SET_NAME('GME','GME_BATCH');
      ELSE
       FND_MESSAGE.SET_NAME('GME','GME_FIRM_PLAN_ORDER');
      END IF;
      gme_common_pvt.log_message ('GME_API_BATCH_CANCELLED','DOC',FND_MESSAGE.GET);
      --FPBug#5040865 End

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Exiting api '
                             || g_pkg_name
                             || '.'
                             || l_api_name
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN batch_cancel_failure THEN
         ROLLBACK TO SAVEPOINT cancel_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT cancel_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT cancel_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END cancel_batch;

    /*================================================================================
     Procedure
       terminate_batch

     Description
       This procedure terminates batch and all the phantom batches.
        It also terminates all the steps.

     Parameters
       p_batch_header (R)        The batch header row to identify the batch
                                 Following columns are used from this row.
                                 batch_id  (R)
       p_reason_name             Reason to terminate the batch
       x_batch_header            The batch header that is returned, with all the data
       x_return_status           outcome of the API call
                                 S - Success
                                 E - Error
                                 U - Unexpected Error
   ================================================================================*/
   PROCEDURE terminate_batch (
      p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name       CONSTANT VARCHAR2 (30) := 'TERMINATE_BATCH';
      setup_failure             EXCEPTION;
      batch_terminate_failure   EXCEPTION;
   BEGIN
      /* Set the save point before processing */
      SAVEPOINT terminate_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('TerminateBatch');
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Call Private Terminate_Batch');
      END IF;

      gme_terminate_batch_pvt.terminate_batch
                                    (p_batch_header_rec      => p_batch_header_rec
                                    ,x_batch_header_rec      => x_batch_header_rec
                                    ,x_return_status         => x_return_status);

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'x_return_status='
                             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE batch_terminate_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

         gme_common_pvt.log_message ('GME_API_BATCH_TERMINATED');


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting api with return status='
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT terminate_batch;
         x_batch_header_rec := NULL;

         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'SETUP_FAILURE.');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN batch_terminate_failure THEN
         ROLLBACK TO SAVEPOINT terminate_batch;
         x_batch_header_rec := NULL;

         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line
                             (   g_pkg_name
                              || '.'
                              || l_api_name
                              || ':'
                              || 'BATCH_TERMINATE_FAILURE OR BATCH_SAVE_FAILED.');
         END IF;

         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT terminate_batch;
         x_batch_header_rec := NULL;

         IF (g_debug <= gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END terminate_batch;

/*************************************************************************/
   PROCEDURE unrelease_batch (
      p_validation_level        IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list           IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count           OUT NOCOPY      NUMBER
     ,x_message_list            OUT NOCOPY      VARCHAR2
     ,x_return_status           OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec        IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec        OUT NOCOPY      gme_batch_header%ROWTYPE
     ,p_create_resv_pend_lots   IN              NUMBER)
   IS
      l_api_name       CONSTANT VARCHAR2 (30) := 'UNRELEASE_BATCH';
      setup_failure             EXCEPTION;
      batch_unrelease_failure   EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT unrelease_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('UnreleaseBatch');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_common_pvt.reset_txn_hdr_tbl; -- nsinghi bug#5176319
      gme_unrelease_batch_pvt.unrelease_batch
                          (p_batch_header_rec           => p_batch_header_rec
                          ,p_create_resv_pend_lots      => p_create_resv_pend_lots
                          ,x_batch_header_rec           => x_batch_header_rec
                          ,x_return_status              => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE batch_unrelease_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

         gme_common_pvt.log_message ('GME_API_BATCH_UNRELEASED');

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN batch_unrelease_failure THEN
         ROLLBACK TO SAVEPOINT unrelease_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT unrelease_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT unrelease_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END unrelease_batch;

/*************************************************************************/
   PROCEDURE unrelease_step (
      p_validation_level        IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list           IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count           OUT NOCOPY      NUMBER
     ,x_message_list            OUT NOCOPY      VARCHAR2
     ,x_return_status           OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec          IN              gme_batch_steps%ROWTYPE
     ,p_batch_header_rec        IN              gme_batch_header%ROWTYPE
     ,x_batch_step_rec          OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,p_create_resv_pend_lots   IN              NUMBER)
   IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'UNRELEASE_STEP';
      setup_failure            EXCEPTION;
      step_unrelease_failure   EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT unrelease_step;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('UnreleaseStep');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_batch_header_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_common_pvt.reset_txn_hdr_tbl; -- nsinghi bug#5176319
      gme_unrelease_step_pvt.unrelease_step
           (p_batch_step_rec             => p_batch_step_rec
           ,p_update_inventory_ind       => p_batch_header_rec.update_inventory_ind
           ,p_create_resv_pend_lots      => p_create_resv_pend_lots
           ,p_from_unrelease_batch       => 0
           ,x_batch_step_rec             => x_batch_step_rec
           ,x_return_status              => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE step_unrelease_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */


         gme_common_pvt.log_message ('GME_BATCH_STEP_UNRELEASED');

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN step_unrelease_failure THEN
         ROLLBACK TO SAVEPOINT unrelease_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT unrelease_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT unrelease_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END unrelease_step;

/*************************************************************************/
   PROCEDURE auto_detail_line (
      p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,p_material_detail_rec   IN              gme_material_details%ROWTYPE)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'AUTO_DETAIL_LINE';
      setup_failure         EXCEPTION;
      auto_detail_failure   EXCEPTION;
   BEGIN
      /* Set the save point initially */
      SAVEPOINT auto_detail_line;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('AutoDetailLine');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                 gme_common_pvt.setup (p_material_detail_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;
      /* Set the timestamp  */
      gme_common_pvt.set_timestamp;
      gme_reservations_pvt.auto_detail_line
                             (p_material_details_rec      => p_material_detail_rec
                             ,x_return_status             => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE auto_detail_failure;
      END IF;

       gme_common_pvt.log_message ('GME_BATCH_AUTO_DETAIL_LINE');

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN auto_detail_failure OR setup_failure THEN
         ROLLBACK TO SAVEPOINT auto_detail_line;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT auto_detail_line;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END auto_detail_line;
   /*************************************************************************/
   PROCEDURE auto_detail_batch(
      p_init_msg_list            IN              VARCHAR2 := FND_API.G_FALSE,
      x_message_count            OUT NOCOPY      NUMBER,
      x_message_list             OUT NOCOPY      VARCHAR2,
      x_return_status            OUT NOCOPY      VARCHAR2,
      p_batch_rec                IN              gme_batch_header%ROWTYPE) IS

      l_api_name        CONSTANT VARCHAR2 (30)   := 'AUTO_DETAIL_BATCH';


      setup_failure              EXCEPTION;
      auto_detail_failure        EXCEPTION;
   BEGIN
      /* Set the save point initially */
      SAVEPOINT auto_detail_batch;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('AutoDetailBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                 gme_common_pvt.setup (p_batch_rec.organization_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set the timestamp  */
      gme_common_pvt.set_timestamp;

      gme_reservations_pvt.auto_detail_batch(p_batch_rec => p_batch_rec
                                            ,x_return_status => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE auto_detail_failure;
      END IF;
      gme_common_pvt.log_message ('GME_BATCH_AUTO_DETAIL_BATCH');
      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN auto_detail_failure OR setup_failure THEN
         ROLLBACK TO SAVEPOINT auto_detail_batch;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list);
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT auto_detail_batch;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END auto_detail_batch;

/*************************************************************************/
   PROCEDURE create_pending_product_lot (
      p_validation_level        IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list           IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count           OUT NOCOPY      NUMBER
     ,x_message_list            OUT NOCOPY      VARCHAR2
     ,x_return_status           OUT NOCOPY      VARCHAR2
     ,p_org_id                  IN              NUMBER
     ,p_pending_product_lots_rec IN  gme_pending_product_lots%ROWTYPE
     ,x_pending_product_lots_rec OUT NOCOPY  gme_pending_product_lots%ROWTYPE)
   IS
      l_api_name       CONSTANT VARCHAR2 (30) := 'create_pending_product_lot';
      setup_failure             EXCEPTION;
      create_pp_lot_failure     EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT create_pp_lot;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('CreatePendingProdLot');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_org_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_pending_product_lots_pvt.create_pending_product_lot
                          (p_pending_product_lots_rec      => p_pending_product_lots_rec
                          ,x_pending_product_lots_rec      => x_pending_product_lots_rec
                          ,x_return_status                 => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE create_pp_lot_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */


      gme_common_pvt.log_message ('GME_API_PP_LOT_CREATED');

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN create_pp_lot_failure THEN
         ROLLBACK TO SAVEPOINT create_pp_lot;
         x_pending_product_lots_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT create_pp_lot;
         x_pending_product_lots_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT create_pp_lot;
         x_pending_product_lots_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END create_pending_product_lot;

   PROCEDURE update_pending_product_lot (
      p_validation_level           IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list              IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count              OUT NOCOPY      NUMBER
     ,x_message_list               OUT NOCOPY      VARCHAR2
     ,x_return_status              OUT NOCOPY      VARCHAR2
     ,p_org_id                     IN              NUMBER
     ,p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
     ,x_pending_product_lots_rec   IN  OUT NOCOPY  gme_pending_product_lots%ROWTYPE)
   IS
      l_api_name       CONSTANT VARCHAR2 (30) := 'update_pending_product_lot';
      setup_failure             EXCEPTION;
      update_pp_lot_failure     EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT update_pp_lot;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('UpdatePendingProdLot');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_org_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_pending_product_lots_pvt.update_pending_product_lot
                          (p_pending_product_lots_rec      => p_pending_product_lots_rec
                          ,x_pending_product_lots_rec      => x_pending_product_lots_rec
                          ,x_return_status                 => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE update_pp_lot_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */


     gme_common_pvt.log_message ('GME_API_PP_LOT_UPDATED');


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN update_pp_lot_failure THEN
         ROLLBACK TO SAVEPOINT update_pp_lot;
         x_pending_product_lots_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT update_pp_lot;
         x_pending_product_lots_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT update_pp_lot;
         x_pending_product_lots_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END update_pending_product_lot;

   PROCEDURE delete_pending_product_lot (
      p_validation_level           IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list              IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count              OUT NOCOPY      NUMBER
     ,x_message_list               OUT NOCOPY      VARCHAR2
     ,x_return_status              OUT NOCOPY      VARCHAR2
     ,p_org_id                     IN              NUMBER
     ,p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE)
   IS
      l_api_name       CONSTANT VARCHAR2 (30) := 'delete_pending_product_lot';
      setup_failure             EXCEPTION;
      delete_pp_lot_failure     EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      SAVEPOINT delete_pp_lot;

      IF (g_debug IS NOT NULL) THEN
         gme_debug.log_initialize ('DeletePendingProdLot');
      END IF;

      IF NOT gme_common_pvt.g_setup_done THEN
         gme_common_pvt.g_setup_done :=
                    gme_common_pvt.setup (p_org_id);

         IF NOT gme_common_pvt.g_setup_done THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE setup_failure;
         END IF;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_pending_product_lots_pvt.delete_pending_product_lot
                          (p_pending_product_lots_rec      => p_pending_product_lots_rec
                          ,x_return_status                 => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE delete_pp_lot_failure;
      END IF;            /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

         gme_common_pvt.log_message ('GME_API_PP_LOT_DELETED');


      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF (g_debug IS NOT NULL) THEN
         gme_debug.put_line (   'Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN delete_pp_lot_failure THEN
         ROLLBACK TO SAVEPOINT delete_pp_lot;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT delete_pp_lot;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         ROLLBACK TO SAVEPOINT delete_pp_lot;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END delete_pending_product_lot;

END gme_api_main;

/
