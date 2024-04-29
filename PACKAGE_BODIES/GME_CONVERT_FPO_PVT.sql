--------------------------------------------------------
--  DDL for Package Body GME_CONVERT_FPO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_CONVERT_FPO_PVT" AS
/* $Header: GMEVCFPB.pls 120.7 2006/02/14 07:05:18 lgao noship $ */
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_API_CONVERT_FPO';

--*************************************************************
--*************************************************************
   PROCEDURE VALIDATION (
      p_batch_header       IN              gme_batch_header%ROWTYPE
     ,p_batch_size         IN              NUMBER
     ,p_batch_size_uom     IN              VARCHAR2
     ,p_num_batches        IN              NUMBER
     ,p_validity_rule_id   IN              NUMBER
     ,p_leadtime           IN              NUMBER
     ,p_batch_offset       IN              NUMBER
     ,p_offset_type        IN              NUMBER
     ,p_plan_start_date    IN              gme_batch_header.plan_start_date%TYPE
     ,p_plan_cmplt_date    IN              gme_batch_header.plan_cmplt_date%TYPE
     ,x_pregen_fpo_row     OUT NOCOPY      pregen_fpo_row
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      l_api_name               CONSTANT VARCHAR2 (30) := 'VALIDATION';
      /* Exception definitions */
      no_null_dates            EXCEPTION;
      no_populate_both_dates   EXCEPTION;
      invalid_batch_status     EXCEPTION;
      plan_qty_zero_err        EXCEPTION;
      invalid_item_item_um     EXCEPTION;
      no_batches               EXCEPTION;
      neg_validity_rule_id     EXCEPTION;
      leadtime_err             EXCEPTION;
      batch_offset_err         EXCEPTION;
      offset_type_err          EXCEPTION;
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF (p_plan_start_date IS NULL AND p_plan_cmplt_date IS NULL) THEN
         RAISE no_null_dates;
      ELSIF (p_plan_start_date IS NOT NULL AND p_plan_cmplt_date IS NOT NULL) THEN
         RAISE no_populate_both_dates;
      END IF;

      --Shikha Nagar Bug 3607420
      -- Allow planned dates to be in past. In form a warning is issued in such cases.
      IF (p_plan_start_date IS NOT NULL AND p_plan_cmplt_date IS NULL) THEN
         x_pregen_fpo_row.schedule_method := 'FORWARD';
      ELSIF (p_plan_cmplt_date IS NOT NULL AND p_plan_start_date IS NULL) THEN
         x_pregen_fpo_row.schedule_method := 'BACKWARD';
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' schedule method is  '||
                             x_pregen_fpo_row.schedule_method);
      END IF;
      IF (p_batch_header.batch_status <> 1) THEN
         RAISE invalid_batch_status;
      END IF;

      -- Pawan Kumar ADDED code for bug 2398719
      IF (p_batch_header.batch_type = 0) THEN
         RAISE invalid_batch_status;
      END IF;

      IF (p_batch_size IS NULL OR p_batch_size <= 0) THEN
         RAISE plan_qty_zero_err;
      END IF;

      IF (p_batch_size_uom IS NULL) THEN
         RAISE invalid_item_item_um;
      END IF;

      IF (p_num_batches IS NULL OR p_num_batches <= 0) THEN
         RAISE no_batches;
      END IF;

      IF (p_validity_rule_id < 0) THEN
         RAISE neg_validity_rule_id;
      END IF;

      IF (p_leadtime < 0) THEN
         RAISE leadtime_err;
      END IF;

      IF (p_batch_offset < 0) THEN
         RAISE batch_offset_err;
      END IF;

      IF (p_offset_type NOT IN (0, 1) ) THEN
         RAISE offset_type_err;
      END IF;

      --load parameters into structure.
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('assigning all values to x_pregen_fpo_row');
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      x_pregen_fpo_row.qty_per_batch := p_batch_size;
      x_pregen_fpo_row.batch_size_uom := p_batch_size_uom;
      x_pregen_fpo_row.num_batches := p_num_batches;
      x_pregen_fpo_row.validity_rule_id := p_validity_rule_id;

      IF p_leadtime IS NULL THEN
         x_pregen_fpo_row.leadtime := 0;
      ELSE
         x_pregen_fpo_row.leadtime := p_leadtime;
      END IF;

      IF p_batch_offset IS NULL THEN
         x_pregen_fpo_row.batch_offset := 0;
      ELSE
         x_pregen_fpo_row.batch_offset := p_batch_offset;
      END IF;

      x_pregen_fpo_row.offset_type := p_offset_type;
      x_pregen_fpo_row.plan_start_date := p_plan_start_date;
      x_pregen_fpo_row.plan_cmplt_date := p_plan_cmplt_date;

      IF (x_pregen_fpo_row.sum_eff_qty = 0) THEN
         x_pregen_fpo_row.sum_eff_qty :=
                x_pregen_fpo_row.num_batches * x_pregen_fpo_row.qty_per_batch;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN no_null_dates THEN
         gme_common_pvt.log_message ('GME_NO_NULL_DATES');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN no_populate_both_dates THEN
         gme_common_pvt.log_message ('GME_NO_POPULATE_BOTH_DATES');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN invalid_batch_status THEN
         gme_common_pvt.log_message ('GME_INV_FPO_STATUS');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN plan_qty_zero_err THEN
         gme_common_pvt.log_message ('PM_GT_ZERO_ERR');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN invalid_item_item_um THEN
         gme_common_pvt.log_message ('GME_INVALID_ITEM_OR_ITEM_UM');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN no_batches THEN
         gme_common_pvt.log_message ('PM_INV_NO_BATCHES');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN neg_validity_rule_id THEN
         gme_common_pvt.log_message ('GME_NO_NEG_VALIDITY_RULE_ID');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN leadtime_err THEN
         gme_common_pvt.log_message ('PM_LESSTHAN_ZERO_ERR');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN batch_offset_err THEN
         gme_common_pvt.log_message ('PM_LESSTHAN_ZERO_ERR');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN offset_type_err THEN
         gme_common_pvt.log_message ('PM_OFFSET_TYPE_ERR');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_API_CONVERT_FPO', 'validation');
   END VALIDATION;

--*************************************************************

   --*************************************************************
   PROCEDURE retrieve_fpo_data (
      p_fpo_header_row             IN              gme_batch_header%ROWTYPE
     ,x_fpo_header_row             OUT NOCOPY      gme_batch_header%ROWTYPE
     ,p_pregen_fpo_row             IN              pregen_fpo_row
     ,x_pregen_fpo_row             OUT NOCOPY      pregen_fpo_row
     ,x_prim_prod_row              OUT NOCOPY      gme_material_details%ROWTYPE
     ,x_validity_rule_row          OUT NOCOPY      validity_rule_row
     ,x_fpo_material_details_tab   OUT NOCOPY      fpo_material_details_tab
     ,x_return_status              OUT NOCOPY      VARCHAR2)
   IS
      l_api_name                   CONSTANT VARCHAR2 (30) := 'RETRIEVE_FPO_DATA';
      l_cur_dtl                    PLS_INTEGER;
      l_pregen_fpo_row             pregen_fpo_row;
      l_fpo_material_details_tab   fpo_material_details_tab;
      l_return                     BOOLEAN;
      --Begin Bug 2924803 Anil
      l_prod_row                   gme_material_details%ROWTYPE;
      l_plan_qty                   gme_material_details.plan_qty%TYPE;

      --End Bug 2924803 Anil
      CURSOR get_fpo_material_details (v_batch_id NUMBER)
      IS
         SELECT *
           FROM gme_material_details
          WHERE batch_id = v_batch_id;

      l_fpo_material_details_row   get_fpo_material_details%ROWTYPE;

      CURSOR get_prim_prod_row (v_batch_id NUMBER)
      IS
         SELECT *
           FROM gme_material_details
          WHERE batch_id = v_batch_id
            AND line_type = 1
            AND inventory_item_id =
                   (SELECT inventory_item_id
                      FROM gmd_recipe_validity_rules
                     WHERE recipe_validity_rule_id =
                                             (SELECT recipe_validity_rule_id
                                                FROM gme_batch_header
                                               WHERE batch_id = v_batch_id) );

/* GME CONV
      CURSOR get_production_rules (v_plant_code VARCHAR2, v_item_id NUMBER) IS
         SELECT *
           FROM ic_plnt_inv
          WHERE orgn_code = v_plant_code AND
                item_id = v_item_id AND
                delete_mark = 0;
GME CONV Added following 2 cursors */
--Susruth D. Bug#4917636 Start
      CURSOR item_master_cursor (v_inventory_item_id NUMBER, v_org_id NUMBER)
      IS
      SELECT concatenated_segments,description
            FROM mtl_system_items_kfv
           WHERE inventory_item_id = v_inventory_item_id
             AND organization_id = v_org_id;
         /*SELECT *
           FROM mtl_system_items_kfv
          WHERE inventory_item_id = v_inventory_item_id
            AND organization_id = v_org_id;*/
--Susruth D. Bug#4917636 End.
      l_item_row                   item_master_cursor%ROWTYPE;

      CURSOR get_production_rules (v_inventory_item_id NUMBER, v_org_id NUMBER)
      IS
         SELECT std_lot_size, primary_uom_code, fixed_lead_time
               ,variable_lead_time
           FROM mtl_system_items_b
          WHERE inventory_item_id = v_inventory_item_id
            AND organization_id = v_org_id;

      l_get_production_rules       get_production_rules%ROWTYPE;
      /* Exception definitions */
      no_fetch_material_details    EXCEPTION;
      batch_fetch_error            EXCEPTION;
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      l_pregen_fpo_row := p_pregen_fpo_row;
      --Retrieve fpo_header into local fpo_header_rec structure.
      l_return :=
          gme_batch_header_dbl.fetch_row (p_fpo_header_row, x_fpo_header_row);

      -- exception added
      IF NOT l_return THEN
         RAISE batch_fetch_error;
      END IF;
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' batch header fetch_row returns success ');
      END IF;

      --Retrieve fpo_material_details into local fpo_material_details structure.
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' Retrieve material details  for batch_id '||
                             x_fpo_header_row.batch_id);
      END IF;
      l_cur_dtl := 0;

      OPEN get_fpo_material_details (x_fpo_header_row.batch_id);

      FETCH get_fpo_material_details
       INTO l_fpo_material_details_row;

      IF get_fpo_material_details%FOUND THEN
         WHILE get_fpo_material_details%FOUND LOOP
            l_cur_dtl := l_cur_dtl + 1;
            l_fpo_material_details_tab (l_cur_dtl) :=
                                                   l_fpo_material_details_row;
            x_fpo_material_details_tab (l_cur_dtl) :=
                                       l_fpo_material_details_tab (l_cur_dtl);

            FETCH get_fpo_material_details
             INTO l_fpo_material_details_row;
         END LOOP;
      ELSE
         CLOSE get_fpo_material_details;

         RAISE no_fetch_material_details;
      END IF;

      CLOSE get_fpo_material_details;

      -- Call get_effective_prim_prod api for line_id of the fpo's prim_prod
      --Bogus primary_product line for now......get UK api
      OPEN get_prim_prod_row (p_fpo_header_row.batch_id);

      FETCH get_prim_prod_row
       INTO x_prim_prod_row;

      --Begin Bug 2924803 Anil
      LOOP
         FETCH get_prim_prod_row
          INTO l_prod_row;

         EXIT WHEN get_prim_prod_row%NOTFOUND;

         IF x_prim_prod_row.dtl_um = l_prod_row.dtl_um THEN
            l_plan_qty := l_prod_row.plan_qty;
         ELSE
            gmicuom.icuomcv (x_prim_prod_row.inventory_item_id
                            ,0
                            ,l_prod_row.plan_qty
                            ,l_prod_row.dtl_um
                            ,x_prim_prod_row.dtl_um
                            ,l_plan_qty);
         END IF;

         x_prim_prod_row.plan_qty := x_prim_prod_row.plan_qty + l_plan_qty;
      END LOOP;

      --End Bug 2924803 Anil
      CLOSE get_prim_prod_row;

      --Get prim prod item info
      OPEN item_master_cursor (x_prim_prod_row.inventory_item_id
                              ,p_fpo_header_row.organization_id);

      FETCH item_master_cursor
       INTO l_item_row;

      CLOSE item_master_cursor;

/* GME CONV  Added above lines
      SELECT *
        INTO l_item_row
        FROM ic_item_mst
       WHERE ic_item_mst.item_id = x_prim_prod_row.inventory_item_id;
*/    --Assign primary product details to validity_rule structure
      x_validity_rule_row.organization_id := p_fpo_header_row.organization_id;
      x_validity_rule_row.prim_prod_item_id :=
                                             x_prim_prod_row.inventory_item_id;
      x_validity_rule_row.prim_prod_item_no :=
                                              l_item_row.concatenated_segments;
      x_validity_rule_row.prim_prod_item_desc1 := l_item_row.description;
      x_validity_rule_row.prim_prod_item_um := x_prim_prod_row.dtl_um;
      x_validity_rule_row.prim_prod_effective_qty := x_prim_prod_row.plan_qty;

      --GET PRODUCTION RULES
      OPEN get_production_rules (x_fpo_header_row.organization_id
                                ,x_prim_prod_row.inventory_item_id);

      FETCH get_production_rules
       INTO l_get_production_rules;

      IF get_production_rules%FOUND THEN
         l_pregen_fpo_row.std_qty := l_get_production_rules.std_lot_size;
         l_pregen_fpo_row.fixed_leadtime :=
                                       l_get_production_rules.fixed_lead_time;
         l_pregen_fpo_row.variable_leadtime :=
                                    l_get_production_rules.variable_lead_time;
         l_pregen_fpo_row.rules_found := 1;
      ELSE
         l_pregen_fpo_row.rules_found := 0;
      END IF;

      l_pregen_fpo_row.batch_size_uom := x_prim_prod_row.dtl_um;

      CLOSE get_production_rules;

      x_pregen_fpo_row := l_pregen_fpo_row;
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN no_fetch_material_details THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('no fetch material_details');
         END IF;

         gme_common_pvt.log_message ('PM_NO_MATL_DTL');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN batch_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_API_CONVERT_FPO', 'retrieve_fpo_data');
   END retrieve_fpo_data;

--*************************************************************

   --*************************************************************
   PROCEDURE calculate_leadtime (
      p_pregen_fpo_row   IN              pregen_fpo_row
     ,x_pregen_fpo_row   OUT NOCOPY      pregen_fpo_row
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'CALCULATE_LEADTIME';
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_pregen_fpo_row := p_pregen_fpo_row;
      x_return_status := fnd_api.g_ret_sts_success;

      IF (   p_pregen_fpo_row.variable_leadtime = 0
          OR p_pregen_fpo_row.std_qty = 0) THEN
         x_pregen_fpo_row.leadtime := p_pregen_fpo_row.fixed_leadtime;
      ELSE
         x_pregen_fpo_row.leadtime :=
              p_pregen_fpo_row.fixed_leadtime
            + (  p_pregen_fpo_row.variable_leadtime
               * p_pregen_fpo_row.qty_per_batch
               / p_pregen_fpo_row.std_qty);
      END IF;
   --Bug2804440
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   --End Bug2804440
   END calculate_leadtime;

--*************************************************************
--*****************************************************************
   PROCEDURE generate_pre_batch_header_recs (
      p_fpo_header_row            IN              gme_batch_header%ROWTYPE
     ,p_prim_prod_row             IN              gme_material_details%ROWTYPE
     ,p_pregen_fpo_row            IN              pregen_fpo_row
     ,x_generated_pre_batch_tab   OUT NOCOPY      generated_pre_batch_tab
     ,x_return_status             OUT NOCOPY      VARCHAR2)
   IS
      l_api_name                  CONSTANT VARCHAR2 (30) := 'GENERATE_PRE_BATCH_HEADER_RECS';
      x_prev_plan_start_date      gme_batch_header.plan_start_date%TYPE;
      x_prev_plan_cmplt_date      gme_batch_header.plan_cmplt_date%TYPE;
      x_batch_leadtime_days       NUMBER;
      x_batch_offset_days         NUMBER;
      x_neg_batch_leadtime_days   NUMBER;
      x_neg_batch_offset_days     NUMBER;
      l_fpo_header_row            gme_batch_header%ROWTYPE;
      l_prim_prod_row             gme_material_details%ROWTYPE;
      l_pregen_fpo_row            pregen_fpo_row;
      l_generated_pre_batch_tab   generated_pre_batch_tab;
      /* Exception definitions */
      generate_pre_batch_err      EXCEPTION;
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      l_fpo_header_row := p_fpo_header_row;
      l_prim_prod_row := p_prim_prod_row;
      l_pregen_fpo_row := p_pregen_fpo_row;

      --Convert variables expressed in hours to days.
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'l_pregen_fpo_row.leadtime =  '
                             || TO_CHAR (l_pregen_fpo_row.leadtime) );
      END IF;

      x_batch_leadtime_days := l_pregen_fpo_row.leadtime / 24;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'x_batch_leadtime_days =  '
                             || TO_CHAR (x_batch_leadtime_days) );
         gme_debug.put_line (   'l_pregen_fpo_row.batch_offset =  '
                             || TO_CHAR (l_pregen_fpo_row.batch_offset) );
      END IF;

      x_batch_offset_days := l_pregen_fpo_row.batch_offset / 24;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'x_batch_offset_days =  '
                             || TO_CHAR (x_batch_offset_days) );
      END IF;

      --Negative values of above.
      x_neg_batch_leadtime_days := x_batch_leadtime_days * -1;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'x_neg_batch_leadtime_days =  '
                             || TO_CHAR (x_neg_batch_leadtime_days) );
      END IF;

      x_neg_batch_offset_days := x_batch_offset_days * -1;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'x_neg_batch_offset_days =  '
                             || TO_CHAR (x_neg_batch_offset_days) );
         gme_debug.put_line (   'l_pregen_fpo_row.schedule_method =  '
                             || (l_pregen_fpo_row.schedule_method) );
      END IF;
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' Begin looping here for count of  '||
                             l_pregen_fpo_row.num_batches);
      END IF;

      FOR i IN 1 .. l_pregen_fpo_row.num_batches LOOP
         -- KYH GME CONV BEGIN
      -- l_generated_pre_batch_tab (i).plant_code :=
      --                                          l_fpo_header_row.plant_code;
         l_generated_pre_batch_tab (i).organization_id :=
                                                  l_fpo_header_row.organization_id;
         -- KYH GME CONV END
         l_generated_pre_batch_tab (i).batch_type := 0;
         l_generated_pre_batch_tab (i).fpo_id := l_fpo_header_row.batch_id;

                 -- Bug 3258483 Mohit Kapoor
                 /* Added the assignment of wip_whse_code so that correct
                 wip_whse_code is saved to batch */
         --        l_generated_pre_batch_tab (i).wip_whse_code := l_fpo_header_row.wip_whse_code;
         IF (i = 1) THEN
            --first batch
            IF (l_pregen_fpo_row.schedule_method = 'FORWARD') THEN
               --First batch/Scheduling FORWARD
               l_generated_pre_batch_tab (i).plan_start_date :=
                                             l_pregen_fpo_row.plan_start_date;
               l_generated_pre_batch_tab (i).plan_cmplt_date :=
                     l_pregen_fpo_row.plan_start_date + x_batch_leadtime_days;
            ELSE
               --First Batch/Scheduling BACKWARD
               l_generated_pre_batch_tab (i).plan_cmplt_date :=
                                             l_pregen_fpo_row.plan_cmplt_date;
               l_generated_pre_batch_tab (i).plan_start_date :=
                  l_pregen_fpo_row.plan_cmplt_date
                  + x_neg_batch_leadtime_days;
            END IF;

            IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
               gme_debug.put_line
                     (   'l_generated_pre_batch_tab(i).plan_start_date = '
                      || TO_CHAR
                                (l_generated_pre_batch_tab (i).plan_start_date
                                ,'MM/DD/YYYY hh24:mi:ss') );
               gme_debug.put_line
                      (   'l_generated_pre_batch_tab(i).plan_cmplt_date = '
                       || TO_CHAR
                                (l_generated_pre_batch_tab (i).plan_cmplt_date
                                ,'MM/DD/YYYY hh24:mi:ss') );
            END IF;
         ELSE
            IF (l_pregen_fpo_row.schedule_method = 'FORWARD') THEN
               --Not First Batch; Scheduling FORWARD
               IF (l_pregen_fpo_row.offset_type = 0) THEN
                  --Start-to-Start
                  x_prev_plan_start_date :=
                            l_generated_pre_batch_tab (i - 1).plan_start_date;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line (   'x_prev_plan_start_date = '
                                         || TO_CHAR (x_prev_plan_start_date
                                                    ,'MM/DD/YYYY hh24:mi:ss') );
                  END IF;

                  l_generated_pre_batch_tab (i).plan_start_date :=
                                                        x_prev_plan_start_date;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line
                        (   'l_generated_pre_batch_tab(i).plan_start_date = '
                         || TO_CHAR
                                (l_generated_pre_batch_tab (i).plan_start_date
                                ,'MM/DD/YYYY hh24:mi:ss') );
                  END IF;
               ELSE
                  --End-to-Start
                  x_prev_plan_cmplt_date :=
                            l_generated_pre_batch_tab (i - 1).plan_cmplt_date;
                  l_generated_pre_batch_tab (i).plan_start_date :=
                                                       x_prev_plan_cmplt_date;
               END IF;

               l_generated_pre_batch_tab (i).plan_start_date :=
                    l_generated_pre_batch_tab (i).plan_start_date
                  + x_batch_offset_days;

               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line
                     (   'W/OFFSET l_generated_pre_batch_tab(i).plan_start_date = '
                      || TO_CHAR
                                (l_generated_pre_batch_tab (i).plan_start_date
                                ,'MM/DD/YYYY hh24:mi:ss ') );
               END IF;

               l_generated_pre_batch_tab (i).plan_cmplt_date :=
                    l_generated_pre_batch_tab (i).plan_start_date
                  + x_batch_leadtime_days;

               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line
                     (   'W/LEADTIME l_generated_pre_batch_tab(i).plan_cmplt_date = '
                      || TO_CHAR
                                (l_generated_pre_batch_tab (i).plan_cmplt_date
                                ,'MM/DD/YYYY hh24:mi:ss') );
               END IF;
            ELSIF (l_pregen_fpo_row.schedule_method = 'BACKWARD') THEN
               --Not First Batch; Scheduling BACKWARD
               IF (l_pregen_fpo_row.offset_type = 0) THEN
                  --Start-to-Start
                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line ('BACKWARD scheduling start-to-start');
                  END IF;

                  x_prev_plan_start_date :=
                             l_generated_pre_batch_tab (i - 1).plan_start_date;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line (   'x_prev_plan_start_date = '
                                         || TO_CHAR (x_prev_plan_start_date
                                                    ,'MM/DD/YYYY hh24:mi:ss') );
                  END IF;

                  l_generated_pre_batch_tab (i).plan_start_date :=
                              x_prev_plan_start_date + x_neg_batch_offset_days;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line
                        (   'W/NEG OFFSET l_generated_pre_batch_tab(i).plan_start_date = '
                         || TO_CHAR
                                (l_generated_pre_batch_tab (i).plan_start_date
                                ,'MM/DD/YYYY hh24:mi:ss') );
                  END IF;

                  l_generated_pre_batch_tab (i).plan_cmplt_date :=
                       l_generated_pre_batch_tab (i).plan_start_date
                     + x_batch_leadtime_days;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line
                        (   'W/LEADTIME l_generated_pre_batch_tab(i).plan_cmplt_date = '
                         || TO_CHAR
                                (l_generated_pre_batch_tab (i).plan_cmplt_date
                                ,'MM/DD/YYYY hh24:mi:ss') );
                  END IF;
               ELSE
                  --End-to-Start
                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line ('BACKWARD scheduling end-to-start');
                  END IF;

                  x_prev_plan_start_date :=
                             l_generated_pre_batch_tab (i - 1).plan_start_date;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line (   'x_prev_plan_start_date = '
                                         || TO_CHAR (x_prev_plan_start_date
                                                    ,'MM/DD/YYYY hh24:mi:ss') );
                  END IF;

                  l_generated_pre_batch_tab (i).plan_cmplt_date :=
                              x_prev_plan_start_date + x_neg_batch_offset_days;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line
                        (   'W/NEG OFFSET l_generated_pre_batch_tab(i).plan_cmplt_date = '
                         || TO_CHAR
                                (l_generated_pre_batch_tab (i).plan_cmplt_date
                                ,'MM/DD/YYYY hh24:mi:ss') );
                  END IF;

                  l_generated_pre_batch_tab (i).plan_start_date :=
                       l_generated_pre_batch_tab (i).plan_cmplt_date
                     + x_neg_batch_leadtime_days;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line
                        (   'W/NEG LEADTIME l_generated_pre_batch_tab(i).plan_start_date = '
                         || TO_CHAR
                                (l_generated_pre_batch_tab (i).plan_start_date
                                ,'MM/DD/YYYY hh24:mi:ss') );
                  END IF;
               END IF;
            END IF;
         END IF;

         l_generated_pre_batch_tab (i).due_date :=
                                 l_generated_pre_batch_tab (i).plan_cmplt_date;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                            (   'l_generated_pre_batch_tab(i).due_date= '
                             || TO_CHAR
                                       (l_generated_pre_batch_tab (i).due_date
                                       ,'MM/DD/YYYY hh24:mi:ss') );
         END IF;

         x_generated_pre_batch_tab (i) := l_generated_pre_batch_tab (i);
         x_return_status := fnd_api.g_ret_sts_success;
      END LOOP;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE generate_pre_batch_err;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN generate_pre_batch_err THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                             ('problem generateing the pre_batch-header recs');
         END IF;

         gme_common_pvt.log_message ('GEN_PRE_BATCH_HEADER_ERR');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_API_CONVERT_FPO'
                                 ,'generate_pre_batch_header_recs');
   END generate_pre_batch_header_recs;

--****************************************************************
--****************************************************************
   PROCEDURE convert_fpo_to_batch (
      p_generated_pre_batch_tab    IN              generated_pre_batch_tab
     ,p_recipe_validity_rule_tab   IN              gme_common_pvt.recipe_validity_rule_tab
     ,p_pregen_fpo_row             IN              pregen_fpo_row
     ,x_generated_pre_batch_tab    OUT NOCOPY      generated_pre_batch_tab
     ,x_return_status              OUT NOCOPY      VARCHAR2
     ,x_arr_rtn_sts                OUT NOCOPY      return_array_sts
     ,p_process_row                IN              NUMBER DEFAULT 0
     ,p_use_shop_cal               IN              VARCHAR2 := fnd_api.g_false
     ,p_contiguity_override        IN              VARCHAR2 := fnd_api.g_true
     ,x_exception_material_tbl     OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,p_fpo_validity_rule_id       IN              NUMBER --BUG#3185748 Sastry
                                                         )
   IS
      l_api_name          CONSTANT VARCHAR2 (30)    := 'CONVERT_FPO_TO_BATCH';
      dummy                        NUMBER;
      l_generated_pre_batch_tab    generated_pre_batch_tab;
      l_pre_batch_row              gme_batch_header%ROWTYPE;
      l_in_pre_batch_row           gme_batch_header%ROWTYPE;
      l_recipe_validity_rule_tab   gme_common_pvt.recipe_validity_rule_tab;
      l_pregen_fpo_row             pregen_fpo_row;
      l_exception_material_tbl     gme_common_pvt.exceptions_tab;
      l_return_status              VARCHAR2 (1);
      l_api_version                NUMBER;
      l_validation_level           NUMBER                              := 100;
      l_batch_size                 gme_material_details.plan_qty%TYPE;
      l_batch_uom                  gme_material_details.dtl_um%TYPE;
      l_creation_mode              VARCHAR2 (10);
      l_om_gme_batch_rec           gml_batch_om_util.batch_line_rec;
      -- Bug 3185748 Added variables, validation_failure and cursor get_validity_rule .
      l_inventory_item_id          NUMBER;  -- KYH GME CONV
      l_item_um                    VARCHAR2 (3);
      /* Exception definitions */
      batch_creation_failure       EXCEPTION;
      validation_failure           EXCEPTION;
      --Swapna Kommineni bug#3565971 13/08/2004 Added variables to store the start and end dates
      --calculated for the previous batch.
      l_prev_start_date            DATE;
      l_prev_cmplt_date            DATE;
      l_msg_count                  NUMBER;
      l_msg_data                   VARCHAR2(300);


      /* Cusror definitions */
      --KYH GME Convergence - replace ic_item_mst with mtl_system_items
      --Remember that organization_id can be null in gmd_recipe_validity_rules
      Cursor get_validity_rule (v_validity_rule_id NUMBER,v_organization_id NUMBER) IS
	  SELECT v.inventory_item_id, i.primary_uom_code
          FROM   gmd_recipe_validity_rules v, mtl_system_items i
          WHERE  recipe_validity_rule_id = v_validity_rule_id
          AND  i.organization_id = v_organization_id
          AND  v.inventory_item_id = i.inventory_item_id;
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      dummy := 0;
      l_validation_level := gme_common_pvt.g_max_errors;
      l_api_version := 2.0;
      l_generated_pre_batch_tab := p_generated_pre_batch_tab;
      l_recipe_validity_rule_tab := p_recipe_validity_rule_tab;
      l_pregen_fpo_row := p_pregen_fpo_row;
      l_batch_size := l_pregen_fpo_row.qty_per_batch;
      -- change for item_uom for bug 2398719
      l_batch_uom := l_pregen_fpo_row.batch_size_uom;
      --Swapna Kommineni bug#3565971 13/08/2004 Initialization of variables to NULL
      l_prev_start_date := NULL;
      l_prev_cmplt_date := NULL;
      l_creation_mode := 'PRODUCT';

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
        gme_debug.put_line (g_pkg_name ||
                            '.'        ||
                            l_api_name ||
                            'Batch UOM is '||
                            l_batch_uom);
      END IF;

      --Populate generated_pre_batch_tab with validity_rule.
      IF (p_process_row = 0) THEN
        IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
          gme_debug.put_line (g_pkg_name ||
                              '.'        ||
                              l_api_name ||
                              ' p_process_row is set to 0     ');
         END IF;
         FOR i IN 1 .. p_generated_pre_batch_tab.COUNT LOOP
            -- Bug 3185748 Added Begin .. End
            BEGIN
               gme_common_pvt.g_error_count := 0;
               l_generated_pre_batch_tab (i).recipe_validity_rule_id :=
                       l_recipe_validity_rule_tab (i).recipe_validity_rule_id;
               -- Populate header row with values of generated_pre_batch_tab row.
               l_pre_batch_row := l_generated_pre_batch_tab (i);
               -- Create batches from the generate_pre_batch_tab.
               -- Pawan Kumar changed the call to private layer from the public layer for creat_batch
               l_in_pre_batch_row := l_pre_batch_row;
               --BEGIN BUG#3185748 Sastry
               SAVEPOINT create_batch;

               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (g_pkg_name ||
                                      '.'        ||
                                      l_api_name ||
                                      ' Retrieve validity_rule for id '||
                                      p_fpo_validity_rule_id||
                                      ' organization_id is '||
                                      l_in_pre_batch_row.organization_id);
               END IF;
               OPEN get_validity_rule (p_fpo_validity_rule_id,l_in_pre_batch_row.organization_id);

               FETCH Get_validity_rule INTO l_inventory_item_id, l_item_um; -- KYH GME CONV

               IF get_validity_rule%NOTFOUND THEN
                  gme_common_pvt.log_message
                                            ('GME_VALIDITY_RULE_RETRIEVE_ERR');

                  CLOSE get_validity_rule;

                  RAISE validation_failure;
               END IF;

               CLOSE get_validity_rule;

               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (g_pkg_name ||
                                      '.'        ||
                                      l_api_name ||
                                      ' Invoke validate validity rule ');
               END IF;
               IF NOT gme_common_pvt.validate_validity_rule
                        (p_validity_rule_id      => l_in_pre_batch_row.recipe_validity_rule_id
                        ,p_organization_id       => l_in_pre_batch_row.organization_id
                        ,p_prim_product_id       => l_inventory_item_id
                        ,p_qty                   => l_batch_size
                        ,p_uom                   => l_item_um
                        ,p_object_type           => 'P'
                        ,p_start_date            => l_in_pre_batch_row.plan_start_date
                        ,p_cmplt_date            => l_in_pre_batch_row.plan_cmplt_date
                        ,p_creation_mode         => 'PRODUCT') THEN
                  RAISE validation_failure;
               END IF;

               --END BUG#3185748
               --Rishi Varma bug#3460631 22/03/04
               --assigned null to the due date as the due date should be
               --defaulted to the planned completion date.
               l_in_pre_batch_row.due_date := NULL;

               --Swapna Kommineni bug#3565971 13/08/2004 Start
               /*This will recalculate the start and end dates for the second batch onwards depending on
                 the calculated completed or start dates of the first batch only in the case leadtime is
                 not given.In the case leadtime is given the correct dates will be calculated from
                 generate_pre_batch_header_recs*/
               IF (    l_prev_cmplt_date IS NOT NULL
                   AND l_prev_start_date IS NOT NULL
                   AND l_pregen_fpo_row.leadtime = 0
                   AND l_pregen_fpo_row.offset_type = 1) THEN
                  IF (l_pregen_fpo_row.schedule_method = 'FORWARD') THEN
                     l_in_pre_batch_row.plan_start_date :=
                          l_prev_cmplt_date
                        + NVL (l_pregen_fpo_row.batch_offset, 0) / 24;
                     l_in_pre_batch_row.plan_cmplt_date := NULL;
                  ELSIF (l_pregen_fpo_row.schedule_method = 'BACKWARD') THEN
                     l_in_pre_batch_row.plan_cmplt_date :=
                          l_prev_start_date
                        - NVL (l_pregen_fpo_row.batch_offset, 0) / 24;
                     l_in_pre_batch_row.plan_start_date := NULL;
                  END IF;
               END IF;

               --Swapna Kommineni bug#3565971 13/08/2004 End
               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (g_pkg_name ||
                                      '.'        ||
                                      l_api_name ||
                                      ' about to invoke create_batch ');
               END IF;
               gme_create_batch_pvt.create_batch
                         (p_validation_level            => l_validation_level
                         ,x_return_status               => l_return_status
                         ,p_batch_header_rec            => l_in_pre_batch_row
                         ,x_batch_header_rec            => l_pre_batch_row
                         ,p_batch_size                  => l_batch_size
                         ,p_batch_size_uom              => l_batch_uom
                         ,p_creation_mode               => l_creation_mode
                         ,p_ignore_qty_below_cap        => 'T'
                         ,p_use_workday_cal             => p_use_shop_cal
                         ,p_contiguity_override         => p_contiguity_override
                         ,x_exception_material_tbl      => l_exception_material_tbl);

               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (g_pkg_name ||
                                      '.'        ||
                                      l_api_name ||
                                      ' create_batch returns status of '||
                                      l_return_status );
               END IF;
               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  x_arr_rtn_sts (i).return_status := l_return_status;

                  -- Pawan Kumar ADDED code for bug 2398719
                  IF l_return_status NOT IN (gme_common_pvt.g_inv_short_err) THEN
                     RAISE batch_creation_failure;
                  ELSE
                     FOR j IN 1 .. l_exception_material_tbl.COUNT LOOP
                        x_exception_material_tbl (i) :=
                                                 l_exception_material_tbl (j);
                     END LOOP;
                  END IF;
               END IF;      /* l_return_status <> FND_API.G_RET_STS_SUCCESS */

               --Swapna Kommineni bug#3565971 13/08/2004 Assigning the planned start and end dates of
               --batch that are calculated from the create_batch api
               l_prev_start_date := l_pre_batch_row.plan_start_date;
               l_prev_cmplt_date := l_pre_batch_row.plan_cmplt_date;
               x_generated_pre_batch_tab (i) := l_pre_batch_row;
            -- B3140274 OM-GME integration - CONVERT for convert FPO to batch
            -- B3194346 OM-GME integration - call to central routine

            /*            GME_TRANS_ENGINE_PVT.inform_OM
                            ( p_action              => 'CONVERT'
                            , p_trans_id            => NULL
                            , p_trans_id_reversed   => NULL
                            , p_gme_batch_hdr       => l_pre_batch_row
                            , p_gme_matl_dtl        => NULL
                            );   */
                      GME_SUPPLY_RES_PVT.create_reservation_from_FPO
                            (    P_FPO_batch_id  => l_pre_batch_row.fpo_id
                               , P_New_batch_id  => l_pre_batch_row.batch_id
                               , X_return_status => x_return_status
                               , X_msg_count     => l_msg_count
                               , X_msg_data      => l_msg_data
                            );

           --BEGIN BUG#3185748 Sastry
            EXCEPTION
               WHEN batch_creation_failure OR validation_failure THEN
                  x_return_status := fnd_api.g_ret_sts_error;
                  ROLLBACK TO SAVEPOINT create_batch;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line ('batch creation_fail');
                  END IF;
            END;
         --END BUG#3185748
         END LOOP;
      ELSE                                        /* IF (p_process_row = 0) */
         l_generated_pre_batch_tab (p_process_row).recipe_validity_rule_id :=
            l_recipe_validity_rule_tab (p_process_row).recipe_validity_rule_id;
         -- Populate header row with values of generated_pre_batch_tab row.
         l_pre_batch_row := l_generated_pre_batch_tab (p_process_row);
         -- Create batches from the generate_pre_batch_tab.
         -- Pawan Kumar changed the call to private layer from public API
         l_in_pre_batch_row := l_pre_batch_row;
         gme_create_batch_pvt.create_batch
                        (p_validation_level            => l_validation_level
                        ,x_return_status               => l_return_status
                        ,p_batch_header_rec            => l_in_pre_batch_row
                        ,x_batch_header_rec            => l_pre_batch_row
                        ,p_batch_size                  => l_batch_size
                        ,p_batch_size_uom              => l_batch_uom
                        ,p_creation_mode               => l_creation_mode
                        ,p_ignore_qty_below_cap        => 'T'
                        ,p_use_workday_cal             => p_use_shop_cal
                        ,p_contiguity_override         => p_contiguity_override
                        ,x_exception_material_tbl      => l_exception_material_tbl);

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (g_pkg_name ||
                                '.'        ||
                                l_api_name ||
                                ' call to create_batch returns status of '||
                                l_return_status||
                                ' current return status '||
                                x_return_status);
         END IF;
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_arr_rtn_sts (p_process_row).return_status := l_return_status;

            IF l_return_status NOT IN (gme_common_pvt.g_inv_short_err) THEN
               RAISE batch_creation_failure;
            END IF;
         END IF;

         x_generated_pre_batch_tab (p_process_row) := l_pre_batch_row;
      -- B3140274 OM-GME integration - CONVERT for convert FPO to batch
      -- B3194346 OM-GME integration - call to central routine

      /*         GME_TRANS_ENGINE_PVT.inform_OM
                            ( p_action              => 'CONVERT'
                            , p_trans_id            => NULL
                            , p_trans_id_reversed   => NULL
                            , p_gme_batch_hdr       => l_pre_batch_row
                            , p_gme_matl_dtl        => NULL
                            );  */
               GME_SUPPLY_RES_PVT.create_reservation_from_FPO
                            (    P_FPO_batch_id  => l_pre_batch_row.fpo_id
                               , P_New_batch_id  => l_pre_batch_row.batch_id
                               , X_return_status => x_return_status
                               , X_msg_count     => l_msg_count
                               , X_msg_data      => l_msg_data
                            );

      END IF;                                     /* IF (p_process_row = 0) */
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name ||' with status '||x_return_status);
      END IF;
   EXCEPTION
      WHEN batch_creation_failure THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('batch creation_fail');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('x_return_status = ' || x_return_status);
         END IF;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_API_CONVERT_FPO'
                                 ,'CONVERT_FPO_TO_BATCH');
   END convert_fpo_to_batch;

--*********************************************************
--*********************************************************
   PROCEDURE update_original_fpo (
      p_fpo_header_row             IN              gme_batch_header%ROWTYPE
     ,p_prim_prod_row              IN              gme_material_details%ROWTYPE
     ,p_pregen_fpo_row             IN              pregen_fpo_row
     ,p_fpo_material_details_tab   IN              fpo_material_details_tab
     ,p_enforce_vldt_check         IN              VARCHAR2 := fnd_api.g_true
     ,x_fpo_header_row             OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status              OUT NOCOPY      VARCHAR2)
   IS
      CURSOR get_phantom_fpo (v_batch_id NUMBER)
      IS
         SELECT phantom_id
           FROM gme_material_details
          WHERE batch_id = v_batch_id AND phantom_id IS NOT NULL;

      l_api_name                   CONSTANT VARCHAR2 (30) := 'UPDATE_ORIGINAL_FPO';
      l_fpo_header_row             gme_batch_header%ROWTYPE;
      l_prim_prod_row              gme_material_details%ROWTYPE;
      l_pregen_fpo_row             pregen_fpo_row;
      l_fpo_material_details_tab   fpo_material_details_tab;
      l_over_allocations           gme_common_pvt.exceptions_tab;
      l_tran_row                   gme_inventory_txns_gtmp%ROWTYPE;
      --  GME CONV l_tran_tab                    gme_common_pvt.transactions_tab;
      l_batch_header               gme_batch_header%ROWTYPE;
      x_batch_header               gme_batch_header%ROWTYPE;
      l_resource_txns              gme_resource_txns_gtmp%ROWTYPE;
      l_resource_tab               gme_common_pvt.resource_transactions_tab;
--   l_batch_type                  ic_tran_pnd.doc_type%TYPE;
      l_scale_factor               NUMBER;
      l_primaries                  VARCHAR2 (8);
      l_batch_status               gme_batch_header.batch_status%TYPE;
      l_mat_row_count              NUMBER;
      l_rsc_row_count              NUMBER;
      l_return_status              VARCHAR2 (1);
      l_return                     BOOLEAN;
      l_exception_material_tbl     gme_common_pvt.exceptions_tab;
      /*Exceptions */
      load_rsrc_trans_err          EXCEPTION;
      gme_fetch_all_trans_err      EXCEPTION;
      update_row_err               EXCEPTION;
      delete_pending_trans_err     EXCEPTION;
      scale_batch_err              EXCEPTION;
      update_pending_trans         EXCEPTION;
      cancel_batch_err             EXCEPTION;
      fetch_batch_err              EXCEPTION;
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;

      l_fpo_header_row := p_fpo_header_row;
      l_batch_status := l_fpo_header_row.batch_status;
      l_fpo_material_details_tab := p_fpo_material_details_tab;
      l_primaries := 'OUTPUTS';
      l_prim_prod_row := p_prim_prod_row;
      l_pregen_fpo_row := p_pregen_fpo_row;
      -- Working with the Pending Transactions of the original FPO.
      --
      -- Load pending transactions for FPO from ic_tran_pnd to
      -- gme temp table. Will have to work
      -- with pending transactions.
      gme_trans_engine_util.load_rsrc_trans (p_batch_row     => l_fpo_header_row
                                             ,x_rsc_row_count => l_rsc_row_count
                                             ,x_return_status => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE load_rsrc_trans_err;
      END IF;

            --Fetch all Pending transactions for original FPO
            --into local table.
            /*  GME CONV
            l_tran_row.doc_id := l_fpo_header_row.batch_id;
            l_tran_row.doc_type := 'FPO';
            gme_trans_engine_pvt.fetch_all_trans (
               l_tran_row,
               l_tran_tab,
               l_return_status
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE gme_fetch_all_trans_err;
            END IF;
      GME CONV */

      -- Determine whether sum of effective qtys inserted is
-- less than the original FPO quantity.
-- If less than the original FPO qty
-- scale the original FPO and all pending transactions to the
-- difference.
-- If greater than or equal to the original FPO qty, set FPO status
-- to converted and delete pending transactions.
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'l_prim_prod_row.plan_qty = '
                             || TO_CHAR (l_prim_prod_row.plan_qty) );
         gme_debug.put_line (   'l_pregen_fpo_row.sum_eff_qty = '
                             || TO_CHAR (l_pregen_fpo_row.sum_eff_qty) );
      END IF;

      IF (l_prim_prod_row.plan_qty <= l_pregen_fpo_row.sum_eff_qty) THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                        ('in IF.gonna update header and delete pending trans');
         END IF;

         --Update FPO status to CONVERTED
         l_fpo_header_row.batch_status := -3;
         l_return := gme_batch_header_dbl.update_row (l_fpo_header_row);

         IF NOT l_return THEN
            IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
               gme_debug.put_line ('l_return from update_row = FALSE');
            END IF;

            RAISE update_row_err;
         ELSE
            IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
               gme_debug.put_line ('l_return from update_row = TRUE');
            END IF;
         END IF;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   'l_fpo_header_row.batch_status = '
                                || TO_CHAR (l_fpo_header_row.batch_status) );
            gme_debug.put_line (   'l_fpo_header_row.batch_id = '
                                || TO_CHAR (l_fpo_header_row.batch_id) );
            gme_debug.put_line (   'l_fpo_header_row.batch_type = '
                                || TO_CHAR (l_fpo_header_row.batch_type) );
         END IF;

         --FPBug#4941012 set plan qty to zero for parent FPO
	 UPDATE gme_material_details
	    SET plan_qty = 0
	  WHERE batch_id = l_fpo_header_row.batch_id;

         --Gonna delete the pending transactions associated with orig FPO
         /* GME CONV

         FOR i IN 1 .. l_tran_tab.COUNT
         LOOP
            l_tran_row := l_tran_tab (i);
            l_tran_row.alloc_qty := 0;
            l_tran_row.trans_qty := 0;
            l_tran_row.trans_qty2 := 0;
            gme_trans_engine_pvt.update_pending_trans (
               l_tran_row,
               l_return_status
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE update_pending_trans;
            END IF;
         END LOOP;
        GME CONV */

         --Fetch all resource transactions for original FPO
         --into local table.
         l_resource_txns.doc_id := l_fpo_header_row.batch_id;
         gme_resource_engine_pvt.fetch_active_resources
                                           (p_resource_rec       => l_resource_txns
                                           ,x_resource_tbl       => l_resource_tab
                                           ,x_return_status      => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE gme_fetch_all_trans_err;
         END IF;                   /* IF l_return_status <> x_return_status */

         FOR i IN 1 .. l_resource_tab.COUNT LOOP
            l_resource_txns := l_resource_tab (i);
            /* Bug 2376315 - Thomas Daniel */
            /* Commented the following code for updating the resource usage to zero and added */
            /* code to delete the resource transactions */

            /*l_resource_txns.resource_usage := 0;
            GME_RESOURCE_ENGINE_PVT.update_resource_trans (p_tran_row    => l_resource_txns
                                                          ,x_return_status  => l_return_status);*/
            gme_resource_engine_pvt.delete_resource_trans
                                          (p_tran_rec           => l_resource_txns
                                          ,x_return_status      => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE update_row_err;
            END IF;
         END LOOP;                      /* FOR i IN 1..l_resource_tab.COUNT */

         -- Add code for canel phantom fpo
         --  pk_fpo('in fpo-before cancel'||l_fpo_header_row.batch_id);
         FOR l_rec IN get_phantom_fpo (l_fpo_header_row.batch_id) LOOP
            l_batch_header.batch_id := l_rec.phantom_id;

            IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
               gme_debug.put_line (   'phantom to cancel = '
                                   || TO_CHAR (l_batch_header.batch_id) );
            END IF;

            --FPBug#4941012
	    IF NOT gme_batch_header_dbl.fetch_row(l_batch_header,
	                                          l_batch_header) THEN
              RAISE fetch_batch_err;
	    END IF;

            gme_cancel_batch_pvt.cancel_batch
                                        (p_batch_header_rec      => l_batch_header
                                        ,x_batch_header_rec      => x_batch_header
                                        ,x_return_status         => x_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE cancel_batch_err;
            END IF;
         END LOOP;
      ELSE
         --Scale FPO material details line
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('gonna do some scaling');
         END IF;

         l_scale_factor :=
              (l_prim_prod_row.plan_qty - l_pregen_fpo_row.sum_eff_qty)
            / l_prim_prod_row.plan_qty;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('l_scale_factor = ' || l_scale_factor);
         END IF;

           --p_qty_type is default 1 for the plan qty only
         /* l_over_allocations parameter is used to handle default lot going */
         /* negative cases, which would not be a case here as their are no   */
         /* actual allocations against the FPO               */
         gme_scale_batch_pvt.scale_batch
                         (p_batch_header_rec            => l_fpo_header_row
                         ,p_scale_factor                => l_scale_factor
                         ,p_primaries                   => l_primaries
                         ,p_qty_type                    => 1
                         ,p_validity_rule_id            => NULL
                         ,p_enforce_vldt_check          => 'F'
                         ,p_use_workday_cal             => 'F'
                         ,p_contiguity_override         => 'T'
                         ,p_recalc_dates                => 'T'
                         ,x_return_status               => l_return_status
                         ,x_batch_header_rec            => x_fpo_header_row
                         ,x_exception_material_tbl      => l_exception_material_tbl);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE scale_batch_err;
         END IF;
      END IF;

      x_fpo_header_row := l_fpo_header_row;
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN load_rsrc_trans_err THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('load_rsrc_trans_err_fail');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN cancel_batch_err THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Cancel_FPO_PHANTOM_fail');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN gme_fetch_all_trans_err THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('fetch_alltrans_err_fail');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      --FPBug#4941012
      WHEN fetch_batch_err THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('fetch batch header fail');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN update_row_err THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('update_row _fail');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN delete_pending_trans_err THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('delete_pending_trans _fail');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN scale_batch_err THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('scale_batch _fail');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN update_pending_trans THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('update_pending_trans _fail');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_API_CONVERT_FPO'
                                 ,'UPDATE_ORIGINAL_FPO');
   END update_original_fpo;

--*********************************************************
   PROCEDURE convert_fpo_main (
      p_batch_header          IN              gme_batch_header%ROWTYPE
     ,p_batch_size            IN              NUMBER
     ,p_num_batches           IN              NUMBER
     ,p_validity_rule_id      IN              NUMBER
     ,p_validity_rule_tab     IN              gme_common_pvt.recipe_validity_rule_tab
     ,p_enforce_vldt_check    IN              VARCHAR2 := fnd_api.g_true
     ,p_leadtime              IN              NUMBER
     ,p_batch_offset          IN              NUMBER
     ,p_offset_type           IN              NUMBER
     ,
--      p_schedule_method      IN       VARCHAR2,
      p_plan_start_date       IN              gme_batch_header.plan_start_date%TYPE
     ,p_plan_cmplt_date       IN              gme_batch_header.plan_cmplt_date%TYPE
     ,p_use_shop_cal          IN              VARCHAR2 := fnd_api.g_false
     ,p_contiguity_override   IN              VARCHAR2 := fnd_api.g_true
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_batch_header          OUT NOCOPY      gme_batch_header%ROWTYPE
     ,p_use_for_all           IN              VARCHAR2 := fnd_api.g_true)
   IS
      l_api_name              CONSTANT VARCHAR2 (30) := 'CONVERT_FPO_MAIN';
      /* Cursor definitions */
      --KYH GME Convergence - replace ic_item_mst with mtl_system_items
      Cursor get_validity_rule (v_validity_rule_id NUMBER, v_organization_id NUMBER) IS
	  SELECT v.inventory_item_id, i.primary_uom_code
          FROM   gmd_recipe_validity_rules v, mtl_system_items i
          WHERE  recipe_validity_rule_id = v_validity_rule_id
          AND  i.organization_id = v_organization_id
          AND  v.inventory_item_id = i.inventory_item_id;

      /* Local variables */
      l_inventory_item_id            NUMBER; -- KYH GME CONV
      l_fpo_header_row               gme_batch_header%ROWTYPE;
      l_in_fpo_header_row            gme_batch_header%ROWTYPE;
      l_batch_header                 gme_batch_header%ROWTYPE;
      l_prim_prod_row                gme_material_details%ROWTYPE;
      l_fpo_material_details_tab     fpo_material_details_tab;
      l_validity_rule_row            validity_rule_row;
      l_pregen_fpo_row               pregen_fpo_row;
      l_in_pregen_fpo_row            pregen_fpo_row;
      x_pregen_fpo_row               pregen_fpo_row;
      l_generated_pre_batch_tab      generated_pre_batch_tab;
      l_in_generated_pre_batch_tab   generated_pre_batch_tab;
      l_recipe_validity_rule_tab     gme_common_pvt.recipe_validity_rule_tab;
      l_return_status                VARCHAR2 (1);
      l_item_um                      VARCHAR2 (4);
      l_arr_rtn_sts                  return_array_sts;
      l_batch_range                  VARCHAR2 (2000);
      l_exception_material_tbl       gme_common_pvt.exceptions_tab;
      /* Exception definitions */
      validation_failure             EXCEPTION;
      fpo_retrieval_failure          EXCEPTION;
      batch_generation_failure       EXCEPTION;
      insufficient_validity_rules    EXCEPTION;
      create_batch_failure           EXCEPTION;
      update_original_fpo_failure    EXCEPTION;
      batch_header_fetch_error       EXCEPTION;
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.log_initialize ('ConvertFPO');
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      -- Pawan Kumar ADDED code for bug 2398719
      l_batch_header.batch_id := p_batch_header.batch_id;
      /* Bug2403042: Added following code to identify the
         FPO based on batch_no, and plant_code */
      l_batch_header.batch_no := p_batch_header.batch_no;
      l_batch_header.organization_id := p_batch_header.organization_id; -- KYH GME CONV
      l_batch_header.batch_id        := p_batch_header.batch_id;        -- KYH GME CONV
      l_batch_header.batch_type      := 10;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' Retrieve batch header for batch_id '||
                             l_batch_header.batch_id);
      END IF;
      IF NOT (gme_batch_header_dbl.fetch_row (l_batch_header, l_batch_header) ) THEN
         RAISE batch_header_fetch_error;
      END IF;

      /* Get the validity rule for the existing FPO */
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' Retrieve validity rule for rule_id '||
                             l_batch_header.recipe_validity_rule_id);
      END IF;
      OPEN get_validity_rule (l_batch_header.recipe_validity_rule_id,l_batch_header.organization_id);

      FETCH get_validity_rule
       INTO l_inventory_item_id, l_item_um;

      IF get_validity_rule%NOTFOUND THEN
         gme_common_pvt.log_message ('GME_VALIDITY_RULE_RETRIEVE_ERR');

         CLOSE get_validity_rule;

         RAISE validation_failure;
      END IF;

      CLOSE get_validity_rule;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' Invoke Validation  ');
      END IF;

      VALIDATION (p_batch_header          => l_batch_header
                 ,
--         x_batch_header => x_batch_header,
                  p_batch_size            => p_batch_size
                 ,p_batch_size_uom        => l_item_um
                 ,p_num_batches           => p_num_batches
                 ,p_validity_rule_id      => p_validity_rule_id
                 ,p_leadtime              => p_leadtime
                 ,p_batch_offset          => p_batch_offset
                 ,p_offset_type           => p_offset_type
                 ,
--         p_schedule_method => p_schedule_method,
                  p_plan_start_date       => p_plan_start_date
                 ,p_plan_cmplt_date       => p_plan_cmplt_date
                 ,x_pregen_fpo_row        => x_pregen_fpo_row
                 ,x_return_status         => x_return_status);

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' VALIDATION procedure returns  '||
                             x_return_status);
      END IF;

      l_pregen_fpo_row := x_pregen_fpo_row;
      l_fpo_header_row := l_batch_header;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE validation_failure;
      END IF;

      l_in_fpo_header_row := l_fpo_header_row;
      l_in_pregen_fpo_row := l_pregen_fpo_row;
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' About to INVOKE retrieve_fpo_data ');
      END IF;
      retrieve_fpo_data
                    (p_fpo_header_row                => l_in_fpo_header_row
                    ,x_fpo_header_row                => l_fpo_header_row
                    ,p_pregen_fpo_row                => l_in_pregen_fpo_row
                    ,x_pregen_fpo_row                => l_pregen_fpo_row
                    ,x_prim_prod_row                 => l_prim_prod_row
                    ,x_validity_rule_row             => l_validity_rule_row
                    ,x_fpo_material_details_tab      => l_fpo_material_details_tab
                    ,x_return_status                 => x_return_status);

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' retrieve_fpo_data returns status of '||
                             x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fpo_retrieval_failure;
      END IF;

      l_item_um := l_prim_prod_row.dtl_um;

      IF p_use_for_all = fnd_api.g_true THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
           gme_debug.put_line (g_pkg_name ||
                               '.'        ||
                               l_api_name ||
                               ' p_use_for_all is TRUE ');
         END IF;
         IF p_validity_rule_id IS NULL OR p_validity_rule_id = 0 THEN
            RAISE insufficient_validity_rules;
         -- Bug 3185748 Removed the code to validate the validity rule if
         -- p_validity_rule_id is not null. The validation is done before creating the batch.
         END IF;                           /* p_validity_rule_id IS NULL OR */

         FOR i IN 1 .. p_num_batches LOOP
            l_recipe_validity_rule_tab (i).recipe_validity_rule_id :=
                                                           p_validity_rule_id;
         END LOOP;
      ELSE                                              /* IF p_use_for_all */
         IF p_num_batches = 1 THEN
            IF p_validity_rule_id IS NULL THEN
               RAISE insufficient_validity_rules;
            -- Bug 3185748 Removed the code to validate the validity rule if
            -- p_validity_rule_id is not null. The validation is done before creating the batch.
            END IF;

            l_recipe_validity_rule_tab (1).recipe_validity_rule_id :=
                                                            p_validity_rule_id;
         ELSE                                       /* IF p_num_batches = 1 */
            IF p_validity_rule_tab.COUNT <> p_num_batches THEN
               RAISE insufficient_validity_rules;
            -- Bug 3185748 Removed the code to validate the validity rule if
            -- p_validity_rule_id is not null. The validation is done before creating the batch.
            END IF;        /* IF p_validity_rule_tab.COUNT <> p_num_batches */

            l_recipe_validity_rule_tab := p_validity_rule_tab;
         END IF;                                    /* IF p_num_batches = 1 */
      END IF;                                           /* IF p_use_for_all */

      --Swapna Kommineni bug#3565971 13/08/2004 commented the code so that passed lead time
      -- does not get overwritten.
/*    IF (l_pregen_fpo_row.rules_found = 1) THEN
         l_in_pregen_fpo_row := l_pregen_fpo_row;
         calculate_leadtime (
            p_pregen_fpo_row => l_in_pregen_fpo_row,
            x_pregen_fpo_row => l_pregen_fpo_row,
            x_return_status => l_return_status
         );
      END IF; */
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' Retrieve batch header for batch_id '||
                             l_batch_header.batch_id);
      END IF;
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' Invoke generate_pre_batch_header_recs');
      END IF;
      generate_pre_batch_header_recs
                      (p_fpo_header_row               => l_fpo_header_row
                      ,p_prim_prod_row                => l_prim_prod_row
                      ,p_pregen_fpo_row               => l_pregen_fpo_row
                      ,x_generated_pre_batch_tab      => l_generated_pre_batch_tab
                      ,x_return_status                => x_return_status);

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' generate_pre_batch_header_recs returns '||
                             x_return_status );
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE batch_generation_failure;
      END IF;

      --Swapna Kommineni bug#3565971 13/08/2004 Start
      FOR i IN 1 .. l_generated_pre_batch_tab.COUNT LOOP
--       IF (p_leadtime is NULL) and  (i=1) THEN

         --Swapna Kommineni reopened bug#3565971 07/09/2004
           /* Only when the leadtime is not passed then the start and enddates calculated
             from generate_pre_batch_header_recs will be changed */
         IF (p_leadtime IS NULL) THEN
            IF (i = 1) THEN
               /* For the first batch if the leadtime is not passed then plan start and end dates are
               passed to the create_batch api as the given dates. so that api will*/
               l_generated_pre_batch_tab (i).plan_start_date :=
                                                            p_plan_start_date;
               l_generated_pre_batch_tab (i).plan_cmplt_date :=
                                                            p_plan_cmplt_date;
            ELSE
               IF (p_plan_cmplt_date IS NULL) THEN
                  l_generated_pre_batch_tab (i).plan_cmplt_date :=
                                                            p_plan_cmplt_date;
               ELSIF (p_plan_start_date IS NULL) THEN
                  l_generated_pre_batch_tab (i).plan_start_date :=
                                                            p_plan_start_date;
               END IF;
            END IF;
         END IF;
      END LOOP;

      --Swapna Kommineni bug#3565971 13/08/2004 End
      l_in_generated_pre_batch_tab := l_generated_pre_batch_tab;
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' Invoke convert_fpo_to_batch ');
      END IF;
      convert_fpo_to_batch
         (p_generated_pre_batch_tab       => l_in_generated_pre_batch_tab
         ,p_recipe_validity_rule_tab      => l_recipe_validity_rule_tab
         ,p_pregen_fpo_row                => l_pregen_fpo_row
         ,x_generated_pre_batch_tab       => l_generated_pre_batch_tab
         ,p_use_shop_cal                  => p_use_shop_cal
         ,p_contiguity_override           => p_contiguity_override
         ,x_return_status                 => x_return_status
         ,x_arr_rtn_sts                   => l_arr_rtn_sts
         ,x_exception_material_tbl        => l_exception_material_tbl
         ,p_fpo_validity_rule_id          => l_batch_header.recipe_validity_rule_id
                                                                -- Bug 3185748
                                                                                   );
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name ||
                             '.'        ||
                             l_api_name ||
                             ' convert_fpo_to_batch returns  '||
                             x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE create_batch_failure;
      END IF;

      --BEGIN BUG#3185748 Sastry
      -- Call update fpo only if some batches were created.
      IF l_generated_pre_batch_tab.COUNT > 0 THEN
         l_pregen_fpo_row.num_batches := l_generated_pre_batch_tab.COUNT;
         l_pregen_fpo_row.sum_eff_qty :=
                               l_generated_pre_batch_tab.COUNT * p_batch_size;
         update_original_fpo
                   (p_fpo_header_row                => l_fpo_header_row
                   ,p_prim_prod_row                 => l_prim_prod_row
                   ,p_pregen_fpo_row                => l_pregen_fpo_row
                   ,p_fpo_material_details_tab      => l_fpo_material_details_tab
                   ,p_enforce_vldt_check            => p_enforce_vldt_check
                   ,x_fpo_header_row                => x_batch_header
                   ,x_return_status                 => x_return_status);

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   'in private convert_fpo-after update'
                                || x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE update_original_fpo_failure;
         END IF;

         -- Bug 3185748 Use l_generated_pre_batch_tab.FIRST and l_generated_pre_batch_tab.LAST
         -- to get the batch range as all the batches might have not been created.
         l_batch_range :=
            l_generated_pre_batch_tab (l_generated_pre_batch_tab.FIRST).batch_no;

         IF l_generated_pre_batch_tab.COUNT > 1 THEN
            l_batch_range :=
                  l_batch_range
               || ' - '
               || l_generated_pre_batch_tab (l_generated_pre_batch_tab.LAST).batch_no;
         END IF;

         -- Bug 3185748 Display proper message
         IF p_num_batches = l_generated_pre_batch_tab.COUNT THEN
            gme_common_pvt.log_message ('GME_FPO_TO_BATCHES_CREATED'
                                       ,'BATCHRANGE'
                                       ,l_batch_range);
         ELSE
            gme_common_pvt.log_message ('GME_NOT_ALL_BATCHES_CREATED'
                                       ,'BATCHRANGE'
                                       ,l_batch_range);
         END IF;
      END IF;
   --END BUG#3185748 Sastry
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;
   EXCEPTION
      WHEN validation_failure THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('in validiation fail exception');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fpo_retrieval_failure THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('in retrieval fail exception');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN batch_generation_failure THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('in batch_generation fail exception');
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN insufficient_validity_rules THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_INSUF_VAL_RULE');
      WHEN create_batch_failure THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN update_original_fpo_failure OR batch_header_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_API_CONVERT_FPO', 'CONVERT_FPO_MAIN');
   END convert_fpo_main;
--****************************************************************
END gme_convert_fpo_pvt;

/
