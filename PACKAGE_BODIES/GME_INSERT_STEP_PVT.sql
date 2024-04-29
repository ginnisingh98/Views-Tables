--------------------------------------------------------
--  DDL for Package Body GME_INSERT_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_INSERT_STEP_PVT" AS
/*  $Header: GMEVINSB.pls 120.6.12010000.1 2008/07/25 10:31:06 appldev ship $ */
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_API_INSERT_STEP';

   PROCEDURE insert_batch_step (
      p_gme_batch_header   IN              gme_batch_header%ROWTYPE
     ,p_gme_batch_step     IN              gme_batch_steps%ROWTYPE
     ,x_gme_batch_step     OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      CURSOR get_steps_count (v_batchstep_no NUMBER, v_batch_id NUMBER)
      IS
         SELECT COUNT (*)
           FROM gme_batch_steps
          WHERE batch_id = v_batch_id
            AND batchstep_no = v_batchstep_no
            AND delete_mark = 0;

      /* Punit Kumar */
      /* Susruth D. Bug#4917184 Start */
      CURSOR get_orgn_code (p_org_id NUMBER)
      IS
         SELECT organization_code
            FROM mtl_parameters
            WHERE organization_id = p_org_id ;

      /* Bug#5231180 */
      CURSOR cur_get_std_factor (v_um_code VARCHAR2)
      IS
         SELECT conversion_rate, uom_class
           FROM mtl_uom_conversions
          WHERE uom_code = v_um_code
	   AND  inventory_item_id = 0;

      --nsinghi bug#5202811.
      CURSOR cur_text_code (v_text_code NUMBER) IS
         SELECT 1
         FROM   sys.DUAL
         WHERE  EXISTS ( SELECT 1
                         FROM   gme_text_header
                         WHERE  text_code = v_text_code);

      /* Bug#4917184 End */
      l_recipe_rout_step          gmd_recipe_fetch_pub.recipe_step_tbl;
                                                            -- gme_batch_steps
      l_recipe_rout_act           gmd_recipe_fetch_pub.oprn_act_tbl;
                                                  -- gme_batch_step_activities
      l_recipe_rout_resc          gmd_recipe_fetch_pub.oprn_resc_tbl;
                                                   -- gme_batch_step_resources
      /* Pawan kumar  bug 2509572 added code for process parameters */
      l_resc_parameters           gmd_recipe_fetch_pub.recp_resc_proc_param_tbl;
                                                     -- gme_process_parameters
      l_recipe_rout_matl          gmd_recipe_fetch_pub.recipe_rout_matl_tbl;
                                                       -- gme_batch_step_items
      l_routing_depd              gmd_recipe_fetch_pub.routing_depd_tbl;
                                                -- gme_batch_step_dependencies
      l_message_count             NUMBER;
      l_message_data              VARCHAR2 (2048);
      l_return_code               NUMBER;
      l_return_status             VARCHAR2 (1);
      l_count                     NUMBER;
      l_batch_id                  NUMBER;
      l_batch_step_row            gme_batch_steps%ROWTYPE;
      l_exists                    NUMBER; --nsinghi bug#5202811
      --Bug#5231180
      l_um_type                   mtl_units_of_measure.uom_class%TYPE;
      l_std_factor                NUMBER;
      /* Punit Kumar */
      l_orgn_code                 VARCHAR2 (3);
      error_inv_status_ins_step   EXCEPTION;
      error_no_oprn_defined       EXCEPTION;
      error_gmd_fetch_oprn        EXCEPTION;
      error_step_qty_lthan_zero   EXCEPTION;
      error_create_batch_step     EXCEPTION;
      error_calc_max_capacity     EXCEPTION;
      batch_step_fetch_error      EXCEPTION;
      /* Punit Kumar
           */
      error_no_organization_id    EXCEPTION;
      validation_failure          EXCEPTION;
      batch_step_update_error     EXCEPTION;
      expected_error              EXCEPTION;
      invalid_text_code           EXCEPTION; --nsinghi bug#5202811
      invalid_oprn_effectivity    EXCEPTION;
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Begin Insert_Batch_Step');
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      /* Bug 2397077 Use only one batch_id when batch IDs passed in both parameters. */
      l_batch_id :=
                  NVL (p_gme_batch_step.batch_id, p_gme_batch_header.batch_id);

      /* End Bug 2397077 */
      IF p_gme_batch_step.batchstep_no IS NULL THEN
         gme_common_pvt.log_message ('GME_STEP_REQD'
                                    ,'FIELDREQ'
                                    ,'Batchstep Number');
         RAISE expected_error;
      END IF;

      OPEN get_steps_count (p_gme_batch_step.batchstep_no, l_batch_id);

      FETCH get_steps_count
       INTO l_count;

      CLOSE get_steps_count;

      IF l_count > 0 THEN
         /* Bug 2397077 Corrected message from PC_DUPLICATESTEP_NO to PC_DUPLICATESTEPNO*/
         gme_common_pvt.log_message ('PC_DUPLICATESTEPNO');
         RAISE expected_error;
      END IF;

      /* Bug 2397077 Validate step_release_type passed to program. */
      IF (p_gme_batch_step.steprelease_type NOT IN (1, 2) ) THEN
         gme_common_pvt.log_message ('GME_INVALID_STEPRELEASE');
         RAISE expected_error;
      END IF;

      /* End Bug 2397077 */
      IF    (p_gme_batch_header.batch_status = 4)
         OR (p_gme_batch_header.batch_status = -1) THEN
         -- Closed or cancelled batch not valid for step insert...
         RAISE error_inv_status_ins_step;
      END IF;

      IF p_gme_batch_step.oprn_id IS NULL THEN
         RAISE error_no_oprn_defined;
      END IF;

      /* Punit Kumar */
      IF p_gme_batch_header.organization_id IS NULL THEN
         RAISE error_no_organization_id;
      END IF;

      /* Punit Kumar */
      OPEN get_orgn_code (p_gme_batch_header.organization_id);

      FETCH get_orgn_code
       INTO l_orgn_code;

      CLOSE get_orgn_code;

      /* Pawan kumar  bug 2509572 added code for process parameters */

      /* Punit Kumar */
      gmd_fetch_oprn.fetch_oprn
              (p_api_version                   => 1.0
              ,p_init_msg_list                 => fnd_api.g_false
              ,p_oprn_id                       => p_gme_batch_step.oprn_id
              ,p_orgn_code                     => l_orgn_code
              ,                           /* p_gme_batch_header.plant_code, */
               x_return_status                 => l_return_status
              ,x_msg_count                     => l_message_count
              ,x_msg_data                      => l_message_data
              ,x_return_code                   => l_return_code
              ,x_oprn_act_out                  => l_recipe_rout_act
              ,x_oprn_resc_rec                 => l_recipe_rout_resc
              ,x_oprn_resc_proc_param_tbl      => l_resc_parameters);

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Inser_Batch_step:fetch_oprn returned:'
                             || l_return_status
                             || ' Return Code:'||l_return_code
                             || ' Error Msg: '
                             || l_message_data
                             || ' ERROR:'
                             || SQLERRM);
         gme_debug.put_line
                (   'Insert_Batch_Step... GMD_FETCH_OPRN.FETCH_OPRN returned '
                 || l_recipe_rout_act.COUNT
                 || ' ACTIVITIES');
         gme_debug.put_line
                (   'Insert_Batch_Step... GMD_FETCH_OPRN.FETCH_OPRN returned '
                 || l_recipe_rout_resc.COUNT
                 || ' RESOURCES');

         FOR i IN 1 .. l_recipe_rout_act.COUNT LOOP
            gme_debug.put_line
               (   'Insert_Batch_Step... GMD_FETCH_OPRN.FETCH_OPRN returned '
                || l_recipe_rout_act (i).oprn_id
                || ' operation_id');
            gme_debug.put_line
                (   'Insert_Batch_Step... GMD_FETCH_OPRN.FETCH_OPRN returned '
                 || l_recipe_rout_act (i).minimum_transfer_qty
                 || ' minimum_transfer_qty at Activity '||l_recipe_rout_act (i).activity);
         END LOOP;
      END IF;

      IF l_return_status <> x_return_status THEN
         RAISE error_gmd_fetch_oprn;
      END IF;

      IF l_recipe_rout_act.COUNT < 1 THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
               ('Insert_Batch Step - GMD_FETCH_OPRN.FETCH_OPRN returned no activities');
         END IF;
         gme_common_pvt.log_message('GME_AT_LEAST_ONE_ACTIVITY');
         RAISE error_gmd_fetch_oprn;
      END IF;

      IF l_recipe_rout_resc.COUNT < 1 THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
               ('Insert_Batch Step - GMD_FETCH_OPRN.FETCH_OPRN returned no resources');
         END IF;
         gme_common_pvt.log_message('GME_AT_LEAST_ONE_RESOURCE');
         RAISE error_gmd_fetch_oprn;
      END IF;

      -- Fill in the recipe_rout_step structure from what was filled in on p_gme_batch_step
      -- subscript is hard-coded to 1 since this is only inserting 1 batch step....
      l_recipe_rout_step (1).routingstep_no := p_gme_batch_step.batchstep_no;
      l_recipe_rout_step (1).oprn_id := p_gme_batch_step.oprn_id;
      l_recipe_rout_step (1).steprelease_type :=
                                             p_gme_batch_step.steprelease_type;

      --Bharati Satpute bug2848936 added to fetch minimum_transfer_qty
      -- Bug 4773956: Corrected field name to process_qty_uom instead of um
      -- Also combined both the select statements into one.
      SELECT minimum_transfer_qty, process_qty_uom
        INTO l_recipe_rout_step (1).minimum_transfer_qty,
             l_recipe_rout_step (1).process_qty_uom
        FROM gmd_operations_b
       WHERE oprn_id = p_gme_batch_step.oprn_id;
       --Bug#5231180
       l_recipe_rout_step (1).capacity_uom := l_recipe_rout_step (1).process_qty_uom;

      --bharati satpute bug2848936 Added
      --   l_recipe_rout_step (1). minimum_transfer_qty := p_gme_batch_step.minimum_transfer_qty;
      IF (p_gme_batch_header.automatic_step_calculation = 1) THEN
         l_recipe_rout_step (1).step_qty := 0;
      --NULL;
      ELSE
         IF p_gme_batch_step.plan_step_qty < 0 THEN
            RAISE error_step_qty_lthan_zero;
         END IF;
         l_recipe_rout_step (1).step_qty := p_gme_batch_step.plan_step_qty;
      END IF;



      /* SELECT process_qty_um
        INTO l_recipe_rout_step (1).process_qty_uom
        FROM gmd_operations
       WHERE oprn_id = p_gme_batch_step.oprn_id;*/

      calc_max_capacity (p_recipe_rout_resc      => l_recipe_rout_resc
                        ,p_max_capacity          => l_recipe_rout_step (1).max_capacity
                        ,p_capacity_uom          => l_recipe_rout_step (1).capacity_uom
   		        ,x_resource             =>  l_recipe_rout_step (1).resources
                        ,x_return_status         => l_return_status
			,p_step_qty_uom          => l_recipe_rout_step (1).process_qty_uom);

      IF l_return_status <> x_return_status THEN
         RAISE error_calc_max_capacity;
      END IF;

      /* Pawan kumar  bug 2509572 added code for process parameters */

      /* Punit Kumar */
      gme_create_step_pvt.create_batch_steps
                       (p_recipe_rout_step_tbl      => l_recipe_rout_step
                       ,p_recipe_rout_act_tbl       => l_recipe_rout_act
                       ,p_recipe_rout_resc_tbl      => l_recipe_rout_resc
                       ,p_resc_parameters_tbl       => l_resc_parameters
                       ,p_recipe_rout_matl_tbl      => l_recipe_rout_matl
                       ,p_routing_depd_tbl          => l_routing_depd
                       ,p_gme_batch_header_rec      => p_gme_batch_header
                       ,p_use_workday_cal           => fnd_api.g_true
                       ,p_contiguity_override       => fnd_api.g_true
                       ,x_return_status             => l_return_status
                       ,p_ignore_qty_below_cap      => fnd_api.g_true
                       ,p_step_start_date           => p_gme_batch_step.plan_start_date
                       ,p_step_cmplt_date           => p_gme_batch_step.plan_cmplt_date
                       ,p_step_due_date             => p_gme_batch_step.due_date);

      IF l_return_status <> x_return_status THEN
         RAISE error_create_batch_step;
      END IF;

      x_gme_batch_step.batchstep_no := p_gme_batch_step.batchstep_no;
      x_gme_batch_step.batch_id := l_batch_id;

      IF NOT (gme_batch_steps_dbl.fetch_row (x_gme_batch_step
                                            ,x_gme_batch_step) ) THEN
         RAISE batch_step_fetch_error;
      END IF;

     /* Bug#6408612 calculated step plan start and end dates are validated
         against the operation effectivity start and end dates */
      IF  NOT gme_common_pvt.check_oprn_effectivity_dates(x_gme_batch_step.oprn_id,
                                       x_gme_batch_step.plan_start_date,
                                       x_gme_batch_step.plan_cmplt_date) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE invalid_oprn_effectivity;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (' Before Validate Flex ');
      END IF;

      -- Added following code in order to set the flexfields and the ID fields
      -- Before calling the validate_flex_fields
      l_batch_step_row := x_gme_batch_step;
      l_batch_step_row.attribute_category :=
                                           p_gme_batch_step.attribute_category;
      l_batch_step_row.attribute1 := p_gme_batch_step.attribute1;
      l_batch_step_row.attribute2 := p_gme_batch_step.attribute2;
      l_batch_step_row.attribute3 := p_gme_batch_step.attribute3;
      l_batch_step_row.attribute4 := p_gme_batch_step.attribute4;
      l_batch_step_row.attribute5 := p_gme_batch_step.attribute5;
      l_batch_step_row.attribute6 := p_gme_batch_step.attribute6;
      l_batch_step_row.attribute7 := p_gme_batch_step.attribute7;
      l_batch_step_row.attribute8 := p_gme_batch_step.attribute8;
      l_batch_step_row.attribute9 := p_gme_batch_step.attribute9;
      l_batch_step_row.attribute10 := p_gme_batch_step.attribute10;
      l_batch_step_row.attribute11 := p_gme_batch_step.attribute11;
      l_batch_step_row.attribute12 := p_gme_batch_step.attribute12;
      l_batch_step_row.attribute13 := p_gme_batch_step.attribute13;
      l_batch_step_row.attribute14 := p_gme_batch_step.attribute14;
      l_batch_step_row.attribute15 := p_gme_batch_step.attribute15;
      l_batch_step_row.attribute16 := p_gme_batch_step.attribute16;
      l_batch_step_row.attribute17 := p_gme_batch_step.attribute17;
      l_batch_step_row.attribute18 := p_gme_batch_step.attribute18;
      l_batch_step_row.attribute19 := p_gme_batch_step.attribute19;
      l_batch_step_row.attribute20 := p_gme_batch_step.attribute20;
      l_batch_step_row.attribute21 := p_gme_batch_step.attribute21;
      l_batch_step_row.attribute22 := p_gme_batch_step.attribute22;
      l_batch_step_row.attribute23 := p_gme_batch_step.attribute23;
      l_batch_step_row.attribute24 := p_gme_batch_step.attribute24;
      l_batch_step_row.attribute25 := p_gme_batch_step.attribute25;
      l_batch_step_row.attribute26 := p_gme_batch_step.attribute26;
      l_batch_step_row.attribute27 := p_gme_batch_step.attribute27;
      l_batch_step_row.attribute28 := p_gme_batch_step.attribute28;
      l_batch_step_row.attribute29 := p_gme_batch_step.attribute29;
      l_batch_step_row.attribute30 := p_gme_batch_step.attribute30;
      --3556979
      gme_validate_flex_fld_pvt.validate_flex_batch_step
                                           (p_batch_step         => l_batch_step_row
                                           ,x_batch_step         => x_gme_batch_step
                                           ,x_return_status      => x_return_status);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE validation_failure;
      END IF;

      --nsinghi bug#5202811 added the code to process edit text.
      IF p_gme_batch_step.text_code IS NOT NULL THEN
         OPEN cur_text_code (p_gme_batch_step.text_code);
         FETCH cur_text_code INTO l_exists;
         IF cur_text_code%NOTFOUND THEN
            CLOSE cur_text_code;
            RAISE invalid_text_code;
         END IF;

         CLOSE cur_text_code;
      END IF;
      x_gme_batch_step.text_code := p_gme_batch_step.text_code;

      IF NOT (gme_batch_steps_dbl.update_row (p_batch_step      => x_gme_batch_step) ) THEN
         RAISE batch_step_update_error;
      END IF;

      /* Bug 2397077 Added message to indicate success of program. */
      gme_common_pvt.log_message ('GME_INSERT_BATCH_STEP_SUCCESS');

      /* End Bug 2397077 */
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('End Insert_Batch_Step');
      END IF;
   EXCEPTION
      WHEN error_inv_status_ins_step THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('insert_step --> invalid batch status');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_INV_STATUS_INSERT_STEP');
      WHEN error_no_oprn_defined THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('insert_step --> no oprn passed');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_NO_OPRN_DEFINED');
      WHEN error_gmd_fetch_oprn THEN
         x_return_status := l_return_status;
      WHEN error_step_qty_lthan_zero THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('insert_step --> step qty < zero');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_STEP_QTY_LTHAN_ZERO');
      /* Punit Kumar */
      WHEN error_no_organization_id THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('insert_step --> no ORGANIZATION_ID supplied');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN error_create_batch_step THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                              (fnd_msg_pub.get (p_encoded      => fnd_api.g_false) );
         END IF;

         x_return_status := l_return_status;
      WHEN error_calc_max_capacity THEN
         x_return_status := l_return_status;
      WHEN invalid_text_code THEN -- nsinghi bug#5202911
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_INVALID_TEXT_CODE');
      WHEN batch_step_fetch_error OR batch_step_update_error THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                              (fnd_msg_pub.get (p_encoded      => fnd_api.g_false) );
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN validation_failure THEN
         NULL;
      WHEN expected_error OR invalid_oprn_effectivity THEN --Bug#6408612
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   'GME insert_step API -- when others '
                                || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_API_INSERT_STEP', 'INSERT_BATCH_STEP');
   END insert_batch_step;

   PROCEDURE calc_max_capacity (
      p_recipe_rout_resc   IN              gmd_recipe_fetch_pub.oprn_resc_tbl
                                 -- resources that we want the max_capacity of
     ,p_max_capacity       OUT NOCOPY      gme_batch_steps.max_step_capacity%TYPE
     ,p_capacity_uom       OUT NOCOPY      gme_batch_steps.max_step_capacity_um%TYPE
     ,x_resource           OUT NOCOPY      gme_batch_step_resources.resources%TYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,p_step_qty_uom       IN              VARCHAR2 DEFAULT NULL) --Bug#5231180
   IS
      l_max_cap                 cr_rsrc_mst.max_capacity%TYPE;
      l_std_cap                 cr_rsrc_mst.max_capacity%TYPE;
      l_std_min_of_max_cap      cr_rsrc_mst.max_capacity%TYPE;
      l_min_of_max_cap          cr_rsrc_mst.max_capacity%TYPE;
      l_min_of_max_cap_uom      cr_rsrc_mst.capacity_uom%TYPE;
      l_cap_uom                 cr_rsrc_mst.capacity_uom%TYPE;

      --Bug#5231180 changed to mtl_units_of_measure
      l_min_of_max_um_type      mtl_units_of_measure.uom_class%TYPE; --sy_uoms_mst.um_type%TYPE;
      l_std_factor              NUMBER;
      l_um_type                 mtl_units_of_measure.uom_class%TYPE; --sy_uoms_mst.um_type%TYPE;

      l_first                   BOOLEAN;
      l_assign                  BOOLEAN;
      l_api_name       CONSTANT VARCHAR2 (30)          := 'CALC_MAX_CAPACITY';

      CURSOR cur_get_rsrc (p_rsrc cr_rsrc_mst.resources%TYPE)
      IS
         SELECT max_capacity, capacity_um   --Bug#5231180 changed to capacity um
           FROM cr_rsrc_mst
          WHERE resources = p_rsrc
            AND delete_mark = 0
            AND capacity_constraint = 1;

      --Bug#5231180 rewritten the folloiwing cursor to use mtl_uom_conversions table
      /*CURSOR cur_get_std_factor (v_um_code VARCHAR2)
      IS
         SELECT std_factor, um_type
           FROM sy_uoms_mst
          WHERE um_code = v_um_code; */
      CURSOR cur_get_std_factor (v_um_code VARCHAR2)
      IS
         SELECT conversion_rate, uom_class
           FROM mtl_uom_conversions
          WHERE uom_code = v_um_code
	   AND  inventory_item_id = 0;

      error_rsrc_diff_um_type   EXCEPTION;
      error_calc_charge_conv    EXCEPTION; --Bug#5231180
      l_temp_qty                NUMBER;    --Bug#5231180
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Insert_batch_step... BEGIN calc max cap');
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      l_first := TRUE;
      l_assign := FALSE;
      -- Initialize in case we don't find any rsrcs that are capacity constraining...
      l_min_of_max_cap := NULL;
      l_min_of_max_cap_uom := NULL;
      -- Initialize in case there is an error...
      p_max_capacity := NULL;
      p_capacity_uom := NULL;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
       gme_debug.put_line ('Resource Count: '||p_recipe_rout_resc.COUNT);
      END IF;

      FOR i IN 1 .. p_recipe_rout_resc.COUNT LOOP
         l_max_cap := NULL;
         l_cap_uom := NULL;

         OPEN cur_get_rsrc (p_recipe_rout_resc (i).resources);
         FETCH cur_get_rsrc INTO l_max_cap, l_cap_uom;
         CLOSE cur_get_rsrc;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
          gme_debug.put_line ('Max Capacity: '||l_max_cap);
          gme_debug.put_line ('Resource Capacity UOM: '||l_cap_uom);
         END IF;

         -- Did we find something? not deleted and capacity constraining...
         IF (l_max_cap IS NOT NULL AND l_cap_uom IS NOT NULL) THEN

	    OPEN cur_get_std_factor (l_cap_uom);
            FETCH cur_get_std_factor INTO l_std_factor, l_um_type;
            CLOSE cur_get_std_factor;

            -- calculate the capacity in the std UOM for it's UOM type...
            l_std_cap := l_max_cap * l_std_factor;

            -- If this is the first to be found, then take it.
            IF (l_first) THEN
               l_assign := TRUE;
               l_first := FALSE;
            ELSE
               -- If this is not the first to come through, then the capacity must be less then
               -- that which we have already stored... we are ensuring that both qty's are in the
               -- same um type and then comparing the capacity in the STD UOM.
               IF (l_min_of_max_um_type = l_um_type) THEN
                  IF l_std_cap < l_std_min_of_max_cap THEN
                     l_assign := TRUE;
                  END IF;
               ELSE
                  -- can't compare the capacity... this will cause the max cap and cap_UOM to
                  -- be returned as NULL.
		  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                   gme_debug.put_line('GME insert_step API calc_max_cap --> resources in diff UOM types...');
                  END IF;
                  --Bug#5231180 used gme_common_pvt to log the message
	          gme_common_pvt.log_message('GME_RSRC_DIFF_UM_TYPE');
                  RAISE error_rsrc_diff_um_type;
               END IF;
            END IF;

            IF (l_assign) THEN
               l_std_min_of_max_cap := l_std_cap;
               l_min_of_max_cap := l_max_cap;
               l_min_of_max_cap_uom := l_cap_uom;
               l_min_of_max_um_type := l_um_type;
	       x_resource           := p_recipe_rout_resc(i).resources;
               l_assign := FALSE;
            END IF;
         END IF;
      END LOOP;

      /*Bug#5231180 Begin calculate the max step capacity in step qty uom*/
      IF NVL(l_min_of_max_cap,0) > 0 THEN
        l_temp_qty :=  inv_convert.inv_um_convert
                                    (item_id            => 0
                                    ,PRECISION          => gme_common_pvt.g_precision
                                    ,from_quantity      => l_min_of_max_cap
                                    ,from_unit          => l_min_of_max_cap_uom
                                    ,to_unit            => p_step_qty_uom
                                    ,from_name          => NULL
                                    ,to_name            => NULL);
        IF (l_temp_qty < 0) THEN
          RAISE error_calc_charge_conv;
	ELSE
          p_max_capacity := l_temp_qty;
        END IF;
     END IF;

     p_capacity_uom := p_step_qty_uom;
     --Bug#5231180 End

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line('Max Capcity calculated: '||p_max_capacity);
         gme_debug.put_line('Capcity UOM : '||p_capacity_uom);
         gme_debug.put_line ('Insert_batch_step... END calc max cap');
      END IF;
   EXCEPTION
      WHEN error_rsrc_diff_um_type OR error_calc_charge_conv THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                      (   'GME insert_step API calc_max_cap --> when others '
                       || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         --Bug2804440
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END calc_max_capacity;



END gme_insert_step_pvt;

/
