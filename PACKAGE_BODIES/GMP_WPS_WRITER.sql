--------------------------------------------------------
--  DDL for Package Body GMP_WPS_WRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_WPS_WRITER" AS
/* $Header: GMPWPSWB.pls 120.3 2005/10/13 13:03:43 asatpute noship $ */

  v_cp_enabled BOOLEAN := FALSE;

/***********************************************************************
*
*   NAME
*     update_batch_header
*
*   DESCRIPTION
*     This procedure will update the batch plan start and end date after
*     once the WPS scheduling engine has completed.
*   HISTORY
*     M Craig  created
*     Rajesh Patangya Removed Materail Update R12.0.
************************************************************************/
PROCEDURE update_batch_header(
  pbatch_id      IN  NUMBER,
  pstart_date    IN  NUMBER,
  pend_date      IN  NUMBER,
  plast_update   IN  NUMBER,
  phorizon       IN  NUMBER,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER)

IS

  v_batch_id       NUMBER;
  last_update_date DATE;
  v_start_date     DATE;
  v_end_date       DATE;

  CURSOR validate_batch_header IS
    SELECT
      gbh.batch_status,
      gbh.last_update_date
    FROM
      gme_batch_header gbh
    WHERE
      batch_id = v_batch_id;

  v_batch_status     NUMBER;
  v_last_update_date DATE;

BEGIN

  v_batch_id := pbatch_id;
  return_status := 0;
  v_start_date := wip_datetimes.float_to_DT(pstart_date/1440+phorizon);
  v_end_date := wip_datetimes.float_to_DT(pend_date/1440+phorizon);
  v_batch_status := 0;

  OPEN validate_batch_header;
  FETCH validate_batch_header INTO v_batch_status, v_last_update_date;

  IF validate_batch_header%NOTFOUND THEN
    return_status := -1;
  ELSE
    last_update_date := wip_datetimes.float_to_DT(plast_update/1440+phorizon+1);

    IF v_last_update_date > last_update_date THEN
      return_status := -2;
    ELSIF v_batch_status > 2 THEN
      return_status := 0;
    ELSE
      IF v_batch_status = 1 THEN
        UPDATE
          gme_batch_header
        SET
          plan_start_date = v_start_date,
          plan_cmplt_date = v_end_date,
          finite_scheduled_ind = 1,
          last_update_date = SYSDATE,
          last_updated_by = puser_id,
          last_update_login = plogin_id
        WHERE
          batch_id = v_batch_id;
      ELSE
        UPDATE
          gme_batch_header
        SET
          plan_cmplt_date = v_end_date,
          finite_scheduled_ind = 1,
          last_update_date = SYSDATE,
          last_updated_by = puser_id,
          last_update_login = plogin_id
        WHERE
          batch_id = v_batch_id;
      END IF;
      IF SQL%NOTFOUND THEN
          return_status := -3;
      END IF;
    END IF;
  END IF;

  CLOSE validate_batch_header;

  EXCEPTION
    WHEN OTHERS THEN
      return_status := -99;
      log_message('Failure occured during Batch Header Update: ' || pbatch_id);
      log_message(sqlerrm);

END update_batch_header;

/***********************************************************************
*
*   NAME
*     update_batch_steps
*
*   DESCRIPTION
*     This procedure will update the batch step plan start and end date after
*     the WPS scheduling engine has completed.
*
*   HISTORY
*     M Craig  -- created
*     Rajesh Patangya -- Modified for Release 12.0
*     If the item is associated to step and NOT having release_type of
*     Automatic (0) in the material detail then the step's plan_start_date
*     will be used for all ingredients (line_type= -1) and plan_cmplt_date
*     for all products and byproducts (line_type = 1 or 2).
*     If the item is not associated to step OR Item is associated to step and
*     having release_type of Automatic (0) in the material detail then the
*     batch's plan_start_date will be used for all ingredients (line_type= -1)
*     and plan_cmplt_date for all products and byproducts (line_type = 1 or 2)
*
************************************************************************/
PROCEDURE update_batch_steps(
  pbatch_id      IN  NUMBER,
  pstep_no       IN  NUMBER_TBL_TYPE,
  pstep_id       IN  NUMBER_TBL_TYPE,
  pstart_date    IN  NUMBER_TBL_TYPE,
  pend_date      IN  NUMBER_TBL_TYPE,
  plast_update   IN  NUMBER_TBL_TYPE,
  phorizon       IN  NUMBER,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  pnum_rows      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER)

IS

  v_batch_id   NUMBER ;
  v_step_no    NUMBER ;
  v_step_id    NUMBER ;
  v_start_date DATE;
  v_end_date   DATE;
  num_rows     NUMBER ;
  last_update_date DATE;

  CURSOR validate_step IS
    SELECT
      gbs.last_update_date,
      gbs.step_status
    FROM
      gme_batch_steps gbs
    WHERE
          gbs.batch_id = v_batch_id
      AND gbs.batchstep_no = v_step_no;

  v_last_update_date   DATE;
  v_step_status        NUMBER;
  v_material_detail_id NUMBER ;
  v_line_type          NUMBER ;
  m_return_status      VARCHAR2(1);

  CURSOR get_step_material IS
    SELECT material_detail_id, line_type
      FROM gme_material_details
    WHERE batch_id = v_batch_id ;

BEGIN

  return_status := 0;
  v_batch_id    := pbatch_id;
  v_step_no := 0;
  v_step_id := 0;
  num_rows  := 0;

  v_step_status := 0;
  m_return_status      := NULL;
  v_material_detail_id := 0;
  v_line_type          := 0;

  FOR i IN 1..pnum_rows LOOP
    v_step_no := pstep_no(i);
    v_step_id := pstep_id(i);
    OPEN validate_step;
    FETCH validate_step INTO v_last_update_date, v_step_status;

    IF validate_step%NOTFOUND THEN
      return_status := -1;
    ELSIF v_step_status > 1 THEN
      return_status := -2;
    ELSE
      last_update_date := wip_datetimes.float_to_DT(plast_update(i)/1440+phorizon+1);
      IF v_last_update_date > last_update_date THEN
        return_status := -2;
      ELSE
        v_start_date := wip_datetimes.float_to_DT(pstart_date(i)/1440+phorizon);
        v_end_date := wip_datetimes.float_to_DT(pend_date(i)/1440+phorizon);

        UPDATE
          gme_batch_steps
        SET
          plan_start_date  = v_start_date,
          plan_cmplt_date  = v_end_date,
          last_update_date = SYSDATE,
          last_updated_by  = puser_id
        WHERE
              batch_id     = v_batch_id
          AND batchstep_no = v_step_no;

        IF SQL%NOTFOUND THEN
          return_status := -2;
        ELSE
        /* Update to the charges */
        BEGIN
        UPDATE GME_BATCH_STEP_CHARGES
          SET
            PLAN_START_DATE  = v_start_date,
            plan_cmplt_date  = v_end_date,
            last_update_date = SYSDATE,
            last_updated_by  = puser_id
         WHERE
              batch_id     = v_batch_id
           AND batchstep_id = v_step_id;

            num_rows := num_rows + 1;

         EXCEPTION
          WHEN NO_DATA_FOUND THEN
            num_rows := num_rows + 1;
          WHEN OTHERS THEN
	     return_status := -88;
	     log_message('Failure occured Charge Update: ' || pbatch_id);
	     log_message(sqlerrm);
         END ;

        END IF;
      END IF;
    END IF;
    CLOSE validate_step;

    EXIT WHEN return_status < 0;

  END LOOP;

  IF return_status = 0 THEN

    -- API will check the step and materail association for the batch and
    -- decide the materail requirement date, should be step start/End OR
    -- Batch start/End Date. This will also ensures the further impact on
    -- Move order and allocations and reservations for the batch.

        OPEN get_step_material;
        LOOP
          FETCH get_step_material INTO v_material_detail_id, v_line_type;
          EXIT WHEN get_step_material%NOTFOUND;

          GME_API_GRP.update_material_date(
             v_material_detail_id,  --  p_material_detail_id,
             NULL,                  --  p_material_date
             m_return_status);

          IF m_return_status = 'S' THEN
             return_status := 0 ;
          ELSE
            -- Basically E and U
             return_status := -3;
             EXIT ;
          END IF;
        END LOOP;
        CLOSE get_step_material;

  END IF;

  IF return_status = 0 THEN
     return_status := num_rows;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
	return_status := -98;
	log_message('Failure occured during Batch Step Update: ' || pbatch_id);
	log_message(sqlerrm);
END update_batch_steps;


/***********************************************************************
*
*   NAME
*     update_batch_activities
*
*   DESCRIPTION
*     This procedure will update the batch step activity plan start and
*     end date once the WPS scheduling engine has completed.
*   HISTORY
*     M Craig
*     Rajesh Patangya -- Modified for Release 12.0
************************************************************************/
PROCEDURE update_batch_activities(
  pbatch_id      IN  NUMBER,
  pstep_id       IN  NUMBER,
  pactivity_id   IN  NUMBER,
  pstart_date    IN  NUMBER,
  pend_date      IN  NUMBER,
  plast_update   IN  NUMBER,
  phorizon       IN  NUMBER,
  puom_hour      IN  VARCHAR2,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER)

IS

  v_activity_id    NUMBER;
  v_step_id        NUMBER;
  v_batch_id       NUMBER;
  found            NUMBER;
  v_trn_start_date DATE;
  v_trn_end_date   DATE;
  v_start_date     DATE;
  v_end_date       DATE;
  v_hour_uom       VARCHAR2(3);
  v_trans_row      gme_resource_txns%ROWTYPE;

  last_update_date DATE;

  CURSOR validate_activity IS
    SELECT
      gsa.last_update_date,
      gbs.step_status
    FROM
      gme_batch_steps gbs,
      gme_batch_step_activities gsa
    WHERE
          gbs.batchstep_id = v_step_id
      AND gbs.batchstep_id = gsa.batchstep_id
      AND gsa.batchstep_activity_id = v_activity_id;

  v_last_update_date DATE;
  v_step_status      NUMBER;

  -- Activities, its resources and resource transactions with ZERO usage
  CURSOR get_zero_non_usage IS
    SELECT
      gsr.batchstep_resource_id,
      DECODE(gsr.plan_rsrc_usage, 0, 0, inv_convert.inv_um_convert(-1,38,
        gsr.plan_rsrc_usage,u2.uom_code,u1.uom_code,NULL,NULL)) plan_rsrc_usage,
      gsr.offset_interval,
      gsr.plan_start_date,
      gsr.plan_cmplt_date
    FROM
      gme_batch_step_resources gsr,
      mtl_units_of_measure u1,
      mtl_units_of_measure u2
    WHERE
          gsr.batchstep_activity_id = v_activity_id
      AND u1.uom_code = gsr.usage_um
      AND u2.uom_code = v_hour_uom
      AND (gsr.plan_rsrc_usage = 0 OR
           u1.uom_class <> u2.uom_class) ;

  v_zero_res_id     NUMBER;
  v_offset_interval NUMBER;
  temp_date         DATE;

BEGIN

  return_status := 0;
  v_activity_id := 0;
  v_step_id     := 0;
  v_batch_id    := 0;
  found         := 0;
  v_hour_uom    := NULL;
  v_step_status := 0;
  v_zero_res_id := 0;
  v_offset_interval := 0;
  temp_date         := NULL;

  v_activity_id := pactivity_id;
  v_step_id     := pstep_id;
  v_batch_id    := pbatch_id;

  OPEN validate_activity;
  FETCH validate_activity INTO v_last_update_date, v_step_status;

  IF validate_activity%NOTFOUND THEN
    return_status := -1;
  ELSIF v_step_status > 1 THEN
    return_status := -2;
  ELSE
    last_update_date := wip_datetimes.float_to_DT(plast_update/1440+phorizon+1);
    IF v_last_update_date > last_update_date THEN
      return_status := -3;
    ELSE
      v_start_date := wip_datetimes.float_to_DT(pstart_date/1440+phorizon);
      v_end_date := wip_datetimes.float_to_DT(pend_date/1440+phorizon);

      UPDATE
        gme_batch_step_activities
      SET
        plan_start_date  = v_start_date,
        plan_cmplt_date  = v_end_date,
        last_update_date = SYSDATE,
        last_updated_by  = puser_id
      WHERE
        batchstep_activity_id = v_activity_id;

      IF SQL%NOTFOUND THEN
        return_status := -4;
      ELSE

        v_hour_uom := puom_hour;
        FOR v_zero IN get_zero_non_usage LOOP

          v_zero_res_id := v_zero.batchstep_resource_id;
          v_offset_interval := v_zero.offset_interval/24;
          found := 0;

          IF v_zero.plan_rsrc_usage = 0 THEN

            temp_date := v_start_date + v_offset_interval;
            IF temp_date > v_end_date THEN
              v_offset_interval := 0;
            END IF;
            v_trn_start_date := v_start_date + v_offset_interval;
            v_trn_end_date := v_start_date + v_offset_interval;
            UPDATE
              gme_batch_step_resources
            SET
              plan_start_date = v_trn_start_date,
              plan_cmplt_date = v_trn_end_date,
              last_update_date = SYSDATE,
              last_updated_by = puser_id
            WHERE
              batchstep_resource_id = v_zero_res_id;

            IF SQL%NOTFOUND THEN
              return_status := -5;
            ELSE
              found := 1;
            END IF;
          ELSIF v_zero.plan_rsrc_usage < 0 THEN

            v_trn_start_date:= v_start_date;
            v_trn_end_date:= v_end_date;
            UPDATE
              gme_batch_step_resources
            SET
              plan_start_date = v_trn_start_date,
              plan_cmplt_date = v_trn_end_date,
              last_update_date = SYSDATE,
              last_updated_by = puser_id
            WHERE
              batchstep_resource_id = v_zero_res_id;

            IF SQL%NOTFOUND THEN
              return_status := -7;
            ELSE
              found := 1;
            END IF;
          END IF;

          IF found = 1 THEN
            UPDATE
              gme_resource_txns
            SET
              start_date = v_trn_start_date,
              end_date = v_trn_end_date,
              last_update_date = SYSDATE,
              last_updated_by = puser_id
            WHERE
                  doc_id = v_batch_id
              AND doc_type = 'PROD'
              AND line_id = v_zero_res_id
              AND completed_ind = 0
              AND delete_mark = 0;

            IF SQL%NOTFOUND THEN
              return_status := -6;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END IF;
  END IF;

  CLOSE validate_activity;

  IF return_status >= 0 THEN
    return_status := 1;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      return_status := -97;
      log_message('Failure occured during Batch Step Activities Update: '
        || pbatch_id);
      log_message(sqlerrm);

END update_batch_activities;

/***********************************************************************
*
*   NAME
*     update_batch_resources
*
*   DESCRIPTION
*     This procedure will update the batch step resource plan start and end date
*     once the WPS scheduling engine has completed.
*   HISTORY
*     M Craig
*     Rajesh Patangya -- Modified for Release 12.0
************************************************************************/
PROCEDURE update_batch_resources(
  pbatch_id      IN  NUMBER,
  pstep_id       IN  NUMBER_TBL_TYPE,
  pact_res_id    IN  NUMBER_TBL_TYPE,
  pres_usage     IN  NUMBER_TBL_TYPE,
  presource_id   IN  NUMBER_TBL_TYPE,
  psetup_id      IN  NUMBER_TBL_TYPE,
  pstart_date    IN  NUMBER_TBL_TYPE,
  pend_date      IN  NUMBER_TBL_TYPE,
  plast_update   IN  NUMBER_TBL_TYPE,
  pseq_dep_usage IN  NUMBER_TBL_TYPE,
  phorizon       IN  NUMBER,
  puom_hour      IN  VARCHAR2,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  pres_rows      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER,
  pnew_act_res   IN OUT NOCOPY NUMBER_TBL_TYPE)

IS

  v_batch_id        NUMBER ;
  v_act_resource_id NUMBER ;
  v_resource_id     NUMBER ;
  v_step_id         NUMBER ;
  v_start_date      DATE;
  v_end_date        DATE;
  v_setup_id        NUMBER;
  last_update_date  DATE;
  v_res_usage       NUMBER ;
  v_seq_dep_usage   NUMBER;
  v_step_act_id     NUMBER;
  v_in_step_res_row gme_batch_step_resources%ROWTYPE;  /* Added for NOCOPY */
  v_step_res_row    gme_batch_step_resources%ROWTYPE;

  CURSOR validate_step_resource IS
    SELECT
      gsr.organization_id,
      gsr.last_update_date,
      gbs.step_status,
      gsr.resources,
      crd.resources,
      gsr.usage_um,
      gsr.batchstep_activity_id
    FROM
      gme_batch_steps gbs,
      gme_batch_step_resources gsr,
      cr_rsrc_dtl crd
    WHERE
          gbs.batchstep_id = v_step_id
      AND gbs.batchstep_id = gsr.batchstep_id
      AND gsr.batchstep_resource_id = v_act_resource_id
      AND crd.resource_id = v_resource_id
      AND crd.organization_id = gsr.organization_id ;

  v_activity_id      NUMBER;
  v_organization_id  NUMBER;
  v_resources        VARCHAR2(16);
  v_step_resource_id NUMBER ;

  CURSOR validate_alt_resource IS
    SELECT
      gsr.batchstep_resource_id
    FROM
      gme_batch_step_resources gsr
    WHERE
          gsr.batchstep_activity_id = v_activity_id
      AND gsr.resources = v_resources
      AND gsr.organization_id = v_organization_id;

  v_last_update_date DATE;
  v_step_status      NUMBER;
  v_o_resources      VARCHAR2(16);
  v_n_resources      VARCHAR2(16);
  v_uom_code         VARCHAR2(4);
  row_cnt            NUMBER;

BEGIN

  return_status     := 0;
  v_act_resource_id := 0;
  v_resource_id     := 0;
  v_step_id         := 0;
  v_setup_id        := 0;
  v_res_usage       := 0;
  v_seq_dep_usage   := 0;
  v_step_act_id     := 0;

  v_activity_id      := 0;
  v_resources        := NULL;
  v_step_resource_id := 0 ;

  v_step_status      := 0;
  row_cnt            := 0;
  v_batch_id             := pbatch_id;

  -- Rajesh Patangya, Changed for R12.0
  gme_common_pvt.set_timestamp ;
  gme_common_pvt.g_timestamp  := sysdate ;
  gme_common_pvt.g_user_ident := puser_id;
  gme_common_pvt.g_login_id   := plogin_id;

  FOR i IN 1..pres_rows LOOP
    v_act_resource_id := pact_res_id(i);
    v_in_step_res_row.batchstep_resource_id := -1;
    v_step_id := pstep_id(i);
    v_resource_id := presource_id(i);
    v_res_usage := pres_usage(i)/60;

    OPEN validate_step_resource;
    FETCH validate_step_resource INTO v_organization_id, v_last_update_date,
       v_step_status,v_o_resources, v_n_resources, v_uom_code, v_step_act_id;

    IF validate_step_resource%NOTFOUND THEN
      return_status := -1;
    ELSIF v_step_status > 1 THEN
      return_status := -2;
    ELSE
      last_update_date := wip_datetimes.float_to_DT(plast_update(i)/1440+phorizon+1);
      IF v_last_update_date > last_update_date THEN
        return_status := -3;
      ELSE
        v_start_date := wip_datetimes.float_to_DT(pstart_date(i)/1440+phorizon);
        v_end_date := wip_datetimes.float_to_DT(pend_date(i)/1440+phorizon);
        v_seq_dep_usage :=
                inv_convert.inv_um_convert(-1,38,(pseq_dep_usage(i)/60),puom_hour,
                v_uom_code,NULL,NULL);

        IF v_o_resources = v_n_resources THEN
          pnew_act_res(i) := pact_res_id(i);

          UPDATE
            gme_batch_step_resources
          SET
            plan_start_date = v_start_date,
            plan_cmplt_date = v_end_date,
            sequence_dependent_usage = v_seq_dep_usage,
            last_update_date = SYSDATE,
            last_updated_by = puser_id
          WHERE
            batchstep_resource_id = v_act_resource_id;

          IF SQL%NOTFOUND THEN
            return_status := -4;
          ELSE
            row_cnt := row_cnt + 1;
          END IF;
        ELSE

          v_resources := v_n_resources;
          v_activity_id := v_step_act_id;
          OPEN validate_alt_resource;
          FETCH validate_alt_resource INTO v_step_resource_id;

          IF validate_alt_resource%FOUND THEN
            return_status := -8;
          ELSE
            v_in_step_res_row.batchstep_resource_id := v_act_resource_id;
            IF NOT GME_BATCH_STEP_RESOURCES_DBL.fetch_row(v_in_step_res_row,
               v_step_res_row) THEN
              return_status := -5;
            ELSE

              DELETE
                gme_batch_step_resources
              WHERE
                batchstep_resource_id = v_act_resource_id;

              IF SQL%NOTFOUND THEN
                return_status := -6;
              ELSE

                v_step_res_row.plan_start_date := v_start_date;
                v_step_res_row.plan_cmplt_date := v_end_date;
                v_step_res_row.resources := v_n_resources;
                v_step_res_row.sequence_dependent_usage := v_seq_dep_usage;
                v_step_res_row.plan_rsrc_usage :=
                  inv_convert.inv_um_convert(-1,38,v_res_usage,puom_hour,
                  v_uom_code,NULL,NULL);

                IF NOT GME_BATCH_STEP_RESOURCES_DBL.insert_row
                  (v_step_res_row, v_in_step_res_row) THEN
                  return_status := -7;
                ELSE
                  pnew_act_res(i) := v_in_step_res_row.batchstep_resource_id;
                  row_cnt := row_cnt + 1;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;

    CLOSE validate_step_resource;

    EXIT WHEN return_status < 0;

   /* delete all resource transactions for current step resource */
    DELETE
      gme_resource_txns
    WHERE
          doc_id = v_batch_id
      AND line_id = v_act_resource_id
      AND doc_type = v_doc_prod
      AND organization_id = v_organization_id
      AND completed_ind = 0;

  END LOOP;

  IF return_status >= 0 THEN
    return_status := row_cnt;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
      return_status := -96;
      log_message('Failure occured during Batch Step Resources Update: '
        || pbatch_id);
      log_message(sqlerrm);

END update_batch_resources;

/***********************************************************************
*
*   NAME
*     update_operation_resources
*
*   DESCRIPTION
*     This procedure will update the batch step activities, resource and
*     resource transactions from the operation resource. Sequence
*     dependent usage and transactions are included
*   HISTORY
*     M Craig
*     Rajesh Patangya -- Modified for Release 12.0
************************************************************************/
PROCEDURE update_operation_resources(
  pbatch_id       IN  NUMBER,
  pactivity_id    IN  NUMBER,
  pact_start_date IN  NUMBER,
  pact_end_date   IN  NUMBER,
  pact_last_update IN  NUMBER,
  pstep_id        IN  NUMBER_TBL_TYPE,
  pact_res_id     IN  NUMBER_TBL_TYPE,
  presource_id    IN  NUMBER_TBL_TYPE,
  presource_usage IN  NUMBER_TBL_TYPE,
  psetup_id       IN  NUMBER_TBL_TYPE,
  pres_start_date IN  NUMBER_TBL_TYPE,
  pres_end_date   IN  NUMBER_TBL_TYPE,
  plast_update    IN  NUMBER_TBL_TYPE,
  pseq_dep_usage  IN  NUMBER_TBL_TYPE,
  ptrn_act_res_id IN  NUMBER_TBL_TYPE,
  ptrn_resource_id IN  NUMBER_TBL_TYPE,
  ptrn_rsrc_count IN  NUMBER_TBL_TYPE,
  ptrn_seq_dep    IN  NUMBER_TBL_TYPE,
  ptrn_start_date IN  NUMBER_TBL_TYPE,
  ptrn_end_date   IN  NUMBER_TBL_TYPE,
  ptrn_instance_id IN  NUMBER_TBL_TYPE,
  phorizon        IN  NUMBER,
  puom_hour       IN  VARCHAR2,
  puser_id        IN  NUMBER,
  plogin_id       IN  NUMBER,
  pres_rows       IN  NUMBER,
  ptrn_rows       IN  NUMBER,
  return_status   OUT NOCOPY NUMBER)

IS

  areturn_status NUMBER;
  rreturn_status NUMBER;
  treturn_status NUMBER;
  v_step_id      NUMBER;
  new_act_res    NUMBER_TBL_TYPE;

BEGIN

  areturn_status := 0;
  rreturn_status := 0;
  treturn_status := 0;
  v_step_id      := 0;
  return_status  := 0;

  v_step_id := pstep_id(1);
  update_batch_activities(
    pbatch_id,
    v_step_id,
    pactivity_id,
    pact_start_date,
    pact_end_date,
    pact_last_update,
    phorizon,
    puom_hour,
    puser_id,
    plogin_id,
    areturn_status);

  IF areturn_status < 1 THEN
    return_status := -1;
  ELSE

    update_batch_resources(
      pbatch_id,
      pstep_id,
      pact_res_id,
      presource_usage,
      presource_id,
      psetup_id,
      pres_start_date,
      pres_end_date,
      plast_update,
      pseq_dep_usage,
      phorizon,
      puom_hour,
      puser_id,
      plogin_id,
      pres_rows,
      rreturn_status,
      new_act_res);

    IF rreturn_status < 1 THEN
      return_status := -2;
    ELSE

      update_resource_transactions(
        pbatch_id,
        ptrn_act_res_id,
        ptrn_resource_id,
        ptrn_instance_id,
        ptrn_rsrc_count,
        ptrn_seq_dep,
        ptrn_start_date,
        ptrn_end_date,
        phorizon,
        puom_hour,
        puser_id,
        plogin_id,
        pres_rows,
        ptrn_rows,
        treturn_status,
        pact_res_id,
        new_act_res);

      IF treturn_status < 1 THEN
        return_status := -3;
      ELSE
        return_status := areturn_status + rreturn_status + treturn_status;
      END IF;
    END IF;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      return_status := -95;
      log_message('Failure occured during Operation Resource Update: '
        || pbatch_id);
      log_message(sqlerrm);

END update_operation_resources;

/***********************************************************************
*
*   NAME
*     update_resource_transactions
*
*   DESCRIPTION
*     This procedure will update batch resource instance transactions
*     once the WPS scheduling engine has completed.
*   HISTORY
*     M Craig
*     Rajesh Patangya -- Modified for Release 12.0
************************************************************************/
PROCEDURE update_resource_transactions(
  pbatch_id      IN  NUMBER,
  pact_res_id    IN  NUMBER_TBL_TYPE,
  presource_id   IN  NUMBER_TBL_TYPE,
  pinstance_id   IN  NUMBER_TBL_TYPE,
  prsrc_count    IN  NUMBER_TBL_TYPE,
  pseq_dep_ind   IN  NUMBER_TBL_TYPE,
  pstart_date    IN  NUMBER_TBL_TYPE,
  pend_date      IN  NUMBER_TBL_TYPE,
  phorizon       IN  NUMBER,
  puom_hour      IN  VARCHAR2,
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  pres_rows      IN  NUMBER,
  ptrn_rows      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER,
  porig_act_res  IN  NUMBER_TBL_TYPE,
  pnew_act_res   IN  NUMBER_TBL_TYPE)

IS

  v_batch_id        NUMBER;
  v_resource_id     NUMBER;
  v_act_resource_id NUMBER;
  v_start_date      DATE;
  v_end_date        DATE;
  v_res_usage       NUMBER;
  temp_date         NUMBER;
  row_cnt           NUMBER;
  v_in_trans_row    gme_resource_txns%ROWTYPE;   /* Added for NOCOPY */
  v_trans_row       gme_resource_txns%ROWTYPE;

  CURSOR validate_resource IS
    SELECT
      crd.schedule_ind,
      crd.resources,
      gsr.usage_um,
      gbh.ORGANIZATION_ID
    FROM
      cr_rsrc_dtl crd,
      gme_batch_step_resources gsr,
      gme_batch_header gbh
    WHERE
          crd.resource_id = v_resource_id
      AND crd.delete_mark = 0
      AND gsr.batchstep_resource_id = v_act_resource_id
      AND gbh.batch_id = v_batch_id
      AND gbh.ORGANIZATION_ID = gsr.ORGANIZATION_ID
      AND crd.ORGANIZATION_ID = gsr.ORGANIZATION_ID;

  v_resources       VARCHAR2(16);
  v_schedule_ind    NUMBER;
  v_uom_code        VARCHAR2(3);
  v_ORGANIZATION_ID NUMBER;

BEGIN

  return_status     := 0;
  v_batch_id        := 0;
  v_resource_id     := 0;
  v_act_resource_id := 0;
  v_res_usage       := 0;
  temp_date         := 0;
  row_cnt           := 0;

  v_schedule_ind := 0;
  v_batch_id := pbatch_id;

  FOR i IN 1..ptrn_rows LOOP
    v_resource_id := presource_id(i);

    v_act_resource_id := -1;
    FOR k IN 1..pres_rows LOOP
      IF porig_act_res(k) = pact_res_id(i) THEN
         v_act_resource_id := pnew_act_res(k);
      END IF;
      EXIT WHEN porig_act_res(k) = pact_res_id(i);
    END LOOP;

    OPEN validate_resource;
    FETCH validate_resource INTO v_schedule_ind, v_resources, v_uom_code,
      v_ORGANIZATION_ID;

    IF validate_resource%NOTFOUND THEN
      return_status := -1;
    ELSE
      temp_date := (pend_date(i) - pstart_date(i))/60;
      v_res_usage := inv_convert.inv_um_convert(-1,38,temp_date,
        puom_hour,v_uom_code,NULL,NULL);
      v_start_date := wip_datetimes.float_to_DT(pstart_date(i)/1440+phorizon);
      v_end_date := wip_datetimes.float_to_DT(pend_date(i)/1440+phorizon);

      v_in_trans_row.line_id := v_act_resource_id;
      v_in_trans_row.ORGANIZATION_ID := v_ORGANIZATION_ID;   -- For R12.0
      v_in_trans_row.doc_type := v_doc_prod;
      v_in_trans_row.doc_id := v_batch_id;
      v_in_trans_row.line_type := 0;
      v_in_trans_row.resources := v_resources;
      v_in_trans_row.resource_usage := v_res_usage;
      v_in_trans_row.TRANS_QTY_UM := v_uom_code;    -- For R12.0
      v_in_trans_row.trans_date := SYSDATE;
      v_in_trans_row.completed_ind := 0;
      v_in_trans_row.posted_ind := 0;
      v_in_trans_row.overrided_protected_ind := 'N';
      v_in_trans_row.start_date := v_start_date;
      v_in_trans_row.end_date := v_end_date;
      v_in_trans_row.creation_date := SYSDATE;
      v_in_trans_row.last_update_date := SYSDATE;
      v_in_trans_row.created_by := puser_id;
      v_in_trans_row.last_updated_by := puser_id;
      v_in_trans_row.last_update_login := plogin_id;
      v_in_trans_row.delete_mark := 0;
      v_in_trans_row.sequence_dependent_ind := pseq_dep_ind(i);
      v_in_trans_row.instance_id := pinstance_id(i);
      IF v_in_trans_row.instance_id = 0 OR v_in_trans_row.instance_id = -1 THEN
        v_in_trans_row.instance_id := NULL;
      END IF;

      gme_common_pvt.set_timestamp ;
      gme_common_pvt.g_timestamp   := sysdate ;
      gme_common_pvt.g_user_ident  := puser_id;
      gme_common_pvt.g_login_id    := plogin_id;

      FOR j IN 1..prsrc_count(i) LOOP
    -- This is not going to change For R12.0
        IF NOT gme_resource_txns_dbl.insert_row
                  (v_in_trans_row, v_trans_row) THEN
          return_status := -2;
          EXIT;
        ELSE
          row_cnt := row_cnt + 1;
        END IF;
      END LOOP;
    END IF;

    CLOSE validate_resource;
    EXIT WHEN return_status < 0;

  END LOOP;

  IF return_status >= 0 THEN
    return_status := row_cnt;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      return_status := -94;
      log_message('Failure occured during Resource Transaction Insert: '
        || pbatch_id);
      log_message(sqlerrm);

END update_resource_transactions;

/***********************************************************************
*
*   NAME
*     lock_batch_details
*
*   DESCRIPTION
*     This procedure will select for update all of the batch details
*     except for the transactions.
*   HISTORY
*     M Craig
*     Rajesh Patangya -- Modified for Release 12.0
************************************************************************/
PROCEDURE lock_batch_details(
  pbatch_id IN NUMBER,
  return_status OUT NOCOPY NUMBER)

IS

  l_batch_id NUMBER;
  v_batch_id NUMBER;
  found      NUMBER;

  /* lock the batch header being updated */
  CURSOR lock_batch_header IS
    SELECT
      batch_id
    FROM
      gme_batch_header
    WHERE
      batch_id = v_batch_id
    FOR UPDATE NOWAIT;

  /* lock all of the batch steps for update */
  CURSOR lock_batch_steps IS
    SELECT
      batch_id
    FROM
      gme_batch_steps
    WHERE
      batch_id = v_batch_id
    FOR UPDATE NOWAIT;

  /* lock all of the batch step activities for update */
  CURSOR lock_batch_activities IS
    SELECT
      batch_id
    FROM
      gme_batch_step_activities
    WHERE
      batch_id = v_batch_id
    FOR UPDATE NOWAIT;

  /* lock all of the batch step resources for update */
  CURSOR lock_batch_resources IS
    SELECT
      batch_id
    FROM
      gme_batch_step_resources
    WHERE
      batch_id = v_batch_id
    FOR UPDATE NOWAIT;

BEGIN

  return_status := 0;
  l_batch_id    := 0;
  found         := 0;

  v_batch_id := pbatch_id;

  OPEN lock_batch_header;
  LOOP
    FETCH lock_batch_header INTO l_batch_id;
    EXIT WHEN lock_batch_header%NOTFOUND;
    found := 1;
  END LOOP;
  CLOSE lock_batch_header;
  IF found = 0 THEN
    return_status := -1;
  ELSE
    found := 0;
    OPEN lock_batch_steps;
    LOOP
      FETCH lock_batch_steps INTO l_batch_id;
      EXIT WHEN lock_batch_steps%NOTFOUND;
      found := 1;
    END LOOP;
    CLOSE lock_batch_steps;
    IF found = 0 THEN
      return_status := -1;
    ELSE
      found := 0;
      OPEN lock_batch_activities;
      LOOP
        FETCH lock_batch_activities INTO l_batch_id;
        EXIT WHEN lock_batch_activities%NOTFOUND;
        found := 1;
      END LOOP;
      CLOSE lock_batch_activities;
      IF found = 0 THEN
        return_status := -1;
      ELSE
        found := 0;
        OPEN lock_batch_resources;
        LOOP
           FETCH lock_batch_resources INTO l_batch_id;
           EXIT WHEN lock_batch_resources%NOTFOUND;
            found := 1;
        END LOOP;
        CLOSE lock_batch_resources;
        IF found = 0 THEN
          return_status := -1;
        END IF;
      END IF;
    END IF;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        return_status := -1;
        log_message('Failure occured during Lock of Production Batch Details: '
          || pbatch_id);
        log_message(sqlerrm);

END lock_batch_details;

/***********************************************************************
*
*   NAME
*     log_message
*
*   DESCRIPTION
*     This procedure will print the the string passed to it
*   HISTORY
*     Rajesh Patangya
************************************************************************/
PROCEDURE log_message(
  pbuff  VARCHAR2)
IS
BEGIN
  IF v_cp_enabled THEN
    fnd_file.put_line(fnd_file.log, pbuff);
  ELSE
     /* Bug# 1374205 - Commented the statement dbms_output.put_line - 08/07/00
        Uncomment the Following statement for Debugging Purposes */
    NULL;
  END IF;
END log_message;

/*+==========================================================================+
| FUNCTION NAME
|   get_wps_atr
|
| USAGE
|    Return ATR quantity at org, item level using Item tree
|
| ARGUMENTS
| p_api_version API Version of this procedure. Current version is 1.0
| p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to
| determine whether to Initialize message list or not
| x_return_status Returns the status to indicate success or failure of execution
| x_msg_count Returns number of error message in the error message stack in
| case of failure
| x_msg_data Returns the error message in case of failure
|
| RETURNS
|   returns via x_ OUT
|
| HISTORY
|   Created  11-Jul-2005 Rajesh Patangya
+==========================================================================+ */
FUNCTION get_wps_atr(
      p_organization_id       IN  NUMBER,
      p_inventory_item_id     IN  NUMBER ) RETURN NUMBER IS

      p_demand_source_type_id   NUMBER ;
      p_tree_mode               INTEGER ;
      p_api_version_number      NUMBER ;
      p_init_msg_lst            VARCHAR2(2000) ;
      p_is_serial_control       BOOLEAN;
      p_demand_source_header_id NUMBER ;
      p_demand_source_line_id   NUMBER ;
      p_demand_source_name      VARCHAR2(50) ;
      p_lot_expiration_date     DATE ;
      l_api_name     CONSTANT   VARCHAR2 (30) := 'QUERY_QUANTITIES';
      l_is_revision_control     BOOLEAN;
      l_is_lot_control          BOOLEAN;
      x_return_status           VARCHAR2(1) ;
      p_onhand_source           NUMBER ;
      p_grade_code              VARCHAR2(150);
      p_revision                VARCHAR2(30);
      p_lot_number              VARCHAR2(80);
      p_subinventory_code       VARCHAR2(30);
      p_locator_id              NUMBER ;
      x_qoh                     NUMBER ;
      x_rqoh                    NUMBER ;
      x_qr                      NUMBER ;
      x_qs                      NUMBER ;
      x_att                     NUMBER ;
      x_atr                     NUMBER ;
      x_sqoh                    NUMBER ;
      x_srqoh                   NUMBER ;
      x_sqr                     NUMBER ;
      x_sqs                     NUMBER ;
      x_satt                    NUMBER ;
      x_satr                    NUMBER ;
      X_msg_data                VARCHAR2(2000);
      x_msg_count               NUMBER(5);
      p_cost_group_id           NUMBER;
      p_transfer_locator_id     NUMBER;
      p_lpn_id                  NUMBER;
      p_transfer_subinventory_code VARCHAR2(30);

   BEGIN
      p_lpn_id                := NULL;
      p_transfer_locator_id   := NULL;
      p_cost_group_id         := NULL;
      p_transfer_subinventory_code := NULL;
      p_demand_source_type_id := gme_common_pvt.g_txn_source_type ;
      X_msg_data              := NULL;
      x_msg_count             := NULL;
      x_return_status         := fnd_api.g_ret_sts_success;
      p_api_version_number    := 1 ;
      p_init_msg_lst          := fnd_api.g_false ;
      p_tree_mode             := 1 ;   -- for Reservations
      p_is_serial_control     := FALSE;

      p_demand_source_header_id  := -9999 ;
      p_demand_source_line_id    := -9999 ;
      p_demand_source_name       := NULL ;
      p_lot_expiration_date      := NULL ;

      l_is_revision_control := FALSE;
      l_is_lot_control      := FALSE;
      p_onhand_source       := inv_quantity_tree_pvt.g_all_subs ;
      p_grade_code          := NULL;
      p_transfer_subinventory_code := NULL;
      p_cost_group_id              := NULL;
      p_lpn_id                     := NULL;
      p_transfer_locator_id        := NULL;
      p_revision              := NULL;
      p_lot_number            := NULL;
      p_subinventory_code     := NULL;
      p_locator_id            := NULL;

      inv_quantity_tree_pub.query_quantities
            (p_api_version_number              => p_api_version_number
            ,p_init_msg_lst                    => p_init_msg_lst
            ,x_return_status                   => x_return_status
            ,x_msg_count                       => x_msg_count
            ,x_msg_data                        => x_msg_data
            ,p_organization_id                 => p_organization_id
            ,p_inventory_item_id               => p_inventory_item_id
            ,p_tree_mode                       => p_tree_mode
            ,p_is_revision_control             => l_is_revision_control
            ,p_is_lot_control                  => l_is_lot_control
            ,p_is_serial_control               => p_is_serial_control
            ,p_grade_code                      => p_grade_code
            ,p_demand_source_type_id           => p_demand_source_type_id
            ,p_demand_source_header_id         => p_demand_source_header_id
            ,p_demand_source_line_id           => p_demand_source_line_id
            ,p_demand_source_name              => p_demand_source_name
            ,p_lot_expiration_date             => p_lot_expiration_date
            ,p_revision                        => p_revision
            ,p_lot_number                      => p_lot_number
            ,p_subinventory_code               => p_subinventory_code
            ,p_locator_id                      => p_locator_id
            ,p_onhand_source                   => p_onhand_source
            ,x_qoh                             => x_qoh
            ,x_rqoh                            => x_rqoh
            ,x_qr                              => x_qr
            ,x_qs                              => x_qs
            ,x_att                             => x_att
            ,x_atr                             => x_atr
            ,x_sqoh                            => x_sqoh
            ,x_srqoh                           => x_srqoh
            ,x_sqr                             => x_sqr
            ,x_sqs                             => x_sqs
            ,x_satt                            => x_satt
            ,x_satr                            => x_satr
            ,p_transfer_subinventory_code      => p_transfer_subinventory_code
            ,p_cost_group_id                   => p_cost_group_id
            ,p_lpn_id                          => p_lpn_id
            ,p_transfer_locator_id             => p_transfer_locator_id);

   RETURN x_atr ;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
         RETURN -1;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
         RETURN -2;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
         RETURN -3;
END get_wps_atr;


/*+==========================================================================+
| FUNCTION NAME
|   get_wps_onhand
|
| USAGE
|    Return onhand quantity at org, item level using Item tree
|
| ARGUMENTS
| p_api_version API Version of this procedure. Current version is 1.0
| p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to
| determine whether to Initialize message list or not
| x_return_status Returns the status to indicate success or failure of execution
| x_msg_count Returns number of error message in the error message stack in
| case of failure
| x_msg_data Returns the error message in case of failure
|
| RETURNS
|   returns via x_ OUT
|
| HISTORY
|   Created  02-Aug-2005 Rajesh Patangya
+==========================================================================+ */
FUNCTION get_wps_onhand(
      p_organization_id       IN  NUMBER,
      p_inventory_item_id     IN  NUMBER ) RETURN NUMBER IS

      p_demand_source_type_id   NUMBER ;
      p_tree_mode               INTEGER ;
      p_api_version_number      NUMBER ;
      p_init_msg_lst            VARCHAR2(2000) ;
      p_is_serial_control       BOOLEAN;
      p_demand_source_header_id NUMBER ;
      p_demand_source_line_id   NUMBER ;
      p_demand_source_name      VARCHAR2(50) ;
      p_lot_expiration_date     DATE ;
      l_api_name     CONSTANT   VARCHAR2 (30) := 'QUERY_QUANTITIES';
      l_is_revision_control     BOOLEAN;
      l_is_lot_control          BOOLEAN;
      x_return_status           VARCHAR2(1) ;
      p_onhand_source           NUMBER ;
      p_grade_code              VARCHAR2(150);
      p_revision                VARCHAR2(30);
      p_lot_number              VARCHAR2(80);
      p_subinventory_code       VARCHAR2(30);
      p_locator_id              NUMBER ;
      x_qoh                     NUMBER ;
      x_rqoh                    NUMBER ;
      x_qr                      NUMBER ;
      x_qs                      NUMBER ;
      x_att                     NUMBER ;
      x_atr                     NUMBER ;
      x_sqoh                    NUMBER ;
      x_srqoh                   NUMBER ;
      x_sqr                     NUMBER ;
      x_sqs                     NUMBER ;
      x_satt                    NUMBER ;
      x_satr                    NUMBER ;
      X_msg_data                VARCHAR2(2000);
      x_msg_count               NUMBER(5);
      p_cost_group_id           NUMBER;
      p_transfer_locator_id     NUMBER;
      p_lpn_id                  NUMBER;
      p_transfer_subinventory_code VARCHAR2(30);
	TYPE gmp_cursor_typ IS REF CURSOR;
	cur_get_onhand	  gmp_cursor_typ;


   BEGIN
-- synonyms used in this program
--     qoh          quantity on hand
--     rqoh         reservable quantity on hand
--     qr           quantity reserved
--     qs           quantity suggested
--     att          available to transact
--     atr          available to reserve
--    sqoh          secondary quantity on hand R12
--    srqoh         secondary reservable quantity on hand R12
--    sqr           secondary quantity reserved  R12
--    sqs           secondare quantity suggested  R12
--    satt          secondary available to transact R12
--    satr          secondary available to reserve R12

-----      p_lpn_id                := NULL;
-----      p_transfer_locator_id   := NULL;
-----      p_cost_group_id         := NULL;
-----      p_transfer_subinventory_code := NULL;
-----      p_demand_source_type_id := gme_common_pvt.g_txn_source_type ;
-----      X_msg_data              := NULL;
-----      x_msg_count             := NULL;
-----      x_return_status         := fnd_api.g_ret_sts_success;
-----      p_api_version_number    := 1 ;
-----      p_init_msg_lst          := fnd_api.g_false ;

      /* Transaction Mode will return on hand quantity and avaialble to transact
         quantity, This onhand quantity does not consider the material statuses,
         If material status controlled on hand is required, then select on hand
         quantity from here and select all the transactions to come up with the
         desired quantity e.g. if the onhand quantity  only for WIP issue
         enabled will not be returned from this tree */
      /* On hand = ATT + Reserved Quantity */
      /* The items shall be revision or serial or lot controlled */
      /* The items will be restricted to a particular subinventory or loactor */
      /* Subinventory and locator (stock locator) have master detail relationship */
      /* GME looks for most restrictive material status, i.e. if at any one level
       of material status is disallowed means it is disallowed, before allowing the
       item to be used in a batch */

-----      p_tree_mode             := 2 ;   -- in transaction Mode
-----      p_is_serial_control     := FALSE;
-----
-----      p_demand_source_header_id  := -9999 ;
-----      p_demand_source_line_id    := -9999 ;
-----      p_demand_source_name       := NULL ;
-----      p_lot_expiration_date      := NULL ;
-----
-----      l_is_revision_control := FALSE;
-----      l_is_lot_control      := FALSE;
-----      p_onhand_source       := inv_quantity_tree_pvt.g_all_subs ;
-----      p_grade_code          := NULL;
-----      p_transfer_subinventory_code := NULL;
-----      p_cost_group_id              := NULL;
-----      p_lpn_id                     := NULL;
-----      p_transfer_locator_id        := NULL;
-----      p_revision              := NULL;
-----      p_lot_number            := NULL;
-----      p_subinventory_code     := NULL;
-----      p_locator_id            := NULL;
-----
-----      inv_quantity_tree_pub.query_quantities
-----            (p_api_version_number              => p_api_version_number
-----            ,p_init_msg_lst                    => p_init_msg_lst
-----            ,x_return_status                   => x_return_status
-----            ,x_msg_count                       => x_msg_count
-----            ,x_msg_data                        => x_msg_data
-----            ,p_organization_id                 => p_organization_id
-----            ,p_inventory_item_id               => p_inventory_item_id
-----            ,p_tree_mode                       => p_tree_mode
-----            ,p_is_revision_control             => l_is_revision_control
-----            ,p_is_lot_control                  => l_is_lot_control
-----            ,p_is_serial_control               => p_is_serial_control
-----            ,p_grade_code                      => p_grade_code
-----            ,p_demand_source_type_id           => p_demand_source_type_id
-----            ,p_demand_source_header_id         => p_demand_source_header_id
-----            ,p_demand_source_line_id           => p_demand_source_line_id
-----            ,p_demand_source_name              => p_demand_source_name
-----            ,p_lot_expiration_date             => p_lot_expiration_date
-----            ,p_revision                        => p_revision
-----            ,p_lot_number                      => p_lot_number
-----            ,p_subinventory_code               => p_subinventory_code
-----            ,p_locator_id                      => p_locator_id
-----            ,p_onhand_source                   => p_onhand_source
-----            ,x_qoh                             => x_qoh
-----            ,x_rqoh                            => x_rqoh
-----            ,x_qr                              => x_qr
-----            ,x_qs                              => x_qs
-----            ,x_att                             => x_att
-----            ,x_atr                             => x_atr
-----            ,x_sqoh                            => x_sqoh
-----            ,x_srqoh                           => x_srqoh
-----            ,x_sqr                             => x_sqr
-----            ,x_sqs                             => x_sqs
-----            ,x_satt                            => x_satt
-----            ,x_satr                            => x_satr
-----            ,p_transfer_subinventory_code      => p_transfer_subinventory_code
-----            ,p_cost_group_id                   => p_cost_group_id
-----            ,p_lpn_id                          => p_lpn_id
-----            ,p_transfer_locator_id             => p_transfer_locator_id);
-----
	OPEN cur_get_onhand FOR
	SELECT sum(quantity)
	FROM gmp_nettable_onhands_v
	WHERE organization_id = p_organization_id
	AND inventory_item_id = p_inventory_item_id ;

	FETCH  cur_get_onhand into x_qoh ;

	CLOSE cur_get_onhand ;

   RETURN x_qoh ;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
         RETURN -1;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
         RETURN -2;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
         RETURN -3;
END get_wps_onhand;

END;

/
