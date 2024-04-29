--------------------------------------------------------
--  DDL for Package Body GME_RESCHEDULE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_RESCHEDULE_BATCH_PVT" AS
   /* $Header: GMEVRSBB.pls 120.9 2006/09/28 17:20:56 pxkumar ship $ */
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_RESCHEDULE_BATCH_PVT';

   /***********************************************************************************
    Procedure
      reschedule_batch
    Description
      This particular procedure is used to reschedule the batch and the associated steps.
    Parameters
      p_batch_header_rec      The batch header record.
      x_batch_header_rec      Output batch record.
      p_use_workday_cal       Whether to use workday calendar or not.
                              T - Use it
                              F - Do not use it
      p_contiguity_override   Whether to override contiguity check and reschedule
                              step anyway.
                              T - Override it
                              F - DO not override it.
      x_return_status         outcome of the API call
                              S - Success
                              E - Error
                              U - Unexpected error
   ***********************************************************************************/
   PROCEDURE reschedule_batch (
      p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_use_workday_cal       IN              VARCHAR2
     ,p_contiguity_override   IN              VARCHAR2
     ,x_batch_header_rec      OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS
      l_api_name          CONSTANT VARCHAR2 (30)        := 'RESCHEDULE_BATCH';

      /* Collections for details etc */
      TYPE l_line_type_tbl_typ IS TABLE OF gme_material_details.line_type%TYPE
         INDEX BY BINARY_INTEGER;

      l_line_type_tbl              l_line_type_tbl_typ;
      l_material_date              DATE;
      l_loop_count_get_material    NUMBER;
      l_material_detail_ids        gme_common_pvt.number_tab;
      l_material_detail_rec        gme_material_details%ROWTYPE;
      l_batch_header_rec           gme_batch_header%ROWTYPE;
      l_in_batch_header_rec        gme_batch_header%ROWTYPE;
      /* Local variables */
      l_return_status              VARCHAR2 (1);
      l_rsrc_trans_count           NUMBER                              := 0;
      max_cmplt_date               DATE;
      min_start_date               DATE;
      l_plan_date                  DATE;
      l_rel_type                   NUMBER;
      l_doc_type                   VARCHAR2 (4);
      l_prim_item_um               VARCHAR2 (3);
      l_prim_prod_qty              NUMBER;
      l_prim_prod_um               VARCHAR2 (3);
      l_no_prod_rule_found         BOOLEAN;
      l_prim_prod_found            BOOLEAN;
      l_recipe_validity_rule_rec   gmd_recipe_validity_rules%ROWTYPE;
      l_duration                   NUMBER;
      l_cal_count                  NUMBER;
      l_contig_period_tbl          gmp_calendar_api.contig_period_tbl;
      l_temp_qty                   NUMBER;
      l_item_id                    NUMBER;
      l_item_no                    VARCHAR2 (32);
      l_from_uom                   VARCHAR2 (3);
      l_to_uom                     VARCHAR2 (3);
      l_date                       DATE;
      l_start_date                 DATE;
      l_cmplt_date                 DATE;
      l_calendar_code              VARCHAR2 (10);
      l_contiguous_ind             NUMBER;

      CURSOR cur_get_status_type (v_validity_rule_id NUMBER)
      IS
         SELECT status_type
           FROM gmd_status gs, gmd_recipe_validity_rules grvr
          WHERE grvr.recipe_validity_rule_id = v_validity_rule_id
            AND status_code = grvr.validity_rule_status;

      l_status_type                gmd_status.status_type%TYPE;

      CURSOR cur_get_valid_dates (v_validity_rule_id NUMBER)
      IS
         SELECT start_date, end_date
           FROM gmd_recipe_validity_rules
          WHERE recipe_validity_rule_id = v_validity_rule_id;

      l_valid_dates_rec            cur_get_valid_dates%ROWTYPE;

      CURSOR cur_get_material (v_batch_id NUMBER)
      IS
         SELECT material_detail_id, line_type
           FROM gme_material_details
          WHERE batch_id = v_batch_id;

      CURSOR cur_get_phant (v_batch_id NUMBER)
      IS
         SELECT phantom_id, m.material_detail_id, release_type, line_type
               ,i.batchstep_id
           FROM gme_material_details m, gme_batch_step_items i
          WHERE m.batch_id = v_batch_id
            AND NVL (phantom_id, 0) > 0
            AND m.batch_id = i.batch_id(+)
            AND m.material_detail_id = i.material_detail_id(+);

      CURSOR cur_get_step_date (v_batch_id NUMBER, v_batchstep_id NUMBER)
      IS
         SELECT plan_start_date
           FROM gme_batch_steps
          WHERE batch_id = v_batch_id AND batchstep_id = v_batchstep_id;

      CURSOR cur_batch_step (
         v_batch_id          NUMBER
        ,v_plan_cmplt_date   DATE
        ,l_diff              NUMBER)
      IS
         SELECT batchstep_no, plan_cmplt_date
           FROM gme_batch_steps
          WHERE batch_id = v_batch_id
            AND (plan_cmplt_date + l_diff) > v_plan_cmplt_date;

      CURSOR recipe_validity_rule_cursor (
         p_recipe_validity_rule_id   gme_batch_header.recipe_validity_rule_id%TYPE)
      IS
         SELECT *
           FROM gmd_recipe_validity_rules
          WHERE recipe_validity_rule_id = NVL (p_recipe_validity_rule_id, -1);

      CURSOR primary_prod_from_batch_cursor(v_batch_id IN NUMBER)
      IS
         SELECT primary_item_id
           FROM wip_entities
          WHERE wip_entity_id = v_batch_id;

      CURSOR get_prim_prod (
         v_batch_id   gme_batch_header.batch_id%TYPE
        ,v_item_id    gme_material_details.inventory_item_id%TYPE)
      IS
         SELECT   plan_qty, dtl_um
             FROM gme_material_details
            WHERE batch_id = v_batch_id
              AND inventory_item_id = v_item_id
              AND line_type = 1
         ORDER BY line_no ASC;

      CURSOR cur_item_no (
         p_item_id           gme_material_details.inventory_item_id%TYPE
        ,p_organization_id   gme_material_details.organization_id%TYPE)
      IS
         SELECT segment1
           FROM mtl_system_items
          WHERE organization_id = p_organization_id
            AND inventory_item_id = p_item_id;

      CURSOR cur_is_charge_associated (v_batch_id NUMBER)
      IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS (SELECT 1
                          FROM gme_batch_step_charges
                         WHERE batch_id = v_batch_id);

      l_cur_is_charge_associated   cur_is_charge_associated%ROWTYPE;
      /* Exceptions */
      cal_dates_error              EXCEPTION;
      invalid_batch                EXCEPTION;
      null_dates                   EXCEPTION;
      error_load_trans             EXCEPTION;
      mtl_dt_chg_error             EXCEPTION;
      resched_phant_fail           EXCEPTION;
      date_is_less_than_actual     EXCEPTION;
      cmplt_less_start             EXCEPTION;
      cannot_reschedule_start      EXCEPTION;
      batch_header_fetch_error     EXCEPTION;
      trun_date_error              EXCEPTION;
      date_exceed_validity_rule    EXCEPTION;
      error_cont_period            EXCEPTION;
      error_non_contiguious        EXCEPTION;
      conversion_failure           EXCEPTION;
      invalid_validity_rule        EXCEPTION;
      clear_chg_dates_error        EXCEPTION;

      --FPBug#4585491
      l_R_count                       NUMBER := 0;
      l_M_count                       NUMBER := 0;
      l_B_count                       NUMBER := 0;
   BEGIN
      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status tosuccess initially */
      x_return_status := fnd_api.g_ret_sts_success;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Trying to reschedule to '
                             || TO_CHAR (p_batch_header_rec.plan_start_date
                                        ,'MM/DD/YYYY HH24:MI:SS')
                             || ' and '
                             || TO_CHAR (p_batch_header_rec.plan_cmplt_date
                                        ,'MM/DD/YYYY HH24:MI:SS') );
      END IF;

      /* Initialize out batch header record */
      IF     (p_batch_header_rec.plan_start_date IS NULL)
         AND (p_batch_header_rec.plan_cmplt_date IS NULL) THEN
         RAISE null_dates;
      END IF;

      IF p_batch_header_rec.plan_cmplt_date <
                                            p_batch_header_rec.plan_start_date THEN
         gme_common_pvt.log_message ('PM_PLAN_END_DATE_ERR');
         RAISE cmplt_less_start;
      END IF;

      IF NOT (gme_batch_header_dbl.fetch_row (p_batch_header_rec
                                             ,x_batch_header_rec) ) THEN
         RAISE batch_header_fetch_error;
      END IF;

      /*  Don't allow the Batch to be Rescheduled if the Batch Status is  */
      /*  Cancelled or Closed or Certified                                */
      IF (x_batch_header_rec.batch_status NOT IN (1, 2) ) THEN
         RAISE invalid_batch;
      END IF;

      l_calendar_code := gme_common_pvt.g_calendar_code;

      IF x_batch_header_rec.batch_status = 2 THEN   /* Batch is already WIP */
         IF p_batch_header_rec.plan_start_date <>
                                           x_batch_header_rec.plan_start_date THEN
            gme_common_pvt.log_message ('GME_CANT_RESCH_START');
            RAISE cannot_reschedule_start;
         END IF;

         IF p_batch_header_rec.plan_cmplt_date <
                                          x_batch_header_rec.actual_start_date THEN
            -- Updated the DATE1 as plan_cmplt_date and DATE2 as actual_start_date
            gme_common_pvt.log_message
               ('GME_INVALID_DATE_RANGE'
               ,'DATE1'
               ,fnd_date.date_to_displaydt (p_batch_header_rec.plan_cmplt_date)
               ,'DATE2'
               ,fnd_date.date_to_displaydt
                                         (x_batch_header_rec.actual_start_date) );
            RAISE date_is_less_than_actual;
         END IF;
      END IF;
      /* Check validity rule if not LCF batch */
      IF x_batch_header_rec.recipe_validity_rule_id IS NOT NULL THEN


        IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
           gme_debug.put_line (   g_pkg_name
                               || '.'
                               || l_api_name
                               || ':'
                               || 'Calling Check Validity Rule Dates');
        END IF;

        /* Check wether the dates requested for rescheduling are within the ranges of the recipe validity rule  */
        IF NOT gme_common_pvt.check_validity_rule_dates
                                    (x_batch_header_rec.recipe_validity_rule_id
                                    ,p_batch_header_rec.plan_start_date
                                    ,p_batch_header_rec.plan_cmplt_date
                                    ,x_batch_header_rec) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           RAISE date_exceed_validity_rule;
        END IF;

        IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
           gme_debug.put_line
              (   'Came back from Check Validity Rule Dates. Trying to reschedule From '
               || TO_CHAR (x_batch_header_rec.plan_start_date
                          ,'MM/DD/YYYY HH24:MI:SS')
               || ' and '
               || TO_CHAR (x_batch_header_rec.plan_cmplt_date
                          ,'MM/DD/YYYY HH24:MI:SS') );
        END IF;
      ELSE /* x_batch_header_rec.recipe_validity_rule_id IS NULL */
        IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
           gme_debug.put_line (   g_pkg_name
                               || '.'
                               || l_api_name
                               || ':'
                               || 'Do not Check Validity Rule Dates as this is LCF batch');
        END IF;
      END IF; /* IF x_batch_header_rec.recipe_validity_rule_id IS NOT NULL */

      IF (x_batch_header_rec.batch_type = 0) THEN
         l_doc_type := 'PROD';
      ELSE
         l_doc_type := 'FPO';
      END IF;

      IF (NVL (g_debug, 0) <= gme_debug.g_log_procedure) THEN
         gme_debug.put_line ('Delete all the  pending resource transactions');
      END IF;

      -- delete all the  pending resource transactions
      IF x_batch_header_rec.update_inventory_ind = 'Y' THEN
         DELETE FROM gme_resource_txns
               WHERE doc_id = x_batch_header_rec.batch_id
                 AND doc_type = l_doc_type
                 AND line_id IN (
                        SELECT batchstep_resource_id
                          FROM gme_batch_step_resources
                         WHERE batch_id = x_batch_header_rec.batch_id
                           AND batchstep_id IN (
                                  SELECT batchstep_id
                                    FROM gme_batch_steps
                                   WHERE batch_id =
                                                   x_batch_header_rec.batch_id
                                     AND step_status = 1) );
         DELETE FROM gme_resource_txns_gtmp
               WHERE doc_id = x_batch_header_rec.batch_id
                 AND doc_type = l_doc_type
                 AND line_id IN (
                        SELECT batchstep_resource_id
                          FROM gme_batch_step_resources
                         WHERE batch_id = x_batch_header_rec.batch_id
                           AND batchstep_id IN (
                                  SELECT batchstep_id
                                    FROM gme_batch_steps
                                   WHERE batch_id =
                                                   x_batch_header_rec.batch_id
                                     AND step_status = 1) );
      END IF;

      l_batch_header_rec := x_batch_header_rec;
      l_batch_header_rec.plan_start_date := p_batch_header_rec.plan_start_date;
      l_batch_header_rec.plan_cmplt_date := p_batch_header_rec.plan_cmplt_date;

      /* Whenever the batch is created with the routing, the poc_ind is set to 'Y'
         and set to 'N' when there is no routing. So the below code is replaced with
         the check so that this code works fine for the migrated batches from old gme code */
      IF l_batch_header_rec.poc_ind = 'Y' THEN
         IF (x_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending) THEN
            IF     (p_batch_header_rec.plan_start_date IS NOT NULL)
               AND (p_batch_header_rec.plan_cmplt_date IS NULL) THEN
               gme_create_step_pvt.calc_dates
                             (p_gme_batch_header_rec      => l_batch_header_rec
                             ,p_use_workday_cal           => p_use_workday_cal
                             ,p_contiguity_override       => p_contiguity_override
                             ,p_return_status             => l_return_status);

               IF l_return_status <> x_return_status THEN
                  RAISE cal_dates_error;
               END IF;
            ELSIF     (p_batch_header_rec.plan_cmplt_date IS NOT NULL)
                  AND (p_batch_header_rec.plan_start_date IS NULL) THEN
               gme_create_step_pvt.calc_dates
                             (p_gme_batch_header_rec      => l_batch_header_rec
                             ,p_use_workday_cal           => p_use_workday_cal
                             ,p_contiguity_override       => p_contiguity_override
                             ,p_return_status             => l_return_status);

               IF l_return_status <> x_return_status THEN
                  RAISE cal_dates_error;
               END IF;
            END IF; /*plan_start_date not null*/

            IF (     (p_batch_header_rec.plan_start_date IS NOT NULL)
                AND (p_batch_header_rec.plan_cmplt_date IS NOT NULL) ) THEN
               gme_create_step_pvt.calc_dates
                             (p_gme_batch_header_rec      => l_batch_header_rec
                             ,p_use_workday_cal           => p_use_workday_cal
                             ,p_contiguity_override       => p_contiguity_override
                             ,p_return_status             => l_return_status);

               IF l_return_status <> x_return_status THEN
                  RAISE cal_dates_error;
               END IF;
            END IF; /* both date not null*/
         END IF; /* batch_status = 1*/

         IF (x_batch_header_rec.batch_status = gme_common_pvt.g_batch_wip) THEN
            IF (p_batch_header_rec.plan_cmplt_date IS NOT NULL) THEN
               gme_create_step_pvt.calc_dates
                             (p_gme_batch_header_rec      => p_batch_header_rec
                             ,p_use_workday_cal           => p_use_workday_cal
                             ,p_contiguity_override       => p_contiguity_override
                             ,p_return_status             => l_return_status);

               IF l_return_status <> x_return_status THEN
                  RAISE cal_dates_error;
               END IF;
            END IF; /*plan_cmpt_date is not null*/
         END IF; /* batch_status = 2*/

         IF NOT (gme_batch_header_dbl.fetch_row (p_batch_header_rec
                                                ,x_batch_header_rec) ) THEN
            RAISE batch_header_fetch_error;
         END IF;
      ELSE /* no routing */
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('No Routing');
         END IF;
         /* GO to validity rule is not an LCF batch */
         IF l_batch_header_rec.recipe_validity_rule_id IS NOT NULL THEN
            OPEN recipe_validity_rule_cursor
                                   (l_batch_header_rec.recipe_validity_rule_id);

            FETCH recipe_validity_rule_cursor
             INTO l_recipe_validity_rule_rec;

            CLOSE recipe_validity_rule_cursor;
         ELSE /* LCF Batch */
            OPEN primary_prod_from_batch_cursor
                                   (l_batch_header_rec.batch_id);

            FETCH primary_prod_from_batch_cursor
             INTO l_recipe_validity_rule_rec.inventory_item_id;

            CLOSE primary_prod_from_batch_cursor;
         END IF; /* IF l_batch_header_rec.recipe_validity_rule_id IS NOT NULL */


         SELECT primary_uom_code
           INTO l_prim_item_um
           FROM mtl_system_items
          WHERE inventory_item_id =
                                  l_recipe_validity_rule_rec.inventory_item_id
            AND organization_id = l_batch_header_rec.organization_id;

         OPEN get_prim_prod (x_batch_header_rec.batch_id
                            ,l_recipe_validity_rule_rec.inventory_item_id);

         FETCH get_prim_prod
          INTO l_prim_prod_qty, l_prim_prod_um;

         IF get_prim_prod%FOUND THEN
            l_prim_prod_found := TRUE;
         ELSE
            l_prim_prod_found := FALSE;
         END IF;

         CLOSE get_prim_prod;
         -- Pawan changed for issues dound during UTE
         IF l_prim_prod_found THEN
            l_temp_qty :=
               inv_convert.inv_um_convert
                    (item_id            => l_recipe_validity_rule_rec.inventory_item_id
                    ,PRECISION          => 5
                    ,from_quantity      => l_prim_prod_qty
                    ,from_unit          => l_prim_prod_um
                    ,to_unit            => l_prim_item_um
                    ,from_name          => NULL
                    ,to_name            => NULL);

            IF l_temp_qty = -99999 THEN
               l_item_id := l_recipe_validity_rule_rec.inventory_item_id;
               l_from_uom := l_prim_prod_um;
               l_to_uom := l_prim_item_um;
               RAISE conversion_failure;
            END IF;

            /* Pass plan_start_date to this procedure in case of a WIP batch */
            IF x_batch_header_rec.batch_status = 2 THEN
               l_date := NULL;
            ELSE
               l_date := p_batch_header_rec.plan_start_date;
            END IF;

            IF gme_common_pvt.calc_date_from_prod_rule
                  (p_organization_id        => x_batch_header_rec.organization_id
                  ,p_inventory_item_id      => l_recipe_validity_rule_rec.inventory_item_id
                  ,p_item_qty               => l_temp_qty
                  ,p_start_date             => l_date
                  ,p_cmplt_date             => p_batch_header_rec.plan_cmplt_date
                  ,x_start_date             => x_batch_header_rec.plan_start_date
                  ,x_cmplt_date             => x_batch_header_rec.plan_cmplt_date) =
                                                                          TRUE THEN
               l_no_prod_rule_found := FALSE;

               /* IF batch is WIP then disregard calculated plan_start_date  */
               IF x_batch_header_rec.batch_status =
                                                   gme_common_pvt.g_batch_wip THEN
                  x_batch_header_rec.plan_start_date :=
                                           p_batch_header_rec.plan_start_date;
               END IF;
            ELSE
               l_no_prod_rule_found := TRUE;
            END IF;
         ELSE
            -- prim prod was not found...
            l_no_prod_rule_found := TRUE;
         END IF;                                       /* l_prim_prod_found */

         IF l_no_prod_rule_found THEN
            IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
               gme_debug.put_line ('No Rules');
            END IF;

            IF     p_batch_header_rec.plan_start_date IS NOT NULL
               AND p_batch_header_rec.plan_cmplt_date IS NULL THEN
               x_batch_header_rec.plan_cmplt_date :=
                                           p_batch_header_rec.plan_start_date;
               x_batch_header_rec.plan_start_date :=
                                           p_batch_header_rec.plan_start_date;
            ELSIF     p_batch_header_rec.plan_start_date IS NULL
                  AND p_batch_header_rec.plan_cmplt_date IS NOT NULL THEN
               x_batch_header_rec.plan_start_date :=
                                           p_batch_header_rec.plan_cmplt_date;
               x_batch_header_rec.plan_cmplt_date :=
                                           p_batch_header_rec.plan_cmplt_date;
            ELSIF     p_batch_header_rec.plan_start_date IS NULL
                  AND p_batch_header_rec.plan_cmplt_date IS NULL THEN
               x_batch_header_rec.plan_start_date :=
                                                   gme_common_pvt.g_timestamp;
               x_batch_header_rec.plan_cmplt_date :=
                                                   gme_common_pvt.g_timestamp;
            ELSIF     p_batch_header_rec.plan_start_date IS NOT NULL
                  AND p_batch_header_rec.plan_cmplt_date IS NOT NULL THEN
               x_batch_header_rec.plan_start_date :=
                                           p_batch_header_rec.plan_start_date;
               x_batch_header_rec.plan_cmplt_date :=
                                           p_batch_header_rec.plan_cmplt_date;
            END IF;                               /*plan_start_date NOT NULL*/

            IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
               gme_debug.put_line
                             (   'Production rule start_date '
                              || TO_CHAR (x_batch_header_rec.plan_start_date
                                         ,'yyyy/mon/dd hh24:mi:ss')
                              || ' Production rule end_date '
                              || TO_CHAR (x_batch_header_rec.plan_cmplt_date
                                         ,'yyyy/mon/dd hh24:mi:ss') );
            END IF;
         ELSE /*  l_no_prod_found*/
            IF p_use_workday_cal = fnd_api.g_true THEN
               gmd_recipe_fetch_pub.fetch_contiguous_ind
                  (p_recipe_id                    => NULL
                  ,p_orgn_id                      => NULL
                  ,p_recipe_validity_rule_id      => l_batch_header_rec.recipe_validity_rule_id
                  ,x_contiguous_ind               => l_contiguous_ind
                  ,x_return_status                => l_return_status);

               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (   'l_contiguous_ind found '
                                      || l_contiguous_ind);
               END IF;

               l_duration :=
                    (  x_batch_header_rec.plan_cmplt_date
                     - x_batch_header_rec.plan_start_date)
                  * 24;

               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line ('l duration ' || l_duration);
               END IF;

               IF    p_batch_header_rec.plan_start_date IS NOT NULL
                  OR (    p_batch_header_rec.plan_start_date IS NULL
                      AND p_batch_header_rec.plan_cmplt_date IS NULL) THEN
                  gmp_calendar_api.get_contiguous_periods
                     (p_api_version        => 1
                     ,p_init_msg_list      => TRUE
                     ,p_start_date         => NVL
                                                 (p_batch_header_rec.plan_start_date
                                                 ,x_batch_header_rec.plan_start_date)
                     ,p_end_date           => NULL
                     ,p_calendar_code      => l_calendar_code
                     ,p_duration           => l_duration
                     ,p_output_tbl         => l_contig_period_tbl
                     ,x_return_status      => l_return_status);

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line
                        (   'Came back from Get Contiguous Periods with status '
                         || l_return_status);
                  END IF;

                  IF (l_return_status <> x_return_status) THEN
                     RAISE error_cont_period;
                  END IF;

                  l_cal_count := l_contig_period_tbl.COUNT;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line ('l cal_count ' || l_cal_count);
                     gme_debug.put_line (   'p_contiguity_override '
                                         || p_contiguity_override);
                  END IF;

                  IF     l_contiguous_ind = 1
                     AND p_contiguity_override = fnd_api.g_false
                     AND l_cal_count > 1 THEN
                     RAISE error_non_contiguious;
                  END IF;

                  x_batch_header_rec.plan_start_date :=
                     NVL (p_batch_header_rec.plan_start_date
                         ,x_batch_header_rec.plan_start_date);
                  x_batch_header_rec.plan_cmplt_date :=
                                    l_contig_period_tbl (l_cal_count).end_date;

                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line
                               (   'x_batch_header_rec.plan_cmplt_date '
                                || TO_CHAR
                                          (x_batch_header_rec.plan_cmplt_date
                                          ,'yyyy/mon/dd hh24:mi:ss') );
                  END IF;
               ELSE       /* p_batch_header_rec.plan_start_date IS NOT NULL */
                  IF p_batch_header_rec.plan_cmplt_date IS NOT NULL THEN
                     gmp_calendar_api.get_contiguous_periods
                           (p_api_version        => 1
                           ,p_init_msg_list      => TRUE
                           ,p_start_date         => NULL
                           ,p_end_date           => p_batch_header_rec.plan_cmplt_date
                           ,p_calendar_code      => l_calendar_code
                           ,p_duration           => l_duration
                           ,p_output_tbl         => l_contig_period_tbl
                           ,x_return_status      => l_return_status);

                     IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                        gme_debug.put_line
                           (   'Plan start date is null. Came back from Get Contiguous Periods with status '
                            || l_return_status);
                     END IF;

                     IF (l_return_status <> x_return_status) THEN
                        RAISE error_cont_period;
                     END IF;

                     l_cal_count := l_contig_period_tbl.COUNT;

                     IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                        gme_debug.put_line ('l cal_count ' || l_cal_count);
                        gme_debug.put_line (   'p_contiguity_override '
                                            || p_contiguity_override);
                     END IF;

                     IF     l_contiguous_ind = 1
                        AND p_contiguity_override = fnd_api.g_false
                        AND l_cal_count > 1 THEN
                        RAISE error_non_contiguious;
                     END IF;

                     x_batch_header_rec.plan_cmplt_date :=
                                            p_batch_header_rec.plan_cmplt_date;
                     x_batch_header_rec.plan_start_date :=
                                  l_contig_period_tbl (l_cal_count).start_date;

                     IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                        gme_debug.put_line
                               (   'x_batch_header_rec.plan_start_date '
                                || TO_CHAR
                                          (x_batch_header_rec.plan_start_date
                                          ,'yyyy/mon/dd hh24:mi:ss') );
                     END IF;
                  END IF;   /*p_batch_header_rec_plan_cmplt_date is not null*/
               END IF;      /*p_batch_header_rec_plan_start_date is not null*/

               IF (    p_batch_header_rec.plan_start_date IS NOT NULL
                   AND p_batch_header_rec.plan_cmplt_date IS NOT NULL) THEN
                  x_batch_header_rec.plan_cmplt_date :=
                                           p_batch_header_rec.plan_cmplt_date;
               END IF;
            END IF; /* p_use_workday_cal = FND_API.G_TRUE */
         END IF; /*  l_no_prod_found*/

         IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
            gme_debug.put_line ('Update gme_batch_header.');
         END IF;

         UPDATE gme_batch_header
            SET plan_start_date = x_batch_header_rec.plan_start_date
               ,plan_cmplt_date = x_batch_header_rec.plan_cmplt_date
               ,due_date =
                   NVL (x_batch_header_rec.due_date
                       ,x_batch_header_rec.plan_cmplt_date)
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = x_batch_header_rec.batch_id;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
                (   ' After update gme_batch_header. Final plan_start_date '
                 || TO_CHAR (x_batch_header_rec.plan_start_date
                            ,'yyyy/mon/dd hh24:mi:ss')
                 || ' Final plan_cmplt_date '
                 || TO_CHAR (x_batch_header_rec.plan_cmplt_date
                            ,'yyyy/mon/dd hh24:mi:ss') );
      END IF;

      /* Whenever the batch is created with the routing, the poc_ind is set to 'Y'
         and set to 'N' when there is no routing. So the below code is replaced with
         the check so that this code works fine for the migrated batches from old gme code */
      IF x_batch_header_rec.poc_ind = 'Y' THEN
         SELECT MIN (plan_start_date)
           INTO min_start_date
           FROM gme_batch_steps
          WHERE batch_id = p_batch_header_rec.batch_id;
      ELSE
         min_start_date := x_batch_header_rec.plan_start_date;
      END IF;

      IF (x_batch_header_rec.batch_status = 2) THEN
         IF p_batch_header_rec.plan_start_date > min_start_date THEN
            x_batch_header_rec.plan_start_date :=
                                           p_batch_header_rec.plan_start_date;
            truncate_date (p_batch_header_rec      => x_batch_header_rec
                          ,p_date                  => 0
                          ,x_return_status         => l_return_status);

            IF l_return_status <> x_return_status THEN
               RAISE trun_date_error;
            END IF;
         END IF;                                           /* min_start_date*/
      END IF;
/* batch_status = 2*/
/* Whenever the batch is created with the routing, the poc_ind is set to 'Y'
   and set to 'N' when there is no routing. So the below code is replaced with
   the check so that this code works fine for the migrated batches from old gme code */

      IF x_batch_header_rec.poc_ind = 'Y' THEN
         SELECT MAX (plan_cmplt_date)
           INTO max_cmplt_date
           FROM gme_batch_steps
          WHERE batch_id = p_batch_header_rec.batch_id;
      ELSE
         max_cmplt_date := x_batch_header_rec.plan_cmplt_date;
      END IF;

      IF (     (x_batch_header_rec.plan_start_date IS NOT NULL)
          AND (x_batch_header_rec.plan_cmplt_date IS NOT NULL) ) THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   'max_date '
                                || TO_CHAR (max_cmplt_date
                                           ,'yyyy/mon/dd hh24:mi:ss') );
            gme_debug.put_line (   'required batch end_date '
                                || TO_CHAR
                                          (p_batch_header_rec.plan_cmplt_date
                                          ,'yyyy/mon/dd hh24:mi:ss') );
         END IF;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   'p_plan_cmplt_date '
                                || TO_CHAR
                                          (p_batch_header_rec.plan_cmplt_date
                                          ,'yyyy/mon/dd hh24:mi:ss') );
            gme_debug.put_line (   'x_plan_cmplt_date '
                                || TO_CHAR
                                          (x_batch_header_rec.plan_cmplt_date
                                          ,'yyyy/mon/dd hh24:mi:ss') );
         END IF;

         IF p_batch_header_rec.plan_cmplt_date < max_cmplt_date THEN
            x_batch_header_rec.plan_cmplt_date :=
                                           p_batch_header_rec.plan_cmplt_date;
            truncate_date (p_batch_header_rec      => x_batch_header_rec
                          ,p_date                  => 1
                          ,x_return_status         => l_return_status);

            IF l_return_status <> x_return_status THEN
               RAISE trun_date_error;
            END IF;
         ELSIF p_batch_header_rec.plan_cmplt_date >
                                            x_batch_header_rec.plan_cmplt_date THEN
            IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
               gme_debug.put_line
                  ('User supplied plan completion date is greater than what system calculated User wants to leave gaps.');
            END IF;

            UPDATE gme_batch_header
               SET plan_cmplt_date = p_batch_header_rec.plan_cmplt_date
             WHERE batch_id = x_batch_header_rec.batch_id;
         END IF;                                          /* max_cmplt_date */
      END IF;                                             /* dates not null */

      IF NOT (gme_batch_header_dbl.fetch_row (p_batch_header_rec
                                             ,x_batch_header_rec) ) THEN
         RAISE batch_header_fetch_error;
      END IF;

      -- Checking of batch dates with validity rules dates after the reschedule
      -- Pawan Kumar added code for bug 3088739
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'affinal plan_start_date '
                             || TO_CHAR (x_batch_header_rec.plan_start_date
                                        ,'yyyy/mon/dd hh24:mi:ss') );
         gme_debug.put_line (   'affinal plan_cmplt_date '
                             || TO_CHAR (x_batch_header_rec.plan_cmplt_date
                                        ,'yyyy/mon/dd hh24:mi:ss') );
      END IF;

      /* If not LCF batch then check validity rule dates */
      IF l_batch_header_rec.recipe_validity_rule_id IS NOT NULL THEN
         IF NOT gme_common_pvt.check_validity_rule_dates
                                  (l_batch_header_rec.recipe_validity_rule_id
                                  ,x_batch_header_rec.plan_start_date
                                  ,x_batch_header_rec.plan_cmplt_date
                                  ,l_batch_header_rec) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE date_exceed_validity_rule;
         END IF;
      END IF; /* IF l_batch_header_rec.recipe_validity_rule_id IS NOT NULL */

      /*  Load all the transactions and resources to the temporary table */
      /*  for the current batch if the update inventory ind is set for the batch  */
      IF x_batch_header_rec.update_inventory_ind = 'Y' THEN
         IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
            gme_debug.put_line
               ('Load all the transactions and resources to the temporary table.');
         END IF;

         gme_trans_engine_util.load_rsrc_trans
                                       (p_batch_row          => x_batch_header_rec
                                       ,x_rsc_row_count      => l_rsrc_trans_count
                                       ,x_return_status      => l_return_status);

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
               (   'Came back after loading all the transactions and resources to the temporary table with status '
                || l_return_status);
         END IF;

         IF l_return_status <> x_return_status THEN
            RAISE error_load_trans;
         END IF;
      END IF;           /* IF x_batch_header_rec.update_inventory_ind = 'Y' */

      FOR l_rec IN cur_get_phant (x_batch_header_rec.batch_id) LOOP
         l_in_batch_header_rec.batch_id := l_rec.phantom_id;

         IF l_rec.batchstep_id IS NOT NULL AND l_rec.release_type = 3 THEN
            OPEN cur_get_step_date (x_batch_header_rec.batch_id
                                   ,l_rec.batchstep_id);

            FETCH cur_get_step_date
             INTO l_plan_date;

            CLOSE cur_get_step_date;

            l_in_batch_header_rec.plan_cmplt_date := l_plan_date;
         ELSE
            l_in_batch_header_rec.plan_cmplt_date :=
                                           x_batch_header_rec.plan_start_date;
         END IF;

         IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                        (   g_pkg_name
                         || '.'
                         || l_api_name
                         || ':'
                         || 'Calling Reschedule Batch for phantom batch_id: '
                         || l_in_batch_header_rec.batch_id);
         END IF;

         gme_reschedule_batch_pvt.reschedule_batch
                              (p_batch_header_rec         => l_in_batch_header_rec
                              ,p_use_workday_cal          => p_use_workday_cal
                              ,p_contiguity_override      => p_contiguity_override
                              ,x_batch_header_rec         => l_batch_header_rec
                              ,x_return_status            => l_return_status);

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                          (   'Came back from Reschedule Batch  with status '
                           || l_return_status);
         END IF;

         IF l_return_status <> x_return_status THEN
            RAISE resched_phant_fail;
         END IF;
      END LOOP;

      /* Now we have to update the transaction dates of pending transactions */
      /* for the material lines which are not of step release type           */
      OPEN cur_get_material (x_batch_header_rec.batch_id);

      FETCH cur_get_material
      BULK COLLECT INTO l_material_detail_ids, l_line_type_tbl;

      l_loop_count_get_material := cur_get_material%ROWCOUNT;

      CLOSE cur_get_material;

      FOR i IN 1 .. l_loop_count_get_material LOOP
         l_material_detail_rec.material_detail_id :=
                                                    l_material_detail_ids (i);
         -- Stamp manual and incremental with step dates also
          -- Pawan Kumar  bug 5499499 added code for step dates.
            l_rel_type :=
             gme_common_pvt.is_material_auto_release (l_material_detail_ids (i));

         IF ( l_rel_type = 3 OR
             ( gme_common_pvt.is_material_assoc_to_step(l_material_detail_ids(i)) = TRUE
                 AND l_rel_type IN (1, 2))
            ) THEN
            SELECT plan_start_date, plan_cmplt_date
            INTO   l_start_date, l_cmplt_date
            FROM   gme_batch_steps
            WHERE  batch_id = x_batch_header_rec.batch_id
              AND  batchstep_id = (SELECT batchstep_id
                                   FROM   gme_batch_step_items
                                   WHERE  batch_id = x_batch_header_rec.batch_id
                                     AND  material_detail_id = l_material_detail_ids(i));


         ELSE                                     /* NOT ASSOCIATED TO STEP */
            l_start_date := x_batch_header_rec.plan_start_date;
            l_cmplt_date := x_batch_header_rec.plan_cmplt_date;

         END IF; /* IF l_rel_type = gme_common_pvt.g_mtl_autobystep_release */

         -- Navin Added as part of Reschedule Batch/Step Build.
         IF l_line_type_tbl (i) = gme_common_pvt.g_line_type_ing THEN
            -- Update the material_required_date with the associated plan_start_Date;
            l_material_date := l_start_date;
         ELSE
            -- Update the material required date with the associated plan cmplt Date;
            l_material_date := l_cmplt_date;
         END IF;

         IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                          (   'Calling Material Date Change for batch_id : '
                           || x_batch_header_rec.batch_id
                           || ' Material_detail_id : '
                           || l_material_detail_ids (i)
                           ||'date sent for change'
                           ||l_material_date
                           );
         END IF;

         gme_common_pvt.material_date_change
                            (p_material_detail_id      => l_material_detail_ids
                                                                           (i)
                            ,p_material_date           => l_material_date
                            ,x_return_status           => l_return_status);

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                       (   'Came back from material_date_change with status '
                        || l_return_status);
         END IF;
         --FPBug#4585491 Begin
         /*IF l_return_status <> x_return_status THEN
            RAISE mtl_dt_chg_error;
         END IF; */

	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           RAISE mtl_dt_chg_error;
         ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;

	 /*
	  The above material_date_change returns different status as described below
	  R: When reservations are deleted for a material line
	  M: When MO Allocations are deleted for a material line
	  B: When Both reservations and material lines are deleted for a material line
	 */
	 IF x_return_status = 'R' THEN
 	   l_R_count := l_R_count + 1;
	 ELSIF x_return_status = 'M' THEN
           l_M_count := l_M_count + 1;
	 ELSIF x_return_status = 'B' THEN
      	   l_B_count := l_B_count + 1;
	 END IF;
         --FPBug#4585491 End

      END LOOP;                    /* FOR i IN 1..l_loop_count_get_material */

      --FPBug#4585491 Begin
      IF (l_B_count > 0) OR (l_R_count > 0 AND l_M_count > 0) THEN
       --atleast for one material line MO allocations and reservations are deleted
       gme_common_pvt.log_message('GME_EXPIRED_RESERV_MO_DELETED');
      ELSIF l_R_count > 0 THEN
       ----atleast for one material line reservations are deleted
       gme_common_pvt.log_message('GME_EXPIRED_RESERV_DELETED');
      ELSIF l_M_count > 0 THEN
       ----atleast for one material line MO allocations are deleted
       gme_common_pvt.log_message('GME_EXPIRED_MO_DELETED');
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      --FPBug#4585491 End


      --clearing the charge dates on batch reschedule;
      OPEN cur_is_charge_associated (x_batch_header_rec.batch_id);

      FETCH cur_is_charge_associated
       INTO l_cur_is_charge_associated;

      IF cur_is_charge_associated%FOUND THEN
         CLOSE cur_is_charge_associated;

         gme_batch_step_chg_pvt.clear_charge_dates
                                  (p_batch_id           => x_batch_header_rec.batch_id
                                  ,x_return_status      => l_return_status);

         IF l_return_status <> x_return_status THEN
            RAISE clear_chg_dates_error;
         END IF;
      ELSE
         CLOSE cur_is_charge_associated;
      END IF;
      --Susruth Bug#5359091 Finite Scheduled indicator is set back to 0 once the batch is rescheduled. START
      IF x_batch_header_rec.FINITE_SCHEDULED_IND = 1 THEN
         UPDATE gme_batch_header
            SET FINITE_SCHEDULED_IND = 0
          WHERE batch_id = x_batch_header_rec.batch_id;
      x_batch_header_rec.FINITE_SCHEDULED_IND := 0;
      END IF;

      -- Bug#5359091 end
      /* Update the row who columns */
      x_batch_header_rec.last_update_date := gme_common_pvt.g_timestamp;
      x_batch_header_rec.last_updated_by := gme_common_pvt.g_user_ident;
      x_batch_header_rec.last_update_login := gme_common_pvt.g_login_id;

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
      WHEN invalid_batch THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_INV_BATCH_RESCHED');
      WHEN null_dates THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_common_pvt.log_message ('GME_API_RESCH_NO_DATES_PASSED');
      WHEN date_exceed_validity_rule THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN invalid_validity_rule THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN batch_header_fetch_error OR error_load_trans THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN resched_phant_fail OR mtl_dt_chg_error OR cal_dates_error THEN
         x_return_status := l_return_status;
      WHEN cmplt_less_start OR cannot_reschedule_start OR date_is_less_than_actual THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN error_cont_period THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Contiguity period ... _failed');
         END IF;

         x_return_status := l_return_status;
      WHEN clear_chg_dates_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN error_non_contiguious THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('Contiguity period ... not found');
         END IF;

         gme_common_pvt.log_message ('GME_NON_CONTIGUOUS_TIME');
         x_return_status := 'C';
      WHEN conversion_failure THEN
         IF l_item_no IS NULL THEN
            OPEN cur_item_no (l_item_id, p_batch_header_rec.organization_id);

            FETCH cur_item_no
             INTO l_item_no;

            CLOSE cur_item_no;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name ('GMI', 'IC_API_UOM_CONVERSION_ERROR');
         fnd_message.set_token ('ITEM_NO', l_item_no);
         fnd_message.set_token ('FROM_UOM', l_from_uom);
         fnd_message.set_token ('TO_UOM', l_to_uom);
         fnd_msg_pub.ADD;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || ' OTHERS:'
                                || SQLERRM);
         END IF;
   END reschedule_batch;

   /***********************************************************************************
    Procedure
      truncate_date
    Description
      This particular procedure is used to update the pending transactions of the material detail
      line passed in to the trans date to the plan_start or completion dates of the batch/
    Parameters

      P_batch_header     Batch Header Row.
      p_date             number possible values = 0 for start date and 1 for end date
      x_return_status    outcome of the API call
                S - Success
                E - Error
                U - Unexpected error
      Revision History
                Rishi Varma bug # 3446787.
                       Added the p_batchstep_id parameter for updating only the steps,actvities,
                       resources,resource transactions.
                       For this modified the sql query to include the condition
                       "AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id)" for
                       steps,activities,resources and resource transactions.
   ***********************************************************************************/
   PROCEDURE truncate_date (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_date               IN              NUMBER
     ,p_batchstep_id       IN              gme_batch_steps.batchstep_id%TYPE
            DEFAULT NULL
     ,x_return_status      OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'UPDATE_TRANSACTION';
      l_batch_id            NUMBER        := 0;
      l_doc_type            VARCHAR2 (4);
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Set the return status to success initially */
      x_return_status := fnd_api.g_ret_sts_success;
      l_batch_id := p_batch_header_rec.batch_id;

      IF (p_batch_header_rec.batch_type = 0) THEN
         l_doc_type := 'PROD';
      ELSE
         l_doc_type := 'FPO';
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('batch_id=' || l_batch_id);
      END IF;

      IF p_date = 0 THEN
         --update batch start date
         IF (p_batchstep_id IS NULL) THEN
            UPDATE gme_batch_header
               SET plan_start_date = p_batch_header_rec.plan_start_date
                  ,last_updated_by = gme_common_pvt.g_user_ident
                  ,last_update_date = gme_common_pvt.g_timestamp
                  ,last_update_login = gme_common_pvt.g_login_id
             WHERE batch_id = l_batch_id;

            --update batch end date
            UPDATE gme_batch_header
               SET plan_cmplt_date = p_batch_header_rec.plan_start_date
                  ,last_updated_by = gme_common_pvt.g_user_ident
                  ,last_update_date = gme_common_pvt.g_timestamp
                  ,last_update_login = gme_common_pvt.g_login_id
             WHERE batch_id = l_batch_id
               AND plan_cmplt_date < p_batch_header_rec.plan_start_date;

            --update batch due date
            UPDATE gme_batch_header
               SET due_date = p_batch_header_rec.plan_start_date
                  ,last_updated_by = gme_common_pvt.g_user_ident
                  ,last_update_date = gme_common_pvt.g_timestamp
                  ,last_update_login = gme_common_pvt.g_login_id
             WHERE batch_id = l_batch_id
               AND due_date < p_batch_header_rec.plan_start_date;
         END IF;

         -- update batch steps start date
         UPDATE gme_batch_steps
            SET plan_start_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_start_date < p_batch_header_rec.plan_start_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch steps end  date
         UPDATE gme_batch_steps
            SET plan_cmplt_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_cmplt_date < p_batch_header_rec.plan_start_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch steps due  date
         UPDATE gme_batch_steps
            SET due_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND due_date < p_batch_header_rec.plan_start_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch activity start  date
         UPDATE gme_batch_step_activities
            SET plan_start_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_start_date < p_batch_header_rec.plan_start_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch activity end date
         UPDATE gme_batch_step_activities
            SET plan_cmplt_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_cmplt_date < p_batch_header_rec.plan_start_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch resources start  date
         UPDATE gme_batch_step_resources
            SET plan_start_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_start_date < p_batch_header_rec.plan_start_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch resources end date
         UPDATE gme_batch_step_resources
            SET plan_cmplt_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_cmplt_date < p_batch_header_rec.plan_start_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch resources  txns start  date
         UPDATE gme_resource_txns
            SET start_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE doc_id = l_batch_id
            AND doc_type = l_doc_type
            AND start_date < p_batch_header_rec.plan_start_date;

         -- update batch resources  txns end date
         UPDATE gme_resource_txns
            SET end_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE doc_id = l_batch_id
            AND doc_type = l_doc_type
            AND end_date < p_batch_header_rec.plan_start_date;

         -- update batch resources  txns trans date
         UPDATE gme_resource_txns
            SET trans_date = p_batch_header_rec.plan_start_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE doc_id = l_batch_id
            AND doc_type = l_doc_type
            AND trans_date < p_batch_header_rec.plan_start_date;
      ELSE
         --update batch start date
         IF (p_batchstep_id IS NULL) THEN
            UPDATE gme_batch_header
               SET plan_cmplt_date = p_batch_header_rec.plan_cmplt_date
                  ,last_updated_by = gme_common_pvt.g_user_ident
                  ,last_update_date = gme_common_pvt.g_timestamp
                  ,last_update_login = gme_common_pvt.g_login_id
             WHERE batch_id = l_batch_id;

            --update batch end date
            UPDATE gme_batch_header
               SET plan_start_date = p_batch_header_rec.plan_cmplt_date
                  ,last_updated_by = gme_common_pvt.g_user_ident
                  ,last_update_date = gme_common_pvt.g_timestamp
                  ,last_update_login = gme_common_pvt.g_login_id
             WHERE batch_id = l_batch_id
               AND plan_start_date > p_batch_header_rec.plan_cmplt_date;

           --update batch due date
           -- Bug 4416538( front bug of 4200964)
           -- The due date which was getting updated with the planned
           -- completion date is changed to be updated with the same due date.
            UPDATE gme_batch_header
               SET due_date = p_batch_header_rec.due_date
                  ,last_updated_by = gme_common_pvt.g_user_ident
                  ,last_update_date = gme_common_pvt.g_timestamp
                  ,last_update_login = gme_common_pvt.g_login_id
             WHERE batch_id = l_batch_id
               AND due_date > p_batch_header_rec.plan_cmplt_date;
         END IF;

         -- update batch steps start date
         UPDATE gme_batch_steps
            SET plan_start_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_start_date > p_batch_header_rec.plan_cmplt_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch steps end  date
         UPDATE gme_batch_steps
            SET plan_cmplt_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_cmplt_date > p_batch_header_rec.plan_cmplt_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch steps due  date
         UPDATE gme_batch_steps
            SET due_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND due_date > p_batch_header_rec.plan_cmplt_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch activity start  date
         UPDATE gme_batch_step_activities
            SET plan_start_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_start_date > p_batch_header_rec.plan_cmplt_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch activity end date
         UPDATE gme_batch_step_activities
            SET plan_cmplt_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_cmplt_date > p_batch_header_rec.plan_cmplt_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch resources start  date
         UPDATE gme_batch_step_resources
            SET plan_start_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_start_date > p_batch_header_rec.plan_cmplt_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch resources end date
         UPDATE gme_batch_step_resources
            SET plan_cmplt_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batch_id = l_batch_id
            AND plan_cmplt_date > p_batch_header_rec.plan_cmplt_date
            AND (p_batchstep_id IS NULL OR batchstep_id = p_batchstep_id);

         -- update batch resources  txns start  date
         UPDATE gme_resource_txns
            SET start_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE doc_id = l_batch_id
            AND doc_type = l_doc_type
            AND start_date > p_batch_header_rec.plan_cmplt_date;

         -- update batch resources  txns end date
         UPDATE gme_resource_txns
            SET end_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE doc_id = l_batch_id
            AND doc_type = l_doc_type
            AND end_date > p_batch_header_rec.plan_cmplt_date;

         -- update batch resources  txns trans date
         UPDATE gme_resource_txns
            SET trans_date = p_batch_header_rec.plan_cmplt_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE doc_id = l_batch_id
            AND doc_type = l_doc_type
            AND trans_date > p_batch_header_rec.plan_cmplt_date;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || ' OTHERS:'
                                || SQLERRM);
         END IF;
   END truncate_date;
END gme_reschedule_batch_pvt;

/
