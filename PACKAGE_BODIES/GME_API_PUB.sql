--------------------------------------------------------
--  DDL for Package Body GME_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_API_PUB" AS
/*  $Header: GMEPAPIB.pls 120.62.12010000.9 2009/06/18 18:21:11 gmurator ship $    */
   g_debug               VARCHAR2 (5)  := NVL(fnd_profile.VALUE ('AFLOG_LEVEL'),-1);
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_API_PUB';

   PROCEDURE gme_when_others (
      p_api_name        IN              VARCHAR2
     ,x_message_count   OUT NOCOPY      NUMBER
     ,x_message_list    OUT NOCOPY      VARCHAR2
     ,x_return_status   OUT NOCOPY      VARCHAR2
     )
   IS
   	l_api_name   CONSTANT VARCHAR2 (30)   := 'gme_when_others';
   BEGIN
     IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
     IF g_debug <= gme_debug.g_log_unexpected THEN
        gme_debug.put_line(g_pkg_name||'.'||p_api_name||':'||'When others exception:'||SQLERRM);
     END IF;
     fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
     gme_common_pvt.count_and_get (x_count        => x_message_count
                                  ,p_encoded      => fnd_api.g_false
                                  ,x_data         => x_message_list);
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   END gme_when_others ;


/*************************************************************************/
   /* Bug 5255959 added p_clear_qty_cache parameter */
   PROCEDURE save_batch (
      p_header_id       IN              NUMBER DEFAULT NULL
     ,p_table           IN              NUMBER DEFAULT NULL
     ,p_commit          IN              VARCHAR2 := fnd_api.g_false
     ,x_return_status   OUT NOCOPY      VARCHAR2
      --Bug#5584699 Changed variable from boolean to varchar2
      ,p_clear_qty_cache    IN              VARCHAR2 := FND_API.g_true)
     --,p_clear_qty_cache    IN              BOOLEAN DEFAULT TRUE)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)   := 'SAVE_BATCH';
      l_header_id           NUMBER;
      l_trans_count         NUMBER;
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);

      error_save_batch      EXCEPTION;

      CURSOR header_cursor
      IS
         SELECT DISTINCT doc_id batch_id
                    FROM gme_resource_txns_gtmp
                ORDER BY batch_id;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('p_header_id = ' || p_header_id);
         gme_debug.put_line ('p_table = ' || p_table);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      FOR header_row IN header_cursor LOOP
         -- Check that there is one and only one primary resource
         IF     gme_common_pvt.g_check_primary_rsrc = 1
            AND p_commit = fnd_api.g_true THEN
            gme_resource_engine_pvt.check_primary_resource
                                          (p_batch_id           => header_row.batch_id
                                          ,p_batchstep_id       => NULL
                                          ,x_return_status      => x_return_status);

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE error_save_batch;
            END IF;
         END IF;            -- IF gme_common_pvt.g_check_primary_rsrc = 1 THEN

         gme_resource_engine_pvt.consolidate_batch_resources
                                                         (header_row.batch_id
                                                         ,x_return_status);

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE error_save_batch;
         END IF;
      END LOOP;

      l_header_id := NVL (p_header_id, gme_common_pvt.g_transaction_header_id);


      IF (NVL (l_header_id, 0) <>  0) THEN
      	 /* Bug 5255959 added p_clear_qty_cache parameter */
         gme_transactions_pvt.process_transactions
                 (p_api_version           => 2.0
                 ,p_init_msg_list         => fnd_api.g_false
                 ,p_commit                => fnd_api.g_false
                 ,p_validation_level      => fnd_api.g_valid_level_full
                 ,p_table                 => p_table
                 ,p_header_id             => l_header_id
                 ,x_return_status         => x_return_status
                 ,x_msg_count             => l_msg_count
                 ,x_msg_data              => l_msg_data
                 ,x_trans_count           => l_trans_count
                 ,p_clear_qty_cache       => p_clear_qty_cache);

         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            IF g_debug <= gme_debug.g_log_statement THEN
               gme_debug.put_line(   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'Return status from process_transactions '
                                || x_return_status);
            END IF;

            RAISE error_save_batch;
         END IF;
      END IF; /* IF (NVL (l_header_id, 0) <>  0) */

      IF p_commit = fnd_api.g_true THEN
         COMMIT;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN error_save_batch THEN
         gme_common_pvt.count_and_get (x_count        => l_msg_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => l_msg_data);
      WHEN OTHERS THEN
      	    gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => l_msg_count
     				,x_message_list         => l_msg_data
     				,x_return_status   	=> x_return_status );
   END save_batch;

/*************************************************************************/
   PROCEDURE create_batch (
      p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_org_code                 IN              VARCHAR2 := NULL
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,p_batch_size               IN              NUMBER := NULL
     ,p_batch_size_uom           IN              VARCHAR2 := NULL
     ,p_creation_mode            IN              VARCHAR2
     ,p_recipe_id                IN              NUMBER := NULL
     ,p_recipe_no                IN              VARCHAR2 := NULL
     ,p_recipe_version           IN              NUMBER := NULL
     ,p_product_no               IN              VARCHAR2 := NULL
     ,p_item_revision            IN              VARCHAR2 := NULL
     ,p_product_id               IN              NUMBER := NULL
     ,p_sum_all_prod_lines       IN              VARCHAR2 := 'A'
     ,p_ignore_qty_below_cap     IN              VARCHAR2 := fnd_api.g_true
     ,p_use_workday_cal          IN              VARCHAR2 := fnd_api.g_true
     ,p_contiguity_override      IN              VARCHAR2 := fnd_api.g_true
     ,p_use_least_cost_validity_rule     IN              VARCHAR2 := fnd_api.g_false
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab)
   IS
      l_api_name       CONSTANT VARCHAR2 (30)               := 'CREATE_BATCH';
      l_batch_header            gme_batch_header%ROWTYPE;
      l_return_status           VARCHAR2 (1);
      l_object_type             VARCHAR2 (10);
      l_total_input             NUMBER;
      l_total_output            NUMBER;
      l_item_id                 NUMBER;
      l_item_rec                mtl_system_items_b%ROWTYPE;
      l_product_qty             NUMBER;
      l_recipe_use              NUMBER;
      l_status_type             VARCHAR2 (10);
      l_return_code             NUMBER (5);
      l_msg_count               NUMBER;
      l_msg_list                VARCHAR2 (2000);
      l_validity_tbl            gmd_validity_rules.recipe_validity_tbl;
      l_use                     VARCHAR2 (1);
      l_contiguity_override     VARCHAR2 (1);
      l_cmplt_date              DATE;
      l_exists                  NUMBER;

      CURSOR cur_validity_item (v_vrule_id NUMBER)
      IS
         SELECT inventory_item_id
           FROM gmd_recipe_validity_rules
          WHERE recipe_validity_rule_id = v_vrule_id;

      CURSOR get_item_id(v_item_no VARCHAR2)
      IS
        SELECT inventory_item_id
	  FROM mtl_system_items_kfv
	 WHERE concatenated_segments = v_item_no;

      CURSOR cur_validate_uom (v_uom_code VARCHAR2)
      IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS (SELECT 1
                          FROM mtl_units_of_measure
                         WHERE uom_code = v_uom_code);
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('CreateBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'create_batch'
                                         ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      l_batch_header := p_batch_header_rec;

      IF (l_batch_header.organization_id IS NULL AND p_org_code IS NULL) THEN
         fnd_message.set_name ('INV', 'INV_ORG_REQUIRED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_batch_header.batch_type NOT IN
             (gme_common_pvt.g_doc_type_batch, gme_common_pvt.g_doc_type_fpo) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_BATCH_TYPE');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_contiguity_override NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_contiguity_override');
         RAISE fnd_api.g_exc_error;
      ELSE
         l_contiguity_override := p_contiguity_override;
      END IF;

      IF (p_use_workday_cal NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_use_workday_cal');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_ignore_qty_below_cap NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_ignore_qty_below_cap');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_creation_mode NOT IN ('INPUT', 'OUTPUT', 'RECIPE', 'PRODUCT') ) THEN
         gme_common_pvt.log_message ('GME_API_UNSUPPORTED_MODE'
                                    ,'MODE'
                                    ,p_creation_mode);
         RAISE fnd_api.g_exc_error;
      ELSIF (p_creation_mode IN ('INPUT', 'OUTPUT', 'PRODUCT') ) THEN
         IF (p_batch_size IS NULL) THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'p_batch_size');
            RAISE fnd_api.g_exc_error;
         ELSIF (p_batch_size < 0) THEN
            gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                       ,'FIELD'
                                       ,'p_batch_size');
            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_batch_size_uom IS NULL) THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'p_batch_size_uom');
            RAISE fnd_api.g_exc_error;
         ELSE
            OPEN cur_validate_uom (p_batch_size_uom);

            FETCH cur_validate_uom
             INTO l_exists;

            IF (cur_validate_uom%NOTFOUND) THEN
               gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                          ,'FIELD'
                                          ,'p_batch_size_uom');
               CLOSE cur_validate_uom;
               RAISE fnd_api.g_exc_error;
            END IF;

            CLOSE cur_validate_uom;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('Finished parameter validation');
      END IF;

      gme_common_pvt.g_error_count := 0;
      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_batch_header.organization_id
                              ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_batch_header.organization_id := gme_common_pvt.g_organization_id;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('Finished setup');
      END IF;

      IF (gme_common_pvt.g_lab_ind = 0 AND l_batch_header.laboratory_ind = 1) THEN
         gme_common_pvt.log_message ('GME_NOT_LAB_ORG');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (gme_common_pvt.g_plant_ind = 0 AND l_batch_header.batch_type = 10) THEN
         gme_common_pvt.log_message ('GME_FPO_NO_CREATE');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (gme_common_pvt.g_lab_ind = 1 AND gme_common_pvt.g_plant_ind = 1) THEN
         IF (l_batch_header.laboratory_ind = 1) THEN
            l_object_type := 'L';
         ELSE
            IF (l_batch_header.batch_type = gme_common_pvt.g_doc_type_fpo) THEN
               l_object_type := fnd_api.g_false;
            ELSE
               l_object_type := 'P';
            END IF;
         END IF;
      ELSIF (gme_common_pvt.g_lab_ind = 1) THEN
         l_object_type := 'L';
      ELSIF (gme_common_pvt.g_plant_ind = 1) THEN
         IF (l_batch_header.batch_type = 10) THEN
            l_object_type := fnd_api.g_false;
         ELSE
            l_object_type := 'P';
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('Finished lab_ind plant_ind setup');
      END IF;

      IF NVL (gme_common_pvt.g_validate_plan_dates_ind, 0) = 1 THEN
         l_cmplt_date := NULL;
      ELSE
         l_cmplt_date := p_batch_header_rec.plan_cmplt_date;
      END IF;

      IF p_batch_header_rec.recipe_validity_rule_id IS NULL THEN
         IF p_creation_mode = 'PRODUCT' THEN
            l_product_qty := p_batch_size;
	    /*Bug#5256138 Begin item validation check starts. If we don't pass any VR and if we use PRODUCT MODE
	      then only we need to do the item validation. IF VR is provided tht will be used directly */
	    IF p_product_no IS NOT NULL THEN
	      OPEN get_item_id(p_product_no);
	      FETCH get_item_id INTO l_item_id;
	      CLOSE get_item_id;
	    ELSIF p_product_id IS NOT NULL THEN
	      l_item_id := p_product_id;
            ELSE
              gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                          ,'FIELD_NAME'
                                          ,'p_product_no or p_product_id');
              RAISE fnd_api.g_exc_error;
	    END IF;
	    --All error messages will be logged in this procedure itself..
	    gme_material_detail_pvt.validate_item_id(
	         p_org_id          => l_batch_header.organization_id
                ,p_item_id         => l_item_id
                ,x_item_rec        => l_item_rec
                ,x_return_status   => l_return_status);

	   IF l_return_status <> fnd_api.g_ret_sts_success THEN
	     RAISE fnd_api.g_exc_error;
	   END IF;
    	   --Bug#5256138 End
         ELSIF p_creation_mode = 'OUTPUT' THEN
            l_total_output := p_batch_size;
         ELSIF p_creation_mode = 'INPUT' THEN
            l_total_input := p_batch_size;
         END IF;

         gmd_val_data_pub.get_val_data
                         (p_api_version              => 1.0
                         ,p_object_type              => l_object_type
                         ,p_recipe_no                => p_recipe_no
                         ,p_recipe_version           => p_recipe_version
                         ,p_recipe_id                => p_recipe_id
                         ,p_total_input              => l_total_input
                         ,p_total_output             => l_total_output
                         ,p_item_id                  => p_product_id
                         ,p_item_no                  => p_product_no
                         ,p_product_qty              => l_product_qty
                         ,p_uom                      => p_batch_size_uom
                         ,p_recipe_use               => l_recipe_use
                         ,p_organization_id          => l_batch_header.organization_id
                         ,p_start_date               => p_batch_header_rec.plan_start_date
                         ,p_end_date                 => l_cmplt_date
                         ,p_status_type              => l_status_type
                         ,p_least_cost_validity      => p_use_least_cost_validity_rule
			 ,p_revision		     => p_item_revision --nsinghi bug#5436643 Pass Revision Number
                         ,x_return_status            => l_return_status
                         ,x_msg_count                => l_msg_count
                         ,x_msg_data                 => l_msg_list
                         ,x_return_code              => l_return_code
                         ,x_recipe_validity_out      => l_validity_tbl);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_validity_tbl.COUNT = 0 THEN
            fnd_message.set_name ('GMD', 'GMD_NO_VLDTY_RLE_CRIT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         ELSE
            l_batch_header.recipe_validity_rule_id :=
                                   l_validity_tbl (1).recipe_validity_rule_id;
         END IF;
      ELSE
         IF (p_product_id IS NULL) THEN
            OPEN cur_validity_item
                                  (p_batch_header_rec.recipe_validity_rule_id);

            FETCH cur_validity_item
             INTO l_item_id;

            CLOSE cur_validity_item;
         ELSE
            l_item_id := p_product_id;
         END IF;

         IF NOT (gme_common_pvt.validate_validity_rule
                    (p_validity_rule_id      => l_batch_header.recipe_validity_rule_id
                    ,p_organization_id       => l_batch_header.organization_id
                    ,p_prim_product_id       => l_item_id
                    ,p_qty                   => p_batch_size
                    ,p_uom                   => p_batch_size_uom
                    ,p_object_type           => l_object_type
                    ,p_start_date            => p_batch_header_rec.plan_start_date
                    ,p_cmplt_date            => p_batch_header_rec.plan_cmplt_date
                    ,p_creation_mode         => p_creation_mode) ) THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('Finished validity rule stuff');
      END IF;

      IF p_use_workday_cal IS NOT NULL THEN
         l_use := p_use_workday_cal;

         IF l_use = fnd_api.g_true THEN
            IF (gme_common_pvt.g_calendar_code IS NOT NULL) THEN
               IF (p_batch_header_rec.plan_start_date IS NOT NULL) THEN
                  IF NOT gmp_calendar_api.is_working_daytime
                                         (1.0
                                         ,FALSE
                                         ,gme_common_pvt.g_calendar_code
                                         ,p_batch_header_rec.plan_start_date
                                         ,0
                                         ,l_return_status) THEN
                     gme_common_pvt.log_message
                        ('GME_NON_WORKING_TIME'
                        ,'PDATE'
                        ,fnd_date.date_to_displaydt
                                           (p_batch_header_rec.plan_start_date) );
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;

               IF (p_batch_header_rec.plan_cmplt_date IS NOT NULL) THEN
                  IF NOT gmp_calendar_api.is_working_daytime
                                         (1.0
                                         ,FALSE
                                         ,gme_common_pvt.g_calendar_code
                                         ,p_batch_header_rec.plan_cmplt_date
                                         ,1
                                         ,l_return_status) THEN
                     gme_common_pvt.log_message
                               ('GME_NON_WORKING_TIME'
                               ,'PDATE'
                               ,TO_CHAR (p_batch_header_rec.plan_cmplt_date
                                        ,'DD-MON-YYYY HH24:MI:SS') );
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;

               IF     p_batch_header_rec.plan_cmplt_date IS NULL
                  AND p_batch_header_rec.plan_start_date IS NULL THEN
                  IF NOT gmp_calendar_api.is_working_daytime
                                             (1.0
                                             ,FALSE
                                             ,gme_common_pvt.g_calendar_code
                                             ,SYSDATE
                                             ,0
                                             ,l_return_status) THEN
                     gme_common_pvt.log_message
                                          ('GME_NON_WORKING_TIME'
                                          ,'PDATE'
                                          ,TO_CHAR (SYSDATE
                                                   ,'DD-MON-YYYY HH24:MI:SS') );
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('calling main');
      END IF;

      gme_api_main.create_batch
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_batch_header_rec            => l_batch_header
                         ,x_batch_header_rec            => x_batch_header_rec
                         ,p_batch_size                  => p_batch_size
                         ,p_batch_size_uom              => p_batch_size_uom
                         ,p_creation_mode               => p_creation_mode
                         ,p_recipe_id                   => p_recipe_id
                         ,p_recipe_no                   => p_recipe_no
                         ,p_recipe_version              => p_recipe_version
                         ,p_product_no                  => p_product_no
                         ,p_product_id                  => p_product_id
                         ,p_sum_all_prod_lines          => p_sum_all_prod_lines
                         ,p_ignore_qty_below_cap        => p_ignore_qty_below_cap
                         ,p_use_workday_cal             => l_use
                         ,p_contiguity_override         => l_contiguity_override
                         ,p_use_least_cost_validity_rule => p_use_least_cost_validity_rule
                         ,x_exception_material_tbl      => x_exception_material_tbl);

      IF (    x_return_status <> fnd_api.g_ret_sts_success
          AND x_return_status <> gme_common_pvt.g_inv_short_err) THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_commit = fnd_api.g_true) THEN
         COMMIT;
      END IF;

      gme_common_pvt.log_message ('GME_API_BATCH_CREATED');
      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         x_batch_header_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END create_batch;

/*************************************************************************/
   PROCEDURE create_phantom (
      p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_material_detail_rec      IN              gme_material_details%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE --Bug#6738476
     ,p_org_code                 IN              VARCHAR2
     ,p_batch_no                 IN              VARCHAR2 DEFAULT NULL
     ,x_material_detail_rec      OUT NOCOPY      gme_material_details%ROWTYPE
     ,p_validity_rule_id         IN              NUMBER
     ,p_use_workday_cal          IN              VARCHAR2 := fnd_api.g_true
     ,p_contiguity_override      IN              VARCHAR2 := fnd_api.g_true
     ,p_use_least_cost_validity_rule     IN      VARCHAR2 := fnd_api.g_false
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab)
   IS
      l_api_name        CONSTANT VARCHAR2 (30)            := 'CREATE_PHANTOM';
      phantom_creation_failure   EXCEPTION;
      l_batch_header             gme_batch_header%ROWTYPE;
      l_material_detail          gme_material_details%ROWTYPE;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('CreatePhantom');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT create_phantom;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'create_phantom'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_material_detail_rec.organization_id IS NULL AND p_org_code IS NULL) THEN
         fnd_message.set_name ('INV', 'INV_ORG_REQUIRED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_contiguity_override NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_contiguity_override');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_use_workday_cal NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_use_workday_cal');
         RAISE fnd_api.g_exc_error;
      END IF;

      l_material_detail := p_material_detail_rec;
      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_material_detail_rec.organization_id
                              ,p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_material_detail.organization_id :=
                                             gme_common_pvt.g_organization_id;
      END IF;

      gme_api_main.create_phantom
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_material_detail_rec         => l_material_detail
                         ,p_batch_header_rec            =>  p_batch_header_rec
                         ,p_batch_no                    => p_batch_no
                         ,x_material_detail_rec         => x_material_detail_rec
                         ,p_validity_rule_id            => p_validity_rule_id
                         ,p_use_workday_cal             => p_use_workday_cal
                         ,p_contiguity_override         => p_contiguity_override
                         ,p_use_least_cost_validity_rule => p_use_least_cost_validity_rule
                         ,x_exception_material_tbl      => x_exception_material_tbl);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE phantom_creation_failure;
      END IF;

      IF (p_commit = fnd_api.g_true) THEN
         COMMIT;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN phantom_creation_failure THEN
         ROLLBACK TO SAVEPOINT create_phantom;
         x_material_detail_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT create_phantom;
         x_material_detail_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_phantom;
         x_material_detail_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END create_phantom;

/*************************************************************************/
   PROCEDURE scale_batch (
      p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
     ,p_init_msg_list            IN              VARCHAR2
     ,p_commit                   IN              VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_org_code                 IN              VARCHAR2
     ,p_ignore_exception         IN              VARCHAR2
     ,p_scale_factor             IN              NUMBER
     ,p_primaries                IN              VARCHAR2
     ,p_qty_type                 IN              NUMBER
     ,p_recalc_dates             IN              VARCHAR2
     ,p_use_workday_cal          IN              VARCHAR2
     ,p_contiguity_override      IN              VARCHAR2
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30)              := 'SCALE_BATCH';
      scale_batch_failed     EXCEPTION;
      l_batch_header_rec     gme_batch_header%ROWTYPE;
      l_return_status        VARCHAR2(1);

   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('ScaleBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT scale_batch;

      -- Initialize message list and count if needed
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'scale_batch'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;
      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      /* Check for p_qty_type */
      IF (p_qty_type NOT IN (0, 1) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_QUANTITY_TYPE');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Check for p_recalc_dates */
      IF (p_recalc_dates NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_recalc_dates');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Check for p_use_workday_cal */
      IF (p_use_workday_cal NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_use_workday_cal');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Check for p_contiguity_override */
      IF (p_contiguity_override NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_contiguity_override');
         RAISE fnd_api.g_exc_error;
      END IF;

      x_batch_header_rec := l_batch_header_rec;
      gme_api_main.scale_batch
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_batch_header_rec            => l_batch_header_rec
                         ,x_batch_header_rec            => x_batch_header_rec
                         ,p_scale_factor                => p_scale_factor
                         ,p_primaries                   => p_primaries
                         ,p_qty_type                    => p_qty_type
                         ,p_recalc_dates                => p_recalc_dates
                         ,p_use_workday_cal             => p_use_workday_cal
                         ,p_contiguity_override         => p_contiguity_override
                         ,x_exception_material_tbl      => x_exception_material_tbl);
      x_message_count := 0;

      --Bug#5459105 Begin
      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => NULL
                                   ,p_table              => NULL
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE scale_batch_failed;
      END IF;
      --Bug#5459105 End

      gme_common_pvt.log_message ('GME_SCALE_SUCCESS');
      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN scale_batch_failed THEN
         ROLLBACK TO SAVEPOINT scale_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT scale_batch;
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT scale_batch;
         x_batch_header_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END scale_batch;

/*************************************************************************/

   PROCEDURE theoretical_yield_batch (
      p_api_version        IN              NUMBER := 2.0
     ,p_validation_level   IN              NUMBER
     ,p_init_msg_list      IN              VARCHAR2
     ,p_commit             IN              VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_org_code           IN              VARCHAR2
     ,p_scale_factor       IN              NUMBER
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      l_api_name        CONSTANT VARCHAR2 (30)   := 'THEORETICAL_YIELD_BATCH';
      theoretical_yield_failed   EXCEPTION;
      l_batch_header_rec         gme_batch_header%ROWTYPE;
      l_return_status            VARCHAR2(1);
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('TheoreticalYieldBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT theoretical_yield_batch;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'theoretical_yield_batch'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;
      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
      gme_api_main.theoretical_yield_batch
                                    (p_validation_level      => p_validation_level
                                    ,p_init_msg_list         => fnd_api.g_false
                                    ,x_message_count         => x_message_count
                                    ,x_message_list          => x_message_list
                                    ,p_batch_header_rec      => l_batch_header_rec
                                    ,p_scale_factor          => p_scale_factor
                                    ,x_return_status         => x_return_status);

      --Bug#5459105 Begin
      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => NULL
                                   ,p_table              => NULL
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE theoretical_yield_failed;
      END IF;
      --Bug#5459105 End

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT theoretical_yield_batch;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN theoretical_yield_failed THEN
         ROLLBACK TO SAVEPOINT theoretical_yield_batch;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT theoretical_yield_batch;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END theoretical_yield_batch;

   /*##########################################################################
   # PROCEDURE
   #  update_actual_rsrc_usage
   # DESCRIPTION
   #
   # HISTORY :
   #  10-MAR-2005  Punit Kumar  Convergence changes
   #########################################################################*/
   PROCEDURE update_actual_rsrc_usage (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                IN              VARCHAR2 := fnd_api.g_false
     ,p_org_code              IN              VARCHAR2
     ,p_batch_no              IN              VARCHAR2 := NULL
     ,p_batchstep_no          IN              NUMBER := NULL
     ,p_activity              IN              VARCHAR2 := NULL
     ,p_resource              IN              VARCHAR2 := NULL
     ,p_instance_no           IN              NUMBER := NULL
     ,p_reason_name           IN              VARCHAR2 := NULL
     ,p_rsrc_txn_rec          IN              gme_resource_txns%ROWTYPE
     ,p_validate_flexfields   IN              VARCHAR2 := fnd_api.g_false
     ,x_rsrc_txn_rec          IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS
      l_api_name       CONSTANT  VARCHAR2(30) := 'UPDATE_ACTUAL_RSRC_USAGE';

      l_batch_header             gme_batch_header%ROWTYPE;
      l_poc_trans_id             NUMBER;
      l_line_id                  NUMBER;
      l_inv_trans_count          NUMBER;
      l_rsrc_trans_count         NUMBER;
      l_return_status            VARCHAR2 (2);
      /*start, Punit Kumar*/
      l_rsrc_txn_rec             gme_resource_txns%ROWTYPE;

      /*end */
      CURSOR cur_get_trans_id (v_line_id NUMBER)
      IS
         SELECT r.*
           FROM gme_resource_txns_gtmp t, gme_resource_txns r
          WHERE action_code = 'NONE' AND t.line_id = v_line_id
            AND t.poc_trans_id = r.poc_trans_id;

      update_rsrc_usage          EXCEPTION;
   BEGIN
      /* Set the savepoint */
      SAVEPOINT update_actual_rsrc_usage;
      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('UpdateResource');
      END IF;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;
      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      l_rsrc_txn_rec := p_rsrc_txn_rec ;
      IF (l_rsrc_txn_rec.organization_id IS NULL AND p_org_code IS NULL) THEN
         gme_common_pvt.log_message(p_product_code => 'INV'
                                    ,p_message_code => 'INV_ORG_REQUIRED');
         RAISE fnd_api.g_exc_error;
      END IF;
      /* Setup the common constants used accross the apis */
         gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_rsrc_txn_rec.organization_id
                              ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_rsrc_txn_rec.organization_id := gme_common_pvt.g_organization_id;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'update_actual_resource_usage'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_validate_flexfields = 'T' THEN
         gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
         gme_common_pvt.g_flex_validate_prof := 0;
      END IF;
      gme_common_pvt.set_timestamp;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
            ||'BEFORE CALLING gme_resource_engine_pvt.update_actual_resource_usagep ' );
      END IF;

      gme_resource_engine_pvt.update_actual_resource_usage
                                           (p_org_code           => p_org_code
                                           ,p_batch_no           => p_batch_no
                                           ,p_batchstep_no       => p_batchstep_no
                                           ,p_activity           => p_activity
                                           ,p_resource           => p_resource
                                           ,p_instance_no        => p_instance_no
                                           ,p_reason_name        => p_reason_name
                                           ,p_rsrc_txn_rec       => p_rsrc_txn_rec
                                           ,x_rsrc_txn_rec       => x_rsrc_txn_rec
                                           ,x_return_status      => x_return_status);

      gme_common_pvt.g_flex_validate_prof := 0;

      l_batch_header.batch_id := x_rsrc_txn_rec.doc_id;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => NULL
                                   ,p_table              => NULL
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE update_rsrc_usage;
      END IF;

      /* In order to get the poc_trans_id */
       /* Lets now load the transactions associated with the batch into the temporary table */
      IF p_commit = fnd_api.g_true THEN
         IF NOT (gme_batch_header_dbl.fetch_row (l_batch_header
                                                ,l_batch_header) ) THEN
            RAISE fnd_api.g_exc_error;
         END IF;
         gme_trans_engine_util.load_rsrc_trans
                                       (p_batch_row          => l_batch_header
                                       ,x_rsc_row_count      => l_rsrc_trans_count
                                       ,x_return_status      => x_return_status);

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         OPEN cur_get_trans_id (x_rsrc_txn_rec.line_id);
         FETCH cur_get_trans_id  INTO x_rsrc_txn_rec;
         CLOSE cur_get_trans_id;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Actual rsrc usage at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT update_actual_rsrc_usage;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN update_rsrc_usage THEN
         ROLLBACK TO SAVEPOINT update_actual_rsrc_usage;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_actual_rsrc_usage;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END update_actual_rsrc_usage;

   /*##########################################################################
   # PROCEDURE
   #   insert_incr_actual_rsrc_txn
   # DESCRIPTION
   # HISTORY
   #  10-MAR-2005  Punit Kumar
   #    Convergence changes
   #########################################################################*/
   PROCEDURE insert_incr_actual_rsrc_txn (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER  := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                IN              VARCHAR2 := fnd_api.g_false
     ,p_org_code              IN              VARCHAR2
     ,p_batch_no              IN              VARCHAR2 := NULL
     ,p_batchstep_no          IN              NUMBER := NULL
     ,p_activity              IN              VARCHAR2 := NULL
     ,p_resource              IN              VARCHAR2 := NULL
     ,p_instance_no           IN              NUMBER := NULL
     ,p_reason_name           IN              VARCHAR2 := NULL
     ,p_rsrc_txn_rec          IN              gme_resource_txns%ROWTYPE
     ,p_validate_flexfields   IN              VARCHAR2 := fnd_api.g_false
     ,x_rsrc_txn_rec          IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS
      l_api_name       CONSTANT  VARCHAR2(30) := 'INSERT_INCR_ACTUAL_RSRC_TXN';
      l_batch_header           gme_batch_header%ROWTYPE;
      l_rsrc_txn_rec           gme_resource_txns%ROWTYPE;
   BEGIN
      /* Set the savepoint */
      SAVEPOINT insert_incr_actual_rsrc_txn;

      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('InsertIncr');
      END IF;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;
      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      l_rsrc_txn_rec := p_rsrc_txn_rec ;
      IF (l_rsrc_txn_rec.organization_id IS NULL AND p_org_code IS NULL) THEN
         gme_common_pvt.log_message(p_product_code => 'INV'
                                    ,p_message_code => 'INV_ORG_REQUIRED');
         RAISE fnd_api.g_exc_error;
      END IF;
      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_rsrc_txn_rec.organization_id
                              ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_rsrc_txn_rec.organization_id := gme_common_pvt.g_organization_id;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'insert_incr_actual_rsrc_txn'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /*Validate if org_code or organization_id is passed, or give error.*/
      IF p_validate_flexfields = 'T' THEN
         gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
         gme_common_pvt.g_flex_validate_prof := 0;
      END IF;
      gme_common_pvt.set_timestamp;
      IF g_debug <= gme_debug.g_log_procedure THEN
          gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
            ||'BEFORE CALLING gme_resource_engine_pvt.insert_incr_actual_rsrc_txnp ' );
      END IF;
      gme_resource_engine_pvt.insert_incr_actual_rsrc_txn
                                           (p_org_code           => p_org_code
                                           ,p_batch_no           => p_batch_no
                                           ,p_batchstep_no       => p_batchstep_no
                                           ,p_activity           => p_activity
                                           ,p_resource           => p_resource
                                           ,p_instance_no        => p_instance_no
                                           ,p_reason_name        => p_reason_name
                                           ,p_rsrc_txn_rec       => p_rsrc_txn_rec
                                           ,x_rsrc_txn_rec       => x_rsrc_txn_rec
                                           ,x_return_status      => x_return_status);
      --Reset flex global
      gme_common_pvt.g_flex_validate_prof := 0;
      l_batch_header.batch_id := x_rsrc_txn_rec.doc_id;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => NULL
                                   ,p_table              => NULL
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Insert Incr Actual rsrc usage at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT insert_incr_actual_rsrc_txn;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT insert_incr_actual_rsrc_txn;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END insert_incr_actual_rsrc_txn;

   /*##########################################################################
   # PROCEDURE
   #   insert_timed_actual_rsrc_txn
   # DESCRIPTION
   #   This procedure calculates the resource usage based on
   #   difference of p_end_date and p_start_date converted in resource UOM.
   # HISTORY
   # 10-MAR-2005  Punit Kumar
   #   Convergence changes
   #########################################################################*/
   PROCEDURE insert_timed_actual_rsrc_txn (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER  := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                IN              VARCHAR2 := fnd_api.g_false
     ,p_org_code              IN              VARCHAR2
     ,p_batch_no              IN              VARCHAR2 := NULL
     ,p_batchstep_no          IN              NUMBER := NULL
     ,p_activity              IN              VARCHAR2 := NULL
     ,p_resource              IN              VARCHAR2 := NULL
     ,p_instance_no           IN              NUMBER := NULL
     ,p_reason_name           IN              VARCHAR2 := NULL
     ,p_rsrc_txn_rec          IN              gme_resource_txns%ROWTYPE
     ,p_validate_flexfields   IN              VARCHAR2 := fnd_api.g_false
     ,x_rsrc_txn_rec          IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS
      l_api_name       CONSTANT VARCHAR2(30) := 'INSERT_TIMED_ACTUAL_RSRC_TXN';
      l_batch_header            gme_batch_header%ROWTYPE;
      l_rsrc_txn_rec            gme_resource_txns%ROWTYPE;

   BEGIN
      /* Set the savepoint */
      SAVEPOINT insert_timed_actual_rsrc_txn;
       /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;
      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('InsertTimed');
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;
      l_rsrc_txn_rec := p_rsrc_txn_rec ;
      IF (l_rsrc_txn_rec.organization_id IS NULL AND p_org_code IS NULL) THEN
         gme_common_pvt.log_message(p_product_code => 'INV'
                                    ,p_message_code => 'INV_ORG_REQUIRED');
         RAISE fnd_api.g_exc_error;
      END IF;

       gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_rsrc_txn_rec.organization_id
                              ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_rsrc_txn_rec.organization_id := gme_common_pvt.g_organization_id;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'insert_timed_actual_rsrc_txn'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.set_timestamp;

      IF p_validate_flexfields = 'T' THEN
         gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
         gme_common_pvt.g_flex_validate_prof := 0;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
            ||'BEFORE CALLING gme_resource_engine_pvt.insert_timed_actual_rsrc_txnp ');
      END IF;

      gme_resource_engine_pvt.insert_timed_actual_rsrc_txn
                                           (p_org_code           => p_org_code
                                           ,p_batch_no           => p_batch_no
                                           ,p_batchstep_no       => p_batchstep_no
                                           ,p_activity           => p_activity
                                           ,p_resource           => p_resource
                                           ,p_instance_no        => p_instance_no
                                           ,p_reason_name        => p_reason_name
                                           ,p_rsrc_txn_rec       => p_rsrc_txn_rec
                                           ,x_rsrc_txn_rec       => x_rsrc_txn_rec
                                           ,x_return_status      => x_return_status);
      --Reset flex global
      gme_common_pvt.g_flex_validate_prof := 0;
      l_batch_header.batch_id := x_rsrc_txn_rec.doc_id;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => NULL
                                   ,p_table              => NULL
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Insert timed Actual rsrc usage at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT insert_timed_actual_rsrc_txn;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT insert_timed_actual_rsrc_txn;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END insert_timed_actual_rsrc_txn;

    /*##########################################################################
   #  PROCEDURE
   #    start_cmplt_actual_rsrc_txn
   #  DESCRIPTION
   #    This Api is used to state that a resource has started, and
   #    creates a transaction row in the resource transactions table.
   #    At a later time this transaction is updated with the usage
   #    by calling gme_api_pub.end_cmplt_actual_rsrc_txn (It passes
   #    the end date and the usage is calculated as diferrence between
   #    end_date and start_date)
   # HISTORY
   #   10-MAR-2005  Punit Kumar
   #     Convergence changes
   #    Pawan kumar corrected check for organization_id and various parameters
   #########################################################################*/
   PROCEDURE start_cmplt_actual_rsrc_txn (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                IN              VARCHAR2 := fnd_api.g_false
     ,p_org_code              IN              VARCHAR2
     ,p_batch_no              IN              VARCHAR2 := NULL
     ,p_batchstep_no          IN              NUMBER := NULL
     ,p_activity              IN              VARCHAR2 := NULL
     ,p_resource              IN              VARCHAR2 := NULL
     ,p_instance_no           IN              NUMBER
     ,p_reason_name           IN              VARCHAR2 := NULL
     ,p_rsrc_txn_rec          IN              gme_resource_txns%ROWTYPE
     ,p_validate_flexfields   IN              VARCHAR2 := fnd_api.g_false
     ,x_rsrc_txn_rec          IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS
      l_api_name       CONSTANT  VARCHAR2(30) := 'START_CMPLT_ACTUAL_RSRC_TXN';
      l_batch_header                gme_batch_header%ROWTYPE;
       l_rsrc_txn_rec                gme_resource_txns%ROWTYPE;

   BEGIN
      /* Set the savepoint */
      SAVEPOINT start_cmplt_actual_rsrc_txn;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;
      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('StartCmplt');
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;
      l_rsrc_txn_rec := p_rsrc_txn_rec ;
      IF (l_rsrc_txn_rec.organization_id IS NULL AND p_org_code IS NULL) THEN
         gme_common_pvt.log_message(p_product_code => 'INV'
                                    ,p_message_code => 'INV_ORG_REQUIRED');
         RAISE fnd_api.g_exc_error;
      END IF;
      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_rsrc_txn_rec.organization_id
                              ,p_org_code      => p_org_code);
      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_rsrc_txn_rec.organization_id := gme_common_pvt.g_organization_id;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0,p_api_version,
                                          'start_cmplt_actual_rsrc_txn',g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;
      gme_common_pvt.set_timestamp;
      IF p_validate_flexfields = 'T' THEN
         gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
         gme_common_pvt.g_flex_validate_prof := 0;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
            ||'BEFORE CALLING gme_resource_engine_pvt.start_cmplt_actual_rsrc_txnp ' );
      END IF;

      gme_resource_engine_pvt.start_cmplt_actual_rsrc_txn
                                           (p_org_code           => p_org_code
                                           ,p_batch_no           => p_batch_no
                                           ,p_batchstep_no       => p_batchstep_no
                                           ,p_activity           => p_activity
                                           ,p_resource           => p_resource
                                           ,p_instance_no        => p_instance_no
                                           ,p_reason_name        => p_reason_name
                                           ,p_rsrc_txn_rec       => l_rsrc_txn_rec
                                           ,x_rsrc_txn_rec       => x_rsrc_txn_rec
                                           ,x_return_status      => x_return_status);
      -----Reset flex global
      gme_common_pvt.g_flex_validate_prof := 0;
      l_batch_header.batch_id := x_rsrc_txn_rec.doc_id;

      /*end */
      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => NULL
                                   ,p_table              => NULL
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'start Actual rsrc txn at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);
   EXCEPTION
      WHEN fnd_api.g_exc_error  THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT start_cmplt_actual_rsrc_txn;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT start_cmplt_actual_rsrc_txn;
        gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END start_cmplt_actual_rsrc_txn;

   /*##########################################################################
    #  PROCEDURE
    #    end_cmplt_actual_rsrc_txn
    #  DESCRIPTION
    #    This particular procedure is used to end a started completed
    #    rsrc txn row and calculates the   usage from rsrc txn date,
    #    for non asqc batch and batch step is in WIP or Completed state
    #  HISTORY :
    #    10-MAR-2005  Punit Kumar
    #      Convergence changes
    #########################################################################*/
   PROCEDURE end_cmplt_actual_rsrc_txn (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                IN              VARCHAR2 := fnd_api.g_false
     ,p_instance_no           IN              NUMBER := NULL
     ,p_reason_name           IN              VARCHAR2 := NULL
     ,p_rsrc_txn_rec          IN              gme_resource_txns%ROWTYPE
     ,p_validate_flexfields   IN              VARCHAR2 := fnd_api.g_false
     ,x_rsrc_txn_rec          IN OUT NOCOPY   gme_resource_txns%ROWTYPE
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS
      l_api_name       CONSTANT  VARCHAR2(30) := 'END_CMPLT_ACTUAL_RSRC_TXN';
      l_batch_header           gme_batch_header%ROWTYPE;
      l_rsrc_txn_rec           gme_resource_txns%ROWTYPE;
   BEGIN
      /* Set the savepoint */
      SAVEPOINT end_cmplt_actual_rsrc_txn;

      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('EndCmplt');
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;
      l_rsrc_txn_rec := p_rsrc_txn_rec;
      IF (l_rsrc_txn_rec.organization_id IS NULL ) THEN
         gme_common_pvt.log_message(p_product_code => 'INV'
                                    ,p_message_code => 'INV_ORG_REQUIRED');
         RAISE fnd_api.g_exc_error;
      END IF;
      /* Setup the common constants used accross the apis */
      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_rsrc_txn_rec.organization_id
                              ,p_org_code      => null);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_rsrc_txn_rec.organization_id := gme_common_pvt.g_organization_id;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'end_cmplt_actual_rsrc_txn'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;
      gme_common_pvt.set_timestamp;
      IF p_validate_flexfields = 'T' THEN
         gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
         gme_common_pvt.g_flex_validate_prof := 0;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             ||'CALLING gme_resource_engine_pvt.end_cmplt_actual_rsrc_txnp ');
      END IF;

      gme_resource_engine_pvt.end_cmplt_actual_rsrc_txn
                                           (p_instance_no        => p_instance_no
                                           ,p_reason_name        => p_reason_name
                                           ,p_rsrc_txn_rec       => p_rsrc_txn_rec
                                           ,x_rsrc_txn_rec       => x_rsrc_txn_rec
                                           ,x_return_status      => x_return_status);

      gme_common_pvt.g_flex_validate_prof := 0;
      l_batch_header.batch_id := x_rsrc_txn_rec.doc_id;

      /* end */
      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => NULL
                                   ,p_table              => NULL
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Insert Incr Actual rsrc usage at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT end_cmplt_actual_rsrc_txn;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT end_cmplt_actual_rsrc_txn;
        gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END end_cmplt_actual_rsrc_txn;

/*************************************************************************/
   PROCEDURE reschedule_batch (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER
     ,p_init_msg_list         IN              VARCHAR2
     ,p_commit                IN              VARCHAR2
     ,p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_use_workday_cal       IN              VARCHAR2
     ,p_contiguity_override   IN              VARCHAR2
     ,p_org_code              IN              VARCHAR2
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_batch_header_rec      OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name       CONSTANT VARCHAR2 (30)           := 'RESCHEDULE_BATCH';
      reschedule_batch_failed   EXCEPTION;
      batch_save_failed         EXCEPTION;
      l_return_status           VARCHAR2 (1);
      l_use                     VARCHAR2 (1);
      l_batch_header_rec        gme_batch_header%ROWTYPE;
   BEGIN
      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('RescheduleBatch');
      END IF;

      IF (g_debug IN (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT reschedule_batch;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
       END IF;
      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'reschedule_batch'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Bug 8218955 - Note: l_batch_header_rec is the record stored in the database not what was passed in.
      -- Reworked debug logging messages so we can see all the values.
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Batch_status is: '|| l_batch_header_rec.batch_status);

         gme_debug.put_line ('Value of Plan_start_date in DB    : ' ||
            TO_CHAR(l_batch_header_rec.plan_start_date ,'DD-MON-YYYY HH24:MI:SS'));

         IF p_batch_header_rec.plan_start_date IS NOT NULL THEN
            gme_debug.put_line ('Value of Plan_start_date passed in: ' ||
               TO_CHAR(p_batch_header_rec.plan_start_date ,'DD-MON-YYYY HH24:MI:SS'));
         ELSE
            gme_debug.put_line ('Value of Plan_start_date passed in is NULL');
         END IF;

         gme_debug.put_line ('Value of Plan_cmplt_date in DB       : ' ||
            TO_CHAR (l_batch_header_rec.plan_cmplt_date,'DD-MON-YYYY HH24:MI:SS'));

         IF p_batch_header_rec.plan_cmplt_date IS NOT NULL THEN
            gme_debug.put_line ('Value of Plan_cmplt_date in passed in: ' ||
               TO_CHAR (p_batch_header_rec.plan_cmplt_date,'DD-MON-YYYY HH24:MI:SS'));
         ELSE
            gme_debug.put_line ('Value of Plan_cmplt_date passed in is NULL');
         END IF;
      END IF;

      -- Bug 8218955 - Change l_batch_header_rec to p_batch_header_rec so we can validate what was passed in.
      IF     p_batch_header_rec.plan_start_date IS NULL
         AND p_batch_header_rec.plan_cmplt_date IS NULL THEN
         gme_common_pvt.log_message ('GME_NO_NULL_DATES');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Check plan_start_date > plan_cmplt_date if batch_status = pending */
      IF (l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending) THEN
         -- Bug 8218955 - Change l_batch_header_rec to p_batch_header_rec so we can validate what was passed in.
         IF     p_batch_header_rec.plan_start_date IS NOT NULL
            AND p_batch_header_rec.plan_cmplt_date IS NOT NULL
            AND p_batch_header_rec.plan_start_date >
                                            p_batch_header_rec.plan_cmplt_date THEN
            --Bug#5439736 replaced the message
            gme_common_pvt.log_message ('GME_CMPLT_START_DT');
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF (l_batch_header_rec.batch_status = gme_common_pvt.g_batch_wip) THEN
         -- Bug 8218955 - Change l_batch_header_rec to p_batch_header_rec so we can validate what was passed in.
         IF p_batch_header_rec.plan_cmplt_date IS NULL THEN
            gme_common_pvt.log_message ('GME_NO_CMPLTDATE_FOR_WIP');
            RAISE fnd_api.g_exc_error;
         ELSE
            -- Bug 8218955 - Change l_batch_header_rec to p_batch_header_rec so we can validate what was passed in.
            IF NVL (p_batch_header_rec.plan_start_date
                   ,l_batch_header_rec.plan_start_date) <>
                                            l_batch_header_rec.plan_start_date THEN
               gme_common_pvt.log_message ('GME_NO_PLAN_DT_UPD');
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Bug 8218955 - Change l_batch_header_rec to p_batch_header_rec so we can validate what was passed in.
            IF p_batch_header_rec.plan_cmplt_date <
                                            l_batch_header_rec.plan_start_date THEN
               gme_common_pvt.log_message ('GME_CMPLT_START_DT');
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE                          /* batch status other than pending, WIP */
         -- Batch cannot be rescheduled. Batch must have a status of pending or WIP to be rescheduled.
         gme_common_pvt.log_message ('GME_API_INV_BATCH_RESCHED');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_use_workday_cal IS NOT NULL THEN
         IF p_use_workday_cal IN (fnd_api.g_true, fnd_api.g_false) THEN
            l_use := p_use_workday_cal;
         ELSE
            gme_common_pvt.log_message ('GME_INVALID_VALUE_SPECIFIED'
                                       ,'FIELD_NAME'
                                       ,'p_use_workday_cal');
            RAISE fnd_api.g_exc_error;
         END IF;
         IF p_contiguity_override IS NOT NULL THEN
            IF p_contiguity_override NOT IN
                                           (fnd_api.g_true, fnd_api.g_false) THEN
               gme_common_pvt.log_message ('GME_INVALID_VALUE_SPECIFIED'
                                          ,'FIELD_NAME'
                                          ,'p_contiguity_override');
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         l_use := fnd_api.g_false;
      END IF;                              /* p_use_workday_cal IS NOT NULL */

      IF l_use = fnd_api.g_true THEN
         IF (gme_common_pvt.g_calendar_code IS NOT NULL) THEN
            -- Bug 8218955 - Change l_batch_header_rec to p_batch_header_rec so we can validate what was passed in.
            -- Check if plan_start_date falls on non working day for pending batch.
            IF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending AND
               p_batch_header_rec.plan_start_date IS NOT NULL THEN
               IF NOT gmp_calendar_api.is_working_daytime
                                         (1.0
                                         ,FALSE
                                         ,gme_common_pvt.g_calendar_code
                                         ,p_batch_header_rec.plan_start_date
                                         ,0
                                         ,l_return_status) THEN
                  gme_common_pvt.log_message
                               ('GME_NON_WORKING_TIME'
                               ,'PDATE'
                               ,TO_CHAR (p_batch_header_rec.plan_start_date
                                        ,'DD-MON-YYYY HH24:MI:SS') );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

            /* l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending */

            -- Bug 8218955 - Change l_batch_header_rec to p_batch_header_rec so we can validate what was passed in.
            -- Check if plan_cmplt_date falls on non working day for pending and WIP batch.
            IF     l_batch_header_rec.batch_status IN
                      (gme_common_pvt.g_batch_pending
                      ,gme_common_pvt.g_batch_wip)
               AND p_batch_header_rec.plan_cmplt_date IS NOT NULL THEN
               IF NOT gmp_calendar_api.is_working_daytime
                                         (1.0
                                         ,FALSE
                                         ,gme_common_pvt.g_calendar_code
                                         ,p_batch_header_rec.plan_cmplt_date
                                         ,1
                                         ,l_return_status) THEN
                  gme_common_pvt.log_message
                               ('GME_NON_WORKING_TIME'
                               ,'PDATE'
                               ,TO_CHAR (p_batch_header_rec.plan_cmplt_date
                                        ,'DD-MON-YYYY HH24:MI:SS') );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

            -- Bug 8218955 - Change l_batch_header_rec to p_batch_header_rec so we can validate what was passed in.
            /* l_batch_header_rec.batch_status IN (gme_common_pvt.g_batch_pending, gme_common_pvt.g_batch_wip) */
            IF p_batch_header_rec.plan_cmplt_date IS NULL AND
               p_batch_header_rec.plan_start_date IS NULL THEN
               IF NOT gmp_calendar_api.is_working_daytime
                                             (1.0
                                             ,FALSE
                                             ,gme_common_pvt.g_calendar_code
                                             ,SYSDATE
                                             ,0
                                             ,l_return_status) THEN
                  gme_common_pvt.log_message ('GME_NON_WORKING_TIME' ,'PDATE'
                  ,TO_CHAR (SYSDATE,'DD-MON-YYYY HH24:MI:SS') );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;           /* p_batch_header_rec.plan_cmplt_date IS NULL   */
         END IF;              /* (gme_common_pvt.g_calendar_code IS NOT NULL) */
      END IF;                 /* l_use = FND_API.G_TRUE                       */

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ':'
                             || 'Calling Main Reschedule Batch');
      END IF;

      -- 8218955 - Use the dates passed in by the user.
      l_batch_header_rec.plan_start_date := p_batch_header_rec.plan_start_date;
      l_batch_header_rec.plan_cmplt_date := p_batch_header_rec.plan_cmplt_date;

      gme_api_main.reschedule_batch
                              (p_validation_level         => p_validation_level
                              ,p_init_msg_list            => fnd_api.g_false
                              ,p_batch_header_rec         => l_batch_header_rec
                              ,p_use_workday_cal          => l_use
                              ,p_contiguity_override      => p_contiguity_override
                              ,x_message_count            => x_message_count
                              ,x_message_list             => x_message_list
                              ,x_return_status            => x_return_status
                              ,x_batch_header_rec         => x_batch_header_rec);

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line
                      (   'Came back from Main Reschedule Batch with status '
                       || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE reschedule_batch_failed;
      ELSE
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => NULL
                                   ,p_table              => NULL
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ':' ||
         'Exiting with ' || x_return_status || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
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
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END reschedule_batch;

/*************************************************************************/
   PROCEDURE reschedule_step (
      p_api_version             IN              NUMBER := 2.0
     ,p_validation_level        IN              NUMBER
     ,p_init_msg_list           IN              VARCHAR2
     ,p_commit                  IN              VARCHAR2
     ,p_batch_step_rec          IN              gme_batch_steps%ROWTYPE
     ,p_use_workday_cal         IN              VARCHAR2
     ,p_contiguity_override     IN              VARCHAR2
     ,p_org_code                IN              VARCHAR2
     ,p_batch_no                IN              VARCHAR2
     ,p_batch_type              IN              NUMBER
     ,p_reschedule_preceding    IN              VARCHAR2
     ,p_reschedule_succeeding   IN              VARCHAR2
     ,x_message_count           OUT NOCOPY      NUMBER
     ,x_message_list            OUT NOCOPY      VARCHAR2
     ,x_return_status           OUT NOCOPY      VARCHAR2
     ,x_batch_step_rec          OUT NOCOPY      gme_batch_steps%ROWTYPE)
   IS
      l_api_name       CONSTANT VARCHAR2 (30)            := 'RESCHEDULE_STEP';
      l_diff                    NUMBER                     := 0;
      l_diff_cmplt              NUMBER                     := 0;
      reschedule_step_failed    EXCEPTION;
      l_batch_header_rec        gme_batch_header%ROWTYPE;
      l_batch_step_rec          gme_batch_steps%ROWTYPE;
      l_use                     VARCHAR2 (1);
      l_return_status           VARCHAR2 (1);
      l_reschedule_preceding    VARCHAR2 (1);
      l_reschedule_succeeding   VARCHAR2 (1);
   BEGIN
      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('RescheduleStep');
      END IF;

      IF (g_debug IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT reschedule_step;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      /* Validate Input parameters */
      gme_common_pvt.Validate_batch_step (
              p_batch_step_rec     =>      p_batch_step_rec
             ,p_org_code           =>      p_org_code
             ,p_batch_no           =>      p_batch_no
             ,x_batch_step_rec     =>      l_batch_step_rec
             ,x_batch_header_rec   =>      l_batch_header_rec
             ,x_message_count      => x_message_count
             ,x_message_list       => x_message_list
             ,x_return_status      => x_return_status) ;

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch step validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'reschedule_batch_step'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Navin: Check whether both l_batch_step_rec.plan_start_date, l_batch_step_rec.plan_cmplt_date are null. If so, RAISE error; */
      IF     p_batch_step_rec.plan_start_date IS NULL
         AND p_batch_step_rec.plan_cmplt_date IS NULL THEN
         -- Both planned start and planned completion dates cannot be null.
         gme_common_pvt.log_message ('GME_NO_NULL_DATES');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_batch_type = gme_common_pvt.g_doc_type_fpo THEN
         -- You cannot reschedule steps for firm planned orders.
         gme_common_pvt.log_message ('GME_FPO_STEP_RESCH_ERR');
         -- Navin: PENDING: New Message
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_reschedule_preceding NOT IN (fnd_api.g_true, fnd_api.g_false) THEN
         gme_common_pvt.log_message ('GME_INVALID_VALUE_SPECIFIED'
                                    ,'FIELD_NAME'
                                    ,'p_reschedule_preceding');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_reschedule_succeeding NOT IN (fnd_api.g_true, fnd_api.g_false) THEN
         gme_common_pvt.log_message ('GME_INVALID_VALUE_SPECIFIED'
                                    ,'FIELD_NAME'
                                    ,'p_reschedule_succeeding');
         RAISE fnd_api.g_exc_error;
      END IF;

      l_batch_step_rec.plan_start_date := p_batch_step_rec.plan_start_date;
      l_batch_step_rec.plan_cmplt_date := p_batch_step_rec.plan_cmplt_date;
      /* Navin: Check plan_start_date > plan_cmplt_date if step_status = pending */
      IF (l_batch_step_rec.step_status = gme_common_pvt.g_batch_pending) THEN
         IF     l_batch_step_rec.plan_start_date IS NOT NULL
            AND l_batch_step_rec.plan_cmplt_date IS NOT NULL
            AND l_batch_step_rec.plan_start_date >
                                              l_batch_step_rec.plan_cmplt_date THEN
            -- The planned start cannot be greater than the planned completion date.
            gme_common_pvt.log_message ('GME_CMPLT_START_DT');
            -- Navin: PENDING: New Message
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF (l_batch_step_rec.step_status = gme_common_pvt.g_batch_wip) THEN
         IF l_batch_step_rec.plan_cmplt_date IS NULL THEN
            -- Planned completion dates cannot be null for a batch with status of WIP.
            gme_common_pvt.log_message ('GME_NO_CMPLTDATE_FOR_WIP');
            -- Navin: PENDING: New Message
            RAISE fnd_api.g_exc_error;
         ELSE
            IF NVL (l_batch_step_rec.plan_start_date
                   ,l_batch_step_rec.plan_start_date) <>
                                              l_batch_step_rec.plan_start_date THEN
               -- Cannot update planned start date.
               gme_common_pvt.log_message ('GME_NO_PLAN_DT_UPD');
               -- Navin: PENDING: New Message
               RAISE fnd_api.g_exc_error;
            END IF;

            IF l_batch_step_rec.plan_cmplt_date <
                                              l_batch_step_rec.plan_start_date THEN
               -- Planned completion date cannot be earlier than the planned start date.
               gme_common_pvt.log_message ('GME_CMPLT_START_DT');
               -- Navin: PENDING: New Message
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE                            /*step status other than pending, WIP */
         --Bug#5439736
         gme_common_pvt.log_message ('GME_API_INV_STEP_STAT_RESCH');
         RAISE fnd_api.g_exc_error;
      END IF;

      -- When enforce_step_dependency option is enforced then override Reschedule_preceding, Reschedule_succeeding fields.
      IF l_batch_header_rec.enforce_step_dependency = 1 THEN
         l_reschedule_preceding := fnd_api.g_true;
         l_reschedule_succeeding := fnd_api.g_true;
      ELSE
         l_reschedule_preceding := p_reschedule_preceding;
         l_reschedule_succeeding := p_reschedule_succeeding;
      END IF;

      IF p_use_workday_cal IS NOT NULL THEN
         IF p_use_workday_cal IN (fnd_api.g_true, fnd_api.g_false) THEN
            l_use := p_use_workday_cal;
         ELSE
            gme_common_pvt.log_message ('GME_INVALID_VALUE_SPECIFIED'
                                       ,'FIELD_NAME'
                                       ,'p_use_workday_cal');
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_contiguity_override IS NOT NULL THEN
            IF p_contiguity_override NOT IN
                                           (fnd_api.g_true, fnd_api.g_false) THEN
               gme_common_pvt.log_message ('GME_INVALID_VALUE_SPECIFIED'
                                          ,'FIELD_NAME'
                                          ,'p_contiguity_override');
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;                                   /* p_contiguity_override */
      ELSE
         l_use := fnd_api.g_false;
      END IF;                              /* p_use_workday_cal IS NOT NULL */

      IF l_use = fnd_api.g_true THEN
         IF (gme_common_pvt.g_calendar_code IS NOT NULL) THEN
            -- Check if plan_start_date falls on non working day for pending batch step.
            IF     l_batch_step_rec.step_status =
                                                gme_common_pvt.g_step_pending
               AND l_batch_step_rec.plan_start_date IS NOT NULL THEN
               IF NOT gmp_calendar_api.is_working_daytime
                                           (1.0
                                           ,FALSE
                                           ,gme_common_pvt.g_calendar_code
                                           ,l_batch_step_rec.plan_start_date
                                           ,0
                                           ,l_return_status) THEN
                  gme_common_pvt.log_message
                                 ('GME_NON_WORKING_TIME'
                                 ,'PDATE'
                                 ,TO_CHAR (l_batch_step_rec.plan_start_date
                                          ,'DD-MON-YYYY HH24:MI:SS') );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

            -- Check if plan_cmplt_date falls on non working day for pending and WIP batch step.
            IF     l_batch_step_rec.step_status IN
                      (gme_common_pvt.g_step_pending
                      ,gme_common_pvt.g_step_wip)
               AND l_batch_step_rec.plan_cmplt_date IS NOT NULL THEN
               gme_debug.put_line ('in cmplt');

               IF NOT gmp_calendar_api.is_working_daytime
                                           (1.0
                                           ,FALSE
                                           ,gme_common_pvt.g_calendar_code
                                           ,l_batch_step_rec.plan_cmplt_date
                                           ,1
                                           ,l_return_status) THEN
                  gme_common_pvt.log_message
                                 ('GME_NON_WORKING_TIME'
                                 ,'PDATE'
                                 ,TO_CHAR (l_batch_step_rec.plan_cmplt_date
                                          ,'DD-MON-YYYY HH24:MI:SS') );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

            IF     l_batch_step_rec.plan_cmplt_date IS NULL
               AND l_batch_step_rec.plan_start_date IS NULL THEN
               IF NOT gmp_calendar_api.is_working_daytime
                                             (1.0
                                             ,FALSE
                                             ,gme_common_pvt.g_calendar_code
                                             ,SYSDATE
                                             ,0
                                             ,l_return_status) THEN
                  gme_common_pvt.log_message
                                          ('GME_NON_WORKING_TIME'
                                          ,'PDATE'
                                          ,TO_CHAR (SYSDATE
                                                   ,'DD-MON-YYYY HH24:MI:SS') );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;            /* l_batch_step_rec.plan_cmplt_date IS NULL  */
         END IF;            /* (gme_common_pvt.g_calendar_code IS NOT NULL) */
      END IF;                                     /* l_use = FND_API.G_TRUE */

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Calling Main Reschedule Step');
      END IF;

      gme_api_main.reschedule_step
                          (p_validation_level           => p_validation_level
                          ,p_init_msg_list              => fnd_api.g_false
                          ,p_batch_header_rec           => l_batch_header_rec
                          ,p_batch_step_rec             => l_batch_step_rec
                          ,p_reschedule_preceding       => p_reschedule_preceding
                          ,p_reschedule_succeeding      => p_reschedule_succeeding
                          ,p_use_workday_cal            => l_use
                          ,p_contiguity_override        => p_contiguity_override
                          ,x_message_count              => x_message_count
                          ,x_message_list               => x_message_list
                          ,x_return_status              => x_return_status
                          ,x_batch_step_rec             => x_batch_step_rec);

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line
                       (   'Came back from Main Reschedule Step with status '
                        || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE reschedule_step_failed;
      ELSE
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => NULL
                                   ,p_table              => NULL
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

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
      WHEN reschedule_step_failed THEN
         ROLLBACK TO SAVEPOINT reschedule_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT reschedule_step;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT reschedule_step;
         x_batch_step_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     		   		        ,x_message_count        => x_message_count
     				           ,x_message_list         => x_message_list
     				            ,x_return_status   	=> x_return_status );
   END reschedule_step;

/*************************************************************************/
   PROCEDURE create_batch_reservations (
      p_api_version      IN              NUMBER := 2.0
     ,p_validation_level IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list    IN              VARCHAR2 := fnd_api.g_false
     ,p_commit           IN              VARCHAR2 := fnd_api.g_false
     ,p_batch_rec        IN              gme_batch_header%ROWTYPE
     ,p_org_code         IN              VARCHAR2
     ,x_message_count    OUT NOCOPY      NUMBER
     ,x_message_list     OUT NOCOPY      VARCHAR2
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      l_api_name       CONSTANT VARCHAR2 (30)  := 'CREATE_BATCH_RESERVATIONS';
      l_batch_header_rec        gme_batch_header%ROWTYPE;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the savepoint */
      SAVEPOINT create_batch_reservations;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('CreateBatchReservations');
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'insert_batchstep_resource'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      gme_common_pvt.set_timestamp;

     /* IF p_batch_rec.batch_no IS NULL AND p_batch_rec.batch_id IS NULL THEN
         gme_common_pvt.log_message ('GME_MISSING_BATCH_IDENTIFIER');
         RAISE fnd_api.g_exc_error;
      END IF; */
      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => gme_common_pvt.g_doc_type_batch
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      /* Verify Batch to be in pending or WIP status */
      IF l_batch_header_rec.batch_status NOT IN
                 (gme_common_pvt.g_batch_pending, gme_common_pvt.g_batch_wip) THEN
         gme_common_pvt.log_message ('GME_INVALID_BATCH_STATUS'
                                    ,'PROCESS'
                                    ,'CREATE_LINE_RESERVATIONS');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_api_main.create_batch_reservations
                                    (p_init_msg_list         => p_init_msg_list
                                    ,p_batch_header_rec      => l_batch_header_rec
                                    ,x_message_count         => x_message_count
                                    ,x_message_list          => x_message_list
                                    ,x_return_status         => x_return_status);

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'create batch reservations returns '
                             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_commit = fnd_api.g_true THEN
         COMMIT;
      END IF;

      gme_debug.put_line (   'End of Create_Batch_Reservations at '
                          || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT create_batch_reservations;
         gme_common_pvt.count_and_get(x_count        => x_message_count
                                     ,p_encoded      => fnd_api.g_false
                                     ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_batch_reservations;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END create_batch_reservations;
/*************************************************************************/
   PROCEDURE create_line_reservations (
      p_api_version          IN              NUMBER := 2.0
     ,p_validation_level     IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list        IN              VARCHAR2 := fnd_api.g_false
     ,p_commit               IN              VARCHAR2 := fnd_api.g_false
     ,p_material_detail_id   IN              NUMBER
     ,p_org_code             IN              VARCHAR2
     ,p_batch_no             IN              VARCHAR2
     ,p_line_no              IN              NUMBER
     ,x_message_count        OUT NOCOPY      NUMBER
     ,x_message_list         OUT NOCOPY      VARCHAR2
     ,x_return_status        OUT NOCOPY      VARCHAR2)
   IS
      l_api_name              CONSTANT VARCHAR2 (30)
                                                := 'CREATE_LINE_RESERVATIONS';
      l_material_details_rec           gme_material_details%ROWTYPE;
      l_material_details_rec_out       gme_material_details%ROWTYPE;
      l_batch_header_rec               gme_batch_header%ROWTYPE;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the savepoint */
      SAVEPOINT create_line_reservations;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('CreateLineReservations');
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'insert_batchstep_resource'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      gme_common_pvt.set_timestamp;
      l_material_details_rec.material_detail_id := p_material_detail_id;
      l_material_details_rec.line_no := p_line_no;
      /* Ensure line_type is populated.  Reservations only permitted for ingredient lines. */
      /* Line type is needed for retrieval based on key values                             */
      l_material_details_rec.line_type := -1;

       gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> l_material_details_rec
                          ,p_org_code                 	=> p_org_code
                          ,p_batch_no                 	=> p_batch_no
                          ,p_batch_type               	=> 0
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_material_details_rec_out
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
      l_material_details_rec := l_material_details_rec_out;

      /* Reservation cannot be against a phantom */
      IF l_material_details_rec.phantom_type IN (1, 2) THEN
         gme_common_pvt.log_message ('GME_INVALID_RSV_FOR_PHANTOM');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Reservation cannot be against a phantom */
      IF l_material_details_rec.line_type <> -1 THEN
         gme_common_pvt.log_message ('GME_INVALID_LINE_FOR_RSV');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Verify that update_inventory is permitted for this batch */
      IF l_batch_header_rec.update_inventory_ind <> 'Y' THEN
         gme_common_pvt.log_message ('GME_INVENTORY_UPDATE_BLOCKED');
         RAISE fnd_api.g_exc_error;
      END IF;

     --  gme_debug.put_line(l_batch_header_rec.batch_status);

      /* Verify Batch to be in pending or WIP status */
      IF l_batch_header_rec.batch_status NOT IN
                 (gme_common_pvt.g_batch_pending, gme_common_pvt.g_batch_wip) THEN
         gme_common_pvt.log_message ('GME_INVALID_BATCH_STATUS'
                                    ,'PROCESS'
                                    ,'CREATE_RESERVATION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF l_batch_header_rec.batch_type = gme_common_pvt.g_doc_type_fpo THEN
         gme_common_pvt.log_message ('GME_FPO_RESERVATION_ERROR');
         RAISE fnd_api.g_exc_error;
      END IF;
       gme_api_main.create_line_reservations
                                    (p_init_msg_list      => p_init_msg_list
                                    ,p_matl_dtl_rec       => l_material_details_rec
                                    ,x_message_count      => x_message_count
                                    ,x_message_list       => x_message_list
                                    ,x_return_status      => x_return_status);

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'create line reservation returns '
                             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_commit = fnd_api.g_true THEN
         COMMIT;
      END IF;

      gme_debug.put_line (   'End of Create_Line_Reservations at '
                          || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT create_line_reservations;
         gme_common_pvt.count_and_get(x_count        => x_message_count
                                     ,p_encoded      => fnd_api.g_false
                                     ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_line_reservations;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END create_line_reservations;

/*************************************************************************/
   PROCEDURE insert_process_parameter (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER
     ,p_init_msg_list         IN              VARCHAR2
     ,p_commit                IN              VARCHAR2
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,p_batch_no              IN              VARCHAR2
     ,p_org_code              IN              VARCHAR2
     ,p_validate_flexfields   IN              VARCHAR2
     ,p_batchstep_no          IN              NUMBER
     ,p_activity              IN              VARCHAR2
     ,p_parameter             IN              VARCHAR2
     ,p_process_param_rec     IN              gme_process_parameters%ROWTYPE
     ,x_process_param_rec     OUT NOCOPY      gme_process_parameters%ROWTYPE)
   IS
      insert_parameter_failed   EXCEPTION;
      l_api_name       CONSTANT VARCHAR2 (30) := 'INSERT_PROCESS_PARAMETER';
   BEGIN
      IF (g_debug IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      SAVEPOINT insert_process_parameter;

      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('InsertProcessParameters');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
       END IF;
      -- Make sure we are call compatible
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'Insert_process_parameter'
                                         ,g_pkg_name) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('PM_INVALID_PHANTOM_ACTION');
         RAISE fnd_api.g_exc_error;
      END IF;

       gme_common_pvt.g_setup_done := gme_common_pvt.setup (p_org_code => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
      	  IF (g_debug = gme_debug.g_log_statement) THEN
             gme_debug.put_line (g_pkg_name||'.'||l_api_name|| ':set up problem ');
          END IF;
         RAISE fnd_api.g_exc_error;
      END IF;
      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line ('Calling Insert process parameters');
      END IF;

      gme_common_pvt.set_timestamp;
      gme_process_parameters_pvt.insert_process_parameter
                              (p_batch_no                 => p_batch_no
                              ,p_org_code                 => p_org_code
                              ,p_validate_flexfields      => p_validate_flexfields
                              ,p_batchstep_no             => p_batchstep_no
                              ,p_activity                 => p_activity
                              ,p_parameter                => p_parameter
                              ,p_process_param_rec        => p_process_param_rec
                              ,x_process_param_rec        => x_process_param_rec
                              ,x_return_status            => x_return_status);

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line
               (   'Came back from Pvt insert process parameter with status '
                || x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            COMMIT;
            gme_common_pvt.log_message ('PM_SAVED_CHANGES');
         END IF;
      ELSE
         RAISE insert_parameter_failed;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' : Exiting with '
                             || x_return_status
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT insert_process_parameter;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN insert_parameter_failed THEN
         ROLLBACK TO SAVEPOINT insert_process_parameter;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT insert_process_parameter;
        gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END insert_process_parameter;

/*************************************************************************/
   PROCEDURE update_process_parameter (
      p_api_version           IN              NUMBER
     ,p_validation_level      IN              NUMBER
     ,p_init_msg_list         IN              VARCHAR2
     ,p_commit                IN              VARCHAR2
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,p_batch_no              IN              VARCHAR2
     ,p_org_code              IN              VARCHAR2
     ,p_validate_flexfields   IN              VARCHAR2
     ,p_batchstep_no          IN              NUMBER
     ,p_activity              IN              VARCHAR2
     ,p_parameter             IN              VARCHAR2
     ,p_process_param_rec     IN              gme_process_parameters%ROWTYPE
     ,x_process_param_rec     OUT NOCOPY      gme_process_parameters%ROWTYPE)
   IS
      update_parameter_failed   EXCEPTION;
      l_api_name       CONSTANT VARCHAR2 (30) := 'UPDATE_PROCESS_PARAMETER';
   BEGIN
      IF (g_debug IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      SAVEPOINT update_process_parameter;

      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('UpdateProcessParameter');
      END IF;

      /* Initially let us assign the return status to success */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      -- Make sure we are call compatible
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'Insert_process_parameter'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.g_setup_done := gme_common_pvt.setup (p_org_code => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_process_parameters_pvt.update_process_parameter
                              (p_batch_no                 => p_batch_no
                              ,p_org_code                 => p_org_code
                              ,p_validate_flexfields      => p_validate_flexfields
                              ,p_batchstep_no             => p_batchstep_no
                              ,p_activity                 => p_activity
                              ,p_parameter                => p_parameter
                              ,p_process_param_rec        => p_process_param_rec
                              ,x_process_param_rec        => x_process_param_rec
                              ,x_return_status            => x_return_status);

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line
               (   'Came back from Pvt update process parameter with status '
                || x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            COMMIT;
            gme_common_pvt.log_message ('PM_SAVED_CHANGES');
         END IF;
      ELSE
         RAISE update_parameter_failed;
      END IF;

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
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT update_process_parameter;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN update_parameter_failed THEN
         ROLLBACK TO SAVEPOINT update_process_parameter;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT update_process_parameter;
        gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END update_process_parameter;

/*************************************************************************/
   PROCEDURE delete_process_parameter (
      p_api_version         IN              NUMBER
     ,p_validation_level    IN              NUMBER
     ,p_init_msg_list       IN              VARCHAR2
     ,p_commit              IN              VARCHAR2
     ,x_message_count       OUT NOCOPY      NUMBER
     ,x_message_list        OUT NOCOPY      VARCHAR2
     ,x_return_status       OUT NOCOPY      VARCHAR2
     ,p_batch_no            IN              VARCHAR2
     ,p_org_code            IN              VARCHAR2
     ,p_batchstep_no        IN              NUMBER
     ,p_activity            IN              VARCHAR2
     ,p_parameter           IN              VARCHAR2
     ,p_process_param_rec   IN              gme_process_parameters%ROWTYPE)
   IS
      delete_parameter_failed   EXCEPTION;
      l_api_name       CONSTANT VARCHAR2 (30) := 'DELETE_PROCESS_PARAMETER';
   BEGIN
      IF (g_debug IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      SAVEPOINT delete_process_parameter;

      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('DeleteProcessParameter');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      -- Make sure we are call compatible
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'Insert_process_parameter'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.g_setup_done := gme_common_pvt.setup (p_org_code => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (g_debug <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line ('Calling Insert process parameters');
      END IF;

      gme_common_pvt.set_timestamp;
      gme_process_parameters_pvt.delete_process_parameter
                                  (p_batch_no               => p_batch_no
                                  ,p_org_code               => p_org_code
                                  ,p_batchstep_no           => p_batchstep_no
                                  ,p_activity               => p_activity
                                  ,p_parameter              => p_parameter
                                  ,p_process_param_rec      => p_process_param_rec
                                  ,x_return_status          => x_return_status);

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line
               (   'Came back from Pvt delete process parameter with status '
                || x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            COMMIT;
            gme_common_pvt.log_message ('PM_SAVED_CHANGES');
         END IF;
      ELSE
         RAISE delete_parameter_failed;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ':' ||
         'Exiting with ' || x_return_status || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT delete_process_parameter;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN delete_parameter_failed THEN
         ROLLBACK TO SAVEPOINT delete_process_parameter;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_process_parameter;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END delete_process_parameter;

/*************************************************************************/
   PROCEDURE delete_step (
      p_api_version        IN              NUMBER := 2.0
     ,p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_commit             IN              VARCHAR2
     ,p_org_code           IN              VARCHAR2
     ,p_batch_no           IN              VARCHAR2
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec     IN              gme_batch_steps%ROWTYPE)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'DELETE_STEP';
      l_batch_header_rec    gme_batch_header%rowtype;
      delete_step_failed    EXCEPTION;
   BEGIN
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT delete_step;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Setup the common constants used accross the apis */
        gme_common_pvt.g_setup_done := gme_common_pvt.setup (p_org_code => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2
                                         ,p_api_version
                                         ,'delete_step'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;
      gme_api_main.delete_step (p_validation_level      => p_validation_level
                               ,p_init_msg_list         => fnd_api.g_false
                               ,x_message_count         => x_message_count
                               ,x_message_list          => x_message_list
                               ,x_return_status         => x_return_status
                               ,p_batch_header_rec      => l_batch_header_rec
                               ,p_batch_step_rec        => p_batch_step_rec);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE delete_step_failed;
      ELSE
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => null
                                   ,p_table              => 1
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at ' || TO_CHAR
         (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT delete_step;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN delete_step_failed THEN
         ROLLBACK TO SAVEPOINT delete_step;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
          ROLLBACK TO SAVEPOINT delete_step;
          gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END delete_step;

   /*************************************************************************
    * PROCEURE
    *    insert_step
    * History
    * Punit Kumar 07-Apr-2005
    *   Convergence Changes
    * SivakumarG 16-NOV-2005 FPBug#4395561
    *  Added new argument p_validate_flexfields
   /*************************************************************************/
   PROCEDURE insert_step (
      p_api_version         IN              NUMBER := 2.0
     ,p_validation_level    IN              NUMBER  := gme_common_pvt.g_max_errors
     ,p_init_msg_list       IN              VARCHAR2 := fnd_api.g_false
     ,p_commit              IN              VARCHAR2
     ,p_org_code            IN              VARCHAR2
     ,p_validate_flexfields IN              VARCHAR2 := fnd_api.g_false
     ,p_oprn_no             IN              VARCHAR2
     ,p_oprn_vers           IN              NUMBER
     ,p_batch_header_rec    IN              gme_batch_header%ROWTYPE
     ,p_batch_step_rec      IN              gme_batch_steps%ROWTYPE
     ,x_batch_step_rec      OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_message_count       OUT NOCOPY      NUMBER
     ,x_message_list        OUT NOCOPY      VARCHAR2
     ,x_return_status       OUT NOCOPY      VARCHAR2)
   IS
      l_api_name         CONSTANT VARCHAR2 (30)              := 'INSERT_STEP';
      insert_step_failed          EXCEPTION;
      l_batch_header_rec          gme_batch_header%ROWTYPE;
      l_oprn_no                   VARCHAR2 (16);
      /* The operation number for the step */
      l_oprn_vers                 NUMBER;
      /* The operation version for the step */
      l_org_id                    NUMBER;
      l_verify_oprn               NUMBER                     := NULL;

      CURSOR get_oprn (l_oprn_id NUMBER)
      IS
         SELECT oprn_no, oprn_vers
           FROM gmd_operations_b
          WHERE oprn_id = l_oprn_id;

      CURSOR verify_oprn (
         l_oprn_no     VARCHAR2
        ,l_oprn_vers   NUMBER
        ,l_org_id      NUMBER)
      IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS (
                   SELECT 1
                     FROM gmd_operations_b
                    WHERE oprn_no = l_oprn_no
                      AND oprn_vers = l_oprn_vers
                      AND owner_organization_id = l_org_id);
   BEGIN
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT insert_step;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;
      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => p_batch_header_rec.organization_id
                              ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2
                                         ,p_api_version
                                         ,'insert_step'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_batch_step_rec.batch_id IS NOT NULL) THEN
         l_batch_header_rec.batch_id := p_batch_step_rec.batch_id;

         IF NOT (gme_batch_header_dbl.fetch_row (l_batch_header_rec
                                                ,l_batch_header_rec) ) THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         IF NOT (gme_batch_header_dbl.fetch_row (p_batch_header_rec
                                                ,l_batch_header_rec) ) THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      /* Bug 2766460 Added check not to allow insert step if batch is completed/closed or cancelled */
      IF (l_batch_header_rec.batch_status IN (gme_common_pvt.g_batch_cancelled,
                                              gme_common_pvt.g_batch_completed,
                                              gme_common_pvt.g_batch_closed) ) THEN
         gme_common_pvt.log_message ('GME_INV_STATUS_INSERT_STEP');
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Bug 2979072 Stop insert if there is no routing associated with this batch.
      IF (l_batch_header_rec.routing_id IS NULL) THEN
         gme_common_pvt.log_message
                           (p_message_code      => 'GME_API_NO_ROUTING_ASSOCIATED');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Punit Kumar , bringing this code from GMEVINSB.pls*/
      IF (p_batch_step_rec.steprelease_type NOT IN (1, 2) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_STEPRELEASE');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* End Bug 2397077 */
      IF    (l_batch_header_rec.batch_status = gme_common_pvt.g_batch_closed)
         OR (l_batch_header_rec.batch_status = gme_common_pvt.g_batch_cancelled) THEN
         -- Closed or cancelled batch not valid for step insert...
         gme_common_pvt.log_message ('GME_INV_STATUS_INSERT_STEP');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_batch_step_rec.oprn_id IS NOT NULL THEN
         OPEN get_oprn (p_batch_step_rec.oprn_id);

         FETCH get_oprn
          INTO l_oprn_no, l_oprn_vers;

         CLOSE get_oprn;

         IF     NVL (l_oprn_no, 0) = NVL (p_oprn_no, 0)
            AND NVL (l_oprn_vers, 0) = NVL (p_oprn_vers, 0) THEN
            IF g_debug <= gme_debug.g_log_procedure THEN
               gme_debug.put_line (' oprn_no and oprn_vers are valid');
            END IF;
         ELSE
            IF g_debug <= gme_debug.g_log_procedure THEN
               gme_debug.put_line (' oprn_no and oprn_vers are NOT valid');
            END IF;
            -- Bug 8312658 - Move command to raise the error outside of debug if statement.
            RAISE insert_step_failed;
         END IF;
      ELSE
         IF p_oprn_no IS NOT NULL AND p_oprn_vers IS NOT NULL THEN
            OPEN verify_oprn (p_oprn_no
                             ,p_oprn_vers
                             ,p_batch_header_rec.organization_id);

            FETCH verify_oprn
             INTO l_verify_oprn;

            CLOSE verify_oprn;

            IF l_verify_oprn IS NULL THEN
               IF g_debug <= gme_debug.g_log_procedure THEN
                  gme_debug.put_line
                     ('oprn_no and oprn_vers passed in are wrong and hence an error condition ');
               END IF;

               RAISE insert_step_failed;
            END IF;
         ELSE
            IF g_debug <= gme_debug.g_log_procedure THEN
               gme_debug.put_line
                  (' Both oprn_no and oprn_vers are  null hence oprn_no and oprn_vers cannot be validated ');
            END IF;

            RAISE insert_step_failed;
         END IF;
      END IF;

      IF p_validate_flexfields = fnd_api.g_true THEN
        gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
        gme_common_pvt.g_flex_validate_prof := 0;
      END IF;
       gme_api_main.insert_step (p_validation_level      => p_validation_level
                               ,p_init_msg_list         => fnd_api.g_false
                               ,x_message_count         => x_message_count
                               ,x_message_list          => x_message_list
                               ,x_return_status         => x_return_status
                               ,p_batch_header_rec      => l_batch_header_rec
                               ,p_batch_step_rec        => p_batch_step_rec
                               ,x_batch_step            => x_batch_step_rec);

      gme_common_pvt.g_flex_validate_prof := 0;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE insert_step_failed;
      ELSE
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => null
                                   ,p_table              => 1
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT insert_step;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN insert_step_failed THEN
         ROLLBACK TO SAVEPOINT insert_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT insert_step;
         x_batch_step_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END insert_step;

   /*================================================================================
    Procedure
      insert_material_line
    Description
      This procedure is used to insert a material line

    Parameters
      p_batch_header_rec (R)          batch for which material line has to be updated
      p_material_detail_rec (R)       material line details that has to be inserted
      p_locator_code (O)              Default Consumption/Yield Locator Code
      p_org_code (O)                  organization code
      p_batchstep_no(O)               batch step no
      p_validate_flexfields (O)       Whether to validate the flexfields
      x_material_detail_rec           inserted material detail record
      x_return_status                 outcome of the API call
                                      S - Success
                                      E - Error
                                      U - Unexpected Error
    HISTORY
     SivakumarG Bug#5078853 02-MAR-2006
      Procedure Created

     G. Muratore    12-JUN-2009   Bug 7562848
        Allow users to insert material lines on phantom batches.
        Added parameter p_check_phantom when calling validate_batch.
  ================================================================================*/
    PROCEDURE insert_material_line (
         p_api_version           IN           NUMBER := 2.0
        ,p_validation_level      IN           NUMBER := gme_common_pvt.g_max_errors
        ,p_init_msg_list         IN           VARCHAR2 DEFAULT fnd_api.g_false
        ,p_commit                IN           VARCHAR2 DEFAULT fnd_api.g_false
        ,p_batch_header_rec      IN           gme_batch_header%ROWTYPE
        ,p_material_detail_rec   IN           gme_material_details%ROWTYPE
        ,p_locator_code          IN           VARCHAR2
        ,p_org_code              IN           VARCHAR2
        ,p_batchstep_no          IN           NUMBER := NULL
        ,p_validate_flexfields   IN           VARCHAR2 DEFAULT fnd_api.g_false
        ,x_material_detail_rec   OUT NOCOPY   gme_material_details%ROWTYPE
        ,x_message_count         OUT NOCOPY   NUMBER
        ,x_message_list          OUT NOCOPY   VARCHAR2
        ,x_return_status         OUT NOCOPY   VARCHAR2 )
    IS
    /* get the locator id */
    CURSOR c_get_locator(v_org_id NUMBER,v_sub_inv VARCHAR2) IS
     SELECT inventory_location_id locator_id
       FROM mtl_item_locations_kfv
      WHERE organization_id = v_org_id
        AND subinventory_code = v_sub_inv
        AND concatenated_segments = p_locator_code;

    l_api_name                    CONSTANT VARCHAR2 (30) := 'INSERT_MATERIAL_LINE';
    l_batch_header_rec            gme_batch_header%ROWTYPE;
    l_return_status               VARCHAR2(1);
    l_batch_step_rec              gme_batch_steps%ROWTYPE;
    l_material_detail_rec         gme_material_details%ROWTYPE;
    p_trans_id                    NUMBER;
    l_locator_id                  NUMBER;

    x_transacted                  VARCHAR2(30);

    BEGIN
     IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('INSERT_MATERIAL_LINE');
      END IF;

       IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'|| l_api_name);
       END IF;

       /* Set the return status to success initially */
       x_return_status := fnd_api.g_ret_sts_success;

       /* Set savepoint here */
       SAVEPOINT insert_material_line;

       /* Make sure we are call compatible */
       IF NOT fnd_api.compatible_api_call (2.0
                                           ,p_api_version
                                           ,'insert_material_line'
                                           ,g_pkg_name) THEN
          gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
          RAISE fnd_api.g_exc_error;
       END IF;

       /* Initialize message list and count if needed */
       IF p_init_msg_list = fnd_api.g_true THEN
          fnd_msg_pub.initialize;
       END IF;

       /* intialize local variable */
       l_material_detail_rec := p_material_detail_rec;
       -- Bug 7562848 - This api is ok for phantoms so bypass phantom check.
       gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,p_check_phantom     	=> 'N'
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      /*for ASQC batches batchstep_no is required */
      IF l_batch_header_rec.automatic_step_calculation <> 0 AND
         p_batchstep_no IS NULL THEN
         gme_common_pvt.log_message('GME_ASQC_STEP_REQUIRED');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF l_batch_header_rec.poc_ind = 'Y' AND
         p_batchstep_no IS NOT NULL THEN
        l_batch_step_rec.batch_id := l_batch_header_rec.batch_id;
        l_batch_step_rec.batchstep_no := p_batchstep_no;
        IF NOT gme_batch_steps_dbl.fetch_row(l_batch_step_rec, l_batch_step_rec) THEN
         RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

       --validate batch for insertion of  material line
       gme_material_detail_pvt.validate_batch_for_matl_ins
            (p_batch_header_rec => l_batch_header_rec
            ,p_batch_step_rec   => l_batch_step_rec
            ,x_return_status    => x_return_status );

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
       END IF;

       /* getting the locator for entered subinventory */
       IF l_material_detail_rec.subinventory IS NOT NULL AND
          p_locator_code IS NOT NULL THEN
          IF p_locator_code = fnd_api.g_miss_char THEN
           l_material_detail_rec.locator_id := fnd_api.g_miss_num;
          ELSE
            OPEN c_get_locator(l_batch_header_rec.organization_id, l_material_detail_rec.subinventory);
            FETCH c_get_locator INTO l_locator_id;
            IF c_get_locator%NOTFOUND THEN
             CLOSE c_get_locator;
              gme_common_pvt.log_message(p_product_code => 'INV'
                                       ,p_message_code => 'INV_INVALID_LOCATION');
             RAISE fnd_api.g_exc_error;
            END IF;
            CLOSE c_get_locator;
            l_material_detail_rec.locator_id := l_locator_id;
          END IF;
       END IF;

       --setting global flex validate
       IF p_validate_flexfields = FND_API.G_TRUE THEN
          gme_common_pvt.g_flex_validate_prof := 1;
       ELSE
          gme_common_pvt.g_flex_validate_prof := 0;
       END IF;

       --validate individual fields
       gme_material_detail_pvt.validate_material_for_ins (
          p_batch_header_rec      => l_batch_header_rec
         ,p_material_detail_rec   => l_material_detail_rec
         ,p_batch_step_rec        => l_batch_step_rec
         ,x_material_detail_rec   => x_material_detail_rec
         ,x_return_status         => x_return_status);

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
       END IF;
       gme_common_pvt.g_flex_validate_prof := 0;
       gme_common_pvt.set_timestamp;
       gme_common_pvt.g_move_to_temp := fnd_api.g_false;
       --calling insert material line new API
       l_material_detail_rec := x_material_detail_rec;

       gme_api_main.insert_material_line (
          p_validation_level    => p_validation_level
         ,p_init_msg_list       => p_init_msg_list
         ,x_message_count       => x_message_count
         ,x_message_list        => x_message_list
         ,x_return_status       => x_return_status
         ,p_batch_header_rec    => l_batch_header_rec
         ,p_material_detail_rec => l_material_detail_rec
         ,p_batch_step_rec      => l_batch_step_rec
         ,p_trans_id            => NULL
         ,x_transacted          => x_transacted
         ,x_material_detail_rec => x_material_detail_rec);

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
       ELSE
          IF p_commit = fnd_api.g_true THEN
             gme_api_pub.save_batch (p_header_id          => NULL
                                    ,p_table              => 1
                                    ,p_commit             => fnd_api.g_false
                                    ,x_return_status      => x_return_status);

    	  IF x_return_status = fnd_api.g_ret_sts_success THEN
                COMMIT;
              ELSE
               RAISE fnd_api.g_exc_error;
              END IF;
           END IF;
           NULL;
       END IF;

       IF g_debug <= gme_debug.g_log_procedure THEN
           gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                                 || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
       END IF;

    EXCEPTION
       WHEN fnd_api.g_exc_error THEN
          ROLLBACK TO SAVEPOINT insert_material_line;
          x_return_status := fnd_api.g_ret_sts_error;
          x_material_detail_rec := NULL;
          gme_common_pvt.count_and_get (x_count        => x_message_count
                                       ,p_encoded      => fnd_api.g_false
                                       ,x_data         => x_message_list);
       WHEN OTHERS THEN
          ROLLBACK TO SAVEPOINT insert_material_line;
      	 x_material_detail_rec := NULL;
          gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
    END insert_material_line;

    /*================================================================================
        Procedure
          update_material_line
        Description
          This procedure is used to update a material line

        Parameters
          p_batch_header_rec (R)          batch for which material line has to be updated
          p_material_detail_rec (R)       material line that has to be updated
          p_locator_code (O)              Default Consumption/Yield Locator Code
          p_org_code (O)                  organization code
          p_scale_phantom (O)             to scale phantom product only or total batch
          p_validate_flexfields (O)       Whether to validate the flexfields
          x_material_detail_rec           updated material detail record
          x_return_status                 outcome of the API call
                                          S - Success
                                          E - Error
                                          U - Unexpected Error
        HISTORY
         SivakumarG Bug#5078853 02-MAR-2006
          Procedure Created
      ================================================================================*/
    PROCEDURE update_material_line (
          p_api_version           IN           NUMBER := 2.0
         ,p_validation_level      IN           NUMBER := gme_common_pvt.g_max_errors
         ,p_init_msg_list         IN           VARCHAR2 DEFAULT fnd_api.g_false
         ,p_commit                IN           VARCHAR2 DEFAULT fnd_api.g_false
         ,p_batch_header_rec      IN           gme_batch_header%ROWTYPE
         ,p_material_detail_rec   IN           gme_material_details%ROWTYPE
         ,p_locator_code          IN           VARCHAR2
         ,p_org_code              IN           VARCHAR2
         ,p_scale_phantom         IN           VARCHAR2 DEFAULT fnd_api.g_false
         ,p_validate_flexfields   IN           VARCHAR2 DEFAULT fnd_api.g_false
         ,x_material_detail_rec   OUT NOCOPY   gme_material_details%ROWTYPE
         ,x_message_count         OUT NOCOPY   NUMBER
         ,x_message_list          OUT NOCOPY   VARCHAR2
         ,x_return_status         OUT NOCOPY   VARCHAR2 )
    IS
      /* get the locator id */
      CURSOR c_get_locator(v_org_id NUMBER,v_sub_inv VARCHAR2,v_locator VARCHAR2) IS
       SELECT inventory_location_id locator_id
         FROM mtl_item_locations_kfv
        WHERE organization_id = v_org_id
          AND subinventory_code = v_sub_inv
          AND concatenated_segments = v_locator;

      CURSOR c_get_step_id(v_mat_id NUMBER) IS
       SELECT batchstep_id
         FROM gme_batch_step_items
        WHERE material_detail_id = v_mat_id;

      l_api_name                   CONSTANT VARCHAR2 (30) := 'UPDATE_MATERIAL_LINE';
      l_batch_header_rec           gme_batch_header%ROWTYPE;
      l_return_status              VARCHAR2(1);
      l_batch_step_rec             gme_batch_steps%ROWTYPE;
      l_material_detail_rec        gme_material_details%ROWTYPE;
      l_stored_material_detail_rec gme_material_details%ROWTYPE;
      p_trans_id                   NUMBER;
      l_subinventory               VARCHAR2(30);
      l_locator_id                 NUMBER;
      l_batchstep_id               NUMBER;

      x_transacted                 VARCHAR2(30);
      x_batch_header_rec           gme_batch_header%ROWTYPE;


    BEGIN

       IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('UPADATE_MATERIAL_LINE');
      END IF;
       IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'|| l_api_name);
       END IF;

       /* Set the return status to success initially */
       x_return_status := fnd_api.g_ret_sts_success;

       /* Set savepoint here */
       SAVEPOINT update_material_line;

       /* Make sure we are call compatible */
       IF NOT fnd_api.compatible_api_call (2.0
                                           ,p_api_version
                                           ,'update_material_line'
                                           ,g_pkg_name) THEN
          gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
          RAISE fnd_api.g_exc_error;
       END IF;

       /* Initialize message list and count if needed */
       IF p_init_msg_list = fnd_api.g_true THEN
          fnd_msg_pub.initialize;
       END IF;

       /*validatep p_scale_phantom procedure */
       IF (p_scale_phantom NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
          gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                      ,'FIELD'
                                      ,'p_scale_phantom');
          RAISE fnd_api.g_exc_error;
       END IF;

       /* assigning local variables */
       l_material_detail_rec := p_material_detail_rec;
       gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> l_material_detail_rec
                          ,p_org_code                 	=> p_org_code
                          ,p_batch_no                 	=> p_batch_header_rec.batch_no
                          ,p_batch_type               	=> nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_stored_material_detail_rec
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      /* get the batch step record if the material line is associated to step*/
       IF l_batch_header_rec.poc_ind = 'Y' THEN --routing is there
         OPEN c_get_step_id(l_stored_material_detail_rec.material_detail_id);
         FETCH c_get_step_id INTO l_batchstep_id;
         IF c_get_step_id%FOUND THEN
           l_batch_step_rec.batchstep_id :=  l_batchstep_id;

           IF NOT gme_batch_steps_dbl.fetch_row(l_batch_step_rec, l_batch_step_rec) THEN
            CLOSE c_get_step_id;
            RAISE fnd_api.g_exc_error;
           END IF;
         END IF;
         CLOSE c_get_step_id;
       END IF;


       --validate batch for update of  material line
       gme_material_detail_pvt.validate_batch_for_matl_ins
            (p_batch_header_rec => l_batch_header_rec
            ,p_batch_step_rec   => l_batch_step_rec
            ,x_return_status    => l_return_status );

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
       END IF;

       /*updating the locator will have meaning only sub inv is existing already */
       l_subinventory := NVL(l_material_detail_rec.subinventory, l_stored_material_detail_rec.subinventory);
       IF l_subinventory IS NOT NULL AND p_locator_code IS NOT NULL THEN
         IF p_locator_code = fnd_api.g_miss_char THEN
          l_material_detail_rec.locator_id := fnd_api.g_miss_num;
         ELSE
            OPEN c_get_locator(l_stored_material_detail_rec.organization_id, l_subinventory,p_locator_code);
            FETCH c_get_locator INTO l_locator_id;
            IF c_get_locator%NOTFOUND THEN
             CLOSE c_get_locator;
             gme_common_pvt.log_message(p_product_code => 'INV'
                                       ,p_message_code => 'INV_INVALID_LOCATION');
             RAISE fnd_api.g_exc_error;
            END IF;
            CLOSE c_get_locator;
            l_material_detail_rec.locator_id := l_locator_id;
          END IF;
       END IF;

       --setting global flex validate
       IF p_validate_flexfields = FND_API.G_TRUE THEN
          gme_common_pvt.g_flex_validate_prof := 1;
       ELSE
          gme_common_pvt.g_flex_validate_prof := 0;
       END IF;

       --validate and pop material line
       gme_material_detail_pvt.val_and_pop_material_for_upd
          ( p_batch_header_rec             => l_batch_header_rec
           ,p_material_detail_rec          => l_material_detail_rec
           ,p_stored_material_detail_rec   => l_stored_material_detail_rec
           ,p_batch_step_rec               => l_batch_step_rec
           ,x_material_detail_rec          => x_material_detail_rec
           ,x_return_status                => l_return_status );

       --resetting global flex validate after validating
       gme_common_pvt.g_flex_validate_prof := 0;

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
       END IF;
       gme_common_pvt.g_move_to_temp := fnd_api.g_false;
       gme_common_pvt.set_timestamp;
       --calling update material line new API
       l_material_detail_rec := x_material_detail_rec;

       gme_api_main.update_material_line (
          p_validation_level             => p_validation_level
         ,p_init_msg_list                => p_init_msg_list
         ,x_message_count                => x_message_count
         ,x_message_list                 => x_message_list
         ,x_return_status                => x_return_status
         ,p_batch_header_rec             => l_batch_header_rec
         ,p_material_detail_rec          => l_material_detail_rec
         ,p_stored_material_detail_rec   => l_stored_material_detail_rec
         ,p_batch_step_rec               => l_batch_step_rec
         ,p_scale_phantom                => p_scale_phantom
         ,p_trans_id                     => NULL
         ,x_transacted                   => x_transacted
         ,x_material_detail_rec          => x_material_detail_rec);



       IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
       ELSE
          IF p_commit = fnd_api.g_true THEN
             gme_api_pub.save_batch (p_header_id          => NULL
                                    ,p_table              => 1
                                    ,p_commit             => fnd_api.g_false
                                    ,x_return_status      => x_return_status);

    	  IF x_return_status = fnd_api.g_ret_sts_success THEN
                COMMIT;
              ELSE
               RAISE fnd_api.g_exc_error;
              END IF;
           END IF;
           NULL;
       END IF;

       IF g_debug <= gme_debug.g_log_procedure THEN
           gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                                 || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
       END IF;

    EXCEPTION
       WHEN fnd_api.g_exc_error THEN
          ROLLBACK TO SAVEPOINT update_material_line;
          x_return_status := fnd_api.g_ret_sts_error;
          x_material_detail_rec := NULL;
           gme_common_pvt.count_and_get (x_count        => x_message_count
                                       ,p_encoded      => fnd_api.g_false
                                       ,x_data         => x_message_list);
       WHEN OTHERS THEN
          ROLLBACK TO SAVEPOINT update_material_line;
       	 x_material_detail_rec := NULL;
          gme_when_others (	p_api_name              => l_api_name
     				              ,x_message_count        => x_message_count
     				              ,x_message_list         => x_message_list
     				              ,x_return_status   	=> x_return_status );
    END update_material_line;

    /*================================================================================
        Procedure
          delete_material_line
        Description
          This procedure is used to delete a material line

        Parameters
          p_batch_header_rec (R)          batch for which material line has to be updated
          p_material_detail_rec (R)       material line that has to be updated
          p_org_code (O)                  organization code
          x_return_status                 outcome of the API call
                                          S - Success
                                          E - Error
                                          U - Unexpected Error
        HISTORY
         SivakumarG Bug#5078853 02-MAR-2006
          Procedure Created
    ================================================================================*/
    PROCEDURE delete_material_line (
          p_api_version           IN           NUMBER := 2.0
         ,p_validation_level      IN           NUMBER := gme_common_pvt.g_max_errors
         ,p_init_msg_list         IN           VARCHAR2 DEFAULT fnd_api.g_false
         ,p_commit                IN           VARCHAR2 DEFAULT fnd_api.g_false
         ,p_batch_header_rec      IN           gme_batch_header%ROWTYPE
         ,p_material_detail_rec   IN           gme_material_details%ROWTYPE
         ,p_org_code              IN           VARCHAR2
         ,x_message_count         OUT NOCOPY   NUMBER
         ,x_message_list          OUT NOCOPY   VARCHAR2
         ,x_return_status         OUT NOCOPY   VARCHAR2 )
    IS
      CURSOR c_get_step_id(v_mat_id NUMBER) IS
       SELECT batchstep_id
         FROM gme_batch_step_items
        WHERE material_detail_id = v_mat_id;

      l_api_name         CONSTANT VARCHAR2 (30) := 'DELETE_MATERIAL_LINE';
      l_batch_header_rec           gme_batch_header%ROWTYPE;
      l_return_status              VARCHAR2(1);
      l_batch_step_rec             gme_batch_steps%ROWTYPE;
      l_material_detail_rec        gme_material_details%ROWTYPE;

      l_batchstep_id               NUMBER;
      x_transacted                 VARCHAR2(30);
      x_batch_header_rec           gme_batch_header%ROWTYPE;

    BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('DELETE_MATERIAL_LINE');
      END IF;
       IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'|| l_api_name);
       END IF;

       /* Set the return status to success initially */
       x_return_status := fnd_api.g_ret_sts_success;

       /* Set savepoint here */
       SAVEPOINT delete_material_line;

       /* Make sure we are call compatible */
       IF NOT fnd_api.compatible_api_call (2.0
                                           ,p_api_version
                                           ,'delete_material_line'
                                           ,g_pkg_name) THEN
          gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
          RAISE fnd_api.g_exc_error;
       END IF;

       /* Initialize message list and count if needed */
       IF p_init_msg_list = fnd_api.g_true THEN
          fnd_msg_pub.initialize;
       END IF;

        gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> p_material_detail_rec
                          ,p_org_code                 	=> p_org_code
                          ,p_batch_no                 	=> p_batch_header_rec.batch_no
                          ,p_batch_type               	=> nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_material_detail_rec
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

       /* get the batch step record if the material line is associated to step*/
       IF l_batch_header_rec.poc_ind = 'Y' THEN --routing is there
         OPEN c_get_step_id(l_material_detail_rec.material_detail_id);
         FETCH c_get_step_id INTO l_batchstep_id;
         IF c_get_step_id%FOUND THEN
           l_batch_step_rec.batchstep_id :=  l_batchstep_id;

           IF NOT gme_batch_steps_dbl.fetch_row(l_batch_step_rec, l_batch_step_rec) THEN
            CLOSE c_get_step_id;
            RAISE fnd_api.g_exc_error;
           END IF;
         END IF;
         CLOSE c_get_step_id;
       END IF;

       --calling validate material (includes batch status check)
       gme_material_detail_pvt.validate_material_for_del (
          p_batch_header_rec     => l_batch_header_rec
         ,p_material_detail_rec  => l_material_detail_rec
         ,p_batch_step_rec       => l_batch_step_rec
         ,x_return_status        => x_return_status);

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
       END IF;
        gme_common_pvt.g_move_to_temp := fnd_api.g_false;
       --calling delete material line
       gme_api_main.delete_material_line (
          p_validation_level    => p_validation_level
         ,p_init_msg_list       => p_init_msg_list
         ,x_message_count       => x_message_count
         ,x_message_list        => x_message_list
         ,x_return_status       => x_return_status
         ,p_batch_header_rec    => l_batch_header_rec
         ,p_material_detail_rec => l_material_detail_rec
         ,p_batch_step_rec      => l_batch_step_rec
         ,x_transacted          => x_transacted );

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
       END IF;

       IF g_debug <= gme_debug.g_log_procedure THEN
           gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                                 || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
       END IF;

    EXCEPTION
       WHEN fnd_api.g_exc_error THEN
          ROLLBACK TO SAVEPOINT delete_material_line;
          x_return_status := fnd_api.g_ret_sts_error;
          gme_common_pvt.count_and_get (x_count        => x_message_count
                                       ,p_encoded      => fnd_api.g_false
                                       ,x_data         => x_message_list);
       WHEN OTHERS THEN
          ROLLBACK TO SAVEPOINT delete_material_line;
          gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
    END delete_material_line;

  /*================================================================================
    Procedure
      revert_batch
    Description
      This procedure reverts a completed batch to WIP and all the phantom batches.

    Parameters
      p_batch_header (R)        The batch header row to identify the batch
                                Following columns are used from this row.
                                batch_id  (R)
      p_org_code                The name of organization to which this batch belongs
      p_continue_lpn_txn (O)     Indicates whether to continue processing a batch when product or byproduct has lpn transaction.
      x_batch_header            The batch header that is returned, with all the data
      x_return_status           outcome of the API call
                                S - Success
                                E - Error
                                U - Unexpected Error
  ================================================================================*/

    PROCEDURE revert_batch (
      p_continue_lpn_txn         IN              VARCHAR2 := 'N'
     ,p_api_version            	IN             	NUMBER := 2.0
     ,p_validation_level       	IN              NUMBER
     ,p_init_msg_list          	IN              VARCHAR2
     ,p_commit                 	IN              VARCHAR2
     ,x_message_count          	OUT NOCOPY      NUMBER
     ,x_message_list           	OUT NOCOPY      VARCHAR2
     ,x_return_status          	OUT NOCOPY      VARCHAR2
     ,p_org_code              	IN            	VARCHAR2
     ,p_batch_header_rec       	IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec      	OUT NOCOPY 	gme_batch_header%ROWTYPE)IS

      l_api_name        CONSTANT VARCHAR2 (30) := 'REVERT_BATCH';
      l_batch_header_rec             gme_batch_header%ROWTYPE;
      batch_revert_failure   	EXCEPTION;
      -- FP Bug 6437252
      x_lpn_txns                 NUMBER;
      l_continue_lpn_txn         VARCHAR2(1);
      CURSOR get_lpn_txns(p_batch_id IN NUMBER) IS
         SELECT  COUNT(1)
         FROM mtl_material_transactions mmt, gme_material_details mtl
         WHERE NVL(transfer_lpn_id,0) > 0
           AND TRANSACTION_SOURCE_ID = p_batch_id
           AND transaction_action_id = 31
           AND transaction_type_id IN (44, 1002)
           AND mmt.transaction_source_id = mtl.batch_id
           AND mmt.inventory_item_id = mtl.inventory_item_id
           AND mmt.transaction_id NOT IN (
           SELECT transaction_id1
                    FROM gme_transaction_pairs
                    WHERE batch_id = p_batch_id
                    AND pair_type = 1);
    BEGIN
        IF (g_debug <> -1) THEN
          gme_debug.log_initialize('RevertBatch');
        END IF;
        IF g_debug <= gme_debug.g_log_procedure THEN
          gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
        END IF;
        /* Set the return status to success initially */
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_init_msg_list = FND_API.G_TRUE THEN
          fnd_msg_pub.initialize;
        END IF;

        /* Set savepoint here */
        SAVEPOINT revert_batch;

        IF NOT FND_API.compatible_api_call(2.0, p_api_version, 'revert_to_wip_batch', g_pkg_name ) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
          RAISE FND_API.g_exc_error;
        END IF;
        -- fetch and validate the batch
        gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

        IF (l_batch_header_rec.batch_type <> gme_common_pvt.g_doc_type_batch) THEN
          gme_common_pvt.log_message('GME_INVALID_BATCH_TYPE');
          RAISE fnd_api.g_exc_error;
        END IF;
        IF (l_batch_header_rec.batch_status <> gme_common_pvt.g_batch_completed) THEN
          gme_common_pvt.log_message('GME_API_INVALID_BATCH_UNCERT');
          RAISE fnd_api.g_exc_error;
        END IF;
        IF (NVL(l_batch_header_rec.terminated_ind, 0) = 1) THEN
          gme_common_pvt.log_message('GME_API_REV_WIP_TERM_ERROR');
          RAISE fnd_api.g_exc_error;
        END IF;

        IF g_debug <= gme_debug.g_log_statement THEN
          gme_debug.put_line('calling main revert');
        END IF;
        --Bug#5327296
        gme_common_pvt.g_move_to_temp := fnd_api.g_false;
        /* Bug 6437252 Check for LPN txns */
        OPEN get_lpn_txns (l_batch_header_rec.batch_id);
        FETCH get_lpn_txns INTO x_lpn_txns;
        CLOSE get_lpn_txns;

        IF ( NVL(x_lpn_txns, 0) > 0) THEN
           IF p_continue_lpn_txn = 'N' THEN
              gme_common_pvt.log_message ('GME_LPN_TRANS_EXISTS');
              RAISE fnd_api.g_exc_error;
           END IF;
        END IF;

        gme_api_main.revert_batch
                                 (p_validation_level       => p_validation_level,
                                  p_init_msg_list          => FND_API.G_FALSE,
                                  x_message_count          => x_message_count,
                                  x_message_list           => x_message_list,
                                  x_return_status          => x_return_status,
                                  p_batch_header_rec       => l_batch_header_rec,
                                  x_batch_header_rec       => x_batch_header_rec
                                 );


        IF g_debug <= gme_debug.g_log_statement THEN
          gme_debug.put_line(g_pkg_name|| '.'|| l_api_name||
             ':'||'return_status from main'||x_return_status );
        END IF;

        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
           IF p_commit = FND_API.G_TRUE THEN
              gme_api_pub.save_batch (p_header_id     => NULL,
                                      p_table         => gme_common_pvt.g_interface_table,
                                      p_commit        => p_commit,
                                      x_return_status => x_return_status);

              IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
              ELSE
                 RAISE fnd_api.g_exc_error;
              END IF;
           END IF;
        ELSE
           RAISE batch_revert_failure;
        END IF;

        gme_common_pvt.count_and_get (
             x_count =>        x_message_count,
             p_encoded =>      FND_API.g_false,
             x_data =>         x_message_list
        );

        IF g_debug <= gme_debug.g_log_procedure THEN
          gme_debug.put_line ('Completed '|| l_api_name|| ' at '|| TO_CHAR
          (SYSDATE, 'MM/DD/YYYY HH24:MI:SS'));
        END IF;

    EXCEPTION
       WHEN batch_revert_failure THEN
         ROLLBACK TO SAVEPOINT revert_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get(x_count   => x_message_count,
                                      p_encoded => FND_API.g_false,
                                      x_data    => x_message_list);
       WHEN FND_API.g_exc_error THEN
            ROLLBACK TO SAVEPOINT revert_batch;
            x_return_status := fnd_api.g_ret_sts_error;
            x_batch_header_rec := NULL;
            gme_common_pvt.count_and_get (x_count        => x_message_count
                                         ,p_encoded      => fnd_api.g_false
                                         ,x_data         => x_message_list);
       WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT revert_batch;
         x_batch_header_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
    END revert_batch ;
   /*================================================================================
    Procedure
      revert_step
    Description
      This procedure reverts a step to WIP.

    Parameters
      p_batch_step (R)          The batch step row to identify the step
                                Following columns are used from this row.
                                batchstep_id  (R)
                                actual_start_date (O) (In case of direct completion)
                                actual_cmplt_date (O)
      p_org_code                The name of organization to which this batch belongs
      p_batch_no		batch number to which this step belongs
      x_batch_step              The batch step that is returned, with all the data
      x_return_status           outcome of the API call
                                S - Success
                                E - Error
                                U - Unexpected Error
  ================================================================================*/

   PROCEDURE revert_step (
     p_api_version            	IN             	NUMBER := 2.0
     ,p_validation_level       	IN              NUMBER
     ,p_init_msg_list          	IN              VARCHAR2
     ,p_commit                 	IN              VARCHAR2
     ,x_message_count          	OUT NOCOPY      NUMBER
     ,x_message_list           	OUT NOCOPY      VARCHAR2
     ,x_return_status          	OUT NOCOPY      VARCHAR2
     ,p_org_code              	IN            	VARCHAR2
     ,p_batch_no   		IN		VARCHAR2
     ,p_batch_step_rec        	IN         gme_batch_steps%ROWTYPE
     ,x_batch_step_rec       	OUT NOCOPY gme_batch_steps%ROWTYPE)IS

      l_api_name       CONSTANT VARCHAR2 (30) := 'REVERT_STEP';
      l_batch_step_rec          gme_batch_steps%ROWTYPE;
      l_batch_header_rec	gme_batch_header%rowtype;

      step_revert_failure      	EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
        gme_debug.log_initialize('RevertStep');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /* Set savepoint here */
      SAVEPOINT revert_step;

      IF p_init_msg_list = FND_API.G_TRUE THEN
        fnd_msg_pub.initialize;
      END IF;

      IF NOT FND_API.compatible_api_call(2.0, p_api_version, 'revert_step', g_pkg_name ) THEN
        gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Input parameters */
       gme_common_pvt.Validate_batch_step (
              p_batch_step_rec     =>  	p_batch_step_rec
             ,p_org_code           =>  	p_org_code
             ,p_batch_no           =>  	p_batch_no
             ,x_batch_step_rec     =>  	l_batch_step_rec
             ,x_batch_header_rec   =>  	l_batch_header_rec
             ,x_message_count      => 	x_message_count
     	     ,x_message_list       => 	x_message_list
             ,x_return_status      => 	x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch step validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      IF (l_batch_header_rec.batch_status <> 2) THEN
       gme_common_pvt.log_message ('GME_API_INV_BATCH_UNCERT_STEP');
       RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_batch_step_rec.step_status <> 3) THEN
       gme_common_pvt.log_message ('GME_API_INV_STEP_STAT_UNCERT');
       RAISE fnd_api.g_exc_error;
      END IF;

      --Bug#5327296
      gme_common_pvt.g_move_to_temp := fnd_api.g_false;
      gme_api_main.revert_step
                             (p_validation_level       => p_validation_level,
                              p_init_msg_list          => FND_API.G_FALSE,
                              x_message_count          => x_message_count,
                              x_message_list           => x_message_list,
                              x_return_status          => x_return_status,
                              p_batch_step_rec         => l_batch_step_rec,
                              p_batch_header_rec       => l_batch_header_rec,
                              x_batch_step_rec         => x_batch_step_rec
                             );

      IF g_debug <= gme_debug.g_log_statement THEN
       gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'||'return_status from main'||x_return_status );
      END IF;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF p_commit = FND_API.G_TRUE THEN
          gme_api_pub.save_batch (p_header_id     => NULL,
                                  p_table         => gme_common_pvt.g_interface_table,
                                  p_commit        => FND_API.G_FALSE,
                                  x_return_status => x_return_status);
           IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
             COMMIT;
           ELSE
              RAISE fnd_api.g_exc_error;
           END IF;
       END IF;
      ELSE
       RAISE step_revert_failure;
      END IF;

      gme_common_pvt.count_and_get (
         x_count =>        x_message_count,
         p_encoded =>      FND_API.g_false,
         x_data =>         x_message_list
      );

      IF g_debug <= gme_debug.g_log_procedure THEN
       gme_debug.put_line ('Completed '|| l_api_name|| ' at '|| TO_CHAR
       (SYSDATE, 'MM/DD/YYYY HH24:MI:SS'));
      END IF;
  EXCEPTION
    WHEN step_revert_failure  THEN
      ROLLBACK TO SAVEPOINT revert_step;
      x_batch_step_rec := NULL;
      gme_common_pvt.count_and_get(x_count   => x_message_count,
                                   p_encoded => FND_API.g_false,
                                   x_data    => x_message_list);
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO SAVEPOINT revert_step;
      x_batch_step_rec := NULL;
      x_return_status := fnd_api.g_ret_sts_error;
      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT revert_step;
      x_batch_step_rec := NULL;
       gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
END revert_step ;
/*************************************************************************/
   PROCEDURE close_batch (
      p_api_version        IN              NUMBER
     ,p_validation_level   IN              NUMBER
     ,p_init_msg_list      IN              VARCHAR2
     ,p_commit             IN              VARCHAR2
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE
     ,p_org_code           IN              VARCHAR2)
   IS
      l_api_name        CONSTANT VARCHAR2 (30)              := 'CLOSE_BATCH';
      l_batch_header_rec         gme_batch_header%ROWTYPE;

      batch_close_failure        EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT close_batch_pub;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2
                                         ,p_api_version
                                         ,'close_batch'
                                         ,g_pkg_name) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;
      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;


      IF (l_batch_header_rec.batch_status <> gme_common_pvt.g_batch_completed) THEN
         gme_common_pvt.log_message ('GME_CLOSE_STATUS_ERR');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_batch_header_rec.batch_close_date IS NULL) THEN
         l_batch_header_rec.batch_close_date := SYSDATE;
      ELSIF (p_batch_header_rec.batch_close_date <
                                              l_batch_header_rec.actual_cmplt_date) THEN
         gme_common_pvt.log_message ('GME_INVALID_DATE_RANGE' ,'DATE1' ,'Close
         				date' ,'DATE2','completion date');
         RAISE fnd_api.g_exc_error;
      ELSIF (p_batch_header_rec.batch_close_date > SYSDATE) THEN
      	 gme_common_pvt.log_message(p_product_code => 'GMA'
                                       ,p_message_code => 'SY_NOFUTUREDATE');
         RAISE fnd_api.g_exc_error;
      ELSE
         l_batch_header_rec.batch_close_date :=
                                          p_batch_header_rec.batch_close_date;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Calling gme_api_main.close_batch.');
      END IF;

      gme_api_main.close_batch (p_validation_level      => p_validation_level
                               ,p_init_msg_list         => fnd_api.g_false
                               ,x_message_count         => x_message_count
                               ,x_message_list          => x_message_list
                               ,x_return_status         => x_return_status
                               ,p_batch_header_rec      => l_batch_header_rec
                               ,x_batch_header_rec      => x_batch_header_rec);

      IF (g_debug = gme_debug.g_log_statement) THEN
         gme_debug.put_line('Came back from Main Close Batch with status '
                            || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE batch_close_failure;
      ELSE
         IF (g_debug = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Calling save_batch.');
         END IF;

         gme_api_pub.save_batch (p_header_id          => null
                                ,p_table              => 1
                                ,p_commit             => fnd_api.g_false
                                ,x_return_status      => x_return_status);

         IF (g_debug = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   'Came back from save_batch with status '
                                || x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_commit = fnd_api.g_true THEN
            COMMIT;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN batch_close_failure THEN
         ROLLBACK TO SAVEPOINT close_batch_pub;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO SAVEPOINT close_batch_pub;
         x_batch_header_rec := NULL;
	      x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT close_batch_pub;
         x_batch_header_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END close_batch;
/*************************************************************************/
   PROCEDURE close_step (
      p_api_version        IN              NUMBER := 2
      /* Punit Kumar */
     ,p_validation_level   IN              NUMBER   := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_commit             IN              VARCHAR2
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec     IN              gme_batch_steps%ROWTYPE
     ,p_delete_pending     IN              VARCHAR2 := fnd_api.g_false
     ,p_org_code           IN              VARCHAR2
     ,p_batch_no           IN              VARCHAR2
     ,x_batch_step_rec     OUT NOCOPY      gme_batch_steps%ROWTYPE)
   IS
      l_api_name      CONSTANT VARCHAR2 (30)              := 'CLOSE_STEP';

      l_batch_header_rec       gme_batch_header%ROWTYPE;
      l_batch_step_rec             gme_batch_steps%ROWTYPE;

      step_close_failed        EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT close_step_pub;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2
                                         ,p_api_version
                                         ,'close_batch_step'
                                         ,g_pkg_name) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Input parameters */
       gme_common_pvt.Validate_batch_step (
              p_batch_step_rec     =>  	p_batch_step_rec
             ,p_org_code           =>  	p_org_code
             ,p_batch_no           =>  	p_batch_no
             ,x_batch_step_rec     =>  	l_batch_step_rec
             ,x_batch_header_rec   =>  	l_batch_header_rec
             ,x_message_count      => 	x_message_count
     	     ,x_message_list       => 	x_message_list
             ,x_return_status      => 	x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch step validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      /* Bug 2404169 all date and status checks */
      IF (p_batch_step_rec.step_close_date IS NULL) THEN
         l_batch_step_rec.step_close_date := SYSDATE;
      ELSIF (p_batch_step_rec.step_close_date <
                NVL (l_batch_step_rec.actual_cmplt_date
                    ,p_batch_step_rec.step_close_date) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_DATE_RANGE'
                                    ,'DATE1'
                                    ,'Close date'
                                    ,'DATE2'
                                    ,'completion date');
         RAISE fnd_api.g_exc_error;
      ELSIF (p_batch_step_rec.step_close_date > SYSDATE) THEN
         gme_common_pvt.log_message(p_product_code => 'GMA'
                                       ,p_message_code => 'SY_NOFUTUREDATE');
         RAISE fnd_api.g_exc_error;
      ELSE
         l_batch_step_rec.step_close_date := p_batch_step_rec.step_close_date;
      END IF;

      IF (l_batch_step_rec.step_status <> 3) THEN
         gme_common_pvt.log_message ('PC_STEP_STATUS_ERR');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_api_main.close_step (p_validation_level      => p_validation_level
                              ,p_init_msg_list         => fnd_api.g_false
                              ,x_message_count         => x_message_count
                              ,x_message_list          => x_message_list
                              ,x_return_status         => x_return_status
                              ,p_batch_header_rec      => l_batch_header_rec
                              ,p_batch_step_rec        => l_batch_step_rec
                              ,p_delete_pending        => p_delete_pending
                              ,x_batch_step_rec        => x_batch_step_rec);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE step_close_failed;
      ELSE
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => null
                                   ,p_table              => 1
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN  step_close_failed THEN
         ROLLBACK TO SAVEPOINT close_step_pub;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT close_step_pub;
         x_batch_step_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
          ROLLBACK TO SAVEPOINT close_step_pub;
          x_batch_step_rec := NULL;
          gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END close_step;

/*************************************************************************/
   PROCEDURE reopen_batch (
      p_api_version        IN              NUMBER := 2
     ,p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_commit             IN              VARCHAR2
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_org_code           IN              VARCHAR2
     ,p_reopen_steps       IN              VARCHAR2 := fnd_api.g_false
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30) := 'REOPEN_BATCH';
      l_batch_header_rec     gme_batch_header%ROWTYPE;
      batch_reopen_failure   EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
       /* Set the success staus to success inititally*/
      x_return_status := fnd_api.g_ret_sts_success;
      /* Initialize message list and count if needed*/
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0                   /* Punit Kumar */
                                         ,p_api_version
                                         ,'reopen_batch'
                                         ,g_pkg_name) THEN
	gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
        RAISE fnd_api.g_exc_error;
      END IF;
      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
          IF (g_debug = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                              || ': batch validate error ');
           END IF;
         RAISE fnd_api.g_exc_error;
       END IF;
      gme_api_main.reopen_batch (p_validation_level      => p_validation_level
                                ,p_init_msg_list         => fnd_api.g_false
                                ,x_message_count         => x_message_count
                                ,x_message_list          => x_message_list
                                ,x_return_status         => x_return_status
                                ,p_batch_header_rec      => l_batch_header_rec
                                ,p_reopen_steps          => p_reopen_steps
                                ,x_batch_header_rec      => x_batch_header_rec);

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE batch_reopen_failure;
      ELSE
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch
                                 (p_header_id          => null
                                 ,p_table              => 1
                                 ,p_commit             => fnd_api.g_false
                                 ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
    WHEN batch_reopen_failure THEN
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_error THEN
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         x_batch_header_rec := NULL;
          gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END reopen_batch;

/*************************************************************************/
   PROCEDURE reopen_step (
      p_api_version        IN              NUMBER   := 2
     ,p_validation_level   IN              NUMBER   := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_commit             IN              VARCHAR2
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_org_code           IN              VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_batch_step_rec     IN              gme_batch_steps%ROWTYPE
     ,x_batch_step_rec     OUT NOCOPY      gme_batch_steps%ROWTYPE)
   IS
      l_api_name   CONSTANT VARCHAR2 (30):= 'REOPEN_STEP';
      l_batch_header_rec        gme_batch_header%ROWTYPE;
      l_batch_step_rec             gme_batch_steps%ROWTYPE;
      step_reopen_failure   EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
      /* Initialize message list and count if needed*/
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2
                                         ,p_api_version
                                         ,'reopen_step'
                                         ,g_pkg_name) THEN
        gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
	RAISE fnd_api.g_exc_error;
      END IF;

      /* Set the success staus to success inititally*/
      x_return_status := fnd_api.g_ret_sts_success;
     gme_common_pvt.Validate_batch_step (
              p_batch_step_rec     =>  	p_batch_step_rec
             ,p_org_code           =>  	p_org_code
             ,p_batch_no           =>  	p_batch_header_rec.batch_no
             ,x_batch_step_rec     =>  	l_batch_step_rec
             ,x_batch_header_rec   =>  	l_batch_header_rec
             ,x_message_count      => 	x_message_count
     	     ,x_message_list       => 	x_message_list
             ,x_return_status      => 	x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch step validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
        gme_api_main.reopen_step (p_validation_level      => p_validation_level
                               ,p_init_msg_list         => fnd_api.g_false
                               ,x_message_count         => x_message_count
                               ,x_message_list          => x_message_list
                               ,x_return_status         => x_return_status
                               ,p_batch_header_rec      => l_batch_header_rec
                               ,p_batch_step_rec        => l_batch_step_rec
                               ,x_batch_step_rec        => x_batch_step_rec);

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE step_reopen_failure;
      ELSE
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch (p_header_id          => null
                                   ,p_table              => 1
                                   ,p_commit             => fnd_api.g_false
                                   ,x_return_status      => x_return_status);
            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN step_reopen_failure THEN
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_error THEN
         x_batch_step_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
        x_batch_step_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END reopen_step;

/*************************************************************************/
   PROCEDURE incremental_backflush
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER   := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_org_code                 IN              VARCHAR2
     ,p_material_detail_rec      IN              gme_material_details%ROWTYPE
     ,p_qty                      IN              NUMBER
     ,p_qty_type                 IN              NUMBER
     ,p_trans_date               IN              DATE
     ,p_ignore_exception         IN              VARCHAR2 := fnd_api.g_false
     ,p_adjust_cmplt             IN              VARCHAR2 := fnd_api.g_true
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab)
   IS
      l_api_name        CONSTANT VARCHAR2 (30)  := 'INCREMENTAL_BACKFLUSH';
      l_material_detail_rec      gme_material_details%ROWTYPE;
      l_batch_header_rec         gme_batch_header%ROWTYPE;
      l_exception_material_tbl   gme_common_pvt.exceptions_tab;

      error_incr_backflush       EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('IncrementalBackflush');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'incremental_backflush'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Retrieve Batch Header and Material Detail Record */
      gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> p_material_detail_rec
                          ,p_org_code                 	=> p_org_code
                          ,p_batch_no                 	=> p_batch_header_rec.batch_no
                          ,p_batch_type               	=> nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_material_detail_rec
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
      -- Validations
      IF p_trans_date IS NOT NULL THEN
        IF p_trans_date > SYSDATE THEN
	  gme_common_pvt.log_message(p_product_code => 'GMA'
                                       ,p_message_code => 'SY_NOFUTUREDATE');
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /*Bug#5277982 if the batch is completed then we should not allow +veIB through API. so restricting this in public layer.
        we have to consider wip plan qty for new actual calculation
         0 - By increment qty,1 - New actual qty, 2 - % of Plan
       */
      IF l_batch_header_rec.batch_status = 3 THEN /*other batch status will be validated in the below validate procedure */
       IF (p_qty_type = 0 AND p_qty > 0) OR
          (p_qty_type = 1 AND p_qty > l_material_detail_rec.actual_qty) OR
          (p_qty_type = 2 AND (l_material_detail_rec.wip_plan_qty *p_qty/100) > l_material_detail_rec.actual_qty) THEN
	  gme_common_pvt.log_message('GME_IB_NOT_ALLOWED');
          RAISE fnd_api.g_exc_error;
       END IF;
      END IF;

      gme_incremental_backflush_pvt.validate_material_for_IB
                        (p_material_detail_rec        => l_material_detail_rec
                        ,p_batch_header_rec           => l_batch_header_rec
                        ,p_adjust_cmplt               => p_adjust_cmplt
                        ,x_return_status              => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_incremental_backflush_pvt.validate_qty_for_IB
                        (p_qty_type                  => p_qty_type
                        ,p_qty                       => p_qty
                        ,p_actual_qty                => l_material_detail_rec.actual_qty
                        ,x_return_status             => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;

      /* Invoke main */
      gme_api_main.incremental_backflush
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_batch_header_rec            => l_batch_header_rec
                         ,p_material_detail_rec         => l_material_detail_rec
                         ,p_qty                         => p_qty
                         ,p_qty_type                    => p_qty_type
                         ,p_trans_date                  => p_trans_date
                         ,x_exception_material_tbl      => l_exception_material_tbl);

      IF p_ignore_exception = fnd_api.g_true AND x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := fnd_api.g_ret_sts_success;
      ELSIF x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_exception_material_tbl := l_exception_material_tbl;
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_incr_backflush;
      END IF;

      /* Invoke save_batch */
      gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN error_incr_backflush THEN
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,p_data         => x_message_list);
      WHEN OTHERS THEN
          gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END incremental_backflush;

/*************************************************************************/
   PROCEDURE create_material_txn (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,p_org_code              IN              VARCHAR2 := NULL
     ,p_mmti_rec              IN              mtl_transactions_interface%ROWTYPE
     ,p_mmli_tbl              IN              gme_common_pvt.mtl_trans_lots_inter_tbl
     ,p_batch_no              IN              VARCHAR2 := NULL
     ,p_line_no               IN              NUMBER := NULL
     ,p_line_type             IN              NUMBER := NULL
     ,p_create_lot            IN              VARCHAR2 := NULL
     ,p_generate_lot          IN              VARCHAR2 := NULL
     ,p_generate_parent_lot   IN              VARCHAR2 := NULL
     ,x_mmt_rec               OUT NOCOPY      mtl_material_transactions%ROWTYPE
     ,x_mmln_tbl              OUT NOCOPY      gme_common_pvt.mtl_trans_lots_num_tbl)
   IS
      CURSOR cur_get_item_rec (v_item_id NUMBER, v_org_id NUMBER)
      IS
         SELECT *
           FROM mtl_system_items_b
          WHERE inventory_item_id = v_item_id AND organization_id = v_org_id;

      CURSOR cur_get_trans (v_header_id IN NUMBER)
      IS
         SELECT *
           FROM mtl_material_transactions
          WHERE transaction_set_id = v_header_id;

      l_api_name   CONSTANT VARCHAR2 (30)            := 'CREATE_MATERIAL_TXN';
      l_mmti_rec            mtl_transactions_interface%ROWTYPE;
      l_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
      l_mat_dtl_rec         gme_material_details%ROWTYPE;
      l_mat_dtl_rec_out     gme_material_details%ROWTYPE;
      l_batch_header_rec    gme_batch_header%ROWTYPE;
      l_item_rec            mtl_system_items_b%ROWTYPE;
      l_lot_rec             mtl_lot_numbers%ROWTYPE;
      l_parent_gen_lot      VARCHAR2 (2000)                      DEFAULT NULL;
      l_gen_lot             VARCHAR2 (80)                        DEFAULT NULL;
      l_msg_count           NUMBER;
      l_row_id              ROWID;
      l_api_version         NUMBER;
      l_source              NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_msg_index           NUMBER (5);
      l_txn_count           NUMBER;
      l_header_id           NUMBER;
      l_return_status       VARCHAR2 (1);
      l_trans_date          DATE ;
      x_lot_rec             mtl_lot_numbers%ROWTYPE;

      create_txn_fail       EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('CreateTxn');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT create_material_txn;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'create_material_txn'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      l_mmti_rec := p_mmti_rec;
      l_mmli_tbl := p_mmli_tbl;

      IF (l_mmti_rec.organization_id IS NULL AND p_org_code IS NULL) THEN
         fnd_message.set_name ('INV', 'INV_ORG_REQUIRED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

     /* gme_common_pvt.g_error_count := 0;
      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_mmti_rec.organization_id
                              ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_mmti_rec.organization_id := gme_common_pvt.g_organization_id;
      END IF;*/
      gme_common_pvt.set_timestamp;
      /* Bug 5358129 added code so line type line no combo will also retrieve material */
      l_mat_dtl_rec.material_detail_id := l_mmti_rec.trx_source_line_id;
      l_mat_dtl_rec.line_no            := p_line_no;
      l_mat_dtl_rec.line_type          := p_line_type;
      gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> l_mat_dtl_rec
                          ,p_org_code                 	=> p_org_code
                          ,p_batch_no                 	=> p_batch_no
                          ,p_batch_type               	=> gme_common_pvt.g_doc_type_batch
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_mat_dtl_rec_out
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         ELSE
            l_mat_dtl_rec := l_mat_dtl_rec_out;
            l_mmti_rec.trx_source_line_id := l_mat_dtl_rec.material_detail_id;
            l_mmti_rec.transaction_source_id := l_batch_header_rec.batch_id;
         END IF;

      OPEN cur_get_item_rec (l_mmti_rec.inventory_item_id, l_mmti_rec.organization_id);
      FETCH cur_get_item_rec INTO l_item_rec;
      IF cur_get_item_rec%NOTFOUND THEN
         CLOSE cur_get_item_rec;
         gme_common_pvt.log_message ('PM_INVALID_ITEM');
         IF (g_debug = gme_debug.g_log_statement) THEN
            gme_debug.put_line('Item cursor fetch no record in mtl_system_items_b: ');
            gme_debug.put_line('inventory_item_id = '|| TO_CHAR (l_mmti_rec.inventory_item_id) );
            gme_debug.put_line('organization_id = '|| TO_CHAR (l_mmti_rec.organization_id) );
         END IF;
         RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE cur_get_item_rec;

      /*Bug#5394232 Begin
        if we don't pass any date to this procedure then we have to default the trans date*/
      IF l_mmti_rec.transaction_date IS NULL THEN
        gme_common_pvt.fetch_trans_date(
	     p_material_detail_id => l_mat_dtl_rec.material_detail_id
            ,p_invoke_mode        => 'T'
            ,x_trans_date         => l_trans_date
            ,x_return_status      => l_return_status );

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
       END IF;
       --initializing the transaction date according to default rules
       l_mmti_rec.transaction_date := l_trans_date;
      ELSE
       /* transaction date can't be in future and should not be less than actual start date of the batch*/
       IF l_mmti_rec.transaction_date < l_batch_header_rec.actual_start_date OR
          l_mmti_rec.transaction_date > SYSDATE THEN
	  gme_common_pvt.log_message('GME_NOT_VALID_TRANS_DATE');
	  RAISE fnd_api.g_exc_error;
       END IF;
      END IF;
      --Bug#5394232 End

      -- code for lot creation
      IF l_mat_dtl_rec.line_type IN (1, 2) THEN
         -- code for lot creation
         IF l_item_rec.lot_control_code = 2 THEN                -- lot control
            IF p_generate_lot = fnd_api.g_true AND
               p_create_lot = fnd_api.g_false THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            IF p_generate_parent_lot = fnd_api.g_true THEN
               l_parent_gen_lot :=
                  inv_lot_api_pub.auto_gen_lot
                        (p_org_id                          => l_mmti_rec.organization_id
                        ,p_inventory_item_id               => l_mmti_rec.inventory_item_id
                        ,p_lot_generation                  => NULL
                        ,p_lot_uniqueness                  => NULL
                        ,p_lot_prefix                      => NULL
                        ,p_zero_pad                        => NULL
                        ,p_lot_length                      => NULL
                        ,p_transaction_date                => NULL
                        ,p_revision                        => NULL
                        ,p_subinventory_code               => NULL
                        ,p_locator_id                      => NULL
                        ,p_transaction_type_id             => NULL
                        ,p_transaction_action_id           => NULL
                        ,p_transaction_source_type_id      => NULL
                        ,p_lot_number                      => NULL
                        ,p_api_version                     => 1.0
                        ,p_init_msg_list                   => fnd_api.g_false
                        ,p_commit                          => fnd_api.g_false
                        ,p_validation_level                => NULL
                        ,p_parent_lot_number               => NULL
                        ,x_return_status                   => l_return_status
                        ,x_msg_count                       => l_msg_count
                        ,x_msg_data                        => l_msg_data);

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
               END IF;

               IF (g_debug = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (   'lot_gen'
                                      || ':'
                                      || 'l_parent_gen_lot '
                                      || l_return_status);
               END IF;
            END IF;                                   -- p_generate_parent_lot

            FOR i IN 1 .. l_mmli_tbl.COUNT LOOP
               IF     p_create_lot = fnd_api.g_true
                  AND l_mmli_tbl (i).lot_number IS NULL THEN
                  IF p_generate_lot = fnd_api.g_true THEN
                     l_gen_lot :=
                        inv_lot_api_pub.auto_gen_lot
                           (p_org_id                          => l_mmti_rec.organization_id
                           ,p_inventory_item_id               => l_mmti_rec.inventory_item_id
                           ,p_lot_generation                  => NULL
                           ,p_lot_uniqueness                  => NULL
                           ,p_lot_prefix                      => NULL
                           ,p_zero_pad                        => NULL
                           ,p_lot_length                      => NULL
                           ,p_transaction_date                => NULL
                           ,p_revision                        => NULL
                           ,p_subinventory_code               => NULL
                           ,p_locator_id                      => NULL
                           ,p_transaction_type_id             => NULL
                           ,p_transaction_action_id           => NULL
                           ,p_transaction_source_type_id      => NULL
                           ,p_lot_number                      => NULL
                           ,p_api_version                     => 1.0
                           ,p_init_msg_list                   => fnd_api.g_false
                           ,p_commit                          => fnd_api.g_false
                           ,p_validation_level                => NULL
                           ,p_parent_lot_number               => l_parent_gen_lot
                           ,x_return_status                   => l_return_status
                           ,x_msg_count                       => l_msg_count
                           ,x_msg_data                        => l_msg_data);

                     IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE fnd_api.g_exc_error;
                     END IF;

                     IF (g_debug = gme_debug.g_log_statement) THEN
                        gme_debug.put_line (   'lot_gen'
                                            || ':'
                                            || 'l_parent_gen_lot '
                                            || l_return_status);
                     END IF;
                  END IF;                                    -- p_generate_lot

                  l_lot_rec.parent_lot_number := l_parent_gen_lot;
                  l_lot_rec.organization_id := l_mmti_rec.organization_id;
                  l_lot_rec.inventory_item_id := l_mmti_rec.inventory_item_id;
                  l_lot_rec.lot_number := l_gen_lot;
                  -- Bug 6941158 - Initialize origination type to production
                  l_lot_rec.origination_type := 1;

                  inv_lot_api_pub.create_inv_lot
                            (x_return_status         => l_return_status
                            ,x_msg_count             => l_msg_count
                            ,x_msg_data              => l_msg_data
                            ,x_row_id                => l_row_id
                            ,x_lot_rec               => x_lot_rec
                            ,p_lot_rec               => l_lot_rec
                            ,p_source                => l_source
                            ,p_api_version           => l_api_version
                            ,p_init_msg_list         => fnd_api.g_true
                            ,p_commit                => fnd_api.g_false
                            ,p_validation_level      => fnd_api.g_valid_level_full
                            ,p_origin_txn_id         => 1);

                  IF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;

                  l_mmli_tbl (i).lot_number := x_lot_rec.lot_number;
               END IF;                                         -- p_create_lot
            END LOOP;
         END IF;                                            -- for lot_control
      END IF;                                                 -- for line_type

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;
      /* Bug 5554841 Migration will call this with existing header ID*/
      --gme_common_pvt.g_transaction_header_id := NULL;
      gme_transactions_pvt.create_material_txn
                                           (p_mmti_rec           => l_mmti_rec
                                           ,p_mmli_tbl           => l_mmli_tbl
                                           ,x_return_status      => l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_success THEN
         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'before save batch'
                                || gme_common_pvt.g_transaction_header_id);
         END IF;
         l_header_id := gme_common_pvt.g_transaction_header_id;
         gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'return from save batch  with'
                                || x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         RAISE create_txn_fail;
      END IF;
      IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'l_header_id'
                                || l_header_id);
         END IF;
      -- get all the transactions from the mmt
      OPEN cur_get_trans (l_header_id);

      FETCH cur_get_trans
       INTO x_mmt_rec;

      CLOSE cur_get_trans;

      -- for lots with this transaction
      gme_transactions_pvt.get_lot_trans
                                (p_transaction_id      => x_mmt_rec.transaction_id
                                ,x_mmln_tbl            => x_mmln_tbl
                                ,x_return_status       => x_return_status);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
     WHEN create_txn_fail  THEN
        ROLLBACK TO SAVEPOINT create_material_txn;
	     gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
        /* Bug 5554841 have to set x_return_status*/
        x_return_status := l_return_status;
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT create_material_txn;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_material_txn;
         gme_when_others (	p_api_name              => l_api_name
     		            		,x_message_count        => x_message_count
     				            ,x_message_list         => x_message_list
     				            ,x_return_status   	=> x_return_status );
   END create_material_txn;

  /*************************************************************************/
   PROCEDURE update_material_txn (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,p_transaction_id        IN              NUMBER
     ,p_mmti_rec              IN              mtl_transactions_interface%ROWTYPE
     ,p_mmli_tbl              IN              gme_common_pvt.mtl_trans_lots_inter_tbl
     ,p_create_lot            IN              VARCHAR2 := NULL
     ,p_generate_lot          IN              VARCHAR2 := NULL
     ,p_generate_parent_lot   IN              VARCHAR2 := NULL
     ,x_mmt_rec               OUT NOCOPY      mtl_material_transactions%ROWTYPE
     ,x_mmln_tbl              OUT NOCOPY      gme_common_pvt.mtl_trans_lots_num_tbl)
   IS
      CURSOR cur_get_item_rec (v_item_id NUMBER, v_org_id NUMBER)
      IS
         SELECT *
           FROM mtl_system_items_b
          WHERE inventory_item_id = v_item_id AND organization_id = v_org_id;

      CURSOR cur_get_trans (v_header_id IN NUMBER)
      IS
         SELECT *
           FROM mtl_material_transactions
          WHERE transaction_set_id = v_header_id;

      CURSOR cur_trans_org (v_transaction_id IN NUMBER)
      IS
         SELECT organization_id, transaction_source_id, trx_source_line_id, transaction_type_id
           FROM mtl_material_transactions
          WHERE transaction_id = v_transaction_id;

      l_api_name   CONSTANT VARCHAR2 (30)            := 'UPDATE_MATERIAL_TXN';
      l_transaction_id      NUMBER;
      l_mmt_rec             mtl_material_transactions%ROWTYPE;
      l_mmln_tbl            gme_common_pvt.mtl_trans_lots_num_tbl;
      l_mmti_rec            mtl_transactions_interface%ROWTYPE;
      l_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
      l_mat_dtl_rec         gme_material_details%ROWTYPE;
      l_item_rec            mtl_system_items_b%ROWTYPE;
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_msg_index           NUMBER (5);
      l_txn_count           NUMBER;
      l_orgn_id             NUMBER;
      l_lot_rec             mtl_lot_numbers%ROWTYPE;
      l_return_status       VARCHAR2 (1);
      l_parent_gen_lot      VARCHAR2 (2000)                      DEFAULT NULL;
      l_gen_lot             VARCHAR2 (80)                        DEFAULT NULL;
      l_row_id              ROWID;
      l_api_version         NUMBER;
      l_source              NUMBER;
      l_header_id           NUMBER;
      x_lot_rec             mtl_lot_numbers%ROWTYPE;
      l_batch_id            NUMBER;
      l_material_detail_id  NUMBER;
      l_txn_type_id         NUMBER;
      update_txn_fail       EXCEPTION;
      update_txn_mismatch   EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('UpdateTxn');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the savepoint */
      SAVEPOINT update_transaction;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'update_material_txn'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_transaction_id IS NULL) THEN
         gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                    ,'FIELD_NAME'
                                    ,'p_transaction_id');
         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN cur_trans_org (p_transaction_id);
      FETCH cur_trans_org INTO l_orgn_id, l_batch_id, l_material_detail_id, l_txn_type_id;
      CLOSE cur_trans_org;

      l_mmti_rec := p_mmti_rec;
      l_mmli_tbl := p_mmli_tbl;
      gme_common_pvt.g_error_count := 0;
      gme_common_pvt.g_setup_done := gme_common_pvt.setup(p_org_id => l_orgn_id);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_orgn_id := gme_common_pvt.g_organization_id;
      END IF;

      gme_common_pvt.set_timestamp;
      l_mat_dtl_rec.material_detail_id := l_mmti_rec.trx_source_line_id;

      IF NOT gme_material_details_dbl.fetch_row
                                          (p_material_detail      => l_mat_dtl_rec
                                          ,x_material_detail      => l_mat_dtl_rec) THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      /* Added for bug 5597385 */
      IF (l_mat_dtl_rec.organization_id <> l_orgn_id
          OR l_mat_dtl_rec.batch_id <> l_batch_id
          OR l_mat_dtl_rec.material_detail_id <> l_material_detail_id
          OR l_mmti_rec.transaction_type_id <> l_txn_type_id) THEN
        RAISE update_txn_mismatch;
      END IF;
      -- code for lot creation
      IF l_mat_dtl_rec.line_type IN (1, 2) THEN
         OPEN cur_get_item_rec (l_mmti_rec.inventory_item_id
                               ,l_mmti_rec.organization_id);

         FETCH cur_get_item_rec INTO l_item_rec;
         IF cur_get_item_rec%NOTFOUND THEN
            CLOSE cur_get_item_rec;
            gme_common_pvt.log_message ('PM_INVALID_ITEM');

            IF (g_debug = gme_debug.g_log_statement) THEN
               gme_debug.put_line
                       ('Item cursor fetch no record in mtl_system_items_b: ');
               gme_debug.put_line (   'inventory_item_id = '
                                   || TO_CHAR (l_mmti_rec.inventory_item_id) );
               gme_debug.put_line (   'organization_id = '
                                   || TO_CHAR (l_mmti_rec.organization_id) );
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;
         CLOSE cur_get_item_rec;

         -- code for lot creation
         IF l_item_rec.lot_control_code = 2 THEN                -- lot control
            IF     p_generate_lot = fnd_api.g_true
               AND p_create_lot = fnd_api.g_false THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            IF p_generate_parent_lot = fnd_api.g_true THEN
               l_parent_gen_lot :=
                  inv_lot_api_pub.auto_gen_lot
                        (p_org_id                          => l_mmti_rec.organization_id
                        ,p_inventory_item_id               => l_mmti_rec.inventory_item_id
                        ,p_lot_generation                  => NULL
                        ,p_lot_uniqueness                  => NULL
                        ,p_lot_prefix                      => NULL
                        ,p_zero_pad                        => NULL
                        ,p_lot_length                      => NULL
                        ,p_transaction_date                => NULL
                        ,p_revision                        => NULL
                        ,p_subinventory_code               => NULL
                        ,p_locator_id                      => NULL
                        ,p_transaction_type_id             => NULL
                        ,p_transaction_action_id           => NULL
                        ,p_transaction_source_type_id      => NULL
                        ,p_lot_number                      => NULL
                        ,p_api_version                     => 1.0
                        ,p_init_msg_list                   => fnd_api.g_false
                        ,p_commit                          => fnd_api.g_false
                        ,p_validation_level                => NULL
                        ,p_parent_lot_number               => NULL
                        ,x_return_status                   => l_return_status
                        ,x_msg_count                       => l_msg_count
                        ,x_msg_data                        => l_msg_data);

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
               END IF;

               IF (g_debug = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (   'lot_gen'
                                      || ':'
                                      || 'l_parent_gen_lot '
                                      || l_return_status);
               END IF;
            END IF;                                   -- p_generate_parent_lot

            FOR i IN 1 .. l_mmli_tbl.COUNT LOOP
               IF     p_create_lot = fnd_api.g_true
                  AND l_mmli_tbl (i).lot_number IS NULL THEN
                  IF p_generate_lot = fnd_api.g_true THEN
                     l_gen_lot :=
                        inv_lot_api_pub.auto_gen_lot
                           (p_org_id                          => l_mmti_rec.organization_id
                           ,p_inventory_item_id               => l_mmti_rec.inventory_item_id
                           ,p_lot_generation                  => NULL
                           ,p_lot_uniqueness                  => NULL
                           ,p_lot_prefix                      => NULL
                           ,p_zero_pad                        => NULL
                           ,p_lot_length                      => NULL
                           ,p_transaction_date                => NULL
                           ,p_revision                        => NULL
                           ,p_subinventory_code               => NULL
                           ,p_locator_id                      => NULL
                           ,p_transaction_type_id             => NULL
                           ,p_transaction_action_id           => NULL
                           ,p_transaction_source_type_id      => NULL
                           ,p_lot_number                      => NULL
                           ,p_api_version                     => 1.0
                           ,p_init_msg_list                   => fnd_api.g_false
                           ,p_commit                          => fnd_api.g_false
                           ,p_validation_level                => NULL
                           ,p_parent_lot_number               => l_parent_gen_lot
                           ,x_return_status                   => l_return_status
                           ,x_msg_count                       => l_msg_count
                           ,x_msg_data                        => l_msg_data);

                     IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE fnd_api.g_exc_error;
                     END IF;

                     IF (g_debug = gme_debug.g_log_statement) THEN
                        gme_debug.put_line (   'lot_gen'
                                            || ':'
                                            || 'l_parent_gen_lot '
                                            || l_return_status);
                     END IF;
                  END IF;                                    -- p_generate_lot

                  l_lot_rec.parent_lot_number := l_parent_gen_lot;
                  l_lot_rec.organization_id := l_mmti_rec.organization_id;
                  l_lot_rec.inventory_item_id := l_mmti_rec.inventory_item_id;
                  l_lot_rec.lot_number := l_gen_lot;
                  -- Bug 6941158 - Initialize origination type to production
                  l_lot_rec.origination_type := 1;

                  inv_lot_api_pub.create_inv_lot
                            (x_return_status         => l_return_status
                            ,x_msg_count             => l_msg_count
                            ,x_msg_data              => l_msg_data
                            ,x_row_id                => l_row_id
                            ,x_lot_rec               => x_lot_rec
                            ,p_lot_rec               => l_lot_rec
                            ,p_source                => l_source
                            ,p_api_version           => l_api_version
                            ,p_init_msg_list         => fnd_api.g_true
                            ,p_commit                => fnd_api.g_false
                            ,p_validation_level      => fnd_api.g_valid_level_full
                            ,p_origin_txn_id         => 1);

                  IF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;

                  l_mmli_tbl (i).lot_number := x_lot_rec.lot_number;
               END IF;                                         -- p_create_lot
            END LOOP;
         END IF;                                            -- for lot_control
      END IF;                                                 -- for line_type

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;
      gme_common_pvt.g_transaction_header_id := NULL;
      gme_transactions_pvt.update_material_txn
                                        (p_transaction_id      => p_transaction_id
                                        ,p_mmti_rec            => l_mmti_rec
                                        ,p_mmli_tbl            => l_mmli_tbl
                                        ,x_return_status       => l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_success THEN
         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'before save batch'
                                || gme_common_pvt.g_transaction_header_id);
         END IF;
         l_header_id:=  gme_common_pvt.g_transaction_header_id;
         gme_api_pub.save_batch
                             (p_header_id          => gme_common_pvt.get_txn_header_id
                             ,p_table              => 1
                             ,p_commit             => p_commit
                             ,x_return_status      => x_return_status);

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'return from save batch  with'
                                || x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         RAISE update_txn_fail;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   'l_header_id'
                                || l_header_id);
         END IF;
      -- get all the transactions from the mmt
      OPEN cur_get_trans (l_header_id);

      FETCH cur_get_trans
       INTO x_mmt_rec;

      CLOSE cur_get_trans;

      -- for lots with this transaction
      gme_transactions_pvt.get_lot_trans
                                (p_transaction_id      => x_mmt_rec.transaction_id
                                ,x_mmln_tbl            => x_mmln_tbl
                                ,x_return_status       => x_return_status);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN update_txn_mismatch THEN
        ROLLBACK TO SAVEPOINT update_transaction;
        gme_common_pvt.log_message('GME_TXN_UPDATE_MISMATCH');
        x_return_status := fnd_api.g_ret_sts_error;
        gme_common_pvt.count_and_get (x_count        => x_message_count
                                     ,p_encoded      => fnd_api.g_false
                                     ,x_data         => x_message_list);
      WHEN update_txn_fail THEN
         ROLLBACK TO SAVEPOINT update_transaction;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT update_transaction;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
          gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END update_material_txn;

 /*************************************************************************/
   PROCEDURE delete_material_txn (
      p_api_version        IN              NUMBER := 2.0
     ,p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_commit             IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_transaction_id     IN              NUMBER)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)   := 'DELETE_MATERIAL_TXN';
      l_transaction_id      NUMBER;
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_msg_index           NUMBER (5);
      l_txn_count           NUMBER;
      l_return_status       VARCHAR2 (1)    := fnd_api.g_ret_sts_success;
      l_orgn_id             NUMBER;

      setup_failure         EXCEPTION;
      error_condition       EXCEPTION;


      delete_txn_fail       EXCEPTION;
      batch_save_failed     EXCEPTION;

      CURSOR cur_trans_org (v_transaction_id IN NUMBER)
      IS
         SELECT organization_id
           FROM mtl_material_transactions
          WHERE transaction_id = v_transaction_id;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('DeleteTxn');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the savepoint */
      SAVEPOINT delete_transaction;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'delete_material_txn'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_transaction_id IS NULL) THEN
         gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                    ,'FIELD_NAME'
                                    ,'p_transaction_id');
         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN cur_trans_org (p_transaction_id);
      FETCH cur_trans_org INTO l_orgn_id;

      CLOSE cur_trans_org;

      gme_common_pvt.g_error_count := 0;
      gme_common_pvt.g_setup_done :=
                                  gme_common_pvt.setup (p_org_id      => l_orgn_id);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_orgn_id := gme_common_pvt.g_organization_id;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_common_pvt.g_move_to_temp := fnd_api.g_false;
      gme_common_pvt.g_transaction_header_id := NULL;
      l_transaction_id := p_transaction_id;
      gme_transactions_pvt.delete_material_txn
                                        (p_transaction_id      => l_transaction_id
                                        ,x_return_status       => x_return_status);

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF (p_commit = fnd_api.g_true) THEN
            gme_api_pub.save_batch
                            (p_header_id          => gme_common_pvt.get_txn_header_id
                            ,p_table              => 1
                            ,p_commit             => p_commit
                            ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE delete_txn_fail;
      END IF;

     IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN delete_txn_fail THEN
         ROLLBACK TO SAVEPOINT delete_transaction;
	 gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT delete_transaction;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
          gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END delete_material_txn;
    /*================================================================================
     Procedure
       reroute_batch
     Description
       This procedure reroutes batch (typically change the route associated with the batch).
     Parameters
       p_batch_header_rec (R)    The batch header row to identify the batch
                                 Following columns are used from this row.
                                 batch_id  (R)
       p_org_code                (R) if batch_no is specified instead of batch_id
                                 on batch header row
       p_validity_rule_id (R)    Recipe validity rule id for the new recipe.
       x_batch_header_rec        The batch header that is returned, with all the data
       x_return_status           outcome of the API call
                                 S - Success
                                 E - Error
                                 U - Unexpected Error
                                 C - No continous periods found
   ================================================================================*/
   PROCEDURE reroute_batch (
      p_api_version           IN              NUMBER := 2.0
     ,p_validation_level      IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list         IN              VARCHAR2 DEFAULT fnd_api.g_false
     ,p_commit                IN              VARCHAR2 DEFAULT fnd_api.g_false
     ,p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_validity_rule_id      IN              NUMBER
     ,p_org_code              IN              VARCHAR2
     ,p_use_workday_cal       IN              VARCHAR2 DEFAULT fnd_api.g_false
     ,p_contiguity_override   IN              VARCHAR2 DEFAULT fnd_api.g_false
     ,x_message_count         OUT NOCOPY      NUMBER
     ,x_message_list          OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_batch_header_rec      OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30)              := 'REROUTE_BATCH';
      l_batch_header_rec     gme_batch_header%ROWTYPE;

      reroute_batch_failed   EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('RerouteBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
       /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT reroute_batch_pub;

      IF (fnd_api.to_boolean (p_init_msg_list) ) THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,l_api_name
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
	 RAISE fnd_api.g_exc_error;
      END IF;

      --FPBug#4585491 Begin
      /* Check for p_use_workday_cal */
      IF (p_use_workday_cal NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_use_workday_cal');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Check for p_contiguity_override */
      IF (p_contiguity_override NOT IN (fnd_api.g_true, fnd_api.g_false) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_contiguity_override');
         RAISE fnd_api.g_exc_error;
      END IF;
      --FPBug#4585491 End

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Get the Batch header */
      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

       gme_reroute_batch_pvt.validate_validity_id_from_pub
                                    (p_batch_header_rec      => l_batch_header_rec
                                    ,p_validity_rule_id      => p_validity_rule_id
                                    ,x_return_status         => x_return_status);

      IF (x_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      gme_api_main.reroute_batch
                              (p_validation_level         => p_validation_level
                              ,p_init_msg_list            => fnd_api.g_false
                              ,p_batch_header_rec         => l_batch_header_rec
                              ,p_validity_rule_id         => p_validity_rule_id
                              ,p_use_workday_cal          => p_use_workday_cal
                              ,p_contiguity_override      => p_contiguity_override
                              ,x_message_count            => x_message_count
                              ,x_message_list             => x_message_list
                              ,x_return_status            => x_return_status
                              ,x_batch_header_rec         => x_batch_header_rec);

      IF (x_return_status = 'C') THEN
         RAISE fnd_api.g_exc_error; --message will be set on stack in pvt layer itself
      ELSIF (x_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE reroute_batch_failed;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      gme_api_pub.save_batch
                                (p_header_id          => NULL
                                ,p_table              => gme_common_pvt.g_interface_table
                                ,p_commit             => p_commit
                                ,x_return_status      => x_return_status);

      IF (x_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (fnd_api.to_boolean (p_commit) ) THEN
         COMMIT WORK;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN reroute_batch_failed THEN
         ROLLBACK TO SAVEPOINT reroute_batch_pub;
	 x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT reroute_batch_pub;
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO SAVEPOINT reroute_batch_pub;
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (g_debug > 0) THEN gme_debug.put_line (   g_pkg_name || '.' ||
         l_api_name || ':' || 'UNEXPECTED:' || SQLERRM);
         END IF;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT reroute_batch_pub;
         x_batch_header_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
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
       p_org_code                The name of organization to which this batch belongs
       x_batch_header            The batch header that is returned, with all the data
       x_return_status           outcome of the API call
                                 S - Success
                                 E - Error
                                 U - Unexpected Error
   ================================================================================*/
   PROCEDURE cancel_batch (
      p_api_version        IN              NUMBER := 2.0
     ,p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_commit             IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_org_code           IN              VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name    CONSTANT VARCHAR2 (30)              := 'CANCEL_BATCH';
      l_batch_header_rec     gme_batch_header%ROWTYPE;

      batch_cancel_failure   EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('CancelBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT cancel_batch_pub;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'cancel_batch'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      --fetch the batch
      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;


      IF (l_batch_header_rec.batch_type <> gme_common_pvt.g_doc_type_batch) THEN
         gme_common_pvt.log_message ('GME_INVALID_BATCH_TYPE');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.g_error_count := 0;

      /* Check for batch status */
      IF l_batch_header_rec.batch_status <> gme_common_pvt.g_batch_pending THEN
         gme_common_pvt.log_message ('GME_API_INVALID_BATCH_CANCEL');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ':'
                             || 'calling main cancel');
      END IF;

      gme_api_main.cancel_batch (p_validation_level      => p_validation_level
                                ,p_init_msg_list         => fnd_api.g_false
                                ,x_message_count         => x_message_count
                                ,x_message_list          => x_message_list
                                ,x_return_status         => x_return_status
                                ,p_batch_header_rec      => l_batch_header_rec
                                ,x_batch_header_rec      => x_batch_header_rec);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ':' ||
         'return_status from main'|| x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch
                                (p_header_id          => NULL
                                ,p_table              => gme_common_pvt.g_interface_table
                                ,p_commit             => p_commit
                                ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE batch_cancel_failure;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN batch_cancel_failure THEN
         ROLLBACK TO SAVEPOINT cancel_batch_pub;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT cancel_batch_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT cancel_batch_pub;
         x_batch_header_rec := NULL;
	      gme_when_others (	p_api_name              => l_api_name
     				           ,x_message_count        => x_message_count
     				           ,x_message_list         => x_message_list
     				           ,x_return_status   	=> x_return_status );
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
      p_org_code                The name of organization to which this batch belongs
      p_reason_name             Reason to terminate the batch
      x_batch_header            The batch header that is returned, with all the data
      x_return_status           outcome of the API call
                                S - Success
                                E - Error
                                U - Unexpected Error
  ================================================================================*/
   PROCEDURE terminate_batch (
      p_api_version        IN              NUMBER := 2.0
     ,p_validation_level   IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_commit             IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count      OUT NOCOPY      NUMBER
     ,x_message_list       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_org_code           IN              VARCHAR2
     ,p_reason_name        IN              VARCHAR2
     ,p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      CURSOR cur_val_reason_id (v_reason_id NUMBER)
      IS
         SELECT 1
           FROM mtl_transaction_reasons
          WHERE NVL (disable_date, SYSDATE + 1) > SYSDATE
            AND reason_id = v_reason_id;

      CURSOR cur_val_reason_name (v_reason_name VARCHAR)
      IS
         SELECT reason_id
           FROM mtl_transaction_reasons
          WHERE NVL (disable_date, SYSDATE + 1) > SYSDATE
            AND reason_name = v_reason_name;

      i                         NUMBER;
      l_api_name       CONSTANT VARCHAR2 (30)             := 'TERMINATE_BATCH';
      l_batch_header_rec        gme_batch_header%ROWTYPE;
      l_reason_valid            NUMBER;

      batch_terminate_failure   EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('TerminateBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT terminate_batch;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'terminate_batch'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;
--Bug#5281136 Fetching the batch before checking for the reason_id or reason name.
      --fetch the batch
     gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      /* Check for reason id */
      IF p_batch_header_rec.terminate_reason_id IS NOT NULL THEN
         OPEN cur_val_reason_id (p_batch_header_rec.terminate_reason_id);

         FETCH cur_val_reason_id
          INTO l_reason_valid;

         CLOSE cur_val_reason_id;

         IF l_reason_valid = 1 THEN
            l_batch_header_rec.terminate_reason_id :=
                                       p_batch_header_rec.terminate_reason_id;
         ELSE
            gme_common_pvt.log_message(p_product_code => 'INV'
                                       ,p_message_code => 'INV_LOTC_REASONID_INVALID');
            RAISE FND_API.g_exc_error;
         END IF;
      ELSIF p_reason_name IS NOT NULL THEN
         i := 0;
         FOR get_rec IN cur_val_reason_name (p_reason_name) LOOP
            i := i + 1;
            l_batch_header_rec.terminate_reason_id := get_rec.reason_id;
         END LOOP;

         IF i > 1 THEN
            gme_common_pvt.log_message('GME_REASON_NAME_NOT_UNIQUE');
            RAISE FND_API.g_exc_error;
         ELSIF i = 0 THEN
            gme_common_pvt.log_message('GME_INVALID_REASON_NAME');
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;


      IF (l_batch_header_rec.batch_type <> gme_common_pvt.g_doc_type_batch) THEN
         gme_common_pvt.log_message ('GME_INVALID_BATCH_TYPE');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.g_error_count := 0;

      /* Check for batch status */
      IF l_batch_header_rec.batch_status <> gme_common_pvt.g_batch_wip THEN
         gme_common_pvt.log_message ('GME_INVALID_BSTAT_TERM');

         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ':'
                                || 'INVALID_BATCH_STATUS');
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      /* check for dates*/
      /* Completion date cannot be greater than start date or in future */
      IF p_batch_header_rec.actual_cmplt_date IS NULL THEN
         l_batch_header_rec.actual_cmplt_date := SYSDATE;
      ELSIF (p_batch_header_rec.actual_cmplt_date <
                                          l_batch_header_rec.actual_start_date) THEN
         gme_common_pvt.log_message ('GME_INVALID_DATE_RANGE' ,'DATE1'
         ,'Termination date' ,'DATE2','Start date');
         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      ELSIF (p_batch_header_rec.actual_cmplt_date > SYSDATE) THEN
        gme_common_pvt.log_message(p_product_code => 'GMA'
                                       ,p_message_code => 'SY_NOFUTUREDATE');
         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      ELSE
         l_batch_header_rec.actual_cmplt_date :=
                                         p_batch_header_rec.actual_cmplt_date;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('calling main terminate');
      END IF;

      gme_api_main.terminate_batch (p_validation_level      => p_validation_level
                                   ,p_init_msg_list         => fnd_api.g_false
                                   ,x_message_count         => x_message_count
                                   ,x_message_list          => x_message_list
                                   ,x_return_status         => x_return_status
                                   ,p_batch_header_rec      => l_batch_header_rec
                                   ,x_batch_header_rec      => x_batch_header_rec);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'return_status from main'
                             || x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF p_commit = fnd_api.g_true THEN
            gme_api_pub.save_batch
                                (p_header_id          => NULL
                                ,p_table              => gme_common_pvt.g_interface_table
                                ,p_commit             => p_commit
                                ,x_return_status      => x_return_status);

            IF x_return_status = fnd_api.g_ret_sts_success THEN
               COMMIT;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         RAISE batch_terminate_failure;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN batch_terminate_failure THEN
         ROLLBACK TO SAVEPOINT terminate_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT terminate_batch;
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT terminate_batch;
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'When others exception:'
                                || SQLERRM);
         END IF;
         x_batch_header_rec := NULL;
	      gme_when_others (	p_api_name              => l_api_name
     		              	  ,x_message_count        => x_message_count
     				           ,x_message_list         => x_message_list
     				           ,x_return_status   	=> x_return_status );
   END terminate_batch;

/*************************************************************************/
   PROCEDURE convert_dtl_reservation (
      p_api_version       IN              NUMBER := 2.0
     ,p_validation_level  IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list     IN              VARCHAR2 := fnd_api.g_false
     ,p_commit            IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count     OUT NOCOPY      NUMBER
     ,x_message_list      OUT NOCOPY      VARCHAR2
     ,x_return_status     OUT NOCOPY      VARCHAR2
     ,p_reservation_rec   IN              mtl_reservations%ROWTYPE
     ,p_qty_convert       IN              NUMBER := NULL)
   IS
      l_api_name        CONSTANT VARCHAR2 (30)   := 'CONVERT_DTL_RESERVATION';
      l_material_details_rec     gme_material_details%ROWTYPE;
      l_reservation_rec          mtl_reservations%ROWTYPE;
      l_valid_status             VARCHAR2(1);

      detail_reservation_error   EXCEPTION;
      negative_qty_error   EXCEPTION;
      CURSOR cur_fetch_reservation (v_reservation_id NUMBER)
      IS
         SELECT *
           FROM mtl_reservations
          WHERE reservation_id = v_reservation_id;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('ConvertDtlReservation');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the savepoint */
      SAVEPOINT convert_dtl_reservation;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'convert_dtl_reservation'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ' Input
         reservation_id is  '|| p_reservation_rec.reservation_id);
      END IF;

      /* Verify that the reservation exists */
      OPEN cur_fetch_reservation (p_reservation_rec.reservation_id);

      FETCH cur_fetch_reservation
       INTO l_reservation_rec;

      IF cur_fetch_reservation%NOTFOUND THEN
         CLOSE cur_fetch_reservation;

         gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                    ,'TABLE_NAME'
                                    ,'MTL_RESERVATIONS');

         IF g_debug <= gme_debug.g_log_statement THEN gme_debug.put_line (
         	g_pkg_name || '.' || l_api_name || ' Retrieval failure against
         	mtl_reservations using id of ' || p_reservation_rec.reservation_id);
         END IF;

         RAISE  fnd_api.g_exc_error;
      END IF;
      CLOSE cur_fetch_reservation;


      -- Bug 6778968 - Do not allow negative quantities.
      IF (NVL(p_qty_convert, 0) < 0) THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (g_pkg_name || '.' || l_api_name || ' Negative qty not allowed');
         END IF;

         gme_common_pvt.log_message (p_product_code => 'GMI'
                                    ,p_message_code => 'IC_ACTIONQTYNEG');
         /*Bug#6778968 Rework */
         x_return_status := fnd_api.g_ret_sts_error;
         RAISE negative_qty_error;
      END IF;

      /* Do setups appropriate to the organization */
      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_reservation_rec.organization_id
                              ,p_org_code      => NULL);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE  fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.set_timestamp;
      /* Verify that we have a valid row in gme_material_details */
      l_material_details_rec.material_detail_id :=
                                       l_reservation_rec.demand_source_line_id;

      IF NOT (gme_material_details_dbl.fetch_row (l_material_details_rec
                                                 ,l_material_details_rec) ) THEN
         RAISE  fnd_api.g_exc_error;
      END IF;

      /* Validate the demand source - it must be a valid ingredient line */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                     (   g_pkg_name
                      || '.'
                      || l_api_name
                      || ' Invoke validate_supply_demand for demand line of '
                      || l_material_details_rec.material_detail_id);
      END IF;
       /*Bug#6778968 Passing the p_called_by as CVT for validating the conversions */
      GME_API_GRP.validate_supply_demand(
                   x_return_status             => x_return_status,
                   x_msg_count                 => x_message_count,
                   x_msg_data                  => x_message_list,
                   x_valid_status              => l_valid_status,
                   p_organization_id           => l_material_details_rec.organization_id,
                   p_item_id                   => l_material_details_rec.inventory_item_id,
                   p_supply_demand_code        => 2,      -- signals DEMAND
                   p_supply_demand_type_id     => INV_RESERVATION_GLOBAL.g_source_type_wip,
                   p_supply_demand_header_id   => l_material_details_rec.batch_id,
                   p_supply_demand_line_id     => l_material_details_rec.material_detail_id,
                   p_supply_demand_line_detail => FND_API.G_MISS_NUM,
                   p_demand_ship_date          => NULL,
                   p_expected_receipt_date     => NULL,
                   p_called_by                => 'CVT',
                   p_api_version_number        => 1.0,
                   p_init_msg_lst              => FND_API.G_FALSE );

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
             (   g_pkg_name
              || '.'
              || l_api_name
              || ' Return status from gme_api_grp.validate_supply_demand is '
              || x_return_status);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        OR l_valid_status <> 'Y' THEN
          RAISE  fnd_api.g_exc_error;
      END IF;

      /* Invoke private layer to process transactions */
      gme_reservations_pvt.convert_dtl_reservation
                            (p_reservation_rec           => l_reservation_rec
                            ,p_material_details_rec      => l_material_details_rec
                            ,p_qty_convert               => p_qty_convert
                            ,x_message_count             => x_message_count
                            ,x_message_list              => x_message_list
                            ,x_return_status             => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Return status from gme_reservations_pvt.convert_dtl_reservation is '
             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE detail_reservation_error;
      END IF;
      gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' return status from gme_api_pub.save_batch is '
                          || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
       WHEN detail_reservation_error OR negative_qty_error THEN
         ROLLBACK TO SAVEPOINT convert_dtl_reservation;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT convert_dtl_reservation;
	gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END convert_dtl_reservation;

/*************************************************************************/
   PROCEDURE insert_batchstep_resource (
      p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_org_code                 IN              VARCHAR2 := NULL
     ,p_batch_no                 IN              VARCHAR2 := NULL
     ,p_batchstep_no             IN              NUMBER := NULL
     ,p_activity                 IN              VARCHAR2 := NULL
     ,p_ignore_qty_below_cap     IN              VARCHAR2 := fnd_api.g_false
     ,p_validate_flexfields      IN              VARCHAR2 := fnd_api.g_false
     ,x_batchstep_resource_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name            CONSTANT VARCHAR2 (30)
                                               := 'INSERT_BATCHSTEP_RESOURCE';
      l_batch_header                 gme_batch_header%ROWTYPE;
      l_batchstep_resource_rec       gme_batch_step_resources%ROWTYPE;
      l_batchstep_resource_rec_out   gme_batch_step_resources%ROWTYPE;
      l_table                        NUMBER;
      l_step_status                  NUMBER;
      l_dummy                        NUMBER;
      l_batch_id                     NUMBER;
      l_batchstep_id                 NUMBER;
      l_rsrc_id                      NUMBER;
      l_delete_mark                  NUMBER;
      l_min_capacity                 NUMBER;
      l_max_capacity                 NUMBER;
      l_max_step_capacity            NUMBER;
      l_capacity_constraint          NUMBER;
      l_capacity_um                  VARCHAR2 (3);
      l_usage_uom                    VARCHAR2 (3);
      l_capacity_tolerance           NUMBER;
      l_return_status                VARCHAR2 (2);

      insert_rsrc_failed             EXCEPTION;

      /* Cursor Declarations */
      CURSOR cur_validate_activity (v_activity_id NUMBER)
      IS
         SELECT batchstep_id, batch_id
           FROM gme_batch_step_activities
          WHERE batchstep_activity_id = v_activity_id;

      CURSOR cur_validate_batch_type (v_activity_id NUMBER)
      IS
         SELECT 1
           FROM gme_batch_header a, gme_batch_step_activities b
          WHERE a.batch_id = b.batch_id
            AND b.batchstep_activity_id = v_activity_id
            AND a.batch_type = 10;

      CURSOR cur_get_rsrc_dtl (v_resources VARCHAR2, v_organization_id VARCHAR2)
      IS
         SELECT min_capacity, max_capacity, capacity_constraint, capacity_um
               ,usage_uom, delete_mark, capacity_tolerance
           FROM cr_rsrc_dtl
          WHERE resources = v_resources
                AND organization_id = v_organization_id;

      CURSOR cur_get_rsrc_hdr (v_resources VARCHAR2)
      IS
         SELECT min_capacity, max_capacity, capacity_constraint, capacity_um
               ,std_usage_uom, delete_mark, capacity_tolerance
           FROM cr_rsrc_mst
          WHERE resources = v_resources;

      CURSOR cur_get_step_status (v_batch_id NUMBER, v_batchstep_id NUMBER)
      IS
         SELECT step_status
           FROM gme_batch_steps
          WHERE batch_id = v_batch_id AND batchstep_id = v_batchstep_id;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('InsertBatchstepResource');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the savepoint */
      SAVEPOINT insert_batchstep_rsrc;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'insert_batchstep_resource'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Setup the common constants used across the apis */
      /* This will raise an error if both organization_id and org_code are null values */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ( g_pkg_name || '.' || l_api_name ||
                             'Invoking setup for org_id ' ||
                               p_batchstep_resource_rec.organization_id ||
                               ' org_code ' || p_org_code);
      END IF;

      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup
                        (p_org_id        => p_batchstep_resource_rec.organization_id
                        ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_common_pvt.g_check_primary_rsrc := 1;
      l_batchstep_resource_rec := p_batchstep_resource_rec;
      l_batchstep_resource_rec.organization_id :=
                                              gme_common_pvt.g_organization_id;

      IF l_batchstep_resource_rec.resources IS NULL THEN
         gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                    ,'FIELD_NAME'
                                    ,'RESOURCES');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF l_batchstep_resource_rec.batchstep_activity_id IS NOT NULL THEN
         -- validate the key provided
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line
                              (   g_pkg_name
                               || '.'
                               || l_api_name
                               || ' validate batchstep activity id'
                               || l_batchstep_resource_rec.batchstep_activity_id);
         END IF;

         OPEN cur_validate_activity
                               (l_batchstep_resource_rec.batchstep_activity_id);

         FETCH cur_validate_activity
          INTO l_batchstep_id, l_batch_id;

         IF cur_validate_activity%NOTFOUND THEN
            CLOSE cur_validate_activity;

            gme_common_pvt.log_message
                              ('GME_ACTID_NOT_FOUND'
                              ,'BATCHSTEP_ACT_ID'
                              ,l_batchstep_resource_rec.batchstep_activity_id);
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE cur_validate_activity;

         -- make sure activity id does not belong to an FPO
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' validate for FPO');
         END IF;

         OPEN cur_validate_batch_type
                               (l_batchstep_resource_rec.batchstep_activity_id);

         FETCH cur_validate_batch_type
          INTO l_dummy;

         IF cur_validate_batch_type%FOUND THEN
            CLOSE cur_validate_batch_type;

            gme_common_pvt.log_message ('GME_FPO_RSRC_NO_EDIT');
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE cur_validate_batch_type;
      ELSE
         /* User supplies EITHER internal identifiers via p_batchstep_resource_rec OR a
         series of keys.  In the case of the latter, these must be validated and converted to
         internal identifiers for ongoing processing */
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Invoke validate_param');
         END IF;

         gme_batchstep_rsrc_pvt.validate_param
             (p_org_code             => gme_common_pvt.g_organization_code
             ,p_batch_no             => p_batch_no
             ,p_batchstep_no         => p_batchstep_no
             ,p_activity             => p_activity
             ,p_resource             => l_batchstep_resource_rec.resources
             ,x_organization_id      => l_batchstep_resource_rec.organization_id
             ,x_batch_id             => l_batchstep_resource_rec.batch_id
             ,x_batchstep_id         => l_batchstep_resource_rec.batchstep_id
             ,x_activity_id          => l_batchstep_resource_rec.batchstep_activity_id
             ,x_rsrc_id              => l_rsrc_id
             ,x_step_status          => l_step_status
             ,x_return_status        => l_return_status);

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' validate_param returns '
                                || l_return_status);
         END IF;

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (g_pkg_name || '.' || l_api_name || ' batch_id
            			=> ' || l_batchstep_resource_rec.batch_id);
            gme_debug.put_line (g_pkg_name || '.' || l_api_name || ' batchstep_id => ' ||
            			l_batchstep_resource_rec.batchstep_id);
            gme_debug.put_line ( g_pkg_name || '.' || l_api_name || ' batchstep_activity_id => '
            			 || l_batchstep_resource_rec.batchstep_activity_id);
            gme_debug.put_line ( g_pkg_name || '.' || l_api_name || ' rsrc_id => ' || l_rsrc_id);
            gme_debug.put_line ( g_pkg_name || '.' || l_api_name || ' step_status => '
                                || l_step_status);
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' proceed with resource validation for '
                             || l_batchstep_resource_rec.resources);
      END IF;

      OPEN cur_get_rsrc_dtl (l_batchstep_resource_rec.resources
                            ,l_batchstep_resource_rec.organization_id);

      FETCH cur_get_rsrc_dtl
       INTO l_min_capacity, l_max_capacity, l_capacity_constraint
           ,l_capacity_um, l_usage_uom, l_delete_mark, l_capacity_tolerance;

      IF (cur_get_rsrc_dtl%NOTFOUND) THEN
         OPEN cur_get_rsrc_hdr (l_batchstep_resource_rec.resources);

         FETCH cur_get_rsrc_hdr
          INTO l_min_capacity, l_max_capacity, l_capacity_constraint
              ,l_capacity_um, l_usage_uom, l_delete_mark
              ,l_capacity_tolerance;

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line ('after rsrc hdr fetch ');
         END IF;

         IF cur_get_rsrc_hdr%NOTFOUND OR l_delete_mark = 1 THEN
            CLOSE cur_get_rsrc_dtl;

            CLOSE cur_get_rsrc_hdr;

            fnd_message.set_name ('GMD', 'FM_BAD_RESOURCE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
         CLOSE cur_get_rsrc_hdr;
      END IF;

      CLOSE cur_get_rsrc_dtl;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' retrieve step status for batchstep_id'
                             || l_batchstep_resource_rec.batchstep_id);
      END IF;

      OPEN cur_get_step_status (l_batchstep_resource_rec.batch_id
                               ,l_batchstep_resource_rec.batchstep_id);

      FETCH cur_get_step_status
       INTO l_step_status;

      IF cur_get_step_status%NOTFOUND THEN
         CLOSE cur_get_step_status;

         gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                    ,'TABLE_NAME'
                                    ,'GME_BATCH_STEPS');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ' step_status
         			is ' || l_step_status);
      END IF;

      CLOSE cur_get_step_status;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Invoke validate_rsrc_param');
      END IF;

      --FPBug#4395561 Start  setting global flex validate variable
      IF p_validate_flexfields = FND_API.G_TRUE THEN
        gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
        gme_common_pvt.g_flex_validate_prof := 0;
      END IF;
       --FPBug#4395561 End

      gme_batchstep_rsrc_pvt.validate_rsrc_param
             (p_batchstep_resource_rec      => l_batchstep_resource_rec
             ,p_activity_id                 => l_batchstep_resource_rec.batchstep_activity_id
             ,p_ignore_qty_below_cap        => p_ignore_qty_below_cap
             ,p_validate_flexfield          => p_validate_flexfields
             ,p_action                      => 'INSERT'
             ,x_batchstep_resource_rec      => l_batchstep_resource_rec_out
             ,x_step_status                 => l_step_status
             ,x_return_status               => l_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' validate_rsrc_param returns '
                             || l_return_status);
      END IF;

      --FPBug#4395561  resetting globla flex field variable
      gme_common_pvt.g_flex_validate_prof := 0;

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Set capacity data
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			 ' set capacity data as follows ');
         gme_debug.put_line (   g_pkg_name || '.'  || l_api_name ||
         			 ' usage_um           => ' || l_usage_uom);
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			' capacity_um => ' || l_capacity_um);
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			 ' min_capacity       => ' || l_min_capacity);
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || '
         			max_capacity       => ' || l_max_capacity);
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			' capacity tolerance => '|| l_capacity_tolerance);
      END IF;

      l_batchstep_resource_rec := l_batchstep_resource_rec_out;
      l_batchstep_resource_rec.usage_um := l_usage_uom;
      l_batchstep_resource_rec.capacity_um := l_capacity_um;
      l_batchstep_resource_rec.min_capacity := l_min_capacity;
      l_batchstep_resource_rec.max_capacity := l_max_capacity;
      l_batchstep_resource_rec.capacity_tolerance := l_capacity_tolerance;

      IF l_batchstep_resource_rec.offset_interval IS NULL THEN
         l_batchstep_resource_rec.offset_interval := 0;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                             || ' invoke private layer insert_batchstep_rsrc');
      END IF;

      gme_batchstep_rsrc_pvt.insert_batchstep_rsrc
                        (p_batchstep_resource_rec      => l_batchstep_resource_rec
                        ,x_batchstep_resource_rec      => x_batchstep_resource_rec
                        ,x_return_status               => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || '
         insert_batchstep_rsrc returns '|| x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' invoke save_batch');
         END IF;

         gme_api_pub.save_batch (p_header_id          => NULL
                                ,p_table              => NULL
                                ,p_commit             => p_commit
                                ,x_return_status      => x_return_status);

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name || '.' || l_api_name || '
            save_batch returns '|| x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         RAISE insert_rsrc_failed;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed ' || g_pkg_name || '.' || l_api_name
         || ' at ' || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
      gme_common_pvt.count_and_get(x_count        => x_message_count
                                  ,p_encoded      => fnd_api.g_false
                                  ,x_data         => x_message_list);
   EXCEPTION
      WHEN insert_rsrc_failed THEN
         ROLLBACK TO SAVEPOINT insert_batchstep_rsrc;
         gme_common_pvt.count_and_get(x_count        => x_message_count
                                     ,p_encoded      => fnd_api.g_false
                                     ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT insert_batchstep_rsrc;
         gme_common_pvt.count_and_get(x_count        => x_message_count
                                     ,p_encoded      => fnd_api.g_false
                                     ,x_data         => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT insert_batchstep_rsrc;
        gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END insert_batchstep_resource;

/*************************************************************************/
   PROCEDURE update_batchstep_resource (
      p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER   := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_org_code                 IN              VARCHAR2 := NULL
     ,p_batch_no                 IN              VARCHAR2 := NULL
     ,p_batchstep_no             IN              NUMBER := NULL
     ,p_activity                 IN              VARCHAR2 := NULL
     ,p_ignore_qty_below_cap     IN              VARCHAR2 := fnd_api.g_false
     ,p_validate_flexfields      IN              VARCHAR2 := fnd_api.g_false
     ,x_batchstep_resource_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name             CONSTANT VARCHAR2 (30)
                                               := 'UPDATE_BATCHSTEP_RESOURCE';
      l_batch_header                  gme_batch_header%ROWTYPE;
      l_batchstep_resource_rec        gme_batch_step_resources%ROWTYPE;
      l_batchstep_resource_rec_out    gme_batch_step_resources%ROWTYPE;
      l_cons_batchstep_resource_rec   gme_batch_step_resources%ROWTYPE;
      l_return_status                 VARCHAR2 (2);
      l_step_status                   NUMBER;

      CURSOR cur_get_batchstep_status (
         v_batchstep_id   NUMBER
        ,v_batch_id       NUMBER)
      IS
         SELECT step_status
           FROM gme_batch_steps
          WHERE batchstep_id = v_batchstep_id AND batch_id = v_batch_id;

      update_rsrc_failed              EXCEPTION;
   BEGIN
      /* Set the savepoint */
      SAVEPOINT update_batchstep_rsrc;

      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('UpdateBatchstepResource');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'update_batchstep_resource'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.set_timestamp;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      l_batchstep_resource_rec := p_batchstep_resource_rec;
      gme_common_pvt.g_check_primary_rsrc := 1;

      /* Retrieve the row to be updated              */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'Invoke get_batchstep_rsrc');
      END IF;

      IF NOT gme_common_pvt.get_batchstep_rsrc
                         (p_batchstep_rsrc_rec      => l_batchstep_resource_rec
                         ,p_org_code                => p_org_code
                         ,p_batch_no                => p_batch_no
                         ,p_batchstep_no            => p_batchstep_no
                         ,p_activity                => p_activity
                         ,p_resource                => l_batchstep_resource_rec.resources
                         ,x_batchstep_rsrc_rec      => l_batchstep_resource_rec_out) THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' get_batchstep_rsrc failed to retrieve row');
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      /* Make sure the essential keys are populated from the retrieved row */
      /* Don't overwrite any other input data which carries the updates    */
      l_batchstep_resource_rec.organization_id :=
                                  l_batchstep_resource_rec_out.organization_id;
      l_batchstep_resource_rec.batchstep_resource_id :=
                            l_batchstep_resource_rec_out.batchstep_resource_id;
      l_batchstep_resource_rec.batch_id :=
                                         l_batchstep_resource_rec_out.batch_id;
      l_batchstep_resource_rec.batchstep_id :=
                                     l_batchstep_resource_rec_out.batchstep_id;
      l_batchstep_resource_rec.batchstep_activity_id :=
                            l_batchstep_resource_rec_out.batchstep_activity_id;
      l_batchstep_resource_rec.resources :=
                                        l_batchstep_resource_rec_out.resources;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' batchstep_resource_id is '
                             || l_batchstep_resource_rec.batchstep_resource_id);
      END IF;

      /* Setup the common constants used accross the apis */
      /* This will raise an error if both organization_id and org_code are null values */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Invoking setup for org_id '
                             || p_batchstep_resource_rec.organization_id
                             || ' org_code '
                             || p_org_code);
      END IF;

      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup
                        (p_org_id        => l_batchstep_resource_rec.organization_id
                        ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' setup failure ');
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      /* Establish the step_status of the batchstep                   */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' retrieve step status for batchstep_id '
                             || l_batchstep_resource_rec.batchstep_id);
      END IF;

      OPEN cur_get_batchstep_status (l_batchstep_resource_rec.batchstep_id
                                    ,l_batchstep_resource_rec.batch_id);

      FETCH cur_get_batchstep_status
       INTO l_step_status;

      IF cur_get_batchstep_status%NOTFOUND THEN
         CLOSE cur_get_batchstep_status;

         gme_common_pvt.log_message ('GME_BATCH_STEP_NOT_FOUND'
                                    ,'STEP_ID'
                                    ,l_batchstep_resource_rec.batchstep_id);
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' step_status is '
                             || l_step_status);
      END IF;

      CLOSE cur_get_batchstep_status;

      --FPBug#4395561 Start setting global flex validate variable
      IF p_validate_flexfields = FND_API.G_TRUE THEN
        gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
        gme_common_pvt.g_flex_validate_prof := 0;
      END IF;
       --FPBug#4395561 End

      gme_batchstep_rsrc_pvt.validate_rsrc_param
             (p_batchstep_resource_rec      => l_batchstep_resource_rec
             ,p_activity_id                 => l_batchstep_resource_rec.batchstep_activity_id
             ,p_ignore_qty_below_cap        => p_ignore_qty_below_cap
             ,p_validate_flexfield          => p_validate_flexfields
             ,p_action                      => 'UPDATE'
             ,x_batchstep_resource_rec      => l_batchstep_resource_rec_out
             ,x_step_status                 => l_step_status
             ,x_return_status               => l_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('val rsrc param returns ' || l_return_status);
      END IF;

      --FPBug#4395561 resetting global flex field validate
      gme_common_pvt.g_flex_validate_prof := 0;

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      l_batchstep_resource_rec := l_batchstep_resource_rec_out;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                      (   g_pkg_name
                       || '.'
                       || l_api_name
                       || ' Invoke gme_batchstep_rsrc_pvt.update_batchstep_rsrc');
      END IF;

      gme_batchstep_rsrc_pvt.update_batchstep_rsrc
                        (p_batchstep_resource_rec      => l_batchstep_resource_rec
                        ,x_batchstep_resource_rec      => x_batchstep_resource_rec
                        ,x_return_status               => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' update_batchstep_rsrc returns '
                             || x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' invoke save_batch with commit ='
                                || p_commit);
         END IF;

         gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => null
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' save_batch return_status is '
                                || x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         RAISE update_rsrc_failed;
      END IF;

      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
      gme_common_pvt.count_and_get(x_count        => x_message_count
                                  ,p_encoded      => fnd_api.g_false
                                  ,x_data         => x_message_list);

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN update_rsrc_failed THEN
         ROLLBACK TO SAVEPOINT update_batchstep_rsrc;
         gme_common_pvt.count_and_get(x_count        => x_message_count
                                  ,p_encoded      => fnd_api.g_false
                                  ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT update_batchstep_rsrc;
         gme_common_pvt.count_and_get(x_count        => x_message_count
                                  ,p_encoded      => fnd_api.g_false
                                  ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_batchstep_rsrc;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END update_batchstep_resource;

/*************************************************************************/
   PROCEDURE delete_batchstep_resource (
      p_api_version             IN              NUMBER := 2.0
     ,p_validation_level        IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list           IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                  IN              VARCHAR2 := fnd_api.g_false
     ,p_batchstep_resource_id   IN              NUMBER := NULL
     ,p_org_code                IN              VARCHAR2 := NULL
     ,p_batch_no                IN              VARCHAR2 := NULL
     ,p_batchstep_no            IN              NUMBER := NULL
     ,p_activity                IN              VARCHAR2 := NULL
     ,p_resource                IN              VARCHAR2 := NULL
     ,x_message_count           OUT NOCOPY      NUMBER
     ,x_message_list            OUT NOCOPY      VARCHAR2
     ,x_return_status           OUT NOCOPY      VARCHAR2)
   IS
      l_api_name        CONSTANT VARCHAR2 (30) := 'DELETE_BATCHSTEP_RESOURCE';
      l_step_status              NUMBER;
      l_batch_status             NUMBER;
      l_organization_id          NUMBER;
      l_rsrc_id                  NUMBER;
      l_activity_id              NUMBER;
      l_dummy                    NUMBER;
      l_batch_id                 NUMBER;
      l_batchstep_id             NUMBER;
      l_return_status            VARCHAR2 (2);
      l_batchstep_resource_rec   gme_batch_step_resources%ROWTYPE;

          CURSOR cur_get_step_dtl (v_batchstep_rsrc_id NUMBER)
      IS
         SELECT c.organization_id, a.step_status, a.batch_id, a.batchstep_id
               ,b.batchstep_activity_id, c.batch_status
           FROM gme_batch_steps a
               ,gme_batch_step_resources b
               ,gme_batch_header c
          WHERE a.batch_id = b.batch_id
            AND a.batchstep_id = b.batchstep_id
            AND b.batchstep_resource_id = v_batchstep_rsrc_id
            AND a.batch_id = c.batch_id;

      CURSOR cur_validate_batch_type (v_rsrc_id NUMBER)
      IS
         SELECT 1
           FROM gme_batch_header a, gme_batch_step_resources b
          WHERE a.batch_id = b.batch_id
            AND b.batchstep_resource_id = v_rsrc_id
            AND a.batch_type = 10;

      delete_rsrc_failed         EXCEPTION;
   BEGIN
      /* Set the savepoint */
      SAVEPOINT delete_batchstep_rsrc;

      IF g_debug <> -1 THEN
         gme_debug.log_initialize ('DeleteBatchstepResource');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Make sure we are call compatible */
      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'delete_batchstep_resource'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.set_timestamp;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      gme_common_pvt.g_check_primary_rsrc := 1;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'input data - p_batchstep_resource_id is : '
                             || p_batchstep_resource_id
                             || 'input data - p_resource is : '
                             || p_resource);
      END IF;

      /* Report error if insufficient data to pinpoint batchstep resource */
      IF (p_batchstep_resource_id IS NULL AND p_resource IS NULL) THEN
         gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                    ,'FIELD_NAME'
                                    ,'RESOURCES');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* validate key values where no internal ID provided */
      IF p_batchstep_resource_id IS NULL THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Invoke validate param ');
         END IF;

         gme_batchstep_rsrc_pvt.validate_param
                                      (p_org_code             => p_org_code
                                      ,p_batch_no             => p_batch_no
                                      ,p_batchstep_no         => p_batchstep_no
                                      ,p_activity             => p_activity
                                      ,p_resource             => p_resource
                                      ,x_organization_id      => l_organization_id
                                      ,x_batch_id             => l_batch_id
                                      ,x_batchstep_id         => l_batchstep_id
                                      ,x_activity_id          => l_activity_id
                                      ,x_rsrc_id              => l_rsrc_id
                                      ,x_step_status          => l_step_status
                                      ,x_return_status        => l_return_status);

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'validate_param returns status : '
                                || l_return_status
                                || 'validate_param returns rsrc_id : '
                                || l_rsrc_id );
         END IF;

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'Working with Input batchstep resource id : '
                                || p_batchstep_resource_id);
         END IF;

         l_rsrc_id := p_batchstep_resource_id;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' retrieve batch step detail using id => '
                             || l_rsrc_id);
      END IF;

      OPEN cur_get_step_dtl (l_rsrc_id);

      FETCH cur_get_step_dtl
       INTO l_organization_id, l_step_status, l_batch_id, l_batchstep_id
           ,l_activity_id, l_batch_status;

      IF cur_get_step_dtl%NOTFOUND THEN
         CLOSE cur_get_step_dtl;

         gme_common_pvt.log_message ('GME_INVALID_RSRC_ID');
         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE cur_get_step_dtl;

      /* Setup the common constants used across the apis */
      /* This will raise an error if both organization_id and org_code are null values */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' invoke setup using org_id => '
                             || l_organization_id
                             || ' and org_code => '
                             || p_org_code);
      END IF;

      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_organization_id
                              ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Validations prior to deletion */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' start of validations');
      END IF;

      /* make sure resource id does not belong to an FPO */
      OPEN cur_validate_batch_type (l_rsrc_id);

      FETCH cur_validate_batch_type
       INTO l_dummy;

      IF cur_validate_batch_type%FOUND THEN
         CLOSE cur_validate_batch_type;
         gme_common_pvt.log_message ('GME_FPO_RSRC_NO_EDIT');
         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE cur_validate_batch_type;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' validate batch_status of '
                             || l_batch_status);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' validate step_status of  '
                             || l_step_status);
      END IF;

      IF l_batch_status <> gme_common_pvt.g_batch_pending THEN
         gme_common_pvt.log_message ('PM_WRONG_STATUS');
         RAISE fnd_api.g_exc_error;
      ELSIF l_step_status <> gme_common_pvt.g_step_pending THEN
         gme_common_pvt.log_message ('PC_STEP_STATUS_ERR');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Ensure that the batchstep_resource_rec is sufficiently populated for deletion to proceed */
      l_batchstep_resource_rec.organization_id := l_organization_id;
      l_batchstep_resource_rec.batch_id := l_batch_id;
      l_batchstep_resource_rec.batchstep_id := l_batchstep_id;
      l_batchstep_resource_rec.batchstep_activity_id := l_activity_id;
      l_batchstep_resource_rec.batchstep_resource_id := l_rsrc_id;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			' invoke gme_batchstep_rsrc_pvt.delete_batchstep_rsrc ');
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			'organization_id       => ' || l_organization_id);
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			' batch_id => ' || l_batch_id);
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			'batchstep_id          => ' || l_batchstep_id);
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			 ' activity_id => '     || l_activity_id);
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			'batchstep_resource_id => ' || l_rsrc_id);
      END IF;

      gme_batchstep_rsrc_pvt.delete_batchstep_rsrc
                        (p_batchstep_resource_rec      => l_batchstep_resource_rec
                        ,x_return_status               => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ' return
         			status from delete is ' || x_return_status);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_success THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ' invoke
            			save_batch tith commit set '   || p_commit);
         END IF;

         gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => null
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ' return
            			status from save_batch is '
                                || x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         RAISE delete_rsrc_failed;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
      gme_common_pvt.log_message ('PM_SAVED_CHANGES');
      gme_common_pvt.count_and_get(x_count        => x_message_count
                                  ,p_encoded      => fnd_api.g_false
                                  ,x_data         => x_message_list);
   EXCEPTION
      WHEN delete_rsrc_failed THEN
         ROLLBACK TO SAVEPOINT delete_batchstep_rsrc;
         gme_common_pvt.count_and_get(x_count        => x_message_count
                                     ,p_encoded      => fnd_api.g_false
                                     ,x_data         => x_message_list);
     WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT delete_batchstep_rsrc;
         gme_common_pvt.count_and_get(x_count        => x_message_count
                                     ,p_encoded      => fnd_api.g_false
                                     ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_batchstep_rsrc;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END delete_batchstep_resource;

 /*************************************************************************/
   PROCEDURE auto_detail_line (
      p_api_version          IN              NUMBER := 2.0
     ,p_validation_level     IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list        IN              VARCHAR2 := fnd_api.g_false
     ,p_commit               IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count        OUT NOCOPY      NUMBER
     ,x_message_list         OUT NOCOPY      VARCHAR2
     ,x_return_status        OUT NOCOPY      VARCHAR2
     ,p_material_detail_id   IN              NUMBER
     ,p_org_code             IN              VARCHAR2
     ,p_batch_no             IN              VARCHAR2
     ,p_line_no              IN              NUMBER)
   IS
      l_api_name          CONSTANT VARCHAR2 (30)        := 'AUTO_DETAIL_LINE';
      l_material_details_rec       gme_material_details%ROWTYPE;
      l_material_details_rec_out   gme_material_details%ROWTYPE;
      l_reservation_rec            mtl_reservations%ROWTYPE;
      l_batch_header_rec           gme_batch_header%ROWTYPE;
      l_valid_status               VARCHAR2(1);

      CURSOR cur_fetch_reservation (v_reservation_id NUMBER)
      IS
         SELECT *
           FROM mtl_reservations
          WHERE reservation_id = v_reservation_id;

      auto_detail_error            EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('AutoDetailLine');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the savepoint */
      SAVEPOINT auto_detail_line;
      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'auto_detail_line'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (
          g_pkg_name || '.' || l_api_name ||
         ' input material_detail_id is  ' || p_material_detail_id ||
         ' input batch_no is  ' || p_batch_no ||
         ' input org_code is  ' || p_org_code ||
         ' input  line_no  is  ' || p_line_no);
      END IF;

      l_material_details_rec.material_detail_id := p_material_detail_id;
      l_material_details_rec.line_no := p_line_no;
      /* Ensure line_type is populated.  Reservations only permitted for ingredient lines. */
      l_material_details_rec.line_type := -1;
      gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> l_material_details_rec
                          ,p_org_code                 	=> p_org_code
                          ,p_batch_no                 	=> p_batch_no
                          ,p_batch_type               	=> 0
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_material_details_rec_out
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         ELSE
               l_material_details_rec := l_material_details_rec_out;
         END IF;
      gme_common_pvt.set_timestamp;

      /* Validate the demand source - it must be a valid ingredient line */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                     (   g_pkg_name
                      || '.'
                      || l_api_name
                      || ' Invoke validate_supply_demand for demand line of '
                      || l_material_details_rec.material_detail_id);
      END IF;

      GME_API_GRP.validate_supply_demand(
             x_return_status             => x_return_status,
             x_msg_count                 => x_message_count,
             x_msg_data                  => x_message_list,
             x_valid_status              => l_valid_status,
             p_organization_id           => l_material_details_rec.organization_id,
             p_item_id                   => l_material_details_rec.inventory_item_id,
             p_supply_demand_code        => 2,      -- signals DEMAND
             p_supply_demand_type_id     => INV_RESERVATION_GLOBAL.g_source_type_wip,
             p_supply_demand_header_id   => l_material_details_rec.batch_id,
             p_supply_demand_line_id     => l_material_details_rec.material_detail_id,
             p_supply_demand_line_detail => FND_API.G_MISS_NUM,
             p_demand_ship_date          => NULL,
             p_expected_receipt_date     => NULL,
             p_api_version_number        => 1.0,
             p_init_msg_lst              => FND_API.G_FALSE );

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
             (   g_pkg_name
              || '.'
              || l_api_name
              || ' Return status from gme_api_grp.validate_supply_demand is '
              || x_return_status);
         gme_debug.put_line(g_pkg_name
              ||'.'
              ||l_api_name
              || ' valid status is '
              || l_valid_status);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        OR l_valid_status <> 'Y' THEN
          RAISE fnd_api.g_exc_error;
      END IF;

      /* Invoke auto_detail_line to create detailed level reservations */
      gme_api_main.auto_detail_line
                             (p_init_msg_list            => fnd_api.g_false
                             ,p_material_detail_rec      => l_material_details_rec
                             ,x_message_count            => x_message_count
                             ,x_message_list             => x_message_list
                             ,x_return_status            => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			' Return status from GME_API_MAIN.Auto_Detail_Line is '
                   		|| x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE auto_detail_error;
      END IF;

      /* COMMIT handling */
      IF p_commit = fnd_api.g_true THEN
         COMMIT;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed '
                             || g_pkg_name
                             || '.'
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN auto_detail_error THEN
         ROLLBACK TO SAVEPOINT auto_detail_line;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT auto_detail_line;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT auto_detail_line;
	gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END auto_detail_line;

 /*************************************************************************/
   PROCEDURE auto_detail_batch     (p_api_version            IN          NUMBER := 2.0
                                   ,p_init_msg_list          IN          VARCHAR2 := FND_API.G_FALSE
                                   ,p_commit                 IN          VARCHAR2 := FND_API.G_FALSE
                                   ,x_message_count          OUT NOCOPY  NUMBER
                                   ,x_message_list           OUT NOCOPY  VARCHAR2
                                   ,x_return_status          OUT NOCOPY  VARCHAR2
                                   ,p_org_code               IN          VARCHAR2
                                   ,p_batch_rec              IN          GME_BATCH_HEADER%ROWTYPE) IS

    l_api_name                      CONSTANT VARCHAR2 (30)   :=          'AUTO_DETAIL_BATCH';
    l_batch_rec                     GME_BATCH_HEADER%ROWTYPE;
    l_batch_header_rec              GME_BATCH_HEADER%ROWTYPE;

    auto_detail_error               EXCEPTION;
   BEGIN
     IF (g_debug <> -1) THEN
       gme_debug.log_initialize ('AutoDetailBatch');
     END IF;

     IF g_debug <= gme_debug.g_log_procedure THEN
       gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
     END IF;

     /* Set the savepoint */
     SAVEPOINT auto_detail_batch;

     /* Set the return status to success initially */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_init_msg_list = FND_API.G_TRUE THEN
       fnd_msg_pub.initialize;
     END IF;

     IF NOT FND_API.compatible_api_call(2.0
                                       ,p_api_version
                                       ,'auto_detail_batch'
                                       ,g_pkg_name ) THEN
       gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
       RAISE fnd_api.g_exc_error;
     END IF;

     IF g_debug <= gme_debug.g_log_statement THEN
       gme_debug.put_line(  g_pkg_name
                          ||'.'
                          ||l_api_name
                          || 'Retrieve batch header row'
                          || ' Input org_code is  '
                          ||p_org_code
                          ||' Input org_id   is  '
                          ||p_batch_rec.organization_id
                          ||' Input batch_no is  '
                          ||p_batch_rec.batch_no
                          ||' Input batch_id is  '
                          ||p_batch_rec.batch_id  );
     END IF;

     l_batch_rec := p_batch_rec;
     /* Check setup is done. For all profile/parameter values based on orgn_code/organization_id. */
     IF p_org_code is NOT NULL and p_batch_rec.organization_id is NULL THEN
       gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id    => l_batch_header_rec.organization_id,
                               p_org_code   => p_org_code);

       IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
       ELSE
         l_batch_rec.organization_id := gme_common_pvt.g_organization_id;
         IF g_debug <= gme_debug.g_log_statement THEN
           gme_debug.put_line(  g_pkg_name
                              ||'.'
                              ||l_api_name
                              || ' Organization_id set to '
                              ||gme_common_pvt.g_organization_id);
         END IF;
       END IF;
     END IF;

     IF l_batch_rec.batch_type is NULL THEN
       l_batch_rec.batch_type := gme_common_pvt.g_doc_type_batch;
     END IF;

     IF (NOT gme_batch_header_dbl.fetch_row (l_batch_rec,
                                             l_batch_header_rec) ) THEN
       RAISE fnd_api.g_exc_error;
     END IF;

     /* Validate for organization */
     IF (l_batch_header_rec.organization_id IS NULL AND p_org_code IS NULL) THEN
       fnd_message.set_name ('INV', 'INV_ORG_REQUIRED');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
     END IF;

     /* Check setup is done. For all profile/parameter values based on orgn_code/organization_id. */
     gme_common_pvt.g_setup_done :=
       gme_common_pvt.setup (p_org_id        => l_batch_header_rec.organization_id,
                             p_org_code      => p_org_code);

     IF NOT gme_common_pvt.g_setup_done THEN
       RAISE fnd_api.g_exc_error;
     END IF;

     /* Verify that update_inventory is permitted for this batch */
     IF l_batch_header_rec.update_inventory_ind <> 'Y' THEN
       gme_common_pvt.log_message ('GME_INVENTORY_UPDATE_BLOCKED');
       RAISE fnd_api.g_exc_error;
     END IF;

     /* Verify Batch to be in pending or WIP status */
     IF l_batch_header_rec.batch_status NOT IN
               (gme_common_pvt.g_batch_pending, gme_common_pvt.g_batch_wip) THEN
       gme_common_pvt.log_message ('GME_INVALID_BATCH_STATUS','PROCESS','AUTO_DETAIL_BATCH');
       RAISE fnd_api.g_exc_error;
     END IF;

     /* Reservations not permitted for FPOs */
     IF l_batch_header_rec.batch_type = gme_common_pvt.g_doc_type_fpo THEN
       gme_common_pvt.log_message ('GME_FPO_RESERVATION_ERROR');
       RAISE fnd_api.g_exc_error;
     END IF;

     gme_common_pvt.set_timestamp;

     /* Invoke auto_detail_batch to create detailed level reservations */
     GME_API_MAIN.Auto_Detail_Batch(p_init_msg_list        => FND_API.G_FALSE
                                  ,x_message_count        => x_message_count
                                  ,x_message_list         => x_message_list
                                  ,x_return_status        => x_return_status
                                  ,p_batch_rec            => l_batch_header_rec);

     IF g_debug <= gme_debug.g_log_statement THEN
       gme_debug.put_line(  g_pkg_name
                          ||'.'
                          ||l_api_name
                          ||' Return status from GME_API_MAIN.Auto_Detail_Batch is '
                          ||x_return_status);
     END IF;

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE auto_detail_error;
     END IF;

     /* COMMIT handling */
     IF p_commit = FND_API.G_TRUE THEN
       COMMIT;
     END IF;

     IF g_debug <= gme_debug.g_log_procedure THEN
       gme_debug.put_line (  ' Completed '
                           ||g_pkg_name
                           ||'.'
                           || l_api_name
                           || ' at '
                           || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS'));
     END IF;

   EXCEPTION
     WHEN auto_detail_error THEN
       ROLLBACK TO SAVEPOINT auto_detail_batch;
       gme_common_pvt.count_and_get(x_count   => x_message_count,
                                    p_encoded => FND_API.g_false,
                                    x_data    => x_message_list);
      WHEN fnd_api.g_exc_error THEN
       x_return_status := FND_API.g_ret_sts_error;
       ROLLBACK TO SAVEPOINT auto_detail_batch;
       gme_common_pvt.count_and_get(x_count   => x_message_count,
                                    p_encoded => FND_API.g_false,
                                    x_data    => x_message_list);
     WHEN OTHERS THEN
       ROLLBACK TO SAVEPOINT auto_detail_batch;
       gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END auto_detail_batch;

   /*================================================================================
    Procedure
      insert_batchstep_activity
    Description
      This procedure is used to insert an activity for a step

    Parameters
      p_batchstep_activity_rec (R)    activity to be inserted for a step
      p_batchstep_resource_tbl (R) one or more resources to be inserted for the activity
      p_org_code (O)              organization code
      p_batch_no (O)              batch number
      p_batchstep_no(O)           batch step number
      p_ignore_qty_below_cap (O)  controls - allow rsrc_qty going below rsrc capacity
      p_validate_flexfield (O)    Whether to validate the flexfields
      x_batchstep_activity_rec        newly inserted activity row, can be used for update etc
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
    HISTORY
     Sivakumar.G FPBug#4395561 16-NOV-2005
     Code changes made to set global flex field validate flag
  ================================================================================*/
   PROCEDURE insert_batchstep_activity (
      p_api_version              IN              NUMBER ,
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors,
      p_init_msg_list            IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_commit                   IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_org_code                 IN              VARCHAR2,
      p_batchstep_activity_rec   IN              gme_batch_step_activities%ROWTYPE,
      p_batchstep_resource_tbl   IN              gme_create_step_pvt.resources_tab,
      p_batch_no                 IN              VARCHAR2 := NULL,
      p_batchstep_no             IN              NUMBER := NULL,
      p_ignore_qty_below_cap     IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_validate_flexfield       IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      x_batchstep_activity_rec   OUT NOCOPY      gme_batch_step_activities%ROWTYPE,
      x_message_count            OUT NOCOPY      NUMBER,
      x_message_list             OUT NOCOPY      VARCHAR2,
      x_return_status            OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name            CONSTANT VARCHAR2 (30) := 'INSERT_BATCHSTEP_ACTIVITY';

      insert_activity_failed         EXCEPTION;
   BEGIN
      /* Set savepoint here */
      SAVEPOINT insert_activity_pub;

      IF (g_debug <> -1)
      THEN
         gme_debug.log_initialize ('InsertBatchstepActivity');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF (fnd_api.to_boolean (p_init_msg_list))
      THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (2.0,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
       gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
       RAISE fnd_api.g_exc_error;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Setup the common constants used accross the apis */
      IF (NOT gme_common_pvt.setup (p_org_id        => NULL,
                                    p_org_code      => p_org_code)
         )THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --FPBug#4395561 Start setting global flex validate variable
      IF p_validate_flexfield = FND_API.G_TRUE THEN
        gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
        gme_common_pvt.g_flex_validate_prof := 0;
      END IF;
      --FPBug#4395561 End

      gme_common_pvt.set_timestamp;
      gme_batchstep_act_pvt.insert_batchstep_activity (p_batchstep_activity_rec      => p_batchstep_activity_rec,
                                                       p_batchstep_resource_tbl      => p_batchstep_resource_tbl,
                                                       p_org_code                    => p_org_code,
                                                       p_batch_no                    => p_batch_no,
                                                       p_batchstep_no                => p_batchstep_no,
                                                       p_ignore_qty_below_cap        => p_ignore_qty_below_cap,
                                                       p_validate_flexfield          => p_validate_flexfield,
                                                       x_batchstep_activity_rec      => x_batchstep_activity_rec,
                                                       x_return_status               => x_return_status
                                                      );
      --FPBug#4395561 resetting global flex field validate
      gme_common_pvt.g_flex_validate_prof := 0;

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE insert_activity_failed;
      END IF;

      gme_api_pub.save_batch (x_return_status => x_return_status);

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
         COMMIT WORK;
      ELSE
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count,
                                    p_encoded      => fnd_api.g_false,
                                    x_data         => x_message_list
                                   );

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN insert_activity_failed THEN
         ROLLBACK TO SAVEPOINT insert_activity_pub;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list
                                      );
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT insert_activity_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list
                                      );
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT insert_activity_pub;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END insert_batchstep_activity;

   /*================================================================================
    Procedure
      update_batchstep_activity
    Description
      This procedure is used to update an activity for a step

    Parameters
      p_batchstep_activity (R)    activity to be updated
      p_org_code (O)              organization code
      p_batch_no (O)              batch number
      p_batchstep_no(O)           batch step number
      p_validate_flexfield (O)    Whether to validate the flexfields
      x_batchstep_activity        updated activity row
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
   HISTORY
     Sivakumar.G FPBug#4395561 16-NOV-2005
     Code changes made to set global flex field validate flag
  ================================================================================*/
   PROCEDURE update_batchstep_activity (
      p_api_version              IN              NUMBER ,
      p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors,
      p_init_msg_list            IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_commit                   IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_org_code                 IN              VARCHAR2,
      p_batchstep_activity_rec   IN              gme_batch_step_activities%ROWTYPE,
      p_batch_no                 IN              VARCHAR2 := NULL,
      p_batchstep_no             IN              NUMBER := NULL,
      p_validate_flexfield       IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      x_batchstep_activity_rec   OUT NOCOPY      gme_batch_step_activities%ROWTYPE,
      x_message_count            OUT NOCOPY      NUMBER,
      x_message_list             OUT NOCOPY      VARCHAR2,
      x_return_status            OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name   CONSTANT  VARCHAR2 (30) := 'UPDATE_BATCHSTEP_ACTIVITY';
      update_activity_failed EXCEPTION;
   BEGIN
      /* Set savepoint here */
      SAVEPOINT update_activity_pub;

      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('UpdateBatchstepActivity');
      END IF;
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF (fnd_api.to_boolean (p_init_msg_list)) THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (2.0,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Setup the common constants used accross the apis */
      IF (NOT gme_common_pvt.setup (p_org_id        => NULL,
                                    p_org_code      => p_org_code)) THEN
         RAISE fnd_api.g_exc_error;
      END IF;

       --FPBug#4395561 Start setting global flex validate variable
      IF p_validate_flexfield = FND_API.G_TRUE THEN
        gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
        gme_common_pvt.g_flex_validate_prof := 0;
      END IF;
      --FPBug#4395561 End

      gme_common_pvt.set_timestamp;
      gme_batchstep_act_pvt.update_batchstep_activity (p_batchstep_activity_rec      => p_batchstep_activity_rec,
                                                       p_org_code                    => p_org_code,
                                                       p_batch_no                    => p_batch_no,
                                                       p_batchstep_no                => p_batchstep_no,
                                                       p_validate_flexfield          => p_validate_flexfield,
                                                       x_batchstep_activity_rec      => x_batchstep_activity_rec,
                                                       x_return_status               => x_return_status
                                                      );
      --FPBug#4395561  resetting global flex-field validate variable
      gme_common_pvt.g_flex_validate_prof := 0;

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE update_activity_failed;
      END IF;

      gme_api_pub.save_batch (x_return_status => x_return_status);

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
           COMMIT WORK;
      ELSE
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count,
                                    p_encoded      => fnd_api.g_false,
                                    x_data         => x_message_list
                                   );
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
     WHEN update_activity_failed THEN
         ROLLBACK TO SAVEPOINT update_activity_pub;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list
                                      );
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT update_activity_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list
                                      );
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_activity_pub;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END update_batchstep_activity;

   /*================================================================================
    Procedure
      delete_batchstep_activity
    Description
      This procedure is used to delete an activity from a step.  Note that either the
      activity_id must be provided or the combination of organization_code, batch_no, batchstep_no,
      and activity in order to uniquely identify an activity to be deleted.

    Parameters
      p_batchstep_activity_id (O) activity_id to be deleted
      p_org_code (O)              organization code
      p_batch_no (O)              batch number
      p_batchstep_no(O)           batch step number
      p_activity(O)               activity
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
  ================================================================================*/
   PROCEDURE delete_batchstep_activity (
      p_api_version             IN              NUMBER := 2.0,
      p_validation_level        IN              NUMBER
            := gme_common_pvt.g_max_errors,
      p_init_msg_list           IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_commit                  IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_org_code                IN              VARCHAR2,
      p_batchstep_activity_id   IN              NUMBER := NULL,
      p_batch_no                IN              VARCHAR2 := NULL,
      p_batchstep_no            IN              NUMBER := NULL,
      p_activity                IN              VARCHAR2 := NULL,
      x_message_count           OUT NOCOPY      NUMBER,
      x_message_list            OUT NOCOPY      VARCHAR2,
      x_return_status           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name   CONSTANT  VARCHAR2 (30) := 'DELETE_BATCHSTEP_ACTIVITY';

      delete_activity_failed EXCEPTION;
   BEGIN
      /* Set savepoint here */
      SAVEPOINT delete_activity_pub;

      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('CreatePhantom');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF (fnd_api.to_boolean (p_init_msg_list))
      THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (2.0,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Setup the common constants used accross the apis */
      IF (NOT gme_common_pvt.setup (p_org_id        => NULL,
                                    p_org_code      => p_org_code)) THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.set_timestamp;
      gme_batchstep_act_pvt.delete_batchstep_activity (p_batchstep_activity_id      => p_batchstep_activity_id,
                                                       p_org_code                   => p_org_code,
                                                       p_batch_no                   => p_batch_no,
                                                       p_batchstep_no               => p_batchstep_no,
                                                       p_activity                   => p_activity,
                                                       x_return_status              => x_return_status
                                                      );
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE delete_activity_failed;
      END IF;

      gme_api_pub.save_batch (x_return_status => x_return_status);

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
        COMMIT;
      ELSE
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.count_and_get (x_count        => x_message_count,
                                    p_encoded      => fnd_api.g_false,
                                    x_data         => x_message_list
                                   );

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN delete_activity_failed THEN
         ROLLBACK TO SAVEPOINT delete_activity_pub;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list
                                      );
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT delete_activity_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count,
                                       p_encoded      => fnd_api.g_false,
                                       x_data         => x_message_list
                                      );
      WHEN OTHERS THEN
          ROLLBACK TO SAVEPOINT delete_activity_pub;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END delete_batchstep_activity;

/*************************************************************************/
   PROCEDURE convert_fpo (
      p_api_version          IN         NUMBER := 2.0,
      p_validation_level     IN         NUMBER := gme_common_pvt.g_max_errors,
      p_init_msg_list        IN         VARCHAR2 := fnd_api.g_false,
      p_commit               IN         VARCHAR2 := fnd_api.g_false,
      x_message_count        OUT NOCOPY NUMBER,
      x_message_list         OUT NOCOPY VARCHAR2,
      p_enforce_vldt_check   IN         VARCHAR2 := fnd_api.g_true,
      x_return_status        OUT NOCOPY VARCHAR2,
      p_org_code             IN         VARCHAR2 := NULL,
      p_batch_header         IN         gme_batch_header%ROWTYPE,
      x_batch_header         OUT NOCOPY gme_batch_header%ROWTYPE,
      p_batch_size           IN         NUMBER,
      p_num_batches          IN         NUMBER,
      p_validity_rule_id     IN         NUMBER,
      p_validity_rule_tab    IN         gme_common_pvt.recipe_validity_rule_tab,
      p_leadtime             IN         NUMBER DEFAULT 0,
      p_batch_offset         IN         NUMBER DEFAULT 0,
      p_offset_type          IN         NUMBER DEFAULT 0,
      p_plan_start_date      IN         gme_batch_header.plan_start_date%TYPE,
      p_plan_cmplt_date      IN         gme_batch_header.plan_cmplt_date%TYPE,
      p_use_shop_cal         IN         VARCHAR2 := fnd_api.g_false,
      p_contiguity_override  IN         VARCHAR2 := fnd_api.g_true,
      p_use_for_all          IN         VARCHAR2 := fnd_api.g_true
   ) IS
      l_api_name    CONSTANT VARCHAR2 (30)              := 'CONVERT_FPO';
      l_batch_header         gme_batch_header%ROWTYPE;

      convert_fpo_failed     EXCEPTION;
   BEGIN
      /* Set the savepoint before proceeding */
      SAVEPOINT convert_fpo;

      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('ConvertFPO');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'convertFPO'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;


      IF (p_batch_header.organization_id IS NULL AND p_org_code IS NULL) THEN
         fnd_message.set_name ('INV', 'INV_ORG_REQUIRED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Use local variable, so that user does not have to pass batch_type value 10 */
      l_batch_header := p_batch_header;
      l_batch_header.batch_type := 10;

      /* Check for phantom batch */
      IF gme_phantom_pvt.is_phantom (
            p_batch_header =>       l_batch_header,
            x_return_status =>      x_return_status
         ) THEN
         gme_common_pvt.log_message ('PM_INVALID_PHANTOM_ACTION');
         RAISE fnd_api.g_exc_error;
      ELSIF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' Do setup for org using org_code of '||
                             p_org_code ||
                             ' and organization_id of '||
                             l_batch_header.organization_id);
      END IF;

      /* Setup the common constants used accross the apis */
      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup (p_org_id        => l_batch_header.organization_id
                              ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         RAISE fnd_api.g_exc_error;
      ELSE
         l_batch_header.organization_id := gme_common_pvt.g_organization_id;
      END IF;

      gme_common_pvt.set_timestamp;

      gme_convert_fpo_pvt.convert_fpo_main (
         p_batch_header =>            l_batch_header,
         p_batch_size =>              p_batch_size,
         p_num_batches =>             p_num_batches,
         p_validity_rule_id =>        p_validity_rule_id,
         p_validity_rule_tab =>       p_validity_rule_tab,
         p_enforce_vldt_check =>      p_enforce_vldt_check,
         p_leadtime =>                p_leadtime,
         p_batch_offset =>            p_batch_offset,
         p_offset_type =>             p_offset_type,
         p_plan_start_date =>         p_plan_start_date,
         p_plan_cmplt_date =>         p_plan_cmplt_date,
         p_use_shop_cal =>            p_use_shop_cal,
         p_contiguity_override =>     p_contiguity_override,
         x_return_status =>           x_return_status,
         x_batch_header =>            x_batch_header,
         p_use_for_all =>             p_use_for_all
      );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF p_commit = fnd_api.g_true THEN
         gme_api_pub.save_batch (p_header_id          => NULL
                                ,p_table              => NULL
                                ,p_commit             => p_commit
                                ,x_return_status      => x_return_status);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE fnd_api.g_exc_error;
         ELSE
           gme_common_pvt.log_message ('GME_API_BATCH_CREATED');
         END IF;
        END IF;
      ELSE
         RAISE convert_fpo_failed;
      END IF;

      gme_common_pvt.count_and_get (x_count =>        x_message_count,
                                    p_encoded =>      FND_API.g_false,
                                    x_data =>         x_message_list);
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ( 'Completed ' || l_api_name || ' at ' || TO_CHAR
         (SYSDATE, 'MM/DD/YYYY HH24:MI:SS'));
      END IF;
   EXCEPTION
      WHEN convert_fpo_failed THEN
         ROLLBACK TO SAVEPOINT convert_fpo;
         x_batch_header := NULL;
         gme_common_pvt.count_and_get (x_count =>        x_message_count,
                                       p_encoded =>      FND_API.g_false,
				       x_data =>         x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT convert_fpo;
         x_batch_header := NULL;
	 x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count =>        x_message_count,
                                       p_encoded =>      FND_API.g_false,
                                       x_data =>         x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT convert_fpo;
         x_batch_header := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END convert_fpo;

   /*================================================================================
    Procedure
      create_pending_product_lot
    Description
      This procedure is used to create a pending product lot record for a specified
      material detail record.
      Following key sequences can be specified:
      material_detail_id OR
      batch_id, line_no, line_type OR
      batch_no, org_code, line_no, line_type (batch_type is assumed to be Batch)

    Parameters
      p_batch_header_rec (O)      batch header record
      p_org_code (O)              organization code
      p_material_detail_rec (O)   material detail record
      p_pending_product_lots_rec (R) pending product lots record
      p_create_lot (O)            This indicates whether to create the lot if the lot does
                                  not exist.  Default to False, do not create the lot.  This
                                  applies to products and by-products only.
      p_generate_lot (O)          This indicates to generate a lot if there is nothing passed
                                  in the lot number field of p_pending_product_lots_rec.  Default
                                  to False, do not generate the lot.  This applies to products and
                                  by-products only.
      p_generate_parent_lot (O)   This indicates to generate a parent lot.  Default
                                  to False, do not generate the parent lot.  This applies to products and
                                  by-products only.
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error

    Modification History
      Bug#4486074 Namit S. Added the p_expiration_Date parameter.

      18-JUN-2009 G. Muratore     Bug 8490219
        Conditionalize call to save batch based on p_commit_parameter.
  ================================================================================*/
    PROCEDURE create_pending_product_lot
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_org_code                 IN              VARCHAR2
     ,p_create_lot               IN              VARCHAR2 := fnd_api.g_false
     ,p_generate_lot             IN              VARCHAR2 := fnd_api.g_false
     ,p_generate_parent_lot      IN              VARCHAR2 := fnd_api.g_false
     ,p_material_detail_rec      IN              gme_material_details%ROWTYPE
      /* nsinghi bug#4486074 Added the p_expiration_dt parameter. */
     ,p_expiration_date            IN              mtl_lot_numbers.expiration_date%TYPE := NULL
     ,p_pending_product_lots_rec IN              gme_pending_product_lots%ROWTYPE
     ,x_pending_product_lots_rec OUT NOCOPY      gme_pending_product_lots%ROWTYPE)
   IS
      l_api_name           CONSTANT VARCHAR2 (30)  := 'CREATE_PENDING_PRODUCT_LOT';

      l_pending_product_lots_rec gme_pending_product_lots%ROWTYPE;
      l_material_detail_rec      gme_material_details%ROWTYPE;
      l_in_material_detail_rec   gme_material_details%ROWTYPE;
      l_batch_header_rec         gme_batch_header%ROWTYPE;
      l_batch_id                 NUMBER;
      l_matl_dtl_id              NUMBER;

      error_create_pp_lot        EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('CreatePendingProdLot');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT create_pending_product_lot;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'create_pending_prod_lot'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      l_batch_id := NVL(p_pending_product_lots_rec.batch_id,
                        NVL(p_material_detail_rec.batch_id, p_batch_header_rec.batch_id));
      l_matl_dtl_id := NVL(p_pending_product_lots_rec.material_detail_id, p_material_detail_rec.material_detail_id);

      l_in_material_detail_rec := p_material_detail_rec;
      l_in_material_detail_rec.batch_id := l_batch_id;
      l_in_material_detail_rec.material_detail_id := l_matl_dtl_id;

      /* Retrieve Batch Header and Material Detail Record */
      gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> l_in_material_detail_rec
                          ,p_org_code                 	=> p_org_code
                          ,p_batch_no                 	=> p_batch_header_rec.batch_no
                          ,p_batch_type               	=> gme_common_pvt.g_doc_type_batch
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_material_detail_rec
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      -- Validations
      gme_pending_product_lots_pvt.validate_material_for_create
                        (p_batch_header_rec          => l_batch_header_rec
                        ,p_material_detail_rec       => l_material_detail_rec
                        ,x_return_status             => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_pending_product_lots_pvt.validate_record_for_create
                        (p_material_detail_rec        => l_material_detail_rec
                        ,p_pending_product_lots_rec   => p_pending_product_lots_rec
                        ,p_create_lot                 => p_create_lot
                        ,p_generate_lot               => p_generate_lot
                        ,p_generate_parent_lot        => p_generate_parent_lot
                        ,x_pending_product_lots_rec   => l_pending_product_lots_rec
                        ,x_return_status              => x_return_status
                         /* nsinghi bug#4486074 Added the following parameter. */
                        ,p_expiration_date            => p_expiration_date);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Invoke main */
      gme_api_main.create_pending_product_lot
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_org_id                      => l_batch_header_rec.organization_id
                         ,p_pending_product_lots_rec    => l_pending_product_lots_rec
                         ,x_pending_product_lots_rec    => x_pending_product_lots_rec);


      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Return status from gme_api_main.create_pending_product_lot is '
             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_create_pp_lot;
      END IF;

      -- Bug 8490219 - Only call save batch is commit is TRUE.
      IF p_commit = fnd_api.g_true THEN
         gme_api_pub.save_batch
                          (p_header_id          => gme_common_pvt.g_transaction_header_id
                          ,p_table              => 1
                          ,p_commit             => p_commit
                          ,x_return_status      => x_return_status);

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line
                            (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Return status from gme_api_pub.save_batch is '
                             || x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

   EXCEPTION
      WHEN error_create_pp_lot THEN
         ROLLBACK TO SAVEPOINT create_pending_product_lot;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT create_pending_product_lot;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_pending_product_lot;
         gme_when_others (	p_api_name              => l_api_name
              				  ,x_message_count        => x_message_count
     				           ,x_message_list         => x_message_list
     				           ,x_return_status   	=> x_return_status );
   END create_pending_product_lot;

   /*================================================================================
    Procedure
      update_pending_product_lot
    Description
      This procedure is used to update a pending product lot record for a specified
      pending product lot record
      Following key sequences can be specified:
      pending_product_lot_id OR
      batch_id, line_no, line_type, sequence OR
      batch_no, org_code, line_no, line_type, sequence (batch_type is assumed to be Batch)

    Parameters
      p_batch_header_rec (O)      batch header record
      p_org_code (O)              organization code
      p_material_detail_rec (O)   material detail record
      p_pending_product_lots_rec (R) pending product lots record
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
  ================================================================================*/

  PROCEDURE update_pending_product_lot
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_org_code                 IN              VARCHAR2
     ,p_material_detail_rec      IN              gme_material_details%ROWTYPE
     ,p_pending_product_lots_rec IN              gme_pending_product_lots%ROWTYPE
     ,x_pending_product_lots_rec OUT NOCOPY      gme_pending_product_lots%ROWTYPE)
   IS
      l_api_name           CONSTANT VARCHAR2 (30)  := 'UPDATE_PENDING_PRODUCT_LOT';

      l_pending_product_lots_rec    gme_pending_product_lots%ROWTYPE;
      l_db_pending_product_lots_rec gme_pending_product_lots%ROWTYPE;
      l_in_material_detail_rec      gme_material_details%ROWTYPE;
      l_in_batch_header_rec         gme_batch_header%ROWTYPE;
      l_material_detail_rec         gme_material_details%ROWTYPE;
      l_batch_header_rec            gme_batch_header%ROWTYPE;
      l_batch_id                    NUMBER;
      l_matl_dtl_id                 NUMBER;

      error_update_pp_lot        EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('UpdatePendingProdLot');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT update_pending_product_lot;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'update_pending_prod_lot'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_pending_product_lots_rec.pending_product_lot_id IS NOT NULL THEN
        IF NOT gme_pending_product_lots_dbl.fetch_row
             (p_pending_product_lots_rec   => p_pending_product_lots_rec
             ,x_pending_product_lots_rec   => l_db_pending_product_lots_rec)  THEN
          x_return_status := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;
        END IF;

        l_in_material_detail_rec.material_detail_id := l_db_pending_product_lots_rec.material_detail_id;
        l_in_material_detail_rec.batch_id := l_db_pending_product_lots_rec.batch_id;
        gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> l_in_material_detail_rec
                          ,p_org_code                 	=> NULL
                          ,p_batch_no                 	=> NULL
                          ,p_batch_type               	=> NULL
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_material_detail_rec
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      ELSE
        l_batch_id := NVL(p_pending_product_lots_rec.batch_id,
                          NVL(p_material_detail_rec.batch_id, p_batch_header_rec.batch_id));
        l_matl_dtl_id := NVL(p_pending_product_lots_rec.material_detail_id, p_material_detail_rec.material_detail_id);

        l_in_material_detail_rec := p_material_detail_rec;
        l_in_material_detail_rec.batch_id := l_batch_id;
        l_in_material_detail_rec.material_detail_id := l_matl_dtl_id;

        /* Retrieve Batch Header and Material Detail Record */
        gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> l_in_material_detail_rec
                          ,p_org_code                 	=> p_org_code
                          ,p_batch_no                 	=> p_batch_header_rec.batch_no
                          ,p_batch_type               	=> gme_common_pvt.g_doc_type_batch
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_material_detail_rec
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- Validations
      gme_pending_product_lots_pvt.validate_material_for_update
                        (p_batch_header_rec          => l_batch_header_rec
                        ,p_material_detail_rec       => l_material_detail_rec
                        ,x_return_status             => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_pending_product_lots_pvt.validate_record_for_update
                        (p_material_detail_rec             => l_material_detail_rec
                        ,p_db_pending_product_lots_rec     => l_db_pending_product_lots_rec
                        ,p_pending_product_lots_rec        => p_pending_product_lots_rec
                        ,x_pending_product_lots_rec        => l_pending_product_lots_rec
                        ,x_return_status                   => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Invoke main */
      gme_api_main.update_pending_product_lot
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_org_id                      => l_batch_header_rec.organization_id
                         ,p_pending_product_lots_rec    => l_pending_product_lots_rec
                         ,x_pending_product_lots_rec    => x_pending_product_lots_rec);


      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Return status from gme_api_main.update_pending_product_lot is '
             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_update_pp_lot;
      END IF;

      /* Invoke save_batch */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' About to invoke save_batch with header_id of '
                          || gme_common_pvt.g_transaction_header_id);
      END IF;

      gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' Return status from gme_api_pub.save_batch is '
                          || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN error_update_pp_lot THEN
         ROLLBACK TO SAVEPOINT update_pending_product_lot;
         x_pending_product_lots_rec :=  NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT update_pending_product_lot;
         x_pending_product_lots_rec :=  NULL;
	      x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT update_pending_product_lot;
        x_pending_product_lots_rec :=  NULL;
	     gme_when_others (	p_api_name              => l_api_name
     	  			           ,x_message_count        => x_message_count
     				           ,x_message_list         => x_message_list
     				           ,x_return_status   	=> x_return_status );
   END update_pending_product_lot;

   /*================================================================================
    Procedure
      Delete_pending_product_lot
    Description
      This procedure is used to delete a pending product lot record for a specified
      pending product lot record
      Following key sequences can be specified:
      pending_product_lot_id OR
      batch_id, line_no, line_type, sequence OR
      batch_no, org_code, line_no, line_type, sequence (batch_type is assumed to be Batch)

    Parameters
      p_batch_header_rec (O)      batch header record
      p_org_code (O)              organization code
      p_material_detail_rec (O)   material detail record
      p_pending_product_lots_rec (R) pending product lots record
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
  ================================================================================*/

  PROCEDURE delete_pending_product_lot
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_org_code                 IN              VARCHAR2
     ,p_material_detail_rec      IN              gme_material_details%ROWTYPE
     ,p_pending_product_lots_rec IN              gme_pending_product_lots%ROWTYPE)
   IS
      l_api_name           CONSTANT VARCHAR2 (30)  := 'DELETE_PENDING_PRODUCT_LOT';

      l_pending_product_lots_rec       gme_pending_product_lots%ROWTYPE;
      l_db_pending_product_lots_rec    gme_pending_product_lots%ROWTYPE;
      l_in_material_detail_rec         gme_material_details%ROWTYPE;
      l_in_batch_header_rec            gme_batch_header%ROWTYPE;
      l_material_detail_rec            gme_material_details%ROWTYPE;
      l_batch_header_rec               gme_batch_header%ROWTYPE;
      l_batch_id                       NUMBER;
      l_matl_dtl_id                    NUMBER;

      invalid_version            EXCEPTION;
      setup_failure              EXCEPTION;
      fetch_error                EXCEPTION;
      batch_save_failed          EXCEPTION;
      error_validation           EXCEPTION;
      error_delete_pp_lot        EXCEPTION;

   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('DeletePendingProdLot');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT delete_pending_product_lot;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'delete_pending_prod_lot'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_pending_product_lots_rec.pending_product_lot_id IS NOT NULL THEN
        IF NOT gme_pending_product_lots_dbl.fetch_row
             (p_pending_product_lots_rec   => p_pending_product_lots_rec
             ,x_pending_product_lots_rec   => l_db_pending_product_lots_rec)  THEN
          x_return_status := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;
        END IF;

        l_in_material_detail_rec.material_detail_id := l_db_pending_product_lots_rec.material_detail_id;
        l_in_material_detail_rec.batch_id := l_db_pending_product_lots_rec.batch_id;
        gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> l_in_material_detail_rec
                          ,p_org_code                 	=> NULL
                          ,p_batch_no                 	=> NULL
                          ,p_batch_type               	=> NULL
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_material_detail_rec
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
     ELSE
        l_batch_id := NVL(p_pending_product_lots_rec.batch_id,
                          NVL(p_material_detail_rec.batch_id, p_batch_header_rec.batch_id));
        l_matl_dtl_id := NVL(p_pending_product_lots_rec.material_detail_id, p_material_detail_rec.material_detail_id);

        l_in_material_detail_rec := p_material_detail_rec;
        l_in_material_detail_rec.batch_id := l_batch_id;
        l_in_material_detail_rec.material_detail_id := l_matl_dtl_id;

        /* Retrieve Batch Header and Material Detail Record */
        gme_common_pvt.Validate_material_detail
                          (p_material_detail_rec      	=> l_in_material_detail_rec
                          ,p_org_code                 	=> p_org_code
                          ,p_batch_no                 	=> p_batch_header_rec.batch_no
                          ,p_batch_type               	=> gme_common_pvt.g_doc_type_batch
                          ,x_batch_header_rec         	=> l_batch_header_rec
                          ,x_material_detail_rec      	=> l_material_detail_rec
                          ,x_message_count      	=> x_message_count
     			  ,x_message_list        	=> x_message_list
                          ,x_return_status       	=> x_return_status );
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch mateiral validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
     END IF;
      -- Validations
      gme_pending_product_lots_pvt.validate_material_for_delete
                        (p_batch_header_rec          => l_batch_header_rec
                        ,p_material_detail_rec       => l_material_detail_rec
                        ,x_return_status             => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_pending_product_lots_pvt.validate_record_for_delete
                        (p_material_detail_rec             => l_material_detail_rec
                        ,p_db_pending_product_lots_rec     => l_db_pending_product_lots_rec
                        ,p_pending_product_lots_rec        => p_pending_product_lots_rec
                        ,x_pending_product_lots_rec        => l_pending_product_lots_rec
                        ,x_return_status                   => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Invoke main */
      gme_api_main.delete_pending_product_lot
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_org_id                      => l_batch_header_rec.organization_id
                         ,p_pending_product_lots_rec    => l_pending_product_lots_rec);


      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Return status from gme_api_main.delete_pending_product_lot is '
             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_delete_pp_lot;
      END IF;

      /* Invoke save_batch */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' About to invoke save_batch with header_id of '
                          || gme_common_pvt.g_transaction_header_id);
      END IF;

      gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' Return status from gme_api_pub.save_batch is '
                          || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

   EXCEPTION
      WHEN error_delete_pp_lot THEN
         ROLLBACK TO SAVEPOINT delete_pending_product_lot;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT delete_pending_product_lot;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT delete_pending_product_lot;
        gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END delete_pending_product_lot;

   /*================================================================================
    Procedure
      unrelease_batch
    Description
      This procedure is used to unrelease a WIP batch.
      One of the following key sequences must be specified:
      batch_id OR
      batch_no, org_code  batch_type assumed to be batch

    Parameters
      p_batch_id (O)              batch ID to identify the batch
      p_batch_no (O)              batch number to identify the batch in combination with p_org_code
      p_org_code (O)              organization code to identigy the batch is combination with p_batch_no
      p_create_resv_pend_lots (R) indicates whether to create reservations or pending product lots
                                  depending on the line type.
      p_continue_lpn_txn (O)     Indicates whether to continue processing a
batch when product or byproduct has lpn transaction.
      x_batch_header_rec          Output batch header record after unrelease
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
  ================================================================================*/
 PROCEDURE unrelease_batch
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_org_code                 IN              VARCHAR2
     ,p_create_resv_pend_lots    IN              NUMBER
     ,p_continue_lpn_txn         IN              VARCHAR2 := 'N'
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE)
   IS
      l_api_name           CONSTANT VARCHAR2 (30)  := 'UNRELEASE_BATCH';

      l_in_batch_header_rec       gme_batch_header%ROWTYPE;
      l_batch_header_rec          gme_batch_header%ROWTYPE;

      error_unrelease_batch       EXCEPTION;
      -- Bug 6437252
      x_lpn_txns                 NUMBER;
      l_continue_lpn_txn         VARCHAR2(1);
      CURSOR get_lpn_txns(p_batch_id IN NUMBER) IS
         SELECT  COUNT(1)
         FROM mtl_material_transactions mmt, gme_material_details mtl
         WHERE NVL(transfer_lpn_id,0) > 0
           AND TRANSACTION_SOURCE_ID = p_batch_id
           AND transaction_action_id = 31
           AND transaction_type_id IN (44, 1002)
           AND mmt.transaction_source_id = mtl.batch_id
           AND mmt.inventory_item_id = mtl.inventory_item_id
           AND mmt.transaction_id NOT IN (
           SELECT transaction_id1
                    FROM gme_transaction_pairs
                    WHERE batch_id = p_batch_id
                    AND pair_type = 1);

   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('UnreleaseBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT unrelease_batch;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'unrelease_batch'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;


      --l_in_batch_header_rec.batch_type := gme_common_pvt.g_doc_type_batch;
      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;


      -- Validations
      gme_unrelease_batch_pvt.validate_batch_for_unrelease
               (p_batch_hdr_rec        => l_batch_header_rec
               ,x_return_status        => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;

      /* Invoke main */
      gme_api_main.unrelease_batch
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_batch_header_rec            => l_batch_header_rec
                         ,x_batch_header_rec            => x_batch_header_rec
                         ,p_create_resv_pend_lots       => p_create_resv_pend_lots);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
          ' Return status from main.unrelease_batch is '|| x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_unrelease_batch;
      END IF;

      /* Invoke save_batch */
        gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
                             ' Return status from gme_api_pub.save_batch is '
                             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

   EXCEPTION
      WHEN error_unrelease_batch THEN
         ROLLBACK TO SAVEPOINT unrelease_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT unrelease_batch;
         x_batch_header_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT unrelease_batch;
         x_batch_header_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END unrelease_batch;

   /*================================================================================
    Procedure
      unrelease_step
    Description
      This procedure is used to unrelease a WIP step.
      One of the following key sequences must be specified:
      batchstep_id OR
      batch_id, batchstep_no OR
      batch_no, org_code, batchstep_no  batch_type assumed to be batch

    Parameters
      p_batchstep_id (O)          batch step ID to identify the step
      p_batch_id (O)              batch ID to identify the step
      p_batchstep_no (O)          step number to identify the step
      p_batch_no (O)              batch number to identify the step
      p_org_code (O)              organization code to identify the step
      p_create_resv_pend_lots (R) indicates whether to create reservations or pending product lots
                                  depending on the line type associated to the step.
      x_batch_step_rec            Output step record after unrelease
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
  ================================================================================*/
  PROCEDURE unrelease_step
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_no                 IN              VARCHAR2
     ,p_org_code                 IN              VARCHAR2
     ,p_create_resv_pend_lots    IN              NUMBER
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE)
   IS
      l_api_name           CONSTANT VARCHAR2 (30)  := 'UNRELEASE_STEP';

      l_in_batch_step_rec         gme_batch_steps%ROWTYPE;
      l_batch_step_rec            gme_batch_steps%ROWTYPE;
      l_in_batch_header_rec       gme_batch_header%ROWTYPE;
      l_batch_header_rec          gme_batch_header%ROWTYPE;

      error_unrelease_step        EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('UnreleaseStep');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT unrelease_step;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'unrelease_step'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Input parameters */
      gme_common_pvt.Validate_batch_step (
              p_batch_step_rec     =>      p_batch_step_rec
             ,p_org_code           =>      p_org_code
             ,p_batch_no           =>      p_batch_no
             ,x_batch_step_rec     =>      l_batch_step_rec
             ,x_batch_header_rec   =>      l_batch_header_rec
             ,x_message_count      => x_message_count
             ,x_message_list       => x_message_list
             ,x_return_status      => x_return_status) ;

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch step validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      -- Validations
      gme_unrelease_step_pvt.validate_step_for_unrelease
               (p_batch_hdr_rec        => l_batch_header_rec
               ,p_batch_step_rec       => l_batch_step_rec
               ,x_return_status        => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;

      /* Invoke main */
      gme_api_main.unrelease_step
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_batch_step_rec              => l_batch_step_rec
                         ,p_batch_header_rec            => l_batch_header_rec
                         ,x_batch_step_rec              => x_batch_step_rec
                         ,p_create_resv_pend_lots       => p_create_resv_pend_lots);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Return status from gme_api_main.unrelease_step is '
             || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_unrelease_step;
      END IF;

      /* Invoke save_batch */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' About to invoke save_batch with header_id of '
                          || gme_common_pvt.g_transaction_header_id);
      END IF;

      gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' Return status from gme_api_pub.save_batch is '
                          || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

   EXCEPTION
      WHEN error_unrelease_step THEN
         ROLLBACK TO SAVEPOINT unrelease_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT unrelease_step;
         x_batch_step_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT unrelease_step;
         x_batch_step_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END unrelease_step;

   /*================================================================================
    Procedure
      complete_batch
    Description
      This procedure is used to complete a batch
      One of the following key sequences must be specified:
      batch_id OR
      batch_no, org_code, batch_type assumed to be batch

    Parameters
      p_batch_header_rec (O)      batch header to identify the batch to complete;
      p_org_code (O)              organization code to identify the batch is conjunction with batch_no in p_batch_header_rec
      p_ignore_exception (O)      indicates whether to ignore exceptions; if exceptions are ignored,
                                  x_exception_material_tbl won't be populated even if exceptions were found
      p_validate_flexfields (O)   indicates whether to validate flexfields... Defaults to fnd_api.g_false;
                                  this is used for direct completion only because of release batch
      x_batch_header_rec          Output batch header record after complete
      x_exception_material_tbl    Batch exceptions found in complete batch
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
                                  X - Batch Exception
    History
    =======
      G. Muratore   18-JUN-09  Bug 8312658
         Make a call to purge_batch_exceptions to remove any pending reservations.
  ================================================================================*/
  PROCEDURE complete_batch
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_org_code                 IN              VARCHAR2
     ,p_ignore_exception         IN              VARCHAR2 := fnd_api.g_false
     ,p_validate_flexfields      IN              VARCHAR2 := fnd_api.g_false
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab)
   IS
      l_api_name             CONSTANT VARCHAR2 (30)  := 'COMPLETE_BATCH';

      l_in_batch_header_rec  gme_batch_header%ROWTYPE;
      l_batch_header_rec     gme_batch_header%ROWTYPE;
      l_exception_material_tbl   gme_common_pvt.exceptions_tab;

      error_complete_batch   EXCEPTION;
      purge_exception_err    EXCEPTION;

   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('CompleteBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT complete_batch;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'complete_batch'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;


      --l_in_batch_header_rec.batch_type := gme_common_pvt.g_doc_type_batch;
       gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;

      -- Validations
      IF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending THEN
        IF p_validate_flexfields = fnd_api.g_true THEN
          gme_common_pvt.g_flex_validate_prof := 1;
        ELSE
          gme_common_pvt.g_flex_validate_prof := 0;
        END IF;

        l_in_batch_header_rec := l_batch_header_rec;
        l_in_batch_header_rec.actual_start_date := p_batch_header_rec.actual_start_date;
        -- call release batch validation... output batch header will have actual start date filled in
        NULL;

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        -- reset flex global
        gme_common_pvt.g_flex_validate_prof := 0;
      END IF;

      l_in_batch_header_rec := l_batch_header_rec;
      -- Bug 6828656
      -- Reassign actual_start_date
      l_in_batch_header_rec.actual_start_date := p_batch_header_rec.actual_start_date;
      l_in_batch_header_rec.actual_cmplt_date := p_batch_header_rec.actual_cmplt_date;
      -- output batch header contains the actual complete date
       gme_complete_batch_pvt.validate_batch_for_complete
                                        (p_batch_header_rec     => l_in_batch_header_rec
                                        ,x_batch_header_rec     => l_batch_header_rec
                                        ,x_return_status        => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;

      /* Invoke main */
      gme_api_main.complete_batch
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_batch_header_rec            => l_batch_header_rec
                         ,x_batch_header_rec            => x_batch_header_rec
                         ,x_exception_material_tbl      => l_exception_material_tbl
 			 ,p_ignore_exception            => p_ignore_exception);    --Bug#5186328

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Return status from gme_api_main.complete_batch is '
             || x_return_status);
      END IF;

      IF p_ignore_exception = fnd_api.g_true AND x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := fnd_api.g_ret_sts_success;
      ELSIF x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_exception_material_tbl := l_exception_material_tbl;
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_complete_batch;
      END IF;

      -- Bug 8312658 - Delete all remaining reservations including for phantom batches.
      gme_cancel_batch_pvt.purge_batch_exceptions (p_batch_header_rec         => x_batch_header_rec
                                                  ,p_delete_invis_mo          => 'F'
                                                  ,p_delete_reservations      => 'T'
                                                  ,p_delete_trans_pairs       => 'F'
                                                  ,p_recursive                => 'R'
                                                  ,x_return_status            => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         IF (g_debug <= gme_debug.g_log_procedure) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'purge_exception_err');
         END IF;

         RAISE purge_exception_err;
      END IF;

      /* Invoke save_batch */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' About to invoke save_batch with header_id of '
                          || gme_common_pvt.g_transaction_header_id);
      END IF;

      gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' Return status from gme_api_pub.save_batch is '
                          || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

   EXCEPTION
      WHEN error_complete_batch THEN
         ROLLBACK TO SAVEPOINT complete_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT complete_batch;
         x_batch_header_rec := NULL;
	      x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN purge_exception_err THEN
         ROLLBACK TO SAVEPOINT complete_batch;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT complete_batch;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END complete_batch;

   /*================================================================================
    Procedure
      complete_step
    Description
      This procedure is used to complete a step
      One of the following key sequences must be specified:
      batchstep_id
      batch_id, batchstep_no OR
      batch_no, org_code, batchstep_no batch_type assumed to be batch

    Parameters
      p_batch step_rec (O)        batch step to identify the step to complete.
      p_batch_no (O)              batch_no to identify the step
      p_org_code (O)              organization code to identify the step is conjunction with batch_no in p_batch_header_rec
      p_ignore_exception (O)      indicates whether to ignore exceptions; if exceptions are ignored,
                                  x_exception_material_tbl won't be populated ever if exceptions were found
      p_override_quality (O)      Override quality indicator; defaults to fnd_api.g_false
      p_validate_flexfields (O)   indicates whether to validate flexfields... Defaults to fnd_api.g_false;
                                  this is used for direct step completion (pending_batch) only, because of release batch
      x_batch_step_rec            Output batch step record after complete
      x_exception_material_tbl    Material exceptions found in complete step (only those associated to step)
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
                                  X - Batch Exception
  ================================================================================*/
  PROCEDURE complete_step
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_no                 IN              VARCHAR2
     ,p_org_code                 IN              VARCHAR2
     ,p_ignore_exception         IN              VARCHAR2 := fnd_api.g_false
     ,p_override_quality         IN              VARCHAR2 := fnd_api.g_false
     ,p_validate_flexfields      IN              VARCHAR2 := fnd_api.g_false
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab)
   IS
      l_api_name             CONSTANT VARCHAR2 (30)  := 'COMPLETE_STEP';

      l_in_batch_step_rec    gme_batch_steps%ROWTYPE;
      l_batch_step_rec       gme_batch_steps%ROWTYPE;
      l_in_batch_header_rec  gme_batch_header%ROWTYPE;
      l_batch_header_rec     gme_batch_header%ROWTYPE;
      l_calc_batch_start_date DATE;

      l_exception_material_tbl   gme_common_pvt.exceptions_tab;

      error_complete_step    EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('CompleteStep');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT complete_step;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'complete_step'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Input parameters */
      gme_common_pvt.Validate_batch_step (
              p_batch_step_rec     =>      p_batch_step_rec
             ,p_org_code           =>      p_org_code
             ,p_batch_no           =>      p_batch_no
             ,x_batch_step_rec     =>      l_batch_step_rec
             ,x_batch_header_rec   =>      l_batch_header_rec
             ,x_message_count      => x_message_count
             ,x_message_list       => x_message_list
             ,x_return_status      => x_return_status) ;

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch step validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
       -- Validations

      IF l_batch_header_rec.batch_type = gme_common_pvt.g_doc_type_fpo THEN
        gme_common_pvt.log_message('GME_API_INVALID_BATCH_TYPE');
        RAISE fnd_api.g_exc_error;
      END IF;

      -- current Step Status must be Pending or WIP
      IF (l_batch_step_rec.step_status NOT IN (gme_common_pvt.g_step_pending, gme_common_pvt.g_step_WIP)) THEN
        gme_common_pvt.log_message('GME_API_INV_STAT_STEP_CERT');
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_batch_header_rec.batch_status NOT IN
                         (gme_common_pvt.g_batch_pending, gme_common_pvt.g_batch_wip) THEN
        gme_common_pvt.log_message ('GME_API_INV_BATCH_CERT_STEP');
        RAISE fnd_api.g_exc_error;
      END IF;

      --Bug#5109119 checking for parameter value 1 instead of Y
      IF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending AND
         (gme_common_pvt.g_step_controls_batch_sts_ind <> 1 OR
          l_batch_header_rec.parentline_id IS NOT NULL) THEN
        gme_common_pvt.log_message ('GME_API_INV_BATCH_CMPL_STEP');
        RAISE fnd_api.g_exc_error;
      END IF;

      l_in_batch_step_rec := l_batch_step_rec;
      l_in_batch_step_rec.actual_cmplt_date := p_batch_step_rec.actual_cmplt_date;
      -- output step contains the actual complete date
      gme_complete_batch_step_pvt.validate_step_for_complete
                                        (p_batch_header_rec     => l_batch_header_rec
                                        ,p_batch_step_rec       => l_in_batch_step_rec
                                        ,p_override_quality     => p_override_quality
                                        ,x_batch_step_rec       => l_batch_step_rec
                                        ,x_return_status        => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF l_batch_step_rec.step_status = gme_common_pvt.g_step_pending THEN
        -- call release step validation; use step actual cmplt date
        -- if step actual start date is NULL and batch is Pending
        NULL;
      END IF;  -- IF l_batch_step_rec.step_status = gme_common_pvt.g_step_pending

      gme_complete_batch_step_pvt.validate_step_cmplt_date
                        (p_batch_step_rec       => l_batch_step_rec
                        ,p_batch_header_rec     => l_batch_header_rec
                        ,x_batch_start_date     => l_calc_batch_start_date
                        ,x_return_status        => x_return_status);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- needed for release batch AND/OR release step (release step is in private to take care of dependent steps)
      IF p_validate_flexfields = fnd_api.g_true THEN
        gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
        gme_common_pvt.g_flex_validate_prof := 0;
      END IF;

      IF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending THEN
        l_in_batch_header_rec := l_batch_header_rec;
        l_in_batch_header_rec.actual_start_date := l_calc_batch_start_date;
        -- call release batch validation...
        NULL;

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;

      /* Invoke main */
      gme_api_main.complete_step
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_batch_step_rec              => l_batch_step_rec
                         ,p_batch_header_rec            => l_batch_header_rec
                         ,x_batch_step_rec              => x_batch_step_rec
                         ,x_exception_material_tbl      => l_exception_material_tbl
			 ,p_ignore_exception            => p_ignore_exception);  --Bug#5186328

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ' Return status from gme_api_main.complete_step is '
             || x_return_status);
      END IF;

      IF p_ignore_exception = fnd_api.g_true AND x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := fnd_api.g_ret_sts_success;
      ELSIF x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_exception_material_tbl := l_exception_material_tbl;
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_complete_step;
      END IF;
     -- reset flex global
      gme_common_pvt.g_flex_validate_prof := 0;

      /* Invoke save_batch */
       gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ' Return status from gme_api_pub.save_batch is '
                          || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN error_complete_step THEN
         ROLLBACK TO SAVEPOINT complete_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT complete_step;
         x_batch_step_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT complete_step;
         x_batch_step_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END complete_step;

   /*================================================================================
    Procedure
      release_batch
    Description
      This procedure is used to release a batch
      One of the following key sequences must be specified:
      batch_id OR
      batch_no, org_code, batch_type assumed to be batch

    Parameters
      p_batch_header_rec (O)      batch header to identify the batch to release;
      p_org_code (O)              organization code to identify the batch is conjunction with batch_no in p_batch_header_rec
      p_ignore_exception (O)      indicates whether to ignore exceptions; if exceptions are ignored,
                                  x_exception_material_tbl won't be populated even if exceptions were found
      p_validate_flexfields (O)   indicates whether to validate flexfields... Defaults to fnd_api.g_false;
      x_batch_header_rec          Output batch header record after release
      x_exception_material_tbl    Batch exceptions found in release batch
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
                                  X - Batch Exception
  ================================================================================*/
 PROCEDURE release_batch
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE
     ,p_org_code                 IN              VARCHAR2
     ,p_ignore_exception         IN              VARCHAR2 := fnd_api.g_false
     ,p_validate_flexfields      IN              VARCHAR2 := fnd_api.g_false
     ,x_batch_header_rec         OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab)
   IS
      l_api_name             CONSTANT VARCHAR2 (30)  := 'RELEASE_BATCH';

      l_in_batch_header_rec  gme_batch_header%ROWTYPE;
      l_batch_header_rec     gme_batch_header%ROWTYPE;
      l_exception_material_tbl   gme_common_pvt.exceptions_tab;

      error_release_batch    EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('ReleaseBatch');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT release_batch;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'release_batch'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.validate_batch
                         (p_batch_header_rec 	=> p_batch_header_rec
                         ,p_org_code        	=> p_org_code
                         ,p_batch_type          => nvl(p_batch_header_rec.batch_type,gme_common_pvt.g_doc_type_batch)
                         ,x_batch_header_rec    => l_batch_header_rec
                         ,x_message_count      	=> x_message_count
     			 ,x_message_list        => x_message_list
                         ,x_return_status       => x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
      -- Validations
      IF p_validate_flexfields = fnd_api.g_true THEN
          gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
          gme_common_pvt.g_flex_validate_prof := 0;
      END IF;

      l_in_batch_header_rec := l_batch_header_rec;
      l_in_batch_header_rec.actual_start_date := p_batch_header_rec.actual_start_date;
      -- call release batch validation...output batch header will have actual start date filled in

      gme_release_batch_pvt.validate_batch_for_release  (
      p_batch_header_rec     => l_in_batch_header_rec
     ,x_batch_header_rec     => l_batch_header_rec
     ,x_return_status        => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- reset flex global
      gme_common_pvt.g_flex_validate_prof := 0;

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                               || 'batch_id '||l_batch_header_rec.batch_id);
      END IF;
      /* Invoke main */
      gme_api_main.release_batch
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_batch_header_rec            => l_batch_header_rec
			 ,p_ignore_exception            => p_ignore_exception  --Bug#5186328
                         ,x_batch_header_rec            => x_batch_header_rec
                         ,x_exception_material_tbl      => l_exception_material_tbl);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         		       ' Return status from gme_api_main.release_batch is '
             			|| x_return_status);
      END IF;

      IF p_ignore_exception = fnd_api.g_true AND x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := fnd_api.g_ret_sts_success;
      ELSIF x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_exception_material_tbl := l_exception_material_tbl;
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_release_batch;
      END IF;

      /* Invoke save_batch */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ' About to
         invoke save_batch with header_id of ' || gme_common_pvt.g_transaction_header_id);
      END IF;

      gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name ||
         			' Return status from gme_api_pub.save_batch is ' || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN error_release_batch THEN
         ROLLBACK TO SAVEPOINT release_batch;
         x_batch_header_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT release_batch;
         x_batch_header_rec := NULL;
	      x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT release_batch;
         x_batch_header_rec := NULL;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END release_batch;

   /*================================================================================
    Procedure
      release_step
    Description
      This procedure is used to release a step
      One of the following key sequences must be specified:
      batchstep_id
      batch_id, batchstep_no OR
      batch_no, org_code, batchstep_no batch_type assumed to be batch

    Parameters
      p_batch step_rec (O)        batch step to identify the step to release.
      p_batch_no (O)              batch_no to identify the step
      p_org_code (O)              organization code to identify the step is conjunction with batch_no in p_batch_header_rec
      p_ignore_exception (O)      indicates whether to ignore exceptions; if exceptions are ignored,
                                  x_exception_material_tbl won't be populated ever if exceptions were found
      p_validate_flexfields (O)   indicates whether to validate flexfields... Defaults to fnd_api.g_false;
      x_batch_step_rec            Output batch step record after release
      x_exception_material_tbl    Material exceptions found in release step (only those associated to step and processed dep steps)
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
                                  X - Batch Exception
  ================================================================================*/
 PROCEDURE release_step
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2
     ,p_batch_step_rec           IN              gme_batch_steps%ROWTYPE
     ,p_batch_no                 IN              VARCHAR2
     ,p_org_code                 IN              VARCHAR2
     ,p_ignore_exception         IN              VARCHAR2 := fnd_api.g_false
     ,p_validate_flexfields      IN              VARCHAR2 := fnd_api.g_false
     ,x_batch_step_rec           OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab)
   IS
      l_api_name             CONSTANT VARCHAR2 (30)  := 'RELEASE_STEP';

      l_in_batch_step_rec    gme_batch_steps%ROWTYPE;
      l_batch_step_rec       gme_batch_steps%ROWTYPE;
      l_in_batch_header_rec  gme_batch_header%ROWTYPE;
      l_batch_header_rec     gme_batch_header%ROWTYPE;

      l_exception_material_tbl   gme_common_pvt.exceptions_tab;

      error_release_step     EXCEPTION;
   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('ReleaseStep');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      SAVEPOINT release_step;

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'release_step'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;
     /* Validate Input parameters */
      gme_common_pvt.Validate_batch_step (
              p_batch_step_rec     =>  	p_batch_step_rec
             ,p_org_code           =>  	p_org_code
             ,p_batch_no           =>  	p_batch_no
             ,x_batch_step_rec     =>  	l_batch_step_rec
             ,x_batch_header_rec   =>  	l_batch_header_rec
             ,x_message_count      => 	x_message_count
     	     ,x_message_list       => 	x_message_list
             ,x_return_status      => 	x_return_status );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug = gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name || '.' || l_api_name
                                || ': batch step validate error ');
             END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
      -- Validations
      IF l_batch_header_rec.batch_type = gme_common_pvt.g_doc_type_fpo THEN
        gme_common_pvt.log_message('GME_API_INVALID_BATCH_TYPE');
        RAISE fnd_api.g_exc_error;
      END IF;
   -- current Step Status must be Pending
      IF (l_batch_step_rec.step_status <> gme_common_pvt.g_step_pending) THEN
        gme_common_pvt.log_message('GME_API_INV_STAT_STEP_REL');
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_batch_header_rec.batch_status NOT IN
                         (gme_common_pvt.g_batch_pending, gme_common_pvt.g_batch_wip) THEN
        gme_common_pvt.log_message ('GME_API_INV_BATCH_REL_STEP');
        RAISE fnd_api.g_exc_error;
      END IF;

      --Pawan kumar changed to number for g_step_controls_batch_sts
      IF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending AND
         (gme_common_pvt.g_step_controls_batch_sts_ind <> 1 OR
          l_batch_header_rec.parentline_id IS NOT NULL) THEN
        gme_common_pvt.log_message ('GME_API_INV_BATCH_REL_STEP');
        RAISE fnd_api.g_exc_error;
      END IF;

      l_in_batch_step_rec := l_batch_step_rec;
      l_in_batch_step_rec.actual_start_date := p_batch_step_rec.actual_start_date;
      -- output step contains the actual complete date
      gme_release_batch_step_pvt.validate_step_for_release
                                        (p_batch_header_rec     => l_batch_header_rec
                                        ,p_batch_step_rec       => l_in_batch_step_rec
                                        ,x_batch_step_rec       => l_batch_step_rec
                                        ,x_return_status        => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- needed for release batch AND/OR release step (release step is in private to take care of dependent steps)
      IF p_validate_flexfields = fnd_api.g_true THEN
        gme_common_pvt.g_flex_validate_prof := 1;
      ELSE
        gme_common_pvt.g_flex_validate_prof := 0;
      END IF;

      IF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending THEN
        l_in_batch_header_rec := l_batch_header_rec;
        l_in_batch_header_rec.actual_start_date := l_batch_step_rec.actual_start_date;

        -- call release batch validation... output batch header will have actual start date filled in
        gme_release_batch_pvt.validate_batch_for_release
                                   (p_batch_header_rec     => l_in_batch_header_rec
                                   ,x_batch_header_rec     => l_batch_header_rec
                                   ,x_return_status        => x_return_status);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      gme_common_pvt.g_move_to_temp := fnd_api.g_false;

      /* Invoke main */
      gme_api_main.release_step
                         (p_validation_level            => p_validation_level
                         ,p_init_msg_list               => fnd_api.g_false
                         ,x_message_count               => x_message_count
                         ,x_message_list                => x_message_list
                         ,x_return_status               => x_return_status
                         ,p_batch_step_rec              => l_batch_step_rec
                         ,p_batch_header_rec            => l_batch_header_rec
			 ,p_ignore_exception            => p_ignore_exception     --Bug#5186328
                         ,x_batch_step_rec              => x_batch_step_rec
                         ,x_exception_material_tbl      => l_exception_material_tbl);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ' Return
         status from gme_api_main.release_step is ' || x_return_status);
      END IF;

      -- reset flex global
      gme_common_pvt.g_flex_validate_prof := 0;

      IF p_ignore_exception = fnd_api.g_true AND x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_return_status := fnd_api.g_ret_sts_success;
      ELSIF x_return_status = gme_common_pvt.g_exceptions_err THEN
        x_exception_material_tbl := l_exception_material_tbl;
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE error_release_step;
      END IF;

      /* Invoke save_batch */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ' About to
         invoke save_batch with header_id of ' || gme_common_pvt.g_transaction_header_id);
      END IF;

      gme_api_pub.save_batch
                       (p_header_id          => gme_common_pvt.g_transaction_header_id
                       ,p_table              => 1
                       ,p_commit             => p_commit
                       ,x_return_status      => x_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name || '.' || l_api_name || ' Return
         status from gme_api_pub.save_batch is ' || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   ' Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;

   EXCEPTION
      WHEN error_release_step THEN
         ROLLBACK TO SAVEPOINT release_step;
         x_batch_step_rec := NULL;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO SAVEPOINT release_step;
         x_batch_step_rec := NULL;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT release_step;
        x_batch_step_rec := NULL;
        gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END release_step;

   /*================================================================================
    Procedure
      process_group
    Description
      This procedure is used to perform mass batch actions on group of batches.
      Required parameters are - group_name, org_code, action and on_error_flag.

    Parameters
      p_group_name                Group name to identify the group of batches to process.
                                  Set of batches can grouped under a group name which can be created
                                  from the batch group management form.
      p_org_code                  organization code to identify the group_name is conjunction with group_name in p_batch_header_rec
      p_action                    Identifies what batch action to perform
                                  Valid values from lookup type GME_BATCH_GROUP_ACTION (3,4,5,6,7,8,9,10,11)
      p_on_error_flag             Indicates whether to continue or stop processing in case of an error.
                                  Valid values are 'STOP' OR 'CONTINUE'
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
                                  X - Batch Exception
  ================================================================================*/
   PROCEDURE process_group
     (p_api_version              IN              NUMBER
     ,p_validation_level         IN              NUMBER
            := gme_common_pvt.g_max_errors
     ,p_init_msg_list            IN              VARCHAR2 := fnd_api.g_false
     ,p_commit                   IN              VARCHAR2 := fnd_api.g_false
     ,p_group_name               IN              VARCHAR2
     ,p_org_code                 IN              VARCHAR2
     ,p_action                   IN              NUMBER
     ,p_on_error_flag            IN              VARCHAR2
     ,x_message_count            OUT NOCOPY      NUMBER
     ,x_message_list             OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2)
    IS
      l_api_name             CONSTANT VARCHAR2 (30)  := 'PROCESS_GROUP';
      l_action                NUMBER;
      l_group_id              NUMBER;
      l_group_name            VARCHAR2(32);
      l_org_id                NUMBER;
      i                       NUMBER := 0;
      success_count           NUMBER := 0;
      failed_count            NUMBER := 0;
      l_batch_header_rec      gme_batch_header%ROWTYPE;
      l_in_batch_header_rec      gme_batch_header%ROWTYPE;
      l_exception_material_tbl   gme_common_pvt.exceptions_tab;
      error_process_group     EXCEPTION;

      CURSOR get_organization (l_org_code IN VARCHAR2)
      IS
         SELECT organization_id
           FROM mtl_parameters
          WHERE organization_code = p_org_code;

      CURSOR get_group_id (l_org_id IN NUMBER, l_group_name IN VARCHAR2)
      IS
         SELECT group_id
           FROM gme_batch_groups_b
          WHERE organization_id = l_org_id AND group_name = l_group_name;

     CURSOR validate_lookup_code(l_lookup_code IN NUMBER)
      IS
         SELECT lookup_code FROM gem_lookups
         WHERE lookup_type = 'GME_BATCH_GROUP_ACTION'
         AND lookup_code = l_lookup_code
         AND lookup_code NOT IN (1,2);

     CURSOR get_associated_batches (l_group_id IN NUMBER)
     IS
         SELECT batch_id
         FROM gme_batch_groups_association
         WHERE group_id = l_group_id;

     CURSOR get_batch_status (l_batch_id IN NUMBER, l_org_id IN NUMBER)
     IS
         SELECT batch_status
         FROM gme_batch_header
         WHERE batch_id = l_batch_id
         and organization_id = l_org_id;

   BEGIN
      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('ProcessGroup');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Set savepoint here */
      /* SAVEPOINT process_group; */

      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (2.0
                                         ,p_api_version
                                         ,'process_group'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

     /* Validate Input parameters */


         IF (p_org_code IS NULL) THEN
            fnd_message.set_name ('INV', 'INV_ORG_REQUIRED');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_group_name IS NULL) THEN
            fnd_message.set_name ('GME', 'GME_GROUP_REQUIRED');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_action IS NULL) THEN
            fnd_message.set_name ('GME', 'GME_ACTION_REQUIRED');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_on_error_flag IS NULL) THEN
            fnd_message.set_name ('GME', 'GME_ERR_FLAG_REQUIRED');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;

         OPEN get_organization (p_org_code);

         FETCH get_organization INTO l_org_id;

         IF get_organization%NOTFOUND THEN
            CLOSE get_organization;
            gme_common_pvt.log_message ('GME_INVALID_ORG');
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE get_organization;

         OPEN get_group_id (l_org_id, p_group_name);

         FETCH get_group_id INTO l_group_id;

         IF get_group_id%NOTFOUND THEN
            CLOSE get_group_id;
            gme_common_pvt.log_message ('GME_INVALID_GROUP');
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE get_group_id;

         OPEN validate_lookup_code(p_action);
         FETCH validate_lookup_code INTO l_action;

         IF validate_lookup_code%NOTFOUND THEN
            CLOSE validate_lookup_code;
            gme_common_pvt.log_message ('GME_INVALID_GROUP_ACTION');
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE validate_lookup_code;

         IF (p_on_error_flag <> 'STOP' AND p_on_error_flag <> 'CONTINUE') THEN
            gme_common_pvt.log_message ('GME_INVALID_ERR_FLAG');
            RAISE fnd_api.g_exc_error;
         END IF;

         i := 0;
         FOR get_rec IN get_associated_batches(l_group_id) LOOP
         BEGIN
            i := i+1;
            l_in_batch_header_rec.batch_id := get_rec.batch_id;
            -- DBMS_OUTPUT.put_line ('batch_id is ' || l_in_batch_header_rec.batch_id);
            IF  (p_action = 3) THEN
                gme_api_pub.auto_detail_batch
                        (p_api_version         => 2.0,
                         p_init_msg_list      => 'T',
                         p_commit             => 'T',
                         x_message_count      => x_message_count,
                         x_message_list       => x_message_list,
                         x_return_status      => x_return_status,
                         p_batch_rec          => l_in_batch_header_rec,
                         p_org_code           => NULL
                        );
             ELSIF (p_action = 4) THEN
                 gme_api_pub.release_batch
                        (p_api_version                 => 2.0,
                         p_validation_level            => 100,
                         p_init_msg_list               => 'T',
                         p_commit                      => 'T',
                         x_message_count               => x_message_count,
                         x_message_list                => x_message_list,
                         x_return_status               => x_return_status,
                         p_batch_header_rec            => l_in_batch_header_rec,
                         p_org_code                    => NULL,
                         p_ignore_exception            => 'F',
                         p_validate_flexfields         => 'F',
                         x_batch_header_rec            => l_batch_header_rec,
                         x_exception_material_tbl      => l_exception_material_tbl
                       );
            ELSIF (p_action = 5) THEN
                gme_api_pub.complete_batch
                         (p_api_version                 => 2.0,
                          p_validation_level            => 100,
                          p_init_msg_list               => 'T',
                          p_commit                      => 'T',
                          x_message_count               => x_message_count,
                          x_message_list                => x_message_list,
                          x_return_status               => x_return_status,
                          p_batch_header_rec            => l_in_batch_header_rec,
                          p_org_code                    => NULL,
                          p_ignore_exception            => 'F',
                          p_validate_flexfields         => 'F',
                          x_batch_header_rec            => l_batch_header_rec,
                          x_exception_material_tbl      => l_exception_material_tbl
                         );
            ELSIF (p_action = 6) THEN
                gme_api_pub.close_batch
                        (p_api_version           => 2.0,
                         p_validation_level      => 100,
                         p_init_msg_list         => 'T',
                         p_commit                => 'T',
                         x_message_count         => x_message_count,
                         x_message_list          => x_message_list,
                         x_return_status         => x_return_status,
                         p_batch_header_rec      => l_in_batch_header_rec,
                         x_batch_header_rec      => l_batch_header_rec,
                         p_org_code              => NULL
                         );
            ELSIF (p_action = 7) THEN
                gme_api_pub.reopen_batch
                        (p_api_version           => 2.0,
                         p_validation_level      => 100,
                         p_init_msg_list         => 'T',
                         p_commit                => 'T',
                         x_message_count         => x_message_count,
                         x_message_list          => x_message_list,
                         x_return_status         => x_return_status,
                         p_org_code              => NULL,
                         p_batch_header_rec      => l_in_batch_header_rec,
                         p_reopen_steps          => NULL,
                         x_batch_header_rec      => l_batch_header_rec
                         );
            ELSIF (p_action = 8) THEN
                gme_api_pub.revert_batch
                        (p_api_version           => 2.0,
                         p_validation_level      => 100,
                         p_init_msg_list         => 'T',
                         p_commit                => 'T',
                         x_message_count         => x_message_count,
                         x_message_list          => x_message_list,
                         x_return_status         => x_return_status,
                         p_org_code              => NULL,
                         p_batch_header_rec      => l_in_batch_header_rec,
                         x_batch_header_rec      => l_batch_header_rec
                         );
            ELSIF (p_action = 9) THEN
                gme_api_pub.unrelease_batch
                          (p_api_version                => 2.0,
                           p_validation_level           => 100,
                           p_init_msg_list              => 'T',
                           p_commit                     => 'T',
                           x_message_count              => x_message_count,
                           x_message_list               => x_message_list,
                           x_return_status              => x_return_status,
                           p_batch_header_rec           => l_in_batch_header_rec,
                           p_org_code                   => NULL,
                           p_create_resv_pend_lots      => NULL,
                           x_batch_header_rec           => l_batch_header_rec
                          );
            ELSIF (p_action = 10) THEN
                gme_api_pub.cancel_batch
                        (p_api_version           => 2.0,
                         p_validation_level      => 100,
                         p_init_msg_list         => 'T',
                         p_commit                => 'T',
                         x_message_count         => x_message_count,
                         x_message_list          => x_message_list,
                         x_return_status         => x_return_status,
                         p_batch_header_rec      => l_in_batch_header_rec,
                         x_batch_header_rec      => l_batch_header_rec,
                         p_org_code              => NULL
                        );

            ELSIF (p_action = 11) THEN
                gme_api_pub.terminate_batch
                           (p_api_version           => 2.0,
                            p_validation_level      => 100,
                            p_init_msg_list         => 'T',
                            p_commit                => 'T',
                            x_message_count         => x_message_count,
                            x_message_list          => x_message_list,
                            x_return_status         => x_return_status,
                            p_org_code              => NULL,
                            p_reason_name           => NULL,
                            p_batch_header_rec      => l_in_batch_header_rec,
                            x_batch_header_rec      => l_batch_header_rec
                           );
            END IF;

            -- DBMS_OUTPUT.put_line ('return status is = ' || x_return_status);
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
               failed_count := failed_count + 1;
               gme_common_pvt.count_and_get (x_count        => x_message_count
                                            ,p_encoded      => fnd_api.g_false
                                            ,x_data         => x_message_list);
               -- DBMS_OUTPUT.put_line('Error ' || x_message_list);
               IF (p_on_error_flag = 'STOP') THEN
                  RAISE error_process_group;
               END IF;
            ELSE
                success_count := success_count + 1;
            END IF;

         EXCEPTION
         WHEN OTHERS THEN
         failed_count := failed_count + 1;
          gme_common_pvt.count_and_get (x_count        => x_message_count
                                       ,p_encoded      => fnd_api.g_false
                                       ,x_data         => x_message_list);
         -- DBMS_OUTPUT.put_line('Error ' || x_message_list);
         IF (p_on_error_flag = 'STOP') THEN
             RAISE error_process_group;
         END IF;
         END;
         END LOOP;

         IF i=0 THEN
            gme_common_pvt.log_message ('GME_NO_GROUP_ASSOC');
            RAISE fnd_api.g_exc_error;
         ELSE
            -- DBMS_OUTPUT.put_line('Total ' || i);
            -- DBMS_OUTPUT.put_line('Success ' || success_count);
            -- DBMS_OUTPUT.put_line('Failed ' || failed_count);
            gme_common_pvt.log_message
               ( p_message_code => 'GME_GROUP_ASSOC_TOTAL'
                ,p_product_code => 'GME'
                ,p_token1_name  => 'TOTAL_COUNT'
                ,p_token1_value =>  i
               );
            gme_common_pvt.log_message
               ( p_message_code => 'GME_GROUP_ASSOC_SUCCESS'
                ,p_product_code => 'GME'
                ,p_token1_name  => 'SUCCESS_COUNT'
                ,p_token1_value =>  success_count
               );

            gme_common_pvt.log_message
               ( p_message_code => 'GME_GROUP_ASSOC_FAIL'
                ,p_product_code => 'GME'
                ,p_token1_name  => 'FAILED_COUNT'
                ,p_token1_value =>  failed_count
               );
         END IF;

     EXCEPTION

      WHEN error_process_group THEN
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
	      x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
    END process_group;

   /*================================================================================
    Procedure
      update_batchstep_qty
    Description
      This api procedure is used only for updating actual_step_qty.
      Charges will also be recalculated.
      One of the following key sequences must be specified:
      batchstep_id
      batch_id, batchstep_no OR
      batch_no, org_code, batchstep_no batch_type assumed to be batch

    Parameters
      p_batch step_rec (O)        batch step to identify the step to update.
      p_org_code (O)              organization code to identify the step is conjunction with batch_no in p_batch_header_rec
      p_batch_no (O)              batch_no to identify the step
      p_add (O)                   indicates whether to add to the actual step qty for incremental
                                  recording or overwrite. Default is 'N' Meaning overwrite.
      x_batch_step_rec            Output batch step record after update
      x_return_status             outcome of the API call
                                  S - Success
                                  E - Error
                                  U - Unexpected Error
                                  X - Batch Exception

    History:
      G. Muratore    15-JUN-2009  Bug 7447757
         Introduced new api for update actual_step_qty
         PROCEDURE update_batchstep_qty. Charges will also be recalculated.
  ================================================================================*/
   PROCEDURE update_batchstep_qty (
      p_api_version         IN              NUMBER   := 1.0
     ,p_validation_level    IN              NUMBER   := gme_common_pvt.g_max_errors
     ,p_init_msg_list       IN              VARCHAR2 := fnd_api.g_false
     ,p_commit              IN              VARCHAR2
     ,p_org_code            IN              VARCHAR2
     ,p_batch_no            IN              VARCHAR2 := NULL
     ,p_add                 IN              VARCHAR2 := 'N'
     ,p_batch_step_rec      IN              gme_batch_steps%ROWTYPE
     ,x_batch_step_rec      OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_message_count       OUT NOCOPY      NUMBER
     ,x_message_list        OUT NOCOPY      VARCHAR2
     ,x_return_status       OUT NOCOPY      VARCHAR2)

   IS
      l_api_name             CONSTANT VARCHAR2 (30)
                                               := 'UPDATE_STEP';
      l_batch_header         gme_batch_header%ROWTYPE;
      l_batch_step_rec       gme_batch_steps%ROWTYPE;
      l_batch_step_rec2      gme_batch_steps%ROWTYPE;
      l_return_status        VARCHAR2 (2);
      l_step_status          NUMBER;
      l_record_changed       NUMBER;

      negative_qty_error              EXCEPTION;
      l_invalid_step_status           EXCEPTION;
      update_step_failed              EXCEPTION;
   BEGIN
      /* Set the savepoint */
      SAVEPOINT update_batchstep_qty;

      IF (g_debug <> -1) THEN
         gme_debug.log_initialize ('UpdateBatchstep');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;

      /* Make sure we are call compatible */

      IF NOT fnd_api.compatible_api_call (1.0
                                         ,p_api_version
                                         ,'update_batchstep'
                                         ,g_pkg_name) THEN
         gme_common_pvt.log_message ('GME_INVALID_API_VERSION');
         RAISE fnd_api.g_exc_error;
      END IF;

      gme_common_pvt.set_timestamp;

      /* Initialize message list and count if needed */
      IF p_init_msg_list = fnd_api.g_true THEN
         fnd_msg_pub.initialize;
         gme_common_pvt.g_error_count := 0;
      END IF;

      /* Retrieve the row to be updated              */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('actual qty passed in is '||p_batch_step_rec.actual_step_qty);
         gme_debug.put_line ('batchstep_id is  '||p_batch_step_rec.batchstep_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Invoke get_batchstep');
      END IF;

      -- Fetch the step record from the DB as well as the batch header record.
      IF NOT gme_common_pvt.get_batch_step
                         (p_batch_step_rec      => p_batch_step_rec
                         ,p_org_code            => p_org_code
                         ,p_batch_no            => p_batch_no
                         ,x_batch_step_rec      => l_batch_step_rec
                         ,x_batch_header_rec    => l_batch_header) THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' get_batchstep failed to retrieve row');
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' batchstep_id is '
                             || l_batch_step_rec.batchstep_id);
         gme_debug.put_line ('actual qty fetched from DB is '||l_batch_step_rec.actual_step_qty);
      END IF;

      /* Setup the common constants used accross the apis */
      /* This will raise an error if both organization_id and org_code are null values */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Invoking setup for org_id '
                             || l_batch_header.organization_id
                             || ' org_code '
                             || p_org_code);
      END IF;

      gme_common_pvt.g_setup_done :=
         gme_common_pvt.setup
                        (p_org_id        => l_batch_header.organization_id
                        ,p_org_code      => p_org_code);

      IF NOT gme_common_pvt.g_setup_done THEN
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' setup failure ');
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      /* Check the step_status of the batchstep                   */
      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' step_status is '
                             || l_batch_step_rec.step_status);
      END IF;

      -- This api only good NON ASQC batches.
      IF l_batch_header.automatic_step_calculation = 1 THEN

         gme_common_pvt.log_message (p_product_code => 'GME'
                                    ,p_message_code => 'GME_API_BATCH_STEP_UPD_ERR');
         RAISE l_invalid_step_status;
      END IF;

      -- This api only good for wip and completed steps.
      IF l_batch_step_rec.step_status NOT IN (gme_common_pvt.g_step_completed
                                            ,gme_common_pvt.g_step_wip) THEN

         gme_common_pvt.log_message (p_product_code => 'GME'
                                    ,p_message_code => 'GME_API_INV_STAT_STEP_EDIT');
         RAISE l_invalid_step_status;
      END IF;

      l_record_changed := 0;
      -- Let's see if the actual_qty has been changed or if we need to add to it.
      IF (NVL(l_batch_step_rec.actual_step_qty,0) <> p_batch_step_rec.actual_step_qty
          OR p_add = 'Y') THEN
         -- Do not allow negative quantities.

         IF (NVL(p_batch_step_rec.actual_step_qty, 0) < 0) THEN
            IF g_debug <= gme_debug.g_log_statement THEN
               gme_debug.put_line (g_pkg_name || '.' || l_api_name || ' Negative qty not allowed');
            END IF;

            gme_common_pvt.log_message (p_product_code => 'GMI'
                                       ,p_message_code => 'IC_ACTIONQTYNEG');
            RAISE negative_qty_error;
         END IF;

         l_record_changed := 1;
         IF (p_add <> 'Y') THEN
            l_batch_step_rec.actual_step_qty := p_batch_step_rec.actual_step_qty;
         ELSE
            l_batch_step_rec.actual_step_qty := NVL(l_batch_step_rec.actual_step_qty, 0) + p_batch_step_rec.actual_step_qty;
         END IF;

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line ('Before calling recalc');
            gme_debug.put_line ('batchstep_id is  '||l_batch_step_rec.batchstep_id);
            gme_debug.put_line ('actual qty going into recal is '||l_batch_step_rec.actual_step_qty);
         END IF;

         -- This calc will recalculate the charges but also updates the step record in the database.
         gme_update_step_qty_pvt.recalculate_charges(p_batchstep_rec => l_batch_step_rec
                                                    ,p_cal_type      => 'P'
                                                    ,x_batchstep_rec => l_batch_step_rec2
                                                    ,x_return_status => x_return_status );

         l_batch_step_rec := l_batch_step_rec2;

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' recalc charges returns '
                                || x_return_status);
         END IF;
      END IF;

      IF l_record_changed = 1 THEN

         -- Send information back to calling program.
         x_batch_step_rec := l_batch_step_rec;

         IF x_return_status = fnd_api.g_ret_sts_success THEN
            IF g_debug <= gme_debug.g_log_statement THEN
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ' invoke save_batch with commit ='
                                   || p_commit);
            END IF;

            -- We may revert back to using just a pure commit if required. Leaving code for now.
/*
            IF p_commit = fnd_api.g_true THEN
               COMMIT;
               gme_common_pvt.log_message ('PM_SAVED_CHANGES');
            END IF;
*/
            IF p_commit = fnd_api.g_true THEN
               gme_api_pub.save_batch
                             (p_header_id          => gme_common_pvt.g_transaction_header_id
                             ,p_table              => null
                             ,p_commit             => p_commit
                             ,p_clear_qty_cache    => fnd_api.g_true
                             ,x_return_status      => x_return_status);

               IF g_debug <= gme_debug.g_log_statement THEN
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || ' save_batch return_status is '
                                      || x_return_status);
               END IF;

               IF x_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
               END IF;

               gme_common_pvt.log_message ('PM_SAVED_CHANGES');
               gme_common_pvt.count_and_get(x_count        => x_message_count
                                           ,p_encoded      => fnd_api.g_false
                                           ,x_data         => x_message_list);
            END IF;
         ELSE
            RAISE update_step_failed;
         END IF;
      ELSE
         -- Tell user that nothing was changed.
         gme_common_pvt.log_message (p_product_code => 'IEM'
                                    ,p_message_code => 'IEM_NOTHING_TO_UPDATE');
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   'Completed ' || l_api_name || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN l_invalid_step_status OR negative_qty_error OR update_step_failed THEN
         ROLLBACK TO SAVEPOINT update_batchstep_qty;
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO SAVEPOINT update_batchstep_qty;
         gme_common_pvt.count_and_get (x_count        => x_message_count
                                      ,p_encoded      => fnd_api.g_false
                                      ,x_data         => x_message_list);
      WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_batchstep_qty;
         gme_when_others (	p_api_name              => l_api_name
     				,x_message_count        => x_message_count
     				,x_message_list         => x_message_list
     				,x_return_status   	=> x_return_status );
   END update_batchstep_qty;


END gme_api_pub;

/
