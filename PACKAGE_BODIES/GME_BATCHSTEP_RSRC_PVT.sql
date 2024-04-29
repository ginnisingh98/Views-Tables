--------------------------------------------------------
--  DDL for Package Body GME_BATCHSTEP_RSRC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCHSTEP_RSRC_PVT" AS
/*  $Header: GMEVRSRB.pls 120.3.12010000.2 2009/04/17 13:10:54 gmurator ship $
 *****************************************************************
 *                                                               *
 * Package  GME_BATCHSTEP_RSRC_PVT                               *
 *                                                               *
 * Contents INSERT RESOURCE                                      *
 *          UPDATE RESOURCE                                      *
 *          DELETE RESOURCE                                      *
 *                                                               *
 * Use      This is the private layer of the GME Batch Step      *
 *          Resources.                                           *
 *                                                               *
 * History                                                       *
 *          K.Y.Hunt                                             *
 *          Reworked for Inventory Convergence.   02-APR-2005    *
 * Pawan Kumar 	10-Oct-2005 Bug-4175041		                 *
 * Added the interdependency validation for the resource count   *
 * and resource usage in update_batchstep_resource procedure     *

   G. Muratore    15-APR-2009  Bug 8335046
      Update the last_update_date for locking issues at the step level.
      PROCEDURE: update_batchstep_rsrc
 *****************************************************************
*/
/*  Global variables   */
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_BATCHSTEP_RSRC_PVT';
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');

/*===========================================================================================
   Procedure
      validate_param
   Description
     Procedure to validate parameter combination provided to identify an activity for the
     resource APIs
   Parameters
     (p_org_code,p_batch_no,p_batchstep_no and p_activity )  to uniquely identify an activity
     x_return_status                                         reflects return status of the API
=============================================================================================*/
   PROCEDURE validate_param (
      p_org_code          IN              VARCHAR2 := NULL
     ,p_batch_no          IN              VARCHAR2 := NULL
     ,p_batchstep_no      IN              NUMBER := NULL
     ,p_activity          IN              VARCHAR2 := NULL
     ,p_resource          IN              VARCHAR2 := NULL
     ,x_organization_id   OUT NOCOPY      NUMBER
     ,x_batch_id          OUT NOCOPY      NUMBER
     ,x_batchstep_id      OUT NOCOPY      NUMBER
     ,x_activity_id       OUT NOCOPY      NUMBER
     ,x_rsrc_id           OUT NOCOPY      NUMBER
     ,x_step_status       OUT NOCOPY      NUMBER
     ,x_return_status     OUT NOCOPY      VARCHAR2)
   IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'validate_param';
      l_organization_id        NUMBER;
      l_batch_id               NUMBER;
      l_batchstep_id           NUMBER;
      l_activity_id            NUMBER;
      l_resource               VARCHAR2 (16);
      l_step_status            NUMBER;
      l_rsrc_id                NUMBER;
      l_batch_type             NUMBER;
      l_rsrc_not_found         BOOLEAN;

      CURSOR cur_get_batch_dtl (
         v_organization_code   VARCHAR2
        ,v_batch_no            VARCHAR2)
      IS
         SELECT bh.organization_id, bh.batch_id, bh.batch_type
           FROM gme_batch_header bh, mtl_parameters mp
          WHERE mp.organization_code = v_organization_code
            AND mp.organization_id = bh.organization_id
            AND bh.batch_no = v_batch_no
            AND batch_type = 0;

      CURSOR cur_get_batchstep_dtl (v_batch_id NUMBER, v_batchstep_no NUMBER)
      IS
         SELECT batchstep_id, step_status
           FROM gme_batch_steps
          WHERE batch_id = v_batch_id AND batchstep_no = v_batchstep_no;

      CURSOR cur_get_activity_id (
         v_step_id    NUMBER
        ,v_activity   VARCHAR2
        ,v_batch_id   NUMBER)
      IS
         SELECT batchstep_activity_id
           FROM gme_batch_step_activities
          WHERE batchstep_id = v_step_id
            AND batch_id = v_batch_id
            AND activity = v_activity;

      CURSOR cur_fetch_resource_dtl (v_activity_id NUMBER, v_resource VARCHAR2)
      IS
         SELECT batchstep_resource_id
           FROM gme_batch_step_resources
          WHERE batchstep_activity_id = v_activity_id
            AND resources = v_resource;

      batch_not_found          EXCEPTION;
      batchstep_not_found      EXCEPTION;
      stepactivity_not_found   EXCEPTION;
      resource_not_found       EXCEPTION;
      input_param_missing      EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' input org_code     =>'
                             || p_org_code);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' input batch_no     =>'
                             || p_batch_no);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' input batchstep_no =>'
                             || p_batchstep_no);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' input activity     =>'
                             || p_activity);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' input resource     =>'
                             || p_resource);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' **********************************');
      END IF;

      /* Initially let us assign the return status to success */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_org_code IS NULL THEN
         gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                    ,'FIELD_NAME'
                                    ,'ORGANIZATION');
         RAISE input_param_missing;
      ELSIF p_batch_no IS NULL THEN
         gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                    ,'FIELD_NAME'
                                    ,'BATCH NUMBER');
         RAISE input_param_missing;
      ELSIF p_batchstep_no IS NULL THEN
         gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                    ,'FIELD_NAME'
                                    ,'BATCH STEP NUMBER');
         RAISE input_param_missing;
      ELSIF p_activity IS NULL THEN
         gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                    ,'FIELD_NAME'
                                    ,'ACTIVITY');
         RAISE input_param_missing;
      END IF;

      -- Validate input param one by one to see if it identifies a resource/activity correctly
      OPEN cur_get_batch_dtl (p_org_code, p_batch_no);

      FETCH cur_get_batch_dtl
       INTO l_organization_id, l_batch_id, l_batch_type;

      IF cur_get_batch_dtl%NOTFOUND THEN
         CLOSE cur_get_batch_dtl;

         gme_common_pvt.log_message ('GME_BATCH_NOT_FOUND');
         RAISE batch_not_found;
      END IF;

      CLOSE cur_get_batch_dtl;

      x_organization_id := l_organization_id;
      x_batch_id := l_batch_id;

      -- use batch_id to fetch batchstep_id
      OPEN cur_get_batchstep_dtl (l_batch_id, p_batchstep_no);

      FETCH cur_get_batchstep_dtl
       INTO l_batchstep_id, l_step_status;

      IF cur_get_batchstep_dtl%NOTFOUND THEN
         CLOSE cur_get_batchstep_dtl;

         gme_common_pvt.log_message ('GME_BATCH_STEP_NOT_FOUND'
                                    ,'STEP_ID'
                                    ,p_batchstep_no);
         RAISE batchstep_not_found;
      END IF;

      CLOSE cur_get_batchstep_dtl;

      x_step_status := l_step_status;
      x_batchstep_id := l_batchstep_id;

      -- fetch activity and resource id
      -- Bug 2651359 - rework done for issue where same activity exists more than once in a
      -- step and specified rsrc exists only in second or later occurrence of the activity
      FOR step_activity IN cur_get_activity_id (l_batchstep_id
                                               ,p_activity
                                               ,l_batch_id) LOOP
         IF cur_get_activity_id%FOUND THEN
            l_activity_id := step_activity.batchstep_activity_id;
            x_activity_id := l_activity_id;

            IF p_resource IS NOT NULL THEN
               OPEN cur_fetch_resource_dtl (l_activity_id, p_resource);

               FETCH cur_fetch_resource_dtl
                INTO l_rsrc_id;

               IF cur_fetch_resource_dtl%NOTFOUND THEN
                  CLOSE cur_fetch_resource_dtl;

                  l_rsrc_not_found := TRUE;
               ELSE
                  CLOSE cur_fetch_resource_dtl;

                  l_rsrc_not_found := FALSE;
                  x_rsrc_id := l_rsrc_id;
                  EXIT;
               END IF;
            END IF;
         ELSE
            gme_common_pvt.log_message ('GME_STEP_ACTIVITY_NOT_FOUND'
                                       ,'ACTIVITY'
                                       ,p_activity
                                       ,'STEP_NO'
                                       ,p_batchstep_no);
            RAISE stepactivity_not_found;
         END IF;
      END LOOP;

      -- If resource was not found in any activity then report error
      IF l_rsrc_not_found THEN
         gme_common_pvt.log_message ('GME_RSRC_NOT_FOUND'
                                    ,'RESOURCE'
                                    ,p_resource
                                    ,'ACTIVITY'
                                    ,p_activity);
         RAISE resource_not_found;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' output organization =>'
                             || x_organization_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' output batch_id     =>'
                             || x_batch_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' output batchstep_id =>'
                             || x_batchstep_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' output activity_id  =>'
                             || x_activity_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' output rsrc_id      =>'
                             || x_rsrc_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' output step_status  =>'
                             || x_step_status);
         gme_debug.put_line (   ' Completed private layer '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN batch_not_found OR batchstep_not_found OR input_param_missing THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN stepactivity_not_found OR resource_not_found THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END validate_param;

/*===========================================================================================
   Procedure
      validate_rsrc_param
   Description
      Procedure is used to validate all parameters passed to rsrc APIs
   Parameters

     x_return_status              reflects return status of the API
=============================================================================================*/
   PROCEDURE validate_rsrc_param (
      p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_activity_id              IN              NUMBER
     ,p_ignore_qty_below_cap     IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,p_validate_flexfield       IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,p_action                   IN              VARCHAR2
     ,x_batchstep_resource_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_step_status              OUT NOCOPY      NUMBER
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name            CONSTANT VARCHAR2 (30)   := 'validate_rsrc_param';
      l_step_status                  NUMBER;
      l_activity_id                  NUMBER;
      l_batch_id                     NUMBER;
      l_count_int                    NUMBER (10);
      l_batch_asqc                   NUMBER;
      l_activity_factor              NUMBER;
      l_dummy                        NUMBER;
      l_return_status                VARCHAR2 (2);
      l_field_updated                BOOLEAN                         := FALSE;
      l_act_plan_start_date          DATE;
      l_act_plan_cmplt_date          DATE;
      l_act_actual_start_date        DATE;
      l_act_actual_cmplt_date        DATE;
      l_step_qty_um                  VARCHAR2 (4);
      l_batchstep_resource_rec       gme_batch_step_resources%ROWTYPE;
      l_batchstep_resource_rec_out   gme_batch_step_resources%ROWTYPE;

      CURSOR cur_get_step_dtl_from_act (v_act_id NUMBER)
      IS
         SELECT a.step_status, a.batch_id, a.step_qty_um
           FROM gme_batch_steps a, gme_batch_step_activities b
          WHERE b.batchstep_activity_id = v_act_id
            AND a.batch_id = b.batch_id
            AND a.batchstep_id = b.batchstep_id;

      CURSOR cur_get_activity_dtl (v_status NUMBER, v_activity_id NUMBER)
      IS
         SELECT DECODE (v_status
                       ,1, plan_activity_factor
                       ,actual_activity_factor)
               ,plan_start_date, plan_cmplt_date, actual_start_date
               ,actual_cmplt_date
           FROM gme_batch_step_activities
          WHERE batchstep_activity_id = v_activity_id;

      CURSOR cur_get_activity_detail (v_activity_id NUMBER)
      IS
         SELECT plan_start_date, plan_cmplt_date
           FROM gme_batch_step_activities
          WHERE batchstep_activity_id = v_activity_id;

      CURSOR cur_get_batch_asqc (v_batch_id NUMBER)
      IS
         SELECT automatic_step_calculation
           FROM gme_batch_header
          WHERE batch_id = v_batch_id;

      CURSOR cur_get_cost_cmpnt (v_cost_cmpntcls_id NUMBER)
      IS
         SELECT 1
           FROM cm_cmpt_mst
          WHERE cost_cmpntcls_id = v_cost_cmpntcls_id;

      CURSOR cur_get_analysis_code (v_cost_analysis_code VARCHAR2)
      IS
         SELECT 1
           FROM cm_alys_mst
          WHERE cost_analysis_code = v_cost_analysis_code;

      invalid_step_status            EXCEPTION;
      invalid_activity_factor        EXCEPTION;
      invalid_asqc                   EXCEPTION;
      invalid_action                 EXCEPTION;
      cost_cmpnt_not_found           EXCEPTION;
      analysis_code_not_found        EXCEPTION;
      invalid_prim_rsrc_ind          EXCEPTION;
      input_param_missing            EXCEPTION;
      invalid_date                   EXCEPTION;
      date_outside_range             EXCEPTION;
      invalid_scale_type             EXCEPTION;
      process_qty_error              EXCEPTION;
      error_condition                EXCEPTION;
      flex_validation_error          EXCEPTION;
      flex_consolidation_error       EXCEPTION;
      rsrc_fetch_error               EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' action is '
                             || p_action);
      END IF;

      /* Initially let us assign the return status to success */
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_action = 'INSERT' THEN
         /* Validations for Insert processing */
         --check analysis code
         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' validate cost analysis code '
                                || p_batchstep_resource_rec.cost_analysis_code);
         END IF;

         IF p_batchstep_resource_rec.cost_analysis_code IS NULL THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'COST_ANALYSIS_CODE');
            RAISE input_param_missing;
         ELSE
            OPEN cur_get_analysis_code
                                 (p_batchstep_resource_rec.cost_analysis_code);

            FETCH cur_get_analysis_code
             INTO l_dummy;

            IF cur_get_analysis_code%NOTFOUND THEN
               CLOSE cur_get_analysis_code;

               fnd_message.set_name ('GMD', 'GMD_INVALID_COST_ANLYS_CODE');
               fnd_msg_pub.ADD;
               RAISE analysis_code_not_found;
            END IF;

            CLOSE cur_get_analysis_code;
         END IF;

         --check cost cmpnt id
         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' validate cost component class'
                                || p_batchstep_resource_rec.cost_cmpntcls_id);
         END IF;

         IF p_batchstep_resource_rec.cost_cmpntcls_id IS NULL THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'COST_COMPONENT_CLASS_ID');
            RAISE input_param_missing;
         ELSE
            OPEN cur_get_cost_cmpnt
                                   (p_batchstep_resource_rec.cost_cmpntcls_id);

            FETCH cur_get_cost_cmpnt
             INTO l_dummy;

            IF cur_get_cost_cmpnt%NOTFOUND THEN
               fnd_message.set_name ('GMD', 'GMD_INVALID_COST_CMPNTCLS_ID');
               fnd_msg_pub.ADD;

               CLOSE cur_get_cost_cmpnt;

               RAISE cost_cmpnt_not_found;
            END IF;

            CLOSE cur_get_cost_cmpnt;
         END IF;

         -- check scale_type
         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' validate scale type '
                                || p_batchstep_resource_rec.scale_type);
         END IF;

         IF p_batchstep_resource_rec.scale_type IS NULL THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'SCALE_TYPE');
            RAISE input_param_missing;
         ELSIF (NOT (lookup_code_valid ('GMD_RESOURCE_SCALE_TYPE'
                                       ,p_batchstep_resource_rec.scale_type) ) ) THEN
            gme_common_pvt.log_message ('GME_INVALID_SCALE_TYPE');
            RAISE invalid_scale_type;
         END IF;

         -- prim rsrc ind
         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' validate primary_resource '
                                || p_batchstep_resource_rec.prim_rsrc_ind);
         END IF;

         IF p_batchstep_resource_rec.prim_rsrc_ind IS NULL THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'Primary_Resource Indicator');
            RAISE input_param_missing;
         ELSIF (NOT (lookup_code_valid ('GMD_PRIM_RSRC_IND'
                                       ,p_batchstep_resource_rec.prim_rsrc_ind) ) ) THEN
            gme_common_pvt.log_message ('GME_INV_PRM_RSRC_IND');
            RAISE invalid_prim_rsrc_ind;
         END IF;

         l_batchstep_resource_rec := p_batchstep_resource_rec;
         -- FETCH step_id
         l_activity_id := p_activity_id;

         OPEN cur_get_step_dtl_from_act (p_activity_id);

         FETCH cur_get_step_dtl_from_act
          INTO l_step_status, l_batch_id, l_step_qty_um;

         CLOSE cur_get_step_dtl_from_act;

         l_batchstep_resource_rec.batch_id := l_batch_id;
         l_batchstep_resource_rec.batchstep_activity_id := l_activity_id;
         l_batchstep_resource_rec.resource_qty_um := l_step_qty_um;

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' validate step_status for activity_id '
                                || p_activity_id
                                || ' status is '
                                || l_step_status);
         END IF;

         IF l_step_status IN (4, 5) THEN
            gme_common_pvt.log_message ('PC_STEP_STATUS_ERR');
            RAISE invalid_step_status;
         END IF;

         -- check ASQC property
         OPEN cur_get_batch_asqc (l_batch_id);

         FETCH cur_get_batch_asqc
          INTO l_batch_asqc;

         CLOSE cur_get_batch_asqc;

         IF l_batch_asqc = 1 AND l_step_status = 2 THEN
            gme_common_pvt.log_message ('GME_INVALID_ASQC_ACTION');
            RAISE invalid_asqc;
         END IF;

         x_step_status := l_step_status;

         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' get activity detail for step_status '
                                || l_step_status
                                || ' with activity '
                                || l_activity_id);
         END IF;

         OPEN cur_get_activity_dtl (l_step_status, l_activity_id);

         FETCH cur_get_activity_dtl
          INTO l_activity_factor, l_act_plan_start_date
              ,l_act_plan_cmplt_date, l_act_actual_start_date
              ,l_act_actual_cmplt_date;

         CLOSE cur_get_activity_dtl;

         -- check activity factor
         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' validate activity factor of '
                                || l_activity_factor);
         END IF;

         IF l_activity_factor <= 0 THEN
            gme_common_pvt.log_message ('GME_INVALID_ACTIVITY_FACTOR');
            RAISE invalid_activity_factor;
         END IF;

         -- check for count and usage values
         -- Pawan Kumar added for integer value of the count only and changed to l_rec
         -- variable in rest of procedure
         -- trunc the plan_rsrc_count and actual_rsrc_count
         IF p_batchstep_resource_rec.plan_rsrc_count IS NOT NULL THEN
            l_batchstep_resource_rec.plan_rsrc_count :=
                             TRUNC (p_batchstep_resource_rec.plan_rsrc_count);

            IF g_debug <= gme_debug.g_log_procedure THEN
               gme_debug.put_line
                            (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' integer value needed for  plan_rsrc_count '
                             || p_batchstep_resource_rec.plan_rsrc_count);
            END IF;

            IF p_batchstep_resource_rec.plan_rsrc_count <>
                                      l_batchstep_resource_rec.plan_rsrc_count THEN
               gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                          ,'FIELD'
                                          ,'plan_rsrc_count');
               RAISE error_condition;
            END IF;
         END IF;

         IF p_batchstep_resource_rec.actual_rsrc_count IS NOT NULL THEN
            l_batchstep_resource_rec.actual_rsrc_count :=
                           TRUNC (p_batchstep_resource_rec.actual_rsrc_count);

            IF g_debug <= gme_debug.g_log_procedure THEN
               gme_debug.put_line
                           (   g_pkg_name
                            || '.'
                            || l_api_name
                            || ' integer value needed for actual_rsrc_count '
                            || p_batchstep_resource_rec.actual_rsrc_count);
            END IF;

            IF p_batchstep_resource_rec.actual_rsrc_count <>
                                    l_batchstep_resource_rec.actual_rsrc_count THEN
               gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                          ,'FIELD'
                                          ,'actual_rsrc_count');
               RAISE error_condition;
            END IF;
         END IF;

         l_count_int :=
            NVL (l_batchstep_resource_rec.plan_rsrc_count
                ,l_batchstep_resource_rec.actual_rsrc_count);

         IF    (l_batchstep_resource_rec.plan_rsrc_count) <= 0
            OR ( (  NVL (l_batchstep_resource_rec.plan_rsrc_count, 0)
                  - NVL (l_count_int, 0) ) > 0)
            OR ( (  NVL (l_batchstep_resource_rec.actual_rsrc_count, 0)
                  - NVL (l_count_int, 0) ) > 0)
            OR (l_batchstep_resource_rec.actual_rsrc_count) <= 0
            OR p_batchstep_resource_rec.plan_rsrc_qty < 0
            OR p_batchstep_resource_rec.actual_rsrc_qty < 0
            OR p_batchstep_resource_rec.plan_rsrc_usage < 0
            OR p_batchstep_resource_rec.actual_rsrc_usage < 0 THEN
            fnd_message.set_name ('GMI', 'IC_INV_QTY');
            fnd_msg_pub.ADD;
            RAISE error_condition;
         END IF;

         IF l_step_status = 1 THEN
            IF l_batchstep_resource_rec.plan_rsrc_count IS NULL THEN
               gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                          ,'FIELD_NAME'
                                          ,'plan_rsrc_count');
               RAISE input_param_missing;
            END IF;

            IF p_batchstep_resource_rec.plan_rsrc_usage IS NULL THEN
               gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                          ,'FIELD_NAME'
                                          ,'plan_rsrc_usage');
               RAISE input_param_missing;
            END IF;

            IF (l_batch_asqc = 0) THEN
               IF p_batchstep_resource_rec.plan_rsrc_qty IS NULL THEN
                  gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                             ,'FIELD_NAME'
                                             ,'plan_rsrc_qty');
                  RAISE input_param_missing;
               END IF;
            ELSE
               IF p_batchstep_resource_rec.plan_rsrc_qty IS NOT NULL THEN
                  gme_common_pvt.log_message ('GME_INPUT_PARAM_IGNORED'
                                             ,'FIELD'
                                             ,'plan_rsrc_qty');
               END IF;
            END IF;
         ELSIF l_step_status IN (2, 3) THEN
            IF l_batchstep_resource_rec.actual_rsrc_count IS NULL THEN
               gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                          ,'FIELD_NAME'
                                          ,'actual_rsrc_count');
               RAISE input_param_missing;
            END IF;

            IF p_batchstep_resource_rec.actual_rsrc_usage IS NULL THEN
               gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                          ,'FIELD_NAME'
                                          ,'actual_rsrc_usage');
               RAISE input_param_missing;
            END IF;

            IF (l_batch_asqc = 0) THEN
               IF (p_batchstep_resource_rec.actual_rsrc_qty IS NULL) THEN
                  gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                             ,'FIELD_NAME'
                                             ,'actual_rsrc_qty');
                  RAISE input_param_missing;
               END IF;
            ELSE
               IF p_batchstep_resource_rec.actual_rsrc_qty IS NOT NULL THEN
                  gme_common_pvt.log_message ('GME_INPUT_PARAM_IGNORED'
                                             ,'FIELD'
                                             ,'actual_rsrc_qty');
               END IF;
            END IF;
         END IF;

         -- moved date validation out of above if condn as planned dates are defaulted when
         -- we insert rsrc in WIP step. which is not true for count and usage and other flds
         IF g_debug <= gme_debug.g_log_procedure THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' start date validations  ');
         END IF;

         IF l_step_status IN (1, 2, 3) THEN
            IF     p_batchstep_resource_rec.plan_start_date IS NOT NULL
               AND p_batchstep_resource_rec.plan_cmplt_date IS NOT NULL
               AND l_step_status = 1 THEN
               IF p_batchstep_resource_rec.plan_start_date >
                                     p_batchstep_resource_rec.plan_cmplt_date THEN
                  gme_common_pvt.log_message ('PM_BADSTARTDATE');
                  RAISE invalid_date;
               END IF;

               IF NOT (date_within_activity_dates
                                     (l_activity_id
                                     ,1
                                     ,p_batchstep_resource_rec.plan_start_date) ) THEN
                  gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                  RAISE date_outside_range;
               END IF;

               l_batchstep_resource_rec.plan_start_date :=
                                      p_batchstep_resource_rec.plan_start_date;

               IF NOT (date_within_activity_dates
                                     (l_activity_id
                                     ,1
                                     ,p_batchstep_resource_rec.plan_cmplt_date) ) THEN
                  gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                  RAISE date_outside_range;
               END IF;

               l_batchstep_resource_rec.plan_cmplt_date :=
                                      p_batchstep_resource_rec.plan_cmplt_date;
            ELSE
               IF (   p_batchstep_resource_rec.plan_start_date IS NULL
                   OR l_step_status = 3) THEN
                  l_batchstep_resource_rec.plan_start_date :=
                                                        l_act_plan_start_date;
               ELSE
                  IF NOT (date_within_activity_dates
                                     (l_activity_id
                                     ,1
                                     ,p_batchstep_resource_rec.plan_start_date) ) THEN
                     gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                     RAISE date_outside_range;
                  END IF;

                  l_batchstep_resource_rec.plan_start_date :=
                                      p_batchstep_resource_rec.plan_start_date;
               END IF;

               IF (   p_batchstep_resource_rec.plan_cmplt_date IS NULL
                   OR l_step_status = 3) THEN
                  l_batchstep_resource_rec.plan_cmplt_date :=
                                                        l_act_plan_cmplt_date;
               ELSE
                  IF NOT (date_within_activity_dates
                                     (l_activity_id
                                     ,1
                                     ,p_batchstep_resource_rec.plan_cmplt_date) ) THEN
                     gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                     RAISE date_outside_range;
                  END IF;

                  l_batchstep_resource_rec.plan_cmplt_date :=
                                      p_batchstep_resource_rec.plan_cmplt_date;
               END IF;
            END IF;

            IF l_step_status IN (2, 3) THEN
               IF     p_batchstep_resource_rec.actual_start_date IS NOT NULL
                  AND p_batchstep_resource_rec.actual_cmplt_date IS NOT NULL
                  AND l_step_status = 3 THEN
                  IF p_batchstep_resource_rec.actual_start_date >
                                   p_batchstep_resource_rec.actual_cmplt_date THEN
                     gme_common_pvt.log_message ('PM_BADSTARTDATE');
                     RAISE invalid_date;
                  END IF;

                  IF NOT (date_within_activity_dates
                                   (l_activity_id
                                   ,3
                                   ,p_batchstep_resource_rec.actual_start_date) ) THEN
                     gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                     RAISE date_outside_range;
                  END IF;

                  l_batchstep_resource_rec.actual_start_date :=
                                    p_batchstep_resource_rec.actual_start_date;

                  IF NOT (date_within_activity_dates
                                   (l_activity_id
                                   ,3
                                   ,p_batchstep_resource_rec.actual_cmplt_date) ) THEN
                     gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                     RAISE date_outside_range;
                  END IF;

                  l_batchstep_resource_rec.actual_cmplt_date :=
                                    p_batchstep_resource_rec.actual_cmplt_date;
               ELSE
                  IF p_batchstep_resource_rec.actual_start_date IS NULL THEN
                     l_batchstep_resource_rec.actual_start_date :=
                                                      l_act_actual_start_date;
                  ELSE
                     IF p_batchstep_resource_rec.actual_start_date >
                                                   gme_common_pvt.g_timestamp THEN
                        fnd_message.set_name ('GMA', 'SY_NOFUTUREDATE');
                        fnd_msg_pub.ADD;
                        RAISE date_outside_range;
                     END IF;

                     IF NOT (date_within_activity_dates
                                   (l_activity_id
                                   ,3
                                   ,p_batchstep_resource_rec.actual_start_date) ) THEN
                        gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                        RAISE date_outside_range;
                     END IF;

                     l_batchstep_resource_rec.actual_start_date :=
                                    p_batchstep_resource_rec.actual_start_date;
                  END IF;

                  IF (    l_step_status = 3
                      AND p_batchstep_resource_rec.actual_cmplt_date IS NULL) THEN
                     l_batchstep_resource_rec.actual_cmplt_date :=
                                                      l_act_actual_cmplt_date;
                  ELSIF     l_step_status = 3
                        AND p_batchstep_resource_rec.actual_cmplt_date IS NOT NULL THEN
                     IF p_batchstep_resource_rec.actual_start_date >
                                                   gme_common_pvt.g_timestamp THEN
                        fnd_message.set_name ('GMA', 'SY_NOFUTUREDATE');
                        fnd_msg_pub.ADD;
                        RAISE date_outside_range;
                     END IF;

                     IF NOT (date_within_activity_dates
                                   (l_activity_id
                                   ,3
                                   ,p_batchstep_resource_rec.actual_cmplt_date) ) THEN
                        gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                        RAISE date_outside_range;
                     END IF;

                     l_batchstep_resource_rec.actual_cmplt_date :=
                                    p_batchstep_resource_rec.actual_cmplt_date;
                  END IF;
               END IF;
            END IF;
         END IF;

         /* Additional Validations for action INSERT */
         IF l_batchstep_resource_rec.offset_interval IS NULL THEN
            l_batchstep_resource_rec.offset_interval := 0;
         END IF;

         -- null out values of actual fields for pending step
         IF l_step_status = 1 THEN
            l_batchstep_resource_rec.actual_rsrc_count := NULL;
            l_batchstep_resource_rec.actual_rsrc_usage := NULL;
            l_batchstep_resource_rec.actual_rsrc_qty := NULL;
            l_batchstep_resource_rec.actual_start_date := NULL;
            l_batchstep_resource_rec.actual_cmplt_date := NULL;
         ELSIF l_step_status IN (2, 3) THEN
            l_batchstep_resource_rec.plan_rsrc_count := NULL;
            l_batchstep_resource_rec.plan_rsrc_usage := NULL;
            l_batchstep_resource_rec.plan_rsrc_qty := NULL;
         END IF;

         IF gme_common_pvt.is_qty_below_capacity
                       (p_batch_step_resources_rec      => l_batchstep_resource_rec) THEN
            gme_common_pvt.log_message ('GME_RESOURCE_PROCESS_QUANTITY'
                                       ,'RESOURCE'
                                       ,l_batchstep_resource_rec.resources);

            IF p_ignore_qty_below_cap = fnd_api.g_false THEN
               RAISE process_qty_error;
            END IF;
         END IF;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('bef ins' || l_batchstep_resource_rec.batch_id);
         END IF;
      ELSIF p_action = 'UPDATE' THEN
/* ============================ */
 --NULL;
   -- check for count and usage values
         l_count_int :=
            NVL (p_batchstep_resource_rec.plan_rsrc_count
                ,p_batchstep_resource_rec.actual_rsrc_count);

         IF    p_batchstep_resource_rec.plan_rsrc_count <= 0
            OR ( (  NVL (p_batchstep_resource_rec.plan_rsrc_count, 0)
                  - NVL (l_count_int, 0) ) > 0)
            OR p_batchstep_resource_rec.actual_rsrc_count <= 0
            OR ( (  NVL (p_batchstep_resource_rec.actual_rsrc_count, 0)
                  - NVL (l_count_int, 0) ) > 0)
            OR p_batchstep_resource_rec.plan_rsrc_qty < 0
            OR p_batchstep_resource_rec.actual_rsrc_qty < 0
            OR p_batchstep_resource_rec.plan_rsrc_usage < 0
            OR p_batchstep_resource_rec.actual_rsrc_usage < 0 THEN
            fnd_message.set_name ('GMI', 'IC_INV_QTY');
            fnd_msg_pub.ADD;
            RAISE error_condition;
         END IF;

         IF l_step_status IN (4, 5) THEN
            gme_common_pvt.log_message ('PC_STEP_STATUS_ERR');
            RAISE invalid_step_status;
         END IF;

         IF NOT (gme_batch_step_resources_dbl.fetch_row
                                                    (p_batchstep_resource_rec
                                                    ,l_batchstep_resource_rec) ) THEN
            RAISE rsrc_fetch_error;
         END IF;

         OPEN cur_get_batch_asqc (p_batchstep_resource_rec.batch_id);

         FETCH cur_get_batch_asqc
          INTO l_batch_asqc;

         CLOSE cur_get_batch_asqc;

         /* Bug 3620264 - compare analysis code to G_MISS_CHAR instead of G_MISS_NUM */
         IF p_batchstep_resource_rec.cost_analysis_code = fnd_api.g_miss_char THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'COST_ANALYSIS_CODE');
            RAISE input_param_missing;
         ELSIF (    p_batchstep_resource_rec.cost_analysis_code IS NOT NULL
                AND (l_batchstep_resource_rec.cost_analysis_code <>
                                   p_batchstep_resource_rec.cost_analysis_code) ) THEN
            OPEN cur_get_analysis_code
                                 (p_batchstep_resource_rec.cost_analysis_code);

            FETCH cur_get_analysis_code
             INTO l_dummy;

            IF cur_get_analysis_code%NOTFOUND THEN
               CLOSE cur_get_analysis_code;

               fnd_message.set_name ('GMD', 'GMD_INVALID_COST_ANLYS_CODE');
               fnd_msg_pub.ADD;
               RAISE analysis_code_not_found;
            END IF;

            CLOSE cur_get_analysis_code;

            l_field_updated := TRUE;
            l_batchstep_resource_rec.cost_analysis_code :=
                                   p_batchstep_resource_rec.cost_analysis_code;
         END IF;

         IF p_batchstep_resource_rec.cost_cmpntcls_id = fnd_api.g_miss_num THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'COST_COMPONENT_CLASS_ID');
            RAISE input_param_missing;
         ELSIF (    p_batchstep_resource_rec.cost_cmpntcls_id IS NOT NULL
                AND (l_batchstep_resource_rec.cost_cmpntcls_id <>
                                     p_batchstep_resource_rec.cost_cmpntcls_id) ) THEN
            OPEN cur_get_cost_cmpnt
                                   (p_batchstep_resource_rec.cost_cmpntcls_id);

            FETCH cur_get_cost_cmpnt
             INTO l_dummy;

            IF cur_get_cost_cmpnt%NOTFOUND THEN
               fnd_message.set_name ('GMD', 'GMD_INVALID_COST_CMPNTCLS_ID');
               fnd_msg_pub.ADD;

               CLOSE cur_get_cost_cmpnt;

               RAISE cost_cmpnt_not_found;
            END IF;

            CLOSE cur_get_cost_cmpnt;

            l_field_updated := TRUE;
            l_batchstep_resource_rec.cost_cmpntcls_id :=
                                     p_batchstep_resource_rec.cost_cmpntcls_id;
         END IF;

         IF p_batchstep_resource_rec.scale_type = fnd_api.g_miss_num THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'scale_type');
            RAISE input_param_missing;
         ELSIF (    p_batchstep_resource_rec.scale_type IS NOT NULL
                AND (l_batchstep_resource_rec.scale_type <>
                                           p_batchstep_resource_rec.scale_type) ) THEN
            IF (NOT (lookup_code_valid ('GMD_RESOURCE_SCALE_TYPE'
                                       ,p_batchstep_resource_rec.scale_type) ) ) THEN
               gme_common_pvt.log_message ('GME_INVALID_SCALE_TYPE');
               RAISE invalid_scale_type;
            END IF;

            l_field_updated := TRUE;
            l_batchstep_resource_rec.scale_type :=
                                           p_batchstep_resource_rec.scale_type;
         END IF;

         IF p_batchstep_resource_rec.prim_rsrc_ind = fnd_api.g_miss_num THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'prim_rsrc_ind');
            RAISE input_param_missing;
         ELSIF (    p_batchstep_resource_rec.prim_rsrc_ind IS NOT NULL
                AND (l_batchstep_resource_rec.prim_rsrc_ind <>
                                        p_batchstep_resource_rec.prim_rsrc_ind) ) THEN
            IF (NOT (lookup_code_valid ('GMD_PRIM_RSRC_IND'
                                       ,p_batchstep_resource_rec.prim_rsrc_ind) ) ) THEN
               gme_common_pvt.log_message ('GME_INV_PRM_RSRC_IND');
               RAISE invalid_prim_rsrc_ind;
            END IF;

            l_field_updated := TRUE;
            l_batchstep_resource_rec.prim_rsrc_ind :=
                                        p_batchstep_resource_rec.prim_rsrc_ind;
         END IF;

         --Pawan Kumar added trunc to give only integer value to count
         IF     p_batchstep_resource_rec.plan_rsrc_count = fnd_api.g_miss_num
            AND l_step_status = 1 THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'plan_rsrc_cout');
            RAISE input_param_missing;
         ELSIF p_batchstep_resource_rec.plan_rsrc_count IS NOT NULL THEN
            IF p_batchstep_resource_rec.plan_rsrc_count <>
                             TRUNC (p_batchstep_resource_rec.plan_rsrc_count) THEN
               gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                          ,'FIELD'
                                          ,'plan_rsrc_count');
               RAISE error_condition;
            END IF;

            IF l_step_status = 3 THEN
               gme_common_pvt.log_message ('GME_INV_ACT_STEP_STATUS'
                                          ,'FIELD'
                                          ,'plan_rsrc_count');
               RAISE invalid_action;
            ELSIF l_step_status = 2 THEN
               gme_common_pvt.log_message ('GME_UPD_NT_ALLOWED'
                                          ,'FIELD'
                                          ,'plan_rsrc_count');
               RAISE invalid_action;
            ELSIF (TRUNC (p_batchstep_resource_rec.plan_rsrc_count) <>
                                      l_batchstep_resource_rec.plan_rsrc_count) THEN
               l_field_updated := TRUE;
               l_batchstep_resource_rec.plan_rsrc_count :=
                             TRUNC (p_batchstep_resource_rec.plan_rsrc_count);
            END IF;
         END IF;

         IF     p_batchstep_resource_rec.actual_rsrc_count =
                                                            fnd_api.g_miss_num
            AND l_step_status = 3 THEN
            l_batchstep_resource_rec.actual_rsrc_count :=
                                     l_batchstep_resource_rec.plan_rsrc_count;
         ELSIF p_batchstep_resource_rec.actual_rsrc_count IS NOT NULL THEN
            IF p_batchstep_resource_rec.actual_rsrc_count <>
                           TRUNC (p_batchstep_resource_rec.actual_rsrc_count) THEN
               gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                          ,'FIELD'
                                          ,'actual_rsrc_count');
               RAISE error_condition;
            END IF;

            IF l_step_status = 1 THEN
               gme_common_pvt.log_message ('GME_INV_ACT_STEP_STATUS'
                                          ,'FIELD'
                                          ,'actual_rsrc_count');
               RAISE invalid_action;
            --ELSIF (trunc(p_batchstep_resource_rec.actual_rsrc_count) <> l_batchstep_resource_rec.actual_rsrc_count) THEN
            --Rishi Varma B3865212 30/09/2004
            ELSIF (TRUNC (p_batchstep_resource_rec.actual_rsrc_count) <>
                           NVL (l_batchstep_resource_rec.actual_rsrc_count, 0) ) THEN
               l_field_updated := TRUE;
               l_batchstep_resource_rec.actual_rsrc_count :=
                           TRUNC (p_batchstep_resource_rec.actual_rsrc_count);
            END IF;
         --Pawan added for bug 4175041
         /* When the actual resource count is null in the database and we are trying to update actual resource usage without the
         actual resource count, then user will be given error message that actual resource count is required.*/
         ELSE
           IF (l_batchstep_resource_rec.actual_rsrc_count IS NULL AND p_batchstep_resource_rec.actual_rsrc_usage IS NOT NULL) THEN
             gme_common_pvt.log_message('GME_FIELD_VALUE_REQUIRED','FIELD_NAME', 'actual_rsrc_count');
             RAISE input_param_missing;
           END IF;
         END IF;

         IF     p_batchstep_resource_rec.plan_rsrc_usage = fnd_api.g_miss_num
            AND l_step_status = 1 THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'plan_rsrc_usage');
            RAISE input_param_missing;
         ELSIF p_batchstep_resource_rec.plan_rsrc_usage IS NOT NULL THEN
            IF l_step_status = 3 THEN
               gme_common_pvt.log_message ('GME_INV_ACT_STEP_STATUS'
                                          ,'FIELD'
                                          ,'plan_rsrc_usage');
               RAISE invalid_action;
            ELSIF (l_step_status = 2 OR l_batch_asqc = 1) THEN
               gme_common_pvt.log_message ('GME_UPD_NT_ALLOWED'
                                          ,'FIELD'
                                          ,'plan_rsrc_usage');
               RAISE invalid_action;
            ELSIF (p_batchstep_resource_rec.plan_rsrc_usage <>
                                      l_batchstep_resource_rec.plan_rsrc_usage) THEN
               l_field_updated := TRUE;
               l_batchstep_resource_rec.plan_rsrc_usage :=
                                     p_batchstep_resource_rec.plan_rsrc_usage;
            END IF;
         END IF;

         IF     p_batchstep_resource_rec.actual_rsrc_usage =
                                                            fnd_api.g_miss_num
            AND l_step_status = 3 THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'actual_rsrc_usage');
            RAISE input_param_missing;
         ELSIF p_batchstep_resource_rec.actual_rsrc_usage IS NOT NULL THEN
            IF l_step_status = 1 THEN
               gme_common_pvt.log_message ('GME_INV_ACT_STEP_STATUS'
                                          ,'FIELD'
                                          ,'actual_rsrc_usage');
               RAISE invalid_action;
            ELSIF (l_batch_asqc = 1) THEN
               --Pawan Kumar changed the token
               gme_common_pvt.log_message ('GME_UPD_RSRC_NT_WRK_ASQCBTCH');
               RAISE invalid_action;
            --Pawan Kumar added nvl for proper update
            ELSIF (p_batchstep_resource_rec.actual_rsrc_usage <>
                           NVL (l_batchstep_resource_rec.actual_rsrc_usage
                               ,-1) ) THEN
               l_field_updated := TRUE;
               l_batchstep_resource_rec.actual_rsrc_usage :=
                                   p_batchstep_resource_rec.actual_rsrc_usage;
            END IF;
          --Pawan added for bug 4175041
         /* When the actual resource count is null in the database and we are trying to update actual resource usage without the
         actual resource count, then user will be given error message that actual resource count is required.*/
         ELSE
           IF (l_batchstep_resource_rec.actual_rsrc_count IS NULL AND p_batchstep_resource_rec.actual_rsrc_usage IS NOT NULL) THEN
             gme_common_pvt.log_message('GME_FIELD_VALUE_REQUIRED','FIELD_NAME', 'actual_rsrc_count');
             RAISE input_param_missing;
           END IF;
         END IF;

         IF (    p_batchstep_resource_rec.usage_um IS NOT NULL
             AND p_batchstep_resource_rec.usage_um <>
                                             l_batchstep_resource_rec.usage_um) THEN
            gme_common_pvt.log_message ('GME_UPD_NT_ALLOWED'
                                       ,'FIELD'
                                       ,'usage_uom');
            RAISE error_condition;
         END IF;

         IF     p_batchstep_resource_rec.plan_rsrc_qty = fnd_api.g_miss_num
            AND l_step_status = 1 THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'plan_rsrc_qty');
            RAISE input_param_missing;
         ELSIF (p_batchstep_resource_rec.plan_rsrc_qty IS NOT NULL) THEN
            IF l_batch_asqc = 1 THEN
               gme_common_pvt.log_message ('GME_ASQC_NO_PLAN_RSRC_QTY');
               RAISE error_condition;
            ELSIF l_step_status = 3 THEN
               gme_common_pvt.log_message ('GME_INV_ACT_STEP_STATUS'
                                          ,'FIELD'
                                          ,'plan_rsrc_qty');
               RAISE invalid_action;
            ELSIF (l_step_status = 2 OR l_batch_asqc = 1) THEN
               gme_common_pvt.log_message ('GME_UPD_NT_ALLOWED'
                                          ,'FIELD'
                                          ,'plan_rsrc_qty');
               RAISE invalid_action;
            ELSIF (p_batchstep_resource_rec.plan_rsrc_qty <>
                                        l_batchstep_resource_rec.plan_rsrc_qty) THEN
               l_field_updated := TRUE;
               l_batchstep_resource_rec.plan_rsrc_qty :=
                                       p_batchstep_resource_rec.plan_rsrc_qty;
            END IF;
         END IF;

         IF     p_batchstep_resource_rec.actual_rsrc_qty = fnd_api.g_miss_num
            AND l_step_status = 3 THEN
            gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                       ,'FIELD_NAME'
                                       ,'actual_rsrc_qty');
            RAISE input_param_missing;
         ELSIF p_batchstep_resource_rec.actual_rsrc_qty IS NOT NULL THEN
            IF l_batch_asqc = 1 THEN
               gme_common_pvt.log_message ('GME_ASQC_NO_ACT_RSRC_QTY');
               RAISE error_condition;
            ELSIF l_step_status = 1 THEN
               gme_common_pvt.log_message ('GME_INV_ACT_STEP_STATUS'
                                          ,'FIELD'
                                          ,'actual_rsrc_qty');
               RAISE invalid_action;
            --Pawan Kumar added nvl for proper update
            ELSIF (p_batchstep_resource_rec.actual_rsrc_qty <>
                             NVL (l_batchstep_resource_rec.actual_rsrc_qty
                                 ,-1) ) THEN
               l_field_updated := TRUE;
               l_batchstep_resource_rec.actual_rsrc_qty :=
                                     p_batchstep_resource_rec.actual_rsrc_qty;
            END IF;
         END IF;

         IF (    p_batchstep_resource_rec.resource_qty_um IS NOT NULL
             AND p_batchstep_resource_rec.resource_qty_um <>
                                      l_batchstep_resource_rec.resource_qty_um) THEN
            gme_common_pvt.log_message ('GME_UPD_NT_ALLOWED'
                                       ,'FIELD'
                                       ,'resource_qty_uom');
            RAISE error_condition;
         END IF;

         IF l_step_status IN (1, 2, 3) THEN
            IF     p_batchstep_resource_rec.plan_start_date IS NOT NULL
               AND p_batchstep_resource_rec.plan_cmplt_date IS NOT NULL
               AND l_step_status = 1 THEN
               IF p_batchstep_resource_rec.plan_start_date >
                                     p_batchstep_resource_rec.plan_cmplt_date THEN
                  gme_common_pvt.log_message ('PM_BADSTARTDATE');
                  RAISE invalid_date;
               END IF;

               IF NOT (date_within_activity_dates
                                     (l_activity_id
                                     ,l_step_status
                                     ,p_batchstep_resource_rec.plan_start_date) ) THEN
                  gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                  RAISE date_outside_range;
               END IF;

               l_field_updated := TRUE;
               l_batchstep_resource_rec.plan_start_date :=
                                      p_batchstep_resource_rec.plan_start_date;

               IF NOT (date_within_activity_dates
                                     (l_activity_id
                                     ,l_step_status
                                     ,p_batchstep_resource_rec.plan_cmplt_date) ) THEN
                  gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                  RAISE date_outside_range;
               END IF;

               l_field_updated := TRUE;
               l_batchstep_resource_rec.plan_cmplt_date :=
                                      p_batchstep_resource_rec.plan_cmplt_date;
            ELSE
               IF (p_batchstep_resource_rec.plan_start_date IS NOT NULL) THEN
                  IF NOT (date_within_activity_dates
                                     (l_activity_id
                                     ,1
                                     ,p_batchstep_resource_rec.plan_start_date) ) THEN
                     gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                     RAISE date_outside_range;
                  END IF;

                  IF     l_batchstep_resource_rec.plan_cmplt_date IS NOT NULL
                     AND p_batchstep_resource_rec.plan_start_date >
                                      l_batchstep_resource_rec.plan_cmplt_date THEN
                     gme_common_pvt.log_message ('PM_BADSTARTDATE');
                     RAISE invalid_date;
                  END IF;

                  l_field_updated := TRUE;
                  l_batchstep_resource_rec.plan_start_date :=
                                      p_batchstep_resource_rec.plan_start_date;
               END IF;

               IF (p_batchstep_resource_rec.plan_cmplt_date IS NOT NULL) THEN
                  IF NOT (date_within_activity_dates
                                     (l_activity_id
                                     ,1
                                     ,p_batchstep_resource_rec.plan_cmplt_date) ) THEN
                     gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                     RAISE date_outside_range;
                  END IF;

                  IF     l_batchstep_resource_rec.plan_start_date IS NOT NULL
                     AND l_batchstep_resource_rec.plan_start_date >
                                      p_batchstep_resource_rec.plan_cmplt_date THEN
                     gme_common_pvt.log_message ('PM_BADSTARTDATE');
                     RAISE invalid_date;
                  END IF;

                  l_field_updated := TRUE;
                  l_batchstep_resource_rec.plan_cmplt_date :=
                                      p_batchstep_resource_rec.plan_cmplt_date;
               END IF;
            END IF;

            IF l_step_status IN (2, 3) THEN
               IF     p_batchstep_resource_rec.actual_start_date IS NOT NULL
                  AND p_batchstep_resource_rec.actual_cmplt_date IS NOT NULL
                  AND l_step_status = 3 THEN
                  IF p_batchstep_resource_rec.actual_start_date >
                                   p_batchstep_resource_rec.actual_cmplt_date THEN
                     gme_common_pvt.log_message ('PM_BADSTARTDATE');
                     RAISE invalid_date;
                  END IF;

                  IF p_batchstep_resource_rec.actual_start_date =
                                                           fnd_api.g_miss_date THEN
                     gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                                ,'FIELD_NAME'
                                                ,'actual_start_date');
                     RAISE input_param_missing;
                  END IF;

                  IF NOT (date_within_activity_dates
                                   (l_activity_id
                                   ,3
                                   ,p_batchstep_resource_rec.actual_start_date) ) THEN
                     gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                     RAISE date_outside_range;
                  END IF;

                  l_field_updated := TRUE;
                  l_batchstep_resource_rec.actual_start_date :=
                                    p_batchstep_resource_rec.actual_start_date;

                  IF p_batchstep_resource_rec.actual_cmplt_date =
                                                           fnd_api.g_miss_date THEN
                     gme_common_pvt.log_message ('GME_FIELD_VALUE_REQUIRED'
                                                ,'FIELD_NAME'
                                                ,'actual_cmplt_date');
                     RAISE input_param_missing;
                  END IF;

                  IF NOT (date_within_activity_dates
                                   (l_activity_id
                                   ,3
                                   ,p_batchstep_resource_rec.actual_cmplt_date) ) THEN
                     gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                     RAISE date_outside_range;
                  END IF;

                  l_field_updated := TRUE;
                  l_batchstep_resource_rec.actual_cmplt_date :=
                                    p_batchstep_resource_rec.actual_cmplt_date;
               ELSE
                  IF p_batchstep_resource_rec.actual_start_date IS NOT NULL THEN
                     IF p_batchstep_resource_rec.actual_start_date =
                                                          fnd_api.g_miss_date THEN
                        gme_common_pvt.log_message
                                                 ('GME_FIELD_VALUE_REQUIRED'
                                                 ,'FIELD_NAME'
                                                 ,'actual_start_date');
                        RAISE input_param_missing;
                     END IF;

                     --Pawan Kumar added code for actual start date
                     IF p_batchstep_resource_rec.actual_start_date >
                                                    gme_common_pvt.g_timestamp THEN
                        fnd_message.set_name ('GMA', 'SY_NOFUTUREDATE');
                        fnd_msg_pub.ADD;
                        RAISE date_outside_range;
                     END IF;

                     IF NOT (date_within_activity_dates
                                   (l_activity_id
                                   ,3
                                   ,p_batchstep_resource_rec.actual_start_date) ) THEN
                        gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                        RAISE date_outside_range;
                     END IF;

                     IF     l_batchstep_resource_rec.actual_cmplt_date IS NOT NULL
                        AND p_batchstep_resource_rec.actual_start_date >
                                    l_batchstep_resource_rec.actual_cmplt_date THEN
                        gme_common_pvt.log_message ('PM_BADSTARTDATE');
                        RAISE invalid_date;
                     END IF;

                     l_field_updated := TRUE;
                     l_batchstep_resource_rec.actual_start_date :=
                                    p_batchstep_resource_rec.actual_start_date;
                  END IF;

                  IF (    p_batchstep_resource_rec.actual_cmplt_date IS NOT NULL
                      AND l_step_status = 3) THEN
                     IF p_batchstep_resource_rec.actual_cmplt_date =
                                                          fnd_api.g_miss_date THEN
                        gme_common_pvt.log_message
                                                 ('GME_FIELD_VALUE_REQUIRED'
                                                 ,'FIELD_NAME'
                                                 ,'actual_cmplt_date');
                        RAISE input_param_missing;
                     END IF;

                     IF NOT (date_within_activity_dates
                                   (l_activity_id
                                   ,3
                                   ,p_batchstep_resource_rec.actual_cmplt_date) ) THEN
                        gme_common_pvt.log_message
                                          ('GME_RSRC_DATES_NOT_ALLOWED'
                                          ,'RESOURCE'
                                          ,p_batchstep_resource_rec.resources);
                        RAISE date_outside_range;
                     END IF;

                     IF     l_batchstep_resource_rec.actual_start_date IS NOT NULL
                        AND p_batchstep_resource_rec.actual_cmplt_date <
                                    l_batchstep_resource_rec.actual_start_date THEN
                        gme_common_pvt.log_message ('PM_BADSTARTDATE');
                        RAISE invalid_date;
                     END IF;

                     l_field_updated := TRUE;
                     l_batchstep_resource_rec.actual_cmplt_date :=
                                    p_batchstep_resource_rec.actual_cmplt_date;
                  END IF;
               END IF;

               IF l_step_status = 2 THEN
                  OPEN cur_get_activity_detail (l_activity_id);

                  FETCH cur_get_activity_detail
                   INTO l_act_plan_start_date, l_act_plan_cmplt_date;

                  CLOSE cur_get_activity_detail;

                  IF     p_batchstep_resource_rec.plan_start_date IS NULL
                     AND l_batchstep_resource_rec.plan_start_date IS NULL THEN
                     l_field_updated := TRUE;
                     l_batchstep_resource_rec.plan_start_date :=
                                                        l_act_plan_start_date;
                  END IF;

                  IF     p_batchstep_resource_rec.plan_cmplt_date IS NULL
                     AND l_batchstep_resource_rec.plan_cmplt_date IS NULL THEN
                     l_field_updated := TRUE;
                     l_batchstep_resource_rec.plan_cmplt_date :=
                                                        l_act_plan_cmplt_date;
                  END IF;
               END IF;
            END IF;                                    -- l_step_status IN 1,2
         END IF;                                     -- l_step_status IN 1,2,3

         IF gme_common_pvt.is_qty_below_capacity
                       (p_batch_step_resources_rec      => l_batchstep_resource_rec) THEN
            gme_common_pvt.log_message ('GME_RESOURCE_PROCESS_QUANTITY'
                                       ,'RESOURCE'
                                       ,l_batchstep_resource_rec.resources);

            IF p_ignore_qty_below_cap = fnd_api.g_false THEN
               RAISE process_qty_error;
            END IF;
         END IF;

         /* consolidate flexfield values from the input rec and the existing rec ahead of updating the table */
         consolidate_flexfields
                    (p_new_batchstep_resource_rec      => p_batchstep_resource_rec
                    ,p_old_batchstep_resource_rec      => l_batchstep_resource_rec
                    ,p_validate_flexfield              => p_validate_flexfield
                    ,x_batchstep_resource_rec          => l_batchstep_resource_rec_out
                    ,x_return_status                   => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE flex_consolidation_error;
         ELSE
            l_batchstep_resource_rec := l_batchstep_resource_rec_out;
         END IF;
      END IF;                            --                         p_action =

/* Flexfield Validation */
/* =====================*/
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' start flexfield validation ');
      END IF;

      IF p_validate_flexfield = fnd_api.g_true THEN
         gme_validate_flex_fld_pvt.validate_flex_step_resources
                           (p_step_resources      => l_batchstep_resource_rec
                           ,x_step_resources      => l_batchstep_resource_rec_out
                           ,x_return_status       => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE flex_validation_error;
         ELSE
            l_batchstep_resource_rec := l_batchstep_resource_rec_out;
         END IF;
      END IF;

/* Populate the output batchstep resource rec*/
/* ========================================= */
      x_batchstep_resource_rec := l_batchstep_resource_rec;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   ' Completed  '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN invalid_step_status OR invalid_asqc OR invalid_activity_factor OR invalid_date OR date_outside_range OR invalid_action THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN cost_cmpnt_not_found OR analysis_code_not_found OR invalid_prim_rsrc_ind OR invalid_scale_type OR input_param_missing OR error_condition OR flex_validation_error OR flex_consolidation_error OR rsrc_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END validate_rsrc_param;

/*===========================================================================================
   Procedure
      insert_batchstep_rsrc
   Description
     Procedure is used to insert rsrc for an activity
   Parameters
     p_batchstep_resource_rec     Input  Row from GME_BATCH_STEP_RESOURCES
     x_batchstep_resource_rec     Output Row from GME_BATCH_STEP_RESOURCES
     x_return_status              reflects return status of the API
=============================================================================================*/
   PROCEDURE insert_batchstep_rsrc (
      p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_batchstep_resource_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name            CONSTANT VARCHAR2 (30) := 'insert_batchstep_rsrc';
      l_batchstep_resource_rec       gme_batch_step_resources%ROWTYPE;
      l_batchstep_resource_out_rec   gme_batch_step_resources%ROWTYPE;
      l_batch_header                 gme_batch_header%ROWTYPE;
      l_batch_header_out             gme_batch_header%ROWTYPE;
      l_return_status                VARCHAR2 (2);
      l_rsrc_trans_count             NUMBER;
      l_capacity_constraint          NUMBER;
      l_max_step_capacity            NUMBER;

      -- Define CURSORS
      CURSOR cur_get_step_dtls (v_batchstep_id NUMBER)
      IS
         SELECT max_step_capacity
           FROM gme_batch_steps
          WHERE batchstep_id = v_batchstep_id;

      CURSOR cur_get_rsrc_hdr (v_resources VARCHAR2)
      IS
         SELECT capacity_constraint
           FROM cr_rsrc_mst
          WHERE resources = v_resources;

      validation_failure             EXCEPTION;
      rsrc_insert_failure            EXCEPTION;
      rsrc_not_found                 EXCEPTION;
      error_condition                EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Initially let us assign the return status to success */
      x_return_status := fnd_api.g_ret_sts_success;
      l_batchstep_resource_rec := p_batchstep_resource_rec;

      IF l_batchstep_resource_rec.offset_interval IS NULL THEN
         l_batchstep_resource_rec.offset_interval := 0;
      END IF;

      -- load temp table so that save_batch routine does resource txn consolidation
      -- since we are inserting a new resource rsrc txn temp table would not have any data in it
      -- after inserting the resource we would have corresponding txn inserted
      l_batch_header.batch_id := l_batchstep_resource_rec.batch_id;

      IF NOT gme_batch_header_dbl.fetch_row
                                         (p_batch_header      => l_batch_header
                                         ,x_batch_header      => l_batch_header_out) THEN
         RAISE error_condition;
      END IF;

      l_batch_header := l_batch_header_out;

      IF l_batch_header.update_inventory_ind = 'Y' THEN
         gme_trans_engine_util.load_rsrc_trans
                                      (p_batch_row          => l_batch_header
                                      ,x_rsc_row_count      => l_rsrc_trans_count
                                      ,x_return_status      => l_return_status);

         IF l_return_status <> 'S' THEN
            RAISE error_condition;
         END IF;
      END IF;

      gme_resource_engine_pvt.resource_dtl_process
                        (p_step_resources_rec      => l_batchstep_resource_rec
                        ,p_action_code             => 'INSERT'
                        ,p_check_prim_rsrc         => TRUE
                        ,x_step_resources_rec      => l_batchstep_resource_out_rec
                        ,x_return_status           => l_return_status);

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('after insert ' || l_return_status);
      END IF;

      IF l_return_status <> 'S' THEN
         RAISE rsrc_insert_failure;
      ELSE
         --Rishi Varma bug 3307549 13-05-2005
         gme_batch_step_chg_pvt.set_sequence_dependent_id
                                                     (l_batch_header.batch_id);

         -- UPDATE rsrc max capacity if required
         OPEN cur_get_step_dtls (l_batchstep_resource_rec.batchstep_id);

         FETCH cur_get_step_dtls
          INTO l_max_step_capacity;

         CLOSE cur_get_step_dtls;

         OPEN cur_get_rsrc_hdr (l_batchstep_resource_rec.resources);

         FETCH cur_get_rsrc_hdr
          INTO l_capacity_constraint;

         IF cur_get_rsrc_hdr%NOTFOUND THEN
            CLOSE cur_get_rsrc_hdr;

            fnd_message.set_name ('GMD', 'FM_BAD_RESOURCE');
            fnd_msg_pub.ADD;
            RAISE rsrc_not_found;
         END IF;

         CLOSE cur_get_rsrc_hdr;

         IF (    l_capacity_constraint = 1
             AND l_batchstep_resource_rec.max_capacity < l_max_step_capacity) THEN
            -- CALL DBL with updated max_capacity
            UPDATE gme_batch_steps
               SET max_step_capacity = l_batchstep_resource_rec.max_capacity
                  ,last_update_date = gme_common_pvt.g_timestamp
                  ,last_updated_by = gme_common_pvt.g_user_ident
                  ,last_update_login = gme_common_pvt.g_login_id
             WHERE batchstep_id = l_batchstep_resource_rec.batchstep_id
               AND batch_id = l_batchstep_resource_rec.batch_id;
         END IF;
      END IF;

      x_batchstep_resource_rec := l_batchstep_resource_out_rec;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN validation_failure OR rsrc_not_found OR rsrc_insert_failure OR error_condition THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END insert_batchstep_rsrc;

/*===========================================================================================
   Procedure
      update_batchstep_rsrc
   Description
     Procedure to update resource for an activity
   Parameters
     p_batchstep_resource_rec     Input  Row from GME_BATCH_STEP_RESOURCES
     x_batchstep_resource_rec     Output Row from GME_BATCH_STEP_RESOURCES
     x_return_status              reflects return status of the API
   History
     Inventory Convergence Project - March 2005

     G. Muratore    15-APR-2009  Bug 8335046
        Update the last_update_date for locking issues at the step level.
=============================================================================================*/
   PROCEDURE update_batchstep_rsrc (
      p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_batchstep_resource_rec   OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name            CONSTANT VARCHAR2 (30) := 'update_batchstep_rsrc';
      l_dummy                        NUMBER;
      l_rsrc_id                      NUMBER;
      l_batch_id                     NUMBER;
      l_activity_id                  NUMBER;
      l_batchstep_id                 NUMBER;
      l_batch_status                 NUMBER;
      l_step_status                  NUMBER;
      l_capacity_constraint          NUMBER;
      l_return_status                VARCHAR2 (2);
      l_max_step_capacity            NUMBER;
      l_batch_asqc                   NUMBER;
      l_field_updated                BOOLEAN                         := FALSE;
      l_resource                     VARCHAR2 (16);
      l_act_plan_start_date          DATE;
      l_act_plan_cmplt_date          DATE;
      l_inv_trans_count              NUMBER;
      l_rsrc_trans_count             NUMBER;
      l_count_int                    NUMBER (10);
      l_flex_validate                BOOLEAN                         := FALSE;
      l_batchstep_resource_rec       gme_batch_step_resources%ROWTYPE;
      l_batchstep_resource_out_rec   gme_batch_step_resources%ROWTYPE;
      l_batch_header                 gme_batch_header%ROWTYPE;

      -- Bug 8335046 - Introduced following variable.
      l_update_capacity             NUMBER;

      /* CURSOR DECLARATIONS
      ====================== */
      CURSOR cur_get_step_dtl (v_resource_id NUMBER)
      IS
         SELECT a.batchstep_id, a.step_status, b.batchstep_activity_id
               ,a.batch_id, b.resources
           FROM gme_batch_steps a, gme_batch_step_resources b
          WHERE b.batchstep_resource_id = v_resource_id
            AND a.batch_id = b.batch_id
            AND a.batchstep_id = b.batchstep_id;

      CURSOR cur_get_step_capacity (v_batchstep_id NUMBER)
      IS
         SELECT max_step_capacity
           FROM gme_batch_steps;

      CURSOR cur_get_rsrc_dtl (v_resources VARCHAR2, v_orgn_code VARCHAR2)
      IS
         SELECT capacity_constraint
           FROM cr_rsrc_dtl
          WHERE resources = v_resources AND orgn_code = v_orgn_code;

      CURSOR cur_get_rsrc_hdr (v_resources VARCHAR2)
      IS
         SELECT capacity_constraint
           FROM cr_rsrc_mst
          WHERE resources = v_resources;

      CURSOR cur_validate_batch_type (v_rsrc_id NUMBER)
      IS
         SELECT 1
           FROM gme_batch_header a, gme_batch_step_resources b
          WHERE a.batch_id = b.batch_id
            AND b.batchstep_resource_id = v_rsrc_id
            AND a.batch_type = 10;

      rsrc_update_failure            EXCEPTION;
      input_param_missing            EXCEPTION;
      validate_param_failed          EXCEPTION;
      rsrc_fetch_error               EXCEPTION;
      process_qty_error              EXCEPTION;
      rsrc_not_valid                 EXCEPTION;
      analysis_code_not_found        EXCEPTION;
      cost_cmpnt_not_found           EXCEPTION;
      invalid_action                 EXCEPTION;
      invalid_scale_type             EXCEPTION;
      invalid_prim_rsrc_ind          EXCEPTION;
      invalid_date                   EXCEPTION;
      date_outside_range             EXCEPTION;
      rsrc_not_found                 EXCEPTION;
      validation_failure             EXCEPTION;
      no_change                      EXCEPTION;
      invalid_step_status            EXCEPTION;
      error_condition                EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Initially let us assign the return status to success */
      x_return_status := fnd_api.g_ret_sts_success;
      /* Get Batch step resource info */
      l_rsrc_id := p_batchstep_resource_rec.batchstep_resource_id;

      OPEN cur_get_step_dtl (l_rsrc_id);

      FETCH cur_get_step_dtl
       INTO l_batchstep_id, l_step_status, l_activity_id, l_batch_id
           ,l_resource;

      IF cur_get_step_dtl%NOTFOUND THEN
         CLOSE cur_get_step_dtl;

         gme_common_pvt.log_message ('GME_INVALID_RSRC_ID');
         RAISE rsrc_not_valid;
      END IF;

      CLOSE cur_get_step_dtl;

      -- make sure resource id does not belong to an FPO
      OPEN cur_validate_batch_type (l_rsrc_id);

      FETCH cur_validate_batch_type
       INTO l_dummy;

      IF cur_validate_batch_type%FOUND THEN
         CLOSE cur_validate_batch_type;

         gme_common_pvt.log_message ('GME_FPO_RSRC_NO_EDIT');
         RAISE rsrc_not_valid;
      END IF;

      CLOSE cur_validate_batch_type;

      -- load temp table so that save_batch routine does resource txn consolidation
      l_batch_header.batch_id := p_batchstep_resource_rec.batch_id;

      IF NOT gme_batch_header_dbl.fetch_row (p_batch_header      => l_batch_header
                                            ,x_batch_header      => l_batch_header) THEN
         RAISE error_condition;
      END IF;

      IF l_batch_header.update_inventory_ind = 'Y' THEN
         gme_trans_engine_util.load_rsrc_trans
                                      (p_batch_row          => l_batch_header
                                      ,x_rsc_row_count      => l_rsrc_trans_count
                                      ,x_return_status      => l_return_status);

         IF l_return_status <> x_return_status THEN
            RAISE error_condition;
         END IF;
      END IF;

      gme_resource_engine_pvt.resource_dtl_process
                        (p_step_resources_rec      => p_batchstep_resource_rec
                        ,p_action_code             => 'UPDATE'
                        ,p_check_prim_rsrc         => TRUE
                        ,x_step_resources_rec      => l_batchstep_resource_out_rec
                        ,x_return_status           => l_return_status);

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('aft upd' || l_return_status);
      END IF;

      IF l_return_status <> 'S' THEN
         RAISE rsrc_update_failure;
      ELSE
         -- UPDATE rsrc max capacity if required after fetching capacity constraint from resource
         OPEN cur_get_step_capacity (p_batchstep_resource_rec.batchstep_id);

         FETCH cur_get_step_capacity
          INTO l_max_step_capacity;

         CLOSE cur_get_step_capacity;

         OPEN cur_get_rsrc_dtl (l_resource
                               ,p_batchstep_resource_rec.organization_id);

         FETCH cur_get_rsrc_dtl
          INTO l_capacity_constraint;

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('after rsrc dtl fetch ');
         END IF;

         IF (cur_get_rsrc_dtl%NOTFOUND) THEN
            OPEN cur_get_rsrc_hdr (l_resource);

            FETCH cur_get_rsrc_hdr
             INTO l_capacity_constraint;

            IF cur_get_rsrc_hdr%NOTFOUND THEN
               CLOSE cur_get_rsrc_dtl;

               CLOSE cur_get_rsrc_hdr;

               fnd_message.set_name ('GMD', 'FM_BAD_RESOURCE');
               fnd_msg_pub.ADD;
               RAISE rsrc_not_found;
            END IF;

            CLOSE cur_get_rsrc_hdr;
         END IF;

         CLOSE cur_get_rsrc_dtl;

         -- Bug 8335046 - Restructured this update so that we always update the
         -- last_update_date for locking at the step level.
         l_update_capacity := 0;
         IF (l_capacity_constraint = 1 AND
             l_batchstep_resource_out_rec.max_capacity < l_max_step_capacity) THEN
            l_update_capacity := 1;
         END IF;

         -- CALL DBL with updated max_capacity
         UPDATE gme_batch_steps
            SET max_step_capacity = DECODE(l_update_capacity, 1, l_batchstep_resource_out_rec.max_capacity, max_step_capacity),
                last_update_date = l_batchstep_resource_out_rec.last_update_date
          WHERE batchstep_id = l_batchstep_id AND batch_id = l_batch_id;
      END IF;

      x_batchstep_resource_rec := l_batchstep_resource_out_rec;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN validation_failure OR analysis_code_not_found OR cost_cmpnt_not_found OR rsrc_fetch_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN rsrc_not_valid OR rsrc_update_failure OR input_param_missing THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN rsrc_not_found OR validate_param_failed OR invalid_action OR invalid_scale_type OR process_qty_error OR invalid_date OR date_outside_range OR invalid_prim_rsrc_ind OR no_change OR invalid_step_status OR error_condition THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END update_batchstep_rsrc;

/*===========================================================================================
   Procedure
      delete_batchstep_rsrc
   Description
     Procedure to delete batchstep resource
   Parameters
     p_batchstep_resource_rec     batchstep resource row targetted for deletion
     x_return_status              reflects return status of the API
=============================================================================================*/
   PROCEDURE delete_batchstep_rsrc (
      p_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,x_return_status            OUT NOCOPY      VARCHAR2)
   IS
      l_api_name        CONSTANT VARCHAR2 (30)     := 'delete_batchstep_rsrc';
      l_batchstep_resource_rec   gme_batch_step_resources%ROWTYPE;
      l_batch_header             gme_batch_header%ROWTYPE;
      l_return_status            VARCHAR2 (2);
      l_rsrc_trans_count         NUMBER;
      error_deleting_rsrc        EXCEPTION;
      error_condition            EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Initially let us assign the return status to success */
      x_return_status := fnd_api.g_ret_sts_success;
      -- load temp table so that save_batch routine does resource txn consolidation
      l_batch_header.batch_id := p_batchstep_resource_rec.batch_id;

      IF NOT gme_batch_header_dbl.fetch_row (p_batch_header      => l_batch_header
                                            ,x_batch_header      => l_batch_header) THEN
         gme_common_pvt.log_message ('GME_BATCH_NOT_FOUND');
         RAISE error_condition;
      END IF;

      IF l_batch_header.update_inventory_ind = 'Y' THEN
         gme_trans_engine_util.load_rsrc_trans
                                      (p_batch_row          => l_batch_header
                                      ,x_rsc_row_count      => l_rsrc_trans_count
                                      ,x_return_status      => l_return_status);

         IF l_return_status <> x_return_status THEN
            RAISE error_condition;
         END IF;
      END IF;

      gme_resource_engine_pvt.resource_dtl_process
                            (p_step_resources_rec      => p_batchstep_resource_rec
                            ,p_action_code             => 'DELETE'
                            ,p_check_prim_rsrc         => TRUE
                            ,x_step_resources_rec      => l_batchstep_resource_rec
                            ,x_return_status           => l_return_status);

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   'delete batchsetp resource returns '
                             || l_return_status);
      END IF;

      IF l_return_status <> 'S' THEN
         RAISE error_deleting_rsrc;
      END IF;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN error_deleting_rsrc OR error_condition THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END delete_batchstep_rsrc;

   FUNCTION date_within_activity_dates (
      p_batchstep_activity_id   NUMBER
     ,p_step_status             NUMBER
     ,p_date                    DATE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'date_within_activity_dates';
      l_plan_start_date     DATE;
      l_plan_cmplt_date     DATE;
      l_actual_start_date   DATE;
      l_actual_cmplt_date   DATE;

      CURSOR cur_get_act_dates
      IS
         SELECT plan_start_date, plan_cmplt_date, actual_start_date
               ,actual_cmplt_date
           FROM gme_batch_step_activities
          WHERE batchstep_activity_id = p_batchstep_activity_id;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' ||
                             g_pkg_name || '.' ||
                             l_api_name);
         gme_debug.put_line ('Input step status is ' ||
                             p_step_status  ||
                             'Input batchstep activity id is '||
                             p_batchstep_activity_id);
      END IF;

      OPEN cur_get_act_dates;

      FETCH cur_get_act_dates
       INTO l_plan_start_date, l_plan_cmplt_date, l_actual_start_date
           ,l_actual_cmplt_date;

      CLOSE cur_get_act_dates;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Input date =>'
                             || p_date
                             || 'plan start =>'
                             || l_plan_start_date
                             || 'plan cmplt =>'
                             || l_plan_cmplt_date
                             || 'actual start=>'
                             || l_actual_start_date
                             || 'actual cmplt=>'
                             || l_actual_cmplt_date);
      END IF;

--Pawan Kumar added the NVL
      IF p_step_status = 1 THEN
         IF (    p_date >= l_plan_start_date
             AND p_date <= NVL (l_plan_cmplt_date, SYSDATE) ) THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END IF;

      IF p_step_status = 3 THEN
         IF (    p_date >= l_actual_start_date
             AND p_date <= NVL (l_actual_cmplt_date, SYSDATE) ) THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END IF;
   END date_within_activity_dates;

   FUNCTION lookup_code_valid (p_lookup_type VARCHAR2, p_lookup_code VARCHAR2)
      RETURN BOOLEAN
   IS
      CURSOR cur_validate_from_lookup
      IS
         SELECT 1
           FROM gem_lookups
          WHERE lookup_type = p_lookup_type AND lookup_code = p_lookup_code;

      l_dummy   NUMBER;
   BEGIN
      IF p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL THEN
         OPEN cur_validate_from_lookup;

         FETCH cur_validate_from_lookup
          INTO l_dummy;

         IF cur_validate_from_lookup%NOTFOUND THEN
            CLOSE cur_validate_from_lookup;

            RETURN FALSE;
         END IF;

         CLOSE cur_validate_from_lookup;

         RETURN TRUE;
      END IF;

      RETURN FALSE;
   END lookup_code_valid;

/*===========================================================================================
   Procedure
      consolidate_flexfields
   Description
     Move input attribute values into the output record structure prior to validation or update
     processing.
     If p_validate_flexfield is TRUE, just move the value. The validation processing will
     do the rest.
     If flexfield validation is FALSE, then interpret the input values according to these rules
       NULL        means update value not supplied so retain the original (old) value
       G_MISS_???  means update with a NULL value
       NOT NULL    update with the supplied value
   Parameters
     p_new_batchstep_resource_rec   input record with values to be applied as updates
     p_old_batchstep_resource_rec   original record retrieved from the database
     p_validate_flexfield           indicates whethere validation required or not
     x_batchstep_resource_rec       Consolidation of the inputs above
     x_return_status                Return status
=============================================================================================*/
   PROCEDURE consolidate_flexfields (
      p_new_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_old_batchstep_resource_rec   IN              gme_batch_step_resources%ROWTYPE
     ,p_validate_flexfield           IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,x_batchstep_resource_rec       OUT NOCOPY      gme_batch_step_resources%ROWTYPE
     ,x_return_status                OUT NOCOPY      VARCHAR2)
   IS
      l_api_name        CONSTANT VARCHAR2 (30)    := 'consolidate_flexfields';
      l_batchstep_resource_rec   gme_batch_step_resources%ROWTYPE;
      l_return_status            VARCHAR2 (2);
      error_condition            EXCEPTION;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      /* Initially let us assign the return status to success */
      x_return_status := fnd_api.g_ret_sts_success;
      l_batchstep_resource_rec := p_old_batchstep_resource_rec;

      IF p_validate_flexfield = fnd_api.g_false THEN
         -- start with the old record
         -- field values will be overwritten by data from the new record as appropriate
         -- Follow these rules when interpreting inputs from the new rec:
         -- NULL        means update value not supplied so retain the original (old) value
         -- G_MISS_???  means update with a NULL value
         -- NOT NULL    update with the supplied value
         IF p_new_batchstep_resource_rec.attribute_category IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute_category =
                                                          fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute_category := NULL;
            ELSE
               l_batchstep_resource_rec.attribute_category :=
                              p_new_batchstep_resource_rec.attribute_category;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute1 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute1 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute1 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute1 :=
                                      p_new_batchstep_resource_rec.attribute1;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute2 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute2 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute2 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute2 :=
                                      p_new_batchstep_resource_rec.attribute2;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute3 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute3 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute3 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute3 :=
                                      p_new_batchstep_resource_rec.attribute3;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute4 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute4 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute4 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute4 :=
                                      p_new_batchstep_resource_rec.attribute4;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute5 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute5 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute5 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute5 :=
                                      p_new_batchstep_resource_rec.attribute5;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute6 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute6 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute6 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute6 :=
                                      p_new_batchstep_resource_rec.attribute6;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute7 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute7 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute7 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute7 :=
                                      p_new_batchstep_resource_rec.attribute7;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute8 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute8 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute8 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute8 :=
                                      p_new_batchstep_resource_rec.attribute8;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute9 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute9 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute9 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute9 :=
                                      p_new_batchstep_resource_rec.attribute9;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute10 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute10 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute10 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute10 :=
                                     p_new_batchstep_resource_rec.attribute10;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute11 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute11 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute11 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute11 :=
                                     p_new_batchstep_resource_rec.attribute11;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute12 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute12 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute12 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute12 :=
                                     p_new_batchstep_resource_rec.attribute12;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute13 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute13 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute13 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute13 :=
                                     p_new_batchstep_resource_rec.attribute13;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute14 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute14 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute14 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute14 :=
                                     p_new_batchstep_resource_rec.attribute14;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute15 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute15 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute15 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute15 :=
                                     p_new_batchstep_resource_rec.attribute15;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute16 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute16 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute16 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute16 :=
                                     p_new_batchstep_resource_rec.attribute16;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute17 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute17 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute17 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute17 :=
                                     p_new_batchstep_resource_rec.attribute17;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute18 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute18 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute18 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute18 :=
                                     p_new_batchstep_resource_rec.attribute18;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute19 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute19 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute19 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute19 :=
                                     p_new_batchstep_resource_rec.attribute19;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute20 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute20 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute20 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute20 :=
                                     p_new_batchstep_resource_rec.attribute20;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute21 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute21 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute21 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute21 :=
                                     p_new_batchstep_resource_rec.attribute21;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute22 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute22 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute22 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute22 :=
                                     p_new_batchstep_resource_rec.attribute22;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute23 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute23 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute23 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute23 :=
                                     p_new_batchstep_resource_rec.attribute23;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute24 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute24 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute24 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute24 :=
                                     p_new_batchstep_resource_rec.attribute24;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute25 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute25 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute25 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute25 :=
                                     p_new_batchstep_resource_rec.attribute25;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute26 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute26 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute26 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute26 :=
                                     p_new_batchstep_resource_rec.attribute26;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute27 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute27 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute27 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute27 :=
                                     p_new_batchstep_resource_rec.attribute27;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute28 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute28 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute28 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute28 :=
                                     p_new_batchstep_resource_rec.attribute28;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute29 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute29 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute29 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute29 :=
                                     p_new_batchstep_resource_rec.attribute29;
            END IF;
         END IF;

         IF p_new_batchstep_resource_rec.attribute30 IS NOT NULL THEN
            IF p_new_batchstep_resource_rec.attribute30 = fnd_api.g_miss_char THEN
               l_batchstep_resource_rec.attribute30 := NULL;
            ELSE
               l_batchstep_resource_rec.attribute30 :=
                                     p_new_batchstep_resource_rec.attribute30;
            END IF;
         END IF;
      ELSE
         /* validate flexfield is set True, so flex field handling is not dealt with here     */
         /* It will be dealt with by the validation procedure.                                */
         /* On this basis, retain the new update values                                       */
         l_batchstep_resource_rec.attribute_category :=
                              p_new_batchstep_resource_rec.attribute_category;
         l_batchstep_resource_rec.attribute1 :=
                                      p_new_batchstep_resource_rec.attribute1;
         l_batchstep_resource_rec.attribute2 :=
                                      p_new_batchstep_resource_rec.attribute2;
         l_batchstep_resource_rec.attribute3 :=
                                      p_new_batchstep_resource_rec.attribute3;
         l_batchstep_resource_rec.attribute4 :=
                                      p_new_batchstep_resource_rec.attribute4;
         l_batchstep_resource_rec.attribute5 :=
                                      p_new_batchstep_resource_rec.attribute5;
         l_batchstep_resource_rec.attribute6 :=
                                      p_new_batchstep_resource_rec.attribute6;
         l_batchstep_resource_rec.attribute7 :=
                                      p_new_batchstep_resource_rec.attribute7;
         l_batchstep_resource_rec.attribute8 :=
                                      p_new_batchstep_resource_rec.attribute8;
         l_batchstep_resource_rec.attribute9 :=
                                      p_new_batchstep_resource_rec.attribute9;
         l_batchstep_resource_rec.attribute10 :=
                                     p_new_batchstep_resource_rec.attribute10;
         l_batchstep_resource_rec.attribute11 :=
                                     p_new_batchstep_resource_rec.attribute11;
         l_batchstep_resource_rec.attribute12 :=
                                     p_new_batchstep_resource_rec.attribute12;
         l_batchstep_resource_rec.attribute13 :=
                                     p_new_batchstep_resource_rec.attribute13;
         l_batchstep_resource_rec.attribute14 :=
                                     p_new_batchstep_resource_rec.attribute14;
         l_batchstep_resource_rec.attribute15 :=
                                     p_new_batchstep_resource_rec.attribute15;
         l_batchstep_resource_rec.attribute16 :=
                                     p_new_batchstep_resource_rec.attribute16;
         l_batchstep_resource_rec.attribute17 :=
                                     p_new_batchstep_resource_rec.attribute17;
         l_batchstep_resource_rec.attribute18 :=
                                     p_new_batchstep_resource_rec.attribute18;
         l_batchstep_resource_rec.attribute19 :=
                                     p_new_batchstep_resource_rec.attribute19;
         l_batchstep_resource_rec.attribute20 :=
                                     p_new_batchstep_resource_rec.attribute20;
         l_batchstep_resource_rec.attribute21 :=
                                     p_new_batchstep_resource_rec.attribute21;
         l_batchstep_resource_rec.attribute22 :=
                                     p_new_batchstep_resource_rec.attribute22;
         l_batchstep_resource_rec.attribute23 :=
                                     p_new_batchstep_resource_rec.attribute23;
         l_batchstep_resource_rec.attribute24 :=
                                     p_new_batchstep_resource_rec.attribute24;
         l_batchstep_resource_rec.attribute25 :=
                                     p_new_batchstep_resource_rec.attribute25;
         l_batchstep_resource_rec.attribute26 :=
                                     p_new_batchstep_resource_rec.attribute26;
         l_batchstep_resource_rec.attribute27 :=
                                     p_new_batchstep_resource_rec.attribute27;
         l_batchstep_resource_rec.attribute28 :=
                                     p_new_batchstep_resource_rec.attribute28;
         l_batchstep_resource_rec.attribute29 :=
                                     p_new_batchstep_resource_rec.attribute29;
         l_batchstep_resource_rec.attribute30 :=
                                     p_new_batchstep_resource_rec.attribute30;
      END IF;

      x_batchstep_resource_rec := l_batchstep_resource_rec;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line (   ' Completed '
                             || l_api_name
                             || ' at '
                             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS') );
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END consolidate_flexfields;
END gme_batchstep_rsrc_pvt;

/
