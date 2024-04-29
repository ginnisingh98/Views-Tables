--------------------------------------------------------
--  DDL for Package Body GMP_APS_WRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_APS_WRITER" AS
/* $Header: GMPAPSWB.pls 120.15.12010000.4 2009/07/02 06:39:33 vpedarla ship $ */

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    main_process                                                          |
REM| DESCRIPTION                                                              |
REM|    This procedure will update all the information related to a batch     |
REM|    1. This procedure will be called from GMPAPSNW/RS screen.             |
REM|    2. Materail transactions are calculated by OPM(GME logic)             |
REM|                                                                          |
REM| PARAMETERS                                                               |
REM|  p_batch_id    - Batch ID                                                |
REM|  p_group_id    - Group ID                                                |
REM|  p_header_id   - Header ID                                               |
REM|  p_start_date  - Batch Start Date                                        |
REM|  p_end_date    - Batch Start Date                                        |
REM|  p_required_completion - Batch Completion Date                           |
REM|  p_order_priority  - Batch Order Priority                                |
REM|  p_organization_id - Batch Organizaiton                                  |
REM|  p_eff_id      - Batch Validity Rule ID                                  |
REM|  p_action_type - Batch type (1 = New, 3 = Reschedule)                    |
REM|  p_creation_date - Batch Creation Date                                   |
REM|  p_user_id     - User ID                                                 |
REM|  p_login_id    - Application Login ID                                    |
REM|                                                                          |
REM| AUTHOR                                                                   |
REM|    R Patangya Created 25-MAY-2003                                        |
REM| HISTORY                                                                  |
REM|    Enhancements (APS K -- R12): 10-DEC-2004 (B3710615)                   |
REM| A. Do not plan Resources in place of secondary resources                 |
REM| NOTE                                                                     |
REM|  Hard Link, complex routs and MTQ deos not affect the detail feedback.   |
REM|                                                                          |
REM+==========================================================================+
*/
PROCEDURE main_process(
  p_batch_id             IN NUMBER,
  p_group_id             IN NUMBER,
  p_header_id            IN NUMBER,
  p_start_date           IN DATE,
  p_end_date             IN DATE,
  p_required_completion  IN DATE,     -- For R12.0
  p_order_priority       IN NUMBER,   -- For R12.0
  p_organization_id      IN NUMBER,   -- For R12.0
  p_eff_id               IN NUMBER,
  p_action_type          IN NUMBER,
  p_creation_date        IN DATE,
  p_user_id              IN NUMBER,
  p_login_id             IN NUMBER,
  return_msg             OUT NOCOPY VARCHAR2,
  return_status          OUT NOCOPY NUMBER) IS

/* Local array definition */
TYPE ref_cursor_typ IS REF CURSOR;

TYPE operations_typ IS RECORD
(
  batchstep_id              NUMBER(20),
  batchstep_no              NUMBER(10),
  oprn_id                   NUMBER(16),
  operation_seq_num         NUMBER(10),
  first_unit_start_date     DATE,
  last_unit_completion_date DATE,
  bo_last_update            NUMBER(20),
  step_status               NUMBER(4),
  aps_oper_count            NUMBER(10),
  gme_oper_count            NUMBER(10),
  max_step_date             DATE    -- B5473156
);
TYPE operations_tbl IS TABLE OF operations_typ INDEX by BINARY_INTEGER;
operation_tab   operations_tbl;
oper_cnt       INTEGER;  /* Number of rows in operations_cursor */

TYPE oper_rsrc_typ IS RECORD
(
  operation_seq_num       NUMBER(10),
  schedule_seq_num        NUMBER(10),    -- For R12.0
  resource_seq_num        NUMBER(20),
  batchstep_id            NUMBER(20),
  organization_id         NUMBER(20),    -- For R12.0
  batchstep_activity_id   NUMBER(20),
  batchstep_resource_id   NUMBER(20),
  activity                VARCHAR2(25),
  aps_resource            VARCHAR2(20),
  aps_resource_id         NUMBER(20),
  gme_resource            VARCHAR2(20),
  aps_uom_code            VARCHAR2(3),
  gme_uom_code            VARCHAR2(3),
  assigned_units          NUMBER,
  plan_rsrc_count         NUMBER,
  plan_rsrc_usage         NUMBER,
  sequence_dependent_usage NUMBER,   -- For R12.0
  start_date              DATE,
  completion_date         DATE,
  act_start_date          DATE,
  act_end_date            DATE,
  aps_rsrc_usage          NUMBER,
  aps_charges             NUMBER,    -- For R12.0
  scale_type              NUMBER,    -- For R12.0
  aps_data_use            NUMBER,
  Aoperation_seq_num      NUMBER(20),
  Aschedule_seq_num       NUMBER(20),    -- For R12.0
  bsa_lup                 NUMBER(20),
  bsr_lup                 NUMBER(20),
  gme_actv_count          NUMBER(10),
  aps_actv_count          NUMBER(10),
  gme_rsrc_count          NUMBER(10),
  aps_rsrc_count          NUMBER(10),
  setup_id                NUMBER,     -- For R12.0
  group_sequence_id       NUMBER,     -- For R12.0
  group_sequence_number   NUMBER,     -- For R12.0
  firm_flag               NUMBER ,     -- For R12.0
  Product_item            NUMBER  -- Bug: 8616967 Vpedarla
);
TYPE oper_rsrc_tbl IS TABLE OF oper_rsrc_typ INDEX by BINARY_INTEGER;
or_tab     oper_rsrc_tbl;
or_cnt     INTEGER;  /* Number of rows in oper_rsrc cursor */

TYPE activity_typ IS RECORD
(
  organization_id         NUMBER(20),    -- For R12.0
  batchstep_id            NUMBER(20),
  batchstep_activity_id   NUMBER(20),
  start_date              DATE,
  end_date                DATE,
  uom_code                VARCHAR2(3),
  operation_seq_num       NUMBER(20),
  schedule_seq_num        NUMBER(20),       -- For R12.0
  resource_seq_num        NUMBER(20)
);
TYPE activity_tbl IS TABLE OF activity_typ INDEX by BINARY_INTEGER;
act_tab     activity_tbl;
act_cnt     INTEGER;  /* Number of rows in activity cursor */

TYPE rsrc_tran_typ IS RECORD
(
  batchstep_resource_id   NUMBER(20),
  organization_id         NUMBER(20),     -- For R12.0
  operation_seq_num       NUMBER(20),
  schedule_seq_num        NUMBER(20),     -- For R12.0
  resource_seq_num        NUMBER(20),
  parent_seq_num          NUMBER(20),     -- For R12.0
  aps_resource_id         NUMBER(20),
  aps_resource            VARCHAR2(32),
  aps_uom_code            VARCHAR2(3),    -- For R12.0
  assigned_units          NUMBER,
  resource_hour           NUMBER,
  start_date              DATE,
  completion_date         DATE,
  resource_instance_id    NUMBER ,  -- For R12.0
  gme_usage_uom           VARCHAR2(3),  --Bug: 8616967 Vpedarla
  Product_item            NUMBER   --Bug: 8616967 Vpedarla
);
TYPE rsrc_tran_tbl IS TABLE OF rsrc_tran_typ INDEX by BINARY_INTEGER;
rsrc_tran_tab  rsrc_tran_tbl;
rtran_cnt      INTEGER;  /* Number of rows in rsrc_tran cursor */

  cur_operations      ref_cursor_typ;
  cur_oper_rsrc       ref_cursor_typ;
  cur_rsrc_tran       ref_cursor_typ;
  operations_cursor   VARCHAR2(15000) ;
  oper_rsrc_cursor    VARCHAR2(30000) ;
  rsrc_tran_cursor    VARCHAR2(15000) ;

  i                 INTEGER ;
  j                 INTEGER ;
  k                 INTEGER ;
  l                 INTEGER ;
  end_tran          NUMBER  ;
  batch_valid       NUMBER  ;
  new_batchstep_resource_id  NUMBER ;
  old_activity_id   NUMBER ;
  vreturn_status    NUMBER ;
  lreturn_status    NUMBER ;
  areturn_status    NUMBER ;
  breturn_status    NUMBER ;
  rreturn_status    NUMBER ;
  sreturn_status    NUMBER ;
  mreturn_status    NUMBER ;
  treturn_status    NUMBER ;
  xreturn_status    NUMBER ;
  t_batch_status    NUMBER ;
  t_struc_size      NUMBER ;
  batch_last_update DATE ;
  rsrc_cnt          NUMBER ;
  rsrc_usg          NUMBER ;
  t_due_date        DATE ;       -- For R12.0
  t_seq_dep_ind     NUMBER ;     -- For R12.0
  t_max_step_date   DATE ;
  t_firm_flag       NUMBER ;   -- B5897392

BEGIN
  log_message('Main Process called '||p_organization_id||p_batch_id||'**'||p_group_id||'**'||p_header_id||'**'||p_eff_id );
  /* Initialize all the variables */
  operations_cursor   := NULL;
  oper_rsrc_cursor    := NULL;
  rsrc_tran_cursor    := NULL;
  i            := 1;
  j            := 1;
  k            := 1;
  l            := 1;
  end_tran     := 0 ;
  batch_valid  := 0 ;
  new_batchstep_resource_id  := 0 ;
  batch_last_update := NULL ;
  rsrc_cnt          := 0 ;
  rsrc_usg          := 0 ;
  t_batch_status    := 0 ;
  t_struc_size      := 0 ;
  old_activity_id   := 0;
  vreturn_status    := -1 ;
  lreturn_status    := -1 ;
  areturn_status    := -1 ;
  breturn_status    := -1 ;
  rreturn_status    := -1 ;
  sreturn_status    := -1 ;
  mreturn_status    := -1 ;
  treturn_status    := -1 ;
  xreturn_status    := -1 ;
  t_due_date        := p_required_completion ;  -- For R12.0
  t_firm_flag       := 0 ;   -- B5897392

  -- find out the last collection
  orig_last_update_date := p_creation_date;

  -- Initialize message list
   fnd_msg_pub.initialize;

  /* Set the savepoint before proceeding */
   SAVEPOINT Before_Main_Program ;

  /* B5897392 get the firm_flag at header level */
  BEGIN
  SELECT firm_flag INTO t_firm_flag FROM gmp_aps_output_tbl
  WHERE batch_id = p_batch_id
    AND process_id = p_group_id
    AND header_id = p_header_id ;
  EXCEPTION
    WHEN OTHERS THEN
     gmp_debug_message(' gmp_aps_writer failed at firm_flag selection ');
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','main_process');
     e_msg := e_msg || ' Main Porgam Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
     return_status := -131 ;
     return_msg := e_msg ;
  END;

   IF p_action_type = 1 THEN
      -- For new batch validation
      gmp_debug_message(' Calling validate_structure for new batch');
      validate_structure (p_eff_id, p_organization_id, p_group_id, p_header_id,
                          t_struc_size, vreturn_status);
    log_message('After Validate ' || vreturn_status) ;
   ELSE
      vreturn_status := 0 ;
      -- For R12.0
      t_due_date := NULL ;   -- For reschdule batches this must be NULL
   END IF ;

   IF vreturn_status >= 0 THEN
      lock_batch_details(p_batch_id, t_batch_status,
                         batch_last_update, lreturn_status) ;  -- For R12.0
      log_message('After lock ' || lreturn_status) ;
   END IF ;   /* vreturned_status */

   IF lreturn_status >= 0 THEN

     IF (batch_last_update > orig_last_update_date) AND
        (p_action_type <> 1) THEN
        fnd_message.set_name('GMP','GMP_BATCH_HEADER_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Batch header is changed.';
        breturn_status := -1 ;
     ELSIF (p_start_date < sysdate AND p_action_type = 1) THEN
        fnd_message.set_name('GMP','GMP_BATCH_START_DATE_PAST_DUE');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' New Batch start date is past due.' ;
        breturn_status := -1 ;
     ELSIF (t_batch_status > 2 OR t_batch_status <= 0) AND
        (p_action_type <> 1) THEN
        fnd_message.set_name('GMP','GMP_BATCH_STATUS_NOT_PENDING');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Batch is not in pending.' ;
        breturn_status := -1 ;
     ELSE
      update_batch_header(
        p_batch_id,
        p_start_date,
        p_end_date,
        t_due_date,        -- For R12.0
        p_order_priority,  -- For R12.0
        t_batch_status,
        t_firm_flag,   -- B5897392
        p_user_id,
        p_login_id,
        breturn_status);
     END IF;
      log_message('After Batch Header'|| breturn_status);

    END IF ;   /* lreturn_status */

     -- In case of New batch APS provide operation/resource row
     -- if resource usage is ZERO
     -- But for reschedule batch No rows are provided by OPM and hence APS
        operations_cursor := ' SELECT '
        ||' nvl(gbs.batchstep_id,0),  '
        ||' gbs.batchstep_no, '
        ||' gbs.oprn_id,  '
        ||' gad.operation_seq_num,  '
        ||' gad.first_unit_start_date, '
        ||' gad.last_unit_completion_date, '
        ||' gbs.bo_last_update,  '
        ||' gbs.step_status , '
        ||' gad.oper_count, '
        ||' gbs.oper_count, '
        ||' gad.Max_Step '
        ||' FROM  '
        ||'   (  SELECT  '
        ||'      b.operation_seq_num,  '
        ||'      b.first_unit_start_date,  '
        ||'      b.last_unit_completion_date, '
        ||'      COUNT(distinct b.operation_seq_num) OVER (PARTITION BY '
        ||'      b.parent_header_id, b.group_id) oper_count , '
        ||'   max(b.last_unit_completion_date) OVER (PARTITION BY a.batch_id) Max_Step '
        ||'   FROM  gmp_aps_output_tbl a,'
        ||'         gmp_aps_output_dtl b '
        ||'   WHERE b.load_type = 3  '
        ||'     AND b.parent_header_id = a.header_id '
        ||'     AND b.group_id = a.process_id '
        ||'     AND b.organization_id = a.organization_id '  -- For R12.0
        ||'     AND a.process_id = :pgpr  '
        ||'     AND a.header_id = :phdr  '
        ||'   ) gad , '
        ||'   ( SELECT batchstep_id,  '
        ||'      batchstep_no,  '
        ||'      oprn_id,  '
        ||'      DECODE(sign(:lup '
        ||'      - last_update_date), 1,1,0,1,-1,-600) bo_last_update, '
        ||'      step_status , '
        ||'      COUNT(distinct batchstep_no)  '
        ||'      OVER (PARTITION BY batch_id) oper_count '
        ||'   FROM  gme_batch_steps   '
  -- B5714301, changed the position of operation count
  --    ||'   WHERE batch_id = :pbatch1 '
        ||'   WHERE batchstep_id IN ( select batchstep_id from gme_batch_steps '
        ||'          WHERE batch_id = :pbatch1 ) '
        ||'     AND step_status in (1,2) '
        ||'     AND delete_mark = 0 '
   --  B5473156, This check is not required as per scenario in the bug
   --   ||'     AND (plan_cmplt_date > plan_start_date OR :patype = 1 )'
        ||'   ) gbs '
        ||' WHERE gad.operation_seq_num = gbs.batchstep_no (+) '
        ||' ORDER BY gbs.batchstep_id, gad.operation_seq_num ' ;

gmp_debug_message(' operations_cursor -'||operations_cursor);

    oper_cnt  := 1 ;
    t_max_step_date := NULL ;
    IF breturn_status >= 0 THEN

        OPEN cur_operations FOR operations_cursor USING p_group_id,
             p_header_id, orig_last_update_date, p_batch_id ;
-- , p_action_type ;

        LOOP
         FETCH cur_operations INTO operation_tab(oper_cnt);
         EXIT WHEN cur_operations%NOTFOUND;

       IF p_action_type <> 1 THEN

         IF operation_tab(oper_cnt).batchstep_id = 0 THEN
           fnd_message.set_name('GMP','GMP_OPER_DELETED');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Operation deleted.';
           sreturn_status := -1 ;
           EXIT ;
         ELSIF (operation_tab(oper_cnt).gme_oper_count <>
               operation_tab(oper_cnt).aps_oper_count) THEN
           fnd_message.set_name('GMP','GMP_NUMBER_OF_OPER_MISMATCH');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Number of operation does not match.';
           sreturn_status := -1 ;
           EXIT ;
         ELSIF (operation_tab(oper_cnt).bo_last_update < 0) AND
               (operation_tab(oper_cnt).step_status = 1) THEN
           -- If step is in pending and last update changed, We are not
           -- Updating the batch
           fnd_message.set_name('GMP','GMP_BATCH_STEP_CHANGED');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Pending Step/Operation is changed.' ;
           sreturn_status := -1 ;
           EXIT;
         ELSIF (operation_tab(oper_cnt).first_unit_start_date < sysdate) AND
          (operation_tab(oper_cnt).step_status = 1) AND t_batch_status = 2 THEN
           -- For WIP batch, step is pending and step start date is past due,
           --  We are not Updating the batch
           fnd_message.set_name('GMP','GMP_STEP_PAST_DUE');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' WIP batch, Pending Step is past due.' ;
           sreturn_status := -1 ;
           EXIT;
         ELSE
           sreturn_status := 0 ;
         END IF ;

       END IF ;   /* action type */

       t_max_step_date := operation_tab(oper_cnt).max_step_date ;

       IF (operation_tab(oper_cnt).step_status = 1) THEN
        -- Update the Steps only if it pending

          IF p_action_type = 1 THEN
            gmp_debug_message(' Updating steps in pending status for new batch');
            update_batch_steps(
              p_batch_id,
              operation_tab(oper_cnt).operation_seq_num,
              operation_tab(oper_cnt).batchstep_id,
              operation_tab(oper_cnt).first_unit_start_date,
              operation_tab(oper_cnt).last_unit_completion_date,
              operation_tab(oper_cnt).last_unit_completion_date, /* B5454215 */
              p_user_id,
              p_login_id,
              sreturn_status);
          ELSE
            gmp_debug_message(' Updating steps in pending status for reschedule batch');
            update_batch_steps(
              p_batch_id,
              operation_tab(oper_cnt).operation_seq_num,
              operation_tab(oper_cnt).batchstep_id,
              operation_tab(oper_cnt).first_unit_start_date,
              operation_tab(oper_cnt).last_unit_completion_date,
              NULL,    /* B5454215 */
              p_user_id,
              p_login_id,
              sreturn_status);
          END IF;

          IF sreturn_status < 0 THEN
             fnd_message.set_name('GMP','GMP_STEP_UPDATE_FAILED');
             fnd_msg_pub.add ;
             e_msg := e_msg || ' Failed: Update to Step/Operation' ;
             EXIT;
          END IF ;
       ELSE
        gmp_debug_message(' step to be updated not in pending status '||operation_tab(oper_cnt).operation_seq_num );
        -- No Update to steps (WIP or completed)
        BEGIN
         UPDATE gmp_aps_output_dtl
            SET load_type = (load_type * -1)
          WHERE operation_seq_num =
                operation_tab(oper_cnt).operation_seq_num
            AND wip_entity_id = p_batch_id
            AND organization_id = p_organization_id   -- For R12.0
            AND group_id = p_group_id
            AND parent_header_id = p_header_id ;
        EXCEPTION
          WHEN OTHERS THEN
           fnd_msg_pub.add_exc_msg('gmp_aps_writer','main_process');
           e_msg := e_msg || ' WIP/completed step: '||TO_CHAR(SQLCODE)||': '||SQLERRM ;
           sreturn_status := -1 ;
           EXIT;
        END;

       END IF ;  /* step_status check */

       oper_cnt := oper_cnt + 1;
       END LOOP;
       CLOSE cur_operations;
       time_stamp;
       oper_cnt := oper_cnt - 1;
       log_message(' Step/Operation size is = ' || to_char(oper_cnt)) ;

    END IF ;  /* Breturn_status */

    -- B5473156, Update the Batch Plan Completion Date
    IF (p_end_date < t_max_step_date) AND (sreturn_status >= 0) THEN
      breturn_status := -1 ;

      update_batch_header(
        p_batch_id,
        p_start_date,
        t_max_step_date,
        t_due_date,        -- For R12.0
        p_order_priority,  -- For R12.0
        t_batch_status,
        t_firm_flag,   -- B5897392
        p_user_id,
        p_login_id,
        breturn_status);

        IF breturn_status < 0 THEN
           fnd_message.set_name('GMP','GMP_STEP_UPDATE_FAILED');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Failed: Update to Batch End Date' ;
           sreturn_status := -1 ;
        ELSE
           log_message(' SET Batch End Date to Maximum of Step End Date ');
        END IF ;
    END IF;  /* t_max_step_date */

    BEGIN
    gmp_debug_message(' Updating attribute9 with batchstep resource id' );

    UPDATE GMP_APS_OUTPUT_DTL gad
    SET attribute9 = ( SELECT gbr.batchstep_resource_id
    FROM GME_BATCH_HEADER gbh,
         GME_BATCH_STEPS  gbs,
         GME_BATCH_STEP_ACTIVITIES gba,
         GME_BATCH_STEP_RESOURCES gbr,
         CR_RSRC_DTL crd
    WHERE gbh.batch_id = gbs.batch_id
      AND gbs.batchstep_id = gba.batchstep_id
      AND gbs.batchstep_id = gbr.batchstep_id
      AND gba.batchstep_activity_id = gbr.batchstep_activity_id
      AND gbr.resources = crd.resources
      AND gbh.organization_id = crd.organization_id   -- For R12.0
      AND gbh.organization_id = gbr.organization_id   -- For R12.0
      AND gbr.prim_rsrc_ind <> 1
      AND crd.resource_id = gad.resource_id_new
      AND gbh.batch_id = gad.wip_entity_id
      AND gbs.batchstep_no = gad.operation_seq_num
      AND gba.sequence_dependent_ind = gad.schedule_seq_num )
    WHERE gad.wip_entity_id = p_batch_id
      AND gad.group_id = p_group_id
      AND gad.parent_header_id = p_header_id
      AND gad.organization_id = p_organization_id
      AND gad.load_type = 1 ;

       log_message( p_group_id || '-' || p_header_id || '-'||
       p_batch_id  ||' Org  ' || p_organization_id );

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         null;
        WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg('gmp_aps_writer','main_process');
         e_msg := e_msg || ' Attribute9: '||TO_CHAR(SQLCODE)||': '||SQLERRM ;
         sreturn_status := -1 ;
    END ;

    -- Update Resources / Activities
       oper_rsrc_cursor := ' SELECT '
      ||' final.batchstep_no , '
      ||' final.schedule_seq_num , '   -- For R12.0
      ||' aps.resource_seq_num , '
      ||' final.batchstep_id , '
      ||' aps.organization_id, '
      ||' final.batchstep_activity_id , '
      ||' final.batchstep_resource_id , '
      ||' final.activity , '
      ||' aps.resources , '
      ||' aps.resource_id_new, '
      ||' final.resources , '
      ||' aps.uom_code,  '
      ||' final.uom_code, '
      ||' aps.assigned_units , '
      ||' final.plan_rsrc_count, '
   -- Alternate for primary resource For R12.0
      ||' (final.plan_rsrc_usage * '
      ||'   NVL((SELECT cam.runtime_factor FROM cr_ares_mst cam '
      ||'        WHERE cam.delete_mark = 0 '
      ||'        AND nvl(aps.replacement_group_num,0) <> 0 '
      ||'        AND final.prim_rsrc_ind = 1 '
      ||'        AND final.resources <> aps.resources '
      ||'        AND aps.attribute9 is null '
      ||'        AND final.resources = cam.primary_resource '
      ||'        AND aps.resources = cam.alternate_resource '
      ||'       ),1 ) ), '                 -- GME Resource Usage
      ||' aps.sequence_dependent_usage, ' -- For R12.0
      ||' aps.start_date, '
      ||' aps.completion_date,   '
   -- Select Min activity start date For R12.0
      ||' MIN(aps.act_start_date) OVER (PARTITION BY '
      ||'     final.batchstep_activity_id), '
      ||' MAX(aps.completion_date) OVER (PARTITION BY '
      ||'     final.batchstep_activity_id), '
      ||' aps.resource_hour, '            -- APS Resource Usage
   --  Is Charge exists
      ||'  ( SELECT  count(*) from gmp_aps_output_dtl '
      ||'    WHERE wip_entity_id = aps.wip_entity_id '
      ||'     AND parent_header_id = aps.parent_header_id '
      ||'     AND group_id = aps.group_id  '
      ||'     AND load_type = 10 '
      ||'     AND operation_seq_num = aps.operation_seq_num '
      ||'     AND schedule_seq_num = aps.schedule_seq_num '
      ||'     AND resource_id_new = aps.resource_id_new ) Charges_present, '
      ||' final.scale_type, '
   -- Only Use APS data if alternate resource factor is 1
      ||' SUM( '
      ||' DECODE(final.rsrc_count,1,0, '
      ||'   DECODE( '
      ||'   NVL((SELECT cam.runtime_factor FROM cr_ares_mst cam '
      ||'        WHERE cam.delete_mark = 0 '
      ||'        AND nvl(aps.replacement_group_num,0) <> 0 '
      ||'        AND final.prim_rsrc_ind = 1 '
      ||'        AND final.resources <> aps.resources '
      ||'        AND aps.attribute9 is null '
      ||'        AND final.resources = cam.primary_resource '
      ||'        AND aps.resources = cam.alternate_resource ) '
      ||'       ,1),1,final.Batch_rsrc_Avg,9) '
      ||'       ) '
      ||'     ) OVER '
      ||' (PARTITION BY final.batchstep_activity_id), ' ; -- aps or gme use

    IF p_action_type = 1 THEN  -- (New Batch)
      oper_rsrc_cursor :=  oper_rsrc_cursor
      ||' to_number(null), '
      ||' to_number(null), '
      ||' to_number(null), '
      ||' to_number(null), '
      ||' to_number(null), '
      ||' to_number(null), '
      ||' to_number(null), '
      ||' to_number(null), ' ;
    ELSE                      -- (Reschedule Batch)
      oper_rsrc_cursor :=  oper_rsrc_cursor
      ||' nvl(aps.operation_seq_num,0) , '
      ||' nvl(aps.schedule_seq_num,0) , '  -- For R12.0
      ||' final.bsa_last_update, '
      ||' final.bsr_last_update,   '
      ||' final.act_count , '
      ||' nvl(aps.activity_count,0) , '
      ||' final.rsrc_count , '
      ||' nvl(aps.rsrc_count,0),  ' ;
    END IF;

      oper_rsrc_cursor :=  oper_rsrc_cursor
      ||' aps.setup_id , '               -- For R12.0
      ||' aps.group_sequence_id , '      -- For R12.0
      ||' aps.group_sequence_number,  '  -- For R12.0
      ||' aps.firm_flag  , '              -- For R12.0
      ||' aps.inventory_item_id '   -- Bug: 8616967 Vpedarla
      ||' FROM  '
      ||'    ( '
      ||'     SELECT '
      ||'     gsa.batch_id, '
      ||'     gsa.batchstep_id, '
      ||'     gbs.batchstep_no, '
      ||'     gsa.batchstep_activity_id, '
      ||'     gsa.activity, '
      ||'     gsa.offset_interval, '
      ||'     nvl(gsa.sequence_dependent_ind,0) schedule_seq_num,' -- For R12.0
      ||'     gsr.batchstep_resource_id ,   '
      ||'     gsr.resources, '
      ||'     gsr.scale_type, '
      ||'     gsr.prim_rsrc_ind, '
      ||'     gsr.plan_rsrc_usage, '
      ||'     gsr.plan_rsrc_count, '
      ||'     DECODE(sign(ceil(gsr.plan_rsrc_usage) - '
      ||'        (AVG(ceil(gsr.plan_rsrc_usage)/gsr.plan_rsrc_count) '
      ||'         OVER (PARTITION BY gsr.batchstep_activity_id)) '
      ||'            ) ,0,0,1,1,-1,1 ) Batch_rsrc_Avg ,'
      ||'     COUNT(distinct gbs.batchstep_no) '
      ||'     OVER (PARTITION BY gsr.batch_id) oper_count, '
      ||'     COUNT(distinct gsa.batchstep_activity_id) '
      ||'     OVER (PARTITION BY gbs.batchstep_no) act_count, '
      ||'     COUNT(gsr.resources) '
    -- For R12.0
      ||'     OVER (PARTITION BY gbs.batchstep_no,  '
      ||'                        gsa.batchstep_activity_id, '
      ||'     DECODE(crd.schedule_ind,1,1,2,1,0,1) ) rsrc_count, '
      ||'     gsr.usage_um uom_code,'
      ||'     DECODE(sign(:LUP1 '
      ||'          - gsr.last_update_date), 1,1,0,1,-1,-500) bsr_last_update, '
      ||'     DECODE(sign(:LUP2 '
      ||'         - gsa.last_update_date), 1,1,0,1,-1,-500) bsa_last_update '
    -- For R12.0
      ||'      FROM gme_batch_step_activities gsa, '
      ||'           gme_batch_steps gbs, '
      ||'           gme_batch_step_resources gsr, '
      ||'           cr_rsrc_dtl crd '            -- For R12.0
      ||'      WHERE  '
      ||'           gsr.batch_id = gsa.batch_id  '
      ||'       AND gsr.batchstep_activity_id = gsa.batchstep_activity_id '
      ||'       AND crd.resources = gsr.resources  '   -- For R12.0
      ||'       AND crd.organization_id = gsr.organization_id ' -- For R12.0
      ||'       AND crd.delete_mark = 0 '              -- For R12.0
      ||'       AND crd.schedule_ind <> 3 '            -- For R12.0
      ||'       AND gsr.plan_rsrc_usage > 0 '          -- For R12.0
      ||'       AND gsa.batch_id = :PBATCH1 '
      ||'       AND gsa.delete_mark = 0 '
      ||'       AND gbs.delete_mark = 0 '
      -- bug: 8348916 vpedarla added condition to process only steps in pending status.
      -- For records of steps in status other than pending, load_type will be negative and not allowed to process.
      ||'       AND gbs.step_status  = 1 '
      ||'       AND gbs.batch_id = gsa.batch_id '
      ||'       AND gsa.batchstep_id = gbs.batchstep_id '
      ||'    ) final, '
      ||'    ( '
      ||'     SELECT gad.wip_entity_id, gad.organization_id, '  -- For R12.0
      ||'     gad.parent_header_id , '
      ||'     gad.group_id , '
      ||'     gad.operation_seq_num,  '
      ||'     gad.resource_seq_num,  '
      ||'     gad.schedule_seq_num,  '       -- For R12.0
      ||'     gad.assigned_units , '
      ||'     gad.resource_id_new , '
      ||'     gad.resource_id_old , '
      ||'     gad.attribute9, '
      ||'     crd.resources , '
      ||'     gad.uom_code , '
      ||'     gad.replacement_group_num , '
      ||'     gad.setup_id , '               -- For R12.0
      ||'     gad.group_sequence_id , '      -- For R12.0
      ||'     gad.group_sequence_number , '  -- For R12.0
      ||'     gad.firm_flag  , '             -- For R12.0
      ||'     gad.start_date, '
      ||'     gad.completion_date, '
      -- For R12.0
      ||' DECODE(seq.start_date, NULL,gad.start_date, '
      ||'        seq.start_Date) act_start_date, '
      ||'     seq.start_date seq_start_date, '
      ||'     seq.sequence_dependent_usage, '
      ||'     nvl(fnd_number.canonical_to_number(gad.attribute1),0) resource_hour, '
      /*sowsubra B4629277 - changed to_number to fnd_number.canonical_to_number*/
      ||'     MAX(nvl(to_number(gad.attribute1),0)) '
      ||'     OVER (PARTITION BY gad.operation_seq_num, '
      ||'          gad.schedule_seq_num ) aps_max_usage, '
      ||'     COUNT(distinct gad.operation_seq_num)  '
      ||'     OVER (PARTITION BY gad.wip_entity_id) oper_count, '
      ||'     COUNT(distinct gad.schedule_seq_num) '
      ||'     OVER (PARTITION BY gad.operation_seq_num) activity_count, '
      ||'     ( COUNT(gad.resource_id_new) '
      ||'     OVER (PARTITION BY gad.operation_seq_num, '
      ||'          gad.schedule_seq_num ) '
      ||'      - crd.delete_mark ) rsrc_count, '
      ||'      gao.inventory_item_id  '       -- Bug: 8616967 Vpedarla
      ||'     FROM  gmp_aps_output_dtl gad, '
      ||'           gmp_aps_output_tbl gao, '
      ||'           cr_rsrc_dtl crd, '
      -- Sequence depdendency selection For R12.0
      ||'   ( SELECT operation_seq_num, parent_seq_num, schedule_seq_num, '
      ||'      wip_entity_id, resource_id_new , '
      ||'      TO_NUMBER(attribute1) sequence_dependent_usage, '
      ||'      MIN(start_date) OVER (PARTITION BY '
      ||'          group_id, parent_header_id, schedule_seq_num) start_date '
      ||'     FROM  gmp_aps_output_dtl '
      ||'     WHERE parent_header_id = :phdr2 '
      ||'       AND group_id  = :PGRP2 '
      ||'       AND wip_entity_id = :PBATCH2 '
      ||'       AND load_type = 1 '
      ||'       AND parent_seq_num IS NOT NULL '
      ||'   ) seq '
      ||'     WHERE gad.parent_header_id = gao.header_id '
      ||'       AND gad.group_id = gao.process_id '
      ||'       AND gao.header_id = :PHDR3  '
      ||'       AND gad.group_id  = :PGRP3 '
      ||'       AND gad.wip_entity_id = :PBATCH3 '
      ||'       AND gao.batch_id = gad.wip_entity_id '
      ||'       AND gad.load_type = 1 '
      ||'       AND gad.parent_seq_num IS NULL '          -- For R12.0
      ||'       AND gad.resource_id_new = crd.resource_id '
      ||'       AND crd.organization_id = gao.organization_id '
      -- For R12.0
      ||'  AND gad.wip_entity_id = seq.wip_entity_id (+) '
      ||'  AND gad.resource_id_new = seq.resource_id_new (+) '
      ||'  AND gad.operation_seq_num = seq.operation_seq_num (+) '
      ||'  AND gad.schedule_seq_num = seq.schedule_seq_num  (+) '
      ||'    ) APS '
      ||' WHERE ' ;

      -- For R12.0
    IF p_action_type = 1 THEN  -- (New Batch)
      oper_rsrc_cursor :=  oper_rsrc_cursor
      ||'     final.batch_id = aps.wip_entity_id '
      ||' AND final.schedule_seq_num = aps.schedule_seq_num '
      ||' AND final.batchstep_no = aps.operation_seq_num '
      ||' AND ( '
      ||'      ( final.resources = aps.resources '
      ||'        AND nvl(final.prim_rsrc_ind,0) <> 1 '
      ||'        AND final.batchstep_resource_id = aps.attribute9 ) '
      ||'      OR '
      ||'      ( final.resources = aps.resources '
      ||'        AND nvl(aps.replacement_group_num,0) = 0 '
      ||'        AND nvl(final.prim_rsrc_ind,0) = 1 )'
      ||'      OR '
      ||'      ( final.resources <> aps.resources '
      ||'        AND nvl(final.prim_rsrc_ind,0) = 1 '
      ||'        AND nvl(aps.replacement_group_num,0) <> 0 '
      ||'        AND aps.attribute9 is null ) '
      ||'      ) '
      ||' ORDER BY '
      ||'     final.batchstep_no, final.schedule_seq_num ' ;
    ELSE                      -- (Reschedule Batch)
      oper_rsrc_cursor :=  oper_rsrc_cursor
      ||'     final.batchstep_resource_id = aps.resource_seq_num (+) '
      ||' AND final.schedule_seq_num = aps.schedule_seq_num (+) '
      ||' AND final.batchstep_no = aps.operation_seq_num (+) '
      ||' ORDER BY '
      ||'     final.batchstep_no, final.schedule_seq_num ' ;
    END IF ;

     log_message('After Load 1 Cursor ');
     log_message(' orig_last_update_date -' ||to_char(orig_last_update_date,'dd-mm-yy hh24:mi:ss'));
gmp_debug_message(' oper_rsrc_cursor -'||oper_rsrc_cursor);
    or_cnt  := 1 ;
    act_cnt    := 1 ;
    IF sreturn_status >= 0 THEN
      OPEN cur_oper_rsrc FOR oper_rsrc_cursor USING orig_last_update_date,
           orig_last_update_date,  p_batch_id, p_header_id, p_group_id, p_batch_id,
           p_header_id, p_group_id, p_batch_id ;

      LOOP
      FETCH cur_oper_rsrc INTO or_tab(or_cnt);
      EXIT WHEN cur_oper_rsrc%NOTFOUND;
      IF p_action_type <> 1 THEN
      -- For reschedule batch

  log_message(or_tab(or_cnt).schedule_seq_num || '--' ||
  or_tab(or_cnt).resource_seq_num || '--' ||
  or_tab(or_cnt).gme_rsrc_count || '--' ||
or_tab(or_cnt).aps_rsrc_count);

         IF or_tab(or_cnt).Aoperation_seq_num = 0 THEN
           fnd_message.set_name('GMP','GMP_OPERATION_CHANGED');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Operation Changed. ';
           batch_valid := -1 ;
           EXIT ;
         ELSIF or_tab(or_cnt).Aschedule_seq_num = 0 THEN    -- For R12.0
           fnd_message.set_name('GMP','GMP_ACTIVITY_CHANGED');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Activity Changed.';
           batch_valid := -1 ;
           EXIT ;
         ELSIF or_tab(or_cnt).gme_actv_count <>
               or_tab(or_cnt).aps_actv_count THEN
           fnd_message.set_name('GMP','GMP_ACTV_CNT_MISMATCH');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Number of activities does not match.';
           batch_valid := -1 ;
           EXIT ;

         ELSIF or_tab(or_cnt).gme_rsrc_count <>
               or_tab(or_cnt).aps_rsrc_count THEN
           fnd_message.set_name('GMP','GMP_RSRC_CNT_MISMATCH');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Number of resources does not match.';
           batch_valid := -1 ;
           EXIT ;
         ELSIF or_tab(or_cnt).bsa_lup < 0 THEN
           fnd_message.set_name('GMP','GMP_ACTIVITY_CHANGED');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Activity updated.';
           batch_valid := -1 ;
           EXIT ;
         ELSIF or_tab(or_cnt).bsr_lup < 0 THEN
           fnd_message.set_name('GMP','GMP_ACT_RSRC_CHANGED');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Activity Resource changed.';
           batch_valid := -1 ;
           EXIT ;
         ELSE
           batch_valid := 0 ;
         END IF;   /* Validation check */

      ELSE
           batch_valid := 0 ;
      END IF;      /* p_action_type check */

      IF or_cnt  = 1 THEN
      -- First row should be written
       act_cnt := 1 ;
       act_tab(act_cnt).organization_id   := or_tab(or_cnt).organization_id ;
       act_tab(act_cnt).batchstep_id      := or_tab(or_cnt).batchstep_id ;
       act_tab(act_cnt).start_date        := or_tab(or_cnt).act_start_date ;
       act_tab(act_cnt).end_date          := or_tab(or_cnt).act_end_date ;
       act_tab(act_cnt).uom_code          := or_tab(or_cnt).gme_uom_code ;
       act_tab(act_cnt).operation_seq_num := or_tab(or_cnt).operation_seq_num ;
       -- For 12.0
       act_tab(act_cnt).schedule_seq_num  := or_tab(or_cnt).schedule_seq_num;
       act_tab(act_cnt).resource_seq_num  := or_tab(or_cnt).resource_seq_num;
       act_tab(act_cnt).batchstep_activity_id :=
                 or_tab(or_cnt).batchstep_activity_id ;

       old_activity_id := or_tab(or_cnt).batchstep_activity_id;
      ELSE
        IF or_tab(or_cnt).batchstep_activity_id <> old_activity_id THEN
           act_cnt := act_cnt + 1;

       act_tab(act_cnt).organization_id   := or_tab(or_cnt).organization_id ;
       act_tab(act_cnt).batchstep_id      := or_tab(or_cnt).batchstep_id ;
       act_tab(act_cnt).start_date        := or_tab(or_cnt).act_start_date ;
       act_tab(act_cnt).end_date          := or_tab(or_cnt).act_end_date ;
       act_tab(act_cnt).uom_code          := or_tab(or_cnt).gme_uom_code ;
       act_tab(act_cnt).operation_seq_num := or_tab(or_cnt).operation_seq_num ;
       -- For 12.0
       act_tab(act_cnt).schedule_seq_num  := or_tab(or_cnt).schedule_seq_num;
       act_tab(act_cnt).resource_seq_num  := or_tab(or_cnt).resource_seq_num;
       act_tab(act_cnt).batchstep_activity_id :=
                 or_tab(or_cnt).batchstep_activity_id ;

        END IF ;

      END IF ;
      old_activity_id := or_tab(or_cnt).batchstep_activity_id;
      or_cnt := or_cnt + 1;
      END LOOP;
      CLOSE cur_oper_rsrc;
      or_cnt := or_cnt - 1;
      time_stamp;
      log_message('Operation Resource size is = ' || to_char(or_cnt)) ;

      -- Last row only if it is not the first row
       IF (or_tab(or_cnt).batchstep_activity_id <> old_activity_id)
            AND (or_cnt > 1) THEN

       act_cnt := act_cnt + 1;
       act_tab(act_cnt).organization_id   := or_tab(or_cnt).organization_id ;
       act_tab(act_cnt).batchstep_id      := or_tab(or_cnt).batchstep_id ;
       act_tab(act_cnt).start_date        := or_tab(or_cnt).act_start_date ;
       act_tab(act_cnt).end_date          := or_tab(or_cnt).act_end_date ;
       act_tab(act_cnt).uom_code          := or_tab(or_cnt).gme_uom_code ;
       act_tab(act_cnt).operation_seq_num := or_tab(or_cnt).operation_seq_num ;
       -- For 12.0
       act_tab(act_cnt).schedule_seq_num  := or_tab(or_cnt).schedule_seq_num;
       act_tab(act_cnt).resource_seq_num  := or_tab(or_cnt).resource_seq_num;
       act_tab(act_cnt).batchstep_activity_id :=
                 or_tab(or_cnt).batchstep_activity_id ;

       END IF ;
       time_stamp;
       log_message('Activity size is = ' || to_char(act_cnt)) ;

      IF batch_valid = 0 THEN
       log_message('Batch is Valid ');
      j := 1 ;
      FOR j IN 1..or_cnt LOOP

       rsrc_cnt := 0 ;
       rsrc_usg := 0 ;

       -- In a activity resource usage of multiple resources are different
       -- then use GME data as APS transaction data is not correct i.e.
       -- Simultanesous resources with different speed (Use GME data)

         IF or_tab(j).aps_charges <> 0 THEN
            -- mattt with charges and DS the usage and count can change
            -- for a resource, Charges exists then use APS data
            or_tab(j).aps_data_use  := 0 ;  -- APS Way

               --  bug: 8616967 added the below code to convert usage from APS_UOM_CODE to GME_UOM_CODE.
                     IF ( or_tab(j).APS_UOM_CODE <> or_tab(j).GME_UOM_CODE ) THEN
                          or_tab(j).aps_rsrc_usage := inv_convert.inv_um_convert(
                                        or_tab(j).Product_item ,
                                        NULL,
                                        or_tab(j).organization_id,
                                        5,
                                        or_tab(j).aps_rsrc_usage,
                                        or_tab(j).APS_UOM_CODE,
                                        or_tab(j).GME_UOM_CODE,
                                        NULL,
                                        NULL);
                     END IF;

            Rsrc_usg := or_tab(j).aps_rsrc_usage ;
            rsrc_cnt := or_tab(j).assigned_units ;

         ELSE
            -- Charges are not present and type is scale by charge
            IF or_tab(j).scale_type = 2 THEN
               or_tab(j).scale_type := 1 ;  -- Change to proportional
            ELSE
               NULL ;   -- Do not change scale type
            END IF;

  log_message(  or_tab(j).aps_rsrc_usage ||'**'|| or_tab(j).APS_UOM_CODE  );

               --  bug: 8616967 added the below code to convert usage from APS_UOM_CODE to GME_UOM_CODE.
                     IF ( or_tab(j).APS_UOM_CODE <> or_tab(j).GME_UOM_CODE ) THEN
                          or_tab(j).aps_rsrc_usage := inv_convert.inv_um_convert(
                                        or_tab(j).Product_item ,
                                        NULL,
                                        or_tab(j).organization_id,
                                        5,
                                        or_tab(j).aps_rsrc_usage,
                                        or_tab(j).APS_UOM_CODE,
                                        or_tab(j).GME_UOM_CODE,
                                        NULL,
                                        NULL);
                     END IF;

  log_message(  or_tab(j).aps_rsrc_usage ||'**'|| or_tab(j).gme_uom_code  );

              IF (or_tab(j).aps_data_use  <> 0) AND
                (or_tab(j).aps_rsrc_usage = or_tab(j).plan_rsrc_usage) AND
                (or_tab(j).assigned_units = or_tab(j).plan_rsrc_count)
              THEN
                  or_tab(j).aps_data_use := 0 ;
              END IF ;

              IF or_tab(j).aps_data_use  = 0 THEN
                    -- APS Way
                    Rsrc_usg := or_tab(j).aps_rsrc_usage ;
                    rsrc_cnt := or_tab(j).assigned_units ;
              ELSE
                    -- GME Way (or_tab(j).aps_data_use <> 0 )
                    Rsrc_usg := or_tab(j).plan_rsrc_usage ;
                    rsrc_cnt := or_tab(j).plan_rsrc_count ;
              END IF;

         END IF;   /* Charges End if */

       IF (or_tab(j).aps_data_use <> 0 ) THEN
       -- Decision: Use GME data
          log_message('Inside GME Way ');
         gmp_debug_message(' calling update_step_resources with usage '||rsrc_usg );
         update_step_resources(
         p_batch_id,
         or_tab(j).organization_id,          -- For R12.0,
         or_tab(j).batchstep_resource_id,
         rsrc_usg,
         or_tab(j).sequence_dependent_usage,  -- For R12.0
         or_tab(j).gme_resource,
         or_tab(j).aps_resource,
         or_tab(j).start_date,
         or_tab(j).completion_date,
         or_tab(j).gme_uom_code ,
         rsrc_cnt,
         or_tab(j).aps_data_use,
         or_tab(j).setup_id ,            -- For R12.0
         or_tab(j).group_sequence_id ,   -- For R12.0
         or_tab(j).group_sequence_number,   -- For R12.0
         or_tab(j).firm_flag ,           -- For R12.0
         or_tab(j).scale_type,           -- For R12.0
         p_user_id,
         p_login_id,
         new_batchstep_resource_id,
         rreturn_status );

         IF rreturn_status < 0 THEN
            fnd_message.set_name('GMP','GMP_STEP_RESOURCE_FAILED');
            fnd_msg_pub.add ;
            e_msg := e_msg || ' Step Resource failed: GME way' ;
            log_message(e_msg) ;
            EXIT;
         END IF ;  /* rreturn_status */

       ELSIF (or_tab(j).aps_data_use  = 0 ) THEN
       -- Decision: Use APS data
          log_message('Inside APS Way ');
         gmp_debug_message(' calling update_step_resources with usage '||rsrc_usg );
         update_step_resources(
         p_batch_id,
         or_tab(j).organization_id,          -- For R12.0,
         or_tab(j).batchstep_resource_id,
         rsrc_usg,
         or_tab(j).sequence_dependent_usage,   -- For R12.0
         or_tab(j).gme_resource,
         or_tab(j).aps_resource,
         or_tab(j).start_date,
         or_tab(j).completion_date,
         or_tab(j).gme_uom_code ,
         rsrc_cnt,
         or_tab(j).aps_data_use,
         or_tab(j).setup_id ,            -- For R12.0
         or_tab(j).group_sequence_id ,   -- For R12.0
         or_tab(j).group_sequence_number,   -- For R12.0
         or_tab(j).firm_flag ,           -- For R12.0
         or_tab(j).scale_type,           -- For R12.0
         p_user_id,
         p_login_id,
         new_batchstep_resource_id,
         rreturn_status );

         IF rreturn_status < 0 THEN
             fnd_message.set_name('GMP','GMP_STEP_RESOURCE_FAILED');
             fnd_msg_pub.add ;
             e_msg := e_msg || ' Step Resource failed:APS Way' ;
             log_message(e_msg) ;
             EXIT;
         ELSE

         BEGIN
         IF p_action_type = 1 THEN
         -- New batch

            UPDATE GMP_APS_OUTPUT_DTL
            SET attribute9 = new_batchstep_resource_id,
                attribute10 = or_tab(j).APS_UOM_CODE
            WHERE load_type IN (4,9)      -- For R12.0
              AND resource_id_new =  or_tab(j).aps_resource_id
              AND group_id = p_group_id
              AND parent_header_id = p_header_id
              AND operation_seq_num = or_tab(j).operation_seq_num
              -- For R12.0
              AND schedule_seq_num  = or_tab(j).schedule_seq_num
    -- PS Issue B6045398, PS engine is sending resource_seq_num NULL for laod_type = 1
              AND ( ( resource_seq_num = NVL(or_tab(j).resource_seq_num,resource_seq_num)
                      AND parent_seq_num IS NULL )
                  OR
                   (
                   parent_seq_num = NVL(or_tab(j).resource_seq_num,parent_seq_num)
                   AND parent_seq_num IS NOT NULL )
                  ) ;

         ELSE
         -- Reschedule batch (Update the count as APS does not provide)
            UPDATE GMP_APS_OUTPUT_DTL
            SET attribute9 = new_batchstep_resource_id,
                attribute10 = or_tab(j).APS_UOM_CODE,
                assigned_units = rsrc_cnt
            WHERE load_type IN (4,9)                            -- For R12.0
              AND resource_id_new =  or_tab(j).aps_resource_id
              AND group_id = p_group_id
              AND parent_header_id = p_header_id
              AND operation_seq_num = or_tab(j).operation_seq_num
              -- For R12.0
              AND schedule_seq_num  = or_tab(j).schedule_seq_num
              AND ( ( resource_seq_num = or_tab(j).resource_seq_num
                      AND parent_seq_num IS NULL )
                  OR
                   (
                   parent_seq_num = or_tab(j).resource_seq_num
                   AND parent_seq_num IS NOT NULL )
                  ) ;

         END IF;   /* action type */

         EXCEPTION
            WHEN OTHERS THEN
               fnd_msg_pub.add_exc_msg('gmp_aps_writer','main_process');
               e_msg := e_msg || ' Transactions: '||TO_CHAR(SQLCODE)||': '||SQLERRM;
               rreturn_status := -13 ;
               EXIT;
         END;
         END IF ;  /* rreturn_status */

       END IF ;  /* aps_data_use */

      END LOOP;   /* Operation Resource Loop */
      END IF ;    /* Batch Valid */

    END IF ;  /* Sreturn_status */

    IF rreturn_status >= 0 THEN
     -- Update activities
     FOR i IN 1..act_cnt LOOP

          update_batch_activities(
            p_batch_id,
            act_tab(i).organization_id,     -- For R12.0
            act_tab(i).batchstep_id,
            act_tab(i).batchstep_activity_id,
            act_tab(i).start_date,
            act_tab(i).end_date,
            act_tab(i).uom_code,
            p_user_id,
            p_login_id,
            areturn_status);

          IF areturn_status < 0 THEN
            fnd_message.set_name('GMP','GMP_ACTIVITY_UPDATE_FAIL');
            fnd_msg_pub.add ;
            e_msg := e_msg || ' Update to Activities is failed' ;
            log_message(e_msg) ;
            EXIT;
          END IF ;

        END LOOP ;

    END IF;  /* End if for rreturn_status */

-- NOTE:
-- GMPOUTIB.pls  will populate column resource_instance_number with
-- WIP resource_instance_id then update GMP_APS_OUTPUT_DTL table
-- resource_instance_id column
-- with actual resource_instance_id from GMP_RESOURCE_INSTACNES table

   -- Update the resource level transactions if instance level transactions
   -- are present
        BEGIN

         UPDATE gmp_aps_output_dtl
            SET load_type = (load_type * -1)
         WHERE load_type = 4
           AND group_id = p_group_id
           AND parent_header_id = p_header_id
           -- PS Issue, B6051303 Alternate resource Issue
           AND (operation_Seq_num,nvl(parent_seq_num,resource_seq_num),
               schedule_seq_num) IN
                 ( SELECT b.operation_Seq_num,
                    nvl(b.parent_seq_num,b.resource_seq_num),
                    b.schedule_seq_num
                    FROM gmp_aps_output_dtl b
                    WHERE b.group_id = p_group_id
                    AND b.parent_header_id = p_header_id
                    AND b.load_type = 9 ) ;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           NULL ;
          WHEN OTHERS THEN
           fnd_msg_pub.add_exc_msg('gmp_aps_writer','main_process');
           e_msg := e_msg || ' WIP/completed step: '||TO_CHAR(SQLCODE)||': '||SQLERRM ;
           areturn_status := -1 ;
        END;

      -- Select resource transactions before any update
      rsrc_tran_cursor := ' SELECT '
      ||'  gad.attribute9, '   -- Batchstep resource ID
      ||'  gao.organization_id,  '     -- For R12.0
      ||'  gad.operation_seq_num, '
      ||'  gad.schedule_seq_num, '     -- For R12.0
      ||'  gad.resource_seq_num, '
      ||'  gad.parent_seq_num, '       -- For R12.0
      ||'  gad.resource_id_new, '
      ||'  crd.resources, '
      ||'  gad.attribute10, '   -- uom_code
      ||'  gad.assigned_units, '
      ||'  nvl(fnd_number.canonical_to_number(gad.attribute1),0) resource_hour, '
      -- sowsubra B4629277 changed to_number to fnd_number.canonical_to_number
      ||'  gad.start_date, '
      ||'  gad.completion_date, '
      ||'  gad.resource_instance_id , '   -- For R12.0
      ||'  gme.USAGE_UM ,     '     --Bug: 8616967 Vpedarla
      ||'  gao.inventory_item_id  '   --Bug: 8616967 Vpedarla
      ||' FROM gmp_aps_output_dtl gad, '
      ||'      gmp_aps_output_tbl gao,  '
      ||'      cr_rsrc_dtl crd , '
      ||'      gme_batch_step_resources gme '   --Bug: 8616967 Vpedarla
      ||' WHERE  '
      ||'       gad.load_type in (4,9) '
      ||'   AND gad.parent_header_id = gao.header_id '
      ||'   AND gad.group_id = gao.process_id '
      ||'   AND gad.wip_entity_id = gao.batch_id  '
      ||'   AND gao.process_id = :pgpr  '
      ||'   AND gao.header_id = :phdr  '
      ||'   AND gad.resource_id_new = crd.resource_id '
      ||'   AND crd.organization_id = gao.organization_id '  -- For R12.0
      ||'   AND nvl(to_number(gad.attribute9),0) > 0 ' -- batchstep_resource_id
      ||'   AND nvl(fnd_number.canonical_to_number(gad.attribute1),0) > 0 '
      -- sowsubra B4629277 changed to_number to fnd_number.canonical_to_number
      ||'   AND gao.batch_id = :pbatch1 '
      ||'   AND gme.batchstep_resource_id =gad.attribute9 '     ;  --Bug: 8616967 Vpedarla

   gmp_debug_message('rsrc_tran_cursor -'||rsrc_tran_cursor);

    IF (areturn_status >= 0 ) THEN
    rtran_cnt  := 1 ;
   -- Changes for Resource Instances
    OPEN cur_rsrc_tran FOR rsrc_tran_cursor USING
         p_group_id, p_header_id, p_batch_id ;
    LOOP
      FETCH cur_rsrc_tran INTO rsrc_tran_tab(rtran_cnt);
      EXIT WHEN cur_rsrc_tran%NOTFOUND;
      l        := 1 ;
      end_tran := rsrc_tran_tab(rtran_cnt).assigned_units ;

        FOR l in 1..end_tran
        LOOP       /* Expansion Loop starts */

        -- For R12.0
      log_message(rsrc_tran_tab(rtran_cnt).parent_seq_num || '-' ||
          rsrc_tran_tab(rtran_cnt).resource_instance_id ) ;
        IF (rsrc_tran_tab(rtran_cnt).parent_seq_num IS NOT NULL) AND
            (rsrc_tran_tab(rtran_cnt).resource_instance_id IS NOT NULL) THEN
           t_seq_dep_ind := 1 ;
        ELSE
           t_seq_dep_ind := 0 ;
        END IF ;
    gmp_debug_message(rsrc_tran_tab(rtran_cnt).resource_hour ||'**'||rsrc_tran_tab(rtran_cnt).aps_uom_code );
               --  bug: 8616967 added the below code to convert usage from APS_UOM_CODE to GME_UOM_CODE.
                     IF ( rsrc_tran_tab(rtran_cnt).aps_uom_code <> rsrc_tran_tab(rtran_cnt).gme_usage_uom) THEN
                          rsrc_tran_tab(rtran_cnt).resource_hour := inv_convert.inv_um_convert(
                                        rsrc_tran_tab(rtran_cnt).Product_item ,
                                        NULL,
                                        rsrc_tran_tab(rtran_cnt).ORGANIZATION_ID,
                                        5,
                                        rsrc_tran_tab(rtran_cnt).resource_hour,
                                        rsrc_tran_tab(rtran_cnt).aps_uom_code,
                                        rsrc_tran_tab(rtran_cnt).gme_usage_uom,
                                        NULL,
                                        NULL);
                     END IF;
    gmp_debug_message(rsrc_tran_tab(rtran_cnt).resource_hour ||'**'||rsrc_tran_tab(rtran_cnt).gme_usage_uom );
        update_resource_transactions(
          p_batch_id,
          rsrc_tran_tab(rtran_cnt).batchstep_resource_id,
          rsrc_tran_tab(rtran_cnt).organization_id,     -- For R12.0
       --   (rsrc_tran_tab(rtran_cnt).resource_hour/end_tran),   --  bug: 8616967 vpedarla
          rsrc_tran_tab(rtran_cnt).resource_hour,
          rsrc_tran_tab(rtran_cnt).aps_resource,
          rsrc_tran_tab(rtran_cnt).start_date,
          rsrc_tran_tab(rtran_cnt).completion_date,
          rsrc_tran_tab(rtran_cnt).gme_usage_uom ,
          rsrc_tran_tab(rtran_cnt).resource_instance_id , -- For R12.0
          t_seq_dep_ind,                                  -- For R12.0
          p_user_id,
          p_login_id,
          treturn_status );

          IF treturn_status < 0 THEN
             EXIT;
          END IF ;

        END LOOP;    /* Expansion Loop Ends */

        rtran_cnt := rtran_cnt + 1;

        IF treturn_status < 0 THEN
           fnd_message.set_name('GMP','GMP_RSRC_TRANS_UPDATE_FAIL');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Update to Resource Transaction is failed' ;
           EXIT;
        END IF ;

    END LOOP;
    CLOSE cur_rsrc_tran;
    time_stamp;
    rtran_cnt := rtran_cnt - 1;
    log_message(' Resource Transaction size is = ' || to_char(rtran_cnt)) ;
    IF rtran_cnt = 0 THEN
       treturn_status     := 0 ;
    END IF;

    IF (treturn_status >= 0) THEN
      update_materails( p_batch_id,
                      p_organization_id,
                      mreturn_status) ;

      IF mreturn_status < 0 THEN
        fnd_message.set_name('GMP','GMP_MATL_UPDATE_FAIL');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Materail Update is failed' ;
      END IF ;
    END IF ;

   -- Charge information
      Insert_charges( p_batch_id,
                      p_group_id ,
                      p_header_id,
                      xreturn_status) ;

        IF xreturn_status < 0 THEN
           fnd_message.set_name('GMP','GMP_RSRC_CHRGS_UPDATE_FAIL');
           fnd_msg_pub.add ;
           e_msg := e_msg || ' Charges Insert is failed' ;
        END IF ;

    END IF;   /* end if for areturn_status */

    IF vreturn_status < 0 THEN
       return_status := vreturn_status ;
       ROLLBACK TO SAVEPOINT Before_Main_Program ;
    ELSIF lreturn_status < 0 THEN
       return_status := lreturn_status ;
       ROLLBACK TO SAVEPOINT Before_Main_Program ;
    ELSIF breturn_status < 0 THEN
       return_status := breturn_status ;
       ROLLBACK TO SAVEPOINT Before_Main_Program ;
    ELSIF sreturn_status < 0 THEN
       return_status := sreturn_status ;
       ROLLBACK TO SAVEPOINT Before_Main_Program ;
    ELSIF rreturn_status < 0 THEN
       return_status := rreturn_status ;
       ROLLBACK TO SAVEPOINT Before_Main_Program ;
    ELSIF areturn_status < 0 THEN
       return_status := areturn_status ;
       ROLLBACK TO SAVEPOINT Before_Main_Program ;
    ELSIF treturn_status < 0 THEN
       return_status := treturn_status ;
       log_message('TR = ' || treturn_status);
       ROLLBACK TO SAVEPOINT Before_Main_Program ;
    ELSIF xreturn_status < 0 THEN
       return_status := xreturn_status ;
       log_message('XR = ' || xreturn_status);
       ROLLBACK TO SAVEPOINT Before_Main_Program ;
    ELSIF mreturn_status < 0 THEN    -- For R12.0
       return_status := mreturn_status ;
       log_message('MR = ' || mreturn_status);
       ROLLBACK TO SAVEPOINT Before_Main_Program ;
    ELSE
       log_message('Writer success - '||p_batch_id);
     IF p_action_type <> 1 THEN
     -- Reschedule form is not calling GME routine and hence once
     -- the batch is updated successfully, then processed_ind = 0
       UPDATE gmp_aps_output_tbl
          SET processed_ind = 0
        WHERE batch_id = p_batch_id
          AND process_id = p_group_id
          AND header_id = p_header_id ;
     END IF;

       return_status :=  0 ;
     COMMIT ;
    END IF;
     return_msg := e_msg ;

   EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','main_process');
     e_msg := e_msg || ' Main Porgam Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
     return_status := -99 ;
     return_msg := e_msg ;
END main_process ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    update_step_resources                                                |
REM| DESCRIPTION                                                             |
REM|    This procedure will update the step resources plan start and end date|
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM+=========================================================================+
*/
PROCEDURE update_step_resources(
  pbatch_id              IN  NUMBER,
  porganization_id       IN  NUMBER,    -- For R12.0
  pstep_resource_id      IN  NUMBER,
  prsrc_usage            IN  NUMBER,
  psequence_dep_usage    IN  NUMBER,    -- For R12.0
  pgme_resource          IN  VARCHAR2,
  paps_resource          IN  VARCHAR2,
  pstart_date            IN  DATE,
  pend_date              IN  DATE,
  pbs_usage_uom          IN  VARCHAR2,  -- Gme UOM code
  passigned_unit         IN  NUMBER,
  paps_data_use          IN  NUMBER,
  psetup_id              IN  NUMBER,    -- For R12.0
  pgroup_sequence_id     IN  NUMBER,    -- For R12.0
  pgroup_sequence_number IN  NUMBER,    -- For R12.0
  pfirm_flag             IN  NUMBER,    -- For R12.0
  pscale_type            IN  NUMBER,    -- For R12.0
  puser_id               IN  NUMBER,
  plogin_id              IN  NUMBER,
  pnew_act_res           OUT NOCOPY NUMBER,
  return_status          OUT NOCOPY NUMBER )
IS

  v_batch_id         NUMBER ;
  v_organization_id  NUMBER ;         -- For R12.0
  v_step_resource_id NUMBER ;
  v_resource_id      NUMBER ;
  v_end_date         DATE ;
  temp_date          DATE ;

  v_o_resources      VARCHAR2(16) ;
  v_n_resources      VARCHAR2(16) ;
  v_uom_code         VARCHAR2(3)  ;
  v_rsrc_usage       NUMBER ;
  v_assigned_unit    NUMBER ;

  v_in_step_res_row gme_batch_step_resources%ROWTYPE;  /* Added for NOCOPY */
  v_step_res_row gme_batch_step_resources%ROWTYPE;

  l            INTEGER ;
  tran_status  NUMBER  ;

BEGIN

    v_batch_id   := 0;
    l            := 1;
    tran_status  := -1 ;
    return_status := 0;

    gme_common_pvt.set_timestamp ;
    gme_common_pvt.g_timestamp  := sysdate ;
    gme_common_pvt.g_user_ident := puser_id;
    gme_common_pvt.g_login_id   := plogin_id;
    v_batch_id                  := pbatch_id;
    v_organization_id   := porganization_id ; -- For R12.0
    v_rsrc_usage        := prsrc_usage;
    v_assigned_unit     := passigned_unit;
    v_step_resource_id  := pstep_resource_id ;
    v_o_resources       := pgme_resource;
    v_n_resources       := paps_resource;
    v_uom_code          := pbs_usage_uom ;
    v_end_date          := pend_date ;
    temp_date           := NULL;
    v_in_step_res_row.batchstep_resource_id := -1;

     -- Delete resource transactions for current batchstep resource */
     DELETE gme_resource_txns
      WHERE doc_id = v_batch_id
        AND resource_usage > 0
        AND line_id= v_step_resource_id ;

     IF v_o_resources = v_n_resources THEN
        pnew_act_res  := v_step_resource_id ;

log_message(' updaing gme_batch_step_resources ');

       IF paps_data_use = 0  THEN
       -- APS way
        UPDATE gme_batch_step_resources
        SET
            plan_start_date = pstart_date,
            plan_cmplt_date = pend_date,
            plan_rsrc_usage = prsrc_usage,
            plan_rsrc_count = v_assigned_unit,
            sequence_dependent_id = psetup_id ,             -- For R12.0
            sequence_dependent_usage = psequence_dep_usage, -- For R12.0
            group_sequence_id = pgroup_sequence_id ,        -- For R12.0
            group_sequence_number = pgroup_sequence_number ,-- For R12.0
            firm_type = pfirm_flag ,                       -- For R12.0
            scale_type = pscale_type ,                     -- For R12.0
            last_update_date = SYSDATE,
            last_updated_by = puser_id
        WHERE
            batchstep_resource_id = v_step_resource_id;

       ELSE
       -- GME way
        UPDATE gme_batch_step_resources
        SET
            plan_start_date = pstart_date,
            plan_cmplt_date = pend_date,
            sequence_dependent_id = psetup_id ,             -- For R12.0
            sequence_dependent_usage = psequence_dep_usage, -- For R12.0
            group_sequence_id = pgroup_sequence_id ,        -- For R12.0
            group_sequence_number = pgroup_sequence_number ,-- For R12.0
            firm_type = pfirm_flag ,                       -- For R12.0
            scale_type = pscale_type ,                      -- For R12.0
            last_update_date = SYSDATE,
            last_updated_by = puser_id
        WHERE
            batchstep_resource_id = v_step_resource_id;

       END IF ;   /* APS data Use */

        IF SQL%NOTFOUND THEN
            return_status := -1;
        END IF;
       -- Transaction will be modified later
     ELSE
         -- Alternate resource
        v_in_step_res_row.batchstep_resource_id := v_step_resource_id;

        IF NOT GME_BATCH_STEP_RESOURCES_DBL.fetch_row(v_in_step_res_row,
               v_step_res_row) THEN
          return_status := -2;
        ELSE
           v_step_res_row.plan_start_date := pstart_date;
           v_step_res_row.plan_cmplt_date := pend_date;
           v_step_res_row.resources       := v_n_resources;
           -- For R12.0
           v_in_step_res_row.organization_id := porganization_id;
           v_step_res_row.sequence_dependent_id := psetup_id ;
           v_step_res_row.sequence_dependent_usage := psequence_dep_usage ;
           v_step_res_row.plan_rsrc_usage := prsrc_usage;
           v_step_res_row.group_sequence_id := pgroup_sequence_id;
           v_step_res_row.group_sequence_number := pgroup_sequence_number;
           v_step_res_row.firm_type  := pfirm_flag ;
           v_step_res_row.scale_type  := pscale_type ;

           IF paps_data_use = 0  THEN
              -- APS count may be different from GME
              v_step_res_row.plan_rsrc_count := v_assigned_unit;
           END IF ;

           temp_date := pstart_date + ((v_rsrc_usage/24) / v_assigned_unit ) ;

           IF (temp_date > v_end_date) THEN
               return_status := -3;
               fnd_message.set_name('GMP','GMP_SEND_GREATER_START');
               fnd_msg_pub.add ;
               e_msg := e_msg || ' Step End date greater than start date.';

           END IF;

           DELETE gme_batch_step_resources
            WHERE batchstep_resource_id = v_step_resource_id;

           IF SQL%NOTFOUND THEN
               return_status := -4;
           ELSE
              IF NOT GME_BATCH_STEP_RESOURCES_DBL.insert_row
                 (v_step_res_row, v_in_step_res_row) THEN
                     return_status := -5;
              ELSE
                   pnew_act_res  := v_in_step_res_row.batchstep_resource_id;
              END IF;

           END IF;  /* Delete NOTFOUND */

        END IF; /* fetch_row */

     END IF;  /* v_o_resources */

     IF (v_rsrc_usage > 0 AND return_status = 0 AND paps_data_use <> 0 ) THEN
     -- GME way, only if usage is greater than Zero
        l          := 1 ;
        v_rsrc_usage := (v_rsrc_usage / v_assigned_unit) ;
        v_end_date   :=  pstart_date + (v_rsrc_usage/24) ;

        FOR l in  1..v_assigned_unit
        LOOP                          /* Expansion Loop starts */
            update_resource_transactions(
             v_batch_id       ,
             pnew_act_res     ,
             v_organization_id,  -- For R12.0
             v_rsrc_usage     ,
             v_n_resources    ,  -- alternate or auxillary
             pstart_date      ,
             v_end_date       ,
             v_uom_code       ,  -- Changed from 3 char to 4 character
             NULL             ,  -- Resource Instance Id
             0                ,  -- Sequence Depdent Indicator
             puser_id         ,
             plogin_id        ,
             tran_status );

             IF tran_status < 0 THEN
                fnd_message.set_name('GMP','GMP_RSRC_TRANS_UPDATE_FAIL');
                fnd_msg_pub.add ;
                e_msg := e_msg || ' Failed: Resource Transaction' ;
                return_status := -6 ;
                EXIT;
             ELSE
                return_status := 0 ;
             END IF ;

        END LOOP ;                  /* Expansion Loop ends */
     END IF ;  /* return status */

  EXCEPTION
   WHEN OTHERS THEN
     return_status := -96;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','update_step_resources');
     e_msg := e_msg || ' Update Step Resources Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
END update_step_resources;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    update_resource_transactions                                         |
REM| DESCRIPTION                                                             |
REM|    This procedure will update the resource instance start and end date  |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM+=========================================================================+
*/
PROCEDURE update_resource_transactions(
  pbatch_id        IN  NUMBER,
  pbstep_rsrc_id   IN  NUMBER,
  porganization_id IN NUMBER,    -- For R12.0
  prsrc_hour       IN  NUMBER,
  paps_resource    IN  VARCHAR2,
  pstart_date      IN  DATE,
  pend_date        IN  DATE,
  puom_code        IN  VARCHAR2,
  prsrc_inst_id    IN  NUMBER,   -- For R12.0 resource_instance_id
  pseq_dep_ind     IN  NUMBER,   -- For R12.0 sequence dependent
  puser_id         IN  NUMBER,
  plogin_id        IN  NUMBER,
  return_status    OUT NOCOPY NUMBER ) IS

  v_in_trans_row gme_resource_txns%ROWTYPE;   /* Added for NOCOPY */
  v_trans_row gme_resource_txns%ROWTYPE;
  l_doc_type       VARCHAR2(5);
BEGIN
  return_status := 0;
  /* B5470072, Resource Transaction should have doc_type of FPO */
  BEGIN
    SELECT DECODE(nvl(batch_type,0),0,'PROD',10,'FPO') into l_doc_type
    FROM gme_batch_header where batch_id = pbatch_id ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     l_doc_type := 'PROD' ;
  END ;

      v_in_trans_row.line_id           := pbstep_rsrc_id;
      v_in_trans_row.organization_id   := porganization_id ;  -- For R12.0
      v_in_trans_row.doc_type          := l_doc_type ;
      v_in_trans_row.doc_id            := pbatch_id;
      v_in_trans_row.line_type         := 0;
      v_in_trans_row.resources         := paps_resource;
     -- Resource_hour populated in ATTRIBUTE1 column of WIP detail
     -- by APS is used as resource usage for transaction
      v_in_trans_row.resource_usage    := prsrc_hour;
      v_in_trans_row.TRANS_QTY_UM      := puom_code;  -- For R12.0 (4 character)
      v_in_trans_row.trans_date        := pstart_date;
      v_in_trans_row.completed_ind     := 0;
      v_in_trans_row.posted_ind        := 0;
      v_in_trans_row.start_date        := pstart_date;
      v_in_trans_row.end_date          := pend_date;
      v_in_trans_row.creation_date     := SYSDATE;
      v_in_trans_row.last_update_date  := SYSDATE;
      v_in_trans_row.created_by        := puser_id;
      v_in_trans_row.last_updated_by   := puser_id;
      v_in_trans_row.last_update_login := plogin_id;
      v_in_trans_row.instance_id       := prsrc_inst_id;      -- For R12.0
      v_in_trans_row.delete_mark       := 0;
      v_in_trans_row.sequence_dependent_ind := pseq_dep_ind ; -- For R12.0
      v_in_trans_row.overrided_protected_ind := 'N';
      gme_common_pvt.set_timestamp ;
      gme_common_pvt.g_timestamp       := sysdate ;
      gme_common_pvt.g_user_ident      := puser_id;
      gme_common_pvt.g_login_id        := plogin_id;

    -- This is not going to change For R12.0
        IF NOT gme_resource_txns_dbl.insert_row
                  (v_in_trans_row, v_trans_row) THEN
          return_status := -1;
        ELSE
          return_status := 0;
        END IF;

  EXCEPTION
   WHEN OTHERS THEN
     return_status := -97;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','update_resource_transactions');
     e_msg := e_msg || ' Update SResource Transaction Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
END update_resource_transactions;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    update_batch_activities                                              |
REM| DESCRIPTION                                                             |
REM|    This procedure will update the activity plan start and end date      |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM+=========================================================================+
*/
PROCEDURE update_batch_activities(
  pbatch_id        IN  NUMBER,
  porganization_id IN  NUMBER,   -- For R12.0
  pstep_id         IN  NUMBER,
  pactivity_id     IN  NUMBER,
  pstart_date      IN  DATE,
  pend_date        IN  DATE,
  puom_hour        IN  VARCHAR2,
  puser_id         IN  NUMBER,
  plogin_id        IN  NUMBER,
  return_status    OUT NOCOPY NUMBER)
IS

  v_activity_id      NUMBER ;
  v_step_id          NUMBER ;
  v_batch_id         NUMBER ;
  found              NUMBER ;
  v_trn_start_date   DATE ;
  v_trn_end_date     DATE ;
  v_start_date       DATE ;
  v_end_date         DATE ;
  v_hour_uom         VARCHAR2(3) ;
  v_organization_id  NUMBER ;
  v_zero_res_id     NUMBER ;
  v_offset_interval NUMBER ;
  temp_date         DATE ;

  v_trans_row gme_resource_txns%ROWTYPE;

  -- Activities, its resources and resource transactions with ZERO usage
  -- or not convertible UOM
  CURSOR get_zero_non_usage IS
    SELECT
      gsr.batchstep_resource_id, gsr.resources, gsr.plan_rsrc_count,
      DECODE(gsr.plan_rsrc_usage, 0, 0, inv_convert.inv_um_convert(-1,38,
        gsr.plan_rsrc_usage,u2.uom_code,u1.uom_code,NULL,NULL)) plan_rsrc_usage,
      gsr.offset_interval,
      gsr.plan_start_date,
      gsr.plan_cmplt_date,
      crd.schedule_ind
    FROM
      gme_batch_step_resources gsr,
      cr_rsrc_dtl crd,
      mtl_units_of_measure u1,
      mtl_units_of_measure u2
    WHERE
          gsr.batchstep_activity_id = v_activity_id
      AND crd.resources = gsr.resources    -- For R12.0
      AND crd.organization_id = v_organization_id -- For R12.0
      AND gsr.organization_id = crd.organization_id -- For R12.0
      AND crd.delete_mark = 0              -- For R12.0
      AND u1.uom_code = gsr.usage_um
      AND u2.uom_code = v_hour_uom
      AND (gsr.plan_rsrc_usage = 0 OR
           u1.uom_class <> u2.uom_class OR
           crd.schedule_ind = 3 );        -- For R12.0
BEGIN
  return_status  := 0;
  v_activity_id  := pactivity_id;
  v_step_id      := pstep_id;
  v_batch_id     := pbatch_id;
  v_start_date   := pstart_date ;
  v_end_date     := pend_date ;
  v_organization_id  := porganization_id ;
  found              := 0;
  v_trn_start_date   := NULL;
  v_trn_end_date     := NULL;
  v_hour_uom         := NULL;
  v_zero_res_id      := 0;
  v_offset_interval  := 0;
  temp_date          := NULL;

  UPDATE gme_batch_step_activities
  SET
     plan_start_date  = v_start_date,
     plan_cmplt_date  = v_end_date,
     last_update_date = SYSDATE,
     last_updated_by  = puser_id
  WHERE batchstep_activity_id = v_activity_id;

    IF SQL%NOTFOUND THEN
      return_status := -1;
    ELSE
      v_hour_uom := puom_hour;
      FOR v_zero IN get_zero_non_usage LOOP
          v_zero_res_id     := v_zero.batchstep_resource_id;
          v_offset_interval := v_zero.offset_interval/24;
          found := 0;

          IF v_zero.plan_rsrc_usage = 0 THEN

            temp_date := v_start_date + v_offset_interval;
            IF temp_date > v_end_date THEN
              v_offset_interval := 0;
            END IF;

            v_trn_start_date := v_start_date + v_offset_interval;
            v_trn_end_date   := v_start_date + v_offset_interval;

            UPDATE
              gme_batch_step_resources
            SET
              plan_start_date  = v_trn_start_date,
              plan_cmplt_date  = v_trn_end_date,
              last_update_date = SYSDATE,
              last_updated_by  = puser_id
            WHERE
              batchstep_resource_id = v_zero_res_id;

            IF SQL%NOTFOUND THEN
              return_status := -2;
            ELSE
              found := 1;
            END IF;
          ELSIF v_zero.plan_rsrc_usage < 0 THEN

           -- Delete resource transactions for sequence depedent Usage */
           DELETE gme_resource_txns
            WHERE doc_id = v_batch_id
              AND nvl(sequence_dependent_ind,0) > 0
              AND line_id=  v_zero_res_id ;

            v_trn_start_date := v_start_date;
            v_trn_end_date   := v_end_date;

            UPDATE
              gme_batch_step_resources
            SET
              plan_start_date  = v_trn_start_date,
              plan_cmplt_date  = v_trn_end_date,
              last_update_date = SYSDATE,
              last_updated_by  = puser_id
            WHERE
              batchstep_resource_id = v_zero_res_id;

            IF SQL%NOTFOUND THEN
              return_status := -3;
            ELSE
              found := 1;
            END IF;

          ELSIF (v_zero.plan_rsrc_usage > 0 AND v_zero.schedule_ind = 3) THEN
          -- DO NOT PLAN resource, we do not apply offset, start and end date
          -- must fall between activity used
            temp_date := v_start_date +
             ( (v_zero.plan_rsrc_usage / v_zero.plan_rsrc_count) / 24 ) ;

           IF temp_date > v_end_date THEN
             fnd_message.set_name('GMP','GMP_USER_RSRC');
             fnd_msg_pub.add ;
             e_msg := e_msg || ' User must maintain the DO NOT PLAN resource dates. ' || v_zero.resources;
           ELSE

           -- Delete resource transactions for sequence depedent Usage */
           DELETE gme_resource_txns
            WHERE doc_id = v_batch_id
              AND nvl(sequence_dependent_ind,0) > 0
              AND line_id=  v_zero_res_id ;

            v_trn_start_date := v_start_date ;
            v_trn_end_date   := temp_date ;

            UPDATE
              gme_batch_step_resources
            SET
              plan_start_date  = v_trn_start_date,
              plan_cmplt_date  = v_trn_end_date,
              last_update_date = SYSDATE,
              last_updated_by  = puser_id
            WHERE
              batchstep_resource_id = v_zero_res_id;

            IF SQL%NOTFOUND THEN
              return_status := -5;
            ELSE
              found := 1;
            END IF;

           END IF;   /* Date check */
          END IF;

          IF found = 1 THEN
            UPDATE
              gme_resource_txns
            SET
              start_date       = v_trn_start_date,
              end_date         = v_trn_end_date,
              trans_date       = v_trn_start_date,
              last_update_date = SYSDATE,
              last_updated_by  = puser_id,
              instance_id      = NULL,
              delete_mark      = 0,
              sequence_dependent_ind  = 0,
              overrided_protected_ind = 'N',
              last_update_login = plogin_id
            WHERE
                  doc_id = v_batch_id
              AND doc_type in ('PROD','FPO')
              AND line_id = v_zero_res_id
              AND completed_ind = 0
              AND delete_mark = 0;

            IF SQL%NOTFOUND THEN
              return_status := -6;
            END IF;

          END IF;  /* found */

        END LOOP;

    END IF; /* Not found */
  EXCEPTION
    WHEN OTHERS THEN
      return_status := -98;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','update_batch_activities');
     e_msg := e_msg || ' Update Step Activities Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
END update_batch_activities;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    update_materails                                                     |
REM| DESCRIPTION                                                             |
REM|    This procedure will update the Materail deatails as per GME rules    |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM| If the item is associated to step and NOT having release_type of        |
REM| Automatic (0) in the material detail then the step's plan_start_date    |
REM| will be used for all ingredients (line_type= -1) and plan_cmplt_date    |
REM| for all products and byproducts (line_type = 1 or 2).                   |
REM| If the item is not associated to step OR Item is associated to step and |
REM| having release_type of Automatic (0) in the material detail then the    |
REM| batch's plan_start_date will be used for all ingredients (line_type= -1)|
REM| and plan_cmplt_date for all products and byproducts (line_type = 1 or 2)|
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE update_materails (
  pbatch_id          IN  NUMBER,
  porganization_id   IN  NUMBER,
  return_status      OUT NOCOPY NUMBER)
IS

  v_batch_id           NUMBER ;
  v_organization_id    NUMBER ;
  v_material_detail_id NUMBER ;
  v_line_type          NUMBER ;
  m_return_status      VARCHAR2(1);

  CURSOR get_step_material IS
    SELECT gmd.material_detail_id, gmd.line_type
      FROM gme_material_details gmd
    WHERE gmd.batch_id        = v_batch_id
      AND gmd.organization_id = v_organization_id ;

BEGIN
    return_status        := 0;
    m_return_status      := NULL;
    v_batch_id           := pbatch_id;
    v_organization_id    := porganization_id;
    v_material_detail_id := 0;
    v_line_type          := 0;

    -- API will check the step and materail association for the batch and
    -- decide the materail requirement date should be step start/End OR
    -- Batch start/End Date. This will also ensures the further impact on
    -- Move order and allocations for the batch.

        OPEN get_step_material;
        LOOP
          FETCH get_step_material INTO v_material_detail_id, v_line_type;
          EXIT WHEN get_step_material%NOTFOUND;

          gme_api_grp.update_material_date(
             v_material_detail_id,  --  p_material_detail_id,
             NULL,                  --  p_material_date
             m_return_status);

          IF m_return_status = 'S' THEN
             return_status := 0 ;
          ELSE
            -- Basically E and U
           return_status := -19;
           EXIT ;
          END IF;

        END LOOP;
        CLOSE get_step_material;
  EXCEPTION
    WHEN OTHERS THEN
     return_status := -89;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','update_materails');
     e_msg := e_msg || ' Update Materails Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
END update_materails;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    update_batch_steps                                                   |
REM| DESCRIPTION                                                             |
REM|    This procedure will update the step plan start and end date          |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE update_batch_steps(
  pbatch_id      IN  NUMBER,
  pstep_no       IN  NUMBER,
  pstep_id       IN  NUMBER,
  pstart_date    IN  DATE,
  pend_date      IN  DATE,
  pdue_date      IN  DATE,     --  B5454215
  puser_id       IN  NUMBER,
  plogin_id      IN  NUMBER,
  return_status  OUT NOCOPY NUMBER)
IS

  v_plan_charges     NUMBER ;

BEGIN
    return_status  := 0;
    v_plan_charges := 0;

   -- For R12.0
   BEGIN
       SELECT count(*) INTO v_plan_charges
       FROM
         gmp_aps_output_dtl gad,
         gme_batch_steps gbs
       WHERE gad.wip_entity_id = pbatch_id
         AND gad.load_type = 10
         AND gbs.batch_id = gad.wip_entity_id
         AND gbs.batchstep_no = pstep_no
         AND gbs.batchstep_no = gad.operation_seq_num
         AND gbs.delete_mark = 0
         AND gbs.step_status = 1  ;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       v_plan_charges := 0;
    WHEN OTHERS THEN
     return_status := -995;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','update_batch_steps');
     e_msg := e_msg || ' CHARGE in Step Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
    END;

    IF pdue_date IS NOT NULL THEN
    -- For New Batch only  B5454215

    IF v_plan_charges <> 0 THEN

    UPDATE gme_batch_steps
    SET plan_start_date  = pstart_date,
        plan_cmplt_date  = pend_date,
        due_date         = pdue_date,
        -- For R12.0
        plan_charges     = DECODE(step_status,1,v_plan_charges,plan_charges),
        last_update_date = SYSDATE,
        last_updated_by  = puser_id
    WHERE batch_id       = pbatch_id
      AND batchstep_no   = pstep_no
      AND batchstep_id   = pstep_id ;

    ELSE

    UPDATE gme_batch_steps
    SET plan_start_date  = pstart_date,
        plan_cmplt_date  = pend_date,
        -- For R12.0
        due_date         = pdue_date,
        last_update_date = SYSDATE,
        last_updated_by  = puser_id
    WHERE batch_id       = pbatch_id
      AND batchstep_no   = pstep_no
      AND batchstep_id   = pstep_id ;

    END IF;  /* Plan Charges */

    ELSE

    IF v_plan_charges <> 0 THEN

    UPDATE gme_batch_steps
    SET plan_start_date  = pstart_date,
        plan_cmplt_date  = pend_date,
        -- For R12.0
        plan_charges     = DECODE(step_status,1,v_plan_charges,plan_charges),
        last_update_date = SYSDATE,
        last_updated_by  = puser_id
    WHERE batch_id       = pbatch_id
      AND batchstep_no   = pstep_no
      AND batchstep_id   = pstep_id ;

    ELSE

    UPDATE gme_batch_steps
    SET plan_start_date  = pstart_date,
        plan_cmplt_date  = pend_date,
        last_update_date = SYSDATE,
        last_updated_by  = puser_id
    WHERE batch_id       = pbatch_id
      AND batchstep_no   = pstep_no
      AND batchstep_id   = pstep_id ;

    END IF;  /* Plan Charges */

    END IF;  /* v_due_date */

      IF SQL%NOTFOUND THEN
         return_status := -11;
      END IF;  /* Not found */

  EXCEPTION
    WHEN OTHERS THEN
     return_status := -95;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','update_batch_steps');
     e_msg := e_msg || ' Update Batch Step Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
END update_batch_steps;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    update_batch_header                                                  |
REM| DESCRIPTION                                                             |
REM|    This procedure will update the batch plan start and end date         |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE update_batch_header(
  pbatch_id            IN  NUMBER,
  pstart_date          IN  DATE,
  pend_date            IN  DATE,
  preq_completion_date IN  DATE,    -- For R12.0
  pord_priority        IN  NUMBER,  -- For R12.0
  pbatch_status        IN  NUMBER,
  pfirm_flag           IN  NUMBER,   -- B5897392
  puser_id             IN  NUMBER,
  plogin_id            IN  NUMBER,
  return_status        OUT NOCOPY NUMBER)
IS

  v_batch_status     NUMBER ;

BEGIN
  return_status  := 0;
  v_batch_status := pbatch_status ;

  IF v_batch_status = 1 THEN
    -- pending
    -- Only Update the new batch with due_date informnation,
    -- otherwise take the same date what GME have, basically reschedule batch
    UPDATE gme_batch_header
    SET
      plan_start_date   = pstart_date,
      plan_cmplt_date   = pend_date,
      due_date          = NVL(preq_completion_date,gme_batch_header.due_date),
      order_priority    = NVL(pord_priority,gme_batch_header.order_priority),
      firmed_ind        = pfirm_flag,   -- B5897392
      last_update_date  = SYSDATE,
      last_updated_by   = puser_id,
      last_update_login = plogin_id
--      finite_scheduled_ind = 1   /*B5186781*/
    WHERE batch_id = pbatch_id;
  ELSE
    -- In Wip status
    -- No changes for WIP batch for due_date informnation
    UPDATE gme_batch_header
    SET
      plan_cmplt_date   = pend_date,
       -- Vpedarla Bug: 8348883 added the below line to enable update of due date for batches in WIP status.
      due_date          = NVL(preq_completion_date,gme_batch_header.due_date),
      order_priority    = NVL(pord_priority,gme_batch_header.order_priority),
      firmed_ind        = pfirm_flag,   -- B5897392
      last_update_date  = SYSDATE,
      last_updated_by   = puser_id,
      last_update_login = plogin_id
--      finite_scheduled_ind = 1   /*B5186781*/
    WHERE batch_id = pbatch_id;
  END IF;

    IF SQL%NOTFOUND THEN
      return_status := -12;
    END IF;  /* Not found */

  EXCEPTION
    WHEN OTHERS THEN
     return_status := -94;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','update_batch_header');
     e_msg := e_msg || ' Update Batch Header Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
END update_batch_header;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    lock_batch_details                                                   |
REM| DESCRIPTION                                                             |
REM|    This procedure will select for update all of the batch details       |
REM|    except for the transactions.                                         |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM+=========================================================================+
*/
PROCEDURE lock_batch_details(
  pbatch_id          IN  NUMBER,
  pbatch_status      OUT NOCOPY NUMBER,
  pbatch_last_update OUT NOCOPY DATE,
  return_status      OUT NOCOPY NUMBER)
IS

  l_batch_id     NUMBER ;
  l_batch_status NUMBER ;
  l_batch_last_update DATE ;

  v_batch_id     NUMBER ;
  found          NUMBER ;

  /* lock the batch header being updated */
  CURSOR lock_batch_header IS
    SELECT
      batch_id, batch_status, last_update_date
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

  l_batch_id     := 0;
  l_batch_status := 0;
  l_batch_last_update := NULL;
  found          := 0;

  return_status := 0;
  v_batch_id    := pbatch_id;

  OPEN lock_batch_header;
  LOOP
    FETCH lock_batch_header INTO l_batch_id, l_batch_status,
          l_batch_last_update;
    EXIT WHEN lock_batch_header%NOTFOUND;
    pbatch_status      := l_batch_status ;
    pbatch_last_update := l_batch_last_update;
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
      return_status := -2;
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
        return_status := -3;
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
          return_status := -4;
        END IF;
      END IF;
    END IF;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
     return_status := -92;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','lock_batch_details');
     e_msg := e_msg || ' Loocking Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
END lock_batch_details;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    validate_structure                                                   |
REM| DESCRIPTION                                                             |
REM|    This procedure validate the structure for new batch with the APS     |
REM|    information coming back.                                             |
REM|    1. Number of Operations(Insert/Update/Delete                         |
REM|    2. Number of Activities(Insert/Update/Delete                         |
REM|    3. Number of resources (Insert/Update/Delete                         |
REM|    4. Change Recipe/Validity Rule OR Routing/formula header             |
REM| NOTE :                                                                  |
REM|    We are not validating materials overrides as per discussion          |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM| B3583620 - Rearranged the Group By clause and made unique in APS table  |
REM| Kaushek B                                                               |
REM| B6407903 - Used TRUNC for all the date columns used in the structure_cursor|
REM+=========================================================================+
*/
PROCEDURE validate_structure (
  pfmeff_id         IN NUMBER,
  porganization_id  IN  NUMBER,     -- For R12.0
  pgroup_id         IN NUMBER,
  pheader_id        IN NUMBER,
  struc_size        OUT NOCOPY NUMBER,
  return_status     OUT NOCOPY NUMBER)
IS

/* Local array definition */
  TYPE ref_cursor_typ IS REF CURSOR;

TYPE structure_typ IS RECORD
(
  recipe_id             NUMBER(16),
  formula_id            NUMBER(16),
  routing_id            NUMBER(16),
  routingstep_id        NUMBER(16),
  routingstep_no        NUMBER(8),
  oprn_id               NUMBER(16),
  oprn_line_id          NUMBER(16),
  oprn_no               VARCHAR2(40),
  activity              VARCHAR2(40),
  resource_seq_num      NUMBER(8),
  recipe_change         NUMBER(16),  -- For R12.0
  validity_rule_change  NUMBER(16),  -- For R12.0
  formula_header_change NUMBER(16),  -- For R12.0
  formula_detail_change NUMBER(16),  -- For R12.0
  routing_header_change NUMBER(16),  -- For R12.0
  rtg_detail_change     NUMBER(16),
  rtg_oper_change       NUMBER(16),
  rtg_activity_change   NUMBER(16),
  opm_resource_change   NUMBER(16),  -- This will be used as opm resource sum
  opm_oper_sum          NUMBER(16),
  opm_activity_sum      NUMBER(16),
  aps_opeartion_seq_num NUMBER(8),
  aps_resource_seq_num  NUMBER(8),
  aps_oper_sum          NUMBER(16),
  aps_resource_sum      NUMBER(16),
  aps_activity_sum      NUMBER(16)
);
TYPE structure_tbl IS TABLE OF structure_typ INDEX by BINARY_INTEGER;
structure_tab        structure_tbl;

structure_size     INTEGER;  /* Number of rows */

  cur_structure     ref_cursor_typ;
  structure_cursor  VARCHAR2(10000) ;

BEGIN

  return_status := 0 ;
  structure_cursor := NULL;

  -- Finally it is the summary of OPM and  APS information
   structure_cursor := ' SELECT opm.recipe_id, opm.formula_id, '
   ||'     opm.routing_id, opm.routingstep_id, opm.routingstep_no,   '
   ||'     opm.oprn_id, opm.oprn_line_id, opm.oprn_no, opm.activity,  '
   ||'     opm.resource_seq_num, opm.recipe_change, opm.validity_rule_change,'
   ||'     opm.formula_header_change, opm.formula_detail_change, '
   ||'     opm.routing_header_change, '
   ||'     opm.rtg_detail_change, opm.rtg_oper_change, '
   ||'     opm.rtg_activity_change, opm.opm_resource_change, '
   ||'     opm.opm_oper_sum, opm.opm_activity_sum,'
   ||'     aps.operation_seq_num, aps.resource_seq_num, '
   ||'     aps.aps_oper_sum, aps.aps_resource_sum, aps.aps_activity_sum '
   ||'     FROM (   '
   -- Find the count of routing operations, activity
   -- find the routing detail change, operation change, activity change
   ||'       SELECT recipe_id, formula_id, routing_id, routingstep_id,   '
   ||'       routingstep_no, oprn_id, oprn_line_id, activity, oprn_no ,  '
   ||'       seq_dep_ind resource_seq_num, '
   ||'       offset_interval,  '
   ||'       gr_last_date recipe_change,'
   ||'       ffe_last_date validity_rule_change, '
   ||'       ffm_last_date formula_header_change,'
   ||'       fmd_last_date formula_detail_change,'
   ||'       frh_last_date routing_header_change,'
   ||'       SUM(frd_last_date)  '
   ||'       OVER (PARTITION BY routing_id) rtg_detail_change ,  '
   ||'       SUM(fom_last_date)  '
   ||'       OVER (PARTITION BY routing_id) rtg_oper_change ,  '
   ||'       SUM(goa_last_date)  '
   ||'       OVER (PARTITION BY routing_id) rtg_activity_change ,  '
   ||'       opm_resource_change , '
   ||'       opm_oper_sum, '
    -- PS Issue B6045398, Activity count is incorrect
   ||'       COUNT(unique oprn_line_id) OVER (PARTITION BY   '
   ||'       routing_id,oprn_id ) opm_activity_sum '
   ||'       FROM ( '
   ||'          SELECT gr.recipe_id, gr.formula_id, gr.routing_id, '
   ||'          frd.routingstep_id, frd.routingstep_no, '
   ||'          nvl(goa.sequence_dependent_ind,0) seq_dep_ind, g1.gen_lupd, '
   ||'          goa.offset_interval, '
  -- B5714301, changed the position of operation count
   ||'       COUNT(unique frd.routingstep_no) OVER (PARTITION BY '
   ||'       gr.routing_id) opm_oper_sum, '
   --  Recipe/Validity Rule OR Routing/formula header changed
   ||'          DECODE(sign(g1.gen_lupd '
   ||'          - trunc(gr.last_update_date)), 1,1,0,1,-1,-600) gr_last_date,  '
   ||'          DECODE(sign(g1.gen_lupd '
   ||'          - trunc(ffe.last_update_date)), 1,1,0,1,-1,-600) ffe_last_date,'
   ||'          DECODE(sign(g1.gen_lupd '
   ||'          - trunc(ffm.last_update_date)), 1,1,0,1,-1,-600) ffm_last_date,  '
   ||'          ( SELECT sum(DECODE(sign(gen_lupd'
   ||'                       - trunc(fmd.last_update_date)), 1,1,0,1,-1,-600))'
   ||'            FROM fm_matl_dtl fmd '
   ||'            WHERE fmd.formula_id = gr.formula_id) fmd_last_date,'
   ||'          DECODE(sign(g1.gen_lupd '
   ||'          - trunc(frh.last_update_date)), 1,1,0,1,-1,-600) frh_last_date,  '
   ||'          DECODE(sign(g1.gen_lupd '
   ||'          - trunc(frd.last_update_date)), 1,1,0,1,-1,-600) frd_last_date, '
   ||'          fom.oprn_id, fom.oprn_no,'
   ||'          DECODE(sign(g1.gen_lupd '
   ||'          - trunc(fom.last_update_date)), 1,1,0,1,-1,-600) fom_last_date,  '
   ||'          goa.oprn_line_id, goa.activity, '
   ||'          DECODE(sign(g1.gen_lupd '
   ||'          - trunc(goa.last_update_date)), 1,1,0,1,-1,-600) goa_last_date, '
   ||'          nvl((SELECT SUM(DECODE(sign(g1.gen_lupd '
   ||'                          - trunc(gor.last_update_date)), 1,1,0,1,-1,-600))'
   ||'               FROM'
   ||'                  gmd_operation_resources gor,  '
   ||'                  cr_rsrc_dtl crd  '
   ||'               WHERE'
   ||'               goa.oprn_line_id = gor.oprn_line_id  '
   ||'               AND crd.organization_id = :porgid '  -- For R12.0
   ||'               AND crd.resources = gor.resources '  -- For R12.0
   ||'               AND crd.delete_mark = 0 '            -- For R12.0
   ||'               AND crd.schedule_ind <> 3 '  -- Do Not plan
/*
OPM is sending ZERO resource usages along with routing, if it is not a primary resource. APS is sending back these resources may be with usage or ZERO resource usage. We have to consider this resource for validation, but for final update
we have to use GME WAY to update this type of resource. This is only
applicable for NEW BATCH */
--   ||'               AND gor.resource_usage > 0'  -- Do Not plan R12
   ||'               GROUP BY gor.oprn_line_id  '
   ||'              ),0) opm_resource_change'
   ||'          FROM   '
   ||'                gmd_recipes_b gr,  '
   ||'                gmd_recipe_validity_rules ffe,  '
   ||'                fm_form_mst ffm,  '
   ||'                fm_rout_hdr frh,  '
   ||'                fm_rout_dtl frd ,  '
   ||'                gmd_operations fom,  '
   ||'                gmd_operation_activities goa,  '
    -- B6051303, PS Issue
   ||'                ( SELECT creation_date gen_lupd '
   ||'                 FROM GMP_APS_OUTPUT_TBL WHERE process_id = :pgrp1 '
   ||'                 AND header_id = :phdr1  ) g1 '
   ||'          WHERE gr.recipe_id  = ffe.recipe_id   '
   ||'            AND gr.routing_id = frh.routing_id  '
   ||'            AND gr.formula_id = ffm.formula_id  '
   ||'            AND frd.routing_id = gr.routing_id   '
   ||'            AND frd.oprn_id = fom.oprn_id  '
   ||'            AND fom.oprn_id = goa.oprn_id  '
   ||'            AND ffe.recipe_validity_rule_id = :eff1 '
   ||'             )  '
   ||'         WHERE opm_resource_change <> 0 '
   ||'       ) OPM ,  '
   ||'       (  '
   -- Query will take count at operation, activity for resources
   ||'         SELECT a.operation_seq_num, a.schedule_seq_num resource_seq_num,  '
   ||'         count(unique a.operation_seq_num) '   /* B3583620 */
   ||'         OVER (PARTITION BY b.process_id, b.header_id) aps_oper_sum, '
   ||'         count(unique a.schedule_seq_num)  '     /* B3583620 */
   ||'         OVER (PARTITION BY a.operation_seq_num ) aps_activity_sum, '
   ||'         count(a.resource_id_new)  '
   ||'         OVER (PARTITION BY a.operation_seq_num, '
   ||'         a.schedule_seq_num) aps_resource_sum '
   ||'         FROM  gmp_aps_output_dtl a,  '
   ||'               gmp_aps_output_tbl b  '
   ||'         WHERE a.parent_header_id = b.header_id  '
   ||'           AND a.group_id = b.process_id  '
   ||'           AND b.process_id = :pgrp2 '
   ||'           AND b.header_id = :phdr2 '
   ||'           AND b.effectivity_id = :eff2 '
   ||'           AND a.load_type = 1  '
   ||'           AND a.parent_seq_num IS NULL '
   ||'       ) APS  '
   ||'        WHERE opm.resource_seq_num(+) = aps.resource_seq_num '
   ||'          AND opm.routingstep_no(+)   = aps.operation_seq_num '
   ||'          AND opm.routingstep_no IS NOT NULL ' ;

   structure_size  := 1;
   OPEN cur_structure FOR structure_cursor USING
           porganization_id, pgroup_id, pheader_id, pfmeff_id,
           pgroup_id, pheader_id, pfmeff_id ;

   LOOP
   FETCH cur_structure INTO structure_tab(structure_size);
   EXIT WHEN cur_structure%NOTFOUND;

   gmp_debug_message(' Inside validate_structure Loop '||structure_size||' aps_resource_seq_num '||structure_tab(structure_size).aps_resource_seq_num|| ' aps_resource_seq_num '|| structure_tab(structure_size).aps_resource_seq_num );

      IF structure_tab(structure_size).recipe_change < 0  THEN
        fnd_message.set_name('GMP','GMP_RECIPE_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Recipe is Changed';
        return_status := -1 ;
        EXIT ;

      ELSIF structure_tab(structure_size).validity_rule_change < 0 THEN
        fnd_message.set_name('GMP','GMP_RECIPE_VR_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Recipe/Validity Rule changed' ;
        return_status := -1 ;
        EXIT ;

      ELSIF structure_tab(structure_size).formula_header_change < 0 THEN
        fnd_message.set_name('GMP','GMP_FORMULA_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Formula Header/detail is Changed ';
        return_status := -1 ;
        EXIT ;

      ELSIF structure_tab(structure_size).formula_detail_change < 0 THEN
        fnd_message.set_name('GMP','GMP_FORMULA_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Formula Header/detail is Changed ';
        return_status := -1 ;
        EXIT ;

      ELSIF structure_tab(structure_size).routing_header_change < 0 THEN
        fnd_message.set_name('GMP','GMP_ROUTING_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Routing Header is changed';
        return_status := -1 ;
        EXIT ;

      ELSIF structure_tab(structure_size).routingstep_no IS NULL THEN
        fnd_message.set_name('GMP','GMP_ROUTING_ACT_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Routing Opeartion/Activity deleted';
        return_status := -1 ;
        EXIT ;
      ELSIF (structure_tab(structure_size).opm_resource_change <>
            structure_tab(structure_size).aps_resource_sum) THEN
        fnd_message.set_name('GMP','GMP_RSRC_MISMATCH');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Routing resources added or deleted. Details of the batch will NOT be synchronized.' ;
        return_status := -1 ;
        EXIT ;
      ELSIF (structure_tab(structure_size).opm_oper_sum <>
            structure_tab(structure_size).aps_oper_sum ) THEN
        fnd_message.set_name('GMP','GMP_OPERATION_MISMATCH');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Routing steps added or deleted. Details of the batch will NOT be synchronized.' ;
        return_status := -1 ;
        EXIT ;
      ELSIF (structure_tab(structure_size).opm_activity_sum <>
            structure_tab(structure_size).aps_activity_sum) THEN
        fnd_message.set_name('GMP','GMP_ACTIVITY_MISMATCH');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Routing activity added or deleted. Details of the batch will NOT be synchronized.' ;
        return_status := -1 ;
        EXIT ;
      ELSIF (structure_tab(structure_size).rtg_detail_change < 0) THEN
        fnd_message.set_name('GMP','GMP_OPERATION_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Details of a step have changed. Details of the batch will NOT be synchronized.' ;
        return_status := -1 ;
        EXIT ;
      ELSIF (structure_tab(structure_size).rtg_oper_change < 0) THEN
        fnd_message.set_name('GMP','GMP_OPERATION_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Details of a step have changed. Details of the batch will NOT be synchronized.' ;
        return_status := -1 ;
        EXIT ;
      ELSIF (structure_tab(structure_size).rtg_activity_change < 0) THEN
        fnd_message.set_name('GMP','GMP_ROUTING_ACT_CHANGED');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' An activity in the routing has changed. Details of the batch will NOT be synchronized.';
        return_status := -1 ;
        EXIT ;
      ELSIF (structure_tab(structure_size).opm_resource_change < 0) THEN
   -- MEssage is OK
        fnd_message.set_name('GMP','GMP_ROUTING_CHANGED2');
        fnd_msg_pub.add ;
        e_msg := e_msg || ' Routing resources have changed. Details of the batch will NOT be synchronized.' ;
        return_status := -1 ;
        EXIT ;
      ELSE
        return_status := 0 ;
      END IF ;

      structure_size := structure_size + 1;
   END LOOP;
   CLOSE cur_structure;
   time_stamp;

   structure_size := structure_size - 1;
   log_message('Structure size is = ' || to_char(structure_size)) ;

   struc_size := structure_size ;  /*B3583620 */
  EXCEPTION
    WHEN OTHERS THEN
     return_status := -91;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','valildate_structure');
     e_msg := e_msg || ' Validation Failure '||TO_CHAR(SQLCODE) || ': '||SQLERRM;
END validate_structure ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    log_message                                                          |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM+=========================================================================+
*/
PROCEDURE log_message(
  pbuff  VARCHAR2)
IS
BEGIN
    fnd_file.put_line(fnd_file.log, pbuff);
END log_message;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    time_stamp                                                           |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM+=========================================================================+
*/
PROCEDURE time_stamp IS

  cur_time VARCHAR2(25) ;
BEGIN
  cur_time := NULL ;

   SELECT to_char(sysdate,'DD-MON-RRRR HH24:MI:SS')
   INTO cur_time FROM sys.dual ;

   log_message(cur_time);
  EXCEPTION
    WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','time_stamp');
     e_msg := e_msg || ' time_stamp Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
END time_stamp ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    update_activity_offsets  (Bug # 3679906)                             |
REM| DESCRIPTION                                                             |
REM|    This procedure is called by update_batches and also by the           |
REM|      new batch/reschedule forms  to update the activity                 |
REM|    offsets for each of the batch                                        |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM+=========================================================================+
*/
PROCEDURE update_activity_offsets ( batch_id IN NUMBER) IS

TYPE offset_rec IS RECORD(
batchstep_id           NUMBER(20),
batchstep_no           NUMBER(10),
batchstep_activity_id  NUMBER(20),
activity               VARCHAR2(16),
offset_interval        NUMBER,
oprn_line_id           NUMBER(20),
actual_usage           NUMBER ,
start_date             VARCHAR2(30),
completion_date        VARCHAR2(30),
prev_act_offset        NUMBER(15),
final_offset           NUMBER
);

TYPE offset_tbl IS TABLE OF offset_rec INDEX by BINARY_INTEGER;
offset_tab offset_tbl;

TYPE batch_activity_cur IS REF CURSOR;
c_batch_dtl     batch_activity_cur;

 v_batch_cursor    VARCHAR2(15000) ;
 v_batch_id        NUMBER;
 act_count         NUMBER;
 p                 NUMBER;
 batch_size        NUMBER;

BEGIN

 v_batch_cursor := NULL;
 p              := 0;
 v_batch_id     := batch_id;
 act_count      := 1;
 batch_size     := 1;

        v_batch_cursor :=  ' SELECT batchstep_id '
        ||' batchstep_no,     '
        ||' batchstep_activity_id activity_id, '
        ||' activity,         '
        ||' offset_interval orig_offset, '
        ||' oprn_line_id, '
        ||' actual_usage, '
        ||' to_char(plan_start_date,'||''''||'DD-MON-YYYY HH24:MI:SS'||''''||') start_date, '
        ||' to_char(plan_cmplt_date,'||''''||'DD-MON-YYYY HH24:MI:SS'||''''||') completion_date, '
        ||' DECODE( sign(batchstep_no - NVL((lag(batchstep_no,1) over(order by batchstep_id)),0) '
        ||'         ),-1,0,1,0,(lag(actual_usage,1) over(order by batchstep_id)) ) prev_act_offset, '
        ||' (SUM(actual_usage) '
        ||' OVER (PARTITION BY batchstep_no order by batchstep_no '
        ||' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - actual_usage) final_offset '
        ||' FROM ( '
        ||'   SELECT distinct   '
        ||'    gsa.batchstep_id, '
        ||'    gbs.batchstep_no, '
        ||'    gsa.batchstep_activity_id, '
        ||'    gsa.activity,  '
        ||'    gsa.offset_interval, '
        ||'    nvl(gsa.oprn_line_id,0) oprn_line_id,  '
        ||'    gsa.plan_start_date, '
        ||'    gsa.plan_cmplt_date, '
        ||'    DECODE(nvl(gsa.sequence_dependent_ind,0),1,1,0) , '
        ||'    max((gsr.plan_rsrc_usage/gsr.plan_rsrc_count)) actual_usage '
        ||'    FROM gme_batch_step_activities gsa,'
        ||'           gme_batch_step_resources gsr,'
        ||'           gme_batch_steps gbs '
        ||'    WHERE gsa.batch_id = :p_batch_id '
        ||'      AND gbs.batch_id = gsa.batch_id '
        ||'      AND gsr.batch_id = gsa.batch_id '
        ||'      AND gsa.delete_mark = 0 '
        ||'      AND gbs.delete_mark = 0 '
        ||'      AND gbs.step_status = 1 '
        ||'      AND gsa.batchstep_id = gbs.batchstep_id '
        ||'      AND gsr.batchstep_activity_id = gsa.batchstep_activity_id '
        ||'      AND gsr.prim_rsrc_ind = 1 '
        ||'    GROUP BY '
        ||'     gsa.batchstep_id, '
        ||'     gbs.batchstep_no, '
        ||'     gsa.batchstep_activity_id, '
        ||'     gsa.activity,  '
        ||'     gsa.offset_interval, '
        ||'     gsa.oprn_line_id, '
        ||'     gsa.plan_start_date, '
        ||'     gsa.plan_cmplt_date, '
        ||'     DECODE(nvl(gsa.sequence_dependent_ind,0),1,1,0) '
        ||'     ORDER BY gbs.batchstep_no, '
        ||'     DECODE(nvl(gsa.sequence_dependent_ind,0),1,1,0)  DESC, '
        ||'     gsa.offset_interval, gsa.activity, nvl(gsa.oprn_line_id,0) '
        ||'     ) ';

       OPEN c_batch_dtl FOR v_batch_cursor USING v_batch_id ;
       LOOP
           FETCH  c_batch_dtl INTO offset_tab(act_count);
           EXIT WHEN  c_batch_dtl%NOTFOUND ;
           act_count := act_count + 1;
       END LOOP;
       CLOSE c_batch_dtl ;

       batch_size := act_count - 1;

       FOR p IN 1..batch_size
       LOOP
        UPDATE gme_batch_step_activities
         SET offset_interval = offset_tab(p).final_offset
        WHERE batch_id = v_batch_id
          AND batchstep_id = offset_tab(p).batchstep_id
          AND batchstep_activity_id = offset_tab(p).batchstep_activity_id
          AND oprn_line_id = offset_tab(p).oprn_line_id;
       END LOOP;

     COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
       fnd_msg_pub.add_exc_msg('gmp_aps_writer','update_activity_offsets');
       e_msg := e_msg || ' update_activity_offsets Failure '|| TO_CHAR(SQLCODE)
                ||': '||SQLERRM;

END update_activity_offsets;

 /*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    update_batches         (Bug # 3679906)                               |
REM| DESCRIPTION                                                             |
REM|    This procedure is called by the concurernt program for all the       |
REM|    batches to make GME batches in sync with APS suggestions             |
REM|    which in turn calls the  update_activity_offsets to update activity  |
REM|    offsets in each btach once the APS engine has completed.             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM+=========================================================================+
*/
PROCEDURE update_batches IS

TYPE batch_fet_cur IS REF CURSOR;
c_batch_id_cur     batch_fet_cur;

v_batch_sql    VARCHAR2(4000) ;
m_batch_id     NUMBER;

BEGIN

 v_batch_sql := NULL;

    v_batch_sql := ' SELECT batch_id FROM gme_batch_header '
    || ' WHERE delete_mark = 0 AND batch_status IN (1,2) ';

    OPEN c_batch_id_cur FOR v_batch_sql ;
    LOOP
      FETCH  c_batch_id_cur INTO m_batch_id;
      EXIT WHEN  c_batch_id_cur%NOTFOUND ;

      update_activity_offsets (m_batch_id);

    END LOOP;
    CLOSE c_batch_id_cur ;

END update_batches;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    Insert_charges                                                       |
REM| DESCRIPTION                                                             |
REM|    This procedure Deletes/Inserts the pending step charges              |
REM| HISTORY                                                                 |
REM| Rajesh Patangya                                                         |
REM+=========================================================================+
*/
PROCEDURE insert_charges (
  pbatch_id     IN NUMBER,
  pgroup_id     IN NUMBER,
  pheader_id    IN NUMBER,
  return_status OUT NOCOPY NUMBER)
IS

BEGIN
   BEGIN
   -- NOTE: The steps wll not be having activity Sequence Number ??
   -- For WIP steps No deletes
     DELETE from GME_BATCH_STEP_CHARGES
     WHERE batch_id = pbatch_id
     AND BATCHSTEP_ID IN ( SELECT batchstep_id
                           FROM gme_batch_steps
                           WHERE batch_id = pbatch_id
                           AND step_status = 1 );
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
     NULL ;
    WHEN OTHERS THEN
     return_status := -90;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','Insert_charges');
     e_msg := e_msg || ' Delete Charge Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
   END ;

   -- WIP steps needs to be populated with activity_seq Number
/* mattt remember the case where we have more than one activity involved
   in the charge hence you will get two rows back here. we need to just use
   the first activity where charegeble resources exist
   Hence Minmimum activity seq Number is taken  */
--     UPDATE GME_BATCH_STEP_CHARGES
--     set ACTIVITY_SEQUENCE_NUMBER = (SELECT min(gsa.sequence_dependent_ind)
--         FROM gme_batch_step_activities gsa,
--              gme_batch_step_resources gsr,
--              gme_batch_steps gbs
--         WHERE gsa.batchstep_id = GME_BATCH_STEP_CHARGES.batchstep_id
--           AND gsa.batchstep_id = gbs.batchstep_id
--           AND gsa.batchstep_id = gbs.batchstep_id
--           AND gsr.batch_id = gsa.batch_id
--           AND gsr.batchstep_activity_id = gsa.batchstep_activity_id
--           AND gsr.resources = GME_BATCH_STEP_CHARGES.resources
--           AND gbs.batch_id = pbatch_id
--           AND gbs.step_status = 2 )
--     WHERE batch_id = pbatch_id  ;

    -- For WIP steps No inserts
           INSERT INTO GME_BATCH_STEP_CHARGES
           (
            BATCH_ID,
            BATCHSTEP_ID,
            ACTIVITY_SEQUENCE_NUMBER,
            RESOURCES,
            CHARGE_NUMBER,
            CHARGE_QUANTITY,
            PLAN_START_DATE,
            PLAN_CMPLT_DATE,
            LAST_UPDATE_LOGIN,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            CREATION_DATE,
            CREATED_BY
           )
    SELECT gad.wip_entity_id,
           gbs.batchstep_id,        -- Operation Id
           gad.schedule_seq_num,    -- Activity Number
           crd.resources ,
           gad.charge_number,
           gad.required_quantity,
           gad.start_date,
           gad.completion_date,
           gad.last_update_login,
           gad.last_updated_by,
           gad.last_update_date,
           gad.creation_date,
           gad.created_by
           FROM  gmp_aps_output_dtl gad,
                 gmp_aps_output_tbl gao,
                 gme_batch_steps gbs,
                 cr_rsrc_dtl crd
           WHERE gad.parent_header_id = gao.header_id
             AND gad.group_id = gao.process_id
             AND gad.organization_id = gao.organization_id
             AND gad.wip_entity_id = pbatch_id
             AND gao.process_id = pgroup_id
             AND gao.header_id =  pheader_id
             AND gao.batch_id = gad.wip_entity_id
             AND gad.load_type = 10
             AND gad.resource_id_new = crd.resource_id
             AND gad.organization_id = crd.organization_id
             AND gbs.batchstep_no = gad.operation_seq_num
             AND gbs.batch_id = gao.batch_id
             AND gbs.delete_mark = 0
             AND gbs.step_status = 1  ;   -- Pending steps

     return_status := 1 ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     return_status := 1 ;
    WHEN OTHERS THEN
     return_status := -90;
     fnd_msg_pub.add_exc_msg('gmp_aps_writer','Insert_charges');
     e_msg := e_msg || ' Insert_charges Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM;
END Insert_charges ;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    gmp_debug_message                                                    |
REM| DESCRIPTION                                                             |
REM|    This procedure is created to enable more debug messages              |
REM| HISTORY                                                                 |
REM|    Vpedarla created this procedure                         |
REM+=========================================================================+
*/
PROCEDURE gmp_debug_message(pBUFF  IN  VARCHAR2) IS
BEGIN
   IF (l_debug = 'Y') then
        LOG_MESSAGE(pBUFF);
   END IF;
END gmp_debug_message;

END gmp_aps_writer;

/
